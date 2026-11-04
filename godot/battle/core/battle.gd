class_name Battle
extends RefCounted
## Headless battle (GDD §3, §4, §9.3, §11, §12, §14). No nodes; the view listens to `event_emitted`.
##
## A turn: due Surges of the active monster fire → start-of-turn ground (Voidscar, Blight)
## → 2 AP → end of turn: zone push/pull, then Lava. Round end: zones and timed ground tick,
## burning Trees burn down, brittle props crumble, Voidscar spreads, the queue is rebuilt.

signal event_emitted(e: Dictionary)

const AP_PER_TURN := 2
const EXTRA_TURN_INIT_PENALTY := 3.0
## Round-1 initiative of the side that struck first on the overworld (gdd_overworld §6.2).
const AMBUSH_BONUS := 1.0

enum Stat { MOVE, INIT, RANGE }

var board: Board
var monsters := {}                  # id -> Monster
var roster: Array[StringName] = []  # stable order (tie-break of last resort)
var queue: Array[Dictionary] = []   # this round: [{id, init, base, side, ghost}]
var queue_idx := 0
var turn_owner: StringName = &""
var ap := 0
var round_number := 1
var over := false
var winner_side := -1
var voidscar_from := 6
var ambush_side := -1               # side with the round-1 initiative bonus (-1 = nobody)
var events: Array[Dictionary] = []
var _gid := 0
var _tie_side := -1                 # side that wins the next initiative tie (-1 = not decided yet)


func _init(p_board: Board, p_monsters: Array[Monster], p_voidscar_from: int = 6) -> void:
	board = p_board
	voidscar_from = p_voidscar_from
	for m in p_monsters:
		monsters[m.id] = m
		roster.append(m.id)
		board.occupants[m.pos] = m.id


func _emit(e: Dictionary) -> void:
	events.append(e)
	event_emitted.emit(e)


func begin() -> void:
	_build_queue()
	queue_idx = 0
	_emit({"type": &"round_started", "round": round_number, "first": queue[0]["id"]})
	_start_turn(queue[0])


func active() -> Monster:
	return monsters.get(turn_owner)


func allies_of(m: Monster) -> Array[Monster]:
	var out: Array[Monster] = []
	for id in roster:
		var o: Monster = monsters[id]
		if o.side == m.side and o.id != m.id and o.is_alive():
			out.append(o)
	return out


func enemies_of(m: Monster) -> Array[Monster]:
	var out: Array[Monster] = []
	for id in roster:
		var o: Monster = monsters[id]
		if o.side != m.side and o.is_alive():
			out.append(o)
	return out


func monster_at(p: Vector2i) -> Monster:
	var id = board.occupants.get(p)
	return monsters[id] if id != null else null


# ---------- effective stats ----------

func _zone_value(sq: Square, tag: ZoneEffect.Tag) -> int:
	if sq.zone == null:
		return 0
	return sq.zone["def"].value_of(tag, sq.zone["level"], sq.attunement, sq.zone["native"])


func effective_stat(m: Monster, stat: Stat) -> float:
	var sq := board.at(m.pos)
	match stat:
		Stat.MOVE:
			if m.has_passive(&"sure_footed"):
				return float(m.def.move + _zone_value(sq, ZoneEffect.Tag.HASTE))
			return maxf(0.0, m.def.move - _zone_value(sq, ZoneEffect.Tag.SLOW) + _zone_value(sq, ZoneEffect.Tag.HASTE))
		Stat.INIT:
			return maxf(0.1, m.def.initiative + m.prep_init - _zone_value(sq, ZoneEffect.Tag.DRAIN_INIT)
					+ _zone_value(sq, ZoneEffect.Tag.QUICKEN))
	# RANGE modifier
	return float((1 if sq.elevated else 0) - _zone_value(sq, ZoneEffect.Tag.DRAIN_RANGE)
			+ _zone_value(sq, ZoneEffect.Tag.EXTEND))


func skill_range(m: Monster, skill: SkillDef) -> int:
	return maxi(1, skill.base_range() + int(effective_stat(m, Stat.RANGE)))


func reach(m: Monster) -> int:
	return maxi(1, m.def.reach + int(effective_stat(m, Stat.RANGE)))


# ---------- movement ----------

func _step_cost(from: Vector2i, to: Vector2i) -> int:
	var a := board.at(from)
	var b := board.at(to)
	if b.ground == Square.GroundType.RUBBLE or (b.elevated and not a.elevated):
		return 2
	return 1


func _thorn_damage(m: Monster, p: Vector2i) -> int:
	var sq := board.at(p)
	if sq.ground != Square.GroundType.THORNBED or m.has_passive(&"thornwalker"):
		return 0
	return sq.level


## Reachable squares with the least Thornbed damage on the way: {Vector2i: {cost, thorn}}.
## Props, monsters and pending Surges block (Spirit / Phasing pass through props but can't stop on them).
func move_options(m: Monster, budget: int = -1) -> Dictionary:
	if budget < 0:
		budget = int(effective_stat(m, Stat.MOVE))
	var best := {}                       # Vector2i -> {cost, thorn}
	var frontier: Array = [[m.pos, 0, 0]]
	var seen := {}                       # "x,y,cost" -> thorn
	while not frontier.is_empty():
		var cur: Array = frontier.pop_front()
		var p: Vector2i = cur[0]
		var cost: int = cur[1]
		var thorn: int = cur[2]
		for n in board.neighbors(p):
			var nsq := board.at(n)
			if board.occupants.has(n) or nsq.surge != null:
				continue
			var passing_prop: bool = nsq.object != null
			if passing_prop and not m.phases():
				continue
			var c := cost + _step_cost(p, n)
			if c > budget:
				continue
			var t := thorn + _thorn_damage(m, n)
			var key := "%d,%d,%d" % [n.x, n.y, c]
			if seen.has(key) and seen[key] <= t:
				continue
			seen[key] = t
			frontier.append([n, c, t])
			if not passing_prop and n != m.pos:
				if not best.has(n) or t < best[n]["thorn"] or (t == best[n]["thorn"] and c < best[n]["cost"]):
					best[n] = {"cost": c, "thorn": t}
	return best


func reachable(m: Monster) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for p in move_options(m):
		out.append(p)
	return out


# ---------- action checks ----------

func can_act(who: StringName) -> bool:
	return not over and turn_owner == who and ap >= 1


func has_charging(owner: StringName) -> bool:
	for sq: Square in board.all_squares():
		if sq.surge != null and sq.surge["owner"] == owner:
			return true
	return false


func can_cast(who: StringName, skill: SkillDef) -> bool:
	if not can_act(who):
		return false
	return not (skill.kind == SkillDef.Kind.SURGE and has_charging(who))


## Why a skill can't be used at all right now ("" = usable).
func cast_error(who: StringName, skill: SkillDef) -> String:
	if over:
		return "the battle is over"
	if turn_owner != who:
		return "not this monster's turn"
	if ap < 1:
		return "no AP left"
	if skill.kind == SkillDef.Kind.SURGE and has_charging(who):
		return "this monster already has a charging Surge (one at a time)"
	return ""


## Why a placement is illegal ("" = legal). Same checks as placement_cells, in readable form.
func placement_error(who: StringName, skill: SkillDef, orient_idx: int, anchor: Vector2i) -> String:
	var e := cast_error(who, skill)
	if e != "":
		return e
	var m: Monster = monsters[who]
	if skill.kind == SkillDef.Kind.SURGE and skill.twist == SkillDef.Twist.RING:
		return "" if not board.neighbors(m.pos).is_empty() else "no free neighbours"
	var orients := skill.orientations()
	if orients.is_empty():
		return "this skill has no shape"
	var cells := Shapes.footprint(orients[effective_orientation(m, skill, orient_idx)], anchor)
	match skill.twist:
		SkillDef.Twist.POUNCE:
			if Board.manhattan(m.pos, anchor) != 1:
				return "Pounce: the anchor (centre cell) must be right next to %s" % m.display_name()
		SkillDef.Twist.TRAIL:
			if not _is_trail(m.pos, cells):
				return "Trail: the line must start next to %s and point straight away from it" % m.display_name()
		_:
			if not board.in_bounds(anchor):
				return "the anchor is off the board"
			var r := skill_range(m, skill)
			var d := Board.manhattan(m.pos, anchor)
			if d > r:
				return "out of range: anchor is %d away, range is %d" % [d, r]
	for c in cells:
		if not board.in_bounds(c):
			return "the shape doesn't fit on the board"
	var allow_flammable := skill.kind == SkillDef.Kind.GROUND and skill.aspect == Aspect.Type.FORCE
	for c in cells:
		var sq := board.at(c)
		match skill.placement():
			Board.Placement.PROP:
				if sq.object != null:
					return "[%d,%d] already holds a %s — props need empty squares" % [c.x, c.y, sq.object["name"]]
				if board.occupants.has(c):
					return "[%d,%d] is occupied by %s — props need empty squares" % [c.x, c.y, monster_at(c).display_name()]
				if sq.surge != null:
					return "[%d,%d] holds a charging Surge — props need empty squares" % [c.x, c.y]
			Board.Placement.GROUND:
				if sq.object != null and not (allow_flammable and sq.has_tag("flammable")):
					return "[%d,%d] holds a %s — ground skills need prop-free squares%s" % [c.x, c.y,
							sq.object["name"], " (only Force Fields may target Trees)" if sq.has_tag("flammable") else ""]
	if cells.has(m.pos) and skill.kind == SkillDef.Kind.PROP:
		return "can't raise a Wall on your own square"
	return ""


## Cells of a placement or empty if illegal (range, shape, twists, placement rule).
func placement_cells(who: StringName, skill: SkillDef, orient_idx: int, anchor: Vector2i) -> Array[Vector2i]:
	var none: Array[Vector2i] = []
	var m: Monster = monsters[who]
	var cells: Array[Vector2i] = []
	if skill.kind == SkillDef.Kind.SURGE and skill.twist == SkillDef.Twist.RING:
		cells = board.neighbors(m.pos)
		return cells if not cells.is_empty() else none
	var orients := skill.orientations()
	if orients.is_empty():
		return none
	var o: Dictionary = orients[effective_orientation(m, skill, orient_idx)]
	cells = Shapes.footprint(o, anchor)
	match skill.twist:
		SkillDef.Twist.POUNCE:
			if Board.manhattan(m.pos, anchor) != 1:
				return none
		SkillDef.Twist.TRAIL:
			if not _is_trail(m.pos, cells):
				return none
		_:
			if not board.in_bounds(anchor) or Board.manhattan(m.pos, anchor) > skill_range(m, skill):
				return none
	var allow_flammable := skill.kind == SkillDef.Kind.GROUND and skill.aspect == Aspect.Type.FORCE
	if not board.cells_allowed(skill.placement(), cells, allow_flammable):
		return none
	if cells.has(m.pos) and skill.kind == SkillDef.Kind.PROP:
		return none
	return cells


## Shapes are fixed in battle (the skill's own orientation); only Adaptive may pick another.
func effective_orientation(m: Monster, skill: SkillDef, requested: int) -> int:
	var n := skill.orientations().size()
	if n == 0:
		return 0
	if m.has_passive(&"adaptive"):
		return posmod(requested, n)
	return clampi(skill.orientation, 0, n - 1)


func can_rotate(who: StringName, skill: SkillDef) -> bool:
	return monsters[who].has_passive(&"adaptive") and skill.orientations().size() > 1


## Trail: a straight line that starts next to the caster and leads away from it.
func _is_trail(caster: Vector2i, cells: Array[Vector2i]) -> bool:
	var same_x := true
	var same_y := true
	var nearest := 99
	for c in cells:
		same_x = same_x and c.x == caster.x
		same_y = same_y and c.y == caster.y
		nearest = mini(nearest, Board.manhattan(caster, c))
		if c == caster:
			return false
	return (same_x or same_y) and nearest == 1


## Every legal placement of a skill: [{oi, anchor, cells}] (Ring: a single one).
func all_placements(who: StringName, skill: SkillDef) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	if skill.kind == SkillDef.Kind.SURGE and skill.twist == SkillDef.Twist.RING:
		var cells := placement_cells(who, skill, 0, monsters[who].pos)
		if not cells.is_empty():
			out.append({"oi": 0, "anchor": monsters[who].pos, "cells": cells})
		return out
	var n := skill.orientations().size()
	var choices: Array[int] = []
	if can_rotate(who, skill):
		for oi in n:
			choices.append(oi)
	else:
		choices.append(effective_orientation(monsters[who], skill, 0))
	for oi in choices:
		for y in board.size:
			for x in board.size:
				var cells := placement_cells(who, skill, oi, Vector2i(x, y))
				if not cells.is_empty():
					out.append({"oi": oi, "anchor": Vector2i(x, y), "cells": cells})
	return out


# ---------- actions ----------

func move(who: StringName, to: Vector2i) -> bool:
	if not can_act(who):
		return false
	var m: Monster = monsters[who]
	var opts := move_options(m)
	if not opts.has(to):
		return false
	var full: bool = opts[to]["cost"] >= int(effective_stat(m, Stat.MOVE))
	board.occupants.erase(m.pos)
	m.pos = to
	board.occupants[to] = who
	ap -= 1
	if full and m.has_passive(&"momentum"):
		m.momentum_bonus = 1
	_emit({"type": &"moved", "who": who, "to": to})
	if opts[to]["thorn"] > 0:
		_hurt(who, opts[to]["thorn"], "Thornbed")
	return true


func cast(who: StringName, skill: SkillDef, orient_idx: int, anchor: Vector2i,
		dir: Vector2i = Vector2i.UP) -> bool:
	if not can_cast(who, skill):
		return false
	var cells := placement_cells(who, skill, orient_idx, anchor)
	if cells.is_empty():
		return false
	var m: Monster = monsters[who]
	if skill.twist == SkillDef.Twist.RING:
		anchor = m.pos
	_gid += 1
	var gid := "g%d" % _gid
	var native := m.has_passive(&"native_ground")
	if skill.kind == SkillDef.Kind.SURGE:
		var lost := 0
		for c in cells:
			var sq := board.at(c)
			if sq.surge != null:
				lost += 1
				continue
			sq.surge = {"owner": who, "type": skill.surge_type, "aspect": skill.aspect,
				"name": skill.display_name, "value": skill.surge_value() + m.momentum_bonus,
				"turns_left": skill.fire_delay(), "dir": dir, "anchor": anchor, "gid": gid,
				"twist": skill.twist, "residue": skill.residue_rounds(), "native": native,
				"painter": m.has_passive(&"painter")}
		m.momentum_bonus = 0
		ap -= 1
		_emit({"type": &"cast", "who": who, "skill": skill.id, "cells": cells, "lost": lost})
		return true
	var result := Rules.cast(board, who, skill, cells, gid, dir, anchor, native)
	ap -= 1
	_emit({"type": &"cast", "who": who, "skill": skill.id, "cells": cells, "result": result})
	return true


## AP cost of a Strike at `target` (2, or 1 with Pack Hunter when an ally is next to the target).
func strike_cost(who: StringName, target: Vector2i) -> int:
	var m: Monster = monsters[who]
	if m.has_passive(&"pack_hunter"):
		for a in allies_of(m):
			if Board.manhattan(a.pos, target) == 1:
				return 1
	return 2


## A legal Strike target: an enemy monster or a prop within Reach, line of sight from Reach 2.
func can_strike(who: StringName, target: Vector2i) -> bool:
	if not can_act(who) or not board.in_bounds(target):
		return false
	var m: Monster = monsters[who]
	if ap < strike_cost(who, target):
		return false
	var d := Board.manhattan(m.pos, target)
	if d < 1 or d > reach(m):
		return false
	var t := monster_at(target)
	var sq := board.at(target)
	if t == null and sq.object == null:
		return false
	if t != null and t.side == m.side:
		return false
	if sq.object != null and sq.has_tag("indestructible"):
		return false
	return d == 1 or has_line_of_sight(m.pos, target)


## Why a Strike at `target` is illegal ("" = legal).
func strike_error(who: StringName, target: Vector2i) -> String:
	if not can_act(who):
		return "no AP left" if turn_owner == who else "not this monster's turn"
	var m: Monster = monsters[who]
	var sq := board.at(target)
	var t := monster_at(target)
	if t == null and sq.object == null:
		return "nothing to hit here"
	if t != null and t.side == m.side:
		return "can't strike your own side"
	if sq.object != null and sq.has_tag("indestructible"):
		return "the %s is indestructible" % sq.object["name"]
	var d := Board.manhattan(m.pos, target)
	if d > reach(m):
		return "out of Reach: %d away, Reach is %d" % [d, reach(m)]
	if ap < strike_cost(who, target):
		return "needs %d AP, %d left" % [strike_cost(who, target), ap]
	if d > 1 and not has_line_of_sight(m.pos, target):
		return "no line of sight (a prop is in the way)"
	return ""


func strike_targets(who: StringName) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for sq: Square in board.all_squares():
		if can_strike(who, sq.pos):
			out.append(sq.pos)
	return out


## Props on squares strictly between a and b block the line (sampled along the segment).
func has_line_of_sight(a: Vector2i, b: Vector2i) -> bool:
	var steps := 24
	for i in range(1, steps):
		var t := float(i) / steps
		var p := Vector2(a).lerp(Vector2(b), t)
		var cell := Vector2i(roundi(p.x), roundi(p.y))
		if cell == a or cell == b:
			continue
		if board.at(cell).object != null:
			return false
	return true


## Expected Strike damage (before the target's own reductions are known to the caller).
func strike_damage(who: StringName, target: Vector2i) -> int:
	var m: Monster = monsters[who]
	var t := monster_at(target)
	var sq := board.at(target)
	if t == null:
		match m.kin():
			MonsterDef.Kin.BEAST, MonsterDef.Kin.SWARM, MonsterDef.Kin.ANCIENT:
				return 2
		return 1
	var dmg := 2 if m.kin() == MonsterDef.Kin.BEAST else 1
	if t.has_passive(&"thick_hide"):
		dmg -= 1
	if sq.zone != null:
		dmg -= sq.zone["def"].strike_shield
	return maxi(0, dmg)


func strike(who: StringName, target: Vector2i, dir: Vector2i = Vector2i.UP) -> bool:
	if not can_strike(who, target):
		return false
	var m: Monster = monsters[who]
	ap -= strike_cost(who, target)
	var t := monster_at(target)
	var dmg := strike_damage(who, target)
	_emit({"type": &"strike", "who": who, "target": target, "amount": dmg})
	if t == null:
		_damage_prop(board.at(target), dmg)
	else:
		if dmg > 0:
			_hurt(t.id, dmg, m.def.strike_name())
		if t.is_alive():
			match m.kin():
				MonsterDef.Kin.SCALED:
					_displace(t, dir, 0)
				MonsterDef.Kin.SPIRIT:
					t.init_penalty_next += 1
	if m.kin() == MonsterDef.Kin.ANCIENT and board.at(target).elevated:
		board.at(target).make_rubble()
		_emit({"type": &"collapse", "pos": target})
	if m.kin() == MonsterDef.Kin.WINGED and m.is_alive():
		_step_away(m, target)
	_check_over()
	return true


func end_turn() -> void:
	if over:
		return
	var m: Monster = monsters.get(turn_owner)
	if m != null and m.is_alive():
		_end_of_turn(m)
	if over:
		return
	_next_turn()


# ---------- turn flow ----------

func _build_queue() -> void:
	var entries: Array[Dictionary] = []
	for id in roster:
		var m: Monster = monsters[id]
		if not m.is_alive():
			if has_charging(id):     # a dead caster's Surges still fire in its slot
				entries.append({"id": id, "init": m.def.initiative, "base": m.def.initiative, "side": m.side, "ghost": true})
			continue
		var eff := maxf(0.1, effective_stat(m, Stat.INIT) - m.init_penalty_next)
		if round_number == 1 and m.side == ambush_side:
			eff += AMBUSH_BONUS
		m.init_penalty_next = 0
		entries.append({"id": id, "init": eff, "base": m.def.initiative, "side": m.side, "ghost": false})
		for k in range(1, m.def.tpr):
			entries.append({"id": id, "init": maxf(0.1, eff - EXTRA_TURN_INIT_PENALTY * k),
				"base": m.def.initiative, "side": m.side, "ghost": false})
	if _tie_side < 0:
		var totals := [0.0, 0.0]
		for e in entries:
			totals[e["side"]] += e["init"]
		_tie_side = 0 if totals[0] <= totals[1] else 1
	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if a["init"] != b["init"]:
			return a["init"] > b["init"]
		if a["base"] != b["base"]:
			return a["base"] > b["base"]
		return roster.find(a["id"]) < roster.find(b["id"]))
	# ties between the sides alternate (GDD §4.3)
	var i := 0
	while i < entries.size() - 1:
		var a: Dictionary = entries[i]
		var b: Dictionary = entries[i + 1]
		if a["init"] == b["init"] and a["base"] == b["base"] and a["side"] != b["side"]:
			if a["side"] != _tie_side:
				entries[i] = b
				entries[i + 1] = a
			_tie_side = 1 - _tie_side
			i += 2
		else:
			i += 1
	queue = entries


func _start_turn(entry: Dictionary) -> void:
	if over:
		return
	turn_owner = entry["id"]
	ap = 0
	var m: Monster = monsters[turn_owner]
	_fire_due_surges(turn_owner)
	if over:
		return
	if entry["ghost"] or not m.is_alive():
		_next_turn()
		return
	var sq := board.at(m.pos)
	if sq.ground == Square.GroundType.VOIDSCAR:
		_hurt(m.id, 1, "Voidscar")
	elif sq.ground == Square.GroundType.BLIGHT and not m.has_passive(&"void_touched"):
		_hurt(m.id, sq.level, "Blight")
	if over:
		return
	if not m.is_alive():
		_next_turn()
		return
	ap = AP_PER_TURN
	m.momentum_bonus = 0
	_emit({"type": &"turn_started", "who": m.id})


func _next_turn() -> void:
	if over:
		return
	queue_idx += 1
	if queue_idx >= queue.size():
		_end_round()
	else:
		_start_turn(queue[queue_idx])


func _end_of_turn(m: Monster) -> void:
	var sq := board.at(m.pos)
	if sq.zone != null:
		var z: Dictionary = sq.zone
		var def: ZoneDef = z["def"]
		if def.has_tag(ZoneEffect.Tag.PUSH):
			_displace(m, z["dir"], def.collision_bonus)
		elif def.has_tag(ZoneEffect.Tag.PULL):
			_displace(m, _step_toward(m.pos, z["anchor"]), def.collision_bonus)
	if not m.is_alive():
		return
	sq = board.at(m.pos)
	if sq.ground == Square.GroundType.LAVA and not m.has_passive(&"heatproof"):
		if not (sq.zone != null and sq.zone["def"].ignores_lava):
			_hurt(m.id, sq.level, "Lava")


func _end_round() -> void:
	round_number += 1
	var faded := Rules.tick_zones(board)
	if faded > 0:
		_emit({"type": &"zones_faded", "count": faded})
	Rules.tick_ground(board)
	for sq: Square in board.all_squares():
		if sq.object == null:
			continue
		if sq.object["burning"]:
			sq.object = null
			sq.clear_ground()
			sq.lay_ground(Square.GroundType.LAVA, 2)
			_emit({"type": &"burned_down", "pos": sq.pos})
		elif sq.has_tag("brittle") and (sq.ground == Square.GroundType.BLIGHT
				or (sq.zone != null and sq.zone["def"].aspect == Aspect.Type.DARK)):
			_damage_prop(sq, 1)
	if over:
		return
	_late_game_hazard()
	_build_queue()
	if queue.is_empty():
		_check_over()
		return
	queue_idx = 0
	_emit({"type": &"round_started", "round": round_number, "first": queue[0]["id"]})
	_start_turn(queue[0])


# ---------- Surges (GDD §9.3, §11.2) ----------

func _fire_due_surges(owner: StringName) -> void:
	var groups := {}                       # gid -> Array[Square]
	for sq: Square in board.all_squares():
		if sq.surge == null or sq.surge["owner"] != owner:
			continue
		sq.surge["turns_left"] -= 1
		if sq.surge["turns_left"] <= 0:
			if not groups.has(sq.surge["gid"]):
				groups[sq.surge["gid"]] = []
			groups[sq.surge["gid"]].append(sq)
	for gid in groups:
		_detonate(groups[gid])
		if over:
			return


func _detonate(squares: Array) -> void:
	var sg: Dictionary = squares[0].surge
	var type: SkillDef.SurgeType = sg["type"]
	_emit({"type": &"surge_fired", "who": sg["owner"], "name": sg["name"],
		"cells": squares.map(func(s: Square): return s.pos)})
	var hits: Array = []                   # [Monster id, damage]
	var debris: Array[Vector2i] = []
	var residue_cells: Array[Square] = []
	var paint_cells: Array[Square] = []
	var collapse_cells: Array[Square] = []
	var struck: Array[StringName] = []
	for sq: Square in squares:
		sq.surge = null
		if type == SkillDef.SurgeType.FLOOD and sq.elevated:
			_emit({"type": &"blanked", "pos": sq.pos})
			continue
		if sq.object != null:
			_surge_hits_prop(sq, type, debris)
			paint_cells.append(sq)
			continue
		var target := monster_at(sq.pos)
		if target != null:
			var dmg := surge_damage_at(sq, sg, target)
			hits.append([target.id, dmg])
			struck.append(target.id)
		if sq.elevated:
			if type == SkillDef.SurgeType.RIFT:
				collapse_cells.append(sq)
			paint_cells.append(sq)
			continue
		residue_cells.append(sq)
		paint_cells.append(sq)
	for h in hits:
		if h[1] > 0:
			_hurt(h[0], h[1], sg["name"])
		else:
			_emit({"type": &"absorbed", "target": h[0]})
	for sq in collapse_cells:
		sq.make_rubble()
		_emit({"type": &"collapse", "pos": sq.pos})
	var gt := _residue_ground(type)
	for sq in residue_cells:
		sq.lay_ground(gt, sg["residue"])
	for sq in paint_cells:
		sq.set_attunement(sg["aspect"])
		if sg["painter"]:
			for n in board.neighbors(sq.pos):
				board.at(n).set_attunement(sg["aspect"])
	_debris(debris)
	# displacement after the damage (Flood pushes, Constrict pulls)
	for id in struck:
		var m: Monster = monsters[id]
		if not m.is_alive():
			continue
		if type == SkillDef.SurgeType.FLOOD:
			_displace(m, sg["dir"], 0)
		elif sg["twist"] == SkillDef.Twist.CONSTRICT:
			_displace(m, _step_toward(m.pos, sg["anchor"]), 0)
	for h in hits:
		var m: Monster = monsters[h[0]]
		if h[1] > 0 and m.is_alive() and m.has_passive(&"skittish"):
			_step_away(m, m.pos)
	_check_over()


## Damage of a pending Surge on a square for a monster standing there (preview-safe, no side effects).
func surge_damage_at(sq: Square, sg: Dictionary, target: Monster = null) -> int:
	if sg["type"] == SkillDef.SurgeType.FLOOD and sq.elevated:
		return 0
	var dmg: int = sg["value"] + Aspect.attunement_mod(sg["aspect"], sq.attunement, sg["native"])
	if sq.zone != null:
		dmg -= _zone_value(sq, ZoneEffect.Tag.SHIELD)
	if target != null:
		for a in allies_of(target):
			if a.has_passive(&"bulwark") and Board.manhattan(a.pos, sq.pos) == 1:
				dmg -= 1
				break
	return maxi(0, dmg)


static func _residue_ground(type: SkillDef.SurgeType) -> Square.GroundType:
	match type:
		SkillDef.SurgeType.FLOOD:
			return Square.GroundType.THORNBED
		SkillDef.SurgeType.RIFT:
			return Square.GroundType.BLIGHT
	return Square.GroundType.LAVA


func _surge_hits_prop(sq: Square, type: SkillDef.SurgeType, debris: Array[Vector2i]) -> void:
	var obj: Dictionary = sq.object
	if sq.has_tag("indestructible"):
		return
	if type == SkillDef.SurgeType.ERUPTION and sq.has_tag("flammable"):
		if not obj["burning"]:
			obj["burning"] = true
			_emit({"type": &"ignite", "pos": sq.pos})
		return
	if type == SkillDef.SurgeType.FLOOD:
		if obj["burning"]:
			obj["burning"] = false
			_emit({"type": &"extinguish", "pos": sq.pos})
		if sq.has_tag("heavy"):
			return
	var dmg := Rules.SURGE_PROP_DAMAGE + (1 if type == SkillDef.SurgeType.RIFT and sq.has_tag("brittle") else 0)
	if _damage_prop(sq, dmg, false):
		debris.append(sq.pos)


## Damages a prop; on 0 HP it shatters (Rubble). Returns true if it shattered.
## With `debris_now` the debris is resolved immediately (otherwise the caller collects it).
func _damage_prop(sq: Square, amount: int, debris_now: bool = true) -> bool:
	if sq.object == null or sq.has_tag("indestructible") or amount <= 0:
		return false
	sq.object["hp"] -= amount
	_emit({"type": &"prop_hit", "pos": sq.pos, "hp": maxi(0, sq.object["hp"])})
	if sq.object["hp"] > 0:
		return false
	sq.object = null
	sq.make_rubble()
	_emit({"type": &"shatter", "pos": sq.pos})
	if debris_now:
		var one: Array[Vector2i] = [sq.pos]
		_debris(one)
	return true


func _debris(origins: Array[Vector2i]) -> void:
	var seen := {}
	for d in origins:
		for n in board.neighbors(d):
			if seen.has(n):
				continue
			seen[n] = true
			var m := monster_at(n)
			if m != null:
				_hurt(m.id, 1, "Debris")
			var nsq := board.at(n)
			if nsq.elevated:
				nsq.make_rubble()
				_emit({"type": &"collapse", "pos": n})


# ---------- displacement (GDD §11.3, §12) ----------

static func _step_toward(from: Vector2i, to: Vector2i) -> Vector2i:
	var v := to - from
	if v == Vector2i.ZERO:
		return Vector2i.ZERO
	if absi(v.x) >= absi(v.y):
		return Vector2i(signi(v.x), 0)
	return Vector2i(0, signi(v.y))


func can_be_displaced(m: Monster) -> bool:
	if m.has_passive(&"immovable"):
		return false
	if m.has_passive(&"deep_roots") and board.at(m.pos).attunement == m.aspect():
		return false
	for a in allies_of(m):
		if a.has_passive(&"counterweight") and Board.manhattan(a.pos, m.pos) == 1:
			return false
	return true


## Moves a monster 1 square by push/pull. Pending Surges don't block displacement —
## pushing someone into a charging Surge is the point (GDD §12).
func _displace(m: Monster, step: Vector2i, collision_bonus: int) -> void:
	if step == Vector2i.ZERO or not m.is_alive() or not can_be_displaced(m):
		return
	var from := m.pos
	var to := from + step
	if not board.in_bounds(to):
		_emit({"type": &"pinned", "who": m.id})
		return
	var tsq := board.at(to)
	if tsq.object != null:
		_emit({"type": &"collision", "who": m.id, "prop": tsq.object["name"]})
		if not tsq.has_tag("heavy"):
			_damage_prop(tsq, 1)
		var dmg := 0 if m.has_passive(&"crashlander") else 1 + collision_bonus
		if m.has_passive(&"thick_hide"):
			dmg -= 1
		if dmg > 0:
			_hurt(m.id, dmg, "Collision")
		return
	var other := monster_at(to)
	if other != null:
		if m.has_passive(&"crashlander"):
			_hurt(other.id, 1, "Collision")
		return
	if tsq.elevated and not board.at(from).elevated:
		return
	var fall := board.at(from).elevated and not tsq.elevated
	board.occupants.erase(from)
	m.pos = to
	board.occupants[to] = m.id
	_emit({"type": &"displaced", "who": m.id, "to": to})
	if fall:
		_hurt(m.id, 1, "Fall")
	var thorn := _thorn_damage(m, to)
	if thorn > 0 and m.is_alive():
		_hurt(m.id, thorn, "Thornbed")


## Free step to the free neighbour farthest from `away_from` (Dive, Skittish). Deterministic.
func _step_away(m: Monster, away_from: Vector2i) -> void:
	var best := m.pos
	var best_score := -999.0
	for n in board.neighbors(m.pos):
		var sq := board.at(n)
		if sq.object != null or board.occupants.has(n) or sq.surge != null:
			continue
		var score := float(Board.manhattan(n, away_from)) - _ground_risk(m, n)
		if score > best_score:
			best_score = score
			best = n
	if best == m.pos:
		return
	board.occupants.erase(m.pos)
	m.pos = best
	board.occupants[best] = m.id
	_emit({"type": &"displaced", "who": m.id, "to": best})
	var thorn := _thorn_damage(m, best)
	if thorn > 0:
		_hurt(m.id, thorn, "Thornbed")


func _ground_risk(m: Monster, p: Vector2i) -> float:
	var sq := board.at(p)
	match sq.ground:
		Square.GroundType.LAVA:
			return 0.0 if m.has_passive(&"heatproof") else float(sq.level)
		Square.GroundType.BLIGHT:
			return 0.0 if m.has_passive(&"void_touched") else float(sq.level)
		Square.GroundType.VOIDSCAR:
			return 1.0
	return 0.0


# ---------- damage ----------

func _hurt(id: StringName, amount: int, source: String) -> void:
	var m: Monster = monsters[id]
	if not m.is_alive() or amount <= 0:
		return
	m.hp = maxi(0, m.hp - amount)
	_emit({"type": &"damage", "target": id, "amount": amount, "source": source})
	if m.hp == 0:
		board.occupants.erase(m.pos)
		_emit({"type": &"slain", "who": id})
		_check_over()


func _check_over() -> void:
	if over:
		return
	var alive := [0, 0]
	for id in roster:
		if monsters[id].is_alive():
			alive[monsters[id].side] += 1
	if alive[0] == 0 or alive[1] == 0:
		over = true
		winner_side = -1 if alive[0] == alive[1] else (0 if alive[0] > 0 else 1)
		_emit({"type": &"battle_over", "winner_side": winner_side})


# ---------- anti-stalling (GDD §13.1) ----------

func _late_game_hazard() -> void:
	if round_number < voidscar_from:
		return
	var best: Square = null
	var best_score := -1
	for sq: Square in board.all_squares():
		if sq.ground == Square.GroundType.VOIDSCAR or sq.object != null \
				or board.occupants.has(sq.pos) or sq.surge != null:
			continue
		var score := 0
		for id in roster:
			var m: Monster = monsters[id]
			if m.is_alive():
				score += Board.manhattan(sq.pos, m.pos)
		if score > best_score:
			best_score = score
			best = sq
	if best != null:
		best.ground = Square.GroundType.VOIDSCAR
		best.level = 1
		best.timer = Square.PERMANENT
		best.elevated = false
		best.attunement = Aspect.Type.NONE
		best.zone = null
		_emit({"type": &"voidscar", "pos": best.pos})
	else:
		# the arena is fully consumed: everyone left takes 1 per round, so every battle ends
		for id in roster:
			if monsters[id].is_alive():
				_hurt(id, 1, "Collapse")
