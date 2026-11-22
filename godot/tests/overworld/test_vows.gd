extends GdUnitTestSuite
## Vows (docs/overworld.md §5.3): three offered at the start and after a breakthrough, one or none taken, at most
## `vow_cap` in a game; each gives something and takes something for the rest of the game. A vow of one Way is
## offered in that Way alone.

const H := preload("res://tests/overworld/helpers.gd")


func _swear(g: GameState, id: StringName) -> void:
	g.vow_offer = [id]
	assert_bool(g.take_vow(id)).is_true()


func test_three_vows_are_offered_at_the_start_and_after_a_breakthrough() -> void:
	var g := H.game()
	assert_int(g.vow_offer.size()).is_equal(g.values.vow_offer)
	assert_bool(g.take_vow(&"")).is_true()
	assert_array(g.vow_offer).is_empty()
	g.break_through()
	assert_int(g.vow_offer.size()).is_equal(g.values.vow_offer)
	var id := g.vow_offer[0]
	assert_bool(g.take_vow(id)).is_true()
	assert_array(g.vows).is_equal([id])


func test_a_game_holds_at_most_three_vows() -> void:
	var g := H.game()
	for id: StringName in [&"loner", &"one_kin", &"no_seal"]:
		_swear(g, id)
	g.break_through()
	assert_array(g.vow_offer).is_empty()


func test_a_vow_of_a_way_is_offered_in_that_way_alone() -> void:
	var by_way := {}
	for v: Dictionary in GameValues.shared().vows:
		by_way[StringName(v["id"])] = String(v.get("way", ""))
	for way: StringName in [H.ARTIFICER, H.FORMATION, H.ALCHEMIST]:
		for seed_value in 25:
			for id in H.game(way, seed_value).vow_offer:
				assert_bool(by_way[id] == "" or by_way[id] == String(way)).is_true()
	assert_str(by_way[&"still_ground"]).is_equal(String(H.ARTIFICER))
	assert_str(by_way[&"open_hand"]).is_equal(String(H.FORMATION))


func test_every_vow_of_the_values_names_effects_the_build_reads() -> void:
	var known := ["kin_choice", "slot_all", "tamer_slots", "drop", "egg_chance", "bg_budget", "vein_weight", "void_eggs", "ban_kin",
		"one_kin_team", "team", "no_seal", "lifespan", "no_wild_eggs", "no_zones", "no_props"]
	for v: Dictionary in GameValues.shared().vows:
		assert_str(String(v["gain"])).is_not_empty()
		assert_str(String(v["price"])).is_not_empty()
		for key: String in v["effects"]:
			assert_bool(known.has(key)).is_true()
		for old: String in ["weapon", "gift", "AP", "dungeon", "XP", "brew"]:
			assert_bool((String(v["gain"]) + String(v["price"])).contains(old)).is_false()


func test_a_vow_of_a_kin_gives_two_choices_and_bans_another_kin() -> void:
	var g := H.game()
	_swear(g, &"vow_beast")
	g.break_through()
	var m := g.roster[0]
	while int(m.stage) < 1:
		g.lift(m)
	assert_int(m.choice_picks).is_equal(2)                             # two of the choices
	assert_bool(m.choose(MonsterInstance.BREADTH)).is_true()
	assert_bool(m.choose(MonsterInstance.BREADTH)).is_false()          # two different ones
	assert_bool(m.choose(MonsterInstance.DEPTH)).is_true()
	var rng := RandomNumberGenerator.new()
	assert_bool(g.add_monster(MonsterInstance.grown(GameData.monster(&"thorn_mites"), rng, 0))).is_false()      # a Swarm monster
	assert_bool(g.add_monster(MonsterInstance.grown(GameData.monster(&"moss_turtle"), rng, 0))).is_true()


func test_the_other_vows_change_what_they_name() -> void:
	var g := H.game()
	var rng := RandomNumberGenerator.new()
	g.add_monster(MonsterInstance.grown(GameData.monster(&"moss_turtle"), rng, 0))
	_swear(g, &"one_kin")
	assert_str(g.team_problem(g.roster)).contains("one Kin")
	var more := Wild.offers(g)
	var plain := Wild.offers(H.game())
	for i in more.size():                                               # one more of the reward of the Way
		if (plain[i]["drop"] as Dictionary).has(Wild.INSIGHT):
			assert_int(int(more[i]["drop"][Wild.INSIGHT])).is_equal(int(plain[i]["drop"][Wild.INSIGHT]) + 1)

	var loner := H.game()
	_swear(loner, &"loner")
	assert_int(loner.roster[0].slots).is_equal(5)
	assert_int(loner.team_cap(3)).is_equal(2)

	var sealless := H.game()
	_swear(sealless, &"no_seal")
	assert_bool(sealless.tamer_skills.has(GameState.SEAL)).is_false()
	assert_bool(sealless.can_catch()).is_false()
	assert_int(sealless.vow_sum("egg_chance")).is_equal(35)            # wild battles hold an egg far more often

	var hand := H.game(H.FORMATION)
	var slots := hand.tamer_slots()
	_swear(hand, &"open_hand")
	assert_int(hand.tamer_slots()).is_equal(slots + 1)

	var still := H.game(H.ARTIFICER)
	_swear(still, &"still_ground")
	assert_bool(Crafting.part_banned(still, "zone:gale")).is_true()
	assert_bool(Crafting.part_banned(still, "prop:earth_wall")).is_false()
