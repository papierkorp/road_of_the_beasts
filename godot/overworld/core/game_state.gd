class_name GameState
extends RefCounted
## The whole state of one game of the hub game (docs/vision.md): the day and its day AP, the lifespan, the tamer's
## stage and cultivation system, the roster and what the player owns. Headless: no nodes, no battle rules. The places
## (WildArea, DungeonRun, VoidPlace), the tree (Cultivation) and crafting (Crafting) work on it.
##
## Everything drawn is drawn from `game_seed` (`rng_for`), so a save holds no generator state and the same game
## shows the same encounters, dungeon maps and properties again.

const TAMER_SLOTS: Array[int] = [1, 2, 3, 3, 4, 4]          # docs/overworld.md §5.1
const SEAL := &"seal"
const LOST := &"lost"
const WON := &"won"

var values: GameValues
var game_seed := 0
var day := 1
var ap := 0
var stage: Stage.Type = Stage.Type.QI_GATHERING
## Days left to live; at 0 the breakthrough trial is forced (docs/vision.md §3).
var lifespan := 0
var forced_trial := false
## "" while the game runs, LOST or WON when it is over.
var outcome: StringName = &""

var system: StringName = &""
var path_points := 0
## Bought nodes of the cultivation system.
var nodes: Array[StringName] = []
var tamer_skills: Array[StringName] = [SEAL]
var blueprints: Array[StringName] = []
## Built parts of the battleground: part id -> number owned.
var parts := {}
## The player's own battleground as plain data ({} = none built yet); the format is that of `MapData`.
var battleground := {}

var roster: Array[MonsterInstance] = []
## Eggs in the nest: {"species": id, "nights": nights left}.
var eggs: Array[Dictionary] = []
## Materials and pills: item id -> number.
var items := {}

## Indexes of today's wild encounters that were won or whose monster was caught.
var wild_gone: Array[int] = []
## Rare encounters (by their number) that are gone.
var rare_gone: Array[int] = []
## The running dungeon run as plain data ({} = none), see DungeonRun.
var dungeon := {}
var dungeon_runs := 0
## Stages whose dungeon challenge is met, and the runs won in a row per stage.
var dungeon_mastered: Array[int] = []
var dungeon_streak := {}
## Depths of the void won in the current stage.
var void_depth := 0
## What the player has found out by brewing and forging: key -> result.
var known := {}
var messages: Array[String] = []


static func new_game(p_seed: int, p_system: StringName, egg_species: StringName, p_values: GameValues = null) -> GameState:
	var g := GameState.new()
	g.values = p_values if p_values != null else GameValues.shared()
	g.game_seed = p_seed
	g.system = p_system
	g.lifespan = GameValues.at(g.values.lifespan_days, 0)
	g.ap = g.max_ap()
	g.parts = g.values.bg_start_parts.duplicate()
	g.battleground = g.values.bg_start_map.duplicate(true)
	var def := GameData.monster(egg_species)
	if def != null:
		g.roster.append(MonsterInstance.hatched(def))
		g.say("Your egg hatched: %s. Shape it under Monsters: spend its stat points and choose its skills." % def.display_name)
	return g


## A generator for one purpose: the same game, day and tag always give the same numbers.
func rng_for(tag: String, with_day := false) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([game_seed, tag, day if with_day else 0])
	return rng


func max_ap() -> int:
	return GameValues.at(values.day_ap, int(stage))


func tamer_slots() -> int:
	return TAMER_SLOTS[clampi(int(stage), 0, TAMER_SLOTS.size() - 1)]


func is_over() -> bool:
	return outcome != &""


func say(text: String) -> void:
	messages.append(text)
	while messages.size() > 30:
		messages.pop_front()


func spend_ap(n: int) -> bool:
	if n < 0 or ap < n or is_over():
		return false
	ap -= n
	return true


## The night (docs/overworld.md §2.2): the lifespan shrinks by a day, the encounters are drawn anew, eggs progress.
## A day cannot end while a dungeon run is under way or the forced trial waits.
func can_end_day() -> bool:
	return not is_over() and dungeon.is_empty() and not forced_trial


func end_day() -> bool:
	if not can_end_day():
		return false
	day += 1
	lifespan -= 1
	ap = max_ap()
	wild_gone.clear()
	for m in roster:
		m.heal_full()
	for e in eggs.duplicate():
		e["nights"] = int(e["nights"]) - 1
		if int(e["nights"]) <= 0 and roster.size() < values.roster_cap:
			eggs.erase(e)
			var def := GameData.monster(StringName(e["species"]))
			roster.append(MonsterInstance.hatched(def, int(stage) * 3))
			say("An egg hatched: %s. Shape it under Monsters." % def.display_name)
	if lifespan <= 0:
		lifespan = 0
		forced_trial = true
		say("Your lifespan has run out. The breakthrough trial waits in the void: you must take it now.")
	return true


## The breakthrough (docs/vision.md §3): the next stage, its lifespan, a new ladder of depths. Sovereign wins the game.
func break_through() -> void:
	stage = (int(stage) + 1) as Stage.Type
	forced_trial = false
	void_depth = 0
	if stage == Stage.Type.SOVEREIGN:
		outcome = WON
		say("You have reached Sovereign.")
		return
	lifespan = GameValues.at(values.lifespan_days, int(stage))
	ap = max_ap()
	say("Breakthrough: you are now at %s. Lifespan: %d years." % [Stage.stage_name(stage), lifespan])


func lose() -> void:
	outcome = LOST


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


func has_room() -> bool:
	return roster.size() + eggs.size() < values.roster_cap


func add_monster(m: MonsterInstance) -> bool:
	if not has_room():
		return false
	roster.append(m)
	return true


func add_egg(species: StringName) -> bool:
	if not has_room():
		return false
	eggs.append({"species": String(species), "nights": values.egg_nights})
	return true


## The first `size` monsters of the roster that can fight (HP above 0).
func default_team(size: int) -> Array[MonsterInstance]:
	var out: Array[MonsterInstance] = []
	for m in roster:
		if m.current_hp > 0 and out.size() < size:
			out.append(m)
	return out


## The tamer skills brought by default: as many of the learned ones as there are slots.
func default_loadout() -> Array[StringName]:
	var out: Array[StringName] = []
	for id in tamer_skills:
		if out.size() < tamer_slots():
			out.append(id)
	return out


## The step of growth a monster of a place has: the middle of the stage of the place.
static func step_of(place_stage: int, sub_tier := 1) -> int:
	return clampi(place_stage * 3 + sub_tier, 0, MonsterInstance.STEPS - 1)


## Gives XP for a won battle to the monsters that fought and still stand. Returns the lines to show.
func award_xp(team: Array[MonsterInstance], place_stage: int) -> Array[String]:
	var lines: Array[String] = []
	var amount := GameValues.at(values.xp_per_win, place_stage)
	for m in team:
		if m.current_hp <= 0:
			continue
		var ups := m.gain_xp(amount, stage)
		if ups > 0:
			lines.append("%s grew to %s %s: +%d stat points%s." % [m.species().display_name, Stage.stage_name(m.stage),
				Stage.sub_tier_name(m.sub_tier), ups * MonsterInstance.STEP_POINTS, " and a breakthrough choice" if m.choice_picks > 0 else ""])
	return lines


# ---------- save ----------

func to_dict() -> Dictionary:
	var r: Array = []
	for m in roster:
		r.append(m.to_dict())
	return {"version": 2, "seed": game_seed, "day": day, "ap": ap, "stage": int(stage), "lifespan": lifespan,
		"forced_trial": forced_trial, "outcome": String(outcome), "system": String(system), "path_points": path_points,
		"nodes": _strings(nodes), "tamer_skills": _strings(tamer_skills), "blueprints": _strings(blueprints),
		"parts": parts.duplicate(), "battleground": battleground.duplicate(true), "roster": r, "eggs": eggs.duplicate(true),
		"items": items.duplicate(), "wild_gone": wild_gone.duplicate(), "rare_gone": rare_gone.duplicate(),
		"dungeon": dungeon.duplicate(true), "dungeon_runs": dungeon_runs, "dungeon_mastered": dungeon_mastered.duplicate(),
		"dungeon_streak": dungeon_streak.duplicate(), "void_depth": void_depth, "known": known.duplicate(true),
		"messages": messages.duplicate()}


static func from_dict(d: Dictionary, p_values: GameValues = null) -> GameState:
	if int(d.get("version", 0)) != 2:
		return null
	var g := GameState.new()
	g.values = p_values if p_values != null else GameValues.shared()
	g.game_seed = int(d["seed"])
	g.day = int(d["day"])
	g.ap = int(d["ap"])
	g.stage = int(d["stage"]) as Stage.Type
	g.lifespan = int(d["lifespan"])
	g.forced_trial = bool(d["forced_trial"])
	g.outcome = StringName(d["outcome"])
	g.system = StringName(d["system"])
	g.path_points = int(d["path_points"])
	g.nodes = _names(d["nodes"])
	g.tamer_skills = _names(d["tamer_skills"])
	g.blueprints = _names(d["blueprints"])
	for k in d["parts"]:
		g.parts[String(k)] = int(d["parts"][k])
	g.battleground = (d["battleground"] as Dictionary).duplicate(true)
	for m in d["roster"]:
		g.roster.append(MonsterInstance.from_dict(m))
	for e in d["eggs"]:
		g.eggs.append({"species": String(e["species"]), "nights": int(e["nights"])})
	for k in d["items"]:
		g.items[String(k)] = int(d["items"][k])
	g.wild_gone = _ints(d["wild_gone"])
	g.rare_gone = _ints(d["rare_gone"])
	g.dungeon = (d["dungeon"] as Dictionary).duplicate(true)
	g.dungeon_runs = int(d["dungeon_runs"])
	g.dungeon_mastered = _ints(d["dungeon_mastered"])
	for k in d["dungeon_streak"]:
		g.dungeon_streak[int(k)] = int(d["dungeon_streak"][k])
	g.void_depth = int(d["void_depth"])
	g.known = (d["known"] as Dictionary).duplicate(true)
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


static func _ints(list: Array) -> Array[int]:
	var out: Array[int] = []
	for v in list:
		out.append(int(v))
	return out
