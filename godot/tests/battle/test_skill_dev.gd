extends GdUnitTestSuite
## The development of a skill slot (docs/skills.md §8): levels 1 to 3, one option of the skill's kind per level
## above the first; the slot keeps its level when it takes another skill, and the options are chosen anew.

const H := preload("res://tests/battle/helpers.gd")


func _monster() -> MonsterInstance:
	var m := MonsterInstance.hatched(GameData.monster(&"blaze_tiger"))
	m.learn(&"fire_trail")
	m.learn(&"strike_jab")
	m.fresh = false
	return m


func test_the_options_follow_the_kind_of_the_skill() -> void:
	var c := H.content()
	assert_array(SkillDev.options(c.skill(&"strike_jab"))).contains([SkillDev.STRIKE_AREA, SkillDev.STRIKE_GROUND_OPT])
	assert_array(SkillDev.options(c.skill(&"run"))).contains([SkillDev.MOVE_RANGE, SkillDev.MOVE_PROPS, SkillDev.MOVE_MONSTERS, SkillDev.MOVE_GROUND])
	assert_array(SkillDev.options(c.skill(&"lava_field"))).is_equal([SkillDev.LAY_AREA, SkillDev.LAY_ROUNDS])
	assert_array(SkillDev.options(c.skill(&"brace"))).contains([SkillDev.BUFF_ROUNDS])
	for id: StringName in c.skills:
		for o in SkillDev.options(c.skill(id)):
			assert_bool(SkillDev.TEXT.has(o)).is_true()


func test_a_development_step_raises_a_slot_and_takes_one_option() -> void:
	var m := _monster()
	m.dev_steps = 3
	assert_bool(m.develop_slot(1, "no_such_option")).is_false()
	assert_bool(m.develop_slot(1, SkillDev.STRIKE_AREA)).is_true()
	assert_bool(m.develop_slot(1, SkillDev.STRIKE_AREA)).is_false()   # each option once
	assert_bool(m.develop_slot(1, SkillDev.STRIKE_GROUND_OPT)).is_true()
	assert_int(m.slot_level(1)).is_equal(3)
	assert_bool(m.develop_slot(1, SkillDev.STRIKE_PROPS)).is_false()  # level 3 is the top
	assert_int(m.dev_steps).is_equal(1)
	var copy := MonsterInstance.from_dict(JSON.parse_string(JSON.stringify(m.to_dict())))
	assert_int(copy.slot_level(1)).is_equal(3)
	assert_array(copy.slot_options(1)).is_equal([SkillDev.STRIKE_AREA, SkillDev.STRIKE_GROUND_OPT])


func test_a_developed_skill_goes_into_the_battle_and_the_record_stays() -> void:
	var m := _monster()
	m.dev_steps = 2
	m.develop_slot(1, SkillDev.STRIKE_AREA)
	m.develop_slot(1, SkillDev.STRIKE_GROUND_OPT)
	var record := H.content().skill(&"strike_jab")
	var skill := UnitSheets.from_instance(m).skills[1]
	assert_int(skill.shape_extension).is_equal(record.shape_extension + 1)
	assert_bool(skill.has_op(BoardOp.GROUND)).is_true()
	assert_int(record.shape_extension).is_equal(0)
	assert_bool(record.has_op(BoardOp.GROUND)).is_false()
	assert_object(UnitSheets.from_instance(m).skills[0]).is_same(H.content().skill(&"fire_trail"))      # an undeveloped slot is the record


func test_a_longer_strike_reaches_the_second_square() -> void:
	var long := SkillDev.developed(H.strike("jab"), [SkillDev.STRIKE_AREA])
	var b := H.battle([[0, Vector2i(3, 5), {"pace": 1.9, "skills": [long]}], [1, Vector2i(3, 3)]])
	b.begin()
	b.apply({"type": &"skill", "slot": 0, "dir": H.UP})
	assert_that(H.unit(b, 1).pos).is_equal(Vector2i(3, 2))            # struck two squares away and pushed


func test_what_a_skill_lays_lasts_a_round_longer() -> void:
	var field := SkillDev.developed(H.content().skill(&"lava_field"), [SkillDev.LAY_ROUNDS])
	var b := H.battle([[0, Vector2i(3, 5), {"pace": 1.9, "reach": 3, "skills": [field]}], [1, Vector2i(6, 0)]])
	b.begin()
	assert_bool(b.apply({"type": &"skill", "slot": 0, "anchor": Vector2i(3, 3)})).is_true()
	assert_int(b.board.at(Vector2i(3, 3)).ground_until).is_equal(b.round_number + BattleExperiment.ground_rounds)      # one more than the rule


func test_a_movement_that_passes_over_props_and_one_square_further() -> void:
	var run := H.content().skill(&"run")
	var far := SkillDev.developed(run, [SkillDev.MOVE_RANGE, SkillDev.MOVE_PROPS])
	assert_int(far.move_range).is_equal((run.move_range if run.move_range > 0 else 3) + 1)
	assert_bool(far.blocked_by_objects).is_false()
	assert_bool(run.blocked_by_objects).is_true()


func test_a_slot_keeps_its_level_when_it_takes_another_skill_and_chooses_anew() -> void:
	var m := _monster()
	m.dev_steps = 2
	m.develop_slot(1, SkillDev.STRIKE_AREA)
	m.develop_slot(1, SkillDev.STRIKE_GROUND_OPT)
	assert_bool(m.relearn(1, &"run")).is_true()
	assert_int(m.slot_level(1)).is_equal(3)
	assert_array(m.slot_options(1)).is_empty()
	assert_int(m.open_picks(1)).is_equal(2)                           # two options to choose without a step
	assert_bool(m.pick_option(1, SkillDev.STRIKE_AREA)).is_false()    # the options of the new skill's kind
	assert_bool(m.pick_option(1, SkillDev.MOVE_RANGE)).is_true()
	assert_bool(m.pick_option(1, SkillDev.MOVE_PROPS)).is_true()
	assert_bool(m.pick_option(1, SkillDev.MOVE_MONSTERS)).is_false()  # no more than its level allows
	assert_int(m.dev_steps).is_equal(0)
