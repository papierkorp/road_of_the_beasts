class_name PropBody
extends InkFigure
## The figure of a prop: simple parts in the colour of the prop, drawn with an ink line (`InkFigure`), and its
## movements (appearing, being hit, sliding to another square, a trap going off, falling apart). Which figure a
## prop has is its `PropDef.figure`. Look only: no rule reads it. The figure stands on y = 0.

## The fall of a destroyed prop is over.
signal fell

## Top of the figure: where its label goes.
var height := 0.6

var _act: Node3D
var _rest := {}                # joint -> rotation
var _sways: Array = []         # [joint, axis, radians, speed, phase]
var _spins: Array = []         # [joint, turns in radians per second]
var _time := 0.0
var _act_tween: Tween
var _falling := false
var _worn := false
var _plain := {}               # name -> Color (the tones of a prop that is not worn)


## The figure of `def` in `color`.
static func create(def: PropDef, color: Color) -> PropBody:
	var b := PropBody.new()
	b._build(def, color)
	return b


func _build(def: PropDef, color: Color) -> void:
	_time = float(hash(get_instance_id()) % 628) / 100.0       # figures do not move in step
	_act = Node3D.new()
	add_child(_act)
	_materials(color)
	_plain = _tints.duplicate()
	match def.figure:
		"tablet":
			_build_tablet()
		"bamboo":
			_build_bamboo()
		"beam":
			_build_beam()
		"urn":
			_build_urn()
		"wall":
			_build_wall()
		"screen":
			_build_screen()
		"brazier":
			_build_brazier()
		"gong":
			_build_gong()
		"drum":
			_build_drum()
		"column":
			_build_column()
		"lantern":
			_build_lantern()
		"tree":
			_build_tree()
		"lion":
			_build_lion()
		"idol":
			_build_idol()
		"bell":
			_build_bell()
		"banner":
			_build_banner()
		"rune":
			_build_rune()
		"spikes":
			_build_spikes()
		"mine":
			_build_mine()
		"vortex":
			_build_vortex()
		_:
			if def.solid:
				_build_block(BattleView.AIR_H + 0.6 if def.layer == "both" else 0.52)
			else:
				_plate(&"main")
	for e in _sways:
		_rest[e[0]] = (e[0] as Node3D).rotation
	set_process(not _sways.is_empty() or not _spins.is_empty())


# ---------- what the view asks for ----------

## Grow out of the square, after `delay` seconds.
func appear(delay: float = 0.0) -> void:
	var tw := _begin()
	if tw == null:
		return
	_act.scale = Vector3.ONE * 0.02
	if delay > 0.0:
		tw.tween_interval(delay)
	tw.tween_property(_act, "scale", Vector3.ONE, 0.26).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Shake and flash pale, after `delay` seconds.
func hit(delay: float = 0.0) -> void:
	var tw := _begin()
	if tw == null:
		return
	flash(UiTheme.PAPER_LIGHT, delay)
	if delay > 0.0:
		tw.tween_interval(delay)
	tw.tween_property(_act, "rotation:z", 0.16, 0.04)
	tw.parallel().tween_property(_act, "scale", Vector3(1.08, 0.9, 1.08), 0.04)
	tw.tween_property(_act, "rotation:z", -0.12, 0.06)
	tw.tween_property(_act, "rotation:z", 0.06, 0.06)
	tw.tween_property(_act, "rotation:z", 0.0, 0.08)
	tw.parallel().tween_property(_act, "scale", Vector3.ONE, 0.08)


## Arrive from `offset` (where it stood, seen from here), leaning against the way.
func slide_from(offset: Vector3, seconds: float) -> void:
	var tw := _begin()
	if tw == null:
		return
	_act.position = offset
	var way := -offset.normalized()
	_act.rotation = Vector3(-way.z, 0.0, way.x) * 0.3
	tw.tween_property(_act, "position", Vector3.ZERO, seconds).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(_act, "rotation", Vector3(way.z, 0.0, -way.x) * 0.1, 0.07)
	tw.tween_property(_act, "rotation", Vector3.ZERO, 0.1)


## A trap goes off: it snaps up and flashes in cinnabar.
func spring(delay: float = 0.0) -> void:
	var tw := _begin()
	if tw == null:
		return
	flash(UiTheme.CINNABAR, delay)
	if delay > 0.0:
		tw.tween_interval(delay)
	tw.tween_property(_act, "scale", Vector3(1.25, 2.4, 1.25), 0.07).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(_act, "scale", Vector3.ONE, 0.2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)


## Fall apart, after `delay` seconds; then `fell`.
func fall(delay: float = 0.0) -> void:
	var tw := _begin()
	if tw == null:
		return
	_falling = true
	flash(UiTheme.PAPER_LIGHT, delay)
	if delay > 0.0:
		tw.tween_interval(delay)
	tw.tween_property(_act, "scale", Vector3(1.2, 0.78, 1.2), 0.08)
	tw.tween_property(_act, "scale", Vector3(1.35, 0.05, 1.35), 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(_act, "scale", Vector3.ONE * 0.02, 0.14)
	tw.tween_callback(fell.emit)


## Whole again (a figure that fell apart and is shown again).
func restore() -> void:
	_falling = false
	_settle()


## A prop without HP that still stands is drawn darker.
func set_worn(worn: bool) -> void:
	if worn == _worn:
		return
	_worn = worn
	for key in _plain:
		_tints[key] = (_plain[key] as Color).darkened(0.35) if worn else _plain[key]
	_show_flash()


## Tint the parts for a moment; the figure is painted every frame only while the flash lasts.
func flash(color: Color, delay: float = 0.0) -> void:
	super(color, delay)
	if _flash_tween != null:
		set_process(true)
		_flash_tween.tween_callback(func() -> void:
			_show_flash()
			set_process(not _sways.is_empty() or not _spins.is_empty()))


func _begin() -> Tween:
	if _falling or not is_inside_tree():
		return null
	_settle()
	_act_tween = create_tween()
	return _act_tween


func _settle() -> void:
	if _act_tween != null:
		_act_tween.kill()
	_act.position = Vector3.ZERO
	_act.rotation = Vector3.ZERO
	_act.scale = Vector3.ONE


func _process(delta: float) -> void:
	_time += delta
	_show_flash()
	for e in _sways:
		var j: Node3D = e[0]
		j.rotation = (_rest[j] as Vector3) + (e[1] as Vector3) * (float(e[2]) * sin(_time * float(e[3]) + float(e[4])))
	for e in _spins:
		(e[0] as Node3D).rotation.y = _time * float(e[1])


# ---------- the figures ----------

func _torus(inner: float, outer: float) -> TorusMesh:
	var m := TorusMesh.new()
	m.inner_radius = inner
	m.outer_radius = outer
	m.rings = 24
	m.ring_segments = 8
	return m


## The flat stone a walkable prop lies on.
func _plate(key: StringName) -> void:
	_part(_act, _cone(0.4, 0.37, 0.05), key, Vector3(0, 0.025, 0))
	height = 0.06


func _build_block(tall: float) -> void:
	_part(_act, _box(Vector3(0.62, tall, 0.62)), &"main", Vector3(0, tall / 2.0, 0))
	height = tall


## An upright slab with three lines of writing on a base.
func _build_tablet() -> void:
	_part(_act, _box(Vector3(0.42, 0.08, 0.26)), &"dark", Vector3(0, 0.04, 0))
	_part(_act, _box(Vector3(0.3, 0.56, 0.1)), &"main", Vector3(0, 0.36, 0))
	_part(_act, _box(Vector3(0.35, 0.05, 0.14)), &"dark", Vector3(0, 0.665, 0))
	for i in 3:
		for z in [-0.052, 0.052]:
			_part(_act, _box(Vector3(0.17 - 0.03 * i, 0.022, 0.01)), &"ink", Vector3(0, 0.5 - 0.09 * i, z))
	height = 0.7


## Four stalks with leaves that sway.
func _build_bamboo() -> void:
	var spots := [Vector3(-0.14, 0, 0.06), Vector3(0.06, 0, 0.14), Vector3(0.15, 0, -0.08), Vector3(-0.05, 0, -0.14)]
	for i in spots.size():
		var tall := 0.66 + 0.1 * ((i * 2) % 3)
		var stalk := _joint(_act, spots[i])
		_part(stalk, _capsule(0.032, tall), &"main", Vector3(0, tall / 2.0, 0))
		_part(stalk, _cone(0.04, 0.04, 0.025), &"dark", Vector3(0, tall * 0.4, 0))
		_part(stalk, _cone(0.04, 0.04, 0.025), &"dark", Vector3(0, tall * 0.72, 0))
		for s in [-1.0, 1.0]:
			_part(stalk, _prism(Vector3(0.07, 0.2, 0.02)), &"light", Vector3(s * 0.07, tall - 0.04, 0), Vector3(0, 40.0 * i, -s * 62))
		_sways.append([stalk, Vector3.FORWARD, 0.06, 1.3 + 0.2 * i, float(i)])
	height = 0.92


## A beam lying on two blocks.
func _build_beam() -> void:
	for s in [-1.0, 1.0]:
		_part(_act, _box(Vector3(0.12, 0.14, 0.26)), &"dark", Vector3(s * 0.22, 0.07, 0))
	_part(_act, _box(Vector3(0.74, 0.17, 0.17)), &"main", Vector3(0, 0.225, 0))
	_part(_act, _box(Vector3(0.6, 0.12, 0.13)), &"light", Vector3(0.02, 0.37, 0.0), Vector3(0, 7, 0))
	height = 0.44


## A pot with a neck and a rim.
func _build_urn() -> void:
	_part(_act, _cone(0.13, 0.15, 0.05), &"dark", Vector3(0, 0.025, 0))
	_part(_act, _ball(0.22), &"main", Vector3(0, 0.26, 0), Vector3.ZERO, Vector3(1.0, 1.08, 1.0))
	_part(_act, _torus(0.2, 0.235), &"dark", Vector3(0, 0.27, 0), Vector3.ZERO, Vector3(1.0, 0.6, 1.0))
	_part(_act, _cone(0.13, 0.1, 0.1), &"main", Vector3(0, 0.5, 0))
	_part(_act, _cone(0.135, 0.145, 0.045), &"light", Vector3(0, 0.565, 0))
	height = 0.6


## A wall of packed earth with two blocks on top.
func _build_wall() -> void:
	_part(_act, _box(Vector3(0.8, 0.26, 0.34)), &"main", Vector3(0, 0.13, 0))
	_part(_act, _box(Vector3(0.36, 0.2, 0.3)), &"dark", Vector3(-0.2, 0.36, 0), Vector3(0, 4, 0))
	_part(_act, _box(Vector3(0.34, 0.17, 0.28)), &"light", Vector3(0.2, 0.345, 0.01), Vector3(0, -5, 0))
	height = 0.48


## A screen of reed between two posts.
func _build_screen() -> void:
	for s in [-1.0, 1.0]:
		_part(_act, _capsule(0.028, 0.66), &"dark", Vector3(s * 0.32, 0.33, 0))
	_part(_act, _box(Vector3(0.6, 0.44, 0.03)), &"light", Vector3(0, 0.36, 0))
	for y in [0.14, 0.36, 0.58]:
		_part(_act, _box(Vector3(0.66, 0.03, 0.045)), &"dark", Vector3(0, y, 0))
	height = 0.68


## A bowl on three legs with a flame.
func _build_brazier() -> void:
	for i in 3:
		var leg := _joint(_act, Vector3.ZERO, Vector3(0, 120.0 * i, 0))
		_part(leg, _capsule(0.025, 0.36), &"dark", Vector3(0.15, 0.16, 0), Vector3(0, 0, 22))
	_part(_act, _ball(0.22), &"dark", Vector3(0, 0.36, 0), Vector3.ZERO, Vector3(1.0, 0.55, 1.0))
	_part(_act, _ball(0.16), &"light", Vector3(0, 0.42, 0), Vector3.ZERO, Vector3(1.0, 0.4, 1.0))
	var flame := _joint(_act, Vector3(0, 0.44, 0))
	_part(flame, _cone(0.1, 0.0, 0.28), &"main", Vector3(0, 0.14, 0))
	var tongue := _joint(flame, Vector3(0.05, 0.04, 0.03))
	_part(tongue, _cone(0.05, 0.0, 0.16), &"light", Vector3(0, 0.08, 0))
	_sways.append([flame, Vector3.FORWARD, 0.22, 4.0, 0.0])
	_sways.append([flame, Vector3.RIGHT, 0.14, 3.1, 1.0])
	_sways.append([tongue, Vector3.FORWARD, 0.3, 5.3, 2.0])
	height = 0.74


## A disc hanging in a frame.
func _build_gong() -> void:
	for s in [-1.0, 1.0]:
		_part(_act, _box(Vector3(0.07, 0.72, 0.07)), &"dark", Vector3(s * 0.31, 0.36, 0))
		_part(_act, _box(Vector3(0.12, 0.05, 0.22)), &"dark", Vector3(s * 0.31, 0.025, 0))
	_part(_act, _box(Vector3(0.78, 0.07, 0.09)), &"dark", Vector3(0, 0.72, 0))
	var disc := _joint(_act, Vector3(0, 0.69, 0))
	_part(disc, _cone(0.21, 0.21, 0.04), &"main", Vector3(0, -0.29, 0), Vector3(90, 0, 0))
	for z in [-0.03, 0.03]:
		_part(disc, _ball(0.055), &"light", Vector3(0, -0.29, z), Vector3.ZERO, Vector3(1.0, 1.0, 0.5))
	_sways.append([disc, Vector3.RIGHT, 0.07, 1.5, 0.0])
	height = 0.78


## A drum standing on feet, two sticks on its skin.
func _build_drum() -> void:
	for i in 3:
		var foot := _joint(_act, Vector3.ZERO, Vector3(0, 120.0 * i + 30.0, 0))
		_part(foot, _box(Vector3(0.1, 0.1, 0.1)), &"dark", Vector3(0.2, 0.05, 0))
	_part(_act, _cone(0.24, 0.24, 0.34), &"main", Vector3(0, 0.27, 0))
	_part(_act, _ball(0.26), &"main", Vector3(0, 0.27, 0), Vector3.ZERO, Vector3(1.0, 0.5, 1.0))
	_part(_act, _cone(0.25, 0.25, 0.035), &"light", Vector3(0, 0.455, 0))
	_part(_act, _cone(0.25, 0.25, 0.035), &"dark", Vector3(0, 0.1, 0))
	for s in [-1.0, 1.0]:
		_part(_act, _capsule(0.02, 0.3), &"dark", Vector3(s * 0.04, 0.495, 0), Vector3(90, s * 28, 0))
	height = 0.52


## A pillar with a foot and a small roof.
func _build_column() -> void:
	_part(_act, _box(Vector3(0.36, 0.1, 0.36)), &"dark", Vector3(0, 0.05, 0))
	_part(_act, _cone(0.14, 0.115, 0.78), &"main", Vector3(0, 0.49, 0))
	_part(_act, _box(Vector3(0.3, 0.07, 0.3)), &"light", Vector3(0, 0.915, 0))
	var roof := _cone(0.4, 0.06, 0.17)
	roof.radial_segments = 4                       # four sides, as a pagoda roof
	_part(_act, roof, &"dark", Vector3(0, 1.035, 0), Vector3(0, 45, 0))
	_part(_act, _ball(0.05), &"main", Vector3(0, 1.14, 0))
	height = 1.2


## A paper lantern on a short post.
func _build_lantern() -> void:
	_part(_act, _box(Vector3(0.22, 0.05, 0.22)), &"dark", Vector3(0, 0.025, 0))
	_part(_act, _box(Vector3(0.055, 0.26, 0.055)), &"dark", Vector3(0, 0.17, 0))
	var body := _joint(_act, Vector3(0, 0.3, 0))
	_part(body, _cone(0.1, 0.1, 0.04), &"dark", Vector3(0, 0.02, 0))
	_part(body, _ball(0.19), &"main", Vector3(0, 0.22, 0), Vector3.ZERO, Vector3(1.0, 1.1, 1.0))
	for y in [0.14, 0.22, 0.3]:
		var r := 0.165 if y != 0.22 else 0.185
		_part(body, _torus(r, r + 0.012), &"light", Vector3(0, y, 0))
	_part(body, _cone(0.1, 0.1, 0.04), &"dark", Vector3(0, 0.425, 0))
	_part(body, _ball(0.035), &"dark", Vector3(0, 0.47, 0))
	_sways.append([body, Vector3.FORWARD, 0.05, 1.4, 0.0])
	height = 0.8


## A small tree in blossom.
func _build_tree() -> void:
	_part(_act, _cone(0.09, 0.06, 0.46), &"dark", Vector3(0, 0.23, 0))
	var crown := _joint(_act, Vector3(0, 0.44, 0))
	_part(crown, _ball(0.23), &"main", Vector3(0, 0.2, 0))
	_part(crown, _ball(0.17), &"main", Vector3(0.18, 0.1, 0.05))
	_part(crown, _ball(0.16), &"main", Vector3(-0.17, 0.12, -0.06))
	_part(crown, _ball(0.14), &"main", Vector3(0.0, 0.1, -0.17))
	for spot in [Vector3(0.1, 0.38, 0.1), Vector3(-0.14, 0.3, 0.12), Vector3(0.24, 0.2, 0.14), Vector3(-0.05, 0.2, 0.22), Vector3(-0.24, 0.22, -0.14)]:
		_part(crown, _ball(0.05), &"light", spot)
	_sways.append([crown, Vector3.FORWARD, 0.045, 1.1, 0.0])
	_sways.append([crown, Vector3.RIGHT, 0.035, 0.8, 1.0])
	height = 0.92


## A seated guardian of stone on a plinth.
func _build_lion() -> void:
	_part(_act, _box(Vector3(0.5, 0.12, 0.5)), &"dark", Vector3(0, 0.06, 0))
	_part(_act, _box(Vector3(0.28, 0.28, 0.32)), &"main", Vector3(0, 0.25, -0.04), Vector3(-14, 0, 0))
	for s in [-1.0, 1.0]:
		_part(_act, _box(Vector3(0.09, 0.26, 0.09)), &"main", Vector3(s * 0.09, 0.25, 0.14))
		_part(_act, _box(Vector3(0.11, 0.07, 0.14)), &"light", Vector3(s * 0.09, 0.155, 0.17))
	_part(_act, _box(Vector3(0.34, 0.3, 0.16)), &"dark", Vector3(0, 0.5, 0.0))
	_part(_act, _box(Vector3(0.24, 0.22, 0.2)), &"main", Vector3(0, 0.5, 0.1))
	_part(_act, _box(Vector3(0.13, 0.08, 0.08)), &"light", Vector3(0, 0.455, 0.22))
	for s in [-1.0, 1.0]:
		_part(_act, _ball(0.024), &"ink", Vector3(s * 0.065, 0.545, 0.203))
	height = 0.68


## A carved stake set with thorns.
func _build_idol() -> void:
	_part(_act, _cone(0.15, 0.1, 0.58), &"main", Vector3(0, 0.29, 0))
	_part(_act, _ball(0.135), &"dark", Vector3(0, 0.64, 0))
	for s in [-1.0, 1.0]:
		_part(_act, _ball(0.024), &"ink", Vector3(s * 0.05, 0.655, 0.122))
	for ring in 2:
		for i in 5:
			var arm := _joint(_act, Vector3(0, 0.2 + 0.2 * ring, 0), Vector3(0, 72.0 * i + 36.0 * ring, 0))
			_part(arm, _cone(0.035, 0.0, 0.2), &"light", Vector3(0.2 - 0.02 * ring, 0.03, 0), Vector3(0, 0, -72))
	_part(_act, _cone(0.04, 0.0, 0.16), &"light", Vector3(0, 0.83, 0))
	height = 0.92


## A bell hanging in a frame.
func _build_bell() -> void:
	for s in [-1.0, 1.0]:
		_part(_act, _box(Vector3(0.07, 0.8, 0.07)), &"dark", Vector3(s * 0.3, 0.4, 0))
		_part(_act, _box(Vector3(0.12, 0.05, 0.24)), &"dark", Vector3(s * 0.3, 0.025, 0))
	_part(_act, _box(Vector3(0.76, 0.07, 0.1)), &"dark", Vector3(0, 0.8, 0))
	var bell := _joint(_act, Vector3(0, 0.77, 0))
	_part(bell, _ball(0.04), &"dark", Vector3(0, -0.04, 0))
	_part(bell, _cone(0.2, 0.13, 0.3), &"main", Vector3(0, -0.24, 0))
	_part(bell, _ball(0.13), &"main", Vector3(0, -0.1, 0), Vector3.ZERO, Vector3(1.0, 0.7, 1.0))
	_part(bell, _torus(0.185, 0.22), &"light", Vector3(0, -0.385, 0), Vector3.ZERO, Vector3(1.0, 0.6, 1.0))
	_part(bell, _ball(0.05), &"dark", Vector3(0, -0.43, 0))
	_sways.append([bell, Vector3.RIGHT, 0.09, 1.7, 0.0])
	height = 0.86


## A flag on a pole.
func _build_banner() -> void:
	_part(_act, _cone(0.1, 0.07, 0.06), &"dark", Vector3(0, 0.03, 0))
	_part(_act, _capsule(0.025, 1.0), &"dark", Vector3(0, 0.5, 0))
	var flag := _joint(_act, Vector3(0, 0.94, 0))
	_part(flag, _box(Vector3(0.34, 0.3, 0.02)), &"main", Vector3(0.19, -0.15, 0))
	_part(flag, _box(Vector3(0.34, 0.05, 0.025)), &"light", Vector3(0.19, -0.15, 0))
	_sways.append([flag, Vector3.UP, 0.35, 2.2, 0.0])
	height = 1.05


## A flat stone with a ring cut into it.
func _build_rune() -> void:
	_plate(&"main")
	_part(_act, _torus(0.2, 0.26), &"dark", Vector3(0, 0.05, 0), Vector3.ZERO, Vector3(1.0, 0.3, 1.0))
	_part(_act, _ball(0.07), &"light", Vector3(0, 0.05, 0), Vector3.ZERO, Vector3(1.0, 0.3, 1.0))
	height = 0.08


## A plate with spikes.
func _build_spikes() -> void:
	_plate(&"dark")
	_part(_act, _cone(0.045, 0.0, 0.2), &"light", Vector3(0, 0.14, 0))
	for i in 5:
		var arm := _joint(_act, Vector3.ZERO, Vector3(0, 72.0 * i, 0))
		_part(arm, _cone(0.04, 0.0, 0.16), &"main", Vector3(0.23, 0.12, 0))
	height = 0.24


## A plate with a charged dome.
func _build_mine() -> void:
	_plate(&"dark")
	_part(_act, _ball(0.2), &"main", Vector3(0, 0.05, 0), Vector3.ZERO, Vector3(1.0, 0.62, 1.0))
	_part(_act, _torus(0.19, 0.225), &"dark", Vector3(0, 0.06, 0), Vector3.ZERO, Vector3(1.0, 0.5, 1.0))
	_part(_act, _ball(0.05), &"light", Vector3(0, 0.175, 0))
	height = 0.2


## A plate with two rings that turn.
func _build_vortex() -> void:
	_plate(&"dark")
	var outer := _joint(_act, Vector3(0, 0.06, 0))
	_part(outer, _torus(0.25, 0.3), &"main", Vector3.ZERO, Vector3.ZERO, Vector3(1.0, 0.4, 1.0))
	_part(outer, _ball(0.05), &"light", Vector3(0.275, 0.01, 0))
	var inner := _joint(_act, Vector3(0, 0.07, 0))
	_part(inner, _torus(0.1, 0.15), &"light", Vector3.ZERO, Vector3.ZERO, Vector3(1.0, 0.4, 1.0))
	_part(inner, _ball(0.04), &"main", Vector3(0.125, 0.01, 0))
	_spins.append([outer, 1.6])
	_spins.append([inner, -2.6])
	height = 0.1
