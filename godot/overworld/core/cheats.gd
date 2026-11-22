class_name Cheats
extends RefCounted
## Developer cheats for testing the hub game. Each returns a short message for the cheat menu.


static func add_lifespan(g: GameState, days: int) -> String:
	g.lifespan = maxi(1, g.lifespan + days)
	g.forced_trial = false
	return "Lifespan: %d years." % g.lifespan


static func last_day(g: GameState) -> String:
	g.lifespan = 1
	return "Lifespan set to 1 year: the next battle forces the trial."


## Every monster rises a step, as far as the tamer's stage allows.
static func rise_all(g: GameState) -> String:
	var n := 0
	for m in g.roster:
		if g.lift(m):
			n += 1
	return "%d monster(s) rose a step." % n


static func heal_all(g: GameState) -> String:
	for m in g.roster:
		m.heal_full()
	return "All monsters healed."


static func give_points(g: GameState, n: int) -> String:
	g.path_points += n
	return "+%d Insight." % n


## The reward of the Way as a wild battle against `n` monsters would drop it.
static func give_drop(g: GameState, n: int) -> String:
	Wild._hand_out(g, Wild._drop(g, g.rng_for("cheat%d" % g.messages.size()), int(g.stage), n))
	return g.messages[-1]


## The tamer rises a stage as if the trial were passed.
static func stage_up(g: GameState) -> String:
	if int(g.stage) >= int(Stage.Type.IMMORTAL):
		return "Already at the last stage: only the Sovereign beast is left."
	g.break_through()
	return "You are now at %s." % Stage.stage_name(g.stage)


## Every monster grows to the first step of the next stage, as far as the tamer's stage allows.
static func monsters_stage_up(g: GameState) -> String:
	var n := 0
	for m in g.roster:
		var before := int(m.stage)
		for i in 3:
			if int(m.stage) == before:
				g.lift(m)
		if int(m.stage) > before:
			n += 1
	return "%d monster(s) rose a stage." % n if n > 0 else "No monster can rise: they never pass your stage."
