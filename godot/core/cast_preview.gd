class_name CastPreview
extends RefCounted
## Explains, square by square, what a placement will do — before you click (GDD pillar 2).
## Returns readable lines; identical lines are merged with a ×count.


static func _pos(p: Vector2i) -> String:
	return "[%d,%d]" % [p.x, p.y]


static func _owner_tag(battle: Battle, caster: Monster, owner_id: StringName) -> String:
	var o: Monster = battle.monsters.get(owner_id)
	if o == null:
		return ""
	if o.id == caster.id:
		return "your own"
	return "ally's" if o.side == caster.side else "enemy"


static func _opposite_pair(a: ZoneDef, b: ZoneDef) -> String:
	for e in a.effects:
		for f in b.effects:
			if ZoneEffect.OPPOSITE.get(e.tag, -1) == f.tag:
				return "%s ↔ %s" % [ZoneEffect.label(e.tag), ZoneEffect.label(f.tag)]
	return ""


static func _where_lands(battle: Battle, m: Monster, step: Vector2i) -> String:
	if step == Vector2i.ZERO:
		return "stays (at the anchor)"
	if not battle.can_be_displaced(m):
		return "can't be moved (passive)"
	var to := m.pos + step
	if not battle.board.in_bounds(to):
		return "pinned against the edge"
	var sq := battle.board.at(to)
	if sq.object != null:
		return "slams into the %s (collision)" % sq.object["name"]
	if battle.monster_at(to) != null:
		return "blocked by %s" % battle.monster_at(to).display_name()
	var extra := ""
	if sq.is_aspect_ground():
		extra = " onto %s %s" % [Square.ground_name(sq.ground), BattleView.ROMAN[sq.level - 1]]
	if sq.surge != null:
		extra += " into a charging Surge"
	return "→ %s%s" % [_pos(to), extra]


## Lines describing everything a cast at these cells would do.
static func lines(battle: Battle, caster: Monster, skill: SkillDef, cells: Array[Vector2i],
		dir: Vector2i, anchor: Vector2i) -> Array[String]:
	var out: Array[String] = []
	for c in cells:
		var sq := battle.board.at(c)
		var pg := Rules.preview_cell(skill, sq)
		var occ := battle.monster_at(c)
		match skill.kind:
			SkillDef.Kind.ZONE:
				_zone_lines(battle, caster, skill, sq, pg, occ, dir, anchor, out)
			SkillDef.Kind.GROUND:
				match pg["kind"]:
					&"ignite":
						out.append("ignites the Tree (burns down at round end → Lava)")
					&"lost":
						out.append("%s: nothing — %s" % [_pos(c), "Voidscar can't change" if sq.object == null else "a prop is in the way"])
					&"level":
						out.append("%s %s → II (stronger)" % [Square.ground_name(skill.ground_type), "I"])
					&"replace":
						out.append("replaces %s with %s" % [Square.ground_name(sq.ground), Square.ground_name(skill.ground_type)])
					_:
						out.append("new %s I (permanent)" % Square.ground_name(skill.ground_type))
				if occ != null:
					out.append("%s stands on it now" % occ.display_name())
			SkillDef.Kind.HEIGHT:
				out.append("nothing — already Elevated or Voidscar" if pg["kind"] == &"lost" else "raises Elevated, clears ground and colour")
			SkillDef.Kind.PROP:
				out.append("raises a Wall (2 HP)")
			SkillDef.Kind.SURGE:
				_surge_lines(battle, caster, skill, sq, pg, occ, dir, out)
	return _merge(out)


static func _zone_lines(battle: Battle, caster: Monster, skill: SkillDef, sq: Square, pg: Dictionary,
		occ: Monster, dir: Vector2i, anchor: Vector2i, out: Array[String]) -> void:
	var z := skill.zone
	match pg["kind"]:
		&"new":
			out.append("new %s I" % z.display_name)
		&"level":
			out.append("%s levels up → %s (refreshed to 2 rounds)" % [z.display_name, BattleView.ROMAN[pg["level"] - 1]])
		&"replace":
			var old: Dictionary = sq.zone
			out.append("replaces %s %s with %s I" % [_owner_tag(battle, caster, old["owner"]), old["def"].display_name, z.display_name])
		&"cancel":
			var old2: Dictionary = sq.zone
			out.append("CANCELS %s %s (%s are opposites) → square ends EMPTY" % [
				_owner_tag(battle, caster, old2["owner"]), old2["def"].display_name, _opposite_pair(z, old2["def"])])
	match pg["ground"]:
		&"clear":
			out.append("clears %s → Plain (%s beats %s)" % [Square.ground_name(sq.ground),
					Aspect.NAMES[z.aspect], Aspect.NAMES[sq.ground_aspect()]])
		&"boost":
			out.append("strengthens %s → II" % Square.ground_name(sq.ground))
	if pg["ground"] == &"" and sq.is_aspect_ground() and Aspect.beats(sq.ground_aspect(), z.aspect):
		out.append("%s stays (%s can't touch %s)" % [Square.ground_name(sq.ground), Aspect.NAMES[z.aspect], Aspect.NAMES[sq.ground_aspect()]])
	match pg["prop"]:
		&"ignite":
			out.append("ignites the Tree")
		&"extinguish":
			out.append("puts out the burning Tree")
		&"heal":
			out.append("%s +1 HP" % sq.object["name"])
	if sq.object != null and pg["prop"] == &"":
		out.append("lies under the %s (works once it's gone)" % sq.object["name"])
	if pg["kind"] != &"cancel" and occ != null:
		var who := "%s (%s)" % [occ.display_name(), "you" if occ.id == caster.id else ("ally" if occ.side == caster.side else "enemy")]
		if z.has_tag(ZoneEffect.Tag.PUSH):
			out.append("%s pushed at the end of its turn %s" % [who, _where_lands(battle, occ, dir)])
		elif z.has_tag(ZoneEffect.Tag.PULL):
			out.append("%s pulled at the end of its turn %s" % [who, _where_lands(battle, occ, Battle._step_toward(occ.pos, anchor))])
		else:
			var effs := []
			for e in z.effective(pg["level"], sq.attunement, caster.has_passive(&"native_ground")):
				effs.append("%s %d" % [ZoneEffect.label(e["tag"]), e["value"]])
			out.append("%s gets %s" % [who, ", ".join(PackedStringArray(effs))])
	var mod := Aspect.attunement_mod(z.aspect, sq.attunement, caster.has_passive(&"native_ground"))
	if mod != 0:
		out.append("%s on %s ground" % ["+%d stronger" % mod if mod > 0 else "%d weaker" % mod, Aspect.ATTUNEMENT_NAMES[sq.attunement]])


static func _surge_lines(battle: Battle, caster: Monster, skill: SkillDef, sq: Square, pg: Dictionary,
		occ: Monster, dir: Vector2i, out: Array[String]) -> void:
	if pg["kind"] == &"lost":
		out.append("%s: LOST — already claimed by %s's Surge" % [_pos(sq.pos), battle.monsters[sq.surge["owner"]].display_name()])
		return
	var sg := {"type": skill.surge_type, "aspect": skill.aspect,
		"value": skill.surge_value() + caster.momentum_bonus, "native": caster.has_passive(&"native_ground")}
	if skill.surge_type == SkillDef.SurgeType.FLOOD and sq.elevated:
		out.append("Elevated: the Flood can't reach it")
		return
	if sq.object != null:
		if skill.surge_type == SkillDef.SurgeType.ERUPTION and sq.has_tag("flammable"):
			out.append("ignites the Tree")
		elif sq.has_tag("indestructible") or (skill.surge_type == SkillDef.SurgeType.FLOOD and sq.has_tag("heavy")):
			out.append("%s is unaffected" % sq.object["name"])
		else:
			var dmg := Rules.SURGE_PROP_DAMAGE + (1 if skill.surge_type == SkillDef.SurgeType.RIFT and sq.has_tag("brittle") else 0)
			out.append("%s takes %d%s" % [sq.object["name"], dmg, " → shatters, debris hits its neighbours" if dmg >= sq.object["hp"] else ""])
		return
	if occ != null:
		var d := battle.surge_damage_at(sq, sg, occ)
		var who := "%s (%s)" % [occ.display_name(), "you" if occ.id == caster.id else ("ally" if occ.side == caster.side else "enemy")]
		out.append("%s would take %d if still here when it fires" % [who, d])
	if sq.elevated:
		if skill.surge_type == SkillDef.SurgeType.RIFT:
			out.append("Elevated collapses to Rubble")
		elif skill.surge_type == SkillDef.SurgeType.ERUPTION:
			out.append("Elevated: no residue here")
		return
	var gt := Battle._residue_ground(skill.surge_type)
	if sq.is_aspect_ground() and sq.ground != gt:
		out.append("residue replaces %s with %s I (%d rounds)" % [Square.ground_name(sq.ground), Square.ground_name(gt), skill.residue_rounds()])
	else:
		out.append("residue: %s I for %d rounds" % [Square.ground_name(gt), skill.residue_rounds()])
	if occ != null and skill.surge_type == SkillDef.SurgeType.FLOOD:
		out.append("%s then pushed %s" % [occ.display_name(), _where_lands(battle, occ, dir)])


static func _merge(src: Array[String]) -> Array[String]:
	var counts := {}
	var order: Array[String] = []
	for l in src:
		if not counts.has(l):
			order.append(l)
		counts[l] = counts.get(l, 0) + 1
	var out: Array[String] = []
	for l in order:
		out.append(l + (" ×%d" % counts[l] if counts[l] > 1 else ""))
	return out
