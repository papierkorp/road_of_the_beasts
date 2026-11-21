class_name Places
extends RefCounted
## Reads the result of a fight back into the game, by the place it came from (docs/vision.md §4).


## `result` is null or not over when the player left the battle: that counts as a defeat.
static func resolve(game: GameState, f: Fight, result: BattleResult) -> void:
	var won := result != null and result.over and result.player_won()
	if result != null and result.over:
		result.apply_hp(f.team, 0)
	for m in f.team:
		m.fresh = false
	match f.place:
		Fight.WILD:
			WildArea.resolve(game, f, result, won)
		Fight.DUNGEON:
			DungeonRun.resolve(game, f, result, won)
		Fight.VOID:
			VoidPlace.resolve(game, f, result, won)


## The monsters of the enemy side that were caught, as individuals for the roster.
static func caught(f: Fight, result: BattleResult) -> Array[MonsterInstance]:
	var out: Array[MonsterInstance] = []
	if result == null:
		return out
	for e in result.enemy:
		var i: int = e["index"]
		if bool(e.get("caught", false)) and i >= 0 and i < f.enemies.size():
			out.append(f.enemies[i])
	return out


## A battleground of the places for a stage: one of those that first appear in it, or in the latest stage before.
static func pick_map(values: GameValues, rng: RandomNumberGenerator, stage: int) -> Dictionary:
	var best := -1
	for b: Dictionary in values.battlegrounds:
		if int(b["stage"]) <= stage:
			best = maxi(best, int(b["stage"]))
	var pool: Array = values.battlegrounds.filter(func(b: Dictionary) -> bool: return int(b["stage"]) == best)
	return {} if pool.is_empty() else pool[rng.randi_range(0, pool.size() - 1)]


## `n` wild individuals of random species at a step of growth.
static func monsters(rng: RandomNumberGenerator, n: int, step: int, rarity := MonsterInstance.Rarity.NORMAL) -> Array[MonsterInstance]:
	var ids := GameData.monster_ids()
	var out: Array[MonsterInstance] = []
	for i in n:
		out.append(MonsterInstance.grown(GameData.monster(ids[rng.randi_range(0, ids.size() - 1)]), rng, step, rarity))
	return out


## A number of enemies from a per-stage [least, most] table, never more than the battleground holds.
static func enemy_count(table: Array, stage: int, rng: RandomNumberGenerator, room: int, extra := 0) -> int:
	var pair: Array = GameValues.entry(table, stage)
	return clampi(rng.randi_range(int(pair[0]), int(pair[1])) + extra, 1, room)
