class_name CauldronPanel
extends HubPanel
## Cauldron (docs/vision.md §6).


func title() -> String:
	return "Cauldron"


func pillar() -> String:
	return "Tamer"


func hint() -> String:
	return "Brew pills from plants"


func build(into: VBoxContainer) -> void:
	into.add_child(HubUi.label("Not built yet."))
