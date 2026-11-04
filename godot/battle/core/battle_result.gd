class_name BattleResult
extends RefCounted
## What a finished battle reports back (gdd_overworld §1.3): facts, not rewards.
## The overworld decides what they are worth (XP, loot, catch) and which HP to keep.
##
## Per unit, in team order: {species, index, hp_left, max_hp, alive}.
## `hp_left` 0 means the monster fell. What that costs the owner is a game rule that is still
## open (gdd_overworld §12), so `apply_hp` only writes the number.

var over := false
var winner_side := -1               # 0 player, 1 enemy, -1 draw / not finished
var rounds := 0
var player: Array[Dictionary] = []
var enemy: Array[Dictionary] = []


static func from_battle(b: Battle) -> BattleResult:
	var r := BattleResult.new()
	r.over = b.over
	r.winner_side = b.winner_side
	r.rounds = b.round_number
	for id in b.roster:
		var m: Monster = b.monsters[id]
		var entry := {"species": m.def.id, "index": m.team_index, "hp_left": maxi(m.hp, 0),
			"max_hp": m.max_hp, "alive": m.is_alive()}
		if m.side == 0:
			r.player.append(entry)
		else:
			r.enemy.append(entry)
	var by_index := func(a: Dictionary, c: Dictionary) -> bool: return a["index"] < c["index"]
	r.player.sort_custom(by_index)
	r.enemy.sort_custom(by_index)
	return r


func player_won() -> bool:
	return over and winner_side == 0


func survivors(side := 0) -> int:
	var n := 0
	for e in (player if side == 0 else enemy):
		if e["alive"]:
			n += 1
	return n


## Writes the remaining HP back into the individuals the units came from.
func apply_hp(team: Array[MonsterInstance], side := 0) -> void:
	for e in (player if side == 0 else enemy):
		var i: int = e["index"]
		if i >= 0 and i < team.size():
			team[i].current_hp = int(e["hp_left"])
