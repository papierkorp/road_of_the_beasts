class_name MiniBoard
extends Control
## A battleground in small, painted like the board of the battle: paper squares with an ink edge, a wash of the
## ground's colour, rings on a Dragon Vein, a block for a solid prop, a ring for a trap, an arrow for a zone and a
## band in the colour of a side along its start area. It shows a MapDef and decides nothing.

var map: MapDef
var cell := 20.0


static func of(p_map: MapDef, p_cell := 20.0) -> MiniBoard:
	var b := MiniBoard.new()
	b.map = p_map
	b.cell = p_cell
	b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	if p_map != null:
		b.custom_minimum_size = Vector2(p_map.width, p_map.height) * p_cell + Vector2(4, 4)
	return b


func _draw() -> void:
	if map == null:
		return
	var content := BattleContent.shared()
	var paper := Color(0.80, 0.75, 0.64)
	var ink := UiTheme.INK
	var origin := Vector2(2, 2)
	draw_rect(Rect2(Vector2.ZERO, Vector2(map.width, map.height) * cell + Vector2(4, 4)), ink)
	for y in map.height:
		for x in map.width:
			var p := Vector2i(x, y)
			var at := origin + Vector2(x, y) * cell
			var box := Rect2(at + Vector2(1, 1), Vector2(cell - 2, cell - 2))
			if not map.has_square(p):
				draw_rect(Rect2(at, Vector2(cell, cell)), UiTheme.PAPER)
				continue
			var wash := paper
			var gid: StringName = map.grounds.get(p, GroundDef.PLAIN)
			var g := content.ground(gid)
			if g != null and gid != GroundDef.PLAIN:
				wash = paper.lerp(g.color, 0.65)
			draw_rect(box, wash)
			for side in 2:
				if map.start_area(side).has(p):
					draw_rect(Rect2(box.position, Vector2(box.size.x, maxf(2.0, cell * 0.16))), Color(UiTheme.SIDE[side], 0.9))
			var mid := at + Vector2(cell, cell) * 0.5
			if gid == GroundDef.WELL:
				draw_arc(mid, cell * 0.30, 0, TAU, 20, wash.darkened(0.6), maxf(1.5, cell * 0.08), true)
				draw_circle(mid, cell * 0.09, wash.darkened(0.6))
			if map.zones.has(p):
				var z: Dictionary = map.zones[p]
				var zdef := content.zone(z.get("zone", &""))
				var zc := (zdef.color if zdef != null else UiTheme.INK_SOFT).darkened(0.35)
				var d: Vector2 = Vector2(z.get("dir", Vector2i.ZERO))
				if d == Vector2.ZERO:
					draw_arc(mid, cell * 0.26, 0.4, TAU - 0.4, 14, zc, maxf(1.5, cell * 0.09), true)
				else:
					var tip := mid + d * cell * 0.32
					var side_v := Vector2(-d.y, d.x) * cell * 0.22
					draw_colored_polygon(PackedVector2Array([tip, mid - d * cell * 0.2 + side_v, mid - d * cell * 0.2 - side_v]), zc)
			if map.props.has(p):
				var prop := content.prop(map.props[p])
				if prop != null and prop.solid:
					var inner := Rect2(at + Vector2(cell, cell) * 0.22, Vector2(cell, cell) * 0.56)
					draw_rect(inner, prop.color.darkened(0.15))
					draw_rect(inner, ink, false, maxf(1.0, cell * 0.07))
				elif prop != null:
					draw_arc(mid, cell * 0.24, 0, TAU, 16, ink, maxf(1.5, cell * 0.09), true)
