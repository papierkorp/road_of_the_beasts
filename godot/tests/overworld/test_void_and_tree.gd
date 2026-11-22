extends GdUnitTestSuite
## The void, the breakthrough trial, the Sovereign beast and the tree of the Way (docs/vision.md §3, §4, §8).


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


func test_the_void_monsters_of_a_depth_are_drawn_per_game() -> void:
	var seen := {}
	for seed_value in [51, 52, 53, 54, 55, 56]:
		var g := GameState.new_game(seed_value, &"way_of_the_formation", &"blaze_tiger")
		var f := VoidPlace.fight(g)
		assert_str(f.enemy_text()).is_equal(VoidPlace.fight(g).enemy_text())      # the same within a game
		seen[f.enemies[0].species_id] = true
	assert_int(seen.size()).is_greater(1)


func test_a_depth_won_gives_one_insight_and_opens_the_next_one() -> void:
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


func test_the_last_depth_is_the_trial_and_asks_for_no_material() -> void:
	var g := _game()
	g.void_depth = g.values.void_depths - 1
	assert_bool(VoidPlace.is_trial(g)).is_true()
	assert_str(VoidPlace.problem(g)).is_empty()
	_fight(g, true)
	assert_int(int(g.stage)).is_equal(int(Stage.Type.FOUNDATION))
	assert_int(g.void_depth).is_equal(0)
	assert_int(g.path_points).is_equal(1)


func test_at_the_end_of_the_lifespan_the_trial_is_forced_and_losing_it_loses_the_game() -> void:
	var g := _game()
	g.lifespan = 1
	g.end_day()
	assert_bool(g.forced_trial).is_true()
	assert_bool(VoidPlace.is_trial(g)).is_true()
	assert_str(VoidPlace.problem(g)).is_empty()           # ready or not: no day AP asked
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


func test_the_sovereign_beast_waits_from_the_first_day_and_may_be_attacked_early() -> void:
	var g := _game()
	var beast := VoidPlace.sovereign(g)
	assert_int(beast.enemies.size()).is_equal(g.values.sovereign_enemies)
	for e in beast.enemies:
		assert_int(int(e.species().kin)).is_equal(int(MonsterDef.Kin.VOID))
		assert_int(e.step()).is_equal(g.values.sovereign_step)
		assert_int(int(e.bloodline)).is_equal(int(MonsterInstance.Bloodline.DIVINE))
	g.end_day()
	g.end_day()
	assert_str(VoidPlace.sovereign(g).enemy_text()).is_equal(beast.enemy_text())      # the same beast for the whole game
	assert_bool(VoidPlace.trial_is_sovereign(g)).is_false()
	var f := VoidPlace.sovereign(g)
	f.team = g.default_team(f.max_team)
	assert_bool(VoidPlace.pay_sovereign(g)).is_true()
	assert_int(g.ap).is_equal(g.max_ap() - g.values.void_ap)
	Places.resolve(g, f, _result(f, false))
	assert_str(String(g.outcome)).is_equal("")            # an early defeat costs the day AP and nothing else
	assert_int(g.void_depth).is_equal(0)
	var again := VoidPlace.sovereign(g)
	again.team = g.default_team(again.max_team)
	assert_bool(VoidPlace.pay_sovereign(g)).is_true()
	Places.resolve(g, again, _result(again, true))
	assert_str(String(g.outcome)).is_equal(String(GameState.WON))
	assert_int(int(g.stage)).is_equal(int(Stage.Type.SOVEREIGN))


func test_the_trial_of_the_last_stage_is_the_sovereign_beast() -> void:
	var g := _game()
	g.stage = VoidPlace.LAST_STAGE
	g.ap = g.max_ap()
	assert_bool(VoidPlace.fight(g).ref.has("sovereign")).is_false()      # the depths before it are depths
	g.void_depth = g.values.void_depths - 1
	var f := VoidPlace.fight(g)
	assert_bool(f.ref.has("sovereign")).is_true()
	assert_str(f.enemy_text()).is_equal(VoidPlace.sovereign(g).enemy_text())
	g.lifespan = 1
	g.end_day()
	assert_bool(g.forced_trial).is_true()
	var forced := VoidPlace.fight(g)
	assert_bool(bool(forced.ref["forced"])).is_true()
	forced.team = g.default_team(forced.max_team)
	assert_bool(VoidPlace.pay(g)).is_true()
	Places.resolve(g, forced, _result(forced, false))
	assert_str(String(g.outcome)).is_equal(String(GameState.LOST))


func test_a_node_is_bought_with_insight_and_gives_its_tamer_skill() -> void:
	var g := _game()
	assert_str(Cultivation.problem(g, &"stone_wall")).is_not_empty()
	g.path_points = 2
	assert_bool(Cultivation.buy(g, &"stone_wall")).is_true()
	assert_array(g.tamer_skills).contains([&"stone_wall"])
	assert_int(g.path_points).is_equal(1)
	assert_bool(Cultivation.buy(g, &"stone_wall")).is_false()
	assert_str(Cultivation.problem(g, &"domain_glimpse")).contains("Foundation")       # the tree of the next stage
	g.stage = Stage.Type.FOUNDATION
	assert_bool(Cultivation.buy(g, &"domain_glimpse")).is_true()
	assert_array(g.tamer_skills).contains([&"domain_glimpse"])
	g.path_points = 5
	assert_str(Cultivation.problem(g, &"ember_line")).contains("Thorn Field")           # a node may need another
	Cultivation.buy(g, &"thorn_field")
	assert_bool(Cultivation.buy(g, &"ember_line")).is_true()


func test_every_way_has_two_branches_of_tamer_skills_the_battle_knows() -> void:
	var content := BattleContent.shared()
	for sid in CultivationDef.ids():
		var def := CultivationDef.of(sid)
		assert_int(def.branches.size()).is_equal(2)
		var ids := [String(def.branches[0]["id"]), String(def.branches[1]["id"])]
		for stage in 2:
			var cost := {ids[0]: 0, ids[1]: 0}
			for n: Dictionary in def.nodes_of(stage):
				assert_bool(ids.has(String(n["branch"]))).is_true()
				cost[String(n["branch"])] += int(n["cost"])
				assert_str(String(n["kind"])).is_equal("tamer")       # no perks, no blueprints
				assert_object(content.tamer_skill(StringName(n["ref"]))).is_not_null()
			for b: String in ids:                               # a stage gives 3 Insight: about one branch
				assert_bool(int(cost[b]) >= 1 and int(cost[b]) <= 4).is_true()
