class_name BattleView
extends Node3D
## 3D presentation of a Battle: orbit camera (orthographic), shadows, glow, tiles, monsters,
## props, zone/Surge/highlight overlays, direction arrows and small animations.
## It only reads the battle state and never decides a rule (gdd_battle §7.1).
##
## Camera: Q / E rotate by 90°, mouse wheel zooms, middle-mouse drag orbits freely.

const CELL := 1.0
const TILE := 0.92
const FLAT_H := 0.12
const HIGH_H := 0.45
const AIR_H := 1.05                # height of the air layer above the tile top
const ROMAN := ["I", "II", "III"]

const PITCH := 40.0
const ZOOM_MIN := 5.0
const ZOOM_MAX := 20.0

const SIDE_COLORS := [Color(0.35, 0.62, 1.0), Color(1.0, 0.38, 0.35)]
const SURGE_COLOR := Color(1.0, 0.62, 0.2)

var battle: Battle
var camera: Camera3D
var highlights := {}           # Vector2i -> Color
var preview_arrows := {}       # Vector2i -> Vector2i (direction shown while aiming)
var _tiles := {}               # Vector2i -> Dictionary of nodes
var _pieces := {}              # unit id -> Node3D
var _pivot: Node3D
var _yaw := 45.0
var _yaw_target := 45.0
var _zoom := 8.5
var _zoom_target := 8.5
var _time := 0.0


func build(p_battle: Battle) -> void:
	battle = p_battle
	_zoom = battle.board.size * 1.25 + 2.2
	_zoom_target = _zoom
	_build_environment()
	_build_base()
	for cell in battle.board.cells:
		_tiles[cell.pos] = _make_tile(cell.pos)
	for id in battle.roster:
		_pieces[id] = _make_monster(battle.units[id])
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


func _top(cell: BoardCell) -> float:
	return HIGH_H if cell.is_mountain() else FLAT_H


## Centre of a body (1x1 or 2x2) on the board plane.
func _body_pos(u: BattleUnit) -> Vector3:
	var a := _cell_pos(u.pos)
	var c := _cell_pos(u.pos + Vector2i(u.size - 1, u.size - 1))
	return (a + c) / 2.0


func _body_top(u: BattleUnit) -> float:
	var h := FLAT_H
	for p in u.cells():
		h = maxf(h, _top(battle.board.at(p)))
	return h + (AIR_H if u.layer == Board.AIR else 0.0)


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
	if battle.board.unit_id_at(p, Board.GROUND) == &"" and battle.board.unit_id_at(p, Board.AIR) != &"":
		start.y += AIR_H
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
		"prop_key": "", "prop_node": null, "air_prop_key": "", "air_prop_node": null,
	}


## A simple body per Kin; the colour is a look hint of the species, never a rule.
func _make_monster(u: BattleUnit) -> Node3D:
	var root := Node3D.new()
	root.name = str(u.id)
	var scale_f := float(u.size)
	var mi := MeshInstance3D.new()
	mi.name = "Body"
	mi.mesh = MonsterLook.kin_mesh(u.kin())
	mi.position.y = 0.4
	mi.scale = Vector3.ONE * (1.0 if u.size == 1 else 1.7)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = MonsterLook.aspect_color(u.sheet.look.aspect) if u.sheet.look != null else Color(0.62, 0.62, 0.66)
	mat.roughness = 0.55
	if u.kin() == MonsterDef.Kin.SPIRIT:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color.a = 0.75
	mi.material_override = mat
	root.add_child(mi)
	if u.kin() == MonsterDef.Kin.SWARM:
		for off in [Vector3(0.22, -0.05, 0.12), Vector3(-0.2, -0.08, 0.16)]:
			var extra := MeshInstance3D.new()
			extra.mesh = mi.mesh
			extra.material_override = mat
			extra.position = off
			extra.scale = Vector3.ONE * 0.7
			mi.add_child(extra)

	var disc := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.36 * scale_f
	cyl.bottom_radius = 0.36 * scale_f
	cyl.height = 0.03
	disc.mesh = cyl
	disc.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	disc.material_override = _unshaded(SIDE_COLORS[u.side], false)
	disc.position.y = 0.02
	root.add_child(disc)

	var ring := MeshInstance3D.new()
	ring.name = "Ring"
	var torus := TorusMesh.new()
	torus.inner_radius = 0.40 * scale_f
	torus.outer_radius = 0.48 * scale_f
	ring.mesh = torus
	ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	ring.material_override = _unshaded(Color(1.0, 0.85, 0.45), false)
	ring.position.y = 0.04
	root.add_child(ring)

	var label := _make_label(root, 26)
	label.name = "Label"
	label.position.y = 1.25 + 0.5 * (scale_f - 1.0)
	label.modulate = SIDE_COLORS[u.side].lerp(Color.WHITE, 0.6)
	add_child(root)
	return root


# ---------- refresh ----------

func refresh() -> void:
	for p in _tiles:
		_update_tile(p, _tiles[p], battle.board.at(p))
	for id in _pieces:
		var u: BattleUnit = battle.units[id]
		var node: Node3D = _pieces[id]
		node.visible = u.is_alive()
		if not u.is_alive():
			node.remove_meta("target")
			continue
		var target := _body_pos(u) + Vector3(0, _body_top(u), 0)
		if not node.has_meta("target"):
			node.position = target
		elif node.get_meta("target") != target:
			var tw := create_tween()
			tw.tween_property(node, "position", target, 0.28).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		node.set_meta("target", target)
		var marks := ""
		if not battle.surges_of(id).is_empty():
			marks += "  ⚠"
		if u.nullify or u.life_thread:
			marks += "  ◈"
		if u.layer == Board.AIR:
			marks += "  ↟"
		(node.get_node("Label") as Label3D).text = "%s%s\n%d/%d" % [u.display_name(), marks, u.hp, u.max_hp]
		(node.get_node("Ring") as Node3D).visible = id == battle.turn_owner and not battle.over


func _ground_color(cell: BoardCell) -> Color:
	var g := battle.content.ground(cell.ground)
	var base := g.color if g != null else Color(0.3, 0.3, 0.3)
	base = base.darkened(0.45)
	if g != null and g.max_level > 1 and cell.level > 1:
		base = base.lightened(0.18)
	if cell.is_mountain():
		base = base.lerp(Color(0.18, 0.35, 0.41), 0.55 if cell.ground == GroundDef.PLAIN else 0.3)
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


## Direction a zone square moves its occupant (push direction or one step toward the anchor).
func _zone_arrow(cell: BoardCell) -> Vector2i:
	var z := cell.zone
	if z == null:
		return Vector2i.ZERO
	if z.def.has_tag(FieldEffect.PUSH):
		return z.dir
	if z.def.has_tag(FieldEffect.PULL):
		var v := z.anchor - cell.pos
		if v == Vector2i.ZERO or absi(v.x) == absi(v.y):
			return Vector2i.ZERO
		return Vector2i(signi(v.x), 0) if absi(v.x) > absi(v.y) else Vector2i(0, signi(v.y))
	return Vector2i.ZERO


func _update_tile(p: Vector2i, t: Dictionary, cell: BoardCell) -> void:
	var h := _top(cell)
	(t["mesh"] as BoxMesh).size = Vector3(TILE, h, TILE)
	(t["body"] as MeshInstance3D).position.y = h / 2.0
	var mat := t["mat"] as StandardMaterial3D
	mat.albedo_color = _ground_color(cell)
	var g := battle.content.ground(cell.ground)
	mat.emission_enabled = g != null and g.is_hazard()
	if mat.emission_enabled:
		mat.emission = g.color
		mat.emission_energy_multiplier = 0.18 * cell.level

	var zc := Color(1, 1, 1, 0)
	if cell.zone != null:
		zc = cell.zone.def.color
		zc.a = 0.3 + 0.1 * cell.zone.level
	_set_overlay(t["zone"], h + 0.01, zc, cell.zone != null)

	t["surge_on"] = cell.surge >= 0
	var sc := Color(1, 1, 1, 0)
	if cell.surge >= 0:
		sc = SURGE_COLOR
		t["surge_col"] = sc
		sc.a = 0.8
	_set_overlay(t["surge"], h + 0.02, sc, cell.surge >= 0)

	_set_overlay(t["hl"], h + 0.03, highlights.get(p, Color(1, 1, 1, 0)), highlights.has(p))

	if preview_arrows.has(p):
		_set_arrow(t["arrow"], h + 0.12, preview_arrows[p], Color(1.0, 0.9, 0.55, 0.95))
	else:
		var zc2 := Color(1, 1, 1, 0.85)
		if cell.zone != null:
			zc2 = cell.zone.def.color.lightened(0.4)
		_set_arrow(t["arrow"], h + 0.12, _zone_arrow(cell), zc2)

	var lines := ""
	if cell.surge >= 0:
		var surge := battle.surge_by_id(cell.surge)
		if surge != null:
			lines += "⚠ %s · %d\n" % [surge.skill.display_name, surge.skill.surge_damage]
	if cell.zone != null:
		lines += "%s %s · %dr\n" % [cell.zone.def.display_name, ROMAN[cell.zone.level - 1], cell.zone.duration]
	if g != null and cell.ground != GroundDef.PLAIN:
		lines += g.label(cell.level) + "\n"
	var label: Label3D = t["label"]
	label.text = lines.strip_edges()
	label.position.y = h + 0.12
	_update_prop(t, "prop", cell.prop, h)
	_update_prop(t, "air_prop", cell.air_prop if cell.air_prop != cell.prop else null, h + AIR_H)


## Rebuilds the node of a prop when its identity or HP changed. The shape follows the prop's
## catalogue class; a both-layer prop is drawn as a tall column through both layers.
func _update_prop(t: Dictionary, slot: String, prop: BoardProp, y: float) -> void:
	var key := "" if prop == null else "%d:%d" % [prop.uid, prop.hp]
	if key == t[slot + "_key"]:
		return
	t[slot + "_key"] = key
	if t[slot + "_node"] != null:
		(t[slot + "_node"] as Node).queue_free()
		t[slot + "_node"] = null
	if prop == null:
		return
	var def := prop.def
	var root := Node3D.new()
	root.position.y = y
	var mi := MeshInstance3D.new()
	var mat := StandardMaterial3D.new()
	mat.roughness = 0.85
	mat.albedo_color = def.color.darkened(0.35) if prop.hp <= 0 else def.color
	var height := 0.6
	match def.prop_class:
		"aura":
			var col := CylinderMesh.new()
			col.top_radius = 0.16
			col.bottom_radius = 0.26
			col.height = 0.9
			mi.mesh = col
			height = 0.9
			mat.emission_enabled = true
			mat.emission = def.color
			mat.emission_energy_multiplier = 0.5
		"burst":
			var sp := SphereMesh.new()
			sp.radius = 0.3
			sp.height = 0.6
			mi.mesh = sp
		"residue":
			var cone := CylinderMesh.new()
			cone.top_radius = 0.0
			cone.bottom_radius = 0.32
			cone.height = 0.85
			mi.mesh = cone
			height = 0.85
		"push":
			var disc := CylinderMesh.new()
			disc.top_radius = 0.36
			disc.bottom_radius = 0.36
			disc.height = 0.3
			mi.mesh = disc
			height = 0.3
		"spawn":
			var pillar := CylinderMesh.new()
			pillar.top_radius = 0.25
			pillar.bottom_radius = 0.28
			pillar.height = 1.1
			mi.mesh = pillar
			height = 1.1
		_:
			var box := BoxMesh.new()
			box.size = Vector3(0.62, 0.52, 0.62) if def.layer != "both" else Vector3(0.7, AIR_H + 0.6, 0.7)
			mi.mesh = box
			height = box.size.y
	mi.position.y = height / 2.0
	mi.material_override = mat
	root.add_child(mi)
	var l := _make_label(root, 22)
	l.position.y = height + 0.25
	l.text = "%s %d/%d" % [def.display_name, prop.hp, def.hp]
	(t["root"] as Node3D).add_child(root)
	t[slot + "_node"] = root
