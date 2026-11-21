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
