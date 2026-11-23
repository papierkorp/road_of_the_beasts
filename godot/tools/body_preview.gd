extends SceneTree
## Shows every body of the eight Kins (`MonsterBody`) or the figures of the props (`PropBody`) on paper and plays
## their movements in turn. No battle, no rule.
## godot --path godot -s res://tools/body_preview.gd                        # monsters: a window that loops
## godot --path godot -s res://tools/body_preview.gd -- props               # props of the game instead
## godot --path godot -s res://tools/body_preview.gd -- monsters <folder>   # saves one picture per movement, ends
## It needs a window: `--headless` draws nothing.

const MONSTER_MOVES := ["stand", "walk", "attack", "cast", "hit", "pushed", "healed", "defeated"]
const PROP_MOVES := ["stand", "appear", "hit", "slide", "spring", "worn", "fall"]
const STEP := 1.6                  # seconds per movement
const SHOT_AT := 0.2               # seconds into a movement at which its picture is taken

var _bodies: Array[MonsterBody] = []
var _props: Array[PropBody] = []
var _world: Node3D
var _moves: Array = MONSTER_MOVES
var _label: Label
var _folder := ""
var _move := -1
var _clock := STEP
var _shot := true


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var show_props := args.size() > 0 and args[0] == "props"
	_folder = args[1] if args.size() > 1 else ""
	_moves = PROP_MOVES if show_props else MONSTER_MOVES
	var world := Node3D.new()
	_world = world
	root.add_child(world)
	var back := CanvasLayer.new()
	back.layer = -1
	back.add_child(UiTheme.paper_rect())
	world.add_child(back)
	var env := Environment.new()
	env.background_mode = Environment.BG_CANVAS
	env.background_canvas_max_layer = -1
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(1.0, 0.97, 0.92)
	env.ambient_light_energy = 0.5
	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	var we := WorldEnvironment.new()
	we.environment = env
	world.add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-52, 30, 0)
	sun.light_energy = 0.36
	sun.shadow_enabled = true
	sun.shadow_opacity = 0.55
	world.add_child(sun)
	var floor_mesh := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(40, 40)
	floor_mesh.mesh = plane
	var mat := StandardMaterial3D.new()
	mat.albedo_color = BattleView.TILE_PAPER
	mat.roughness = 1.0
	floor_mesh.material_override = mat
	world.add_child(floor_mesh)
	var pivot := Node3D.new()
	pivot.rotation_degrees.y = 45.0
	world.add_child(pivot)
	var cam := Camera3D.new()
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = 4.2
	cam.far = 120.0
	cam.position = Vector3(0, 34.0 * sin(deg_to_rad(BattleView.PITCH)), 34.0 * cos(deg_to_rad(BattleView.PITCH)))
	cam.rotation_degrees = Vector3(-BattleView.PITCH, 0, 0)
	pivot.add_child(cam)
	cam.current = true
	root.msaa_3d = Viewport.MSAA_4X
	cam.size = 6.4
	if show_props:
		_show_props()
	else:
		_show_monsters()
	var ui := CanvasLayer.new()
	root.add_child(ui)
	_label = Label.new()
	_label.position = Vector2(40, 30)
	_label.add_theme_font_size_override("font_size", 44)
	_label.add_theme_color_override("font_color", UiTheme.INK)
	ui.add_child(_label)


## Every body of every Kin (`MonsterBody.BODIES`), in rows of seven.
func _show_monsters() -> void:
	var aspects := [Aspect.Type.FORCE, Aspect.Type.NATURE, Aspect.Type.DARK]
	var k := 0
	for kin in MonsterBody.BODIES:
		for body_name: String in MonsterBody.BODIES[kin]:
			var color := MonsterLook.aspect_color(aspects[k % 3]).lerp(BattleView.MUTE, 0.28)
			var body := MonsterBody.create(kin, color, body_name)
			var across := Vector3(1, 0, -1).normalized() * ((k % 7) * 1.6 - 4.8)
			var away := Vector3(1, 0, 1).normalized() * ((k / 7) * 2.3 - 2.3)
			body.position = across + away
			body.face(Vector2(1, 0.45), true)
			_world.add_child(body)
			_bodies.append(body)
			_name_label("%s · %s" % [MonsterDef.Kin.keys()[kin].capitalize(), body_name], body.position + Vector3(0, 1.3, 0), 30)
			k += 1


## Every prop the game can field, in rows of seven.
func _show_props() -> void:
	var content := BattleContent.shared()
	var ids: Array = []
	for id in BattleContent.sorted_ids(content.props):
		if ContentStatus.in_game(content.props[id]):
			ids.append(id)
	for k in ids.size():
		var def: PropDef = content.props[ids[k]]
		var body := PropBody.create(def, def.color.lerp(BattleView.MUTE, 0.25))
		var across := Vector3(1, 0, -1).normalized() * ((k % 7) * 1.4 - 4.2)
		var away := Vector3(1, 0, 1).normalized() * ((k / 7) * 2.3 - 2.3)
		body.position = across + away
		_world.add_child(body)
		_props.append(body)
		_name_label(def.display_name, body.position + Vector3(0, 1.3, 0), 30)


func _name_label(text: String, at: Vector3, size_px: int) -> void:
	var l := Label3D.new()
	l.text = text
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.no_depth_test = true
	l.pixel_size = 0.004
	l.font_size = size_px
	l.modulate = UiTheme.INK
	l.outline_size = 0
	l.position = at
	_world.add_child(l)


func _process(delta: float) -> bool:
	_clock += delta
	if not _shot and _clock >= SHOT_AT:
		_shot = true
		if _folder != "":
			root.get_texture().get_image().save_png(_folder.path_join("%d_%s.png" % [_move, _moves[_move]]))
	if _clock < STEP:
		return false
	_clock = 0.0
	_move += 1
	if _move >= _moves.size():
		if _folder != "":
			return true
		_move = 0
	_shot = false
	_label.text = _moves[_move]
	for b in _bodies:
		b.stand_up()
		match _moves[_move]:
			"walk":
				b.walk(STEP - 0.3)
			"attack":
				b.attack()
			"cast":
				b.cast()
			"hit":
				b.hit()
			"pushed":
				b.pushed(Vector2(-1, -1), 0.28)
			"healed":
				b.healed()
			"defeated":
				b.defeated()
	for f in _props:
		f.restore()
		f.set_worn(_moves[_move] == "worn")
		match _moves[_move]:
			"appear":
				f.appear()
			"hit":
				f.hit()
			"slide":
				f.slide_from(Vector3(-0.7, 0, -0.7), 0.28)
			"spring":
				f.spring()
			"fall":
				f.fall()
	return false
