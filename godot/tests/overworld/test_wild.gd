extends GdUnitTestSuite
## The wild (docs/vision.md §4): a look shows a few battles with their boards, monsters and drops; a battle costs a
## year; a battle won drops the reward of the Way and leaves rises; a new look costs a year.

const H := preload("res://tests/overworld/helpers.gd")


func _grown(species: StringName, step: int) -> MonsterInstance:
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	return MonsterInstance.grown(GameData.monster(species), rng, step)


## A wild fight against monsters at the given steps, fought by `team` and read back as won.
func _win(g: GameState, team: Array[MonsterInstance], steps: Array) -> void:
	var f := Wild.fight_for(g, int(Wild.open(g)[0]["id"]))
	f.enemies.clear()
	for s: int in steps:
		f.enemies.append(_grown(&"moss_turtle", s))
	f.ref["drop"] = {}
	f.ref["egg"] = ""
	f.team = team
	Places.resolve(g, f, H.result(f, true))


func test_a_look_shows_battles_and_the_first_is_one_a_fresh_monster_can_win() -> void:
	for game_seed in 8:
		var g := H.game(H.FORMATION, game_seed + 1)
		var offers := Wild.offers(g)
		assert_int(offers.size()).is_equal(g.values.wild_offer)
		assert_int((offers[0]["enemies"] as Array).size()).is_equal(1)
		assert_int((offers[0]["enemies"][0] as MonsterInstance).step()).is_equal(0)
		for o in offers:
			var foes: Array = o["enemies"]
			assert_bool(foes.size() >= 1 and foes.size() <= 2).is_true()      # Qi Gathering: one or two
			for m: MonsterInstance in foes:
				assert_int(int(m.stage)).is_equal(0)
				assert_int(int(m.species().kin)).is_not_equal(int(MonsterDef.Kin.VOID))
			var map := MapData.from_dict(o["map"])
			assert_bool(map.start_a.size() >= g.values.team_room).is_true()
			assert_bool(map.start_b.size() >= foes.size()).is_true()
		assert_str(JSON.stringify(Wild.offers(g)[1]["map"])).is_equal(JSON.stringify(offers[1]["map"]))      # the same look again


func test_a_battle_won_leaves_the_look_and_a_new_look_costs_a_year() -> void:
	var g := H.game()
	var years := g.lifespan
	var first := JSON.stringify(Wild.offers(g)[1]["map"])
	H.wild_fight(g, 0, true)
	assert_bool(g.wild_gone.has(0)).is_true()
	assert_int(Wild.open(g).size()).is_equal(g.values.wild_offer - 1)
	assert_object(Wild.fight_for(g, 0)).is_null()
	H.wild_fight(g, 1, false)
	assert_bool(g.wild_gone.has(1)).is_false()                         # a battle lost waits
	assert_bool(Wild.reroll(g)).is_true()
	assert_int(g.lifespan).is_equal(years - 3)
	assert_array(g.wild_gone).is_empty()
	assert_str(JSON.stringify(Wild.offers(g)[1]["map"])).is_not_equal(first)
	for i in g.values.wild_offer:                                      # every battle of a look won: a new look, for nothing
		H.wild_fight(g, i, true)
	assert_array(g.wild_gone).is_empty()
	assert_int(g.lifespan).is_equal(years - 3 - g.values.wild_offer)


func test_the_drop_follows_the_way() -> void:
	var smith := H.game(H.ARTIFICER)
	var parts := 0
	for o in Wild.offers(smith):
		for id: String in o["drop"]:
			assert_bool(id.get_slice(":", 0) in ["ground", "prop", "zone"]).is_true()
			assert_int(int(o["drop"][id])).is_equal((o["enemies"] as Array).size())      # one unit per monster
			parts += 1
	assert_bool(parts > 0).is_true()
	var owned := smith.parts.duplicate()
	H.wild_fight(smith, 0, true)
	assert_bool(JSON.stringify(smith.parts) != JSON.stringify(owned)).is_true()
	assert_dict(smith.items).is_empty()

	var brewer := H.game(H.ALCHEMIST)
	for o in Wild.offers(brewer):
		var pills := 0
		for id: String in o["drop"]:
			assert_str(Materials.form(id)).is_equal("pill")
			assert_bool(not Crafting.property(brewer.values, Materials.property_of(id)).is_empty()).is_true()
			pills += int(o["drop"][id])
		assert_int(pills).is_equal((o["enemies"] as Array).size())
	assert_dict(brewer.parts).is_empty()

	var tamer := H.game(H.FORMATION)
	for o in Wild.offers(tamer):
		var foes := (o["enemies"] as Array).size()
		assert_int(int((o["drop"] as Dictionary).get(Wild.INSIGHT, 0))).is_equal(1 if foes >= tamer.values.wild_insight_from else 0)
	assert_dict(tamer.items).is_empty()


func test_every_monster_defeated_lifts_one_monster_at_its_step_or_below() -> void:
	var g := H.game()
	var a := g.roster[0]
	var b := _grown(&"moss_turtle", 0)
	g.roster.append(b)
	var team: Array[MonsterInstance] = [a, b]
	_win(g, team, [0, 0])
	assert_int(a.step()).is_equal(1)                                   # two at their step: both rise, nobody chooses
	assert_int(b.step()).is_equal(1)
	assert_array(g.rises).is_empty()
	_win(g, team, [0, 0])
	assert_int(a.step()).is_equal(1)                                   # monsters below them lift nobody
	assert_array(Wild.can_rise(g)).is_empty()
	_win(g, team, [2])
	assert_int(a.step() + b.step()).is_equal(2)                        # one rise for two: the player chooses
	assert_int(Wild.can_rise(g).size()).is_equal(2)
	assert_bool(Wild.give(g, b)).is_true()
	assert_int(b.step()).is_equal(2)
	assert_bool(Wild.give(g, a)).is_false()
	assert_array(g.rises).is_empty()
	_win(g, team, [0, 1])
	assert_int(a.step()).is_equal(2)                                   # the one at Middle takes the rise that reaches it
	assert_int(b.step()).is_equal(2)                                   # High: no wild battle lifts it further
	assert_bool(b.may_rise).is_false()


func test_a_rise_not_given_is_lost_with_the_next_battle_and_the_bench_never_rises() -> void:
	var g := H.game()
	var a := g.roster[0]
	var b := _grown(&"moss_turtle", 0)
	var bench := _grown(&"moss_turtle", 0)
	g.roster.append(b)
	g.roster.append(bench)
	var team: Array[MonsterInstance] = [a, b]
	_win(g, team, [1])
	assert_int(Wild.can_rise(g).size()).is_equal(2)
	assert_bool(Wild.give(g, bench)).is_false()
	H.wild_fight(g, 0, false)
	assert_array(g.rises).is_empty()
	assert_int(a.step() + b.step() + bench.step()).is_equal(0)


func test_wild_monsters_are_caught_and_every_battle_starts_at_full_hp() -> void:
	var g := H.game()
	var f := Wild.fight_for(g, 0)
	f.team = g.default_team(f.max_team)
	Places.resolve(g, f, H.result(f, true, 1, [0]))
	assert_int(g.roster.size()).is_equal(2)
	for m in g.roster:
		assert_int(m.current_hp).is_equal(m.max_hp())


func test_a_wild_battle_may_hold_an_egg() -> void:
	var found := false
	for game_seed in 40:
		var g := H.game(H.FORMATION, game_seed + 1)
		for o in Wild.offers(g):
			if String(o["egg"]) == "":
				continue
			found = true
			H.wild_fight(g, int(o["id"]), true)
			assert_int(g.eggs.size()).is_equal(1)
			break
		if found:
			break
	assert_bool(found).is_true()
