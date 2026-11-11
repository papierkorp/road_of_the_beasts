class_name BoardProp
extends RefCounted
## A prop instance on the board. At 0 HP it stays and keeps blocking until the removal step
## of the running payload (gdd_battle §6.2 step 4a).

var uid: int = 0
var def: PropDef
var hp: int = 1
var pos := Vector2i.ZERO


func _init(p_uid: int = 0, p_def: PropDef = null, p_pos: Vector2i = Vector2i.ZERO) -> void:
	uid = p_uid
	def = p_def
	pos = p_pos
	hp = p_def.hp if p_def != null else 1


func clone() -> BoardProp:
	var p := BoardProp.new(uid, def, pos)
	p.hp = hp
	return p
