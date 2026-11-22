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
	g.add_item(Materials.beast_part(0), 3)
	g.add_egg(&"moss_turtle")
	g.path_points = 2
	g.roster[0].gain_xp(70, g.stage)
	var data = JSON.parse_string(JSON.stringify(g.to_dict()))
	var h := GameState.from_dict(data)
	assert_int(h.day).is_equal(2)
	assert_int(h.ap).is_equal(g.ap)
	assert_int(h.count(Materials.beast_part(0))).is_equal(3)
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
	assert_int(m.choice_picks).is_equal(1)


func test_a_reshape_gives_every_point_back() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 9
	var m := MonsterInstance.grown(GameData.monster(&"dusk_moth"), rng, 5)
	m.refund_points()
	assert_dict(m.stats).is_equal(MonsterInstance.FLOOR)
	assert_int(m.points_spent() + m.unspent).is_equal(MonsterInstance.START_POINTS + MonsterInstance.STEP_POINTS * 5)


func test_the_cultivation_systems_and_the_eggs_of_the_values_exist() -> void:
	assert_int(CultivationDef.ids().size()).is_equal(3)
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
			assert_bool(v.egg_pool.find(id) < v.egg_pool_start).is_true()      # only what the first game has open
		assert_int(kins.size()).is_equal(3)
		assert_array(GameState.egg_offer(v, seed_value, 0)).is_equal(offer)
	var seen := {}
	for seed_value in 60:
		for id in GameState.egg_offer(v, seed_value, 99):
			seen[id] = true
	assert_int(seen.size()).is_equal(v.egg_pool.size())      # finished games open the whole pool
	var content := BattleContent.shared()
	for sid in CultivationDef.ids():
		for n: Dictionary in CultivationDef.of(sid).nodes:
			if n["kind"] == "tamer":
				assert_object(content.tamer_skill(n["ref"])).is_not_null()


func test_a_development_step_raises_a_slot_up_to_level_three() -> void:
	var m := MonsterInstance.hatched(GameData.monster(&"blaze_tiger"))
	m.learn(&"fire_trail")
	m.learn(&"strike_jab")
	m.dev_steps = 2
	assert_bool(m.develop_slot(0)).is_true()
	assert_bool(m.develop_slot(0)).is_true()
	assert_int(m.slot_level(0)).is_equal(3)
	assert_int(m.slot_level(1)).is_equal(1)
	assert_bool(m.develop_slot(1)).is_false()
	assert_bool(m.develop_slot(2)).is_false()
	var copy := MonsterInstance.from_dict(JSON.parse_string(JSON.stringify(m.to_dict())))
	assert_int(copy.slot_level(0)).is_equal(3)
	assert_array(copy.kit).is_equal(m.kit)


func test_a_monster_from_an_egg_is_shaped_by_the_player() -> void:
	var g := GameState.new_game(7, &"way_of_the_beast_lord", &"blaze_tiger")
	var m := g.roster[0]
	assert_bool(m.fresh).is_true()
	assert_int(m.kit.size()).is_equal(0)
	assert_int(m.unspent).is_equal(MonsterInstance.START_POINTS - m.points_spent())
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
	assert_str(String(UnitSheets.from_instance(m).skills[3].id)).is_equal("run")
	m.fresh = false
	assert_bool(m.unlearn(0)).is_false()


func test_a_wild_monster_fills_its_four_slots() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 4
	var m := MonsterInstance.grown(GameData.monster(&"moss_turtle"), rng, 0)
	assert_int(m.slots).is_equal(4)
	assert_int(m.kit.size()).is_equal(4)
	assert_bool(m.fresh).is_false()
	assert_int(m.choice_picks).is_equal(0)
	var later := MonsterInstance.grown(GameData.monster(&"moss_turtle"), rng, 7)
	assert_int(later.choice_picks).is_equal(0)
	assert_int((later.slots - 4) + later.dev_steps + later.gifts.size()).is_equal(2)


func test_a_stage_breakthrough_gives_one_of_three() -> void:
	var m := MonsterInstance.hatched(GameData.monster(&"blaze_tiger"), 3)
	assert_int(m.choice_picks).is_equal(1)
	assert_bool(m.choose(MonsterInstance.BREADTH)).is_true()
	assert_int(m.slots).is_equal(5)
	assert_bool(m.choose(MonsterInstance.DEPTH)).is_false()
	var epic := MonsterInstance.hatched(GameData.monster(&"blaze_tiger"), 3, MonsterInstance.Bloodline.ANCIENT)
	assert_int(epic.choice_picks).is_equal(2)                 # Ancient and Divine take two of the offer
	epic.gift_picks = 0                                       # the gifts of its bloodline are tested below
	assert_bool(epic.choose(MonsterInstance.BLOOD, &"brawler")).is_true()
	assert_bool(epic.choose(MonsterInstance.BLOOD, &"surefoot")).is_false()
	assert_bool(epic.choose(MonsterInstance.DEPTH)).is_true()
	assert_array(epic.gifts).is_equal([&"brawler"])
	assert_int(epic.dev_steps).is_equal(1)
	var copy := MonsterInstance.from_dict(JSON.parse_string(JSON.stringify(epic.to_dict())))
	assert_array(copy.gifts).is_equal([&"brawler"])


func test_a_wider_bloodline_is_offered_lore_and_reshape() -> void:
	var def := GameData.monster(&"blaze_tiger")
	var mortal := MonsterInstance.hatched(def, 3)
	assert_array(mortal.offered()).is_equal([MonsterInstance.BREADTH, MonsterInstance.DEPTH, MonsterInstance.BLOOD])
	assert_bool(mortal.can_choose(MonsterInstance.LORE)).is_false()
	var spirit := MonsterInstance.hatched(def, 3, MonsterInstance.Bloodline.SPIRIT)
	assert_int(spirit.offered().size()).is_equal(4)
	assert_int(spirit.choice_picks).is_equal(1)
	var options := spirit.lore_options()
	assert_array(options).is_not_empty()                       # skills of the other species of its Kin
	var before := spirit.learnable().size()
	assert_bool(spirit.can_learn(options[0].id)).is_false()
	assert_bool(spirit.choose(MonsterInstance.LORE, options[0].id)).is_true()
	assert_int(spirit.learnable().size()).is_equal(before + 1)
	assert_bool(spirit.learn(options[0].id)).is_true()
	assert_str(String(spirit.kit_skills()[0].id)).is_equal(String(options[0].id))
	var copy := MonsterInstance.from_dict(JSON.parse_string(JSON.stringify(spirit.to_dict())))
	assert_str(String(copy.kit_skills()[0].id)).is_equal(String(options[0].id))
	var divine := MonsterInstance.hatched(def, 3, MonsterInstance.Bloodline.DIVINE)
	assert_int(divine.offered().size()).is_equal(5)
	assert_int(divine.choice_picks).is_equal(2)
	divine.buy("hp")
	assert_bool(divine.choose(MonsterInstance.RESHAPE)).is_true()
	assert_dict(divine.stats).is_equal(MonsterInstance.FLOOR)
	assert_bool(divine.choose(MonsterInstance.RESHAPE)).is_false()      # nothing twice in one breakthrough
	assert_bool(divine.choose(MonsterInstance.DEPTH)).is_true()


func test_a_bloodline_awakens_gifts_from_the_start_and_caps_no_stage() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	var def := GameData.monster(&"blaze_tiger")
	for grade in MonsterInstance.Bloodline.size():
		var wild := MonsterInstance.grown(def, rng, 0, grade as MonsterInstance.Bloodline)
		assert_int(wild.gifts.size()).is_equal(grade)            # a wild monster comes with them
		var egg := MonsterInstance.hatched(def, 0, grade as MonsterInstance.Bloodline)
		assert_int(egg.gifts.size()).is_equal(0)
		assert_int(egg.gift_picks).is_equal(grade)               # from an egg the player chooses them
	var mortal := MonsterInstance.grown(def, rng, 8)             # Core Formation High
	mortal.gain_xp(MonsterInstance.XP_STEPS[8], Stage.Type.IMMORTAL)
	assert_int(int(mortal.stage)).is_equal(int(Stage.Type.SOUL))       # a Mortal bloodline passes Core Formation
	for i in 4:
		mortal.gain_xp(MonsterInstance.XP_STEPS[11], Stage.Type.SOUL)
	assert_int(mortal.step()).is_equal(11)                        # only the stage of its tamer holds it


func test_every_kin_has_a_trait_four_groups_and_gifts() -> void:
	for k in MonsterDef.Kin.values():
		var def := KinDef.of(k)
		assert_object(def).is_not_null()
		assert_str(def.trait_name).is_not_empty()
		assert_int(def.learns.size()).is_equal(4)
		assert_int(def.never_learns().size()).is_equal(2)
		assert_int(def.gifts.size()).is_equal(3)


func test_the_cheats_raise_the_stage_of_tamer_and_monsters() -> void:
	var g := GameState.new_game(7, &"way_of_the_beast_lord", &"blaze_tiger")
	Cheats.monsters_stage_up(g)
	assert_int(int(g.roster[0].stage)).is_equal(0)
	Cheats.stage_up(g)
	assert_int(int(g.stage)).is_equal(1)
	Cheats.monsters_stage_up(g)
	assert_int(int(g.roster[0].stage)).is_equal(1)
	assert_int(g.roster[0].choice_picks).is_equal(1)


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
	assert_int(GameData.monster_ids().size()).is_equal(9)      # the multiplayer battle keeps its nine


func test_void_monsters_live_in_the_void_only_and_come_as_an_egg_of_the_trial() -> void:
	var g := GameState.new_game(21, &"way_of_the_beast_lord", &"moss_turtle")
	for e in WildArea.encounters(g, 0):
		for m in e.fight.enemies:
			assert_int(int(m.species().kin)).is_not_equal(int(MonsterDef.Kin.VOID))
	var f := VoidPlace.fight(g)
	for m in f.enemies:
		assert_int(int(m.species().kin)).is_equal(int(MonsterDef.Kin.VOID))
	g.void_depth = VoidPlace.depths(g) - 1
	var trial := VoidPlace.fight(g)
	trial.team = g.default_team(1)
	VoidPlace.resolve(g, trial, null, true)
	assert_int(int(g.stage)).is_equal(1)
	assert_int(g.eggs.size()).is_equal(1)
	assert_int(int(GameData.monster(StringName(g.eggs[0]["species"])).kin)).is_equal(int(MonsterDef.Kin.VOID))
