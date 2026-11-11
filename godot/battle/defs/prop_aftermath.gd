class_name PropAftermath
extends Resource
## One fixed, direction-independent operation a prop performs when it is destroyed
## (gdd_battle §4.10). Aftermath damage hits monsters only, never props (no chain reactions).

const RING8: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
	Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)]
const CARDINAL4: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]

@export_enum("damage", "push", "spawn") var op: String = "damage"
@export_enum("ring8", "cardinal4") var pattern: String = "ring8"
## damage: amount per monster · push: distance (always 1 in the catalogue).
@export var amount: int = 1
## spawn: the child prop created on each free pattern square.
@export var spawn_prop: StringName = &""


static func make(p_op: String, p_pattern := "ring8", p_amount := 1, p_spawn := &"") -> PropAftermath:
	var a := PropAftermath.new()
	a.op = p_op
	a.pattern = p_pattern
	a.amount = p_amount
	a.spawn_prop = p_spawn
	return a


func offsets() -> Array[Vector2i]:
	return CARDINAL4 if pattern == "cardinal4" else RING8
