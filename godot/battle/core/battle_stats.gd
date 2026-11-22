class_name BattleStats
extends RefCounted
## Effective stats and continuous modifiers (gdd_battle §3.1).
##
## Every continuous source (zone, ground, aura prop, Mountain, passive, timed unit effect)
## contributes entries {key, tag, value} in the shared FieldEffect vocabulary. The same source
## key never adds twice; different sources add without a cap; only the stat floors apply.
## This is the single place that knows which sources exist, so preview, AI and resolution
## read identical numbers.

const MIN_PACE := 0.1
## One Pace point: a stat point buys it, and `quicken` / `drain_pace` values count in it (user decision 2026-11-15).
const PACE_POINT := 0.1
const MIN_MOVEMENT := 1
const MIN_REACH := 1


## Distinct active zones under the body, each cast group once at its highest covered level,
## in stable (gid) order. A zone under a ground-layer prop waits (gdd_battle §4.11).
static func zones_under(b: Battle, u: BattleUnit) -> Array[BoardZone]:
	var by_gid := {}
	for p in u.cells():
		var c := b.board.at(p)
		if c == null or c.zone == null or (c.prop != null and c.prop.def.solid):
			continue
		var z: BoardZone = c.zone
		if not by_gid.has(z.gid) or by_gid[z.gid].level < z.level:
			by_gid[z.gid] = z
	var gids := by_gid.keys()
	gids.sort()
	var out: Array[BoardZone] = []
	for g in gids:
		out.append(by_gid[g])
	return out


## Ground types under a ground-layer body: {ground id: highest level}, each type once
## (gdd_battle §4.3 mixed ground). Air-layer monsters ignore ground.
static func grounds_under(b: Battle, u: BattleUnit, cells: Array[Vector2i] = []) -> Dictionary:
	var out := {}
	if u.layer != Board.GROUND:
		return out
	for p in (cells if not cells.is_empty() else u.cells()):
		var c := b.board.at(p)
		if c != null:
			out[c.ground] = maxi(out.get(c.ground, 0), c.level)
	return out


## True if the whole body stands on Mountain squares (ground layer only).
static func on_mountain(b: Battle, u: BattleUnit) -> bool:
	if u.layer != Board.GROUND:
		return false
	for p in u.cells():
		if not b.board.at(p).is_mountain():
			return false
	return true


## Props orthogonally adjacent to the body, each once, in stable (uid) order.
static func adjacent_props(b: Battle, u: BattleUnit) -> Array[BoardProp]:
	var seen := {}
	for p in u.cells():
		for d in Board.CARDINAL:
			var q: Vector2i = p + d
			if u.covers(q) or not b.board.in_bounds(q):
				continue
			var c := b.board.at(q)
			for prop: BoardProp in [c.prop, c.air_prop]:
				if prop != null and prop.hp > 0:
					seen[prop.uid] = prop
	var uids := seen.keys()
	uids.sort()
	var out: Array[BoardProp] = []
	for id in uids:
		out.append(seen[id])
	return out


static func _ignored_tags(u: BattleUnit) -> Dictionary:
	var out := {}
	for s in u.passives():
		for t in s.ignores_effects:
			out[t] = true
	return out


## Every continuous effect on the unit: [{key, tag, value}], de-duplicated per source key.
static func contributions(b: Battle, u: BattleUnit) -> Array[Dictionary]:
	var raw: Array[Dictionary] = []
	for z in zones_under(b, u):
		for e in z.def.effects:
			if e.affects_layer(u.layer) and (e.tag == FieldEffect.PUSH or e.tag == FieldEffect.PULL):     # a zone changes no stat
				raw.append({"key": "zone:%d" % z.gid, "tag": e.tag, "value": e.value_at(z.level)})
	var grounds := grounds_under(b, u)
	for gid: StringName in grounds:
		var g := b.content.ground(gid)
		if g == null:
			continue
		for e in g.effects:
			if e.affects_layer(u.layer):
				raw.append({"key": "ground:%s" % gid, "tag": e.tag, "value": e.value_at(grounds[gid])})
	for prop in adjacent_props(b, u):
		for e in prop.def.aura:
			if e.affects_layer(u.layer):
				raw.append({"key": "prop:%d" % prop.uid, "tag": e.tag, "value": e.value_at(1)})
	var high := on_mountain(b, u)
	if high:
		raw.append({"key": "mountain", "tag": FieldEffect.EXTEND, "value": 1})
	for s in u.passives():
		if s.passive_condition == "on_mountain" and not high:
			continue
		for e in s.passive_effects:
			raw.append({"key": "passive:%s" % s.id, "tag": e.tag, "value": e.value_at(1)})
	for fx in u.effects:
		raw.append({"key": String(fx["key"]), "tag": fx["tag"], "value": fx["value"]})
	var ignored := _ignored_tags(u)
	var seen := {}
	var out: Array[Dictionary] = []
	for r in raw:
		if ignored.has(r["tag"]):
			continue
		var k := "%s|%s" % [r["key"], r["tag"]]
		if seen.has(k):
			continue
		seen[k] = true
		out.append(r)
	return out


static func total(b: Battle, u: BattleUnit, tag: String) -> int:
	var sum := 0
	for c in contributions(b, u):
		if c["tag"] == tag:
			sum += int(c["value"])
	return sum


## A drain point counts double (user decision 2026-11-18, docs/battle.md §2.3): `drain_pace 1` lowers Pace by 0.2, so a
## drain can pass a monster of lower base Pace; `quicken 1` still raises it by 0.1.
const DRAIN_FACTOR := 2


## Effective Pace: the queue position of a monster. `quicken` and `drain_pace` change it in Pace points.
static func pace(b: Battle, u: BattleUnit) -> float:
	var v := u.sheet.pace + u.sheet.pace_bonus + PACE_POINT * (total(b, u, FieldEffect.QUICKEN) - DRAIN_FACTOR * total(b, u, FieldEffect.DRAIN_PACE))
	return maxf(MIN_PACE, snappedf(v, 0.1))


static func movement(b: Battle, u: BattleUnit) -> int:
	return maxi(MIN_MOVEMENT, u.sheet.movement + total(b, u, FieldEffect.HASTE) - total(b, u, FieldEffect.SLOW))


static func reach(b: Battle, u: BattleUnit) -> int:
	return maxi(MIN_REACH, u.sheet.reach + total(b, u, FieldEffect.EXTEND) - total(b, u, FieldEffect.DRAIN_RANGE))


## Battle-AP per turn: the AP stat; no temporary AP edits exist (gdd_skills §4).
static func ap(u: BattleUnit) -> int:
	var bonus := 0                            # experiment: timed unit effects vigor / sap
	for fx in u.effects:
		if fx["tag"] == FieldEffect.VIGOR:
			bonus += int(fx["value"])
		elif fx["tag"] == FieldEffect.SAP:
			bonus -= int(fx["value"])
	return maxi(1, u.sheet.ap + bonus)


## Value reduction against Surge damage (gdd_battle §6.1): zone shield, Hallowed, Wardstone,
## guarding allies and the unit's own passives add without a cap.
static func surge_reduction(b: Battle, u: BattleUnit) -> int:
	var r := total(b, u, FieldEffect.SHIELD)
	for other in b.living(u.side):
		if other.id == u.id:
			continue
		for s in other.passives():
			if s.guards_adjacent_allies > 0 and _bodies_orth_adjacent(u, other):
				r += s.guards_adjacent_allies
				break
	for s in u.passives():
		if s.reduces_damage.has("surge"):
			r += s.reduction
	return r


## Reduction of a non-Surge damage type from the unit's own passives.
static func passive_reduction(u: BattleUnit, type: String) -> int:
	var r := 0
	for s in u.passives():
		if s.reduces_damage.has(type):
			r += s.reduction
	return r


static func _bodies_orth_adjacent(a: BattleUnit, c: BattleUnit) -> bool:
	for p in a.cells():
		if c.orth_adjacent_to(p):
			return true
	return false


static func ignores_ground(u: BattleUnit, ground: StringName) -> bool:
	for s in u.passives():
		if s.ignores_grounds.has(ground):
			return true
	return false


## Push and pull of `kind` ("strike": a Strike or another skill, "zone", "prop") do not move this unit: a timed
## anchor, its own passive against that kind, or an anchoring ally next to it.
static func is_immovable(b: Battle, u: BattleUnit, kind := "strike") -> bool:
	for fx in u.effects:
		if fx["tag"] == FieldEffect.ANCHOR:
			return true
	for s in u.passives():
		if s.immovable or (s.unmoved_by != "" and s.unmoved_by == kind):
			return true
	for other in b.living(u.side):
		if other.id == u.id:
			continue
		for s in other.passives():
			if s.anchors_adjacent_allies and _bodies_orth_adjacent(u, other):
				return true
	return false


## Whether a passive of the unit (kit, Kin trait or gift) sets the flag `name` of BattleSkillDef.
static func has_flag(u: BattleUnit, name: StringName) -> bool:
	for s in u.passives():
		if bool(s.get(name)):
			return true
	return false


static func ignores_ground_at(u: BattleUnit, timing: String) -> bool:
	for s in u.passives():
		if s.ignores_ground_moments.has(timing):
			return true
	return false


static func ground_rounds_bonus(u: BattleUnit) -> int:
	var n := 0
	for s in u.passives():
		n += s.ground_rounds_bonus
	return n


static func is_rooted(u: BattleUnit) -> bool:
	for s in u.passives():
		if s.rooted:
			return true
	return false


static func can_rotate(_u: BattleUnit) -> bool:
	return not BattleExperiment.no_rotation   # every monster may turn its shapes (build rule, T38)


static func phases(u: BattleUnit) -> bool:
	for s in u.passives():
		if s.phasing:
			return true
	return false


## Stamina a monster recovers at the end of a round: the whole number of the Pace it has at that moment, at
## least 1 (user decisions 2026-11-15; the current value counts, not the one on the sheet). A zone or a timed
## effect on Pace therefore changes the recovery when it carries the monster across a whole number.
static func recovery(b: Battle, u: BattleUnit) -> int:
	if BattleExperiment.stamina_regen > 0:
		return BattleExperiment.stamina_regen
	return maxi(1, floori(pace(b, u) + 0.0001)) + total(b, u, FieldEffect.REFRESH)
