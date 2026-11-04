extends GdUnitTestSuite
## Overworld core (gdd_overworld §3, §7, §10.2): day / AP / money, the night, dungeon runs.


func _rng(seed_value := 9) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng


func _result(winner: int, hp_left: int) -> BattleResult:
	var r := BattleResult.new()
	r.over = true
	r.winner_side = winner
	r.player.append({"species": &"blaze_tiger", "index": 0, "hp_left": hp_left, "max_hp": 4, "alive": hp_left > 0})
	return r


func test_new_game_has_one_rolled_monster_and_full_ap() -> void:
	var g := GameState.new_game(_rng())
	assert_int(g.monsters.size()).is_equal(1)
	assert_int(g.ap).is_equal(GameState.START_AP)
	assert_int(g.day).is_equal(1)
	assert_int(g.stage).is_equal(Stage.Type.QI_GATHERING)
	assert_int(g.monsters[0].stats["hp"]).is_between(1, 4)
	assert_str(String(g.battle_mode())).is_equal("1v1")
	assert_int(g.team_for(&"1v1").size()).is_equal(1)


func test_ap_is_spent_and_never_negative() -> void:
	var g := GameState.new_game(_rng())
	assert_bool(g.spend_ap(2)).is_true()
	assert_bool(g.spend_ap(2)).is_false()
	assert_int(g.ap).is_equal(1)


func test_night_restores_ap_heals_and_advances_the_day() -> void:
	var g := GameState.new_game(_rng())
	g.spend_ap(3)
	g.monsters[0].current_hp = 1
	var report := g.end_day()
	assert_int(g.day).is_equal(2)
	assert_int(g.ap).is_equal(g.max_ap)
	assert_int(g.monsters[0].current_hp).is_equal(g.monsters[0].max_hp())
	assert_int(report["healed"]).is_equal(1)


func test_state_survives_a_json_round_trip() -> void:
	var g := GameState.new_game(_rng())
	g.money = 55
	g.day = 4
	g.monsters[0].xp = 20
	var back := GameState.from_dict(JSON.parse_string(JSON.stringify(g.to_dict())))
	assert_int(back.money).is_equal(55)
	assert_int(back.day).is_equal(4)
	assert_int(back.monsters.size()).is_equal(1)
	assert_int(back.monsters[0].xp).is_equal(20)
	assert_int(back.monsters[0].stats["hp"]).is_equal(g.monsters[0].stats["hp"])
	assert_float(back.monsters[0].stats["initiative"]).is_equal(g.monsters[0].stats["initiative"])


func test_expedition_is_a_chain_of_wild_battles_at_the_players_mode() -> void:
	var g := GameState.new_game(_rng())
	var e := Expedition.generate(g, _rng())
	assert_int(e.nodes.size()).is_equal(Expedition.NODE_COUNT)
	for n in e.nodes:
		assert_str(String(n["mode"])).is_equal("1v1")
		assert_int((n["enemies"] as Array).size()).is_equal(1)
	var req := e.request_for(g)
	assert_str(req.problem()).is_empty()
	assert_object(req.player_team[0]).is_same(g.monsters[0])


func test_victory_pays_keeps_hp_gives_xp_and_advances() -> void:
	var g := GameState.new_game(_rng())
	var e := Expedition.generate(g, _rng())
	e.apply_result(g, _result(0, 2))
	assert_int(g.monsters[0].current_hp).is_equal(2)
	assert_int(g.money).is_equal(Expedition.REWARD_PER_NODE)
	assert_int(g.monsters[0].xp).is_equal(Expedition.XP_PER_WIN)
	assert_int(e.index).is_equal(1)
	assert_bool(e.finished).is_false()


func test_clearing_the_last_node_ends_the_run_in_victory() -> void:
	var g := GameState.new_game(_rng())
	var e := Expedition.generate(g, _rng())
	for i in Expedition.NODE_COUNT:
		e.apply_result(g, _result(0, 3))
	assert_bool(e.finished).is_true()
	assert_bool(e.victory).is_true()
	assert_int(g.money).is_equal(e.money_earned)


func test_defeat_ends_the_run_without_reward() -> void:
	var g := GameState.new_game(_rng())
	var e := Expedition.generate(g, _rng())
	e.apply_result(g, _result(1, 0))
	assert_bool(e.finished).is_true()
	assert_bool(e.victory).is_false()
	assert_int(g.money).is_equal(0)
	assert_int(g.monsters[0].current_hp).is_equal(0)


func test_an_unfinished_battle_changes_nothing() -> void:
	var g := GameState.new_game(_rng())
	var e := Expedition.generate(g, _rng())
	var r := _result(0, 1)
	r.over = false
	e.apply_result(g, r)
	assert_int(e.index).is_equal(0)
	assert_int(g.money).is_equal(0)
