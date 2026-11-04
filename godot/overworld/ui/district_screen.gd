class_name DistrictScreen
extends Node3D
## A walkable city district (gdd_overworld §6.1): fixed isometric camera like the battles, WASD to
## walk (relative to the camera), E to use a building or gate. Your first monster follows you
## (§6.2); in the Inner World all your monsters wander freely (§6.3). What a place offers is shown
## in a PlacePanel, so the menu map and the streets share the same content.
## The layout comes from DistrictMap; this script only draws it and moves the figures.

const SCENE := "res://overworld/district.tscn"
const MAP_SCENE := "res://overworld/overworld.tscn"
const MENU_SCENE := "res://game/menu.tscn"

const SPEED := 5.0
const YAW := 45.0
const PITCH := 40.0
const CAMERA_SIZE := 11.0
const FOLLOW_GAP := 1.3
const WANDER_SPEED := 1.2

var _game: GameState
var _map: DistrictMap
var _rng := RandomNumberGenerator.new()
var _pos := Vector2.ZERO
var _player: Node3D
var _follower: Node3D
var _follower_pos := Vector2.ZERO
var _wanderers: Array[Dictionary] = []     # {node, pos, target, wait}
var _camera: Camera3D
var _camera_target := Vector3.ZERO
var _header: Label
var _toast: Label
var _prompt: Label
var _side: PanelContainer
var _panel: PlacePanel
var _toast_time := 0.0


func _ready() -> void:
	_rng.randomize()
	_game = GameSession.game
	if _game == null:
		get_tree().change_scene_to_file.call_deferred(MENU_SCENE)
		return
	_map = DistrictMap.of(GameSession.district)
	GameSession.district = _map.id
	_pos = _map.spawn_for(GameSession.arrive_from)
	_build_world()
	_build_actors()
	_build_hud()
	GameSession.state_changed.connect(_on_state_changed)
	_camera_target = Vector3(_pos.x, 0.0, _pos.y)
	_update_camera(1.0)
	_refresh_header()
	if GameSession.arrive_from == &"start":
		_say("WASD to walk, E to use things.", 5.0)


# ---------- world ----------

func _build_world() -> void:
	get_viewport().msaa_3d = Viewport.MSAA_4X
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.075, 0.082, 0.094)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.75, 0.78, 0.9)
	env.ambient_light_energy = 0.55
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-52, 30, 0)
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 40.0
	add_child(sun)

	_camera = Camera3D.new()
	_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	_camera.size = CAMERA_SIZE
	_camera.far = 100.0
	add_child(_camera)

	_flat(Vector3(_map.size.x + 40.0, 0.02, _map.size.y + 40.0), Vector3(_map.size.x / 2.0, -0.03, _map.size.y / 2.0),
		Color(0.05, 0.055, 0.065))
	_flat(Vector3(_map.size.x, 0.1, _map.size.y), Vector3(_map.size.x / 2.0, -0.05, _map.size.y / 2.0), _map.ground)
	for t in _map.things:
		var h: float = t["height"]
		var sz: Vector2 = t["size"]
		var p: Vector2 = t["pos"]
		_flat(Vector3(sz.x, h, sz.y), Vector3(p.x, h / 2.0, p.y), t["color"])
		if t["name"] != "":
			var label := Label3D.new()
			label.text = t["name"]
			label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			label.pixel_size = 0.012
			label.font_size = 40
			label.outline_size = 8
			label.no_depth_test = true
			label.position = Vector3(p.x, h + 0.6, p.y)
			add_child(label)


func _flat(size: Vector3, at: Vector3, color: Color) -> void:
	var mi := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mi.mesh = box
	mi.position = at
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.8
	mi.material_override = mat
	add_child(mi)


func _build_actors() -> void:
	_player = Node3D.new()
	var body := MeshInstance3D.new()
	var cap := CapsuleMesh.new()
	cap.radius = 0.28
	cap.height = 1.0
	body.mesh = cap
	body.position.y = 0.5
	var mat := StandardMaterial3D.new()
	mat.albedo_color = UiTheme.ACCENT
	body.material_override = mat
	_player.add_child(body)
	_player.position = Vector3(_pos.x, 0.0, _pos.y)
	add_child(_player)

	if _map.id == &"inner":
		for m in _game.monsters:
			var node := MonsterLook.make_body(m.species())
			add_child(node)
			var start := _map.random_free_point(_rng)
			node.position = Vector3(start.x, 0.0, start.y)
			_wanderers.append({"node": node, "pos": start, "target": _map.random_free_point(_rng), "wait": _rng.randf_range(0.0, 2.0)})
	elif not _game.monsters.is_empty():
		_follower = MonsterLook.make_body(_game.monsters[0].species())
		_follower_pos = _map.move(_pos, Vector2(0.0, FOLLOW_GAP), 0.3)
		_follower.position = Vector3(_follower_pos.x, 0.0, _follower_pos.y)
		add_child(_follower)


# ---------- HUD ----------

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.theme = UiTheme.create()
	layer.add_child(root)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 72)     # room for the cheat menu button
	root.add_child(margin)
	var col := VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(col)
	var top := HBoxContainer.new()
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_theme_constant_override("separation", 10)
	col.add_child(top)
	_header = Label.new()
	_header.add_theme_font_size_override("font_size", 22)
	_header.add_theme_color_override("font_color", UiTheme.ACCENT)
	_header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(_header)
	top.add_child(_hud_button("End day", _end_day))
	top.add_child(_hud_button("City map", func(): get_tree().change_scene_to_file(MAP_SCENE)))
	top.add_child(_hud_button("Menu", _to_menu))
	_toast = Label.new()
	_toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_toast.add_theme_color_override("font_color", UiTheme.TEXT)
	col.add_child(_toast)

	_prompt = Label.new()
	_prompt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_prompt.anchor_left = 0.0
	_prompt.anchor_right = 1.0
	_prompt.anchor_top = 1.0
	_prompt.anchor_bottom = 1.0
	_prompt.offset_top = -72.0
	_prompt.offset_bottom = -24.0
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt.add_theme_font_size_override("font_size", 24)
	_prompt.add_theme_color_override("font_color", UiTheme.ACCENT)
	root.add_child(_prompt)

	_side = PanelContainer.new()
	_side.visible = false
	_side.anchor_left = 1.0
	_side.anchor_right = 1.0
	_side.anchor_top = 0.0
	_side.anchor_bottom = 1.0
	_side.offset_left = -500.0
	_side.offset_right = -16.0
	_side.offset_top = 64.0
	_side.offset_bottom = -16.0
	root.add_child(_side)
	var side_col := VBoxContainer.new()
	side_col.add_theme_constant_override("separation", 10)
	_side.add_child(side_col)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	side_col.add_child(scroll)
	_panel = PlacePanel.new()
	_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_panel.setup(_game)
	_panel.changed.connect(_refresh_header)
	scroll.add_child(_panel)
	side_col.add_child(_hud_button("Close  (Esc)", _close_panel))


func _hud_button(text: String, action: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(120, 36)
	b.pressed.connect(action)
	return b


func _refresh_header() -> void:
	_header.text = "%s  ·  Day %d  ·  AP %d / %d  ·  %d spirit stones  ·  %s %s" % [_map.title, _game.day, _game.ap,
		_game.max_ap, _game.money, Stage.stage_name(_game.stage), Stage.sub_tier_name(_game.sub_tier)]


func _on_state_changed() -> void:
	_refresh_header()
	if _side.visible:
		_panel.refresh()


func _say(text: String, seconds := 3.0) -> void:
	_toast.text = text
	_toast_time = seconds


# ---------- input and movement ----------

func _unhandled_input(event: InputEvent) -> void:
	if _game == null:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_E:
			_interact()
		elif event.physical_keycode == KEY_ESCAPE and _side.visible:
			_close_panel()
			get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	if _game == null:
		return
	if _toast_time > 0.0:
		_toast_time -= delta
		if _toast_time <= 0.0:
			_toast.text = ""
	if not _side.visible:
		_move_player(delta)
	_move_follower(delta)
	_move_wanderers(delta)
	_update_camera(minf(1.0, delta * 6.0))
	var near := _map.nearest_action(_pos)
	_prompt.text = "" if near.is_empty() or _side.visible else "[E]  " + String(near["label"])


func _move_player(delta: float) -> void:
	var x := 0.0
	var z := 0.0
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
		x += 1.0
	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
		x -= 1.0
	if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP):
		z += 1.0
	if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN):
		z -= 1.0
	if x == 0.0 and z == 0.0:
		return
	# screen directions on the ground, for a camera looking along (-sin yaw, -cos yaw)
	var yaw := deg_to_rad(YAW)
	var right := Vector2(cos(yaw), -sin(yaw))
	var forward := Vector2(-sin(yaw), -cos(yaw))
	var dir := (right * x + forward * z).normalized()
	_pos = _map.move(_pos, dir * SPEED * delta)
	_player.position = Vector3(_pos.x, 0.0, _pos.y)
	_player.rotation.y = atan2(dir.x, dir.y)


func _move_follower(delta: float) -> void:
	if _follower == null:
		return
	var to_player := _pos - _follower_pos
	var d := to_player.length()
	if d > FOLLOW_GAP:
		var step := minf(d - FOLLOW_GAP, SPEED * 1.1 * delta)
		_follower_pos = _map.move(_follower_pos, to_player.normalized() * step, 0.3)
		_follower.rotation.y = atan2(to_player.x, to_player.y)
	_follower.position = Vector3(_follower_pos.x, 0.0, _follower_pos.y)


func _move_wanderers(delta: float) -> void:
	for w in _wanderers:
		if w["wait"] > 0.0:
			w["wait"] -= delta
			continue
		var from: Vector2 = w["pos"]
		var to_target: Vector2 = w["target"] - from
		if to_target.length() < 0.15:
			w["wait"] = _rng.randf_range(1.0, 3.0)
			w["target"] = _map.random_free_point(_rng)
			continue
		var next := _map.move(from, to_target.normalized() * minf(to_target.length(), WANDER_SPEED * delta), 0.3)
		if next == from:
			w["target"] = _map.random_free_point(_rng)       # stuck behind something
		w["pos"] = next
		var node: Node3D = w["node"]
		node.position = Vector3(next.x, 0.0, next.y)
		node.rotation.y = atan2(to_target.x, to_target.y)


func _update_camera(weight: float) -> void:
	_camera_target = _camera_target.lerp(Vector3(_pos.x, 0.0, _pos.y), weight)
	var yaw := deg_to_rad(YAW)
	var pitch := deg_to_rad(PITCH)
	var dir := Vector3(sin(yaw) * cos(pitch), sin(pitch), cos(yaw) * cos(pitch))
	_camera.position = _camera_target + dir * 30.0
	_camera.look_at(_camera_target, Vector3.UP)


# ---------- actions ----------

func _interact() -> void:
	if _side.visible:
		return
	var thing := _map.nearest_action(_pos)
	if thing.is_empty():
		return
	var parts := String(thing["action"]).split(":")
	var arg := StringName(parts[1])
	match parts[0]:
		"panel":
			_panel.show_place(arg)
			_side.visible = true
		"goto":
			_go(arg)
		"locked":
			_say(String(thing["label"]))


func _close_panel() -> void:
	_side.visible = false


func _go(district: StringName) -> void:
	if not DistrictMap.ids().has(district):
		_say("Not built yet.")
		return
	GameSession.arrive_from = _map.id
	GameSession.district = district
	get_tree().reload_current_scene()


func _end_day() -> void:
	if GameSession.expedition != null:
		_say("Finish or leave the dungeon first.")
		return
	var report := _game.end_day(_rng)
	SaveGame.save(_game)
	_refresh_header()
	if _side.visible:
		_panel.refresh()
	_say("The night passes. Day %d begins; %d monster(s) recovered." % [report["day"], report["healed"]], 5.0)


func _to_menu() -> void:
	if GameSession.expedition == null:
		SaveGame.save(_game)
	get_tree().change_scene_to_file(MENU_SCENE)
