extends GdUnitTestSuite
## Vows (docs/overworld.md §5.3): three offered at the start and after a breakthrough, one or none taken, at most
## `vow_cap` in a game; each gives something and takes something for the rest of the game.


func _game() -> GameState:
	return GameState.new_game(5, &"way_of_the_beast_lord", &"blaze_tiger")


func _swear(g: GameState, id: StringName) -> void:
	g.vow_offer = [id]
	assert_bool(g.take_vow(id)).is_true()


func test_three_vows_are_offered_at_the_start_and_after_a_breakthrough() -> void:
	var g := _game()
	assert_int(g.vow_offer.size()).is_equal(3)
	assert_bool(g.take_vow(&"not_offered")).is_false()
	var first := g.vow_offer[0]
	assert_bool(g.take_vow(first)).is_true()
	assert_array(g.vows).is_equal([first])
	assert_int(g.vow_offer.size()).is_equal(0)
	g.break_through()
	assert_int(g.vow_offer.size()).is_equal(3)
	assert_bool(g.vow_offer.has(first)).is_false()
	assert_bool(g.take_vow(&"")).is_true()                 # none
	assert_int(g.vows.size()).is_equal(1)
	var copy := GameState.from_dict(JSON.parse_string(JSON.stringify(g.to_dict())))
	assert_array(copy.vows).is_equal(g.vows)


func test_a_game_holds_at_most_three_vows() -> void:
	var g := _game()
	for id: StringName in [&"short_life", &"bare_hand", &"ascetic"]:
		_swear(g, id)
	g.break_through()
	assert_int(g.vow_offer.size()).is_equal(0)


func test_every_vow_of_the_values_names_effects_the_build_reads() -> void:
	var known := ["kin_choice", "gift_all", "slot_all", "tamer_slots", "dungeon_heal", "wild_egg", "ap", "bg_budget", "vein_weight",
		"void_eggs", "ban_kin", "one_kin_team", "team", "no_weapons", "no_pills", "no_seal", "lifespan", "no_zones", "no_props", "no_wild_eggs"]
	assert_int(GameValues.shared().vows.size()).is_equal(16)
	for v: Dictionary in GameValues.shared().vows:
		assert_int((v["effects"] as Dictionary).size()).is_equal(2)
		for key: String in v["effects"]:
			assert_bool(known.has(key)).is_true()


func test_a_vow_of_a_kin_gives_a_choice_more_and_bans_another_kin() -> void:
	var g := _game()
	_swear(g, &"vow_beast")
	g.stage = Stage.Type.FOUNDATION
	var tiger := g.roster[0]
	tiger.xp = 0
	for i in 3:
		tiger.sub_tier = Stage.SubTier.HIGH
	tiger.xp = MonsterInstance.XP_STEPS[2]
	g.values = g.values.duplicate()
	g.award_xp([tiger] as Array[MonsterInstance], 0)
	assert_int(int(tiger.stage)).is_equal(1)
	assert_int(tiger.choice_picks).is_equal(2)
	assert_bool(tiger.choose(MonsterInstance.BREADTH)).is_true()
	assert_bool(tiger.choose(MonsterInstance.BREADTH)).is_false()      # two different ones
	assert_bool(tiger.choose(MonsterInstance.DEPTH)).is_true()
	var rng := RandomNumberGenerator.new()
	assert_bool(g.add_monster(MonsterInstance.grown(GameData.monster(&"thorn_mites"), rng))).is_false()      # Swarm is banned
	assert_bool(g.add_egg(&"thorn_mites")).is_false()
	assert_bool(g.add_monster(MonsterInstance.grown(GameData.monster(&"moss_turtle"), rng))).is_true()


func test_one_blood_gives_every_owned_monster_a_gift_and_binds_the_team_to_one_kin() -> void:
	var g := _game()
	var rng := RandomNumberGenerator.new()
	g.add_monster(MonsterInstance.grown(GameData.monster(&"moss_turtle"), rng))
	g.add_monster(MonsterInstance.grown(GameData.monster(&"gloom_wolf"), rng))
	_swear(g, &"one_blood")
	for m in g.roster:
		assert_int(m.gift_picks).is_equal(1)
	assert_bool(g.roster[0].take_gift(&"brawler")).is_true()
	assert_bool(g.roster[0].take_gift(&"surefoot")).is_false()
	assert_str(g.team_problem([g.roster[0], g.roster[1]] as Array[MonsterInstance])).is_not_empty()
	assert_str(g.team_problem([g.roster[0], g.roster[2]] as Array[MonsterInstance])).is_empty()
	var team := g.default_team(3)
	assert_int(team.size()).is_equal(2)                    # tiger and wolf: both Beast
	g.add_monster(MonsterInstance.grown(GameData.monster(&"dusk_moth"), rng))
	assert_int(g.roster[3].gift_picks).is_equal(0)         # only those owned when the vow was sworn


func test_the_other_vows_change_what_they_name() -> void:
	var g := _game()
	var ap := g.max_ap()
	var life := g.lifespan
	_swear(g, &"short_life")
	assert_int(g.max_ap()).is_equal(ap + 1)
	assert_int(g.lifespan).is_equal(life - 2)
	var slots := g.tamer_slots()
	_swear(g, &"bare_hand")
	assert_int(g.tamer_slots()).is_equal(slots + 1)
	g.add_item(Materials.ore(0), 2)
	g.add_item(Materials.beast_part(0), 2)
	assert_bool(Crafting.can_forge(g, Crafting.WEAPON, Materials.ore(0), Materials.beast_part(0))).is_false()
	assert_bool(Crafting.can_forge(g, Crafting.ARMOUR, Materials.ore(0), Materials.beast_part(0))).is_true()
	var h := _game()
	_swear(h, &"loner")
	assert_int(h.roster[0].slots).is_equal(5)
	assert_int(h.team_cap(3)).is_equal(2)
	assert_int(h.team_cap(1)).is_equal(1)
	h.add_egg(&"moss_turtle")
	for i in h.values.egg_nights:
		h.end_day()
	assert_int(h.roster[1].slots).is_equal(5)
	_swear(h, &"no_seal")
	assert_bool(h.tamer_skills.has(GameState.SEAL)).is_false()
	_swear(h, &"ascetic")
	h.add_item("pill:change:0", 1)
	assert_str(Crafting.use_problem(h, "pill:change:0", h.roster[0], false)).contains("vow")
