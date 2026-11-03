class_name AiBrain
extends RefCounted
## Heuristic opponent, ported from the prototype's wolfDecide (GDD §16).
## Uses the same rules as the player: Rules.preview_cell, Battle.reachable, Battle.cast.
## Kit roles are found by skill kind: one Surge, an optional drain zone ("hex")
## and an optional shield zone ("veil").


## Decide one action for `who`. Returns {type: &"cast"|&"move"|&"pass", ...}.
static func decide(battle: Battle, who: StringName, rng: RandomNumberGenerator) -> Dictionary:
	var me: Monster = battle.monsters[who]
	var foe := _enemy_of(battle, who)
	if foe == null:
		return {"type": &"pass"}
	var surge := _find(me, func(s: SkillDef): return s.kind == SkillDef.Kind.SURGE)
	var hex := _find(me, func(s: SkillDef): return _has_tag(s, ZoneEffect.Tag.DRAIN_INIT))
	var veil := _find(me, func(s: SkillDef): return _has_tag(s, ZoneEffect.Tag.SHIELD))

	var danger := _danger_from(battle, foe.id)
	var my_move := int(battle.effective_stat(me, Battle.Stat.MOVE))
	var reach: Array[Vector2i] = [me.pos]
	if my_move > 0:
		reach.append_array(battle.reachable(me, my_move))
	var threatened: bool = danger["hit"].has(me.pos) or danger["deb"].has(me.pos)
	var spots := reach.duplicate()
	spots.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		return _spot(battle, me, foe, b, danger) < _spot(battle, me, foe, a, danger))

	if threatened:
		var cut = null
		if veil != null and battle.can_cast(who, veil):
			cut = _best(battle, who, veil, rng, func(pl): return _cut_score(battle, me, foe, veil, pl))
		var safe := spots.filter(func(c: Vector2i): return _cell_risk(battle, c, danger) <= 0.7)
		if cut != null and cut["score"] >= 6.0 and (safe.is_empty() or rng.randf() < 0.4):
			return _cast_action(veil, cut)
		if not safe.is_empty():
			return {"type": &"move", "to": safe[0]}
		if cut != null and cut["score"] >= 6.0:
			return _cast_action(veil, cut)
		return {"type": &"pass"}

	if surge != null and battle.can_cast(who, surge):
		var b = _best(battle, who, surge, rng, func(pl): return _surge_score(battle, me, foe, surge, pl))
		if b != null and b["score"] >= 1.2:
			return _cast_action(surge, b)
	if hex != null and battle.can_cast(who, hex):
		var b = _best(battle, who, hex, rng, func(pl): return _hex_score(battle, me, foe, hex, pl))
		if b != null and b["score"] >= 3.0:
			return _cast_action(hex, b)
	var best: Vector2i = spots[0]
	if best != me.pos and _spot(battle, me, foe, best, danger) > _spot(battle, me, foe, me.pos, danger) + 0.6:
		return {"type": &"move", "to": best}
	return {"type": &"pass"}


## Plays a whole turn (spend AP, then end it).
static func play_turn(battle: Battle, who: StringName, rng: RandomNumberGenerator) -> void:
	while battle.can_act(who):
		var a := decide(battle, who, rng)
		var ok := false
		match a["type"]:
			&"move":
				ok = battle.move(who, a["to"])
			&"cast":
				ok = battle.cast(who, a["skill"], a["oi"], a["anchor"])
		if not ok:
			break
	battle.end_turn()


# ---------- helpers ----------

static func _cast_action(skill: SkillDef, pl: Dictionary) -> Dictionary:
	return {"type": &"cast", "skill": skill, "oi": pl["oi"], "anchor": pl["anchor"]}


static func _enemy_of(battle: Battle, who: StringName) -> Monster:
	for id in battle.roster:
		if id != who and battle.monsters[id].is_alive():
			return battle.monsters[id]
	return null


static func _find(m: Monster, pred: Callable) -> SkillDef:
	for s in m.skills:
		if pred.call(s):
			return s
	return null


static func _has_tag(s: SkillDef, tag: ZoneEffect.Tag) -> bool:
	if s.kind != SkillDef.Kind.ZONE or s.zone == null:
		return false
	for e in s.zone.effects:
		if e.tag == tag:
			return true
	return false


## Squares and debris neighbours the enemy's pending Surges will hurt.
static func _danger_from(battle: Battle, owner: StringName) -> Dictionary:
	var hit := {}
	var deb := {}
	for sq: Square in battle.board.all_squares():
		if sq.surge == null or sq.surge["owner"] != owner or sq.elevated:
			continue
		if sq.object != null:
			if sq.object["hp"] - Rules.SURGE_PROP_DAMAGE <= 0:
				for n in battle.board.neighbors(sq.pos):
					deb[n] = true
		else:
			var v := sq.surge_damage(sq.surge["aspect"], sq.surge["value"])
			if v > 0:
				hit[sq.pos] = v
	return {"hit": hit, "deb": deb}


static func _cell_risk(battle: Battle, c: Vector2i, danger: Dictionary) -> float:
	var sq := battle.board.at(c)
	var r := 0.0
	if danger["hit"].has(c):
		r += minf(3.0, danger["hit"][c] * 1.1)
	if danger["deb"].has(c):
		r += 1.0
	if sq.ground == Square.GroundType.LAVA:
		r += sq.lava_level * 1.2
	if sq.zone != null:
		for e in sq.zone["def"].effective(sq.zone["level"], sq.attunement):
			match e["tag"]:
				ZoneEffect.Tag.SLOW, ZoneEffect.Tag.PULL, ZoneEffect.Tag.PUSH:
					r += 0.6
				ZoneEffect.Tag.DRAIN_INIT, ZoneEffect.Tag.DRAIN_RANGE:
					r += 0.5
	if sq.ground == Square.GroundType.VOIDSCAR:
		r += 1.5
	return r


static func _spot(battle: Battle, me: Monster, foe: Monster, c: Vector2i, danger: Dictionary) -> float:
	var sq := battle.board.at(c)
	var s := -_cell_risk(battle, c, danger) * 2.0
	if sq.elevated:
		s += 1.5
	if sq.attunement == me.aspect:
		s += 0.6
	elif sq.attunement == foe.aspect:
		s -= 0.3
	return s - 0.4 * absf(Board.manhattan(c, foe.pos) - 3)


static func _best(battle: Battle, who: StringName, skill: SkillDef, rng: RandomNumberGenerator, score: Callable):
	var best = null
	for pl in battle.all_placements(who, skill):
		var sc: float = score.call(pl)
		if best == null or sc > best["score"] + 1e-9 \
				or (absf(sc - best["score"]) < 1e-9 and rng.randf() < 0.3):
			best = {"oi": pl["oi"], "anchor": pl["anchor"], "cells": pl["cells"], "score": sc}
	return best


static func _surge_score(battle: Battle, me: Monster, foe: Monster, surge: SkillDef, pl: Dictionary) -> float:
	var vals := {}
	for c: Vector2i in pl["cells"]:
		var sq := battle.board.at(c)
		if Rules.preview_cell(surge, sq)["kind"] == &"lost" or sq.object != null:
			vals[c] = 0
		else:
			vals[c] = sq.surge_damage(surge.aspect, surge.value)
	var any := false
	for v in vals.values():
		if v > 0:
			any = true
	if not any:
		return -9.0
	var deb := {}
	for c: Vector2i in pl["cells"]:
		var o = battle.board.at(c).object
		if o != null and o["hp"] - Rules.SURGE_PROP_DAMAGE <= 0:
			for n in battle.board.neighbors(c):
				deb[n] = true
	var hurts := func(c: Vector2i) -> bool: return vals.get(c, 0) > 0 or deb.has(c)
	var fmv := int(battle.effective_stat(foe, Battle.Stat.MOVE))
	var f_reach: Array[Vector2i] = [foe.pos]
	if fmv > 0:
		f_reach.append_array(battle.reachable(foe, fmv))
	var unsafe := 0
	for c in f_reach:
		if hurts.call(c):
			unsafe += 1
	var dmg := maxi(vals.get(foe.pos, 0), 1 if hurts.call(foe.pos) else 0)
	var sc: float
	if not hurts.call(foe.pos):
		sc = 0.2 * 3.0 * unsafe / f_reach.size() if unsafe > 0 else 0.0
	else:
		sc = dmg * (0.3 + 0.7 * unsafe / f_reach.size())
	var own: int = vals.get(me.pos, 0)
	if own > 0:
		sc -= own * 0.8
	if deb.has(me.pos):
		sc -= 1.0
	return sc


static func _hex_score(battle: Battle, me: Monster, foe: Monster, hex: SkillDef, pl: Dictionary) -> float:
	var sc := 0.0
	for c: Vector2i in pl["cells"]:
		var sq := battle.board.at(c)
		var pg := Rules.preview_cell(hex, sq)
		if c == foe.pos:
			sc += 3.0 * (0.7 if Aspect.attunement_mod(hex.aspect, sq.attunement) < 0 else 1.0)
		if c == me.pos:
			sc -= 2.5
		if pg["kind"] == &"level":
			sc += 0.3
	return sc


## How much a Veil cast would cut the enemy's pending Surge damage (own square counts most).
static func _cut_score(battle: Battle, me: Monster, foe: Monster, veil: SkillDef, pl: Dictionary) -> float:
	var sc := 0.0
	for c: Vector2i in pl["cells"]:
		var sq := battle.board.at(c)
		if sq.surge == null or sq.surge["owner"] != foe.id:
			continue
		var sg: Dictionary = sq.surge
		var before := sq.surge_damage(sg["aspect"], sg["value"])
		var pg := Rules.preview_cell(veil, sq)
		var shield := 0
		if pg["kind"] != &"cancel":
			shield = veil.zone.shield(pg["level"], sq.attunement)
		var after := 0 if sq.elevated else maxi(0, sg["value"] + Aspect.attunement_mod(sg["aspect"], sq.attunement) - shield)
		var red := before - after
		sc += red * 0.4
		if c == me.pos:
			sc += 10.0 if after == 0 else (6.0 if after <= 1 else float(red))
	return sc
