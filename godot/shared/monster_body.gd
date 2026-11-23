class_name MonsterBody
extends InkFigure
## The body of a monster: a beast of a hard wuxia world, built from simple parts with an ink line. Dark tones of
## the colour of its aspect, horns, fangs and claws of bone, armour of bronze and gold, eyes and qi that glow
## (`_tones`). Two or three bodies per Kin (`BODIES`), and its movements (standing, walking, attacking, casting,
## being hit, pushed, healed and defeated). Look only: no rule reads it.
## Built from code, no model files (parts and ink line: `InkFigure`). The body stands on y = 0 and looks along +Z;
## `face` turns it.
##
## Nodes: this node (facing) → `_act` (one movement at a time, by tween) → `_core` (standing and walking, every
## frame) → parts and joints.

## The fall of a defeated body is over.
signal fell

const TURN_SPEED := 14.0

var kin: MonsterDef.Kin
## True while the body falls and after it: the view hides it when `fell` is emitted.
var down := false

var _act: Node3D
var _core: Node3D
var _rest := {}                # joint -> [position, rotation]
var _legs: Array = []          # [joint, phase, swing in radians]
var _wings: Array = []         # [joint, side (+1 right, -1 left)]
var _sways: Array = []         # [joint, axis, radians, speed, phase]
var _bobs: Array = []          # [joint, height, speed, phase]
var _orbits: Array = []        # [joint, radius, speed, phase, wave height]
var _spins: Array = []         # [joint, axis, speed]
var _strikers: Array = []      # [joint, rotation at the height of an attack]
var _pulses: Array = []        # [joint, amount, speed, phase]: qi that swells and sinks
var _hover := 0.0              # how far a floating body rises and sinks
var _breath := 0.02
var _hops := false             # a body without legs hops when it walks
var _wing_rest := 0.15
var _time := 0.0
var _walk := 0.0               # 0 standing … 1 walking
var _strike := 0.0             # 0 … 1 at the height of an attack
var _yaw_target := 0.0
var _act_tween: Tween
var _walk_tween: Tween


## The bodies of each Kin, by name (`MonsterDef.body`); the first of a Kin is what `auto` builds.
const BODIES := {
	MonsterDef.Kin.BEAST: ["tiger", "wolf", "bear"],
	MonsterDef.Kin.WINGED: ["hawk", "moth"],
	MonsterDef.Kin.SCALED: ["lizard", "turtle", "serpent"],
	MonsterDef.Kin.SWARM: ["wasps", "mites"],
	MonsterDef.Kin.SPIRIT: ["ghost", "wisp", "shade"],
	MonsterDef.Kin.STONE: ["golem", "colossus"],
	MonsterDef.Kin.FLORA: ["treant", "mushroom"],
	MonsterDef.Kin.VOID: ["eye", "stalker", "maw"],
}


## A body of `p_kin` in `color`. `body` names one of the bodies of the Kin (`BODIES`); any other name builds the
## first of the Kin.
static func create(p_kin: MonsterDef.Kin, color: Color, body: String = "auto") -> MonsterBody:
	var b := MonsterBody.new()
	b.kin = p_kin
	b._build(color, body if body in BODIES[p_kin] else String(BODIES[p_kin][0]))
	return b


func _build(color: Color, body: String) -> void:
	_time = float(hash(get_instance_id()) % 628) / 100.0       # bodies do not move in step
	_act = Node3D.new()
	add_child(_act)
	_core = Node3D.new()
	_act.add_child(_core)
	_tones(color)
	match body:
		"tiger", "wolf", "bear":
			_build_beast(body)
		"hawk":
			_build_winged()
		"moth":
			_build_moth()
		"lizard":
			_build_scaled()
		"turtle":
			_build_turtle()
		"serpent":
			_build_serpent()
		"wasps":
			_build_swarm()
		"mites":
			_build_mites()
		"ghost":
			_build_spirit()
		"wisp":
			_build_wisp()
		"shade":
			_build_shade()
		"golem":
			_build_stone()
		"colossus":
			_build_colossus()
		"treant":
			_build_flora()
		"mushroom":
			_build_mushroom()
		"eye":
			_build_void()
		"stalker":
			_build_stalker()
		"maw":
			_build_maw()
	for list in [_legs, _wings, _sways, _bobs, _orbits, _spins, _strikers, _pulses]:
		for entry in list:
			var j: Node3D = entry[0]
			if not _rest.has(j):
				_rest[j] = [j.position, j.rotation]
	_rest[_core] = [_core.position, _core.rotation]


# ---------- what the view asks for ----------

## Turn to a board direction (x, y of the board = x, z of the world). `at_once` skips the turn.
func face(dir: Vector2, at_once: bool = false) -> void:
	if dir.length_squared() < 0.001:
		return
	_yaw_target = atan2(dir.x, dir.y)
	if at_once:
		rotation.y = _yaw_target


## Walk on the spot for `seconds` (the view moves the body).
func walk(seconds: float) -> void:
	if down:
		return
	if _walk_tween != null:
		_walk_tween.kill()
	_walk_tween = create_tween()
	_walk_tween.tween_property(self, "_walk", 1.0, 0.06)
	_walk_tween.tween_interval(maxf(0.0, seconds - 0.14))
	_walk_tween.tween_property(self, "_walk", 0.0, 0.08)


## Draw back, lunge forward and return. The blow lands `strike_time()` after the start.
func attack() -> void:
	var tw := _begin()
	if tw == null:
		return
	tw.tween_property(_act, "position", Vector3(0, 0.02, -0.1), 0.09).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(_act, "rotation:x", -0.16, 0.09)
	tw.tween_property(_act, "position", Vector3(0, 0.04, 0.3), 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(_act, "rotation:x", 0.24, 0.08)
	tw.parallel().tween_property(self, "_strike", 1.0, 0.08)
	tw.tween_property(_act, "position", Vector3.ZERO, 0.24).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(_act, "rotation:x", 0.0, 0.24)
	tw.parallel().tween_property(self, "_strike", 0.0, 0.24)


## Seconds from the start of `attack` or `cast` to its height: what it causes is shown from then on.
static func strike_time() -> float:
	return 0.15


## A skill that is no blow: gather, rise and swell, settle.
func cast() -> void:
	var tw := _begin()
	if tw == null:
		return
	tw.tween_property(_act, "scale", Vector3(1.08, 0.86, 1.08), 0.1)
	tw.tween_property(_act, "scale", Vector3(0.94, 1.14, 0.94), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(_act, "position:y", 0.14, 0.1)
	tw.parallel().tween_property(self, "_strike", 0.6, 0.1)
	tw.tween_property(_act, "scale", Vector3.ONE, 0.22)
	tw.parallel().tween_property(_act, "position:y", 0.0, 0.22).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(self, "_strike", 0.0, 0.22)


## Flinch back and flash pale, after `delay` seconds. The flash also shows when another movement
## (a push) replaces the flinch.
func hit(delay: float = 0.0) -> void:
	var tw := _begin(delay)
	if tw == null:
		return
	flash(UiTheme.PAPER_LIGHT, delay)
	tw.tween_property(_act, "position", Vector3(0, 0, -0.12), 0.05)
	tw.parallel().tween_property(_act, "rotation:x", -0.3, 0.05)
	tw.parallel().tween_property(_act, "scale", Vector3(1.1, 0.88, 1.1), 0.05)
	tw.tween_property(_act, "rotation:z", 0.14, 0.05)
	tw.tween_property(_act, "rotation:z", -0.1, 0.06)
	tw.tween_property(_act, "position", Vector3.ZERO, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(_act, "rotation", Vector3.ZERO, 0.16)
	tw.parallel().tween_property(_act, "scale", Vector3.ONE, 0.16)


## Thrown along `board_dir` (the view moves the body): it leans away from the push and rocks back.
func pushed(board_dir: Vector2, seconds: float) -> void:
	var tw := _begin()
	if tw == null:
		return
	var world := Vector3(board_dir.x, 0.0, board_dir.y).normalized()
	var local := world.rotated(Vector3.UP, -rotation.y)
	# lean with the head against the direction of travel
	var lean := Vector3(-local.z, 0.0, local.x) * 0.42
	tw.tween_property(_act, "rotation", lean, 0.07)
	tw.parallel().tween_property(_act, "position:y", 0.1, 0.07)
	tw.tween_interval(maxf(0.0, seconds - 0.14))
	tw.tween_property(_act, "rotation", -lean * 0.35, 0.08)
	tw.parallel().tween_property(_act, "position:y", 0.0, 0.08)
	tw.tween_property(_act, "rotation", Vector3.ZERO, 0.12)


## A small jump and a flash in jade.
func healed(delay: float = 0.0) -> void:
	var tw := _begin(delay)
	if tw == null:
		return
	flash(UiTheme.JADE, delay)
	tw.tween_property(_act, "position:y", 0.16, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(_act, "scale", Vector3(0.95, 1.1, 0.95), 0.12)
	tw.tween_property(_act, "position:y", 0.0, 0.16).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(_act, "scale", Vector3.ONE, 0.16)


## Topple, lie, shrink away; then `fell`.
func defeated(delay: float = 0.0) -> void:
	if down:
		return
	var tw := _begin(delay)
	if tw == null:
		return
	down = true
	flash(UiTheme.CINNABAR, delay)
	tw.tween_property(_act, "rotation:z", 1.45, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(_act, "position:y", 0.12, 0.3)
	tw.parallel().tween_property(self, "_walk", 0.0, 0.1)
	tw.tween_interval(0.22)
	tw.tween_property(_act, "scale", Vector3.ONE * 0.02, 0.26).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_callback(fell.emit)


## Back on its feet (a body that fell and is used again).
func stand_up() -> void:
	down = false
	if _act_tween != null:
		_act_tween.kill()
	_settle()


func _begin(delay: float = 0.0) -> Tween:
	if down or not is_inside_tree():
		return null
	if _act_tween != null:
		_act_tween.kill()
	_settle()
	_act_tween = create_tween()
	if delay > 0.0:
		_act_tween.tween_interval(delay)
	return _act_tween


func _settle() -> void:
	_act.position = Vector3.ZERO
	_act.rotation = Vector3.ZERO
	_act.scale = Vector3.ONE
	_strike = 0.0


# ---------- every frame ----------

func _process(delta: float) -> void:
	_time += delta * (1.0 + 1.4 * _walk)
	rotation.y = lerp_angle(rotation.y, _yaw_target, 1.0 - exp(-TURN_SPEED * delta))
	_show_flash()
	if down:
		return
	for j in _rest:
		(j as Node3D).position = _rest[j][0]
		(j as Node3D).rotation = _rest[j][1]
	# standing: a floating body rises and sinks, a standing one breathes; walking: it leans and bounces
	_core.position.y += _hover * sin(_time * 2.0)
	_core.scale = Vector3(1.0 - 0.5 * _breath * sin(_time * 2.2), 1.0 + _breath * sin(_time * 2.2), 1.0)
	_core.rotation.x += 0.12 * _walk
	_core.position.y += (0.09 if _hops else 0.03) * absf(sin(_time * 9.0)) * _walk
	for e in _legs:
		(e[0] as Node3D).rotation.x += float(e[2]) * sin(_time * 9.0 + float(e[1])) * _walk
	for e in _wings:
		var beat := lerpf(5.0, 13.0, _walk)
		var reach := lerpf(0.3, 0.6, maxf(_walk, _strike))
		(e[0] as Node3D).rotation.z += float(e[1]) * (_wing_rest + reach * sin(_time * beat))
	for e in _sways:
		var a := float(e[2]) * sin(_time * float(e[3]) + float(e[4]))
		(e[0] as Node3D).rotation += (e[1] as Vector3) * a
	for e in _bobs:
		(e[0] as Node3D).position.y += float(e[1]) * sin(_time * float(e[2]) + float(e[3]))
	for e in _orbits:
		var ang := _time * float(e[2]) + float(e[3])
		var r := float(e[1]) * (1.0 - 0.55 * _strike)
		var j: Node3D = e[0]
		j.position += Vector3(sin(ang) * r, float(e[4]) * sin(ang * 1.7 + float(e[3])), cos(ang) * r)
		j.rotation.y += ang + PI * 0.5
	for e in _spins:
		(e[0] as Node3D).rotate_object_local(e[1], _time * float(e[2]))
	for e in _strikers:
		(e[0] as Node3D).rotation += (e[1] as Vector3) * _strike
	for e in _pulses:
		var swell := 1.0 + float(e[1]) * sin(_time * float(e[2]) + float(e[3])) + 0.3 * _strike
		(e[0] as Node3D).scale = Vector3(1.0 + 0.3 * (swell - 1.0), swell, 1.0 + 0.3 * (swell - 1.0))


# ---------- tones ----------

## The tones of a body in the colour of its aspect: a deep main tone, a near-black one, a bright one, bone for
## horns, fangs and claws, bronze and gold for armour, and two that glow (qi and eyes).
func _tones(color: Color) -> void:
	var deep := Color.from_hsv(color.h, minf(1.0, color.s * 1.2), color.v * 0.54)
	_material(&"main", deep)
	_material(&"dark", UiTheme.INK.lerp(deep, 0.26))
	_material(&"light", Color.from_hsv(color.h, minf(1.0, color.s * 1.1), color.v * 0.95))
	_material(&"bone", UiTheme.PAPER_SHADE.lerp(UiTheme.OCHRE, 0.16).darkened(0.06))
	_material(&"metal", UiTheme.OCHRE.lerp(UiTheme.INK, 0.4))
	_material(&"gold", Color.from_hsv(UiTheme.OCHRE.h, 0.7, 0.95))
	_material(&"glow", Color.from_hsv(color.h, minf(1.0, color.s * 1.7), 1.0))
	_material(&"spark", Color.from_hsv(color.h, 0.22, 1.0))
	_material(&"eye", Color.from_hsv(color.h, minf(1.0, color.s * 1.7), 1.0))
	for key: StringName in [&"glow", &"spark", &"eye"]:
		(_mats[key] as StandardMaterial3D).shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for key: StringName in [&"metal", &"gold"]:
		var m: StandardMaterial3D = _mats[key]
		m.specular_mode = BaseMaterial3D.SPECULAR_TOON
		m.roughness = 0.35
	var ink := StandardMaterial3D.new()
	ink.albedo_color = UiTheme.INK
	ink.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_mats[&"ink"] = ink


# ---------- parts ----------

## Two slanted eyes that glow in sockets of ink; `on_bone`: in the colour of the qi (a skull, a mask).
func _eyes(parent: Node3D, half: float, y: float, z: float, r: float = 0.024, on_bone: bool = false) -> void:
	for s: float in [-1.0, 1.0]:
		var slant := Vector3(0, 0, s * 28.0)
		_part(parent, _ball(r * 1.55), &"ink", Vector3(s * half, y, z), slant, Vector3(1.75, 0.9, 0.6))
		_part(parent, _ball(r), &"eye" if on_bone else &"spark", Vector3(s * half, y - r * 0.1, z + r * 0.75), slant, Vector3(1.6, 0.62, 0.6))


## A horn that grows along the Y of its joint and bends by `bend` degrees toward its Z.
func _horn(parent: Node3D, pos: Vector3, rot_deg: Vector3, length: float, r: float, key: StringName = &"bone",
		bend: float = 35.0) -> Node3D:
	var j := _joint(parent, pos, rot_deg)
	_part(j, _cone(r, r * 0.62, length * 0.55), key, Vector3(0, length * 0.27, 0))
	var k := _joint(j, Vector3(0, length * 0.5, 0), Vector3(bend, 0, 0))
	_part(k, _cone(r * 0.64, 0.0, length * 0.6), key, Vector3(0, length * 0.28, 0))
	return j


## `n` claws that point forward from `pos`.
func _claws(parent: Node3D, pos: Vector3, n: int = 3, size: float = 0.06, spread: float = 0.035) -> void:
	for i in n:
		var x := (i - (n - 1) * 0.5) * spread
		_part(parent, _cone(size * 0.32, 0.0, size), &"bone", pos + Vector3(x, 0, size * 0.4), Vector3(90, x * 300.0, 0))


## A spike that stands on `pos` and leans by `lean` degrees toward the board direction `turn` (degrees around Y).
func _spike(parent: Node3D, pos: Vector3, r: float, h: float, key: StringName = &"bone", lean: float = 0.0,
		turn: float = 0.0) -> void:
	var j := _joint(parent, pos, Vector3(lean, turn, 0))
	_part(j, _cone(r, 0.0, h), key, Vector3(0, h * 0.45, 0))


## A flame of qi that grows along the Y of its joint: it flickers, and swells with an attack.
func _flame(parent: Node3D, pos: Vector3, r: float, h: float, phase: float = 0.0,
		rot_deg: Vector3 = Vector3.ZERO, key: StringName = &"glow") -> Node3D:
	var j := _joint(parent, pos, rot_deg)
	_part(j, _cone(r, 0.0, h), key, Vector3(0, h * 0.5, 0))
	var tip := _joint(j, Vector3(0, h * 0.55, 0), Vector3(0, 0, 14))
	_part(tip, _cone(r * 0.5, 0.0, h * 0.6), key, Vector3(0, h * 0.3, 0))
	_sways.append([j, Vector3.FORWARD, 0.16, 3.1, phase])
	_sways.append([tip, Vector3.FORWARD, 0.35, 4.3, phase + 1.0])
	_pulses.append([j, 0.14, 5.3, phase])
	return j


## A flat part that lies in the board plane and points from `root` in the direction `yaw` (degrees; 0 is
## backward, positive turns it to the left side of the body): a feather, a wing blade.
func _blade(parent: Node3D, root: Vector3, yaw: float, width: float, length: float, key: StringName,
		tip: float = 0.5, thick: float = 0.025) -> void:
	var a := deg_to_rad(yaw)
	var dir := Vector3(-sin(a), 0, -cos(a))
	_part(parent, _prism(Vector3(width, length, thick), tip), key, root + dir * length * 0.5, Vector3(-90, yaw, 0))


static func _ring(inner: float, outer: float) -> TorusMesh:
	var t := TorusMesh.new()
	t.inner_radius = inner
	t.outer_radius = outer
	t.rings = 28
	t.ring_segments = 8
	return t


# ---------- the bodies of the eight Kins ----------

## Four clawed legs, a deep chest, a head held low with a jaw that opens. tiger: stripes, sabre fangs, plated
## shoulders, a mane and a tail tip of qi fire · wolf: a long snout, a mane of blades, bone spurs, a brush ·
## bear: heavy, a bronze skull plate with horns, plated shoulders, bone spikes along the back.
func _build_beast(body: String) -> void:
	var bear := body == "bear"
	var wolf := body == "wolf"
	var tiger := body == "tiger"
	var girth := 0.2 if bear else 0.16
	_core.position.y = 0.43
	_breath = 0.025
	_part(_core, _capsule(girth * 0.85, 0.5), &"main", Vector3(0, -0.01, -0.1), Vector3(90, 0, 0))
	_part(_core, _ball(girth + 0.05), &"main", Vector3(0, 0.03, 0.14), Vector3.ZERO, Vector3(1.0, 1.05, 1.2))
	_part(_core, _ball(girth + 0.01), &"dark", Vector3(0, -0.05, 0.12), Vector3.ZERO, Vector3(0.9, 0.85, 1.25))
	if tiger:
		for z: float in [-0.26, -0.15, -0.04]:
			_part(_core, _ball(girth * 0.85 + 0.012), &"dark", Vector3(0, -0.01, z), Vector3.ZERO, Vector3(1.0, 1.0, 0.13))
		for i in 3:
			_flame(_core, Vector3(0, 0.2 - 0.02 * i, 0.2 - 0.13 * i), 0.055, 0.2 - 0.03 * i, 1.3 * i, Vector3(-30, 0, 0))
	elif wolf:
		for i in 6:
			_part(_core, _prism(Vector3(0.13, 0.2 - 0.022 * i, 0.03), 1.0), &"dark",
					Vector3(0, 0.27 - 0.025 * i - (0.05 if i > 2 else 0.0), 0.24 - 0.1 * i), Vector3(0, 90, 0))
	else:
		_part(_core, _ball(girth), &"dark", Vector3(0, 0.14, 0.1), Vector3.ZERO, Vector3(0.9, 0.7, 1.1))
		for i in 4:
			_spike(_core, Vector3(0, 0.26 - 0.03 * i, 0.16 - 0.13 * i), 0.035, 0.15 - 0.015 * i, &"bone", -28)
	# the head
	var head := _joint(_core, Vector3(0, 0.12, 0.36), Vector3(14, 0, 0))
	var skull := 0.16 if bear else 0.135
	var snout := 0.2 if wolf else (0.15 if bear else 0.13)
	var wide := 0.1 if bear else 0.085
	_part(head, _ball(skull), &"main", Vector3(0, 0, 0.05), Vector3.ZERO, Vector3(1.05, 0.92, 1.1))
	_part(head, _cone(wide, wide * 0.65, snout), &"main", Vector3(0, -0.02, 0.13 + snout * 0.5), Vector3(90, 0, 0))
	_part(head, _ball(0.026), &"ink", Vector3(0, 0.015, 0.135 + snout))
	var jaw := _joint(head, Vector3(0, -0.07, 0.1), Vector3(12, 0, 0))
	_part(jaw, _cone(wide * 0.8, wide * 0.5, snout + 0.03), &"dark", Vector3(0, -0.01, snout * 0.5 + 0.02), Vector3(90, 0, 0), Vector3(1.0, 1.0, 0.45))
	var fang := 0.13 if tiger else 0.075
	for s: float in [-1.0, 1.0]:
		_part(head, _cone(0.0, 0.019, fang), &"bone", Vector3(s * wide * 0.5, -0.055 - fang * 0.5, 0.1 + snout))
		_part(jaw, _cone(0.014, 0.0, 0.05), &"bone", Vector3(s * wide * 0.4, 0.025, snout))
		if bear:
			_part(head, _ball(0.05), &"dark", Vector3(s * 0.13, 0.12, 0.0))
			_horn(head, Vector3(s * 0.1, 0.1, 0.04), Vector3(0, 0, -s * 42), 0.2, 0.036)
		elif wolf:
			_part(head, _prism(Vector3(0.08, 0.19, 0.04), 0.5 - s * 0.3), &"dark", Vector3(s * 0.085, 0.16, -0.01), Vector3(-20, 0, -s * 14))
		else:
			_part(head, _prism(Vector3(0.09, 0.11, 0.04)), &"dark", Vector3(s * 0.095, 0.13, 0.0), Vector3(0, 0, -s * 20))
			_part(head, _prism(Vector3(0.09, 0.12, 0.03)), &"light", Vector3(s * 0.15, -0.03, 0.04), Vector3(0, 0, -s * 112))
	if bear:
		_part(head, _ball(0.11), &"metal", Vector3(0, 0.085, 0.08), Vector3.ZERO, Vector3(1.05, 0.5, 1.0))
		_part(head, _ball(0.03), &"gold", Vector3(0, 0.135, 0.1))
	_eyes(head, 0.062, 0.05, 0.198 if bear else 0.165, 0.022)
	# the legs
	var thick := 0.075 if bear else 0.058
	var phase := 0.0
	for z: float in [0.2, -0.24]:
		for s: float in [-1.0, 1.0]:
			var leg := _joint(_core, Vector3(s * (girth - 0.02), -0.04, z))
			_part(leg, _capsule(thick, 0.24), &"main", Vector3(0, -0.08, 0))
			_part(leg, _capsule(thick * 0.72, 0.22), &"dark", Vector3(0, -0.25, 0.01))
			_part(leg, _ball(thick), &"dark", Vector3(0, -0.36, 0.03), Vector3.ZERO, Vector3(1.0, 0.6, 1.35))
			_claws(leg, Vector3(0, -0.375, 0.09), 3, 0.085 if bear else 0.065, thick * 0.55)
			_legs.append([leg, phase, 0.45 if bear else 0.6])
			phase += PI
			if z > 0.0:
				if wolf:
					_spike(_core, Vector3(s * (girth + 0.02), 0.1, 0.2), 0.03, 0.16, &"bone", 0, 0)
				else:
					_part(_core, _ball(0.09), &"metal", Vector3(s * (girth + 0.04), 0.08, 0.2), Vector3(0, 0, -s * 20), Vector3(0.55, 1.0, 1.1))
					_part(_core, _ball(0.03), &"gold", Vector3(s * (girth + 0.085), 0.08, 0.2))
		phase += PI
	# the tail
	var tail: Node3D
	if bear:
		tail = _joint(_core, Vector3(0, 0.06, -0.34), Vector3(-38, 0, 0))
		_part(tail, _ball(0.065), &"dark", Vector3(0, -0.02, -0.02))
	elif wolf:
		tail = _joint(_core, Vector3(0, 0.05, -0.34), Vector3(-22, 0, 0))
		_part(tail, _capsule(0.07, 0.36), &"main", Vector3(0, 0, -0.16), Vector3(90, 0, 0))
		_part(tail, _cone(0.075, 0.0, 0.2), &"dark", Vector3(0, 0, -0.38), Vector3(-90, 0, 0))
	else:
		tail = _joint(_core, Vector3(0, 0.05, -0.34), Vector3(28, 0, 0))
		_part(tail, _capsule(0.04, 0.34), &"main", Vector3(0, 0, -0.17), Vector3(90, 0, 0))
		_part(tail, _ball(0.046), &"dark", Vector3(0, 0, -0.14), Vector3.ZERO, Vector3(1.0, 1.0, 0.3))
		var end := _joint(tail, Vector3(0, 0, -0.33), Vector3(34, 0, 0))
		_part(end, _capsule(0.035, 0.24), &"main", Vector3(0, 0, -0.1), Vector3(90, 0, 0))
		_part(end, _ball(0.042), &"dark", Vector3(0, 0, -0.1), Vector3.ZERO, Vector3(1.0, 1.0, 0.3))
		_flame(end, Vector3(0, 0, -0.2), 0.06, 0.2, 0.5, Vector3(-50, 0, 0))
		_sways.append([end, Vector3.UP, 0.3, 2.6, 1.0])
	_sways.append([tail, Vector3.UP, 0.35, 2.6, 0.0])
	_sways.append([head, Vector3.FORWARD, 0.06, 1.3, 1.0])
	_strikers.append([head, Vector3(0.3, 0, 0)])
	_strikers.append([jaw, Vector3(0.6, 0, 0)])
	_strikers.append([tail, Vector3(-0.5, 0, 0)])


## A bird of prey that never lands: feathered wings with a bronze edge, a breastplate, a hooked golden beak,
## a crest, talons and long tail feathers with a trail of qi.
func _build_winged() -> void:
	_core.position.y = 0.56
	_hover = 0.05
	_breath = 0.0
	_part(_core, _ball(0.17), &"main", Vector3.ZERO, Vector3.ZERO, Vector3(1.0, 1.0, 1.4))
	_part(_core, _ball(0.14), &"metal", Vector3(0, -0.05, 0.09), Vector3.ZERO, Vector3(1.0, 0.95, 1.2))
	_part(_core, _ball(0.04), &"gold", Vector3(0, -0.06, 0.235))
	var head := _joint(_core, Vector3(0, 0.15, 0.22))
	_part(head, _ball(0.115), &"main")
	_part(head, _cone(0.052, 0.022, 0.13), &"gold", Vector3(0, -0.01, 0.15), Vector3(90, 0, 0))
	_part(head, _cone(0.0, 0.024, 0.08), &"gold", Vector3(0, -0.05, 0.21))
	for i in 3:
		_part(head, _prism(Vector3(0.2, 0.1 + 0.02 * i, 0.03), 1.0), &"dark" if i == 1 else &"light",
				Vector3(0.05 * (i - 1), 0.11 - 0.02 * absf(i - 1.0), -0.08), Vector3(0, 90, -22.0 * (i - 1)))
	_eyes(head, 0.06, 0.03, 0.092, 0.022)
	for s: float in [-1.0, 1.0]:
		var wing := _joint(_core, Vector3(s * 0.14, 0.07, 0.0))
		_part(wing, _prism(Vector3(0.48, 0.34, 0.03), 0.0 if s > 0.0 else 1.0), &"dark", Vector3(s * 0.24, 0, -0.03), Vector3(-90, 0, 0))
		_part(wing, _prism(Vector3(0.3, 0.22, 0.035), 0.0 if s > 0.0 else 1.0), &"main", Vector3(s * 0.15, 0.014, 0.03), Vector3(-90, 0, 0))
		_part(wing, _capsule(0.024, 0.5), &"metal", Vector3(s * 0.24, 0.012, 0.14), Vector3(0, 0, 90))
		_part(wing, _ball(0.036), &"gold", Vector3(s * 0.01, 0.02, 0.14))
		for i in 4:
			_blade(wing, Vector3(s * (0.38 - 0.085 * i), -0.006, 0.11), -s * (42.0 - 12.0 * i), 0.1, 0.27 - 0.01 * i,
					&"light" if i == 0 else &"dark")
		_wings.append([wing, s])
		_part(_core, _capsule(0.024, 0.15), &"dark", Vector3(s * 0.07, -0.2, 0.02))
		for i in 3:
			_part(_core, _cone(0.0, 0.016, 0.09), &"bone", Vector3(s * 0.07 + 0.028 * (i - 1), -0.3, 0.05), Vector3(-25, 0, 0))
	var tail := _joint(_core, Vector3(0, 0.0, -0.2))
	for i in 3:
		_blade(tail, Vector3.ZERO, 24.0 * (i - 1), 0.1, 0.44 if i == 1 else 0.36, &"main" if i == 1 else &"dark")
	_flame(tail, Vector3(0, 0.01, -0.36), 0.05, 0.24, 0.0, Vector3(-82, 0, 0))
	_sways.append([tail, Vector3.RIGHT, 0.2, 2.5, 0.0])
	_sways.append([head, Vector3.UP, 0.18, 1.1, 0.5])
	_strikers.append([head, Vector3(0.5, 0, 0)])


## A drake, low and long: a horned head with a toothed jaw, splayed clawed legs, bone spikes along the back and
## a tail that ends in a blade.
func _build_scaled() -> void:
	_core.position.y = 0.25
	_part(_core, _ball(0.2), &"main", Vector3.ZERO, Vector3.ZERO, Vector3(1.1, 0.75, 1.8))
	_part(_core, _ball(0.17), &"light", Vector3(0, -0.04, 0.03), Vector3.ZERO, Vector3(1.05, 0.6, 1.7))
	_part(_core, _ball(0.16), &"dark", Vector3(0, 0.05, -0.02), Vector3.ZERO, Vector3(0.95, 0.7, 1.9))
	for i in 5:
		_spike(_core, Vector3(0, 0.13 - 0.012 * absf(i - 1.5), 0.24 - 0.12 * i), 0.04, 0.2 - 0.025 * absf(i - 1.0), &"bone", -30)
	var head := _joint(_core, Vector3(0, 0.07, 0.36), Vector3(8, 0, 0))
	_part(head, _ball(0.12), &"main", Vector3(0, 0, 0.06), Vector3.ZERO, Vector3(1.0, 0.8, 1.2))
	_part(head, _cone(0.085, 0.05, 0.2), &"main", Vector3(0, -0.015, 0.22), Vector3(90, 0, 0))
	_part(head, _cone(0.03, 0.0, 0.09), &"bone", Vector3(0, 0.045, 0.29), Vector3(-20, 0, 0))
	var jaw := _joint(head, Vector3(0, -0.06, 0.08), Vector3(12, 0, 0))
	_part(jaw, _cone(0.07, 0.04, 0.26), &"dark", Vector3(0, -0.01, 0.13), Vector3(90, 0, 0), Vector3(1.0, 1.0, 0.45))
	for s: float in [-1.0, 1.0]:
		for i in 3:
			_part(head, _cone(0.0, 0.014, 0.055), &"bone", Vector3(s * (0.055 - 0.008 * i), -0.085, 0.17 + 0.055 * i))
		_part(jaw, _cone(0.014, 0.0, 0.055), &"bone", Vector3(s * 0.04, 0.03, 0.23))
		_horn(head, Vector3(s * 0.075, 0.07, 0.0), Vector3(-62, 0, -s * 26), 0.28, 0.036, &"bone", -24)
		_part(head, _prism(Vector3(0.1, 0.12, 0.025)), &"dark", Vector3(s * 0.13, 0.0, 0.0), Vector3(0, s * 30, -s * 100))
	_eyes(head, 0.068, 0.052, 0.13, 0.02)
	var phase := 0.0
	for z: float in [0.19, -0.19]:
		for s: float in [-1.0, 1.0]:
			var leg := _joint(_core, Vector3(s * 0.19, -0.01, z))
			_part(leg, _capsule(0.055, 0.2), &"main", Vector3(s * 0.06, -0.01, 0), Vector3(0, 0, s * 62))
			_part(leg, _capsule(0.042, 0.2), &"dark", Vector3(s * 0.13, -0.12, 0.02))
			_part(leg, _ball(0.055), &"dark", Vector3(s * 0.13, -0.21, 0.05), Vector3.ZERO, Vector3(1.0, 0.5, 1.3))
			_claws(leg, Vector3(s * 0.13, -0.215, 0.1), 3, 0.07, 0.035)
			_legs.append([leg, phase, 0.5])
			phase += PI
		phase += PI
	var tail := _joint(_core, Vector3(0, 0.0, -0.33))
	_part(tail, _cone(0.11, 0.06, 0.3), &"main", Vector3(0, 0, -0.14), Vector3(-90, 0, 0))
	_spike(tail, Vector3(0, 0.07, -0.1), 0.03, 0.12, &"bone", -30)
	var end := _joint(tail, Vector3(0, 0, -0.28), Vector3(0, 18, 0))
	_part(end, _cone(0.06, 0.025, 0.26), &"main", Vector3(0, 0, -0.13), Vector3(-90, 0, 0))
	_spike(end, Vector3(0, 0.04, -0.06), 0.022, 0.1, &"bone", -30)
	_part(end, _cone(0.045, 0.0, 0.2), &"bone", Vector3(0, 0, -0.33), Vector3(-90, 0, 0))
	for s: float in [-1.0, 1.0]:
		_part(end, _cone(0.03, 0.0, 0.16), &"bone", Vector3(s * 0.06, 0.02, -0.24), Vector3(-90, s * 55, 0))
	_sways.append([tail, Vector3.UP, 0.4, 2.0, 0.0])
	_sways.append([end, Vector3.UP, 0.4, 2.0, -1.0])
	_sways.append([_core, Vector3.UP, 0.05, 2.0, PI])
	_sways.append([head, Vector3.UP, 0.12, 1.2, 0.0])
	_strikers.append([head, Vector3(-0.2, 0, 0)])
	_strikers.append([jaw, Vector3(0.6, 0, 0)])
	_strikers.append([tail, Vector3(0, 0.9, 0)])


## Five hornets that circle one another: a dark thorax, a banded abdomen with a long sting, bladed wings.
func _build_swarm() -> void:
	_core.position.y = 0.5
	_breath = 0.0
	_hops = true
	for i in 5:
		var one := _joint(_core, Vector3(0, 0.13 * ((i % 3) - 1), 0))
		_part(one, _ball(0.075), &"dark", Vector3.ZERO, Vector3.ZERO, Vector3(1.0, 1.0, 1.2))
		_part(one, _ball(0.055), &"main", Vector3(0, 0.005, 0.1))
		_part(one, _ball(0.072), &"main", Vector3(0, -0.02, -0.15), Vector3.ZERO, Vector3(1.0, 1.0, 1.5))
		for z: float in [-0.12, -0.19]:
			_part(one, _ball(0.07), &"glow", Vector3(0, -0.02, z), Vector3.ZERO, Vector3(1.0, 1.0, 0.16))
		_part(one, _cone(0.026, 0.0, 0.14), &"bone", Vector3(0, -0.03, -0.31), Vector3(-90, 0, 0))
		_eyes(one, 0.034, 0.025, 0.135, 0.016)
		for s: float in [-1.0, 1.0]:
			_part(one, _cone(0.014, 0.0, 0.06), &"bone", Vector3(s * 0.025, -0.025, 0.16), Vector3(90, -s * 20, 0))
			var wing := _joint(one, Vector3(s * 0.04, 0.07, -0.02))
			_blade(wing, Vector3.ZERO, -s * 62.0, 0.08, 0.2, &"light", 0.5, 0.012)
			_wings.append([wing, s])
		_orbits.append([one, 0.22 + 0.04 * (i % 2), 1.5, TAU * i / 5.0, 0.05])
	_wing_rest = 0.2


## A vengeful ghost: a torn robe that ends in a wisp, a horned bone mask with a talisman, clawed hands, a ring
## of prayer beads and a crown of qi fire.
func _build_spirit() -> void:
	_core.position.y = 0.6
	_hover = 0.06
	_breath = 0.03
	_hops = true
	_part(_core, _ball(0.2), &"main", Vector3(0, 0.08, 0))
	var tail := _joint(_core, Vector3(0, 0.02, 0))
	_part(tail, _cone(0.0, 0.185, 0.42), &"main", Vector3(0, -0.19, 0))
	for i in 5:
		var rag := _joint(tail, Vector3.ZERO, Vector3(0, 36.0 + 72.0 * i, 0))
		_part(rag, _cone(0.0, 0.06, 0.24), &"dark", Vector3(0.12, -0.2, 0), Vector3(0, 0, 14))
	var tip := _joint(tail, Vector3(0, -0.4, 0))
	_part(tip, _cone(0.0, 0.05, 0.16), &"dark", Vector3(0, -0.05, 0))
	_part(_core, _ball(0.135), &"bone", Vector3(0, 0.09, 0.13), Vector3.ZERO, Vector3(1.0, 1.15, 0.5))
	_eyes(_core, 0.058, 0.1, 0.195, 0.024, true)
	_part(_core, _box(Vector3(0.05, 0.17, 0.012)), &"gold", Vector3(0, 0.14, 0.208), Vector3(-10, 0, 0))
	_part(_core, _box(Vector3(0.02, 0.1, 0.016)), &"ink", Vector3(0, 0.14, 0.21), Vector3(-10, 0, 0))
	for s: float in [-1.0, 1.0]:
		_horn(_core, Vector3(s * 0.1, 0.2, 0.08), Vector3(0, 0, -s * 30), 0.24, 0.034, &"dark", 25)
		var hand := _joint(_core, Vector3(s * 0.3, -0.02, 0.1))
		_part(hand, _ball(0.055), &"dark")
		_claws(hand, Vector3(0, -0.01, 0.04), 3, 0.09, 0.035)
		_bobs.append([hand, 0.04, 2.4, 1.5 if s > 0.0 else 0.0])
		_strikers.append([hand, Vector3(-0.9, 0, 0)])
	var beads := _joint(_core, Vector3(0, -0.07, 0), Vector3(12, 0, 0))
	var turn := _joint(beads, Vector3.ZERO)
	for i in 10:
		var a := TAU * i / 10.0
		_part(turn, _ball(0.036 if i % 5 == 0 else 0.026), &"gold" if i % 5 == 0 else &"dark", Vector3(sin(a) * 0.23, 0, cos(a) * 0.23))
	_spins.append([turn, Vector3.UP, 0.8])
	for i in 3:
		_flame(_core, Vector3(0.07 * (i - 1), 0.25 - 0.03 * absf(i - 1.0), -0.02), 0.06, 0.24 if i == 1 else 0.16, 1.7 * i, Vector3(0, 0, -16.0 * (i - 1)))
	_sways.append([tail, Vector3.FORWARD, 0.16, 1.7, 0.0])
	_sways.append([tail, Vector3.RIGHT, 0.12, 1.3, 1.0])
	_sways.append([tip, Vector3.FORWARD, 0.4, 1.7, -1.0])
	_strikers.append([tail, Vector3(-0.6, 0, 0)])


## A guardian of stone bound in bronze: wide spiked shoulders, a small head sunk between them, a glowing seal
## in its chest and fists as large as its head.
func _build_stone() -> void:
	_core.position.y = 0.5
	_breath = 0.012
	_part(_core, _box(Vector3(0.5, 0.4, 0.36)), &"main")
	_part(_core, _box(Vector3(0.15, 0.15, 0.03)), &"glow", Vector3(0, 0.02, 0.185), Vector3(0, 0, 45))
	_part(_core, _box(Vector3(0.07, 0.07, 0.04)), &"ink", Vector3(0, 0.02, 0.19), Vector3(0, 0, 45))
	_part(_core, _box(Vector3(0.36, 0.14, 0.3)), &"dark", Vector3(0, -0.26, 0))
	_part(_core, _box(Vector3(0.53, 0.06, 0.39)), &"metal", Vector3(0, -0.17, 0))
	_part(_core, _ball(0.04), &"gold", Vector3(0, -0.17, 0.2))
	var head := _joint(_core, Vector3(0, 0.2, 0.07))
	_part(head, _box(Vector3(0.2, 0.17, 0.2)), &"main", Vector3(0, 0.07, 0))
	_part(head, _box(Vector3(0.24, 0.05, 0.09)), &"dark", Vector3(0, 0.125, 0.085))
	_part(head, _box(Vector3(0.14, 0.05, 0.06)), &"dark", Vector3(0, 0.0, 0.09))
	_eyes(head, 0.05, 0.075, 0.103, 0.022)
	for s: float in [-1.0, 1.0]:
		_part(head, _prism(Vector3(0.07, 0.16, 0.07), 0.5 + s * 0.4), &"dark", Vector3(s * 0.085, 0.22, -0.02))
		_part(_core, _box(Vector3(0.24, 0.2, 0.3)), &"dark", Vector3(s * 0.35, 0.22, 0), Vector3(0, 0, -s * 12))
		_part(_core, _box(Vector3(0.27, 0.045, 0.33)), &"gold", Vector3(s * 0.33, 0.115, 0), Vector3(0, 0, -s * 12))
		_spike(_core, Vector3(s * 0.33, 0.31, 0.07), 0.05, 0.2, &"light", 0)
		_spike(_core, Vector3(s * 0.42, 0.28, -0.07), 0.045, 0.16, &"light", 0)
		var arm := _joint(_core, Vector3(s * 0.37, 0.14, 0))
		_part(arm, _box(Vector3(0.14, 0.3, 0.16)), &"main", Vector3(0, -0.14, 0))
		_part(arm, _box(Vector3(0.18, 0.05, 0.2)), &"metal", Vector3(0, -0.27, 0))
		_part(arm, _box(Vector3(0.24, 0.24, 0.26)), &"dark", Vector3(0, -0.43, 0.03))
		_part(arm, _box(Vector3(0.19, 0.035, 0.03)), &"glow", Vector3(0, -0.4, 0.16))
		_legs.append([arm, 0.0 if s > 0.0 else PI, 0.3])
		_strikers.append([arm, Vector3(-1.9, 0, 0)])
		var leg := _joint(_core, Vector3(s * 0.13, -0.33, 0))
		_part(leg, _box(Vector3(0.18, 0.17, 0.25)), &"dark", Vector3(0, -0.085, 0.01))
		_legs.append([leg, PI if s > 0.0 else 0.0, 0.5])
	_sways.append([head, Vector3.UP, 0.1, 0.9, 0.0])


## A dead tree that walks: a gnarled trunk on root claws, bound with a golden rope and paper seals, a crown
## of sharp boughs, antlers of dead wood and two clawed branches.
func _build_flora() -> void:
	_breath = 0.015
	_hops = true
	_part(_core, _cone(0.17, 0.11, 0.56), &"dark", Vector3(0, 0.28, 0))
	for i in 5:
		var root := _joint(_core, Vector3.ZERO, Vector3(0, 18.0 + 72.0 * i, 0))
		_part(root, _cone(0.065, 0.0, 0.3), &"dark", Vector3(0.24, 0.045, 0), Vector3(0, 0, -98))
	_part(_core, _ring(0.125, 0.175), &"gold", Vector3(0, 0.17, 0))
	for i in 3:
		_part(_core, _box(Vector3(0.045, 0.11, 0.012)), &"bone", Vector3(0.075 * (i - 1), 0.09, 0.16 - 0.02 * absf(i - 1.0)), Vector3(-8, 24.0 * (i - 1), 0))
	_eyes(_core, 0.055, 0.38, 0.115, 0.024)
	_part(_core, _box(Vector3(0.11, 0.028, 0.03)), &"ink", Vector3(0, 0.29, 0.125))
	for i in 4:
		_part(_core, _cone(0.0, 0.012, 0.04), &"bone", Vector3(0.028 * (i - 1.5), 0.285, 0.14))
	var crown := _joint(_core, Vector3(0, 0.54, 0))
	_part(crown, _cone(0.2, 0.0, 0.46), &"main", Vector3(0, 0.2, 0))
	for i in 5:
		var bough := _joint(crown, Vector3(0, 0.02, 0), Vector3(52, 72.0 * i, 0))
		_part(bough, _cone(0.12, 0.0, 0.38), &"main" if i % 2 == 0 else &"light", Vector3(0, 0.17, 0))
	for s: float in [-1.0, 1.0]:
		_horn(crown, Vector3(s * 0.06, 0.2, -0.04), Vector3(-10, 0, -s * 38), 0.36, 0.03, &"dark", 30)
		var arm := _joint(_core, Vector3(s * 0.13, 0.34, 0.02))
		_part(arm, _capsule(0.04, 0.32), &"dark", Vector3(s * 0.12, 0.07, 0), Vector3(0, 0, -s * 58))
		for i in 3:
			_part(arm, _cone(0.022, 0.0, 0.17), &"dark", Vector3(s * 0.29, 0.17 + 0.03 * (i - 1), 0.05 * (i - 1)), Vector3(40.0 * (i - 1), 0, -s * (70.0 - 25.0 * (i - 1))))
		_sways.append([arm, Vector3.FORWARD, 0.1, 1.6, 1.0 if s > 0.0 else 2.2])
		_strikers.append([arm, Vector3(0.3, -s * 1.3, 0)])
	for i in 3:
		var fly := _joint(_core, Vector3(0, 0.5 + 0.12 * i, 0))
		_part(fly, _ball(0.024), &"glow")
		_orbits.append([fly, 0.34, 1.1, TAU * i / 3.0, 0.06])
	_sways.append([crown, Vector3.FORWARD, 0.07, 1.2, 0.0])
	_sways.append([crown, Vector3.RIGHT, 0.05, 0.9, 1.0])
	_strikers.append([crown, Vector3(0.35, 0, 0)])


## An eye of the void: a dark core with a slit pupil in a ring of thorns, two crossed rings of bronze and gold,
## circling blades and hanging threads that end in claws.
func _build_void() -> void:
	_core.position.y = 0.6
	_hover = 0.05
	_breath = 0.035
	_hops = true
	_part(_core, _ball(0.2), &"dark")
	_part(_core, _ball(0.105), &"glow", Vector3(0, 0.01, 0.125), Vector3.ZERO, Vector3(1.0, 1.0, 0.75))
	_part(_core, _ball(0.05), &"ink", Vector3(0, 0.01, 0.195), Vector3.ZERO, Vector3(0.42, 1.5, 0.4))
	for i in 7:
		var a := TAU * i / 7.0
		_part(_core, _cone(0.03, 0.0, 0.15), &"dark", Vector3(sin(a) * 0.19, cos(a) * 0.19 + 0.01, 0.07), Vector3(25, 0, -rad_to_deg(a)))
	var tilt := _joint(_core, Vector3.ZERO, Vector3(24, 0, 14))
	var ring := _joint(tilt, Vector3.ZERO)
	_part(ring, _ring(0.27, 0.315), &"metal")
	for i in 4:
		var a := TAU * i / 4.0
		_part(ring, _ball(0.04), &"glow", Vector3(sin(a) * 0.292, 0, cos(a) * 0.292))
	_spins.append([ring, Vector3.UP, 1.4])
	var tilt_b := _joint(_core, Vector3.ZERO, Vector3(-34, 0, -52))
	var ring_b := _joint(tilt_b, Vector3.ZERO)
	_part(ring_b, _ring(0.345, 0.375), &"gold")
	_spins.append([ring_b, Vector3.UP, -0.9])
	for i in 4:
		var shard := _joint(_core, Vector3(0, 0.05 * (i % 2), 0))
		_part(shard, _prism(Vector3(0.07, 0.28, 0.04)), &"dark" if i % 2 == 0 else &"main", Vector3.ZERO, Vector3(0, 0, 20))
		_orbits.append([shard, 0.45, -0.9, TAU * i / 4.0, 0.07])
	for i in 4:
		var thread := _joint(_core, Vector3(0.07 * (i - 1.5), -0.15, -0.03 * (i % 2)))
		_part(thread, _cone(0.0, 0.04, 0.3), &"dark", Vector3(0, -0.15, 0))
		_part(thread, _cone(0.0, 0.018, 0.1), &"bone", Vector3(0, -0.33, 0))
		_sways.append([thread, Vector3.FORWARD, 0.25, 1.9, float(i)])
		_sways.append([thread, Vector3.RIGHT, 0.2, 1.4, float(i) * 2.0])
		_strikers.append([thread, Vector3(-1.1, 0, 0)])


## A night moth: a banded body with a pale ruff, long feelers, pointed fore wings with a glowing eye each and
## dark hind wings that end in streamers.
func _build_moth() -> void:
	_core.position.y = 0.54
	_hover = 0.05
	_breath = 0.0
	_wing_rest = 0.22
	_part(_core, _capsule(0.08, 0.4), &"dark", Vector3(0, 0, -0.08), Vector3(90, 0, 0))
	for z: float in [-0.1, -0.18]:
		_part(_core, _ball(0.086), &"glow", Vector3(0, 0, z), Vector3.ZERO, Vector3(1.0, 1.0, 0.14))
	_part(_core, _ball(0.12), &"bone", Vector3(0, 0.02, 0.08), Vector3.ZERO, Vector3(1.0, 0.9, 1.0))
	var head := _joint(_core, Vector3(0, 0.03, 0.2))
	_part(head, _ball(0.085), &"dark")
	_eyes(head, 0.048, 0.02, 0.066, 0.028)
	for s: float in [-1.0, 1.0]:
		var feeler := _horn(head, Vector3(s * 0.04, 0.06, 0.03), Vector3(35, s * 30, 0), 0.3, 0.016, &"bone", 45)
		_sways.append([feeler, Vector3.FORWARD, 0.15, 2.3, s])
		var wing := _joint(_core, Vector3(s * 0.08, 0.05, 0.0))
		_blade(wing, Vector3(0, 0, 0.1), -s * 68.0, 0.36, 0.56, &"main", 0.3 if s > 0.0 else 0.7)
		_blade(wing, Vector3(0, 0.014, 0.13), -s * 74.0, 0.12, 0.5, &"light", 0.3 if s > 0.0 else 0.7, 0.03)
		_part(wing, _ball(0.07), &"glow", Vector3(s * 0.25, 0.018, 0.0), Vector3.ZERO, Vector3(1.0, 0.12, 1.0))
		_part(wing, _ball(0.032), &"ink", Vector3(s * 0.25, 0.026, 0.0), Vector3.ZERO, Vector3(1.0, 0.2, 1.0))
		_part(wing, _ball(0.17), &"dark", Vector3(s * 0.16, -0.008, -0.17), Vector3(0, s * 20, 0), Vector3(1.0, 0.07, 1.1))
		_blade(wing, Vector3(s * 0.2, -0.008, -0.3), -s * 14.0, 0.07, 0.3, &"dark")
		_wings.append([wing, s])
	_sways.append([head, Vector3.UP, 0.15, 1.2, 0.0])
	_strikers.append([head, Vector3(0.4, 0, 0)])


## The black tortoise: a spiked shell with a bronze rim, a beaked head, four clawed legs, and a snake for a
## tail that rears over the shell.
func _build_turtle() -> void:
	_core.position.y = 0.24
	_breath = 0.012
	_part(_core, _ball(0.26), &"bone", Vector3(0, -0.03, 0), Vector3.ZERO, Vector3(1.0, 0.3, 1.12))
	_part(_core, _ball(0.3), &"metal", Vector3(0, 0.03, -0.01), Vector3.ZERO, Vector3(1.0, 0.3, 1.1))
	_part(_core, _ball(0.27), &"dark", Vector3(0, 0.07, -0.01), Vector3.ZERO, Vector3(1.0, 0.7, 1.08))
	_part(_core, _ball(0.15), &"main", Vector3(0, 0.2, -0.01), Vector3.ZERO, Vector3(1.0, 0.5, 1.1))
	_spike(_core, Vector3(0, 0.25, -0.01), 0.05, 0.2)
	for i in 6:
		var a := TAU * (i + 0.5) / 6.0
		_part(_core, _ball(0.085), &"main", Vector3(sin(a) * 0.185, 0.14, cos(a) * 0.2 - 0.01), Vector3.ZERO, Vector3(1.0, 0.5, 1.0))
		_spike(_core, Vector3(sin(a) * 0.19, 0.16, cos(a) * 0.205 - 0.01), 0.034, 0.15, &"bone", 38, rad_to_deg(a))
	for i in 8:
		var a := TAU * (i + 0.5) / 8.0
		_part(_core, _ball(0.026), &"gold", Vector3(sin(a) * 0.3, 0.035, cos(a) * 0.33 - 0.01))
	var head := _joint(_core, Vector3(0, 0.05, 0.28))
	_part(head, _capsule(0.065, 0.22), &"main", Vector3(0, 0, 0.04), Vector3(90, 0, 0))
	_part(head, _ball(0.1), &"main", Vector3(0, 0.03, 0.15), Vector3.ZERO, Vector3(1.0, 0.85, 1.2))
	_part(head, _cone(0.065, 0.0, 0.12), &"bone", Vector3(0, 0.015, 0.29), Vector3(98, 0, 0))
	_spike(head, Vector3(0, 0.1, 0.14), 0.028, 0.12, &"bone", -35)
	_eyes(head, 0.056, 0.07, 0.215, 0.02)
	var phase := 0.0
	for z: float in [0.18, -0.18]:
		for s: float in [-1.0, 1.0]:
			var leg := _joint(_core, Vector3(s * 0.22, -0.03, z))
			_part(leg, _capsule(0.07, 0.22), &"main", Vector3(s * 0.03, -0.09, 0), Vector3(0, 0, s * 20))
			_part(leg, _ball(0.07), &"dark", Vector3(s * 0.06, -0.19, 0.03), Vector3.ZERO, Vector3(1.0, 0.5, 1.2))
			_claws(leg, Vector3(s * 0.06, -0.195, 0.09), 3, 0.07, 0.04)
			_legs.append([leg, phase, 0.4])
			phase += PI
		phase += PI
	# the snake: it grows upward from the back of the shell and bends forward over it
	var snake := _joint(_core, Vector3(0, 0.08, -0.27), Vector3(-24, 0, 0))
	_part(snake, _capsule(0.05, 0.36), &"main", Vector3(0, 0.15, 0))
	var bend := _joint(snake, Vector3(0, 0.31, 0), Vector3(58, 0, 0))
	_part(bend, _capsule(0.044, 0.28), &"main", Vector3(0, 0.11, 0))
	var fang := _joint(bend, Vector3(0, 0.24, 0), Vector3(48, 0, 0))
	_part(fang, _ball(0.062), &"dark", Vector3(0, 0.03, 0), Vector3.ZERO, Vector3(1.1, 1.5, 0.75))
	for s: float in [-1.0, 1.0]:
		_part(fang, _ball(0.016), &"spark", Vector3(s * 0.04, 0.05, -0.035))
		_part(fang, _cone(0.0, 0.01, 0.05), &"bone", Vector3(s * 0.025, 0.1, 0.03), Vector3(90, 0, 0))
	_part(fang, _cone(0.012, 0.0, 0.09), &"glow", Vector3(0, 0.15, 0.01))
	_sways.append([snake, Vector3.FORWARD, 0.14, 1.6, 0.0])
	_sways.append([bend, Vector3.FORWARD, 0.2, 1.6, 1.0])
	_sways.append([fang, Vector3.FORWARD, 0.2, 2.3, 2.0])
	_sways.append([head, Vector3.UP, 0.16, 0.9, 0.0])
	_strikers.append([head, Vector3(-0.3, 0, 0)])
	_strikers.append([bend, Vector3(0.7, 0, 0)])


## A horned serpent: a spiked coil on the ground, a tall neck with fins, a wide hood with glowing marks and a
## jaw with long fangs.
func _build_serpent() -> void:
	_breath = 0.015
	_part(_core, _ring(0.13, 0.32), &"main", Vector3(0, 0.1, 0))
	_part(_core, _ring(0.07, 0.22), &"main", Vector3(0, 0.25, -0.01))
	for i in 7:
		var a := TAU * (i + 1.0) / 8.0 + PI * 0.125
		_spike(_core, Vector3(sin(a) * 0.27, 0.16, cos(a) * 0.27), 0.032, 0.14, &"bone", 42, rad_to_deg(a))
	var tail := _joint(_core, Vector3(0.2, 0.08, -0.22), Vector3(0, 35, 0))
	_part(tail, _cone(0.06, 0.0, 0.3), &"dark", Vector3(0, 0, -0.13), Vector3(-90, 0, 0))
	_part(tail, _cone(0.035, 0.0, 0.16), &"bone", Vector3(0, 0, -0.32), Vector3(-90, 0, 0))
	var neck := _joint(_core, Vector3(0, 0.28, 0.02), Vector3(10, 0, 0))
	_part(neck, _capsule(0.08, 0.5), &"main", Vector3(0, 0.2, 0))
	_part(neck, _capsule(0.055, 0.44), &"light", Vector3(0, 0.2, 0.042))
	for i in 3:
		_part(neck, _prism(Vector3(0.1, 0.12, 0.025), 0.2), &"dark", Vector3(0, 0.08 + 0.12 * i, -0.1), Vector3(-90, 90, 0))
	var head := _joint(neck, Vector3(0, 0.46, 0.0), Vector3(-2, 0, 0))
	_part(head, _ball(0.18), &"dark", Vector3(0, -0.06, -0.05), Vector3.ZERO, Vector3(1.5, 1.15, 0.28))
	for s: float in [-1.0, 1.0]:
		_part(head, _ball(0.04), &"glow", Vector3(s * 0.16, -0.06, -0.012), Vector3(0, 0, s * 20), Vector3(0.8, 1.7, 0.3))
		_part(head, _cone(0.0, 0.016, 0.11), &"bone", Vector3(s * 0.04, -0.06, 0.17))
		_horn(head, Vector3(s * 0.06, 0.08, 0.02), Vector3(-55, 0, -s * 22), 0.24, 0.03, &"bone", -26)
	_part(head, _ball(0.1), &"main", Vector3(0, 0.03, 0.07), Vector3.ZERO, Vector3(1.0, 0.75, 1.5))
	var jaw := _joint(head, Vector3(0, -0.025, 0.03), Vector3(20, 0, 0))
	_part(jaw, _box(Vector3(0.1, 0.03, 0.2)), &"dark", Vector3(0, -0.01, 0.09))
	_part(jaw, _box(Vector3(0.012, 0.008, 0.12)), &"glow", Vector3(0, 0.012, 0.2))
	_eyes(head, 0.06, 0.058, 0.176, 0.02)
	_sways.append([neck, Vector3.FORWARD, 0.14, 1.5, 0.0])
	_sways.append([neck, Vector3.UP, 0.2, 1.1, 1.0])
	_sways.append([tail, Vector3.UP, 0.5, 2.4, 0.0])
	_sways.append([_core, Vector3.UP, 0.06, 1.8, 0.0])
	_strikers.append([neck, Vector3(0.95, 0, 0)])
	_strikers.append([head, Vector3(-0.6, 0, 0)])
	_strikers.append([jaw, Vector3(0.5, 0, 0)])


## Six horned beetles that run in two rings on the ground: a dark spiked shell, a curved horn, pincers.
func _build_mites() -> void:
	_core.position.y = 0.09
	_breath = 0.0
	_hops = true
	for i in 6:
		var one := _joint(_core, Vector3.ZERO)
		_part(one, _ball(0.085), &"dark", Vector3.ZERO, Vector3.ZERO, Vector3(1.0, 0.8, 1.3))
		_part(one, _box(Vector3(0.012, 0.02, 0.17)), &"glow", Vector3(0, 0.062, -0.01))
		_part(one, _ball(0.05), &"main", Vector3(0, -0.005, 0.1))
		_eyes(one, 0.028, 0.012, 0.14, 0.012)
		_horn(one, Vector3(0, 0.02, 0.13), Vector3(62, 0, 0), 0.16, 0.022, &"bone", -55)
		for s: float in [-1.0, 1.0]:
			_part(one, _cone(0.012, 0.0, 0.06), &"bone", Vector3(s * 0.03, -0.03, 0.16), Vector3(90, -s * 28, 0))
			for z: float in [-0.04, 0.04]:
				_part(one, _capsule(0.012, 0.12), &"main", Vector3(s * 0.095, -0.035, z), Vector3(0, 0, s * 55))
		var inner := i % 2 == 0
		_orbits.append([one, 0.12 if inner else 0.3, 2.1 if inner else 1.3, TAU * i / 6.0, 0.0])


## A soul fire: a skull that burns in flames of qi, with embers around it.
func _build_wisp() -> void:
	_core.position.y = 0.5
	_hover = 0.07
	_breath = 0.04
	_hops = true
	_part(_core, _cone(0.2, 0.0, 0.46), &"main", Vector3(0, 0.2, -0.1))
	var back := _flame(_core, Vector3(0, 0.0, -0.05), 0.17, 0.46, 0.0)
	for s: float in [-1.0, 1.0]:
		_flame(_core, Vector3(s * 0.11, -0.04, -0.03), 0.1, 0.32, 1.0 + s, Vector3(0, 0, -s * 26))
	var tail := _joint(_core, Vector3(0, -0.1, -0.02))
	_part(tail, _cone(0.0, 0.11, 0.26), &"glow", Vector3(0, -0.12, 0))
	_part(_core, _ball(0.12), &"bone", Vector3(0, 0.02, 0.04), Vector3.ZERO, Vector3(1.0, 1.0, 1.05))
	var jaw := _joint(_core, Vector3(0, -0.06, 0.02), Vector3(8, 0, 0))
	_part(jaw, _box(Vector3(0.12, 0.06, 0.1)), &"bone", Vector3(0, -0.04, 0.05))
	for i in 4:
		_part(jaw, _box(Vector3(0.008, 0.05, 0.01)), &"ink", Vector3(0.028 * (i - 1.5), -0.035, 0.102))
	_eyes(_core, 0.05, 0.035, 0.15, 0.026, true)
	_part(_core, _prism(Vector3(0.03, 0.04, 0.02)), &"ink", Vector3(0, -0.015, 0.158))
	for i in 4:
		var ember := _joint(_core, Vector3(0, 0.0 + 0.09 * i, 0))
		_part(ember, _ball(0.034), &"glow")
		_orbits.append([ember, 0.32, 1.9, TAU * i / 4.0, 0.08])
	_sways.append([tail, Vector3.RIGHT, 0.3, 2.0, 0.0])
	_strikers.append([back, Vector3(0.25, 0, 0)])
	_strikers.append([jaw, Vector3(0.5, 0, 0)])


## A wraith: a hooded cloak with a torn hem, spiked bronze shoulders, horns through the hood, eyes in a face
## of ink, long clawed arms and paper seals that circle it.
func _build_shade() -> void:
	_core.position.y = 0.52
	_hover = 0.05
	_breath = 0.02
	_hops = true
	_part(_core, _cone(0.25, 0.1, 0.62), &"dark")
	_part(_core, _cone(0.2, 0.09, 0.5), &"main", Vector3(0, 0.02, 0.045))
	for i in 7:
		var rag := _joint(_core, Vector3.ZERO, Vector3(0, 360.0 * i / 7.0, 0))
		_part(rag, _cone(0.0, 0.075, 0.24), &"dark", Vector3(0.17, -0.38, 0))
	_part(_core, _ball(0.04), &"gold", Vector3(0, 0.2, 0.13))
	var head := _joint(_core, Vector3(0, 0.33, 0.02))
	_part(head, _ball(0.16), &"dark", Vector3(0, 0.04, -0.01))
	_part(head, _cone(0.09, 0.0, 0.18), &"dark", Vector3(0, 0.2, -0.06), Vector3(-30, 0, 0))
	_part(head, _ball(0.115), &"ink", Vector3(0, 0.02, 0.075), Vector3.ZERO, Vector3(1.0, 1.15, 0.6))
	for s: float in [-1.0, 1.0]:
		_part(head, _ball(0.026), &"spark", Vector3(s * 0.045, 0.04, 0.14), Vector3(0, 0, s * 26), Vector3(1.6, 0.7, 0.6))
		_horn(head, Vector3(s * 0.11, 0.13, -0.02), Vector3(0, 0, -s * 34), 0.26, 0.032, &"bone", 32)
		_part(_core, _ball(0.11), &"metal", Vector3(s * 0.18, 0.24, 0), Vector3(0, 0, -s * 18), Vector3(1.15, 0.7, 1.05))
		_part(_core, _ball(0.03), &"gold", Vector3(s * 0.2, 0.2, 0.1))
		_spike(_core, Vector3(s * 0.22, 0.29, 0), 0.034, 0.2, &"bone", 0)
		var arm := _joint(_core, Vector3(s * 0.2, 0.2, 0.03), Vector3(-32, 0, 0))
		_part(arm, _capsule(0.032, 0.38), &"main", Vector3(0, -0.17, 0))
		_part(arm, _ball(0.05), &"dark", Vector3(0, -0.37, 0))
		for i in 3:
			_part(arm, _cone(0.0, 0.015, 0.15), &"bone", Vector3(0.03 * (i - 1), -0.46, 0.01), Vector3(0, 0, 12.0 * (i - 1)))
		_sways.append([arm, Vector3.RIGHT, 0.14, 1.4, 1.2 if s > 0.0 else 0.0])
		_strikers.append([arm, Vector3(-1.3, 0, 0)])
	for i in 3:
		var seal := _joint(_core, Vector3(0, 0.05 + 0.1 * i, 0))
		_part(seal, _box(Vector3(0.012, 0.15, 0.055)), &"gold")
		_part(seal, _box(Vector3(0.016, 0.08, 0.02)), &"ink")
		_orbits.append([seal, 0.4, 1.0, TAU * i / 3.0, 0.05])
	_sways.append([head, Vector3.FORWARD, 0.08, 1.1, 0.0])
	_sways.append([_core, Vector3.FORWARD, 0.05, 0.9, 0.5])


## A colossus of bone: a horned skull with a jaw, a cage of ribs around a burning heart, spiked shoulders,
## long arms that end in claws and a torn war skirt.
func _build_colossus() -> void:
	_core.position.y = 0.56
	_breath = 0.01
	_part(_core, _box(Vector3(0.09, 0.5, 0.09)), &"dark", Vector3(0, -0.02, -0.05))
	var heart := _joint(_core, Vector3(0, 0.07, 0.0))
	_part(heart, _ball(0.085), &"glow")
	_pulses.append([heart, 0.18, 3.0, 0.0])
	for i in 3:
		_part(_core, _box(Vector3(0.42 - 0.05 * i, 0.05, 0.28 - 0.03 * i)), &"bone", Vector3(0, 0.17 - 0.1 * i, 0))
	_part(_core, _box(Vector3(0.3, 0.1, 0.2)), &"dark", Vector3(0, -0.27, 0))
	_part(_core, _prism(Vector3(0.22, 0.26, 0.02)), &"main", Vector3(0, -0.42, 0.11), Vector3(0, 0, 180))
	_part(_core, _box(Vector3(0.32, 0.04, 0.22)), &"gold", Vector3(0, -0.23, 0))
	var head := _joint(_core, Vector3(0, 0.27, 0.04))
	_part(head, _box(Vector3(0.24, 0.2, 0.24)), &"bone", Vector3(0, 0.12, 0))
	var jaw := _joint(head, Vector3(0, 0.03, -0.02), Vector3(8, 0, 0))
	_part(jaw, _box(Vector3(0.18, 0.06, 0.2)), &"bone", Vector3(0, -0.02, 0.06))
	for i in 5:
		_part(jaw, _box(Vector3(0.008, 0.05, 0.01)), &"ink", Vector3(0.03 * (i - 2), -0.015, 0.162))
	_eyes(head, 0.058, 0.13, 0.118, 0.034, true)
	_part(head, _prism(Vector3(0.04, 0.05, 0.02)), &"ink", Vector3(0, 0.06, 0.122))
	_spike(head, Vector3(0, 0.21, 0.02), 0.035, 0.16, &"dark", -10)
	for s: float in [-1.0, 1.0]:
		_horn(head, Vector3(s * 0.12, 0.18, -0.02), Vector3(0, 0, -s * 56), 0.34, 0.045, &"dark", 40)
		_part(_core, _box(Vector3(0.17, 0.11, 0.2)), &"bone", Vector3(s * 0.28, 0.22, 0))
		_spike(_core, Vector3(s * 0.3, 0.27, 0), 0.04, 0.2, &"dark", 0, 0)
		var arm := _joint(_core, Vector3(s * 0.3, 0.19, 0))
		_part(arm, _box(Vector3(0.07, 0.3, 0.07)), &"bone", Vector3(0, -0.15, 0))
		_part(arm, _ball(0.05), &"dark", Vector3(0, -0.3, 0))
		_part(arm, _box(Vector3(0.09, 0.24, 0.09)), &"bone", Vector3(0, -0.43, 0))
		_part(arm, _box(Vector3(0.12, 0.1, 0.15)), &"dark", Vector3(0, -0.58, 0.02))
		for i in 3:
			_part(arm, _cone(0.0, 0.016, 0.13), &"bone", Vector3(0.035 * (i - 1), -0.67, 0.07), Vector3(-25, 0, 0))
		_legs.append([arm, 0.0 if s > 0.0 else PI, 0.3])
		_strikers.append([arm, Vector3(-1.7, 0, 0)])
		var leg := _joint(_core, Vector3(s * 0.1, -0.32, 0))
		_part(leg, _box(Vector3(0.085, 0.2, 0.085)), &"bone", Vector3(0, -0.1, 0))
		_part(leg, _box(Vector3(0.12, 0.06, 0.2)), &"dark", Vector3(0, -0.21, 0.03))
		_legs.append([leg, PI if s > 0.0 else 0.0, 0.5])
	_sways.append([head, Vector3.UP, 0.14, 0.8, 0.0])
	_strikers.append([head, Vector3(0.3, 0, 0)])
	_strikers.append([jaw, Vector3(0.5, 0, 0)])


## A mushroom that wears its cap like a wanderer's hat: a wide pointed cap with a bronze brim and glowing
## warts, low over its eyes, a pale stem on root claws and spores that circle it.
func _build_mushroom() -> void:
	_breath = 0.03
	_hops = true
	for i in 4:
		var root := _joint(_core, Vector3.ZERO, Vector3(0, 45.0 + 90.0 * i, 0))
		_part(root, _cone(0.05, 0.0, 0.2), &"dark", Vector3(0.14, 0.035, 0), Vector3(0, 0, -100))
	_part(_core, _cone(0.13, 0.1, 0.44), &"bone", Vector3(0, 0.24, 0))
	_part(_core, _cone(0.18, 0.1, 0.08), &"dark", Vector3(0, 0.42, 0))
	_eyes(_core, 0.05, 0.3, 0.115, 0.028, true)
	var cap := _joint(_core, Vector3(0, 0.47, 0), Vector3(-16, 0, 0))
	_part(cap, _cone(0.3, 0.3, 0.03), &"dark", Vector3(0, 0.0, 0))
	_part(cap, _ring(0.275, 0.32), &"metal", Vector3(0, 0.015, 0))
	_part(cap, _cone(0.3, 0.04, 0.34), &"main", Vector3(0, 0.185, 0))
	_part(cap, _ball(0.05), &"gold", Vector3(0, 0.36, 0))
	_spike(cap, Vector3(0, 0.39, 0), 0.02, 0.1, &"gold")
	for wart: Vector2 in [Vector2(0.4, 0.3), Vector2(2.1, 0.25), Vector2(3.4, 0.4), Vector2(4.6, 0.2), Vector2(5.5, 0.6), Vector2(1.3, 0.62), Vector2(2.9, 0.7)]:
		var r := 0.3 - 0.26 * wart.y
		_part(cap, _ball(0.036), &"glow", Vector3(sin(wart.x) * r, 0.03 + 0.34 * wart.y, cos(wart.x) * r), Vector3.ZERO, Vector3(1.0, 0.6, 1.0))
	for i in 4:
		var spore := _joint(_core, Vector3(0, 0.16 + 0.06 * i, 0))
		_part(spore, _ball(0.028), &"glow")
		_orbits.append([spore, 0.4, 1.2, TAU * i / 4.0, 0.07])
	_sways.append([cap, Vector3.FORWARD, 0.06, 1.3, 0.0])
	_sways.append([cap, Vector3.RIGHT, 0.04, 1.0, 1.0])
	_strikers.append([cap, Vector3(0.6, 0, 0)])


## A stalker: a spiked dark body with one great eye and pincers, on six legs that end in bone blades.
func _build_stalker() -> void:
	_core.position.y = 0.4
	_breath = 0.03
	_part(_core, _ball(0.17), &"dark", Vector3(0, 0.02, -0.1), Vector3.ZERO, Vector3(1.0, 0.85, 1.3))
	_part(_core, _ball(0.125), &"dark", Vector3(0, 0, 0.1))
	_part(_core, _ball(0.07), &"glow", Vector3(0, 0.03, 0.185))
	_part(_core, _ball(0.034), &"ink", Vector3(0, 0.03, 0.235), Vector3.ZERO, Vector3(0.45, 1.4, 0.5))
	for i in 4:
		_spike(_core, Vector3(0, 0.13 - 0.01 * i, 0.04 - 0.1 * i), 0.04, 0.22 - 0.025 * i, &"main", -32)
	for s: float in [-1.0, 1.0]:
		_part(_core, _ball(0.02), &"spark", Vector3(s * 0.08, 0.07, 0.16))
		_horn(_core, Vector3(s * 0.06, -0.05, 0.19), Vector3(84, -s * 24, 0), 0.18, 0.022, &"bone", 0)
	var phase := 0.0
	for turn: float in [38.0, 90.0, 142.0, 218.0, 270.0, 322.0]:
		var leg := _joint(_core, Vector3.ZERO, Vector3(0, turn, 0))
		_part(leg, _capsule(0.026, 0.34), &"dark", Vector3(0.14, 0.1, 0), Vector3(0, 0, -55))
		_part(leg, _ball(0.04), &"main", Vector3(0.27, 0.2, 0))
		_part(leg, _cone(0.02, 0.0, 0.1), &"bone", Vector3(0.29, 0.27, 0), Vector3(0, 0, -20))
		_part(leg, _cone(0.0, 0.034, 0.6), &"bone", Vector3(0.325, -0.09, 0), Vector3(0, 0, 11))
		_legs.append([leg, phase, 0.3])
		phase += PI
	_strikers.append([_core, Vector3(0.35, 0, 0)])


## A maw: a round dark body that is mostly mouth, with a glowing gullet, long teeth and tusks, three eyes,
## two horns and fangs that circle it.
func _build_maw() -> void:
	_core.position.y = 0.48
	_hover = 0.03
	_breath = 0.05
	_hops = true
	_part(_core, _ball(0.29), &"dark")
	_part(_core, _ball(0.22), &"glow", Vector3(0, -0.04, 0.14), Vector3.ZERO, Vector3(1.08, 0.42, 0.75))
	for i in 6:
		var a := deg_to_rad(-55.0 + 22.0 * i)
		_part(_core, _cone(0.0, 0.036, 0.15), &"bone", Vector3(sin(a) * 0.245, -0.01, cos(a) * 0.265))
	for i in 5:
		var a := deg_to_rad(-44.0 + 22.0 * i)
		_part(_core, _cone(0.036, 0.0, 0.13), &"bone", Vector3(sin(a) * 0.235, -0.1, cos(a) * 0.255))
	for x: float in [-0.12, 0.0, 0.12]:
		var up := 0.2 if x == 0.0 else 0.16
		var out := 0.215 if x == 0.0 else 0.2
		_part(_core, _ball(0.036), &"spark", Vector3(x, up, out), Vector3(0, 0, signf(x) * 24.0), Vector3(1.5, 0.8, 0.6))
		_part(_core, _ball(0.014), &"ink", Vector3(x, up, out + 0.02), Vector3.ZERO, Vector3(0.6, 1.5, 0.6))
	for s: float in [-1.0, 1.0]:
		_horn(_core, Vector3(s * 0.17, 0.2, 0.02), Vector3(0, 0, -s * 40), 0.3, 0.05, &"bone", 42)
	for i in 3:
		_spike(_core, Vector3(0, 0.26 - 0.07 * i, -0.08 - 0.09 * i), 0.045, 0.16, &"main", -40.0 - 20.0 * i)
	var tail := _joint(_core, Vector3(0, 0.0, -0.24))
	_part(tail, _cone(0.1, 0.0, 0.28), &"dark", Vector3(0, 0, -0.11), Vector3(-90, 0, 0))
	for i in 3:
		var shard := _joint(_core, Vector3(0, 0.1, 0))
		_part(shard, _cone(0.0, 0.035, 0.2), &"bone", Vector3.ZERO, Vector3(0, 0, 20))
		_orbits.append([shard, 0.44, -0.8, TAU * i / 3.0, 0.08])
	_sways.append([tail, Vector3.UP, 0.4, 1.8, 0.0])
	_strikers.append([_core, Vector3(0.4, 0, 0)])
