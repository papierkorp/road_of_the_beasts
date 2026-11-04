class_name BattleView
extends Node3D
## 3D presentation of a Battle: orbit camera (orthographic), shadows, glow, tiles, monsters,
## props, zone/Surge/highlight overlays, direction arrows and small animations. No rules (GDD §16).
##
## Camera: Q / E rotate by 90°, mouse wheel zooms, middle-mouse drag orbits freely.

const CELL := 1.0
const TILE := 0.92
const FLAT_H := 0.12
const HIGH_H := 0.45
const ROMAN := ["I", "II", "III"]

const PITCH := 40.0
const ZOOM_MIN := 5.0
const ZOOM_MAX := 16.0

const SIDE_COLORS := [Color(0.35, 0.62, 1.0), Color(1.0, 0.38, 0.35)]

var battle: Battle
var camera: Camera3D
var highlights := {}           # Vector2i -> Color
var preview_arrows := {}       # Vector2i -> Vector2i (direction shown while aiming)
var _tiles := {}               # Vector2i -> Dictionary of nodes
var _pieces := {}              # monster id -> Node3D
var _pivot: Node3D
var _yaw := 45.0
var _yaw_target := 45.0
var _zoom := 8.5
var _zoom_target := 8.5
var _time := 0.0


static func aspect_color(a: Aspect.Type) -> Color:
	return MonsterLook.aspect_color(a)


func build(p_battle: Battle) -> void:
	battle = p_battle
	_zoom = battle.board.size * 1.25 + 2.2
	_zoom_target = _zoom
	_build_environment()
	_build_base()
	for sq: Square in battle.board.all_squares():
		_tiles[sq.pos] = _make_tile(sq.pos)
	for id in battle.roster:
		_pieces[id] = _make_monster(battle.monsters[id])
	refresh()


func _build_environment() -> void:
	get_viewport().msaa_3d = Viewport.MSAA_4X
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.075, 0.082, 0.094)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.75, 0.78, 0.9)
	env.ambient_light_energy = 0.5
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.glow_enabled = true
	env.glow_intensity = 0.7
	env.glow_blend_mode = Environment.GLOW_BLEND_MODE_SOFTLIGHT
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-52, 30, 0)
	sun.light_energy = 1.0
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 40.0
	add_child(sun)

	_pivot = Node3D.new()
	add_child(_pivot)
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = _zoom
	camera.near = 0.1
	camera.far = 120.0
	_pivot.add_child(camera)
	camera.position = Vector3(0, 34.0 * sin(deg_to_rad(PITCH)), 34.0 * cos(deg_to_rad(PITCH)))
	camera.rotation_degrees = Vector3(-PITCH, 0, 0)
	_pivot.rotation_degrees.y = _yaw
	camera.current = true


## A dark plate under the board so it reads as an object, not floating tiles.
func _build_base() -> void:
	var plate := MeshInstance3D.new()
	var box := BoxMesh.new()
	var s := battle.board.size * CELL + 0.45
	box.size = Vector3(s, 0.4, s)
	plate.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.09, 0.085, 0.085)
	mat.roughness = 0.95
	plate.material_override = mat
	plate.position.y = -0.2
	add_child(plate)


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


## Maps a screen-relative key direction (W = up on screen) to a board direction for the current camera.
func board_dir_from_screen(screen: Vector2i) -> Vector2i:
	var yaw := deg_to_rad(_yaw_target + 0.1)       # tiny bias decides the 45° ties consistently
	var forward := Vector2(-sin(yaw), -cos(yaw))   # world x / z of the camera's view on the ground
	var right := Vector2(cos(yaw), -sin(yaw))
	var w := right * screen.x + forward * (-screen.y)
	if absf(w.x) >= absf(w.y):
		return Vector2i(signi(roundi(w.x * 10)), 0)
	return Vector2i(0, signi(roundi(w.y * 10)))


func set_highlights(map: Dictionary, arrows: Dictionary = {}) -> void:
	highlights = map
	preview_arrows = arrows


# ---------- camera + idle animation ----------

func _unhandled_input(event: InputEvent) -> void:
	if camera == null:
		return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_target = clampf(_zoom_target - 0.6, ZOOM_MIN, ZOOM_MAX)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_target = clampf(_zoom_target + 0.6, ZOOM_MIN, ZOOM_MAX)
	elif event is InputEventMouseMotion and (event.button_mask & MOUSE_BUTTON_MASK_MIDDLE) != 0:
		_yaw_target -= event.relative.x * 0.3
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_Q:
			_yaw_target -= 90.0
		elif event.keycode == KEY_E:
			_yaw_target += 90.0


func _process(delta: float) -> void:
	if camera == null:
		return
	_time += delta
	var k := 1.0 - exp(-10.0 * delta)
	_yaw = lerpf(_yaw, _yaw_target, k)
	_zoom = lerpf(_zoom, _zoom_target, k)
	_pivot.rotation_degrees.y = _yaw
	camera.size = _zoom

	var pulse := 0.6 + 0.25 * sin(_time * 4.0)
	for p in _tiles:
		var t: Dictionary = _tiles[p]
		if t["surge_on"]:
			var c: Color = t["surge_col"]
			(t["surge"]["mat"] as StandardMaterial3D).albedo_color = Color(c.r * 1.5, c.g * 1.5, c.b * 1.5, pulse)
	var i := 0
	for id in _pieces:
		var body: Node3D = (_pieces[id] as Node3D).get_node("Body")
		body.position.y = 0.4 + 0.03 * sin(_time * 2.0 + i * 1.7)
		i += 1


## A number that rises and fades above a square (damage, blocked, ...).
func floating_text(p: Vector2i, text: String, color: Color) -> void:
	var l := _make_label(self, 44)
	l.text = text
	l.modulate = color
	var start := _cell_pos(p) + Vector3(0, _top(battle.board.at(p)) + 1.4, 0)
	l.position = start
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(l, "position:y", start.y + 0.8, 0.9).set_ease(Tween.EASE_OUT)
	tw.tween_property(l, "modulate:a", 0.0, 0.6).set_delay(0.4)
	tw.chain().tween_callback(l.queue_free)


# ---------- construction ----------

func _unshaded(color: Color, transparent: bool = true) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	if transparent:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.albedo_color = color
	return m


func _make_overlay(parent: Node3D) -> Dictionary:
	var mi := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(TILE * 0.94, TILE * 0.94)
	mi.mesh = pm
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var m := _unshaded(Color(1, 1, 1, 0))
	mi.material_override = m
	mi.visible = false
	parent.add_child(mi)
	return {"node": mi, "mat": m}


func _make_arrow(parent: Node3D) -> Dictionary:
	var mi := MeshInstance3D.new()
	var cone := CylinderMesh.new()
	cone.top_radius = 0.0
	cone.bottom_radius = 0.13
	cone.height = 0.4
	cone.radial_segments = 4
	mi.mesh = cone
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var m := _unshaded(Color(1, 1, 1, 0.9))
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
	l.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
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
	mat.roughness = 0.9
	body.material_override = mat
	root.add_child(body)
	var label := _make_label(root, 20)
	return {
		"root": root, "body": body, "mesh": mesh, "mat": mat, "label": label,
		"zone": _make_overlay(root), "surge": _make_overlay(root), "hl": _make_overlay(root),
		"arrow": _make_arrow(root),
		"surge_on": false, "surge_col": Color.WHITE,
		"prop_key": "", "prop_node": null,
	}


func _kin_mesh(kin: MonsterDef.Kin) -> Mesh:
	return MonsterLook.kin_mesh(kin)


func _make_monster(m: Monster) -> Node3D:
	var root := Node3D.new()
	root.name = str(m.id)
	var mi := MeshInstance3D.new()
	mi.name = "Body"
	mi.mesh = _kin_mesh(m.kin())
	mi.position.y = 0.4
	var mat := StandardMaterial3D.new()
	mat.albedo_color = aspect_color(m.aspect())
	mat.roughness = 0.55
	if m.kin() == MonsterDef.Kin.SPIRIT:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color.a = 0.75
	mi.material_override = mat
	root.add_child(mi)
	if m.kin() == MonsterDef.Kin.SWARM:
		for off in [Vector3(0.22, -0.05, 0.12), Vector3(-0.2, -0.08, 0.16)]:
			var extra := MeshInstance3D.new()
			extra.mesh = mi.mesh
			extra.material_override = mat
			extra.position = off
			extra.scale = Vector3.ONE * 0.7
			mi.add_child(extra)

	var disc := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.36
	cyl.bottom_radius = 0.36
	cyl.height = 0.03
	disc.mesh = cyl
	disc.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	disc.material_override = _unshaded(SIDE_COLORS[m.side], false)
	disc.position.y = 0.02
	root.add_child(disc)

	var ring := MeshInstance3D.new()
	ring.name = "Ring"
	var torus := TorusMesh.new()
	torus.inner_radius = 0.40
	torus.outer_radius = 0.48
	ring.mesh = torus
	ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	ring.material_override = _unshaded(Color(1.0, 0.85, 0.45), false)
	ring.position.y = 0.04
	root.add_child(ring)

	var label := _make_label(root, 26)
	label.name = "Label"
	label.position.y = 1.25
	label.modulate = SIDE_COLORS[m.side].lerp(Color.WHITE, 0.6)
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
		if not m.is_alive():
			continue
		var target := _cell_pos(m.pos) + Vector3(0, _top(battle.board.at(m.pos)), 0)
		if not node.has_meta("target"):
			node.position = target
		elif node.get_meta("target") != target:
			var tw := create_tween()
			tw.tween_property(node, "position", target, 0.28).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		node.set_meta("target", target)
		var charging := "  ⚠" if battle.has_charging(id) else ""
		(node.get_node("Label") as Label3D).text = "%s%s\n%d/%d" % [m.display_name(), charging, m.hp, m.max_hp]
		(node.get_node("Ring") as Node3D).visible = id == battle.turn_owner and not battle.over


func _ground_color(sq: Square) -> Color:
	var base := Color(0.17, 0.18, 0.21)
	match sq.ground:
		Square.GroundType.RUBBLE:
			base = Color(0.29, 0.26, 0.21)
		Square.GroundType.VOIDSCAR:
			base = Color(0.10, 0.08, 0.13)
		Square.GroundType.LAVA:
			base = Color(0.55, 0.20, 0.08) if sq.level == 1 else Color(0.80, 0.25, 0.08)
		Square.GroundType.THORNBED:
			base = Color(0.20, 0.33, 0.16) if sq.level == 1 else Color(0.24, 0.45, 0.16)
		Square.GroundType.BLIGHT:
			base = Color(0.25, 0.13, 0.30) if sq.level == 1 else Color(0.36, 0.14, 0.42)
	if sq.elevated and not sq.is_aspect_ground():
		base = Color(0.18, 0.35, 0.41)
	elif sq.elevated:
		base = base.lerp(Color(0.18, 0.35, 0.41), 0.35)
	if sq.attunement != Aspect.Type.NONE and sq.ground == Square.GroundType.PLAIN:
		return base.lerp(aspect_color(sq.attunement), 0.30)
	return base


func _set_overlay(ov: Dictionary, y: float, color: Color, shown: bool) -> void:
	var node: MeshInstance3D = ov["node"]
	node.visible = shown
	node.position.y = y
	(ov["mat"] as StandardMaterial3D).albedo_color = color


func _set_arrow(ov: Dictionary, y: float, dir: Vector2i, color: Color) -> void:
	var node: MeshInstance3D = ov["node"]
	node.visible = dir != Vector2i.ZERO
	if dir == Vector2i.ZERO:
		return
	node.position = Vector3(0, y, 0)
	node.rotation = Vector3(deg_to_rad(90), atan2(float(dir.x), float(dir.y)), 0)
	(ov["mat"] as StandardMaterial3D).albedo_color = color


func _zone_arrow(sq: Square) -> Vector2i:
	if sq.zone == null:
		return Vector2i.ZERO
	var def: ZoneDef = sq.zone["def"]
	if def.has_tag(ZoneEffect.Tag.PUSH):
		return sq.zone["dir"]
	if def.has_tag(ZoneEffect.Tag.PULL):
		return Battle._step_toward(sq.pos, sq.zone["anchor"])
	return Vector2i.ZERO


func _update_tile(p: Vector2i, t: Dictionary, sq: Square) -> void:
	var h := _top(sq)
	(t["mesh"] as BoxMesh).size = Vector3(TILE, h, TILE)
	(t["body"] as MeshInstance3D).position.y = h / 2.0
	var mat := t["mat"] as StandardMaterial3D
	mat.albedo_color = _ground_color(sq)
	mat.emission_enabled = sq.ground == Square.GroundType.LAVA
	if mat.emission_enabled:
		mat.emission = Color(0.9, 0.3, 0.1)
		mat.emission_energy_multiplier = 0.35 * sq.level

	var zc := Color(1, 1, 1, 0)
	if sq.zone != null:
		zc = aspect_color(sq.zone["def"].aspect)
		zc.a = 0.45
	_set_overlay(t["zone"], h + 0.01, zc, sq.zone != null)

	t["surge_on"] = sq.surge != null
	var sc := Color(1, 1, 1, 0)
	if sq.surge != null:
		sc = aspect_color(sq.surge["aspect"])
		t["surge_col"] = sc
		sc.a = 0.8
	_set_overlay(t["surge"], h + 0.02, sc, sq.surge != null)

	_set_overlay(t["hl"], h + 0.03, highlights.get(p, Color(1, 1, 1, 0)), highlights.has(p))

	if preview_arrows.has(p):
		_set_arrow(t["arrow"], h + 0.12, preview_arrows[p], Color(1.0, 0.9, 0.55, 0.95))
	else:
		var zc2 := Color(1, 1, 1, 0.85)
		if sq.zone != null:
			zc2 = aspect_color(sq.zone["def"].aspect).lightened(0.4)
		_set_arrow(t["arrow"], h + 0.12, _zone_arrow(sq), zc2)

	var lines := ""
	if sq.surge != null:
		lines += "⚠ %s · %d\n" % [sq.surge["name"], sq.surge["turns_left"]]
	if sq.zone != null:
		lines += "%s %s · %dr\n" % [sq.zone["def"].display_name, ROMAN[sq.zone["level"] - 1], sq.zone["duration"]]
	if sq.is_aspect_ground():
		lines += "%s %s%s\n" % [Square.ground_name(sq.ground), ROMAN[sq.level - 1],
				" · %dr" % sq.timer if sq.timer != Square.PERMANENT else ""]
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
		key = "%s:%d:%s" % [sq.object["name"], sq.object["hp"], sq.object["burning"]]
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
	mat.roughness = 0.85
	match sq.object["name"]:
		"Tree":
			var cone := CylinderMesh.new()
			cone.top_radius = 0.0
			cone.bottom_radius = 0.34
			cone.height = 0.95
			mi.mesh = cone
			mi.position.y = 0.475
			mat.albedo_color = Color(0.20, 0.42, 0.24)
			if sq.object["burning"]:
				mat.albedo_color = Color(0.55, 0.25, 0.08)
				mat.emission_enabled = true
				mat.emission = Color(1.0, 0.45, 0.1)
				mat.emission_energy_multiplier = 1.6
		"Rock":
			var box := BoxMesh.new()
			box.size = Vector3(0.6, 0.5, 0.6)
			mi.mesh = box
			mi.position.y = 0.25
			mat.albedo_color = Color(0.45, 0.47, 0.52)
		"Pillar":
			var col := CylinderMesh.new()
			col.top_radius = 0.25
			col.bottom_radius = 0.28
			col.height = 1.1
			mi.mesh = col
			mi.position.y = 0.55
			mat.albedo_color = Color(0.7, 0.68, 0.62)
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
	var hp_text := "" if sq.has_tag("indestructible") else " %d/%d" % [sq.object["hp"], sq.object["max_hp"]]
	l.text = "%s%s%s" % [sq.object["name"], hp_text, " 🔥" if sq.object["burning"] else ""]
	(t["root"] as Node3D).add_child(root)
	t["prop_node"] = root
