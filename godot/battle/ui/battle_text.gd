class_name BattleText
extends RefCounted
## Short text for the HUD: skill cards, the square inspector, the cast preview and log lines.
## Presentation only: it reads definitions, state and events and never decides a rule.
##
## House rule: tokens, not sentences. One line per fact ("3 dmg · next turn · 4 sq"), built
## from the data so new content gets its text for free. A card has at most three lines; the
## inspector shows only what is notable about a square.

const ROMAN := ["I", "II", "III"]
const SEP := " · "
const DIR_NAMES := {
	Vector2i(0, -1): "north", Vector2i(1, -1): "north-east", Vector2i(1, 0): "east", Vector2i(1, 1): "south-east",
	Vector2i(0, 1): "south", Vector2i(-1, 1): "south-west", Vector2i(-1, 0): "west", Vector2i(-1, -1): "north-west",
}
const TIMING := {"start_of_turn": "at turn start", "on_enter": "on enter", "end_of_turn": "at turn end"}
const PATHS := {"walk": "walk", "line": "straight line", "free": "any path", "teleport": "teleport"}


static func pos(p: Vector2i) -> String:
	return "[%d,%d]" % [p.x, p.y]


static func dir_name(d: Vector2i) -> String:
	return DIR_NAMES.get(d, "—")


static func rows_to_text(rows: Array) -> String:
	var lines: PackedStringArray = []
	for r in rows:
		lines.append("%s: %s" % [r[0], r[1]] if r[0] != "" else String(r[1]))
	return "\n".join(lines)


static func unit_name(b: Battle, id: StringName) -> String:
	var u: BattleUnit = b.units.get(id)
	return u.display_name() if u != null else String(id)


# ---------- definitions ----------

## "slow 1, shield 2" (an effect that only reaches the air layer is marked).
static func effects_text(effects: Array, level := 1) -> String:
	var parts: PackedStringArray = []
	for e: FieldEffect in effects:
		parts.append(e.text(level) + ("" if e.affects_ground else " (air)"))
	return ", ".join(parts)


## What a ground does, from its data: "2 dmg at turn end", "heal 1 on enter", "quicken 1".
static func ground_brief(g: GroundDef, level := 1) -> String:
	var parts: PackedStringArray = []
	if g.move_cost > 1:
		parts.append("move cost %d" % g.move_cost)
	for t in g.triggers:
		parts.append("%s %s" % ["heal %d" % t.value_at(level) if t.kind == "heal" else "%d dmg" % t.value_at(level), TIMING.get(t.timing, t.timing)])
	if not g.effects.is_empty():
		parts.append(effects_text(g.effects, level))
	return SEP.join(parts)


## What a prop does, from its data: "heavy · leaves Rubble", "burst 1", "aura quicken 1".
static func prop_brief(c: BattleContent, d: PropDef) -> String:
	var parts: PackedStringArray = []
	if d.layer == "air":
		parts.append("air")
	elif d.layer == "both":
		parts.append("ground+air")
	if d.heavy:
		parts.append("heavy")
	if not d.aura.is_empty():
		parts.append("aura " + effects_text(d.aura))
	for a in d.aftermath:
		match a.op:
			"damage":
				parts.append("burst %d" % a.amount)
			"push":
				parts.append("push %d" % a.amount)
			"spawn":
				var child := c.prop(a.spawn_prop)
				parts.append("spawns %s" % (child.display_name if child != null else String(a.spawn_prop)))
	if d.ground_left != &"" and d.ground_left != GroundDef.PLAIN:
		var g := c.ground(d.ground_left)
		parts.append("leaves %s" % (g.display_name if g != null else String(d.ground_left)))
	return SEP.join(parts)


## Board operations as tokens: "Lava I", "Mountain", "breaks Mountain", "+ Stone Lion".
static func ops_tokens(c: BattleContent, ops: Array, residue := false) -> PackedStringArray:
	var parts: PackedStringArray = []
	for op: BoardOp in ops:
		match op.op:
			BoardOp.GROUND:
				var g := c.ground(op.ground)
				var label := g.label(1) if g != null else String(op.ground)
				parts.append("leaves " + label if residue else label)
			BoardOp.RAISE_MOUNTAIN:
				parts.append("Mountain")
			BoardOp.DESTROY_MOUNTAIN:
				parts.append("breaks Mountain")
			BoardOp.CREATE_PROP:
				var p := c.prop(op.prop)
				parts.append("+ " + (p.display_name if p != null else String(op.prop)))
	return parts


static func _area(s: BattleSkillDef) -> String:
	var n := 4 if s.anchor_mode == "caster_ring" else s.footprint.size()
	var where := {"adjacent": "adjacent", "trail": "line from caster", "caster_ring": "around caster"}
	return "%d sq" % n + (SEP + where[s.anchor_mode] if where.has(s.anchor_mode) else "")


static func _usage(s: BattleSkillDef) -> String:
	return {"once_per_round": SEP + "1/round", "once_per_battle": SEP + "1/battle"}.get(s.repetition, "")


## The card of a skill: at most three short lines [["", text], ...]. Name and AP are on the button.
static func skill_rows(c: BattleContent, s: BattleSkillDef, kin := -1) -> Array:
	var rows: Array = []
	match s.kind:
		BattleSkillDef.STRIKE:
			var shape := StringName(s.strike_shape)
			var n := StrikeShapes.hits(shape, StrikeShapes.directions(shape)[0]).size()
			rows.append(["", "%s%s%d sq" % ["%d dmg" % s.strike_damage if s.strike_damage > 0 else "no dmg", SEP, n]])
			var extra: PackedStringArray = []
			if s.kin_effect and kin >= 0 and KinRules.strike(kin).get("text", "") != "":
				extra.append(KinRules.strike(kin)["text"])
			if s.radial_push:
				extra.append("push 1 outward")
			if s.self_retreat:
				extra.append("then retreat 1")
			if not extra.is_empty():
				rows.append(["", SEP.join(extra)])
		BattleSkillDef.SURGE:
			var parts: PackedStringArray = ["%d dmg" % s.surge_damage, "next turn", _area(s)]
			if s.surge_displacement != "none":
				parts.append(s.surge_displacement + " 1")
			if s.surge_mountain == "blank":
				parts.append("not on Mountain")
			if s.surge_hits_air:
				parts.append("hits air")
			rows.append(["", SEP.join(parts)])
			var after := ops_tokens(c, s.board_ops, true)
			if not after.is_empty():
				rows.append(["", SEP.join(after)])
		BattleSkillDef.ZONE:
			rows.append(["", "%s%s%d rd%s%s" % [effects_text(s.zone.effects) if s.zone != null else "—", SEP, s.duration, SEP, _area(s)]])
		BattleSkillDef.GROUND:
			rows.append(["", "%s%s%s" % [SEP.join(ops_tokens(c, s.board_ops)), SEP, _area(s)]])
		BattleSkillDef.MOVE:
			var parts: PackedStringArray = [PATHS.get(s.move_path, s.move_path),
				"Move" + ("" if s.distance_mod == 0 else " %d" % s.distance_mod)]
			if s.blocked_by_height:
				parts.append("not on Mountain")
			rows.append(["", SEP.join(parts)])
		BattleSkillDef.BUFF:
			rows.append(["", "self: %s%s%d rd" % [effects_text(s.buff_effects), SEP, s.duration]])
		BattleSkillDef.PASSIVE:
			rows.append(["", s.description if s.description != "" else "passive"])
	if not rows.is_empty() and s.is_active():
		rows[0][1] += _usage(s)
	return rows


static func step_rows() -> Array:
	return [["", "walk" + SEP + "1 sq"]]


## The pre-battle datasheet: one stat line and the kit.
static func sheet_rows(_c: BattleContent, s: UnitSheet) -> Array:
	var kit: PackedStringArray = []
	for k in s.skills:
		kit.append(k.display_name)
	return [
		["", "%s%sHP %d%sInit %.1f%sMove %d%sReach %d%sAP %d%s" % [MonsterDef.kin_name(s.kin), SEP, s.hp, SEP, s.initiative, SEP,
			s.movement, SEP, s.reach, SEP, s.ap, "" if s.tpr <= 1 else SEP + "TPR %d" % s.tpr]],
		["", SEP.join(kit)],
	]


# ---------- state ----------

static func unit_title(u: BattleUnit) -> String:
	return "%s%s%s%s" % [u.display_name(), SEP + MonsterDef.kin_name(u.kin()), SEP + "2×2" if u.size == 2 else "",
		SEP + "air" if u.layer == Board.AIR else ""]


## A monster under the cursor: live stats, what affects it, its kit. No sources, no sentences.
static func unit_rows(b: Battle, u: BattleUnit) -> Array:
	var rows: Array = [["", "HP %d/%d%sInit %.1f%sMove %d%sReach %d%sAP %d%s" % [u.hp, u.max_hp, SEP, BattleStats.initiative(b, u), SEP,
		BattleStats.movement(b, u), SEP, BattleStats.reach(b, u), SEP, u.sheet.ap, "" if u.sheet.tpr <= 1 else SEP + "TPR %d" % u.sheet.tpr]]]
	var totals := {}
	var order: Array = []
	for c in BattleStats.contributions(b, u):
		if not totals.has(c["tag"]):
			order.append(c["tag"])
		totals[c["tag"]] = int(totals.get(c["tag"], 0)) + int(c["value"])
	var marks: PackedStringArray = []
	for tag: String in order:
		marks.append("%s %d" % [tag, totals[tag]])
	if u.nullify:
		marks.append("Nullify")
	if u.life_thread:
		marks.append("Life Thread")
	if not marks.is_empty():
		rows.append(["", ", ".join(marks)])
	var kit: PackedStringArray = []
	for k in u.sheet.skills:
		kit.append(k.display_name)
	if not kit.is_empty():
		rows.append(["", SEP.join(kit)])
	return rows


static func _prop_row(c: BattleContent, prop: BoardProp) -> Array:
	var brief := prop_brief(c, prop.def)
	return ["Prop", "%s %d/%d%s" % [prop.def.display_name, prop.hp, prop.def.hp, SEP + brief if brief != "" else ""]]


## What is notable about a square, one line per layer. An empty Plain square has nothing to say.
static func cell_rows(b: Battle, p: Vector2i) -> Array:
	var cell := b.board.at(p)
	var rows: Array = []
	var g := b.content.ground(cell.ground)
	if cell.ground != GroundDef.PLAIN or cell.is_mountain():
		var parts: PackedStringArray = []
		if cell.ground != GroundDef.PLAIN and g != null:
			var brief := ground_brief(g, cell.level)
			parts.append(g.label(cell.level) + (SEP + brief if brief != "" else ""))
		if cell.is_mountain():
			parts.append("Mountain" + SEP + "+1 Reach")
		rows.append(["Ground", SEP.join(parts)])
	if cell.zone != null:
		var z := cell.zone
		rows.append(["Zone", "%s %s%s%d rd%s%s" % [z.def.display_name, ROMAN[z.level - 1], SEP, z.duration, SEP, effects_text(z.def.effects, z.level)]])
	if cell.surge >= 0:
		var s := b.surge_by_id(cell.surge)
		if s != null:
			rows.append(["Surge", "%s%s%d dmg%s%s" % [s.skill.display_name, SEP, s.skill.surge_damage, SEP,
				"next round" if s.orphaned else unit_name(b, s.owner)]])
	if cell.prop != null:
		rows.append(_prop_row(b.content, cell.prop))
	if cell.air_prop != null and cell.air_prop != cell.prop:
		rows.append(_prop_row(b.content, cell.air_prop))
	return rows


# ---------- log ----------

## One log line for an event, or "" if the event is not worth a line.
static func event_line(b: Battle, e: Dictionary) -> String:
	match e["type"]:
		&"round_started":
			var first: String = unit_name(b, e["queue"][0]) if not (e["queue"] as Array).is_empty() else "nobody"
			return "Round %d — %s first" % [e["round"], first]
		&"moved":
			return "%s: %s → %s" % [unit_name(b, e["who"]), e["skill"], pos(e["to"])]
		&"strike":
			return "%s strikes%s" % [unit_name(b, e["who"]), " " + dir_name(e["dir"]) if e["dir"] != Vector2i.ZERO else ""]
		&"cast":
			return "%s: %s" % [unit_name(b, e["who"]), _skill_name(b, e["who"], e["skill"])]
		&"surge_declared":
			return "%s declares %s" % [unit_name(b, e["who"]), _skill_name(b, e["who"], e["skill"])]
		&"surge_fired":
			return "%s fires!" % _skill_name(b, e["who"], e["skill"])
		&"tamer_skill":
			var t := b.content.tamer_skill(e["skill"])
			return "%s: %s" % ["Tamer" if int(e["side"]) == 0 else "Enemy tamer", t.display_name if t != null else String(e["skill"])]
		&"zones_faded":
			return "%d zone sq fade" % e["count"]
		&"battle_over":
			return "The battle is over."
	return brief(b, e)


static func _skill_name(b: Battle, who: StringName, skill_id: StringName) -> String:
	var u: BattleUnit = b.units.get(who)
	if u != null:
		for s in u.sheet.skills:
			if s.id == skill_id:
				return s.display_name
	var s2 := b.content.skill(skill_id)
	return s2.display_name if s2 != null else String(skill_id)


static func _prop_name(b: Battle, id: StringName) -> String:
	var p := b.content.prop(id)
	return p.display_name if p != null else String(id)


## The outcome of one event in a few words ("Tiger −2", "Tiger → [4,2]", "Lava I"); "" if it
## says nothing a player needs. Used by the log and, grouped, by the cast preview.
static func brief(b: Battle, e: Dictionary) -> String:
	match e["type"]:
		&"damage":
			return "%s blocked" % unit_name(b, e["target"]) if int(e["amount"]) == 0 else "%s −%d" % [unit_name(b, e["target"]), e["amount"]]
		&"nullified":
			return "%s nullified" % unit_name(b, e["target"])
		&"healed":
			return "%s +%d" % [unit_name(b, e["target"]), e["amount"]]
		&"survived":
			return "%s survives at 1 HP" % unit_name(b, e["target"])
		&"defeated":
			return "%s falls" % unit_name(b, e["who"])
		&"displaced", &"retreated":
			return "%s → %s" % [unit_name(b, e["who"]), pos(e["to"])]
		&"retreat_failed":
			return "%s cannot retreat" % unit_name(b, e["who"])
		&"collision":
			return "%s collides" % unit_name(b, e["who"])
		&"unmoved":
			return "%s stays" % unit_name(b, e["who"])
		&"blanked":
			return "Mountain blocks"
		&"prop_hit":
			return "%s −%d" % [_prop_name(b, e["prop"]), e["amount"]]
		&"prop_destroyed":
			return "%s breaks" % _prop_name(b, e["prop"])
		&"prop_placed":
			return "+ %s" % _prop_name(b, e["prop"])
		&"mountain_raised":
			return "+ Mountain"
		&"mountain_destroyed":
			return "Mountain breaks"
		&"ground_changed":
			var g := b.content.ground(e["ground"])
			return g.label(int(e["level"])) if g != null else String(e["ground"])
		&"effect_applied":
			return "%s: %s %d" % [unit_name(b, e["target"]), e["tag"], e["value"]]
		&"beast_swapped":
			return "%s ⇄ %s" % [unit_name(b, e["out"]), unit_name(b, e["in"])]
	return ""


# ---------- cast preview ----------

## Zone changes of a dry run, grouped: "2 new, 1 levels up → II".
static func _zone_summary(events: Array) -> String:
	var counts := {}
	var order: Array = []
	for e: Dictionary in events:
		if e["type"] != &"zone_changed":
			continue
		var label := String(e["result"])
		match e["result"]:
			&"level", &"weaken":
				label = "%s → %s" % ["level up" if e["result"] == &"level" else "weakens", ROMAN[clampi(int(e["level"]), 1, 3) - 1]]
			&"cancel":
				label = "cancels"
			&"replace":
				label = "replaces"
		if not counts.has(label):
			order.append(label)
		counts[label] = int(counts.get(label, 0)) + 1
	var parts: PackedStringArray = []
	for label: String in order:
		parts.append("%d %s" % [counts[label], label])
	return ", ".join(parts)


static func _briefs(b: Battle, events: Array) -> Array[String]:
	var out: Array[String] = []
	for e: Dictionary in events:
		var line := brief(b, e)
		if line != "":
			out.append(line)
	return _merge(out)


## Lines of a cast preview from `Battle.preview`: what happens now and, for a Surge, what its
## detonation would do if nothing changed until then. Equal lines are merged ("Lava I ×4").
static func preview_lines(b: Battle, p: Dictionary) -> Array[String]:
	var out: Array[String] = []
	if not p["ok"]:
		out.append("✗ " + String(p["error"]))
		return out
	var after: Battle = p["after"]
	var zones := _zone_summary(p["events"])
	if zones != "":
		out.append(zones)
	out.append_array(_briefs(after, p["events"]))
	var fired: Array = p["forecast"]
	if not fired.is_empty():
		var later := _briefs(after, fired)
		out.append("next turn:" if not later.is_empty() else "next turn: no hit")
		for line in later:
			out.append("  " + line)
	return out


static func _merge(src: Array[String]) -> Array[String]:
	var counts := {}
	var order: Array[String] = []
	for l in src:
		if not counts.has(l):
			order.append(l)
		counts[l] = int(counts.get(l, 0)) + 1
	var out: Array[String] = []
	for l in order:
		out.append(l + (" ×%d" % counts[l] if counts[l] > 1 else ""))
	return out
