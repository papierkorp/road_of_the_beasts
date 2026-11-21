class_name Crafting
extends RefCounted
## Alchemy and smithing (docs/vision.md §7, docs/overworld.md §6.2, §6.3). What a plant or a part gives is drawn when
## a game starts and stays fixed within it; the player finds it by trying (`GameState.known`). The same plants
## always give the same pill, the same parts the same piece.

const WEAPON := "weapon"
const ARMOUR := "armour"


# ---------- alchemy ----------

static func property(values: GameValues, id: StringName) -> Dictionary:
	for p: Dictionary in values.properties:
		if StringName(p["id"]) == id:
			return p
	return {}


## The properties of a plant in this game.
static func properties_of(game: GameState, plant: StringName) -> Array[StringName]:
	var ids: Array[StringName] = []
	for p: Dictionary in game.values.properties:
		ids.append(StringName(p["id"]))
	var rng := game.rng_for("plant_%s" % plant)
	var out: Array[StringName] = []
	while out.size() < game.values.properties_per_plant and not ids.is_empty():
		out.append(ids.pop_at(rng.randi_range(0, ids.size() - 1)))
	return out


## The properties of a plant the player has found so far.
static func known_of(game: GameState, plant: StringName) -> Array:
	return game.known.get("plant:%s" % plant, [])


static func plant_of(item: String) -> StringName:
	return StringName(item.get_slice(":", 1))


static func can_brew(game: GameState, plants: Array[String]) -> bool:
	if plants.size() < 2 or plants.size() > 3:
		return false
	var seen := {}
	for item in plants:
		if Materials.form(item) != "plant" or game.count(item) < 1 or seen.has(plant_of(item)):
			return false
		seen[plant_of(item)] = true
	return true


## Brews two or three different plants. They are used up. Returns the pill ("" when they share nothing).
static func brew(game: GameState, plants: Array[String]) -> String:
	if not can_brew(game, plants):
		return ""
	var shared: Array[StringName] = properties_of(game, plant_of(plants[0]))
	var tier := 99
	for item in plants:
		game.take_item(item)
		tier = mini(tier, Materials.tier(item))
		var mine := properties_of(game, plant_of(item))
		shared = shared.filter(func(p: StringName) -> bool: return mine.has(p))
	if shared.is_empty():
		game.say("The plants share nothing: they are lost.")
		return ""
	var names: PackedStringArray = []
	for p in shared:
		names.append(String(p))
	names.sort()
	for item in plants:                           # every plant used is now known to have the shared properties
		var key := "plant:%s" % plant_of(item)
		var found: Array = game.known.get(key, [])
		for p in names:
			if not found.has(p):
				found.append(p)
		game.known[key] = found
	var pill := "pill:%s:%d" % ["+".join(names), tier]
	game.add_item(pill)
	game.say("Brewed: %s." % Materials.display_name(pill, game.values))
	return pill


static func pill_properties(pill: String) -> PackedStringArray:
	return pill.get_slice(":", 1).split("+")


## Why a pill cannot be used on a monster here ("" = it can). `in_dungeon`: between the battles of a run.
static func use_problem(game: GameState, pill: String, m: MonsterInstance, in_dungeon: bool) -> String:
	if game.count(pill) < 1:
		return "none left"
	var can := false
	for p in pill_properties(pill):
		match p:
			"mending":
				if in_dungeon and m.current_hp > 0 and m.current_hp < m.max_hp():
					can = true
			"change":
				if not in_dungeon and m.uses_points():
					can = true
			"bloodline":
				if not in_dungeon and m.rarity < MonsterInstance.Rarity.EPIC:
					can = true
	return "" if can else "no use here"


## Uses a pill on a monster outside a battle. Pills that act in a battle, and the relearning pill, are not built.
static func use(game: GameState, pill: String, m: MonsterInstance, in_dungeon := false) -> bool:
	if use_problem(game, pill, m, in_dungeon) != "":
		return false
	game.take_item(pill)
	for p in pill_properties(pill):
		match p:
			"mending":
				if in_dungeon and m.current_hp > 0:
					m.current_hp = mini(m.max_hp(), m.current_hp + 2)
			"change":
				if not in_dungeon:
					m.refund_points()
			"bloodline":
				if not in_dungeon and m.rarity < MonsterInstance.Rarity.EPIC:
					m.rarity = (int(m.rarity) + 1) as MonsterInstance.Rarity
	game.say("%s took %s." % [m.species().display_name, Materials.display_name(pill, game.values)])
	return true


# ---------- smithing ----------

## What the core of a piece gives: the skill of a weapon or the passive of an armour, by the Kin of the beast part.
## Known from the start: {"name", "text"}.
static func core_of(game: GameState, kind: String, kin: int) -> Dictionary:
	var list: Array = game.values.weapon_skills if kind == WEAPON else game.values.armour_passives
	return list[kin % list.size()] if not list.is_empty() else {"name": "?", "text": ""}


## The variation an essence of a tier gives: {"name", "text"}.
static func temper_of(game: GameState, tier: int) -> Dictionary:
	var list: Array = game.values.tempers
	return list[tier % list.size()] if not list.is_empty() else {"name": "?", "text": ""}


## The name of the piece these parts give, before it is forged.
static func piece_name(game: GameState, kind: String, ore: String, part: String, essence := "") -> String:
	var name := String(core_of(game, kind, int(part.get_slice(":", 1)))["name"])
	if essence != "":
		name = "%s %s" % [temper_of(game, Materials.tier(essence))["name"], name]
	return "%s:%s (%s)" % [kind, name, Stage.stage_name(Materials.tier(ore) as Stage.Type)]


static func can_forge(game: GameState, kind: String, ore: String, part: String, essence := "") -> bool:
	return kind in [WEAPON, ARMOUR] and Materials.form(ore) == "ore" and game.count(ore) > 0 \
		and Materials.form(part) == "part" and game.count(part) > 0 \
		and (essence == "" or (Materials.form(essence) == "essence" and game.count(essence) > 0))


## Forges a piece: a body of ore (the tier), a core of a beast part (what it gives), a temper of an essence (optional).
## What comes out is known before (`piece_name`).
## Returns the item. A piece has no effect in a battle yet.
static func forge(game: GameState, kind: String, ore: String, part: String, essence := "") -> String:
	if not can_forge(game, kind, ore, part, essence):
		return ""
	var item := piece_name(game, kind, ore, part, essence)
	if essence != "":
		game.take_item(essence)
	game.take_item(ore)
	game.take_item(part)
	game.add_item(item)
	game.say("Forged: %s." % Materials.display_name(item, game.values))
	return item


## Puts an armour on a monster; the piece it wore goes back to the inventory. "" takes the armour off.
static func wear(game: GameState, m: MonsterInstance, armour: String) -> bool:
	if armour != "" and (Materials.form(armour) != ARMOUR or game.count(armour) < 1):
		return false
	if m.armour != &"":
		game.add_item(String(m.armour))
	if armour != "":
		game.take_item(armour)
	m.armour = StringName(armour)
	return true
