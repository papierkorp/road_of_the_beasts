class_name GroundDef
extends Resource
## A ground type (gdd_battle §4.7). Lives in res://data/grounds/<id>.tres.
##
## Everything a ground does is composed from reusable elements: a movement cost, damage/heal
## triggers (GroundTrigger) and while-standing effects from the shared vocabulary (FieldEffect).
## A new ground type that only recombines these needs a new file and no code.

const PLAIN := &"plain"
const RUBBLE := &"rubble"

@export var id: StringName
@export var display_name: String
## Internal calculation cost in construction points (gdd_skills §5 working drafts): an
## authoring note, not a rule, not a player value and not settled. Per created cell (permanent-state package).
## -1 = not calculated.
@export var internal_calc_cost: float = -1.0
@export_enum("neutral", "hazard", "blessed") var group: String = "neutral"
## Movement points to enter (movement profiles with ground costs only; gdd_skills §3).
@export var move_cost: int = 1
## Hazard grounds level up to II when the same type is laid again; everything else stays at 1.
@export var max_level: int = 1
## Nothing changes this ground (Voidscar).
@export var immutable: bool = false
@export var triggers: Array[GroundTrigger] = []
## Effects for whoever stands on it (Hearth: quicken 1, Umbra: extend 1, Hallowed: shield 1).
@export var effects: Array[FieldEffect] = []
@export var color: Color = Color(0.42, 0.44, 0.4)
@export_multiline var description: String = ""


func triggers_at(timing: String) -> Array[GroundTrigger]:
	var out: Array[GroundTrigger] = []
	for t in triggers:
		if t.timing == timing:
			out.append(t)
	return out


func is_hazard() -> bool:
	return group == "hazard"


func label(level := 1) -> String:
	return display_name + (" " + ["I", "II", "III"][clampi(level, 1, 3) - 1] if max_level > 1 else "")
