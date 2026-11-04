class_name Evolution
extends RefCounted
## Skill evolution (gdd_overworld §4.7): instead of numbers, an evolution picks ONE variant of a
## skill. Four families — shape, twist, small value, utility swap — and all of them keep the
## battle rules intact: one shape, one fixed orientation, at most one twist, and no evolution
## ever raises Surge, Strike or ground damage.
##
## An evolved skill is a modified COPY of the species' skill; the species file never changes.
## A pick is {slot, skill (&"surge" | &"utility"), family, arg}; the args:
##   shape  "<family>:<orientation>"  reshape (same cell count) or "<family>:<orientation>:w"
##          widen (+1 cell, Surge only, damage -1)
##   twist  a SkillDef.Twist name (NONE = baseline)
##   value  "range" (+1 cast range) | "duration" (a zone lasts +1 round)
##   swap   the id of another utility (before any other pick of that utility)

const SURGE := &"surge"
const UTILITY := &"utility"

## Twists that may be swapped among. Pounce, Trail, Ring and Wide are part of a species' shape
## identity (they fix or imply the shape), so they stay.
const TWIST_CHOICES := [SkillDef.Twist.NONE, SkillDef.Twist.LOB, SkillDef.Twist.SLOW_BURN,
	SkillDef.Twist.LINGERING, SkillDef.Twist.CONSTRICT]
const TWIST_PRICE := {
	SkillDef.Twist.NONE: "baseline: no twist, no price",
	SkillDef.Twist.LOB: "range +2, damage −1",
	SkillDef.Twist.SLOW_BURN: "fires a turn later, damage +1",
	SkillDef.Twist.LINGERING: "residue lasts 3 rounds, damage −1",
	SkillDef.Twist.CONSTRICT: "pulls struck monsters 1 toward the anchor, damage −1",
}
## Archetypes a Kin may not take (gdd_battle §6).
const KIN_LOCKED := {
	MonsterDef.Kin.BEAST: ["Sanctify"], MonsterDef.Kin.WINGED: ["Raise Prop"], MonsterDef.Kin.SCALED: ["Reposition"],
	MonsterDef.Kin.SWARM: ["Relocate"], MonsterDef.Kin.SPIRIT: ["Raise Prop"], MonsterDef.Kin.ANCIENT: ["Reposition"],
}


## Evolution slots a monster has: one per stage above Qi Gathering.
static func slot_count(stage: Stage.Type) -> int:
	return int(stage)


## How many paths are offered per slot and how many may be taken (gdd_overworld §5).
static func offers_per_slot(rarity: MonsterInstance.Rarity) -> int:
	match rarity:
		MonsterInstance.Rarity.NORMAL:
			return 2
		MonsterInstance.Rarity.RARE, MonsterInstance.Rarity.EPIC:
			return 3
	return 99


static func picks_per_slot(rarity: MonsterInstance.Rarity) -> int:
	match rarity:
		MonsterInstance.Rarity.EPIC:
			return 2
		MonsterInstance.Rarity.LEGENDARY:
			return 99
	return 1


## The six paths: (skill, family).
static func all_paths() -> Array[Dictionary]:
	return [
		{"skill": SURGE, "family": &"shape"}, {"skill": SURGE, "family": &"twist"}, {"skill": SURGE, "family": &"value"},
		{"skill": UTILITY, "family": &"shape"}, {"skill": UTILITY, "family": &"value"}, {"skill": UTILITY, "family": &"swap"},
	]


static func path_name(path: Dictionary) -> String:
	return "%s — %s" % [String(path["skill"]).capitalize(), {&"shape": "Shape", &"twist": "Twist", &"value": "Small value",
		&"swap": "Swap utility"}[path["family"]]]


# ---------- the skill a monster ends up with ----------

## The skill with all picks applied (the species' own skill, shared, when nothing changed).
static func current_skill(def: MonsterDef, which: StringName, picks: Array) -> SkillDef:
	var base: SkillDef = def.surge if which == SURGE else def.utility
	var mine: Array[Dictionary] = []
	for p in picks:
		if StringName(p["skill"]) != which:
			continue
		if StringName(p["family"]) == &"swap":
			base = GameData.skill(StringName(p["arg"]))
		else:
			mine.append(p)
	if mine.is_empty():
		return base
	var s: SkillDef = base.duplicate()
	for p in mine:
		_apply(s, p)
	s.description = (s.description + "  [Evolved: %s]" % ", ".join(PackedStringArray(_texts(mine)))).strip_edges()
	return s


static func _texts(mine: Array[Dictionary]) -> Array[String]:
	var out: Array[String] = []
	for p in mine:
		out.append(pick_text(p))
	return out


static func _apply(s: SkillDef, p: Dictionary) -> void:
	var arg := String(p["arg"])
	match StringName(p["family"]):
		&"shape":
			var parts := arg.split(":")
			var fam: Array[StringName] = [StringName(parts[0])]
			s.shapes = fam
			s.orientation = int(parts[1])
			if parts.size() > 2 and parts[2] == "w":
				s.damage_penalty += 1
		&"twist":
			s.twist = SkillDef.Twist[arg]
		&"value":
			if arg == "range":
				s.range_bonus += 1
			elif arg == "duration":
				s.duration_bonus += 1


static func pick_text(p: Dictionary) -> String:
	var arg := String(p["arg"])
	match StringName(p["family"]):
		&"shape":
			var parts := arg.split(":")
			return "%s%s #%d" % ["widened to " if parts.size() > 2 else "reshaped to ", parts[0], int(parts[1]) + 1]
		&"twist":
			return "twist %s" % ("none" if arg == "NONE" else SkillDef.twist_name(SkillDef.Twist[arg]))
		&"value":
			return "cast range +1" if arg == "range" else "lasts +1 round"
		&"swap":
			var sk := GameData.skill(StringName(arg))
			return "swapped to %s" % (sk.display_name if sk != null else arg)
	return arg


# ---------- what can be picked ----------

## The variants a path offers right now, given the picks so far. Empty when the path is closed.
static func variants(def: MonsterDef, which: StringName, family: StringName, picks: Array) -> Array[Dictionary]:
	var none: Array[Dictionary] = []
	for p in picks:
		if StringName(p["skill"]) == which and StringName(p["family"]) == family:
			return none                                   # every path is taken once per skill
	var cur := current_skill(def, which, picks)
	match family:
		&"shape":
			return _shape_variants(def, which, cur)
		&"twist":
			return _twist_variants(which, cur)
		&"value":
			return _value_variants(cur)
		&"swap":
			return _swap_variants(def, which, picks)
	return none


static func _shape_variants(def: MonsterDef, which: StringName, cur: SkillDef) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	if cur.shapes.is_empty():                             # Ring: the shape is its four neighbours
		return out
	var fam: StringName = cur.shapes[0]
	var count: int = (Shapes.BASE[fam] as Array).size()
	var straight := cur.kind == SkillDef.Kind.SURGE and cur.twist == SkillDef.Twist.TRAIL
	var can_widen := which == SURGE and def.kin != MonsterDef.Kin.SWARM and cur.damage_penalty == 0 \
		and cur.twist != SkillDef.Twist.RING and cur.surge_value() - 1 >= 1
	for f: StringName in Shapes.BASE.keys():
		if straight and not String(f).begins_with("I"):
			continue
		var n: int = (Shapes.BASE[f] as Array).size()
		var orients := Shapes.orientations([f])
		if n == count:
			for j in orients.size():
				if f == fam and j == cur.orientation:
					continue
				out.append({"arg": "%s:%d" % [f, j], "label": "%s #%d" % [f, j + 1], "art": shape_art(f, j)})
		elif n == count + 1 and can_widen:
			for j in orients.size():
				out.append({"arg": "%s:%d:w" % [f, j], "label": "Widen to %s #%d (damage −1)" % [f, j + 1], "art": shape_art(f, j)})
	return out


static func _twist_variants(which: StringName, cur: SkillDef) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	if which != SURGE or cur.kind != SkillDef.Kind.SURGE or not TWIST_CHOICES.has(cur.twist):
		return out
	for t in TWIST_CHOICES:
		if t == cur.twist:
			continue
		var tmp: SkillDef = cur.duplicate()
		tmp.damage_penalty = cur.damage_penalty
		tmp.twist = t
		if tmp.surge_value() < 1:
			continue
		out.append({"arg": SkillDef.Twist.keys()[t], "label": "%s — %s" % [
			"Baseline" if t == SkillDef.Twist.NONE else SkillDef.twist_name(t), TWIST_PRICE[t]]})
	return out


static func _value_variants(cur: SkillDef) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	if cur.range_bonus == 0 and cur.twist != SkillDef.Twist.POUNCE and cur.twist != SkillDef.Twist.RING:
		out.append({"arg": "range", "label": "Cast range +1"})
	if cur.kind == SkillDef.Kind.ZONE and cur.duration_bonus == 0:
		out.append({"arg": "duration", "label": "The zone lasts +1 round"})
	return out


static func _swap_variants(def: MonsterDef, which: StringName, picks: Array) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	if which != UTILITY:
		return out
	for p in picks:
		if StringName(p["skill"]) == UTILITY:             # only before any other pick of the utility
			return out
	var locked: Array = KIN_LOCKED.get(def.kin, [])
	for id in GameData.skill_ids():
		var s := GameData.skill(id)
		if s.kind == SkillDef.Kind.SURGE or id == def.utility.id:
			continue
		if s.aspect != def.aspect and s.aspect != Aspect.Type.NONE:
			continue
		if locked.has(String(s.archetype)):
			continue
		out.append({"arg": String(id), "label": "%s (%s)" % [s.display_name, s.archetype]})
	return out


## A tiny picture of a shape orientation: ■ = covered cell.
static func shape_art(family: StringName, orientation: int) -> String:
	var orients := Shapes.orientations([family])
	var cells: Array[Vector2i] = orients[orientation]["cells"]
	var w := 0
	var h := 0
	for c in cells:
		w = maxi(w, c.x + 1)
		h = maxi(h, c.y + 1)
	var rows: Array[String] = []
	for y in h:
		var line := ""
		for x in w:
			line += "■" if cells.has(Vector2i(x, y)) else "·"
		rows.append(line)
	return "\n".join(PackedStringArray(rows))
