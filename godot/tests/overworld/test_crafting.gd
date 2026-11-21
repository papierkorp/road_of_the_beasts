extends GdUnitTestSuite
## Alchemy and smithing (docs/vision.md §7): properties drawn per game, found by trying, always the same result.


func _game(seed_value := 61) -> GameState:
	return GameState.new_game(seed_value, &"way_of_the_formation", &"blaze_tiger")


func _plants(g: GameState) -> Array[StringName]:
	return Materials.plants_of(g.values, 5)


## Two plants that share a property (or not), as items of tier 0.
func _pair(g: GameState, sharing: bool) -> Array[String]:
	var ids := _plants(g)
	for a in ids:
		for b in ids:
			if a == b:
				continue
			var pa := Crafting.properties_of(g, a)
			var shared := Crafting.properties_of(g, b).filter(func(p: StringName) -> bool: return pa.has(p))
			if shared.is_empty() != sharing:
				return [Materials.plant(a, 0), Materials.plant(b, 1)]
	return []


func test_the_properties_of_a_plant_are_fixed_within_a_game_and_differ_between_games() -> void:
	var g := _game(61)
	var differs := false
	for id in _plants(g):
		var props := Crafting.properties_of(g, id)
		assert_int(props.size()).is_equal(g.values.properties_per_plant)
		assert_array(Crafting.properties_of(g, id)).is_equal(props)
		var unique := {}
		for p in props:
			unique[p] = true
		assert_int(unique.size()).is_equal(props.size())
		if Crafting.properties_of(_game(62), id) != props:
			differs = true
	assert_bool(differs).is_true()


func test_plants_that_share_a_property_give_a_pill_and_the_property_becomes_known() -> void:
	var g := _game()
	var pair := _pair(g, true)
	assert_int(pair.size()).is_equal(2)
	for item in pair:
		g.add_item(item, 2)
	assert_array(Crafting.known_of(g, Crafting.plant_of(pair[0]))).is_empty()
	var pill := Crafting.brew(g, pair)
	assert_str(pill).starts_with("pill:")
	assert_int(Materials.tier(pill)).is_equal(0)                  # the lowest tier among the plants
	assert_int(g.count(pill)).is_equal(1)
	assert_int(g.count(pair[0])).is_equal(1)
	assert_array(Crafting.known_of(g, Crafting.plant_of(pair[0]))).is_not_empty()
	assert_str(Crafting.brew(g, pair)).is_equal(pill)             # the same plants always give the same pill
	assert_str(Crafting.brew(g, pair)).is_equal("")               # none left


func test_plants_that_share_nothing_are_lost() -> void:
	var g := _game()
	var pair := _pair(g, false)
	if pair.is_empty():
		return                                                     # every pair shares something in this draw
	for item in pair:
		g.add_item(item)
	assert_str(Crafting.brew(g, pair)).is_equal("")
	assert_int(g.count(pair[0])).is_equal(0)
	assert_int(g.count(pair[1])).is_equal(0)


func test_a_brew_needs_two_or_three_different_plants() -> void:
	var g := _game()
	var a := Materials.plant(_plants(g)[0], 0)
	g.add_item(a, 3)
	assert_bool(Crafting.can_brew(g, [a])).is_false()
	assert_bool(Crafting.can_brew(g, [a, a])).is_false()
	assert_bool(Crafting.can_brew(g, [a, Materials.ore(0)])).is_false()


func test_pills_reshape_raise_the_rarity_and_heal_in_a_dungeon() -> void:
	var g := _game()
	var m := g.roster[0]
	g.add_item("pill:change:0")
	g.add_item("pill:bloodline:0", 3)
	g.add_item("pill:mending:0")
	g.add_item("pill:warding:0")
	assert_bool(Crafting.use(g, "pill:change:0", m)).is_true()
	assert_dict(m.stats).is_equal(MonsterInstance.FLOOR)
	assert_bool(Crafting.use(g, "pill:bloodline:0", m)).is_true()
	assert_bool(Crafting.use(g, "pill:bloodline:0", m)).is_true()
	assert_int(int(m.rarity)).is_equal(int(MonsterInstance.Rarity.EPIC))
	assert_bool(Crafting.use(g, "pill:bloodline:0", m)).is_false()          # never to Legendary
	assert_bool(Crafting.use(g, "pill:warding:0", m)).is_false()            # acts in a battle: not built
	m.current_hp = 1
	assert_bool(Crafting.use(g, "pill:mending:0", m)).is_false()            # only between the battles of a dungeon
	assert_bool(Crafting.use(g, "pill:mending:0", m, true)).is_true()
	assert_int(m.current_hp).is_equal(mini(m.max_hp(), 3))


func test_the_same_parts_always_give_the_same_piece() -> void:
	var g := _game()
	g.add_item(Materials.ore(0), 3)
	g.add_item(Materials.beast_part(2), 3)
	g.add_item(Materials.essence(0), 1)
	var a := Crafting.forge(g, Crafting.ARMOUR, Materials.ore(0), Materials.beast_part(2))
	var b := Crafting.forge(g, Crafting.ARMOUR, Materials.ore(0), Materials.beast_part(2))
	assert_str(a).starts_with("armour:")
	assert_str(b).is_equal(a)
	assert_int(g.count(a)).is_equal(2)
	assert_int(g.count(Materials.ore(0))).is_equal(1)
	assert_str(a).is_equal(Crafting.piece_name(g, Crafting.ARMOUR, Materials.ore(0), Materials.beast_part(2)))      # known before
	assert_str(a).contains(String(Crafting.core_of(g, Crafting.ARMOUR, 2)["name"]))
	var c := Crafting.forge(g, Crafting.WEAPON, Materials.ore(0), Materials.beast_part(2), Materials.essence(0))
	assert_str(c).starts_with("weapon:")
	assert_str(c).contains(String(Crafting.temper_of(g, 0)["name"]))
	assert_int(g.count(Materials.essence(0))).is_equal(0)
	assert_str(Crafting.forge(g, Crafting.WEAPON, Materials.ore(0), Materials.beast_part(2))).is_equal("")     # no ore left


func test_a_monster_wears_one_armour() -> void:
	var g := _game()
	g.add_item("armour:Thick Hide (Qi Gathering)", 1)
	g.add_item("armour:Rooted (Qi Gathering)", 1)
	var m := g.roster[0]
	assert_bool(Crafting.wear(g, m, "armour:Thick Hide (Qi Gathering)")).is_true()
	assert_int(g.count("armour:Thick Hide (Qi Gathering)")).is_equal(0)
	assert_bool(Crafting.wear(g, m, "armour:Rooted (Qi Gathering)")).is_true()
	assert_int(g.count("armour:Thick Hide (Qi Gathering)")).is_equal(1)
	assert_bool(Crafting.wear(g, m, "")).is_true()
	assert_str(String(m.armour)).is_equal("")
	assert_int(g.count("armour:Rooted (Qi Gathering)")).is_equal(1)


func test_a_weapon_and_a_battle_pill_fill_tamer_slots_and_the_pill_is_used_up() -> void:
	var g := _game()
	g.add_item(Materials.ore(0), 1)
	g.add_item(Materials.beast_part(0), 1)
	var weapon := Crafting.forge(g, Crafting.WEAPON, Materials.ore(0), Materials.beast_part(0))
	g.add_item("pill:warding:0", 2)
	g.add_item("pill:change:0", 1)
	var items := Crafting.battle_items(g)
	assert_str(String(items[&"weapon_ember_brand"])).is_equal(weapon)
	assert_str(String(items[&"pill_warding"])).is_equal("pill:warding:0")
	assert_int(items.size()).is_equal(2)                   # the reshape pill acts in no battle
	for id in items:
		assert_object(BattleContent.shared().tamer_skill(id)).is_not_null()
	var f := Fight.new()
	f.tamer_items = items
	var r := BattleResult.new()
	r.used_tamer = [&"weapon_ember_brand", &"pill_warding"]
	Crafting.spend_used(g, f, r)
	assert_int(g.count("pill:warding:0")).is_equal(1)
	assert_int(g.count(weapon)).is_equal(1)                # a weapon is never used up


func test_an_armour_gives_its_wearer_a_passive_in_the_battle() -> void:
	var g := _game()
	g.add_item(Materials.ore(0), 1)
	g.add_item(Materials.beast_part(5), 1)
	var armour := Crafting.forge(g, Crafting.ARMOUR, Materials.ore(0), Materials.beast_part(5))
	var m := g.roster[0]
	assert_bool(Crafting.wear(g, m, armour)).is_true()
	var sheet := UnitSheets.from_instance(m)
	assert_bool(BattleStats.has_flag(BattleUnit.new(&"x", sheet), &"immovable")).is_true()      # Anchor Plate
	var copy := MonsterInstance.from_dict(JSON.parse_string(JSON.stringify(m.to_dict())))
	assert_bool(BattleStats.has_flag(BattleUnit.new(&"y", UnitSheets.from_instance(copy)), &"immovable")).is_true()
	Crafting.wear(g, m, "")
	assert_bool(BattleStats.has_flag(BattleUnit.new(&"z", UnitSheets.from_instance(m)), &"immovable")).is_false()
