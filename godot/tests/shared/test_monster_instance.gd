extends GdUnitTestSuite
## Individual monsters (gdd_overworld §4.3-4.6): reference individuals, rolled stat shapes,
## stage ceilings and the hand-over to the battle.

const STAGES := [Stage.Type.QI_GATHERING, Stage.Type.FOUNDATION, Stage.Type.CORE_FORMATION, Stage.Type.SOUL]


func _rng(seed_value := 7) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng


func test_reference_individual_keeps_the_species_numbers() -> void:
	for id in GameData.monster_ids():
		var def := BattleSetup.load_def(id)
		var unit := MonsterInstance.of_species(def).to_battle_unit()
		assert_int(unit.hp).is_equal(def.hp)
		assert_float(unit.initiative).is_equal(def.initiative)
		assert_int(unit.move).is_equal(def.move)
		assert_int(unit.tpr).is_equal(def.tpr)
		assert_int(unit.reach).is_equal(def.reach)
		assert_object(unit.surge).is_same(def.surge)
		assert_object(unit.utility).is_same(def.utility)


func test_battle_unit_is_a_copy_of_the_species() -> void:
	var def := BattleSetup.load_def(&"blaze_tiger")
	var inst := MonsterInstance.of_species(def)
	inst.stats["hp"] = 3
	var unit := inst.to_battle_unit()
	assert_int(unit.hp).is_equal(3)
	assert_int(def.hp).is_equal(5)
	assert_object(unit).is_not_same(def)
	assert_str(String(unit.id)).is_equal("blaze_tiger")


func test_rolled_stats_stay_in_the_ranges_and_keep_the_point_total() -> void:
	var rng := _rng()
	for shape in StatShape.rollable():
		var d: Dictionary = StatShape.DATA[shape]
		var total: int = int(d["hp"]) + int(d["initiative"]) + int(d["move"])
		for i in 60:
			var core := StatShape.roll_core(shape, rng)
			assert_int(core["hp"]).is_between(d["hp_range"][0], d["hp_range"][1])
			assert_int(int(core["initiative"])).is_between(d["initiative_range"][0], d["initiative_range"][1])
			assert_int(core["move"]).is_between(d["move_range"][0], d["move_range"][1])
			assert_int(core["hp"] + int(core["initiative"]) + core["move"]).is_equal(total)
			assert_int(core["tpr"]).is_equal(d["tpr"])
			assert_int(core["reach"]).is_equal(d["reach"])


func test_a_shape_does_not_always_roll_the_same_stats() -> void:
	var rng := _rng(3)
	var seen := {}
	for i in 80:
		var core := StatShape.roll_core(StatShape.Id.BALANCED, rng)
		seen["%d/%d/%d" % [core["hp"], core["initiative"], core["move"]]] = true
	assert_int(seen.size()).is_greater(1)


func test_rolled_stats_never_exceed_the_stage_ceiling() -> void:
	var rng := _rng(11)
	var def := BattleSetup.load_def(&"gloom_wolf")
	for stage in STAGES:
		var cap := Stage.caps(stage)
		for shape in StatShape.rollable():
			for i in 20:
				var m := MonsterInstance.roll(def, rng, shape, stage)
				assert_int(m.stats["hp"]).is_between(1, cap["hp"])
				assert_float(m.stats["initiative"]).is_between(0.1, cap["initiative"])
				assert_int(m.stats["move"]).is_between(1, cap["move"])
				assert_int(m.stats["tpr"]).is_between(1, cap["tpr"])
				assert_int(m.stats["reach"]).is_between(1, cap["reach"])
				assert_int(m.current_hp).is_equal(m.max_hp())


func test_berserker_tpr_opens_at_soul() -> void:
	var rng := _rng()
	var def := BattleSetup.load_def(&"blaze_tiger")
	assert_int(MonsterInstance.roll(def, rng, StatShape.Id.BERSERKER, Stage.Type.CORE_FORMATION).stats["tpr"]).is_equal(2)
	assert_int(MonsterInstance.roll(def, rng, StatShape.Id.BERSERKER, Stage.Type.SOUL).stats["tpr"]).is_equal(3)
	assert_int(MonsterInstance.roll(def, rng, StatShape.Id.BERSERKER, Stage.Type.QI_GATHERING).stats["tpr"]).is_equal(1)


func test_kin_lean_picks_a_known_shape() -> void:
	var rng := _rng(5)
	for kin in MonsterDef.Kin.values():
		for i in 20:
			assert_bool(StatShape.rollable().has(StatShape.pick_for_kin(kin, rng))).is_true()


func test_battle_monster_starts_at_the_individuals_current_hp() -> void:
	var inst := MonsterInstance.of_species(BattleSetup.load_def(&"forge_golem"))
	inst.current_hp = 3
	var other := MonsterInstance.of_species(BattleSetup.load_def(&"ember_hawk"))
	var b := BattleSetup.create_from_units(&"1v1", [inst] as Array[MonsterInstance], [other] as Array[MonsterInstance])
	var golem: Monster = b.monsters[&"p0_forge_golem"]
	assert_int(golem.hp).is_equal(3)
	assert_int(golem.max_hp).is_equal(8)


func test_create_by_ids_still_builds_the_same_battle() -> void:
	var p: Array[StringName] = [&"blaze_tiger", &"moss_turtle", &"gloom_wolf"]
	var e: Array[StringName] = [&"hollow_serpent", &"grove_wisp", &"ember_hawk"]
	var b := BattleSetup.create(&"3v3", p, e)
	assert_int(b.monsters.size()).is_equal(6)
	var tiger: Monster = b.monsters[&"p0_blaze_tiger"]
	assert_int(tiger.hp).is_equal(5)
	assert_float(tiger.def.initiative).is_equal(7.0)


func test_dictionary_round_trip() -> void:
	var m := MonsterInstance.roll(BattleSetup.load_def(&"dusk_moth"), _rng(), StatShape.Id.GLASS_CANNON, Stage.Type.FOUNDATION)
	m.xp = 12
	m.current_hp = 1
	var back := MonsterInstance.from_dict(m.to_dict())
	assert_str(String(back.species_id)).is_equal("dusk_moth")
	assert_int(back.shape).is_equal(StatShape.Id.GLASS_CANNON)
	assert_int(back.stage).is_equal(Stage.Type.FOUNDATION)
	assert_int(back.xp).is_equal(12)
	assert_int(back.current_hp).is_equal(1)
	assert_int(back.stats["hp"]).is_equal(m.stats["hp"])
