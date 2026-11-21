class_name ForgePanel
extends HubPanel
## Forge (docs/vision.md §6).


func title() -> String:
	return "Forge"


func pillar() -> String:
	return "Tamer and kits"


func hint() -> String:
	return "Forge weapons and armour"


func build(into: VBoxContainer) -> void:
	into.add_child(HubUi.label("Not built yet."))
