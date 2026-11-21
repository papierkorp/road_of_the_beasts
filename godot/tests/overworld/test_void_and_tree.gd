extends GdUnitTestSuite
## The void, the breakthrough trial and the cultivation tree (docs/vision.md §3, §4, §8).


func _game() -> GameState:
	var g := GameState.new_game(51, &"way_of_the_formation", &"blaze_tiger")
	g.battleground = {"w": 5, "h": 5, "start_a": [[1, 4], [2, 4]], "start_b": [[1, 0], [2, 0], [3, 0]]}
	return g


func _result(f: Fight, won: bool) -> BattleResult:
	var r := BattleResult.new()
	r.over = true
	r.winner_side = 0 if won else 1
	for i in f.team.size():
		r.player.append({"index": i, "hp_left": 1 if won else 0, "alive": won})
	for i in f.enemies.size():
		r.enemy.append({"index": i, "hp_left": 0, "alive": false, "caught": false, "died": won})
	return r


func _fight(g: GameState, won: bool) -> Fight:
	var f := VoidPlace.fight(g)
	f.team = g.default_team(f.max_team)
	assert_bool(VoidPlace.pay(g)).is_true()
	Places.resolve(g, f, _result(f, won))
	return f


func test_void_monsters_stand_above_the_stage_and_fight_on_the_players_battleground() -> void:
	var g := _game()
	var f := VoidPlace.fight(g)
	assert_str(String(f.map_id)).is_equal("")
	assert_dict(f.own_map).is_equal(g.battleground)
	assert_int(f.max_team).is_equal(2)
	for e in f.enemies:
		assert_int(e.step()).is_greater(GameState.step_of(0, 2))


func test_a_depth_won_gives_a_path_point_and_opens_the_next_one() -> void:
	var g := _game()
	_fight(g, true)
	assert_int(g.void_depth).is_equal(1)
	assert_int(g.path_points).is_equal(1)
	assert_int(g.ap).is_equal(g.max_ap() - g.values.void_ap)
	_fight(g, false)
	assert_int(g.void_depth).is_equal(1)
	assert_int(g.path_points).is_equal(1)
	assert_str(String(g.outcome)).is_equal("")
	assert_int(g.roster[0].current_hp).is_equal(g.roster[0].max_hp())


func test_the_last_depth_is_the_trial_and_needs_the_breakthrough_material() -> void:
	var g := _game()
	g.void_depth = g.values.void_depths - 1
	assert_bool(VoidPlace.is_trial(g)).is_true()
	assert_str(VoidPlace.problem(g)).is_not_empty()
	assert_bool(VoidPlace.pay(g)).is_false()
	g.add_item(Materials.breakthrough(0), g.values.trial_materials)
	assert_str(VoidPlace.problem(g)).is_empty()
	_fight(g, true)
	assert_int(int(g.stage)).is_equal(int(Stage.Type.FOUNDATION))
	assert_int(g.void_depth).is_equal(0)
	assert_int(g.count(Materials.breakthrough(0))).is_equal(0)
	assert_int(g.path_points).is_equal(1)


func test_at_the_end_of_the_lifespan_the_trial_is_forced_and_losing_it_loses_the_game() -> void:
	var g := _game()
	g.lifespan = 1
	g.end_day()
	assert_bool(g.forced_trial).is_true()
	assert_bool(VoidPlace.is_trial(g)).is_true()
	assert_str(VoidPlace.problem(g)).is_empty()           # ready or not: no material, no day AP asked
	var f := VoidPlace.fight(g)
	assert_bool(bool(f.ref["forced"])).is_true()
	_fight(g, false)
	assert_str(String(g.outcome)).is_equal(String(GameState.LOST))


func test_a_forced_trial_that_is_won_is_a_breakthrough() -> void:
	var g := _game()
	g.lifespan = 1
	g.end_day()
	_fight(g, true)
	assert_int(int(g.stage)).is_equal(int(Stage.Type.FOUNDATION))
	assert_bool(g.forced_trial).is_false()
	assert_int(g.lifespan).is_equal(g.values.lifespan_days[1])
	assert_bool(g.can_end_day()).is_true()


func test_a_node_is_bought_with_path_points_and_gives_its_skill_or_blueprint() -> void:
	var g := _game()
	assert_str(Cultivation.problem(g, &"dragon_vein")).is_not_empty()
	g.path_points = 2
	assert_bool(Cultivation.buy(g, &"dragon_vein")).is_true()
	assert_array(g.blueprints).contains([&"ground:dragon_vein"])
	assert_int(g.path_points).is_equal(1)
	assert_bool(Cultivation.buy(g, &"dragon_vein")).is_false()
	assert_str(Cultivation.problem(g, &"domain_glimpse")).contains("Foundation")       # the tree of the next stage
	g.stage = Stage.Type.FOUNDATION
	assert_bool(Cultivation.buy(g, &"domain_glimpse")).is_true()
	assert_array(g.tamer_skills).contains([&"domain_glimpse"])
	g.path_points = 5
	assert_str(Cultivation.problem(g, &"lava")).contains("Spike Trap")                 # a node may need another
	Cultivation.buy(g, &"spike_trap")
	assert_bool(Cultivation.buy(g, &"lava")).is_true()


func test_a_part_is_built_from_a_blueprint_and_materials() -> void:
	var g := _game()
	var part := "ground:springwater"
	g.add_item(Materials.ore(0), 1)
	assert_bool(Cultivation.build_part(g, part)).is_false()          # no blueprint
	g.blueprints.append(StringName(part))
	assert_bool(Cultivation.build_part(g, part)).is_true()
	assert_int(int(g.parts[part])).is_equal(1)
	assert_int(g.count(Materials.ore(0))).is_equal(0)
	assert_bool(Cultivation.build_part(g, part)).is_false()          # no ore left
