extends GdUnitTestSuite
## The Trader (gdd_overworld §8, §9.4, §10.2): prices, buying, selling, pills.


func _rng(seed_value := 6) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng


func _game() -> GameState:
	return GameState.new_game(_rng())


func test_the_market_has_todays_stock() -> void:
	var g := _game()
	assert_int(g.market.stock.size()).is_equal(Market.STOCK_SIZE)
	assert_int(g.market.factors.size()).is_equal(18)


func test_prices_drift_within_bounds_and_stock_changes() -> void:
	var g := _game()
	var rng := _rng(2)
	var stocks := {}
	for i in 40:
		g.market.new_day(rng)
		stocks[",".join(PackedStringArray(g.market.stock))] = true
		for id in g.market.factors:
			assert_float(g.market.factors[id]).is_between(Market.FACTOR_MIN, Market.FACTOR_MAX)
	assert_int(stocks.size()).is_greater(1)


func test_the_spread_means_instant_resale_loses_money() -> void:
	var g := _game()
	for id in g.market.stock:
		assert_int(g.market.buy_price(id)).is_greater(g.market.sell_price(id))


func test_buying_a_pill_costs_money_and_fills_the_bag() -> void:
	var g := _game()
	var pill := ItemCatalog.pill_id(0)
	g.money = 200
	assert_bool(g.market.buy(g, pill)).is_true()
	assert_int(g.money).is_equal(200 - ItemCatalog.PILL_PRICE)
	assert_int(g.item_count(pill)).is_equal(1)


func test_you_cannot_buy_without_the_money() -> void:
	var g := _game()
	g.money = 5
	assert_bool(g.market.buy(g, ItemCatalog.pill_id(0))).is_false()
	assert_int(g.money).is_equal(5)
	assert_int(g.item_count(ItemCatalog.pill_id(0))).is_equal(0)


func test_only_stocked_materials_can_be_bought() -> void:
	var g := _game()
	g.money = 10000
	var stocked: String = g.market.stock[0]
	var absent := ""
	for id in g.market.factors:
		if not g.market.stock.has(id):
			absent = id
			break
	assert_bool(g.market.buy(g, stocked)).is_true()
	assert_bool(g.market.buy(g, absent)).is_false()


func test_selling_a_material_pays_and_pills_are_not_bought_back() -> void:
	var g := _game()
	var id: String = g.market.stock[0]
	g.add_item(id)
	var price := g.market.sell_price(id)
	assert_bool(g.market.sell(g, id)).is_true()
	assert_int(g.money).is_equal(price)
	assert_int(g.item_count(id)).is_equal(0)
	g.add_item(ItemCatalog.pill_id(0))
	assert_bool(g.market.sell(g, ItemCatalog.pill_id(0))).is_false()


func test_a_pill_gives_xp_and_is_used_up() -> void:
	var g := _game()
	var pill := ItemCatalog.pill_id(0)
	g.add_item(pill, 2)
	var m := g.monsters[0]
	assert_int(g.use_pill(pill, m)).is_equal(0)
	assert_int(m.xp).is_equal(ItemCatalog.PILL_XP)
	assert_int(g.item_count(pill)).is_equal(1)
	assert_int(g.use_pill(pill, m)).is_equal(1)       # 60 XP: the Lower bar is full
	assert_int(m.sub_tier).is_equal(Stage.SubTier.MIDDLE)
	assert_int(g.use_pill(pill, m)).is_equal(-1)      # none left


func test_the_bag_and_the_market_survive_a_save() -> void:
	var g := _game()
	g.add_item(g.market.stock[0], 3)
	g.money = 77
	var back := GameState.from_dict(JSON.parse_string(JSON.stringify(g.to_dict())))
	assert_int(back.item_count(g.market.stock[0])).is_equal(3)
	assert_int(back.money).is_equal(77)
	assert_array(back.market.stock).contains_exactly(g.market.stock)
	assert_float(back.market.factor(g.market.stock[0])).is_equal_approx(g.market.factor(g.market.stock[0]), 0.0001)


func test_the_night_moves_the_market() -> void:
	var g := _game()
	var before := g.market.to_dict()
	g.end_day(_rng(99))
	assert_bool(g.market.to_dict() == before).is_false()


func test_a_won_node_drops_one_material_per_wild_monster() -> void:
	var g := _game()
	var e := Expedition.generate(g, _rng())
	e.select(e.choices()[0])
	e.request_for(g)
	var enemy: MonsterInstance = e.node(e.selected)["enemies"][0]
	var r := BattleResult.new()
	r.over = true
	r.winner_side = 0
	r.player.append({"species": &"blaze_tiger", "index": 0, "hp_left": 2, "max_hp": 4, "alive": true})
	e.apply_result(g, r)
	var def := enemy.species()
	var id := ItemCatalog.material_id(def.kin, def.aspect, int(enemy.stage))
	assert_int(g.item_count(id)).is_equal(1)
	assert_int(int(e.last_loot[id])).is_equal(1)
