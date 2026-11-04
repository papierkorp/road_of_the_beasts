class_name FactionCatalog
extends RefCounted
## The factions of the city and their favor (gdd_overworld §8.2). Favor is a currency, not a
## relationship system: a balance to spend, plus the lifetime "standing" that decides the rank.
## First step: your own family (which doesn't think much of you), the Merchants' Guild and the
## City Watch. Prototype numbers.

const FAMILY := &"family"
const GUILD := &"guild"
const WATCH := &"watch"

## Standing needed for rank 1, 2, 3.
const RANK_AT := [10, 30, 60]
const RANK_NAMES := ["Stranger", "Acquaintance", "Trusted", "Honored"]

const DATA := {
	&"family": {"name": "Your Family", "envoy": "Clan Envoy",
		"blurb": "The great clan you belong to — and which looks down on you. Earn its respect with power: pills and beast parts for its disciples. It lends you bloodlines."},
	&"guild": {"name": "Merchants' Guild", "envoy": "Guild Factor",
		"blurb": "Trade is the guild's life. Good standing brings discounts at the Trader and rare blueprints; it issues the Production License."},
	&"watch": {"name": "City Watch", "envoy": "Watch Captain",
		"blurb": "Keeps the peace and needs supplies: healing pills and fighting materials. It issues the Street Trade Permit and trains beasts for hire."},
}

## What favor buys in a shop: licenses (id -> faction, cost, name). A structure needs its license
## before it can be constructed or placed (see GameState.license_for).
const LICENSES := {
	&"production": {"faction": &"guild", "cost": 8, "name": "Production License"},
	&"street_trade": {"faction": &"watch", "cost": 6, "name": "Street Trade Permit"},
}

## A recruit (a monster for hire) costs this much favor of the faction offering it.
const RECRUIT_COST := 15
## The Trader's discount per guild rank (gdd_overworld §8.2 "spend: rare auction invites, ...").
const DISCOUNT_PER_RANK := 0.05


static func ids() -> Array[StringName]:
	return [FAMILY, GUILD, WATCH]


static func faction_name(id: StringName) -> String:
	return DATA[id]["name"]


static func envoy_name(id: StringName) -> String:
	return DATA[id]["envoy"]


static func blurb(id: StringName) -> String:
	return DATA[id]["blurb"]


static func rank_of(standing: int) -> int:
	var r := 0
	for need in RANK_AT:
		if standing >= int(need):
			r += 1
	return r


static func rank_name(rank: int) -> String:
	return RANK_NAMES[clampi(rank, 0, RANK_NAMES.size() - 1)]


## Standing missing for the next rank, or -1 at the top.
static func to_next_rank(standing: int) -> int:
	var r := rank_of(standing)
	return -1 if r >= RANK_AT.size() else int(RANK_AT[r]) - standing
