class_name PropAftermath
extends Resource
## One fixed, direction-independent operation of a prop and the moment it happens (`when`): one line of its
## sheet (BoardSheet).
## destroyed (the aftermath of gdd_battle §4.10) · hit (it lost HP and still stands) · enter (a
## monster came onto a walkable prop: a trap; the prop is used up) · round_end (every round, while
## it stands). Build draft of 2026-11-14, not a GDD rule. Prop damage hits monsters only, never
## props (no chain reactions).

## When it acts: a moment of the shared list (Moment).
@export_enum("destroyed", "hit", "enter", "round_end") var when: String = Moment.DESTROYED
## push = 1 square away from the prop, pull = 1 square toward its (then empty) square.
@export_enum("damage", "push", "pull", "spawn", "ground", "zone") var op: String = "damage"
## Where it acts: a shape of the shared vocabulary around the prop (BattleShapes; user decision 2026-11-15):
## self = the prop's own square (a trap hits who stands on it) · whirl = the 4 neighbours · cross = the 4
## diagonals · storm = all 8 around · block = the 3×3 block around and including it. `extension` extends it
## (whirl 1 = two squares on every arm, block 1 = 5×5). A prop has no direction, so no Jab, Pincer or Arc.
@export_enum("self", "whirl", "cross", "storm", "block") var shape: String = "storm"
@export var extension: int = 0
## damage: amount per monster · push: distance (always 1 in the catalogue).
@export var amount: int = 1
## spawn: the child prop created on each free pattern square.
@export var spawn_prop: StringName = &""
## ground: the ground type laid on each pattern square · zone: the zone type and its rounds.
@export var ground: StringName = &""
@export var zone: StringName = &""
@export var zone_rounds: int = 2


static func make(p_op: String, p_shape := "storm", p_amount := 1, p_spawn := &"") -> PropAftermath:
	var a := PropAftermath.new()
	a.op = p_op
	a.shape = p_shape
	a.amount = p_amount
	a.spawn_prop = p_spawn
	return a


func offsets() -> Array[Vector2i]:
	return BattleShapes.offsets(StringName(shape), Vector2i.ZERO, extension)
