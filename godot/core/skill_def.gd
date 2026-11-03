class_name SkillDef
extends Resource
## Skill schema (GDD §9.7). Lives in res://data/skills/*.tres.

enum Kind { SURGE, ZONE, GROUND, HEIGHT, PROP }

@export var id: StringName
@export var display_name: String
@export var kind: Kind = Kind.ZONE
@export var aspect: Aspect.Type = Aspect.Type.NONE
@export var zone: ZoneDef                 ## kind ZONE only
@export var shapes: Array[StringName] = []
@export var range: int = 3
@export var cooldown: int = 0
@export var value: int = 0                ## kind SURGE: base damage per square


func placement() -> Board.Placement:
	match kind:
		Kind.SURGE:
			return Board.Placement.SURGE
		Kind.PROP:
			return Board.Placement.PROP
		_:
			return Board.Placement.AREA


func orientations() -> Array[Dictionary]:
	return Shapes.orientations(shapes)
