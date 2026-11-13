class_name BattleQueue
extends RefCounted
## The initiative queue of one round (gdd_battle §2.2). Recalculated every round; within a
## round it only changes through Urgent Order and Beast Swap.
##
## Entry: {id, init, base, side, slot, extra}. Order: effective initiative, then base
## initiative; still tied → the sides alternate (the first cross-side tie of a battle goes to
## the side with the lower total initiative, equal totals to the player); units of one side
## in slot order; an extra-turn entry follows its unit's main entry.

const EXTRA_TURN_PENALTY := 3.0
const PLAYER := 0


static func build(b: Battle) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	var totals := [0.0, 0.0]
	for id in b.roster:
		var u: BattleUnit = b.units[id]
		if not u.is_alive():
			continue
		var eff := BattleStats.initiative(b, u)
		totals[u.side] += eff
		var turns := 1 if b.round_number < BattleExperiment.tpr_from_round else u.sheet.tpr      # test switch
		for fx in u.effects:                      # experiment: one more turn while the effect lasts
			if fx["tag"] == FieldEffect.TEMPO:
				turns += int(fx["value"])
		for k in turns:
			entries.append({"id": id, "init": maxf(BattleStats.MIN_INITIATIVE, snappedf(eff - EXTRA_TURN_PENALTY * k, 0.1)),
				"base": u.sheet.initiative, "side": u.side, "slot": u.slot, "extra": k})
	entries.sort_custom(func(a: Dictionary, c: Dictionary) -> bool:
		if a["init"] != c["init"]:
			return a["init"] > c["init"]
		if a["base"] != c["base"]:
			return a["base"] > c["base"]
		if a["side"] != c["side"]:
			return a["side"] < c["side"]
		if a["slot"] != c["slot"]:
			return a["slot"] < c["slot"]
		return a["extra"] < c["extra"])
	var out: Array[Dictionary] = []
	var i := 0
	while i < entries.size():
		var j := i
		while j < entries.size() and entries[j]["init"] == entries[i]["init"] and entries[j]["base"] == entries[i]["base"]:
			j += 1
		out.append_array(_interleave(b, entries.slice(i, j), totals))
		i = j
	return out


## One tie group: both sides in slot order, alternating from the side holding the tie token.
static func _interleave(b: Battle, group: Array, totals: Array) -> Array[Dictionary]:
	var sides: Array = [[], []]
	for e: Dictionary in group:
		sides[e["side"]].append(e)
	var out: Array[Dictionary] = []
	if sides[0].is_empty() or sides[1].is_empty():
		out.assign(group)
		return out
	if b.tie_side < 0:
		b.tie_side = PLAYER if totals[0] <= totals[1] else 1
	while not sides[0].is_empty() or not sides[1].is_empty():
		var s := b.tie_side
		if sides[s].is_empty():
			s = 1 - s
		elif not sides[1 - s].is_empty():
			b.tie_side = 1 - b.tie_side      # a real cross-side tie was decided: the next one flips
		out.append(sides[s].pop_front())
	return out


## Position of a unit's main entry in the given queue (large = not in it).
static func rank_in(queue: Array[Dictionary], id: StringName) -> int:
	for i in queue.size():
		if queue[i]["id"] == id:
			return i
	return 9999
