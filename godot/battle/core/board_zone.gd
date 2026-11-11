class_name BoardZone
extends RefCounted
## The zone entry of one square (gdd_battle §4.4). All squares of one cast share `gid`;
## runtime values come from the definition and the stored level, never from stored numbers.

var def: BattleZoneDef
## Cast group: every square laid by the same cast.
var gid: int = 0
var owner: StringName = &""
var level: int = 1
## Rounds left; ticks at round end.
var duration: int = 2
## Push direction fixed at cast.
var dir := Vector2i.ZERO
## Pull anchor fixed at cast.
var anchor := Vector2i.ZERO


func value(tag: String) -> int:
	var e := def.effect(tag)
	return e.value_at(level) if e != null else 0


func clone() -> BoardZone:
	var z := BoardZone.new()
	z.def = def
	z.gid = gid
	z.owner = owner
	z.level = level
	z.duration = duration
	z.dir = dir
	z.anchor = anchor
	return z
