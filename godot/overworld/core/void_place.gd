class_name VoidPlace
extends RefCounted
## The void (docs/vision.md §4): a ladder of battles against void monsters on the player's own battleground. A few
## depths per stage, each won once; every depth won gives one Insight; the last depth is the breakthrough trial.
## At the end of the lifespan the trial is forced, and losing that one loses the game (docs/vision.md §3).
##
## The Sovereign beast (docs/vision.md §3) is the last depth of the void: drawn when the game starts, shown from the
## first day, and open to an attack on any day. It is the trial of the last stage; who defeats it has won.

const LAST_STAGE := Stage.Type.IMMORTAL


static func depths(game: GameState) -> int:
	return game.values.void_depths


## The depth the player stands before (0-based).
static func depth(game: GameState) -> int:
	return mini(game.void_depth, depths(game) - 1)


static func is_trial(game: GameState) -> bool:
	return game.forced_trial or game.void_depth >= depths(game) - 1


## Whether the trial of this stage is the Sovereign beast.
static func trial_is_sovereign(game: GameState) -> bool:
	return int(game.stage) >= int(LAST_STAGE)


## Why the player cannot enter now ("" = they can). The battleground itself is checked by the hub.
static func problem(game: GameState) -> String:
	if game.is_over() or DungeonRun.running(game):
		return "not now"
	if game.forced_trial:
		return ""                                   # ready or not
	if game.ap < game.values.void_ap:
		return "needs %d AP" % game.values.void_ap
	return ""


static func _fight(game: GameState) -> Fight:
	var f := Fight.new()
	f.place = Fight.VOID
	f.stage = int(game.stage)
	f.own_map = game.battleground
	f.max_team = maxi(1, (game.battleground.get("start_a", []) as Array).size())
	f.wild = true
	return f


## The fight of the depth the player stands before; with a forced trial it is the trial at once. The void monsters
## of a depth are drawn from the game's seed: another game meets others (docs/vision.md §4).
static func fight(game: GameState) -> Fight:
	if is_trial(game) and trial_is_sovereign(game):
		return sovereign(game)
	var v := game.values
	var d := depths(game) - 1 if is_trial(game) else depth(game)
	var rng := game.rng_for("void%d_%d" % [int(game.stage), d])
	var f := _fight(game)
	f.title = "The breakthrough trial" if is_trial(game) else "Void, depth %d of %d" % [d + 1, depths(game)]
	var step := GameState.step_of(int(game.stage), 2) + GameValues.at(v.void_steps_above, d)
	f.enemies = Places.monsters(rng, maxi(1, GameValues.at(v.void_enemies, d)), step, MonsterInstance.Bloodline.MORTAL, true)
	f.roll_seed = rng.randi_range(1, 1 << 30)
	f.ref = {"depth": d, "trial": is_trial(game), "forced": game.forced_trial}
	f.loot_text = "the next stage and its lifespan, one Insight" if is_trial(game) else "one Insight, monster XP"
	return f


## The Sovereign beast of this game: the same from the first day on.
static func sovereign(game: GameState) -> Fight:
	var v := game.values
	var rng := game.rng_for("sovereign")
	var f := _fight(game)
	f.title = "The Sovereign beast"
	f.enemies = Places.monsters(rng, maxi(1, v.sovereign_enemies), v.sovereign_step, MonsterInstance.Bloodline.DIVINE, true)
	f.roll_seed = rng.randi_range(1, 1 << 30)
	f.ref = {"sovereign": true, "forced": game.forced_trial and trial_is_sovereign(game)}
	f.loot_text = "you become Sovereign: the game is won"
	return f


static func pay(game: GameState) -> bool:
	if problem(game) != "":
		return false
	return true if game.forced_trial else game.spend_ap(game.values.void_ap)


## Paying for an attack on the Sovereign beast before its time: day AP like a depth.
static func pay_sovereign(game: GameState) -> bool:
	if trial_is_sovereign(game) and is_trial(game):
		return pay(game)
	if game.is_over() or DungeonRun.running(game) or game.forced_trial:
		return false
	return game.spend_ap(game.values.void_ap)


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
			game.say("%s lost. The AP are spent; %s." % [f.title, "it waits" if f.ref.has("sovereign") else "the depth waits"])
		return
	if f.ref.has("sovereign"):
		game.win()
		return
	game.path_points += 1
	for line in game.award_xp(f.team, f.stage):
		game.say(line)
	if bool(f.ref.get("trial", false)):
		game.say("The trial is won: +1 Insight.")
		game.break_through()
		var eggs := GameData.species_ids(true)              # the trophy of the trial: an egg of the void
		if not eggs.is_empty() and not game.is_over():
			var egg_rng := game.rng_for("void_egg%d" % f.stage)
			for i in maxi(1, game.vow_sum("void_eggs")):
				var egg: StringName = eggs[egg_rng.randi_range(0, eggs.size() - 1)]
				game.say("The void left an egg: %s." % GameData.monster(egg).display_name if game.add_egg(egg) else "The void left an egg, but your nest is full.")
	else:
		game.void_depth += 1
		game.say("%s won: +1 Insight." % f.title)
