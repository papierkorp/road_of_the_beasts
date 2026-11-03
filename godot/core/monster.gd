class_name Monster
extends RefCounted
## Runtime state of one monster in a battle (GDD §4.1-4.2).

var id: StringName
var display_name: String
var aspect: Aspect.Type
var pos := Vector2i.ZERO
var hp: int
var max_hp: int
var initiative: float
var base_move: int = 2
var skills: Array[SkillDef] = []
var cooldowns := {}                 # skill id -> turns left


func _init(p_id: StringName, p_name: String, p_aspect: Aspect.Type, p_pos: Vector2i,
		p_hp: int, p_init: float, p_move: int, p_skills: Array[SkillDef]) -> void:
	id = p_id
	display_name = p_name
	aspect = p_aspect
	pos = p_pos
	hp = p_hp
	max_hp = p_hp
	initiative = p_init
	base_move = p_move
	skills = p_skills


func is_alive() -> bool:
	return hp > 0


func skill_by_id(skill_id: StringName) -> SkillDef:
	for s in skills:
		if s.id == skill_id:
			return s
	return null
