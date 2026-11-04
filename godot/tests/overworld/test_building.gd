extends GdUnitTestSuite
## The building system of the Inner World (gdd_overworld §6.4): grid, constructing, placing,
## cultivation spots, herb plots, adjacency bonuses, blueprints and the Trader's offer.


func _rng(seed_value := 17) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng


func _game() -> GameState:
	return GameState.new_game(_rng())


func _mat(aspect: Aspect.Type, kin := MonsterDef.Kin.BEAST) -> String:
	return ItemCatalog.material_id(kin, aspect, 0)


## A game with the structure already in the bag.
func _with(g: GameState, sid: StringName) -> GameState:
	g.add_item(ItemCatalog.structure_item_id(sid))
	return g


func _place(g: GameState, sid: StringName, cell: Vector2i, rot := false) -> int:
	g.add_item(ItemCatalog.structure_item_id(sid))
	return g.place_structure(sid, cell, rot)


# ---------- catalog and grid ----------

func test_every_structure_has_a_recipe_a_footprint_and_a_name() -> void:
	assert_int(StructureCatalog.ids().size()).is_greater_equal(7)
	for id in StructureCatalog.ids():
		var d := StructureCatalog.def(id)
		assert_str(d.display_name).is_not_empty()
		assert_bool(d.recipe.is_empty()).is_false()
		assert_int(d.size.x).is_greater_equal(1)
		assert_int(d.price).is_greater(0)
		assert_str(d.recipe_text()).is_not_empty()


func test_the_buildable_area_grows_with_the_stage() -> void:
	var qi := BuildGrid.region(Stage.Type.QI_GATHERING)
	var foundation := BuildGrid.region(Stage.Type.FOUNDATION)
	var core := BuildGrid.region(Stage.Type.CORE_FORMATION)
	assert_int(foundation.get_area()).is_greater(qi.get_area())
	assert_int(core.get_area()).is_greater(foundation.get_area())
	assert_bool(foundation.encloses(qi)).is_true()
	assert_bool(core.encloses(foundation)).is_true()


func test_the_grid_stays_clear_of_the_stone_and_the_gate() -> void:
	var map := DistrictMap.of(&"inner")
	var core := BuildGrid.region(Stage.Type.CORE_FORMATION)
	for x in range(core.position.x, core.end.x):
		for y in range(core.position.y, core.end.y):
			var centre := (Vector2(x, y) + Vector2(0.5, 0.5)) * BuildGrid.CELL
			for t in map.things:
				assert_float(DistrictMap.distance_to(t, centre)).is_greater(0.9)


func test_a_pond_is_two_cells_wide_and_rotates() -> void:
	var pond := StructureCatalog.def(&"spirit_pond")
	assert_int(BuildGrid.cells_of(pond, Vector2i(2, 1), false).size()).is_equal(2)
	assert_array(BuildGrid.cells_of(pond, Vector2i(2, 1), true)).contains_exactly([Vector2i(2, 1), Vector2i(2, 2)])


func test_structures_cannot_leave_the_area_or_overlap() -> void:
	var g := _game()
	var stone := StructureCatalog.def(&"meditation_stone")
	assert_bool(BuildGrid.can_place(g, stone, Vector2i(0, 0), false)).is_false()      # outside the Qi area
	assert_bool(BuildGrid.can_place(g, stone, Vector2i(2, 1), false)).is_true()
	_place(g, &"meditation_stone", Vector2i(2, 1))
	assert_bool(BuildGrid.can_place(g, stone, Vector2i(2, 1), false)).is_false()      # taken
	assert_bool(BuildGrid.can_place(g, stone, Vector2i(3, 1), false)).is_true()


# ---------- constructing and placing ----------

func test_constructing_needs_the_blueprint_the_materials_and_ap() -> void:
	var g := _game()
	assert_bool(g.can_construct(&"meditation_stone")).is_false()           # no materials yet
	g.add_item(_mat(Aspect.Type.FORCE), 3)
	assert_bool(g.can_construct(&"meditation_stone")).is_true()
	assert_bool(g.can_construct(&"qi_spring")).is_false()                  # no blueprint
	g.spend_ap(3)
	assert_bool(g.can_construct(&"meditation_stone")).is_false()           # no AP


func test_constructing_uses_the_materials_and_one_ap() -> void:
	var g := _game()
	g.add_item(_mat(Aspect.Type.FORCE), 4)
	assert_bool(g.construct(&"meditation_stone")).is_true()
	assert_int(g.ap).is_equal(g.max_ap - 1)
	assert_int(g.item_count(_mat(Aspect.Type.FORCE))).is_equal(1)
	assert_int(g.item_count(ItemCatalog.structure_item_id(&"meditation_stone"))).is_equal(1)
	assert_bool(g.has_blueprint(&"meditation_stone")).is_true()            # the blueprint stays


func test_a_specific_aspect_is_paid_with_that_aspect_first() -> void:
	var g := _game()
	g.add_item(ItemCatalog.blueprint_id(&"qi_spring"))
	g.add_item(_mat(Aspect.Type.NATURE), 4)
	g.add_item(_mat(Aspect.Type.FORCE), 2)
	assert_bool(g.construct(&"qi_spring")).is_true()      # 4 Nature + 2 any
	assert_int(g.item_count(_mat(Aspect.Type.NATURE))).is_equal(0)
	assert_int(g.item_count(_mat(Aspect.Type.FORCE))).is_equal(0)


func test_placing_is_free_and_picking_up_returns_it_to_the_bag() -> void:
	var g := _with(_game(), &"meditation_stone")
	var ap := g.ap
	var uid := g.place_structure(&"meditation_stone", Vector2i(3, 2), false)
	assert_int(uid).is_greater(0)
	assert_int(g.ap).is_equal(ap)
	assert_int(g.item_count(ItemCatalog.structure_item_id(&"meditation_stone"))).is_equal(0)
	assert_bool(g.pick_up_structure(uid)).is_true()
	assert_int(g.item_count(ItemCatalog.structure_item_id(&"meditation_stone"))).is_equal(1)
	assert_int(g.structures.size()).is_equal(0)


func test_a_structure_can_only_be_placed_when_it_is_in_the_bag() -> void:
	var g := _game()
	assert_int(g.place_structure(&"meditation_stone", Vector2i(2, 1), false)).is_equal(-1)


func test_structures_can_be_moved_for_free() -> void:
	var g := _game()
	var uid := _place(g, &"meditation_stone", Vector2i(2, 1))
	_place(g, &"meditation_stone", Vector2i(3, 1))
	assert_bool(g.move_structure(uid, Vector2i(3, 1), false)).is_false()   # taken
	assert_bool(g.move_structure(uid, Vector2i(4, 2), false)).is_true()
	assert_int(g.structure(uid)["x"]).is_equal(4)


# ---------- cultivation ----------

func test_a_meditating_monster_gains_xp_every_night() -> void:
	var g := _game()
	var uid := _place(g, &"meditation_stone", Vector2i(2, 1))
	assert_bool(g.assign_monster(uid, 0)).is_true()
	var report := g.end_day(_rng())
	assert_int(g.monsters[0].xp).is_equal(10)
	assert_int((report["notes"] as Array).size()).is_equal(1)


func test_a_monster_sits_at_one_spot_only() -> void:
	var g := _game()
	var a := _place(g, &"meditation_stone", Vector2i(2, 1))
	var b := _place(g, &"qi_spring", Vector2i(4, 2))
	g.assign_monster(a, 0)
	g.assign_monster(b, 0)
	assert_int(g.structure(a)["assigned"]).is_equal(-1)
	assert_int(g.structure(b)["assigned"]).is_equal(0)


func test_an_altar_of_the_monsters_aspect_next_to_the_spot_adds_xp() -> void:
	var g := _game()          # the starter is a Force monster (Blaze Tiger)
	var uid := _place(g, &"meditation_stone", Vector2i(2, 1))
	g.assign_monster(uid, 0)
	_place(g, &"altar_force", Vector2i(3, 1))
	assert_int(StructureRules.idle_xp(g, g.structure(uid))["xp"]).is_equal(10 + StructureRules.ALTAR_BONUS)
	# a Dark altar does nothing for a Force monster, and an altar further away does nothing either
	var h := _game()
	var uid2 := _place(h, &"meditation_stone", Vector2i(2, 1))
	h.assign_monster(uid2, 0)
	_place(h, &"altar_dark", Vector2i(3, 1))
	_place(h, &"altar_force", Vector2i(5, 3))
	assert_int(StructureRules.idle_xp(h, h.structure(uid2))["xp"]).is_equal(10)


# ---------- growing ----------

func test_a_herb_plot_grows_a_material_into_three() -> void:
	var g := _game()
	var uid := _place(g, &"herb_plot", Vector2i(2, 1))
	var herb := _mat(Aspect.Type.NATURE)
	g.add_item(herb)
	assert_bool(g.plant(uid, herb)).is_true()
	assert_int(g.item_count(herb)).is_equal(0)
	for night in StructureRules.GROW_NIGHTS - 1:
		g.end_day(_rng())
		assert_str(g.harvest(uid)).is_empty()
	g.end_day(_rng())
	assert_str(g.harvest(uid)).is_equal(herb)
	assert_int(g.item_count(herb)).is_equal(StructureRules.HARVEST_YIELD)
	assert_str(String(g.structure(uid)["plant"])).is_empty()


func test_water_next_to_a_plot_saves_a_night() -> void:
	var g := _game()
	var uid := _place(g, &"herb_plot", Vector2i(2, 1))
	assert_int(StructureRules.grow_nights(g, g.structure(uid))).is_equal(StructureRules.GROW_NIGHTS)
	_place(g, &"spirit_pond", Vector2i(3, 1))
	assert_int(StructureRules.grow_nights(g, g.structure(uid))).is_equal(StructureRules.GROW_NIGHTS - 1)
	_place(g, &"qi_spring", Vector2i(2, 2))          # a second water source doesn't stack
	assert_int(StructureRules.grow_nights(g, g.structure(uid))).is_equal(StructureRules.GROW_NIGHTS - 1)


func test_a_growing_plot_cannot_be_picked_up() -> void:
	var g := _game()
	var uid := _place(g, &"herb_plot", Vector2i(2, 1))
	var herb := _mat(Aspect.Type.NATURE)
	g.add_item(herb)
	g.plant(uid, herb)
	assert_bool(g.pick_up_structure(uid)).is_false()


# ---------- saving ----------

func test_structures_survive_a_save() -> void:
	var g := _game()
	var uid := _place(g, &"meditation_stone", Vector2i(3, 2))
	g.assign_monster(uid, 0)
	var back := GameState.from_dict(JSON.parse_string(JSON.stringify(g.to_dict())))
	assert_int(back.structures.size()).is_equal(1)
	assert_int(back.structures[0]["x"]).is_equal(3)
	assert_int(back.structures[0]["assigned"]).is_equal(0)
	var more := _with(back, &"qi_spring")
	assert_int(more.place_structure(&"qi_spring", Vector2i(4, 2), false)).is_not_equal(uid)


# ---------- in the world ----------

func test_placed_structures_become_solid_usable_things_of_the_inner_world() -> void:
	var g := _game()
	var uid := _place(g, &"meditation_stone", Vector2i(3, 2))
	var map := DistrictMap.of(&"inner")
	var before := map.things.size()
	map.add_structures(g.structures)
	assert_int(map.things.size()).is_equal(before + 1)
	var centre := (Vector2(3, 2) + Vector2(0.5, 0.5)) * BuildGrid.CELL
	assert_bool(map.blocked(centre)).is_true()
	assert_str(String(map.nearest_action(centre + Vector2(0, 1.5))["action"])).is_equal("structure:%d" % uid)


# ---------- trader and blueprints ----------

func test_the_trader_sometimes_offers_a_ready_made_structure_once() -> void:
	var g := _game()
	g.market.structure_offer = &"qi_spring"
	g.money = 1000
	var id := ItemCatalog.structure_item_id(&"qi_spring")
	assert_bool(g.market.can_buy(id)).is_true()
	assert_bool(g.market.buy(g, id)).is_true()
	assert_int(g.money).is_equal(1000 - StructureCatalog.def(&"qi_spring").price)
	assert_int(g.item_count(id)).is_equal(1)
	assert_bool(g.market.can_buy(id)).is_false()          # sold
	assert_bool(g.market.sell(g, id)).is_false()          # and not bought back


func test_blueprints_are_not_sold() -> void:
	var g := _game()
	assert_bool(g.market.can_buy(ItemCatalog.blueprint_id(&"qi_spring"))).is_false()


func test_the_offer_changes_with_the_nights() -> void:
	var g := _game()
	var rng := _rng(3)
	var seen_offer := false
	var seen_none := false
	for i in 60:
		g.market.new_day(rng)
		if g.market.structure_offer == &"":
			seen_none = true
		else:
			seen_offer = true
	assert_bool(seen_offer).is_true()
	assert_bool(seen_none).is_true()


func test_the_boss_drops_a_blueprint_you_do_not_know_yet() -> void:
	var g := _game()
	var e := Expedition.generate(g, _rng())
	assert_bool(e.blueprint_reward != &"").is_true()
	assert_bool(g.owns_structure(e.blueprint_reward)).is_false()
	var win := BattleResult.new()
	win.over = true
	win.winner_side = 0
	win.player.append({"species": &"blaze_tiger", "index": 0, "hp_left": 3, "max_hp": 4, "alive": true})
	var guard := 0
	while not e.finished and guard < 20:
		e.select(e.choices()[0])
		e.request_for(g)
		e.apply_result(g, win)
		guard += 1
	assert_bool(e.finished).is_true()
	assert_bool(g.has_blueprint(e.blueprint_reward)).is_true()


func test_nothing_is_dropped_when_every_blueprint_is_known() -> void:
	var g := _game()
	Cheats.give_blueprints(g)
	var e := Expedition.generate(g, _rng())
	assert_bool(e.blueprint_reward == &"").is_true()
