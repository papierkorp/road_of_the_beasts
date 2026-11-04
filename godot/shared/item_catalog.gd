class_name ItemCatalog
extends RefCounted
## Items built from one schema (gdd_overworld §9.3, §10): an item id is a string, everything else
## (name, kind, value, effect) is derived from it — "archetypes over uniques".
##   material  "mat:<kin>:<aspect>:<tier>"   beast part, dropped by kin, tier = cultivation stage
##   pill      "pill:<tier>"                 cultivation pill (out-of-battle XP, §10.2)
## Prices are Phase 1 placeholders (tuning, gdd_overworld §12).

enum Kind { MATERIAL, PILL }

const BASE_VALUE := 8               # spirit stones of a Qi Gathering material
const PILL_PRICE := 80
const PILL_XP := 30

const KIN_FORM := {
	MonsterDef.Kin.BEAST: "Fang", MonsterDef.Kin.WINGED: "Feather", MonsterDef.Kin.SCALED: "Hide",
	MonsterDef.Kin.SWARM: "Chitin", MonsterDef.Kin.SPIRIT: "Essence", MonsterDef.Kin.ANCIENT: "Core",
}
const ASPECT_WORD := {
	Aspect.Type.NONE: "Plain", Aspect.Type.FORCE: "Ember", Aspect.Type.NATURE: "Verdant", Aspect.Type.DARK: "Gloom",
}


static func material_id(kin: MonsterDef.Kin, aspect: Aspect.Type, tier: int) -> String:
	return "mat:%d:%d:%d" % [kin, aspect, tier]


static func pill_id(tier := 0) -> String:
	return "pill:%d" % tier


static func kind_of(id: String) -> Kind:
	return Kind.PILL if id.begins_with("pill:") else Kind.MATERIAL


static func tier_of(id: String) -> int:
	return int(id.split(":")[-1])


static func display_name(id: String) -> String:
	var parts := id.split(":")
	if kind_of(id) == Kind.PILL:
		return "%s Cultivation Pill" % Stage.stage_name(tier_of(id))
	return "%s %s (%s)" % [ASPECT_WORD[int(parts[2])], KIN_FORM[int(parts[1])], Stage.stage_name(int(parts[3]))]


## Spirit stones, before any market factor. Every tier is worth 3x the one below.
static func base_value(id: String) -> int:
	var unit := PILL_PRICE if kind_of(id) == Kind.PILL else BASE_VALUE
	return unit * int(pow(3.0, tier_of(id)))


static func pill_xp(_id: String) -> int:
	return PILL_XP


## All materials of one tier (6 kin x 3 aspects).
static func materials_of_tier(tier: int) -> Array[String]:
	var out: Array[String] = []
	for kin in MonsterDef.Kin.values():
		for aspect in [Aspect.Type.FORCE, Aspect.Type.NATURE, Aspect.Type.DARK]:
			out.append(material_id(kin, aspect, tier))
	return out
