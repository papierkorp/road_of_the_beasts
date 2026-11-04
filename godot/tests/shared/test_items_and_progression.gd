extends GdUnitTestSuite
## Items from one schema and XP → sub-tier progression (gdd_overworld §4.3, §9.3, §10).


func _rng(seed_value := 4) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng


func _monster(shape := StatShape.Id.BALANCED) -> MonsterInstance:
	return MonsterInstance.roll(BattleSetup.load_def(&"blaze_tiger"), _rng(), shape, Stage.Type.QI_GATHERING, Stage.SubTier.LOWER)


func test_material_and_pill_ids_describe_themselves() -> void:
	var feather := ItemCatalog.material_id(MonsterDef.Kin.WINGED, Aspect.Type.FORCE, 0)
	assert_int(ItemCatalog.kind_of(feather)).is_equal(ItemCatalog.Kind.MATERIAL)
	assert_str(ItemCatalog.display_name(feather)).is_equal("Ember Feather (Qi Gathering)")
	var pill := ItemCatalog.pill_id(1)
	assert_int(ItemCatalog.kind_of(pill)).is_equal(ItemCatalog.Kind.PILL)
	assert_str(ItemCatalog.display_name(pill)).is_equal("Foundation Cultivation Pill")


func test_every_tier_is_worth_three_times_the_one_below() -> void:
	var a := ItemCatalog.base_value(ItemCatalog.material_id(MonsterDef.Kin.BEAST, Aspect.Type.DARK, 0))
	var b := ItemCatalog.base_value(ItemCatalog.material_id(MonsterDef.Kin.BEAST, Aspect.Type.DARK, 1))
	assert_int(b).is_equal(a * 3)


func test_a_tier_has_eighteen_materials() -> void:
	assert_int(ItemCatalog.materials_of_tier(0).size()).is_equal(18)


func test_a_full_xp_bar_is_a_sub_tier_up_and_stats_snap() -> void:
	var m := _monster()
	var hp_before := m.max_hp()
	var ups := m.add_xp(MonsterInstance.XP_TO_NEXT[Stage.SubTier.LOWER])
	assert_int(ups).is_equal(1)
	assert_int(m.sub_tier).is_equal(Stage.SubTier.MIDDLE)
	assert_int(m.xp).is_equal(0)
	assert_int(m.max_hp()).is_greater_equal(hp_before)
	assert_int(m.stats["hp"]).is_equal(StatShape.at_stage(m.core, Stage.Type.QI_GATHERING, Stage.SubTier.MIDDLE)["hp"])


func test_xp_carries_over_and_the_high_bar_caps() -> void:
	var m := _monster()
	var ups := m.add_xp(60 + 120 + 5)
	assert_int(ups).is_equal(2)
	assert_int(m.sub_tier).is_equal(Stage.SubTier.HIGH)
	assert_int(m.xp).is_equal(5)
	m.add_xp(1000)
	assert_int(m.xp).is_equal(MonsterInstance.HIGH_BAR)
	assert_bool(m.can_gain_xp()).is_false()


func test_higher_sub_tiers_never_have_less_than_lower_ones() -> void:
	var rng := _rng(8)
	for shape in StatShape.rollable():
		for i in 10:
			var core := StatShape.roll_core(shape, rng)
			for stage in [Stage.Type.QI_GATHERING, Stage.Type.FOUNDATION, Stage.Type.CORE_FORMATION]:
				var lo := StatShape.at_stage(core, stage, Stage.SubTier.LOWER)
				var mid := StatShape.at_stage(core, stage, Stage.SubTier.MIDDLE)
				var hi := StatShape.at_stage(core, stage, Stage.SubTier.HIGH)
				assert_int(mid["hp"]).is_greater_equal(lo["hp"])
				assert_int(hi["hp"]).is_greater_equal(mid["hp"])
				assert_float(hi["initiative"]).is_greater_equal(lo["initiative"])


func test_reference_individuals_keep_their_fixed_stats() -> void:
	var m := MonsterInstance.of_species(BattleSetup.load_def(&"forge_golem"))
	m.add_xp(60)
	assert_int(m.sub_tier).is_equal(Stage.SubTier.MIDDLE)
	assert_int(m.stats["hp"]).is_equal(8)


func test_the_rolled_spread_survives_a_save() -> void:
	var m := _monster(StatShape.Id.ANVIL)
	m.add_xp(60)
	var back := MonsterInstance.from_dict(JSON.parse_string(JSON.stringify(m.to_dict())))
	assert_int(back.sub_tier).is_equal(Stage.SubTier.MIDDLE)
	assert_int(back.core["hp"]).is_equal(m.core["hp"])
	back.add_xp(120)
	assert_int(back.sub_tier).is_equal(Stage.SubTier.HIGH)
	assert_int(back.stats["hp"]).is_equal(StatShape.at_stage(m.core, Stage.Type.QI_GATHERING, Stage.SubTier.HIGH)["hp"])
