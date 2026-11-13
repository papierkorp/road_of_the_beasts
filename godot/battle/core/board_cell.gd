class_name BoardCell
extends RefCounted
## One square of the stack (gdd_battle §4.3): ground + height, one object per layer, one zone,
## one pending Surge marker. Ground is permanent until something changes it.

var pos := Vector2i.ZERO
var ground: StringName = GroundDef.PLAIN
## Hazard level (1-2); other ground stays at 1.
var level: int = 1
## Test switch BattleExperiment.ground_rounds: last round this ground lasts (0 = no end).
var ground_until: int = 0
## 0 = low, 1 = Mountain (the only height state; combines with any ground type).
var height: int = 0
## Ground-layer object (a both-layer prop is referenced here and in `air_prop`).
var prop: BoardProp = null
var air_prop: BoardProp = null
var zone: BoardZone = null
## Id of the pending Surge claiming this square, -1 = none.
var surge: int = -1
## Dragon Vein (gdd_battle §4.2): the side whose monster touched the square last, -1 = nobody yet.
var owner_side: int = -1


func _init(p: Vector2i = Vector2i.ZERO) -> void:
	pos = p


func is_mountain() -> bool:
	return height > 0


func clone(props_seen: Dictionary) -> BoardCell:
	var c := BoardCell.new(pos)
	c.ground = ground
	c.level = level
	c.ground_until = ground_until
	c.height = height
	c.surge = surge
	c.owner_side = owner_side
	if zone != null:
		c.zone = zone.clone()
	if prop != null:
		if not props_seen.has(prop.uid):
			props_seen[prop.uid] = prop.clone()
		c.prop = props_seen[prop.uid]
	if air_prop != null:
		if not props_seen.has(air_prop.uid):
			props_seen[air_prop.uid] = air_prop.clone()
		c.air_prop = props_seen[air_prop.uid]
	return c
