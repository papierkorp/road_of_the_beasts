class_name GameState
extends RefCounted
## The whole state of one game of the hub game (docs/vision.md): the lifespan, the tamer's stage and Way, the roster
## and what the player owns. Headless: no nodes, no battle rules. The places (Wild, VoidPlace), the tree (Cultivation)
## and the goods (Crafting) work on it. The lifespan is the one clock: every battle and every new look at the wild
## costs a year of it; a breakthrough gives a new one. There are no days and no nights.
##
## Everything drawn is drawn from `game_seed` (`rng_for`), so a save holds no generator state and the same game
## shows the same wild battles and battlegrounds again.

const TAMER_SLOTS: Array[int] = [1, 2, 3, 3, 4]             # docs/overworld.md §5.1
const SEAL := &"seal"
## What catches takes no tamer slot: the Seal skill of the Formation, the Binding pill of the Alchemist.
const CATCHING: Array[StringName] = [SEAL, &"pill_binding"]
## The three Ways (docs/vision.md §2): a game follows one and has nothing of the other two.
const ARTIFICER := &"way_of_the_artificer"
const FORMATION := &"way_of_the_formation"
const ALCHEMIST := &"way_of_the_alchemist"
const LOST := &"lost"
const WON := &"won"

var values: GameValues
var game_seed := 0
var day := 1
var stage: Stage.Type = Stage.Type.QI_GATHERING
## Years left to live, the stock every deed is paid from; at 0 the breakthrough trial is forced (docs/vision.md §3).
var lifespan := 0
var forced_trial := false
## "" while the game runs, LOST or WON when it is over.
var outcome: StringName = &""

var system: StringName = &""
var path_points := 0
## Bought nodes of the Way.
var nodes: Array[StringName] = []
var tamer_skills: Array[StringName] = []
## Vows taken (docs/overworld.md §5.3), and the vows offered right now ([] = no offer open).
var vows: Array[StringName] = []
var vow_offer: Array[StringName] = []
## Boons taken at the breakthroughs (docs/overworld.md §5.1; one may be taken more than once), and whether a choice is open.
var boons: Array[StringName] = []
var boon_pick := false
## Forged parts of the battleground: part id -> number owned.
var parts := {}
## The player's own battleground as plain data ({} = none built yet); the format is that of `MapData`.
var battleground := {}

var roster: Array[MonsterInstance] = []
## Eggs in the nest: {"species": id, "battles": battles left until it hatches}.
var eggs: Array[Dictionary] = []
## Materials and pills: item id -> number.
var items := {}

## The wild (see Wild): the number of the look the player has now, and the battles of it already won.
var wild_roll := 0
var wild_gone: Array[int] = []
## Rises the last wild battle won left to give: the step of each monster defeated (see Wild).
var rises: Array[int] = []
## Depths of the void won in the current stage.
var void_depth := 0
var messages: Array[String] = []


## The gifts a new game offers its Way (docs/vision.md §5), drawn from the seed: {"id", "name", "text"}. One is taken.
## The Formation: a tamer skill of its first tree. The Artificer: a pack of parts. The Alchemist: pills for the battle.
static func start_offer(p_values: GameValues, offer_seed: int, p_system: StringName) -> Array[Dictionary]:
	var pool: Array[Dictionary] = []
	match p_system:
		ARTIFICER:
			for p: Dictionary in p_values.start_packs:
				var lines: PackedStringArray = []
				for part: String in p["parts"]:
					lines.append("%d × %s" % [int(p["parts"][part]), Materials.part_name(part)])
				pool.append({"id": String(p["id"]), "name": String(p["name"]), "text": "Parts for the board: " + ", ".join(lines)})
		FORMATION:
			var def := CultivationDef.of(p_system)
			for n: Dictionary in (def.nodes if def != null else []):
				if int(n["stage"]) == 0 and n["kind"] == "tamer" and StringName(n["needs"]) == &"":
					var skill := BattleContent.shared().tamer_skill(StringName(n["ref"]))
					pool.append({"id": String(n["id"]), "name": String(n["name"]), "text": "Tamer skill, once per battle: " + (skill.description if skill != null else "")})
		ALCHEMIST:
			for p: Dictionary in p_values.properties:
				if String(p["use"]) == "battle" and StringName(p["id"]) != Crafting.BINDING:
					pool.append({"id": String(p["id"]), "name": String(p["name"]), "text": "%d × %s" % [p_values.alchemist_start_pills, p["pill"]]})
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([offer_seed, "gift", p_system])
	var out: Array[Dictionary] = []
	while out.size() < p_values.start_offer and not pool.is_empty():
		out.append(pool.pop_at(rng.randi_range(0, pool.size() - 1)))
	return out


## Hands out the gift of the start; an id that was not offered gives nothing.
func _take_gift(gift: String) -> void:
	var offered := false
	for o in start_offer(values, game_seed, system):
		offered = offered or o["id"] == gift
	if not offered:
		return
	match system:
		ARTIFICER:
			for p: Dictionary in values.start_packs:
				if String(p["id"]) == gift:
					for part: String in p["parts"]:
						parts[part] = int(parts.get(part, 0)) + int(p["parts"][part])
		FORMATION:
			var n := CultivationDef.of(system).node(StringName(gift))
			nodes.append(StringName(gift))
			tamer_skills.append(StringName(n["ref"]))
		ALCHEMIST:
			add_item(Materials.pill(StringName(gift)), values.alchemist_start_pills)


## `gift`: the id of one of `start_offer` ("" = none).
static func new_game(p_seed: int, p_system: StringName, egg_species: StringName, p_values: GameValues = null, gift := "") -> GameState:
	var g := GameState.new()
	g.values = p_values if p_values != null else GameValues.shared()
	g.game_seed = p_seed
	g.system = p_system
	g.lifespan = GameValues.at(g.values.lifespan_years, 0)
	g.offer_vows()
	match p_system:                               # what a Way starts with; each catches by its own means
		ARTIFICER:
			g.parts = g.values.bg_start_parts.duplicate()
			g.battleground = g.values.bg_start_map.duplicate(true)
		FORMATION:
			g.tamer_skills.append(SEAL)
		ALCHEMIST:
			Crafting.start_alchemist(g)
	g._take_gift(gift)
	var def := GameData.monster(egg_species)
	if def != null:
		g.roster.append(MonsterInstance.hatched(def))
		g.say("Your egg hatched: %s. Shape it under Monsters: spend its stat points and choose its skills." % def.display_name)
	return g


## The three eggs of the nest for a new game (docs/vision.md §5): drawn from the part of the pool that the finished
## games have opened, each of another Kin.
static func egg_offer(p_values: GameValues, offer_seed: int, finished_games: int) -> Array[StringName]:
	var open: Array[StringName] = []
	var n := mini(p_values.egg_pool.size(), p_values.egg_pool_start + p_values.egg_pool_per_game * maxi(0, finished_games))
	for i in n:
		if GameData.monster(StringName(p_values.egg_pool[i])) != null:
			open.append(StringName(p_values.egg_pool[i]))
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([offer_seed, "eggs"])
	var out: Array[StringName] = []
	var kins := {}
	while out.size() < 3 and not open.is_empty():
		var id: StringName = open.pop_at(rng.randi_range(0, open.size() - 1))
		var kin := int(GameData.monster(id).kin)
		if not kins.has(kin):
			kins[kin] = true
			out.append(id)
	return out


## A generator for one purpose: the same game and tag always give the same numbers.
func rng_for(tag: String) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([game_seed, tag])
	return rng


## The Way of this game.
func is_artificer() -> bool:
	return system == ARTIFICER


func is_formation() -> bool:
	return system == FORMATION


func is_alchemist() -> bool:
	return system == ALCHEMIST


## The sum of an effect over the bought nodes of the Way.
func node_sum(key: String) -> int:
	var def := CultivationDef.of(system)
	var sum := 0
	if def != null:
		for id in nodes:
			sum += int((def.node(id).get("effects", {}) as Dictionary).get(key, 0))
	return sum


## Parts the Artificer lays before each battle of the wild (docs/overworld.md §5.3).
func carry() -> int:
	if not is_artificer():
		return 0
	return values.carry_base + values.carry_per_stage * int(stage) + node_sum("carry") + vow_sum("carry")


## Whether the player may lay Seal Ground and catch.
func can_catch() -> bool:
	return not vow_has("no_seal")


## The options of Seal the Formation bought as nodes of its Way (docs/overworld.md §5.4), in the order bought.
func seal_options() -> Array:
	var out: Array = []
	var def := CultivationDef.of(system)
	if def != null:
		for id in nodes:
			var n := def.node(id)
			if String(n.get("kind", "")) == "seal":
				out.append(String(n["ref"]))
	return out


## Tamer slots: tamer skills for the Formation, pills for the Alchemist; the Artificer has none and lays parts.
func tamer_slots() -> int:
	if is_artificer():
		return 0
	return TAMER_SLOTS[clampi(int(stage), 0, TAMER_SLOTS.size() - 1)] + vow_sum("tamer_slots") + node_sum("tamer_slots")


# ---------- vows ----------

## A vow or a boon by its id: both are a name and effects.
func vow_def(id: StringName) -> Dictionary:
	for v: Dictionary in values.vows + values.boons:
		if StringName(v["id"]) == id:
			return v
	return {}


## The sum of an effect over the vows and boons taken (a flag counts 1).
func vow_sum(key: String) -> int:
	var sum := 0
	for id in vows + boons:
		var e: Dictionary = vow_def(id).get("effects", {})
		if e.has(key):
			sum += int(e[key])
	return sum


func vow_has(key: String) -> bool:
	return vow_sum(key) != 0 or _vow_names(key)


func _vow_names(key: String) -> bool:
	for id in vows:
		if (vow_def(id).get("effects", {}) as Dictionary).has(key):
			return true
	return false


## Whether a loadout fits the tamer slots: every entry takes one, but the means of catching (the Seal skill, a Binding
## pill) rides beside the slots.
func loadout_fits(loadout: Array[StringName]) -> bool:
	var taken := 0
	for id in loadout:
		if not CATCHING.has(id):
			taken += 1
	return taken <= tamer_slots()


## The values of an effect over the vows taken (the Kins of `ban_kin`, of `kin_choice`).
func vow_values(key: String) -> Array[int]:
	var out: Array[int] = []
	for id in vows:
		var e: Dictionary = vow_def(id).get("effects", {})
		if e.has(key):
			out.append(int(e[key]))
	return out


## Draws a new offer: vows not taken yet, of this Way or of every Way. No offer once the cap is reached.
func offer_vows() -> void:
	vow_offer.clear()
	if vows.size() >= values.vow_cap or is_over():
		return
	var pool: Array[StringName] = []
	for v: Dictionary in values.vows:
		var way := String(v.get("way", ""))
		if not vows.has(StringName(v["id"])) and (way == "" or way == String(system)):
			pool.append(StringName(v["id"]))
	var rng := rng_for("vows%d_%d" % [int(stage), vows.size()])
	while vow_offer.size() < values.vow_offer and not pool.is_empty():
		vow_offer.append(pool.pop_at(rng.randi_range(0, pool.size() - 1)))


## Takes one vow of the offer (&"" = none): it holds for the rest of the game.
func take_vow(id: StringName) -> bool:
	if id == &"":
		vow_offer.clear()
		say("You took no vow.")
		return true
	if not vow_offer.has(id) or vows.size() >= values.vow_cap:
		return false
	vows.append(id)
	vow_offer.clear()
	var e: Dictionary = vow_def(id).get("effects", {})
	if e.has("lifespan") and not forced_trial:
		lifespan = maxi(1, lifespan + int(e["lifespan"]))
	if e.has("no_seal"):
		tamer_skills.erase(SEAL)
	if e.has("slot_all"):
		for m in roster:
			m.slots = mini(MonsterInstance.MAX_SLOTS, m.slots + 1)
	say("You swore: %s." % vow_def(id)["name"])
	return true


func kin_banned(kin: int) -> bool:
	return vow_values("ban_kin").has(kin)


## What keeps a team from a battle ("" = nothing).
func team_problem(team: Array[MonsterInstance]) -> String:
	if vow_has("one_kin_team"):
		for m in team:
			if m.species().kin != team[0].species().kin:
				return "your vow: a team of one Kin only"
	return ""


## The places a team has on a battleground that offers `room`.
func team_cap(room: int) -> int:
	return maxi(1, room + vow_sum("team"))


func is_over() -> bool:
	return outcome != &""


func say(text: String) -> void:
	messages.append(text)
	while messages.size() > 30:
		messages.pop_front()


## Pays `years` of the lifespan for a deed (docs/vision.md §3). When none is left the breakthrough trial is forced.
func spend(years: int) -> void:
	if is_over() or forced_trial:
		return
	day += years
	lifespan = maxi(0, lifespan - years)
	if lifespan <= 0:
		forced_trial = true
		say("Your lifespan has run out. The breakthrough trial waits in the void: you must take it now.")


## A battle was fought, won or lost: every egg in the nest comes a battle closer to hatching.
func battle_fought() -> void:
	for e in eggs.duplicate():
		e["battles"] = int(e["battles"]) - 1
		if int(e["battles"]) <= 0 and roster.size() < roster_cap():
			eggs.erase(e)
			var def := GameData.monster(StringName(e["species"]))
			_join(MonsterInstance.hatched(def, int(stage) * 3))
			say("An egg hatched: %s. Shape it under Monsters." % def.display_name)


## The breakthrough (docs/vision.md §3): the next stage, its lifespan, a new ladder of depths. Immortal is the last
## stage: its trial is the Sovereign beast, and nobody rises past it.
func break_through() -> void:
	if int(stage) >= int(Stage.Type.IMMORTAL):
		return
	stage = (int(stage) + 1) as Stage.Type
	forced_trial = false
	void_depth = 0
	wild_roll += 1                                # the wild of the new stage
	wild_gone.clear()
	lifespan = maxi(1, GameValues.at(values.lifespan_years, int(stage)) + vow_sum("lifespan"))
	say("Breakthrough: you are now at %s. Lifespan: %d years." % [Stage.stage_name(stage), lifespan])
	boon_pick = not values.boons.is_empty()
	offer_vows()


## Takes the boon of a breakthrough (docs/overworld.md §5.1): one of all, also one taken before.
func take_boon(id: StringName) -> bool:
	if not boon_pick:
		return false
	var found := false
	for b: Dictionary in values.boons:
		found = found or StringName(b["id"]) == id
	if not found:
		return false
	boons.append(id)
	boon_pick = false
	var e: Dictionary = vow_def(id).get("effects", {})
	if e.has("lifespan") and not forced_trial:
		lifespan += int(e["lifespan"])
	say("You took the boon: %s." % vow_def(id)["name"])
	return true


func lose() -> void:
	outcome = LOST


## The Sovereign beast fell (docs/vision.md §3): the game is won, at whatever stage the tamer stood.
func win() -> void:
	forced_trial = false
	outcome = WON
	say("The Sovereign beast has fallen. You have won.")


# ---------- what the player owns ----------

func count(item: String) -> int:
	return int(items.get(item, 0))


func add_item(item: String, n := 1) -> void:
	if n > 0:
		items[item] = count(item) + n


func take_item(item: String, n := 1) -> bool:
	if count(item) < n:
		return false
	items[item] = count(item) - n
	if int(items[item]) <= 0:
		items.erase(item)
	return true


func roster_cap() -> int:
	return values.roster_cap


func has_room() -> bool:
	return roster.size() + eggs.size() < roster_cap()


func add_monster(m: MonsterInstance) -> bool:
	if not has_room() or kin_banned(int(m.species().kin)):
		return false
	_join(m)
	return true


func _join(m: MonsterInstance) -> void:
	if vow_has("slot_all"):
		m.slots = mini(MonsterInstance.MAX_SLOTS, m.slots + 1)
	roster.append(m)


func add_egg(species: StringName) -> bool:
	var egg_def := GameData.monster(species)
	if not has_room() or (egg_def != null and kin_banned(int(egg_def.kin))):
		return false
	eggs.append({"species": String(species), "battles": values.egg_battles})
	return true


## The first `size` monsters of the roster that can fight (HP above 0).
func default_team(size: int) -> Array[MonsterInstance]:
	var out: Array[MonsterInstance] = []
	for m in roster:
		if m.current_hp > 0 and out.size() < size and team_problem(out + ([m] as Array[MonsterInstance])) == "":
			out.append(m)
	return out


## The tamer skills brought by default: as many of the learned ones as there are slots (the Formation; the pills of
## the Alchemist are chosen by hand).
func default_loadout() -> Array[StringName]:
	var out: Array[StringName] = []
	for id in tamer_skills:
		if loadout_fits(out + ([id] as Array[StringName])):
			out.append(id)
	return out


## The step of growth a monster of a place has: the middle of the stage of the place.
static func step_of(place_stage: int, sub_tier := 1) -> int:
	return clampi(place_stage * 3 + sub_tier, 0, MonsterInstance.STEPS - 1)


## The void lifts (docs/vision.md §8): every monster that fought in a won battle there and still stands rises a
## step, also from High into the next stage, never past the stage of the tamer. Returns the lines to show.
func rise_in_void(team: Array[MonsterInstance]) -> Array[String]:
	var lines: Array[String] = []
	for m in team:
		if m.current_hp > 0 and lift(m):
			lines.append(rise_line(m))
	return lines


## One rise for a monster, with what a vow adds to it.
func lift(m: MonsterInstance) -> bool:
	var before := int(m.stage)
	if not m.rise(stage):
		return false
	if int(m.stage) > before and vow_values("kin_choice").has(int(m.species().kin)):
		m.choice_picks += 1                           # a vow of its Kin: two of the choices
	m.heal_full()
	return true


func rise_line(m: MonsterInstance) -> String:
	return "%s rose to %s %s: +%d stat points%s." % [m.species().display_name, Stage.stage_name(m.stage),
		Stage.sub_tier_name(m.sub_tier), MonsterInstance.STEP_POINTS, " and a breakthrough choice" if m.choice_picks > 0 else ""]


# ---------- save ----------

func to_dict() -> Dictionary:
	var r: Array = []
	for m in roster:
		r.append(m.to_dict())
	return {"version": 5, "seed": game_seed, "day": day, "stage": int(stage), "lifespan": lifespan,
		"forced_trial": forced_trial, "outcome": String(outcome), "system": String(system), "path_points": path_points,
		"nodes": _strings(nodes), "vows": _strings(vows), "vow_offer": _strings(vow_offer), "tamer_skills": _strings(tamer_skills),
		"parts": parts.duplicate(), "battleground": battleground.duplicate(true), "roster": r, "eggs": eggs.duplicate(true),
		"items": items.duplicate(), "wild_roll": wild_roll, "wild_gone": wild_gone.duplicate(), "rises": rises.duplicate(),
		"boons": _strings(boons), "boon_pick": boon_pick, "void_depth": void_depth,
		"messages": messages.duplicate()}


static func from_dict(d: Dictionary, p_values: GameValues = null) -> GameState:
	if int(d.get("version", 0)) != 5:             # a save of the game before the wild cannot be read
		return null
	var g := GameState.new()
	g.values = p_values if p_values != null else GameValues.shared()
	g.game_seed = int(d["seed"])
	g.day = int(d["day"])
	g.stage = int(d["stage"]) as Stage.Type
	g.lifespan = int(d["lifespan"])
	g.forced_trial = bool(d["forced_trial"])
	g.outcome = StringName(d["outcome"])
	g.system = StringName(d["system"])
	g.path_points = int(d["path_points"])
	g.nodes = _names(d["nodes"])
	g.tamer_skills = _names(d["tamer_skills"])
	g.vows = _names(d.get("vows", []))
	g.vow_offer = _names(d.get("vow_offer", []))
	for k in d["parts"]:
		g.parts[String(k)] = int(d["parts"][k])
	g.battleground = (d["battleground"] as Dictionary).duplicate(true)
	for m in d["roster"]:
		g.roster.append(MonsterInstance.from_dict(m))
	for e in d["eggs"]:
		g.eggs.append({"species": String(e["species"]), "battles": int(e["battles"])})
	for k in d["items"]:
		g.items[String(k)] = int(d["items"][k])
	g.wild_roll = int(d["wild_roll"])
	for i in d["wild_gone"]:
		g.wild_gone.append(int(i))
	for s in d["rises"]:
		g.rises.append(int(s))
	g.boons = _names(d["boons"])
	g.boon_pick = bool(d["boon_pick"])
	g.void_depth = int(d["void_depth"])
	for line in d["messages"]:
		g.messages.append(String(line))
	return g


static func _strings(list: Array[StringName]) -> Array:
	var out: Array = []
	for s in list:
		out.append(String(s))
	return out


static func _names(list: Array) -> Array[StringName]:
	var out: Array[StringName] = []
	for s in list:
		out.append(StringName(s))
	return out
