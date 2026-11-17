class_name BattleShapes
extends RefCounted
## The one shape vocabulary of the battle (gdd_skills §8.1, user decision 2026-11-15): six base shapes
## around a centre, each extended any number of times. A Strike uses them around the striker, a skill
## that creates something next to its user around the user, a prop around itself (only the shapes
## without a direction, plus its own square and the full block).
##
## Extension: every square of the base shape gets one more square behind it, away from the centre;
## for the Arc the whole row moves on in the facing direction (so Arc +1 is two rows of three).
## A shape is data: legal directions, offsets from the centre and, for every square that lies
## behind another one, the square in front of it (a solid prop there takes a Strike and shields it).

const STRAIGHT: Array[Vector2i] = [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]
## The eight neighbours: the squares of a free shape touch over an edge or a corner (user decision 2026-11-17).
const AROUND: Array[Vector2i] = [Vector2i(0, -1), Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 1), Vector2i(-1, 1), Vector2i(-1, 0), Vector2i(-1, -1)]
const DIAGONAL: Array[Vector2i] = [Vector2i(1, -1), Vector2i(1, 1), Vector2i(-1, 1), Vector2i(-1, -1)]
const ALL8: Array[Vector2i] = [Vector2i(0, -1), Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1),
	Vector2i(0, 1), Vector2i(-1, 1), Vector2i(-1, 0), Vector2i(-1, -1)]
## Shapes without a direction take none.
const NO_DIR: Array[Vector2i] = [Vector2i.ZERO]
## Marker for "no square in front" in a hit entry.
const NONE := Vector2i(99, 99)

const JAB := &"jab"
const PINCER := &"pincer"
const ARC := &"arc"
const WHIRL := &"whirl"
const CROSS := &"cross"
const STORM := &"storm"
## Only for things that include their own square (props, button squares): the square itself, and the
## full block around and including it (3×3, extended 5×5).
const SELF := &"self"
const BLOCK := &"block"
## A skill that creates something at an anchor: a number of squares the player arranges (BattleSkillDef.footprint).
const FREE := &"free"

## Base shapes: name and legal directions ("8", or "none" for the shapes around the whole centre).
const BASE := {
	JAB: {"name": "Jab", "dirs": "8"},
	PINCER: {"name": "Pincer", "dirs": "8"},
	ARC: {"name": "Arc", "dirs": "8"},
	WHIRL: {"name": "Whirl", "dirs": "none"},
	CROSS: {"name": "Cross", "dirs": "none"},
	STORM: {"name": "Storm", "dirs": "none"},
}
## Names the extended shapes had as shapes of their own (before 2026-11-15) and keep as names.
const EXTENDED_NAMES := {"jab+1": "Thrust", "arc+1": "Cleave", "whirl+1": "Long Whirl", "cross+1": "Long Cross"}
## Working AP of a Strike with 2 damage and push per shape (gdd_skills §8.1; a skill's cost is its own
## `ap_cost`, this table is the draft the Strikes of the data were authored with). Others: open.
const DRAFT_AP := {"jab": 2, "jab+1": 3, "pincer": 3, "arc": 3, "whirl": 3, "cross": 3, "storm": 4,
	"arc+1": 5, "whirl+1": 5, "cross+1": 5}
## Shapes of the data before 2026-11-15 as base shape and extension.
const LEGACY := {"thrust": ["jab", 1], "diagonal_thrust": ["jab", 1], "cleave": ["arc", 1],
	"long_whirl": ["whirl", 1], "long_cross": ["cross", 1]}


static func has(shape: StringName) -> bool:
	return BASE.has(shape)


static func key(shape: StringName, extension := 0) -> String:
	return String(shape) if extension <= 0 else "%s+%d" % [shape, extension]


## "Jab", "Thrust" (Jab +1), "Storm +1", "Jab +2".
static func shape_name(shape: StringName, extension := 0) -> String:
	if EXTENDED_NAMES.has(key(shape, extension)):
		return EXTENDED_NAMES[key(shape, extension)]
	match shape:
		SELF:
			return "own square"
		BLOCK:
			return "block %d×%d" % [3 + 2 * extension, 3 + 2 * extension]
		FREE:
			return "free"
	var base: String = BASE[shape]["name"] if BASE.has(shape) else String(shape)
	return base if extension <= 0 else "%s +%d" % [base, extension]


## -1 = no draft value for this shape.
static func draft_ap(shape: StringName, extension := 0) -> int:
	return int(DRAFT_AP.get(key(shape, extension), -1))


## Directions the shape may be turned to. The extended Arc is straight only (user decision
## 2026-11-11: no diagonal Cleave); shapes around the whole centre take no direction.
static func directions(shape: StringName, extension := 0) -> Array[Vector2i]:
	if not BASE.has(shape) or BASE[shape]["dirs"] == "none":
		return NO_DIR
	if shape == ARC and extension > 0:
		return STRAIGHT
	return ALL8


static func is_legal_dir(shape: StringName, dir: Vector2i, extension := 0) -> bool:
	return directions(shape, extension).has(dir)


## Entries [{o: offset from the centre, front: offset of the square in front of it or NONE}], arm by
## arm from the centre outward (the Arc: row by row).
static func hits(shape: StringName, d: Vector2i, extension := 0) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	if shape == ARC:
		if d.x == 0 or d.y == 0:
			var p := Vector2i(absi(d.y), absi(d.x))
			for row in range(1, extension + 2):
				for side: int in [0, 1, -1]:
					var o: Vector2i = p * side + d * row
					out.append(_hit(o, NONE if row == 1 else o - d))
		else:                                     # the diagonal wedge has no extension
			out.append(_hit(Vector2i(d.x, 0)))
			out.append(_hit(d))
			out.append(_hit(Vector2i(0, d.y)))
		return out
	for c in _arms(shape, d):
		for step in range(1, extension + 2):
			out.append(_hit(c * step, NONE if step == 1 else c * (step - 1)))
	return out


## The offsets only.
static func offsets(shape: StringName, d: Vector2i, extension := 0) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	match shape:
		SELF:
			out.append(Vector2i.ZERO)
		BLOCK:
			var r := 1 + extension
			for y in range(-r, r + 1):
				for x in range(-r, r + 1):
					out.append(Vector2i(x, y))
		_:
			for h in hits(shape, d, extension):
				out.append(h["o"])
	return out


## How many squares the shape covers.
static func count(shape: StringName, extension := 0) -> int:
	return offsets(shape, directions(shape, extension)[0], extension).size()


## The directions from the centre to the base squares ("arms"); every arm grows by extension.
static func _arms(shape: StringName, d: Vector2i) -> Array[Vector2i]:
	match shape:
		JAB:
			return [d]
		PINCER:
			return [d, -d]
		WHIRL:
			return STRAIGHT
		CROSS:
			return DIAGONAL
		STORM:
			return ALL8
	return []


static func _hit(o: Vector2i, front: Vector2i = NONE) -> Dictionary:
	return {"o": o, "front": front}


## Self-retreat direction (gdd_skills §8.1): opposite the centre of the shape, only if that centre
## lies on one of the eight directions. Vector2i.ZERO = this shape has no retreat.
static func retreat_dir(shape: StringName, d: Vector2i, extension := 0) -> Vector2i:
	var sum := Vector2i.ZERO
	for h in hits(shape, d, extension):
		sum += h["o"]
	if sum == Vector2i.ZERO:
		return Vector2i.ZERO
	if sum.x != 0 and sum.y != 0 and absi(sum.x) != absi(sum.y):
		return Vector2i.ZERO
	return -Vector2i(signi(sum.x), signi(sum.y))


## Why `cells` is no legal arrangement of a free shape of `squares` squares ("" = legal): exactly that
## many different squares, the anchor (0, 0) among them, all touching over an edge or a corner.
static func arrangement_error(cells: Array, squares: int) -> String:
	if cells.size() != squares:
		return "the shape has %d square%s, not %d" % [squares, "" if squares == 1 else "s", cells.size()]
	var seen := {}
	for c: Vector2i in cells:
		if seen.has(c):
			return "a square is listed twice"
		seen[c] = true
	if not seen.has(Vector2i.ZERO):
		return "the anchor square must be part of the shape"
	var open: Array[Vector2i] = [Vector2i.ZERO]
	var reached := {Vector2i.ZERO: true}
	while not open.is_empty():
		var c: Vector2i = open.pop_back()
		for d in AROUND:
			if seen.has(c + d) and not reached.has(c + d):
				reached[c + d] = true
				open.append(c + d)
	return "" if reached.size() == squares else "the squares must touch each other, over an edge or a corner"


## A free shape as text, row by row from the top: "■■/■·" (the anchor is one of the squares).
static func arrangement_text(cells: Array) -> String:
	if cells.is_empty():
		return ""
	var lo := Vector2i(99, 99)
	var hi := Vector2i(-99, -99)
	for c: Vector2i in cells:
		lo = Vector2i(mini(lo.x, c.x), mini(lo.y, c.y))
		hi = Vector2i(maxi(hi.x, c.x), maxi(hi.y, c.y))
	var rows: PackedStringArray = []
	for y in range(lo.y, hi.y + 1):
		var row := ""
		for x in range(lo.x, hi.x + 1):
			row += "■" if cells.has(Vector2i(x, y)) else "·"
		rows.append(row)
	return "/".join(rows)
