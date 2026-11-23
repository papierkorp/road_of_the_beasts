class_name MonsterBody
extends InkFigure
## The body of a monster: simple parts in one colour, two or three bodies per Kin (`BODIES`), drawn with an ink line, and its movements
## (standing, walking, attacking, casting, being hit, pushed, healed and defeated). Look only: no rule reads it.
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
	_materials(color)
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
	for list in [_legs, _wings, _sways, _bobs, _orbits, _spins, _strikers]:
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


# ---------- parts ----------

func _eyes(parent: Node3D, half: float, y: float, z: float, r: float = 0.024) -> void:
	for s in [-1.0, 1.0]:
		_part(parent, _ball(r), &"ink", Vector3(s * half, y, z))


# ---------- the bodies of the eight Kins ----------

## Four legs, a head with ears and a snout, a tail. tiger: round ears, stripes, a long tail · wolf: pointed
## ears, a long snout, a ruff and a brush · bear: heavy, small round ears, a stub of a tail.
func _build_beast(body: String) -> void:
	var bear := body == "bear"
	var wolf := body == "wolf"
	var girth := 0.2 if bear else 0.16
	_core.position.y = 0.36
	_part(_core, _capsule(girth, 0.6), &"main", Vector3.ZERO, Vector3(90, 0, 0))
	_part(_core, _ball(girth + 0.025), &"light" if wolf else &"main", Vector3(0, 0.03, 0.15))
	if body == "tiger":
		for z in [-0.14, -0.02, 0.1]:
			_part(_core, _box(Vector3(0.24, 0.03, 0.035)), &"dark", Vector3(0, 0.155, z))
	var head := _joint(_core, Vector3(0, 0.13, 0.3))
	_part(head, _ball(0.17 if bear else 0.145), &"main", Vector3(0, 0.02, 0.06))
	var snout := 0.25 if wolf else 0.17
	_part(head, _capsule(0.06 if not bear else 0.07, snout), &"light", Vector3(0, -0.03, 0.14 + snout * 0.25), Vector3(90, 0, 0))
	_part(head, _ball(0.026), &"ink", Vector3(0, -0.005, 0.185 + snout * 0.5))
	for s in [-1.0, 1.0]:
		if wolf:
			_part(head, _prism(Vector3(0.09, 0.15, 0.05)), &"dark", Vector3(s * 0.085, 0.17, 0.03), Vector3(0, 0, -s * 10))
		else:
			_part(head, _ball(0.05), &"dark", Vector3(s * (0.13 if bear else 0.1), 0.15, 0.03))
	_eyes(head, 0.068, 0.055, 0.2 if bear else 0.178)
	var phase := 0.0
	for z in [0.2, -0.2]:
		for s in [-1.0, 1.0]:
			var leg := _joint(_core, Vector3(s * (girth - 0.05), -0.06, z))
			_part(leg, _capsule(0.07 if bear else 0.05, 0.3), &"dark", Vector3(0, -0.15, 0))
			_legs.append([leg, phase, 0.45 if bear else 0.6])
			phase += PI
		phase += PI
	var tail := _joint(_core, Vector3(0, 0.06, -0.3), Vector3(-38, 0, 0))
	if bear:
		_part(tail, _ball(0.06), &"dark", Vector3(0, -0.03, -0.03))
	elif wolf:
		_part(tail, _capsule(0.065, 0.3), &"main", Vector3(0, 0, -0.14), Vector3(90, 0, 0))
		_part(tail, _ball(0.06), &"light", Vector3(0, 0, -0.27))
	else:
		_part(tail, _capsule(0.035, 0.36), &"main", Vector3(0, 0, -0.18), Vector3(90, 0, 0))
		_part(tail, _ball(0.05), &"dark", Vector3(0, 0, -0.37))
	_sways.append([tail, Vector3.UP, 0.4, 2.6, 0.0])
	_sways.append([head, Vector3.FORWARD, 0.06, 1.3, 1.0])
	_strikers.append([head, Vector3(0.45, 0, 0)])
	_strikers.append([tail, Vector3(-0.5, 0, 0)])


## A bird's body that never quite lands: two wings, a beak, a tail fan.
func _build_winged() -> void:
	_core.position.y = 0.44
	_hover = 0.04
	_breath = 0.0
	_part(_core, _ball(0.17), &"main", Vector3.ZERO, Vector3.ZERO, Vector3(1.0, 1.0, 1.35))
	_part(_core, _ball(0.13), &"light", Vector3(0, -0.05, 0.07), Vector3.ZERO, Vector3(1.0, 1.0, 1.25))
	var head := _joint(_core, Vector3(0, 0.14, 0.2))
	_part(head, _ball(0.12), &"main")
	_part(head, _cone(0.045, 0.0, 0.14), &"dark", Vector3(0, -0.01, 0.16), Vector3(90, 0, 0))
	_part(head, _prism(Vector3(0.05, 0.1, 0.12)), &"dark", Vector3(0, 0.13, -0.03))
	_eyes(head, 0.066, 0.03, 0.09)
	for s in [-1.0, 1.0]:
		var wing := _joint(_core, Vector3(s * 0.13, 0.06, 0.0))
		_part(wing, _prism(Vector3(0.44, 0.3, 0.03), 0.0 if s > 0.0 else 1.0), &"dark", Vector3(s * 0.22, 0, -0.03), Vector3(-90, 0, 0))
		_part(wing, _prism(Vector3(0.26, 0.2, 0.035), 0.0 if s > 0.0 else 1.0), &"main", Vector3(s * 0.13, 0.012, 0.0), Vector3(-90, 0, 0))
		_wings.append([wing, s])
		_part(_core, _capsule(0.022, 0.15), &"dark", Vector3(s * 0.07, -0.2, 0.02))
	var tail := _joint(_core, Vector3(0, 0.0, -0.2))
	_part(tail, _prism(Vector3(0.22, 0.24, 0.03)), &"dark", Vector3(0, 0, -0.12), Vector3(90, 0, 0))
	_sways.append([tail, Vector3.RIGHT, 0.2, 2.5, 0.0])
	_sways.append([head, Vector3.UP, 0.18, 1.1, 0.5])
	_strikers.append([head, Vector3(0.5, 0, 0)])


## Low and long: splayed legs, a ridge along the back, a tail that tapers.
func _build_scaled() -> void:
	_core.position.y = 0.2
	_part(_core, _ball(0.2), &"main", Vector3.ZERO, Vector3.ZERO, Vector3(1.1, 0.72, 1.7))
	_part(_core, _ball(0.17), &"light", Vector3(0, -0.035, 0.03), Vector3.ZERO, Vector3(1.05, 0.6, 1.6))
	for z in [-0.17, 0.0, 0.17]:
		_part(_core, _cone(0.05, 0.0, 0.13), &"dark", Vector3(0, 0.17, z), Vector3(-20, 0, 0))
	var head := _joint(_core, Vector3(0, 0.04, 0.32))
	_part(head, _ball(0.115), &"main", Vector3(0, 0, 0.08), Vector3.ZERO, Vector3(1.0, 0.8, 1.35))
	_eyes(head, 0.07, 0.055, 0.12)
	var phase := 0.0
	for z in [0.17, -0.17]:
		for s in [-1.0, 1.0]:
			var leg := _joint(_core, Vector3(s * 0.2, -0.04, z))
			_part(leg, _capsule(0.05, 0.2), &"dark", Vector3(s * 0.035, -0.07, 0), Vector3(0, 0, s * 28))
			_legs.append([leg, phase, 0.5])
			phase += PI
		phase += PI
	var tail := _joint(_core, Vector3(0, 0.0, -0.3))
	_part(tail, _cone(0.09, 0.0, 0.42), &"main", Vector3(0, 0, -0.2), Vector3(-90, 0, 0))
	_sways.append([tail, Vector3.UP, 0.45, 2.0, 0.0])
	_sways.append([_core, Vector3.UP, 0.05, 2.0, PI])
	_sways.append([head, Vector3.UP, 0.12, 1.2, 0.0])
	_strikers.append([head, Vector3(-0.35, 0, 0)])
	_strikers.append([tail, Vector3(0, 0.9, 0)])


## Five small bodies that circle one another.
func _build_swarm() -> void:
	_core.position.y = 0.44
	_breath = 0.0
	_hops = true
	for i in 5:
		var one := _joint(_core, Vector3(0, 0.12 * ((i % 3) - 1), 0))
		_part(one, _ball(0.08), &"main", Vector3.ZERO, Vector3.ZERO, Vector3(1.0, 1.0, 1.25))
		_part(one, _ball(0.065), &"dark", Vector3(0, -0.012, -0.11), Vector3.ZERO, Vector3(1.0, 1.0, 1.3))
		_eyes(one, 0.04, 0.02, 0.08, 0.016)
		for s in [-1.0, 1.0]:
			var wing := _joint(one, Vector3(s * 0.04, 0.06, -0.02))
			_part(wing, _box(Vector3(0.14, 0.012, 0.07)), &"light", Vector3(s * 0.07, 0, 0))
			_wings.append([wing, s])
		_orbits.append([one, 0.2 + 0.03 * (i % 2), 1.5, TAU * i / 5.0, 0.05])
	_wing_rest = 0.2


## A floating drop with a wisp for a tail, two loose hands and a flame on its head.
func _build_spirit() -> void:
	_core.position.y = 0.5
	_hover = 0.05
	_breath = 0.03
	_hops = true
	_part(_core, _ball(0.2), &"main", Vector3(0, 0.08, 0))
	var tail := _joint(_core, Vector3(0, 0.02, 0))
	_part(tail, _cone(0.0, 0.185, 0.38), &"main", Vector3(0, -0.17, 0))
	var tip := _joint(tail, Vector3(0, -0.36, 0))
	_part(tip, _cone(0.0, 0.05, 0.14), &"light", Vector3(0, -0.04, 0))
	for s in [-1.0, 1.0]:
		_part(_core, _ball(0.03), &"ink", Vector3(s * 0.075, 0.1, 0.178), Vector3.ZERO, Vector3(1.0, 1.5, 0.6))
		var hand := _joint(_core, Vector3(s * 0.27, -0.02, 0.08))
		_part(hand, _ball(0.055), &"light")
		_bobs.append([hand, 0.04, 2.4, 1.5 if s > 0.0 else 0.0])
	var flame := _joint(_core, Vector3(0, 0.26, 0))
	_part(flame, _cone(0.075, 0.0, 0.18), &"light", Vector3(0, 0.07, 0))
	_sways.append([flame, Vector3.FORWARD, 0.3, 3.0, 0.0])
	_sways.append([tail, Vector3.FORWARD, 0.16, 1.7, 0.0])
	_sways.append([tail, Vector3.RIGHT, 0.12, 1.3, 1.0])
	_sways.append([tip, Vector3.FORWARD, 0.4, 1.7, -1.0])
	_strikers.append([tail, Vector3(-0.6, 0, 0)])


## Blocks on two short legs, with heavy arms.
func _build_stone() -> void:
	_core.position.y = 0.42
	_breath = 0.012
	_part(_core, _box(Vector3(0.46, 0.4, 0.34)), &"main")
	_part(_core, _box(Vector3(0.34, 0.14, 0.28)), &"dark", Vector3(0, -0.25, 0))
	var head := _joint(_core, Vector3(0, 0.2, 0.04))
	_part(head, _box(Vector3(0.22, 0.18, 0.22)), &"main", Vector3(0, 0.09, 0))
	_part(head, _box(Vector3(0.25, 0.045, 0.07)), &"dark", Vector3(0, 0.155, 0.1))
	_eyes(head, 0.058, 0.095, 0.112, 0.026)
	for s in [-1.0, 1.0]:
		_part(_core, _box(Vector3(0.17, 0.1, 0.22)), &"light", Vector3(s * 0.27, 0.23, 0), Vector3(0, 0, -s * 14))
		var arm := _joint(_core, Vector3(s * 0.31, 0.14, 0))
		_part(arm, _box(Vector3(0.13, 0.4, 0.15)), &"main", Vector3(0, -0.18, 0))
		_part(arm, _box(Vector3(0.18, 0.16, 0.2)), &"dark", Vector3(0, -0.42, 0.02))
		_legs.append([arm, 0.0 if s > 0.0 else PI, 0.3])
		_strikers.append([arm, Vector3(-1.9, 0, 0)])
		var leg := _joint(_core, Vector3(s * 0.12, -0.3, 0))
		_part(leg, _box(Vector3(0.17, 0.12, 0.22)), &"dark", Vector3(0, -0.06, 0.01))
		_legs.append([leg, PI if s > 0.0 else 0.0, 0.5])
	_sways.append([head, Vector3.UP, 0.1, 0.9, 0.0])


## A trunk on roots with a crown and two branches.
func _build_flora() -> void:
	_breath = 0.015
	_hops = true
	_part(_core, _cone(0.15, 0.1, 0.46), &"dark", Vector3(0, 0.23, 0))
	for i in 3:
		var root := _joint(_core, Vector3.ZERO, Vector3(0, 30 + 120 * i, 0))
		_part(root, _cone(0.06, 0.0, 0.22), &"dark", Vector3(0.2, 0.04, 0), Vector3(0, 0, -90))
	_eyes(_core, 0.055, 0.3, 0.125)
	var crown := _joint(_core, Vector3(0, 0.46, 0))
	_part(crown, _ball(0.22), &"main", Vector3(0, 0.14, 0))
	_part(crown, _ball(0.16), &"main", Vector3(0.16, 0.06, 0.06))
	_part(crown, _ball(0.15), &"main", Vector3(-0.15, 0.07, -0.05))
	_part(crown, _ball(0.12), &"light", Vector3(0.03, 0.29, 0.05))
	for s in [-1.0, 1.0]:
		var arm := _joint(_core, Vector3(s * 0.11, 0.3, 0.02))
		_part(arm, _capsule(0.035, 0.28), &"dark", Vector3(s * 0.11, 0.06, 0), Vector3(0, 0, -s * 58))
		_part(arm, _ball(0.07), &"main", Vector3(s * 0.24, 0.14, 0))
		_sways.append([arm, Vector3.FORWARD, 0.1, 1.6, 1.0 if s > 0.0 else 2.2])
		_strikers.append([arm, Vector3(0.3, -s * 1.3, 0)])
	_sways.append([crown, Vector3.FORWARD, 0.07, 1.2, 0.0])
	_sways.append([crown, Vector3.RIGHT, 0.05, 0.9, 1.0])
	_strikers.append([crown, Vector3(0.35, 0, 0)])


## A dark core with one eye, a turning ring, circling shards and hanging threads.
func _build_void() -> void:
	_core.position.y = 0.52
	_hover = 0.04
	_breath = 0.035
	_hops = true
	var main: Color = _tints[&"main"]
	_tints[&"dark"] = UiTheme.INK.lerp(main, 0.22)
	_tints[&"light"] = main.lerp(UiTheme.PAPER_LIGHT, 0.35)
	_part(_core, _ball(0.18), &"dark")
	_part(_core, _ball(0.075), &"light", Vector3(0, 0.01, 0.135))
	_part(_core, _ball(0.034), &"ink", Vector3(0, 0.01, 0.2))
	var tilt := _joint(_core, Vector3.ZERO, Vector3(24, 0, 14))
	var ring := _joint(tilt, Vector3.ZERO)
	var torus := TorusMesh.new()
	torus.inner_radius = 0.25
	torus.outer_radius = 0.295
	torus.rings = 28
	torus.ring_segments = 8
	_part(ring, torus, &"main")
	_part(ring, _ball(0.045), &"light", Vector3(0.272, 0, 0))
	_spins.append([ring, Vector3.UP, 1.4])
	for i in 4:
		var shard := _joint(_core, Vector3(0, 0.04 * (i % 2), 0))
		_part(shard, _prism(Vector3(0.07, 0.17, 0.05)), &"dark", Vector3.ZERO, Vector3(0, 0, 20))
		_orbits.append([shard, 0.37, -0.9, TAU * i / 4.0, 0.07])
	for i in 3:
		var thread := _joint(_core, Vector3(0.09 * (i - 1), -0.13, -0.03 * (i % 2)))
		_part(thread, _cone(0.0, 0.04, 0.26), &"dark", Vector3(0, -0.13, 0))
		_sways.append([thread, Vector3.FORWARD, 0.25, 1.9, float(i)])
		_sways.append([thread, Vector3.RIGHT, 0.2, 1.4, float(i) * 2.0])
		_strikers.append([thread, Vector3(-1.1, 0, 0)])


## A moth: a furred body, feelers, two pairs of round wings with eye spots.
func _build_moth() -> void:
	_core.position.y = 0.44
	_hover = 0.05
	_breath = 0.0
	_wing_rest = 0.2
	_part(_core, _capsule(0.09, 0.36), &"light", Vector3(0, 0, -0.03), Vector3(90, 0, 0))
	var head := _joint(_core, Vector3(0, 0.02, 0.18))
	_part(head, _ball(0.09), &"main")
	_eyes(head, 0.055, 0.02, 0.07, 0.03)
	for s in [-1.0, 1.0]:
		var feeler := _joint(head, Vector3(s * 0.04, 0.06, 0.04), Vector3(50, s * 28, 0))
		_part(feeler, _capsule(0.012, 0.2), &"dark", Vector3(0, 0.1, 0))
		_part(feeler, _ball(0.026), &"dark", Vector3(0, 0.2, 0))
		_sways.append([feeler, Vector3.FORWARD, 0.15, 2.3, s])
		var wing := _joint(_core, Vector3(s * 0.07, 0.04, 0.0))
		_part(wing, _ball(0.2), &"main", Vector3(s * 0.22, 0, 0.07), Vector3(0, -s * 18, 0), Vector3(1.15, 0.07, 0.85))
		_part(wing, _ball(0.06), &"dark", Vector3(s * 0.27, 0.012, 0.08), Vector3.ZERO, Vector3(1.0, 0.12, 1.0))
		_part(wing, _ball(0.15), &"dark", Vector3(s * 0.17, -0.005, -0.14), Vector3(0, s * 20, 0), Vector3(1.0, 0.07, 0.95))
		_wings.append([wing, s])
	_sways.append([head, Vector3.UP, 0.15, 1.2, 0.0])
	_strikers.append([head, Vector3(0.4, 0, 0)])


## A turtle: a domed shell, a short neck, four stub legs.
func _build_turtle() -> void:
	_core.position.y = 0.19
	_breath = 0.012
	_part(_core, _ball(0.25), &"light", Vector3(0, -0.02, 0), Vector3.ZERO, Vector3(1.0, 0.32, 1.12))
	_part(_core, _ball(0.27), &"dark", Vector3(0, 0.07, -0.01), Vector3.ZERO, Vector3(1.0, 0.62, 1.1))
	_part(_core, _ball(0.17), &"main", Vector3(0, 0.17, -0.01), Vector3.ZERO, Vector3(1.0, 0.5, 1.1))
	for i in 6:
		var a := TAU * i / 6.0
		_part(_core, _ball(0.07), &"main", Vector3(sin(a) * 0.19, 0.12, cos(a) * 0.21 - 0.01), Vector3.ZERO, Vector3(1.0, 0.5, 1.0))
	var head := _joint(_core, Vector3(0, 0.03, 0.27))
	_part(head, _capsule(0.06, 0.18), &"main", Vector3(0, 0, 0.02), Vector3(90, 0, 0))
	_part(head, _ball(0.1), &"main", Vector3(0, 0.02, 0.1))
	_eyes(head, 0.065, 0.06, 0.15)
	var phase := 0.0
	for z in [0.17, -0.17]:
		for s in [-1.0, 1.0]:
			var leg := _joint(_core, Vector3(s * 0.21, -0.05, z))
			_part(leg, _capsule(0.06, 0.17), &"main", Vector3(s * 0.02, -0.06, 0), Vector3(0, 0, s * 24))
			_legs.append([leg, phase, 0.4])
			phase += PI
		phase += PI
	var tail := _joint(_core, Vector3(0, -0.02, -0.28))
	_part(tail, _cone(0.045, 0.0, 0.16), &"main", Vector3(0, 0, -0.06), Vector3(-90, 0, 0))
	_sways.append([tail, Vector3.UP, 0.4, 1.6, 0.0])
	_sways.append([head, Vector3.UP, 0.16, 0.9, 0.0])
	_strikers.append([head, Vector3(-0.3, 0, 0)])


## A serpent: a coil on the ground, a raised neck with a hood.
func _build_serpent() -> void:
	_breath = 0.015
	var coil := TorusMesh.new()
	coil.inner_radius = 0.12
	coil.outer_radius = 0.28
	coil.rings = 24
	coil.ring_segments = 10
	_part(_core, coil, &"main", Vector3(0, 0.08, 0))
	var upper := TorusMesh.new()
	upper.inner_radius = 0.06
	upper.outer_radius = 0.2
	upper.rings = 20
	upper.ring_segments = 10
	_part(_core, upper, &"main", Vector3(0, 0.2, -0.01))
	var tail := _joint(_core, Vector3(0.16, 0.07, -0.18), Vector3(0, 35, 0))
	_part(tail, _cone(0.055, 0.0, 0.26), &"dark", Vector3(0, 0, -0.12), Vector3(-90, 0, 0))
	var neck := _joint(_core, Vector3(0, 0.24, 0.0), Vector3(14, 0, 0))
	_part(neck, _capsule(0.07, 0.36), &"main", Vector3(0, 0.15, 0))
	_part(neck, _capsule(0.045, 0.3), &"light", Vector3(0, 0.15, 0.04))
	var head := _joint(neck, Vector3(0, 0.33, 0.0), Vector3(-6, 0, 0))
	_part(head, _ball(0.14), &"dark", Vector3(0, -0.03, -0.04), Vector3.ZERO, Vector3(1.35, 1.1, 0.3))
	_part(head, _ball(0.095), &"main", Vector3(0, 0.02, 0.06), Vector3.ZERO, Vector3(1.0, 0.75, 1.4))
	_eyes(head, 0.06, 0.05, 0.11)
	_sways.append([neck, Vector3.FORWARD, 0.14, 1.5, 0.0])
	_sways.append([neck, Vector3.UP, 0.2, 1.1, 1.0])
	_sways.append([tail, Vector3.UP, 0.5, 2.4, 0.0])
	_sways.append([_core, Vector3.UP, 0.06, 1.8, 0.0])
	_strikers.append([neck, Vector3(0.95, 0, 0)])
	_strikers.append([head, Vector3(-0.6, 0, 0)])


## Six thorned mites that run in two rings on the ground.
func _build_mites() -> void:
	_core.position.y = 0.07
	_breath = 0.0
	_hops = true
	for i in 6:
		var one := _joint(_core, Vector3.ZERO)
		_part(one, _ball(0.075), &"dark", Vector3.ZERO, Vector3.ZERO, Vector3(1.0, 0.75, 1.25))
		_part(one, _ball(0.045), &"main", Vector3(0, -0.005, 0.09))
		_eyes(one, 0.025, 0.012, 0.125, 0.012)
		for z in [-0.04, 0.03]:
			_part(one, _cone(0.022, 0.0, 0.09), &"light", Vector3(0, 0.08, z), Vector3(-18, 0, 0))
		for s in [-1.0, 1.0]:
			_part(one, _capsule(0.012, 0.11), &"main", Vector3(s * 0.085, -0.03, 0.0), Vector3(0, 0, s * 55))
		var inner := i % 2 == 0
		_orbits.append([one, 0.11 if inner else 0.27, 2.1 if inner else 1.3, TAU * i / 6.0, 0.0])


## A wisp: a small flame with a pointed tip, three sparks around it.
func _build_wisp() -> void:
	_core.position.y = 0.46
	_hover = 0.07
	_breath = 0.05
	_hops = true
	_part(_core, _ball(0.16), &"main")
	_part(_core, _ball(0.11), &"light", Vector3(0, -0.03, 0.07))
	for s in [-1.0, 1.0]:
		_part(_core, _ball(0.026), &"ink", Vector3(s * 0.055, 0.0, 0.17), Vector3.ZERO, Vector3(1.0, 1.5, 0.6))
	var flame := _joint(_core, Vector3(0, 0.08, 0))
	_part(flame, _cone(0.135, 0.0, 0.3), &"main", Vector3(0, 0.13, 0))
	var tip := _joint(flame, Vector3(0.03, 0.2, 0))
	_part(tip, _cone(0.05, 0.0, 0.16), &"light", Vector3(0, 0.07, 0))
	var tail := _joint(_core, Vector3(0, -0.1, 0))
	_part(tail, _cone(0.0, 0.08, 0.18), &"light", Vector3(0, -0.1, 0))
	for i in 3:
		var spark := _joint(_core, Vector3(0, 0.02 + 0.08 * i, 0))
		_part(spark, _ball(0.04), &"light")
		_orbits.append([spark, 0.29, 1.9, TAU * i / 3.0, 0.08])
	_sways.append([flame, Vector3.FORWARD, 0.25, 3.2, 0.0])
	_sways.append([flame, Vector3.RIGHT, 0.15, 2.3, 1.0])
	_sways.append([tip, Vector3.FORWARD, 0.4, 4.1, 2.0])
	_sways.append([tail, Vector3.RIGHT, 0.3, 2.0, 0.0])
	_strikers.append([flame, Vector3(0.9, 0, 0)])


## A shade: a hooded cloak with a torn hem, a pale face and long arms.
func _build_shade() -> void:
	_core.position.y = 0.44
	_hover = 0.04
	_breath = 0.02
	_hops = true
	_part(_core, _cone(0.23, 0.1, 0.56), &"dark")
	for i in 6:
		var rag := _joint(_core, Vector3.ZERO, Vector3(0, 60.0 * i, 0))
		_part(rag, _cone(0.0, 0.07, 0.16), &"dark", Vector3(0.16, -0.33, 0))
	var head := _joint(_core, Vector3(0, 0.3, 0))
	_part(head, _ball(0.16), &"dark", Vector3(0, 0.04, -0.01))
	_part(head, _cone(0.09, 0.0, 0.16), &"dark", Vector3(0, 0.2, -0.05), Vector3(-28, 0, 0))
	_part(head, _ball(0.11), &"light", Vector3(0, 0.02, 0.075), Vector3.ZERO, Vector3(1.0, 1.15, 0.6))
	for s in [-1.0, 1.0]:
		_part(head, _ball(0.024), &"ink", Vector3(s * 0.045, 0.045, 0.14), Vector3.ZERO, Vector3(1.0, 1.6, 0.6))
		var arm := _joint(_core, Vector3(s * 0.15, 0.17, 0.03), Vector3(-25, 0, 0))
		_part(arm, _capsule(0.03, 0.34), &"main", Vector3(0, -0.15, 0))
		_part(arm, _ball(0.05), &"light", Vector3(0, -0.33, 0))
		_sways.append([arm, Vector3.RIGHT, 0.14, 1.4, 1.2 if s > 0.0 else 0.0])
		_strikers.append([arm, Vector3(-1.3, 0, 0)])
	_part(head, _ball(0.028), &"ink", Vector3(0, -0.035, 0.135), Vector3.ZERO, Vector3(1.0, 1.8, 0.6))
	_sways.append([head, Vector3.FORWARD, 0.08, 1.1, 0.0])
	_sways.append([_core, Vector3.FORWARD, 0.05, 0.9, 0.5])


## A colossus of bone: a skull, a cage of ribs, long arms that reach the ground.
func _build_colossus() -> void:
	_core.position.y = 0.5
	_breath = 0.01
	_part(_core, _box(Vector3(0.11, 0.46, 0.11)), &"main", Vector3(0, -0.02, -0.02))
	for i in 3:
		_part(_core, _box(Vector3(0.4 - 0.05 * i, 0.06, 0.26 - 0.03 * i)), &"light", Vector3(0, 0.15 - 0.1 * i, 0))
	_part(_core, _box(Vector3(0.3, 0.1, 0.2)), &"dark", Vector3(0, -0.25, 0))
	var head := _joint(_core, Vector3(0, 0.24, 0.03))
	_part(head, _box(Vector3(0.23, 0.2, 0.23)), &"light", Vector3(0, 0.12, 0))
	_part(head, _box(Vector3(0.17, 0.07, 0.17)), &"main", Vector3(0, 0.0, 0.035))
	_eyes(head, 0.055, 0.13, 0.117, 0.036)
	for s in [-1.0, 1.0]:
		_part(head, _cone(0.035, 0.0, 0.14), &"dark", Vector3(s * 0.11, 0.25, -0.02), Vector3(0, 0, -s * 24))
		_part(_core, _box(Vector3(0.14, 0.1, 0.17)), &"main", Vector3(s * 0.25, 0.2, 0))
		var arm := _joint(_core, Vector3(s * 0.27, 0.17, 0))
		_part(arm, _box(Vector3(0.075, 0.5, 0.075)), &"light", Vector3(0, -0.25, 0))
		_part(arm, _box(Vector3(0.12, 0.13, 0.15)), &"main", Vector3(0, -0.54, 0.02))
		_legs.append([arm, 0.0 if s > 0.0 else PI, 0.3])
		_strikers.append([arm, Vector3(-1.7, 0, 0)])
		var leg := _joint(_core, Vector3(s * 0.1, -0.3, 0))
		_part(leg, _box(Vector3(0.085, 0.16, 0.085)), &"light", Vector3(0, -0.07, 0))
		_part(leg, _box(Vector3(0.12, 0.06, 0.18)), &"main", Vector3(0, -0.17, 0.03))
		_legs.append([leg, PI if s > 0.0 else 0.0, 0.5])
	_sways.append([head, Vector3.UP, 0.14, 0.8, 0.0])
	_strikers.append([head, Vector3(0.3, 0, 0)])


## A mushroom: a spotted cap on a pale stem with two small feet.
func _build_mushroom() -> void:
	_breath = 0.03
	_hops = true
	for s in [-1.0, 1.0]:
		_part(_core, _ball(0.065), &"dark", Vector3(s * 0.09, 0.04, 0.04), Vector3.ZERO, Vector3(1.0, 0.7, 1.3))
	_part(_core, _cone(0.14, 0.1, 0.34), &"light", Vector3(0, 0.2, 0))
	_eyes(_core, 0.05, 0.2, 0.125)
	var cap := _joint(_core, Vector3(0, 0.36, 0))
	_part(cap, _cone(0.3, 0.3, 0.03), &"dark", Vector3(0, 0.0, 0))
	_part(cap, _ball(0.33), &"main", Vector3(0, 0.02, 0), Vector3.ZERO, Vector3(1.0, 0.62, 1.0))
	for spot in [Vector3(0.0, 1.0, 0.1), Vector3(0.6, 0.6, 0.45), Vector3(-0.55, 0.65, 0.4), Vector3(0.3, 0.65, -0.6), Vector3(-0.5, 0.55, -0.55), Vector3(0.05, 0.45, 0.85)]:
		var at: Vector3 = spot.normalized()
		_part(cap, _ball(0.055), &"light", Vector3(at.x * 0.325, 0.02 + at.y * 0.2, at.z * 0.325), Vector3.ZERO, Vector3(1.0, 0.5, 1.0))
	_sways.append([cap, Vector3.FORWARD, 0.07, 1.3, 0.0])
	_sways.append([cap, Vector3.RIGHT, 0.05, 1.0, 1.0])
	_strikers.append([cap, Vector3(0.6, 0, 0)])


## A stalker: a dark body with one eye on four long, thin legs.
func _build_stalker() -> void:
	_core.position.y = 0.36
	_breath = 0.03
	var main: Color = _tints[&"main"]
	_tints[&"dark"] = UiTheme.INK.lerp(main, 0.22)
	_part(_core, _ball(0.16), &"dark", Vector3.ZERO, Vector3.ZERO, Vector3(1.0, 0.8, 1.3))
	_part(_core, _ball(0.07), &"light", Vector3(0, 0.02, 0.16))
	_part(_core, _ball(0.032), &"ink", Vector3(0, 0.02, 0.22))
	for z in [-0.1, 0.0, 0.1]:
		_part(_core, _cone(0.04, 0.0, 0.16), &"main", Vector3(0, 0.16, z - 0.03), Vector3(-25, 0, 0))
	var phase := 0.0
	for turn in [40.0, 140.0, 220.0, 320.0]:
		var leg := _joint(_core, Vector3.ZERO, Vector3(0, turn, 0))
		_part(leg, _capsule(0.024, 0.3), &"dark", Vector3(0.12, 0.08, 0), Vector3(0, 0, -55))
		_part(leg, _ball(0.036), &"main", Vector3(0.235, 0.165, 0))
		_part(leg, _cone(0.0, 0.03, 0.52), &"dark", Vector3(0.285, -0.09, 0), Vector3(0, 0, 11))
		_legs.append([leg, phase, 0.35])
		phase += PI
	_strikers.append([_core, Vector3(0.35, 0, 0)])


## A maw: a round body that is mostly mouth, with teeth, three eyes and two shards around it.
func _build_maw() -> void:
	_core.position.y = 0.42
	_hover = 0.03
	_breath = 0.05
	_hops = true
	var main: Color = _tints[&"main"]
	_tints[&"dark"] = UiTheme.INK.lerp(main, 0.22)
	_part(_core, _ball(0.27), &"dark")
	_part(_core, _ball(0.21), &"main", Vector3(0, -0.04, 0.13), Vector3.ZERO, Vector3(1.08, 0.42, 0.75))
	for i in 5:
		var a := deg_to_rad(-52.0 + 26.0 * i)
		_part(_core, _cone(0.0, 0.035, 0.11), &"light", Vector3(sin(a) * 0.23, 0.0, cos(a) * 0.25))
	for i in 4:
		var a := deg_to_rad(-39.0 + 26.0 * i)
		_part(_core, _cone(0.035, 0.0, 0.1), &"light", Vector3(sin(a) * 0.22, -0.1, cos(a) * 0.24))
	for x in [-0.11, 0.0, 0.11]:
		var up := 0.2 if x == 0.0 else 0.16
		_part(_core, _ball(0.04), &"light", Vector3(x, up, 0.17 if x == 0.0 else 0.15))
		_part(_core, _ball(0.018), &"ink", Vector3(x, up + 0.005, 0.205 if x == 0.0 else 0.185))
	var tail := _joint(_core, Vector3(0, 0.0, -0.22))
	_part(tail, _cone(0.1, 0.0, 0.26), &"dark", Vector3(0, 0, -0.1), Vector3(-90, 0, 0))
	for i in 2:
		var shard := _joint(_core, Vector3(0, 0.1, 0))
		_part(shard, _prism(Vector3(0.07, 0.17, 0.05)), &"main", Vector3.ZERO, Vector3(0, 0, 20))
		_orbits.append([shard, 0.4, -0.8, PI * i, 0.08])
	_sways.append([tail, Vector3.UP, 0.4, 1.8, 0.0])
	_strikers.append([_core, Vector3(0.4, 0, 0)])
