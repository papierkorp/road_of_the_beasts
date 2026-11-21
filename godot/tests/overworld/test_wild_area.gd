extends GdUnitTestSuite
## The wild area (docs/vision.md §4): today's encounters, the night, the rare encounter, what a battle gives.


func _game() -> GameState:
	return GameState.new_game(21, &"way_of_the_formation", &"blaze_tiger")


func _result(f: Fight, won: bool, caught: Array[int] = []) -> BattleResult:
	var r := BattleResult.new()
	r.over = true
	r.winner_side = 0 if won else 1
	for i in f.team.size():
		r.player.append({"index": i, "hp_left": f.team[i].max_hp() if won else 0, "alive": won})
	for i in f.enemies.size():
		r.enemy.append({"index": i, "hp_left": 0, "alive": false, "caught": caught.has(i), "died": won and not caught.has(i)})
	return r


func test_the_list_of_a_day_is_the_same_until_the_night_draws_it_anew() -> void:
	var g := _game()
	var a := WildArea.encounters(g, 0)
	var b := WildArea.encounters(g, 0)
	assert_int(a.size()).is_equal(g.values.wild_encounters)
	for i in a.size():
		assert_str(a[i].fight.enemy_text()).is_equal(b[i].fight.enemy_text())
		assert_str(String(a[i].fight.map_id)).is_equal(String(b[i].fight.map_id))
	g.end_day()
	var c := WildArea.encounters(g, 0)
	var same := 0
	for i in a.size():
		if a[i].fight.enemy_text() == c[i].fight.enemy_text() and a[i].fight.map_id == c[i].fight.map_id:
			same += 1
	assert_bool(same < a.size()).is_true()


func test_an_encounter_never_fields_more_monsters_than_its_battleground_holds() -> void:
	var g := _game()
	g.stage = Stage.Type.FOUNDATION
	for zone in WildArea.zones(g):
		for e in WildArea.encounters(g, zone):
			var room := 0
			for b: Dictionary in g.values.battlegrounds:
				if b["id"] == e.fight.map_id:
					room = int(b["theirs"])
			assert_bool(e.fight.enemies.size() >= 1 and e.fight.enemies.size() <= room).is_true()


func test_a_battle_costs_day_ap_and_a_win_gives_xp_parts_and_removes_the_encounter() -> void:
	var g := _game()
	var f := WildArea.encounters(g, 0)[1].fight
	f.team = g.default_team(f.max_team)
	assert_bool(WildArea.pay(g)).is_true()
	assert_int(g.ap).is_equal(g.max_ap() - g.values.wild_ap)
	Places.resolve(g, f, _result(f, true))
	assert_bool(WildArea.encounters(g, 0)[1].gone).is_true()
	assert_int(g.roster[0].xp + (1000 if g.roster[0].step() > 0 else 0)).is_greater(0)
	var parts := 0
	for id in g.items:
		if Materials.form(id) == "part":
			parts += g.count(id)
	assert_int(parts).is_equal(f.enemies.size())
	assert_int(g.roster[0].current_hp).is_equal(g.roster[0].max_hp())


func test_a_lost_battle_costs_only_the_day_ap() -> void:
	var g := _game()
	var f := WildArea.encounters(g, 0)[0].fight
	f.team = g.default_team(f.max_team)
	WildArea.pay(g)
	Places.resolve(g, f, _result(f, false))
	assert_bool(WildArea.encounters(g, 0)[0].gone).is_false()
	assert_bool(g.items.is_empty()).is_true()
	assert_int(g.roster[0].current_hp).is_equal(g.roster[0].max_hp())
	Places.resolve(g, f, null)                  # leaving the battle counts as a defeat
	assert_bool(WildArea.encounters(g, 0)[0].gone).is_false()


func test_a_caught_monster_joins_the_roster() -> void:
	var g := _game()
	var f := WildArea.encounters(g, 0)[0].fight
	f.team = g.default_team(f.max_team)
	Places.resolve(g, f, _result(f, true, [0]))
	assert_int(g.roster.size()).is_equal(2)
	assert_str(String(g.roster[1].species_id)).is_equal(String(f.enemies[0].species_id))
	assert_bool(WildArea.encounters(g, 0)[0].gone).is_true()


func test_a_rare_encounter_is_announced_stays_and_leaves() -> void:
	var g := _game()
	var v := g.values
	g.day = v.rare_every - v.rare_announce - 1
	assert_object(WildArea.rare_entry(g, 0)).is_null()
	g.day = v.rare_every - v.rare_announce
	var e := WildArea.rare_entry(g, 0)
	assert_int(e.appears_in).is_equal(v.rare_announce)
	g.day = v.rare_every
	e = WildArea.rare_entry(g, 0)
	assert_int(e.appears_in).is_equal(0)
	assert_int(e.stays).is_equal(v.rare_stays)
	assert_int(int(e.fight.enemies[0].rarity)).is_equal(int(MonsterInstance.Rarity.RARE))
	e.fight.team = g.default_team(1)
	Places.resolve(g, e.fight, _result(e.fight, true))
	assert_bool(WildArea.rare_entry(g, 0).gone).is_true()
	assert_int(g.eggs.size()).is_equal(1)
	g.day = v.rare_every + v.rare_stays
	assert_object(WildArea.rare_entry(g, 0)).is_null()
