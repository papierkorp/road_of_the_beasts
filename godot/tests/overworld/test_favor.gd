extends GdUnitTestSuite
## Factions and favor (gdd_overworld §8.2): ranks, requests, spending (discount, licenses, recruits).


func _rng(seed_value := 31) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng


func _game() -> GameState:
	return GameState.new_game(_rng())


func _open(g: GameState, faction: StringName) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for q in g.quests:
		if StringName(q["faction"]) == faction:
			out.append(q)
	return out


# ---------- ranks ----------

func test_standing_decides_the_rank() -> void:
	assert_int(FactionCatalog.rank_of(0)).is_equal(0)
	assert_int(FactionCatalog.rank_of(9)).is_equal(0)
	assert_int(FactionCatalog.rank_of(10)).is_equal(1)
	assert_int(FactionCatalog.rank_of(30)).is_equal(2)
	assert_int(FactionCatalog.rank_of(60)).is_equal(3)
	assert_int(FactionCatalog.rank_of(500)).is_equal(3)
	assert_int(FactionCatalog.to_next_rank(4)).is_equal(6)
	assert_int(FactionCatalog.to_next_rank(80)).is_equal(-1)
	assert_str(FactionCatalog.rank_name(3)).is_equal("Honored")


func test_three_factions_with_names_and_envoys() -> void:
	assert_int(FactionCatalog.ids().size()).is_equal(3)
	for f in FactionCatalog.ids():
		assert_str(FactionCatalog.faction_name(f)).is_not_empty()
		assert_str(FactionCatalog.envoy_name(f)).is_not_empty()
		assert_str(FactionCatalog.blurb(f)).is_not_empty()


# ---------- requests ----------

func test_every_faction_starts_with_three_requests() -> void:
	var g := _game()
	for f in FactionCatalog.ids():
		assert_int(_open(g, f).size()).is_equal(QuestBoard.PER_FACTION)


func test_requests_fit_the_faction_and_pay_something() -> void:
	for seed_value in 25:
		var g := GameState.new_game(_rng(seed_value))
		for q in g.quests:
			assert_int(int(q["count"])).is_greater(0)
			assert_int(int(q["favor"])).is_greater(0)
			assert_int(int(q["days"])).is_between(QuestBoard.MIN_DAYS, QuestBoard.MAX_DAYS)
			var kind := ItemCatalog.kind_of(String(q["item"]))
			match StringName(q["faction"]):
				FactionCatalog.FAMILY:
					assert_bool(kind == ItemCatalog.Kind.PILL or kind == ItemCatalog.Kind.MATERIAL).is_true()
					assert_int(int(q["money"])).is_equal(0)
				FactionCatalog.GUILD:
					assert_int(kind).is_equal(ItemCatalog.Kind.MATERIAL)
					assert_int(int(q["money"])).is_greater(0)
				FactionCatalog.WATCH:
					assert_bool(kind == ItemCatalog.Kind.PILL or kind == ItemCatalog.Kind.MATERIAL).is_true()


func test_delivering_pays_favor_and_money_and_closes_the_request() -> void:
	var g := _game()
	var q: Dictionary = _open(g, FactionCatalog.GUILD)[0]
	var item := String(q["item"])
	assert_bool(g.can_deliver(int(q["uid"]))).is_false()
	assert_bool(g.deliver_quest(int(q["uid"]))).is_false()
	g.add_item(item, int(q["count"]))
	assert_bool(g.deliver_quest(int(q["uid"]))).is_true()
	assert_int(g.item_count(item)).is_equal(0)
	assert_int(g.money).is_equal(int(q["money"]))
	assert_int(g.favor_of(FactionCatalog.GUILD)).is_equal(int(q["favor"]))
	assert_int(g.standing_of(FactionCatalog.GUILD)).is_equal(int(q["favor"]))
	assert_int(g.quest(int(q["uid"])).size()).is_equal(0)


func test_spending_favor_keeps_the_standing() -> void:
	var g := _game()
	g.add_favor(FactionCatalog.GUILD, 12)
	assert_int(g.rank_of(FactionCatalog.GUILD)).is_equal(1)
	assert_bool(g.spend_favor(FactionCatalog.GUILD, 8)).is_true()
	assert_int(g.favor_of(FactionCatalog.GUILD)).is_equal(4)
	assert_int(g.standing_of(FactionCatalog.GUILD)).is_equal(12)
	assert_int(g.rank_of(FactionCatalog.GUILD)).is_equal(1)
	assert_bool(g.spend_favor(FactionCatalog.GUILD, 5)).is_false()


func test_requests_age_expire_and_are_replaced_every_night() -> void:
	var g := _game()
	var before := {}
	for q in g.quests:
		before[int(q["uid"])] = int(q["days"])
	g.end_day(_rng())
	for q in g.quests:
		if before.has(int(q["uid"])):
			assert_int(int(q["days"])).is_equal(before[int(q["uid"])] - 1)
	for f in FactionCatalog.ids():
		assert_int(_open(g, f).size()).is_equal(QuestBoard.PER_FACTION)
	for i in 6:
		g.end_day(_rng(i))
	for q in g.quests:
		assert_int(int(q["days"])).is_greater(0)


func test_request_ids_are_unique() -> void:
	var g := _game()
	for i in 5:
		g.end_day(_rng(i))
	var seen := {}
	for q in g.quests:
		assert_bool(seen.has(int(q["uid"]))).is_false()
		seen[int(q["uid"])] = true


# ---------- the guild: discount and rare blueprints ----------

func test_the_guilds_friends_pay_less_at_the_trader() -> void:
	var g := _game()
	var pill := ItemCatalog.pill_id(0)
	var full := g.market.buy_price(pill)
	g.add_favor(FactionCatalog.GUILD, 10)
	assert_int(g.market.guild_rank).is_equal(1)
	assert_int(g.market.buy_price(pill)).is_equal(floori(float(full) * 0.95))
	g.add_favor(FactionCatalog.GUILD, 50)
	assert_int(g.market.guild_rank).is_equal(3)
	assert_int(g.market.buy_price(pill)).is_equal(floori(float(full) * 0.85))
	assert_int(g.market.sell_price(ItemCatalog.material_id(MonsterDef.Kin.BEAST, Aspect.Type.FORCE, 0))).is_greater(0)


func test_the_discount_never_makes_buying_and_reselling_a_profit() -> void:
	var g := _game()
	g.add_favor(FactionCatalog.GUILD, 100)
	for id in g.market.stock:
		assert_int(g.market.buy_price(id)).is_greater(g.market.sell_price(id))


func test_rare_blueprints_appear_from_rank_two_and_can_be_bought_once() -> void:
	var g := _game()
	g.add_favor(FactionCatalog.GUILD, 30)
	g.end_day(_rng())
	assert_bool(g.market.blueprint_offer != &"").is_true()
	var sid := g.market.blueprint_offer
	var bp := ItemCatalog.blueprint_id(sid)
	assert_bool(g.owns_structure(sid)).is_false()
	assert_bool(g.market.can_buy(bp)).is_true()
	g.money = 5000
	assert_bool(g.market.buy(g, bp)).is_true()
	assert_bool(g.has_blueprint(sid)).is_true()
	assert_bool(g.market.can_buy(bp)).is_false()


func test_no_rare_blueprints_for_strangers() -> void:
	var g := _game()
	g.end_day(_rng())
	assert_bool(g.market.blueprint_offer == &"").is_true()


# ---------- licenses ----------

func test_production_structures_need_their_licenses() -> void:
	var g := _game()
	for id in [&"refining_furnace", &"pill_stall"]:
		assert_bool(g.missing_license(id) != &"").is_true()
		g.add_item(ItemCatalog.blueprint_id(id))
		g.add_item(ItemCatalog.structure_item_id(id))
		assert_bool(g.can_construct(id)).is_false()
		assert_int(g.place_structure(id, Vector2i(2, 1), false)).is_equal(-1)
	assert_bool(g.missing_license(&"meditation_stone") == &"").is_true()


func test_a_license_costs_favor_of_its_faction() -> void:
	var g := _game()
	assert_bool(g.buy_license(&"production")).is_false()
	g.add_favor(FactionCatalog.WATCH, 20)
	assert_bool(g.buy_license(&"production")).is_false()                    # the guild issues it
	g.add_favor(FactionCatalog.GUILD, g.license_cost(&"production"))
	assert_bool(g.buy_license(&"production")).is_true()
	assert_bool(g.has_license(&"production")).is_true()
	assert_int(g.favor_of(FactionCatalog.GUILD)).is_equal(0)
	assert_bool(g.buy_license(&"production")).is_false()                    # only once
	g.add_item(ItemCatalog.structure_item_id(&"refining_furnace"))
	assert_int(g.place_structure(&"refining_furnace", Vector2i(2, 1), false)).is_greater(0)


func test_the_watch_issues_the_street_trade_permit() -> void:
	var g := _game()
	g.add_favor(FactionCatalog.WATCH, g.license_cost(&"street_trade"))
	assert_bool(g.buy_license(&"street_trade")).is_true()
	assert_bool(g.missing_license(&"pill_stall") == &"").is_true()


# ---------- recruits ----------

func test_beasts_for_hire_appear_for_friends_only() -> void:
	var g := _game()
	g.end_day(_rng())
	assert_int(g.recruits.size()).is_equal(0)
	g.add_favor(FactionCatalog.FAMILY, 10)
	g.end_day(_rng())
	assert_int(g.recruits.size()).is_equal(1)
	assert_str(String(g.recruits[0]["faction"])).is_equal("family")


func test_recruiting_needs_favor_and_room_in_the_spatial_space() -> void:
	var g := _game()
	g.add_favor(FactionCatalog.FAMILY, 10)
	g.end_day(_rng())
	assert_bool(g.can_recruit(0)).is_false()                                # not enough favor
	g.add_favor(FactionCatalog.FAMILY, 10)
	assert_bool(g.can_recruit(0)).is_false()                                # capacity 1 at Qi Gathering
	Cheats.stage_up(g)
	assert_bool(g.can_recruit(0)).is_true()
	var hired := (g.recruits[0]["monster"] as MonsterInstance)
	assert_bool(g.recruit(0)).is_true()
	assert_int(g.monsters.size()).is_equal(2)
	assert_object(g.monsters[1]).is_same(hired)
	assert_int(g.favor_of(FactionCatalog.FAMILY)).is_equal(20 - FactionCatalog.RECRUIT_COST)
	assert_int(g.recruits.size()).is_equal(0)


func test_an_honored_friend_is_offered_better_blood() -> void:
	var g := _game()
	g.add_favor(FactionCatalog.FAMILY, 60)
	g.end_day(_rng())
	assert_int((g.recruits[0]["monster"] as MonsterInstance).rarity).is_equal(MonsterInstance.Rarity.RARE)


# ---------- saving and cheats ----------

func test_favor_requests_licenses_and_offers_survive_a_save() -> void:
	var g := _game()
	g.add_favor(FactionCatalog.FAMILY, 12)
	g.add_favor(FactionCatalog.GUILD, 35)
	g.buy_license(&"production")
	g.end_day(_rng())
	var back := GameState.from_dict(JSON.parse_string(JSON.stringify(g.to_dict())))
	assert_int(back.favor_of(FactionCatalog.GUILD)).is_equal(g.favor_of(FactionCatalog.GUILD))
	assert_int(back.standing_of(FactionCatalog.FAMILY)).is_equal(12)
	assert_int(back.quests.size()).is_equal(g.quests.size())
	assert_bool(back.has_license(&"production")).is_true()
	assert_int(back.recruits.size()).is_equal(g.recruits.size())
	assert_int(back.market.guild_rank).is_equal(2)
	assert_bool(back.market.blueprint_offer == g.market.blueprint_offer).is_true()
	var next_uid := back.take_quest_uid()
	for q in back.quests:
		assert_int(int(q["uid"])).is_not_equal(next_uid)


func test_the_cheat_gives_favor_and_licenses() -> void:
	var g := _game()
	Cheats.give_favor(g)
	for f in FactionCatalog.ids():
		assert_int(g.favor_of(f)).is_equal(30)
		assert_int(g.rank_of(f)).is_equal(2)
	assert_bool(g.has_license(&"production")).is_true()
	assert_bool(g.has_license(&"street_trade")).is_true()
