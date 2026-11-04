extends GdUnitTestSuite
## BattleRequest in, BattleResult out (gdd_overworld §1.3).


func _ids(list: Array) -> Array[StringName]:
	var out: Array[StringName] = []
	for id in list:
		out.append(StringName(id))
	return out


func _play(b: Battle, seed_value := 5) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	b.begin()
	var guard := 0
	while not b.over and guard < 400:
		AiBrain.play_turn(b, b.turn_owner, rng)
		guard += 1


func test_default_request_is_a_valid_3v3() -> void:
	var r := BattleRequest.default()
	assert_str(r.problem()).is_empty()
	assert_int(r.player_team.size()).is_equal(3)
	var b := BattleSetup.build(r)
	assert_int(b.board.size).is_equal(7)
	assert_int(b.monsters.size()).is_equal(6)


func test_build_cuts_the_teams_to_the_mode_size() -> void:
	var r := BattleRequest.from_ids(&"1v1", _ids(["blaze_tiger", "moss_turtle", "gloom_wolf"]), _ids(["hollow_serpent", "grove_wisp", "ember_hawk"]))
	var b := BattleSetup.build(r)
	assert_int(b.board.size).is_equal(5)
	assert_int(b.monsters.size()).is_equal(2)
	assert_bool(b.monsters.has(&"p0_blaze_tiger")).is_true()


func test_request_without_a_team_is_rejected() -> void:
	var r := BattleRequest.from_ids(&"3v3", _ids([]), _ids(["ember_hawk"]))
	assert_str(r.problem()).is_not_empty()


func test_units_know_their_place_in_the_team() -> void:
	var b := BattleSetup.build(BattleRequest.default())
	assert_int((b.monsters[&"p0_blaze_tiger"] as Monster).team_index).is_equal(0)
	assert_int((b.monsters[&"p2_gloom_wolf"] as Monster).team_index).is_equal(2)
	assert_int((b.monsters[&"e1_grove_wisp"] as Monster).team_index).is_equal(1)


func test_result_reports_winner_and_hp_in_team_order() -> void:
	var r := BattleRequest.default()
	var b := BattleSetup.build(r)
	_play(b)
	assert_bool(b.over).is_true()
	var res := BattleSetup.make_result(b)
	assert_bool(res.over).is_true()
	assert_int(res.winner_side).is_equal(b.winner_side)
	assert_int(res.rounds).is_equal(b.round_number)
	assert_int(res.player.size()).is_equal(3)
	assert_int(res.enemy.size()).is_equal(3)
	for i in 3:
		assert_int(res.player[i]["index"]).is_equal(i)
		assert_str(String(res.player[i]["species"])).is_equal(String(r.player_team[i].species_id))
		var m: Monster = b.monsters[StringName("p%d_%s" % [i, r.player_team[i].species_id])]
		assert_int(res.player[i]["hp_left"]).is_equal(maxi(m.hp, 0))
		assert_bool(res.player[i]["alive"]).is_equal(m.is_alive())
	# the loser has nobody left
	if res.winner_side == 0:
		assert_int(res.survivors(1)).is_equal(0)
	elif res.winner_side == 1:
		assert_int(res.survivors(0)).is_equal(0)


func test_apply_hp_writes_back_into_the_individuals() -> void:
	var r := BattleRequest.default()
	var b := BattleSetup.build(r)
	_play(b)
	var res := BattleSetup.make_result(b)
	res.apply_hp(r.player_team, 0)
	for i in 3:
		assert_int(r.player_team[i].current_hp).is_equal(res.player[i]["hp_left"])


func test_wounded_individual_enters_the_battle_wounded() -> void:
	var r := BattleRequest.default()
	r.player_team[0].current_hp = 2
	var b := BattleSetup.build(r)
	assert_int((b.monsters[&"p0_blaze_tiger"] as Monster).hp).is_equal(2)
	# the request is not changed by fighting
	_play(b)
	assert_int(r.player_team[0].current_hp).is_equal(2)
