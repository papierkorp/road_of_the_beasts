class_name BattleTurn
extends RefCounted
## Turn and round flow (gdd_battle §2.1–§2.4, §4.2):
##   entry start: start-of-turn ground → AP
##   Surges: a trap fires when sprung, a timed Surge after its turns (between two turns)
##   entry end:   zone push/pull → end-of-turn ground (on the landing square) → mend
##   round end:   push and pull zones move props → round-end ground → props that act every round →
##                Dragon Veins and surrounding (one step) → all clocks tick (zones, timed unit effects,
##                ground laid in battle) → late-round Voidscar / arena collapse → Stamina recovery →
##                the Pace queue of the next round.


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
			BattleDamage.ground_triggers(b, u, Moment.TURN_START)
			if b.check_over():
				return
		if u.is_alive():
			# 2. AP
			b.ap = BattleStats.ap(u)
			b.entry_acted = false
			u.used_turn.clear()
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
	if true:                                      # monsters that waited act in reverse order: the first to wait acts last
		for i in range(b.queue_idx, b.queue.size()):
			if b.queue[i].get("waited", false):
				at = i                            # before the monsters that postponed earlier
				break
	b.queue.insert(at, entry)
	b.delayed[entry["id"]] = b.round_number
	b.waits[entry["id"]] = int(b.waits.get(entry["id"], 0)) + 1
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
		s.acted[b.turn_owner] = true
		s.turns_left = maxi(0, s.turns_left - 1)
		if s.turns_left <= 0 and _all_acted(b, s):
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


## A move of `u` has ended on its square (a Step, the landing of a movement skill, a push or a pull): a push or
## pull zone there moves it on at once (docs/battle.md §4.6). Zones move a monster once per action.
static func arrive(b: Battle, u: BattleUnit) -> void:
	if b.over or u == null or not u.is_alive() or not u.on_field or b.zone_moved.has(u.id):
		return
	if BattleStats.has_flag(u, &"ignores_zones"):
		return
	var d := zone_step(b, u)
	if d == Vector2i.ZERO:
		return
	b.zone_moved[u.id] = true
	BattleDisplace.shove(b, u, d, "zone", "zone")
	BattlePayload.settle(b)


static func end_turn(b: Battle) -> void:
	if b.over:
		return
	var u: BattleUnit = b.units.get(b.turn_owner)
	b.ap = 0
	b.follow = {}
	if u != null and u.is_alive():
		b.emit(&"turn_ended", {"who": u.id})
		# 1. push / pull
		var d := zone_step(b, u) if not BattleStats.has_flag(u, &"ignores_zones") else Vector2i.ZERO
		if d != Vector2i.ZERO:
			b.zone_moved[u.id] = true             # the move at the end of the turn is one zone move, not a chain
			BattleDisplace.shove(b, u, d, "zone", "zone")
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
				BattleDamage.ground_triggers(b, u, Moment.TURN_END, [], mend)
			else:
				BattleDamage.ground_triggers(b, u, Moment.TURN_END)
				if u.is_alive() and not mend.is_empty():
					BattleDamage.apply_round(b, [], mend)
		if u.is_alive():
			var prop_hits := BattleProps.turn_end_hits(b, u)
			if not prop_hits.is_empty():
				BattleDamage.apply_round(b, prop_hits)
				BattleDamage.defeat_step(b)
		# 4. a wild monster on Seal Ground may be caught (docs/battle_ingame.md §7)
		if u.is_alive():
			BattleCatch.turn_end(b, u)
		if b.check_over():
			return
	tick_timers(b)
	if b.over:
		return
	b.queue_idx += 1
	_start_entry(b)


## What the round end would do if the round ended on the board as it stands (a dry run on a copy; the turns still
## to come can change it): {"hits": [{unit, amount, source}], "falls": [unit ids]}. Open information for the HUD.
static func round_end_forecast(b: Battle) -> Dictionary:
	var out := {"hits": [], "falls": []}
	if b.over or b.board == null:
		return out
	var sim := b.clone()
	sim.choice_sides.clear()                      # the copy takes the fixed pick at a Dragon Vein tie
	sim.pending_choice = {}
	sim.events.clear()
	_end_round(sim)
	for e: Dictionary in sim.events:
		if e["type"] == &"round_started":
			break
		if e["type"] == &"damage" and int(e.get("amount", 0)) > 0:
			out["hits"].append({"unit": e["target"], "amount": int(e["amount"]), "source": String(e.get("source", ""))})
		elif e["type"] == &"defeated":
			out["falls"].append(e["who"])
	return out


## The round end moves first, acts afterwards and ticks its clocks last (user decisions 2026-11-15, gdd_battle §2.4).
static func _end_round(b: Battle) -> void:
	var ended := b.round_number
	b.zone_moved.clear()
	# 1. everything that moves: push and pull zones move the props standing in them (user decision 2026-11-14),
	#    then the props that push or pull (Storm Drum). What reacts to entering or leaving a square fires as always.
	_zones_move_props(b)
	if b.check_over():
		return
	BattleProps.round_end(b, true)
	if b.check_over():
		return
	# 2. everything that acts on where things stand now: ground of the round end (gdd_battle §4.7), the other
	#    round-end lines of the props (Ember Brazier), then Dragon Veins and surrounding (_finish_round)
	for id in b.roster:
		var ru: BattleUnit = b.units[id]
		if ru.is_alive() and ru.on_field:
			BattleDamage.ground_triggers(b, ru, Moment.ROUND_END)
	if b.check_over():
		return
	_ground_wears_props(b)
	BattleProps.round_end(b, false)
	if b.check_over():
		return
	b.choice_picks.clear()
	if _ask_choice(b):
		return                                    # the round end waits for the owning side's pick
	_finish_round(b, ended)


## The rest of the round end: Dragon Vein and surround damage, Stamina recovery, the clocks, pressure, the next round.
static func _finish_round(b: Battle, ended: int) -> void:
	var held := _positional(b)
	if b.check_over():
		return
	# Every monster recovers Stamina: the whole number of its current Pace. It belongs to what acts at the round
	# end, so it comes before the clocks tick: a zone or timed effect in its last round still counts once more.
	if BattleExperiment.stamina:
		for id in b.roster:
			var su: BattleUnit = b.units[id]
			if su.is_alive():
				su.stamina = mini(su.sheet.movement, su.stamina + BattleStats.recovery(b, su))
	_tick_clocks(b, ended)
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
	_start_entry(b)


## Wellspring draft (test switches `wells` and `flank`, temp_todo T39): positional damage at the end
## of a round, all of it in one simultaneous step. Every Wellspring a monster stands on deals 1
## damage to the enemy nearest to the square; a monster with two or more enemies on its eight
## neighbour squares takes 1 damage. Returns how many Wellsprings are held.
static func _positional(b: Battle) -> int:
	var hits: Array = []
	var held := [0, 0]
	var ordered: Array = []                       # the veins that act, one after another
	for vein in b.board.cells:
		if BattleExperiment.wells <= 0 or vein.ground != GroundDef.WELL:
			continue
		var p: Vector2i = vein.pos
		var holder := b.any_unit_at(p)
		if holder != null and vein.owner_side != holder.side:
			vein.owner_side = holder.side         # whoever stands on it has touched it
			vein.owner_unit = holder.id
		var side := vein.owner_side if BattleExperiment.vein_touch else (holder.side if holder != null else -1)
		if side < 0:
			continue
		held[side] += 1
		ordered.append({"pos": p, "side": side, "holder": holder.id if holder != null and holder.side == side else &""})
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
	_veins_wear(b)
	_veins_in_order(b, ordered)
	return held[0] + held[1]


## Every Dragon Vein, owned or not, deals 1 to the monster or prop on its square, all of them in one step
## (docs/battle.md §4.2). Nothing reduces it and it stays 1 in every round.
static func _veins_wear(b: Battle) -> void:
	if BattleExperiment.wells <= 0 or b.check_over():
		return
	var hits: Array = []
	var worn := false
	for vein in b.board.cells:
		if vein.ground != GroundDef.WELL:
			continue
		var on := b.unit_at(vein.pos, Board.GROUND)
		if on != null and on.is_alive():
			hits.append({"unit": on.id, "base": 1, "type": BattleDamage.WELL, "source": "Dragon Vein (its own square)"})
		var prop := b.board.prop_at(vein.pos, Board.GROUND)
		if prop != null and prop.hp > 0:
			BattleBoardOps.damage_prop(b, prop, 1)
			worn = true
	if not hits.is_empty():
		BattleDamage.apply_round(b, hits)
		BattleDamage.defeat_step(b)
	if worn:
		BattlePayload.settle(b)


## The owned veins act one at a time, the vein of the faster taker first (current
## Pace, then the queue, then the square); a vein whose taker has fallen comes last. Each picks its target on
## the board as it then stands, and the battle ends as soon as one side is gone.
static func _veins_in_order(b: Battle, veins: Array) -> void:
	for v: Dictionary in veins:
		var taker: BattleUnit = b.units.get(b.board.at(v["pos"]).owner_unit)
		var alive: bool = taker != null and taker.is_alive() and taker.side == int(v["side"])
		v["pace"] = BattleStats.pace(b, taker) if alive else 0.0
		v["rank"] = b.queue_rank(taker.id) if alive else 1000000
	veins.sort_custom(func(a: Dictionary, c: Dictionary) -> bool:
		if not is_equal_approx(a["pace"], c["pace"]):
			return a["pace"] > c["pace"]
		if a["rank"] != c["rank"]:
			return a["rank"] < c["rank"]
		var pa: Vector2i = a["pos"]
		var pc: Vector2i = c["pos"]
		return pa.y < pc.y or (pa.y == pc.y and pa.x < pc.x))
	for v: Dictionary in veins:
		if b.check_over():
			return
		var target := _well_target(b, v["pos"], v["side"])
		if target == null:
			continue
		var hit := {"unit": target.id, "base": BattleExperiment.vein_damage(b.round_number), "type": BattleDamage.WELL, "source": "Dragon Vein"}
		if v["holder"] != &"":
			hit["by"] = v["holder"]
		BattleDamage.apply_round(b, [hit])
		BattleDamage.defeat_step(b)


## Dragon Vein target choice (user decision 2026-11-14): when the side that owns a vein can pick
## among several equally near, equally strong enemies, and that side is one of `Battle.choice_sides`,
## the round end waits for `choose_target`. Sides outside `choice_sides` (the AI, simulations) take
## the roster-order fallback of `_well_target`. Returns true while a choice is pending.
static func _ask_choice(b: Battle) -> bool:
	b.pending_choice = {}
	if BattleExperiment.wells <= 0 or b.choice_sides.is_empty():
		return false
	for vein in b.board.cells:
		if vein.ground != GroundDef.WELL or b.choice_picks.has(vein.pos):
			continue
		var holder := b.any_unit_at(vein.pos)
		var side := holder.side if holder != null else (vein.owner_side if BattleExperiment.vein_touch else -1)
		if side < 0 or not b.choice_sides.has(side):
			continue
		var tied := _well_best(b, vein.pos, side)
		if tied.size() < 2:
			continue
		var ids: Array[StringName] = []
		for t in tied:
			ids.append(t.id)
		b.pending_choice = {"pos": vein.pos, "side": side, "options": ids}
		b.turn_owner = &""
		b.emit(&"choice_needed", {"pos": vein.pos, "side": side, "options": ids})
		return true
	return false


## Applies the pick of the owning side and resumes the round end.
static func choose(b: Battle, unit: StringName) -> void:
	var pos: Vector2i = b.pending_choice["pos"]
	b.choice_picks[pos] = unit
	b.emit(&"choice_made", {"pos": pos, "unit": unit})
	if _ask_choice(b):
		return
	_finish_round(b, b.round_number)


## Every enemy that ties for the target of a held Dragon Vein: nearest, then most HP, then most
## pace (gdd_battle §4.2).
static func _well_best(b: Battle, p: Vector2i, side: int) -> Array[BattleUnit]:
	var out: Array[BattleUnit] = []
	for e in b.living(1 - side):
		if out.is_empty():
			out.append(e)
			continue
		var best := out[0]
		var de := e.chebyshev_to(p)
		var db := best.chebyshev_to(p)
		var ie := BattleStats.pace(b, e)
		var ib := BattleStats.pace(b, best)
		if de < db or (de == db and (e.hp > best.hp or (e.hp == best.hp and ie > ib))):
			out = [e] as Array[BattleUnit]
		elif de == db and e.hp == best.hp and is_equal_approx(ie, ib):
			out.append(e)
	return out


## The pick of a side that does not choose by hand (the AI, simulations; user decision 2026-11-14):
## fewest HP, then highest pace, then lowest max HP, then roster order.
static func ai_pick(b: Battle, tied: Array[BattleUnit]) -> BattleUnit:
	var best := tied[0]
	for t in tied:
		var it := BattleStats.pace(b, t)
		var ib := BattleStats.pace(b, best)
		if t.hp < best.hp \
				or (t.hp == best.hp and it > ib and not is_equal_approx(it, ib)) \
				or (t.hp == best.hp and is_equal_approx(it, ib) and t.max_hp < best.max_hp):
			best = t
	return best


## The enemy a held Wellspring hits: nearest to the square (board distance), then more HP, then
## more pace; a last tie is the holder's choice in the draft (here: roster order).
static func _well_target(b: Battle, p: Vector2i, side: int) -> BattleUnit:
	var tied := _well_best(b, p, side)
	if tied.is_empty():
		return null
	var pick: StringName = b.choice_picks.get(p, &"")
	for t in tied:
		if t.id == pick:
			return t
	return ai_pick(b, tied)


## All clocks tick together, after everything of the round end has acted (user decision 2026-11-15): zones
## lose a round, timed unit effects of this round end, ground laid in battle fades. So a thing that lasts
## N rounds still counts at its N-th round end.
static func _tick_clocks(b: Battle, ended: int) -> void:
	for id in b.units:                            # a shield not used up ends with its round
		(b.units[id] as BattleUnit).nullify = false
	var faded := 0
	for cell in b.board.cells:
		if cell.zone != null:
			cell.zone.duration -= 1
			if cell.zone.duration <= 0:
				cell.zone = null
				faded += 1
	if faded > 0:
		b.emit(&"zones_faded", {"count": faded})
	for id in b.roster:
		var u: BattleUnit = b.units[id]
		var keep: Array[Dictionary] = []
		for fx in u.effects:
			if int(fx["ends_round"]) > ended:
				keep.append(fx)
		u.effects = keep
	_fade(b, ended)
	for prop in b.board.props():                  # a prop a skill created lapses without effect
		if prop.until > 0 and ended >= prop.until and prop.hp > 0:
			b.board.remove_prop(prop)
			b.emit(&"prop_lapsed", {"pos": prop.pos, "prop": prop.def.id})


## Ground laid during the battle turns back into Plain at the end of the round its clock names (build rule:
## 2 rounds, `ground_rounds`).
static func _fade(b: Battle, ended_round: int) -> void:
	if BattleExperiment.ground_rounds > 0:
		for cell in b.board.cells:
			if cell.ground_until > 0 and ended_round >= cell.ground_until:
				cell.ground = GroundDef.PLAIN
				cell.level = 1
				cell.ground_until = 0
				b.emit(&"ground_changed", {"pos": cell.pos, "ground": cell.ground, "level": 1, "result": &"faded", "source": "end of round"})


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


## End-of-turn ground damages the props standing on it at the round end: a prop has no turn (docs/battle.md §4.5).
static func _ground_wears_props(b: Battle) -> void:
	var worn := false
	for prop in b.board.props():
		if BattleDamage.ground_on_prop(b, prop, Moment.TURN_END) > 0:
			worn = true
	if worn:
		BattlePayload.settle(b)


## A prop has no turn, so the push and pull zones move the props standing in them once, at the end
## of the round, before the round-end operations of props.
static func _zones_move_props(b: Battle) -> void:
	var entries: Array = []
	for prop in b.board.props():
		var cell := b.board.at(prop.pos)
		if prop.hp <= 0 or cell == null or cell.zone == null:
			continue
		var z := cell.zone
		var sum := Vector2i.ZERO
		if z.def.effect(FieldEffect.PUSH) != null:
			sum += z.dir
		if z.def.effect(FieldEffect.PULL) != null:
			sum += BattleDisplace.pull_dir_cell(prop.pos, z.anchor)
		var d := Vector2i(signi(sum.x), signi(sum.y))
		if (d.x == 0) != (d.y == 0):
			entries.append({"prop": prop.uid, "dir": d, "cause": "zone"})
	if entries.is_empty():
		return
	BattleDisplace.resolve(b, entries)
	BattlePayload.settle(b)
