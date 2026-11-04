extends GdUnitTestSuite
## Developer shortcuts of the F10 cheat menu.


func _game() -> GameState:
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	return GameState.new_game(rng)


func test_resources_are_added() -> void:
	var g := _game()
	Cheats.give_money(g, 1000)
	Cheats.give_pills(g, 5)
	Cheats.give_materials(g, 2)
	assert_int(g.money).is_equal(1000)
	assert_int(g.item_count(ItemCatalog.pill_id(0))).is_equal(5)
	assert_int(g.item_count(ItemCatalog.materials_of_tier(0)[0])).is_equal(2)


func test_xp_can_lift_the_sub_tier_and_heal_restores_hp() -> void:
	var g := _game()
	g.monsters[0].current_hp = 1
	Cheats.give_xp(g, 100)
	assert_int(g.monsters[0].sub_tier).is_equal(Stage.SubTier.MIDDLE)
	Cheats.heal_all(g)
	assert_int(g.monsters[0].current_hp).is_equal(g.monsters[0].max_hp())


func test_refill_ap_and_next_day() -> void:
	var g := _game()
	g.spend_ap(3)
	Cheats.refill_ap(g)
	assert_int(g.ap).is_equal(g.max_ap)
	Cheats.next_day(g)
	assert_int(g.day).is_equal(2)
