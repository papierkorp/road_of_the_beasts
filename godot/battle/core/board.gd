class_name Board
extends RefCounted
## The square grid (GDD §16): a 2D array of Square objects, no engine nodes.

## How a cast treats existing props/monsters/Surges on its squares (GDD §7).
enum Placement {
	AREA,    # zones: anything goes (zones may lie on props)
	SURGE,   # Surges: anything goes (claimed squares are lost, see Rules)
	GROUND,  # Field / Raise Ground: no props (Force Fields may target flammable props)
	PROP,    # Raise Prop: no prop, monster or Surge
}

var size: int
var _squares := {}                 # Vector2i -> Square
var occupants := {}                # Vector2i -> monster id (StringName)


func _init(board_size: int = 7) -> void:
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


## True if every cell is on the board and allowed by the placement rule.
func cells_allowed(rule: Placement, cells: Array[Vector2i], allow_flammable: bool = false) -> bool:
	if cells.is_empty():
		return false
	for c in cells:
		if not in_bounds(c):
			return false
		var sq := at(c)
		match rule:
			Placement.PROP:
				if sq.object != null or occupants.has(c) or sq.surge != null:
					return false
			Placement.GROUND:
				if sq.object != null and not (allow_flammable and sq.has_tag("flammable")):
					return false
	return true
