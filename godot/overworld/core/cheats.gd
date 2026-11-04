class_name Cheats
extends RefCounted
## Developer shortcuts on a GameState (used by the F10 cheat menu). Headless and testable.


static func give_money(state: GameState, amount: int) -> String:
	state.add_money(amount)
	return "+%d spirit stones" % amount


static func give_pills(state: GameState, count: int) -> String:
	state.add_item(ItemCatalog.pill_id(int(state.stage)), count)
	return "+%d %s" % [count, ItemCatalog.display_name(ItemCatalog.pill_id(int(state.stage)))]


## `count` of every material of the player's tier.
static func give_materials(state: GameState, count: int) -> String:
	var ids := ItemCatalog.materials_of_tier(int(state.stage))
	for id in ids:
		state.add_item(id, count)
	return "+%d of each of %d materials" % [count, ids.size()]


static func give_xp(state: GameState, amount: int) -> String:
	var ups := 0
	for m in state.monsters:
		ups += m.add_xp(amount)
	return "+%d XP for every monster (%d sub-tier up(s))" % [amount, ups]


static func give_blueprints(state: GameState) -> String:
	var n := 0
	for sid in StructureCatalog.ids():
		if not state.has_blueprint(sid):
			state.add_item(ItemCatalog.blueprint_id(sid))
			n += 1
	return "+%d blueprints (all known)" % n


static func stage_up(state: GameState) -> String:
	if int(state.stage) >= int(Stage.Type.SOVEREIGN):
		return "Already at the highest stage"
	state.advance_stage()
	for m in state.monsters:
		if int(m.stage) < int(state.stage):
			m.break_through()
	return "Stage up: %s (monsters follow)" % Stage.stage_name(state.stage)


static func refill_ap(state: GameState) -> String:
	state.ap = state.max_ap
	return "AP refilled (%d)" % state.ap


static func heal_all(state: GameState) -> String:
	for m in state.monsters:
		m.heal_full()
	return "All monsters healed"


static func next_day(state: GameState) -> String:
	var report := state.end_day()
	return "Day %d (market moved)" % report["day"]
