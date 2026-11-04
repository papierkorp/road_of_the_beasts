class_name RecipeCatalog
extends RefCounted
## What the Refining Furnace can make (gdd_overworld §8 Producer, §10.2 pills): one recipe per
## pill type, the pill is of the tier of the player's stage. Prototype numbers.

const WATER_BONUS := 1               # a Qi Spring next to the furnace: one more pill per batch

const RECIPES := {
	&"cultivation": {"name": "Cultivation Pills", "yield": 2, "inputs": [{"aspect": Aspect.Type.NONE, "count": 6}]},
	&"healing": {"name": "Healing Pills", "yield": 3, "inputs": [{"aspect": Aspect.Type.NATURE, "count": 3}]},
	&"prep": {"name": "Battle-Prep Pills", "yield": 2, "inputs": [{"aspect": Aspect.Type.FORCE, "count": 2}, {"aspect": Aspect.Type.NONE, "count": 2}]},
}


static func ids() -> Array[StringName]:
	return [&"cultivation", &"healing", &"prep"]


static func has(id: StringName) -> bool:
	return RECIPES.has(id)


static func recipe_name(id: StringName) -> String:
	return RECIPES[id]["name"]


static func batch_yield(id: StringName) -> int:
	return int(RECIPES[id]["yield"])


static func inputs(id: StringName) -> Array:
	return RECIPES[id]["inputs"]


## The pill a recipe makes for a stage.
static func output_id(id: StringName, tier: int) -> String:
	match id:
		&"healing":
			return ItemCatalog.healing_pill_id(tier)
		&"prep":
			return ItemCatalog.prep_pill_id(tier)
	return ItemCatalog.pill_id(tier)


static func inputs_text(id: StringName) -> String:
	var parts: Array[String] = []
	for r in inputs(id):
		var a: Aspect.Type = r["aspect"]
		parts.append("%d %s" % [r["count"], "any" if a == Aspect.Type.NONE else Aspect.NAMES[a]])
	return ", ".join(PackedStringArray(parts))
