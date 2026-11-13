extends GdUnitTestSuite
## Switches of battle/core/battle_experiment.gd from simulation S011 (temp_todo T38). Build rules
## since 2026-11-12: ground laid in battle lasts 2 rounds, one trap per trap skill and monster.
## Still test switches, off by default: a clock for unsprung traps, shield zone skills switched off.

const H := preload("res://tests/battle/helpers.gd")


func after_test() -> void:
	BattleExperiment.reset()


func _lava_field() -> BattleSkillDef:
	var op := BoardOp.new()
	op.ground = &"lava"
	return H.board_skill([op], [Vector2i.ZERO], "t_lava")


func _two_units(skills: Array) -> Battle:
	var b := H.battle([
		[0, Vector2i(3, 6), {"init": 9.0, "reach": 4, "skills": skills}],
		[1, Vector2i(3, 0), {"init": 5.0}],
	])
	b.begin()
	return b


func _end_round(b: Battle) -> void:
	var now := b.round_number
	while b.round_number == now and not b.over:
		b.end_turn()


func test_ground_laid_in_battle_stays_with_the_clock_switched_off() -> void:
	BattleExperiment.ground_rounds = 0
	var b := _two_units([_lava_field()])
	assert_bool(b.apply({"type": &"skill", "slot": 0, "anchor": Vector2i(3, 3)})).is_true()
	for _i in 4:
		_end_round(b)
	assert_str(String(b.board.at(Vector2i(3, 3)).ground)).is_equal("lava")


func test_ground_laid_in_battle_fades_at_the_end_of_the_following_round() -> void:
	BattleExperiment.ground_rounds = 2
	var b := _two_units([_lava_field()])
	assert_bool(b.apply({"type": &"skill", "slot": 0, "anchor": Vector2i(3, 3)})).is_true()
	_end_round(b)
	assert_str(String(b.board.at(Vector2i(3, 3)).ground)).is_equal("lava")       # round 2: still there
	_end_round(b)
	assert_str(String(b.board.at(Vector2i(3, 3)).ground)).is_equal("plain")      # round 3: gone
	assert_int(b.board.at(Vector2i(3, 3)).ground_until).is_equal(0)


func test_ground_of_the_starting_board_does_not_fade() -> void:
	BattleExperiment.ground_rounds = 2
	var b := _two_units([])
	b.board.at(Vector2i(1, 1)).ground = &"lava"
	for _i in 3:
		_end_round(b)
	assert_str(String(b.board.at(Vector2i(1, 1)).ground)).is_equal("lava")


func test_an_unsprung_trap_lapses_at_the_end_of_the_following_round() -> void:
	BattleExperiment.trap_rounds = 2
	var b := _two_units([H.surge([Vector2i.ZERO])])
	assert_bool(b.apply({"type": &"skill", "slot": 0, "anchor": Vector2i(3, 3)})).is_true()
	_end_round(b)
	assert_int(b.surges.size()).is_equal(1)
	_end_round(b)
	assert_int(b.surges.size()).is_equal(0)
	assert_int(b.board.at(Vector2i(3, 3)).surge).is_equal(-1)
	assert_int(H.events_of(b, &"surge_lapsed").size()).is_equal(1)


func test_a_trap_stays_without_the_switch() -> void:
	var b := _two_units([H.surge([Vector2i.ZERO])])
	assert_bool(b.apply({"type": &"skill", "slot": 0, "anchor": Vector2i(3, 3)})).is_true()
	for _i in 4:
		_end_round(b)
	assert_int(b.surges.size()).is_equal(1)


func test_with_a_trap_limit_of_one_a_second_trap_of_the_skill_moves_the_first() -> void:
	BattleExperiment.trap_cap = 1
	var b := _two_units([H.surge([Vector2i.ZERO])])
	assert_bool(b.apply({"type": &"skill", "slot": 0, "anchor": Vector2i(3, 3)})).is_true()
	assert_bool(b.apply({"type": &"skill", "slot": 0, "anchor": Vector2i(2, 4)})).is_true()
	assert_int(b.surges.size()).is_equal(1)
	assert_int(b.board.at(Vector2i(3, 3)).surge).is_equal(-1)
	assert_int(b.board.at(Vector2i(2, 4)).surge).is_greater(0)


func test_shield_zone_skills_are_unusable_with_the_switch_and_other_zones_are_not() -> void:
	var b := _two_units(["bark_veil", "gale"])
	assert_str(b.usage_error(H.unit(b, 0), 0)).is_empty()
	BattleExperiment.no_shield_zones = true
	assert_str(b.usage_error(H.unit(b, 0), 0)).contains("switched off")
	assert_str(b.usage_error(H.unit(b, 0), 1)).is_empty()


# ---------- Wellspring rules (build rules since 2026-11-13, gdd_battle §4.2) and the open switches of T39 ----------

func _well_battle(units: Array) -> Battle:
	var b := H.battle(units)
	BattleBoards.place_wells(b)
	b.begin()
	return b


func test_wellsprings_lie_on_the_centre_row_and_take_no_prop_or_mountain() -> void:
	var b := _well_battle([[0, Vector2i(3, 6), {}], [1, Vector2i(3, 0), {}]])
	for p: Vector2i in [Vector2i(1, 3), Vector2i(3, 3), Vector2i(5, 3)]:
		assert_str(String(b.board.at(p).ground)).is_equal("wellspring")
		assert_object(b.add_prop(&"clay_urn", p)).is_null()
		assert_bool(BattleBoardOps.raise_mountain(b, b.board.at(p))).is_false()
	assert_str(String(b.board.at(Vector2i(2, 3)).ground)).is_equal("plain")


func test_a_held_wellspring_damages_the_nearest_enemy_at_the_end_of_the_round() -> void:
	var b := _well_battle([
		[0, Vector2i(3, 3), {"init": 9.0}],
		[1, Vector2i(3, 0), {"init": 5.0, "hp": 5}],
		[1, Vector2i(6, 6), {"init": 4.0, "hp": 5}],
	])
	_end_round(b)
	assert_int(H.unit(b, 1).hp).is_equal(4)        # 3 squares away
	assert_int(H.unit(b, 2).hp).is_equal(5)        # 3 squares away and the same HP, but less initiative
	assert_int(H.unit(b, 0).hp).is_equal(H.unit(b, 0).max_hp)


func test_a_wellspring_tie_goes_to_the_enemy_with_more_hp() -> void:
	var b := _well_battle([
		[0, Vector2i(3, 3), {"init": 9.0}],
		[1, Vector2i(3, 0), {"init": 5.0, "hp": 4}],
		[1, Vector2i(6, 6), {"init": 4.0, "hp": 6}],
	])
	_end_round(b)
	assert_int(H.unit(b, 1).hp).is_equal(4)
	assert_int(H.unit(b, 2).hp).is_equal(5)


func test_two_enemies_around_a_monster_deal_one_damage_at_the_end_of_the_round() -> void:
	var b := H.battle([
		[0, Vector2i(2, 2), {"init": 9.0}],
		[0, Vector2i(4, 4), {"init": 8.0}],
		[1, Vector2i(3, 3), {"init": 5.0, "hp": 5}],
	])
	b.begin()
	_end_round(b)
	assert_int(H.unit(b, 2).hp).is_equal(4)
	assert_int(H.unit(b, 0).hp).is_equal(H.unit(b, 0).max_hp)   # one enemy next to it is not enough


func test_turns_per_round_count_from_the_second_round() -> void:
	var b := H.battle([[0, Vector2i(3, 6), {"init": 9.0, "tpr": 2}], [1, Vector2i(3, 0), {"init": 5.0}]])
	b.begin()
	assert_int(b.queue.size()).is_equal(2)
	_end_round(b)
	assert_int(b.queue.size()).is_equal(3)


func test_a_monster_may_postpone_its_turn_once_per_round_before_it_acts() -> void:
	var b := H.battle([[0, Vector2i(3, 6), {"init": 9.0}], [1, Vector2i(3, 0), {"init": 5.0}], [1, Vector2i(5, 0), {"init": 4.0}]])
	b.begin()
	assert_str(b.check({"type": &"delay"})).is_not_empty()         # off by default
	BattleExperiment.delay_turn = true
	assert_bool(b.apply({"type": &"delay"})).is_true()
	assert_that(b.turn_owner).is_equal(H.unit(b, 1).id)
	assert_that(b.queue[2]["id"]).is_equal(H.unit(b, 0).id)
	b.end_turn()
	b.end_turn()
	assert_that(b.turn_owner).is_equal(H.unit(b, 0).id)
	assert_str(b.check({"type": &"delay"})).is_not_empty()         # once per round, and nobody acts after it
	assert_int(b.round_number).is_equal(1)


func test_with_the_switch_a_surge_waits_for_its_casters_next_turn() -> void:
	BattleExperiment.surge_at_caster = true
	var timed := H.surge([Vector2i.ZERO], 3, "timed")
	timed.surge_turns = 1
	var b := H.battle([[0, Vector2i(3, 4), {"init": 9.0, "reach": 4, "skills": [timed]}], [1, Vector2i(3, 1), {"init": 5.0}]])
	b.begin()
	assert_bool(b.apply({"type": &"skill", "slot": 0, "anchor": Vector2i(3, 1)})).is_true()
	b.end_turn()
	assert_int(b.surges.size()).is_equal(1)                         # one finished turn is not enough any more
	assert_int(H.unit(b, 1).hp).is_equal(H.unit(b, 1).max_hp)
	b.end_turn()                                                    # round 2 starts with the caster's turn
	assert_int(b.surges.size()).is_equal(0)
	assert_int(H.unit(b, 1).hp).is_less(H.unit(b, 1).max_hp)



func test_with_the_fair_switch_a_due_surge_waits_for_the_turn_of_the_monster_on_it() -> void:
	BattleExperiment.surge_fair = true
	var timed := H.surge([Vector2i.ZERO], 3, "timed")
	timed.surge_turns = 1
	var b := H.battle([
		[0, Vector2i(3, 4), {"init": 9.0, "reach": 4, "skills": [timed]}],
		[0, Vector2i(0, 6), {"init": 8.0}],
		[1, Vector2i(3, 1), {"init": 5.0}],
	])
	b.begin()
	assert_bool(b.apply({"type": &"skill", "slot": 0, "anchor": Vector2i(3, 1)})).is_true()
	b.end_turn()                                    # the cast turn
	b.end_turn()                                    # one finished turn: due, but the target has not acted
	assert_int(b.surges.size()).is_equal(1)
	assert_int(H.unit(b, 2).hp).is_equal(H.unit(b, 2).max_hp)
	b.end_turn()                                    # the target ends its turn on the square: now it fires
	assert_int(b.surges.size()).is_equal(0)
	assert_int(H.unit(b, 2).hp).is_less(H.unit(b, 2).max_hp)
