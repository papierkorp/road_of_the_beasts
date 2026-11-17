extends GdUnitTestSuite
## The review pack of 2026-11-17 (docs/todo T44) and the Pace ideas (T45): what became a rule on 2026-11-17 (a
## Strike pushes every struck square, one ground and zone level, nothing but veins and surrounding at the round
## end, created props last 2 rounds) and what is still a test switch (battle/core/battle_experiment.gd; on by
## default in the build, off in the rule tests: such a test sets its switch after building its battle).

const H := preload("res://tests/battle/helpers.gd")


func after_test() -> void:
	BattleExperiment.reset()


func _end_round(b: Battle) -> void:
	var now := b.round_number
	while b.round_number == now and not b.over:
		b.end_turn()


func _ground_skill(ground: StringName, id: String) -> BattleSkillDef:
	var op := BoardOp.new()
	op.ground = ground
	return H.board_skill([op], [Vector2i.ZERO], id)


func test_the_pack_is_the_build_default_and_can_be_switched_off() -> void:
	BattleExperiment.reset()
	assert_int(BattleExperiment.vein_late_round).is_equal(3)
	assert_int(BattleExperiment.damage_from_round).is_equal(2)
	assert_str(BattleExperiment.pressure_mode).is_equal("none")
	BattleExperiment.pack(false)
	assert_int(BattleExperiment.vein_late_round).is_equal(0)
	assert_int(BattleExperiment.damage_from_round).is_equal(1)
	assert_str(BattleExperiment.pressure_mode).is_equal("idle")


func test_a_strike_pushes_the_far_square_of_its_shape_too() -> void:
	var thrust := H.strike("thrust", false)
	thrust.strike_push = true
	var b := H.battle([[0, Vector2i(3, 5), {"pace": 1.9, "ap": 5, "skills": [thrust]}], [1, Vector2i(3, 3), {"pace": 1.2}]])
	b.begin()
	var act := {"type": &"skill", "slot": 0, "dir": Vector2i.UP, "push_dir": Vector2i.ZERO, "origin": Vector2i(3, 5)}
	assert_bool(b.apply(act)).is_true()
	assert_that(H.unit(b, 1).pos).is_equal(Vector2i(3, 2))          # two squares away is pushed too, along its line


func test_ground_has_one_level_and_laying_it_again_restarts_its_clock() -> void:
	var b := H.battle([[0, Vector2i(3, 6), {}], [1, Vector2i(3, 0), {}]])
	var c := b.board.at(Vector2i(3, 3))
	assert_str(BattleBoardOps.lay_ground(b, c, &"lava")).is_equal("new")
	b.round_number = 2
	assert_str(BattleBoardOps.lay_ground(b, c, &"lava")).is_equal("refresh")
	assert_int(c.level).is_equal(1)
	assert_int(c.ground_until).is_equal(3)


func test_a_zone_without_stats_changes_no_stat_and_has_one_level() -> void:
	var b := H.battle([[0, Vector2i(3, 3), {"pace": 1.5, "reach": 3}], [1, Vector2i(3, 0), {}]])
	var mire := b.content.zone(&"mire")
	var cell := b.board.at(Vector2i(3, 3))
	BattleBoardOps.land_zone(b, cell, mire, 1, &"", 2, Vector2i.ZERO, Vector2i(3, 3))
	assert_float(BattleStats.pace(b, H.unit(b, 0))).is_equal_approx(1.5, 0.001)
	assert_int(BattleStats.reach(b, H.unit(b, 0))).is_equal(3)
	BattleBoardOps.land_zone(b, cell, mire, 1, &"", 2, Vector2i.ZERO, Vector2i(3, 3))
	assert_int(cell.zone.level).is_equal(1)


func test_round_end_ground_acts_at_the_end_of_the_occupants_turn_instead() -> void:
	var b := H.battle([[0, Vector2i(3, 6), {"pace": 1.9}], [1, Vector2i(3, 0), {"pace": 1.2, "reach": 9, "skills": [_ground_skill(&"blight", "t_blight")]}]])
	b.begin()
	b.end_turn()                                                 # u0 has acted
	assert_bool(b.apply({"type": &"skill", "slot": 0, "anchor": Vector2i(3, 6)})).is_true()   # Blight under it
	_end_round(b)
	assert_int(H.unit(b, 0).hp).is_equal(H.unit(b, 0).max_hp)    # nothing at the round end: it gets a turn to leave
	b.end_turn()                                                 # it stays and ends its turn on the Blight
	assert_int(H.unit(b, 0).hp).is_equal(H.unit(b, 0).max_hp - 1)


func test_a_brazier_hits_who_ends_a_turn_next_to_it_not_everyone_at_the_round_end() -> void:
	var b := H.battle([[0, Vector2i(3, 3), {"pace": 1.9}], [1, Vector2i(3, 0), {"pace": 1.2}]])
	b.add_prop(&"ember_brazier", Vector2i(4, 3))
	b.begin()
	b.end_turn()
	assert_int(H.unit(b, 0).hp).is_equal(H.unit(b, 0).max_hp - 1)   # at the end of its own turn
	_end_round(b)
	assert_int(H.unit(b, 0).hp).is_equal(H.unit(b, 0).max_hp - 1)   # and not again at the round end


func test_dragon_veins_deal_two_from_the_late_round_on() -> void:
	var b := H.battle([[0, Vector2i(3, 3), {"pace": 1.9, "hp": 9}], [1, Vector2i(3, 0), {"pace": 1.2, "hp": 9}]])
	var vein := b.board.at(Vector2i(3, 3))
	vein.ground = GroundDef.WELL
	BattleExperiment.flank = false
	BattleExperiment.vein_late_round = 2
	BattleExperiment.vein_late_damage = 2
	b.begin()
	_end_round(b)
	assert_int(H.unit(b, 1).hp).is_equal(8)                      # round 1: 1
	_end_round(b)
	assert_int(H.unit(b, 1).hp).is_equal(6)                      # round 2: 2


func test_a_prop_created_by_a_skill_lapses_after_two_rounds() -> void:
	var op := BoardOp.new()
	op.op = BoardOp.CREATE_PROP
	op.prop = &"earth_wall"
	var wall := H.board_skill([op], [Vector2i.ZERO], "t_wall")
	var b := H.battle([[0, Vector2i(3, 6), {"pace": 1.9, "reach": 6, "skills": [wall]}], [1, Vector2i(3, 0), {"pace": 1.2}]])
	b.add_prop(&"earth_wall", Vector2i(0, 3))                    # a prop of the board has no clock
	b.begin()
	assert_bool(b.apply({"type": &"skill", "slot": 0, "anchor": Vector2i(3, 3)})).is_true()
	_end_round(b)
	assert_object(b.board.prop_at(Vector2i(3, 3), Board.GROUND)).is_not_null()
	_end_round(b)
	assert_object(b.board.prop_at(Vector2i(3, 3), Board.GROUND)).is_null()
	assert_object(b.board.prop_at(Vector2i(0, 3), Board.GROUND)).is_not_null()


func test_the_round_end_forecast_names_who_is_hit_and_changes_nothing() -> void:
	var b := H.battle([[0, Vector2i(3, 3), {"pace": 1.9, "hp": 9}], [1, Vector2i(3, 0), {"pace": 1.2, "hp": 1}]])
	b.board.at(Vector2i(3, 3)).ground = GroundDef.WELL
	b.begin()
	var before := b.state_hash()
	var f := BattleTurn.round_end_forecast(b)
	assert_int(f["hits"].size()).is_equal(1)
	assert_that(f["hits"][0]["unit"]).is_equal(H.unit(b, 1).id)
	assert_str(f["hits"][0]["source"]).is_equal("Dragon Vein")
	assert_array(f["falls"]).contains([H.unit(b, 1).id])
	assert_that(b.state_hash()).is_equal(before)
	assert_int(b.round_number).is_equal(1)


# ---------- Pace ideas of 2026-11-17 (docs/todo T45) ----------

func test_the_whole_number_of_pace_above_one_is_the_number_of_waits_in_a_battle() -> void:
	var b := H.battle([[0, Vector2i(3, 6), {"pace": 2.3}], [1, Vector2i(3, 0), {"pace": 1.9}], [1, Vector2i(5, 0), {"pace": 1.4}]])
	b.begin()
	assert_int(b.waits_left(H.unit(b, 0))).is_equal(1)
	assert_int(b.waits_total(H.unit(b, 1))).is_equal(0)
	assert_bool(b.apply({"type": &"delay"})).is_true()             # Pace 2.3: one Wait
	assert_that(b.turn_owner).is_equal(H.unit(b, 1).id)
	assert_str(b.check({"type": &"delay"})).contains("too slow")  # Pace 1.9: none
	_end_round(b)
	assert_that(b.turn_owner).is_equal(H.unit(b, 0).id)
	assert_int(b.waits_left(H.unit(b, 0))).is_equal(0)
	assert_str(b.check({"type": &"delay"})).contains("no Wait left")


func _vein_duel() -> Battle:
	var b := H.battle([[0, Vector2i(1, 3), {"pace": 1.9, "hp": 1}], [1, Vector2i(5, 3), {"pace": 1.2, "hp": 1}]])
	b.board.at(Vector2i(1, 3)).ground = GroundDef.WELL
	b.board.at(Vector2i(5, 3)).ground = GroundDef.WELL
	BattleExperiment.flank = false
	return b


func test_in_pace_order_the_vein_of_the_faster_taker_acts_first_and_wins() -> void:
	var b := _vein_duel()
	b.begin()
	_end_round(b)
	assert_bool(b.over).is_true()
	assert_bool(b.draw).is_false()
	assert_int(b.winner_side).is_equal(0)
	assert_that(b.board.at(Vector2i(1, 3)).owner_unit).is_equal(H.unit(b, 0).id)


func test_the_taker_of_a_vein_stays_when_an_ally_touches_it_later() -> void:
	var b := H.battle([[0, Vector2i(3, 4), {"pace": 1.9}], [0, Vector2i(2, 3), {"pace": 1.5}], [1, Vector2i(3, 0), {"pace": 1.2}]])
	b.board.at(Vector2i(3, 3)).ground = GroundDef.WELL
	b.begin()
	assert_bool(b.apply({"type": &"step", "to": Vector2i(3, 3)})).is_true()
	assert_bool(b.apply({"type": &"step", "to": Vector2i(3, 4)})).is_true()
	b.end_turn()
	assert_bool(b.apply({"type": &"step", "to": Vector2i(3, 3)})).is_true()
	assert_that(b.board.at(Vector2i(3, 3)).owner_unit).is_equal(H.unit(b, 0).id)

