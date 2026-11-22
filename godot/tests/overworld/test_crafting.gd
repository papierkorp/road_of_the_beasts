extends GdUnitTestSuite
## Alchemy and smithing (docs/vision.md §7): properties and flaws drawn per game and found by trying; a forge of two
## beast parts that shows every piece before.


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


## Two plants that share a property and have the same flaw (or not the same), as items of tier 0.
func _flaw_pair(g: GameState, same_flaw: bool) -> Array[String]:
	var ids := _plants(g)
	for a in ids:
		for b in ids:
			if a == b:
				continue
			var pa := Crafting.properties_of(g, a)
			var shared := Crafting.properties_of(g, b).filter(func(p: StringName) -> bool: return pa.has(p))
			if not shared.is_empty() and (Crafting.flaw_of(g, a) == Crafting.flaw_of(g, b)) == same_flaw:
				return [Materials.plant(a, 0), Materials.plant(b, 0)]
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
	g.add_item(Materials.beast_part(0), 1)
	assert_bool(Crafting.can_brew(g, [a])).is_false()
	assert_bool(Crafting.can_brew(g, [a, a])).is_false()
	assert_bool(Crafting.can_brew(g, [a, Materials.beast_part(0)])).is_false()


func test_every_plant_has_one_flaw_and_a_pill_has_it_only_when_all_its_plants_share_it() -> void:
	var with_flaw := 0
	var without := 0
	for seed_value in [61, 62, 63, 64]:
		var g := _game(seed_value)
		for id in _plants(g):
			assert_str(Crafting.flaw_of(g, id)).is_not_empty()
			assert_str(Crafting.flaw_of(g, id)).is_equal(Crafting.flaw_of(g, id))
		var same := _flaw_pair(g, true)
		if not same.is_empty():
			with_flaw += 1
			for item in same:
				g.add_item(item)
			assert_str(Crafting.known_flaw(g, Crafting.plant_of(same[0]))).is_equal("")
			var pill := Crafting.brew(g, same)
			assert_str(Materials.flaw(pill)).is_equal(Crafting.flaw_of(g, Crafting.plant_of(same[0])))
			assert_str(Crafting.known_flaw(g, Crafting.plant_of(same[0]))).is_equal(Materials.flaw(pill))      # found by trying
		var other := _flaw_pair(g, false)
		if not other.is_empty():
			without += 1
			for item in other:
				g.add_item(item)
			assert_str(Materials.flaw(Crafting.brew(g, other))).is_equal("")
	assert_int(with_flaw).is_greater(0)
	assert_int(without).is_greater(0)


func test_a_bitter_pill_costs_the_monster_one_hp_in_its_next_battle_never_its_last() -> void:
	var g := _game()
	var m := g.roster[0]
	g.add_item("pill:change:0:bitter", 1)
	g.add_item("pill:mending:0:bitter", 1)
	assert_bool(Crafting.use(g, "pill:change:0:bitter", m)).is_true()
	assert_int(m.current_hp).is_equal(m.max_hp() - 1)
	g.end_day()
	assert_int(m.current_hp).is_equal(m.max_hp() - 1)             # the night does not give it back
	var f := Fight.new()
	f.team = [m]
	Places.resolve(g, f, null)                                    # the battle it was missing in
	assert_int(m.hp_debt).is_equal(0)
	m.heal_full()
	assert_int(m.current_hp).is_equal(m.max_hp())
	m.current_hp = 1
	assert_bool(Crafting.use(g, "pill:mending:0:bitter", m, true)).is_true()      # in a dungeon at once: +2 and -1
	assert_int(m.current_hp).is_equal(2)


func test_a_volatile_pill_spoils_in_the_night_and_a_bitter_one_is_named_to_the_battle() -> void:
	var g := _game()
	g.add_item("pill:warding:0:volatile", 2)
	g.add_item("pill:swiftness:0:bitter", 1)
	g.add_item("pill:anchoring:0", 1)
	var f := Fight.new()
	f.tamer_items = Crafting.battle_items(g)
	assert_array(Crafting.bitter_entries(f)).is_equal([&"pill_swiftness"])
	Crafting.spend_used(g, f, BattleResult.new())         # none was taken in the battle
	assert_int(g.count("pill:warding:0:volatile")).is_equal(2)
	g.end_day()
	assert_int(g.count("pill:warding:0:volatile")).is_equal(0)
	assert_int(g.count("pill:swiftness:0:bitter")).is_equal(1)
	assert_int(g.count("pill:anchoring:0")).is_equal(1)


func test_pills_reshape_raise_the_bloodline_and_heal_in_a_dungeon() -> void:
	var g := _game()
	var m := g.roster[0]
	g.add_item("pill:change:0")
	g.add_item("pill:bloodline:0", 3)
	g.add_item("pill:mending:0")
	g.add_item("pill:warding:0")
	assert_bool(Crafting.use(g, "pill:change:0", m)).is_true()
	assert_dict(m.stats).is_equal(MonsterInstance.FLOOR)
	assert_bool(Crafting.use(g, "pill:bloodline:0", m)).is_true()
	assert_int(int(m.bloodline)).is_equal(int(MonsterInstance.Bloodline.SPIRIT))
	assert_int(m.gift_picks).is_equal(1)                                    # an ascension awakens one gift to choose
	assert_bool(m.take_gift(m.open_gifts()[0])).is_true()
	assert_bool(Crafting.use(g, "pill:bloodline:0", m)).is_true()
	assert_int(int(m.bloodline)).is_equal(int(MonsterInstance.Bloodline.ANCIENT))
	assert_int(m.gift_picks).is_equal(1)
	assert_bool(Crafting.use(g, "pill:bloodline:0", m)).is_false()          # never to Divine
	assert_bool(Crafting.use(g, "pill:warding:0", m)).is_false()            # acts in a battle, from a tamer slot
	m.current_hp = 1
	assert_bool(Crafting.use(g, "pill:mending:0", m)).is_false()            # only between the battles of a dungeon
	assert_bool(Crafting.use(g, "pill:mending:0", m, true)).is_true()
	assert_int(m.current_hp).is_equal(mini(m.max_hp(), 3))


func test_kindling_lifts_only_a_monster_below_the_highest_of_the_roster() -> void:
	var g := _game()
	var first := g.roster[0]
	g.add_item("pill:kindling:0", 3)
	assert_bool(Crafting.use(g, "pill:kindling:0", first)).is_false()       # alone it is the highest
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	var strong := MonsterInstance.grown(GameData.monster(&"moss_turtle"), rng, 2)
	assert_bool(g.add_monster(strong)).is_true()
	assert_bool(Crafting.use(g, "pill:kindling:0", strong)).is_false()
	assert_bool(Crafting.use(g, "pill:kindling:0", first)).is_true()
	assert_int(first.step()).is_equal(1)
	assert_bool(Crafting.use(g, "pill:kindling:0", first)).is_true()
	assert_int(first.step()).is_equal(2)
	assert_bool(Crafting.use(g, "pill:kindling:0", first)).is_false()       # it has caught up
	assert_int(g.count("pill:kindling:0")).is_equal(1)


func test_a_piece_is_forged_from_two_beast_parts_and_is_known_before() -> void:
	var g := _game()
	g.add_item(Materials.beast_part(5), 2)
	g.add_item(Materials.beast_part(0), 1)
	assert_dict(Crafting.forge_cost(5, 0)).is_equal({Materials.beast_part(5): 1, Materials.beast_part(0): 1})
	assert_dict(Crafting.forge_cost(5, 5)).is_equal({Materials.beast_part(5): 2})
	var what := Crafting.what_index(g, 5)                                    # what the Stone part makes in this game
	var how := Crafting.how_index(g, 0)                                      # how the Beast part acts in this game
	var piece := Crafting.piece_name(g.values, what, how)
	assert_str(piece).contains(String(Crafting.what_of(g.values, what)["name"]))
	assert_str(piece).contains(String(Crafting.how_of(g.values, how)["name"]))
	var weapon := Crafting.forge(g, Crafting.WEAPON, 5, 0)
	assert_str(weapon).is_equal(Materials.weapon(what, how))
	assert_str(Materials.display_name(weapon, g.values)).contains(piece)
	assert_int(g.count(weapon)).is_equal(1)
	assert_int(g.count(Materials.beast_part(5))).is_equal(1)
	assert_int(g.count(Materials.beast_part(0))).is_equal(0)
	assert_str(Crafting.forge(g, Crafting.WEAPON, 5, 0)).is_equal("")       # the second part is gone
	assert_str(Crafting.forge(g, Crafting.WEAPON, 5, 5)).is_equal("")       # two of one Kin are needed


func test_which_kin_gives_what_is_drawn_per_game_and_every_entry_is_given_once() -> void:
	var differs := false
	var first := _game(61)
	for seed_value in [61, 62, 63, 64]:
		var g := _game(seed_value)
		var whats := {}
		var hows := {}
		for kin in MonsterDef.Kin.size():
			assert_int(Crafting.what_index(g, kin)).is_equal(Crafting.what_index(g, kin))      # fixed within a game
			whats[Crafting.what_index(g, kin)] = true
			hows[Crafting.how_index(g, kin)] = true
			if Crafting.what_index(g, kin) != Crafting.what_index(first, kin):
				differs = true
		assert_int(whats.size()).is_equal(MonsterDef.Kin.size())
		assert_int(hows.size()).is_equal(MonsterDef.Kin.size())
	assert_bool(differs).is_true()


func test_the_same_pair_gives_a_weapon_or_parts_of_the_battleground() -> void:
	var g := _game()
	g.add_item(Materials.beast_part(5), 1)
	g.add_item(Materials.beast_part(0), 1)
	var what := Crafting.what_index(g, 5)
	var how := Crafting.how_index(g, 0)
	var part := Crafting.board_part(g.values, what)
	var before := int(g.parts.get(part, 0))
	assert_str(Crafting.forge(g, Crafting.PART, 5, 0)).is_equal(part)
	assert_int(int(g.parts[part])).is_equal(before + Crafting.part_units(g.values, how))
	assert_int(g.count(Materials.weapon(what, how))).is_equal(0)
	assert_int(g.count(Materials.beast_part(5))).is_equal(0)


func test_every_what_of_the_forge_lies_on_the_board() -> void:
	var v := GameValues.shared()
	var content := BattleContent.shared()
	assert_int(v.forge_what.size()).is_equal(MonsterDef.Kin.size())
	assert_int(v.forge_how.size()).is_equal(MonsterDef.Kin.size())
	for i in v.forge_what.size():
		var part := Crafting.board_part(v, i)
		var id := StringName(part.get_slice(":", 1))
		assert_object(content.prop(id) if part.begins_with("prop:") else content.ground(id)).is_not_null()


func test_a_weapon_and_a_battle_pill_fill_tamer_slots_and_the_pill_is_used_up() -> void:
	var g := _game()
	g.add_item(Materials.beast_part(2), 1)
	g.add_item(Materials.beast_part(1), 1)
	var weapon := Crafting.forge(g, Crafting.WEAPON, 2, 1)
	var what := Crafting.what_index(g, 2)
	var how := Crafting.how_index(g, 1)
	g.add_item("pill:warding:0", 2)
	g.add_item("pill:change:0", 1)
	var skill := Crafting.weapon_skill(what, how)
	var items := Crafting.battle_items(g)
	assert_str(String(items[skill])).is_equal(weapon)
	assert_str(String(items[&"pill_warding"])).is_equal("pill:warding:0")
	assert_int(items.size()).is_equal(2)                   # the reshape pill acts in no battle
	assert_int(Crafting.battle_uses(g, weapon)).is_equal(int(Crafting.how_of(g.values, how)["uses"]))
	Forged.ensure(g.values)
	for id in items:
		assert_object(BattleContent.shared().tamer_skill(id)).is_not_null()
	var def := BattleContent.shared().tamer_skill(skill)
	assert_str(def.effect).is_equal(TamerSkillDef.LAY)
	var w := Crafting.what_of(g.values, what)
	assert_str(String(def.lay_prop if w.has("prop") else def.lay_ground)).is_equal(String(w["prop"] if w.has("prop") else w["ground"]))
	assert_int(def.lay_count).is_equal(int(Crafting.how_of(g.values, how)["count"]))
	var f := Fight.new()
	f.tamer_items = items
	var r := BattleResult.new()
	r.used_tamer = [skill, &"pill_warding"]
	Crafting.spend_used(g, f, r)
	assert_int(g.count("pill:warding:0")).is_equal(1)
	assert_int(g.count(weapon)).is_equal(1)                # a weapon is never used up
