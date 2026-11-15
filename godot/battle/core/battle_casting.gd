class_name BattleCasting
extends RefCounted
## Placement of skills that create something (gdd_skills §2): a free shape (the squares of the
## footprint, turned in quarter turns) at an anchor within Reach or next to the caster, or a base shape
## around the caster (BattleShapes). All squares must be on the board (no trimming or shifting to fit).
## Anchors use effective Reach as Manhattan distance from the caster's nearest covered square.


## Direction of a base shape around the user from the chosen anchor: the anchor is the neighbouring
## square the shape points to (ZERO for the shapes around the whole user, or if it is no neighbour).
static func shape_dir(u: BattleUnit, s: BattleSkillDef, anchor: Vector2i) -> Vector2i:
	if s.shape_dirs() == BattleShapes.NO_DIR:
		return Vector2i.ZERO
	var d := anchor - u.pos
	return d if s.shape_dirs().has(d) else Vector2i.ZERO


## Quarter turns of a free shape (free rotation for everyone; `no_rotation` switches it off). A base
## shape around the user is aimed, not turned.
static func effective_rot(u: BattleUnit, s: BattleSkillDef, rot: int) -> int:
	if rot == 0 or not BattleStats.can_rotate(u):
		return 0
	return posmod(rot, 4) if s.is_free_shape() else 0


## True if a skill other than a zone skill leaves a push zone: its push direction then follows
## the rotation of the placement (`rot_dir`), so it needs no direction input of its own.
static func pushes_by_rotation(b: Battle, s: BattleSkillDef) -> bool:
	if s.kind == BattleSkillDef.ZONE:
		return false
	for op in s.ops_of(BoardOp.CREATE_ZONE):
		var z := b.content.zone(op.zone)
		if z != null and z.has_tag(FieldEffect.PUSH):
			return true
	return false


## The direction a placement points to: "up" (0, -1) turned like the footprint.
static func rot_dir(u: BattleUnit, s: BattleSkillDef, rot: int) -> Vector2i:
	return BattleSkillDef.rotated(Vector2i(0, -1), effective_rot(u, s, rot))


## The squares of a cast (possibly off the board; `error` reports that): a free shape at its anchor, or a
## base shape around the user, aimed at the anchor (a neighbouring square; the user's own for a shape
## without a direction).
static func cells(u: BattleUnit, s: BattleSkillDef, anchor: Vector2i, rot := 0) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	if s.is_free_shape():
		for o in s.offsets(effective_rot(u, s, rot)):
			out.append(anchor + o)
		return out
	var d := shape_dir(u, s, anchor)
	if d == Vector2i.ZERO and s.shape_dirs() != BattleShapes.NO_DIR:
		return out
	for o in BattleShapes.offsets(s.shape_id(), d, s.shape_extension):
		if not u.covers(u.pos + o) and not out.has(u.pos + o):
			out.append(u.pos + o)
	return out


## Why this placement is illegal ("" = legal).
static func error(b: Battle, u: BattleUnit, s: BattleSkillDef, anchor: Vector2i, dir: Vector2i, rot := 0) -> String:
	if not s.is_free_shape():
		if s.shape_dirs() != BattleShapes.NO_DIR and shape_dir(u, s, anchor) == Vector2i.ZERO:
			return ("the line must start next to %s" % u.display_name()) if s.shape_id() == BattleShapes.JAB else ("aim the %s at a square next to %s" % [s.shape_label(), u.display_name()])
		if s.shape_dirs() == BattleShapes.NO_DIR and anchor != u.pos:
			return "%s lies around %s" % [s.shape_label(), u.display_name()]
	elif s.anchor_mode == "reach":
		if not b.board.in_bounds(anchor):
			return "the anchor is off the board"
		var r := BattleStats.reach(b, u)
		var d := u.manhattan_to(anchor)
		if d > r:
			return "out of Reach: the anchor is %d away, Reach is %d" % [d, r]
	elif s.anchor_mode == "adjacent":
		if u.manhattan_to(anchor) != 1:
			return "the anchor must be next to %s" % u.display_name()
	var list := cells(u, s, anchor, rot)
	if list.is_empty():
		return "this skill has no footprint"
	for c in list:
		if not b.board.in_bounds(c):
			return "the shape does not fit on the board"
	if s.needs_direction() and not Board.CARDINAL.has(dir):
		return "choose a push direction"
	if s.kind == BattleSkillDef.TRAP and free_cells(b, list).is_empty():
		return "every square of the shape already holds a Surge or trap"
	for c in list:
		var cell := b.board.at(c)
		if s.kind == BattleSkillDef.TRAP and b.unit_at(c, Board.GROUND) != null:
			return "a trap needs monster-free squares"
		# a Surge replaces a trap on the squares it covers, but never lies on another Surge
		if s.kind == BattleSkillDef.SURGE and cell.surge >= 0 and b.surge_by_id(cell.surge).turns_left >= 0:
			return "[%d,%d] already holds a Surge" % [c.x, c.y]
		if s.kind == BattleSkillDef.GROUND:
			# ground is laid under a prop as anywhere else (user decision 2026-11-13); only the removed
			# height operation still needs a prop-free square
			if s.has_op(BoardOp.RAISE_MOUNTAIN) and cell.prop != null:
				return "[%d,%d] holds a %s: height needs a prop-free square" % [c.x, c.y, cell.prop.def.display_name]
			for op in s.ops_of(BoardOp.CREATE_PROP):
				var def := b.content.prop(op.prop)
				if def == null:
					return "unknown prop '%s'" % op.prop
				if not def.creatable_by_skill:
					return "%s cannot be created by a skill" % def.display_name
				if not BattleBoardOps.can_place_prop(b, def, c):
					return "[%d,%d] is not empty: props need empty squares" % [c.x, c.y]
	return ""


## The squares of a trap footprint that hold no marker yet: a trap is only laid there.
static func free_cells(b: Battle, list: Array[Vector2i]) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for c in list:
		if b.board.at(c).surge < 0:
			out.append(c)
	return out


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
	if not s.is_free_shape():                     # a base shape: the user's own square, or the neighbours it may point to
		var own: Array[Vector2i] = [u.pos]
		for d in s.shape_dirs():
			if d != Vector2i.ZERO:
				own.append(u.pos + d)
		for p in own:
			if error(b, u, s, p, dir, rot) == "":
				out.append(p)
		return out
	for cell in b.board.cells:
		if error(b, u, s, cell.pos, dir, rot) == "":
			out.append(cell.pos)
	return out
