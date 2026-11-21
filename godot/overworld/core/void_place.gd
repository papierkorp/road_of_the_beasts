class_name VoidPlace
extends RefCounted
## The void (docs/vision.md §4): a ladder of battles against void monsters on the player's own battleground. A few
## depths per stage, each won once; every depth won gives a path point; the last depth is the breakthrough trial.
## At the end of the lifespan the trial is forced, and losing that one loses the game (docs/vision.md §3).


static func depths(game: GameState) -> int:
	return game.values.void_depths


## The depth the player stands before (0-based).
static func depth(game: GameState) -> int:
	return mini(game.void_depth, depths(game) - 1)


static func is_trial(game: GameState) -> bool:
	return game.forced_trial or game.void_depth >= depths(game) - 1


static func has_materials(game: GameState) -> bool:
	return game.count(Materials.breakthrough(int(game.stage))) >= game.values.trial_materials


## Why the player cannot enter now ("" = they can). The battleground itself is checked by the hub.
static func problem(game: GameState) -> String:
	if game.is_over() or DungeonRun.running(game):
		return "not now"
	if game.forced_trial:
		return ""                                   # ready or not
	if game.ap < game.values.void_ap:
		return "needs %d AP" % game.values.void_ap
	if is_trial(game) and not has_materials(game):
		return "the trial needs %d breakthrough material(s) of this stage, from the last battle of its dungeon" % game.values.trial_materials
	return ""


## The fight of the depth the player stands before; with a forced trial it is the trial at once.
static func fight(game: GameState) -> Fight:
	var v := game.values
	var d := depths(game) - 1 if is_trial(game) else depth(game)
	var rng := game.rng_for("void%d_%d" % [int(game.stage), d])
	var f := Fight.new()
	f.place = Fight.VOID
	f.stage = int(game.stage)
	f.title = "The breakthrough trial" if is_trial(game) else "Void, depth %d of %d" % [d + 1, depths(game)]
	f.own_map = game.battleground
	f.max_team = maxi(1, (game.battleground.get("start_a", []) as Array).size())
	var step := GameState.step_of(int(game.stage), 2) + GameValues.at(v.void_steps_above, d)
	f.enemies = Places.monsters(rng, maxi(1, GameValues.at(v.void_enemies, d)), step, MonsterInstance.Rarity.NORMAL, true)
	f.wild = true
	f.roll_seed = rng.randi_range(1, 1 << 30)
	f.ref = {"depth": d, "trial": is_trial(game), "forced": game.forced_trial}
	f.loot_text = "the next stage and its lifespan, a path point" if is_trial(game) else "a path point, monster XP"
	return f


static func pay(game: GameState) -> bool:
	if problem(game) != "":
		return false
	return true if game.forced_trial else game.spend_ap(game.values.void_ap)


static func resolve(game: GameState, f: Fight, result: BattleResult, won: bool) -> void:
	for m in Places.caught(f, result):
		if m.species().kin == MonsterDef.Kin.VOID:      # a creature of the void is never bound (docs/monsters.md §3)
			game.say("%s slipped back into the void: its kind cannot be bound." % m.species().display_name)
		elif game.add_monster(m):
			game.say("Caught: %s." % m.title())
	for m in game.roster:
		m.heal_full()
	if not won:
		if bool(f.ref.get("forced", false)):
			game.say("You lost the trial at the end of your lifespan.")
			game.lose()
		else:
			game.say("%s lost. The AP are spent; the depth waits." % f.title)
		return
	game.path_points += 1
	for line in game.award_xp(f.team, f.stage):
		game.say(line)
	if bool(f.ref.get("trial", false)):
		game.take_item(Materials.breakthrough(f.stage), mini(game.values.trial_materials, game.count(Materials.breakthrough(f.stage))))
		game.say("The trial is won: +1 path point.")
		game.break_through()
		var eggs := GameData.species_ids(true)              # the trophy of the trial: an egg of the void
		if not eggs.is_empty() and not game.is_over():
			var egg_rng := game.rng_for("void_egg%d" % f.stage)
			for i in maxi(1, game.vow_sum("void_eggs")):
				var egg: StringName = eggs[egg_rng.randi_range(0, eggs.size() - 1)]
				game.say("The void left an egg: %s." % GameData.monster(egg).display_name if game.add_egg(egg) else "The void left an egg, but your nest is full.")
	else:
		game.void_depth += 1
		game.say("%s won: +1 path point." % f.title)
