class_name Market
extends RefCounted
## The Trader's market (gdd_overworld §8, §11 Phase 1): every material has a price factor that
## drifts a little each night, a few materials are in stock today. Buy low, sell high — the
## spread (buy x1.25, sell x0.8) means only real price swings pay. Cultivation pills are always
## on sale at a fixed price and are never bought back (money buys speed, never exclusive power, §9.4).
## Headless; the state it trades with is passed in.

const MARKUP := 1.25
const SELL_RATE := 0.8
const STOCK_SIZE := 5
const FACTOR_MIN := 0.6
const FACTOR_MAX := 1.5
const FACTOR_STEP := 0.2

var factors := {}                   # material id -> price factor
var stock: Array[String] = []       # materials for sale today


static func create(tier: int, rng: RandomNumberGenerator) -> Market:
	var m := Market.new()
	for id in ItemCatalog.materials_of_tier(tier):
		m.factors[id] = rng.randf_range(0.8, 1.2)
	m._restock(rng)
	return m


## The night: prices drift, the stock changes.
func new_day(rng: RandomNumberGenerator) -> void:
	var ids := factors.keys()
	ids.sort()
	for id in ids:
		factors[id] = clampf(float(factors[id]) + rng.randf_range(-FACTOR_STEP, FACTOR_STEP), FACTOR_MIN, FACTOR_MAX)
	_restock(rng)


func _restock(rng: RandomNumberGenerator) -> void:
	stock.clear()
	var ids := factors.keys()
	ids.sort()
	while stock.size() < STOCK_SIZE and not ids.is_empty():
		stock.append(String(ids.pop_at(rng.randi_range(0, ids.size() - 1))))


func factor(id: String) -> float:
	return float(factors.get(id, 1.0)) if ItemCatalog.kind_of(id) == ItemCatalog.Kind.MATERIAL else 1.0


func can_buy(id: String) -> bool:
	return ItemCatalog.kind_of(id) == ItemCatalog.Kind.PILL or stock.has(id)


func buy_price(id: String) -> int:
	var value := float(ItemCatalog.base_value(id)) * factor(id)
	if ItemCatalog.kind_of(id) == ItemCatalog.Kind.PILL:
		return int(value)
	return maxi(1, ceili(value * MARKUP))


## 0 = the Trader does not buy this (pills).
func sell_price(id: String) -> int:
	if ItemCatalog.kind_of(id) == ItemCatalog.Kind.PILL:
		return 0
	return floori(float(ItemCatalog.base_value(id)) * factor(id) * SELL_RATE)


func buy(state: GameState, id: String) -> bool:
	if not can_buy(id) or not state.spend_money(buy_price(id)):
		return false
	state.add_item(id)
	return true


func sell(state: GameState, id: String) -> bool:
	var price := sell_price(id)
	if price <= 0 or not state.remove_item(id):
		return false
	state.add_money(price)
	return true


func to_dict() -> Dictionary:
	return {"factors": factors.duplicate(), "stock": stock.duplicate()}


static func from_dict(d: Dictionary) -> Market:
	var m := Market.new()
	for id in d["factors"]:
		m.factors[String(id)] = float(d["factors"][id])
	for id in d["stock"]:
		m.stock.append(String(id))
	return m
