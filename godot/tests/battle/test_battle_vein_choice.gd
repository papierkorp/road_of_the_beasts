extends GdUnitTestSuite
## Dragon Vein tie (user decision 2026-11-14): the owning side picks the target among equally near,
## equally strong enemies at the round end; sides outside `choice_sides` take the roster order.

const H := preload("res://tests/battle/helpers.gd")


func before_test() -> void:
	BattleExperiment.reset()


func after_test() -> void:
	BattleExperiment.reset()


## u0 (side 0) holds the vein at (3, 3); u1 and u2 (side 1) are equally near, equally strong.
func _setup() -> Battle:
	var b := H.battle([[0, Vector2i(3, 3), {"init": 9.0}], [1, Vector2i(1, 3), {"init": 5.0}], [1, Vector2i(5, 3), {"init": 5.0}]])
	b.set_ground(Vector2i(3, 3), GroundDef.WELL)
	b.begin()
	return b


func _to_round_end(b: Battle) -> void:
	var guard := 0
	while b.pending_choice.is_empty() and b.round_number == 1 and not b.over and guard < 12:
		b.end_turn()
		guard += 1


func test_the_owning_side_picks_the_target_of_a_tied_vein() -> void:
	var b := _setup()
	b.choice_sides = [0]
	_to_round_end(b)
	assert_bool(b.pending_choice.is_empty()).is_false()
	assert_array(b.pending_choice["options"]).contains_exactly_in_any_order([&"u1", &"u2"])
	assert_str(b.check({"type": &"end_turn"})).is_not_empty()             # nothing else is legal meanwhile
	assert_str(b.check({"type": &"choose_target", "unit": &"u0"})).is_not_empty()
	var hp := H.unit(b, 2).hp
	assert_bool(b.apply({"type": &"choose_target", "unit": &"u2"})).is_true()
	assert_int(H.unit(b, 2).hp).is_equal(hp - 1)                          # the pick, not the roster-order first
	assert_int(H.unit(b, 1).hp).is_equal(H.unit(b, 1).sheet.hp)
	assert_int(b.round_number).is_equal(2)


func test_without_choice_sides_the_roster_order_decides() -> void:
	var b := _setup()
	_to_round_end(b)
	assert_bool(b.pending_choice.is_empty()).is_true()
	assert_int(H.unit(b, 1).hp).is_equal(H.unit(b, 1).sheet.hp - 1)
	assert_int(b.round_number).is_equal(2)


func test_no_choice_is_asked_when_one_enemy_is_clearly_the_target() -> void:
	var b := H.battle([[0, Vector2i(3, 3), {"init": 9.0}], [1, Vector2i(2, 3), {"init": 5.0}], [1, Vector2i(6, 3), {"init": 5.0}]])
	b.set_ground(Vector2i(3, 3), GroundDef.WELL)
	b.begin()
	b.choice_sides = [0]
	_to_round_end(b)
	assert_bool(b.pending_choice.is_empty()).is_true()
	assert_int(H.unit(b, 1).hp).is_equal(H.unit(b, 1).sheet.hp - 1)


func test_a_clone_keeps_a_pending_choice() -> void:
	var b := _setup()
	b.choice_sides = [0]
	_to_round_end(b)
	var c := b.clone()
	assert_array(c.pending_choice["options"]).contains_exactly_in_any_order([&"u1", &"u2"])
	assert_array(c.choice_sides).is_equal([0])


func test_the_fallback_pick_takes_fewest_hp_then_highest_initiative_then_lowest_max_hp() -> void:
	var b := H.battle([[0, Vector2i(0, 0)], [1, Vector2i(5, 5), {"init": 5.0, "hp": 8}], [1, Vector2i(6, 6), {"init": 7.0, "hp": 8}],
		[1, Vector2i(5, 6), {"init": 7.0, "hp": 6}]])
	b.begin()
	var tied: Array[BattleUnit] = [H.unit(b, 1), H.unit(b, 2), H.unit(b, 3)]
	assert_str(String(BattleTurn.ai_pick(b, tied).id)).is_equal("u3")      # same HP 8/8/6 → fewest HP
	H.unit(b, 3).hp = 8
	assert_str(String(BattleTurn.ai_pick(b, tied).id)).is_equal("u3")      # HP 8/8/8: init 7 beats 5; max HP 6 beats 8
	H.unit(b, 3).max_hp = 9
	assert_str(String(BattleTurn.ai_pick(b, tied).id)).is_equal("u2")      # max HP 9 loses to 8


func test_a_dry_run_of_each_option_leaves_the_pending_choice_untouched() -> void:
	var b := _setup()
	b.choice_sides = [0]
	_to_round_end(b)
	var hp1 := H.unit(b, 1).hp
	var sim := b.clone()
	assert_bool(sim.apply({"type": &"choose_target", "unit": &"u1"})).is_true()
	assert_int(sim.units[&"u1"].hp).is_equal(hp1 - 1)             # what the preview shows
	assert_int(H.unit(b, 1).hp).is_equal(hp1)                      # the real battle still waits
	assert_bool(b.pending_choice.is_empty()).is_false()
