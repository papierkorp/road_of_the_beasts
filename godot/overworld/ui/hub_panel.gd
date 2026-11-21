class_name HubPanel
extends RefCounted
## One building of the hub (docs/vision.md §6). `build` fills the column the hub gives it; after every deed the panel
## calls `hub.refresh()` and is built anew.

var hub: HubScreen
## The id of the building this panel was opened as.
var id: StringName = &""
var game: GameState


func title() -> String:
	return ""


## What the player does here, shown on the button of the building.
func hint() -> String:
	return ""


func pillar() -> String:
	return ""


func build(_into: VBoxContainer) -> void:
	pass
