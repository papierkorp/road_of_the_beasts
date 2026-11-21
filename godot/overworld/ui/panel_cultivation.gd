class_name CultivationPanel
extends HubPanel
## Cultivation Hall (docs/vision.md §6).


func title() -> String:
	return "Cultivation Hall"


func pillar() -> String:
	return "Tamer and board"


func hint() -> String:
	return "Spend path points in your tree"


func build(into: VBoxContainer) -> void:
	into.add_child(HubUi.label("Not built yet."))
