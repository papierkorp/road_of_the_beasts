extends GdUnitTestSuite
## Determinism (prompt requirement; gdd_battle pillar 6): the same start state, content,
## seed and ordered actions give the same events and the same final state.

const H := preload("res://tests/battle/helpers.gd")


func _request(mode: StringName, board_seed := 0) -> BattleRequest:
	var p: Array[StringName] = [&"blaze_tiger", &"moss_turtle", &"gloom_wolf"]
	var e: Array[StringName] = [&"hollow_serpent", &"grove_wisp", &"ember_hawk"]
	var r := BattleRequest.from_ids(mode, p, e)
	r.board_seed = board_seed
	return r


func _play(b: Battle, ai_seed: int, max_turns := 400) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = ai_seed
	b.begin()
	var guard := 0
	while not b.over and guard < max_turns:
		AiBrain.play_turn(b, b.turn_owner, rng)
		guard += 1


func test_same_request_and_seed_give_identical_events_and_state() -> void:
	var a := BattleSetup.build(_request(&"3v3"))
	var c := BattleSetup.build(_request(&"3v3"))
	assert_str(a.state_hash()).is_equal(c.state_hash())
	_play(a, 11)
	_play(c, 11)
	assert_bool(a.over).is_true()
	assert_int(a.events.size()).is_greater(50)
	assert_str(var_to_str(a.events)).is_equal(var_to_str(c.events))
	assert_str(a.state_hash()).is_equal(c.state_hash())
	assert_int(a.winner_side).is_equal(c.winner_side)
	assert_int(a.round_number).is_equal(c.round_number)


func test_replaying_the_recorded_actions_reproduces_the_battle_without_the_ai() -> void:
	var a := BattleSetup.build(_request(&"3v3", 7))
	_play(a, 3)
	assert_bool(a.over).is_true()
	var replayed := BattleSetup.build(_request(&"3v3", 7))
	replayed.replay(a.actions)
	assert_str(replayed.state_hash()).is_equal(a.state_hash())
	assert_str(var_to_str(replayed.events)).is_equal(var_to_str(a.events))
	assert_int(replayed.actions.size()).is_equal(a.actions.size())


func test_a_different_action_order_changes_the_outcome_hash() -> void:
	# sanity check that the hash really describes the state
	var a := BattleSetup.build(_request(&"1v1"))
	var c := BattleSetup.build(_request(&"1v1"))
	a.begin()
	c.begin()
	assert_str(a.state_hash()).is_equal(c.state_hash())
	var opts := BattleMoves.options(a, a.active(), BattleMoves.step_profile())
	var to: Vector2i = opts.keys()[0]
	assert_bool(a.apply({"type": &"step", "to": to})).is_true()
	assert_str(a.state_hash()).is_not_equal(c.state_hash())
	assert_bool(c.apply({"type": &"step", "to": to})).is_true()
	assert_str(a.state_hash()).is_equal(c.state_hash())


func test_seeded_boards_are_reproducible_point_symmetric_and_keep_the_centre_free() -> void:
	for mode: StringName in [&"1v1", &"2v2", &"3v3", &"5v5"]:
		for board_seed in [0, 1, 2, 99]:
			var a := BattleSetup.build(_request(mode, board_seed))
			var c := BattleSetup.build(_request(mode, board_seed))
			assert_str(a.state_hash()).is_equal(c.state_hash())
			var props := a.board.props()
			assert_int(props.size() % 2).is_equal(0)            # mirrored pairs only
			assert_object(a.board.at(a.board.centre()).prop).is_null()
			for prop in props:
				var twin := a.board.prop_at(a.board.mirrored(prop.pos), Board.GROUND)
				assert_object(twin).is_not_null()
				assert_str(twin.def.id).is_equal(prop.def.id)
			for cell in a.board.cells:
				assert_int(a.board.at(a.board.mirrored(cell.pos)).height).is_equal(cell.height)
	# another seed gives another layout
	assert_str(BattleSetup.build(_request(&"3v3", 1)).state_hash()).is_not_equal(BattleSetup.build(_request(&"3v3", 2)).state_hash())


func test_dry_runs_never_touch_the_real_battle() -> void:
	var b := BattleSetup.build(_request(&"3v3"))
	b.begin()
	var hash_before := b.state_hash()
	var events := b.events.size()
	for a in AiBrain.candidates(b):
		var p := b.preview(a)
		assert_bool(p["ok"]).is_true()
	assert_str(b.state_hash()).is_equal(hash_before)
	assert_int(b.events.size()).is_equal(events)


func test_ai_battles_end_in_every_mode() -> void:
	for mode: StringName in [&"1v1", &"3v3"]:
		for s in [1, 2, 3]:
			var b := BattleSetup.build(_request(mode, s))
			_play(b, s, 600)
			assert_bool(b.over).is_true()
