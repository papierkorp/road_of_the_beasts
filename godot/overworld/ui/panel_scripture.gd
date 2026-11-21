class_name ScripturePanel
extends HubPanel
## Scripture Hall (docs/vision.md §6).


func title() -> String:
	return "Scripture Hall"


func pillar() -> String:
	return "Monster: kit"


func hint() -> String:
	return "Kits and skill development"


func build(into: VBoxContainer) -> void:
	into.add_child(HubUi.label("Not built yet."))
