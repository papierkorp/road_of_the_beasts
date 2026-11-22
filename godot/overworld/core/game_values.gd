class_name GameValues
extends Resource
## Every test value of the hub game in one file: res://data/game/values.tres. None of them is a rule: the rule
## files say "not defined" or "working value" for each (docs/vision.md, docs/overworld.md; tasks T54–T64). Change the
## .tres to try other numbers; arrays "per stage" count from Qi Gathering (0) to Immortal (4).

const PATH := "res://data/game/values.tres"

@export_group("Lifespan (T65)")
## Years to live a stage grants when it is reached, per stage: the stock every deed is paid from.
@export var lifespan_years: PackedInt32Array
## What a deed costs in years: a battle of the wild, a new look at the wild, an attack on the void.
@export var wild_years := 1
@export var reroll_years := 1
@export var void_years := 1
## Boons, one taken at every breakthrough: {"id", "name", "text", "effects": {lifespan | tamer_slots | carry | wild_offer: number}}.
@export var boons: Array = []

@export_group("Start and roster (T59)")
## The pool the three eggs of the nest are drawn from, in the order the species join it: the first
## `egg_pool_start` from the first game on, `egg_pool_per_game` more for every finished game. No creature of the void.
@export var egg_pool: Array = []
@export var egg_pool_start := 0
@export var egg_pool_per_game := 0
@export var roster_cap := 0
## Battles fought until an egg hatches.
@export var egg_battles := 0

@export_group("Vows (T57)")
## Vows a game may hold at most; three are offered at the start and after every breakthrough.
@export var vow_cap := 0
@export var vow_offer := 0
## {"id", "name", "gain": text, "price": text, "effects": {key: value}}. The keys the build reads:
## "way": the id of the one Way it is offered in, or "" for every Way.
## gain: kin_choice (Kin: one more choice at a stage breakthrough), slot_all, tamer_slots, drop (one more unit of the
## reward of the Way per wild battle), egg_chance (percent), bg_budget, vein_weight, void_eggs. price: ban_kin (Kin),
## one_kin_team, team, no_seal, lifespan, no_wild_eggs, no_zones, no_props.
@export var vows: Array = []

@export_group("Wild (T65)")
## Battles a look at the wild shows.
@export var wild_offer := 3
## Monsters of a wild battle, per stage: [least, most]. The first battle of a look has the least, all Lower.
@export var wild_enemies: Array = []
## The Formation gains 1 Insight from a wild battle against at least this many monsters.
@export var wild_insight_from := 2
## Parts a wild battle may drop for the Artificer: {"part": part id, "stage": the first stage it drops in}.
@export var drop_parts: Array = []
## Chance in percent that a wild battle holds an egg of one of its species.
@export var egg_chance := 0
## Free squares of the start area of each side on a generated battleground.
@export var team_room := 3

@export_group("Void and trial (T56)")
@export var void_depths := 0
## Enemies per depth; the last entry is the trial.
@export var void_enemies: PackedInt32Array
## Steps of growth a void monster stands above the High sub-tier of the stage, per depth.
@export var void_steps_above: PackedInt32Array
## The Sovereign beast, the last depth of the void: how many void monsters, their step of growth (0–14) and the
## stat points they have beyond that step.
@export var sovereign_enemies := 1
@export var sovereign_step := 14
@export var sovereign_bonus_points := 0

@export_group("The Artificer: parts and the own battleground (T56, T64)")
## Parts laid before each battle of the wild: the base and what every stage adds.
@export var carry_base := 0
@export var carry_per_stage := 0
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

@export_group("Generated battlegrounds (T55)")
## What the generator lays as mirrored pairs: {"id", "stage": the first stage it appears in}.
@export var gen_grounds: Array = []
@export var gen_props: Array = []
@export var gen_zones: Array = []

@export_group("Pills (T58)")
## A tempering pill gives this many stat points, and a monster takes at most `pill_points_cap` of them. The Alchemist
## starts with this many Binding pills.
@export var pill_points := 0
@export var pill_points_cap := 0
@export var alchemist_start_pills := 0
## The gift of the start (docs/vision.md §5): how many are offered, and the packs of parts of the Artificer:
## {"id", "name", "parts": part id -> number}. The Formation is offered tamer skills of its first tree, the
## Alchemist `alchemist_start_pills` pills of a kind taken in a battle.
@export var start_offer := 3
@export var start_packs: Array = []
## The kinds of pill: {"id", "name", "pill": what it does, "use": "battle" (with "skill": the tamer skill it brings) | "hub"}.
@export var properties: Array = []


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
