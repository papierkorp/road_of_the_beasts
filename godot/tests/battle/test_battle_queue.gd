extends GdUnitTestSuite
## Pace queue (gdd_battle §2.2).

const H := preload("res://tests/battle/helpers.gd")


func before_test() -> void:
	H.legacy_rules()


func after_test() -> void:
	BattleExperiment.reset()


## Queue as [id, Pace] pairs; Pace as text with one decimal (tenths are not exact floats).
func _ids(b: Battle) -> Array:
	var out := []
	for e in b.queue:
		out.append([e["id"], "%.1f" % e["pace"]])
	return out


func test_one_queue_for_both_sides_by_effective_pace() -> void:
	var b := H.battle([
		[0, Vector2i(0, 6), {"pace": 1.6}],
		[1, Vector2i(6, 0), {"pace": 1.9}],
		[1, Vector2i(5, 0), {"pace": 1.2}],
	])
	b.begin()
	assert_array(_ids(b)).is_equal([[&"u1", "1.9"], [&"u0", "1.6"], [&"u2", "1.2"]])
	assert_str(b.turn_owner).is_equal("u1")


func test_extra_turn_entries_sit_two_points_lower_and_never_below_the_floor() -> void:
	BattleExperiment.tpr_from_round = 1       # the queue of round 2 and later (in round 1 every monster has one turn)
	var b := H.battle([
		[0, Vector2i(0, 6), {"pace": 1.7}],
		[1, Vector2i(6, 0), {"pace": 1.9, "tpr": 2}],
		[1, Vector2i(5, 0), {"pace": 0.3, "tpr": 3}],
	])
	b.begin()
	# 1.9 · 1.7 (u1 extra) vs 1.7 (u0): higher base Pace first · 0.3 · 0.1 · 0.1 (floor)
	assert_array(_ids(b)).is_equal([[&"u1", "1.9"], [&"u1", "1.7"], [&"u0", "1.7"], [&"u2", "0.3"], [&"u2", "0.1"], [&"u2", "0.1"]])


func test_first_tie_goes_to_the_side_with_the_lower_total_pace() -> void:
	# two players and one enemy fully tied: the enemy's total (5.0) is lower than the
	# player's (10.0), so the enemy wins the first tie; then the sides alternate.
	var b := H.battle([
		[0, Vector2i(0, 6), {"pace": 1.5}],
		[0, Vector2i(1, 6), {"pace": 1.5}],
		[1, Vector2i(6, 0), {"pace": 1.5}],
	])
	b.begin()
	assert_array(_ids(b).map(func(x): return x[0])).is_equal([&"u2", &"u0", &"u1"])


func test_equal_totals_give_the_first_tie_to_the_player_then_alternate() -> void:
	var b := H.battle([
		[0, Vector2i(0, 6), {"pace": 1.5}],
		[0, Vector2i(1, 6), {"pace": 1.5}],
		[1, Vector2i(6, 0), {"pace": 1.5}],
		[1, Vector2i(5, 0), {"pace": 1.5}],
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
		[0, Vector2i(0, 6), {"pace": 1.5}],
		[1, Vector2i(6, 0), {"pace": 1.5}],
	])
	b.begin()
	assert_str(b.queue[0]["id"]).is_equal("u0")        # equal totals: the player's side
	b.end_turn()
	b.end_turn()
	assert_str(b.queue[0]["id"]).is_equal("u1")        # the next tie goes to the other side
	b.end_turn()
	b.end_turn()
	assert_str(b.queue[0]["id"]).is_equal("u0")


func test_queue_is_recalculated_every_round_from_effective_pace() -> void:
	var b := H.battle([
		[0, Vector2i(0, 6), {"pace": 1.6}],
		[1, Vector2i(6, 0), {"pace": 1.5}],
	])
	b.apply_effect(H.unit(b, 0), "t:drain", "drain_pace", 2, 5)     # a timed effect on the monster (a zone changes no stat)
	b.begin()
	# 1.6 - 2 points = 1.4 < 1.5: the drained monster acts second
	assert_array(_ids(b)).is_equal([[&"u1", "1.5"], [&"u0", "1.4"]])
	assert_float(BattleStats.pace(b, H.unit(b, 0))).is_equal_approx(1.4, 0.001)


func test_pace_floor_is_point_one() -> void:
	var b := H.battle([[0, Vector2i(0, 6), {"pace": 0.2}], [1, Vector2i(6, 0), {"pace": 1.5}]])
	b.apply_effect(H.unit(b, 0), "t:drain", "drain_pace", 3, 5)
	assert_float(BattleStats.pace(b, H.unit(b, 0))).is_equal_approx(0.1, 0.001)


func test_prep_bonus_is_part_of_the_unit_sheet() -> void:
	var b := H.battle([[0, Vector2i(0, 6), {"pace": 1.4, "pace_bonus": 0.2}], [1, Vector2i(6, 0), {"pace": 1.5}]])
	b.begin()
	assert_array(_ids(b)).is_equal([[&"u0", "1.6"], [&"u1", "1.5"]])
