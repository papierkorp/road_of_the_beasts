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
## Determinism: the rules use no time and no engine nodes, and no randomness but the seeded catch roll of the
## ingame battle (BattleCatch: `roll_seed`, `rolls`; dry runs never roll). The same start
## state, the same content and the same ordered actions always give the same events and the
## same `state_hash()`. `actions` is the replayable log of everything that was applied.
##
## Actions are Dictionaries:
##   {type: &"step", to}                                    universal Step, 2 AP
##   {type: &"skill", slot, ...}                            a kit skill of the active monster
##        move:   to            strike: dir, origin
##        surge / zone / ground: anchor, dir, rot           buff: nothing else
##   {type: &"end_turn"}
##   {type: &"tamer", side, skill, unit, other, cells}      battle loadout (gdd_battle §5.2)

signal event_emitted(e: Dictionary)

## Legacy display constant of the overworld's ambush text. The ambush bonus itself was dropped
## from the design (gdd_overworld §2.2) and is not applied by the battle.
const AMBUSH_BONUS := 0.1
const PLAYER := 0
const ENEMY := 1

var content: BattleContent
var board: Board
var units := {}                          # id -> BattleUnit
var roster: Array[StringName] = []       # stable order: player slots, enemy slots, benches
## Custom map (MapDef): the squares side 0 and side 1 may place their monsters on ([] = the start area of the mode).
var start_areas: Array = [[], []]
var queue: Array[Dictionary] = []        # this round's entries (BattleQueue)
var prev_queue: Array[Dictionary] = []   # the finished round's queue (orphaned Surge order)
var queue_idx := 0
var turn_owner: StringName = &""
var ap := 0
## Follow-up (Kin trait of Beast): {"who": unit id, "cells": squares a Step of that unit enters for no AP}.
var follow := {}
## Test switch delay_turn: the running entry has acted already · unit id -> round it postponed a turn in.
var entry_acted := false
var delayed := {}
## unit id -> turns it has postponed in this battle.
var waits := {}
var round_number := 1
var over := false
var winner_side := -1                    # 0 player, 1 enemy, -1 none / Draw
var draw := false
## Side that wins the next cross-side pace tie (-1 = not decided yet).
var tie_side := -1
## Sides that pick the target of a held Dragon Vein themselves when several enemies tie (user decision 2026-11-14); the others take the roster-order fallback. Empty: nobody asks (simulations, tests).
var choice_sides: Array[int] = []
var pending_choice := {}                 # {pos, side, options} while the round end waits for a pick
var choice_picks := {}                   # vein pos -> chosen unit id, for the round end being resolved
## Late-round pressure starts at the end of this round (gdd_battle §4.2).
var voidscar_from := 8
var voidscar_ground: StringName = &"voidscar"
var surges: Array[PendingSurge] = []
## Loadouts per side: slotted tamer skills and the ids used this battle.
var tamer_loadout: Array = [[], []]
var tamer_used: Array[Dictionary] = [{}, {}]      # id -> times used
## Uses per battle of a loadout entry (default 1): id -> uses.
var tamer_uses: Array[Dictionary] = [{}, {}]
## Loadout entries that are bitter pills, per side: the monster one is given to loses 1 HP, never its last.
var tamer_bitter: Array = [[], []]
## Pending effects of the tamer per side: squares the next weapon lays more, and whether the next pill spreads.
var tamer_extend: Array[int] = [0, 0]
var tamer_spread: Array[bool] = [false, false]
## Catching (docs/battle_ingame.md §7, BattleCatch): sides without a tamer, the Seal Ground on the board
## (pos -> {side, base}) and the seed and count of the catch rolls.
var wild: Array[bool] = [false, false]
var seals := {}
var roll_seed := 0
var rolls := 0
## Monsters a zone has moved in the running action (docs/battle.md §4.6: once per action). Cleared with every
## action and at the round end; the zone move at the end of a turn marks its monster too.
var zone_moved := {}
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


## The slot number of the Basic Jab every monster has beside its kit, like Step
## (an action {type: &"skill", slot: BASIC_SLOT, dir}); it is no slot of the sheet.
const BASIC_SLOT := 99


func skill_in_slot(u: BattleUnit, slot: int) -> BattleSkillDef:
	if slot == BASIC_SLOT:
		return content.skill(&"basic_jab") if u != null else null
	if u == null or slot < 0 or slot >= u.sheet.skills.size():
		return null
	return u.sheet.skills[slot]


## Repetition policy per equipped instance (gdd_skills §2 Usage and Repetition).
func usage_error(u: BattleUnit, slot: int) -> String:
	var s := skill_in_slot(u, slot)
	if s == null:
		return "no such skill slot"
	if BattleExperiment.once_per_turn and s.usage_limit > 0 and int(u.used_turn.get(slot, 0)) >= s.usage_limit:
		return ("%s was already used this turn" if s.usage_limit == 1 else "%s has no uses left this turn") % s.display_name
	if s.uses_stamina() and u.stamina - BattleMoves.use_cost(self, u) < 1:
		return "%s needs Stamina, none left" % s.display_name
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


## What a Step of `u` onto `to` costs: nothing onto a square its Follow-up opened, else the AP of a Step.
func step_cost(u: BattleUnit, to) -> int:
	if u != null and follow.get("who", &"") == u.id and to is Vector2i and (follow["cells"] as Array).has(to):
		return 0
	return BattleMoves.step_ap()


## The least a Step of `u` costs right now.
func min_step_cost(u: BattleUnit) -> int:
	return 0 if u != null and follow.get("who", &"") == u.id else BattleMoves.step_ap()


## Whether a loadout entry has no use left in this battle.
## The squares a laying tamer skill may take now: its own, and one more for a weapon after Long Reach.
func lay_count(side: int, def: TamerSkillDef) -> int:
	return maxi(1, def.lay_count) + (tamer_extend[side] if def.source == "weapon" else 0)


func tamer_spent(side: int, id: StringName) -> bool:
	return int(tamer_used[side].get(id, 0)) >= int(tamer_uses[side].get(id, 1))


func relocate(u: BattleUnit, to: Vector2i) -> void:
	lift(u)
	put(u, to)
	touch_veins(u)


## A Dragon Vein belongs to the side whose monster touched it last (walked, was pushed or set onto it).
## Wait is bought with Pace: the Waits the current Pace of `u` gives per battle, and how many are left.
func waits_total(u: BattleUnit) -> int:
	return maxi(0, int(floor(BattleStats.pace(self, u) + 0.0001)) - 1)


func waits_left(u: BattleUnit) -> int:
	return maxi(0, waits_total(u) - int(waits.get(u.id, 0)))


func touch_veins(u: BattleUnit) -> void:
	for c in u.cells():
		var cell := board.at(c)
		if cell != null and cell.ground == GroundDef.WELL and cell.owner_side != u.side:
			cell.owner_side = u.side
			cell.owner_unit = u.id
			emit(&"vein_taken", {"pos": c, "side": u.side, "who": u.id})


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
	BattleCatch.on_defeat(self, u)          # a wild monster is caught on Seal Ground or dies
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
	if not pending_choice.is_empty():            # the round end waits for the owner of a Dragon Vein
		if a.get("type", &"") == &"choose_target" and pending_choice["options"].has(a.get("unit", &"")):
			return ""
		return "choose the Dragon Vein target first"
	if a.get("type", &"") == &"choose_target":
		return "no choice is pending"
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
	if type == &"delay":
		if entry_acted:
			return "%s has already acted this turn" % u.display_name()
		if int(delayed.get(u.id, 0)) == round_number:
			return "%s has already postponed a turn this round" % u.display_name()
		if waits_left(u) <= 0:
			if waits_total(u) <= 0:
				return "%s is too slow to wait (Pace 2.0 gives one Wait per battle)" % u.display_name()
			return "%s has no Wait left in this battle" % u.display_name()
		if queue_idx >= queue.size() - 1 or queue[queue_idx + 1].get("waited", false):
			return "nobody acts after %s this round" % u.display_name()
		return ""
	match type:
		&"heal":
			return heal_error(u)
		&"step":
			if ap < step_cost(u, a.get("to")):
				return "Step needs %d AP, %d left" % [BattleMoves.step_ap(), ap]
			if BattleStats.is_rooted(u):
				return "%s cannot move" % u.display_name()
			if not BattleMoves.options(self, u, BattleMoves.step_profile()).has(a.get("to")):
				return "Step moves exactly 1 square onto a free, unblocked square"
			return ""
		&"skill":
			return _skill_error(u, a)
	return "unknown action"


## Heal (rule since 2026-11-18, user decision; docs/battle.md §2.4): an action every monster has beside Step and the
## Basic Jab. It costs HEAL_STAMINA Stamina from the pool and no AP, gives HEAL_HP HP back, never above the maximum,
## once per turn. HEAL_SLOT is its usage key in `used_turn` (no slot of the sheet).
const HEAL_SLOT := 98
const HEAL_STAMINA := 3
const HEAL_HP := 1


## Why the acting monster cannot heal right now ("" = it can).
func heal_error(u: BattleUnit) -> String:
	if not BattleExperiment.stamina:
		return "Heal needs the Stamina pool"
	if u.stamina < HEAL_STAMINA:
		return "Heal needs %d Stamina, %d left" % [HEAL_STAMINA, u.stamina]
	if int(u.used_turn.get(HEAL_SLOT, 0)) > 0:
		return "Heal was already used this turn"
	if u.hp >= u.max_hp:
		return "%s is at full HP" % u.display_name()
	return ""


func _use_heal(u: BattleUnit) -> void:
	u.stamina -= HEAL_STAMINA
	u.used_turn[HEAL_SLOT] = 1
	emit(&"heal_used", {"who": u.id, "spent": HEAL_STAMINA})
	BattleDamage.heal(self, u, HEAL_HP, "Heal")


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
			return strike_error(u, s, a.get("dir", Vector2i.ZERO), a.get("origin", u.pos))
		BattleSkillDef.SURGE, BattleSkillDef.TRAP, BattleSkillDef.ZONE, BattleSkillDef.GROUND:
			return BattleCasting.error(self, u, s, a.get("anchor", u.pos), a.get("dir", Vector2i.ZERO), int(a.get("rot", 0)))
	return ""


## A Strike is legal whenever its direction fits the shape and at least one square of it lies on the
## board; squares over the edge are dropped (user decision 2026-11-17). An empty hit pattern is allowed.
func strike_error(u: BattleUnit, s: BattleSkillDef, dir: Vector2i, origin: Vector2i) -> String:
	if not BattleShapes.is_legal_dir(s.shape_id(), dir, s.shape_extension):
		return "%s cannot be aimed in that direction" % s.shape_label()
	if not u.covers(origin):
		return "the shape must start at a square of the striker"
	var any_on_board := false
	for h in s.shape_hits(dir):
		var c: Vector2i = origin + h["o"]
		if board.in_bounds(c) and not u.covers(c):
			any_on_board = true
			break
	if not any_on_board:
		return "no square of the shape lies on the board"
	return ""


## Applies a legal action. Returns false (and changes nothing) if it is illegal.
## `trusted`: the action comes straight from the legal candidates of this very state (AI dry
## runs), so the legality check is not repeated; a move may carry its path as a["path"].
func apply(a: Dictionary, trusted := false) -> bool:
	if not trusted and check(a) != "":
		return false
	actions.append(a.duplicate(true))
	zone_moved.clear()
	var type: StringName = a["type"]
	if type == &"choose_target":
		BattleTurn.choose(self, a["unit"])
		return true
	if type == &"end_turn":
		BattleTurn.end_turn(self)
		return true
	if type == &"delay":
		BattleTurn.delay(self)
		return true
	if type == &"tamer":
		BattleTamer.apply(self, a)
	else:
		entry_acted = true
		var u := active()
		if type != &"step":
			follow = {}
		if type == &"step":
			ap -= step_cost(u, a["to"])
			follow = {}
			BattleMoves.execute(self, u, BattleMoves.step_profile(), a["to"], "Step", a.get("path", []) if trusted else [])
			BattleTurn.arrive(self, u)
		elif type == &"heal":
			_use_heal(u)
		else:
			_use_skill(u, a, trusted)
		BattleTurn.spring_traps(self)
		check_over()
	# a monster that fell during its own turn has nothing left to do: the queue moves on
	if not over and pending_choice.is_empty() and turn_owner != &"" and active() == null:
		BattleTurn.end_turn(self)
	return true


func _use_skill(u: BattleUnit, a: Dictionary, trusted := false) -> void:
	var slot: int = int(a["slot"])
	var s := skill_in_slot(u, slot)
	# a valid activation spends its AP and one use at activation, whatever happens later
	ap -= s.cost()
	u.used_round[slot] = round_number
	u.used_battle[slot] = true
	u.used_turn[slot] = int(u.used_turn.get(slot, 0)) + 1
	match s.kind:
		BattleSkillDef.MOVE:
			var started := u.pos
			var tired := 0                           # Stamina: what the route costs (the movement cost of every square, BattleMoves.options)
			if s.uses_stamina():
				var reach := BattleMoves.options(self, u, BattleMoves.profile_of(s))
				tired = maxi(0, (int(reach[a["to"]]["cost"]) if reach.has(a["to"]) else 1) + BattleMoves.use_cost(self, u))
			var trail: Array[Vector2i] = []
			if not s.board_ops.is_empty():            # a movement that leaves something on its path
				var route: Array = a.get("path", [])
				if route.is_empty():
					var opts := BattleMoves.options(self, u, BattleMoves.profile_of(s))
					route = opts[a["to"]]["path"] if opts.has(a["to"]) else []
				trail.append(started)
				for i in maxi(0, route.size() - 1):
					trail.append(route[i])
				var span: Vector2i = a["to"] - started
				if route.size() == 1 and (span.x == 0 or span.y == 0 or absi(span.x) == absi(span.y)):
					var unit_step := Vector2i(signi(span.x), signi(span.y))      # a line names only its landing square
					for k in range(1, maxi(absi(span.x), absi(span.y))):
						trail.append(started + unit_step * k)
			BattleMoves.execute(self, u, BattleMoves.profile_of(s), a["to"], s.display_name, a.get("path", []) if trusted else [])
			u.stamina = maxi(0, u.stamina - tired)
			BattleMoves.impact(self, u, s, started, a["to"])
			BattleTurn.arrive(self, u)                # the landing square counts, not the squares passed over
			if not trail.is_empty() and u.is_alive():
				var left: Array[Vector2i] = []
				for c in trail:
					if not u.covers(c) and any_unit_at(c) == null:
						left.append(c)
				var behind := BattlePayload.board(self, u, s, left)
				var way: Vector2i = a["to"] - started   # a push zone left on the path pushes the way the monster went
				behind["dir"] = Vector2i(signi(way.x), 0) if absi(way.x) >= absi(way.y) else Vector2i(0, signi(way.y))
				behind["anchor"] = a["to"]
				BattlePayload.resolve(self, [behind])
		BattleSkillDef.STRIKE:
			BattlePayload.resolve(self, [BattlePayload.strike(self, u, s, a.get("origin", u.pos), a.get("dir", Vector2i.ZERO))])
		BattleSkillDef.SURGE, BattleSkillDef.TRAP:
			_declare_surge(u, s, a)
		BattleSkillDef.ZONE:
			var cells := BattleCasting.on_board(self, u, s, a.get("anchor", u.pos), int(a.get("rot", 0)))
			_next_gid += 1
			emit(&"cast", {"who": u.id, "skill": s.id, "cells": cells.duplicate()})
			for c in cells:
				BattleBoardOps.land_zone(self, board.at(c), s.zone, _next_gid, u.id, s.duration,
					a.get("dir", Vector2i.ZERO), a.get("anchor", u.pos))
		BattleSkillDef.GROUND:
			var cells := BattleCasting.on_board(self, u, s, a.get("anchor", u.pos), int(a.get("rot", 0)))
			emit(&"cast", {"who": u.id, "skill": s.id, "cells": cells.duplicate()})
			var placed := BattlePayload.board(self, u, s, cells)
			placed["anchor"] = a.get("anchor", u.pos)   # a zone the skill leaves pulls toward it
			placed["dir"] = BattleCasting.rot_dir(u, s, int(a.get("rot", 0))) if BattleCasting.pushes_by_rotation(self, s) else a.get("dir", Vector2i.ZERO)
			BattlePayload.resolve(self, [placed])
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
	ps.cells = BattleCasting.on_board(self, u, s, a.get("anchor", u.pos), int(a.get("rot", 0)))
	if s.kind == BattleSkillDef.TRAP:
		var own: Array[PendingSurge] = []                     # one trap per trap skill: the oldest gives way
		for old_trap in surges:
			if old_trap.owner == u.id and old_trap.turns_left < 0 and old_trap.slot == int(a.get("slot", -1)):
				own.append(old_trap)
		while own.size() >= 1:
			var gone: PendingSurge = own.pop_front()
			remove_surge(gone)
			emit(&"surge_lapsed", {"surge": gone.id})
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
	b.follow = follow.duplicate(true)
	b.entry_acted = entry_acted
	b.delayed = delayed.duplicate()
	b.waits = waits.duplicate()
	b.round_number = round_number
	b.over = over
	b.winner_side = winner_side
	b.draw = draw
	b.tie_side = tie_side
	b.choice_sides = choice_sides.duplicate()
	b.pending_choice = pending_choice.duplicate(true)
	b.choice_picks = choice_picks.duplicate()
	b.voidscar_from = voidscar_from
	b.voidscar_ground = voidscar_ground
	for s in surges:
		b.surges.append(s.clone())
	b.tamer_loadout = [tamer_loadout[0].duplicate(), tamer_loadout[1].duplicate()]
	b.tamer_used = [tamer_used[0].duplicate(), tamer_used[1].duplicate()]
	b.tamer_uses = [tamer_uses[0].duplicate(), tamer_uses[1].duplicate()]
	b.tamer_bitter = [tamer_bitter[0].duplicate(), tamer_bitter[1].duplicate()]
	b.tamer_extend = tamer_extend.duplicate()
	b.tamer_spread = tamer_spread.duplicate()
	b.wild = wild.duplicate()
	b.seals = seals.duplicate(true)
	b.roll_seed = roll_seed
	b.rolls = rolls
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
			u.nullify, u.life_thread, u.effects.duplicate(true), u.used_round.duplicate(), u.used_battle.keys(), u.used_turn.duplicate(), u.stamina,
			u.caught, u.died])
	var cs := []
	for c in board.cells:
		var z := []
		if c.zone != null:
			z = [String(c.zone.def.id), c.zone.gid, String(c.zone.owner), c.zone.level, c.zone.duration, c.zone.dir, c.zone.anchor]
		var p := [] if c.prop == null else [String(c.prop.def.id), c.prop.hp, c.prop.uid]
		var air := [] if c.air_prop == null else [String(c.air_prop.def.id), c.air_prop.hp, c.air_prop.uid]
		cs.append([String(c.ground), c.level, c.height, p, air, z, c.surge, c.ground_until])
	var ss := []
	for s in surges:
		ss.append([s.id, String(s.owner), String(s.skill.id), s.cells.duplicate(), s.dir, s.anchor, s.air_cells.duplicate(), s.orphaned])
	var qs := []
	for e in queue:
		qs.append([String(e["id"]), e["pace"], e["extra"]])
	return {"round": round_number, "turn": String(turn_owner), "ap": ap, "idx": queue_idx, "over": over,
		"winner": winner_side, "draw": draw, "tie": tie_side, "units": us, "cells": cs, "surges": ss,
		"queue": qs, "choice": str(pending_choice), "tamer_used": [tamer_used[0].keys(), tamer_used[1].keys()],
		"wild": wild.duplicate(), "seals": str(seals), "rolls": rolls}


func state_hash() -> String:
	return var_to_str(snapshot()).sha256_text()


## Replays a recorded action log on this (freshly set up, not yet begun) battle.
func replay(action_log: Array) -> void:
	begin()
	for a: Dictionary in action_log:
		apply(a)
