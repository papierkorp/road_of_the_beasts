extends RefCounted
## Test builds for simulation runs: turns a SimBuildDef (res://tools/data/builds) into the unit
## sheet a battle resolves and checks what it costs.
## Use it through `const Builds := preload("res://tools/lib/sim_builds.gd")`.
##
## Checked per build: stat spend against the stage budget, stage ceilings, slot prices against
## the slot-level ceiling, skill AP against the AP stat and Strike Kin against the monster's
## Kin. Not checked: species access and progression reachability. The budget tables mirror
## gdd_monsters §2.2 / §2.3 and are not their owner.
##
## A build fights with the definition its price record names (`PriceRecord.skill`), and only
## if that definition is exactly what the record pays for: `engine_check` compares the priced
## components with the definition and rejects the slot on any difference. A rejected slot, or
## a record without a definition, is reported as NOT SIMULATED; nothing is filled in.

const Pricing := preload("res://tools/lib/skill_pricing.gd")

const BUILDS := "res://tools/data/builds"
const SKILLS := "res://data/battle/skills"

const BASE_POINTS := 15
const BUDGET := {
	"qi": {"lower": 4, "middle": 5, "high": 6},
	"foundation": {"lower": 10, "middle": 11, "high": 12},
	"core": {"lower": 14, "middle": 15, "high": 16},
	"soul": {"lower": 18, "middle": 19, "high": 20},
}
## Stage ceilings (gdd_monsters §2.3).
const CEIL := {
	"qi": {"hp": 4, "init": 5.0, "tpr": 1, "move": 3, "reach": 2, "ap": 2},
	"foundation": {"hp": 6, "init": 7.0, "tpr": 2, "move": 4, "reach": 3, "ap": 2},
	"core": {"hp": 8, "init": 9.0, "tpr": 2, "move": 5, "reach": 3, "ap": 3},
	"soul": {"hp": 10, "init": 10.0, "tpr": 3, "move": 5, "reach": 4, "ap": 3},
}
const TPR_PRICE := {1: 3, 2: 8, 3: 15}
const AP_PRICE := {2: 6, 3: 9, 4: 14, 5: 21}

## [base at level I, cap] of the zone effects whose scaling is decided (gdd_battle §4.6). The
## other effects have no decided cap: nothing is extrapolated from zone level III or a stat
## ceiling, so their definitions must stay at the base value.
const ZONE_BOUNDS := {"slow": [1, 2], "push": [1, 1], "pull": [1, 1], "shield": [2, 3], "mend": [1, 2]}
const ZONE_UNDECIDED: Array[String] = ["haste", "drain_init", "quicken", "drain_range", "extend"]
## Priced ground package of a ground id laid as residue (level I).
const RESIDUE_PRICE := {&"lava": "lava_1", &"thornbed": "thornbed_1", &"blight": "blight_1", &"hearth": "hearth",
	&"umbra": "umbra", &"hallowed": "hallowed", &"mossbed": "mossbed", &"plain": "plain", &"rubble": "rubble"}
const ANCHOR_PRICE := {"reach": "free", "adjacent": "adjacent"}


static func list_builds() -> Array[String]:
	return Pricing.ids_in(BUILDS)


static func load_build(id: String) -> SimBuildDef:
	var path := BUILDS.path_join(id + ".tres")
	return load(path) as SimBuildDef if ResourceLoader.exists(path) else null


static func kin_name(kin: int) -> String:
	return String(MonsterDef.Kin.keys()[kin]).to_lower()


## Stat cost of a build (gdd_monsters §2.2): {"ok", "points", "error"}.
static func stat_points(def: SimBuildDef) -> Dictionary:
	if def.hp < 1 or def.movement < 1 or def.reach < 1 or def.initiative <= 0.0:
		return {"ok": false, "points": 0.0, "error": "HP, Movement, Reach and Initiative must be positive"}
	if not TPR_PRICE.has(def.tpr) or not AP_PRICE.has(def.ap):
		return {"ok": false, "points": 0.0, "error": "TPR %d / AP %d not priced" % [def.tpr, def.ap]}
	var points: float = def.hp + def.initiative + def.movement + (def.reach - 1) * 3.0 + float(TPR_PRICE[def.tpr]) + float(AP_PRICE[def.ap])
	return {"ok": true, "points": points, "error": ""}


## Hit cells, cells outside the adjacent ring and whether a direction is chosen, read from the
## engine's own shape table so a Strike record is checked against what the battle resolves.
static func strike_geometry(shape: StringName) -> Dictionary:
	var dirs := StrikeShapes.directions(shape)
	var hits := StrikeShapes.hits(shape, dirs[0])
	var distant := 0
	for h in hits:
		var o: Vector2i = h["o"]
		if maxi(absi(o.x), absi(o.y)) > 1:
			distant += 1
	return {"cells": hits.size(), "distant": distant, "direction": dirs.size() > 1}


# ---------- price record against its definition ----------

static func _no(message: String) -> Dictionary:
	return {"error": message, "notes": [] as Array[String]}


static func _ok(notes: Array[String] = []) -> Dictionary:
	return {"error": "", "notes": notes}


## The components of a record grouped by type.
static func _by_type(rec: PriceRecord) -> Dictionary:
	var out := {}
	for c in rec.components:
		if c == null:
			continue
		if not out.has(c.type):
			out[c.type] = [] as Array[PriceComponent]
		out[c.type].append(c)
	return out


## "" if the grouped components are exactly `counts` (type -> number).
static func _package(by_type: Dictionary, counts: Dictionary, what: String) -> String:
	var same := by_type.size() == counts.size()
	for t: String in counts:
		if not by_type.has(t) or (by_type[t] as Array).size() != int(counts[t]):
			same = false
	return "" if same else "%s: the priced components do not match the package %s" % [what, counts]


## Does `rec.skill` resolve exactly what `rec` prices? {"error", "notes"}: a non-empty error
## rejects the slot; notes name limits of an accepted one (an unapproved fixture, an effect
## that is only covered at level I).
static func engine_check(rec: PriceRecord) -> Dictionary:
	var s := rec.skill
	if s == null:
		return _no("no engine definition: a price reference only")
	var by_type := _by_type(rec)
	var result: Dictionary
	if rec.usage == PriceRecord.PASSIVE_BOOLEAN:
		if s.kind != BattleSkillDef.PASSIVE or not s.rotate_shapes or _package(by_type, {PriceComponent.ROTATION: 1}, "passive") != "":
			return _no("among passive records only the rotation permission can be checked against a definition")
		result = _ok()
	elif rec.usage != PriceRecord.ACTIVE:
		return _no("event records cannot be checked against a definition")
	elif not s.is_active():
		return _no("an active record names a passive definition")
	elif rec.ap != s.cost():
		return _no("the record prices %d AP, the definition costs %d" % [rec.ap, s.cost()])
	elif s.repetition == "once_per_battle" or rec.once_per_round != (s.repetition == "once_per_round"):
		return _no("the record's round limit and the definition's repetition '%s' differ" % s.repetition)
	else:
		match s.kind:
			BattleSkillDef.STRIKE:
				result = _strike(s, by_type)
			BattleSkillDef.SURGE:
				result = _surge(s, by_type)
			BattleSkillDef.ZONE:
				result = _zone(s, by_type)
			BattleSkillDef.BUFF:
				result = _buff(s, by_type)
			BattleSkillDef.MOVE:
				result = _move(s, by_type)
			_:
				return _no("definitions of kind '%s' cannot be checked against a price yet" % s.kind)
	if result["error"] == "" and rec.fixture.strip_edges() != "":
		result["notes"].append("TEST FIXTURE, no GDD geometry approval: %s" % rec.fixture)
	return result


static func _strike(s: BattleSkillDef, by_type: Dictionary) -> Dictionary:
	var shape := StringName(s.strike_shape)
	if not StrikeShapes.has(shape):
		return _no("unknown Strike shape '%s'" % shape)
	var has_damage := by_type.has(PriceComponent.DAMAGE)
	var e := _package(by_type, {PriceComponent.DAMAGE: 1, PriceComponent.STRIKE_EXTRAS: 1} if has_damage
		else {PriceComponent.STRIKE_EXTRAS: 1}, "strike")
	if e != "":
		return _no(e)
	var g := strike_geometry(shape)
	var ex: PriceComponent = by_type[PriceComponent.STRIKE_EXTRAS][0]
	# body-relative variants (gdd_skills §3) are their own skills: Scaled push, Winged retreat
	var variant := s.radial_push or s.self_retreat
	if (s.radial_push and s.self_retreat) or (variant and s.kin_effect) or (not variant and not s.kin_effect):
		return _no("a Strike is priced either with its Kin effect or as one body-relative variant")
	if (s.radial_push and ex.kin != "scaled") or (s.self_retreat and ex.kin != "winged"):
		return _no("push variants are priced for Scaled, retreat variants for Winged")
	# a radial push only moves monsters on hit cells next to the origin
	var kin_cells: int = g["cells"] - g["distant"] if s.radial_push else g["cells"]
	if ex.direction != g["direction"] or ex.kin_cells != kin_cells or ex.distant_cells != int(g["distant"]):
		return _no("the Strike extras do not match the %s shape (%d cells, %d distant)" % [shape, g["cells"], g["distant"]])
	if has_damage:
		var c: PriceComponent = by_type[PriceComponent.DAMAGE][0]
		if s.strike_damage != KinRules.STRIKE_DAMAGE or c.damage != s.strike_damage or c.cells != int(g["cells"]) \
				or not c.ground_air or c.timing != "immediate":
			return _no("Strike damage must be the fixed 2 on every shape cell, ground and air, immediate")
	elif s.strike_damage != 0 or not variant or shape != &"jab":
		return _no("without a damage component only the Jab-shaped movement-only variants are priced")
	return _ok()


static func _surge(s: BattleSkillDef, by_type: Dictionary) -> Dictionary:
	var pushes := s.surge_displacement != "none"
	var grounds: Array = by_type.get(PriceComponent.GROUND, [])
	var counts := {PriceComponent.DAMAGE: 1, PriceComponent.ANCHOR: 1, PriceComponent.MARKER: 1}
	if pushes:
		counts[PriceComponent.DISPLACEMENT] = 1
	if not grounds.is_empty():
		counts[PriceComponent.GROUND] = grounds.size()
	var e := _package(by_type, counts, "surge")
	if e != "":
		return _no(e)
	var cells := s.footprint.size()
	var damage: PriceComponent = by_type[PriceComponent.DAMAGE][0]
	if damage.damage != s.surge_damage or damage.cells != cells or damage.timing != "telegraphed_avoidable" \
			or damage.ground_air != s.surge_hits_air:
		return _no("Surge damage, cells, timing or air recipients differ from the definition")
	if (by_type[PriceComponent.ANCHOR][0] as PriceComponent).anchor_mode != ANCHOR_PRICE.get(s.anchor_mode, ""):
		return _no("the priced anchor does not match placement '%s'" % s.anchor_mode)
	if pushes:
		var c: PriceComponent = by_type[PriceComponent.DISPLACEMENT][0]
		if c.cells != cells or c.timing != "telegraphed_avoidable":
			return _no("Surge displacement cells or timing differ from the definition")
	if s.surge_mountain != "hit" or s.line_shaped:
		return _no("Mountain blanking and line footprints have no price component")
	# every board operation needs its priced ground package, and the other way round
	var expected: Array[String] = []
	for op in s.board_ops:
		if op.op == BoardOp.GROUND and RESIDUE_PRICE.has(op.ground) and not op.on_mountain:
			expected.append(RESIDUE_PRICE[op.ground])
		elif op.op == BoardOp.DESTROY_MOUNTAIN:
			expected.append("mountain_destroy")
		else:
			return _no("board operation '%s' cannot be checked against a price yet" % op.op)
	var priced: Array[String] = []
	for c: PriceComponent in grounds:
		if c.cells != cells:
			return _no("ground cells differ from the Surge footprint")
		priced.append(c.ground)
	expected.sort()
	priced.sort()
	if expected != priced:
		return _no("priced ground %s differs from the definition's board operations %s" % [priced, expected])
	return _ok()


static func _zone(s: BattleSkillDef, by_type: Dictionary) -> Dictionary:
	var zones: Array = by_type.get(PriceComponent.ZONE, [])
	var e := _package(by_type, {PriceComponent.ZONE: zones.size(), PriceComponent.ANCHOR: 1}, "zone")
	if e != "":
		return _no(e)
	if s.zone == null or zones.is_empty() or zones.size() != s.zone.effects.size() or not s.board_ops.is_empty():
		return _no("a zone record prices exactly the effects of its zone and no board operation")
	if (by_type[PriceComponent.ANCHOR][0] as PriceComponent).anchor_mode != ANCHOR_PRICE.get(s.anchor_mode, ""):
		return _no("the priced anchor does not match placement '%s'" % s.anchor_mode)
	var notes: Array[String] = []
	var seen := {}
	for effect in s.zone.effects:
		var c: PriceComponent = null
		for candidate: PriceComponent in zones:
			if candidate.effect == effect.tag:
				c = candidate
		if c == null or seen.has(effect.tag):
			return _no("zone effect %s: priced components and definition differ" % effect.tag)
		seen[effect.tag] = true
		if c.cells != s.footprint.size() or c.rounds != s.duration:
			return _no("zone %s: priced cells or rounds differ from footprint and duration" % effect.tag)
		if c.value != effect.base:
			return _no("zone %s: the price must use the authored level-I value %d" % [effect.tag, effect.base])
		if not effect.affects_ground or effect.affects_air:
			return _no("zone %s: only ground recipients are covered by the zone rate" % effect.tag)
		if ZONE_BOUNDS.has(effect.tag):
			var bound: Array = ZONE_BOUNDS[effect.tag]
			if effect.base != int(bound[0]) or effect.cap != int(bound[1]):
				return _no("zone %s: base / cap must be %d / %d" % [effect.tag, bound[0], bound[1]])
		elif ZONE_UNDECIDED.has(effect.tag):
			if effect.cap != effect.base:
				return _no("zone %s: its scaling is undecided, the definition must not scale (cap = base)" % effect.tag)
			notes.append("%s: only base level I covered; level > I NOT SIMULATED (cap/scaling unresolved)" % effect.tag)
		else:
			return _no("zone effect %s has no decided value contract" % effect.tag)
	return _ok(notes)


static func _buff(s: BattleSkillDef, by_type: Dictionary) -> Dictionary:
	var e := _package(by_type, {PriceComponent.SELF_BUFF: 1}, "buff")
	if e != "":
		return _no(e)
	var c: PriceComponent = by_type[PriceComponent.SELF_BUFF][0]
	if s.buff_effects.size() != 1 or s.buff_effects[0].tag != FieldEffect.QUICKEN or c.stat != "initiative" \
			or s.buff_effects[0].value_at(1) != c.magnitude or s.duration != c.rounds:
		return _no("a self buff is priced as Initiative +magnitude for its rounds; the definition differs")
	return _ok()


static func _move(s: BattleSkillDef, by_type: Dictionary) -> Dictionary:
	var e := _package(by_type, {PriceComponent.MOVE: 1}, "move")
	if e != "":
		return _no(e)
	var c: PriceComponent = by_type[PriceComponent.MOVE][0]
	# movement is priced by preset, so the definition must be that preset's content record
	if c.patches != 0 or s.resource_path != SKILLS.path_join(c.preset + ".tres"):
		return _no("movement is priced as an unpatched preset: the definition must be %s/%s.tres" % [SKILLS, c.preset])
	return _ok()


# ---------- build ----------

## The build stored as res://tools/data/builds/<id>.tres, assembled (see `assemble`).
static func build(id: String) -> Dictionary:
	return assemble(load_build(id), id)


## Assembles one build: {name, kin, stage, stat_points, stat_spent, skill_points, levels,
## slots: [{skill, level, points, ceiling}], errors, warnings, sheet: UnitSheet, ok}.
## `errors` make the build illegal; a NOT SIMULATED warning means the sheet fights without
## that slot (comparisons refuse such a build).
static func assemble(def: SimBuildDef, id: String) -> Dictionary:
	var errors: Array[String] = []
	var warnings: Array[String] = []
	var slots: Array[Dictionary] = []
	var out := {"name": id, "kin": "", "stage": "", "stat_points": "", "stat_spent": 0.0, "skill_points": 0.0,
		"levels": [] as Array[int], "slots": slots, "errors": errors, "warnings": warnings, "sheet": null, "ok": false}
	if def == null:
		errors.append("no build %s/%s.tres" % [BUILDS, id])
		return out
	var spend := stat_points(def)
	if not spend["ok"] or not BUDGET.has(def.stage) or not (BUDGET[def.stage] as Dictionary).has(def.subtier):
		errors.append("stats/stage not priced: %s" % (spend["error"] if not spend["ok"] else "%s %s" % [def.stage, def.subtier]))
		return out
	var kin := kin_name(def.kin)
	var spent: float = spend["points"]
	var budget: int = BASE_POINTS + int(BUDGET[def.stage][def.subtier])
	out["kin"] = kin
	out["stage"] = "%s %s" % [def.stage, def.subtier]
	out["stat_spent"] = spent
	out["stat_points"] = "%s/%d" % [Pricing.fmt(spent), budget]
	if spent > budget + Pricing.EPS:
		errors.append("stat points %s exceed budget %d" % [Pricing.fmt(spent), budget])
	elif spent < budget - Pricing.EPS:
		warnings.append("%s unspent stat point(s) (allowed, player spends freely)" % Pricing.fmt(budget - spent))
	var stats := {"hp": def.hp, "init": def.initiative, "tpr": def.tpr, "move": def.movement, "reach": def.reach, "ap": def.ap}
	for key: String in stats:
		if float(stats[key]) > float(CEIL[def.stage][key]) + Pricing.EPS:
			errors.append("%s %s above stage ceiling %s" % [key, Pricing.fmt(stats[key]), Pricing.fmt(CEIL[def.stage][key])])
	var sheet := UnitSheet.new()
	sheet.species_id = StringName(id)
	sheet.display_name = id
	sheet.kin = def.kin
	sheet.hp = def.hp
	sheet.initiative = def.initiative
	sheet.movement = def.movement
	sheet.reach = def.reach
	sheet.tpr = def.tpr
	sheet.ap = def.ap
	if def.slots.is_empty() or def.slots.size() > 4:
		errors.append("kit needs 1-4 slots")
		return out
	var actives := 0
	var levels: Array[int] = []
	for i in def.slots.size():
		var slot := def.slots[i]
		var n := i + 1
		if slot == null or slot.record == null:
			errors.append("slot %d: no price record; NOT SIMULATED (unresolved candidates are not free perks)" % n)
			continue
		var rec := slot.record
		var ev := Pricing.evaluate(rec, slot.level)
		if not ev["ok"]:
			errors.append("slot %d %s: incomplete pricing (%s); NOT SIMULATED" % [n, rec.display_name, ev["error"]])
			continue
		if rec.usage == PriceRecord.ACTIVE:
			actives += 1
			if rec.ap > def.ap:
				errors.append("slot %d %s: costs %d AP, monster has %d" % [n, rec.display_name, rec.ap, def.ap])
		if not ev["fits"]:
			errors.append("slot %d %s: %s points exceed ceiling %s of slot level %d" % [
				n, rec.display_name, Pricing.fmt(ev["total"]), Pricing.fmt(ev["ceiling"]), slot.level])
		for c in rec.components:
			if c != null and c.type == PriceComponent.STRIKE_EXTRAS and c.kin != kin:
				errors.append("slot %d %s: Strike Kin %s != monster Kin %s" % [n, rec.display_name, c.kin, kin])
		var check := engine_check(rec)
		if check["error"] != "":
			warnings.append("slot %d %s: NOT SIMULATED (%s)" % [n, rec.display_name, check["error"]])
		else:
			sheet.skills.append(rec.skill)
			for note: String in check["notes"]:
				warnings.append("slot %d %s: %s" % [n, rec.display_name, note])
		slots.append({"skill": rec.display_name, "level": slot.level, "points": Pricing.fmt(ev["total"]), "ceiling": Pricing.fmt(ev["ceiling"])})
		out["skill_points"] += float(ev["total"])
		levels.append(slot.level)
	if actives == 0:
		errors.append("kit needs at least one active skill")
	for problem in sheet.problems():
		errors.append("sheet: %s" % problem)
	levels.sort()
	out["levels"] = levels
	out["sheet"] = sheet
	out["ok"] = errors.is_empty()
	return out


## True if a build can stand in for exactly what it prices: legal and without a NOT SIMULATED part.
static func fully_simulated(result: Dictionary) -> bool:
	if not result["ok"]:
		return false
	for w: String in result["warnings"]:
		if w.to_upper().contains("NOT SIMULATED"):
			return false
	return true


## The build result as readable lines (price.gd).
static func report(result: Dictionary) -> PackedStringArray:
	var lines: PackedStringArray = []
	lines.append("%s: %s" % [result["name"], "legal" if result["ok"] else "NOT LEGAL"])
	if result["kin"] != "":
		lines.append("  %s, %s, stat points %s, skill points %s" % [result["kin"], result["stage"], result["stat_points"], Pricing.fmt(result["skill_points"])])
	for s: Dictionary in result["slots"]:
		lines.append("  slot level %d  %s  %s / %s" % [s["level"], s["skill"], s["points"], s["ceiling"]])
	var sheet: UnitSheet = result["sheet"]
	if sheet != null:
		var kit: PackedStringArray = []
		for s in sheet.skills:
			kit.append("%s (%s, %d AP)" % [s.id, s.kind, s.cost()] if s.is_active() else "%s (passive)" % s.id)
		lines.append("  sheet: HP %d, Init %s, Move %d, Reach %d, TPR %d, AP %d; fights with %s" % [sheet.hp, Pricing.fmt(sheet.initiative),
			sheet.movement, sheet.reach, sheet.tpr, sheet.ap, ", ".join(kit) if not kit.is_empty() else "nothing"])
	for e: String in result["errors"]:
		lines.append("  ERROR %s" % e)
	for w: String in result["warnings"]:
		lines.append("  note  %s" % w)
	return lines
