class_name BuildGrid
extends RefCounted
## The coarse building grid of the Inner World (gdd_overworld §6.4): 2 x 2 unit cells, a buildable
## area that grows with the player's stage (§6.3). Placed structures are Dictionaries of the
## GameState: {uid, id, x, y, rot, assigned, plant, grown}. Pure geometry and rules, no nodes.

const CELL := 2.0
const COLS := 8
const ROWS := 5          # cells; the strip below (the gate, the Cultivation Stone) stays free


## The cells that may be built on at a stage: barren rock first, then a growing garden.
static func region(stage: Stage.Type) -> Rect2i:
	match stage:
		Stage.Type.QI_GATHERING:
			return Rect2i(2, 1, 4, 3)
		Stage.Type.FOUNDATION:
			return Rect2i(1, 0, 6, 4)
	return Rect2i(0, 0, COLS, ROWS)


static func footprint(def: StructureDef, rot: bool) -> Vector2i:
	return Vector2i(def.size.y, def.size.x) if rot else def.size


static func cells_of(def: StructureDef, cell: Vector2i, rot: bool) -> Array[Vector2i]:
	var fp := footprint(def, rot)
	var out: Array[Vector2i] = []
	for dx in fp.x:
		for dy in fp.y:
			out.append(cell + Vector2i(dx, dy))
	return out


static func structure_cells(s: Dictionary) -> Array[Vector2i]:
	return cells_of(StructureCatalog.def(StringName(s["id"])), Vector2i(int(s["x"]), int(s["y"])), bool(s["rot"]))


## The rectangle a structure covers, in ground units.
static func world_rect(def: StructureDef, cell: Vector2i, rot: bool) -> Rect2:
	var fp := footprint(def, rot)
	return Rect2(Vector2(cell) * CELL, Vector2(fp) * CELL)


static func cell_at(p: Vector2) -> Vector2i:
	return Vector2i(floori(p.x / CELL), floori(p.y / CELL))


## `ignore_uid` lets a structure be moved onto cells it occupies itself.
static func can_place(state: GameState, def: StructureDef, cell: Vector2i, rot: bool, ignore_uid := -1) -> bool:
	var area := region(state.stage)
	var taken := {}
	for s in state.structures:
		if int(s["uid"]) == ignore_uid:
			continue
		for c in structure_cells(s):
			taken[c] = true
	for c in cells_of(def, cell, rot):
		if not area.has_point(c) or taken.has(c):
			return false
	return true


static func adjacent(a: Array[Vector2i], b: Array[Vector2i]) -> bool:
	for p in a:
		for q in b:
			if absi(p.x - q.x) + absi(p.y - q.y) == 1:
				return true
	return false


## The structure covering a cell, or an empty dictionary.
static func at_cell(state: GameState, cell: Vector2i) -> Dictionary:
	for s in state.structures:
		if structure_cells(s).has(cell):
			return s
	return {}
