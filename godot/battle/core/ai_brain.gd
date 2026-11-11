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


## Every legal action of the active unit except ending the turn.
static func candidates(b: Battle) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var u := b.active()
	if u == null:
		return out
	if b.ap >= BattleMoves.STEP_AP:
		for to: Vector2i in BattleMoves.options(b, u, BattleMoves.step_profile()):
			out.append({"type": &"step", "to": to})
	for slot in u.sheet.skills.size():
		var s := u.sheet.skills[slot]
		if not s.is_active() or b.ap < s.cost() or b.usage_error(u, slot) != "":
			continue
		match s.kind:
			BattleSkillDef.MOVE:
				for to: Vector2i in BattleMoves.options(b, u, BattleMoves.profile_of(s)):
					out.append({"type": &"skill", "slot": slot, "to": to})
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
			BattleSkillDef.SURGE, BattleSkillDef.ZONE, BattleSkillDef.GROUND:
				var dirs: Array[Vector2i] = [Vector2i.ZERO]
				if s.needs_direction():
					dirs = Board.CARDINAL
				var rots := [0, 1, 2, 3] if BattleStats.can_rotate(u) and s.anchor_mode != "caster_ring" and s.anchor_mode != "trail" else [0]
				for rot: int in rots:
					for anchor in BattleCasting.anchors(b, u, s, dirs[0], rot):
						if not _near_someone(b, BattleCasting.cells(u, s, anchor, rot)):
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


static func _near_someone(b: Battle, cells: Array[Vector2i]) -> bool:
	for u in b.living():
		for c in cells:
			if u.chebyshev_to(c) <= PLACEMENT_RADIUS:
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
	# pending Surges: whoever stands in one is in danger
	for s in b.surges:
		for c in s.cells:
			var t := b.unit_at(c, Board.GROUND)
			if t == null:
				continue
			var weight := float(mini(s.skill.surge_damage, t.hp)) * 2.5
			score += weight if t.side != side else -weight * 1.3
	for u in b.living():
		var sgn := 1.0 if u.side == side else -1.0
		# standing on harm at the next start or end of turn
		var harm := BattleDamage.ground_harm(b, u, GroundTrigger.END_OF_TURN, u.cells()) \
			+ BattleDamage.ground_harm(b, u, GroundTrigger.START_OF_TURN, u.cells())
		score -= sgn * 3.0 * harm
		for c in BattleStats.contributions(b, u):
			match String(c["tag"]):
				"slow", "drain_init", "drain_range":
					score -= sgn * 1.5 * float(c["value"])
				"haste", "quicken", "extend", "shield":
					score += sgn * 1.0 * float(c["value"])
				"mend":
					if u.hp < u.max_hp:
						score += sgn * 2.0
	# close the distance: every own unit wants an enemy within reach of its kit
	for u in mine:
		var nearest := 99
		for e in theirs:
			nearest = mini(nearest, e.chebyshev_to(u.pos))
		score -= 0.6 * nearest
	return score


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
		if not sim.apply(a):
			continue
		var gain := evaluate(sim, u.side) - base
		if gain > best_gain + 0.001:
			best_gain = gain
			best = [a]
		elif absf(gain - best_gain) <= 0.001 and not best.is_empty():
			best.append(a)
	if best.is_empty():
		return {"type": &"end_turn"}
	return best[rng.randi_range(0, best.size() - 1)]


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
