extends GdUnitTestSuite
## The Producer (gdd_overworld §8, §10.2): pill types, the Refining Furnace, the Pill Stall,
## healing and battle-prep pills.


func _rng(seed_value := 23) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng


func _game() -> GameState:
	var g := GameState.new_game(_rng())
	g.licenses = ["production", "street_trade"] as Array[String]       # the Producer's structures need licenses
	return g


func _place(g: GameState, sid: StringName, cell: Vector2i) -> int:
	g.add_item(ItemCatalog.structure_item_id(sid))
	return g.place_structure(sid, cell, false)


func _mat(aspect: Aspect.Type) -> String:
	return ItemCatalog.material_id(MonsterDef.Kin.BEAST, aspect, 0)


# ---------- pills ----------

func test_three_pill_types_with_their_own_names_and_values() -> void:
	var cult := ItemCatalog.pill_id(0)
	var heal := ItemCatalog.healing_pill_id(0)
	var prep := ItemCatalog.prep_pill_id(0)
	assert_str(String(ItemCatalog.pill_type(cult))).is_equal("cultivation")
	assert_str(String(ItemCatalog.pill_type(heal))).is_equal("healing")
	assert_str(String(ItemCatalog.pill_type(prep))).is_equal("prep")
	assert_str(ItemCatalog.display_name(heal)).is_equal("Qi Gathering Healing Pill")
	assert_str(ItemCatalog.display_name(prep)).is_equal("Qi Gathering Battle-Prep Pill")
	assert_int(ItemCatalog.base_value(cult)).is_equal(80)
	assert_int(ItemCatalog.base_value(heal)).is_equal(40)
	assert_int(ItemCatalog.base_value(ItemCatalog.healing_pill_id(1))).is_equal(120)
	assert_int(ItemCatalog.tier_of(prep)).is_equal(0)
	for id in [cult, heal, prep]:
		assert_int(ItemCatalog.kind_of(id)).is_equal(ItemCatalog.Kind.PILL)


func test_the_trader_only_sells_cultivation_pills() -> void:
	var g := _game()
	assert_bool(g.market.can_buy(ItemCatalog.pill_id(0))).is_true()
	assert_bool(g.market.can_buy(ItemCatalog.healing_pill_id(0))).is_false()
	assert_bool(g.market.can_buy(ItemCatalog.prep_pill_id(0))).is_false()


func test_only_cultivation_pills_give_xp() -> void:
	var g := _game()
	g.add_item(ItemCatalog.healing_pill_id(0))
	assert_int(g.use_pill(ItemCatalog.healing_pill_id(0), g.monsters[0])).is_equal(-1)
	assert_int(g.item_count(ItemCatalog.healing_pill_id(0))).is_equal(1)


func test_recipes_exist_for_all_three_pills() -> void:
	for id in RecipeCatalog.ids():
		assert_bool(RecipeCatalog.has(id)).is_true()
		assert_int(RecipeCatalog.batch_yield(id)).is_greater(0)
		assert_str(RecipeCatalog.inputs_text(id)).is_not_empty()
	assert_str(RecipeCatalog.output_id(&"healing", 1)).is_equal(ItemCatalog.healing_pill_id(1))
	assert_str(RecipeCatalog.output_id(&"cultivation", 0)).is_equal(ItemCatalog.pill_id(0))


# ---------- the furnace ----------

func test_a_batch_turns_materials_into_pills() -> void:
	var g := _game()
	var uid := _place(g, &"refining_furnace", Vector2i(2, 1))
	assert_bool(g.can_produce(uid, &"cultivation")).is_false()               # no materials
	g.add_item(_mat(Aspect.Type.FORCE), 7)
	var made := g.produce_batch(uid, &"cultivation")
	assert_int(made["count"]).is_equal(2)
	assert_int(g.item_count(ItemCatalog.pill_id(0))).is_equal(2)
	assert_int(g.item_count(_mat(Aspect.Type.FORCE))).is_equal(1)


func test_a_recipe_with_an_aspect_needs_that_aspect() -> void:
	var g := _game()
	var uid := _place(g, &"refining_furnace", Vector2i(2, 1))
	g.add_item(_mat(Aspect.Type.FORCE), 10)
	assert_bool(g.can_produce(uid, &"healing")).is_false()                   # needs Nature
	g.add_item(_mat(Aspect.Type.NATURE), 3)
	assert_bool(g.can_produce(uid, &"healing")).is_true()
	assert_int(g.produce_batch(uid, &"healing")["count"]).is_equal(3)


func test_a_qi_spring_next_to_the_furnace_makes_a_finer_batch() -> void:
	var g := _game()
	var uid := _place(g, &"refining_furnace", Vector2i(2, 1))
	var plain := g.batch_yield(g.structure(uid), &"cultivation")
	_place(g, &"qi_spring", Vector2i(3, 1))
	assert_int(g.batch_yield(g.structure(uid), &"cultivation")).is_equal(plain + RecipeCatalog.WATER_BONUS)
	_place(g, &"qi_spring", Vector2i(5, 3))                                 # not adjacent: no bonus
	assert_int(g.batch_yield(g.structure(uid), &"cultivation")).is_equal(plain + RecipeCatalog.WATER_BONUS)


func test_working_the_furnace_costs_one_ap() -> void:
	var g := _game()
	var uid := _place(g, &"refining_furnace", Vector2i(2, 1))
	g.add_item(_mat(Aspect.Type.FORCE), 6)
	var ap := g.ap
	assert_bool(g.work_furnace(uid, &"cultivation").is_empty()).is_false()
	assert_int(g.ap).is_equal(ap - 1)
	g.add_item(_mat(Aspect.Type.FORCE), 6)
	g.spend_ap(g.ap)
	assert_bool(g.work_furnace(uid, &"cultivation").is_empty()).is_true()


func test_a_standing_order_works_every_night_for_free() -> void:
	var g := _game()
	var uid := _place(g, &"refining_furnace", Vector2i(2, 1))
	assert_bool(g.set_order(uid, &"cultivation")).is_true()
	g.add_item(_mat(Aspect.Type.FORCE), 12)
	var report := g.end_day(_rng())
	assert_int(g.item_count(ItemCatalog.pill_id(0))).is_equal(2)
	assert_int(g.ap).is_equal(g.max_ap)
	assert_str(String((report["notes"] as Array)[0])).contains("Refining Furnace makes")
	g.end_day(_rng())
	assert_int(g.item_count(ItemCatalog.pill_id(0))).is_equal(4)


func test_a_night_without_materials_says_so() -> void:
	var g := _game()
	var uid := _place(g, &"refining_furnace", Vector2i(2, 1))
	g.set_order(uid, &"prep")
	var report := g.end_day(_rng())
	assert_str(String((report["notes"] as Array)[0])).contains("lacks materials")


func test_only_a_furnace_takes_orders() -> void:
	var g := _game()
	var stone := _place(g, &"meditation_stone", Vector2i(2, 1))
	assert_bool(g.set_order(stone, &"cultivation")).is_false()
	var furnace := _place(g, &"refining_furnace", Vector2i(3, 1))
	assert_bool(g.set_order(furnace, &"nonsense")).is_false()


# ---------- the stall ----------

func test_pills_go_on_the_shelf_and_back() -> void:
	var g := _game()
	var uid := _place(g, &"pill_stall", Vector2i(2, 1))
	var pill := ItemCatalog.pill_id(0)
	g.add_item(pill, 3)
	assert_bool(g.stock_shelf(uid, pill, 3)).is_true()
	assert_int(g.item_count(pill)).is_equal(0)
	assert_int(g.structure(uid)["shelf"][pill]).is_equal(3)
	assert_bool(g.stock_shelf(uid, pill, -2)).is_true()
	assert_int(g.item_count(pill)).is_equal(2)
	assert_bool(g.stock_shelf(uid, _mat(Aspect.Type.FORCE), 1)).is_false()   # pills only


func test_customers_buy_the_most_valuable_pills_first_each_night() -> void:
	var g := _game()
	var uid := _place(g, &"pill_stall", Vector2i(2, 1))
	var cult := ItemCatalog.pill_id(0)
	var heal := ItemCatalog.healing_pill_id(0)
	g.add_item(cult, 1)
	g.add_item(heal, 5)
	g.stock_shelf(uid, cult, 1)
	g.stock_shelf(uid, heal, 5)
	var expected := g.market.shop_price(cult) + g.market.shop_price(heal)
	assert_int(g.customers_per_night(g.structure(uid))).is_equal(GameState.SHOP_CUSTOMERS)
	var report := g.shop_night(g.structure(uid))
	assert_int(report.size()).is_equal(2)
	assert_str(String(report[0]["item"])).is_equal(cult)                    # worth more, goes first
	assert_int(g.money).is_equal(expected)
	assert_int(g.structure(uid)["shelf"][heal]).is_equal(4)


func test_water_brings_another_customer() -> void:
	var g := _game()
	var uid := _place(g, &"pill_stall", Vector2i(2, 1))
	_place(g, &"spirit_pond", Vector2i(3, 1))
	assert_int(g.customers_per_night(g.structure(uid))).is_equal(GameState.SHOP_CUSTOMERS + GameState.SHOP_WATER_BONUS)


func test_an_empty_shelf_sells_nothing() -> void:
	var g := _game()
	var uid := _place(g, &"pill_stall", Vector2i(2, 1))
	assert_int(g.shop_night(g.structure(uid)).size()).is_equal(0)
	assert_int(g.money).is_equal(0)


func test_the_night_runs_the_whole_chain_materials_to_money() -> void:
	var g := _game()
	var furnace := _place(g, &"refining_furnace", Vector2i(2, 1))
	var stall := _place(g, &"pill_stall", Vector2i(3, 1))
	g.set_order(furnace, &"cultivation")
	g.add_item(_mat(Aspect.Type.FORCE), 6)
	g.end_day(_rng())                                                      # the furnace makes 2 pills
	assert_int(g.item_count(ItemCatalog.pill_id(0))).is_equal(2)
	g.stock_shelf(stall, ItemCatalog.pill_id(0), 2)
	var report := g.end_day(_rng())
	assert_int(g.money).is_greater(0)
	assert_str(String((report["notes"] as Array)[-1])).contains("Pill Stall sells")


func test_pill_prices_drift_within_bounds() -> void:
	var g := _game()
	var rng := _rng(4)
	for i in 50:
		g.market.new_day(rng)
		for id in g.market.pill_factors:
			assert_float(g.market.pill_factors[id]).is_between(Market.PILL_FACTOR_MIN, Market.PILL_FACTOR_MAX)
	assert_int(g.market.shop_price(ItemCatalog.healing_pill_id(0))).is_greater(0)
	assert_int(g.market.shop_price(_mat(Aspect.Type.FORCE))).is_equal(0)


func test_shelf_order_and_prices_survive_a_save() -> void:
	var g := _game()
	var furnace := _place(g, &"refining_furnace", Vector2i(2, 1))
	var stall := _place(g, &"pill_stall", Vector2i(3, 1))
	g.set_order(furnace, &"healing")
	g.add_item(ItemCatalog.pill_id(0), 2)
	g.stock_shelf(stall, ItemCatalog.pill_id(0), 2)
	var back := GameState.from_dict(JSON.parse_string(JSON.stringify(g.to_dict())))
	assert_str(String(back.structure(furnace)["order"])).is_equal("healing")
	assert_int(back.structure(stall)["shelf"][ItemCatalog.pill_id(0)]).is_equal(2)
	assert_float(back.market.pill_factors[ItemCatalog.pill_id(0)]).is_equal_approx(g.market.pill_factors[ItemCatalog.pill_id(0)], 0.0001)


# ---------- healing and battle prep ----------

func test_a_healing_pill_restores_hp_up_to_the_maximum() -> void:
	var g := _game()
	var heal := ItemCatalog.healing_pill_id(0)
	var m := g.monsters[0]
	m.current_hp = 1
	g.add_item(heal, 3)
	assert_bool(g.use_healing_pill(heal, m)).is_true()
	assert_int(m.current_hp).is_equal(mini(m.max_hp(), 1 + ItemCatalog.HEAL_AMOUNT))
	m.current_hp = m.max_hp()
	assert_bool(g.use_healing_pill(heal, m)).is_false()                      # nothing to heal
	assert_int(g.item_count(heal)).is_equal(2)


func test_a_fallen_monster_can_be_brought_back_with_a_healing_pill() -> void:
	var g := _game()
	var heal := ItemCatalog.healing_pill_id(0)
	g.add_item(heal)
	g.monsters[0].current_hp = 0
	assert_bool(g.use_healing_pill(heal, g.monsters[0])).is_true()
	assert_int(g.monsters[0].current_hp).is_greater(0)


func test_the_wrong_pill_does_not_heal() -> void:
	var g := _game()
	g.add_item(ItemCatalog.pill_id(0))
	g.monsters[0].current_hp = 1
	assert_bool(g.use_healing_pill(ItemCatalog.pill_id(0), g.monsters[0])).is_false()


func test_a_prep_pill_adds_initiative_for_the_whole_battle() -> void:
	var plain := BattleSetup.build(BattleRequest.default())
	plain.begin()
	var r := BattleRequest.default()
	r.prep_init = {0: ItemCatalog.PREP_INIT}
	var prepared := BattleSetup.build(r)
	prepared.begin()
	var mon: Monster = prepared.monsters[&"p0_blaze_tiger"]
	assert_int(mon.prep_init).is_equal(ItemCatalog.PREP_INIT)
	assert_float(prepared.effective_stat(mon, Battle.Stat.INIT)).is_equal(
		plain.effective_stat(plain.monsters[&"p0_blaze_tiger"], Battle.Stat.INIT) + float(ItemCatalog.PREP_INIT))
	var other: Monster = prepared.monsters[&"p1_moss_turtle"]
	assert_int(other.prep_init).is_equal(0)
	# it does not touch the enemy side
	assert_int((prepared.monsters[&"e0_hollow_serpent"] as Monster).prep_init).is_equal(0)


func test_the_new_structures_are_production_structures() -> void:
	assert_int(StructureCatalog.def(&"refining_furnace").category).is_equal(StructureDef.Category.PRODUCTION)
	assert_int(StructureCatalog.def(&"pill_stall").category).is_equal(StructureDef.Category.PRODUCTION)
