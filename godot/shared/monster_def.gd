class_name MonsterDef
extends Resource
## A species (GDD §4.5, §6.2): Kin + Aspect + its own Surge, one utility and a passive.
## Lives in res://data/monsters/*.tres.

enum Kin { BEAST, WINGED, SCALED, SWARM, SPIRIT, ANCIENT }

const STRIKE_NAMES := {
	Kin.BEAST: "Bite", Kin.WINGED: "Dive", Kin.SCALED: "Tail Sweep",
	Kin.SWARM: "Gnaw", Kin.SPIRIT: "Siphon", Kin.ANCIENT: "Slam",
}
const STRIKE_TEXT := {
	Kin.BEAST: "2 damage",
	Kin.WINGED: "1 damage, then step 1 away",
	Kin.SCALED: "1 damage, push 1 (WASD)",
	Kin.SWARM: "1 damage, props take 2",
	Kin.SPIRIT: "1 damage, target -1 init next round",
	Kin.ANCIENT: "1 to monsters / 2 to props, cracks Elevated",
}
const PASSIVE_TEXT := {
	&"momentum": "After a max-distance move, the next Surge this turn deals +1",
	&"skittish": "Steps 1 square away after taking Surge damage",
	&"immovable": "Ignores push and pull",
	&"deep_roots": "Can't be displaced on own-aspect squares",
	&"thornwalker": "Ignores Thornbed",
	&"painter": "Fired Surges also repaint adjacent squares",
	&"adaptive": "May rotate its skill shapes in battle",
	&"pack_hunter": "Strike costs 1 AP if an ally is next to the target",
	&"native_ground": "+2 instead of +1 on own-aspect squares, never -1",
	&"thick_hide": "Strikes and collisions deal 1 less",
}

@export var id: StringName
@export var display_name: String
@export var kin: Kin = Kin.BEAST
@export var aspect: Aspect.Type = Aspect.Type.FORCE
@export var hp: int = 5
@export var initiative: float = 5.0
@export var move: int = 2
@export var tpr: int = 1
@export var reach: int = 1
@export var surge: SkillDef
@export var utility: SkillDef
@export var passive: StringName
@export_multiline var blurb: String = ""


static func kin_name(k: Kin) -> String:
	return Kin.keys()[k].capitalize()


func strike_name() -> String:
	return STRIKE_NAMES[kin]


func passive_name() -> String:
	return String(passive).capitalize()


func passive_text() -> String:
	return PASSIVE_TEXT.get(passive, "")
