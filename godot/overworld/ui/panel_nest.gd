class_name NestPanel
extends HubPanel
## Nest (docs/vision.md §6).


func title() -> String:
	return "Nest"


func pillar() -> String:
	return "Monster: roster"


func hint() -> String:
	return "Your monsters and eggs"


func build(into: VBoxContainer) -> void:
	into.add_child(HubUi.label("Not built yet."))
