class_name GroundTrigger
extends Resource
## A damage or healing trigger of a ground type (gdd_battle §2.4, §4.7).

const START_OF_TURN := "start_of_turn"
const ON_ENTER := "on_enter"
const END_OF_TURN := "end_of_turn"

@export_enum("start_of_turn", "on_enter", "end_of_turn") var timing: String = ON_ENTER
@export_enum("damage", "heal") var kind: String = "damage"
## 0 = the ground's level (hazard grounds); otherwise a fixed amount.
@export var amount: int = 0


static func make(p_timing: String, p_kind := "damage", p_amount := 0) -> GroundTrigger:
	var t := GroundTrigger.new()
	t.timing = p_timing
	t.kind = p_kind
	t.amount = p_amount
	return t


func value_at(level: int) -> int:
	return amount if amount > 0 else level
