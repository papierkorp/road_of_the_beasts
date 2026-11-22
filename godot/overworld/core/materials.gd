class_name Materials
extends RefCounted
## Ids and names of the materials (docs/overworld.md §6.1): a form and a tier (a stage), no grade.
##   plant:<plant id>:<tier> · part:<kin>
## Pills and weapons are items too: pill:<property id>[+<property id>]:<tier>[:<flaw id>] · weapon:<kin of what>:<kin of how>.

const KIN_PARTS: Array[String] = ["Fang", "Feather", "Scale", "Chitin", "Wisp", "Core", "Bark", "Dust"]


static func plant(id: StringName, tier: int) -> String:
	return "plant:%s:%d" % [id, tier]


static func beast_part(kin: int) -> String:
	return "part:%d" % kin


static func weapon(what_kin: int, how_kin: int) -> String:
	return "weapon:%d:%d" % [what_kin, how_kin]


static func form(item: String) -> String:
	return item.get_slice(":", 0)


static func tier(item: String) -> int:
	var parts := item.split(":")
	match parts[0]:
		"plant", "pill":
			return int(parts[2])
	return 0


## The flaw a pill carries ("" = none).
static func flaw(item: String) -> String:
	var parts := item.split(":")
	return parts[3] if parts[0] == "pill" and parts.size() > 3 else ""


static func display_name(item: String, values: GameValues) -> String:
	var parts := item.split(":")
	match parts[0]:
		"plant":
			for p: Dictionary in values.plants:
				if String(p["id"]) == parts[1]:
					return "%s (%s)" % [p["name"], Stage.stage_name(int(parts[2]) as Stage.Type)]
		"part":
			return "%s %s" % [MonsterDef.kin_name(int(parts[1]) as MonsterDef.Kin), KIN_PARTS[int(parts[1])]]
		"pill":
			var names: PackedStringArray = []
			for prop in parts[1].split("+"):
				for p: Dictionary in values.properties:
					if String(p["id"]) == prop:
						names.append(String(p["name"]))
			var text := "%s pill (%s)" % [" and ".join(names), Stage.stage_name(int(parts[2]) as Stage.Type)]
			for f: Dictionary in values.flaws:
				if String(f["id"]) == flaw(item):
					text += " — %s" % f["name"]
			return text
		"weapon":
			return "Weapon: %s" % Crafting.piece_name(values, int(parts[1]), int(parts[2]))
	return item


## The plants a dungeon of `stage` gives: every plant whose first stage is at or below it.
static func plants_of(values: GameValues, stage: int) -> Array[StringName]:
	var out: Array[StringName] = []
	for p: Dictionary in values.plants:
		if int(p["stage"]) <= stage:
			out.append(StringName(p["id"]))
	return out


## Every material a game can hold up to a stage (the cheat menu).
static func all_ids(values: GameValues, stage: int) -> Array[String]:
	var out: Array[String] = []
	for t in stage + 1:
		for id in plants_of(values, t):
			if not out.has(plant(id, t)):
				out.append(plant(id, t))
	for k in MonsterDef.Kin.size():
		out.append(beast_part(k))
	return out


## "Moonleaf ×2, Beast Fang ×1" for a dictionary of item -> number.
static func list_text(loot: Dictionary, values: GameValues) -> String:
	var parts: PackedStringArray = []
	for id in loot:
		parts.append("%s ×%d" % [display_name(String(id), values), int(loot[id])])
	return "nothing" if parts.is_empty() else ", ".join(parts)
