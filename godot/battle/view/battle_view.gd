class_name BattleView
extends Node3D
## 3D presentation of a Battle: orbit camera (orthographic), shadows, glow, tiles, monsters,
## props, zone/Surge/highlight overlays, direction arrows and small animations.
## It only reads the battle state and never decides a rule (gdd_battle §7.1).
##
## Camera: Q / E rotate by 90°, mouse wheel zooms, middle-mouse drag orbits freely (left and right turn it; with
## the view switch `free_camera` up and down tilt it between 15° and 88°).

const CELL := 1.0
const TILE := 0.92
const FLAT_H := 0.12
const HIGH_H := 0.45
const AIR_H := 1.05                # height of the air layer above the tile top
const ROMAN := ["I", "II", "III"]

const PITCH := 40.0
const ZOOM_MIN := 5.0
const ZOOM_MAX := 20.0

## Ink blue for the player, cinnabar for the opponent (UiTheme.SIDE).
const SIDE_COLORS := UiTheme.SIDE
const TILE_SHADER := "res://assets/shaders/tile.gdshader"
const ZONE_SHADER := "res://assets/shaders/zone.gdshader"
## Bodies and props stand on paper: their colours are taken a step toward a warm grey so they sit in the picture.
const MUTE := Color(0.5, 0.45, 0.38)
## A plain square: paper a shade darker than the ground of the screen, so the board reads as one sheet.
const TILE_PAPER := Color(0.80, 0.75, 0.64)
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
## Tilt of the camera in degrees above the board. View switch `free_camera`: a middle-mouse drag changes it.
const PITCH_MIN := 15.0
const PITCH_MAX := 88.0
var _pitch := PITCH
var _pitch_target := PITCH
var _zoom := 8.5
var _zoom_target := 8.5
## Screen height (in viewport units) the HUD's bar takes at the bottom edge: the board is centred in the room above it.
var bottom_room := 0.0
var _time := 0.0


func build(p_battle: Battle) -> void:
	battle = p_battle
	_zoom = battle.board.size * 1.25 + 2.2
	_zoom_target = _zoom
	_build_environment()
	_build_base()
	for cell in battle.board.cells:
		if battle.board.in_bounds(cell.pos):          # a custom map leaves squares out
			_tiles[cell.pos] = _make_tile(cell.pos)
	_make_compass()
	for id in battle.roster:
		_pieces[id] = _make_monster(battle.units[id])
	refresh()


func _build_environment() -> void:
	get_viewport().msaa_3d = Viewport.MSAA_4X
	# the paper ground of the screens lies behind the board: a canvas layer below the 3D world
	var back := CanvasLayer.new()
	back.layer = -1
	back.add_child(UiTheme.paper_rect())
	add_child(back)
	var env := Environment.new()
	env.background_mode = Environment.BG_CANVAS
	env.background_canvas_max_layer = -1
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(1.0, 0.97, 0.92)
	env.ambient_light_energy = 0.5
	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-52, 30, 0)
	sun.light_energy = 0.36
	sun.light_color = Color(1.0, 0.96, 0.9)
	sun.shadow_enabled = true
	sun.shadow_opacity = 0.55
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
	mat.albedo_color = UiTheme.INK
	mat.roughness = 1.0
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
	# keys and buttons are actions of the Input Map (Project Settings)
	if event.is_action_pressed(&"camera_zoom_in"):
		_zoom_target = clampf(_zoom_target - 0.6, ZOOM_MIN, ZOOM_MAX)
	elif event.is_action_pressed(&"camera_zoom_out"):
		_zoom_target = clampf(_zoom_target + 0.6, ZOOM_MIN, ZOOM_MAX)
	elif event is InputEventMouseMotion and Input.is_action_pressed(&"camera_drag"):
		_yaw_target -= event.relative.x * 0.3
		if BattleExperiment.free_camera:
			_pitch_target = clampf(_pitch_target + event.relative.y * 0.3, PITCH_MIN, PITCH_MAX)
	elif event.is_action_pressed(&"camera_turn_left"):
		_yaw_target -= 90.0
	elif event.is_action_pressed(&"camera_turn_right"):
		_yaw_target += 90.0


func _process(delta: float) -> void:
	if camera == null:
		return
	_time += delta
	var k := 1.0 - exp(-10.0 * delta)
	_yaw = lerpf(_yaw, _yaw_target, k)
	if not BattleExperiment.free_camera:
		_pitch_target = PITCH
	_pitch = lerpf(_pitch, _pitch_target, k)
	camera.position = Vector3(0, 34.0 * sin(deg_to_rad(_pitch)), 34.0 * cos(deg_to_rad(_pitch)))
	camera.rotation_degrees = Vector3(-_pitch, 0, 0)
	_zoom = lerpf(_zoom, _zoom_target, k)
	_pivot.rotation_degrees.y = _yaw
	camera.size = _zoom
	# an orthogonal camera shows `size` world units over the viewport height: lower it by half the bar's share
	camera.v_offset = -0.5 * _zoom * bottom_room / maxf(1.0, get_viewport().get_visible_rect().size.y)
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
	l.outline_size = 14
	if UiTheme.title_font() != null:
		l.font = UiTheme.title_font()
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


## The overlay of a zone: a painted wash with a brush arrow (assets/shaders/zone.gdshader).
func _make_zone(parent: Node3D) -> Dictionary:
	var mi := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(TILE * 0.96, TILE * 0.96)
	mi.mesh = pm
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var m := ShaderMaterial.new()
	m.shader = load(ZONE_SHADER)
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
	l.modulate = UiTheme.INK
	l.outline_modulate = Color(UiTheme.PAPER_LIGHT, 0.92)
	if UiTheme.text_font() != null:
		l.font = UiTheme.text_font()
	l.no_depth_test = true
	l.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(l)
	return l


## A compass around the board (user request 2026-11-17): N, E, S and W beside the middle of each edge, in the
## directions the texts name (BattleText.DIR_NAMES: north = y − 1, east = x + 1).
func _make_compass() -> void:
	var size := battle.board.size
	var mid := (size - 1) / 2.0
	var half := (size - 1) / 2.0
	for entry: Array in [["N", Vector2(mid, -1.1)], ["S", Vector2(mid, size + 0.1)], ["W", Vector2(-1.1, mid)], ["E", Vector2(size + 0.1, mid)]]:
		var root := Node3D.new()
		var at: Vector2 = entry[1]
		root.position = Vector3((at.x - half) * CELL, 0.05, (at.y - half) * CELL)
		add_child(root)
		var l := _make_label(root, 28)                # quiet: grey, no strong outline (user, 2026-11-17)
		l.text = entry[0]
		l.modulate = Color(UiTheme.INK_SOFT, 0.85)
		l.outline_modulate = Color(UiTheme.PAPER_LIGHT, 0.0)
		if UiTheme.title_font() != null:
			l.font = UiTheme.title_font()


func _make_tile(p: Vector2i) -> Dictionary:
	var root := Node3D.new()
	root.position = _cell_pos(p)
	add_child(root)
	var body := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	body.mesh = mesh
	var mat := ShaderMaterial.new()
	mat.shader = load(TILE_SHADER)
	mat.set_shader_parameter("tile", TILE)
	body.material_override = mat
	root.add_child(body)
	var label := _make_label(root, 20)
	return {
		"root": root, "body": body, "mesh": mesh, "mat": mat, "label": label,
		"zone": _make_zone(root), "surge": _make_overlay(root), "hl": _make_overlay(root),
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
	mat.albedo_color = (MonsterLook.aspect_color(u.sheet.look.aspect) if u.sheet.look != null else Color(0.62, 0.62, 0.66)).lerp(MUTE, 0.28)
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
	ring.material_override = _unshaded(Color(0.93, 0.68, 0.16), false)
	ring.position.y = 0.04
	root.add_child(ring)

	var label := _make_label(root, 26)
	label.name = "Label"
	label.position.y = 1.25 + 0.5 * (scale_f - 1.0)
	label.modulate = SIDE_COLORS[u.side].darkened(0.35)
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
	# a wash of the ground's colour on the paper of the board; Plain is the bare paper
	var base := TILE_PAPER
	if g != null and cell.ground != GroundDef.PLAIN:
		base = TILE_PAPER.lerp(g.color, 0.62 if cell.level <= 1 else 0.8)
	if _vein_owned(cell):                              # a Dragon Vein shows the colour of the side that owns it
		base = TILE_PAPER.lerp(SIDE_COLORS[cell.owner_side], 0.6)
	if cell.is_mountain():
		base = base.lerp(Color(0.18, 0.35, 0.41), 0.55 if cell.ground == GroundDef.PLAIN else 0.3)
	return base


## The ink sign of a square (assets/shaders/tile.gdshader): 1 a Dragon Vein, 2 ground that acts on entering,
## 3 on leaving, 4 at the end of a turn; 0 none.
func _ground_mark(cell: BoardCell) -> int:
	if cell.ground == GroundDef.WELL:
		return 1
	var g := battle.content.ground(cell.ground)
	if g == null or g.triggers.is_empty():
		return 0
	match g.triggers[0].timing:
		Moment.ENTER:
			return 2
		Moment.LEAVE:
			return 3
	return 4


## Last touch owns (`vein_touch`): the side a Dragon Vein belongs to at the moment, if any.
func _vein_owned(cell: BoardCell) -> bool:
	return cell.ground == GroundDef.WELL and BattleExperiment.vein_touch and cell.owner_side >= 0


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
	var mat := t["mat"] as ShaderMaterial
	var wash := _ground_color(cell)
	mat.set_shader_parameter("wash", wash)
	mat.set_shader_parameter("mark", _ground_mark(cell))
	mat.set_shader_parameter("mark_color", wash.darkened(0.62))
	var g := battle.content.ground(cell.ground)

	var zone_node: MeshInstance3D = t["zone"]["node"]
	zone_node.visible = cell.zone != null
	zone_node.position.y = h + 0.012
	if cell.zone != null:
		var zmat := t["zone"]["mat"] as ShaderMaterial
		var zd := _zone_arrow(cell)
		zmat.set_shader_parameter("color", cell.zone.def.color.darkened(0.45))
		zmat.set_shader_parameter("dir", Vector2(zd.x, zd.y))
		# a pull zone has no arrow on its centre and none on a diagonal: only the centre shows the rings
		zmat.set_shader_parameter("strength", 1.0 if zd != Vector2i.ZERO or cell.zone.anchor == cell.pos or not cell.zone.def.has_tag(FieldEffect.PULL) else 0.55)

	t["surge_on"] = cell.surge >= 0
	var sc := Color(1, 1, 1, 0)
	if cell.surge >= 0:
		sc = SURGE_COLOR
		t["surge_col"] = sc
		sc.a = 0.8
	_set_overlay(t["surge"], h + 0.02, sc, cell.surge >= 0)

	_set_overlay(t["hl"], h + 0.03, highlights.get(p, Color(1, 1, 1, 0)), highlights.has(p))

	if preview_arrows.has(p):
		_set_arrow(t["arrow"], h + 0.12, preview_arrows[p], Color(UiTheme.CINNABAR, 0.95))
	else:
		_set_arrow(t["arrow"], h + 0.12, Vector2i.ZERO, Color.WHITE)      # a zone paints its own arrow on the square

	var lines := ""
	if cell.surge >= 0:
		var surge := battle.surge_by_id(cell.surge)
		if surge != null:
			lines += "⚠ %s · %d\n" % [surge.skill.display_name, surge.skill.surge_damage]
	if cell.zone != null:
		lines += "%s %s%s%s\n" % [cell.zone.def.display_name, ROMAN[cell.zone.level - 1], "" if cell.zone.rounds_text() == "" else " · " + cell.zone.rounds_text(),
			" · centre" if cell.zone.def.has_tag(FieldEffect.PULL) and cell.zone.anchor == cell.pos else ""]
	if g != null and cell.ground != GroundDef.PLAIN:
		lines += g.label(cell.level) + "\n"
	if battle != null and battle.seals.has(cell.pos):
		var seal: Dictionary = battle.seals[cell.pos]
		lines += "%s · %d%% at 1 HP\n" % ["◆ yours" if int(seal["side"]) == 0 else "◆ enemy", int(seal["base"])]
		var on := battle.any_unit_at(cell.pos)
		if on != null and BattleCatch.chance(battle, on) >= 0:
			lines += "catch %d%%\n" % BattleCatch.chance(battle, on)
	if cell.ground == GroundDef.WELL and BattleExperiment.vein_touch:
		lines += ("◆ yours" if cell.owner_side == 0 else ("◆ enemy" if cell.owner_side == 1 else "◇ unclaimed")) + "\n"
		var taker: BattleUnit = battle.units.get(cell.owner_unit) if battle != null else null
		if cell.owner_side >= 0 and taker != null and taker.is_alive():
			lines += "%s · Pace %.1f\n" % [taker.display_name(), BattleStats.pace(battle, taker)]
	var label: Label3D = t["label"]
	label.modulate = SIDE_COLORS[cell.owner_side].darkened(0.45) if _vein_owned(cell) else UiTheme.INK
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
	mat.albedo_color = (def.color.darkened(0.35) if prop.hp <= 0 else def.color).lerp(MUTE, 0.25)
	var height := 0.6
	match def.prop_class if def.solid else "walkable":
		"walkable":                           # a flat plate a monster can stand on
			var plate := CylinderMesh.new()
			plate.top_radius = 0.4
			plate.bottom_radius = 0.42
			plate.height = 0.06
			mi.mesh = plate
			height = 0.06
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
