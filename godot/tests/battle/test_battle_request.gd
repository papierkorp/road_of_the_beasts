extends GdUnitTestSuite
## The battle request / result contract and the unit-sheet adapter (gdd_overworld §2.1, §8).

const H := preload("res://tests/battle/helpers.gd")


func _rolled(species: StringName, stage := Stage.Type.QI_GATHERING) -> MonsterInstance:
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	return MonsterInstance.roll(GameData.monster(species), rng, StatShape.Id.NONE, stage, Stage.SubTier.LOWER)


func test_build_fields_teams_at_mirrored_starts_with_their_current_hp() -> void:
	var r := BattleRequest.default()
	r.player_team[0].current_hp = 2
	var b := BattleSetup.build(r)
	assert_int(b.board.size).is_equal(7)
	assert_int(b.living(0).size()).is_equal(3)
	assert_int(b.living(1).size()).is_equal(3)
	var tiger: BattleUnit = b.units[&"p0_blaze_tiger"]
	assert_array([tiger.hp, tiger.max_hp]).is_equal([2, 5])
	for i in 3:
		assert_that(b.living(1)[i].pos).is_equal(b.board.mirrored(b.living(0)[i].pos))
	assert_int(b.voidscar_from).is_equal(8)
	var duel := BattleSetup.build(BattleRequest.from_ids(&"1v1", [&"blaze_tiger"] as Array[StringName], [&"gloom_wolf"] as Array[StringName]))
	assert_int(duel.board.size).is_equal(5)
	assert_int(duel.voidscar_from).is_equal(6)
	assert_array([BattleRequest.team_size_of(&"1v1"), BattleRequest.team_size_of(&"2v2"), BattleRequest.team_size_of(&"3v3"),
		BattleRequest.team_size_of(&"5v5")]).is_equal([1, 2, 3, 5])


func test_reference_individuals_use_the_gdd_reference_sheet() -> void:
	var sheet := UnitSheets.from_instance(MonsterInstance.of_species(GameData.monster(&"forge_golem")))
	assert_array([sheet.hp, sheet.movement, sheet.tpr, sheet.reach, sheet.ap]).is_equal([8, 1, 1, 3, 3])
	assert_float(sheet.initiative).is_equal(4.0)
	assert_array(sheet.skills.map(func(s): return s.id)).is_equal([&"strike_jab", &"set_gong", &"crucible", &"immovable"])
	assert_bool(sheet.airborne).is_false()


func test_rolled_individuals_keep_their_stats_with_base_ap_and_minimum_reach() -> void:
	var inst := _rolled(&"blaze_tiger")
	inst.current_hp = 1
	var sheet := UnitSheets.from_instance(inst)
	assert_int(sheet.hp).is_equal(inst.max_hp())
	assert_float(sheet.initiative).is_equal(float(inst.stats["initiative"]))
	assert_int(sheet.movement).is_equal(int(inst.stats["move"]))
	assert_int(sheet.tpr).is_equal(int(inst.stats["tpr"]))
	assert_int(sheet.ap).is_equal(2)             # the overworld model has no AP stat: GDD base value
	assert_int(sheet.reach).is_equal(maxi(2, int(inst.stats["reach"])))
	assert_int(sheet.current_hp).is_equal(1)
	assert_array(sheet.problems()).is_empty()
	assert_bool(sheet.notes.size() >= 1).is_true()


func test_winged_individuals_fly_from_soul_tier() -> void:
	assert_bool(UnitSheets.from_instance(_rolled(&"ember_hawk", Stage.Type.CORE_FORMATION)).airborne).is_false()
	assert_bool(UnitSheets.from_instance(_rolled(&"ember_hawk", Stage.Type.SOUL)).airborne).is_true()
	assert_bool(UnitSheets.from_instance(_rolled(&"blaze_tiger", Stage.Type.SOUL)).airborne).is_false()


func test_prep_pill_is_a_pre_battle_initiative_modifier_and_ambush_is_ignored() -> void:
	var plain := BattleSetup.build(BattleRequest.default())
	var r := BattleRequest.default()
	r.prep_init = {0: 2}
	r.ambush_side = 1                            # legacy field: the ambush bonus is not part of the design
	var prepared := BattleSetup.build(r)
	var a: BattleUnit = plain.units[&"p0_blaze_tiger"]
	var c: BattleUnit = prepared.units[&"p0_blaze_tiger"]
	assert_float(BattleStats.initiative(prepared, c)).is_equal(BattleStats.initiative(plain, a) + 2.0)
	for id in plain.roster:
		if plain.units[id].side == 1:
			assert_float(BattleStats.initiative(prepared, prepared.units[id])).is_equal(BattleStats.initiative(plain, plain.units[id]))


func test_chosen_start_squares_must_lie_in_the_start_area() -> void:
	var r := BattleRequest.default()
	r.player_starts = [Vector2i(0, 6), Vector2i(3, 2), Vector2i(0, 6)] as Array[Vector2i]
	var b := BattleSetup.build(r)
	assert_that(b.units[&"p0_blaze_tiger"].pos).is_equal(Vector2i(0, 6))    # back two rows: legal
	assert_that(b.units[&"p1_moss_turtle"].pos).is_equal(Vector2i(3, 6))    # outside: default square
	assert_that(b.units[&"p2_gloom_wolf"].pos).is_equal(Vector2i(5, 5))     # repeated square: default
	assert_bool(BattleBoards.in_start_area(&"3v3", Vector2i(2, 5))).is_true()
	assert_bool(BattleBoards.in_start_area(&"3v3", Vector2i(2, 4))).is_false()
	assert_bool(BattleBoards.in_start_area(&"1v1", Vector2i(0, 4))).is_true()
	assert_bool(BattleBoards.in_start_area(&"1v1", Vector2i(1, 4))).is_false()


func test_loadout_and_bench_come_from_the_request() -> void:
	var r := BattleRequest.default()
	r.player_tamer = [&"second_wind", &"beast_swap", &"unknown_skill"] as Array[StringName]
	r.player_bench = [MonsterInstance.of_species(GameData.monster(&"dusk_moth"))] as Array[MonsterInstance]
	var b := BattleSetup.build(r)
	assert_array(b.tamer_loadout[0].map(func(d): return d.id)).is_equal([&"second_wind", &"beast_swap"])
	assert_array(b.tamer_loadout[1]).is_empty()  # wild monsters have no tamer
	var bench: BattleUnit = b.units[&"pb0_dusk_moth"]
	assert_bool(bench.on_field).is_false()
	assert_int(b.living(0).size()).is_equal(3)


func test_result_reports_facts_and_writes_hp_back() -> void:
	var r := BattleRequest.default()
	var b := BattleSetup.build(r)
	b.begin()
	var rng := RandomNumberGenerator.new()
	rng.seed = 4
	var guard := 0
	while not b.over and guard < 500:
		AiBrain.play_turn(b, b.turn_owner, rng)
		guard += 1
	assert_bool(b.over).is_true()
	var result := BattleSetup.make_result(b)
	assert_bool(result.over).is_true()
	assert_int(result.rounds).is_equal(b.round_number)
	assert_int(result.player.size()).is_equal(3)
	assert_int(result.enemy.size()).is_equal(3)
	if not result.draw:
		assert_int(result.survivors(1 - result.winner_side)).is_equal(0)
		assert_bool(result.survivors(result.winner_side) >= 1).is_true()
	for e in result.player:
		assert_bool(e["hp_left"] >= 0 and e["hp_left"] <= e["max_hp"]).is_true()
		assert_bool(e["alive"] == (e["hp_left"] > 0)).is_true()
	result.apply_hp(r.player_team, 0)
	for i in 3:
		assert_int(r.player_team[i].current_hp).is_equal(result.player[i]["hp_left"])
