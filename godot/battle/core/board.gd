class_name Board
extends RefCounted
## The square grid of one battle: mutable board state only, no rules and no engine nodes
## (gdd_battle §4.3 square stack, §4.4 data model). Two occupancy layers: ground and air.

const GROUND := 0
const AIR := 1
const CARDINAL: Array[Vector2i] = [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]
const RING8: Array[Vector2i] = [Vector2i(0, -1), Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1),
	Vector2i(0, 1), Vector2i(-1, 1), Vector2i(-1, 0), Vector2i(-1, -1)]

var size: int
## Rings broken away from the outside (test switch BattleExperiment.soft_pressure): squares in
## them count as off the board.
var margin: int = 0
var cells: Array[BoardCell] = []
## layer -> {Vector2i: unit id}; a 2x2 body is entered on all four squares.
var occupants: Array[Dictionary] = [{}, {}]


func _init(board_size: int = 7) -> void:
	size = board_size
	for y in size:
		for x in size:
			cells.append(BoardCell.new(Vector2i(x, y)))


func in_bounds(p: Vector2i) -> bool:
	return p.x >= margin and p.y >= margin and p.x < size - margin and p.y < size - margin


func at(p: Vector2i) -> BoardCell:
	return cells[p.y * size + p.x] if in_bounds(p) else null


func centre() -> Vector2i:
	@warning_ignore("integer_division")
	return Vector2i(size / 2, size / 2)


func mirrored(p: Vector2i) -> Vector2i:
	return Vector2i(size - 1 - p.x, size - 1 - p.y)


func unit_id_at(p: Vector2i, layer: int) -> StringName:
	return occupants[layer].get(p, &"")


## The prop occupying `layer` on this square (a both-layer prop is found on either layer).
func prop_at(p: Vector2i, layer: int) -> BoardProp:
	var c := at(p)
	if c == null:
		return null
	return c.air_prop if layer == AIR else c.prop


func neighbors(p: Vector2i) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for d in CARDINAL:
		if in_bounds(p + d):
			out.append(p + d)
	return out


## Places a prop on the layer(s) of its definition.
func put_prop(prop: BoardProp) -> void:
	var c := at(prop.pos)
	if prop.def.on_ground():
		c.prop = prop
	if prop.def.in_air():
		c.air_prop = prop


func remove_prop(prop: BoardProp) -> void:
	var c := at(prop.pos)
	if c.prop == prop:
		c.prop = null
	if c.air_prop == prop:
		c.air_prop = null


## Every prop on the board once, in row order (stable).
func props() -> Array[BoardProp]:
	var out: Array[BoardProp] = []
	for c in cells:
		if c.prop != null:
			out.append(c.prop)
		if c.air_prop != null and c.air_prop != c.prop:
			out.append(c.air_prop)
	return out


static func manhattan(a: Vector2i, b: Vector2i) -> int:
	return absi(a.x - b.x) + absi(a.y - b.y)


## Board distance (gdd_battle §4.1): diagonals count like orthogonal steps.
static func chebyshev(a: Vector2i, b: Vector2i) -> int:
	return maxi(absi(a.x - b.x), absi(a.y - b.y))


func clone() -> Board:
	var b := Board.new(0)
	b.margin = margin
	b.size = size
	var props_seen := {}
	for c in cells:
		b.cells.append(c.clone(props_seen))
	b.occupants = [occupants[0].duplicate(), occupants[1].duplicate()]
	return b
