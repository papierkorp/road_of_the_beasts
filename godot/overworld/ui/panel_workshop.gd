class_name WorkshopPanel
extends HubPanel
## Battleground Workshop (docs/vision.md §6).


func title() -> String:
	return "Battleground Workshop"


func pillar() -> String:
	return "Board"


func hint() -> String:
	return "Build and shape your battleground"


func build(into: VBoxContainer) -> void:
	into.add_child(HubUi.label("Not built yet."))
