class_name WalkScreen
extends Node3D
## Base of every screen where the player walks around a DistrictMap (city districts, dungeon rooms):
## fixed isometric camera like the battles, WASD to walk (relative to the camera), E to use a thing,
## a top bar, a prompt, a toast line and a side panel. Subclasses fill in what is special
## (`_make_map`, `_build_actors`, `_update_actors`, `_interact_with`, `_top_buttons`).
## The layout comes from DistrictMap; this script only draws it and moves the player.

const MENU_SCENE := "res://game/menu.tscn"

const SPEED := 5.0
const YAW := 45.0
const PITCH := 40.0
const CAMERA_SIZE := 11.0

var _game: GameState
var _map: DistrictMap
var _rng := RandomNumberGenerator.new()
var _pos := Vector2.ZERO
var _facing := Vector2.ZERO               # direction of the player's last move
var _player: Node3D
var _camera: Camera3D
var _camera_target := Vector3.ZERO
var _header: Label
var _top: HBoxContainer
var _toast: Label
var _prompt: Label
var _side: PanelContainer
var _side_body: VBoxContainer
var _side_close: Button
var _side_closable := true
var _side_blocks := true                 # a blocking panel stops walking and using things
var _toast_time := 0.0


# ---------- hooks for subclasses ----------

func _can_start() -> bool:
	return true


func _fallback_scene() -> String:
	return MENU_SCENE


func _make_map() -> DistrictMap:
	return DistrictMap.of(&"plaza")


func _spawn_point() -> Vector2:
	return _map.spawn_for(&"start")


func _build_actors() -> void:
	pass


func _update_actors(_delta: float) -> void:
	pass


func _interact_with(_thing: Dictionary) -> void:
	pass


func _top_buttons() -> Array[Button]:
	return []


func _after_ready() -> void:
	pass


## Extra input of a subclass; return true when the event was used.
func _extra_input(_event: InputEvent) -> bool:
	return false


# ---------- setup ----------

func _ready() -> void:
	_rng.randomize()
	_game = GameSession.game
	if _game == null or not _can_start():
		_game = null
		get_tree().change_scene_to_file.call_deferred(_fallback_scene())
		return
	_map = _make_map()
	_pos = _spawn_point()
	_build_world()
	_build_player()
	_build_actors()
	_build_hud()
	GameSession.state_changed.connect(_on_state_changed)
	_camera_target = Vector3(_pos.x, 0.0, _pos.y)
	_update_camera(1.0)
	_refresh_header()
	_after_ready()


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


func _flat(box_size: Vector3, at: Vector3, color: Color) -> void:
	var mi := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = box_size
	mi.mesh = box
	mi.position = at
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.8
	mi.material_override = mat
	add_child(mi)


func _build_player() -> void:
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
	_top = HBoxContainer.new()
	_top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_top.add_theme_constant_override("separation", 10)
	col.add_child(_top)
	_header = Label.new()
	_header.add_theme_font_size_override("font_size", 22)
	_header.add_theme_color_override("font_color", UiTheme.ACCENT)
	_header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_top.add_child(_header)
	for b in _top_buttons():
		_top.add_child(b)
	_toast = Label.new()
	_toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_toast.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
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
	_side.offset_left = -520.0
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
	_side_body = VBoxContainer.new()
	_side_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_side_body.add_theme_constant_override("separation", 10)
	scroll.add_child(_side_body)
	_side_close = hud_button("Close  (Esc)", _close_side)
	side_col.add_child(_side_close)


func hud_button(text: String, action: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(120, 36)
	b.pressed.connect(action)
	return b


func _header_text() -> String:
	return "%s  ·  Day %d  ·  AP %d / %d  ·  %d spirit stones  ·  %s %s" % [_map.title, _game.day, _game.ap,
		_game.max_ap, _game.money, Stage.stage_name(_game.stage), Stage.sub_tier_name(_game.sub_tier)]


func _refresh_header() -> void:
	_header.text = _header_text()


func _on_state_changed() -> void:
	_refresh_header()


func _say(text: String, seconds := 3.0) -> void:
	_toast.text = text
	_toast_time = seconds


func _open_side(closable := true, blocks := true) -> void:
	_side_closable = closable
	_side_blocks = blocks
	_side_close.visible = closable
	_side.visible = true


func _close_side() -> void:
	_side.visible = false
	_side_closed()


func _side_closed() -> void:
	pass


func _clear_side() -> void:
	for c in _side_body.get_children():
		_side_body.remove_child(c)
		c.queue_free()


# ---------- input and movement ----------

func _unhandled_input(event: InputEvent) -> void:
	if _game == null:
		return
	# keep the viewport: a handler may reload the scene, which removes this node from the tree
	var viewport := get_viewport()
	if _extra_input(event):
		viewport.set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_E:
			if not (_side.visible and _side_blocks):
				var thing := _map.nearest_action(_pos)
				if not thing.is_empty():
					_interact_with(thing)
		elif event.physical_keycode == KEY_ESCAPE and _side.visible and _side_closable:
			_close_side()
			get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	if _game == null:
		return
	if _toast_time > 0.0:
		_toast_time -= delta
		if _toast_time <= 0.0:
			_toast.text = ""
	if not (_side.visible and _side_blocks):
		_move_player(delta)
	_update_actors(delta)
	_update_camera(minf(1.0, delta * 6.0))
	var near := _map.nearest_action(_pos)
	_prompt.text = "" if near.is_empty() or (_side.visible and _side_blocks) else "[E]  " + String(near["label"])


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
	_facing = dir
	_player.position = Vector3(_pos.x, 0.0, _pos.y)
	_player.rotation.y = atan2(dir.x, dir.y)


func _update_camera(weight: float) -> void:
	_camera_target = _camera_target.lerp(Vector3(_pos.x, 0.0, _pos.y), weight)
	var yaw := deg_to_rad(YAW)
	var pitch := deg_to_rad(PITCH)
	var dir := Vector3(sin(yaw) * cos(pitch), sin(pitch), cos(yaw) * cos(pitch))
	_camera.position = _camera_target + dir * 30.0
	_camera.look_at(_camera_target, Vector3.UP)


func _to_menu() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)
