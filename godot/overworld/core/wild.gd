class_name Wild
extends RefCounted
## The wild (docs/vision.md §4): a few battles shown at once, each with its battleground, its wild monsters and what
## a win drops. The player picks one; a battle costs a year of the lifespan, won or lost. A battle won leaves the
## look; a new look at the wild costs a year too. Wild monsters are caught here.
##
## A battle won drops the reward of the Way (parts for the Artificer, pills for the Alchemist, Insight for the
## Formation) and leaves rises: every wild monster defeated lifts one monster of the team that still stands and is
## at its step or below, one step, never past High. Where the rises do not reach for all, the player chooses.
##
## The look lives in `GameState.wild_roll` (its number, the seed of its battles) and `wild_gone` (those won).

const INSIGHT := "insight"


static func can_fight(game: GameState) -> bool:
	return not game.is_over() and not game.forced_trial and game.lifespan > 0


## How many battles a look shows.
static func shown(game: GameState) -> int:
	return maxi(1, game.values.wild_offer + game.vow_sum("wild_offer"))


## The battles of the look the player has now: {"id", "map" (a generated battleground, MapGen), "mine", "enemies",
## "drop": what a win gives (INSIGHT, "pill:<property>" or a part id -> number), "egg": a species or ""}. The first
## one is the easiest: the fewest monsters, all at the lowest step of the stage.
static func offers(game: GameState) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var v := game.values
	var stage := int(game.stage)
	var rng := game.rng_for("wild%d_%d" % [stage, game.wild_roll])
	var pair: Array = GameValues.entry(v.wild_enemies, stage)
	for i in shown(game):
		var count := int(pair[0]) if i == 0 else rng.randi_range(int(pair[0]), int(pair[1]))
		count = clampi(count, 1, v.team_room + 1)
		var enemies: Array[MonsterInstance] = []
		for e in count:
			enemies.append_array(Places.monsters(rng, 1, GameState.step_of(stage, 0 if i == 0 else rng.randi_range(0, 2))))
		var egg := ""
		if rng.randi_range(1, 100) <= v.egg_chance + game.vow_sum("egg_chance") and not game.vow_has("no_wild_eggs"):
			egg = String(enemies[rng.randi_range(0, enemies.size() - 1)].species_id)
		out.append({"id": i, "mine": v.team_room, "enemies": enemies, "egg": egg,
			"map": MapGen.generate(rng, v, stage, v.team_room, maxi(v.team_room, count)),
			"drop": _drop(game, rng, stage, count)})
	return out


## The reward of the Way for a battle against `count` monsters: one unit per monster.
static func _drop(game: GameState, rng: RandomNumberGenerator, stage: int, count: int) -> Dictionary:
	var v := game.values
	var out := {}
	var n := count + game.vow_sum("drop") + game.node_sum("drop")
	match game.system:
		GameState.ALCHEMIST:
			for i in n:
				var p: Dictionary = v.properties[rng.randi_range(0, v.properties.size() - 1)]
				var item := Materials.pill(StringName(p["id"]))
				out[item] = int(out.get(item, 0)) + 1
		GameState.ARTIFICER:
			var pool: Array[String] = []
			for p: Dictionary in v.drop_parts:
				if int(p["stage"]) <= stage and not Crafting.part_banned(game, String(p["part"])):
					pool.append(String(p["part"]))
			if not pool.is_empty():
				out[pool[rng.randi_range(0, pool.size() - 1)]] = n
		GameState.FORMATION:
			if count >= v.wild_insight_from:
				out[INSIGHT] = 1 + game.vow_sum("drop")
	return out


## What a battle gives, as text.
static func drop_text(game: GameState, offer: Dictionary) -> String:
	var parts: PackedStringArray = []
	var drop: Dictionary = offer["drop"]
	for id: String in drop:
		if id == INSIGHT:
			parts.append("%d Insight" % int(drop[id]))
		elif Materials.form(id) == "pill":
			parts.append("%s ×%d" % [Materials.display_name(id, game.values), int(drop[id])])
		else:
			parts.append("%d × %s" % [int(drop[id]), Materials.part_name(id)])
	if String(offer["egg"]) != "":
		parts.append("an egg: %s" % GameData.monster(StringName(offer["egg"])).display_name)
	parts.append("a rise per monster defeated")
	return ", ".join(parts)


## The battles still open in the look.
static func open(game: GameState) -> Array[Dictionary]:
	return offers(game).filter(func(o: Dictionary) -> bool: return not game.wild_gone.has(int(o["id"])))


static func fight_for(game: GameState, id: int) -> Fight:
	if not can_fight(game) or game.wild_gone.has(id):
		return null
	var all := offers(game)
	if id < 0 or id >= all.size():
		return null
	var o := all[id]
	var f := Fight.new()
	f.place = Fight.WILD
	f.stage = int(game.stage)
	f.title = "Wild battle"
	f.own_map = o["map"]
	f.max_team = int(o["mine"])
	f.enemies = o["enemies"]
	f.wild = true
	f.carry = game.carry()
	f.roll_seed = hash([game.game_seed, "wild_roll", game.wild_roll, id]) & 0x3FFFFFFF
	f.ref = {"offer": id, "drop": o["drop"], "egg": o["egg"]}
	f.loot_text = drop_text(game, o)
	return f


## A new look at the wild: other battles, for a year of the lifespan.
static func reroll(game: GameState) -> bool:
	if not can_fight(game):
		return false
	game.wild_roll += 1
	game.wild_gone.clear()
	game.say("You look for other battles in the wild: a year passes.")
	game.spend(game.values.reroll_years)
	return true


static func resolve(game: GameState, f: Fight, result: BattleResult, won: bool) -> void:
	for m in Places.caught(f, result):
		if game.add_monster(m):
			game.say("Caught: %s." % m.title())
	drop_rises(game)
	if won:
		_hand_out(game, f.ref.get("drop", {}))
		var egg := String(f.ref.get("egg", ""))
		if egg != "":
			game.say("The battle left an egg: %s." % GameData.monster(StringName(egg)).display_name if game.add_egg(StringName(egg)) else "The battle left an egg, but your nest is full.")
		game.wild_gone.append(int(f.ref["offer"]))
		if open(game).is_empty():                    # every battle of the look is won: the wild shows new ones
			game.wild_roll += 1
			game.wild_gone.clear()
		for e in f.enemies:
			game.rises.append(e.step())
		for m in f.team:
			m.may_rise = m.current_hp > 0
		_give_all_if_no_choice(game)
	else:
		game.say("The wild battle is lost. It waits; the year is spent.")
	game.spend(game.values.wild_years)


static func _hand_out(game: GameState, drop: Dictionary) -> void:
	var got: PackedStringArray = []
	for id: String in drop:
		var n := int(drop[id])
		if id == INSIGHT:
			game.path_points += n
			got.append("%d Insight" % n)
		elif Materials.form(id) == "pill":
			game.add_item(id, n)
			got.append("%s ×%d" % [Materials.display_name(id, game.values), n])
		else:
			game.parts[id] = int(game.parts.get(id, 0)) + n
			got.append("%d × %s" % [n, Materials.part_name(id)])
	game.say("Battle won. You gain: %s." % (", ".join(got) if not got.is_empty() else "nothing but growth"))


# ---------- rises ----------

## The monsters a rise can still be given to: they fought and stand, are below High, and a monster of their step or
## above was defeated.
static func can_rise(game: GameState) -> Array[MonsterInstance]:
	var out: Array[MonsterInstance] = []
	for m in game.roster:
		if m.may_rise and _rise_for(game, m) >= 0:
			out.append(m)
	return out


## The index of the rise a monster would take: the lowest that reaches it (-1 = none).
static func _rise_for(game: GameState, m: MonsterInstance) -> int:
	if m.sub_tier == Stage.SubTier.HIGH or not m.can_step(game.stage):
		return -1
	var best := -1
	for i in game.rises.size():
		if game.rises[i] >= m.step() and (best < 0 or game.rises[i] < game.rises[best]):
			best = i
	return best


## Gives one of the rises left to a monster.
static func give(game: GameState, m: MonsterInstance) -> bool:
	var i := _rise_for(game, m)
	if not m.may_rise or i < 0:
		return false
	game.rises.remove_at(i)
	m.may_rise = false
	game.lift(m)
	game.say(game.rise_line(m))
	if can_rise(game).is_empty():
		drop_rises(game)
	return true


## Lets the rises left go: the player gives no more of them.
static func drop_rises(game: GameState) -> void:
	game.rises.clear()
	for m in game.roster:
		m.may_rise = false


## Where the rises reach for every monster that could take one, nobody has to choose.
static func _give_all_if_no_choice(game: GameState) -> void:
	var want := can_rise(game)
	want.sort_custom(func(a: MonsterInstance, b: MonsterInstance) -> bool: return a.step() > b.step())
	var have := game.rises.duplicate()
	have.sort()
	have.reverse()
	for i in want.size():
		if i >= have.size() or have[i] < want[i].step():
			game.say("The battle left fewer rises than monsters that could take one: choose under Monsters.")
			return
	for m in want:
		give(game, m)
	drop_rises(game)
