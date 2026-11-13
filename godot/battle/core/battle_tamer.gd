class_name BattleTamer
extends RefCounted
## Tamer skills of the battle loadout (gdd_battle §5.2). Each slotted skill is usable once per
## battle, costs no AP and no turn, and only during the turn of one of the tamer's own
## monsters, never inside a payload. These are unique mechanics, so each effect has its own
## small resolver here; nothing else in the core knows a tamer skill by name.
##
## Confirmed and implemented: Swap Places, Urgent Order, Second Wind, Life Thread, Beast Swap,
## Spirit Shield (Nullify), Domain Glimpse. Not implemented because their status is open
## (T20/T24): Spatial Pull, Qi Suppression, Double Bind, Seal Mastery.


static func _own(b: Battle, side: int, id: StringName) -> BattleUnit:
	var u: BattleUnit = b.units.get(id)
	return u if u != null and u.side == side and u.is_alive() else null


## Why the action is illegal ("" = legal). action: {skill, side, ...parameters}.
static func error(b: Battle, a: Dictionary) -> String:
	var side: int = int(a.get("side", -1))
	var active := b.active()
	if b.over or active == null or active.side != side:
		return "tamer skills are used during the turn of one of your own monsters"
	var def: TamerSkillDef = b.tamer_skill(side, a.get("skill", &""))
	if def == null:
		return "this tamer skill is not in the loadout"
	if b.tamer_used[side].has(def.id):
		return "%s was already used this battle" % def.display_name
	match def.effect:
		TamerSkillDef.SWAP_PLACES:
			var x := _own(b, side, a.get("unit", &""))
			var y := _own(b, side, a.get("other", &""))
			if x == null or y == null or x == y:
				return "choose two of your own monsters"
			if x.size != 1 or y.size != 1 or x.layer != Board.GROUND or y.layer != Board.GROUND:
				return "Swap Places needs two 1x1 ground-layer monsters"
		TamerSkillDef.URGENT_ORDER:
			var t := _own(b, side, a.get("unit", &""))
			if t == null:
				return "choose one of your own monsters"
			if _pending_main_entry(b, t.id) < 0:
				return "%s has already acted this round" % t.display_name()
		TamerSkillDef.SECOND_WIND, TamerSkillDef.LIFE_THREAD:
			if _own(b, side, a.get("unit", &"")) == null:
				return "choose one of your own monsters on the field"
		TamerSkillDef.SPIRIT_SHIELD:
			var t2 := _own(b, side, a.get("unit", &""))
			if t2 == null:
				return "choose one of your own monsters on the field"
			if t2.nullify:
				return "%s is already protected (one Nullify per monster)" % t2.display_name()
		TamerSkillDef.BEAST_SWAP:
			var out_u := _own(b, side, a.get("unit", &""))
			var in_u: BattleUnit = b.units.get(a.get("other", &""))
			if out_u == null:
				return "choose one of your own monsters on the field"
			if in_u == null or in_u.side != side or in_u.on_field or in_u.defeated:
				return "choose a monster from the bench"
			if in_u.size != out_u.size:
				return "the incoming monster must have the same body size"
			if out_u.id == b.turn_owner:
				return "the monster whose turn is running cannot be swapped out (open rule, T20)"
		TamerSkillDef.DOMAIN_GLIMPSE:
			var cells: Array = a.get("cells", [])
			if not _is_tetromino(b, cells):
				return "choose four connected squares on the board (any tetromino)"
	return ""


static func apply(b: Battle, a: Dictionary) -> bool:
	if error(b, a) != "":
		return false
	var side: int = int(a["side"])
	var def: TamerSkillDef = b.tamer_skill(side, a["skill"])
	b.tamer_used[side][def.id] = true
	b.emit(&"tamer_skill", {"side": side, "skill": def.id})
	match def.effect:
		TamerSkillDef.SWAP_PLACES:
			var x: BattleUnit = b.units[a["unit"]]
			var y: BattleUnit = b.units[a["other"]]
			var px := x.pos
			var py := y.pos
			b.lift(x)
			b.lift(y)
			b.put(x, py)
			b.put(y, px)
			b.emit(&"swapped", {"a": x.id, "b": y.id})
			# each counts as entering its new square (gdd_battle §5.2)
			BattleDamage.ground_triggers(b, x, GroundTrigger.ON_ENTER)
			BattleDamage.ground_triggers(b, y, GroundTrigger.ON_ENTER)
		TamerSkillDef.URGENT_ORDER:
			var i := _pending_main_entry(b, a["unit"])
			var entry: Dictionary = b.queue[i]
			b.queue.remove_at(i)
			b.queue.insert(b.queue_idx + 1, entry)   # directly after the current turn
			b.emit(&"queue_changed", {"who": a["unit"]})
		TamerSkillDef.SECOND_WIND:
			BattleDamage.heal(b, b.units[a["unit"]], 1, def.display_name)
		TamerSkillDef.LIFE_THREAD:
			b.units[a["unit"]].life_thread = true
			b.emit(&"protected", {"target": a["unit"], "kind": "life_thread"})
		TamerSkillDef.SPIRIT_SHIELD:
			b.units[a["unit"]].nullify = true
			b.emit(&"protected", {"target": a["unit"], "kind": "nullify"})
		TamerSkillDef.BEAST_SWAP:
			_beast_swap(b, b.units[a["unit"]], b.units[a["other"]])
		TamerSkillDef.DOMAIN_GLIMPSE:
			for p: Vector2i in a["cells"]:
				var cell := b.board.at(p)
				if cell.zone != null:
					cell.zone = null
					b.emit(&"zone_changed", {"pos": p, "result": &"cleared", "zone": &"", "level": 0})
				var g := b.content.ground(cell.ground)
				if cell.ground != GroundDef.PLAIN and (g == null or not g.immutable):
					cell.ground = GroundDef.PLAIN
					cell.ground_until = 0
					cell.level = 1
					b.emit(&"ground_changed", {"pos": p, "ground": cell.ground, "level": 1, "result": &"reset", "source": def.display_name})
	BattlePayload.settle(b)
	b.check_over()
	return true


## Index of the unit's main entry that has not started yet this round, or -1.
static func _pending_main_entry(b: Battle, id: StringName) -> int:
	for i in range(b.queue_idx + 1, b.queue.size()):
		if b.queue[i]["id"] == id and int(b.queue[i]["extra"]) == 0:
			return i
	return -1


## The incoming monster takes the square and the queue entries of the swapped-out monster; the
## outgoing one is not defeated, loses its unit-bound effects and leaves its Surges orphaned.
static func _beast_swap(b: Battle, out_u: BattleUnit, in_u: BattleUnit) -> void:
	var pos := out_u.pos
	b.lift(out_u)
	out_u.on_field = false
	b.end_unit_effects(out_u)
	for s in b.surges:
		if s.owner == out_u.id:
			s.orphaned = true
	in_u.on_field = true
	in_u.slot = out_u.slot
	b.put(in_u, pos)
	for e in b.queue:
		if e["id"] == out_u.id:
			e["id"] = in_u.id
			e["base"] = in_u.sheet.initiative
	b.emit(&"beast_swapped", {"out": out_u.id, "in": in_u.id, "pos": pos})


static func _is_tetromino(b: Battle, cells: Array) -> bool:
	if cells.size() != 4:
		return false
	var seen := {}
	for p in cells:
		if not (p is Vector2i) or not b.board.in_bounds(p) or seen.has(p):
			return false
		seen[p] = true
	var reached := {cells[0]: true}
	var frontier: Array = [cells[0]]
	while not frontier.is_empty():
		var cur: Vector2i = frontier.pop_front()
		for d in Board.CARDINAL:
			var n: Vector2i = cur + d
			if seen.has(n) and not reached.has(n):
				reached[n] = true
				frontier.append(n)
	return reached.size() == 4
