class_name StructureRules
extends RefCounted
## What placed structures do and which neighbours help each other (gdd_overworld §6.4).
## The adjacency rules of this step:
##   herb plot next to water            -> grows one night faster
##   cultivation spot next to an altar of the meditating monster's aspect -> +5 XP per night

const GROW_NIGHTS := 3
const HARVEST_YIELD := 3
const ALTAR_BONUS := 5


static func neighbours(state: GameState, s: Dictionary) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var mine := BuildGrid.structure_cells(s)
	for other in state.structures:
		if int(other["uid"]) != int(s["uid"]) and BuildGrid.adjacent(mine, BuildGrid.structure_cells(other)):
			out.append(other)
	return out


static func has_water_neighbour(state: GameState, s: Dictionary) -> bool:
	for n in neighbours(state, s):
		if StructureCatalog.def(StringName(n["id"])).water:
			return true
	return false


## Nights a herb plot needs before it can be harvested.
static func grow_nights(state: GameState, s: Dictionary) -> int:
	return maxi(1, GROW_NIGHTS - (1 if has_water_neighbour(state, s) else 0))


static func is_ready(state: GameState, s: Dictionary) -> bool:
	return String(s["plant"]) != "" and int(s["grown"]) >= grow_nights(state, s)


## XP the monster at a cultivation spot gains tonight: {xp, bonus} (0 without a monster).
static func idle_xp(state: GameState, s: Dictionary) -> Dictionary:
	var def := StructureCatalog.def(StringName(s["id"]))
	var idx := int(s["assigned"])
	if def.category != StructureDef.Category.CULTIVATION or idx < 0 or idx >= state.monsters.size():
		return {"xp": 0, "bonus": 0}
	var monster_aspect := state.monsters[idx].species().aspect
	var bonus := 0
	for n in neighbours(state, s):
		var nd := StructureCatalog.def(StringName(n["id"]))
		if nd.id.begins_with("altar_") and nd.aspect == monster_aspect:
			bonus += ALTAR_BONUS
	return {"xp": def.idle_xp + bonus, "bonus": bonus}


## Short descriptions of the bonuses a structure currently gets (for its panel).
static func bonus_lines(state: GameState, s: Dictionary) -> Array[String]:
	var out: Array[String] = []
	var def := StructureCatalog.def(StringName(s["id"]))
	if def.category == StructureDef.Category.GROWING:
		if has_water_neighbour(state, s):
			out.append("Water next to it: grows one night faster.")
		else:
			out.append("Put water (Spirit Pond, Qi Spring) next to it to grow a night faster.")
	elif def.category == StructureDef.Category.CULTIVATION:
		var info := idle_xp(state, s)
		if int(info["bonus"]) > 0:
			out.append("Altar of the monster's aspect nearby: +%d XP." % int(info["bonus"]))
		else:
			out.append("An altar of the meditating monster's aspect next to it gives +%d XP." % ALTAR_BONUS)
	return out
