class_name ItemCatalog
extends RefCounted
## Items built from one schema (gdd_overworld §9.3, §10): an item id is a string, everything else
## (name, kind, value, effect) is derived from it — "archetypes over uniques".
##   material  "mat:<kin>:<aspect>:<tier>"   beast part, dropped by kin, tier = cultivation stage
##   pill      "pill:<tier>"                 cultivation pill (out-of-battle XP, §10.2)
##             "pill:heal:<tier>"            healing pill (HP between battles)
##             "pill:prep:<tier>"            battle-prep pill (+initiative for the next battle)
##   blueprint "bp:<structure>"               the recipe of a structure (kept, §6.4)
##   structure "st:<structure>"               a constructed structure waiting in the bag to be placed
## Prices are Phase 1 placeholders (tuning, gdd_overworld §12).

enum Kind { MATERIAL, PILL, BLUEPRINT, STRUCTURE }

const BASE_VALUE := 8               # spirit stones of a Qi Gathering material
const PILL_PRICE := 80
const PILL_XP := 30
const HEAL_AMOUNT := 3
const PREP_INIT := 1
## Base value per pill type before the tier factor.
const PILL_VALUE := {&"cultivation": 80, &"healing": 40, &"prep": 60}

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


static func healing_pill_id(tier := 0) -> String:
	return "pill:heal:%d" % tier


static func prep_pill_id(tier := 0) -> String:
	return "pill:prep:%d" % tier


## &"cultivation", &"healing" or &"prep" (only for pills).
static func pill_type(id: String) -> StringName:
	var parts := id.split(":")
	if parts.size() == 3:
		return &"healing" if parts[1] == "heal" else &"prep"
	return &"cultivation"


## The three pills of a tier.
static func pills_of_tier(tier: int) -> Array[String]:
	return [pill_id(tier), healing_pill_id(tier), prep_pill_id(tier)]


static func blueprint_id(structure: StringName) -> String:
	return "bp:%s" % structure


static func structure_item_id(structure: StringName) -> String:
	return "st:%s" % structure


static func kind_of(id: String) -> Kind:
	if id.begins_with("pill:"):
		return Kind.PILL
	if id.begins_with("bp:"):
		return Kind.BLUEPRINT
	if id.begins_with("st:"):
		return Kind.STRUCTURE
	return Kind.MATERIAL


## The structure a blueprint or structure item belongs to.
static func structure_of(id: String) -> StringName:
	return StringName(id.split(":")[1])


## The aspect of a material.
static func material_aspect(id: String) -> Aspect.Type:
	return int(id.split(":")[2]) as Aspect.Type


static func tier_of(id: String) -> int:
	return int(id.split(":")[-1])


static func display_name(id: String) -> String:
	var parts := id.split(":")
	match kind_of(id):
		Kind.BLUEPRINT:
			return "%s Blueprint" % StructureCatalog.def(structure_of(id)).display_name
		Kind.STRUCTURE:
			return StructureCatalog.def(structure_of(id)).display_name
		Kind.PILL:
			var noun: String = {&"cultivation": "Cultivation", &"healing": "Healing", &"prep": "Battle-Prep"}[pill_type(id)]
			return "%s %s Pill" % [Stage.stage_name(tier_of(id)), noun]
	return "%s %s (%s)" % [ASPECT_WORD[int(parts[2])], KIN_FORM[int(parts[1])], Stage.stage_name(int(parts[3]))]


## Spirit stones, before any market factor. Every tier is worth 3x the one below.
static func base_value(id: String) -> int:
	match kind_of(id):
		Kind.STRUCTURE:
			return StructureCatalog.def(structure_of(id)).price
		Kind.BLUEPRINT:
			return StructureCatalog.def(structure_of(id)).price * 2
	var unit: int = PILL_VALUE[pill_type(id)] if kind_of(id) == Kind.PILL else BASE_VALUE
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
