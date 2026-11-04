class_name MonsterLook
extends RefCounted
## How a monster looks as a simple 3D body: a shape per Kin in the colour of its aspect.
## Shared by the battle view and the walkable overworld (no art yet).


static func aspect_color(a: Aspect.Type) -> Color:
	match a:
		Aspect.Type.FORCE:
			return Color(0.89, 0.35, 0.23)
		Aspect.Type.NATURE:
			return Color(0.31, 0.68, 0.50)
		Aspect.Type.DARK:
			return Color(0.54, 0.39, 0.79)
	return Color(0.6, 0.6, 0.6)


static func kin_mesh(kin: MonsterDef.Kin) -> Mesh:
	match kin:
		MonsterDef.Kin.WINGED:
			var pr := PrismMesh.new()
			pr.size = Vector3(0.7, 0.55, 0.3)
			return pr
		MonsterDef.Kin.SCALED:
			var box := BoxMesh.new()
			box.size = Vector3(0.75, 0.38, 0.38)
			return box
		MonsterDef.Kin.SWARM:
			var sp := SphereMesh.new()
			sp.radius = 0.2
			sp.height = 0.4
			return sp
		MonsterDef.Kin.SPIRIT:
			var sp2 := SphereMesh.new()
			sp2.radius = 0.3
			sp2.height = 0.6
			return sp2
		MonsterDef.Kin.ANCIENT:
			var big := BoxMesh.new()
			big.size = Vector3(0.62, 0.8, 0.62)
			return big
	var cap := CapsuleMesh.new()
	cap.radius = 0.26
	cap.height = 0.78
	return cap


## A body standing on y = 0, ready to be placed in a scene.
static func make_body(def: MonsterDef) -> Node3D:
	var root := Node3D.new()
	var mi := MeshInstance3D.new()
	mi.mesh = kin_mesh(def.kin)
	mi.position.y = 0.4
	var mat := StandardMaterial3D.new()
	mat.albedo_color = aspect_color(def.aspect)
	mat.roughness = 0.55
	if def.kin == MonsterDef.Kin.SPIRIT:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color.a = 0.75
	mi.material_override = mat
	root.add_child(mi)
	if def.kin == MonsterDef.Kin.SWARM:
		for off in [Vector3(0.22, -0.05, 0.12), Vector3(-0.2, -0.08, 0.16)]:
			var extra := MeshInstance3D.new()
			extra.mesh = mi.mesh
			extra.material_override = mat
			extra.position = off
			extra.scale = Vector3.ONE * 0.7
			mi.add_child(extra)
	return root
