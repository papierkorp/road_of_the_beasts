class_name PropAftermath
extends Resource
## One fixed, direction-independent operation of a prop and the moment it happens (`when`):
## destroyed (the aftermath of gdd_battle §4.10) · hit (it lost HP and still stands) · enter (a
## monster came onto a walkable prop: a trap; the prop is used up) · round_end (every round, while
## it stands). Build draft of 2026-11-14, not a GDD rule. Prop damage hits monsters only, never
## props (no chain reactions).

const RING8: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
	Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)]
const CARDINAL4: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
const SELF: Array[Vector2i] = [Vector2i(0, 0)]
const DESTROYED := "destroyed"
const HIT := "hit"
const ENTER := "enter"
const ROUND_END := "round_end"

@export_enum("destroyed", "hit", "enter", "round_end") var when: String = DESTROYED
## push = 1 square away from the prop, pull = 1 square toward its (then empty) square.
@export_enum("damage", "push", "pull", "spawn", "ground", "zone") var op: String = "damage"
## self = the prop's own square (a trap hits who stands on it) · block9 / block25 = the 3×3 / 5×5 block around and including it (button squares, 2026-11-15).
@export_enum("ring8", "cardinal4", "self", "block9", "block25") var pattern: String = "ring8"
## damage: amount per monster · push: distance (always 1 in the catalogue).
@export var amount: int = 1
## spawn: the child prop created on each free pattern square.
@export var spawn_prop: StringName = &""
## ground: the ground type laid on each pattern square · zone: the zone type and its rounds.
@export var ground: StringName = &""
@export var zone: StringName = &""
@export var zone_rounds: int = 2


static func make(p_op: String, p_pattern := "ring8", p_amount := 1, p_spawn := &"") -> PropAftermath:
	var a := PropAftermath.new()
	a.op = p_op
	a.pattern = p_pattern
	a.amount = p_amount
	a.spawn_prop = p_spawn
	return a


func offsets() -> Array[Vector2i]:
	if pattern == "self":
		return SELF
	if pattern == "block9" or pattern == "block25":
		var r := 1 if pattern == "block9" else 2
		var out: Array[Vector2i] = []
		for y in range(-r, r + 1):
			for x in range(-r, r + 1):
				out.append(Vector2i(x, y))
		return out
	return CARDINAL4 if pattern == "cardinal4" else RING8
