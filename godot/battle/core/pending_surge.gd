class_name PendingSurge
extends RefCounted
## A declared Surge on board squares (two types, user decision 2026-11-12, temp_todo T38):
## a TIMED Surge is cast on any squares and detonates after a number of finished turns of any
## monster; a TRAP needs monster-free squares, never fires by itself and never lapses: it
## detonates as soon as a ground monster stands on one of its squares or, unless its skill
## says "monsters", a prop or Mountain appears on one. One marker per square for both types.
## `orphaned` only records that its caster is gone.

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
## Kit slot it was cast from.
var slot: int = -1
## Timed Surges: finished turns left until it detonates (-1 = a trap), and whether the cast
## turn is still running.
var turns_left: int = -1
var fresh: bool = false
## Squares that already held a prop or a Mountain at cast (they do not spring it).
var blocked_at_cast: Array[Vector2i] = []
## Squares orthogonally next to its squares, kept for the AI.
var ring: Array[Vector2i] = []


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
	s.slot = slot
	s.turns_left = turns_left
	s.fresh = fresh
	s.blocked_at_cast = blocked_at_cast.duplicate()
	s.ring = ring.duplicate()
	return s
