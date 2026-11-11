class_name PendingSurge
extends RefCounted
## A declared, charging Surge (gdd_skills §3 Surge). Bound to board squares at cast; detonates
## at its caster's next queue entry, or at the next round start once orphaned
## (caster defeated or swapped out, gdd_battle §2.2).

## Cast order across the battle (ties among Surges of one caster).
var id: int = 0
var owner: StringName = &""
var skill: BattleSkillDef
var cells: Array[Vector2i] = []
var dir := Vector2i.ZERO
var anchor := Vector2i.ZERO
## Squares on which air-layer monsters are hit through the Mountain rule, fixed at cast
## (gdd_battle §4.7 "Air next to a Mountain").
var air_cells: Array[Vector2i] = []
var orphaned: bool = false
## Round in which it was declared (a Surge never detonates in the entry that cast it).
var cast_round: int = 0


func clone() -> PendingSurge:
	var s := PendingSurge.new()
	s.id = id
	s.owner = owner
	s.skill = skill
	s.cells = cells.duplicate()
	s.dir = dir
	s.anchor = anchor
	s.air_cells = air_cells.duplicate()
	s.orphaned = orphaned
	s.cast_round = cast_round
	return s
