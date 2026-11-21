class_name TrainingPanel
extends HubPanel
## Training Ground (docs/vision.md §6).


func title() -> String:
	return "Training Ground"


func pillar() -> String:
	return "Monster: growth"


func hint() -> String:
	return "Spend stat points"


func build(into: VBoxContainer) -> void:
	into.add_child(HubUi.label("Not built yet."))
