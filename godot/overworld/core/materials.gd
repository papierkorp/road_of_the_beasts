class_name Materials
extends RefCounted
## Ids and names of the goods (docs/overworld.md §6.1). A pill is an item: pill:<property id>. A part of a
## battleground is "ground:<id>", "prop:<id>" or "zone:<id>" and lives in `GameState.parts`. There are no materials:
## what the Way uses drops ready from a wild battle.


static func pill(property: StringName) -> String:
	return "pill:%s" % property


static func form(item: String) -> String:
	return item.get_slice(":", 0)


## The property of a pill.
static func property_of(item: String) -> StringName:
	return StringName(item.get_slice(":", 1))


static func display_name(item: String, values: GameValues) -> String:
	if form(item) == "pill":
		for p: Dictionary in values.properties:
			if StringName(p["id"]) == property_of(item):
				return "%s pill" % p["name"]
	return item


## "Warding pill ×2, Growth pill ×1" for a dictionary of item -> number.
static func list_text(loot: Dictionary, values: GameValues) -> String:
	var parts: PackedStringArray = []
	for id in loot:
		parts.append("%s ×%d" % [display_name(String(id), values), int(loot[id])])
	return "nothing" if parts.is_empty() else ", ".join(parts)


## The name of a part of a battleground ("ground:<id>", "prop:<id>", "zone:<id>"), with its kind.
static func part_name(part: String) -> String:
	var kind := part.get_slice(":", 0)
	var id := StringName(part.get_slice(":", 1))
	var c := BattleContent.shared()
	var def: Resource = c.ground(id) if kind == "ground" else (c.prop(id) if kind == "prop" else c.zone(id))
	return "%s (%s)" % [def.get("display_name") if def != null else String(id), kind]
