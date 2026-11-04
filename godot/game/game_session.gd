extends Node
## Hand-over point between the parts of the game (replaces the static variables of BattleSetup).
## Whoever starts a battle (draft screen, the overworld) puts a BattleRequest here and changes
## scene; the battle scene reads it and leaves its BattleResult here.
## The request stays after the battle so "Fight Again" fights the same teams again.

## Emitted when something outside a screen changed the running game (the F10 cheat menu).
signal state_changed

var request: BattleRequest = null
var last_result: BattleResult = null
## Scene the battle returns to when it is over ("" = back to the main menu).
var return_scene := ""
## Let the AI play both sides (headless smoke tests: --autoplay).
var autoplay := false

## The running game (null in the plain battle prototype) and its current dungeon run.
var game: GameState = null
var expedition: Expedition = null


func start_battle(r: BattleRequest, return_to := "") -> void:
	request = r
	last_result = null
	return_scene = return_to
