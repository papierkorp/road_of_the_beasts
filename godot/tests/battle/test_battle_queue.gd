extends GdUnitTestSuite
## Initiative queue (gdd_battle §2.2).

const H := preload("res://tests/battle/helpers.gd")


func after_test() -> void:
	BattleExperiment.reset()


func _ids(b: Battle) -> Array:
	var out := []
	for e in b.queue:
		out.append([e["id"], e["init"]])
	return out


func test_one_queue_for_both_sides_by_effective_initiative() -> void:
	var b := H.battle([
		[0, Vector2i(0, 6), {"init": 6.0}],
		[1, Vector2i(6, 0), {"init": 9.0}],
		[1, Vector2i(5, 0), {"init": 2.0}],
	])
	b.begin()
	assert_array(_ids(b)).is_equal([[&"u1", 9.0], [&"u0", 6.0], [&"u2", 2.0]])
	assert_str(b.turn_owner).is_equal("u1")


func test_extra_turn_entries_sit_three_lower_and_never_below_the_floor() -> void:
	BattleExperiment.tpr_from_round = 1       # the queue of round 2 and later (in round 1 every monster has one turn)
	var b := H.battle([
		[0, Vector2i(0, 6), {"init": 6.0}],
		[1, Vector2i(6, 0), {"init": 9.0, "tpr": 2}],
		[1, Vector2i(5, 0), {"init": 2.0, "tpr": 3}],
	])
	b.begin()
	# 9.0 · 6.0 (u0) vs 6.0 (u1 extra): higher base initiative first · 2.0 · 0.1 · 0.1
	assert_array(_ids(b)).is_equal([[&"u1", 9.0], [&"u1", 6.0], [&"u0", 6.0], [&"u2", 2.0], [&"u2", 0.1], [&"u2", 0.1]])


func test_first_tie_goes_to_the_side_with_the_lower_total_initiative() -> void:
	# two players and one enemy fully tied: the enemy's total (5.0) is lower than the
	# player's (10.0), so the enemy wins the first tie; then the sides alternate.
	var b := H.battle([
		[0, Vector2i(0, 6), {"init": 5.0}],
		[0, Vector2i(1, 6), {"init": 5.0}],
		[1, Vector2i(6, 0), {"init": 5.0}],
	])
	b.begin()
	assert_array(_ids(b).map(func(x): return x[0])).is_equal([&"u2", &"u0", &"u1"])


func test_equal_totals_give_the_first_tie_to_the_player_then_alternate() -> void:
	var b := H.battle([
		[0, Vector2i(0, 6), {"init": 5.0}],
		[0, Vector2i(1, 6), {"init": 5.0}],
		[1, Vector2i(6, 0), {"init": 5.0}],
		[1, Vector2i(5, 0), {"init": 5.0}],
	])
	b.begin()
	# same side in slot order, sides alternating: P1, E1, P2, E2
	assert_array(_ids(b).map(func(x): return x[0])).is_equal([&"u0", &"u2", &"u1", &"u3"])
	# three cross-side ties were decided (P1/E1, E1/P2, P2/E2): the next one goes to the enemy
	for i in 4:
		b.end_turn()
	assert_int(b.round_number).is_equal(2)
	assert_array(_ids(b).map(func(x): return x[0])).is_equal([&"u2", &"u0", &"u3", &"u1"])


func test_ties_between_the_sides_keep_alternating_across_rounds() -> void:
	var b := H.battle([
		[0, Vector2i(0, 6), {"init": 5.0}],
		[1, Vector2i(6, 0), {"init": 5.0}],
	])
	b.begin()
	assert_str(b.queue[0]["id"]).is_equal("u0")        # equal totals: the player's side
	b.end_turn()
	b.end_turn()
	assert_str(b.queue[0]["id"]).is_equal("u1")        # the next tie goes to the other side
	b.end_turn()
	b.end_turn()
	assert_str(b.queue[0]["id"]).is_equal("u0")


func test_queue_is_recalculated_every_round_from_effective_initiative() -> void:
	var drain := H.zone_skill([FieldEffect.make("drain_init", 2, 3)])
	var b := H.battle([
		[0, Vector2i(0, 6), {"init": 6.0}],
		[1, Vector2i(6, 0), {"init": 5.0}],
	])
	H.zone_on(b, Vector2i(0, 6), drain.zone, 1, 1, Vector2i.ZERO, Vector2i.ZERO, 5)
	b.begin()
	# 6.0 - 2 = 4.0 < 5.0: the drained monster acts second
	assert_array(_ids(b)).is_equal([[&"u1", 5.0], [&"u0", 4.0]])
	assert_float(BattleStats.initiative(b, H.unit(b, 0))).is_equal(4.0)


func test_initiative_floor_is_point_one() -> void:
	var drain := H.zone_skill([FieldEffect.make("drain_init", 3, 3)])
	var b := H.battle([[0, Vector2i(0, 6), {"init": 2.0}], [1, Vector2i(6, 0), {"init": 5.0}]])
	H.zone_on(b, Vector2i(0, 6), drain.zone)
	assert_float(BattleStats.initiative(b, H.unit(b, 0))).is_equal(0.1)


func test_prep_bonus_is_part_of_the_unit_sheet() -> void:
	var b := H.battle([[0, Vector2i(0, 6), {"init": 4.0, "init_bonus": 2.0}], [1, Vector2i(6, 0), {"init": 5.0}]])
	b.begin()
	assert_array(_ids(b)).is_equal([[&"u0", 6.0], [&"u1", 5.0]])
