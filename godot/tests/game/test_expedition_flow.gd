extends GdUnitTestSuite
## The whole hand-over: overworld → BattleRequest → real (AI) battle → BattleResult → overworld.


func test_a_played_expedition_node_updates_the_game_state() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 21
	var g := GameState.new_game(rng)
	var e := Expedition.generate(g, rng)
	e.select(e.choices()[0])
	var b := BattleSetup.build(e.request_for(g))
	b.begin()
	var guard := 0
	while not b.over and guard < 400:
		AiBrain.play_turn(b, b.turn_owner, rng)
		guard += 1
	assert_bool(b.over).is_true()
	var result := BattleSetup.make_result(b)
	e.apply_result(g, result)
	# whatever happened, the individual carries the HP it ended with
	assert_int(g.monsters[0].current_hp).is_equal(int(result.player[0]["hp_left"]))
	if result.player_won():
		assert_bool(e.current >= 0).is_true()
		assert_int(g.money).is_greater(0)
	else:
		assert_bool(e.finished).is_true()
		assert_int(g.money).is_equal(0)
