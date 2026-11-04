class_name Monster
extends RefCounted
## Runtime state of one monster in a battle.

var id: StringName              # unique in this battle, e.g. &"p0_blaze_tiger"
var def: MonsterDef
var side: int                   # 0 = player, 1 = enemy
var pos := Vector2i.ZERO
var team_index := -1            # position in its team (BattleRequest order)
var hp: int
var max_hp: int

var init_penalty_next := 0      # Spirit Siphon
var momentum_bonus := 0         # passive Momentum


## `p_hp` < 0 starts at full HP; otherwise the current HP of the individual (never above max).
func _init(p_id: StringName, p_def: MonsterDef, p_side: int, p_pos: Vector2i, p_hp := -1) -> void:
	id = p_id
	def = p_def
	side = p_side
	pos = p_pos
	max_hp = p_def.hp
	hp = p_def.hp if p_hp < 0 else clampi(p_hp, 1, p_def.hp)


func is_alive() -> bool:
	return hp > 0


func display_name() -> String:
	return def.display_name


func aspect() -> Aspect.Type:
	return def.aspect


func kin() -> MonsterDef.Kin:
	return def.kin


func has_passive(p: StringName) -> bool:
	return def.passive == p


func skills() -> Array[SkillDef]:
	var out: Array[SkillDef] = []
	if def.surge != null:
		out.append(def.surge)
	if def.utility != null:
		out.append(def.utility)
	return out


func skill_by_id(skill_id: StringName) -> SkillDef:
	for s in skills():
		if s.id == skill_id:
			return s
	return null


## Spirit Kin and the Phasing passive move through props.
func phases() -> bool:
	return def.kin == MonsterDef.Kin.SPIRIT or def.passive == &"phasing"
