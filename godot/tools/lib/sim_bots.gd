extends RefCounted
## Move policies for simulation runs. Like AiBrain they are players, not rules: they only take
## actions from `AiBrain.candidates` (all legal) and apply them through `Battle.apply`.
## Use it through `const Bots := preload("res://tools/lib/sim_bots.gd")`.
##
##   greedy  AiBrain itself, as the game plays it: one-step lookahead on a copy of the battle;
##           with AP left and nothing better to do it walks toward the nearest enemy
##           (`hunt` is the same bot under its name in simulation S011)
##   wait    AiBrain as it was up to S011: ends the turn instead of walking up
##   careful greedy with the switch `ai_careful`: it counts the Strike damage enemies can bring to
##           each of its monsters before their next turn and avoids squares where that is lethal
##   chase   like greedy, but walks up only while its side is not ahead in total HP (the side that is
##           ahead waits for late-round pressure, the other one has to come)
##   plan    AiBrain's evaluation, but the best few first actions are judged together with
##           the best second action of the same turn (set a trap, then push into it)
##   rush    hit whoever is in a Strike shape, else cast, else walk toward the nearest enemy
##   kite    like rush, but backs away from an enemy that is 2 squares or closer
##   random  a random legal action, stops with 15 % chance
##
## All four are crude: none plans ahead, refreshes timed effects on purpose, targets props or
## uses tamer skills. Their results are flow indications, never balance evidence.

const NAMES: Array[String] = ["greedy", "hunt", "careful", "wait", "chase", "plan", "rush", "kite", "random"]
## plan: how many first actions are looked at one action further.
const PLAN_BEAM := 6
const MAX_ACTIONS_PER_TURN := 8
const KITE_DISTANCE := 2
const KITE_STRIKE_DISTANCE := 3
const RANDOM_STOP := 0.15


static func play_turn(bot: String, b: Battle, rng: RandomNumberGenerator) -> void:
	BattleExperiment.ai_hunt = bot != "wait"                        # only `wait` ends a turn instead of walking up
	BattleExperiment.ai_hunt_behind = bot == "chase"
	BattleExperiment.ai_careful = bot == "careful"
	if bot == "greedy" or bot == "hunt" or bot == "careful" or bot == "wait" or bot == "chase":
		AiBrain.play_turn(b, b.turn_owner, rng)
		return
	var owner := b.turn_owner
	var entry := b.queue_idx
	var round_no := b.round_number
	var moved := false
	var guard := 0
	while not b.over and b.turn_owner == owner and b.queue_idx == entry and b.round_number == round_no and guard < MAX_ACTIONS_PER_TURN:
		guard += 1
		var a := _decide(bot, b, rng, moved)
		if a["type"] == &"end_turn":
			break
		moved = moved or _is_move(b, a)
		b.apply(a)
	if not b.over and b.turn_owner == owner and b.queue_idx == entry and b.round_number == round_no:
		b.end_turn()


static func _decide(bot: String, b: Battle, rng: RandomNumberGenerator, moved: bool) -> Dictionary:
	if b.active() == null:
		return {"type": &"end_turn"}
	match bot:
		"plan":
			return _plan(b, rng)
		"rush":
			return _rush(b, rng, moved)
		"kite":
			return _kite(b, rng, moved)
	return _random(b, rng)


static func _kind(b: Battle, a: Dictionary) -> String:
	if a["type"] == &"step":
		return BattleSkillDef.MOVE
	return b.skill_in_slot(b.active(), int(a["slot"])).kind


static func _is_move(b: Battle, a: Dictionary) -> bool:
	return a["type"] == &"step" or (a["type"] == &"skill" and _kind(b, a) == BattleSkillDef.MOVE)


static func _cost(b: Battle, a: Dictionary) -> int:
	return BattleMoves.step_ap() if a["type"] == &"step" else b.skill_in_slot(b.active(), int(a["slot"])).cost()


## Squares an attack covers: the Strike shape or the Surge footprint.
static func _cells(b: Battle, a: Dictionary) -> Array[Vector2i]:
	var u := b.active()
	var s := b.skill_in_slot(u, int(a["slot"]))
	var out: Array[Vector2i] = []
	if s.kind == BattleSkillDef.STRIKE:
		for h in StrikeShapes.hits(StringName(s.strike_shape), a.get("dir", Vector2i.ZERO)):
			out.append(a.get("origin", u.pos) + h["o"])
	else:
		out = BattleCasting.cells(u, s, a.get("anchor", u.pos), int(a.get("rot", 0)))
	return out


## Enemies covered count 2, own monsters -3 (each monster once).
static func _cover_score(b: Battle, a: Dictionary) -> int:
	var u := b.active()
	var seen := {}
	var score := 0
	for c in _cells(b, a):
		var t := b.any_unit_at(c)
		if t == null or t.id == u.id or seen.has(t.id):
			continue
		seen[t.id] = true
		score += 2 if t.side != u.side else -3
	return score


## Board distance (Chebyshev, gdd_battle) from `from` to the nearest enemy.
static func _nearest_enemy_distance(b: Battle, side: int, from: Vector2i) -> int:
	var best := 99
	for e in b.living(1 - side):
		best = mini(best, e.chebyshev_to(from))
	return best


## Walking distance to the nearest enemy. Walking is cardinal in the engine, so a single step
## on an exact diagonal changes this but not the board distance: movement is ranked by it,
## otherwise a monster with Movement 1 would never leave a diagonal.
static func _nearest_enemy_walk(b: Battle, side: int, from: Vector2i) -> int:
	var best := 99
	for e in b.living(1 - side):
		best = mini(best, e.manhattan_to(from))
	return best


static func _pick(list: Array[Dictionary], rng: RandomNumberGenerator) -> Dictionary:
	return list[rng.randi_range(0, list.size() - 1)]


static func _best_cover(b: Battle, cands: Array[Dictionary], kind: String, rng: RandomNumberGenerator) -> Dictionary:
	var best: Array[Dictionary] = []
	var top := 0
	for a in cands:
		if a["type"] != &"skill" or _kind(b, a) != kind:
			continue
		var score := _cover_score(b, a)
		if score > top:
			top = score
			best = [a]
		elif score == top and top > 0:
			best.append(a)
	return {} if best.is_empty() else _pick(best, rng)


## Zones, board skills and self buffs: the one that improves AiBrain's position score most.
static func _best_utility(b: Battle, cands: Array[Dictionary], rng: RandomNumberGenerator) -> Dictionary:
	var side := b.active().side
	var base := AiBrain.evaluate(b, side)
	var best: Array[Dictionary] = []
	var top := AiBrain.MIN_GAIN
	for a in cands:
		if a["type"] != &"skill" or not [BattleSkillDef.ZONE, BattleSkillDef.GROUND, BattleSkillDef.BUFF].has(_kind(b, a)):
			continue
		var sim := b.clone()
		if not sim.apply(a):
			continue
		var gain := AiBrain.evaluate(sim, side) - base
		if gain > top + 0.001:
			top = gain
			best = [a]
		elif absf(gain - top) <= 0.001 and not best.is_empty():
			best.append(a)
	return {} if best.is_empty() else _pick(best, rng)


## The movement that ends nearest to (`toward` true) or farthest from the nearest enemy, by
## walking distance; an empty Dictionary if no destination beats standing still. Cheaper
## movement wins ties.
static func _best_move(b: Battle, cands: Array[Dictionary], toward: bool, rng: RandomNumberGenerator) -> Dictionary:
	var u := b.active()
	var here := _nearest_enemy_walk(b, u.side, u.pos)
	var best: Array[Dictionary] = []
	var top := here
	var top_cost := 99
	for a in cands:
		if not _is_move(b, a):
			continue
		var d := _nearest_enemy_walk(b, u.side, a["to"])
		if (toward and d >= here) or (not toward and d <= here):
			continue
		var cost := _cost(b, a)
		var further := d < top if toward else d > top
		if best.is_empty() or further or (d == top and cost < top_cost):
			top = d
			top_cost = cost
			best = [a]
		elif d == top and cost == top_cost:
			best.append(a)
	return {} if best.is_empty() else _pick(best, rng)


static func _rush(b: Battle, rng: RandomNumberGenerator, moved: bool) -> Dictionary:
	var cands := AiBrain.candidates(b)
	var a := _best_cover(b, cands, BattleSkillDef.STRIKE, rng)
	if a.is_empty():
		a = _best_utility(b, cands, rng)
	if a.is_empty():
		a = _best_cover(b, cands, BattleSkillDef.SURGE, rng)
	if a.is_empty() and not moved:
		a = _best_move(b, cands, true, rng)
	return a if not a.is_empty() else {"type": &"end_turn"}


static func _kite(b: Battle, rng: RandomNumberGenerator, moved: bool) -> Dictionary:
	var u := b.active()
	var cands := AiBrain.candidates(b)
	var distance := _nearest_enemy_distance(b, u.side, u.pos)
	if distance <= KITE_STRIKE_DISTANCE:
		var strike := _best_cover(b, cands, BattleSkillDef.STRIKE, rng)
		if not strike.is_empty():
			return strike
	var a := _rush(b, rng, moved)
	if _is_move(b, a) and distance <= KITE_DISTANCE:
		var away := _best_move(b, cands, false, rng)
		return away if not away.is_empty() else {"type": &"end_turn"}
	return a


## One action group (Step, or one skill slot) at random, then one of its legal uses.
static func _random(b: Battle, rng: RandomNumberGenerator) -> Dictionary:
	var groups := {}
	for a in AiBrain.candidates(b):
		var key: int = -1 if a["type"] == &"step" else int(a["slot"])
		if not groups.has(key):
			groups[key] = [] as Array[Dictionary]
		groups[key].append(a)
	if groups.is_empty() or rng.randf() < RANDOM_STOP:
		return {"type": &"end_turn"}
	var keys := groups.keys()
	keys.sort()
	var list: Array[Dictionary] = groups[keys[rng.randi_range(0, keys.size() - 1)]]
	return _pick(list, rng)


## Two actions of one turn judged together: the PLAN_BEAM best first actions by AiBrain's
## evaluation are each followed by their best second action; the first action of the best
## pair is played. Still no look at the opponent's reply.
static func _plan(b: Battle, rng: RandomNumberGenerator) -> Dictionary:
	var u := b.active()
	var side := u.side
	var base := AiBrain.evaluate(b, side)
	var firsts: Array = []                    # [gain, action, battle after it]
	for a in AiBrain.candidates(b):
		var sim := b.clone()
		if sim.apply(a, true):
			firsts.append([AiBrain.evaluate(sim, side) - base, a, sim])
	if firsts.is_empty():
		return {"type": &"end_turn"}
	firsts.sort_custom(func(x: Array, y: Array) -> bool: return x[0] > y[0])
	# setting a trap gains little by itself, so the best trap casts always
	# get their second action looked at
	var looked: Array = firsts.slice(0, PLAN_BEAM)
	var traps := 0
	for i in range(PLAN_BEAM, firsts.size()):
		if true:
			var fa: Dictionary = firsts[i][1]
			if traps < PLAN_BEAM and fa["type"] == &"skill" and b.skill_in_slot(u, int(fa["slot"])).kind == BattleSkillDef.TRAP:
				looked.append(firsts[i])
				traps += 1
	firsts = looked
	var best: Array[Dictionary] = []
	var best_total := AiBrain.MIN_GAIN
	for i in firsts.size():
		var total: float = firsts[i][0]
		var after: Battle = firsts[i][2]
		if not after.over and after.turn_owner == b.turn_owner and after.queue_idx == b.queue_idx and after.round_number == b.round_number:
			var follow := 0.0
			for a2 in AiBrain.candidates(after):
				var sim2 := after.clone()
				if sim2.apply(a2, true):
					follow = maxf(follow, AiBrain.evaluate(sim2, side) - base - total)
			total += follow
		if total > best_total + 0.001:
			best_total = total
			best = [firsts[i][1]]
		elif absf(total - best_total) <= 0.001 and not best.is_empty():
			best.append(firsts[i][1])
	if best.is_empty():
		return {"type": &"end_turn"}
	return best[rng.randi_range(0, best.size() - 1)]
