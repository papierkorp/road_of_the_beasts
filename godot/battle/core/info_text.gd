class_name InfoText
extends RefCounted
## Builds the "card" tables shown when hovering a skill or a monster: [[label, value], ...].
## Pure functions over the data (and optionally the live battle), so the UI only renders rows.

const TWIST_TEXT := {
	SkillDef.Twist.POUNCE: "must land next to you, 4-cell shape",
	SkillDef.Twist.TRAIL: "a straight line starting next to you",
	SkillDef.Twist.RING: "your 4 neighbours, no aiming",
	SkillDef.Twist.LOB: "range +2, damage −1",
	SkillDef.Twist.WIDE: "+1 cell, damage −1",
	SkillDef.Twist.SLOW_BURN: "fires one turn later, damage +1",
	SkillDef.Twist.LINGERING: "residue lasts 3 rounds, damage −1",
	SkillDef.Twist.CONSTRICT: "pulls the struck toward the anchor, damage −1",
}

const TYPE_TEXT := {
	SkillDef.SurgeType.ERUPTION: ["Lava", "hits Elevated, no residue there; ignites Trees"],
	SkillDef.SurgeType.FLOOD: ["Thornbed", "can't reach Elevated; pushes the struck (WASD); puts out fires"],
	SkillDef.SurgeType.RIFT: ["Blight", "collapses Elevated (still hits); crumbles Walls"],
}

const GROUND_TRIGGER := {
	Square.GroundType.LAVA: "damage at the END of the occupant's turn",
	Square.GroundType.THORNBED: "damage when a monster ENTERS (also pushed / pulled)",
	Square.GroundType.BLIGHT: "damage at the START of the occupant's turn",
}

const AFFECTS := {
	SkillDef.Kind.SURGE: "Surge — burst damage, then residue + repaint",
	SkillDef.Kind.ZONE: "Zone — 2 rounds, movement / tempo",
	SkillDef.Kind.GROUND: "Ground — permanent hazard",
	SkillDef.Kind.HEIGHT: "Height — Elevated, cleanses ground",
	SkillDef.Kind.PROP: "Prop — places objects",
}


static func _ground_of(a: Aspect.Type) -> String:
	match a:
		Aspect.Type.FORCE:
			return "Lava"
		Aspect.Type.NATURE:
			return "Thornbed"
		Aspect.Type.DARK:
			return "Blight"
	return "—"


static func _beaten(a: Aspect.Type) -> Aspect.Type:
	for t in [Aspect.Type.FORCE, Aspect.Type.NATURE, Aspect.Type.DARK]:
		if Aspect.beats(a, t):
			return t
	return Aspect.Type.NONE


static func shape_text(skill: SkillDef, rotatable: bool) -> String:
	if skill.kind == SkillDef.Kind.SURGE and skill.twist == SkillDef.Twist.RING:
		return "ring of 4 around you"
	if skill.shapes.is_empty():
		return "—"
	var o := skill.orientations()
	var cells: int = o[0]["cells"].size() if not o.is_empty() else 0
	return "%s · %d cells · %s" % [skill.shapes[0], cells, "rotatable (Adaptive)" if rotatable else "fixed"]


static func range_text(skill: SkillDef) -> String:
	match skill.twist:
		SkillDef.Twist.POUNCE:
			return "adjacent"
		SkillDef.Twist.RING:
			return "self"
		SkillDef.Twist.TRAIL:
			return "starts next to you"
	return "%d (+1 on Elevated)" % skill.base_range()


## Card rows for a skill. `battle` / `caster` (optional) add live values like Momentum.
static func skill_rows(skill: SkillDef, _battle: Battle = null, caster: Monster = null) -> Array:
	var rotatable := caster != null and caster.has_passive(&"adaptive")
	var rows: Array = [
		["Does", summary(skill, caster)],
		["Affects", AFFECTS.get(skill.kind, "—")],
		["Aspect", Aspect.NAMES[skill.aspect]],
		["AP · Range", "1 · %s" % range_text(skill)],
		["Shape", shape_text(skill, rotatable)],
	]
	match skill.kind:
		SkillDef.Kind.SURGE:
			var bonus := caster.momentum_bonus if caster != null else 0
			var t: Array = TYPE_TEXT.get(skill.surge_type, ["—", "—"])
			rows.append(["Type", SkillDef.surge_type_name(skill.surge_type)])
			rows.append(["Damage", "%d per square%s (±1 attunement, − Veil)" % [skill.surge_value() + bonus,
					" incl. Momentum" if bonus > 0 else ""]])
			rows.append(["Fires", "start of your next turn" if skill.fire_delay() == 1 else "start of your turn after next"])
			rows.append(["Residue", "%s I for %d rounds" % [t[0], skill.residue_rounds()]])
			rows.append(["Special", t[1]])
			if skill.twist != SkillDef.Twist.NONE:
				rows.append(["Twist", "%s — %s" % [SkillDef.twist_name(skill.twist), TWIST_TEXT[skill.twist]]])
			rows.append(["Limit", "one charging Surge per monster"])
		SkillDef.Kind.ZONE:
			var z := skill.zone
			var effs := []
			for e in z.effective(1, Aspect.Type.NONE):
				effs.append("%s %d" % [ZoneEffect.label(e["tag"]), e["value"]])
			rows.append(["Effects", ", ".join(PackedStringArray(effs)) + " (level I; +1 per level, ±1 attunement)"])
			rows.append(["Lasts", "%d rounds, recast = level up (max III)" % (Rules.ZONE_TURNS + skill.duration_bonus)])
			if skill.needs_direction():
				rows.append(["Direction", "push set with WASD, at the end of the occupant's turn"])
			elif skill.is_pull():
				rows.append(["Direction", "pull toward the anchor, at the end of the occupant's turn"])
			var side := []
			if z.collision_bonus > 0:
				side.append("collision +%d" % z.collision_bonus)
			if z.ignores_lava:
				side.append("occupants ignore Lava")
			if z.heals_props:
				side.append("props +1 HP")
			if z.strike_shield > 0:
				side.append("Strikes −%d" % z.strike_shield)
			if not side.is_empty():
				rows.append(["Side effect", ", ".join(PackedStringArray(side))])
			rows.append(["vs. ground", "clears %s, boosts %s" % [_ground_of(_beaten(z.aspect)), _ground_of(z.aspect)]])
			rows.append(["Cancels", "zones with an opposite effect"])
		SkillDef.Kind.GROUND:
			rows.append(["Lays", "%s I, permanent (recast → II)" % Square.ground_name(skill.ground_type)])
			rows.append(["Trigger", GROUND_TRIGGER.get(skill.ground_type, "—")])
			if skill.aspect == Aspect.Type.FORCE:
				rows.append(["Props", "ignites Trees instead"])
		SkillDef.Kind.HEIGHT:
			rows.append(["Effect", "+1 range / Reach on top; climbing costs 2 move; Flood can't reach it"])
		SkillDef.Kind.PROP:
			rows.append(["Effect", "Walls (2 HP, brittle) on empty squares"])
	rows.append(["Archetype", String(skill.archetype)])
	return rows


## One plain sentence: what happens when you use it.
static func summary(skill: SkillDef, caster: Monster = null) -> String:
	var cells: int = 4 if skill.twist == SkillDef.Twist.RING else (skill.orientations()[0]["cells"].size() if not skill.orientations().is_empty() else 0)
	match skill.kind:
		SkillDef.Kind.SURGE:
			var bonus := caster.momentum_bonus if caster != null else 0
			var t: Array = TYPE_TEXT.get(skill.surge_type, ["—", ""])
			var when := "next turn" if skill.fire_delay() == 1 else "turn after next"
			var s := "Marks %d squares. At the start of your %s it deals %d damage to everyone still standing there, then leaves %s for %d rounds." % [
				cells, when, skill.surge_value() + bonus, t[0], skill.residue_rounds()]
			if skill.surge_type == SkillDef.SurgeType.FLOOD:
				s += " Struck monsters are pushed 1 square (WASD)."
			if skill.twist == SkillDef.Twist.CONSTRICT:
				s += " Struck monsters are pulled toward the centre."
			return s
		SkillDef.Kind.ZONE:
			var z := skill.zone
			var parts := []
			for e in z.effective(1, Aspect.Type.NONE):
				match e["tag"]:
					ZoneEffect.Tag.SLOW:
						parts.append("−%d movement" % e["value"])
					ZoneEffect.Tag.DRAIN_INIT:
						parts.append("−%d initiative" % e["value"])
					ZoneEffect.Tag.DRAIN_RANGE:
						parts.append("−%d range and Reach" % e["value"])
					ZoneEffect.Tag.SHIELD:
						parts.append("Surge damage −%d" % e["value"])
					ZoneEffect.Tag.PUSH:
						parts.append("pushed 1 square in the direction you set (WASD) at the end of their turn")
					ZoneEffect.Tag.PULL:
						parts.append("pulled 1 square toward the centre cell at the end of their turn")
			return "For 2 rounds, everyone on these %d squares (allies too): %s." % [cells, "; ".join(PackedStringArray(parts))]
		SkillDef.Kind.GROUND:
			return "Turns %d squares into permanent %s: %s." % [cells, Square.ground_name(skill.ground_type), GROUND_TRIGGER.get(skill.ground_type, "")]
		SkillDef.Kind.HEIGHT:
			return "Raises %d squares to Elevated and clears their ground." % cells
		SkillDef.Kind.PROP:
			return "Raises %d Walls (2 HP) on empty squares." % cells
	return skill.description


static func move_rows(battle: Battle, m: Monster) -> Array:
	return [
		["Affects", "Movement"],
		["AP", "1 (repeatable)"],
		["Squares", "%d" % int(battle.effective_stat(m, Battle.Stat.MOVE))],
		["Costs", "Rubble 2 · climbing Elevated 2 · Thornbed hurts on entering"],
		["Blocked by", "props, monsters, charging Surges%s" % (" (phases through props)" if m.phases() else "")],
	]


static func strike_rows(battle: Battle, m: Monster) -> Array:
	return [
		["Affects", "Direct — instant damage"],
		["Name", m.def.strike_name()],
		["AP", "2 (1 with Pack Hunter next to the target)" if m.has_passive(&"pack_hunter") else "2 — the whole turn"],
		["Reach", "%d (Manhattan; 2+ needs line of sight)" % battle.reach(m)],
		["Effect", MonsterDef.STRIKE_TEXT[m.kin()]],
		["Target", "an enemy monster or a prop"],
	]


## Card rows for a monster species, with live values if a battle monster is given.
static func monster_rows(d: MonsterDef, m: Monster = null, battle: Battle = null) -> Array:
	var init := "%.1f" % d.initiative
	var move := "%d" % d.move
	var reach := "%d" % d.reach
	var hp := "%d" % d.hp
	if m != null and battle != null:
		hp = "%d / %d" % [m.hp, m.max_hp]
		init = "%.1f (base %.1f)" % [battle.effective_stat(m, Battle.Stat.INIT), d.initiative]
		move = "%d" % int(battle.effective_stat(m, Battle.Stat.MOVE))
		reach = "%d" % battle.reach(m)
	var rows: Array = []
	if m != null:
		rows.append(["Side", "yours" if m.side == 0 else "enemy"])
	rows.append_array([
		["Kin", MonsterDef.kin_name(d.kin)],
		["Aspect", Aspect.NAMES[d.aspect]],
		["HP", hp],
		["Initiative", init],
		["Move", move],
		["Reach", reach],
		["Turns / round", "%d" % d.tpr],
		["Strike", "%s — %s" % [d.strike_name(), MonsterDef.STRIKE_TEXT[d.kin]]],
		["Surge", "%s — %s, %d dmg%s" % [d.surge.display_name, SkillDef.surge_type_name(d.surge.surge_type),
				d.surge.surge_value(), ", " + SkillDef.twist_name(d.surge.twist) if d.surge.twist != SkillDef.Twist.NONE else ""]],
		["Utility", "%s — %s" % [d.utility.display_name, String(d.utility.archetype)]],
		["Passive", "%s — %s" % [d.passive_name(), d.passive_text()]],
	])
	if m != null and battle != null and battle.has_charging(m.id):
		rows.append(["Status", "Surge charging"])
	return rows


static func rows_to_text(rows: Array) -> String:
	var lines := []
	for r in rows:
		lines.append("%s: %s" % [r[0], r[1]])
	return "\n".join(PackedStringArray(lines))


## Explained rows for one square: every layer says what it does, not just its name.
static func square_rows(battle: Battle, sq: Square) -> Array:
	var rows: Array = []
	var occ := battle.monster_at(sq.pos)
	if sq.surge != null:
		var sg: Dictionary = sq.surge
		var owner: Monster = battle.monsters[sg["owner"]]
		var when := "start of %s's next turn" % owner.display_name() if sg["turns_left"] <= 1 \
				else "in %d of %s's turns" % [sg["turns_left"], owner.display_name()]
		var dmg := battle.surge_damage_at(sq, sg, occ)
		rows.append(["Surge", "%s (%s) — fires at the %s; %d damage to whoever stands here, then %s residue" % [
			sg["name"], SkillDef.surge_type_name(sg["type"]), when, dmg,
			Square.ground_name(Battle._residue_ground(sg["type"]))]])
	if sq.zone != null:
		var z: Dictionary = sq.zone
		var def: ZoneDef = z["def"]
		var parts := []
		for e in def.effective(z["level"], sq.attunement, z["native"]):
			match e["tag"]:
				ZoneEffect.Tag.SLOW:
					parts.append("movement −%d" % e["value"])
				ZoneEffect.Tag.DRAIN_INIT:
					parts.append("initiative −%d" % e["value"])
				ZoneEffect.Tag.DRAIN_RANGE:
					parts.append("range and Reach −%d" % e["value"])
				ZoneEffect.Tag.SHIELD:
					parts.append("Surge damage −%d" % e["value"])
				ZoneEffect.Tag.PUSH:
					parts.append("pushed 1 %s at the end of the occupant's turn" % _dir_word(z["dir"]))
				ZoneEffect.Tag.PULL:
					parts.append("pulled 1 toward [%d,%d] at the end of the occupant's turn" % [z["anchor"].x, z["anchor"].y])
		rows.append(["Zone", "%s %s · %d round%s left — %s" % [def.display_name, BattleView.ROMAN[z["level"] - 1],
			z["duration"], "" if z["duration"] == 1 else "s", "; ".join(PackedStringArray(parts))]])
	if sq.object != null:
		var o: Dictionary = sq.object
		var tag_text := []
		for t in o["tags"]:
			match t:
				"flammable":
					tag_text.append("burns when a Force skill hits it" if not o["burning"] else "BURNING — burns down at round end, leaves Lava")
				"brittle":
					tag_text.append("crumbles under Dark zones / Blight, Rifts hit it harder")
				"heavy":
					tag_text.append("can't be moved, Floods don't hurt it")
				"indestructible":
					tag_text.append("can't be destroyed")
		var hp := "" if o["tags"].has("indestructible") else " %d/%d HP" % [o["hp"], o["max_hp"]]
		rows.append(["Prop", "%s%s — blocks movement; %s" % [o["name"], hp, ", ".join(PackedStringArray(tag_text))]])
	rows.append(["Ground", ground_text(sq)])
	if sq.elevated:
		rows.append(["Height", "Elevated — +1 range and Reach on top; climbing up costs 2 move; pushed off = 1 fall damage; Floods can't reach it, Rifts collapse it"])
	if sq.attunement != Aspect.Type.NONE:
		rows.append(["Colour", attunement_text(sq.attunement)])
	return rows


static func ground_text(sq: Square) -> String:
	var left := "permanent" if sq.timer == Square.PERMANENT else "%d round%s left" % [sq.timer, "" if sq.timer == 1 else "s"]
	match sq.ground:
		Square.GroundType.PLAIN:
			return "Plain — normal ground (move cost 1)"
		Square.GroundType.RUBBLE:
			return "Rubble — costs 2 movement, can't hold a colour"
		Square.GroundType.VOIDSCAR:
			return "Voidscar — 1 damage at the start of a turn here, permanent"
		Square.GroundType.LAVA:
			return "Lava %s — %d damage to whoever ENDS its turn here · %s" % [BattleView.ROMAN[sq.level - 1], sq.level, left]
		Square.GroundType.THORNBED:
			return "Thornbed %s — %d damage to whoever ENTERS (also when pushed in) · %s" % [BattleView.ROMAN[sq.level - 1], sq.level, left]
		Square.GroundType.BLIGHT:
			return "Blight %s — %d damage to whoever STARTS its turn here · %s" % [BattleView.ROMAN[sq.level - 1], sq.level, left]
	return Square.ground_name(sq.ground)


## "Cursed (Dark) — Dark zones and Surges +1 here, Force ones −1."
static func attunement_text(att: Aspect.Type) -> String:
	var weaker := Aspect.Type.NONE
	for t in [Aspect.Type.FORCE, Aspect.Type.NATURE, Aspect.Type.DARK]:
		if Aspect.beats(att, t):
			weaker = t
	return "%s (%s) — %s zones and Surges are +1 stronger here, %s ones −1 weaker. Set by Surges, fading zones and %s ground" % [
		Aspect.ATTUNEMENT_NAMES[att], Aspect.NAMES[att], Aspect.NAMES[att], Aspect.NAMES[weaker], Aspect.NAMES[att]]


static func _dir_word(d: Vector2i) -> String:
	match d:
		Vector2i(0, -1):
			return "north"
		Vector2i(0, 1):
			return "south"
		Vector2i(-1, 0):
			return "west"
	return "east"
