extends GdUnitTestSuite
## The hand-over of the hub game: a fight of a place → BattleRequest → a real battle played by the AI → BattleResult →
## the game. Also the limits of the Artificer's own battleground.

const H := preload("res://tests/overworld/helpers.gd")


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


func _shape(g: GameState) -> void:
	var m := g.roster[0]
	for s in m.learnable():
		m.learn(s.id)
	var rng := RandomNumberGenerator.new()
	rng.seed = 1
	m.spend_at_random(rng)
	m.heal_full()


func test_a_battle_of_the_wild_is_fought_on_its_generated_board_and_read_back() -> void:
	for way: StringName in [H.FORMATION, H.ALCHEMIST, H.ARTIFICER]:
		var g := H.game(way, 33, &"moss_turtle")
		_shape(g)
		var years := g.lifespan
		var f := Wild.fight_for(g, 0)
		f.team = g.default_team(f.max_team)
		if way == H.FORMATION:
			f.tamer = g.default_loadout()
		elif way == H.ALCHEMIST:
			f.tamer = [&"pill_binding"]
			f.tamer_items = {&"pill_binding": "pill:binding"}
		else:
			assert_bool(Crafting.lay(g, f, "2,2", Fight.SEAL_PART)).is_true()
		var result := _play(f, 5)
		assert_int(result.player.size()).is_equal(1)
		assert_int(result.enemy.size()).is_equal(f.enemies.size())
		Places.resolve(g, f, result)
		assert_int(g.lifespan).is_equal(years - 1)
		assert_bool(g.wild_gone.has(0)).is_equal(result.player_won())      # a battle won leaves the look


func test_seal_ground_laid_as_a_part_lies_on_the_board_from_the_start() -> void:
	var g := H.game(H.ARTIFICER, 12, &"moss_turtle")
	_shape(g)
	var f := Wild.fight_for(g, 0)
	f.team = g.default_team(f.max_team)
	Crafting.lay(g, f, "2,2", Fight.SEAL_PART)
	g.parts["prop:earth_wall"] = 1
	Crafting.lay(g, f, "1,2", "prop:earth_wall")
	BattleExperiment.reset()
	var b := BattleSetup.build(FightBridge.request_of(f))
	assert_bool(b.seals.has(Vector2i(2, 2))).is_true()
	assert_int(int(b.seals[Vector2i(2, 2)]["side"])).is_equal(0)
	assert_str(String(b.board.at(Vector2i(2, 2)).ground)).is_equal("seal")
	var wall := b.board.prop_at(Vector2i(1, 2), Board.GROUND)
	assert_object(wall).is_not_null()
	assert_int(wall.until).is_equal(0)                                 # a part lies for the whole battle, like a prop of the board
	assert_array(b.tamer_loadout[0]).is_empty()                        # the Artificer has no tamer slots


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


func test_the_limits_of_the_artificers_battleground() -> void:
	var g := H.game(H.ARTIFICER, 3)
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
	assert_array(back.missing).is_equal(m.missing)


func test_a_depth_of_the_void_is_fought_and_read_back() -> void:
	for way: StringName in [H.ARTIFICER, H.FORMATION]:
		var g := H.game(way, 8, &"moss_turtle")
		_shape(g)
		var f := VoidPlace.fight(g)
		f.team = g.default_team(f.max_team)
		assert_bool(VoidPlace.pay(g)).is_true()
		var result := _play(f, 9)
		Places.resolve(g, f, result)
		assert_int(g.void_depth).is_equal(1 if result.player_won() else 0)
		assert_int(g.path_points).is_equal(1 if result.player_won() else 0)
		assert_int(g.day).is_equal(2)                                  # the attack was the deed of the year


func test_the_battleground_the_artificer_starts_with_is_legal() -> void:
	var g := H.game(H.ARTIFICER, 3)
	assert_bool(g.battleground.is_empty()).is_false()
	assert_array(_job(g).problems(MapData.from_dict(g.battleground), BattleContent.shared())).is_empty()


func test_a_monster_fights_with_the_stats_the_hub_shows() -> void:
	var g := H.game()
	var m := g.roster[0]
	var s := UnitSheets.from_instance(m)
	assert_int(s.hp).is_equal(int(m.stats["hp"]))
	assert_float(s.pace).is_equal_approx(float(m.stats["pace"]), 0.001)
	assert_int(s.movement).is_equal(int(m.stats["move"]))
	assert_int(s.reach).is_equal(int(m.stats["reach"]))
	assert_int(s.ap).is_equal(int(m.stats["ap"]))
	assert_int(s.tpr).is_equal(int(m.stats["tpr"]))
	assert_str(s.rank).is_equal("Qi Gathering Lower")
