class_name GatesPanel
extends HubTabs
## Gates (docs/vision.md §4): the two places a battle is fought in. Every battle costs a year of the lifespan.


func title() -> String:
	return "Gates"


func pillar() -> String:
	return "Where the years go"


func hint() -> String:
	return "A battle in the wild, or an attack on the void"


func tabs() -> Array:
	return [[&"wild", "Wild", WildPanel], [&"void", "Void", VoidPanel]]


func tab() -> StringName:
	if game.forced_trial:
		return &"void"
	return super.tab()


func tab_locked(tab_id: StringName) -> bool:
	return tab_id != tab() and game.forced_trial
