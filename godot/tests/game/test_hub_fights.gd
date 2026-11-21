extends GdUnitTestSuite
## The hand-over of the hub game: a fight of a place → BattleRequest → a real battle played by the AI → BattleResult →
## the game. Also checks the test battlegrounds against the table of the values.


func test_every_battleground_of_the_values_is_playable_and_holds_what_the_table_says() -> void:
	var content := BattleContent.shared()
	for b: Dictionary in GameValues.shared().battlegrounds:
		var map := MapDef.load_map(b["id"])
		assert_object(map).is_not_null()
		assert_array(map.problems(content)).is_empty()
		assert_int(map.free_starts(content, 0).size()).is_equal(int(b["mine"]))
		assert_int(map.free_starts(content, 1).size()).is_equal(int(b["theirs"]))
		assert_bool(BattlegroundJob.enemy_reaches_player(map, content)).is_true()


func _play(f: Fight, seed_value: int) -> BattleResult:
	BattleExperiment.reset()
	var b := BattleSetup.build(FightBridge.request_of(f))
	b.begin()
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var guard := 0
	while not b.over and guard < 600:
		AiBrain.play_turn(b, b.turn_owner, rng)
		guard += 1
	assert_bool(b.over).is_true()
	return BattleSetup.make_result(b)


func test_a_wild_encounter_is_fought_and_read_back() -> void:
	var g := GameState.new_game(33, &"way_of_the_beast_lord", &"moss_turtle")
	var f := WildArea.encounters(g, 0)[0].fight
	f.team = g.default_team(f.max_team)
	f.tamer = g.default_loadout()
	assert_bool(WildArea.pay(g)).is_true()
	var result := _play(f, 5)
	assert_int(result.player.size()).is_equal(1)
	assert_int(result.enemy.size()).is_equal(f.enemies.size())
	Places.resolve(g, f, result)
	assert_bool(WildArea.encounters(g, 0)[0].gone).is_equal(result.player_won())
	assert_int(g.roster[0].current_hp).is_equal(g.roster[0].max_hp())


func _job(g: GameState) -> BattlegroundJob:
	var job := BattlegroundJob.new()
	job.parts = g.parts.duplicate()
	job.budget = g.values.bg_budget[0]
	job.weights = g.values.bg_weights
	job.min_side = g.values.bg_min_side
	job.max_side = g.values.bg_max_side
	job.enemy_starts = g.values.bg_enemy_starts
	return job


func _own_map() -> MapDef:
	var m := MapDef.new()
	m.width = 5
	m.height = 5
	m.start_a = [Vector2i(1, 4), Vector2i(2, 4)]
	m.start_b = [Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)]
	m.grounds[Vector2i(2, 3)] = &"dragon_vein"
	return m


func test_the_limits_of_the_players_battleground() -> void:
	var g := GameState.new_game(3, &"way_of_the_formation", &"blaze_tiger")
	var content := BattleContent.shared()
	var job := _job(g)
	var m := _own_map()
	assert_array(job.problems(m, content)).is_empty()
	assert_int(job.cost(m)).is_equal(int(g.values.bg_weights["dragon_vein"]))
	m.grounds[Vector2i(2, 2)] = &"dragon_vein"                      # one vein owned, two placed
	assert_array(job.problems(m, content)).is_not_empty()
	m.grounds.erase(Vector2i(2, 2))
	m.grounds[Vector2i(0, 2)] = &"lava"                             # a part the player does not own
	assert_array(job.problems(m, content)).is_not_empty()
	m.grounds.erase(Vector2i(0, 2))
	m.start_b = [Vector2i(1, 0)]                                    # too few start squares for the opponent
	assert_array(job.problems(m, content)).is_not_empty()
	m.start_b = [Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)]
	job.parts["prop:earth_wall"] = 5                                # walling the opponent in is refused
	for x in 5:
		m.props[Vector2i(x, 1)] = &"earth_wall"
	job.budget = 99
	assert_bool(BattlegroundJob.enemy_reaches_player(m, content)).is_false()
	assert_array(job.problems(m, content)).is_not_empty()
	m.props.erase(Vector2i(4, 1))
	assert_array(job.problems(m, content)).is_empty()
	job.budget = 5                                                  # four walls and a vein cost 11
	assert_array(job.problems(m, content)).is_not_empty()


func test_a_battleground_survives_the_save_as_plain_data() -> void:
	var m := _own_map()
	m.props[Vector2i(0, 2)] = &"earth_wall"
	m.zones[Vector2i(3, 2)] = {"zone": &"push_zone", "dir": Vector2i(0, -1), "rounds": 2}
	m.missing = [Vector2i(4, 4)]
	var back := MapData.from_dict(JSON.parse_string(JSON.stringify(MapData.to_dict(m))))
	assert_int(back.width).is_equal(5)
	assert_dict(back.grounds).is_equal(m.grounds)
	assert_dict(back.props).is_equal(m.props)
	assert_dict(back.zones).is_equal(m.zones)
	assert_array(back.start_a).is_equal(m.start_a)
	assert_array(back.start_b).is_equal(m.start_b)
	assert_array(back.missing).is_equal(m.missing)


func test_a_depth_of_the_void_is_fought_on_the_players_battleground() -> void:
	var g := GameState.new_game(8, &"way_of_the_formation", &"moss_turtle")
	g.battleground = MapData.to_dict(_own_map())
	var f := VoidPlace.fight(g)
	f.team = g.default_team(f.max_team)
	f.tamer = g.default_loadout()
	assert_bool(VoidPlace.pay(g)).is_true()
	var result := _play(f, 9)
	Places.resolve(g, f, result)
	assert_int(g.void_depth).is_equal(1 if result.player_won() else 0)
	assert_int(g.path_points).is_equal(1 if result.player_won() else 0)


func test_the_battleground_a_game_starts_with_is_legal() -> void:
	var g := GameState.new_game(3, &"way_of_the_formation", &"blaze_tiger")
	assert_bool(g.battleground.is_empty()).is_false()
	assert_array(_job(g).problems(MapData.from_dict(g.battleground), BattleContent.shared())).is_empty()
