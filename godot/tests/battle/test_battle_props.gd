extends GdUnitTestSuite
## Prop rework of 2026-11-14 (build draft, not a GDD rule): walkable props and traps, the four
## moments a prop acts at (entered, hit, destroyed, round end), props on Dragon Veins, and the
## per-turn usage limit of a skill.

const H := preload("res://tests/battle/helpers.gd")


func before_test() -> void:
	BattleExperiment.reset()


func after_test() -> void:
	BattleExperiment.reset()


func test_a_walkable_trap_blocks_nothing_and_springs_on_the_monster_that_enters() -> void:
	var b := H.battle([[0, Vector2i(3, 4), {"init": 9.0}], [1, Vector2i(6, 0)]])
	b.add_prop(&"spike_trap", Vector2i(3, 3))
	b.begin()
	var opts := BattleMoves.options(b, H.unit(b, 0), BattleMoves.step_profile())
	assert_bool(opts.has(Vector2i(3, 3))).is_true()                       # the square can be entered
	assert_int(opts[Vector2i(3, 3)]["harm"]).is_equal(2)                  # and the search knows what it costs
	assert_bool(b.apply({"type": &"step", "to": Vector2i(3, 3)})).is_true()
	assert_int(H.unit(b, 0).hp).is_equal(3)
	assert_object(b.board.at(Vector2i(3, 3)).prop).is_null()              # used up
	assert_int(H.events_of(b, &"trap_sprung").size()).is_equal(1)


func test_a_monster_pushed_onto_a_trap_springs_it_without_a_collision() -> void:
	var b := H.battle([[0, Vector2i(3, 4)], [1, Vector2i(6, 0)]])
	b.add_prop(&"spike_trap", Vector2i(3, 3))
	b.begin()
	assert_bool(BattleDisplace.shove(b, H.unit(b, 0), H.UP, "test")).is_true()
	assert_that(H.unit(b, 0).pos).is_equal(Vector2i(3, 3))
	assert_int(H.unit(b, 0).hp).is_equal(3)
	assert_int(H.events_of(b, &"collision").size()).is_equal(0)


func test_a_vortex_trap_pulls_the_neighbours_into_the_monster_that_sprang_it() -> void:
	var b := H.battle([[0, Vector2i(3, 4), {"init": 9.0}], [1, Vector2i(2, 3)], [1, Vector2i(5, 3)]])
	b.add_prop(&"vortex_trap", Vector2i(3, 3))
	b.begin()
	b.apply({"type": &"step", "to": Vector2i(3, 3)})
	assert_that(H.unit(b, 1).pos).is_equal(Vector2i(2, 3))                # pulled against the occupied square
	assert_array([H.unit(b, 0).hp, H.unit(b, 1).hp, H.unit(b, 2).hp]).is_equal([4, 4, 5])
	assert_object(b.board.at(Vector2i(3, 3)).prop).is_null()


func test_a_solid_wall_blocks_and_the_wall_skill_raises_three_in_a_line() -> void:
	var b := H.battle([[0, Vector2i(3, 5), {"init": 9.0, "reach": 3, "skills": ["raise_wall"]}], [1, Vector2i(6, 0)]])
	b.begin()
	assert_bool(b.apply({"type": &"skill", "slot": 0, "anchor": Vector2i(3, 4)})).is_true()
	for x in [2, 3, 4]:
		var prop: BoardProp = b.board.at(Vector2i(x, 4)).prop
		assert_str(String(prop.def.id)).is_equal("earth_wall")
	assert_int(b.ap).is_equal(1)
	assert_bool(BattleMoves.options(b, H.unit(b, 0), BattleMoves.step_profile()).has(Vector2i(3, 4))).is_false()


func test_a_thorn_idol_answers_every_hit_it_survives() -> void:
	var b := H.battle([[0, Vector2i(3, 4), {"init": 9.0, "ap": 5, "skills": [H.strike()]}], [1, Vector2i(2, 2)], [1, Vector2i(5, 5)]])
	b.add_prop(&"thorn_idol", Vector2i(3, 3))
	b.begin()
	b.apply({"type": &"skill", "slot": 0, "dir": H.UP})                   # 2 damage to the idol, 1 HP left
	assert_int(b.board.at(Vector2i(3, 3)).prop.hp).is_equal(1)
	assert_array([H.unit(b, 0).hp, H.unit(b, 1).hp, H.unit(b, 2).hp]).is_equal([4, 4, 5])
	BattleExperiment.once_per_turn = false
	b.apply({"type": &"skill", "slot": 0, "dir": H.UP})                   # destroyed: no answer any more
	assert_object(b.board.at(Vector2i(3, 3)).prop).is_null()
	assert_array([H.unit(b, 0).hp, H.unit(b, 1).hp]).is_equal([4, 4])


func test_a_brazier_burns_its_cardinal_neighbours_at_every_round_end() -> void:
	var b := H.battle([[0, Vector2i(3, 4), {"init": 9.0}], [1, Vector2i(4, 2)], [1, Vector2i(2, 3)]])
	b.add_prop(&"ember_brazier", Vector2i(3, 3))
	b.begin()
	for _i in 3:
		b.end_turn()
	assert_int(b.round_number).is_equal(2)
	assert_array([H.unit(b, 0).hp, H.unit(b, 1).hp, H.unit(b, 2).hp]).is_equal([4, 5, 4])   # the diagonal one is spared
	for _i in 3:
		b.end_turn()
	assert_array([H.unit(b, 0).hp, H.unit(b, 2).hp]).is_equal([3, 3])


func test_a_prop_on_a_dragon_vein_keeps_everyone_from_holding_it() -> void:
	var b := H.battle([[0, Vector2i(3, 4), {"init": 9.0}], [1, Vector2i(3, 0)]])
	b.set_ground(Vector2i(3, 3), GroundDef.WELL)
	assert_object(b.add_prop(&"earth_wall", Vector2i(3, 3))).is_not_null()
	b.begin()
	assert_bool(BattleMoves.options(b, H.unit(b, 0), BattleMoves.step_profile()).has(Vector2i(3, 3))).is_false()
	b.end_turn()
	b.end_turn()
	assert_int(H.unit(b, 1).hp).is_equal(5)                               # nobody stands on it: no vein damage


func test_a_skill_can_be_used_as_often_per_turn_as_its_usage_limit_says() -> void:
	var twice := H.strike()
	twice.usage_limit = 2
	var b := H.battle([[0, Vector2i(3, 4), {"init": 9.0, "ap": 9, "skills": [H.strike(), twice]}], [1, Vector2i(3, 3), {"hp": 9}]])
	b.begin()
	assert_bool(b.apply({"type": &"skill", "slot": 0, "dir": H.UP})).is_true()
	assert_bool(b.apply({"type": &"skill", "slot": 0, "dir": H.UP})).is_false()   # build rule: once per turn
	assert_bool(b.apply({"type": &"skill", "slot": 1, "dir": H.UP})).is_true()
	assert_bool(b.apply({"type": &"skill", "slot": 1, "dir": H.UP})).is_true()
	assert_bool(b.apply({"type": &"skill", "slot": 1, "dir": H.UP})).is_false()
	b.end_turn()
	b.end_turn()
	assert_bool(b.apply({"type": &"skill", "slot": 0, "dir": H.UP})).is_true()    # a new turn, a new use


func test_six_kit_slots_are_valid() -> void:
	var s := H.sheet({"skills": [H.strike(), H.strike(), H.strike(), H.strike(), H.strike(), H.strike()]})
	assert_array(s.problems()).is_empty()
	s.skills.append(H.strike())
	assert_array(s.problems()).contains(["more than 6 slots"])


func test_stamina_pays_one_per_square_and_comes_back_at_the_round_end() -> void:
	BattleExperiment.stamina = true
	BattleExperiment.once_per_turn = false
	var b := H.battle([[0, Vector2i(0, 6), {"init": 9.0, "move": 4, "ap": 3, "skills": ["run"]}], [1, Vector2i(6, 0)]])
	b.begin()
	var me := H.unit(b, 0)
	var run := BattleMoves.profile_of(H.skill("run"))
	assert_int(me.stamina).is_equal(4)
	assert_bool(BattleMoves.options(b, me, run).has(Vector2i(0, 3))).is_true()     # the range of the skill: 3 squares
	assert_bool(BattleMoves.options(b, me, run).has(Vector2i(0, 2))).is_false()    # not the whole pool in one use
	assert_bool(b.apply({"type": &"skill", "slot": 0, "to": Vector2i(0, 3)})).is_true()
	assert_array([b.ap, me.stamina]).is_equal([2, 1])                     # its AP and 1 Stamina per square
	assert_bool(BattleMoves.options(b, me, run).has(Vector2i(0, 1))).is_false()    # 1 Stamina left: 1 square
	assert_bool(b.apply({"type": &"skill", "slot": 0, "to": Vector2i(0, 2)})).is_true()
	assert_array([b.ap, me.stamina]).is_equal([1, 0])
	assert_str(b.check({"type": &"skill", "slot": 0, "to": Vector2i(0, 1)})).contains("Stamina")
	assert_bool(b.apply({"type": &"step", "to": Vector2i(0, 1)})).is_true()                       # Step: 1 AP, no Stamina
	assert_array([b.ap, me.stamina]).is_equal([0, 0])
	b.end_turn()
	b.end_turn()
	assert_int(me.stamina).is_equal(1)                                    # +1 at the round end
	BattleExperiment.stamina_ap = false
	assert_int(H.skill("run").cost()).is_equal(0)                          # Stamina only


func test_a_generated_board_never_starts_with_a_prop_on_a_dragon_vein() -> void:
	for board_seed in range(1, 40):
		var b := Battle.new()
		BattleBoards.build(b, &"3v3", board_seed)
		for cell in b.board.cells:
			if cell.ground == GroundDef.WELL:
				assert_object(cell.prop).is_null()


func test_the_prop_pairs_switch_sets_how_many_props_a_board_starts_with() -> void:
	for pairs in [0, 4]:
		BattleExperiment.map_props = pairs
		var b := Battle.new(Board.new(7), BattleContent.shared())
		BattleBoards.build(b, &"3v3", 0)
		var props := 0
		for cell in b.board.cells:
			props += int(cell.prop != null or cell.air_prop != null)
			assert_bool(cell.prop != null and cell.ground == GroundDef.WELL).is_false()
		assert_int(props).is_equal(pairs * 2)
