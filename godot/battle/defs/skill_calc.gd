class_name SkillCalc
extends RefCounted
## The skill calculation (draft, gdd_skills §7): every part of a skill card has a price in points, the sum
## is what the skill is worth, and POINTS_PER_AP points are what one AP pays for. No rule reads it: it is an
## authoring aid (skill builder, overview) and gives generated skills their AP (SkillGen.draw_kind).
##
##   features    the parts of any skill as numbers: {part: amount}; the vocabulary the measuring runs
##               (tools/skill_impact.gd) fit and the price list is written in
##   lines       the priced parts of a skill as rows [part, amount, points]
##   points      their sum
##   fair_ap     the AP that sum pays for
##
## PRICES is a DRAFT fitted to bot runs (docs/simulation_log.md S032); nothing in it is approved. Zero point:
## a Jab with 2 damage and a push is 20 points. Effects of self buffs the runs did not field (AP, turns) fall
## back on DEFAULT_THING and are not measured.

const POINTS_PER_AP := 10.0
const MIN_AP := 1
const MAX_AP := 5

## Points per unit of a part (parts not listed cost nothing). "×extra" rows count every square after the first.
const PRICES := {
	"anchor:adjacent": 0.5, "anchor:user": 1.5, "damage": 19.5, "damage×extra": -0.5, "ground:blight": 12.5,
	"ground:lava": 10.0, "ground:mossbed": 16.5, "ground:snare": 16.5, "ground:thornbed": 7.5, "ground×extra": 0.0,
	"impact:ahead": 8.0, "impact:ring": 15.5, "kind:ground": -30.5, "kind:move": -1.0, "kind:prop": -30.5,
	"kind:strike": -29.0, "kind:zone": -30.5, "leaves:move": -12.0, "leaves:strike": -12.5, "path:free": -5.0, "path:diagonal": 5.0,
	"path:line": 0.5, "prop:ancestor_tablet": 17.0, "prop:bamboo_stand": 21.0, "prop:bronze_gong": 16.0, "prop:clay_urn": 23.5,
	"prop:earth_wall": 16.0, "prop:ember_brazier": 21.5, "prop:pagoda_column": 17.0, "prop:paper_lantern": 15.5, "prop:peach_tree": 13.0,
	"prop:spike_trap": 17.5, "prop:stone_lion": 13.0, "prop:storm_drum": 14.0, "prop:thorn_idol": 22.0, "prop:vortex_trap": 14.0,
	"prop:vortex_urn": 15.0, "prop×extra": 0.5, "push": 9.5, "push×extra": 0.0, "range+": 2.0,
	"rounds+": 1.0, "shape:arc": 6.0, "shape:arc+1": 9.5, "shape:cross": -21.5, "shape:jab+1": 6.0,
	"shape:jab+2": 7.0, "shape:pincer": -3.5, "shape:storm": 5.0, "shape:whirl": -5.0, "use:battle": -6.0,
	"use:round": 1.0, "use:twice": 2.0, "zone:bog": 11.5, "zone:gale": 11.5, "zone:mire": 5.5,
	"zone:shockwave": 11.5, "zone:slowing": 7.0, "zone:tailwind": 8.0, "zone:void_pull": 11.5, "zone×extra": 0.0,
	"ground:shifting_sand": 13.5, "ground:springwater": 8.5, "zone:erosion": 8.5, "zone:updraft": 6.5,
	"ground:entry_damage": 7.5, "ground:stay_damage": 10.0, "ground:exit_damage": 16.5, "ground:entry_heal": 16.5,
	"ground:entry_stamina": 8.5, "ground:no_prop": 13.5, "zone:push_zone": 11.5, "zone:pull_zone": 11.5, "zone:prop_damage_zone": 8.5,
	"kind:self": -12.0, "self:extend": -4.5, "self:haste": -2.0, "self:quicken": -4.5, "self:refresh": -0.5,
}
## Points of one square of a ground, zone or prop not named in PRICES.
const DEFAULT_THING := {"ground": 12.5, "zone": 9.5, "prop": 17.0, "self": 4.0}


## The parts of a skill as numbers. Squares a created thing covers: the shape of a Strike, the range of a
## movement (the squares it leaves), the shape of a placed skill.
static func features(content: BattleContent, s: BattleSkillDef) -> Dictionary:
	var f := {}
	var kind := KitDraw.kind_of(content, s)
	var covered := 1
	match kind:
		"strike":
			covered = s.shape_squares()
			f["kind:strike"] = 1.0
			f["shape:%s" % BattleShapes.key(s.shape_id(), s.shape_extension)] = 1.0
			if s.strike_damage > 0:
				f["damage"] = float(s.strike_damage)
				f["damage×extra"] = float(s.strike_damage * (covered - 1))
			if s.strike_push:
				f["push"] = 1.0
				f["push×extra"] = float(covered - 1)
		"move":
			covered = s.move_range if s.move_range > 0 else 3
			f["kind:move"] = 1.0
			f["path:%s" % s.move_path] = 1.0
			if s.move_path == "line" and s.move_diagonal:
				f["path:diagonal"] = 1.0
			f["range+"] = float(covered - 2)
			if s.impact_push != "none":
				f["impact:%s" % s.impact_push] = 1.0
		"":
			return f
		"self":
			f["kind:self"] = 1.0
			for e in s.buff_effects:
				f["self:%s" % e.tag] = float(e.value_at(1))
			f["rounds+"] = float(s.duration - 1)
		_:
			covered = maxi(1, s.shape_squares())
			f["kind:%s" % kind] = 1.0
			if not s.is_free_shape():
				f["anchor:user"] = 1.0
			elif s.anchor_mode == "adjacent":
				f["anchor:adjacent"] = 1.0
	var things := 0
	if s.kind == BattleSkillDef.ZONE and s.zone != null:
		_thing(f, "zone", s.zone.id, covered)
		f["rounds+"] = float(s.duration - 1)
		things += 1
	for op in s.board_ops:
		match op.op:
			BoardOp.GROUND:
				_thing(f, "ground", op.ground, covered)
				things += 1
			BoardOp.CREATE_ZONE:
				_thing(f, "zone", op.zone, covered)
				f["rounds+"] = float(f.get("rounds+", 0.0)) + float(op.zone_rounds - 1)
				things += 1
			BoardOp.CREATE_PROP:
				_thing(f, "prop", op.prop, covered)
				things += 1
	if things > 0 and (kind == "strike" or kind == "move"):
		f["leaves:%s" % kind] = 1.0
	if s.repetition == "once_per_battle":
		f["use:battle"] = 1.0
	elif s.repetition == "once_per_round":
		f["use:round"] = 1.0
	elif s.usage_limit != 1:
		f["use:twice"] = 1.0
	return f


static func _thing(f: Dictionary, what: String, id: StringName, covered: int) -> void:
	f["%s:%s" % [what, id]] = float(f.get("%s:%s" % [what, id], 0.0)) + 1.0
	if covered > 1:
		f["%s×extra" % what] = float(f.get("%s×extra" % what, 0.0)) + float(covered - 1)


## The parts as text for run reports: "damage=2", "ground:lava", "ap=2".
static func part_names(content: BattleContent, s: BattleSkillDef) -> Array[String]:
	var out: Array[String] = []
	var f := features(content, s)
	for key: String in f:
		out.append(key if is_equal_approx(f[key], 1.0) and key.contains(":") else "%s=%d" % [key, int(f[key])])
	out.append("ap=%d" % s.ap_cost)
	return out


static func price_of(part: String) -> float:
	if PRICES.has(part):
		return PRICES[part]
	var what := part.get_slice(":", 0)
	if part.contains(":") and DEFAULT_THING.has(what):
		return DEFAULT_THING[what]
	return 0.0


## The priced parts of a skill: rows [part, amount, points], parts without a price left out.
static func lines(content: BattleContent, s: BattleSkillDef) -> Array:
	var out: Array = []
	var f := features(content, s)
	for key: String in f:
		var p := price_of(key) * float(f[key])
		if not is_zero_approx(p):
			out.append([key, f[key], p])
	return out


static func points(content: BattleContent, s: BattleSkillDef) -> float:
	var total := 0.0
	for row: Array in lines(content, s):
		total += row[2]
	return total


## The AP the points of a skill pay for (1–5).
static func fair_ap(content: BattleContent, s: BattleSkillDef) -> int:
	return clampi(roundi(points(content, s) / POINTS_PER_AP), MIN_AP, MAX_AP)


## One line for a skill: "23 points · fair 2 AP · costs 2 AP".
static func summary(content: BattleContent, s: BattleSkillDef) -> String:
	if KitDraw.kind_of(content, s) == "":
		return "not priced"
	return "%d points · fair %d AP · costs %d AP" % [roundi(points(content, s)), fair_ap(content, s), s.ap_cost]


const LABELS := {
	"kind:strike": "a Strike", "kind:move": "a movement", "damage": "damage", "damage×extra": "damage on every further square",
	"push": "push", "push×extra": "push on every further square", "range+": "range above 2",
	"impact:ahead": "pushes the monster ahead", "impact:ring": "pushes all neighbours", "path:line": "straight line over everything", "path:diagonal": "the line may run diagonally (not measured)",
	"path:free": "any path over everything", "ground×extra": "ground on every further square", "zone×extra": "zone on every further square",
	"prop×extra": "every further prop", "rounds+": "zone rounds above 1", "anchor:adjacent": "anchor next to the user",
	"anchor:user": "shape around the user", "leaves:strike": "created by a Strike", "leaves:move": "left by a movement",
	"use:twice": "twice per turn", "use:round": "once per round", "use:battle": "once per battle",
}


## A part in words: "damage", "Ground lava", "Shape arc+1".
static func label(part: String) -> String:
	if LABELS.has(part):
		return LABELS[part]
	return "%s %s" % [part.get_slice(":", 0).capitalize(), part.get_slice(":", 1).replace("_", " ")]


## The calculation of a skill as rows of text [part, points] with the sum, the AP it pays for and the AP on
## the card (overview and skill builder); [] for a skill that is not priced.
static func table(content: BattleContent, s: BattleSkillDef) -> Array:
	var out: Array = []
	if KitDraw.kind_of(content, s) == "":
		return out
	for row: Array in lines(content, s):
		var amount := "" if is_equal_approx(row[1], 1.0) else " × %d" % int(row[1])
		out.append([label(row[0]) + amount, "%+.1f" % row[2]])
	out.append(["Total", "%d" % roundi(points(content, s))])
	out.append(["Pays for", "%d AP (%d points per AP)" % [fair_ap(content, s), int(POINTS_PER_AP)]])
	out.append(["On the card", "%d AP" % s.ap_cost])
	return out
