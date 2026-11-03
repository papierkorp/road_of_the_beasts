class_name Shapes
extends RefCounted
## Tetris shape families and their orientations (GDD §7.7).
## Orientations are generated once: rotate + mirror, normalised, de-duplicated.
## Each orientation is {cells: Array[Vector2i], anchor: Vector2i} where the anchor
## is the cell nearest the centroid (first one in y-then-x order on ties).

const BASE := {
	&"I2": [Vector2i(0, 0), Vector2i(1, 0)],
	&"I3": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)],
	&"L3": [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1)],
	&"O4": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)],
	&"T4": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1)],
	&"S4": [Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1)],
	&"L4": [Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(1, 2)],
}

static var _cache := {}


## All distinct orientations for the given families, in a stable order.
static func orientations(families: Array) -> Array[Dictionary]:
	var key := ""
	for f in families:
		key += str(f) + ","
	if _cache.has(key):
		return _cache[key]
	var seen := {}
	var out: Array[Dictionary] = []
	for family in families:
		for mirrored in [false, true]:
			var cells: Array[Vector2i] = []
			for c: Vector2i in BASE[StringName(family)]:
				cells.append(Vector2i(-c.x if mirrored else c.x, c.y))
			for _r in 4:
				var rotated: Array[Vector2i] = []
				for c in cells:
					rotated.append(Vector2i(-c.y, c.x))
				cells = rotated
				var norm := _normalise(cells)
				var k := str(norm)
				if seen.has(k):
					continue
				seen[k] = true
				out.append({"cells": norm, "anchor": _anchor(norm)})
	_cache[key] = out
	return out


static func _normalise(cells: Array[Vector2i]) -> Array[Vector2i]:
	var mn := Vector2i(1 << 30, 1 << 30)
	for c in cells:
		mn = Vector2i(mini(mn.x, c.x), mini(mn.y, c.y))
	var norm: Array[Vector2i] = []
	for c in cells:
		norm.append(c - mn)
	norm.sort_custom(func(a: Vector2i, b: Vector2i): return a.y < b.y or (a.y == b.y and a.x < b.x))
	return norm


static func _anchor(cells: Array[Vector2i]) -> Vector2i:
	var cx := 0.0
	var cy := 0.0
	for c in cells:
		cx += c.x
		cy += c.y
	cx /= cells.size()
	cy /= cells.size()
	var best := cells[0]
	var best_d := INF
	for c in cells:
		var d := (c.x - cx) * (c.x - cx) + (c.y - cy) * (c.y - cy)
		if d < best_d - 1e-9:
			best_d = d
			best = c
	return best


## Board cells covered by `orientation` when its anchor is placed at `anchor_pos`.
static func footprint(orientation: Dictionary, anchor_pos: Vector2i) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for c: Vector2i in orientation["cells"]:
		out.append(anchor_pos + c - orientation["anchor"])
	return out
