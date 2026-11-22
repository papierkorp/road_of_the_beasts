class_name DungeonRun
extends RefCounted
## The dungeon (docs/vision.md §4): a run through a generated map of nodes with forks, for a fixed number of day AP.
## HP stay from battle to battle; leaving keeps the loot, a defeat costs a part of it; the last battle holds the
## best loot. No battle here gives monster XP. A dungeon whose challenge is met can be harvested without a battle.
##
## The run lives in `GameState.dungeon` as plain data: {"stage", "run" (its number, the seed of its map),
## "path": cleared node ids in order, "loot": item -> number}. The nodes are generated from the game's seed.

const BATTLE := &"battle"
const REST := &"rest"
const LAST := &"last"


## The dungeons the player may enter: one per stage reached.
static func stages(game: GameState) -> Array[int]:
	var out: Array[int] = []
	for s in mini(int(game.stage), Stage.Type.IMMORTAL) + 1:
		out.append(s)
	return out


static func running(game: GameState) -> bool:
	return not game.dungeon.is_empty()


static func can_start(game: GameState) -> bool:
	return not running(game) and not game.forced_trial and not game.is_over() and game.ap >= game.values.dungeon_ap


static func start(game: GameState, stage: int) -> bool:
	if not can_start(game) or not stages(game).has(stage):
		return false
	game.spend_ap(game.values.dungeon_ap)
	game.dungeon_runs += 1
	game.dungeon = {"stage": stage, "run": game.dungeon_runs, "path": [], "loot": {}}
	game.say("You enter the dungeon of %s. HP stay from battle to battle." % Stage.stage_name(stage as Stage.Type))
	return true


static func stage_of(game: GameState) -> int:
	return int(game.dungeon.get("stage", 0))


## `n` plants of the dungeon of a stage.
static func _loot(game: GameState, rng: RandomNumberGenerator, stage: int, n: int) -> Dictionary:
	var out := {}
	var plants := Materials.plants_of(game.values, stage)
	for i in n:
		if plants.is_empty():
			break
		var item := Materials.plant(plants[rng.randi_range(0, plants.size() - 1)], stage)
		out[item] = int(out.get(item, 0)) + 1
	return out


## The map of the running dungeon: {"id", "layer", "kind", "map", "mine", "enemies", "loot", "next": [ids]}.
static func nodes(game: GameState) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	if not running(game):
		return out
	var v := game.values
	var stage := stage_of(game)
	var rng := game.rng_for("dungeon%d_%d" % [stage, int(game.dungeon["run"])])
	var layers: Array = []
	var count := v.dungeon_layers.size()
	for l in count:
		var row: Array[int] = []
		var is_last := l == count - 1
		for c in v.dungeon_layers[l]:
			var kind: StringName = LAST if is_last else BATTLE
			if not is_last and v.dungeon_rest_layers.has(l) and c == v.dungeon_layers[l] - 1 and v.dungeon_layers[l] > 1:
				kind = REST
			var n := {"id": out.size(), "layer": l, "kind": kind, "next": [], "loot": {}, "enemies": [], "map": &"", "mine": 0}
			if kind != REST:
				var map := Places.pick_map(v, rng, stage)
				n["map"] = map["id"]
				n["mine"] = int(map["mine"])
				var enemies := Places.enemy_count(v.dungeon_enemies, stage, rng, int(map["theirs"]), 1 if is_last else 0)
				n["enemies"] = Places.monsters(rng, enemies, GameState.step_of(stage, 2 if is_last else rng.randi_range(0, 2)))
				n["loot"] = _loot(game, rng, stage, v.dungeon_node_loot + (v.dungeon_last_loot if is_last else 0))
			row.append(n["id"])
			out.append(n)
		layers.append(row)
	for l in count - 1:                          # straight on, sometimes also across; every next node stays reachable
		var here: Array = layers[l]
		var there: Array = layers[l + 1]
		for c in here.size():
			var straight := mini(c, there.size() - 1)
			var next: Array = [there[straight]]
			if there.size() > 1 and (rng.randf() < 0.6 or here.size() == 1):
				next.append(there[there.size() - 1 - straight])
			out[here[c]]["next"] = next
		for t: int in there:                         # a node nobody leads to hangs on the first node of the layer before
			var reached := false
			for c in here.size():
				if (out[here[c]]["next"] as Array).has(t):
					reached = true
			if not reached:
				(out[here[0]]["next"] as Array).append(t)
	return out


static func path(game: GameState) -> Array:
	return game.dungeon.get("path", [])


## The nodes the player may enter next.
static func choices(game: GameState) -> Array[int]:
	var out: Array[int] = []
	var all := nodes(game)
	if all.is_empty():
		return out
	var done := path(game)
	if done.is_empty():
		for n in all:
			if int(n["layer"]) == 0:
				out.append(int(n["id"]))
	else:
		for id in all[int(done[-1])]["next"]:
			out.append(int(id))
	return out


## Whether any monster can still fight.
static func team_stands(game: GameState) -> bool:
	return not game.default_team(1).is_empty()


static func fight_for(game: GameState, node_id: int) -> Fight:
	var all := nodes(game)
	if not choices(game).has(node_id) or all[node_id]["kind"] == REST:
		return null
	var n := all[node_id]
	var f := Fight.new()
	f.place = Fight.DUNGEON
	f.stage = stage_of(game)
	f.title = "The last battle of the dungeon" if n["kind"] == LAST else "Dungeon battle"
	f.map_id = n["map"]
	f.max_team = int(n["mine"])
	f.enemies = n["enemies"]
	f.wild = true
	f.roll_seed = hash([game.game_seed, "dungeon_roll", game.dungeon["run"], node_id]) & 0x3FFFFFFF
	f.ref = {"node": node_id, "last": n["kind"] == LAST}
	f.loot_text = "%s, a beast part per monster defeated; no monster XP" % Materials.list_text(n["loot"], game.values)
	return f


## Takes a rest node: every monster that still stands regains HP.
static func rest(game: GameState, node_id: int) -> bool:
	var all := nodes(game)
	if not choices(game).has(node_id) or all[node_id]["kind"] != REST:
		return false
	for m in game.roster:
		if m.current_hp > 0:
			m.current_hp = mini(m.max_hp(), m.current_hp + game.values.rest_heal)
	(game.dungeon["path"] as Array).append(node_id)
	game.say("You rest: every monster that stands regains %d HP." % game.values.rest_heal)
	return true


## Ends the run and hands out `percent` of the loot gathered.
static func _end(game: GameState, percent: int) -> Dictionary:
	var kept := {}
	var loot: Dictionary = game.dungeon.get("loot", {})
	for id in loot:
		@warning_ignore("integer_division")
		var n := int(loot[id]) * percent / 100
		if n > 0:
			kept[id] = n
			game.add_item(String(id), n)
	game.dungeon = {}
	for m in game.roster:
		m.heal_full()
	return kept


## Leaving is possible after every battle, with everything gathered so far.
static func leave(game: GameState) -> void:
	if not running(game):
		return
	var stage := stage_of(game)
	game.dungeon_streak[stage] = 0
	var kept := _end(game, 100)
	game.say("You leave the dungeon with: %s." % Materials.list_text(kept, game.values))


static func mastered(game: GameState, stage: int) -> bool:
	return game.dungeon_mastered.has(stage)


static func challenge(game: GameState, stage: int) -> Dictionary:
	return GameValues.entry(game.values.dungeon_challenges, stage)


static func challenge_text(game: GameState, stage: int) -> String:
	var c := challenge(game, stage)
	if c["kind"] == "rounds":
		return "win the last battle within %d rounds" % int(c["n"])
	return "win %d run(s) in a row" % int(c["n"])


static func resolve(game: GameState, f: Fight, result: BattleResult, won: bool) -> void:
	if not running(game):
		return
	var stage := stage_of(game)
	for m in Places.caught(f, result):
		if game.add_monster(m):
			game.say("Caught: %s." % m.title())
	if not won:
		game.dungeon_streak[stage] = 0
		var kept := _end(game, game.values.dungeon_defeat_keeps)
		game.say("Your team fell: the run is over. You keep: %s." % Materials.list_text(kept, game.values))
		return
	var node_id := int(f.ref["node"])
	var n := nodes(game)[node_id]
	var won_loot: Dictionary = (n["loot"] as Dictionary).duplicate()
	for part in Places.beast_parts(f, result):         # every wild monster defeated leaves its beast part
		won_loot[part] = int(won_loot.get(part, 0)) + 1
	var loot: Dictionary = game.dungeon["loot"]
	for id in won_loot:
		loot[id] = int(loot.get(id, 0)) + int(won_loot[id])
	(game.dungeon["path"] as Array).append(node_id)
	game.say("Battle won. Gathered: %s." % Materials.list_text(won_loot, game.values))
	for m in f.team:                              # a vow: HP back after a battle won
		if m.current_hp > 0:
			m.current_hp = mini(m.max_hp(), m.current_hp + game.vow_sum("dungeon_heal"))
	if not bool(f.ref.get("last", false)):
		return
	game.dungeon_streak[stage] = int(game.dungeon_streak.get(stage, 0)) + 1
	var c := challenge(game, stage)
	var met: bool = int(game.dungeon_streak[stage]) >= int(c["n"]) if c["kind"] == "streak" else result.rounds <= int(c["n"])
	var kept := _end(game, 100)
	game.say("The dungeon is cleared. You bring home: %s." % Materials.list_text(kept, game.values))
	if met and not mastered(game, stage):
		game.dungeon_mastered.append(stage)
		game.say("Challenge met (%s): this dungeon can now be harvested without a battle." % challenge_text(game, stage))


static func can_harvest(game: GameState, stage: int) -> bool:
	return mastered(game, stage) and not running(game) and not game.forced_trial and not game.is_over() and game.ap >= game.values.harvest_ap


## A harvest (docs/vision.md §4): a few day AP for a fixed, lower yield of plants.
static func harvest(game: GameState, stage: int) -> Dictionary:
	if not can_harvest(game, stage):
		return {}
	game.spend_ap(game.values.harvest_ap)
	game.dungeon_runs += 1
	var loot := _loot(game, game.rng_for("harvest%d" % game.dungeon_runs), stage, game.values.harvest_yield)
	for id in loot:
		game.add_item(String(id), int(loot[id]))
	game.say("Harvest of the dungeon of %s: %s." % [Stage.stage_name(stage as Stage.Type), Materials.list_text(loot, game.values)])
	return loot
