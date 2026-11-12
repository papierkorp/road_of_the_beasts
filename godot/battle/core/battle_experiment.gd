class_name BattleExperiment
extends RefCounted
## Open test switches of the battle (temp_todo T38). The whole build is an experiment, so they
## apply to every battle; the draft screen and tools/sim.gd set them. Everything else that was
## tried and kept is a rule of the build by now.

## Squares a Strike or Surge push / pull moves (99 = slide until something stops it).
static var push_steps := 1
## A Spirit Strike trades squares with one struck monster (every Strike already pushes).
static var kin_push := false
## Turns the free rotation of placed shapes off again (to compare).
static var no_rotation := false
## AP of the universal Step and of the Jab shape (0 = the rule: Step 1, Jab 2).
static var step_ap := 0
## AP of every slotted movement skill (0 = as authored, 1).
static var move_ap := 0
static var jab_ap := 0
## The AI values closing in more and standing under its own support effects less.
static var ai_aggressive := false
## > 0: late-round pressure deals no damage; instead the outermost ring of the board breaks away
## every N rounds (down to 3×3) and monsters on it are set on the nearest free inner square.
static var soft_pressure := 0


static func reset() -> void:
	push_steps = 1
	kin_push = false
	no_rotation = false
	step_ap = 0
	move_ap = 0
	jab_ap = 0
	ai_aggressive = false
	soft_pressure = 0


## Squares next to `cells` that are not part of them (may lie off the board).
static func ring(cells: Array[Vector2i], diagonal: bool) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for c in cells:
		for dx in [-1, 0, 1]:
			for dy in [-1, 0, 1]:
				if (dx == 0 and dy == 0) or (not diagonal and dx != 0 and dy != 0):
					continue
				var q := c + Vector2i(dx, dy)
				if not cells.has(q) and not out.has(q):
					out.append(q)
	return out
