extends GdUnitTestSuite
## Data integrity of the 9-monster roster and AI smoke tests.


func test_all_roster_monsters_load_with_surge_and_utility() -> void:
	for id in GameData.monster_ids():
		var d := BattleSetup.load_def(id)
		assert_object(d).is_not_null()
		assert_object(d.surge).is_not_null()
		assert_object(d.utility).is_not_null()
		assert_int(d.surge.kind).is_equal(SkillDef.Kind.SURGE)
		assert_int(d.surge.surge_type).is_not_equal(SkillDef.SurgeType.NONE)
		assert_str(d.passive_text()).is_not_empty()


func test_boards_are_point_symmetric() -> void:
	var p: Array[StringName] = [&"blaze_tiger", &"moss_turtle", &"gloom_wolf"]
	var e: Array[StringName] = [&"hollow_serpent", &"grove_wisp", &"ember_hawk"]
	var b := BattleSetup.create(&"3v3", p, e)
	assert_int(b.board.size).is_equal(7)
	for sq: Square in b.board.all_squares():
		var q := b.board.at(Vector2i(6 - sq.pos.x, 6 - sq.pos.y))
		assert_bool(sq.elevated).is_equal(q.elevated)
		assert_bool(sq.object == null).is_equal(q.object == null)


func test_self_play_ends_for_random_teams() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	for i in 6:
		var pick := BattleSetup.random_enemy([] as Array[StringName], 3, rng)
		var b := BattleSetup.create(&"3v3", pick, BattleSetup.random_enemy(pick, 3, rng))
		b.begin()
		var guard := 0
		while not b.over and guard < 400:
			AiBrain.play_turn(b, b.turn_owner, rng)
			guard += 1
		assert_bool(b.over).is_true()
