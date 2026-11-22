class_name Crafting
extends RefCounted
## Alchemy and smithing (docs/vision.md §7, docs/overworld.md §6.2, §6.3). What a plant gives is drawn when a game
## starts and stays fixed within it; the player finds it by trying (`GameState.known`). The same plants always give
## the same pill. The forge shows every piece before it is made: two beast parts, what it makes and how it acts;
## which Kin gives which is drawn per game too, but never hidden.

const WEAPON := "weapon"
const PART := "part"
## The two flaws (docs/overworld.md §6.2).
const VOLATILE := "volatile"      # the pill spoils in the night after it was brewed
const BITTER := "bitter"          # the monster that takes it loses 1 HP, never its last


# ---------- alchemy ----------

static func property(values: GameValues, id: StringName) -> Dictionary:
	for p: Dictionary in values.properties:
		if StringName(p["id"]) == id:
			return p
	return {}


static func flaw_def(values: GameValues, id: String) -> Dictionary:
	for f: Dictionary in values.flaws:
		if String(f["id"]) == id:
			return f
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


## The one flaw of a plant in this game ("" when the values hold none).
static func flaw_of(game: GameState, plant: StringName) -> String:
	var flaws: Array = game.values.flaws
	if flaws.is_empty():
		return ""
	return String(flaws[game.rng_for("flaw_%s" % plant).randi_range(0, flaws.size() - 1)]["id"])


## The properties of a plant the player has found so far.
static func known_of(game: GameState, plant: StringName) -> Array:
	return game.known.get("plant:%s" % plant, [])


## The flaw of a plant if the player has found it ("" = not yet).
static func known_flaw(game: GameState, plant: StringName) -> String:
	return String(game.known.get("flaw:%s" % plant, ""))


static func plant_of(item: String) -> StringName:
	return StringName(item.get_slice(":", 1))


static func can_brew(game: GameState, plants: Array[String]) -> bool:
	if game.vow_has("no_pills"):
		return false
	if plants.size() < 2 or plants.size() > 3:
		return false
	var seen := {}
	for item in plants:
		if Materials.form(item) != "plant" or game.count(item) < 1 or seen.has(plant_of(item)):
			return false
		seen[plant_of(item)] = true
	return true


## Brews two or three different plants. They are used up. Returns the pill ("" when they share nothing). A flaw
## follows the same rule as a property: the pill has it when every plant in it has it.
static func brew(game: GameState, plants: Array[String]) -> String:
	if not can_brew(game, plants):
		return ""
	var shared: Array[StringName] = properties_of(game, plant_of(plants[0]))
	var flaw := flaw_of(game, plant_of(plants[0]))
	var tier := 99
	for item in plants:
		game.take_item(item)
		tier = mini(tier, Materials.tier(item))
		var mine := properties_of(game, plant_of(item))
		shared = shared.filter(func(p: StringName) -> bool: return mine.has(p))
		if flaw_of(game, plant_of(item)) != flaw:
			flaw = ""
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
		if flaw != "":
			game.known["flaw:%s" % plant_of(item)] = flaw
	var pill := "pill:%s:%d" % ["+".join(names), tier]
	if flaw != "":
		pill += ":%s" % flaw
	game.add_item(pill)
	game.say("Brewed: %s." % Materials.display_name(pill, game.values))
	return pill


static func pill_properties(pill: String) -> PackedStringArray:
	return pill.get_slice(":", 1).split("+")


## The highest step of growth in the roster.
static func _top_step(game: GameState) -> int:
	var top := 0
	for m in game.roster:
		top = maxi(top, m.step())
	return top


## Whether Kindling can lift this monster: it stands below the highest monster of the roster and may still grow.
static func _can_kindle(game: GameState, m: MonsterInstance) -> bool:
	return m.uses_points() and m.step() < _top_step(game) and m.can_step(game.stage)


## Why a pill cannot be used on a monster here ("" = it can). `in_dungeon`: between the battles of a run.
static func use_problem(game: GameState, pill: String, m: MonsterInstance, in_dungeon: bool) -> String:
	if game.count(pill) < 1:
		return "none left"
	if game.vow_has("no_pills"):
		return "your vow: no pills"
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
				if not in_dungeon and m.bloodline < MonsterInstance.Bloodline.ANCIENT:
					can = true
			"kindling":
				if not in_dungeon and _can_kindle(game, m):
					can = true
	return "" if can else "no use here"


## Uses a pill on a monster outside a battle. Pills that act in a battle go into a tamer slot; the relearning pill
## is not built.
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
				if not in_dungeon and m.bloodline < MonsterInstance.Bloodline.ANCIENT:
					m.ascend()
			"kindling":
				if not in_dungeon and _can_kindle(game, m):
					m.gain_xp(MonsterInstance.XP_STEPS[m.step()] - m.xp, game.stage)
	if Materials.flaw(pill) == BITTER:              # 1 HP less, never its last: now in a dungeon, else for its next battle
		if in_dungeon:
			m.current_hp = maxi(1, m.current_hp - 1)
		else:
			m.hp_debt += 1
			m.heal_full()
	game.say("%s took %s." % [m.species().display_name, Materials.display_name(pill, game.values)])
	return true


# ---------- smithing ----------

## Which entry a Kin stands for in this game: a shuffle of the list, drawn from the game's seed.
static func _drawn(game: GameState, tag: String, size: int, kin: int) -> int:
	if size <= 0:
		return 0
	var order: Array[int] = []
	for i in size:
		order.append(i)
	var rng := game.rng_for(tag)
	for i in range(size - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var t := order[i]
		order[i] = order[j]
		order[j] = t
	return order[kin % size]


## The "what" the beast part of a Kin gives as the first part in this game (an index into `forge_what`).
static func what_index(game: GameState, kin: int) -> int:
	return _drawn(game, "forge_what", game.values.forge_what.size(), kin)


## The "how" the beast part of a Kin gives as the second part in this game (an index into `forge_how`).
static func how_index(game: GameState, kin: int) -> int:
	return _drawn(game, "forge_how", game.values.forge_how.size(), kin)


## What a first part makes: {"name", "text", "ground" or "prop": id}. `index` is an entry of `forge_what`.
static func what_of(values: GameValues, index: int) -> Dictionary:
	return values.forge_what[index % values.forge_what.size()] if not values.forge_what.is_empty() else {"name": "?", "text": ""}


## How a piece acts: {"name", "text", "count", "uses"}. `index` is an entry of `forge_how`.
static func how_of(values: GameValues, index: int) -> Dictionary:
	return values.forge_how[index % values.forge_how.size()] if not values.forge_how.is_empty() else {"name": "?", "text": "", "count": 1, "uses": 1}


## The name of a piece by its entries of `forge_what` and `forge_how`.
static func piece_name(values: GameValues, what: int, how: int) -> String:
	return "%s %s" % [what_of(values, what)["name"], how_of(values, how)["name"]]


## What a piece does, as one line for the forge.
static func piece_text(values: GameValues, what: int, how: int) -> String:
	return "%s; %s" % [what_of(values, what)["text"], how_of(values, how)["text"]]


## The part of a battleground a "what" stands for: "ground:<id>" or "prop:<id>".
static func board_part(values: GameValues, what: int) -> String:
	var w := what_of(values, what)
	return "prop:%s" % w["prop"] if w.has("prop") else "ground:%s" % w.get("ground", "plain")


## Units of the part a pair gives in the form of a part of a battleground.
static func part_units(values: GameValues, how: int) -> int:
	var h := how_of(values, how)
	return maxi(1, int(h.get("count", 1))) * maxi(1, int(h.get("uses", 1)))


## The beast parts a pair costs: item -> number (two of one Kin when both parts are of it).
static func forge_cost(what_kin: int, how_kin: int) -> Dictionary:
	var cost := {}
	for kin: int in [what_kin, how_kin]:
		var item := Materials.beast_part(kin)
		cost[item] = int(cost.get(item, 0)) + 1
	return cost


static func can_forge(game: GameState, form: String, what_kin: int, how_kin: int) -> bool:
	if not form in [WEAPON, PART] or (form == WEAPON and game.vow_has("no_weapons")):
		return false
	var cost := forge_cost(what_kin, how_kin)
	for item: String in cost:
		if game.count(item) < int(cost[item]):
			return false
	return true


## Forges a piece from two beast parts (docs/overworld.md §6.3): the first says what it makes, the second how it
## acts. The same pair gives a weapon (an item for a tamer slot) or parts of the battleground (units for the
## workshop). Returns the weapon item, or the part id for the form PART; "" when it cannot be forged.
static func forge(game: GameState, form: String, what_kin: int, how_kin: int) -> String:
	if not can_forge(game, form, what_kin, how_kin):
		return ""
	var cost := forge_cost(what_kin, how_kin)
	for item: String in cost:
		game.take_item(item, int(cost[item]))
	var what := what_index(game, what_kin)
	var how := how_index(game, how_kin)
	if form == WEAPON:
		var item := Materials.weapon(what, how)
		game.add_item(item)
		game.say("Forged: %s." % Materials.display_name(item, game.values))
		return item
	var part := board_part(game.values, what)
	var units := part_units(game.values, how)
	game.parts[part] = int(game.parts.get(part, 0)) + units
	game.say("Forged for your battleground: %d × %s." % [units, piece_name(game.values, what, how)])
	return part


## The id of the tamer skill a forged weapon is in a battle (built by `Forged` in game/), by its entries of
## `forge_what` and `forge_how`.
static func weapon_skill(what: int, how: int) -> StringName:
	return StringName("forged_%d_%d" % [what, how])


## Uses per battle of an item in a tamer slot (1 unless its "how" says more).
static func battle_uses(game: GameState, item: String) -> int:
	if Materials.form(item) != WEAPON:
		return 1
	return maxi(1, int(how_of(game.values, int(item.get_slice(":", 2))).get("uses", 1)))


## The tamer skill an item brings into a battle (&"" = none): the skill of a weapon, the effect of a battle pill.
static func battle_skill_of(game: GameState, item: String) -> StringName:
	match Materials.form(item):
		WEAPON:
			return weapon_skill(int(item.get_slice(":", 1)), int(item.get_slice(":", 2))) if not game.vow_has("no_weapons") else &""
		"pill":
			if game.vow_has("no_pills"):
				return &""
			for p in pill_properties(item):
				for def: Dictionary in game.values.properties:
					if StringName(def["id"]) == StringName(p) and def.has("skill"):
						return StringName(def["skill"])
	return &""


## The items the player can put into tamer slots: tamer skill id -> item (one item per skill).
static func battle_items(game: GameState) -> Dictionary:
	var out := {}
	var ids: Array = game.items.keys()
	ids.sort()
	for item: String in ids:
		var skill := battle_skill_of(game, item)
		if skill != &"" and not out.has(skill):
			out[skill] = item
	return out


## After a battle: every pill that was taken is used up.
static func spend_used(game: GameState, f: Fight, result: BattleResult) -> void:
	var used: Array = result.used_tamer if result != null else []
	for id in f.tamer_items:
		var item := String(f.tamer_items[id])
		if Materials.form(item) != "pill":
			continue
		if used.has(id) and game.take_item(item):
			game.say("%s was used up." % Materials.display_name(item, game.values))


## The night: every volatile pill spoils (docs/overworld.md §6.2).
static func spoil(game: GameState) -> void:
	for item: String in game.items.keys():
		if Materials.form(item) == "pill" and Materials.flaw(item) == VOLATILE:
			game.say("%s spoiled in the night: it is volatile." % Materials.display_name(item, game.values))
			game.items.erase(item)


## The loadout entries whose pill is bitter: the battle takes 1 HP from the monster it is given to.
static func bitter_entries(f: Fight) -> Array[StringName]:
	var out: Array[StringName] = []
	for id in f.tamer_items:
		if Materials.flaw(String(f.tamer_items[id])) == BITTER:
			out.append(StringName(id))
	return out
