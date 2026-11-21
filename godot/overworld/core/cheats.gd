class_name Cheats
extends RefCounted
## Developer cheats for testing the hub game. Each returns a short message for the cheat menu.


static func refill_ap(g: GameState) -> String:
	g.ap = g.max_ap()
	return "Day AP refilled."


static func add_lifespan(g: GameState, days: int) -> String:
	g.lifespan = maxi(1, g.lifespan + days)
	g.forced_trial = false
	return "Lifespan: %d days." % g.lifespan


static func last_day(g: GameState) -> String:
	g.lifespan = 1
	return "Lifespan set to 1 day: the next night forces the trial."


static func give_xp(g: GameState, amount: int) -> String:
	for m in g.roster:
		m.gain_xp(amount, g.stage)
	return "+%d XP for every monster." % amount


static func heal_all(g: GameState) -> String:
	for m in g.roster:
		m.heal_full()
	return "All monsters healed."


static func give_points(g: GameState, n: int) -> String:
	g.path_points += n
	return "+%d path points." % n


static func give_materials(g: GameState, n: int) -> String:
	for id in Materials.all_ids(g.values, int(g.stage)):
		g.add_item(id, n)
	return "+%d of every material up to this stage." % n
