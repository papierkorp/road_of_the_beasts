class_name Cheats
extends RefCounted
## Developer cheats for testing the hub game. Each returns a short message for the cheat menu.


static func refill_ap(g: GameState) -> String:
	g.ap = g.max_ap()
	return "AP refilled."


static func add_lifespan(g: GameState, days: int) -> String:
	g.lifespan = maxi(1, g.lifespan + days)
	g.forced_trial = false
	return "Lifespan: %d years." % g.lifespan


static func last_day(g: GameState) -> String:
	g.lifespan = 1
	return "Lifespan set to 1 year: the end of this year forces the trial."


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
	return "+%d Insight." % n


static func give_materials(g: GameState, n: int) -> String:
	for id in Materials.all_ids(g.values, int(g.stage)):
		g.add_item(id, n)
	return "+%d of every material up to this stage." % n


## The tamer rises a stage as if the trial were passed.
static func stage_up(g: GameState) -> String:
	if int(g.stage) >= int(Stage.Type.SOVEREIGN):
		return "Already at the last stage."
	g.break_through()
	return "You are now at %s." % Stage.stage_name(g.stage)


## Every monster grows to the first step of the next stage, as far as the tamer's stage allows.
static func monsters_stage_up(g: GameState) -> String:
	var n := 0
	for m in g.roster:
		var before := int(m.stage)
		for i in 3:
			if int(m.stage) == before and m.step() < MonsterInstance.STEPS - 1:
				m.gain_xp(MonsterInstance.XP_STEPS[m.step()] - m.xp, g.stage)
		if int(m.stage) > before:
			n += 1
	return "%d monster(s) rose a stage." % n if n > 0 else "No monster can rise: they never pass your stage."
