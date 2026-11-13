class_name BattlePayload
extends RefCounted
## Payload resolution in the fixed order of gdd_battle §6.2, for every Strike, every Surge
## detonation and every immediate board skill. Several payloads due at the same event resolve
## phase by phase together:
##   1 damage (simultaneous) → 2 defeat → 3 displacement (furthest first, queue-order ties)
##   → 4 board operations: (a) removals incl. prop aftermath, Mountain collapse and the Gong
##     push, (b) Cleanse (no monster source exists), (c) height creation, (d) prop placement,
##     (e) ground placement / residue → 5 self retreat → event-driven passive reactions.
## The order is fixed here, never by the position of data in a skill.
##
## A payload is a Dictionary built by `strike()`, `surge()` or `board()`; the phases read the
## skill's data (damage, displacement, BoardOp list), so new skills add no code here.

const SURGE_PROP_DAMAGE := 2


# ---------- builders ----------

static func _base(b: Battle, kind: String, owner: StringName, skill: BattleSkillDef, seq: int) -> Dictionary:
	return {"kind": kind, "owner": owner, "skill": skill, "label": skill.display_name,
		"rank": b.source_rank(owner), "seq": seq, "cells": [] as Array[Vector2i],
		"units": [] as Array[StringName], "props": {}, "offsets": {}, "destroyed": {},
		"dir": Vector2i.ZERO, "anchor": Vector2i.ZERO}


## A Strike from `origin` in `dir` (ZERO for symmetric shapes); `push_dir` is the Scaled choice.
static func strike(b: Battle, u: BattleUnit, skill: BattleSkillDef, origin: Vector2i, dir: Vector2i,
		push_dir: Vector2i) -> Dictionary:
	var p := _base(b, "strike", u.id, skill, 0)
	p["origin"] = origin
	p["dir"] = dir
	p["push_dir"] = push_dir
	return p


static func surge(b: Battle, s: PendingSurge) -> Dictionary:
	var p := _base(b, "surge", s.owner, s.skill, s.id)
	p["raw_cells"] = s.cells
	p["dir"] = s.dir
	p["anchor"] = s.anchor
	p["air_cells"] = s.air_cells
	return p


## Immediate board operations of a ground / height / prop skill on `cells`.
static func board(b: Battle, u: BattleUnit, skill: BattleSkillDef, cells: Array[Vector2i]) -> Dictionary:
	var p := _base(b, "board", u.id, skill, 0)
	p["cells"] = cells
	return p


# ---------- resolution ----------

static func resolve(b: Battle, payloads: Array) -> void:
	payloads.sort_custom(func(a: Dictionary, c: Dictionary) -> bool:
		if a["rank"] != c["rank"]:
			return a["rank"] < c["rank"]
		return a["seq"] < c["seq"])
	_phase_damage(b, payloads)
	BattleDamage.defeat_step(b)
	_phase_displacement(b, payloads)
	_phase_board(b, payloads)
	_phase_retreat(b, payloads)
	reactions(b)


## Board follow-up of an event outside a payload (a prop reduced to 0 HP by a collision at
## turn end, for example): removals with aftermath, ground left behind, then reactions.
static func settle(b: Battle) -> void:
	_phase_board(b, [])
	reactions(b)


# ---------- 1: damage ----------

static func _strike_struck(p: Dictionary, u: BattleUnit) -> void:
	if not p["units"].has(u.id):
		p["units"].append(u.id)


static func _collect_strike(b: Battle, p: Dictionary) -> void:
	var u: BattleUnit = b.units[p["owner"]]
	var skill: BattleSkillDef = p["skill"]
	var origin: Vector2i = p["origin"]
	for h: Dictionary in StrikeShapes.hits(StringName(skill.strike_shape), p["dir"]):
		var cell: Vector2i = origin + h["o"]
		if not b.board.in_bounds(cell) or u.covers(cell):
			continue
		if h["front"] != StrikeShapes.NONE:
			var front := b.board.at(origin + h["front"])
			if front != null and front.prop != null:
				continue                      # a solid prop takes the hit and blocks the cell behind it
		p["cells"].append(cell)
		for layer in [Board.GROUND, Board.AIR]:
			var prop := b.board.prop_at(cell, layer)
			if prop != null:
				p["props"][prop.uid] = prop
			var other := b.unit_at(cell, layer)
			if other != null and other.id != u.id:
				_strike_struck(p, other)
				if layer == Board.GROUND:
					if not p.has("struck_at"):
						p["struck_at"] = []
					p["struck_at"].append(cell)   # where it stood when struck (it may be pushed away)
				if not p["offsets"].has(other.id):
					p["offsets"][other.id] = []
				p["offsets"][other.id].append(h["o"])


static func _collect_surge(b: Battle, p: Dictionary) -> void:
	var skill: BattleSkillDef = p["skill"]
	var stopped := false
	for cell: Vector2i in p["raw_cells"]:
		var c := b.board.at(cell)
		if c == null or stopped:
			continue
		if skill.surge_mountain == "blank" and c.is_mountain():
			b.emit(&"blanked", {"pos": cell, "source": p["label"]})
			continue
		p["cells"].append(cell)
		if c.prop != null:
			p["props"][c.prop.uid] = c.prop       # ordinary interception instead of an occupant
			stopped = skill.line_shaped           # a line footprint is stopped by the first prop
		else:
			var g := b.unit_at(cell, Board.GROUND)
			if g != null:
				_strike_struck(p, g)
		if skill.surge_hits_air:
			if c.air_prop != null:
				p["props"][c.air_prop.uid] = c.air_prop
				stopped = stopped or skill.line_shaped
			var a := b.unit_at(cell, Board.AIR)
			if a != null:
				_strike_struck(p, a)
		elif p["air_cells"].has(cell):
			var a2 := b.unit_at(cell, Board.AIR)  # Mountain rule, fixed at cast (gdd_battle §4.7)
			if a2 != null:
				_strike_struck(p, a2)


static func _phase_damage(b: Battle, payloads: Array) -> void:
	var hits: Array = []
	var prop_hits: Array = []
	for p: Dictionary in payloads:
		var skill: BattleSkillDef = p["skill"]
		match p["kind"]:
			"strike":
				_collect_strike(b, p)
				var owner: BattleUnit = b.units[p["owner"]]
				var kin := KinRules.strike(owner.kin()) if skill.kin_effect else {}
				b.emit(&"strike", {"who": p["owner"], "skill": skill.id, "cells": p["cells"].duplicate(), "dir": p["dir"]})
				if skill.strike_damage > 0:
					for id: StringName in p["units"]:
						hits.append({"unit": id, "base": skill.strike_damage, "type": BattleDamage.STRIKE, "source": p["label"]})
					for uid in p["props"]:
						prop_hits.append([p["props"][uid], int(kin.get("prop_damage", KinRules.STRIKE_PROP_DAMAGE))])
			"surge":
				_collect_surge(b, p)
				b.emit(&"surge_fired", {"who": p["owner"], "skill": skill.id, "cells": p["cells"].duplicate(), "surge": p["seq"], "struck": p["units"].duplicate()})
				for id: StringName in p["units"]:
					hits.append({"unit": id, "base": skill.surge_damage, "type": BattleDamage.SURGE, "source": p["label"], "by": p["owner"], "trap": skill.kind == BattleSkillDef.TRAP})
				for uid in p["props"]:
					prop_hits.append([p["props"][uid], SURGE_PROP_DAMAGE])
	BattleDamage.apply_round(b, hits)
	for ph: Array in prop_hits:
		BattleBoardOps.damage_prop(b, ph[0], ph[1])


# ---------- 3: displacement ----------

## Sign vector of a summed offset if it lies on one of the eight directions, else ZERO.
static func _eight_dir(sum: Vector2i) -> Vector2i:
	if sum == Vector2i.ZERO:
		return Vector2i.ZERO
	if sum.x != 0 and sum.y != 0 and absi(sum.x) != absi(sum.y):
		return Vector2i.ZERO
	return Vector2i(signi(sum.x), signi(sum.y))


static func _phase_displacement(b: Battle, payloads: Array) -> void:
	var entries: Array = []
	var swaps: Array = []
	for p: Dictionary in payloads:
		var skill: BattleSkillDef = p["skill"]
		if p["kind"] == "strike":
			var owner: BattleUnit = b.units[p["owner"]]
			var kin := KinRules.strike(owner.kin()) if skill.kin_effect else {}
			for id: StringName in p["units"]:
				var t: BattleUnit = b.units[id]
				if not t.is_alive():
					continue
				if int(kin.get("init_penalty", 0)) > 0:
					b.apply_effect(t, "kin:%s:%s" % [KinRules.strike_name(owner.kin()), owner.id],
						FieldEffect.DRAIN_INIT, int(kin["init_penalty"]), 1)
				if kin.get("push", false) and Board.CARDINAL.has(p["push_dir"]):
					entries.append({"unit": id, "dir": p["push_dir"], "cause": p["label"], "multi": true})
				if BattleExperiment.kin_push and skill.kin_effect and owner.kin() == MonsterDef.Kin.SPIRIT:
					swaps.append([owner.id, id])
				if skill.radial_push or (BattleExperiment.kin_push and skill.kin_effect and owner.kin() == MonsterDef.Kin.BEAST) \
						or (skill.strike_damage > 0 and not kin.get("push", false)):   # every Strike pushes 1 away (T38)
					# only hit cells next to the origin push, each along its own offset (gdd_skills §3)
					var sum := Vector2i.ZERO
					for o: Vector2i in p["offsets"].get(id, []):
						if maxi(absi(o.x), absi(o.y)) == 1:
							sum += o
					var d := _eight_dir(sum)
					if d != Vector2i.ZERO:
						entries.append({"unit": id, "dir": d, "cause": p["label"], "multi": true})
		elif p["kind"] == "surge" and skill.surge_displacement != "none":
			for id: StringName in p["units"]:
				var t: BattleUnit = b.units[id]
				if not t.is_alive():
					continue
				if skill.surge_displacement == "push":
					entries.append({"unit": id, "dir": p["dir"], "cause": p["label"], "multi": true})
				else:
					entries.append({"unit": id, "dir": BattleDisplace.pull_dir(t, p["anchor"]),
						"key": t.chebyshev_to(p["anchor"]), "cause": p["label"]})   # nearest the anchor first
	BattleDisplace.resolve(b, entries)
	# experiment (kin_push): a Spirit Strike trades squares with one struck 1x1 monster
	var swapped := {}
	for pair: Array in swaps:
		var a: BattleUnit = b.units[pair[0]]
		var t: BattleUnit = b.units[pair[1]]
		if swapped.has(a.id) or not a.is_alive() or not t.is_alive() or a.size != 1 or t.size != 1 or a.layer != t.layer:
			continue
		if BattleStats.is_immovable(b, t) or a.chebyshev_to(t.pos) != 1:
			continue
		swapped[a.id] = true
		var pa := a.pos
		var pt := t.pos
		b.lift(a)
		b.lift(t)
		b.put(a, pt)
		b.put(t, pa)
		b.emit(&"displaced", {"who": t.id, "from": pt, "to": pa, "cause": "swap"})
		b.emit(&"displaced", {"who": a.id, "from": pa, "to": pt, "cause": "swap"})
		for w: BattleUnit in [t, a]:
			if w.is_alive() and w.layer == Board.GROUND:
				var entered: Array[Vector2i] = [w.pos]
				BattleDamage.ground_triggers(b, w, GroundTrigger.ON_ENTER, entered)
		BattleDamage.defeat_step(b)


# ---------- 4: board operations ----------

static func _phase_board(b: Battle, payloads: Array) -> void:
	# (a) removals: Mountain destruction and every prop at 0 HP, simultaneously
	var mountains := {}                       # cell -> keep_ground
	for p: Dictionary in payloads:
		var skill: BattleSkillDef = p["skill"]
		var targets: Array[Vector2i] = []
		if skill.has_op(BoardOp.DESTROY_MOUNTAIN):
			targets.assign(p["cells"])
		if p["kind"] == "strike" and skill.kin_effect:
			var owner: BattleUnit = b.units[p["owner"]]
			if KinRules.strike(owner.kin()).get("destroy_mountain", false):
				# "the Mountain under the target": the squares on which monsters were struck, and struck props
				targets.append_array(p.get("struck_at", []))
				for uid in p["props"]:
					targets.append(p["props"][uid].pos)
		for cell in targets:
			var c := b.board.at(cell)
			if c != null and c.is_mountain():
				mountains[cell] = mountains.get(cell, false) or skill.grounds_mountains()
				p["destroyed"][cell] = true
	var removed: Array[BoardProp] = []
	_removal_round(b, mountains, removed)
	var guard := 0
	while _has_dead_props(b) and guard < 64:  # a Gong push can break further props
		_removal_round(b, {}, removed)
		guard += 1
	# (b) Cleanse: no monster source beyond the Mountain-creation reset below (gdd_skills §4)
	# (c) height creation with its Plain reset
	for p: Dictionary in payloads:
		if p["skill"].has_op(BoardOp.RAISE_MOUNTAIN):
			for cell: Vector2i in p["cells"]:
				BattleBoardOps.raise_mountain(b, b.board.at(cell))
	# (d) prop placement (sees the final height)
	for p: Dictionary in payloads:
		for op in p["skill"].ops_of(BoardOp.CREATE_PROP):
			for cell: Vector2i in p["cells"]:
				BattleBoardOps.place_prop(b, b.content.prop(op.prop), cell)
	# (e) ground: what destroyed props leave behind, then authored ground / residue
	for prop in removed:
		if prop.def.ground_left == &"":
			continue
		var c := b.board.at(prop.pos)
		if c.is_mountain() or c.prop != null:
			continue                          # never changes a Mountain square (gdd_battle §4.10)
		BattleBoardOps.lay_ground(b, c, prop.def.ground_left, prop.def.display_name)
	for p: Dictionary in payloads:
		for op in p["skill"].ops_of(BoardOp.GROUND):
			for cell: Vector2i in p["cells"]:
				var c := b.board.at(cell)
				if c.prop != null:
					continue                  # legality at execution: no ground under a prop
				if (c.is_mountain() or p["destroyed"].has(cell)) and not op.on_mountain:
					continue
				BattleBoardOps.lay_ground(b, c, op.ground, p["label"])
		# test switch surge_ground: a timed Surge without ground of its own leaves one
		var sk: BattleSkillDef = p["skill"]
		if BattleExperiment.surge_ground != &"" and p["kind"] == "surge" and sk.kind == BattleSkillDef.SURGE and sk.ops_of(BoardOp.GROUND).is_empty():
			for cell: Vector2i in p["cells"]:
				var c := b.board.at(cell)
				if c.prop == null and not c.is_mountain() and not p["destroyed"].has(cell) and not BattleExperiment.well_squares(b.board.size).has(cell):
					BattleBoardOps.lay_ground(b, c, BattleExperiment.surge_ground, p["label"])


static func _has_dead_props(b: Battle) -> bool:
	for prop in b.board.props():
		if prop.hp <= 0:
			return true
	return false


## One simultaneous removal step. Aftermaths are evaluated on the board as it stands at the
## start of the step (a 0-HP prop still counts as a prop); aftermath and collapse damage form
## one damage round; defeat follows; then Beams appear and a destroyed Gong pushes.
static func _removal_round(b: Battle, mountains: Dictionary, removed: Array[BoardProp]) -> void:
	var dead: Array[BoardProp] = []
	for prop in b.board.props():
		if prop.hp <= 0:
			dead.append(prop)
	if dead.is_empty() and mountains.is_empty():
		return
	var hits: Array = []
	var pushes: Array = []
	var spawns: Array = []
	for prop in dead:
		for a in prop.def.aftermath:
			var per_unit := {}                # unit id -> summed offset (once per prop and unit)
			for o in a.offsets():
				var q: Vector2i = prop.pos + o
				if not b.board.in_bounds(q):
					continue
				if a.op == "spawn":
					var child := b.content.prop(a.spawn_prop)
					if BattleBoardOps.can_place_prop(b, child, q):
						spawns.append([child, q])
					continue
				for u in BattleBoardOps.units_in_reach_of(b, prop.def, q):
					per_unit[u.id] = per_unit.get(u.id, Vector2i.ZERO) + o
			for id in b.roster:
				if not per_unit.has(id):
					continue
				if a.op == "damage":
					hits.append({"unit": id, "base": a.amount, "type": BattleDamage.AFTERMATH, "source": prop.def.display_name})
				elif a.op == "push":
					pushes.append({"unit": id, "dir": _eight_dir(per_unit[id]), "key": 0, "cause": prop.def.display_name})
				elif a.op == "pull":
					pushes.append({"unit": id, "dir": -_eight_dir(per_unit[id]), "key": 0, "cause": prop.def.display_name})
	var collapsed := {}
	var cells := mountains.keys()
	cells.sort()
	for cell: Vector2i in cells:
		var occ := b.unit_at(cell, Board.GROUND)
		if occ != null and not collapsed.has(occ.id):
			collapsed[occ.id] = true          # environmental damage, not part of the skill's own
			hits.append({"unit": occ.id, "base": 1, "type": BattleDamage.COLLAPSE, "source": "Collapse"})
	BattleDamage.apply_round(b, hits)
	for prop in dead:
		b.board.remove_prop(prop)
		removed.append(prop)
		b.emit(&"prop_destroyed", {"pos": prop.pos, "prop": prop.def.id})
		b.reaction_events.append({"type": "prop_destroyed", "pos": prop.pos})
	for cell: Vector2i in cells:
		BattleBoardOps.destroy_mountain(b, b.board.at(cell), mountains[cell])
	BattleDamage.defeat_step(b)
	for s: Array in spawns:
		BattleBoardOps.place_prop(b, s[0], s[1])
	BattleDisplace.resolve(b, pushes)


# ---------- 5: self retreat ----------

static func _phase_retreat(b: Battle, payloads: Array) -> void:
	for p: Dictionary in payloads:
		if p["kind"] != "strike":
			continue
		var u: BattleUnit = b.units[p["owner"]]
		var skill: BattleSkillDef = p["skill"]
		var kin := KinRules.strike(u.kin()) if skill.kin_effect else {}
		if not u.is_alive() or not (skill.self_retreat or kin.get("retreat", false)):
			continue
		var rd := StrikeShapes.retreat_dir(StringName(skill.strike_shape), p["dir"])
		if rd != Vector2i.ZERO:
			BattleMoves.retreat(b, u, rd)


# ---------- event-driven passive reactions (gdd_battle §2.4) ----------

## Reactions collected during the payload resolve now, one at a time in the initiative-queue
## order of the reacting units, on the board as it stands; each passive reacts at most once
## per triggering event and consequences trigger no further reactions.
static func reactions(b: Battle) -> void:
	if b.reaction_events.is_empty():
		return
	var events := b.reaction_events.duplicate()
	b.reaction_events.clear()
	var reactors := b.living()
	reactors.sort_custom(func(a: BattleUnit, c: BattleUnit) -> bool:
		var ra := b.queue_rank(a.id)
		var rc := b.queue_rank(c.id)
		return ra < rc if ra != rc else b.roster.find(a.id) < b.roster.find(c.id))
	for u in reactors:
		for s in u.passives():
			if s.react_event != "prop_destroyed_in_reach" or s.react_heal <= 0:
				continue
			for ev: Dictionary in events:
				if u.is_alive() and ev["type"] == "prop_destroyed" and u.manhattan_to(ev["pos"]) <= BattleStats.reach(b, u):
					BattleDamage.heal(b, u, s.react_heal, s.display_name)
	b.reaction_events.clear()
