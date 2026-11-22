class_name GameOverScreen
extends Control
## The end of a game (docs/vision.md §3): lost at the forced trial, or won against the Sovereign beast. The save is removed and
## the game is counted; a new game starts from the nest.

const NEW_GAME_SCENE := "res://overworld/new_game.tscn"
const MENU_SCENE := "res://game/menu.tscn"


func _ready() -> void:
	var game := GameSession.game
	var margin := HubUi.page(self)
	var center := CenterContainer.new()
	margin.add_child(center)
	var col := HubUi.col(16)
	col.custom_minimum_size = Vector2(900, 0)
	center.add_child(col)
	var won := game != null and game.outcome == GameState.WON
	col.add_child(HubUi.title("The Sovereign beast has fallen" if won else "Your lifespan has ended"))
	if game != null:
		var text := "You defeated the Sovereign beast in year %d, at %s. The game is won." % [game.day, Stage.stage_name(game.stage)] if won else \
			"You lost the breakthrough trial at the end of your lifespan, in year %d at %s. The game is lost." % [game.day, Stage.stage_name(game.stage)]
		col.add_child(HubUi.label(text, 22))
		var names: PackedStringArray = []
		for m in game.roster:
			names.append(m.title())
		col.add_child(HubUi.label("Your monsters: %s" % ", ".join(names)))
		SaveGame.record_end(game.outcome)
		var l := SaveGame.legacy()
		col.add_child(HubUi.dim("Games so far: %d won, %d lost. What a game leaves for the next one is not built yet." % [int(l["won"]), int(l["lost"])]))
	GameSession.game = null
	var row := HubUi.row()
	col.add_child(row)
	row.add_child(HubUi.button("Back to the nest: a new game", func(): get_tree().change_scene_to_file(NEW_GAME_SCENE), 360))
	row.add_child(HubUi.button("Main menu", func(): get_tree().change_scene_to_file(MENU_SCENE), 200))
