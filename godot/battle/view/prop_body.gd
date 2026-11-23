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
	_tones(color)
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


# ---------- tones ----------

## The tones of a prop: weathered tones of its colour, old wood, bronze and gold, rope, paper for seals, and
## one that glows, used only where a prop acts by itself (a rune, a trap, a fire).
func _tones(color: Color) -> void:
	var worn := Color.from_hsv(color.h, minf(1.0, color.s * 1.05), color.v * 0.62)
	_material(&"main", worn)
	_material(&"dark", UiTheme.INK.lerp(worn, 0.3))
	_material(&"light", Color.from_hsv(color.h, color.s * 0.85, color.v * 0.86))
	_material(&"wood", UiTheme.OCHRE.lerp(UiTheme.INK, 0.6))
	_material(&"stone", UiTheme.INK_SOFT.lerp(UiTheme.PAPER_SHADE, 0.22))
	_material(&"metal", UiTheme.OCHRE.lerp(UiTheme.INK, 0.4))
	_material(&"gold", Color.from_hsv(UiTheme.OCHRE.h, 0.7, 0.95))
	_material(&"rope", UiTheme.OCHRE.lerp(UiTheme.PAPER_SHADE, 0.35))
	_material(&"paper", UiTheme.PAPER_SHADE.lerp(UiTheme.OCHRE, 0.12))
	_material(&"seal", UiTheme.CINNABAR.darkened(0.15))
	_material(&"glow", Color.from_hsv(color.h, minf(1.0, color.s * 1.35 + 0.1), 0.97))
	(_mats[&"glow"] as StandardMaterial3D).shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for key: StringName in [&"metal", &"gold"]:
		var m: StandardMaterial3D = _mats[key]
		m.specular_mode = BaseMaterial3D.SPECULAR_TOON
		m.roughness = 0.35
	var ink := StandardMaterial3D.new()
	ink.albedo_color = UiTheme.INK
	ink.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_mats[&"ink"] = ink


# ---------- parts ----------

func _torus(inner: float, outer: float) -> TorusMesh:
	var m := TorusMesh.new()
	m.inner_radius = inner
	m.outer_radius = outer
	m.rings = 24
	m.ring_segments = 8
	return m


## A strip of paper with a stroke of ink: a seal. It hangs down from `pos` and faces the direction `turn`
## (degrees around Y).
func _seal(parent: Node3D, pos: Vector3, turn: float = 0.0, tall: float = 0.14) -> void:
	var j := _joint(parent, pos, Vector3(0, turn, 0))
	_part(j, _box(Vector3(0.05, tall, 0.012)), &"paper", Vector3(0, -tall * 0.5, 0))
	_part(j, _box(Vector3(0.018, tall * 0.6, 0.016)), &"ink", Vector3(0, -tall * 0.5, 0))


## A crack: a stroke of ink on a face that looks along Z.
func _crack(parent: Node3D, pos: Vector3, length: float, tilt: float) -> void:
	_part(parent, _box(Vector3(0.012, length, 0.012)), &"ink", pos, Vector3(0, 0, tilt))
	_part(parent, _box(Vector3(0.01, length * 0.5, 0.012)), &"ink", pos + Vector3(length * 0.2, -length * 0.3, 0), Vector3(0, 0, tilt - 55.0))


## The flat stone a walkable prop lies on.
func _plate(key: StringName) -> void:
	_part(_act, _cone(0.4, 0.37, 0.05), key, Vector3(0, 0.025, 0))
	height = 0.06


## Two posts with pointed heads and a beam with raised ends: the frame a gong or a bell hangs in.
func _frame(half: float, tall: float) -> void:
	for s: float in [-1.0, 1.0]:
		_part(_act, _box(Vector3(0.14, 0.06, 0.26)), &"stone", Vector3(s * half, 0.03, 0))
		_part(_act, _box(Vector3(0.07, tall, 0.07)), &"wood", Vector3(s * half, tall * 0.5, 0))
		_part(_act, _cone(0.05, 0.0, 0.1), &"wood", Vector3(s * half, tall + 0.05, 0))
		_part(_act, _box(Vector3(0.09, 0.04, 0.09)), &"metal", Vector3(s * half, tall * 0.45, 0))
		_part(_act, _box(Vector3(0.16, 0.06, 0.09)), &"wood", Vector3(s * (half + 0.13), tall - 0.04, 0), Vector3(0, 0, s * 22))
	_part(_act, _box(Vector3(half * 2.0 + 0.16, 0.07, 0.1)), &"wood", Vector3(0, tall - 0.08, 0))


# ---------- the figures ----------

## A block of stone bound with a band of bronze.
func _build_block(tall: float) -> void:
	_part(_act, _box(Vector3(0.62, tall, 0.62)), &"main", Vector3(0, tall / 2.0, 0))
	_part(_act, _box(Vector3(0.65, 0.06, 0.65)), &"metal", Vector3(0, tall * 0.7, 0))
	_crack(_act, Vector3(0.1, tall * 0.35, 0.315), tall * 0.4, 20)
	height = tall


## A weathered slab with lines of writing on a stepped base, under a pointed cap, bound with a rope and seals.
func _build_tablet() -> void:
	_part(_act, _box(Vector3(0.46, 0.06, 0.3)), &"stone", Vector3(0, 0.03, 0))
	_part(_act, _box(Vector3(0.38, 0.06, 0.22)), &"dark", Vector3(0, 0.09, 0))
	_part(_act, _box(Vector3(0.3, 0.54, 0.1)), &"main", Vector3(0, 0.39, 0))
	_part(_act, _prism(Vector3(0.38, 0.12, 0.15)), &"dark", Vector3(0, 0.72, 0))
	for i in 3:
		for z: float in [-0.052, 0.052]:
			_part(_act, _box(Vector3(0.022, 0.2 - 0.04 * i, 0.01)), &"ink", Vector3(0.08 - 0.08 * i, 0.5 + 0.02 * i, z))
	_part(_act, _box(Vector3(0.33, 0.035, 0.13)), &"rope", Vector3(0, 0.28, 0))
	_seal(_act, Vector3(-0.08, 0.27, 0.07), 0, 0.12)
	_seal(_act, Vector3(0.07, 0.27, 0.07), 0, 0.09)
	_crack(_act, Vector3(0.1, 0.2, 0.052), 0.12, -25)
	height = 0.8


## Stakes of bamboo cut to points and bound with a rope; a few leaves are left on them.
func _build_bamboo() -> void:
	var spots := [Vector3(-0.14, 0, 0.06), Vector3(0.06, 0, 0.14), Vector3(0.15, 0, -0.08), Vector3(-0.05, 0, -0.14), Vector3(0.0, 0, 0.0)]
	for i in spots.size():
		var tall := 0.6 + 0.1 * ((i * 2) % 3)
		var lean := (spots[i] as Vector3) * 60.0
		var stalk := _joint(_act, spots[i], Vector3(lean.z, 0, -lean.x))
		_part(stalk, _capsule(0.034, tall), &"main", Vector3(0, tall / 2.0, 0))
		_part(stalk, _cone(0.04, 0.04, 0.025), &"dark", Vector3(0, tall * 0.4, 0))
		_part(stalk, _cone(0.04, 0.04, 0.025), &"dark", Vector3(0, tall * 0.72, 0))
		_part(stalk, _cone(0.034, 0.0, 0.14), &"paper", Vector3(0, tall + 0.05, 0))
		if i % 2 == 0:
			_part(stalk, _prism(Vector3(0.06, 0.2, 0.02)), &"dark", Vector3(0.07, tall * 0.78, 0), Vector3(0, 40.0 * i, -62))
		_sways.append([stalk, Vector3.FORWARD, 0.03, 1.3 + 0.2 * i, float(i)])
	_part(_act, _torus(0.16, 0.2), &"rope", Vector3(0, 0.3, 0))
	height = 0.96


## A heavy timber bound in iron on two stones, a splintered one across it.
func _build_beam() -> void:
	for s: float in [-1.0, 1.0]:
		_part(_act, _box(Vector3(0.14, 0.14, 0.28)), &"stone", Vector3(s * 0.22, 0.07, 0))
		_part(_act, _box(Vector3(0.05, 0.19, 0.19)), &"metal", Vector3(s * 0.27, 0.225, 0))
		_part(_act, _ball(0.022), &"gold", Vector3(s * 0.27, 0.225, 0.1))
	_part(_act, _box(Vector3(0.74, 0.17, 0.17)), &"main", Vector3(0, 0.225, 0))
	_part(_act, _box(Vector3(0.5, 0.12, 0.13)), &"dark", Vector3(-0.03, 0.37, 0.0), Vector3(0, 9, 0))
	_part(_act, _prism(Vector3(0.12, 0.2, 0.13), 0.2), &"dark", Vector3(0.3, 0.37, -0.05), Vector3(0, 9, -90))
	height = 0.44


## A dark pot with a lid, a rope around its neck and a seal over its mouth.
func _build_urn() -> void:
	_part(_act, _cone(0.13, 0.15, 0.05), &"dark", Vector3(0, 0.025, 0))
	_part(_act, _ball(0.22), &"main", Vector3(0, 0.26, 0), Vector3.ZERO, Vector3(1.0, 1.08, 1.0))
	_part(_act, _torus(0.2, 0.235), &"dark", Vector3(0, 0.27, 0), Vector3.ZERO, Vector3(1.0, 0.6, 1.0))
	_part(_act, _cone(0.13, 0.1, 0.1), &"main", Vector3(0, 0.5, 0))
	_part(_act, _torus(0.095, 0.135), &"rope", Vector3(0, 0.49, 0))
	_part(_act, _cone(0.135, 0.145, 0.045), &"dark", Vector3(0, 0.565, 0))
	_part(_act, _ball(0.04), &"metal", Vector3(0, 0.61, 0))
	_part(_act, _box(Vector3(0.06, 0.012, 0.3)), &"paper", Vector3(0, 0.592, 0))
	_seal(_act, Vector3(0, 0.59, 0.148), 0, 0.2)
	height = 0.66


## A wall of packed earth and stone with sharpened stakes along its top.
func _build_wall() -> void:
	_part(_act, _box(Vector3(0.8, 0.26, 0.34)), &"main", Vector3(0, 0.13, 0))
	_part(_act, _box(Vector3(0.36, 0.2, 0.3)), &"dark", Vector3(-0.2, 0.36, 0), Vector3(0, 4, 0))
	_part(_act, _box(Vector3(0.34, 0.17, 0.28)), &"stone", Vector3(0.2, 0.345, 0.01), Vector3(0, -5, 0))
	_part(_act, _box(Vector3(0.2, 0.1, 0.36)), &"stone", Vector3(-0.22, 0.08, 0.0))
	for i in 5:
		var stake := _joint(_act, Vector3(-0.32 + 0.16 * i, 0.38, 0.1 if i % 2 == 0 else -0.08), Vector3(22 if i % 2 == 0 else -18, 0, 8.0 * (i - 2)))
		_part(stake, _cone(0.03, 0.0, 0.3), &"wood", Vector3(0, 0.1, 0))
	_crack(_act, Vector3(0.12, 0.14, 0.172), 0.14, 30)
	height = 0.6


## A screen of old reed between two pointed posts, lashed with rope, a seal on it.
func _build_screen() -> void:
	for s: float in [-1.0, 1.0]:
		_part(_act, _capsule(0.03, 0.66), &"wood", Vector3(s * 0.32, 0.33, 0))
		_part(_act, _cone(0.03, 0.0, 0.12), &"wood", Vector3(s * 0.32, 0.72, 0))
	_part(_act, _box(Vector3(0.6, 0.44, 0.03)), &"main", Vector3(0, 0.36, 0))
	for i in 6:
		_part(_act, _box(Vector3(0.012, 0.44, 0.036)), &"dark", Vector3(-0.25 + 0.1 * i, 0.36, 0))
	for y: float in [0.14, 0.58]:
		_part(_act, _box(Vector3(0.66, 0.035, 0.05)), &"rope", Vector3(0, y, 0))
	_seal(_act, Vector3(0.1, 0.56, 0.03), 0, 0.2)
	_seal(_act, Vector3(-0.1, 0.56, -0.03), 180, 0.2)
	height = 0.76


## A bowl of bronze on three legs, full of coals, with a fire that glows.
func _build_brazier() -> void:
	for i in 3:
		var leg := _joint(_act, Vector3.ZERO, Vector3(0, 120.0 * i, 0))
		_part(leg, _capsule(0.028, 0.36), &"metal", Vector3(0.15, 0.16, 0), Vector3(0, 0, 22))
		_part(leg, _cone(0.0, 0.03, 0.1), &"metal", Vector3(0.24, 0.4, 0), Vector3(0, 0, -30))
	_part(_act, _ball(0.22), &"metal", Vector3(0, 0.36, 0), Vector3.ZERO, Vector3(1.0, 0.55, 1.0))
	_part(_act, _torus(0.17, 0.215), &"gold", Vector3(0, 0.4, 0), Vector3.ZERO, Vector3(1.0, 0.6, 1.0))
	_part(_act, _ball(0.16), &"dark", Vector3(0, 0.42, 0), Vector3.ZERO, Vector3(1.0, 0.4, 1.0))
	var flame := _joint(_act, Vector3(0, 0.44, 0))
	_part(flame, _cone(0.11, 0.0, 0.32), &"glow", Vector3(0, 0.16, 0))
	var tongue := _joint(flame, Vector3(0.05, 0.04, 0.03))
	_part(tongue, _cone(0.05, 0.0, 0.2), &"glow", Vector3(0, 0.1, 0))
	var second := _joint(flame, Vector3(-0.06, 0.02, -0.03))
	_part(second, _cone(0.045, 0.0, 0.16), &"light", Vector3(0, 0.08, 0))
	_sways.append([flame, Vector3.FORWARD, 0.22, 4.0, 0.0])
	_sways.append([flame, Vector3.RIGHT, 0.14, 3.1, 1.0])
	_sways.append([tongue, Vector3.FORWARD, 0.3, 5.3, 2.0])
	_sways.append([second, Vector3.FORWARD, 0.3, 4.6, 0.5])
	height = 0.8


## A disc of bronze with a golden boss, hanging in a frame.
func _build_gong() -> void:
	_frame(0.31, 0.8)
	var disc := _joint(_act, Vector3(0, 0.69, 0))
	for s: float in [-1.0, 1.0]:
		_part(disc, _box(Vector3(0.012, 0.14, 0.012)), &"ink", Vector3(s * 0.1, -0.06, 0))
	_part(disc, _cone(0.22, 0.22, 0.04), &"main", Vector3(0, -0.31, 0), Vector3(90, 0, 0))
	for z: float in [-0.022, 0.022]:
		_part(disc, _ball(0.06), &"gold", Vector3(0, -0.31, z * 1.4), Vector3.ZERO, Vector3(1.0, 1.0, 0.5))
	_sways.append([disc, Vector3.RIGHT, 0.07, 1.5, 0.0])
	height = 0.92


## A war drum on iron feet: studded rims, two sticks, and a sign on its skin that glows.
func _build_drum() -> void:
	for i in 3:
		var foot := _joint(_act, Vector3.ZERO, Vector3(0, 120.0 * i + 30.0, 0))
		_part(foot, _box(Vector3(0.1, 0.1, 0.1)), &"metal", Vector3(0.2, 0.05, 0))
	_part(_act, _cone(0.24, 0.24, 0.34), &"main", Vector3(0, 0.27, 0))
	_part(_act, _ball(0.26), &"main", Vector3(0, 0.27, 0), Vector3.ZERO, Vector3(1.0, 0.5, 1.0))
	_part(_act, _cone(0.25, 0.25, 0.035), &"paper", Vector3(0, 0.455, 0))
	_part(_act, _torus(0.225, 0.262), &"dark", Vector3(0, 0.43, 0), Vector3.ZERO, Vector3(1.0, 0.8, 1.0))
	_part(_act, _cone(0.25, 0.25, 0.035), &"dark", Vector3(0, 0.1, 0))
	for i in 8:
		var a := TAU * i / 8.0
		_part(_act, _ball(0.022), &"gold", Vector3(sin(a) * 0.26, 0.42, cos(a) * 0.26))
	_part(_act, _torus(0.07, 0.1), &"glow", Vector3(0, 0.472, 0), Vector3.ZERO, Vector3(1.0, 0.25, 1.0))
	_part(_act, _box(Vector3(0.3, 0.012, 0.03)), &"glow", Vector3(0, 0.474, 0), Vector3(0, 45, 0))
	for s: float in [-1.0, 1.0]:
		_part(_act, _capsule(0.02, 0.3), &"wood", Vector3(s * 0.13, 0.5, 0.02), Vector3(90, s * 28, 0))
	height = 0.54


## A lacquered pillar with bands of bronze on a stone foot, under a small roof with raised corners; a seal on it.
func _build_column() -> void:
	_part(_act, _box(Vector3(0.38, 0.1, 0.38)), &"stone", Vector3(0, 0.05, 0))
	_part(_act, _cone(0.14, 0.115, 0.78), &"main", Vector3(0, 0.49, 0))
	for y: float in [0.2, 0.78]:
		_part(_act, _cone(0.145, 0.14, 0.05), &"metal", Vector3(0, y, 0))
	_part(_act, _box(Vector3(0.3, 0.07, 0.3)), &"dark", Vector3(0, 0.915, 0))
	var roof := _cone(0.4, 0.06, 0.17)
	roof.radial_segments = 4                       # four sides, as a pagoda roof
	_part(_act, roof, &"dark", Vector3(0, 1.035, 0), Vector3(0, 45, 0))
	for i in 4:
		var corner := _joint(_act, Vector3(0, 0.97, 0), Vector3(0, 90.0 * i, 0))
		_part(corner, _cone(0.03, 0.0, 0.14), &"gold", Vector3(0.38, 0.03, 0), Vector3(0, 0, -50))
	_part(_act, _cone(0.035, 0.0, 0.14), &"gold", Vector3(0, 1.18, 0))
	_seal(_act, Vector3(0, 0.66, 0.135), 0, 0.2)
	_crack(_act, Vector3(-0.05, 0.36, 0.136), 0.14, 15)
	height = 1.26


## A lantern on a post: its paper glows between dark ribs, a tassel hangs from it.
func _build_lantern() -> void:
	_part(_act, _box(Vector3(0.22, 0.05, 0.22)), &"stone", Vector3(0, 0.025, 0))
	_part(_act, _box(Vector3(0.055, 0.26, 0.055)), &"wood", Vector3(0, 0.17, 0))
	var body := _joint(_act, Vector3(0, 0.3, 0))
	_part(body, _cone(0.1, 0.1, 0.04), &"metal", Vector3(0, 0.02, 0))
	_part(body, _ball(0.19), &"glow", Vector3(0, 0.22, 0), Vector3.ZERO, Vector3(1.0, 1.1, 1.0))
	for i in 4:
		_part(body, _torus(0.175, 0.2), &"dark", Vector3(0, 0.22, 0), Vector3(90, 45.0 * i, 0), Vector3(1.0, 0.25, 1.1))
	_part(body, _cone(0.1, 0.1, 0.04), &"metal", Vector3(0, 0.425, 0))
	_part(body, _cone(0.05, 0.0, 0.1), &"gold", Vector3(0, 0.49, 0))
	_part(body, _box(Vector3(0.025, 0.14, 0.025)), &"seal", Vector3(0.12, -0.03, 0))
	_sways.append([body, Vector3.FORWARD, 0.05, 1.4, 0.0])
	height = 0.86


## An old gnarled tree: a bent trunk, bare boughs and a few clusters of blossom.
func _build_tree() -> void:
	_part(_act, _cone(0.11, 0.07, 0.32), &"wood", Vector3(0, 0.16, 0))
	for i in 3:
		var root := _joint(_act, Vector3.ZERO, Vector3(0, 120.0 * i + 20.0, 0))
		_part(root, _cone(0.045, 0.0, 0.2), &"wood", Vector3(0.14, 0.03, 0), Vector3(0, 0, -98))
	var crown := _joint(_act, Vector3(0, 0.3, 0), Vector3(0, 0, -14))
	_part(crown, _cone(0.075, 0.045, 0.34), &"wood", Vector3(0, 0.16, 0))
	var boughs := [Vector3(48, 20, 0), Vector3(-40, 70, 30), Vector3(10, 0, 62), Vector3(-20, 150, -50)]
	for i in boughs.size():
		var bough := _joint(crown, Vector3(0, 0.26, 0), boughs[i])
		_part(bough, _cone(0.035, 0.012, 0.34), &"wood", Vector3(0, 0.17, 0))
		_part(bough, _ball(0.12 - 0.015 * i), &"main", Vector3(0, 0.36, 0))
		_part(bough, _ball(0.04), &"light", Vector3(0.05, 0.45, 0.04))
		_part(bough, _ball(0.035), &"light", Vector3(-0.07, 0.4, 0.07))
	_part(crown, _ball(0.13), &"main", Vector3(0, 0.42, 0))
	_sways.append([crown, Vector3.FORWARD, 0.04, 1.1, 0.0])
	_sways.append([crown, Vector3.RIGHT, 0.03, 0.8, 1.0])
	height = 0.98


## A guardian lion of stone on a banded plinth: a spiked mane, a heavy brow, bared fangs, one paw on a ball.
func _build_lion() -> void:
	_part(_act, _box(Vector3(0.52, 0.12, 0.52)), &"dark", Vector3(0, 0.06, 0))
	_part(_act, _box(Vector3(0.54, 0.04, 0.54)), &"metal", Vector3(0, 0.08, 0))
	_part(_act, _box(Vector3(0.28, 0.28, 0.32)), &"light", Vector3(0, 0.25, -0.04), Vector3(-14, 0, 0))
	for s: float in [-1.0, 1.0]:
		_part(_act, _box(Vector3(0.09, 0.26, 0.09)), &"light", Vector3(s * 0.09, 0.25, 0.14))
		_part(_act, _box(Vector3(0.11, 0.07, 0.14)), &"dark", Vector3(s * 0.09, 0.155, 0.17))
		for i in 3:
			_part(_act, _cone(0.012, 0.0, 0.05), &"paper", Vector3(s * 0.09 + 0.03 * (i - 1), 0.14, 0.26), Vector3(90, 0, 0))
	_part(_act, _ball(0.07), &"metal", Vector3(0.09, 0.2, 0.2))
	_part(_act, _box(Vector3(0.36, 0.32, 0.18)), &"dark", Vector3(0, 0.5, 0.0))
	for i in 5:
		var a := deg_to_rad(-80.0 + 40.0 * i)
		_part(_act, _cone(0.04, 0.0, 0.14), &"dark", Vector3(sin(a) * 0.19, 0.5 + cos(a) * 0.17, -0.02), Vector3(-20, 0, -rad_to_deg(a)))
	_part(_act, _box(Vector3(0.24, 0.22, 0.2)), &"light", Vector3(0, 0.5, 0.1))
	_part(_act, _box(Vector3(0.27, 0.05, 0.07)), &"dark", Vector3(0, 0.585, 0.19))
	_part(_act, _box(Vector3(0.15, 0.07, 0.08)), &"light", Vector3(0, 0.475, 0.22))
	_part(_act, _box(Vector3(0.13, 0.05, 0.07)), &"ink", Vector3(0, 0.425, 0.205))
	for s: float in [-1.0, 1.0]:
		_part(_act, _box(Vector3(0.05, 0.022, 0.02)), &"ink", Vector3(s * 0.065, 0.548, 0.203), Vector3(0, 0, s * 22))
		_part(_act, _cone(0.0, 0.014, 0.06), &"paper", Vector3(s * 0.045, 0.425, 0.245))
	height = 0.74


## A stake carved with a face whose eyes glow, set with thorns of bone and bound with a rope.
func _build_idol() -> void:
	_part(_act, _cone(0.15, 0.1, 0.58), &"wood", Vector3(0, 0.29, 0))
	_part(_act, _ball(0.135), &"dark", Vector3(0, 0.64, 0))
	_part(_act, _box(Vector3(0.2, 0.035, 0.06)), &"dark", Vector3(0, 0.7, 0.1))
	for s: float in [-1.0, 1.0]:
		_part(_act, _box(Vector3(0.05, 0.022, 0.02)), &"glow", Vector3(s * 0.05, 0.655, 0.128), Vector3(0, 0, s * 24))
	_part(_act, _box(Vector3(0.09, 0.02, 0.02)), &"ink", Vector3(0, 0.59, 0.118))
	_part(_act, _torus(0.1, 0.14), &"rope", Vector3(0, 0.5, 0))
	for ring in 2:
		for i in 5:
			var arm := _joint(_act, Vector3(0, 0.18 + 0.2 * ring, 0), Vector3(0, 72.0 * i + 36.0 * ring, 0))
			_part(arm, _cone(0.035, 0.0, 0.24), &"paper", Vector3(0.21 - 0.02 * ring, 0.035, 0), Vector3(0, 0, -72))
	_part(_act, _cone(0.04, 0.0, 0.2), &"paper", Vector3(0, 0.84, 0))
	height = 0.96


## A bell of bronze with studs and a golden lip, hanging in a frame.
func _build_bell() -> void:
	_frame(0.3, 0.88)
	var bell := _joint(_act, Vector3(0, 0.77, 0))
	_part(bell, _ball(0.04), &"metal", Vector3(0, -0.04, 0))
	_part(bell, _cone(0.2, 0.13, 0.3), &"main", Vector3(0, -0.24, 0))
	_part(bell, _ball(0.13), &"main", Vector3(0, -0.1, 0), Vector3.ZERO, Vector3(1.0, 0.7, 1.0))
	_part(bell, _torus(0.185, 0.22), &"gold", Vector3(0, -0.385, 0), Vector3.ZERO, Vector3(1.0, 0.6, 1.0))
	_part(bell, _torus(0.13, 0.155), &"dark", Vector3(0, -0.17, 0), Vector3.ZERO, Vector3(1.0, 0.6, 1.0))
	for i in 6:
		var a := TAU * i / 6.0
		_part(bell, _ball(0.022), &"gold", Vector3(sin(a) * 0.175, -0.27, cos(a) * 0.175))
	_part(bell, _ball(0.05), &"dark", Vector3(0, -0.43, 0))
	_sways.append([bell, Vector3.RIGHT, 0.09, 1.7, 0.0])
	height = 1.0


## A war banner: a torn flag with a sign of ink on a pole that ends in a spear head.
func _build_banner() -> void:
	_part(_act, _cone(0.11, 0.08, 0.07), &"stone", Vector3(0, 0.035, 0))
	_part(_act, _capsule(0.025, 1.0), &"wood", Vector3(0, 0.5, 0))
	_part(_act, _cone(0.045, 0.0, 0.16), &"metal", Vector3(0, 1.08, 0))
	_part(_act, _ball(0.035), &"gold", Vector3(0, 0.99, 0))
	var flag := _joint(_act, Vector3(0, 0.94, 0))
	_part(flag, _box(Vector3(0.3, 0.34, 0.02)), &"main", Vector3(0.17, -0.17, 0))
	_part(flag, _box(Vector3(0.3, 0.04, 0.026)), &"dark", Vector3(0.17, -0.02, 0))
	for i in 3:
		_part(flag, _prism(Vector3(0.1, 0.16 - 0.04 * (i % 2), 0.02)), &"main", Vector3(0.07 + 0.1 * i, -0.41 + 0.02 * (i % 2), 0), Vector3(0, 0, 180))
	for z: float in [-0.012, 0.012]:
		_part(flag, _box(Vector3(0.03, 0.2, 0.006)), &"ink", Vector3(0.17, -0.18, z))
		_part(flag, _box(Vector3(0.16, 0.03, 0.006)), &"ink", Vector3(0.17, -0.13, z))
	_sways.append([flag, Vector3.UP, 0.35, 2.2, 0.0])
	height = 1.16


## A flat stone with a ring and a mark cut into it that glow.
func _build_rune() -> void:
	_plate(&"stone")
	_part(_act, _torus(0.2, 0.26), &"glow", Vector3(0, 0.05, 0), Vector3.ZERO, Vector3(1.0, 0.3, 1.0))
	_part(_act, _ball(0.07), &"glow", Vector3(0, 0.05, 0), Vector3.ZERO, Vector3(1.0, 0.3, 1.0))
	for i in 4:
		var notch := _joint(_act, Vector3(0, 0.052, 0), Vector3(0, 90.0 * i + 45.0, 0))
		_part(notch, _box(Vector3(0.1, 0.012, 0.03)), &"ink", Vector3(0.33, 0, 0))
	height = 0.08


## A plate of dark iron with spikes.
func _build_spikes() -> void:
	_plate(&"dark")
	_part(_act, _torus(0.33, 0.37), &"metal", Vector3(0, 0.05, 0), Vector3.ZERO, Vector3(1.0, 0.4, 1.0))
	_part(_act, _cone(0.05, 0.0, 0.26), &"paper", Vector3(0, 0.17, 0))
	for i in 6:
		var arm := _joint(_act, Vector3.ZERO, Vector3(0, 60.0 * i, 0))
		_part(arm, _cone(0.04, 0.0, 0.2), &"paper", Vector3(0.22, 0.14, 0), Vector3(0, 0, -14))
	height = 0.3


## A plate with a studded dome of bronze; its seam and its cap glow.
func _build_mine() -> void:
	_plate(&"dark")
	_part(_act, _ball(0.2), &"metal", Vector3(0, 0.05, 0), Vector3.ZERO, Vector3(1.0, 0.62, 1.0))
	_part(_act, _torus(0.19, 0.225), &"glow", Vector3(0, 0.06, 0), Vector3.ZERO, Vector3(1.0, 0.5, 1.0))
	for i in 5:
		var a := TAU * i / 5.0
		_part(_act, _ball(0.024), &"gold", Vector3(sin(a) * 0.13, 0.135, cos(a) * 0.13))
	_part(_act, _ball(0.055), &"glow", Vector3(0, 0.175, 0))
	height = 0.2


## A plate with two rings that glow and turn.
func _build_vortex() -> void:
	_plate(&"dark")
	var outer := _joint(_act, Vector3(0, 0.06, 0))
	_part(outer, _torus(0.25, 0.3), &"glow", Vector3.ZERO, Vector3.ZERO, Vector3(1.0, 0.4, 1.0))
	_part(outer, _ball(0.05), &"gold", Vector3(0.275, 0.01, 0))
	var inner := _joint(_act, Vector3(0, 0.07, 0))
	_part(inner, _torus(0.1, 0.15), &"main", Vector3.ZERO, Vector3.ZERO, Vector3(1.0, 0.4, 1.0))
	_part(inner, _ball(0.04), &"glow", Vector3(0.125, 0.01, 0))
	_spins.append([outer, 1.6])
	_spins.append([inner, -2.6])
	height = 0.1
