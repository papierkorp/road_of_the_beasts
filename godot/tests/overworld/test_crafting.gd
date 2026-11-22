extends GdUnitTestSuite
## The goods of the Ways (docs/overworld.md §6): pills for the monsters and for the tamer slots of the Alchemist, the
## parts the Artificer lays. Nothing is made: both drop from the wild.

const H := preload("res://tests/overworld/helpers.gd")


func test_pills_belong_to_the_alchemist_alone() -> void:
	var tamer := H.game(H.FORMATION)
	tamer.add_item("pill:tempering")
	assert_str(Crafting.use_problem(tamer, "pill:tempering", tamer.roster[0])).contains("no pills")
	assert_dict(Crafting.battle_items(tamer)).is_empty()
	var brewer := H.game(H.ALCHEMIST)
	assert_bool(Crafting.battle_items(brewer).has(&"pill_binding")).is_true()      # it catches from the start


func test_pills_make_a_monster_rise_give_it_points_and_a_development_step() -> void:
	var g := H.game(H.ALCHEMIST)
	var m := g.roster[0]
	for id: String in ["growth", "tempering", "honing", "change"]:
		g.add_item("pill:" + id, 3)
	assert_bool(Crafting.use(g, "pill:growth", m)).is_true()
	assert_bool(Crafting.use(g, "pill:growth", m)).is_true()
	assert_int(m.step()).is_equal(2)
	assert_bool(Crafting.use(g, "pill:growth", m)).is_false()          # never past High: that is the void's
	assert_int(g.count("pill:growth")).is_equal(1)
	var points := m.unspent
	assert_bool(Crafting.use(g, "pill:tempering", m)).is_true()
	assert_int(m.unspent).is_equal(points + g.values.pill_points)
	assert_int(m.bonus_points).is_equal(g.values.pill_points)
	m.bonus_points = Crafting.pill_cap(g)
	assert_bool(Crafting.use(g, "pill:tempering", m)).is_false()       # a monster takes only so many
	var steps := m.dev_steps
	assert_bool(Crafting.use(g, "pill:honing", m)).is_true()
	assert_int(m.dev_steps).is_equal(steps + 1)
	assert_bool(Crafting.use(g, "pill:change", m)).is_true()
	assert_int(m.unspent + m.points_spent()).is_equal(MonsterInstance.START_POINTS + MonsterInstance.STEP_POINTS * m.step() + m.bonus_points)
	assert_bool(Crafting.use(g, "pill:warding", m)).is_false()         # a pill for the battle goes into a tamer slot


func test_a_relearning_pill_puts_another_skill_into_a_slot_that_keeps_its_level() -> void:
	var g := H.game(H.ALCHEMIST)
	var rng := RandomNumberGenerator.new()
	rng.seed = 4
	var m := MonsterInstance.grown(GameData.monster(&"moss_turtle"), rng, 2)
	g.roster.append(m)
	var other: StringName = &""
	for s in m.learnable():
		if not m.kit.has(s.id):
			other = s.id
			break
	assert_bool(Crafting.relearn(g, m, 0, other)).is_false()           # no pill
	g.add_item("pill:clarity")
	while m.slot_levels.size() < m.kit.size():
		m.slot_levels.append(1)
	m.slot_levels[0] = 2
	assert_bool(Crafting.relearn(g, m, 0, other)).is_true()
	assert_that(m.kit[0]).is_equal(other)
	assert_int(int(m.slot_levels[0])).is_equal(2)
	assert_int(g.count("pill:clarity")).is_equal(0)


func test_the_artificer_lays_parts_before_a_battle_of_the_wild_on_any_square() -> void:
	var g := H.game(H.ARTIFICER)
	g.parts = {"prop:earth_wall": 2, "ground:lava": 1}
	var f := Wild.fight_for(g, 0)
	assert_int(f.carry).is_equal(g.values.carry_base)
	var start_b: Array = f.own_map["start_b"]
	var enemy_square := "%d,%d" % [int(start_b[0][0]), int(start_b[0][1])]
	assert_bool(Crafting.lay(g, f, enemy_square, "prop:earth_wall")).is_true()      # no square is closed to a part
	assert_bool(Crafting.lay(g, f, "2,2", "ground:lava")).is_true()
	assert_str(Crafting.lay_problem(g, f, "1,2", "prop:earth_wall")).contains("carry")      # two parts carried
	assert_bool(Crafting.lay(g, f, "2,2", "")).is_true()               # taken up again
	assert_str(Crafting.lay_problem(g, f, "1,2", "ground:lava")).is_equal("")
	assert_str(Crafting.lay_problem(g, f, "1,2", "ground:thornbed")).contains("own no more")
	assert_bool(Crafting.lay(g, f, "1,2", Fight.SEAL_PART)).is_true()  # Seal Ground is always with them
	assert_str(Crafting.lay_problem(g, f, "3,3", "ground:lava")).is_equal("")      # and takes the room of no part
	assert_str(Crafting.lay_problem(g, f, "1,1", Fight.SEAL_PART)).is_not_equal("")
	assert_dict(g.parts).is_equal({"prop:earth_wall": 2, "ground:lava": 1})      # a part is not used up
	var other := H.game(H.FORMATION)
	var plain := Wild.fight_for(other, 0)
	assert_int(plain.carry).is_equal(0)
	assert_bool(Crafting.lay(other, plain, "2,2", Fight.SEAL_PART)).is_false()
	assert_int(VoidPlace.fight(g).carry).is_equal(0)                   # in the void the board is their own already


func test_pills_fill_the_tamer_slots_of_the_alchemist_and_are_used_up() -> void:
	var g := H.game(H.ALCHEMIST)
	g.add_item("pill:warding", 2)
	g.add_item("pill:mending", 1)
	var items := Crafting.battle_items(g)
	assert_str(String(items[&"pill_warding"])).is_equal("pill:warding")
	assert_str(String(items[&"pill_mending"])).is_equal("pill:mending")      # healing acts in the battle
	for skill: StringName in items:
		assert_object(BattleContent.shared().tamer_skill(skill)).is_not_null()
	var f := Wild.fight_for(g, 0)
	f.team = g.default_team(f.max_team)
	f.tamer = [&"pill_warding", &"pill_mending"]
	f.tamer_items = {&"pill_warding": "pill:warding", &"pill_mending": "pill:mending"}
	f.ref["drop"] = {}
	var r := H.result(f, true)
	r.used_tamer.append(&"pill_warding")
	Places.resolve(g, f, r)
	assert_int(g.count("pill:warding")).is_equal(1)                    # taken: used up
	assert_int(g.count("pill:mending")).is_equal(1)                    # carried, not taken: kept
