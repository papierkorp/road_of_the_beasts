class_name Rules
extends RefCounted
## Pure battle rules (GDD §7, §9, §11, §16). No nodes, no randomness.
## Monster HP is not owned here: resolution returns events the caller applies.

const ZONE_TURNS := 2
const MAX_ZONE_LEVEL := 3
const MAX_LAVA_LEVEL := 2
const SURGE_PROP_DAMAGE := 2
const OPPOSED := [[&"bog", &"gale"]]    # data table, add pairs later


static func opposed(a: StringName, b: StringName) -> bool:
	for p in OPPOSED:
		if (p[0] == a and p[1] == b) or (p[0] == b and p[1] == a):
			return true
	return false


# ---------- previews (pure, drive UI, AI and tests) ----------

## Result of casting `skill` on one square: {kind, zone?, level?}
## kind: new | level | replace | cancel | lost
static func preview_cell(skill: SkillDef, sq: Square) -> Dictionary:
	match skill.kind:
		SkillDef.Kind.SURGE:
			return {"kind": &"lost" if sq.surge != null else &"new"}
		SkillDef.Kind.ZONE:
			return _preview_zone(skill, sq)
		SkillDef.Kind.GROUND:
			if sq.ground == Square.GroundType.VOIDSCAR:
				return {"kind": &"lost"}
			if sq.ground == Square.GroundType.LAVA:
				return {"kind": &"level", "level": mini(MAX_LAVA_LEVEL, sq.lava_level + 1)}
			return {"kind": &"new", "level": 1}
	return {"kind": &"new"}


static func _preview_zone(skill: SkillDef, sq: Square) -> Dictionary:
	var z = sq.zone
	if z == null:
		return {"kind": &"new", "level": 1}
	var existing: StringName = z["def"].id
	if existing == skill.zone.id:
		return {"kind": &"level", "level": mini(MAX_ZONE_LEVEL, z["level"] + 1)}
	if opposed(existing, skill.zone.id):
		return {"kind": &"cancel"}
	return {"kind": &"replace", "level": 1}


## Designed zone x ground reactions: &"cool", &"fan" or &"" (GDD §7.3).
static func zone_on_ground(skill: SkillDef, sq: Square) -> StringName:
	if skill.kind != SkillDef.Kind.ZONE or sq.ground != Square.GroundType.LAVA:
		return &""
	if skill.zone.id == &"bog":
		return &"cool"
	if skill.zone.id == &"gale" and sq.lava_level < MAX_LAVA_LEVEL:
		return &"fan"
	return &""


# ---------- casting ----------

## Applies one cast to its cells. Returns {counts: {kind: n}, cool: n, fan: n}.
static func cast(board: Board, owner: StringName, skill: SkillDef,
		cells: Array[Vector2i], gid: String) -> Dictionary:
	var out := {"counts": {}, "cool": 0, "fan": 0}
	for c in cells:
		var sq := board.at(c)
		if skill.kind == SkillDef.Kind.PROP:
			sq.object = {"name": "Wall", "hp": 2, "max_hp": 2}
			continue
		var pg := preview_cell(skill, sq)
		out["counts"][pg["kind"]] = out["counts"].get(pg["kind"], 0) + 1
		if pg["kind"] == &"lost":
			continue
		match skill.kind:
			SkillDef.Kind.SURGE:
				sq.surge = {"owner": owner, "aspect": skill.aspect, "name": skill.display_name,
					"value": skill.value, "gid": gid}
			SkillDef.Kind.HEIGHT:   # Raise Ground cleanses lava and attunement
				sq.elevated = true
				sq.ground = Square.GroundType.PLAIN
				sq.lava_level = 1
				sq.attunement = Aspect.Type.NONE
			SkillDef.Kind.GROUND:
				sq.ground = Square.GroundType.LAVA
				sq.lava_level = pg["level"]
				if not sq.elevated:
					sq.attunement = Aspect.Type.FORCE
			SkillDef.Kind.ZONE:
				var reaction := zone_on_ground(skill, sq)
				if reaction == &"cool":
					sq.ground = Square.GroundType.RUBBLE
					sq.lava_level = 1
					sq.attunement = Aspect.Type.NONE
					out["cool"] += 1
				elif reaction == &"fan":
					sq.lava_level = MAX_LAVA_LEVEL
					out["fan"] += 1
				if pg["kind"] == &"cancel":
					sq.zone = null
				else:
					sq.zone = {"def": skill.zone, "gid": gid, "owner": owner,
						"level": pg["level"], "duration": ZONE_TURNS}
	return out


# ---------- resolution ----------

## Detonates every Surge due after `who`'s turn (GDD §11.2).
## Returns events: {type: damage|absorbed|prop_hit|shatter|collapse, ...}.
## Damage events must be applied to monster HP by the caller.
static func fire_due(board: Board, who: StringName) -> Array[Dictionary]:
	var events: Array[Dictionary] = []
	var debris: Array[Vector2i] = []
	for sq: Square in board.all_squares():
		if sq.surge == null or sq.surge["owner"] == who:
			continue
		var sg: Dictionary = sq.surge
		sq.surge = null
		var target = board.occupants.get(sq.pos)
		if sq.elevated:                       # Elevated blanks the square
			continue
		if sq.object != null:
			sq.object["hp"] -= SURGE_PROP_DAMAGE
			events.append({"type": &"prop_hit", "pos": sq.pos, "hp": maxi(0, sq.object["hp"])})
			if sq.object["hp"] <= 0:
				sq.object = null
				sq.ground = Square.GroundType.RUBBLE
				sq.lava_level = 1
				sq.attunement = Aspect.Type.NONE
				debris.append(sq.pos)
				events.append({"type": &"shatter", "pos": sq.pos})
			continue
		var dmg := sq.surge_damage(sg["aspect"], sg["value"])
		if target != null:
			if dmg > 0:
				events.append({"type": &"damage", "target": target, "amount": dmg, "source": sg["name"]})
			else:
				events.append({"type": &"absorbed", "target": target})
		sq.set_attunement(sg["aspect"])        # the Surge repaints what it struck
	var seen := {}
	for d in debris:
		for n in board.neighbors(d):
			if seen.has(n):
				continue
			seen[n] = true
			if board.occupants.has(n):
				events.append({"type": &"damage", "target": board.occupants[n], "amount": 1, "source": "Debris"})
			var nsq := board.at(n)
			if nsq.elevated:
				nsq.elevated = false
				nsq.ground = Square.GroundType.RUBBLE
				nsq.lava_level = 1
				nsq.attunement = Aspect.Type.NONE
				events.append({"type": &"collapse", "pos": n})
	return events


## Round end: zones lose a round; a fading zone repaints its square. Returns faded count.
static func tick_zones(board: Board) -> int:
	var faded := 0
	for sq: Square in board.all_squares():
		if sq.zone == null:
			continue
		sq.zone["duration"] -= 1
		if sq.zone["duration"] <= 0:
			sq.set_attunement(sq.zone["def"].aspect)
			sq.zone = null
			faded += 1
	return faded
