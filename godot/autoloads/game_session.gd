extends Node
## Hand-over point between the parts of the game (replaces the static variables of BattleSetup).
## Whoever starts a battle (draft screen, later the overworld) puts a BattleRequest here and
## changes scene; the battle scene reads it and leaves its BattleResult here.
## The request stays after the battle so "Restart" fights the same teams again.

var request: BattleRequest = null
var last_result: BattleResult = null
## Let the AI play both sides (headless smoke tests: --autoplay).
var autoplay := false


func start_battle(r: BattleRequest) -> void:
	request = r
	last_result = null
