class_name MonsterDef
extends Resource
## A species with its kit, in one file: res://data/monsters/<id>.tres (gdd_monsters §1.1, §4.1).
## Everything here is test data: no kit or learn list is approved (temp_todo T10–T12).
## The stats are the Core Formation High reference individual of gdd_monsters §4.1.

enum Kin { BEAST, WINGED, SCALED, SWARM, SPIRIT, ANCIENT }

const STRIKE_NAMES := {
	Kin.BEAST: "Bite", Kin.WINGED: "Dive", Kin.SCALED: "Tail Sweep",
	Kin.SWARM: "Gnaw", Kin.SPIRIT: "Siphon", Kin.ANCIENT: "Slam",
}

@export var id: StringName
@export var display_name: String
## ContentStatus: a test-only or simulation-only monster is never offered by the game.
@export_enum("approved", "draft", "experiment", "test", "simulation", "archived") var content_status: String = ContentStatus.DRAFT
@export var kin: Kin = Kin.BEAST
## Look and overworld material family only; no battle rule reads it (aspects are removed, T01).
@export var aspect: Aspect.Type = Aspect.Type.FORCE

@export_group("Reference individual (gdd_monsters §4.1)")
## The stat shape (frame, gdd_monsters §2.2) the reference stats below were built with: an
## authoring label from the §4.1 table, 0 = not stated. The values follow StatShape.Id; no
## rule reads it (a shape belongs to the individual, not to the species).
@export_enum("None", "Glass cannon", "Anvil", "Skirmisher", "Berserker", "Balanced", "Fragile") var reference_shape: int = 0
@export var hp: int = 5
@export var initiative: float = 5.0
@export var move: int = 2
@export var tpr: int = 1
@export var reach: int = 2
@export var ap: int = 2

@export_group("Kit")
## Up to 4 slots, active or passive, at least one active (gdd_skills §1). Step needs no slot.
@export var skills: Array[BattleSkillDef] = []

@export_multiline var blurb: String = ""
@export_multiline var notes: String = ""


static func kin_name(k: Kin) -> String:
	return Kin.keys()[k].capitalize()


func strike_name() -> String:
	return STRIKE_NAMES[kin]


## "Skill · Skill · Skill" for datasheets.
func kit_text() -> String:
	var names: PackedStringArray = []
	for s in skills:
		if s != null:
			names.append(s.display_name)
	return " · ".join(names)
