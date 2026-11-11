class_name BattleTurn
extends RefCounted
## Turn and round flow (gdd_battle §2.1–§2.4, §4.2):
##   entry start: due Surges → start-of-turn ground → AP
##   entry end:   zone push/pull → end-of-turn ground (on the landing square) → mend
##   round end:   zones -1 round, timed unit effects expire, late-round Voidscar / arena
##                collapse, initiative re-sorted, orphaned Surges detonate before the new queue.


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
			# 1. due Surges of this caster, before anything else
			var due: Array[PendingSurge] = []
			for s in b.surges:
				if s.owner == u.id and not s.orphaned:
					due.append(s)
			if not due.is_empty():
				detonate(b, due)
				if b.check_over():
					return
		if u.is_alive():
			# 2. start-of-turn ground (Voidscar, Blight)
			BattleDamage.ground_triggers(b, u, GroundTrigger.START_OF_TURN)
			if b.check_over():
				return
		if u.is_alive():
			# 3. AP
			b.ap = BattleStats.ap(u)
			b.emit(&"turn_started", {"who": u.id, "ap": b.ap, "extra": entry["extra"]})
			return
		b.queue_idx += 1
	b.turn_owner = &""


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
	# orphaned Surges detonate together at the round start, before the queue
	var orphans: Array[PendingSurge] = []
	for s in b.surges:
		if s.orphaned:
			orphans.append(s)
	if not orphans.is_empty():
		detonate(b, orphans)
		if b.check_over():
			return
	_start_entry(b)


## Anti-stalling (gdd_battle §4.2): from the set round on, the free square farthest from all
## living monsters becomes Voidscar; equally far squares convert together. Once no free square
## is left, every living monster takes 1 damage per round.
static func _late_pressure(b: Battle, ended_round: int) -> void:
	if ended_round < b.voidscar_from:
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
			cell.level = 1
			b.emit(&"ground_changed", {"pos": cell.pos, "ground": cell.ground, "level": 1,
				"result": &"voidscar", "source": "Late-round pressure"})
		return
	var hits: Array = []
	for u in alive:
		hits.append({"unit": u.id, "base": 1, "type": BattleDamage.ARENA, "source": "Arena collapse"})
	BattleDamage.apply_round(b, hits)
	BattleDamage.defeat_step(b)
