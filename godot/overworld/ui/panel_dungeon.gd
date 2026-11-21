class_name DungeonPanel
extends HubPanel
## Dungeon Gate (docs/vision.md §6).


func title() -> String:
	return "Dungeon Gate"


func pillar() -> String:
	return "Tamer and kits"


func hint() -> String:
	return "A run for the whole day"


func build(into: VBoxContainer) -> void:
	into.add_child(HubUi.label("Not built yet."))
