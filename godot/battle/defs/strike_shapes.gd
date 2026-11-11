class_name StrikeShapes
extends RefCounted
## Strike shapes around the body (gdd_skills §8.1, offsets per orientation table).
## A shape is data: legal directions, hit offsets from the origin and, for cells that lie
## behind another hit cell, the cell whose solid prop blocks them. Adding a shape is one entry.

const STRAIGHT: Array[Vector2i] = [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]
const DIAGONAL: Array[Vector2i] = [Vector2i(1, -1), Vector2i(1, 1), Vector2i(-1, 1), Vector2i(-1, -1)]
const ALL8: Array[Vector2i] = [Vector2i(0, -1), Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1),
	Vector2i(0, 1), Vector2i(-1, 1), Vector2i(-1, 0), Vector2i(-1, -1)]
## Symmetric shapes take no direction.
const NO_DIR: Array[Vector2i] = [Vector2i.ZERO]

## name, battle-AP (gdd_skills §8.1) and legal directions: "8", "straight", "diagonal" or "none".
const SHAPES := {
	&"jab": {"name": "Jab", "ap": 2, "dirs": "8"},
	&"thrust": {"name": "Thrust", "ap": 3, "dirs": "straight"},
	&"diagonal_thrust": {"name": "Diagonal Thrust", "ap": 3, "dirs": "diagonal"},
	&"pincer": {"name": "Pincer", "ap": 3, "dirs": "8"},
	&"arc": {"name": "Arc", "ap": 3, "dirs": "8"},
	&"whirl": {"name": "Whirl", "ap": 3, "dirs": "none"},
	&"cross": {"name": "Cross", "ap": 3, "dirs": "none"},
	&"storm": {"name": "Storm", "ap": 4, "dirs": "none"},
	&"cleave": {"name": "Cleave", "ap": 5, "dirs": "straight"},
	&"long_whirl": {"name": "Long Whirl", "ap": 5, "dirs": "none"},
	&"long_cross": {"name": "Long Cross", "ap": 5, "dirs": "none"},
}
## Marker for "no cell in front" in a hit entry.
const NONE := Vector2i(99, 99)


static func has(shape: StringName) -> bool:
	return SHAPES.has(shape)


static func shape_name(shape: StringName) -> String:
	return SHAPES[shape]["name"]


static func ap(shape: StringName) -> int:
	return SHAPES[shape]["ap"]


static func directions(shape: StringName) -> Array[Vector2i]:
	match SHAPES[shape]["dirs"]:
		"8":
			return ALL8
		"straight":
			return STRAIGHT
		"diagonal":
			return DIAGONAL
	return NO_DIR


static func is_legal_dir(shape: StringName, dir: Vector2i) -> bool:
	return directions(shape).has(dir)


## Hit entries [{o: offset from the origin, front: offset of the cell in front or NONE}].
## A solid prop on `front` takes the hit and blocks `o` (gdd_skills §3 Strike).
static func hits(shape: StringName, d: Vector2i) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	match shape:
		&"jab":
			out.append(_hit(d))
		&"thrust", &"diagonal_thrust":
			out.append(_hit(d))
			out.append(_hit(d * 2, d))
		&"pincer":
			out.append(_hit(d))
			out.append(_hit(-d))
		&"arc":
			if d.x == 0 or d.y == 0:
				var p := Vector2i(absi(d.y), absi(d.x))
				out.append(_hit(d))
				out.append(_hit(d + p))
				out.append(_hit(d - p))
			else:
				out.append(_hit(Vector2i(d.x, 0)))
				out.append(_hit(d))
				out.append(_hit(Vector2i(0, d.y)))
		&"whirl":
			for c in STRAIGHT:
				out.append(_hit(c))
		&"cross":
			for c in DIAGONAL:
				out.append(_hit(c))
		&"storm":
			for c in ALL8:
				out.append(_hit(c))
		&"cleave":
			var q := Vector2i(absi(d.y), absi(d.x))
			for k in [-1, 0, 1]:
				out.append(_hit(q * k + d))
			for k in [-1, 0, 1]:
				out.append(_hit(q * k + d * 2, q * k + d))
		&"long_whirl":
			for c in STRAIGHT:
				out.append(_hit(c))
				out.append(_hit(c * 2, c))
		&"long_cross":
			for c in DIAGONAL:
				out.append(_hit(c))
				out.append(_hit(c * 2, c))
	return out


static func _hit(o: Vector2i, front: Vector2i = NONE) -> Dictionary:
	return {"o": o, "front": front}


## Self-retreat direction (gdd_skills §3): opposite the centre of the hit shape, only if that
## centre lies on one of the eight directions. Vector2i.ZERO = this shape has no retreat.
static func retreat_dir(shape: StringName, d: Vector2i) -> Vector2i:
	var sum := Vector2i.ZERO
	for h in hits(shape, d):
		sum += h["o"]
	if sum == Vector2i.ZERO:
		return Vector2i.ZERO
	if sum.x != 0 and sum.y != 0 and absi(sum.x) != absi(sum.y):
		return Vector2i.ZERO
	return -Vector2i(signi(sum.x), signi(sum.y))
