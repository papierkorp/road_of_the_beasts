class_name AiBrain
extends RefCounted
## Heuristic opponent for team battles (GDD §16). Deterministic apart from tie-breaks via `rng`.
## It only uses the public Battle API, so it plays by exactly the same rules as the player.
##
## Each step scores every option — move, Surge, Strike, utility — and takes the best one
## above its threshold; otherwise it ends the turn.

const T_MOVE := 0.4
const T_SURGE := 0.9
const T_STRIKE := 0.8
const T_UTILITY := 0.7

const DIRS: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]


## One action for `who`: {type: &"move"|&"cast"|&"strike"|&"pass", ...}.
static func decide(battle: Battle, who: StringName, rng: RandomNumberGenerator) -> Dictionary:
	var me: Monster = battle.monsters[who]
	var enemies := battle.enemies_of(me)
	if enemies.is_empty() or not battle.can_act(who):
		return {"type": &"pass"}
	var ctx := _context(battle, me, enemies)
	var options: Array[Dictionary] = []

	# move
	var here := _spot(battle, me, me.pos, ctx)
	var opts := battle.move_options(me)
	var best_move = null
	var best_move_score := -INF
	for p in opts:
		var sc: float = _spot(battle, me, p, ctx) - 1.5 * opts[p]["thorn"]
		if sc > best_move_score + 1e-6 or (absf(sc - best_move_score) < 1e-6 and rng.randf() < 0.3):
			best_move_score = sc
			best_move = p
	if best_move != null and best_move_score - here > T_MOVE:
		options.append({"type": &"move", "to": best_move, "score": best_move_score - here})

	# Surge
	var surge := me.def.surge
	if surge != null and battle.can_cast(who, surge):
		var b := _best_placement(battle, me, surge, rng, func(pl, d): return _surge_score(battle, me, surge, pl, d, ctx))
		if not b.is_empty() and b["score"] >= T_SURGE:
			options.append(b)

	# Strike
	for t in battle.strike_targets(who):
		var sc := _strike_score(battle, me, t)
		if sc >= T_STRIKE:
			options.append({"type": &"strike", "target": t, "dir": _strike_dir(me, t), "score": sc})

	# utility
	var util := me.def.utility
	if util != null and battle.can_cast(who, util):
		var b := _best_placement(battle, me, util, rng, func(pl, d): return _utility_score(battle, me, util, pl, d, ctx))
		if not b.is_empty() and b["score"] >= T_UTILITY:
			options.append(b)

	if options.is_empty():
		return {"type": &"pass"}
	options.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a["score"] > b["score"])
	return options[0]


## Plays a whole turn (spend AP, then end it).
static func play_turn(battle: Battle, who: StringName, rng: RandomNumberGenerator) -> void:
	var guard := 0
	while battle.can_act(who) and guard < 6:
		guard += 1
		if not execute(battle, who, decide(battle, who, rng)):
			break
	if not battle.over and battle.turn_owner == who:
		battle.end_turn()


static func execute(battle: Battle, who: StringName, a: Dictionary) -> bool:
	match a["type"]:
		&"move":
			return battle.move(who, a["to"])
		&"cast":
			return battle.cast(who, a["skill"], a["oi"], a["anchor"], a["dir"])
		&"strike":
			return battle.strike(who, a["target"], a["dir"])
	return false


# ---------- context ----------

static func _context(battle: Battle, me: Monster, enemies: Array[Monster]) -> Dictionary:
	var reach := {}
	for e in enemies:
		var r: Array[Vector2i] = [e.pos]
		r.append_array(battle.reachable(e))
		reach[e.id] = r
	var pref := 3
	match me.def.surge.twist if me.def.surge != null else SkillDef.Twist.NONE:
		SkillDef.Twist.POUNCE, SkillDef.Twist.RING:
			pref = 1
		SkillDef.Twist.TRAIL:
			pref = 2
		SkillDef.Twist.LOB:
			pref = 4
	return {"enemies": enemies, "reach": reach, "pref": pref}


## Damage this monster would take from pending Surges on `p` (any owner — Surges hit allies too).
static func _danger(battle: Battle, m: Monster, p: Vector2i) -> float:
	var sq := battle.board.at(p)
	if sq.surge == null:
		return 0.0
	return float(battle.surge_damage_at(sq, sq.surge, m))


static func _spot(battle: Battle, m: Monster, p: Vector2i, ctx: Dictionary) -> float:
	var sq := battle.board.at(p)
	var s := -2.0 * _danger(battle, m, p)
	match sq.ground:
		Square.GroundType.LAVA:
			if not m.has_passive(&"heatproof"):
				s -= 1.2 * sq.level
		Square.GroundType.BLIGHT:
			if not m.has_passive(&"void_touched"):
				s -= 1.0 * sq.level
		Square.GroundType.VOIDSCAR:
			s -= 1.5
	if sq.zone != null and sq.zone["owner"] != m.id:
		var owner: Monster = battle.monsters.get(sq.zone["owner"])
		if owner != null and owner.side != m.side:
			var def: ZoneDef = sq.zone["def"]
			if def.has_tag(ZoneEffect.Tag.PUSH) or def.has_tag(ZoneEffect.Tag.PULL):
				s -= 0.4
			if def.has_tag(ZoneEffect.Tag.SLOW) or def.has_tag(ZoneEffect.Tag.DRAIN_INIT):
				s -= 0.4
	if sq.zone != null and sq.zone["def"].has_tag(ZoneEffect.Tag.SHIELD):
		s += 0.2
	if sq.elevated:
		s += 0.5
	if sq.attunement == m.aspect():
		s += 0.3
	var nearest := 99
	for e: Monster in ctx["enemies"]:
		nearest = mini(nearest, Board.manhattan(p, e.pos))
	s -= 0.35 * absf(nearest - ctx["pref"])
	return s


# ---------- placements ----------

static func _best_placement(battle: Battle, me: Monster, skill: SkillDef, rng: RandomNumberGenerator,
		score: Callable) -> Dictionary:
	var best := {}
	var dirs: Array[Vector2i] = [Vector2i.UP]
	if skill.needs_direction():
		dirs = DIRS.duplicate()
	for pl in battle.all_placements(me.id, skill):
		for d in dirs:
			var sc: float = score.call(pl, d)
			if best.is_empty() or sc > best["score"] + 1e-6 or (absf(sc - best["score"]) < 1e-6 and rng.randf() < 0.3):
				best = {"type": &"cast", "skill": skill, "oi": pl["oi"], "anchor": pl["anchor"],
					"dir": d, "cells": pl["cells"], "score": sc}
	return best


static func _surge_score(battle: Battle, me: Monster, skill: SkillDef, pl: Dictionary, dir: Vector2i,
		ctx: Dictionary) -> float:
	var cells: Array[Vector2i] = pl["cells"]
	var sg := {"type": skill.surge_type, "aspect": skill.aspect,
		"value": skill.surge_value() + me.momentum_bonus, "native": me.has_passive(&"native_ground")}
	var free := {}
	for c in cells:
		if battle.board.at(c).surge == null:
			free[c] = true
	if free.is_empty():
		return -9.0
	var sc := 0.0
	for e: Monster in ctx["enemies"]:
		var r: Array = ctx["reach"][e.id]
		var unsafe := 0
		for c in r:
			if free.has(c) and battle.surge_damage_at(battle.board.at(c), sg, e) > 0:
				unsafe += 1
		var frac := float(unsafe) / maxf(1.0, r.size())
		if free.has(e.pos):
			var d := battle.surge_damage_at(battle.board.at(e.pos), sg, e)
			sc += d * (0.35 + 0.65 * frac)
			if d >= e.hp and frac >= 0.99:
				sc += 2.0
			if skill.surge_type == SkillDef.SurgeType.FLOOD:
				sc += 0.3 * _landing_value(battle, me, e, e.pos + dir)
		else:
			sc += 0.25 * sg["value"] * frac
	for a in battle.allies_of(me):
		if free.has(a.pos):
			sc -= 0.8 * battle.surge_damage_at(battle.board.at(a.pos), sg, a)
	if free.has(me.pos):
		sc -= 0.6 * battle.surge_damage_at(battle.board.at(me.pos), sg, me)
	return sc + 0.05 * free.size()


static func _strike_score(battle: Battle, me: Monster, t: Vector2i) -> float:
	var dmg := battle.strike_damage(me.id, t)
	var target := battle.monster_at(t)
	var cost := battle.strike_cost(me.id, t)
	if target == null:
		# smash a prop for debris next to an enemy
		var sq := battle.board.at(t)
		if sq.object == null or sq.object["hp"] > dmg:
			return 0.0
		for n in battle.board.neighbors(t):
			var o := battle.monster_at(n)
			if o != null and o.side != me.side:
				return 0.9
		return 0.0
	var sc := float(dmg)
	if dmg >= target.hp:
		sc += 1.5
	if cost >= 2:
		sc -= 0.4
	return sc


static func _strike_dir(me: Monster, t: Vector2i) -> Vector2i:
	var v := t - me.pos
	if absi(v.x) >= absi(v.y):
		return Vector2i(signi(v.x), 0)
	return Vector2i(0, signi(v.y))


## How good it is (for `me`) that enemy `e` ends up on `to`.
static func _landing_value(battle: Battle, me: Monster, e: Monster, to: Vector2i) -> float:
	if not battle.board.in_bounds(to):
		return 0.0
	var sq := battle.board.at(to)
	if sq.object != null:
		return 1.0
	if battle.monster_at(to) != null:
		return 0.0
	var v := 0.2
	if sq.surge != null:
		var owner: Monster = battle.monsters.get(sq.surge["owner"])
		if owner != null and owner.side == me.side:
			v += 0.6 * battle.surge_damage_at(sq, sq.surge, e)
	if sq.is_aspect_ground():
		v += 0.5 * sq.level
	if battle.board.at(e.pos).elevated and not sq.elevated:
		v += 0.8
	return v


## How much a zone cast on this square is still worth: 1 new, less for level-ups, 0 at max level.
static func _zone_factor(battle: Battle, me: Monster, z: ZoneDef, sq: Square) -> float:
	var r := Rules.zone_result(z, sq)
	match r["kind"]:
		&"level":
			return 0.0 if sq.zone["level"] >= Rules.MAX_ZONE_LEVEL else 0.35
		&"cancel":
			var owner: Monster = battle.monsters.get(sq.zone["owner"])
			return 0.6 if owner != null and owner.side != me.side else 0.0
		&"replace":
			var owner2: Monster = battle.monsters.get(sq.zone["owner"])
			return 1.0 if owner2 == null or owner2.side != me.side else 0.3
	return 1.0


static func _utility_score(battle: Battle, me: Monster, skill: SkillDef, pl: Dictionary, dir: Vector2i,
		ctx: Dictionary) -> float:
	var cells: Array[Vector2i] = pl["cells"]
	var sc := 0.0
	match skill.kind:
		SkillDef.Kind.ZONE:
			var z := skill.zone
			for c in cells:
				var m := battle.monster_at(c)
				if m == null:
					continue
				var enemy: bool = m.side != me.side
				var f := _zone_factor(battle, me, z, battle.board.at(c))
				if f <= 0.0:
					continue
				var before := sc
				if z.has_tag(ZoneEffect.Tag.SHIELD):
					if not enemy:
						var incoming := _danger(battle, m, c)
						var shield := float(z.value_of(ZoneEffect.Tag.SHIELD, 1, battle.board.at(c).attunement))
						sc += minf(shield, incoming) * 1.1
						if incoming >= m.hp and incoming - shield < m.hp:
							sc += 1.5
				if z.has_tag(ZoneEffect.Tag.SLOW) or z.has_tag(ZoneEffect.Tag.DRAIN_INIT) or z.has_tag(ZoneEffect.Tag.DRAIN_RANGE):
					sc += (1.0 + (0.4 if z.has_tag(ZoneEffect.Tag.DRAIN_INIT) else 0.0)) * (1.0 if enemy else -0.8)
				if z.has_tag(ZoneEffect.Tag.PUSH):
					sc += 0.6 * _landing_value(battle, me, m, c + dir) * (1.0 if enemy else -0.8)
				elif z.has_tag(ZoneEffect.Tag.PULL) and c != pl["anchor"]:
					sc += 0.6 * _landing_value(battle, me, m, c + Battle._step_toward(c, pl["anchor"])) * (1.0 if enemy else -0.8)
				sc = before + (sc - before) * f
			for c in cells:
				var sq := battle.board.at(c)
				var r := Rules.triangle(z.aspect, sq)
				if r == &"clear":
					sc += 0.3
		SkillDef.Kind.GROUND:
			for c in cells:
				var k: StringName = Rules.preview_cell(skill, battle.board.at(c))["kind"]
				if k == &"lost" or (k == &"level" and battle.board.at(c).level >= Rules.MAX_GROUND_LEVEL):
					continue
				var m := battle.monster_at(c)
				if m != null:
					sc += 0.9 if m.side != me.side else -0.8
				for e: Monster in ctx["enemies"]:
					if Board.manhattan(c, e.pos) == 1:
						sc += 0.25
		SkillDef.Kind.HEIGHT:
			for c in cells:
				var m := battle.monster_at(c)
				if m != null and m.side == me.side:
					sc += _danger(battle, m, c) * 0.8 + 0.2
		SkillDef.Kind.PROP:
			for c in cells:
				for e: Monster in ctx["enemies"]:
					if Board.manhattan(c, e.pos) == 1:
						sc += 0.3
	return sc
