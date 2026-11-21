class_name VoidPanel
extends HubPanel
## Void Gate (docs/vision.md §6).


func title() -> String:
	return "Void Gate"


func pillar() -> String:
	return "Tamer and board"


func hint() -> String:
	return "Depths on your own battleground; the trial"


func build(into: VBoxContainer) -> void:
	into.add_child(HubUi.label("Not built yet."))
