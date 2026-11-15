class_name BoardSheet
extends RefCounted
## One sheet for ground, zones and props (gdd_battle §4.3, user decision 2026-11-15): a head (where it
## lies, how it ends, whom it acts on, movement cost, levels, HP) and lines "when · what · how much ·
## where". The three kinds keep their own Resource files (GroundDef, BattleZoneDef, PropDef); this class
## reads all of them into the same lines, for the overview, for hover texts and for the role check.
##
## A line: {when (Moment), what (effect word), amount, cap, level_based, shape, extension, thing}.

## Head and lines of a ground type.
static func ground(g: GroundDef) -> Dictionary:
	var lines: Array[Dictionary] = []
	for t in g.triggers:
		lines.append(_line(t.timing, t.kind, t.amount, "self", 0, &"", t.amount <= 0))
	for e in g.effects:
		lines.append(_line(Moment.INSIDE, e.tag, e.base, "self", 0, &"", false, e.cap))
	var ends := "never" if g.immutable or g.id == GroundDef.PLAIN else ("laid in battle: %d rounds; on the starting board: stays" % BattleExperiment.ground_rounds if BattleExperiment.ground_rounds > 0 else "stays until changed")
	return {"kind": "ground", "id": g.id, "name": g.display_name, "lies": "ground layer", "ends": ends, "acts_on": "who stands on the square",
		"move_cost": g.move_cost, "levels": g.max_level, "hp": 0, "lines": lines}


## Head and lines of a zone (its rounds come from the skill that creates it).
static func zone(z: BattleZoneDef) -> Dictionary:
	var lines: Array[Dictionary] = []
	for e in z.effects:
		var moves := e.tag == FieldEffect.PUSH or e.tag == FieldEffect.PULL
		lines.append(_line(Moment.TURN_END if moves else Moment.INSIDE, e.tag, e.base, "self", 0, &"", false, e.cap))
	return {"kind": "zone", "id": z.id, "name": z.display_name, "lies": "zone layer", "ends": "after the rounds its skill names; an opposite zone",
		"acts_on": "who stands on the square", "move_cost": 0, "levels": BattleZoneDef.MAX_LEVEL, "hp": 0, "lines": lines}


## Head and lines of a prop.
static func prop(p: PropDef) -> Dictionary:
	var lines: Array[Dictionary] = []
	for e in p.aura:
		lines.append(_line(Moment.INSIDE, e.tag, e.base, "whirl", 0, &"", false, e.cap))
	if p.repel:
		lines.append(_line(Moment.TURN_END, "push", 1, "whirl"))
	for a in p.aftermath:
		if a == null:
			continue
		var thing: StringName = a.spawn_prop if a.op == "spawn" else (a.ground if a.op == "ground" else (a.zone if a.op == "zone" else &""))
		lines.append(_line(a.when, "prop" if a.op == "spawn" else a.op, a.amount, a.shape, a.extension, thing))
	if p.ground_left != &"" and p.ground_left != GroundDef.PLAIN:
		lines.append(_line(Moment.DESTROYED, "ground", p.ground_left_level, "self", 0, p.ground_left))
	var lies := "occupant, solid" if p.solid else "occupant, walkable"
	return {"kind": "prop", "id": p.id, "name": p.display_name, "lies": lies, "ends": "at 0 HP" + ("; used up when entered" if p.is_trap() else ""),
		"acts_on": "the squares of its shape" if p.solid else "its own square and the squares of its shape",
		"move_cost": 0, "levels": 1, "hp": p.hp, "lines": lines}


static func _line(when: String, what: String, amount: int, shape := "self", extension := 0, thing := &"", level_based := false, cap := -1) -> Dictionary:
	return {"when": when, "what": what, "amount": amount, "cap": cap, "level_based": level_based, "shape": shape, "extension": extension, "thing": thing}


## What a line does, in words: "1 damage (the level)", "heals 1", "Pace −0.1", "push 1", "creates Lava".
static func what_text(c: BattleContent, line: Dictionary) -> String:
	var n: int = line["amount"]
	match String(line["what"]):
		"damage":
			return "damage = level" if line["level_based"] else "%d damage" % n
		"heal":
			return "heals %d" % n
		"push", "pull":
			return "%s %d" % [line["what"], maxi(1, n)]
		"ground":
			var g := c.ground(line["thing"]) if c != null else null
			return "creates %s" % (g.display_name if g != null else String(line["thing"]))
		"zone":
			var z := c.zone(line["thing"]) if c != null else null
			return "creates the zone %s" % (z.display_name if z != null else String(line["thing"]))
		"prop":
			var p := c.prop(line["thing"]) if c != null else null
			return "creates %s" % (p.display_name if p != null else String(line["thing"]))
	var e := FieldEffect.make(String(line["what"]), n, int(line["cap"]))
	return BattleText.effect_words(e)


## Where a line acts: "" for the square itself, else "on the 4 neighbours" and the like.
static func where_text(line: Dictionary) -> String:
	var shape := StringName(line["shape"])
	if shape == BattleShapes.SELF:
		return ""
	var n := BattleShapes.count(shape, int(line["extension"]))
	return "on %s (%d sq)" % [BattleShapes.shape_name(shape, int(line["extension"])), n]


## One line as text: "on entering: damage = level", "when destroyed: 1 damage on Storm (8 sq)".
static func line_text(c: BattleContent, line: Dictionary) -> String:
	var where := where_text(line)
	return "%s: %s%s" % [Moment.moment_name(line["when"]), what_text(c, line), "" if where == "" else " " + where]


## All lines of a sheet as one text, one line per row.
static func lines_text(c: BattleContent, sheet: Dictionary) -> String:
	var rows: PackedStringArray = []
	for line: Dictionary in sheet["lines"]:
		rows.append(line_text(c, line))
	return "\n".join(rows)


## Lines that break the roles of the three kinds (Moment.MOMENTS / Moment.EFFECTS): ground acts at a
## moment and changes no stat, a zone acts while inside and deals no damage, a prop acts around itself.
static func role_problems(sheet: Dictionary) -> PackedStringArray:
	var out: PackedStringArray = []
	var kind: String = sheet["kind"]
	for line: Dictionary in sheet["lines"]:
		if not (Moment.MOMENTS[kind] as Array).has(line["when"]):
			out.append("%s '%s' acts %s: no moment of a %s" % [kind, sheet["id"], Moment.moment_name(line["when"]), kind])
		if not (Moment.EFFECTS[kind] as Array).has(line["what"]):
			out.append("%s '%s' does '%s': not an effect of a %s" % [kind, sheet["id"], line["what"], kind])
		if kind != "prop" and StringName(line["shape"]) != BattleShapes.SELF:
			out.append("%s '%s' acts off its own square" % [kind, sheet["id"]])
	return out
