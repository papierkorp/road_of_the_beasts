class_name BattleExperiment
extends RefCounted
## Open test switches of the battle (temp_todo T38). The whole build is an experiment, so they
## apply to every battle; the draft screen and tools/sim.gd set them. Three of them carry build
## rules since 2026-11-12 (user decision after simulation S011) and keep their switch only to
## compare: `ground_rounds` = 2, `trap_cap` = 1 and `ai_hunt` = true.

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
## The AI does not end a turn with AP left while no enemy is next to it: without a better action
## it walks toward the nearest enemy (not a rule; off = the waiting AI, bot `wait` of tools/sim.gd).
static var ai_hunt := true
## Skill kind the AI of side 0 / side 1 never uses ("" = none): `--no-kind-a` / `--no-kind-b` of
## tools/sim.gd, to measure what a kind is worth to the side that keeps it.
static var ai_no_kind: Array[String] = ["", ""]
## The AI counts the Strike damage enemies can bring to each of its monsters before that monster's
## next turn and avoids squares where that is lethal (bot `careful` of tools/sim.gd; not a rule).
static var ai_careful := false
## With ai_hunt: only the side that is not ahead in total HP walks up (bot `chase`): the side
## that would win by waiting for late-round pressure waits, the other one has to come.
static var ai_hunt_behind := false
## > 0: late-round pressure deals no damage; instead the outermost ring of the board breaks away
## every N rounds (down to 3×3) and monsters on it are set on the nearest free inner square.
static var soft_pressure := 0
## Build rule (2): ground laid during the battle (skill, Surge residue, prop aftermath) turns back into
## Plain at the end of the N-th round, counting the round it was laid or levelled in. Ground of
## the starting board, Rubble of a destroyed Mountain and Voidscar stay. 0 = no clock.
static var ground_rounds := 2
## > 0: a trap nobody sprang lapses at the end of the N-th round, counting the round it was set in.
static var trap_rounds := 0
## Build rule (1): a monster holds at most N traps per trap skill; setting one more removes its
## oldest trap of that skill without effect (the trap moves). 0 = no limit.
static var trap_cap := 1
## Shield zone skills cannot be used (kits keep the slot; to try battles without kit protection).
static var no_shield_zones := false
## Every monster starts on the back row of its side (3v3: 6 instead of 4 squares between the lines).
static var start_back := false
## Build rule since 2026-11-13 (user decision, T39; gdd_battle §4.2): that many Wellspring squares lie on
## the centre row (odd boards of 7×7 and larger; 0 = none). At the end of a round every Wellspring a monster stands on (either
## layer) deals 1 damage to the enemy nearest to it; ties: more HP, then more initiative, then the
## holder chooses (the code takes roster order as a stand-in). No prop or Mountain on a Wellspring.
static var wells := 3
## Build rule: at the end of a round a monster with two or more enemies on its eight neighbour
## squares takes 1 damage; resolved together with the Wellsprings. false = off, to compare.
static var flank := true
## First round in which TurnsPerRound counts. Build rule 2: in round 1 every monster has one turn.
static var tpr_from_round := 2
## A monster may postpone its turn once per round, before it has done anything: its queue entry
## moves to the end of the round's queue (action `delay`; draft T39).
static var delay_turn := false
## With delay_turn: monsters that postponed act in reverse order of the queue (the one that stood
## first acts last), so the fastest monster has the last word of a round.
static var delay_reverse := false
## With delay_turn (user idea 2026-11-13): postponing is allowed in round 1 only, and only to monsters
## with TurnsPerRound 2+ (their extra turn does not count yet) and to the first monster of the queue.
static var delay_first_round := false
## No damage of any kind before this round (1 = off; 2 = round 1 is for positioning only).
static var damage_from_round := 1
## A charging timed Surge blocks its squares for every movement including Step: nothing may enter
## or land on them (monsters standing there may leave; pushes are not blocked).
static var surge_wall := false
## A timed Surge without ground of its own leaves this ground type on its squares when it detonates
## ("" = nothing); it fades like other ground laid in battle (`ground_rounds`).
static var surge_ground := &""
## A timed Surge detonates at the start of its caster's next turn instead of counting turns of any
## monster (the rule before 2026-11-12); a Surge whose caster is gone detonates at the next round start.
static var surge_at_caster := false
## A timed Surge that is due waits until every monster standing on its squares has finished a turn
## since the cast (draft T39: nobody is hit by a Surge it had no turn to leave).
static var surge_fair := true
## Rule since the reshape of 2026-11-13: a Dragon Vein belongs to the side that touched it last and
## deals its damage for that side whether or not a monster stands on it. false = only while held.
static var vein_touch := true
## Late-round pressure: "idle" (build rule) only at the end of a round in which nobody holds a
## Wellspring · "always" as before 2026-11-13 · "none" never.
static var pressure_mode := "idle"


static func reset() -> void:
	push_steps = 1
	kin_push = false
	no_rotation = false
	step_ap = 0
	move_ap = 0
	jab_ap = 0
	ai_aggressive = false
	ai_hunt = true
	ai_hunt_behind = false
	ai_careful = false
	ai_no_kind = ["", ""]
	soft_pressure = 0
	ground_rounds = 2
	trap_rounds = 0
	start_back = false
	no_shield_zones = false
	trap_cap = 1
	wells = 3
	flank = true
	tpr_from_round = 2
	pressure_mode = "idle"
	delay_turn = false
	delay_reverse = false
	delay_first_round = false
	damage_from_round = 1
	surge_wall = false
	surge_ground = &""
	surge_at_caster = false
	surge_fair = true
	vein_touch = true


## The Wellspring squares of a board of this size: evenly spread on the centre row.
static func well_squares(size: int) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	if wells <= 0 or size % 2 == 0 or size < 7:
		return out
	for i in wells:
		var p := Vector2i(clampi(roundi((i + 0.5) * size / wells - 0.5), 0, size - 1), size >> 1)
		if not out.has(p):
			out.append(p)
	return out


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
