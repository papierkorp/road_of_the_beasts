class_name BattleView
extends Node3D
## 3D presentation of a Battle: orthographic ~iso camera, tiles, monsters, props,
## zone/Surge/highlight overlays. Contains no rules (GDD §16).

const CELL := 1.0
const TILE := 0.92
const FLAT_H := 0.12
const HIGH_H := 0.45
const ROMAN := ["I", "II", "III"]

var battle: Battle
var camera: Camera3D
var highlights := {}           # Vector2i -> Color
var _tiles := {}               # Vector2i -> Dictionary of nodes
var _pieces := {}              # monster id -> Node3D


static func aspect_color(a: Aspect.Type) -> Color:
	match a:
		Aspect.Type.FORCE:
			return Color(0.89, 0.35, 0.23)
		Aspect.Type.NATURE:
			return Color(0.31, 0.68, 0.50)
		Aspect.Type.DARK:
			return Color(0.54, 0.39, 0.79)
	return Color(0.6, 0.6, 0.6)


func build(p_battle: Battle) -> void:
	battle = p_battle
	_build_environment()
	for sq: Square in battle.board.all_squares():
		_tiles[sq.pos] = _make_tile(sq.pos)
	for id in battle.monsters:
		_pieces[id] = _make_monster(battle.monsters[id])
	refresh()


func _build_environment() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.075, 0.082, 0.094)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.8, 0.82, 0.9)
	env.ambient_light_energy = 0.55
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, 35, 0)
	sun.light_energy = 0.9
	add_child(sun)
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 8.5
	camera.near = 0.1
	camera.far = 60.0
	add_child(camera)
	camera.position = Vector3(8, 8, 8)
	camera.look_at(Vector3(0, 0, 0), Vector3.UP)
	camera.current = true


func _cell_pos(p: Vector2i) -> Vector3:
	var half := (battle.board.size - 1) / 2.0
	return Vector3((p.x - half) * CELL, 0.0, (p.y - half) * CELL)


func _top(sq: Square) -> float:
	return HIGH_H if sq.elevated else FLAT_H


## Board cell under a screen position, or null.
func cell_at_screen(pos: Vector2) -> Variant:
	var from := camera.project_ray_origin(pos)
	var dir := camera.project_ray_normal(pos)
	if absf(dir.y) < 0.0001:
		return null
	var t := (FLAT_H - from.y) / dir.y
	var hit := from + dir * t
	var half := (battle.board.size - 1) / 2.0
	var p := Vector2i(roundi(hit.x / CELL + half), roundi(hit.z / CELL + half))
	return p if battle.board.in_bounds(p) else null


func set_highlights(map: Dictionary) -> void:
	highlights = map


# ---------- construction ----------

func _make_overlay(parent: Node3D) -> Dictionary:
	var mi := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(TILE * 0.94, TILE * 0.94)
	mi.mesh = pm
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mi.material_override = m
	mi.visible = false
	parent.add_child(mi)
	return {"node": mi, "mat": m}


func _make_label(parent: Node3D, size_px: int = 26) -> Label3D:
	var l := Label3D.new()
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.pixel_size = 0.006
	l.font_size = size_px
	l.outline_size = 10
	l.no_depth_test = true
	parent.add_child(l)
	return l


func _make_tile(p: Vector2i) -> Dictionary:
	var root := Node3D.new()
	root.position = _cell_pos(p)
	add_child(root)
	var body := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	body.mesh = mesh
	var mat := StandardMaterial3D.new()
	body.material_override = mat
	root.add_child(body)
	var label := _make_label(root, 22)
	return {
		"root": root, "body": body, "mesh": mesh, "mat": mat, "label": label,
		"zone": _make_overlay(root), "surge": _make_overlay(root), "hl": _make_overlay(root),
		"prop_key": "", "prop_node": null,
	}


func _make_monster(m: Monster) -> Node3D:
	var root := Node3D.new()
	root.name = str(m.id)
	var mi := MeshInstance3D.new()
	var cap := CapsuleMesh.new()
	cap.radius = 0.28
	cap.height = 0.8
	mi.mesh = cap
	mi.position.y = 0.4
	var mat := StandardMaterial3D.new()
	mat.albedo_color = aspect_color(m.aspect)
	mi.material_override = mat
	root.add_child(mi)
	var label := _make_label(root, 28)
	label.name = "Label"
	label.position.y = 1.25
	add_child(root)
	return root


# ---------- refresh ----------

func refresh() -> void:
	for p in _tiles:
		_update_tile(p, _tiles[p], battle.board.at(p))
	for id in _pieces:
		var m: Monster = battle.monsters[id]
		var node: Node3D = _pieces[id]
		node.visible = m.is_alive()
		if m.is_alive():
			node.position = _cell_pos(m.pos) + Vector3(0, _top(battle.board.at(m.pos)), 0)
			(node.get_node("Label") as Label3D).text = "%s\n%d/%d" % [m.display_name, m.hp, m.max_hp]


func _ground_color(sq: Square) -> Color:
	var base := Color(0.17, 0.18, 0.21)
	match sq.ground:
		Square.GroundType.RUBBLE:
			base = Color(0.29, 0.26, 0.21)
		Square.GroundType.VOIDSCAR:
			base = Color(0.10, 0.08, 0.13)
		Square.GroundType.LAVA:
			base = Color(0.55, 0.20, 0.08) if sq.lava_level == 1 else Color(0.80, 0.25, 0.08)
	if sq.elevated:
		return Color(0.18, 0.35, 0.41)
	if sq.attunement != Aspect.Type.NONE and sq.ground == Square.GroundType.PLAIN:
		return base.lerp(aspect_color(sq.attunement), 0.30)
	return base


func _set_overlay(ov: Dictionary, y: float, color: Color, shown: bool) -> void:
	var node: MeshInstance3D = ov["node"]
	node.visible = shown
	node.position.y = y
	(ov["mat"] as StandardMaterial3D).albedo_color = color


func _update_tile(p: Vector2i, t: Dictionary, sq: Square) -> void:
	var h := _top(sq)
	(t["mesh"] as BoxMesh).size = Vector3(TILE, h, TILE)
	(t["body"] as MeshInstance3D).position.y = h / 2.0
	(t["mat"] as StandardMaterial3D).albedo_color = _ground_color(sq)

	var zc := Color(1, 1, 1, 0)
	if sq.zone != null:
		zc = aspect_color(sq.zone["def"].aspect)
		zc.a = 0.45
	_set_overlay(t["zone"], h + 0.01, zc, sq.zone != null)

	var sc := Color(1, 1, 1, 0)
	if sq.surge != null:
		sc = aspect_color(sq.surge["aspect"])
		sc.a = 0.8
	_set_overlay(t["surge"], h + 0.02, sc, sq.surge != null)

	var has_hl := highlights.has(p)
	_set_overlay(t["hl"], h + 0.03, highlights.get(p, Color(1, 1, 1, 0)), has_hl)

	var lines := ""
	if sq.surge != null:
		lines += "⚠ %s\n" % sq.surge["name"]
	if sq.zone != null:
		lines += "%s %s · %dr\n" % [sq.zone["def"].display_name, ROMAN[sq.zone["level"] - 1], sq.zone["duration"]]
	if sq.ground == Square.GroundType.LAVA:
		lines += "Lava %s\n" % ROMAN[sq.lava_level - 1]
	elif sq.ground == Square.GroundType.VOIDSCAR:
		lines += "Voidscar\n"
	elif sq.attunement != Aspect.Type.NONE and sq.ground == Square.GroundType.PLAIN:
		lines += Aspect.ATTUNEMENT_NAMES[sq.attunement] + "\n"
	var label: Label3D = t["label"]
	label.text = lines.strip_edges()
	label.position.y = h + 0.12
	_update_prop(t, sq, h)


func _update_prop(t: Dictionary, sq: Square, h: float) -> void:
	var key := ""
	if sq.object != null:
		key = "%s:%d" % [sq.object["name"], sq.object["hp"]]
	if key == t["prop_key"]:
		return
	t["prop_key"] = key
	if t["prop_node"] != null:
		(t["prop_node"] as Node).queue_free()
		t["prop_node"] = null
	if sq.object == null:
		return
	var root := Node3D.new()
	root.position.y = h
	var mi := MeshInstance3D.new()
	var mat := StandardMaterial3D.new()
	match sq.object["name"]:
		"Tree":
			var cone := CylinderMesh.new()
			cone.top_radius = 0.0
			cone.bottom_radius = 0.34
			cone.height = 0.95
			mi.mesh = cone
			mi.position.y = 0.475
			mat.albedo_color = Color(0.20, 0.42, 0.24)
		"Rock":
			var box := BoxMesh.new()
			box.size = Vector3(0.6, 0.5, 0.6)
			mi.mesh = box
			mi.position.y = 0.25
			mat.albedo_color = Color(0.45, 0.47, 0.52)
		_:
			var wall := BoxMesh.new()
			wall.size = Vector3(0.8, 0.7, 0.8)
			mi.mesh = wall
			mi.position.y = 0.35
			mat.albedo_color = Color(0.40, 0.36, 0.30)
	mi.material_override = mat
	root.add_child(mi)
	var l := _make_label(root, 22)
	l.position.y = 1.15
	l.text = "%s %d/%d" % [sq.object["name"], sq.object["hp"], sq.object["max_hp"]]
	(t["root"] as Node3D).add_child(root)
	t["prop_node"] = root
