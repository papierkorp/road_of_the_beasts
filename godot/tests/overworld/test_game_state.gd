extends GdUnitTestSuite
## The day, the lifespan and the growth of the hub game (docs/vision.md §3, docs/monsters.md §2.2, §5).


func _game(seed_value := 7) -> GameState:
	return GameState.new_game(seed_value, &"way_of_the_formation", &"blaze_tiger")


func test_a_new_game_starts_with_one_monster_and_the_values_of_the_first_stage() -> void:
	var g := _game()
	assert_int(g.roster.size()).is_equal(1)
	assert_str(String(g.roster[0].species_id)).is_equal("blaze_tiger")
	assert_int(g.ap).is_equal(g.values.day_ap[0])
	assert_int(g.lifespan).is_equal(g.values.lifespan_days[0])
	assert_array(g.tamer_skills).contains([GameState.SEAL])
	assert_int(g.tamer_slots()).is_equal(1)


func test_the_night_shrinks_the_lifespan_and_refills_the_day_ap() -> void:
	var g := _game()
	assert_bool(g.spend_ap(2)).is_true()
	assert_bool(g.spend_ap(5)).is_false()
	var before := g.lifespan
	assert_bool(g.end_day()).is_true()
	assert_int(g.day).is_equal(2)
	assert_int(g.lifespan).is_equal(before - 1)
	assert_int(g.ap).is_equal(g.max_ap())


func test_the_end_of_the_lifespan_forces_the_trial_and_stops_the_days() -> void:
	var g := _game()
	for i in g.values.lifespan_days[0]:
		assert_bool(g.forced_trial).is_false()
		g.end_day()
	assert_bool(g.forced_trial).is_true()
	assert_int(g.lifespan).is_equal(0)
	assert_bool(g.can_end_day()).is_false()
	assert_bool(g.end_day()).is_false()


func test_a_breakthrough_gives_the_next_stage_and_its_lifespan() -> void:
	var g := _game()
	g.void_depth = 2
	g.forced_trial = true
	g.break_through()
	assert_int(int(g.stage)).is_equal(int(Stage.Type.FOUNDATION))
	assert_int(g.lifespan).is_equal(g.values.lifespan_days[1])
	assert_int(g.void_depth).is_equal(0)
	assert_bool(g.forced_trial).is_false()
	assert_int(g.tamer_slots()).is_equal(2)


func test_sovereign_wins_the_game() -> void:
	var g := _game()
	g.stage = Stage.Type.IMMORTAL
	g.break_through()
	assert_str(String(g.outcome)).is_equal(String(GameState.WON))
	assert_bool(g.can_end_day()).is_false()


func test_a_save_holds_the_whole_game() -> void:
	var g := _game()
	g.end_day()
	g.spend_ap(1)
	g.add_item(Materials.ore(0), 3)
	g.add_egg(&"moss_turtle")
	g.path_points = 2
	g.roster[0].gain_xp(70, g.stage)
	var data = JSON.parse_string(JSON.stringify(g.to_dict()))
	var h := GameState.from_dict(data)
	assert_int(h.day).is_equal(2)
	assert_int(h.ap).is_equal(g.ap)
	assert_int(h.count(Materials.ore(0))).is_equal(3)
	assert_int(h.eggs.size()).is_equal(1)
	assert_int(h.path_points).is_equal(2)
	assert_dict(h.roster[0].stats).is_equal(g.roster[0].stats)
	assert_int(h.roster[0].unspent).is_equal(g.roster[0].unspent)
	assert_int(h.roster[0].step()).is_equal(1)
	assert_int(h.rng_for("x").randi()).is_equal(g.rng_for("x").randi())


func test_an_egg_hatches_after_its_nights() -> void:
	var g := _game()
	g.add_egg(&"moss_turtle")
	for i in g.values.egg_nights:
		g.end_day()
	assert_int(g.eggs.size()).is_equal(0)
	assert_int(g.roster.size()).is_equal(2)


func test_a_grown_monster_never_spends_more_than_its_points() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	for step in [0, 4, 9, 17]:
		var m := MonsterInstance.grown(GameData.monster(&"moss_turtle"), rng, step)
		assert_int(m.step()).is_equal(step)
		assert_int(m.points_spent() + m.unspent).is_equal(MonsterInstance.START_POINTS + MonsterInstance.STEP_POINTS * step)
		assert_bool(m.unspent >= 0).is_true()
		assert_array(UnitSheets.from_instance(m).problems()).is_empty()


func test_a_step_gives_five_points_and_the_player_spends_them() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	var m := MonsterInstance.grown(GameData.monster(&"blaze_tiger"), rng, 0)
	var left := m.unspent
	assert_int(m.gain_xp(MonsterInstance.XP_STEPS[0], Stage.Type.QI_GATHERING)).is_equal(1)
	assert_int(m.unspent).is_equal(left + 5)
	var hp := m.max_hp()
	if m.can_buy("hp"):
		assert_bool(m.buy("hp")).is_true()
		assert_int(m.max_hp()).is_equal(hp + 1)
		assert_int(m.unspent).is_equal(left)


func test_a_monster_never_grows_past_the_stage_of_its_tamer() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	var m := MonsterInstance.grown(GameData.monster(&"blaze_tiger"), rng, 0)
	m.gain_xp(100000, Stage.Type.QI_GATHERING)
	assert_int(int(m.stage)).is_equal(int(Stage.Type.QI_GATHERING))
	assert_int(int(m.sub_tier)).is_equal(int(Stage.SubTier.HIGH))
	m.gain_xp(1, Stage.Type.FOUNDATION)
	assert_int(int(m.stage)).is_equal(int(Stage.Type.FOUNDATION))
	assert_int(m.dev_steps).is_equal(1)


func test_a_reshape_gives_every_point_back() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 9
	var m := MonsterInstance.grown(GameData.monster(&"dusk_moth"), rng, 5)
	m.refund_points()
	assert_dict(m.stats).is_equal(MonsterInstance.FLOOR)
	assert_int(m.points_spent() + m.unspent).is_equal(MonsterInstance.START_POINTS + MonsterInstance.STEP_POINTS * 5)


func test_the_cultivation_systems_and_the_eggs_of_the_values_exist() -> void:
	assert_int(CultivationDef.ids().size()).is_equal(2)
	for id in GameValues.shared().eggs:
		assert_object(GameData.monster(id)).is_not_null()
	var content := BattleContent.shared()
	for sid in CultivationDef.ids():
		for n: Dictionary in CultivationDef.of(sid).nodes:
			if n["kind"] == "tamer":
				assert_object(content.tamer_skill(n["ref"])).is_not_null()


func test_a_development_step_raises_a_slot_up_to_level_three() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 2
	var m := MonsterInstance.grown(GameData.monster(&"blaze_tiger"), rng, 6)
	assert_int(m.dev_steps).is_equal(2)
	assert_bool(m.develop_slot(0)).is_true()
	assert_bool(m.develop_slot(0)).is_true()
	assert_int(m.slot_level(0)).is_equal(3)
	assert_int(m.slot_level(1)).is_equal(1)
	assert_bool(m.develop_slot(1)).is_false()
	var copy := MonsterInstance.from_dict(JSON.parse_string(JSON.stringify(m.to_dict())))
	assert_int(copy.slot_level(0)).is_equal(3)


func test_the_cheats_change_the_running_game() -> void:
	var g := _game()
	g.spend_ap(2)
	Cheats.refill_ap(g)
	assert_int(g.ap).is_equal(g.max_ap())
	Cheats.last_day(g)
	g.end_day()
	assert_bool(g.forced_trial).is_true()
	Cheats.add_lifespan(g, 3)
	assert_bool(g.forced_trial).is_false()
	Cheats.give_materials(g, 2)
	assert_int(g.count(Materials.ore(0))).is_equal(2)
	Cheats.give_points(g, 3)
	assert_int(g.path_points).is_equal(3)
