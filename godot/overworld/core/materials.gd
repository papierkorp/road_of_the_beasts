class_name Materials
extends RefCounted
## Ids and names of the materials (docs/overworld.md §6.1): a form and a tier (a stage), no grade.
##   plant:<plant id>:<tier> · ore:<tier> · essence:<tier> · part:<kin> · break:<tier>
## Pills are items too: pill:<property id>[+<property id>]:<tier>.

const KIN_PARTS: Array[String] = ["Fang", "Feather", "Scale", "Chitin", "Wisp", "Core", "Bark", "Dust"]


static func plant(id: StringName, tier: int) -> String:
	return "plant:%s:%d" % [id, tier]


static func ore(tier: int) -> String:
	return "ore:%d" % tier


static func essence(tier: int) -> String:
	return "essence:%d" % tier


static func beast_part(kin: int) -> String:
	return "part:%d" % kin


static func breakthrough(tier: int) -> String:
	return "break:%d" % tier


static func form(item: String) -> String:
	return item.get_slice(":", 0)


static func tier(item: String) -> int:
	var parts := item.split(":")
	match parts[0]:
		"plant", "pill":
			return int(parts[2])
		"ore", "essence", "break":
			return int(parts[1])
	return 0


static func display_name(item: String, values: GameValues) -> String:
	var parts := item.split(":")
	match parts[0]:
		"plant":
			for p: Dictionary in values.plants:
				if String(p["id"]) == parts[1]:
					return "%s (%s)" % [p["name"], Stage.stage_name(int(parts[2]) as Stage.Type)]
		"ore":
			return "Ore (%s)" % Stage.stage_name(int(parts[1]) as Stage.Type)
		"essence":
			return "Essence (%s)" % Stage.stage_name(int(parts[1]) as Stage.Type)
		"part":
			return "%s %s" % [MonsterDef.kin_name(int(parts[1]) as MonsterDef.Kin), KIN_PARTS[int(parts[1])]]
		"break":
			return "Breakthrough material (%s)" % Stage.stage_name(int(parts[1]) as Stage.Type)
		"pill":
			var names: PackedStringArray = []
			for prop in parts[1].split("+"):
				for p: Dictionary in values.properties:
					if String(p["id"]) == prop:
						names.append(String(p["name"]))
			return "%s pill (%s)" % [" and ".join(names), Stage.stage_name(int(parts[2]) as Stage.Type)]
		"weapon", "armour":
			return "%s: %s" % [parts[0].capitalize(), parts[1]]
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
		out.append(ore(t))
		out.append(essence(t))
		out.append(breakthrough(t))
	for k in MonsterDef.Kin.size():
		out.append(beast_part(k))
	return out


## "Ore (Qi Gathering) ×2, Moonleaf ×1" for a dictionary of item -> number.
static func list_text(loot: Dictionary, values: GameValues) -> String:
	var parts: PackedStringArray = []
	for id in loot:
		parts.append("%s ×%d" % [display_name(String(id), values), int(loot[id])])
	return "nothing" if parts.is_empty() else ", ".join(parts)
