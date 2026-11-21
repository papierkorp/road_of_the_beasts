class_name WildPanel
extends HubPanel
## Wild Gate (docs/vision.md §6).


func title() -> String:
	return "Wild Gate"


func pillar() -> String:
	return "Monster: roster"


func hint() -> String:
	return "Single battles for day AP; catch monsters"


func build(into: VBoxContainer) -> void:
	into.add_child(HubUi.label("Not built yet."))
