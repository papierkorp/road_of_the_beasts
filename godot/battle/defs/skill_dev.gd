class_name SkillDev
extends RefCounted
## The development of a skill slot (docs/skills.md §8): a slot has a level of 1 to 3, and each level above the
## first adds one option from the list of the skill's kind. The options are derived from the card, not written
## per skill: a skill is offered only what its card can take. `developed` returns the skill a monster brings into
## a battle: a copy with the chosen options applied; the record of the skill is never changed.

const MAX_LEVEL := 3
## The ground a Strike leaves when it takes that option (a build choice: the rules name none yet).
const STRIKE_GROUND := &"thornbed"

const STRIKE_AREA := "strike_area"
const STRIKE_PROPS := "strike_props"
const STRIKE_GROUND_OPT := "strike_ground"
const MOVE_RANGE := "move_range"
const MOVE_PROPS := "move_props"
const MOVE_MONSTERS := "move_monsters"
const MOVE_GROUND := "move_ground"
const MOVE_PUSH := "move_push"
const LAY_AREA := "lay_area"
const LAY_ROUNDS := "lay_rounds"
const BUFF_ROUNDS := "buff_rounds"
const BUFF_VALUE := "buff_value"

## id -> [vocabulary of docs/skills.md §8, what it does]
const TEXT := {
	STRIKE_AREA: ["Area", "its shape reaches one square further"],
	STRIKE_PROPS: ["Addition", "it also damages the props in its shape"],
	STRIKE_GROUND_OPT: ["Addition", "it leaves Thornbed on the struck squares"],
	MOVE_RANGE: ["Area", "1 square further"],
	MOVE_PROPS: ["Condition", "it passes over props"],
	MOVE_MONSTERS: ["Condition", "it passes over monsters"],
	MOVE_GROUND: ["Condition", "ground on its way does not act on it: only the landing square counts"],
	MOVE_PUSH: ["Addition", "it pushes the monster ahead on landing"],
	LAY_AREA: ["Area", "1 square more"],
	LAY_ROUNDS: ["Duration", "what it lays lasts 1 round longer"],
	BUFF_ROUNDS: ["Duration", "1 round longer"],
	BUFF_VALUE: ["Number", "its value +1"],
}


static func option_name(id: String) -> String:
	var t: Array = TEXT.get(id, ["", id])
	return "%s: %s" % [t[0], t[1]]


## The options this skill can take, in a fixed order. A skill that already has what an option gives is not
## offered it; a passive has none.
static func options(s: BattleSkillDef) -> Array[String]:
	var out: Array[String] = []
	if s == null:
		return out
	match s.kind:
		BattleSkillDef.STRIKE:
			if s.shape_extension == 0:
				out.append(STRIKE_AREA)
			if not s.hits_props():
				out.append(STRIKE_PROPS)
			if s.board_ops.is_empty():
				out.append(STRIKE_GROUND_OPT)
		BattleSkillDef.MOVE:
			out.append(MOVE_RANGE)
			if s.blocked_by_objects:
				out.append(MOVE_PROPS)
			if s.blocked_by_monsters:
				out.append(MOVE_MONSTERS)
			if s.move_path == "walk":
				out.append(MOVE_GROUND)
			if s.impact_push == "none":
				out.append(MOVE_PUSH)
		BattleSkillDef.ZONE, BattleSkillDef.GROUND:
			out.append(LAY_AREA)
			out.append(LAY_ROUNDS)
		BattleSkillDef.BUFF:
			out.append(BUFF_ROUNDS)
			if not s.buff_effects.is_empty():
				out.append(BUFF_VALUE)
	return out


## The options of `s` that are still open when `taken` are chosen: each option once.
static func open_options(s: BattleSkillDef, taken: Array) -> Array[String]:
	var out: Array[String] = []
	for o in options(s):
		if not taken.has(o):
			out.append(o)
	return out


## The skill with its options applied: a copy when there is any option, else the record itself.
static func developed(s: BattleSkillDef, taken: Array) -> BattleSkillDef:
	if s == null or taken.is_empty():
		return s
	var legal := options(s)
	var d: BattleSkillDef = s.duplicate()
	var names: PackedStringArray = []
	for o in taken:
		if not legal.has(o):
			continue
		names.append(String(TEXT[o][1]))
		match String(o):
			STRIKE_AREA:
				d.shape = String(d.shape_id())
				d.shape_extension += 1
			STRIKE_PROPS:
				d.strike_props = 1
			STRIKE_GROUND_OPT:
				var ops: Array[BoardOp] = []
				ops.assign(d.board_ops)
				ops.append(BoardOp.make(BoardOp.GROUND, STRIKE_GROUND))
				d.board_ops = ops
			MOVE_RANGE:
				if d.fixed_distance > 0:
					d.fixed_distance += 1
				else:
					d.move_range = (d.move_range if d.move_range > 0 else 3) + 1
			MOVE_PROPS:
				d.blocked_by_objects = false
			MOVE_MONSTERS:
				d.blocked_by_monsters = false
			MOVE_GROUND:
				d.move_path = "free"
				d.ground_costs = false
			MOVE_PUSH:
				d.impact_push = "ahead"
			LAY_AREA:
				if d.is_free_shape():
					var cells: Array[Vector2i] = []
					cells.assign(d.footprint)
					cells.append(_next_square(cells))
					d.footprint = cells
				else:
					d.shape_extension += 1
			LAY_ROUNDS:
				d.lays_longer += 1
				if d.kind == BattleSkillDef.ZONE:
					d.duration += 1
			BUFF_ROUNDS:
				d.duration += 1
			BUFF_VALUE:
				var effects: Array[FieldEffect] = []
				for e in d.buff_effects:
					var stronger: FieldEffect = e.duplicate()
					stronger.base += 1
					stronger.cap += 1
					effects.append(stronger)
				d.buff_effects = effects
	if not names.is_empty():
		d.description = "%s%sDeveloped: %s." % [d.description, " " if d.description != "" else "", "; ".join(names)]
	return d


## One more square for a free shape: the first free square next to the last one, so the shape stays connected.
static func _next_square(cells: Array[Vector2i]) -> Vector2i:
	if cells.is_empty():
		return Vector2i.ZERO
	for i in range(cells.size() - 1, -1, -1):
		for step: Vector2i in [Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(0, -1)]:
			if not cells.has(cells[i] + step):
				return cells[i] + step
	return cells[-1] + Vector2i(1, 0)
