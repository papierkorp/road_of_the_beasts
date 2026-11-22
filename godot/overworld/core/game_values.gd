class_name GameValues
extends Resource
## Every test value of the hub game in one file: res://data/game/values.tres. None of them is a rule: the rule
## files say "not defined" for each (docs/vision.md, docs/overworld.md; tasks T54–T60). Change the .tres to try
## other numbers; arrays "per stage" count from Qi Gathering (0) to Sovereign (5).

const PATH := "res://data/game/values.tres"

@export_group("Day and lifespan (T54)")
## Day AP at the start of a day, per stage.
@export var day_ap: PackedInt32Array
## Days to live a stage grants when it is reached, per stage.
@export var lifespan_days: PackedInt32Array
## XP every fielded monster gets for a won battle, per stage of the place.
@export var xp_per_win: PackedInt32Array

@export_group("Start and roster (T59)")
## The pool the three eggs of the nest are drawn from, in the order the species join it: the first
## `egg_pool_start` from the first game on, `egg_pool_per_game` more for every finished game. No creature of the void.
@export var egg_pool: Array = []
@export var egg_pool_start := 0
@export var egg_pool_per_game := 0
@export var roster_cap := 0
## Nights an egg needs to hatch.
@export var egg_nights := 0

@export_group("Vows (T57)")
## Vows a game may hold at most; three are offered at the start and after every breakthrough.
@export var vow_cap := 0
@export var vow_offer := 0
## {"id", "name", "gain": text, "price": text, "effects": {key: value}}. The keys the build reads:
## gain: kin_choice (Kin: one more choice at a stage breakthrough), gift_all, slot_all, tamer_slots, dungeon_heal,
## wild_egg, ap, bg_budget, vein_weight, void_eggs. price: ban_kin (Kin), one_kin_team, team, no_weapons, no_pills,
## no_seal, lifespan, no_zones, no_props, no_wild_eggs.
@export var vows: Array = []

@export_group("Wild area (T55)")
@export var wild_encounters := 0
## Enemies per encounter, per stage: [least, most].
@export var wild_enemies: Array = []
## Each battle costs this many day AP.
@export var wild_ap := 1
## A rare encounter appears every `rare_every` days, is announced `rare_announce` days ahead and stays `rare_stays` days.
@export var rare_every := 0
@export var rare_announce := 0
@export var rare_stays := 0
## Chance in percent that a won wild battle also gives an egg of a defeated species (rare encounters: always).
@export var egg_chance := 0

@export_group("Dungeon (T55)")
## Nodes per layer; the last layer is the last battle.
@export var dungeon_layers: PackedInt32Array
## Enemies per node, per stage: [least, most]; the last battle fields one more.
@export var dungeon_enemies: Array = []
## Plants a won node gives; the last battle gives `dungeon_last_loot` more.
@export var dungeon_node_loot := 0
@export var dungeon_last_loot := 0
## Share of the loot kept after a defeat, in percent.
@export var dungeon_defeat_keeps := 0
## Layers (0-based) that hold a rest node beside the battles; a rest heals `rest_heal` HP per monster.
@export var dungeon_rest_layers: PackedInt32Array
@export var rest_heal := 0
## The challenge per stage: {"kind": "streak" (runs won in a row) | "rounds" (the last battle won within n rounds), "n": int}.
@export var dungeon_challenges: Array = []
## Plants a harvest gives.
@export var harvest_yield := 0
## A run costs this many day AP, a harvest `harvest_ap`.
@export var dungeon_ap := 0
@export var harvest_ap := 0

@export_group("Void and trial (T56)")
@export var void_depths := 0
@export var void_ap := 1
## Enemies per depth; the last entry is the trial.
@export var void_enemies: PackedInt32Array
## Steps of growth a void monster stands above the High sub-tier of the stage, per depth.
@export var void_steps_above: PackedInt32Array
## The Sovereign beast, the last depth of the void: how many void monsters and their step of growth (0–17).
@export var sovereign_enemies := 1
@export var sovereign_step := 17

@export_group("The player's battleground (T56)")
@export var bg_min_side := 0
@export var bg_max_side := 0
## Budget of a battleground, per stage.
@export var bg_budget: PackedInt32Array
## What a placed part counts toward the budget, by kind: ground, dragon_vein, prop, zone.
@export var bg_weights: Dictionary = {}
## Free squares the start area of the opponent needs at least.
@export var bg_enemy_starts := 0
## Parts the player owns from the start: part id -> number. A part id is "ground:<id>", "prop:<id>" or "zone:<id>".
@export var bg_start_parts: Dictionary = {}
## The battleground the player starts with, in the format of MapData ({} = none).
@export var bg_start_map: Dictionary = {}

@export_group("Battlegrounds of the places (T55)")
## {"id": map id, "stage": first stage it appears in, "mine": free squares of the player's start area, "theirs": of the enemy's}.
@export var battlegrounds: Array = []

@export_group("Crafting (T58)")
## Plants: {"id", "name", "stage"}: the stage whose dungeon first gives it.
@export var plants: Array = []
## Properties a plant can have: {"id", "name", "pill", "use": "battle" | "hub" | "dungeon"}.
@export var properties: Array = []
@export var properties_per_plant := 0
## Flaws a plant can have, one each: {"id", "name", "text"}. The build reads the ids volatile and bitter.
@export var flaws: Array = []
## The forge (docs/overworld.md §6.3), one entry per Kin of the beast part. What the first part makes:
## {"name", "text", "ground": id} or {"name", "text", "prop": id}.
@export var forge_what: Array = []
## How the piece acts, by the second part: {"name", "text", "count": squares in a straight line, "uses": per battle}.
@export var forge_how: Array = []


static var _shared: GameValues


static func shared() -> GameValues:
	if _shared == null:
		_shared = load(PATH) as GameValues
	return _shared


static func at(list: PackedInt32Array, stage: int) -> int:
	return 0 if list.is_empty() else list[clampi(stage, 0, list.size() - 1)]


## An entry of a per-stage array of [least, most] pairs or of dictionaries; the last entry holds for later stages.
static func entry(list: Array, stage: int) -> Variant:
	return null if list.is_empty() else list[clampi(stage, 0, list.size() - 1)]
