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
## What the map editor edits when the hub opened it (BattlegroundJob); null = the editor of the prototype.
var editor_job: BattlegroundJob = null


func map_summary(f: Fight) -> String:
	return MapData.summary(FightBridge.map_of(f), BattleContent.shared())


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
