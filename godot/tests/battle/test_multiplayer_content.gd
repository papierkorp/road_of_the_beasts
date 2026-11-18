extends GdUnitTestSuite
## The grounds and zones of the multiplayer battle are named by what they do (docs/content.md).

const H := preload("res://tests/battle/helpers.gd")


func after_test() -> void:
	BattleExperiment.reset()


func test_every_moment_has_a_ground_for_damage_healing_and_stamina() -> void:
	var c := H.content()
	for when: Array in [["entry", Moment.ENTER], ["exit", Moment.LEAVE], ["stay", Moment.TURN_END]]:
		for what: String in ["damage", "heal", "stamina"]:
			var g := c.ground(StringName("%s_%s" % [when[0], what]))
			assert_object(g).is_not_null()
			assert_str(g.display_name).is_equal("%s %s Ground" % [String(when[0]).capitalize(), what.capitalize()])
			assert_str(g.battle).is_equal("multiplayer")
			assert_int(g.triggers.size()).is_equal(1)
			assert_str(g.triggers[0].timing).is_equal(when[1])
			assert_str(g.triggers[0].kind).is_equal(what)


func test_the_generator_uses_no_record_of_the_ingame_battle() -> void:
	var c := H.content()
	var grounds := SkillGen.ground_ids(c)
	assert_int(grounds.size()).is_equal(10)                 # nine by moment and effect, and the No-Prop Ground
	for id in grounds:
		assert_str(c.ground(id).battle).is_not_equal("ingame")
	var zones: Array = SkillGen.zone_ids(c)
	assert_array(zones[0]).contains_exactly_in_any_order([&"push_zone", &"pull_zone", &"prop_damage_zone"])
	for old: StringName in [&"lava", &"thornbed", &"mossbed", &"snare"]:
		assert_bool(grounds.has(old)).is_false()
		assert_object(c.ground(old)).is_not_null()            # still content of the ingame battle


func test_the_grounds_act_at_their_moment() -> void:
	var b := H.battle([[0, Vector2i(3, 5), {"pace": 1.9, "hp": 6, "current_hp": 3, "move": 4, "ap": 4}], [1, Vector2i(6, 0), {"pace": 1.2}]])
	var u := H.unit(b, 0)
	b.set_ground(Vector2i(3, 4), &"entry_heal")
	b.set_ground(Vector2i(3, 3), &"exit_damage")
	b.set_ground(Vector2i(3, 2), &"stay_stamina")
	b.begin()
	u.stamina = 1
	assert_bool(b.apply({"type": &"step", "to": Vector2i(3, 4)})).is_true()
	assert_int(u.hp).is_equal(4)                            # Entry Heal Ground
	assert_bool(b.apply({"type": &"step", "to": Vector2i(3, 3)})).is_true()
	assert_int(u.hp).is_equal(4)                            # entering the Exit Damage Ground costs nothing
	assert_bool(b.apply({"type": &"step", "to": Vector2i(3, 2)})).is_true()
	assert_int(u.hp).is_equal(2)                            # leaving it: 2 damage
	assert_int(u.stamina).is_equal(1)
	b.end_turn()
	assert_int(u.stamina).is_equal(2)                       # Stay Stamina Ground at the end of its turn
