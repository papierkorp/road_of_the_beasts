class_name BoardOp
extends Resource
## One typed `board_changes` operation of a skill (gdd_skills §4): ground, height or prop.
## Immediate skills apply them at cast; Surges apply them at detonation. The resolution order is
## fixed by gdd_battle §6.2 step 4 (removals, height creation, prop placement, ground), never by
## the position in a skill's list.

const GROUND := "ground"
const RAISE_MOUNTAIN := "raise_mountain"
const DESTROY_MOUNTAIN := "destroy_mountain"
const CREATE_PROP := "create_prop"
## A zone left on the squares (reshape 2026-11-13: any skill may leave one).
const CREATE_ZONE := "create_zone"

@export_enum("ground", "raise_mountain", "destroy_mountain", "create_prop", "create_zone") var op: String = GROUND
## ground: the ground type laid (level I; the same hazard levels up to its maximum).
@export var ground: StringName = &""
## ground: whether this operation may change ground on Mountain squares (gdd_battle §4.7).
@export var on_mountain: bool = false
## create_prop: the prop type from the catalogue.
@export var prop: StringName = &""
## create_zone: the zone type and how many rounds it lasts.
@export var zone: StringName = &""
@export var zone_rounds: int = 2


static func make(p_op: String, p_id := &"", p_on_mountain := false) -> BoardOp:
	var o := BoardOp.new()
	o.op = p_op
	if p_op == GROUND:
		o.ground = p_id
	elif p_op == CREATE_PROP:
		o.prop = p_id
	o.on_mountain = p_on_mountain
	return o
