extends GdUnitTestSuite
## Heal (docs/battle.md §2.4): 3 Stamina and no AP for 1 HP, once per turn.

const H := preload("res://tests/battle/helpers.gd")


func after_test() -> void:
	BattleExperiment.reset()


func _duel(o: Dictionary = {}) -> Battle:
	var mine := {"pace": 1.9, "hp": 5, "current_hp": 2, "move": 5, "ap": 3}
	mine.merge(o, true)
	var b := H.battle([[0, Vector2i(1, 5), mine], [1, Vector2i(5, 1), {"pace": 1.2}]])
	b.begin()
	return b


func test_heal_costs_three_stamina_and_no_ap_and_gives_one_hp_back() -> void:
	var b := _duel()
	var u := H.unit(b, 0)
	assert_bool(b.apply({"type": &"heal"})).is_true()
	assert_int(b.ap).is_equal(3)
	assert_int(u.hp).is_equal(3)
	assert_int(u.stamina).is_equal(2)
	assert_int(u.sheet.movement).is_equal(5)


func test_heal_works_without_ap() -> void:
	var b := _duel()
	b.ap = 0
	assert_bool(b.apply({"type": &"heal"})).is_true()
	assert_int(H.unit(b, 0).hp).is_equal(3)


func test_heal_works_once_per_turn_and_again_in_the_next_turn() -> void:
	var b := _duel({"move": 8})
	var u := H.unit(b, 0)
	assert_bool(b.apply({"type": &"heal"})).is_true()
	assert_str(b.check({"type": &"heal"})).contains("already used this turn")
	b.end_turn()
	b.end_turn()
	assert_that(b.turn_owner).is_equal(u.id)
	assert_int(u.stamina).is_equal(6)                 # 8 - 3, and Pace 1.9 recovers 1
	assert_bool(b.apply({"type": &"heal"})).is_true()
	assert_int(u.hp).is_equal(4)
	assert_int(u.stamina).is_equal(3)


func test_heal_needs_three_stamina_in_the_pool() -> void:
	var b := _duel()
	H.unit(b, 0).stamina = 2
	assert_str(b.check({"type": &"heal"})).contains("needs 3 Stamina")
	assert_bool(b.apply({"type": &"heal"})).is_false()
	var small := _duel({"move": 2})                   # a pool of 2 can never heal
	assert_str(small.check({"type": &"heal"})).contains("needs 3 Stamina")


func test_heal_never_heals_above_the_maximum() -> void:
	var full := _duel({"current_hp": -1})
	assert_str(full.check({"type": &"heal"})).contains("full HP")


func test_the_spent_stamina_comes_back_with_the_recovery() -> void:
	var b := _duel()
	var u := H.unit(b, 0)
	assert_bool(b.apply({"type": &"heal"})).is_true()
	assert_int(u.stamina).is_equal(2)
	b.end_turn()
	b.end_turn()
	assert_int(u.stamina).is_equal(3)                 # Pace 1.9 recovers 1, up to the pool of 5


func test_a_copy_of_the_battle_heals_apart() -> void:
	var b := _duel()
	var sim := b.clone()
	assert_bool(sim.apply({"type": &"heal"})).is_true()
	assert_int(H.unit(sim, 0).stamina).is_equal(2)
	assert_int(H.unit(b, 0).stamina).is_equal(5)
	assert_int(H.unit(b, 0).hp).is_equal(2)


func test_the_opponent_ai_lists_heal_only_when_it_is_legal() -> void:
	var b := _duel()
	var has := func(battle: Battle) -> bool:
		for a in AiBrain.candidates(battle):
			if a["type"] == &"heal":
				return true
		return false
	assert_bool(has.call(b)).is_true()
	assert_bool(b.apply({"type": &"heal"})).is_true()
	assert_bool(has.call(b)).is_false()
