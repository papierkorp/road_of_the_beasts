class_name ContentStatus
extends RefCounted
## How far a content Resource is: one shared scale for everything under res://data.
##   approved    released game content (none exists yet; T10–T12 are open)
##   draft       GDD draft or test content the game currently plays with
##   test        exists only for automated tests; the game never fields it
##   simulation  exists only for simulation runs (test monsters and their skills); the game
##               never fields it
##   archived    kept for reference but no longer used; neither the game nor the default lists
##               of the tools offer it
## The scale is a label for people and for the one filter below; it approves nothing by itself.

const APPROVED := "approved"
const DRAFT := "draft"
const TEST := "test"
const SIMULATION := "simulation"
const ARCHIVED := "archived"


## True if the game itself may use the Resource (approved or draft). THE filter: GameData and
## BattleContent call it, nothing else decides what the game sees. Definitions without the
## field (grounds, props, zones, tamer skills) are game content.
static func in_game(res: Resource) -> bool:
	if res == null:
		return false
	var value = res.get("content_status")
	return not (value is String and (value == TEST or value == SIMULATION or value == ARCHIVED))
