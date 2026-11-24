extends GdUnitTestSuite
## The void, the breakthrough trial, the Sovereign beast and the tree of the Way (docs/vision.md §3, §4, §8).

const H := preload("res://tests/overworld/helpers.gd")


func test_void_monsters_stand_above_the_stage_and_live_in_the_void_only() -> void:
	var g := H.game()
	var f := VoidPlace.fight(g)
	for m in f.enemies:
		assert_int(int(m.species().kin)).is_equal(int(MonsterDef.Kin.VOID))
		assert_bool(m.step() > GameState.step_of(0, 2)).is_true()
	for n in Wild.offers(g):
		for m: MonsterInstance in n["enemies"]:
			assert_int(int(m.species().kin)).is_not_equal(int(MonsterDef.Kin.VOID))


func test_only_the_artificer_brings_a_battleground_to_the_void() -> void:
	var smith := H.game(H.ARTIFICER)
	assert_dict(VoidPlace.fight(smith).own_map).is_equal(smith.battleground)
	assert_int(VoidPlace.fight(smith).carry).is_equal(0)               # the board there is their own already
	for way: StringName in [H.FORMATION, H.ALCHEMIST]:
		var g := H.game(way)
		var f := VoidPlace.fight(g)
		var m := MapData.from_dict(f.own_map)
		assert_array(m.problems(BattleContent.shared())).is_empty()
		assert_int(f.max_team).is_equal(g.values.team_room)
		assert_dict(VoidPlace.fight(g).own_map).is_equal(f.own_map)      # the same depth has the same board
		g.void_depth = 1
		assert_dict(VoidPlace.fight(g).own_map).is_not_equal(f.own_map)


func test_the_void_monsters_of_a_depth_are_drawn_per_game() -> void:
	var a := VoidPlace.fight(H.game(H.FORMATION, 51))
	var b := VoidPlace.fight(H.game(H.FORMATION, 51))
	assert_str(a.enemy_text()).is_equal(b.enemy_text())
	var seen := {}
	for seed_value in 12:
		seen[VoidPlace.fight(H.game(H.FORMATION, seed_value)).enemy_text()] = true
	assert_bool(seen.size() > 1).is_true()


func test_an_attack_costs_a_year_and_a_depth_won_gives_one_insight() -> void:
	var g := H.game()
	var years := g.lifespan
	H.void_fight(g, false)
	assert_int(g.void_depth).is_equal(0)
	assert_int(g.path_points).is_equal(0)
	assert_int(g.lifespan).is_equal(years - 1)                        # lost: the year is spent
	H.void_fight(g, true)
	assert_int(g.void_depth).is_equal(1)
	assert_int(g.path_points).is_equal(1)
	assert_int(g.lifespan).is_equal(years - 2)


func test_the_void_lifts_every_monster_that_fought_also_into_the_next_stage() -> void:
	var g := H.game()
	var m := g.roster[0]
	H.void_fight(g, true)
	assert_int(m.step()).is_equal(1)                                  # a step for a battle won in the void
	H.void_fight(g, false)
	assert_int(m.step()).is_equal(1)
	H.void_fight(g, true)
	assert_int(m.step()).is_equal(2)                                  # High
	var bench := MonsterInstance.hatched(GameData.monster(&"moss_turtle"))
	g.roster.append(bench)
	g.void_depth = 0
	var f := VoidPlace.fight(g)
	f.team = [m] as Array[MonsterInstance]
	Places.resolve(g, f, H.result(f, true))
	assert_int(m.step()).is_equal(2)                                  # held at High by the stage of its tamer
	g.void_depth = VoidPlace.depths(g) - 1
	f = VoidPlace.fight(g)
	f.team = [m] as Array[MonsterInstance]
	Places.resolve(g, f, H.result(f, true))
	assert_int(int(g.stage)).is_equal(1)
	assert_int(int(m.stage)).is_equal(1)                              # the trial lifts the team with the tamer
	assert_int(m.choice_picks).is_equal(1)
	assert_int(bench.step()).is_equal(0)                              # who did not fight stays


func test_the_last_depth_is_the_trial() -> void:
	var g := H.game()
	g.void_depth = VoidPlace.depths(g) - 1
	assert_bool(VoidPlace.is_trial(g)).is_true()
	H.void_fight(g, true)
	assert_int(int(g.stage)).is_equal(1)
	assert_int(g.void_depth).is_equal(0)
	assert_int(g.lifespan).is_equal(g.values.lifespan_years[1])      # a whole new lifespan: the trial costs no year of it
	assert_int(g.eggs.size()).is_equal(1)                              # the trophy of the trial: an egg of the void
	assert_int(int(GameData.monster(StringName(g.eggs[0]["species"])).kin)).is_equal(int(MonsterDef.Kin.VOID))


func test_at_the_end_of_the_lifespan_the_trial_is_forced_and_losing_it_loses_the_game() -> void:
	var g := H.game()
	g.spend(g.lifespan)
	assert_bool(VoidPlace.is_trial(g)).is_true()
	assert_str(VoidPlace.problem(g)).is_equal("")
	H.void_fight(g, false)
	assert_that(g.outcome).is_equal(GameState.LOST)


func test_a_forced_trial_that_is_won_is_a_breakthrough() -> void:
	var g := H.game()
	g.spend(g.lifespan)
	H.void_fight(g, true)
	assert_int(int(g.stage)).is_equal(1)
	assert_bool(g.forced_trial).is_false()
	assert_bool(g.is_over()).is_false()


func test_the_sovereign_beast_waits_from_the_first_day_and_defeating_it_wins() -> void:
	var g := H.game()
	var beast := VoidPlace.sovereign(g)
	assert_str(beast.enemy_text()).is_equal(VoidPlace.sovereign(g).enemy_text())
	for m in beast.enemies:
		assert_int(m.step()).is_equal(14)
		assert_int(m.points_spent() + m.unspent).is_equal(MonsterInstance.START_POINTS + MonsterInstance.STEP_POINTS * 14 + g.values.sovereign_bonus_points)
	assert_bool(VoidPlace.pay_sovereign(g)).is_true()
	beast.team = g.default_team(beast.max_team)
	var days := g.lifespan
	Places.resolve(g, beast, H.result(beast, false))
	assert_bool(g.is_over()).is_false()                                # an early defeat costs the year and nothing else
	assert_int(g.lifespan).is_equal(days - 1)
	var again := VoidPlace.sovereign(g)
	again.team = g.default_team(again.max_team)
	Places.resolve(g, again, H.result(again, true))
	assert_that(g.outcome).is_equal(GameState.WON)
	assert_int(int(g.stage)).is_equal(0)                               # won at whatever stage: nobody becomes Sovereign


func test_the_trial_of_the_last_stage_is_the_sovereign_beast() -> void:
	var g := H.game()
	for i in 4:
		g.break_through()
	g.void_depth = VoidPlace.depths(g) - 1
	assert_bool(VoidPlace.trial_is_sovereign(g)).is_true()
	assert_str(VoidPlace.fight(g).title).is_equal("The Sovereign beast")


func test_a_node_of_the_formation_gives_a_tamer_skill() -> void:
	var g := H.game(H.FORMATION)
	assert_str(Cultivation.problem(g, &"thorn_field")).contains("Insight")
	g.path_points = 1
	assert_bool(Cultivation.buy(g, &"thorn_field")).is_true()
	assert_bool(g.tamer_skills.has(&"thorn_field")).is_true()
	assert_int(g.path_points).is_equal(0)
	assert_str(Cultivation.problem(g, &"thorn_field")).is_equal("bought")
	g.path_points = 9
	assert_str(Cultivation.problem(g, &"ember_line")).contains("opens at")      # the tree of the next stage


func test_a_node_of_the_artificer_and_of_the_alchemist_is_a_perk() -> void:
	var smith := H.game(H.ARTIFICER)
	smith.path_points = 2
	var carry := smith.carry()
	assert_bool(Cultivation.buy(smith, &"carry_0")).is_true()
	assert_int(smith.carry()).is_equal(carry + 1)
	assert_bool(Cultivation.buy(smith, &"domain_0")).is_true()
	assert_int(smith.node_sum("bg_budget")).is_equal(3)
	assert_array(smith.tamer_skills).is_empty()
	var brewer := H.game(H.ALCHEMIST)
	brewer.path_points = 3
	assert_bool(Cultivation.buy(brewer, &"rich_brew_0")).is_true()
	assert_int(brewer.node_sum("drop")).is_equal(1)                    # a wild battle drops one pill more
	var cap := Crafting.pill_cap(brewer)
	assert_bool(Cultivation.buy(brewer, &"keen_nose_0")).is_true()
	assert_int(Crafting.pill_cap(brewer)).is_equal(cap + 2)


func test_every_way_has_two_branches_and_nodes_the_build_reads() -> void:
	var content := BattleContent.shared()
	var perks := ["carry", "bg_budget", "drop", "tamer_slots", "pill_cap"]
	for sid in CultivationDef.ids():
		var def := CultivationDef.of(sid)
		assert_int(def.branches.size()).is_equal(2)
		for n: Dictionary in def.nodes:
			assert_bool(int(n["stage"]) <= int(Stage.Type.IMMORTAL)).is_true()
			if n["kind"] == "tamer":
				assert_that(sid).is_equal(H.FORMATION)                 # tamer skills belong to the Formation alone
				assert_object(content.tamer_skill(n["ref"])).is_not_null()
			elif n["kind"] == "seal":
				assert_that(sid).is_equal(H.FORMATION)                 # the options of Seal too
				assert_bool(TamerSkillDef.SEAL_OPTIONS.has(String(n["ref"]))).is_true()
			else:
				for key: String in n["effects"]:
					assert_bool(perks.has(key)).is_true()
