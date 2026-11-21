class_name Places
extends RefCounted
## Reads the result of a fight back into the game, by the place it came from (docs/vision.md §4).


## `result` is null or not over when the player left the battle: that counts as a defeat.
static func resolve(game: GameState, f: Fight, result: BattleResult) -> void:
	var won := result != null and result.over and result.player_won()
	if result != null and result.over:
		result.apply_hp(f.team, 0)
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
