class_name GroundTrigger
extends Resource
## A damage or healing trigger of a ground type (gdd_battle §2.4, §4.7): one line of its sheet (BoardSheet).

## When it acts: a moment of the shared list (Moment): enter, leave, turn_end, round_end. Leaving counts by
## the monster's own movement and by being pushed or pulled; standing still costs nothing.
@export_enum("enter", "leave", "turn_end", "round_end", "turn_start") var timing: String = Moment.ENTER
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
