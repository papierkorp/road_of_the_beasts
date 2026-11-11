class_name BattleResult
extends RefCounted
## What a finished battle reports back (gdd_overworld §1.3): facts, not rewards.
## The overworld decides what they are worth (XP, loot, catch) and which HP to keep.
##
## Per unit, in team order: {species, index, hp_left, max_hp, alive, fielded}.
## `hp_left` 0 means the monster fell. What that costs the owner is a game rule that is still
## open (gdd_overworld §12), so `apply_hp` only writes the number.

var over := false
var winner_side := -1               # 0 player, 1 enemy, -1 Draw / not finished
## Both sides lost their last monsters in the same resolution (gdd_battle §2.1). What a Draw
## means for rewards, injury and defeat is still open (T19/T23); this is only the fact.
var draw := false
var rounds := 0
## Tamer skills of the player's loadout that were used (the result names used-up loadout items).
var used_tamer: Array[StringName] = []
var player: Array[Dictionary] = []
var enemy: Array[Dictionary] = []


## Filled by `BattleSetup.make_result(battle)` — the battle side knows how to read a Battle.

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
