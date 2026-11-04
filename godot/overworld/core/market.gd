class_name Market
extends RefCounted
## The Trader's market (gdd_overworld §8, §11 Phase 1): every material has a price factor that
## drifts a little each night, a few materials are in stock today. Buy low, sell high — the
## spread (buy x1.25, sell x0.8) means only real price swings pay. Cultivation pills are always
## on sale at a fixed price and are never bought back (money buys speed, never exclusive power, §9.4).
## Now and then the Trader also has a ready-made structure (§6.4) — most come from blueprints instead.
## Headless; the state it trades with is passed in.

const MARKUP := 1.25
const SELL_RATE := 0.8
const STOCK_SIZE := 5
const FACTOR_MIN := 0.6
const FACTOR_MAX := 1.5
const FACTOR_STEP := 0.2
const OFFER_CHANCE := 0.3
const PILL_FACTOR_MIN := 0.7
const PILL_FACTOR_MAX := 1.4
const PILL_FACTOR_STEP := 0.15

var factors := {}                   # material id -> price factor
var pill_factors := {}              # pill id -> what customers pay today (x base value), for the Pill Stall
var stock: Array[String] = []       # materials for sale today
var structure_offer: StringName = &""      # a constructed structure for sale today, or none


static func create(tier: int, rng: RandomNumberGenerator) -> Market:
	var m := Market.new()
	for id in ItemCatalog.materials_of_tier(tier):
		m.factors[id] = rng.randf_range(0.8, 1.2)
	for id in ItemCatalog.pills_of_tier(tier):
		m.pill_factors[id] = rng.randf_range(0.9, 1.1)
	m._restock(rng)
	return m


## A new tier of materials becomes tradable (after a breakthrough).
func add_tier(tier: int, rng: RandomNumberGenerator) -> void:
	for id in ItemCatalog.materials_of_tier(tier):
		if not factors.has(id):
			factors[id] = rng.randf_range(0.8, 1.2)
	for id in ItemCatalog.pills_of_tier(tier):
		if not pill_factors.has(id):
			pill_factors[id] = rng.randf_range(0.9, 1.1)


## The night: prices drift, the stock changes.
func new_day(rng: RandomNumberGenerator) -> void:
	var ids := factors.keys()
	ids.sort()
	for id in ids:
		factors[id] = clampf(float(factors[id]) + rng.randf_range(-FACTOR_STEP, FACTOR_STEP), FACTOR_MIN, FACTOR_MAX)
	var pill_ids := pill_factors.keys()
	pill_ids.sort()
	for id in pill_ids:
		pill_factors[id] = clampf(float(pill_factors[id]) + rng.randf_range(-PILL_FACTOR_STEP, PILL_FACTOR_STEP), PILL_FACTOR_MIN, PILL_FACTOR_MAX)
	_restock(rng)


func _restock(rng: RandomNumberGenerator) -> void:
	var offers := StructureCatalog.ids()
	structure_offer = offers[rng.randi_range(0, offers.size() - 1)] if rng.randf() < OFFER_CHANCE else &""
	stock.clear()
	var ids := factors.keys()
	ids.sort()
	while stock.size() < STOCK_SIZE and not ids.is_empty():
		stock.append(String(ids.pop_at(rng.randi_range(0, ids.size() - 1))))


## What a customer of the Pill Stall pays today for one pill (0 = not a pill).
func shop_price(id: String) -> int:
	if ItemCatalog.kind_of(id) != ItemCatalog.Kind.PILL:
		return 0
	return maxi(1, floori(float(ItemCatalog.base_value(id)) * float(pill_factors.get(id, 1.0))))


func factor(id: String) -> float:
	return float(factors.get(id, 1.0)) if ItemCatalog.kind_of(id) == ItemCatalog.Kind.MATERIAL else 1.0


func can_buy(id: String) -> bool:
	match ItemCatalog.kind_of(id):
		ItemCatalog.Kind.PILL:
			return ItemCatalog.pill_type(id) == &"cultivation"       # the rest is made by the Producer
		ItemCatalog.Kind.STRUCTURE:
			return structure_offer != &"" and id == ItemCatalog.structure_item_id(structure_offer)
		ItemCatalog.Kind.BLUEPRINT:
			return false
	return stock.has(id)


func buy_price(id: String) -> int:
	var value := float(ItemCatalog.base_value(id)) * factor(id)
	if ItemCatalog.kind_of(id) == ItemCatalog.Kind.MATERIAL:
		return maxi(1, ceili(value * MARKUP))
	return int(value)


## 0 = the Trader does not buy this (everything but materials).
func sell_price(id: String) -> int:
	if ItemCatalog.kind_of(id) != ItemCatalog.Kind.MATERIAL:
		return 0
	return floori(float(ItemCatalog.base_value(id)) * factor(id) * SELL_RATE)


func buy(state: GameState, id: String) -> bool:
	if not can_buy(id) or not state.spend_money(buy_price(id)):
		return false
	state.add_item(id)
	if ItemCatalog.kind_of(id) == ItemCatalog.Kind.STRUCTURE:
		structure_offer = &""
	return true


func sell(state: GameState, id: String) -> bool:
	var price := sell_price(id)
	if price <= 0 or not state.remove_item(id):
		return false
	state.add_money(price)
	return true


func to_dict() -> Dictionary:
	return {"factors": factors.duplicate(), "stock": stock.duplicate(), "offer": String(structure_offer),
		"pill_factors": pill_factors.duplicate()}


static func from_dict(d: Dictionary) -> Market:
	var m := Market.new()
	for id in d["factors"]:
		m.factors[String(id)] = float(d["factors"][id])
	for id in d["stock"]:
		m.stock.append(String(id))
	m.structure_offer = StringName(d.get("offer", ""))
	for id in d.get("pill_factors", {}):
		m.pill_factors[String(id)] = float(d["pill_factors"][id])
	return m
