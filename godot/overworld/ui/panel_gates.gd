class_name GatesPanel
extends HubTabs
## Gates (docs/vision.md §4): the three places a battle is fought in, and so the three ways to spend day AP.


func title() -> String:
	return "Gates"


func pillar() -> String:
	return "Battles: where day AP go"


func hint() -> String:
	return "Wild area · Dungeon · Void\n%d day AP left" % game.ap


func tabs() -> Array:
	return [[&"wild", "Wild area (%d AP)" % game.values.wild_ap, WildPanel], [&"dungeon", "Dungeon (all AP)", DungeonPanel],
		[&"void", "Void (%d AP)" % game.values.void_ap, VoidPanel]]


func tab() -> StringName:
	if game.forced_trial:
		return &"void"
	if not game.dungeon.is_empty():
		return &"dungeon"
	return super.tab()


func tab_locked(tab_id: StringName) -> bool:
	return tab_id != tab() and (game.forced_trial or not game.dungeon.is_empty())
