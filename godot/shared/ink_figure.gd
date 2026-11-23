class_name InkFigure
extends Node3D
## A figure of the board built from code: simple meshes in a few tones of one colour, each with an ink line
## (`assets/shaders/ink_outline.gdshader`). The base of `MonsterBody` and `PropBody`: materials, parts and the
## flash. Look only: no rule reads it.

const OUTLINE_SHADER := "res://assets/shaders/ink_outline.gdshader"

var _mats := {}                # name -> StandardMaterial3D: main, dark, light, ink
var _tints := {}               # name -> Color (the colour without a flash)
var _outline := {}             # form of the mesh (int) -> ShaderMaterial
var _flash := 0.0
var _flash_color := Color.WHITE
var _flash_tween: Tween


## The tones of a figure in `color`: main, a darker and a paler one, and ink for small marks such as eyes.
func _materials(color: Color) -> void:
	_material(&"main", color)
	_material(&"dark", color.darkened(0.38))
	_material(&"light", color.lerp(UiTheme.PAPER_LIGHT, 0.6))
	var ink := StandardMaterial3D.new()
	ink.albedo_color = UiTheme.INK
	ink.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_mats[&"ink"] = ink


## Tint all parts toward `color` for a moment, after `delay` seconds.
func flash(color: Color, delay: float = 0.0) -> void:
	if not is_inside_tree():
		return
	if _flash_tween != null:
		_flash_tween.kill()
	_flash_tween = create_tween()
	if delay > 0.0:
		_flash_tween.tween_interval(delay)
	_flash_tween.tween_callback(func() -> void:
		_flash_color = color
		_flash = 0.85)
	_flash_tween.tween_property(self, "_flash", 0.0, 0.3)


## Called every frame by the figure: paints the tones with the flash.
func _show_flash() -> void:
	for key in _tints:
		(_mats[key] as StandardMaterial3D).albedo_color = (_tints[key] as Color).lerp(_flash_color, _flash)


func _material(key: StringName, color: Color) -> void:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 1.0
	m.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	m.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	_mats[key] = m
	_tints[key] = color


## The ink line for a mesh form of the shader: 0 round, 1 box or prism, 2 cylinder or cone.
func _outline_material(form: int) -> ShaderMaterial:
	if not _outline.has(form):
		var o := ShaderMaterial.new()
		o.shader = load(OUTLINE_SHADER)
		o.set_shader_parameter("ink", UiTheme.INK)
		o.set_shader_parameter("form", form)
		_outline[form] = o
	return _outline[form]


func _joint(parent: Node3D, pos: Vector3, rot_deg: Vector3 = Vector3.ZERO) -> Node3D:
	var j := Node3D.new()
	j.position = pos
	j.rotation_degrees = rot_deg
	parent.add_child(j)
	return j


## A mesh in the material `key`, with the ink line (none for the small parts in `ink`, `spark` and `eye`, such as eyes).
func _part(parent: Node3D, mesh: Mesh, key: StringName, pos: Vector3 = Vector3.ZERO,
		rot_deg: Vector3 = Vector3.ZERO, scl: Vector3 = Vector3.ONE) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = pos
	mi.rotation_degrees = rot_deg
	mi.scale = scl
	mi.material_override = _mats[key]
	if key == &"ink" or key == &"spark" or key == &"eye":
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	else:
		var line := MeshInstance3D.new()
		line.mesh = mesh
		line.material_override = _outline_material(1 if mesh is BoxMesh or mesh is PrismMesh else (2 if mesh is CylinderMesh else 0))
		line.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mi.add_child(line)
	parent.add_child(mi)
	return mi


static func _ball(r: float) -> SphereMesh:
	var m := SphereMesh.new()
	m.radius = r
	m.height = r * 2.0
	m.radial_segments = 20
	m.rings = 10
	return m


static func _capsule(r: float, h: float) -> CapsuleMesh:
	var m := CapsuleMesh.new()
	m.radius = r
	m.height = h
	m.radial_segments = 16
	m.rings = 4
	return m


static func _box(size: Vector3) -> BoxMesh:
	var m := BoxMesh.new()
	m.size = size
	return m


## A cylinder along Y; a radius of 0 makes a cone.
static func _cone(bottom: float, top: float, h: float) -> CylinderMesh:
	var m := CylinderMesh.new()
	m.bottom_radius = bottom
	m.top_radius = top
	m.height = h
	m.radial_segments = 14
	m.rings = 1
	return m


## A triangle in the XY plane, `size.z` thick; `tip` 0 … 1 moves the point from left to right.
static func _prism(size: Vector3, tip: float = 0.5) -> PrismMesh:
	var m := PrismMesh.new()
	m.size = size
	m.left_to_right = tip
	return m
