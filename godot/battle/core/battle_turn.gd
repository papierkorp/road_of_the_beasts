class_name BattleTurn
extends RefCounted
## Turn and round flow (gdd_battle §2.1–§2.4, §4.2):
##   entry start: start-of-turn ground → AP
##   Surges: a trap fires when sprung, a timed Surge after its turns (between two turns)
##   entry end:   zone push/pull → end-of-turn ground (on the landing square) → mend
##   round end:   zones -1 round, timed unit effects expire, late-round Voidscar / arena
##                collapse, initiative re-sorted.


static func begin(b: Battle) -> void:
	b.queue = BattleQueue.build(b)
	b.queue_idx = 0
	b.emit(&"round_started", {"round": b.round_number, "queue": _queue_ids(b)})
	_start_entry(b)


static func _queue_ids(b: Battle) -> Array:
	var out := []
	for e in b.queue:
		out.append(e["id"])
	return out


## Starts the queue entry at `queue_idx`, skipping entries of units that are gone.
static func _start_entry(b: Battle) -> void:
	while not b.over:
		if b.queue_idx >= b.queue.size():
			_end_round(b)
			return
		var entry: Dictionary = b.queue[b.queue_idx]
		var u: BattleUnit = b.units[entry["id"]]
		b.turn_owner = u.id
		b.ap = 0
		if u.is_alive():
			# 1. start-of-turn ground (Voidscar, Blight); its damage cannot move anyone into a trap
			BattleDamage.ground_triggers(b, u, GroundTrigger.START_OF_TURN)
			if b.check_over():
				return
		if u.is_alive() and BattleExperiment.surge_at_caster:
			# test switch: the Surges this monster cast earlier detonate before it acts
			var due: Array[PendingSurge] = []
			for s in b.surges:
				if s.turns_left >= 0 and not s.fresh and s.owner == u.id:
					due.append(s)
			if not due.is_empty():
				detonate(b, due)
				spring_traps(b)
				if b.check_over():
					return
		if u.is_alive():
			# 2. AP
			b.ap = BattleStats.ap(u)
			b.entry_acted = false
			b.emit(&"turn_started", {"who": u.id, "ap": b.ap, "extra": entry["extra"]})
			return
		b.queue_idx += 1
	b.turn_owner = &""


## Test switch delay_turn: the running entry moves to the end of the queue; nothing of the turn has
## happened, so no end-of-turn effect and no timer runs. Start-of-turn ground triggers again later.
static func delay(b: Battle) -> void:
	var entry: Dictionary = b.queue.pop_at(b.queue_idx)
	entry["waited"] = true
	var at := b.queue.size()
	if BattleExperiment.delay_reverse or BattleExperiment.delay_first_round:
		for i in range(b.queue_idx, b.queue.size()):
			if b.queue[i].get("waited", false):
				at = i                            # before the monsters that postponed earlier
				break
	b.queue.insert(at, entry)
	b.delayed[entry["id"]] = b.round_number
	b.ap = 0
	b.emit(&"turn_delayed", {"who": entry["id"]})
	_start_entry(b)


## Trap Surges: every Surge with a ground monster on one of its squares, or (unless its skill
## is sprung by monsters only) with a prop or Mountain that was not there at cast, detonates
## now. Surges sprung at the same moment resolve together; a detonation can spring others.
static func spring_traps(b: Battle) -> void:
	var guard := 0
	while not b.over and guard < 16:
		guard += 1
		var due: Array[PendingSurge] = []
		for s in b.surges:
			if s.turns_left >= 0:
				continue                      # a timed Surge waits for its turns
			for c in s.cells:
				var cell := b.board.at(c)
				if b.unit_at(c, Board.GROUND) != null or (s.skill.trap_trigger == "any" and (cell.prop != null or cell.is_mountain()) and not s.blocked_at_cast.has(c)):
					due.append(s)
					break
		if due.is_empty():
			return
		detonate(b, due)
		b.check_over()


## Timed Surges count the turns that finish after their cast turn and detonate between two
## turns; all that are due at the same moment resolve together.
static func tick_timers(b: Battle) -> void:
	var due: Array[PendingSurge] = []
	for s in b.surges:
		if s.turns_left < 0:
			continue
		if s.fresh:
			s.fresh = false
			continue
		if BattleExperiment.surge_at_caster:
			continue                          # test switch: it waits for its caster's next turn
		s.acted[b.turn_owner] = true
		s.turns_left = maxi(0, s.turns_left - 1)
		if s.turns_left <= 0 and (not BattleExperiment.surge_fair or _all_acted(b, s)):
			due.append(s)
	if not due.is_empty():
		detonate(b, due)
		spring_traps(b)
		b.check_over()


## Test switch surge_fair: true if every living monster on the Surge's squares has finished a turn
## since it was cast.
static func _all_acted(b: Battle, s: PendingSurge) -> bool:
	for c in s.cells:
		var u := b.unit_at(c, Board.GROUND)
		if u != null and u.is_alive() and not s.acted.has(u.id):
			return false
	return true


## Detonates Surges that are due at the same event, phase by phase together.
static func detonate(b: Battle, due: Array[PendingSurge]) -> void:
	var payloads: Array = []
	for s in due:
		b.remove_surge(s)
		payloads.append(BattlePayload.surge(b, s))
	BattlePayload.resolve(b, payloads)


## Net zone displacement at turn end (gdd_battle §4.3): each zone contributes one cardinal
## direction, opposite directions cancel, and the body moves only if exactly one remains.
static func zone_step(b: Battle, u: BattleUnit) -> Vector2i:
	var sum := Vector2i.ZERO
	for z in BattleStats.zones_under(b, u):
		var push := z.def.effect(FieldEffect.PUSH)
		if push != null and push.affects_layer(u.layer):
			sum += z.dir
		var pull := z.def.effect(FieldEffect.PULL)
		if pull != null and pull.affects_layer(u.layer):
			sum += BattleDisplace.pull_dir(u, z.anchor)
	var d := Vector2i(signi(sum.x), signi(sum.y))
	return d if (d.x == 0) != (d.y == 0) else Vector2i.ZERO


static func end_turn(b: Battle) -> void:
	if b.over:
		return
	var u: BattleUnit = b.units.get(b.turn_owner)
	b.ap = 0
	if u != null and u.is_alive():
		b.emit(&"turn_ended", {"who": u.id})
		# 1. push / pull
		var d := zone_step(b, u)
		if d != Vector2i.ZERO:
			BattleDisplace.shove(b, u, d, "zone")
			BattlePayload.settle(b)
			spring_traps(b)
			if b.over:
				return
		# 1b. a repelling prop next to it pushes it 1 square away
		if u.is_alive() and u.size == 1 and u.layer == Board.GROUND:
			var away := Vector2i.ZERO
			for dir in Board.CARDINAL:
				var n := b.board.at(u.pos + dir)
				if n != null and n.prop != null and n.prop.hp > 0 and n.prop.def.repel:
					away -= dir
			if (away.x == 0) != (away.y == 0):
				BattleDisplace.shove(b, u, Vector2i(signi(away.x), signi(away.y)), "repel")
				BattlePayload.settle(b)
				spring_traps(b)
				if b.over:
					return
		# 2. end-of-turn ground on the squares covered now, 3. mend
		if u.is_alive():
			var mend: Array = []
			for z in BattleStats.zones_under(b, u):
				var e := z.def.effect(FieldEffect.MEND)
				if e != null and e.affects_layer(u.layer):
					mend.append({"unit": u.id, "amount": e.value_at(z.level), "source": z.def.display_name})
			if u.size > 1:
				# a 2x2 body nets mend with its same-timing ground triggers (gdd_battle §4.3)
				BattleDamage.ground_triggers(b, u, GroundTrigger.END_OF_TURN, [], mend)
			else:
				BattleDamage.ground_triggers(b, u, GroundTrigger.END_OF_TURN)
				if u.is_alive() and not mend.is_empty():
					BattleDamage.apply_round(b, [], mend)
		if b.check_over():
			return
	tick_timers(b)
	if b.over:
		return
	b.queue_idx += 1
	_start_entry(b)


static func _end_round(b: Battle) -> void:
	var ended := b.round_number
	# zones lose a round; expired zones are removed (no repaint)
	var faded := 0
	for cell in b.board.cells:
		if cell.zone != null:
			cell.zone.duration -= 1
			if cell.zone.duration <= 0:
				cell.zone = null
				faded += 1
	if faded > 0:
		b.emit(&"zones_faded", {"count": faded})
	# timed unit effects end at the round end of their N-th following round
	for id in b.roster:
		var u: BattleUnit = b.units[id]
		var keep: Array[Dictionary] = []
		for fx in u.effects:
			if int(fx["ends_round"]) > ended:
				keep.append(fx)
		u.effects = keep
	# ground that acts at the end of a round (gdd_battle §4.7), then Dragon Veins and surrounding
	for id in b.roster:
		var ru: BattleUnit = b.units[id]
		if ru.is_alive() and ru.on_field:
			BattleDamage.ground_triggers(b, ru, GroundTrigger.END_OF_ROUND)
	if b.check_over():
		return
	var held := _positional(b)
	if b.check_over():
		return
	_fade(b, ended)
	if BattleExperiment.pressure_mode == "always" or (BattleExperiment.pressure_mode == "idle" and held == 0):
		_late_pressure(b, ended)
	if b.check_over():
		return
	# remember the finished queue: orphaned Surges order their sources by it
	b.prev_queue = b.queue.duplicate(true)
	b.round_number += 1
	b.queue = BattleQueue.build(b)
	b.queue_idx = 0
	b.turn_owner = &""
	b.emit(&"round_started", {"round": b.round_number, "queue": _queue_ids(b)})
	if BattleExperiment.surge_at_caster:        # Surges of a caster that is gone detonate at the round start
		var orphans: Array[PendingSurge] = []
		for s in b.surges:
			var owner: BattleUnit = b.units.get(s.owner)
			if s.turns_left >= 0 and (owner == null or not owner.is_alive()):
				orphans.append(s)
		if not orphans.is_empty():
			detonate(b, orphans)
			spring_traps(b)
			if b.check_over():
				return
	_start_entry(b)


## Wellspring draft (test switches `wells` and `flank`, temp_todo T39): positional damage at the end
## of a round, all of it in one simultaneous step. Every Wellspring a monster stands on deals 1
## damage to the enemy nearest to the square; a monster with two or more enemies on its eight
## neighbour squares takes 1 damage. Returns how many Wellsprings are held.
static func _positional(b: Battle) -> int:
	var hits: Array = []
	var held := [0, 0]
	for p in BattleExperiment.well_squares(b.board.size):
		var holder := b.any_unit_at(p)
		var vein := b.board.at(p)
		if vein.ground != GroundDef.WELL:
			continue
		if holder != null:
			vein.owner_side = holder.side         # whoever stands on it has touched it
		var side := vein.owner_side if BattleExperiment.vein_touch else (holder.side if holder != null else -1)
		if side < 0:
			continue
		held[side] += 1
		var target := _well_target(b, p, side)
		if target != null:
			var hit := {"unit": target.id, "base": 1, "type": BattleDamage.WELL, "source": "Dragon Vein"}
			if holder != null and holder.side == side:
				hit["by"] = holder.id
			hits.append(hit)
	if BattleExperiment.flank:
		for u in b.living():
			var around := 0
			for e in b.living(1 - u.side):
				if e.chebyshev_to(u.pos) == 1:
					around += 1
			if around >= 2:
				hits.append({"unit": u.id, "base": 1, "type": BattleDamage.FLANK, "source": "Surrounded"})
	if BattleExperiment.wells > 0:
		b.emit(&"wells_held", {"held": held})
	if not hits.is_empty():
		BattleDamage.apply_round(b, hits)
		BattleDamage.defeat_step(b)
	return held[0] + held[1]


## The enemy a held Wellspring hits: nearest to the square (board distance), then more HP, then
## more initiative; a last tie is the holder's choice in the draft (here: roster order).
static func _well_target(b: Battle, p: Vector2i, side: int) -> BattleUnit:
	var best: BattleUnit = null
	for e in b.living(1 - side):
		if best == null:
			best = e
			continue
		var de := e.chebyshev_to(p)
		var db := best.chebyshev_to(p)
		if de != db:
			if de < db:
				best = e
		elif e.hp != best.hp:
			if e.hp > best.hp:
				best = e
		elif BattleStats.initiative(b, e) > BattleStats.initiative(b, best):
			best = e
	return best


## Test switches (BattleExperiment): ground laid during the battle and unsprung traps end with
## the round their clock names. Off by default: both stay until something changes them.
static func _fade(b: Battle, ended_round: int) -> void:
	if BattleExperiment.ground_rounds > 0:
		for cell in b.board.cells:
			if cell.ground_until > 0 and ended_round >= cell.ground_until:
				cell.ground = GroundDef.PLAIN
				cell.level = 1
				cell.ground_until = 0
				b.emit(&"ground_changed", {"pos": cell.pos, "ground": cell.ground, "level": 1, "result": &"faded", "source": "end of round"})
	if BattleExperiment.trap_rounds > 0:
		for s: PendingSurge in b.surges.duplicate():
			if s.turns_left < 0 and ended_round >= s.cast_round + BattleExperiment.trap_rounds - 1:
				b.remove_surge(s)
				b.emit(&"surge_lapsed", {"surge": s.id})


## Anti-stalling (gdd_battle §4.2): from the set round on, the free square farthest from all
## living monsters becomes Voidscar; equally far squares convert together. Once no free square
## is left, every living monster takes 1 damage per round.
static func _late_pressure(b: Battle, ended_round: int) -> void:
	if ended_round < b.voidscar_from:
		return
	if BattleExperiment.soft_pressure > 0:
		_soft_pressure(b, ended_round)
		return
	var alive := b.living()
	var best := -1
	var picks: Array[BoardCell] = []
	for cell in b.board.cells:
		var g := b.content.ground(cell.ground)
		if (g != null and g.immutable) or cell.prop != null:
			continue
		if b.board.unit_id_at(cell.pos, Board.GROUND) != &"" or b.board.unit_id_at(cell.pos, Board.AIR) != &"":
			continue
		var nearest := 1 << 20
		for u in alive:
			nearest = mini(nearest, u.chebyshev_to(cell.pos))
		if nearest > best:
			best = nearest
			picks = [cell]
		elif nearest == best:
			picks.append(cell)
	if not picks.is_empty():
		for cell in picks:
			cell.ground = b.voidscar_ground
			cell.ground_until = 0
			cell.level = 1
			b.emit(&"ground_changed", {"pos": cell.pos, "ground": cell.ground, "level": 1,
				"result": &"voidscar", "source": "Late-round pressure"})
		return
	var hits: Array = []
	for u in alive:
		hits.append({"unit": u.id, "base": 1, "type": BattleDamage.ARENA, "source": "Arena collapse"})
	BattleDamage.apply_round(b, hits)
	BattleDamage.defeat_step(b)


## Test switch (temp_todo T38): pressure without damage. Every `soft_pressure` rounds the
## outermost ring breaks away until 3×3 squares are left. Props on it vanish without aftermath,
## monsters on it are set on the nearest free inner square (no damage, no entry effects; a
## trap there springs). The new edge is a board edge: a push against it deals edge damage.
static func _soft_pressure(b: Battle, ended_round: int) -> void:
	if (ended_round - b.voidscar_from) % BattleExperiment.soft_pressure != 0:
		return
	var board := b.board
	var m := board.margin
	if board.size - 2 * (m + 1) < 3:
		return
	var stranded: Array[BattleUnit] = []
	for cell in board.cells:
		var p := cell.pos
		if not board.in_bounds(p) or (p.x > m and p.y > m and p.x < board.size - 1 - m and p.y < board.size - 1 - m):
			continue
		if cell.prop != null:
			board.remove_prop(cell.prop)
		if cell.air_prop != null:
			board.remove_prop(cell.air_prop)
		cell.zone = null
	for id in b.roster:
		var u: BattleUnit = b.units[id]
		if not u.is_alive():
			continue
		for c in u.cells():
			if c.x <= m or c.y <= m or c.x >= board.size - 1 - m or c.y >= board.size - 1 - m:
				stranded.append(u)
				b.lift(u)
				break
	board.margin = m + 1
	# markers lose the squares that broke away; one without squares is gone
	var kept: Array[PendingSurge] = []
	for s in b.surges:
		for list: Array[Vector2i] in [s.cells, s.air_cells, s.ring, s.blocked_at_cast]:
			for i in range(list.size() - 1, -1, -1):
				if not board.in_bounds(list[i]):
					list.remove_at(i)
		if not s.cells.is_empty() or not s.air_cells.is_empty():
			kept.append(s)
	b.surges = kept
	var centre := board.centre()
	for u in stranded:
		var best := Vector2i(-1, -1)
		var best_key := 1 << 20
		for pass_no in 2:                     # second pass: a prop makes room
			for cell in board.cells:
				var p := cell.pos
				if not board.in_bounds(p) or board.unit_id_at(p, u.layer) != &"":
					continue
				if pass_no == 0 and board.prop_at(p, u.layer) != null:
					continue
				var key := Board.chebyshev(p, u.pos) * 100 + Board.chebyshev(p, centre)
				if key < best_key:
					best_key = key
					best = p
			if best.x >= 0:
				break
		if best.x < 0:
			best = u.pos                      # no room at all (cannot happen on 3×3 with 6 monsters)
		var prop := board.prop_at(best, u.layer)
		if prop != null:
			board.remove_prop(prop)
		var from := u.pos
		b.put(u, best)
		b.emit(&"displaced", {"who": u.id, "from": from, "to": best, "cause": "Arena shrinks"})
	b.emit(&"arena_shrunk", {"margin": board.margin})
	spring_traps(b)
