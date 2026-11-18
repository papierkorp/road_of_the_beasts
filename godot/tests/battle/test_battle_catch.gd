extends GdUnitTestSuite
## Catching on the board (docs/battle_ingame.md §7): Seal Ground, the catch roll, death of wild monsters, the contract.

const H := preload("res://tests/battle/helpers.gd")


func before_test() -> void:
	H.legacy_rules()


func after_test() -> void:
	BattleExperiment.reset()


## u0: the player's monster (acts first), u1: an enemy at (3, 3). The enemy side is wild unless told otherwise.
func _battle(enemy: Dictionary = {}, seals: Array = [&"seal"], wild := true) -> Battle:
	var o := {"pace": 1.5, "hp": 5}
	o.merge(enemy, true)
	var b := H.battle([[0, Vector2i(0, 6), {"pace": 1.9}], [1, Vector2i(3, 3), o]])
	for id: StringName in seals:
		b.tamer_loadout[0].append(H.content().tamer_skill(id))
	b.wild[1] = wild
	return b


func _seal(b: Battle, p: Vector2i, skill := &"seal") -> bool:
	return b.apply({"type": &"tamer", "side": 0, "skill": skill, "cells": [p]})


func _hit(b: Battle, u: BattleUnit, amount: int) -> void:
	BattleDamage.apply_round(b, [{"unit": u.id, "base": amount, "type": BattleDamage.GROUND, "source": "test"}])
	BattleDamage.defeat_step(b)
	b.check_over()


func test_seal_ground_cannot_be_changed_and_lies_until_it_catches() -> void:
	var b := _battle()
	b.set_ground(Vector2i(3, 0), GroundDef.WELL)
	b.begin()
	assert_str(b.check({"type": &"tamer", "side": 0, "skill": &"seal", "cells": [Vector2i(3, 0)]})).contains("Dragon Vein")
	assert_str(b.check({"type": &"tamer", "side": 0, "skill": &"seal", "cells": [Vector2i(9, 9)]})).contains("square")
	assert_bool(_seal(b, Vector2i(2, 2))).is_true()
	assert_int(b.ap).is_equal(3)                                   # no AP
	var cell := b.board.at(Vector2i(2, 2))
	assert_str(cell.ground).is_equal("seal")
	assert_str(BattleBoardOps.lay_ground(b, cell, &"lava")).is_equal("immutable")
	for i in 6:                                                    # three rounds: it does not fade
		b.end_turn()
	assert_int(b.round_number).is_greater(2)
	assert_str(cell.ground).is_equal("seal")


func test_one_seal_ground_at_a_time_counts_skill_and_item_together() -> void:
	var b := _battle({}, [&"seal", &"seal_rare"])
	b.begin()
	assert_bool(_seal(b, Vector2i(2, 2))).is_true()
	assert_str(b.check({"type": &"tamer", "side": 0, "skill": &"seal_rare", "cells": [Vector2i(4, 4)]})).contains("one at a time")


func test_a_wild_monster_at_zero_hp_on_seal_ground_is_caught_and_the_seal_is_used_up() -> void:
	var b := _battle({"current_hp": 2})
	b.begin()
	_seal(b, Vector2i(3, 3))
	_hit(b, H.unit(b, 1), 2)
	var u := H.unit(b, 1)
	assert_bool(u.caught).is_true()
	assert_bool(u.died).is_false()
	assert_bool(u.defeated).is_true()
	assert_str(b.board.at(Vector2i(3, 3)).ground).is_equal("plain")
	assert_bool(b.seals.is_empty()).is_true()
	assert_bool(b.over).is_true()                                  # a caught monster counts as defeated
	assert_int(b.winner_side).is_equal(0)
	var r := BattleSetup.make_result(b)
	assert_bool(r.enemy[0]["caught"]).is_true()


func test_a_wild_monster_dies_off_seal_ground_and_a_contracted_one_never_dies() -> void:
	var b := _battle({"current_hp": 1})
	b.begin()
	_seal(b, Vector2i(5, 5))
	_hit(b, H.unit(b, 1), 2)
	assert_bool(H.unit(b, 1).died).is_true()
	assert_bool(H.unit(b, 1).caught).is_false()
	var c := _battle({"current_hp": 1}, [&"seal"], false)          # the enemy has a tamer
	c.begin()
	_seal(c, Vector2i(3, 3))
	_hit(c, H.unit(c, 1), 2)
	assert_bool(H.unit(c, 1).defeated).is_true()
	assert_bool(H.unit(c, 1).died).is_false()
	assert_bool(H.unit(c, 1).caught).is_false()                    # nothing is caught from a tamer


func test_the_chance_falls_by_the_step_for_every_hp_above_one() -> void:
	assert_int(BattleCatch.chance_at(50, 1)).is_equal(50)
	assert_int(BattleCatch.chance_at(50, 2)).is_equal(40)
	assert_int(BattleCatch.chance_at(50, 6)).is_equal(0)
	assert_int(BattleCatch.chance_at(65, 3)).is_equal(45)
	assert_int(BattleCatch.chance_at(20, 4)).is_equal(0)
	BattleExperiment.seal_step = 5
	assert_int(BattleCatch.chance_at(50, 6)).is_equal(25)
	for pair: Array in [[&"seal", 50], [&"seal_normal", 20], [&"seal_rare", 35], [&"seal_epic", 50], [&"seal_legendary", 65]]:
		assert_int(H.content().tamer_skill(pair[0]).seal_base).is_equal(pair[1])


## The enemy ends its turn on Seal Ground with `hp` HP; returns the battle after that turn end.
func _turn_end_on_seal(hp: int, seed: int, seal := &"seal_legendary") -> Battle:
	var b := _battle({"hp": maxi(5, hp), "current_hp": hp}, [seal])
	b.roll_seed = seed
	b.begin()
	_seal(b, Vector2i(3, 3), seal)
	b.end_turn()                                                   # the enemy's turn
	b.end_turn()                                                   # its turn end: the roll
	return b


func test_a_wild_monster_ending_its_turn_on_seal_ground_is_rolled_for_and_the_roll_replays() -> void:
	var outcomes := {}
	for seed in 40:
		var b := _turn_end_on_seal(1, seed)
		var rolls := H.events_of(b, &"catch_roll")
		assert_int(rolls.size()).is_equal(1)
		assert_int(int(rolls[0]["chance"])).is_equal(65)
		var caught: bool = rolls[0]["caught"]
		assert_bool(H.unit(b, 1).caught).is_equal(caught)
		assert_bool(caught == (int(rolls[0]["roll"]) <= 65)).is_true()
		outcomes[caught] = true
		var again := _turn_end_on_seal(1, seed)                    # same seed, same actions: the same roll
		assert_str(again.state_hash()).is_equal(b.state_hash())
	assert_int(outcomes.size()).is_equal(2)                        # both outcomes occur
	var none := _turn_end_on_seal(5, 1, &"seal")                   # 50 − 4 × 10 = 10 %
	assert_int(int(H.events_of(none, &"catch_roll")[0]["chance"])).is_equal(10)
	var zero := _turn_end_on_seal(6, 1, &"seal")                   # 0 %: no roll
	assert_array(H.events_of(zero, &"catch_roll")).is_empty()
	assert_int(zero.rolls).is_equal(0)


func test_a_dry_run_never_rolls() -> void:
	var b := _battle({"current_hp": 1}, [&"seal_legendary"])
	b.begin()
	_seal(b, Vector2i(3, 3), &"seal_legendary")
	b.end_turn()
	var p := b.preview({"type": &"end_turn"})
	var types: Array = (p["events"] as Array).map(func(e): return e["type"])
	assert_bool(types.has(&"catch_chance")).is_true()
	assert_bool(types.has(&"catch_roll")).is_false()
	assert_int(b.rolls).is_equal(0)
	assert_bool(H.unit(b, 1).caught).is_false()


func test_the_ingame_prototype_adds_a_wild_enemy_and_the_seal() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	var r := IngamePrototype.request(&"1v1", [40, 40], rng)
	IngamePrototype.add_catching(r, true, &"seal_rare", rng)
	r.enemy_tamer.append(&"second_wind")
	var b := BattleSetup.build(r)
	assert_bool(b.wild[1]).is_true()
	assert_bool(b.wild[0]).is_false()
	assert_array(b.tamer_loadout[1]).is_empty()                    # a wild side has no tamer
	assert_str(b.tamer_loadout[0][0].id).is_equal("seal_rare")
	assert_int(b.roll_seed).is_not_equal(0)
	r.battle_kind = BattleRequest.MULTIPLAYER                      # catching is the ingame battle's only
	assert_bool(BattleSetup.build(r).wild[1]).is_false()
