extends GdUnitTestSuite
## The game state (docs/vision.md §3, §5; docs/monsters.md §5): the day without day AP, the lifespan, the stages,
## the save, eggs, and the monsters: points, growth, the breakthrough choice and the development of slots.

const H := preload("res://tests/overworld/helpers.gd")


func test_a_new_game_starts_with_one_monster_and_what_its_way_brings() -> void:
	for way: StringName in [H.ARTIFICER, H.FORMATION, H.ALCHEMIST]:
		var g := H.game(way)
		assert_int(g.roster.size()).is_equal(1)
		assert_int(int(g.stage)).is_equal(0)
		assert_int(g.lifespan).is_equal(g.values.lifespan_years[0])
	var smith := H.game(H.ARTIFICER)
	assert_bool(smith.battleground.is_empty()).is_false()             # the board is the Artificer's alone
	assert_int(smith.tamer_slots()).is_equal(0)
	assert_int(smith.carry()).is_equal(smith.values.carry_base)
	assert_array(smith.tamer_skills).is_empty()
	var tamer := H.game(H.FORMATION)
	assert_array(tamer.tamer_skills).is_equal([GameState.SEAL])
	assert_bool(tamer.battleground.is_empty()).is_true()
	assert_dict(tamer.parts).is_empty()
	assert_int(tamer.carry()).is_equal(0)
	var brewer := H.game(H.ALCHEMIST)
	assert_array(brewer.tamer_skills).is_empty()
	assert_int(brewer.count("pill:binding")).is_equal(brewer.values.alchemist_start_pills)


func test_the_lifespan_is_the_one_clock_and_every_deed_costs_a_year() -> void:
	var g := H.game()
	var years := g.lifespan
	assert_int(years).is_equal(g.values.lifespan_years[0])
	H.wild_fight(g, 0, false)                                         # lost: the year is spent all the same
	assert_int(g.lifespan).is_equal(years - 1)
	H.wild_fight(g, 0, true)
	assert_int(g.lifespan).is_equal(years - 2)
	assert_bool(Wild.reroll(g)).is_true()                             # a new look costs a year too
	assert_int(g.lifespan).is_equal(years - 3)


func test_the_end_of_the_lifespan_forces_the_trial_and_closes_the_wild() -> void:
	var g := H.game()
	g.spend(g.lifespan)
	assert_bool(g.forced_trial).is_true()
	assert_bool(Wild.can_fight(g)).is_false()
	assert_bool(Wild.reroll(g)).is_false()
	assert_object(Wild.fight_for(g, 0)).is_null()


func test_a_breakthrough_gives_the_next_stage_a_whole_lifespan_and_a_boon() -> void:
	var g := H.game()
	g.spend(4)
	g.break_through()
	assert_int(int(g.stage)).is_equal(1)
	assert_int(g.lifespan).is_equal(g.values.lifespan_years[1])       # the years left over are lost
	assert_bool(g.boon_pick).is_true()
	assert_bool(g.take_boon(&"no such boon")).is_false()
	assert_bool(g.take_boon(&"long_life")).is_true()
	assert_int(g.lifespan).is_equal(g.values.lifespan_years[1] + 3)   # this lifespan too
	assert_bool(g.take_boon(&"long_life")).is_false()                 # one boon per breakthrough
	g.break_through()
	assert_int(g.lifespan).is_equal(g.values.lifespan_years[2] + 3)   # and every one after it
	var slots := g.tamer_slots()
	var shown := Wild.shown(g)
	assert_bool(g.take_boon(&"wide_hand")).is_true()
	assert_int(g.tamer_slots()).is_equal(slots + 1)
	g.break_through()
	assert_bool(g.take_boon(&"keen_eye")).is_true()
	assert_int(Wild.shown(g)).is_equal(shown + 1)
	assert_int(Wild.offers(g).size()).is_equal(shown + 1)


func test_nobody_rises_past_immortal_and_the_sovereign_beast_wins_the_game() -> void:
	var g := H.game()
	for i in 9:
		g.break_through()
	assert_int(int(g.stage)).is_equal(int(Stage.Type.IMMORTAL))
	assert_bool(g.is_over()).is_false()
	g.win()
	assert_that(g.outcome).is_equal(GameState.WON)
	assert_int(int(g.stage)).is_equal(int(Stage.Type.IMMORTAL))


func test_a_save_holds_the_whole_game() -> void:
	var g := H.game(H.ARTIFICER)
	g.add_egg(&"moss_turtle")
	g.path_points = 2
	H.wild_fight(g, 1, true)
	g.break_through()
	g.take_boon(&"keen_eye")
	g.rises = [2, 4]
	g.roster[0].may_rise = true
	var back := GameState.from_dict(JSON.parse_string(JSON.stringify(g.to_dict())))
	var again := GameState.from_dict(JSON.parse_string(JSON.stringify(back.to_dict())))
	assert_str(JSON.stringify(again.to_dict())).is_equal(JSON.stringify(back.to_dict()))      # a save read and written again is the same
	assert_int(back.eggs.size()).is_equal(g.eggs.size())
	assert_int(back.path_points).is_equal(2)
	assert_dict(back.parts).is_equal(g.parts)
	assert_that(back.system).is_equal(H.ARTIFICER)
	assert_int(back.wild_roll).is_equal(g.wild_roll)
	assert_array(back.wild_gone).is_equal(g.wild_gone)
	assert_array(back.rises).is_equal([2, 4])
	assert_bool(back.roster[0].may_rise).is_true()
	assert_bool(back.boons.size() == 1 and back.boons[0] == &"keen_eye").is_true()
	assert_int(back.lifespan).is_equal(g.lifespan)
	assert_object(GameState.from_dict({"version": 4})).is_null()      # a save of the game before the wild


func test_an_egg_hatches_after_its_battles() -> void:
	var g := H.game()
	g.add_egg(&"moss_turtle")
	for i in g.values.egg_battles:
		assert_int(g.eggs.size()).is_equal(1)
		H.wild_fight(g, 0, false)                                     # a battle lost counts too
	assert_int(g.eggs.size()).is_equal(0)
	assert_int(g.roster.size()).is_equal(2)


func test_a_grown_monster_never_spends_more_than_its_points_and_ends_at_step_fourteen() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	assert_int(MonsterInstance.STEPS).is_equal(15)
	for step in [0, 4, 9, 14, 30]:
		var m := MonsterInstance.grown(GameData.monster(&"moss_turtle"), rng, step)
		var real := mini(step, 14)
		assert_int(m.step()).is_equal(real)
		assert_int(m.points_spent() + m.unspent).is_equal(MonsterInstance.START_POINTS + MonsterInstance.STEP_POINTS * real)
		assert_bool(m.unspent >= 0).is_true()
		assert_array(UnitSheets.from_instance(m).problems()).is_empty()


func test_a_step_gives_five_points_and_the_player_spends_them() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	var m := MonsterInstance.grown(GameData.monster(&"blaze_tiger"), rng, 0)
	var left := m.unspent
	assert_bool(m.rise(Stage.Type.QI_GATHERING)).is_true()
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
	for i in 9:
		m.rise(Stage.Type.QI_GATHERING)
	assert_int(int(m.stage)).is_equal(int(Stage.Type.QI_GATHERING))
	assert_int(int(m.sub_tier)).is_equal(int(Stage.SubTier.HIGH))
	assert_bool(m.rise(Stage.Type.FOUNDATION)).is_true()
	assert_int(int(m.stage)).is_equal(int(Stage.Type.FOUNDATION))
	assert_int(m.choice_picks).is_equal(1)
	for i in 30:
		m.rise(Stage.Type.IMMORTAL)
	assert_int(m.step()).is_equal(14)                                 # Immortal High is the top: no monster is Sovereign


func test_every_monster_has_the_same_choice_at_a_stage_breakthrough() -> void:
	var m := MonsterInstance.hatched(GameData.monster(&"blaze_tiger"), 3)
	assert_int(m.choice_picks).is_equal(1)
	assert_array(m.offered()).is_equal([MonsterInstance.BREADTH, MonsterInstance.DEPTH, MonsterInstance.LORE, MonsterInstance.RESHAPE])
	assert_bool(m.choose(MonsterInstance.BREADTH)).is_true()
	assert_int(m.slots).is_equal(5)
	assert_bool(m.choose(MonsterInstance.DEPTH)).is_false()           # one of them, not two
	var deep := MonsterInstance.hatched(GameData.monster(&"blaze_tiger"), 3)
	assert_bool(deep.choose(MonsterInstance.DEPTH)).is_true()
	assert_int(deep.dev_steps).is_equal(1)
	var wise := MonsterInstance.hatched(GameData.monster(&"blaze_tiger"), 3)
	var before := wise.learnable().size()
	assert_bool(wise.choose(MonsterInstance.LORE)).is_true()
	assert_int(wise.learnable().size()).is_equal(before + 1)
	assert_dict(wise.to_dict()).contains_keys(["slot_opts", "bonus_points"])
	assert_bool(wise.to_dict().has("rarity")).is_false()             # no bloodline, no grade, no gifts


func test_a_reshape_gives_every_point_back() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 9
	var m := MonsterInstance.grown(GameData.monster(&"dusk_moth"), rng, 5)
	m.refund_points()
	assert_dict(m.stats).is_equal(MonsterInstance.FLOOR)
	assert_int(m.points_spent() + m.unspent).is_equal(MonsterInstance.START_POINTS + MonsterInstance.STEP_POINTS * 5)


func test_a_monster_from_an_egg_is_shaped_by_the_player() -> void:
	var g := H.game()
	var m := g.roster[0]
	assert_bool(m.fresh).is_true()
	assert_int(m.kit.size()).is_equal(0)
	assert_dict(m.stats).is_equal(MonsterInstance.FLOOR)
	assert_int(m.learnable().size()).is_equal(8)
	for s in m.learnable():
		m.learn(s.id)
	assert_int(m.kit.size()).is_equal(MonsterInstance.START_SLOTS)
	assert_bool(m.unlearn(0)).is_true()
	assert_bool(m.learn(&"run")).is_true()
	assert_bool(m.learn(&"run")).is_false()
	assert_bool(m.learn(&"light_brazier")).is_false()      # a Beast learns no prop skill
	assert_int(UnitSheets.from_instance(m).skills.size()).is_equal(4)
	m.fresh = false
	assert_bool(m.unlearn(0)).is_false()


func test_a_wild_monster_fills_its_slots_and_spends_its_development_steps() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 4
	var m := MonsterInstance.grown(GameData.monster(&"moss_turtle"), rng, 0)
	assert_int(m.slots).is_equal(4)
	assert_int(m.kit.size()).is_equal(4)
	assert_bool(m.fresh).is_false()
	var late := MonsterInstance.grown(GameData.monster(&"moss_turtle"), rng, 14)
	assert_int(late.choice_picks).is_equal(0)
	assert_int(late.dev_steps).is_equal(0)
	var levels := 0
	for slot in late.kit.size():
		levels += late.slot_level(slot) - 1
		assert_int(late.slot_options(slot).size()).is_equal(late.slot_level(slot) - 1)
	assert_bool(levels >= 2).is_true()                               # the two late steps, and what it chose as Depth


func test_every_kin_has_a_trait_and_four_groups_and_no_further_passives() -> void:
	for k in MonsterDef.Kin.values():
		var def := KinDef.of(k)
		assert_object(def).is_not_null()
		assert_str(def.trait_name).is_not_empty()
		assert_int(def.learns.size()).is_equal(4)
		assert_int(def.never_learns().size()).is_equal(2)
		assert_int(def.passives().size()).is_less_equal(1)
		assert_object(def.get("gifts")).is_null()


func test_the_ways_and_the_eggs_of_the_values_exist() -> void:
	assert_array(CultivationDef.ids()).contains_exactly_in_any_order([H.ARTIFICER, H.FORMATION, H.ALCHEMIST])
	var v := GameValues.shared()
	for id in v.egg_pool:
		assert_object(GameData.monster(id)).is_not_null()
		assert_int(int(GameData.monster(id).kin)).is_not_equal(int(MonsterDef.Kin.VOID))
	for seed_value in 30:
		var offer := GameState.egg_offer(v, seed_value, 0)
		assert_int(offer.size()).is_equal(3)
		var kins := {}
		for id in offer:
			kins[GameData.monster(id).kin] = true
		assert_int(kins.size()).is_equal(3)
		assert_array(GameState.egg_offer(v, seed_value, 0)).is_equal(offer)


func test_the_cheats_raise_the_stage_of_tamer_and_monsters() -> void:
	var g := H.game()
	Cheats.monsters_stage_up(g)
	assert_int(int(g.roster[0].stage)).is_equal(0)
	assert_int(int(g.roster[0].sub_tier)).is_equal(int(Stage.SubTier.HIGH))
	Cheats.stage_up(g)
	assert_int(int(g.stage)).is_equal(1)
	Cheats.monsters_stage_up(g)
	assert_int(int(g.roster[0].stage)).is_equal(1)
	assert_int(g.roster[0].choice_picks).is_equal(1)
	var smith := H.game(H.ARTIFICER)
	var owned := 0
	for part in smith.parts:
		owned += int(smith.parts[part])
	Cheats.give_drop(smith, 3)
	var after := 0
	for part in smith.parts:
		after += int(smith.parts[part])
	assert_int(after).is_equal(owned + 3)
	assert_dict(smith.items).is_empty()


func test_every_species_learns_eight_skills_within_the_groups_of_its_kin() -> void:
	var per_kin := {}
	for void_kin in [false, true]:
		for id in GameData.species_ids(void_kin):
			var def := GameData.monster(id)
			per_kin[def.kin] = int(per_kin.get(def.kin, 0)) + 1
			assert_int(def.learnable.size()).is_equal(8)
			assert_int(def.learn_list().size()).is_equal(8)      # nothing in the list lies outside the groups
	for k in MonsterDef.Kin.values():
		assert_int(int(per_kin.get(k, 0))).is_equal(2)


func test_a_new_game_offers_three_gifts_of_its_way_and_gives_the_one_taken() -> void:
	var v := GameValues.shared()
	for way: StringName in [H.ARTIFICER, H.FORMATION, H.ALCHEMIST]:
		var offer := GameState.start_offer(v, 7, way)
		assert_int(offer.size()).is_equal(3)
		assert_array(GameState.start_offer(v, 7, way)).is_equal(offer)          # the same game, the same offer
		var plain := GameState.new_game(7, way, &"blaze_tiger")
		var g := GameState.new_game(7, way, &"blaze_tiger", null, String(offer[1]["id"]))
		match way:
			H.ARTIFICER:
				var owned := 0
				for part in g.parts:
					owned += int(g.parts[part])
				assert_bool(owned > 1).is_true()                                # more than the Dragon Vein
			H.FORMATION:
				assert_int(g.tamer_skills.size()).is_equal(plain.tamer_skills.size() + 1)
				assert_bool(g.nodes.has(StringName(offer[1]["id"]))).is_true()    # the node is taken, not to be bought again
				assert_int(g.path_points).is_equal(0)
			H.ALCHEMIST:
				assert_int(g.count("pill:" + String(offer[1]["id"]))).is_equal(v.alchemist_start_pills)
		var none := GameState.new_game(7, way, &"blaze_tiger", null, "not offered")
		assert_int(none.tamer_skills.size()).is_equal(plain.tamer_skills.size())
		assert_dict(none.items).is_equal(plain.items)


func test_what_catches_takes_no_tamer_slot() -> void:
	var g := GameState.new_game(7, H.FORMATION, &"blaze_tiger", null, String(GameState.start_offer(GameValues.shared(), 7, H.FORMATION)[0]["id"]))
	assert_int(g.tamer_slots()).is_equal(1)
	var loadout := g.default_loadout()
	assert_int(loadout.size()).is_equal(2)                              # Seal and the skill of the gift
	assert_bool(loadout.has(GameState.SEAL)).is_true()
	assert_bool(g.loadout_fits([GameState.SEAL, &"thorn_field", &"stone_wall"] as Array[StringName])).is_false()
	var brewer := H.game(H.ALCHEMIST)
	assert_bool(brewer.loadout_fits([&"pill_binding", &"pill_warding"] as Array[StringName])).is_true()
	assert_bool(brewer.loadout_fits([&"pill_swiftness", &"pill_warding"] as Array[StringName])).is_false()


func test_every_stat_starts_at_the_lowest_value_of_its_range_and_reach_goes_to_ten() -> void:
	var m := MonsterInstance.hatched(GameData.monster(&"dusk_moth"), MonsterInstance.STEPS - 1)
	assert_dict(m.stats).is_equal({"hp": 1, "pace": 1.0, "move": 1, "reach": 1, "tpr": 1, "ap": 1})
	assert_int(m.unspent).is_equal(MonsterInstance.START_POINTS + MonsterInstance.STEP_POINTS * (MonsterInstance.STEPS - 1))
	for i in 9:
		assert_bool(m.buy("reach")).is_true()
	assert_int(int(m.stats["reach"])).is_equal(10)
	assert_bool(m.can_buy("reach")).is_false()
	assert_array(UnitSheets.from_instance(m, BattleContent.shared()).problems()).is_empty()


func test_the_same_skill_may_sit_in_two_slots() -> void:
	var m := MonsterInstance.hatched(GameData.monster(&"dusk_moth"))
	var first := m.learnable()[0].id
	assert_bool(m.learn(first)).is_true()
	assert_bool(m.learn(first)).is_true()
	assert_int(m.kit.count(first)).is_equal(2)
	assert_int(m.battle_skills().size()).is_equal(2)


func test_a_wild_monster_rolls_a_stat_shape_by_the_lean_of_its_kin() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	var seen := {}
	var hp := {"bulwark": 0, "caster": 0}
	var reach := {"bulwark": 0, "caster": 0}
	for i in 400:
		var m := MonsterInstance.grown(GameData.monster(&"forge_golem"), rng, 6)       # Stone: mostly Bulwark, never Swift
		seen[m.stat_shape] = int(seen.get(m.stat_shape, 0)) + 1
		assert_int(m.unspent).is_less(5)
		if hp.has(m.stat_shape):
			hp[m.stat_shape] += int(m.stats["hp"])
			reach[m.stat_shape] += int(m.stats["reach"])
	assert_bool(seen.has("swift")).is_false()
	assert_int(int(seen["bulwark"])).is_greater(int(seen["caster"]))
	assert_float(float(hp["bulwark"]) / seen["bulwark"]).is_greater(float(hp["caster"]) / seen["caster"])
	assert_float(float(reach["caster"]) / seen["caster"]).is_greater(float(reach["bulwark"]) / seen["bulwark"])
	var m2 := MonsterInstance.grown(GameData.monster(&"forge_golem"), rng, 6)
	assert_str(MonsterInstance.from_dict(m2.to_dict()).stat_shape).is_equal(m2.stat_shape)
	assert_str(MonsterInstance.hatched(GameData.monster(&"forge_golem")).stat_shape).is_empty()
