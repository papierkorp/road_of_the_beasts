extends GdUnitTestSuite
## Skill evolution (gdd_overworld §4.7): variants, rules, slots, offers, applying to the battle unit.


func _rng(seed_value := 5) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng


func _def(id: String) -> MonsterDef:
	return BattleSetup.load_def(StringName(id))


func _args(list: Array[Dictionary]) -> Array[String]:
	var out: Array[String] = []
	for v in list:
		out.append(String(v["arg"]))
	return out


func _cells_of(arg: String) -> int:
	return (Shapes.BASE[StringName(arg.split(":")[0])] as Array).size()


func _individual(species: String, stage: Stage.Type, rarity := MonsterInstance.Rarity.NORMAL) -> MonsterInstance:
	return MonsterInstance.roll(_def(species), _rng(), StatShape.Id.BALANCED, stage, Stage.SubTier.LOWER, rarity)


# ---------- slots and rarity ----------

func test_one_evolution_slot_per_stage_above_qi_gathering() -> void:
	assert_int(Evolution.slot_count(Stage.Type.QI_GATHERING)).is_equal(0)
	assert_int(Evolution.slot_count(Stage.Type.FOUNDATION)).is_equal(1)
	assert_int(Evolution.slot_count(Stage.Type.CORE_FORMATION)).is_equal(2)


func test_rarity_decides_offers_and_picks() -> void:
	assert_int(Evolution.offers_per_slot(MonsterInstance.Rarity.NORMAL)).is_equal(2)
	assert_int(Evolution.offers_per_slot(MonsterInstance.Rarity.RARE)).is_equal(3)
	assert_int(Evolution.picks_per_slot(MonsterInstance.Rarity.RARE)).is_equal(1)
	assert_int(Evolution.picks_per_slot(MonsterInstance.Rarity.EPIC)).is_equal(2)
	assert_int(Evolution.picks_per_slot(MonsterInstance.Rarity.LEGENDARY)).is_greater(5)


# ---------- shape ----------

func test_reshaping_keeps_the_cell_count_and_widening_adds_one() -> void:
	var v := Evolution.variants(_def("gloom_wolf"), Evolution.SURGE, &"shape", [])       # Gloom Rift, I3
	assert_bool(v.is_empty()).is_false()
	var reshape := 0
	var widen := 0
	for variant in v:
		var arg := String(variant["arg"])
		assert_bool(arg == "I3:0").is_false()                 # never the current shape
		if arg.ends_with(":w"):
			widen += 1
			assert_int(_cells_of(arg)).is_equal(4)
		else:
			reshape += 1
			assert_int(_cells_of(arg)).is_equal(3)
	assert_int(reshape).is_greater(0)
	assert_int(widen).is_greater(0)


func test_a_ring_has_no_shape_to_evolve() -> void:
	assert_bool(Evolution.variants(_def("forge_golem"), Evolution.SURGE, &"shape", []).is_empty()).is_true()


func test_swarm_surges_stay_small() -> void:
	var v := _args(Evolution.variants(_def("thorn_mites"), Evolution.SURGE, &"shape", []))
	assert_array(v).contains_exactly(["I2:1"])


func test_a_trail_stays_a_straight_line() -> void:
	for arg in _args(Evolution.variants(_def("ember_hawk"), Evolution.SURGE, &"shape", [])):
		assert_str(arg).starts_with("I")


func test_utilities_reshape_but_never_widen() -> void:
	for arg in _args(Evolution.variants(_def("gloom_wolf"), Evolution.UTILITY, &"shape", [])):    # Mire, T4
		assert_bool(arg.ends_with(":w")).is_false()
		assert_int(_cells_of(arg)).is_equal(4)


# ---------- twist ----------

func test_a_baseline_surge_can_take_any_swappable_twist() -> void:
	var v := _args(Evolution.variants(_def("gloom_wolf"), Evolution.SURGE, &"twist", []))
	assert_array(v).contains_exactly_in_any_order(["LOB", "SLOW_BURN", "LINGERING", "CONSTRICT"])


func test_a_twist_can_be_swapped_but_not_into_the_same_twist() -> void:
	var v := _args(Evolution.variants(_def("moss_turtle"), Evolution.SURGE, &"twist", []))   # Slow-burn
	assert_bool(v.has("SLOW_BURN")).is_false()
	assert_bool(v.has("NONE")).is_true()


func test_species_defining_twists_cannot_be_swapped() -> void:
	for id in ["blaze_tiger", "ember_hawk", "forge_golem", "dusk_moth"]:       # Pounce, Trail, Ring, Wide
		assert_bool(Evolution.variants(_def(id), Evolution.SURGE, &"twist", []).is_empty()).is_true()


func test_utilities_have_no_twists() -> void:
	assert_bool(Evolution.variants(_def("gloom_wolf"), Evolution.UTILITY, &"twist", []).is_empty()).is_true()


# ---------- small values ----------

func test_zones_can_last_longer_and_reach_further() -> void:
	var v := _args(Evolution.variants(_def("gloom_wolf"), Evolution.UTILITY, &"value", []))   # Mire is a zone
	assert_array(v).contains_exactly_in_any_order(["range", "duration"])


func test_ground_skills_only_gain_range() -> void:
	var v := _args(Evolution.variants(_def("blaze_tiger"), Evolution.UTILITY, &"value", []))   # Lava Field
	assert_array(v).contains_exactly(["range"])


func test_a_pounce_has_no_range_to_gain() -> void:
	assert_bool(Evolution.variants(_def("blaze_tiger"), Evolution.SURGE, &"value", []).is_empty()).is_true()


# ---------- swap ----------

func test_a_utility_swap_respects_aspect_and_the_kins_locks() -> void:
	var tiger := _args(Evolution.variants(_def("blaze_tiger"), Evolution.UTILITY, &"swap", []))
	assert_bool(tiger.has("raise_wall")).is_true()             # a Beast may raise props
	assert_bool(tiger.has("lava_field")).is_false()            # its own utility
	assert_bool(tiger.has("bog")).is_false()                   # Nature skill for a Force monster
	var hawk := _args(Evolution.variants(_def("ember_hawk"), Evolution.UTILITY, &"swap", []))
	assert_bool(hawk.has("raise_wall")).is_false()             # Winged can't raise props
	assert_bool(hawk.has("lava_field")).is_true()


func test_a_surge_cannot_be_swapped() -> void:
	assert_bool(Evolution.variants(_def("gloom_wolf"), Evolution.SURGE, &"swap", []).is_empty()).is_true()


# ---------- applying ----------

func test_an_evolved_unit_gets_a_modified_copy_and_the_species_stays() -> void:
	var m := _individual("gloom_wolf", Stage.Type.FOUNDATION)
	m.evolutions.append({"slot": 0, "skill": "surge", "family": "shape", "arg": "T4:2:w"})
	var unit := m.to_battle_unit()
	assert_str(String(unit.surge.shapes[0])).is_equal("T4")
	assert_int(unit.surge.orientation).is_equal(2)
	assert_int(unit.surge.surge_value()).is_equal(_def("gloom_wolf").surge.surge_value() - 1)
	assert_str(String(_def("gloom_wolf").surge.shapes[0])).is_equal("I3")
	assert_object(unit.surge).is_not_same(_def("gloom_wolf").surge)
	assert_object(unit.utility).is_same(_def("gloom_wolf").utility)       # untouched skills stay shared


func test_a_twist_swap_changes_the_price_with_it() -> void:
	var m := _individual("gloom_wolf", Stage.Type.FOUNDATION)
	m.evolutions.append({"slot": 0, "skill": "surge", "family": "twist", "arg": "SLOW_BURN"})
	var unit := m.to_battle_unit()
	assert_int(unit.surge.twist).is_equal(SkillDef.Twist.SLOW_BURN)
	assert_int(unit.surge.surge_value()).is_equal(_def("gloom_wolf").surge.surge_value() + 1)
	assert_int(unit.surge.fire_delay()).is_equal(2)


func test_range_and_duration_reach_the_skill() -> void:
	var m := _individual("gloom_wolf", Stage.Type.CORE_FORMATION)
	m.evolutions.append({"slot": 0, "skill": "surge", "family": "value", "arg": "range"})
	m.evolutions.append({"slot": 1, "skill": "utility", "family": "value", "arg": "duration"})
	var unit := m.to_battle_unit()
	assert_int(unit.surge.base_range()).is_equal(_def("gloom_wolf").surge.base_range() + 1)
	assert_int(unit.utility.duration_bonus).is_equal(1)


func test_a_longer_zone_lasts_a_round_more_in_the_battle() -> void:
	# the unit-sheet adapter carries the duration pick into the battle skill (battle/core/unit_sheets.gd)
	var plain := MonsterInstance.of_species(_def("gloom_wolf"))
	var longer := MonsterInstance.of_species(_def("gloom_wolf"))
	longer.evolutions.append({"slot": 0, "skill": "utility", "family": "value", "arg": "duration"})
	var slot := BattleContent.shared().kit(&"gloom_wolf").utility_slot
	assert_int(UnitSheets.from_instance(plain).skills[slot].duration).is_equal(2)
	assert_int(UnitSheets.from_instance(longer).skills[slot].duration).is_equal(3)


func test_a_swapped_utility_replaces_the_skill() -> void:
	var m := _individual("blaze_tiger", Stage.Type.FOUNDATION)
	m.evolutions.append({"slot": 0, "skill": "utility", "family": "swap", "arg": "raise_wall"})
	assert_str(String(m.to_battle_unit().utility.id)).is_equal("raise_wall")


func test_after_a_swap_the_new_skill_can_still_be_tuned() -> void:
	var picks: Array[Dictionary] = [{"slot": 0, "skill": "utility", "family": "swap", "arg": "raise_wall"}]
	assert_bool(Evolution.variants(_def("blaze_tiger"), Evolution.UTILITY, &"value", picks).is_empty()).is_false()
	# ... but a swap is only possible before the utility got any other pick
	var tuned: Array[Dictionary] = [{"slot": 0, "skill": "utility", "family": "value", "arg": "range"}]
	assert_bool(Evolution.variants(_def("blaze_tiger"), Evolution.UTILITY, &"swap", tuned).is_empty()).is_true()


func test_every_path_is_taken_once_per_skill() -> void:
	var picks: Array[Dictionary] = [{"slot": 0, "skill": "surge", "family": "twist", "arg": "LOB"}]
	assert_bool(Evolution.variants(_def("gloom_wolf"), Evolution.SURGE, &"twist", picks).is_empty()).is_true()


func test_a_widened_surge_cannot_be_widened_again() -> void:
	var picks: Array[Dictionary] = [{"slot": 0, "skill": "surge", "family": "shape", "arg": "T4:0:w"}]
	# the shape path itself is closed after its pick; the penalty also stops any second widen
	assert_bool(Evolution.variants(_def("gloom_wolf"), Evolution.SURGE, &"shape", picks).is_empty()).is_true()


# ---------- picking on an individual ----------

func test_qi_gathering_monsters_have_no_slots() -> void:
	var m := _individual("gloom_wolf", Stage.Type.QI_GATHERING)
	assert_int(m.evo_slots()).is_equal(0)
	assert_int(m.slot_offers(0).size()).is_equal(0)


func test_offers_are_stable_and_limited_by_rarity() -> void:
	var m := _individual("gloom_wolf", Stage.Type.FOUNDATION)
	var a := m.slot_offers(0)
	var b := m.slot_offers(0)
	assert_int(a.size()).is_equal(2)
	assert_array(a).is_equal(b)
	m.rarity = MonsterInstance.Rarity.RARE
	assert_int(m.slot_offers(0).size()).is_equal(3)


func test_a_normal_monster_picks_once_per_slot_from_the_offers() -> void:
	var m := _individual("gloom_wolf", Stage.Type.FOUNDATION)
	var offered := m.slot_offers(0)
	var path: Dictionary = offered[0]
	var variants := m.path_variants(path["skill"], path["family"])
	assert_bool(m.pick(0, path["skill"], path["family"], String(variants[0]["arg"]))).is_true()
	assert_int(m.picks_left(0)).is_equal(0)
	var other: Dictionary = offered[1]
	var other_variants := m.path_variants(other["skill"], other["family"])
	if not other_variants.is_empty():
		assert_bool(m.pick(0, other["skill"], other["family"], String(other_variants[0]["arg"]))).is_false()


func test_a_path_that_was_not_offered_cannot_be_picked() -> void:
	var m := _individual("gloom_wolf", Stage.Type.FOUNDATION)
	for path in Evolution.all_paths():
		if not m.is_offered(0, path["skill"], path["family"]):
			var variants := Evolution.variants(m.species(), path["skill"], path["family"], [])
			if not variants.is_empty():
				assert_bool(m.pick(0, path["skill"], path["family"], String(variants[0]["arg"]))).is_false()
				return


func test_an_epic_monster_picks_two_different_paths_in_a_slot() -> void:
	var m := _individual("gloom_wolf", Stage.Type.FOUNDATION, MonsterInstance.Rarity.EPIC)
	var picked := 0
	for path in m.slot_offers(0):
		var variants := m.path_variants(path["skill"], path["family"])
		if picked < 2 and not variants.is_empty() and m.pick(0, path["skill"], path["family"], String(variants[0]["arg"])):
			picked += 1
	assert_int(picked).is_equal(2)
	assert_int(m.picks_left(0)).is_equal(0)


func test_a_legendary_monster_takes_everything_offered() -> void:
	var m := _individual("gloom_wolf", Stage.Type.FOUNDATION, MonsterInstance.Rarity.LEGENDARY)
	var offers := m.slot_offers(0)
	assert_int(offers.size()).is_equal(6)
	for path in offers:
		var variants := m.path_variants(path["skill"], path["family"])
		assert_bool(variants.is_empty()).is_false()
		assert_bool(m.pick(0, path["skill"], path["family"], String(variants[0]["arg"]))).is_true()


func test_resetting_clears_all_evolutions() -> void:
	var m := _individual("gloom_wolf", Stage.Type.FOUNDATION)
	var path: Dictionary = m.slot_offers(0)[0]
	m.pick(0, path["skill"], path["family"], String(m.path_variants(path["skill"], path["family"])[0]["arg"]))
	m.reset_evolutions()
	assert_int(m.evolutions.size()).is_equal(0)
	assert_int(m.picks_left(0)).is_equal(1)


func test_evolutions_survive_a_save() -> void:
	var m := _individual("gloom_wolf", Stage.Type.FOUNDATION)
	m.evolutions.append({"slot": 0, "skill": "surge", "family": "twist", "arg": "LOB"})
	var back := MonsterInstance.from_dict(JSON.parse_string(JSON.stringify(m.to_dict())))
	assert_int(back.evolutions.size()).is_equal(1)
	assert_str(String(back.evolutions[0]["arg"])).is_equal("LOB")
	assert_int(back.to_battle_unit().surge.twist).is_equal(SkillDef.Twist.LOB)


func test_an_evolved_monster_plays_a_whole_battle() -> void:
	var m := _individual("gloom_wolf", Stage.Type.FOUNDATION)
	m.evolutions.append({"slot": 0, "skill": "surge", "family": "shape", "arg": "L3:1"})
	var enemy := MonsterInstance.of_species(_def("moss_turtle"))
	var b := BattleSetup.create_from_units(&"1v1", [m] as Array[MonsterInstance], [enemy] as Array[MonsterInstance])
	var rng := _rng(9)
	b.begin()
	var guard := 0
	while not b.over and guard < 400:
		AiBrain.play_turn(b, b.turn_owner, rng)
		guard += 1
	assert_bool(b.over).is_true()
