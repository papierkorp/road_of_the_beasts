class_name BattleKitDef
extends Resource
## TEST DATA: the battle kit and reference sheet of one species, keyed by the species id of
## the shared MonsterDef. Lives in res://data/battle/kits/<species_id>.tres.
##
## The GDDs hold no approved kits or learn lists (T10–T12). These kits rebuild the prior-draft
## assignments of gdd_skills §10 from decided mechanics only; the reference stats are the
## Core Formation High individuals of gdd_monsters §4.1. Neither is balance approval.

@export var species_id: StringName
## Up to 4 slots, active or passive, at least one active (gdd_skills §1). Step needs no slot.
@export var skills: Array[BattleSkillDef] = []
## Legacy utility ids of the overworld's species data that map onto a slot of this kit:
## the slot index of the Surge and of the utility (-1 = none), used by the unit-sheet adapter.
@export var surge_slot: int = -1
@export var utility_slot: int = -1

@export_group("Reference individual (gdd_monsters §4.1)")
@export var hp: int = 5
@export var initiative: float = 5.0
@export var movement: int = 2
@export var tpr: int = 1
@export var reach: int = 2
@export var ap: int = 2
@export_multiline var notes: String = ""
