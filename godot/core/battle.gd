class_name Battle
extends RefCounted
## Headless turn flow (GDD §3, §12, §13.1, §14). Ported from the HTML prototype.
## Order in a turn: start effects -> AP -> end effects -> due Surges (which repaint).

signal event_emitted(e: Dictionary)

const AP_PER_TURN := 2
const VOIDSCAR_FROM_ROUND := 6

var board: Board
var monsters := {}                  # id -> Monster
var roster: Array[StringName] = []  # fixed tie-break order
var order: Array[StringName] = []   # this round's turn order
var order_idx := 0
var turn_owner: StringName = &""
var ap := 0
var round_number := 1
var over := false
var winner: StringName = &""
var events: Array[Dictionary] = []
var _gid := 0


func _init(p_board: Board, p_monsters: Array[Monster]) -> void:
	board = p_board
	for m in p_monsters:
		monsters[m.id] = m
		roster.append(m.id)
		board.occupants[m.pos] = m.id


func _emit(e: Dictionary) -> void:
	events.append(e)
	event_emitted.emit(e)


func begin() -> void:
	_sort_order()
	order_idx = 0
	_start_turn(order[0])


# ---------- effective stats ----------

enum Stat { MOVE, INIT, RANGE }

func effective_stat(m: Monster, stat: Stat) -> float:
	var v: float = float(m.base_move) if stat == Stat.MOVE else (m.initiative if stat == Stat.INIT else 0.0)
	var sq := board.at(m.pos)
	if sq.zone != null:
		for e in sq.zone["def"].effective(sq.zone["level"], sq.attunement):
			match e["tag"]:
				ZoneEffect.Tag.SLOW:
					if stat == Stat.MOVE: v -= e["value"]
				ZoneEffect.Tag.DRAIN_INIT:
					if stat == Stat.INIT: v -= e["value"]
				ZoneEffect.Tag.DRAIN_RANGE:
					if stat == Stat.RANGE: v -= e["value"]
	if stat == Stat.RANGE and sq.elevated:
		v += 1
	return v if stat == Stat.RANGE else maxf(0.0, v)


func skill_range(m: Monster, skill: SkillDef) -> int:
	return maxi(1, skill.range + int(effective_stat(m, Stat.RANGE)))


## Squares `m` can reach with `move_range` (rubble costs 2; props, monsters, pending Surges block).
func reachable(m: Monster, move_range: int) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	var seen := {m.pos: true}
	var queue: Array = [[m.pos, 0]]
	while not queue.is_empty():
		var cur: Array = queue.pop_front()
		var cp: Vector2i = cur[0]
		var d: int = cur[1]
		if d >= move_range:
			continue
		for n in board.neighbors(cp):
			if seen.has(n):
				continue
			var sq := board.at(n)
			if sq.object != null or board.occupants.has(n) or sq.surge != null:
				continue
			var cost := 2 if sq.ground == Square.GroundType.RUBBLE else 1
			if d + cost > move_range:
				continue
			seen[n] = true
			out.append(n)
			queue.append([n, d + cost])
	return out


func has_charging(owner: StringName) -> bool:
	for sq: Square in board.all_squares():
		if sq.surge != null and sq.surge["owner"] == owner:
			return true
	return false


# ---------- player/AI actions ----------

func can_act(who: StringName) -> bool:
	return not over and turn_owner == who and ap >= 1


func move(who: StringName, to: Vector2i) -> bool:
	if not can_act(who):
		return false
	var m: Monster = monsters[who]
	if not reachable(m, int(effective_stat(m, Stat.MOVE))).has(to):
		return false
	board.occupants.erase(m.pos)
	m.pos = to
	board.occupants[to] = who
	ap -= 1
	_emit({"type": &"moved", "who": who, "to": to})
	return true


func can_cast(who: StringName, skill: SkillDef) -> bool:
	if not can_act(who):
		return false
	var m: Monster = monsters[who]
	if m.cooldowns.get(skill.id, 0) > 0:
		return false
	return not (skill.kind == SkillDef.Kind.SURGE and has_charging(who))


## Cells for a placement, or empty if illegal.
func placement_cells(who: StringName, skill: SkillDef, orient_idx: int, anchor: Vector2i) -> Array[Vector2i]:
	var m: Monster = monsters[who]
	var orients := skill.orientations()
	return board.valid_placement(skill.placement(), m.pos, skill_range(m, skill),
			orients[orient_idx], anchor)


## Every legal placement of `skill` for `who`: [{oi, anchor, cells}].
func all_placements(who: StringName, skill: SkillDef) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var orients := skill.orientations()
	for oi in orients.size():
		for y in board.size:
			for x in board.size:
				var cells := placement_cells(who, skill, oi, Vector2i(x, y))
				if not cells.is_empty():
					out.append({"oi": oi, "anchor": Vector2i(x, y), "cells": cells})
	return out


func cast(who: StringName, skill: SkillDef, orient_idx: int, anchor: Vector2i) -> bool:
	if not can_cast(who, skill):
		return false
	var cells := placement_cells(who, skill, orient_idx, anchor)
	if cells.is_empty():
		return false
	_gid += 1
	var result := Rules.cast(board, who, skill, cells, "g%d" % _gid)
	monsters[who].cooldowns[skill.id] = skill.cooldown
	ap -= 1
	_emit({"type": &"cast", "who": who, "skill": skill.id, "cells": cells, "result": result})
	return true


func end_turn() -> void:
	if over:
		return
	var who := turn_owner
	_end_of_turn_fx(who)
	if over:
		return
	_apply_events(Rules.fire_due(board, who))
	if over:
		return
	order_idx += 1
	if order_idx >= order.size():
		_end_round()
	else:
		_start_turn(order[order_idx])


# ---------- turn flow ----------

func _sort_order() -> void:
	var alive: Array[StringName] = []
	for id in roster:
		if monsters[id].is_alive():
			alive.append(id)
	alive.sort_custom(func(a: StringName, b: StringName) -> bool:
		var ia := effective_stat(monsters[a], Stat.INIT)
		var ib := effective_stat(monsters[b], Stat.INIT)
		if ia != ib:
			return ia > ib
		return roster.find(a) < roster.find(b))
	order = alive


func _start_turn(who: StringName) -> void:
	if over:
		return
	turn_owner = who
	ap = AP_PER_TURN
	var m: Monster = monsters[who]
	for k in m.cooldowns.keys():
		if m.cooldowns[k] > 0:
			m.cooldowns[k] -= 1
	_emit({"type": &"turn_started", "who": who})
	if board.at(m.pos).ground == Square.GroundType.VOIDSCAR:
		_hurt(who, 1, "Voidscar")
		if over:
			return
	_start_of_turn_fx(m)


func _end_round() -> void:
	round_number += 1
	var faded := Rules.tick_zones(board)
	if faded > 0:
		_emit({"type": &"zones_faded", "count": faded})
	_late_game_hazard()
	_sort_order()
	order_idx = 0
	_emit({"type": &"round_started", "round": round_number, "first": order[0]})
	_start_turn(order[0])


func _start_of_turn_fx(m: Monster) -> void:
	var sq := board.at(m.pos)
	if sq.zone == null:
		return
	for e in sq.zone["def"].effective(sq.zone["level"], sq.attunement):
		if over:
			return
		if e["tag"] == ZoneEffect.Tag.PUSH:
			_displace(m, sq, true)
		elif e["tag"] == ZoneEffect.Tag.PULL:
			_displace(m, sq, false)


func _end_of_turn_fx(who: StringName) -> void:
	var sq := board.at(monsters[who].pos)
	if sq.ground == Square.GroundType.LAVA:
		_hurt(who, sq.lava_level, "Lava")


# ---------- displacement (GDD §12) ----------

func patch_center(sq: Square) -> Variant:
	var sum := Vector2.ZERO
	var n := 0
	for q: Square in board.all_squares():
		if q.zone != null and q.zone["gid"] == sq.zone["gid"] and q.zone["def"].id == sq.zone["def"].id:
			sum += Vector2(q.pos)
			n += 1
	return sum / n if n > 0 else null


func _displace(m: Monster, sq: Square, push: bool) -> void:
	var c = patch_center(sq)
	if c == null:
		return
	var v: Vector2 = c - Vector2(m.pos)
	if push:
		v = -v
	if maxf(absf(v.x), absf(v.y)) < 0.5:
		return
	var step := Vector2i.ZERO
	if absf(v.x) >= absf(v.y):
		step.x = int(signf(v.x))
	else:
		step.y = int(signf(v.y))
	var target := m.pos + step
	if not board.in_bounds(target):
		_emit({"type": &"pinned", "who": m.id})
		return
	var tsq := board.at(target)
	if tsq.object != null:
		if push:
			_emit({"type": &"collision", "who": m.id, "prop": tsq.object["name"]})
			_hurt(m.id, 1, "Collision")
		return
	if board.occupants.has(target):
		return
	board.occupants.erase(m.pos)
	m.pos = target
	board.occupants[target] = m.id
	_emit({"type": &"displaced", "who": m.id, "to": target, "push": push})


# ---------- damage ----------

func _apply_events(evs: Array[Dictionary]) -> void:
	for e in evs:
		_emit(e)
		if e["type"] == &"damage" and not over:
			_hurt(e["target"], e["amount"], e["source"], false)


func _hurt(id: StringName, amount: int, source: String, announce: bool = true) -> void:
	var m: Monster = monsters[id]
	if not m.is_alive():
		return
	m.hp = maxi(0, m.hp - amount)
	if announce:
		_emit({"type": &"damage", "target": id, "amount": amount, "source": source})
	if m.hp == 0:
		board.occupants.erase(m.pos)
		_emit({"type": &"slain", "who": id})
		var alive: Array[StringName] = []
		for k in roster:
			if monsters[k].is_alive():
				alive.append(k)
		if alive.size() <= 1:
			over = true
			winner = alive[0] if alive.size() == 1 else &""
			_emit({"type": &"battle_over", "winner": winner})


# ---------- anti-stalling (GDD §13.1) ----------

func _late_game_hazard() -> void:
	if round_number < VOIDSCAR_FROM_ROUND:
		return
	var best: Square = null
	var best_score := -1
	for sq: Square in board.all_squares():
		if sq.ground == Square.GroundType.VOIDSCAR or sq.object != null \
				or board.occupants.has(sq.pos) or sq.surge != null:
			continue
		var score := 0
		for m: Monster in monsters.values():
			if m.is_alive():
				score += Board.manhattan(sq.pos, m.pos)
		if score > best_score:
			best_score = score
			best = sq
	if best != null:
		best.ground = Square.GroundType.VOIDSCAR
		best.lava_level = 1
		best.attunement = Aspect.Type.NONE
		best.zone = null
		_emit({"type": &"voidscar", "pos": best.pos})
