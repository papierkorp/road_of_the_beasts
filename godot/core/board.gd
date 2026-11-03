class_name Board
extends RefCounted
## The square grid (GDD §16): a 2D array of Square objects, no engine nodes.

## How a cast treats existing objects/monsters/surges on its squares.
enum Placement {
	AREA,   # zones and ground skills: no props
	SURGE,  # may land on props
	PROP,   # needs empty squares (no prop, monster or surge)
}

var size: int
var _squares := {}                 # Vector2i -> Square
var occupants := {}                # Vector2i -> monster id (StringName)


func _init(board_size: int = 5) -> void:
	size = board_size
	for y in size:
		for x in size:
			var p := Vector2i(x, y)
			_squares[p] = Square.new(p)


func in_bounds(p: Vector2i) -> bool:
	return p.x >= 0 and p.y >= 0 and p.x < size and p.y < size


func at(p: Vector2i) -> Square:
	return _squares.get(p)


func all_squares() -> Array:
	return _squares.values()


func neighbors(p: Vector2i) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for d in [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.DOWN, Vector2i.UP]:
		if in_bounds(p + d):
			out.append(p + d)
	return out


static func manhattan(a: Vector2i, b: Vector2i) -> int:
	return absi(a.x - b.x) + absi(a.y - b.y)


## Cells of a valid placement, or an empty array if it is illegal.
## `max_range` is the already-modified skill range (Elevated bonus, drains).
func valid_placement(rule: Placement, caster_pos: Vector2i, max_range: int,
		orientation: Dictionary, anchor_pos: Vector2i) -> Array[Vector2i]:
	var none: Array[Vector2i] = []
	if not in_bounds(anchor_pos) or manhattan(caster_pos, anchor_pos) > max_range:
		return none
	var cells := Shapes.footprint(orientation, anchor_pos)
	for c in cells:
		if not in_bounds(c):
			return none
		var sq := at(c)
		match rule:
			Placement.PROP:
				if sq.object != null or occupants.has(c) or sq.surge != null:
					return none
			Placement.AREA:
				if sq.object != null:
					return none
	return cells
