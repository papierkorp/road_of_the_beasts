class_name Rules
extends RefCounted
## Pure board rules (GDD §7, §8). No nodes, no randomness, no monster HP.
## The same preview function drives the cast preview, the AI and the tests (GDD §16).
## Surge detonation, Strikes and displacement need monsters and live in Battle.

const ZONE_TURNS := 2
const MAX_ZONE_LEVEL := 3
const MAX_GROUND_LEVEL := 2
const SURGE_PROP_DAMAGE := 2


# ---------- previews ----------

## What a zone does to a square that may already hold one (GDD §7.3).
## kind: new | level | cancel | replace ; level = resulting level.
static func zone_result(zone: ZoneDef, sq: Square) -> Dictionary:
	var z = sq.zone
	if z == null:
		return {"kind": &"new", "level": 1}
	var existing: ZoneDef = z["def"]
	if existing.id == zone.id:
		return {"kind": &"level", "level": mini(MAX_ZONE_LEVEL, z["level"] + 1)}
	if existing.opposes(zone) or zone.opposes(existing):
		return {"kind": &"cancel", "level": 0}
	return {"kind": &"replace", "level": 1}


## Zone × ground, the triangle rule (GDD §7.3): &"clear", &"boost" or &"".
static func triangle(zone_aspect: Aspect.Type, sq: Square) -> StringName:
	if not sq.is_aspect_ground():
		return &""
	var g := sq.ground_aspect()
	if Aspect.beats(zone_aspect, g):
		return &"clear"
	if zone_aspect == g and sq.level < MAX_GROUND_LEVEL:
		return &"boost"
	return &""


## Prop reaction of an aspect source hitting a prop (GDD §8.2): &"ignite", &"extinguish", &"heal" or &"".
static func prop_reaction(aspect: Aspect.Type, sq: Square, zone: ZoneDef = null) -> StringName:
	if sq.object == null:
		return &""
	if sq.has_tag("flammable"):
		if aspect == Aspect.Type.FORCE and not sq.object["burning"]:
			return &"ignite"
		if aspect == Aspect.Type.NATURE and sq.object["burning"]:
			return &"extinguish"
	if zone != null and zone.heals_props and not sq.object["healed"] and not sq.has_tag("indestructible"):
		return &"heal"
	return &""


## Full per-square preview of a cast: {kind, level?, ground?, prop?}.
## kind: new | level | replace | cancel | lost | ignite
static func preview_cell(skill: SkillDef, sq: Square) -> Dictionary:
	match skill.kind:
		SkillDef.Kind.SURGE:
			return {"kind": &"lost" if sq.surge != null else &"new"}
		SkillDef.Kind.ZONE:
			var r := zone_result(skill.zone, sq)
			r["ground"] = triangle(skill.zone.aspect, sq)
			r["prop"] = prop_reaction(skill.zone.aspect, sq, skill.zone)
			return r
		SkillDef.Kind.GROUND:
			if sq.object != null:
				return {"kind": &"ignite"} if prop_reaction(skill.aspect, sq) == &"ignite" else {"kind": &"lost"}
			if sq.ground == Square.GroundType.VOIDSCAR:
				return {"kind": &"lost"}
			if sq.ground == skill.ground_type:
				return {"kind": &"level", "level": mini(MAX_GROUND_LEVEL, sq.level + 1)}
			return {"kind": &"replace" if sq.is_aspect_ground() else &"new", "level": 1}
		SkillDef.Kind.HEIGHT:
			return {"kind": &"lost" if sq.ground == Square.GroundType.VOIDSCAR or sq.elevated else &"new"}
	return {"kind": &"new"}


# ---------- casting (zones, ground, height, props; Surges are placed by Battle) ----------

## Applies a non-Surge cast. Returns {counts: {kind: n}, cleared, boosted, ignited, extinguished, healed}.
static func cast(board: Board, owner: StringName, skill: SkillDef, cells: Array[Vector2i],
		gid: String, dir: Vector2i, anchor: Vector2i, native: bool = false) -> Dictionary:
	var out := {"counts": {}, "cleared": 0, "boosted": 0, "ignited": 0, "extinguished": 0, "healed": 0}
	for c in cells:
		var sq := board.at(c)
		if skill.kind == SkillDef.Kind.PROP:
			sq.object = Square.make_prop("Wall")
			_count(out, &"new")
			continue
		var pg := preview_cell(skill, sq)
		_count(out, pg["kind"])
		match skill.kind:
			SkillDef.Kind.ZONE:
				_apply_zone(sq, skill, pg, owner, gid, dir, anchor, native, out)
			SkillDef.Kind.GROUND:
				if pg["kind"] == &"ignite":
					sq.object["burning"] = true
					out["ignited"] += 1
				elif pg["kind"] != &"lost":
					sq.lay_ground(skill.ground_type, Square.PERMANENT)
			SkillDef.Kind.HEIGHT:
				if pg["kind"] != &"lost":
					sq.clear_ground()
					sq.attunement = Aspect.Type.NONE
					sq.elevated = true
	return out


static func _apply_zone(sq: Square, skill: SkillDef, pg: Dictionary, owner: StringName, gid: String,
		dir: Vector2i, anchor: Vector2i, native: bool, out: Dictionary) -> void:
	match pg["ground"]:
		&"clear":
			sq.clear_ground()
			sq.set_attunement(skill.zone.aspect)
			out["cleared"] += 1
		&"boost":
			sq.level = mini(MAX_GROUND_LEVEL, sq.level + 1)
			out["boosted"] += 1
	match pg["prop"]:
		&"ignite":
			sq.object["burning"] = true
			out["ignited"] += 1
		&"extinguish":
			sq.object["burning"] = false
			out["extinguished"] += 1
		&"heal":
			sq.object["hp"] = mini(sq.object["max_hp"] + 1, sq.object["hp"] + 1)
			sq.object["max_hp"] = maxi(sq.object["max_hp"], sq.object["hp"])
			sq.object["healed"] = true
			out["healed"] += 1
	if pg["kind"] == &"cancel":
		sq.zone = null
	else:
		sq.zone = {"def": skill.zone, "gid": gid, "owner": owner, "level": pg["level"],
			"duration": ZONE_TURNS + skill.duration_bonus, "dir": dir, "anchor": anchor, "native": native}


static func _count(out: Dictionary, kind: StringName) -> void:
	out["counts"][kind] = out["counts"].get(kind, 0) + 1


# ---------- round end ----------

## Zones lose a round; a fading zone repaints its square (GDD §7.2). Returns faded count.
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


## Timed ground (Surge residue) loses a round; expired → Plain, attunement stays. Returns expired count.
static func tick_ground(board: Board) -> int:
	var expired := 0
	for sq: Square in board.all_squares():
		if sq.timer == Square.PERMANENT:
			continue
		sq.timer -= 1
		if sq.timer <= 0:
			sq.clear_ground()
			expired += 1
	return expired
