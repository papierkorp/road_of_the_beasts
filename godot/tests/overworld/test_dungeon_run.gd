extends GdUnitTestSuite
## The dungeon (docs/vision.md §4): the run, leaving, a defeat, the last battle, the challenge and the harvest.


func _game(seed_value := 41) -> GameState:
	return GameState.new_game(seed_value, &"way_of_the_formation", &"blaze_tiger")


func _result(f: Fight, won: bool, rounds := 4, hp := -1) -> BattleResult:
	var r := BattleResult.new()
	r.over = true
	r.winner_side = 0 if won else 1
	r.rounds = rounds
	for i in f.team.size():
		r.player.append({"index": i, "hp_left": (f.team[i].max_hp() if hp < 0 else hp) if won else 0, "alive": won})
	for i in f.enemies.size():
		r.enemy.append({"index": i, "hp_left": 0, "alive": false, "caught": false, "died": won})
	return r


## Wins battles (and takes rests) until the run is over or `battles` are won.
func _advance(g: GameState, battles := 99, rounds := 4) -> void:
	while DungeonRun.running(g) and battles > 0:
		var id := DungeonRun.choices(g)[0]
		if DungeonRun.nodes(g)[id]["kind"] == DungeonRun.REST:
			DungeonRun.rest(g, id)
			continue
		var f := DungeonRun.fight_for(g, id)
		f.team = g.default_team(f.max_team)
		Places.resolve(g, f, _result(f, true, rounds))
		battles -= 1


func test_a_run_costs_all_day_ap_of_a_full_day() -> void:
	var g := _game()
	g.spend_ap(1)
	assert_bool(DungeonRun.start(g, 0)).is_false()
	g.end_day()
	assert_bool(DungeonRun.start(g, 0)).is_true()
	assert_int(g.ap).is_equal(0)
	assert_bool(g.can_end_day()).is_false()
	assert_bool(DungeonRun.start(g, 0)).is_false()


func test_the_map_has_forks_and_every_node_can_be_reached() -> void:
	for seed_value in [1, 2, 3, 4, 5]:
		var g := _game(seed_value)
		DungeonRun.start(g, 0)
		var all := DungeonRun.nodes(g)
		var total := 0
		for n in g.values.dungeon_layers:
			total += n
		assert_int(all.size()).is_equal(total)
		var reached := {}
		for n in all:
			if int(n["layer"]) == 0:
				reached[int(n["id"])] = true
			for t in n["next"]:
				reached[int(t)] = true
		assert_int(reached.size()).is_equal(total)
		assert_str(String(all[-1]["kind"])).is_equal(String(DungeonRun.LAST))
		assert_int(int(all[-1]["loot"][Materials.breakthrough(0)])).is_equal(1)
		assert_str(DungeonRun.nodes(g)[0]["enemies"][0].title()).is_equal(all[0]["enemies"][0].title())


func test_hp_stay_from_battle_to_battle_and_a_rest_heals() -> void:
	var g := _game()
	DungeonRun.start(g, 0)
	var f := DungeonRun.fight_for(g, DungeonRun.choices(g)[0])
	f.team = g.default_team(f.max_team)
	Places.resolve(g, f, _result(f, true, 4, 1))
	assert_int(g.roster[0].current_hp).is_equal(1)
	var rest := -1
	while rest < 0 and DungeonRun.running(g):
		for id in DungeonRun.choices(g):
			if DungeonRun.nodes(g)[id]["kind"] == DungeonRun.REST:
				rest = id
		if rest < 0:
			var f2 := DungeonRun.fight_for(g, DungeonRun.choices(g)[0])
			f2.team = g.default_team(f2.max_team)
			Places.resolve(g, f2, _result(f2, true, 4, 1))
	if rest >= 0:
		assert_bool(DungeonRun.rest(g, rest)).is_true()
		assert_int(g.roster[0].current_hp).is_equal(mini(g.roster[0].max_hp(), 1 + g.values.rest_heal))


func test_leaving_keeps_the_loot_and_a_defeat_keeps_a_part() -> void:
	var g := _game()
	DungeonRun.start(g, 0)
	_advance(g, 1)
	var gathered := 0
	for id in g.dungeon["loot"]:
		gathered += int(g.dungeon["loot"][id])
	assert_int(gathered).is_equal(g.values.dungeon_node_loot)
	DungeonRun.leave(g)
	assert_bool(DungeonRun.running(g)).is_false()
	var owned := 0
	for id in g.items:
		owned += g.count(id)
	assert_int(owned).is_equal(gathered)
	assert_int(g.roster[0].current_hp).is_equal(g.roster[0].max_hp())

	var h := _game()
	DungeonRun.start(h, 0)
	h.dungeon["loot"] = {Materials.ore(0): 4, Materials.essence(0): 1}
	var f := DungeonRun.fight_for(h, DungeonRun.choices(h)[0])
	f.team = h.default_team(f.max_team)
	Places.resolve(h, f, _result(f, false))
	assert_bool(DungeonRun.running(h)).is_false()
	assert_int(h.count(Materials.ore(0))).is_equal(4 * h.values.dungeon_defeat_keeps / 100)
	assert_int(h.count(Materials.essence(0))).is_equal(0)
	assert_str(String(h.outcome)).is_equal("")
	assert_int(h.roster[0].current_hp).is_equal(h.roster[0].max_hp())


func test_the_last_battle_gives_the_breakthrough_material_and_meets_the_challenge() -> void:
	var g := _game()
	assert_bool(DungeonRun.mastered(g, 0)).is_false()
	assert_bool(DungeonRun.can_harvest(g, 0)).is_false()
	DungeonRun.start(g, 0)
	_advance(g)
	assert_bool(DungeonRun.running(g)).is_false()
	assert_int(g.count(Materials.breakthrough(0))).is_equal(1)
	assert_bool(DungeonRun.mastered(g, 0)).is_true()         # the test value of the first dungeon: one run won


func test_a_rounds_challenge_is_met_only_by_a_fast_last_battle() -> void:
	var g := _game()
	g.stage = Stage.Type.FOUNDATION
	g.ap = g.max_ap()
	var c := DungeonRun.challenge(g, 1)
	assert_str(c["kind"]).is_equal("rounds")
	DungeonRun.start(g, 1)
	_advance(g, 99, int(c["n"]) + 1)
	assert_bool(DungeonRun.mastered(g, 1)).is_false()
	g.end_day()
	DungeonRun.start(g, 1)
	_advance(g, 99, int(c["n"]))
	assert_bool(DungeonRun.mastered(g, 1)).is_true()


func test_a_harvest_gives_materials_without_a_battle_but_no_breakthrough_material_and_no_xp() -> void:
	var g := _game()
	g.dungeon_mastered.append(0)
	var xp := g.roster[0].xp
	var loot := DungeonRun.harvest(g, 0)
	var n := 0
	for id in loot:
		n += int(loot[id])
		assert_bool(Materials.form(id) in ["plant", "ore"]).is_true()
	assert_int(n).is_equal(g.values.harvest_yield)
	assert_int(g.ap).is_equal(0)
	assert_int(g.roster[0].xp).is_equal(xp)
	assert_int(g.count(Materials.breakthrough(0))).is_equal(0)
	assert_bool(DungeonRun.harvest(g, 0).is_empty()).is_true()


func test_a_running_dungeon_survives_a_save() -> void:
	var g := _game()
	DungeonRun.start(g, 0)
	_advance(g, 1)
	var h := GameState.from_dict(JSON.parse_string(JSON.stringify(g.to_dict())))
	assert_bool(DungeonRun.running(h)).is_true()
	assert_array(DungeonRun.choices(h)).is_equal(DungeonRun.choices(g))
	assert_str(DungeonRun.nodes(h)[-1]["enemies"][0].title()).is_equal(DungeonRun.nodes(g)[-1]["enemies"][0].title())
