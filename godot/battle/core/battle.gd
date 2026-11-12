class_name Battle
extends RefCounted
## One headless, deterministic battle (gdd_battle.md): the mutable state of an encounter and
## the single entry point for everything that changes it.
##
##   definitions  battle/defs  (data, shared by all battles)        → `content`
##   state        this object, Board, BattleUnit, PendingSurge       (plain data, cloneable)
##   rules        Battle* modules in this folder (static functions on a Battle)
##   presentation battle/view, battle/ui: they call `check` / `apply` and read `events`
##
## Determinism: the rules use no randomness, no time and no engine nodes. The same start
## state, the same content and the same ordered actions always give the same events and the
## same `state_hash()`. `actions` is the replayable log of everything that was applied.
##
## Actions are Dictionaries:
##   {type: &"step", to}                                    universal Step, 2 AP
##   {type: &"skill", slot, ...}                            a kit skill of the active monster
##        move:   to            strike: dir, push_dir, origin
##        surge / zone / ground: anchor, dir, rot           buff: nothing else
##   {type: &"end_turn"}
##   {type: &"tamer", side, skill, unit, other, cells}      battle loadout (gdd_battle §5.2)

signal event_emitted(e: Dictionary)

## Legacy display constant of the overworld's ambush text. The ambush bonus itself was dropped
## from the design (gdd_overworld §2.2) and is not applied by the battle.
const AMBUSH_BONUS := 1.0
const PLAYER := 0
const ENEMY := 1

var content: BattleContent
var board: Board
var units := {}                          # id -> BattleUnit
var roster: Array[StringName] = []       # stable order: player slots, enemy slots, benches
var queue: Array[Dictionary] = []        # this round's entries (BattleQueue)
var prev_queue: Array[Dictionary] = []   # the finished round's queue (orphaned Surge order)
var queue_idx := 0
var turn_owner: StringName = &""
var ap := 0
var round_number := 1
var over := false
var winner_side := -1                    # 0 player, 1 enemy, -1 none / Draw
var draw := false
## Side that wins the next cross-side initiative tie (-1 = not decided yet).
var tie_side := -1
## Late-round pressure starts at the end of this round (gdd_battle §4.2).
var voidscar_from := 8
var voidscar_ground: StringName = &"voidscar"
var surges: Array[PendingSurge] = []
## Loadouts per side: slotted tamer skills and the ids used this battle.
var tamer_loadout: Array = [[], []]
var tamer_used: Array[Dictionary] = [{}, {}]
## Events collected for event-driven passives during a payload (gdd_battle §2.4).
var reaction_events: Array[Dictionary] = []
var events: Array[Dictionary] = []
var actions: Array[Dictionary] = []
## Dry runs stay silent: no signal, so the view never shows a simulated outcome.
var muted := false

var _next_gid := 0
var _next_surge := 0
var _next_prop := 0


func _init(p_board: Board = null, p_content: BattleContent = null) -> void:
	board = p_board if p_board != null else Board.new(7)
	content = p_content if p_content != null else BattleContent.shared()


# ---------- setup ----------

## Adds a unit. `fielded` false puts it on the bench (Beast Swap).
func add_unit(u: BattleUnit, fielded := true) -> BattleUnit:
	units[u.id] = u
	roster.append(u.id)
	u.on_field = fielded
	if fielded:
		put(u, u.pos)
	return u


func add_prop(prop_id: StringName, p: Vector2i) -> BoardProp:
	return BattleBoardOps.place_prop(self, content.prop(prop_id), p)


func set_ground(p: Vector2i, ground: StringName, level := 1) -> void:
	var c := board.at(p)
	c.ground = ground
	c.level = level


func begin() -> void:
	BattleTurn.begin(self)


# ---------- events ----------

func emit(type: StringName, data: Dictionary = {}) -> void:
	var e := data.duplicate()
	e["type"] = type
	events.append(e)
	if not muted:
		event_emitted.emit(e)


# ---------- queries ----------

func active() -> BattleUnit:
	var u: BattleUnit = units.get(turn_owner)
	return u if u != null and u.is_alive() and not over else null


## Living units on the field in roster order (`side` -1 = both).
func living(side := -1) -> Array[BattleUnit]:
	var out: Array[BattleUnit] = []
	for id in roster:
		var u: BattleUnit = units[id]
		if u.is_alive() and (side < 0 or u.side == side):
			out.append(u)
	return out


func unit_at(p: Vector2i, layer: int) -> BattleUnit:
	var id := board.unit_id_at(p, layer)
	return units[id] if id != &"" else null


## Any unit on the square: the ground layer first, then the air layer.
func any_unit_at(p: Vector2i) -> BattleUnit:
	var u := unit_at(p, Board.GROUND)
	return u if u != null else unit_at(p, Board.AIR)


func queue_rank(id: StringName) -> int:
	return BattleQueue.rank_in(queue, id)


## Order of a payload source among simultaneous sources: a living caster's place in the
## current queue, a defeated or removed caster's place in the previous round's queue.
func source_rank(owner: StringName) -> int:
	var u: BattleUnit = units.get(owner)
	if u != null and u.is_alive():
		return queue_rank(owner)
	return BattleQueue.rank_in(prev_queue, owner)


func tamer_skill(side: int, id: StringName) -> TamerSkillDef:
	if side < 0 or side > 1:
		return null
	for def: TamerSkillDef in tamer_loadout[side]:
		if def.id == id:
			return def
	return null


func surge_by_id(id: int) -> PendingSurge:
	for s in surges:
		if s.id == id:
			return s
	return null


func surges_of(owner: StringName) -> Array[PendingSurge]:
	var out: Array[PendingSurge] = []
	for s in surges:
		if s.owner == owner:
			out.append(s)
	return out


func skill_in_slot(u: BattleUnit, slot: int) -> BattleSkillDef:
	if u == null or slot < 0 or slot >= u.sheet.skills.size():
		return null
	return u.sheet.skills[slot]


## Repetition policy per equipped instance (gdd_skills §2 Usage and Repetition).
func usage_error(u: BattleUnit, slot: int) -> String:
	var s := skill_in_slot(u, slot)
	if s == null:
		return "no such skill slot"
	match s.repetition:
		"once_per_round":
			if int(u.used_round.get(slot, 0)) == round_number:
				return "%s was already used this round" % s.display_name
		"once_per_battle":
			if u.used_battle.has(slot):
				return "%s was already used this battle" % s.display_name
	return ""


# ---------- low-level state changes used by the rule modules ----------

func next_prop_uid() -> int:
	_next_prop += 1
	return _next_prop


func lift(u: BattleUnit) -> void:
	for c in u.cells():
		if board.occupants[u.layer].get(c, &"") == u.id:
			board.occupants[u.layer].erase(c)


func put(u: BattleUnit, p: Vector2i) -> void:
	u.pos = p
	for c in u.cells():
		board.occupants[u.layer][c] = u.id


func relocate(u: BattleUnit, to: Vector2i) -> void:
	lift(u)
	put(u, to)


## Timed unit effect lasting until the round end of the N-th following round. The same key
## (same effect of the same owner) only refreshes the duration (gdd_battle §3.1).
func apply_effect(u: BattleUnit, key: String, tag: String, value: int, rounds: int) -> void:
	var ends := round_number + rounds
	for fx in u.effects:
		if fx["key"] == key and fx["tag"] == tag:
			fx["ends_round"] = maxi(int(fx["ends_round"]), ends)
			emit(&"effect_refreshed", {"target": u.id, "tag": tag, "value": fx["value"], "ends_round": fx["ends_round"]})
			return
	u.effects.append({"key": key, "tag": tag, "value": value, "ends_round": ends})
	emit(&"effect_applied", {"target": u.id, "tag": tag, "value": value, "ends_round": ends})


## Unit-bound effects end when their bearer is defeated or removed (gdd_battle §2.2).
func end_unit_effects(u: BattleUnit) -> void:
	u.effects.clear()
	u.nullify = false
	u.life_thread = false


## Zones, ground, props and Surges stay when their caster falls; its Surges become orphaned
## and stay set (a Surge is a trap and never lapses).
func defeat(u: BattleUnit) -> void:
	u.hp = 0
	u.defeated = true
	lift(u)
	end_unit_effects(u)
	for s in surges:
		if s.owner == u.id:
			s.orphaned = true
	emit(&"defeated", {"who": u.id})


func remove_surge(s: PendingSurge) -> void:
	surges.erase(s)
	for c in s.cells:
		var cell := board.at(c)
		if cell != null and cell.surge == s.id:
			cell.surge = -1


## The battle ends when a side has no monsters left on the field; checked only after a
## payload or phase has fully resolved. Both sides empty at once is a Draw. Pending Surges
## and autonomous aftermath lapse (gdd_battle §2.1).
func check_over() -> bool:
	if over:
		return true
	var alive := [living(PLAYER).size(), living(ENEMY).size()]
	if alive[0] > 0 and alive[1] > 0:
		return false
	over = true
	draw = alive[0] == 0 and alive[1] == 0
	winner_side = -1 if draw else (PLAYER if alive[0] > 0 else ENEMY)
	for s in surges.duplicate():
		remove_surge(s)
	ap = 0
	emit(&"battle_over", {"winner_side": winner_side, "draw": draw, "round": round_number})
	return true


# ---------- actions ----------

## Why an action is illegal right now ("" = legal). Never changes state: an invalid attempt
## consumes neither AP nor usage.
func check(a: Dictionary) -> String:
	if over:
		return "the battle is over"
	var type: StringName = a.get("type", &"")
	if type == &"tamer":
		return BattleTamer.error(self, a)
	if type == &"end_turn":
		return "" if turn_owner != &"" else "no turn is running"
	var u := active()
	if u == null:
		return "no monster is acting"
	if a.has("unit") and a["unit"] != u.id:
		return "it is not this monster's turn"
	match type:
		&"step":
			if ap < BattleMoves.step_ap():
				return "Step needs %d AP, %d left" % [BattleMoves.step_ap(), ap]
			if BattleStats.is_rooted(u):
				return "%s cannot move" % u.display_name()
			if not BattleMoves.options(self, u, BattleMoves.step_profile()).has(a.get("to")):
				return "Step moves exactly 1 square onto a free, unblocked square"
			return ""
		&"skill":
			return _skill_error(u, a)
	return "unknown action"


func _skill_error(u: BattleUnit, a: Dictionary) -> String:
	var slot: int = int(a.get("slot", -1))
	var s := skill_in_slot(u, slot)
	if s == null:
		return "no such skill slot"
	if not s.is_active():
		return "%s is a passive" % s.display_name
	if ap < s.cost():
		return "%s needs %d AP, %d left" % [s.display_name, s.cost(), ap]
	var usage := usage_error(u, slot)
	if usage != "":
		return usage
	match s.kind:
		BattleSkillDef.MOVE:
			if BattleStats.is_rooted(u):
				return "%s cannot move" % u.display_name()
			if not BattleMoves.options(self, u, BattleMoves.profile_of(s)).has(a.get("to")):
				return "%s cannot reach that square" % s.display_name
		BattleSkillDef.STRIKE:
			return strike_error(u, s, a.get("dir", Vector2i.ZERO), a.get("push_dir", Vector2i.ZERO), a.get("origin", u.pos))
		BattleSkillDef.SURGE, BattleSkillDef.TRAP, BattleSkillDef.ZONE, BattleSkillDef.GROUND:
			return BattleCasting.error(self, u, s, a.get("anchor", u.pos), a.get("dir", Vector2i.ZERO), int(a.get("rot", 0)))
	return ""


## A Strike is legal whenever its direction fits the shape and the whole shape lies on the
## board (gdd_skills §2 area contract); an empty hit pattern is allowed.
func strike_error(u: BattleUnit, s: BattleSkillDef, dir: Vector2i, push_dir: Vector2i, origin: Vector2i) -> String:
	var shape := StringName(s.strike_shape)
	if not StrikeShapes.is_legal_dir(shape, dir):
		return "%s cannot be aimed in that direction" % StrikeShapes.shape_name(shape)
	if not u.covers(origin):
		return "the shape must start at a square of the striker"
	for h in StrikeShapes.hits(shape, dir):
		if not board.in_bounds(origin + h["o"]):
			return "the shape does not fit on the board"
	if s.kin_effect and KinRules.strike(u.kin()).get("push", false) and not Board.CARDINAL.has(push_dir):
		return "choose the push direction"
	return ""


## Applies a legal action. Returns false (and changes nothing) if it is illegal.
## `trusted`: the action comes straight from the legal candidates of this very state (AI dry
## runs), so the legality check is not repeated; a move may carry its path as a["path"].
func apply(a: Dictionary, trusted := false) -> bool:
	if not trusted and check(a) != "":
		return false
	actions.append(a.duplicate(true))
	var type: StringName = a["type"]
	if type == &"end_turn":
		BattleTurn.end_turn(self)
		return true
	if type == &"tamer":
		BattleTamer.apply(self, a)
	else:
		var u := active()
		if type == &"step":
			ap -= BattleMoves.step_ap()
			BattleMoves.execute(self, u, BattleMoves.step_profile(), a["to"], "Step", a.get("path", []) if trusted else [])
		else:
			_use_skill(u, a, trusted)
		BattleTurn.spring_traps(self)
		check_over()
	# a monster that fell during its own turn has nothing left to do: the queue moves on
	if not over and turn_owner != &"" and active() == null:
		BattleTurn.end_turn(self)
	return true


func _use_skill(u: BattleUnit, a: Dictionary, trusted := false) -> void:
	var slot: int = int(a["slot"])
	var s := skill_in_slot(u, slot)
	# a valid activation spends its AP and one use at activation, whatever happens later
	ap -= s.cost()
	u.used_round[slot] = round_number
	u.used_battle[slot] = true
	match s.kind:
		BattleSkillDef.MOVE:
			var started := u.pos
			BattleMoves.execute(self, u, BattleMoves.profile_of(s), a["to"], s.display_name, a.get("path", []) if trusted else [])
			BattleMoves.impact(self, u, s, started, a["to"])
		BattleSkillDef.STRIKE:
			BattlePayload.resolve(self, [BattlePayload.strike(self, u, s, a.get("origin", u.pos),
				a.get("dir", Vector2i.ZERO), a.get("push_dir", Vector2i.ZERO))])
		BattleSkillDef.SURGE, BattleSkillDef.TRAP:
			_declare_surge(u, s, a)
		BattleSkillDef.ZONE:
			var cells := BattleCasting.cells(u, s, a.get("anchor", u.pos), int(a.get("rot", 0)))
			_next_gid += 1
			emit(&"cast", {"who": u.id, "skill": s.id, "cells": cells.duplicate()})
			for c in cells:
				BattleBoardOps.land_zone(self, board.at(c), s.zone, _next_gid, u.id, s.duration,
					a.get("dir", Vector2i.ZERO), a.get("anchor", u.pos))
			if s.zone.has_tag(FieldEffect.PUSH) or s.zone.has_tag(FieldEffect.PULL):
				# a current also moves whoever stands in it at the moment it is cast (T38)
				var moved: Array = []
				for c in cells:
					var t := unit_at(c, Board.GROUND)
					if t == null:
						continue
					var d: Vector2i = a.get("dir", Vector2i.ZERO) if s.zone.has_tag(FieldEffect.PUSH) else BattleDisplace.pull_dir(t, a.get("anchor", u.pos))
					moved.append({"unit": t.id, "dir": d, "cause": s.display_name})
				BattleDisplace.resolve(self, moved)
				BattlePayload.settle(self)
		BattleSkillDef.GROUND:
			var cells := BattleCasting.cells(u, s, a.get("anchor", u.pos), int(a.get("rot", 0)))
			emit(&"cast", {"who": u.id, "skill": s.id, "cells": cells.duplicate()})
			BattlePayload.resolve(self, [BattlePayload.board(self, u, s, cells)])
		BattleSkillDef.BUFF:
			emit(&"cast", {"who": u.id, "skill": s.id, "cells": u.cells()})
			for e in s.buff_effects:
				apply_effect(u, "buff:%s:%s" % [s.id, u.id], e.tag, e.value_at(1), s.duration)


func _declare_surge(u: BattleUnit, s: BattleSkillDef, a: Dictionary) -> void:
	var ps := PendingSurge.new()
	_next_surge += 1
	ps.id = _next_surge
	ps.owner = u.id
	ps.skill = s
	ps.cells = BattleCasting.cells(u, s, a.get("anchor", u.pos), int(a.get("rot", 0)))
	if s.kind == BattleSkillDef.TRAP:
		ps.cells = BattleCasting.free_cells(self, ps.cells)   # laid only where no marker lies
	else:
		for c in ps.cells:                                    # a Surge replaces a trap square by square
			var old := surge_by_id(board.at(c).surge)
			if old != null:
				old.cells.erase(c)
				old.ring = []
				for q in BattleExperiment.ring(old.cells, false):
					if board.in_bounds(q):
						old.ring.append(q)
				if old.cells.is_empty():
					surges.erase(old)
	ps.dir = a.get("dir", Vector2i.ZERO)
	ps.anchor = a.get("anchor", u.pos)
	ps.air_cells = BattleCasting.mountain_air_cells(self, u, ps.cells)
	ps.cast_round = round_number
	ps.slot = int(a.get("slot", -1))
	for c in ps.cells:
		if board.at(c).prop != null or board.at(c).is_mountain():
			ps.blocked_at_cast.append(c)
	if s.kind == BattleSkillDef.SURGE:
		ps.turns_left = maxi(1, s.surge_turns)
		ps.fresh = true
	for q in BattleExperiment.ring(ps.cells, false):
		if board.in_bounds(q):
			ps.ring.append(q)
	surges.append(ps)
	for c in ps.cells:
		board.at(c).surge = ps.id
	emit(&"surge_declared", {"who": u.id, "skill": s.id, "cells": ps.cells.duplicate(), "surge": ps.id})


func end_turn() -> bool:
	return apply({"type": &"end_turn"})


# ---------- preview and replay support ----------

## A deep copy of the state that shares definitions and unit sheets. Used for dry runs by
## the cast preview and the AI, so both read exactly what the resolution would do.
func clone() -> Battle:
	var b := Battle.new(board.clone(), content)
	for id in roster:
		b.units[id] = units[id].clone()
	b.roster = roster.duplicate()
	b.queue = queue.duplicate(true)
	b.prev_queue = prev_queue.duplicate(true)
	b.queue_idx = queue_idx
	b.turn_owner = turn_owner
	b.ap = ap
	b.round_number = round_number
	b.over = over
	b.winner_side = winner_side
	b.draw = draw
	b.tie_side = tie_side
	b.voidscar_from = voidscar_from
	b.voidscar_ground = voidscar_ground
	for s in surges:
		b.surges.append(s.clone())
	b.tamer_loadout = [tamer_loadout[0].duplicate(), tamer_loadout[1].duplicate()]
	b.tamer_used = [tamer_used[0].duplicate(), tamer_used[1].duplicate()]
	b._next_gid = _next_gid
	b._next_surge = _next_surge
	b._next_prop = _next_prop
	b.muted = true
	return b


## Simulates an action on a copy: {ok, error, events, after}. For a Surge, `forecast` holds
## the events of its detonation if nothing on the board changed until then.
func preview(a: Dictionary) -> Dictionary:
	var why := check(a)
	if why != "":
		return {"ok": false, "error": why, "events": [], "forecast": [], "after": null}
	var sim := clone()
	sim.apply(a)
	var out := {"ok": true, "error": "", "events": sim.events.duplicate(true), "forecast": [], "after": sim}
	if a.get("type") == &"skill" and not sim.surges.is_empty():
		var s := skill_in_slot(active(), int(a["slot"]))
		if s != null and s.is_marker():
			var ahead := sim.clone()
			var mine: Array[PendingSurge] = [ahead.surges[ahead.surges.size() - 1]]
			BattleTurn.detonate(ahead, mine)
			out["forecast"] = ahead.events.duplicate(true)
	return out


## Canonical description of the whole mutable state, independent of presentation.
func snapshot() -> Dictionary:
	var us := []
	for id in roster:
		var u: BattleUnit = units[id]
		us.append([String(id), u.side, u.slot, u.pos, u.layer, u.hp, u.max_hp, u.on_field, u.defeated,
			u.nullify, u.life_thread, u.effects.duplicate(true), u.used_round.duplicate(), u.used_battle.keys()])
	var cs := []
	for c in board.cells:
		var z := []
		if c.zone != null:
			z = [String(c.zone.def.id), c.zone.gid, String(c.zone.owner), c.zone.level, c.zone.duration, c.zone.dir, c.zone.anchor]
		var p := [] if c.prop == null else [String(c.prop.def.id), c.prop.hp, c.prop.uid]
		var air := [] if c.air_prop == null else [String(c.air_prop.def.id), c.air_prop.hp, c.air_prop.uid]
		cs.append([String(c.ground), c.level, c.height, p, air, z, c.surge])
	var ss := []
	for s in surges:
		ss.append([s.id, String(s.owner), String(s.skill.id), s.cells.duplicate(), s.dir, s.anchor, s.air_cells.duplicate(), s.orphaned])
	var qs := []
	for e in queue:
		qs.append([String(e["id"]), e["init"], e["extra"]])
	return {"round": round_number, "turn": String(turn_owner), "ap": ap, "idx": queue_idx, "over": over,
		"winner": winner_side, "draw": draw, "tie": tie_side, "units": us, "cells": cs, "surges": ss,
		"queue": qs, "tamer_used": [tamer_used[0].keys(), tamer_used[1].keys()]}


func state_hash() -> String:
	return var_to_str(snapshot()).sha256_text()


## Replays a recorded action log on this (freshly set up, not yet begun) battle.
func replay(action_log: Array) -> void:
	begin()
	for a: Dictionary in action_log:
		apply(a)
