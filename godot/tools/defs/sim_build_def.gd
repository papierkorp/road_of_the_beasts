class_name SimBuildDef
extends Resource
## A test build for simulation runs: one stat allocation and up to four priced skill slots.
## Lives in res://tools/data/builds/<id>.tres; the file name is the id.
##
## A build is a test fixture, never roster content: it claims no species access and no
## progression reachability. res://tools/lib/sim_builds.gd checks its stat spend, stage
## ceilings and slot prices and turns it into the unit sheet a battle resolves.

@export var kin: MonsterDef.Kin = MonsterDef.Kin.BEAST
@export_enum("qi", "foundation", "core", "soul") var stage: String = "core"
@export_enum("lower", "middle", "high") var subtier: String = "high"
@export_multiline var note: String = ""

@export_group("Stats")
@export var hp: int = 5
@export var initiative: float = 5.0
@export var movement: int = 2
@export var reach: int = 2
@export var tpr: int = 1
@export var ap: int = 2

@export_group("Kit")
## One to four slots in kit order.
@export var slots: Array[SimBuildSlot] = []
