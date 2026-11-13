class_name AiBrain
extends RefCounted
## A simple opponent. It is a player, not a rule: it only reads the battle, asks `Battle.check`
## what is legal and judges each candidate by simulating it on a copy (`Battle.clone`), so it
## can never do anything the rules would not allow and never needs rule knowledge of its own.
## The seeded generator only breaks ties between equally good actions.

const MAX_ACTIONS_PER_TURN := 8
## A skill placement is only simulated if its footprint comes this close to some monster.
const PLACEMENT_RADIUS := 1
const MIN_GAIN := 0.05
## Score points per point of damage a ready push would deal (real damage counts 10 per HP).
const PUSH_FOCUS := 4.0
## ai_hunt: score points an approaching move may cost.
const HUNT_TOLERANCE := 4.0
## Wellspring draft: score points for a held Wellspring and for a monster with two enemies around it
## (1 damage at the end of the round, if nothing changes until then; real damage counts 10).
const WELL_VALUE := 9.0
const FLANK_VALUE := 7.0
## delay_turn: a first action that gains less than this is not worth acting before the enemy.
const DELAY_GAIN := 3.0
## ai_careful: share of a monster's value that counts as lost while enemies can strike it down before
## its next turn, score points per point of non-lethal Strike damage in reach, and the weight of the
## same threat against enemy monsters.
const DANGER_LETHAL := 0.6
const DANGER_HIT := 3.5
const DANGER_ENEMY := 0.25


## Every legal action of the active unit except ending the turn.
static func candidates(b: Battle) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var u := b.active()
	if u == null:
		return out
	if b.ap >= BattleMoves.step_ap():
		var steps := BattleMoves.options(b, u, BattleMoves.step_profile())
		for to: Vector2i in steps:
			out.append({"type": &"step", "to": to, "path": steps[to]["path"]})
	for slot in u.sheet.skills.size():
		var s := u.sheet.skills[slot]
		if not s.is_active() or b.ap < s.cost() or b.usage_error(u, slot) != "":
			continue
		if s.kind == BattleExperiment.ai_no_kind[u.side]:
			continue                              # test switch: this side plays without the kind
		match s.kind:
			BattleSkillDef.MOVE:
				var moves := BattleMoves.options(b, u, BattleMoves.profile_of(s))
				for to: Vector2i in moves:
					out.append({"type": &"skill", "slot": slot, "to": to, "path": moves[to]["path"]})
			BattleSkillDef.STRIKE:
				var pushes: Array[Vector2i] = [Vector2i.ZERO]
				if s.kin_effect and KinRules.strike(u.kin()).get("push", false):
					pushes = Board.CARDINAL
				for origin in u.cells():
					for d in StrikeShapes.directions(StringName(s.strike_shape)):
						for pd in pushes:
							var a := {"type": &"skill", "slot": slot, "dir": d, "push_dir": pd, "origin": origin}
							if b.check(a) == "" and _strike_touches(b, u, s, origin, d):
								out.append(a)
			BattleSkillDef.SURGE, BattleSkillDef.TRAP, BattleSkillDef.ZONE, BattleSkillDef.GROUND:
				var dirs: Array[Vector2i] = [Vector2i.ZERO]
				if s.needs_direction():
					dirs = Board.CARDINAL
				var rots := [0, 1, 2, 3] if BattleStats.can_rotate(u) and s.anchor_mode != "caster_ring" and s.anchor_mode != "trail" else [0]
				var seen_shapes := {}
				for rot: int in rots:
					var shape_key := s.offsets(rot)
					shape_key.sort()
					if seen_shapes.has(shape_key):
						continue                  # this turn of the shape covers the same squares
					seen_shapes[shape_key] = true
					# a zone only matters on a monster; a trap or ground next to one
					var radius := 0 if s.kind == BattleSkillDef.ZONE or s.kind == BattleSkillDef.SURGE else PLACEMENT_RADIUS
					# a Surge is only worth casting on an enemy, a trap next to one
					var whom := 1 - u.side if s.is_marker() else -1
					for anchor in BattleCasting.anchors(b, u, s, dirs[0], rot):
						if not _near_someone(b, BattleCasting.cells(u, s, anchor, rot), radius, whom):
							continue
						for d in dirs:
							out.append({"type": &"skill", "slot": slot, "anchor": anchor, "dir": d, "rot": rot})
			BattleSkillDef.BUFF:
				out.append({"type": &"skill", "slot": slot})
	return out


static func _strike_touches(b: Battle, u: BattleUnit, s: BattleSkillDef, origin: Vector2i, d: Vector2i) -> bool:
	for h in StrikeShapes.hits(StringName(s.strike_shape), d):
		var cell: Vector2i = origin + h["o"]
		var other := b.any_unit_at(cell)
		if (other != null and other.id != u.id) or b.board.prop_at(cell, Board.GROUND) != null or b.board.prop_at(cell, Board.AIR) != null:
			return true
	return false


static func _near_someone(b: Battle, cells: Array[Vector2i], radius := PLACEMENT_RADIUS, side := -1) -> bool:
	for u in b.living(side):
		for c in cells:
			if u.chebyshev_to(c) <= radius:
				return true
	return false


## How good the position is for `side` (higher is better). Plain heuristics, no rules.
static func evaluate(b: Battle, side: int) -> float:
	if b.over:
		if b.draw:
			return -50.0
		return 1000.0 if b.winner_side == side else -1000.0
	var score := 0.0
	var mine := b.living(side)
	var theirs := b.living(1 - side)
	for u in mine:
		score += 14.0 + 10.0 * u.hp
	for u in theirs:
		score -= 14.0 + 10.0 * u.hp
	# timed Surges threaten whoever stands in them; traps whoever stands next to them
	for s in b.surges:
		if s.turns_left >= 0:
			for c in s.cells:
				var t := b.unit_at(c, Board.GROUND)
				if t != null:
					var weight := float(mini(s.skill.surge_damage, t.hp)) * _timed_weight(b, s, t)
					score += weight if t.side != side else -weight * 1.3
			continue
		for c in s.ring:
			var t := b.unit_at(c, Board.GROUND)
			if t != null:
				var weight := float(mini(s.skill.surge_damage, t.hp)) * 0.5
				score += weight if t.side != side else -weight * 0.6
	for u in b.living():
		var sgn := 1.0 if u.side == side else -1.0
		score -= sgn * _standing_cost(b, u)
	# displacement: an enemy next to something that hurts when it is pushed there is a target,
	# an own unit in that spot a liability
	for u in theirs:
		score += _exposure(b, u, mine)
	for u in mine:
		score -= 0.5 * _exposure(b, u, theirs)
	# close the distance: every own unit wants an enemy within reach of its kit
	var closing := 1.5 if BattleExperiment.ai_aggressive else 0.6
	for u in mine:
		var nearest := 99
		for e in theirs:
			nearest = mini(nearest, e.chebyshev_to(u.pos))
		score -= closing * nearest
	if BattleExperiment.ai_careful:
		for u in b.living():
			var threat := _strike_threat(b, u)
			if threat <= 0:
				continue
			var cost := DANGER_LETHAL * (14.0 + 10.0 * u.hp) if threat >= u.hp else DANGER_HIT * threat
			score += -cost if u.side == side else cost * DANGER_ENEMY
	for p in BattleExperiment.well_squares(b.board.size):
		var holder := b.any_unit_at(p)
		if holder != null:
			score += WELL_VALUE if holder.side == side else -WELL_VALUE
	if BattleExperiment.flank:
		for u in b.living():
			var around := 0
			for e in b.living(1 - u.side):
				if e.chebyshev_to(u.pos) == 1:
					around += 1
			if around >= 2:
				score += -FLANK_VALUE if u.side == side else FLANK_VALUE
	return score


## Score points for how exposed `u` is to being pushed into harm by one of `pushers`: for each
## cardinal direction the damage a 1-square push would deal (board edge, prop, spiky prop,
## monster, fall, trap or Surge, hazard ground), weighted by how ready a pusher is: one standing
## on the opposite neighbour square (a Strike pushes straight away from the striker), one within
## two squares of it; with none near it counts nothing.
static func _exposure(b: Battle, u: BattleUnit, pushers: Array) -> float:
	if u.size != 1 or u.layer != Board.GROUND or BattleStats.is_immovable(b, u):
		return 0.0
	var total := 0.0
	var here := b.board.at(u.pos)
	for d in Board.CARDINAL:
		var harm := _push_harm(b, u, here, u.pos + d)
		if harm <= 0.0:
			continue
		var from := u.pos - d
		var ready := 0.0
		for p: BattleUnit in pushers:
			var dist := absi(p.pos.x - from.x) + absi(p.pos.y - from.y)
			if dist == 0:
				ready = 1.0
				break
			if dist <= 2:
				ready = 0.3
		total += PUSH_FOCUS * minf(harm, float(u.hp)) * ready
	return total


## Damage a 1-square push of `u` onto `to` would deal (0 if it would only move or be stopped).
static func _push_harm(b: Battle, u: BattleUnit, here: BoardCell, to: Vector2i) -> float:
	var cell := b.board.at(to) if b.board.in_bounds(to) else null
	if cell == null:
		return float(BattleDisplace.EDGE_DAMAGE)
	if cell.prop != null and cell.prop.hp > 0:
		return float(BattleDisplace.SPIKY_DAMAGE) if cell.prop.def.spiky else 1.0
	if b.unit_at(to, Board.GROUND) != null:
		return 1.0
	if cell.height > here.height:
		return 0.0
	var harm := 1.0 if cell.height < here.height else 0.0
	if cell.surge >= 0:
		var s := b.surge_by_id(cell.surge)
		if s != null:
			harm += float(s.skill.surge_damage) * (1.0 if s.turns_left < 0 else 0.6)
	var g := b.content.ground(cell.ground)
	if g != null and not BattleStats.ignores_ground(u, cell.ground):
		for t in g.triggers:
			if t.kind == "damage":
				harm += float(t.value_at(cell.level))
	return harm


## Weight per point of pending timed Surge damage: higher if the target has no turn left
## before the detonation within this round's queue (it cannot walk out by itself).
static func _timed_weight(b: Battle, s: PendingSurge, t: BattleUnit) -> float:
	if BattleExperiment.surge_at_caster:       # it fires at its caster's next entry: can the target move before?
		for i in range(b.queue_idx + 1, b.queue.size()):
			if b.queue[i]["id"] == t.id:
				return 2.5
			if b.queue[i]["id"] == s.owner:
				return 8.0
		return 2.5
	var last := b.queue_idx + s.turns_left + (1 if s.fresh else 0)
	if last >= b.queue.size():
		return 2.5                            # crosses the round end: the next order is unknown
	for i in range(b.queue_idx + (0 if b.turn_owner == t.id else 1), last + 1):
		if b.queue[i]["id"] == t.id:
			return 2.5
	return 8.0


## What standing where it stands costs `u` (harm at its next turn start / end, hindering and
## helping effects), in score points. 1x1 ground units take a direct look at their square;
## other bodies use the general (slower) stat functions.
static func _standing_cost(b: Battle, u: BattleUnit) -> float:
	var cost := 0.0
	if u.size != 1 or u.layer != Board.GROUND:
		var harm := BattleDamage.ground_harm(b, u, GroundTrigger.END_OF_TURN, u.cells()) \
			+ BattleDamage.ground_harm(b, u, GroundTrigger.START_OF_TURN, u.cells())
		cost += 3.0 * harm
		for c in BattleStats.contributions(b, u):
			cost += _tag_cost(String(c["tag"]), float(c["value"]), u)
		return cost
	var cell := b.board.at(u.pos)
	var g := b.content.ground(cell.ground)
	if g != null and not BattleStats.ignores_ground(u, cell.ground):
		for t in g.triggers:
			if t.timing != GroundTrigger.ON_ENTER:
				cost += (3.0 if t.kind == "damage" else -3.0) * t.value_at(cell.level)
		for e in g.effects:
			cost += _tag_cost(e.tag, float(e.value_at(cell.level)), u)
	if cell.zone != null and cell.prop == null:
		for e in cell.zone.def.effects:
			if e.affects_ground:
				cost += _tag_cost(e.tag, float(e.value_at(cell.zone.level)), u)
	for d in Board.CARDINAL:
		var n := b.board.at(u.pos + d)
		if n != null and n.prop != null and n.prop.hp > 0:
			for e in n.prop.def.aura:
				cost += _tag_cost(e.tag, float(e.value_at(1)), u)
	for fx in u.effects:
		cost += _tag_cost(String(fx["tag"]), float(fx["value"]), u)
	return cost


static func _tag_cost(tag: String, value: float, u: BattleUnit) -> float:
	match tag:
		"slow", "drain_init", "drain_range":
			return 1.5 * value
		"haste", "quicken", "extend", "shield":
			return (-0.3 if BattleExperiment.ai_aggressive else -1.0) * value
		"mend":
			return -2.0 if u.hp < u.max_hp else 0.0
	return 0.0


## The best action for the active unit ({type: &"end_turn"} if nothing helps).
static func decide(b: Battle, rng: RandomNumberGenerator) -> Dictionary:
	var u := b.active()
	if u == null:
		return {"type": &"end_turn"}
	var base := evaluate(b, u.side)
	var best: Array[Dictionary] = []
	var best_gain := MIN_GAIN
	for a in candidates(b):
		var sim := b.clone()
		if not sim.apply(a, true):
			continue
		var gain := evaluate(sim, u.side) - base
		if gain > best_gain + 0.001:
			best_gain = gain
			best = [a]
		elif absf(gain - best_gain) <= 0.001 and not best.is_empty():
			best.append(a)
	if BattleExperiment.delay_turn and (best.is_empty() or best_gain < DELAY_GAIN) and b.check({"type": &"delay"}) == "" and _enemy_acts_later(b, u.side):
		return {"type": &"delay"}
	if best.is_empty() and BattleExperiment.ai_hunt:
		best = _approach(b, u, base)
	if best.is_empty():
		return {"type": &"end_turn"}
	return best[rng.randi_range(0, best.size() - 1)]


## Test switch `ai_hunt`: the movement actions that bring the active unit closest to an enemy
## (walking distance), as long as the position does not get worse by more than HUNT_TOLERANCE
## score points (about one point of hazard-ground damage; never a sprung trap). Empty if the
## unit already stands next to an enemy or cannot get closer.
static func _approach(b: Battle, u: BattleUnit, base: float) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var best_dist := _walk_to_enemy(b, u.side, u.pos)
	if best_dist <= 1:
		return out
	if BattleExperiment.ai_hunt_behind:
		var hp := [0, 0]
		for lu in b.living():
			hp[lu.side] += lu.hp
		if hp[u.side] > hp[1 - u.side]:
			return out                        # ahead: let the other side come
	var best_gain := -HUNT_TOLERANCE
	for a in candidates(b):
		if not a.has("to"):
			continue
		var sim := b.clone()
		if not sim.apply(a, true) or sim.over:
			continue
		var me: BattleUnit = sim.units[u.id]
		if not me.is_alive():
			continue
		var gain := evaluate(sim, u.side) - base
		if gain < -HUNT_TOLERANCE:
			continue
		var dist := _walk_to_enemy(sim, u.side, me.pos)
		if dist < best_dist or (dist == best_dist and not out.is_empty() and gain > best_gain + 0.001):
			best_dist = dist
			best_gain = gain
			out = [a]
		elif dist == best_dist and not out.is_empty() and absf(gain - best_gain) <= 0.001:
			out.append(a)
	return out


## Strike damage the enemies of `u` can bring to it with the turns of one round: each enemy with a
## Strike walks up (a movement skill covers its Movement per AP, Steps 1 square) and strikes with
## the AP that are left. A rough count: no Surges, no pushes, no blocked paths, no turn borders.
static func _strike_threat(b: Battle, u: BattleUnit) -> int:
	var total := 0
	for e in b.living(1 - u.side):
		var strike: BattleSkillDef = null
		var stride := 1
		for s in e.sheet.skills:
			if s.kind == BattleSkillDef.STRIKE and s.strike_damage > 0 and (strike == null or s.cost() < strike.cost()):
				strike = s
			elif s.kind == BattleSkillDef.MOVE and not BattleStats.is_rooted(e):
				stride = maxi(stride, maxi(1, BattleStats.movement(b, e) + s.distance_mod) if s.fixed_distance <= 0 else s.fixed_distance)
		if strike == null:
			continue
		var turns := e.sheet.tpr if b.round_number >= BattleExperiment.tpr_from_round else 1
		var ap := BattleStats.ap(e) * turns
		var steps := maxi(0, e.manhattan_to(u.pos) - 1)
		if steps > 0 and BattleStats.is_rooted(e):
			continue
		ap -= int(ceil(float(steps) / stride))
		var hits := mini(ap / strike.cost(), turns * (BattleStats.ap(e) / strike.cost()))
		if hits > 0:
			total += hits * strike.strike_damage
	return total


static func _enemy_acts_later(b: Battle, side: int) -> bool:
	for i in range(b.queue_idx + 1, b.queue.size()):
		var e: BattleUnit = b.units[b.queue[i]["id"]]
		if e.side != side and e.is_alive():
			return true
	return false


static func _walk_to_enemy(b: Battle, side: int, from: Vector2i) -> int:
	var best := 99
	for e in b.living(1 - side):
		best = mini(best, e.manhattan_to(from))
	for p in BattleExperiment.well_squares(b.board.size):      # a free Wellspring is a goal too
		if b.any_unit_at(p) == null:
			best = mini(best, absi(p.x - from.x) + absi(p.y - from.y) + 1)
	return best


static func execute(b: Battle, _who: StringName, action: Dictionary) -> bool:
	return b.apply(action)


## Plays the whole turn of the active unit (`who` is kept for callers that pass the owner).
static func play_turn(b: Battle, _who: StringName, rng: RandomNumberGenerator) -> void:
	var owner := b.turn_owner
	var entry := b.queue_idx
	var round_no := b.round_number
	var guard := 0
	while not b.over and b.turn_owner == owner and b.queue_idx == entry and b.round_number == round_no and guard < MAX_ACTIONS_PER_TURN:
		guard += 1
		var a := decide(b, rng)
		if a["type"] == &"end_turn":
			break
		b.apply(a)
	if not b.over and b.turn_owner == owner and b.queue_idx == entry and b.round_number == round_no:
		b.end_turn()
