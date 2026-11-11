class_name BattleCasting
extends RefCounted
## Placement of anchored skills: Surges, zones and immediate board skills (gdd_skills §2
## spatial and area contracts). Footprints are explicit offsets with a fixed board orientation;
## all cells must be on the board (no trimming, shifting or rotation to fit). Anchors use
## effective Reach as Manhattan distance from the caster's nearest covered square.


## Turns an offset authored along +x into direction `d` (trail footprints).
static func _turned(o: Vector2i, d: Vector2i) -> Vector2i:
	if d == Vector2i(1, 0):
		return o
	if d == Vector2i(0, 1):
		return Vector2i(-o.y, o.x)
	if d == Vector2i(-1, 0):
		return Vector2i(-o.x, -o.y)
	return Vector2i(o.y, -o.x)


## Direction from the body to an orthogonally adjacent square (ZERO if it is not adjacent).
static func _dir_to_adjacent(u: BattleUnit, p: Vector2i) -> Vector2i:
	for c in u.cells():
		var d := p - c
		if absi(d.x) + absi(d.y) == 1 and not u.covers(p):
			return d
	return Vector2i.ZERO


## Rotation is the owner-scoped Adaptive permission; fixed otherwise.
static func effective_rot(u: BattleUnit, s: BattleSkillDef, rot: int) -> int:
	if rot == 0 or not BattleStats.can_rotate(u):
		return 0
	return posmod(rot, 4) if (s.anchor_mode == "reach" or s.anchor_mode == "adjacent") else 0


## Footprint cells of a cast (possibly off the board; `error` reports that).
static func cells(u: BattleUnit, s: BattleSkillDef, anchor: Vector2i, rot := 0) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	match s.anchor_mode:
		"caster_ring":
			for c in u.cells():
				for d in Board.CARDINAL:
					var q: Vector2i = c + d
					if not u.covers(q) and not out.has(q):
						out.append(q)
		"trail":
			var d := _dir_to_adjacent(u, anchor)
			if d != Vector2i.ZERO:
				for o in s.footprint:
					out.append(anchor + _turned(o, d))
		_:
			for o in s.offsets(effective_rot(u, s, rot)):
				out.append(anchor + o)
	return out


## Why this placement is illegal ("" = legal).
static func error(b: Battle, u: BattleUnit, s: BattleSkillDef, anchor: Vector2i, dir: Vector2i, rot := 0) -> String:
	match s.anchor_mode:
		"reach":
			if not b.board.in_bounds(anchor):
				return "the anchor is off the board"
			var r := BattleStats.reach(b, u)
			var d := u.manhattan_to(anchor)
			if d > r:
				return "out of Reach: the anchor is %d away, Reach is %d" % [d, r]
		"adjacent":
			if u.manhattan_to(anchor) != 1:
				return "the anchor must be next to %s" % u.display_name()
		"trail":
			if _dir_to_adjacent(u, anchor) == Vector2i.ZERO:
				return "the line must start next to %s" % u.display_name()
	var list := cells(u, s, anchor, rot)
	if list.is_empty():
		return "this skill has no footprint"
	for c in list:
		if not b.board.in_bounds(c):
			return "the shape does not fit on the board"
	if s.needs_direction() and not Board.CARDINAL.has(dir):
		return "choose a push direction"
	for c in list:
		var cell := b.board.at(c)
		if s.kind == BattleSkillDef.SURGE and cell.surge >= 0:
			return "[%d,%d] is already claimed by a charging Surge" % [c.x, c.y]
		if s.kind == BattleSkillDef.GROUND:
			if (s.has_op(BoardOp.GROUND) or s.has_op(BoardOp.RAISE_MOUNTAIN)) and cell.prop != null:
				return "[%d,%d] holds a %s: ground and height need prop-free squares" % [c.x, c.y, cell.prop.def.display_name]
			for op in s.ops_of(BoardOp.CREATE_PROP):
				var def := b.content.prop(op.prop)
				if def == null:
					return "unknown prop '%s'" % op.prop
				if not def.creatable_by_skill:
					return "%s cannot be created by a skill" % def.display_name
				if not BattleBoardOps.can_place_prop(b, def, c):
					return "[%d,%d] is not empty: props need empty squares" % [c.x, c.y]
	return ""


## Squares on which a Surge cast now would also hit air-layer monsters through the Mountain
## rule: the owner stands on a Mountain and the footprint square is one of the eight squares
## adjacent to it. Fixed at cast (gdd_battle §4.7).
static func mountain_air_cells(b: Battle, u: BattleUnit, list: Array[Vector2i]) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	if not BattleStats.on_mountain(b, u):
		return out
	for c in list:
		if u.chebyshev_to(c) == 1:
			out.append(c)
	return out


## Every legal anchor of a skill for the given direction and rotation (UI and AI).
static func anchors(b: Battle, u: BattleUnit, s: BattleSkillDef, dir: Vector2i, rot := 0) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	if s.anchor_mode == "caster_ring":
		if error(b, u, s, u.pos, dir, rot) == "":
			out.append(u.pos)
		return out
	for cell in b.board.cells:
		if error(b, u, s, cell.pos, dir, rot) == "":
			out.append(cell.pos)
	return out
