extends Node
## Hand-over point between the parts of the game (replaces the static variables of BattleSetup).
## Whoever starts a battle (draft screen, the overworld) puts a BattleRequest here and changes
## scene; the battle scene reads it and leaves its BattleResult here.
## The request stays after the battle so "Fight Again" fights the same teams again.

var request: BattleRequest = null
var last_result: BattleResult = null
## Scene the battle returns to when it is over ("" = back to the main menu).
var return_scene := ""
## Let the AI play both sides (headless smoke tests: --autoplay).
var autoplay := false


## Emitted when something outside a screen changed the running game (the cheat menu).
@warning_ignore("unused_signal")
signal state_changed

const HUB_SCENE := "res://overworld/hub.tscn"
const BATTLE_SCENE := "res://battle/battle.tscn"

## The running game of the hub game (null in the plain battle modes), the fight it sent into the battle scene and
## the building the hub shows when the player comes back.
var game: GameState = null
var fight: Fight = null
var hub_panel: StringName = &""
## The open tab of a building with several parts: building id -> tab id.
var hub_tabs := {}
## What the map editor edits when the hub opened it (BattlegroundJob); null = the editor of the prototype.
var editor_job: BattlegroundJob = null


## The battle content with the forged weapons of the running game in it (the screen that prepares a fight).
func battle_content() -> BattleContent:
	Forged.ensure(game.values if game != null else GameValues.shared())
	return BattleContent.shared()


func map_summary(f: Fight) -> String:
	return MapData.summary(FightBridge.map_of(f), BattleContent.shared())


const EDITOR_SCENE := "res://battle/ingame/map_editor.tscn"


## The limits of the player's own battleground for the running game (test values, T56).
func _job() -> BattlegroundJob:
	var v := game.values
	var job := BattlegroundJob.new()
	job.map = MapData.from_dict(game.battleground)
	job.parts = game.parts.duplicate()
	job.budget = GameValues.at(v.bg_budget, int(game.stage)) + game.vow_sum("bg_budget")
	job.weights = v.bg_weights.duplicate()
	if game.vow_has("vein_weight"):
		job.weights["dragon_vein"] = game.vow_sum("vein_weight")
	for pair: Array in [["no_zones", "zone"], ["no_props", "prop"]]:
		if game.vow_has(pair[0]):
			job.banned.append(pair[1])
	job.min_side = v.bg_min_side
	job.max_side = v.bg_max_side
	job.enemy_starts = v.bg_enemy_starts
	job.return_scene = HUB_SCENE
	if game.battleground.is_empty():
		job.map.width = v.bg_min_side + 1
		job.map.height = v.bg_min_side + 1
	return job


## Opens the map editor on the player's battleground; `take_battleground` reads it back in the hub.
func edit_battleground() -> void:
	editor_job = _job()
	get_tree().change_scene_to_file(EDITOR_SCENE)


## Called by the hub when it is shown: a battleground saved in the editor becomes the player's.
func take_battleground() -> void:
	if editor_job != null and editor_job.saved and game != null:
		game.battleground = MapData.to_dict(editor_job.map)
		game.say("Your battleground is saved.")
	editor_job = null


## What keeps the player's battleground from being used in the void ([] = legal).
func battleground_problems() -> PackedStringArray:
	if game == null or game.battleground.is_empty():
		return PackedStringArray(["you have not built a battleground yet"])
	var job := _job()
	return job.problems(job.map, BattleContent.shared())


func battleground_summary() -> String:
	if game == null or game.battleground.is_empty():
		return "none yet"
	var job := _job()
	return "%s · budget %d / %d" % [MapData.summary(job.map, BattleContent.shared()), job.cost(job.map), job.budget]


## The name of a part of a battleground ("ground:lava" -> "Lava (ground)").
func part_name(part: String) -> String:
	var kind := part.get_slice(":", 0)
	var id := StringName(part.get_slice(":", 1))
	var c := BattleContent.shared()
	var def: Resource = c.ground(id) if kind == "ground" else (c.prop(id) if kind == "prop" else c.zone(id))
	return "%s (%s)" % [def.get("display_name") if def != null else String(id), kind]


## Games that were played to their end, won or lost (what a game leaves behind: the pool of eggs grows).
func finished_games() -> int:
	var l := SaveGame.legacy()
	var n := 0
	for key in l:
		if l[key] is float or l[key] is int:
			n += int(l[key])
	return n


## What a skill does, as the battle shows it on its card: generated from the record, never from its free text
## (the description fields of the data are partly older than the rules).
func skill_text(s: BattleSkillDef) -> String:
	var parts: PackedStringArray = []
	for r: Array in BattleText.skill_rows(BattleContent.shared(), s):
		parts.append("%s: %s" % [r[0], r[1]] if String(r[0]) != "" else String(r[1]))
	return "   ·   ".join(parts)


## Sends a fight into the battle scene; the hub reads `last_result` when the scene comes back.
func start_fight(f: Fight) -> void:
	BattleExperiment.reset()                 # the ingame battle plays none of the switches of the multiplayer draft
	fight = f
	start_battle(FightBridge.request_of(f), HUB_SCENE)
	get_tree().change_scene_to_file(BATTLE_SCENE)


func start_battle(r: BattleRequest, return_to := "") -> void:
	request = r
	last_result = null
	return_scene = return_to
