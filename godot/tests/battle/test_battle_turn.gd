extends GdUnitTestSuite
## Turn structure, AP, usage, timing of ground / zone effects, round end, battle end
## (gdd_battle §2.1–§2.4, §4.2, §4.5; gdd_skills §2 Usage and Repetition).

const H := preload("res://tests/battle/helpers.gd")


func after_test() -> void:
	BattleExperiment.reset()


func test_ap_per_turn_is_the_ap_stat_and_step_costs_one() -> void:
	var b := H.battle([[0, Vector2i(3, 3), {"ap": 2, "init": 9.0}], [1, Vector2i(6, 0)]])
	b.begin()
	assert_int(b.ap).is_equal(2)
	assert_bool(b.apply({"type": &"step", "to": Vector2i(3, 2)})).is_true()
	assert_int(b.ap).is_equal(1)
	assert_that(H.unit(b, 0).pos).is_equal(Vector2i(3, 2))
	assert_bool(b.apply({"type": &"step", "to": Vector2i(3, 1)})).is_true()
	assert_int(b.ap).is_equal(0)
	# an invalid attempt consumes neither AP nor usage and changes nothing
	assert_str(b.check({"type": &"step", "to": Vector2i(3, 0)})).contains("1 AP")
	assert_bool(b.apply({"type": &"step", "to": Vector2i(3, 0)})).is_false()
	assert_int(b.ap).is_equal(0)
	assert_that(H.unit(b, 0).pos).is_equal(Vector2i(3, 1))


func test_step_moves_exactly_one_orthogonal_square_and_ignores_slow_and_rubble() -> void:
	var slow := H.zone_skill([FieldEffect.make("slow", 2, 2)])
	var b := H.battle([[0, Vector2i(3, 3), {"ap": 4, "init": 9.0, "move": 1}], [1, Vector2i(6, 0)]])
	H.zone_on(b, Vector2i(3, 3), slow.zone)
	b.set_ground(Vector2i(3, 2), &"rubble")
	b.begin()
	assert_str(b.check({"type": &"step", "to": Vector2i(4, 2)})).is_not_empty()   # no diagonal step
	assert_str(b.check({"type": &"step", "to": Vector2i(3, 1)})).is_not_empty()   # not two squares
	assert_bool(b.apply({"type": &"step", "to": Vector2i(3, 2)})).is_true()        # Rubble costs Step nothing extra
	assert_int(b.ap).is_equal(3)


func test_every_skill_use_pays_its_authored_ap() -> void:
	var b := H.battle([[0, Vector2i(3, 3), {"ap": 3, "init": 9.0, "skills": ["slowing_zone_example", "run"]}], [1, Vector2i(6, 0)]])
	b.begin()
	assert_bool(b.apply({"type": &"skill", "slot": 0, "anchor": Vector2i(3, 2)})).is_true()   # zone: 1 AP
	assert_int(b.ap).is_equal(2)
	assert_bool(b.apply({"type": &"skill", "slot": 1, "to": Vector2i(3, 5)})).is_true()        # Run: 1 AP
	assert_int(b.ap).is_equal(1)
	assert_bool(b.apply({"type": &"skill", "slot": 1, "to": Vector2i(3, 3)})).is_true()
	assert_int(b.ap).is_equal(0)
	assert_str(b.check({"type": &"skill", "slot": 0, "anchor": Vector2i(3, 4)})).contains("AP")


func test_once_per_round_counts_per_equipped_instance_and_resets_with_the_global_round() -> void:
	BattleExperiment.tpr_from_round = 1       # extra turns as from round 2 on (in round 1 every monster has one turn)
	var limited := H.zone_skill([FieldEffect.make("slow", 1, 2)])
	limited.repetition = "once_per_round"
	var b := H.battle([[0, Vector2i(3, 3), {"ap": 5, "init": 9.0, "tpr": 2, "skills": [limited, limited]}], [1, Vector2i(6, 0), {"init": 1.0}]])
	b.begin()
	assert_bool(b.apply({"type": &"skill", "slot": 0, "anchor": Vector2i(3, 2)})).is_true()
	assert_str(b.check({"type": &"skill", "slot": 0, "anchor": Vector2i(3, 4)})).contains("already used this round")
	# the second copy in its own slot has its own allowance
	assert_bool(b.apply({"type": &"skill", "slot": 1, "anchor": Vector2i(3, 4)})).is_true()
	b.end_turn()                               # the extra turn in the same round does not reset it
	assert_str(b.turn_owner).is_equal("u0")
	assert_str(b.check({"type": &"skill", "slot": 0, "anchor": Vector2i(2, 3)})).contains("already used this round")
	b.end_turn()
	b.end_turn()                               # round 2
	assert_int(b.round_number).is_equal(2)
	assert_str(b.check({"type": &"skill", "slot": 0, "anchor": Vector2i(2, 3)})).is_empty()


func test_end_of_turn_order_push_then_ground_damage_on_the_landing_square() -> void:
	var push := H.zone_skill([FieldEffect.make("push", 1)])
	var b := H.battle([[0, Vector2i(2, 3), {"init": 9.0}], [1, Vector2i(6, 0)]])
	H.zone_on(b, Vector2i(2, 3), push.zone, 1, 1, H.RIGHT)
	b.set_ground(Vector2i(2, 3), &"lava", 2)    # where the turn ends before the push
	b.set_ground(Vector2i(3, 3), &"lava", 1)    # the landing square
	b.begin()
	b.end_turn()
	assert_that(H.unit(b, 0).pos).is_equal(Vector2i(3, 3))
	assert_int(H.unit(b, 0).hp).is_equal(4)     # Lava I of the landing square, not Lava II


func test_mend_comes_after_end_of_turn_ground_damage_for_a_1x1() -> void:
	var mend := H.zone_skill([FieldEffect.make("mend", 1, 2)])
	var b := H.battle([[0, Vector2i(2, 3), {"init": 9.0, "current_hp": 3}], [0, Vector2i(4, 3), {"init": 8.0, "current_hp": 1}], [1, Vector2i(6, 0)]])
	for p in [Vector2i(2, 3), Vector2i(4, 3)]:
		H.zone_on(b, p, mend.zone, 1, 1)
		b.set_ground(p, &"lava", 1)
	b.begin()
	b.end_turn()
	assert_int(H.unit(b, 0).hp).is_equal(3)     # 3 - 1 Lava, then + 1 mend
	b.end_turn()
	assert_bool(H.unit(b, 1).defeated).is_true()  # Lava at 1 HP is lethal before mend


func test_mend_heals_min_two_and_level_and_never_above_max_hp() -> void:
	var mend := H.zone_skill([FieldEffect.make("mend", 1, 2)])
	var b := H.battle([[0, Vector2i(2, 3), {"init": 9.0, "hp": 6, "current_hp": 1}], [1, Vector2i(4, 3), {"init": 8.0, "hp": 6, "current_hp": 5}]])
	H.zone_on(b, Vector2i(2, 3), mend.zone, 1, 3, Vector2i.ZERO, Vector2i.ZERO, 9)   # level III heals 2
	H.zone_on(b, Vector2i(4, 3), mend.zone, 2, 2, Vector2i.ZERO, Vector2i.ZERO, 9)   # zones work for enemies too
	b.begin()
	b.end_turn()
	assert_int(H.unit(b, 0).hp).is_equal(3)
	b.end_turn()
	assert_int(H.unit(b, 1).hp).is_equal(6)     # 5 + 2, capped at max HP 6


func test_start_of_turn_blight_and_voidscar_and_on_enter_thornbed_and_mossbed() -> void:
	var b := H.battle([
		[0, Vector2i(1, 1), {"init": 9.0}],
		[0, Vector2i(3, 1), {"init": 8.0}],
		[0, Vector2i(5, 1), {"init": 7.0, "ap": 4, "current_hp": 2}],
		[1, Vector2i(6, 6)],
	])
	b.set_ground(Vector2i(1, 1), &"blight", 2)
	b.set_ground(Vector2i(3, 1), &"voidscar")
	b.set_ground(Vector2i(5, 2), &"thornbed", 1)
	b.set_ground(Vector2i(5, 3), &"mossbed")
	b.begin()
	assert_int(H.unit(b, 0).hp).is_equal(3)     # Blight II at the start of its turn
	b.end_turn()
	assert_int(H.unit(b, 1).hp).is_equal(4)     # Voidscar: 1
	b.end_turn()
	assert_bool(b.apply({"type": &"step", "to": Vector2i(5, 2)})).is_true()
	assert_int(H.unit(b, 2).hp).is_equal(1)     # Thornbed I on entry
	assert_bool(b.apply({"type": &"step", "to": Vector2i(5, 3)})).is_true()
	assert_int(H.unit(b, 2).hp).is_equal(2)     # Mossbed heals 1 on entry


func test_placing_ground_under_an_occupant_is_not_entry() -> void:
	var field := H.board_skill([BoardOp.make("ground", &"thornbed", true)])
	var b := H.battle([[0, Vector2i(3, 3), {"init": 9.0, "skills": [field]}], [1, Vector2i(3, 4), {"hp": 5}]])
	b.begin()
	assert_bool(b.apply({"type": &"skill", "slot": 0, "anchor": Vector2i(3, 4)})).is_true()
	assert_str(b.board.at(Vector2i(3, 4)).ground).is_equal("thornbed")
	assert_int(H.unit(b, 1).hp).is_equal(5)


func test_a_passive_can_ignore_a_ground_type() -> void:
	var heatproof := H.passive("t_heatproof", {"ignores_grounds": [&"lava"] as Array[StringName]})
	var b := H.battle([[0, Vector2i(3, 3), {"init": 9.0, "skills": [heatproof]}], [1, Vector2i(6, 6)]])
	b.set_ground(Vector2i(3, 3), &"lava", 2)
	b.begin()
	b.end_turn()
	assert_int(H.unit(b, 0).hp).is_equal(5)


func test_zone_lasts_its_duration_in_rounds_and_ticks_at_round_end() -> void:
	var b := H.battle([[0, Vector2i(3, 3), {"init": 9.0, "skills": ["slowing_zone_example"]}], [1, Vector2i(6, 0)]])
	b.begin()
	b.apply({"type": &"skill", "slot": 0, "anchor": Vector2i(3, 1)})
	assert_int(b.board.at(Vector2i(3, 1)).zone.duration).is_equal(2)
	b.end_turn()
	b.end_turn()                                # round 2
	assert_int(b.board.at(Vector2i(3, 1)).zone.duration).is_equal(1)
	b.end_turn()
	b.end_turn()                                # round 3: expired and removed, ground untouched
	assert_object(b.board.at(Vector2i(3, 1)).zone).is_null()
	assert_str(b.board.at(Vector2i(3, 1)).ground).is_equal("plain")


func test_timed_self_effect_lasts_n_following_rounds_and_only_refreshes() -> void:
	var b := H.battle([[0, Vector2i(3, 3), {"init": 5.0, "ap": 3, "skills": ["focus_reference"]}], [1, Vector2i(6, 0), {"init": 5.5}]])
	b.begin()
	b.end_turn()                                # enemy (5.5) first, then the caster
	assert_bool(b.apply({"type": &"skill", "slot": 0})).is_true()
	assert_bool(b.apply({"type": &"skill", "slot": 0})).is_true()   # recast: refresh, no stacking
	assert_float(BattleStats.initiative(b, H.unit(b, 0))).is_equal(6.0)
	b.end_turn()
	assert_int(b.round_number).is_equal(2)
	assert_str(b.queue[0]["id"]).is_equal("u0")  # 6.0 beats 5.5 in rounds 2 and 3
	b.end_turn()
	b.end_turn()
	assert_int(b.round_number).is_equal(3)
	assert_str(b.queue[0]["id"]).is_equal("u0")
	b.end_turn()
	b.end_turn()
	assert_int(b.round_number).is_equal(4)       # ended at the round end of the 2nd following round
	assert_str(b.queue[0]["id"]).is_equal("u1")
	assert_float(BattleStats.initiative(b, H.unit(b, 0))).is_equal(5.0)


func test_late_round_pressure_converts_all_equally_far_squares_together() -> void:
	var b := H.battle([[0, Vector2i(0, 4), {"init": 9.0}], [1, Vector2i(4, 0)]], 5)
	b.voidscar_from = 2
	b.begin()
	b.end_turn()
	b.end_turn()                                # end of round 1: not yet
	assert_str(b.board.at(Vector2i(0, 0)).ground).is_equal("plain")
	b.end_turn()
	b.end_turn()                                # end of round 2: both far corners are 4 away
	assert_str(b.board.at(Vector2i(0, 0)).ground).is_equal("voidscar")
	assert_str(b.board.at(Vector2i(4, 4)).ground).is_equal("voidscar")
	assert_str(b.board.at(Vector2i(1, 1)).ground).is_equal("plain")


func test_arena_collapse_damages_everyone_once_no_free_square_is_left() -> void:
	var b := H.battle([[0, Vector2i(0, 2), {"init": 9.0}], [1, Vector2i(2, 0)]], 3)
	for cell in b.board.cells:
		if cell.pos != Vector2i(0, 2) and cell.pos != Vector2i(2, 0):
			cell.ground = &"voidscar"
	b.voidscar_from = 1
	b.begin()
	b.end_turn()
	b.end_turn()
	assert_int(H.unit(b, 0).hp).is_equal(4)
	assert_int(H.unit(b, 1).hp).is_equal(4)


func test_battle_ends_when_a_side_has_no_monsters_and_pending_surges_lapse() -> void:
	var b := H.battle([
		[0, Vector2i(3, 3), {"init": 9.0, "ap": 3, "skills": [H.strike(), H.surge([Vector2i.ZERO])]}],
		[1, Vector2i(3, 2), {"hp": 2}],
	])
	b.begin()
	assert_bool(b.apply({"type": &"skill", "slot": 1, "anchor": Vector2i(3, 4)})).is_true()
	assert_int(b.surges.size()).is_equal(1)
	assert_bool(b.apply({"type": &"skill", "slot": 0, "dir": H.UP})).is_true()
	assert_bool(b.over).is_true()
	assert_int(b.winner_side).is_equal(0)
	assert_bool(b.draw).is_false()
	assert_int(b.surges.size()).is_equal(0)
	assert_int(b.board.at(Vector2i(3, 4)).surge).is_equal(-1)
	assert_str(b.check({"type": &"end_turn"})).is_equal("the battle is over")


func test_simultaneous_defeat_of_the_last_monsters_is_a_draw() -> void:
	# T04 walkthroughs 1 and 5: a Clay Urn destroyed by the Strike hits both last monsters
	var b := H.battle([
		[0, Vector2i(2, 3), {"init": 9.0, "current_hp": 1, "skills": [H.strike()]}],
		[1, Vector2i(2, 1), {"current_hp": 1}],
	])
	b.add_prop(&"clay_urn", Vector2i(2, 2))
	b.begin()
	assert_bool(b.apply({"type": &"skill", "slot": 0, "dir": H.UP})).is_true()
	assert_bool(b.over).is_true()
	assert_bool(b.draw).is_true()
	assert_int(b.winner_side).is_equal(-1)
	var r := BattleSetup.make_result(b)
	assert_bool(r.draw).is_true()
	assert_int(r.survivors(0)).is_equal(0)
	assert_int(r.survivors(1)).is_equal(0)


func test_a_monster_that_falls_in_its_own_turn_passes_the_turn_on() -> void:
	var b := H.battle([
		[0, Vector2i(3, 3), {"init": 9.0, "current_hp": 1}],
		[0, Vector2i(0, 6), {"init": 2.0}],
		[1, Vector2i(6, 0), {"init": 5.0}],
	])
	b.set_ground(Vector2i(3, 2), &"thornbed", 1)
	b.begin()
	assert_bool(b.apply({"type": &"step", "to": Vector2i(3, 2)})).is_true()
	assert_bool(H.unit(b, 0).defeated).is_true()
	assert_bool(b.over).is_false()
	assert_str(b.turn_owner).is_equal("u2")      # the queue moved on by itself
	assert_int(b.ap).is_equal(3)
	assert_bool(b.end_turn()).is_true()
	assert_str(b.turn_owner).is_equal("u1")


func test_actions_of_the_wrong_monster_or_after_the_end_are_refused() -> void:
	var b := H.battle([[0, Vector2i(3, 3), {"init": 9.0, "skills": ["immovable"]}], [1, Vector2i(6, 0)]])
	assert_str(b.check({"type": &"end_turn"})).is_equal("no turn is running")    # not begun yet
	b.begin()
	assert_str(b.check({"type": &"step", "unit": &"u1", "to": Vector2i(6, 1)})).contains("not this monster's turn")
	assert_str(b.check({"type": &"skill", "slot": 0})).contains("passive")
	assert_str(b.check({"type": &"skill", "slot": 7})).contains("no such skill slot")
	assert_str(b.check({"type": &"dance"})).is_equal("unknown action")
	assert_int(b.actions.size()).is_equal(0)     # refused attempts are not logged
