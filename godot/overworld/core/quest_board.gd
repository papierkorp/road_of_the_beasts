class_name QuestBoard
extends RefCounted
## The requests of the factions (gdd_overworld §8.2 "earn: quests"): deliver items, get favor and
## some money. Each faction keeps a few open requests; they expire after a few days — never forcing
## anything (§7 "nothing time-critical"). Headless; works on a GameState.
##
## A quest is {uid, faction, item, count, favor, money, days}.

const PER_FACTION := 3
const MIN_DAYS := 3
const MAX_DAYS := 5


static func make(faction: StringName, tier: int, uid: int, rng: RandomNumberGenerator) -> Dictionary:
	var item := ""
	var count := 1
	var favor := 3
	var money := 0
	match faction:
		FactionCatalog.FAMILY:
			# power for the clan's disciples: cultivation pills, beast parts
			if rng.randf() < 0.5:
				item = ItemCatalog.pill_id(tier)
				count = rng.randi_range(1, 2)
			else:
				item = _random_material(tier, rng)
				count = rng.randi_range(2, 3)
			favor = 4 + count
		FactionCatalog.GUILD:
			item = _random_material(tier, rng)
			count = rng.randi_range(3, 5)
			favor = 2 + count / 2
			money = floori(float(ItemCatalog.base_value(item)) * count * 1.25)
		_:
			# the watch: healing pills first, fighting materials otherwise
			if rng.randf() < 0.6:
				item = ItemCatalog.healing_pill_id(tier)
				count = rng.randi_range(1, 3)
			else:
				var aspect: Aspect.Type = [Aspect.Type.FORCE, Aspect.Type.DARK][rng.randi_range(0, 1)]
				item = ItemCatalog.material_id(MonsterDef.Kin.values()[rng.randi_range(0, 5)], aspect, tier)
				count = rng.randi_range(2, 3)
			favor = 3 + count
			money = floori(float(ItemCatalog.base_value(item)) * count * 0.5)
	return {"uid": uid, "faction": String(faction), "item": item, "count": count, "favor": favor,
		"money": money, "days": rng.randi_range(MIN_DAYS, MAX_DAYS)}


static func _random_material(tier: int, rng: RandomNumberGenerator) -> String:
	var all := ItemCatalog.materials_of_tier(tier)
	return all[rng.randi_range(0, all.size() - 1)]


## Tops every faction up to PER_FACTION open requests.
static func fill(state: GameState, rng: RandomNumberGenerator) -> void:
	for f in FactionCatalog.ids():
		var open := 0
		for q in state.quests:
			if StringName(q["faction"]) == f:
				open += 1
		while open < PER_FACTION:
			state.quests.append(make(f, int(state.stage), state.take_quest_uid(), rng))
			open += 1


## One night: every request has a day less, expired ones are dropped, then the board is refilled.
static func night(state: GameState, rng: RandomNumberGenerator) -> void:
	var keep: Array[Dictionary] = []
	for q in state.quests:
		q["days"] = int(q["days"]) - 1
		if int(q["days"]) > 0:
			keep.append(q)
	state.quests = keep
	fill(state, rng)


static func text(q: Dictionary) -> String:
	var parts: Array[String] = ["%d × %s" % [int(q["count"]), ItemCatalog.display_name(String(q["item"]))]]
	var reward := "%d favor" % int(q["favor"])
	if int(q["money"]) > 0:
		reward += ", %d spirit stones" % int(q["money"])
	return "Deliver %s — reward %s — %d day(s) left" % [parts[0], reward, int(q["days"])]
