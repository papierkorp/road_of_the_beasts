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
## layer) deals 1 damage to the enemy nearest to it; ties: more HP, then more pace, then the
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
## true (GDD rule of the reshape of 2026-11-13, kept by the user after S028): a Dragon Vein belongs to
## the side that touched it last and deals its damage for that side whether or not a monster stands
## on it. false = only while a monster stands on it at the round end (measured in S028).
static var vein_touch := true
## Late-round pressure: "idle" (build rule) only at the end of a round in which nobody holds a
## Wellspring · "always" as before 2026-11-13 · "none" never.
static var pressure_mode := "idle"
## Build rule since 2026-11-14 (user decision): every slotted skill at most `usage_limit` times per
## turn of its monster (1 unless the skill says more; the universal Step is not slotted). false = no limit.
static var once_per_turn := true
## Build default since 2026-11-14 (S025, not a GDD rule): a push or pull zone does not move its
## occupants when it is cast, only at the end of their turn. true = it also moves them at cast.
static var zone_cast_push := false
## false: a monster pushed or pulled into another monster takes the collision damage alone;
## the blocking monster takes none.
static var collision_both := true
## Charged Dragon Veins (draft, S026): every vein is charged at the start of a round. The first
## monster that touches it (walks onto or across it, is pushed or pulled onto it), or the monster
## standing on it at the end of its own turn, discharges it: 1 damage to the enemy nearest to the
## square. Then it is empty until the next round. No ownership and no vein damage at the round end.
static var vein_charge := false
## With vein_charge: the discharge deals no damage at once. The side that touched the vein first in
## the round has won it for that round, wherever its monster stands afterwards, and the vein deals
## its 1 damage for that side at the end of the round (user idea 2026-11-14, S027).
static var vein_charge_late := false
## The universal Step walks up to the monster's Movement for its AP (like Run), instead of 1 square.
static var step_full_move := false
## Stamina (rule since 2026-11-15, user decision; S028/S029): the Movement stat is the size of a Stamina
## pool a monster spends in battle. A slotted movement skill costs Stamina for every square it enters
## (what the ground costs: Plain 1, Rubble 2; a path over other squares 1 per square of the distance)
## and reaches at most the range the skill names (`move_range`, 3 unless authored) and never further
## than the Stamina left. At the end of a round every monster recovers the whole number of its Pace,
## at least 1, up to its pool. The universal Step stays 1 AP for 1 square and costs no Stamina.
## false = the rule before: a movement skill covers the Movement stat, no pool (to compare).
static var stamina := true
## 0 = the rule (recovery by Pace); N > 0 = every monster recovers N per round (to compare, S029).
static var stamina_regen := 0
## With stamina: a movement skill also costs its AP (false = Stamina only).
static var stamina_ap := true
## Board switch: mirrored prop pairs a board starts with (-1 = as the layout or its seed says, 0 = none).
static var map_props := -1
## Board switch (user request 2026-11-15): side length of the board, for every mode (0 = the size of the mode;
## the draft offers 8 and 9; a size not larger than the mode's is ignored). Start squares, the fixed test
## layout and the number of seeded prop pairs follow the size (BattleBoards.mode_data).
static var board_size := 0
## Board switch (user idea, 2026-11-15): mirrored pairs of "button" squares the board starts with: walkable
## rune props without damage that act on the board when a monster collects them (0 = none).
static var map_buttons := 0
## Idea of 2026-11-16 (to try and to measure, no rule): a movement skill costs this much Stamina for its use,
## on top of the Stamina for every square. 0 = the rule: squares only.
static var stamina_base := 0
## Idea of 2026-11-16 (no rule): a solid prop that is created on or pushed onto a trap removes the trap
## without springing it and takes its square. false = the build rule: a trap square takes no other prop.
static var trap_defuse := false
## Idea to try (user, 2026-11-17; no rule): Stamina pays for what the body does. A movement skill pays the
## squares it enters as before, a Strike pays Stamina beside its AP (BattleSkillDef.stamina_price: 1, or 2
## for an extended shape and a Cross); skills that place something and buffs cost AP only. Every monster
## has the Basic Jab (1 AP, 1 damage, no Stamina) as an action beside Step (Battle.BASIC_SLOT).
static var skill_stamina := false
## Idea to try (user, 2026-11-17; no rule): Strikes deal no damage to monsters (props still take it); shape
## and push stay as the card says. Damage comes from ground, collisions, Dragon Veins, props and the Basic
## Jab, which every monster has with this switch too. (Reach 3 and pulling Strikes were tried and dropped.)
static var strike_push_only := false


static func has_basic_jab() -> bool:
	return skill_stamina or strike_push_only
## Kit switch of the multiplayer mode (user request 2026-11-16): every monster of a battle plays a random
## kit by a kit template (KitDraw: so many Strikes, movement, zone, ground and prop skills), drawn from the
## skills of the game. Its own kit is not used.
static var random_kits := false
## Kit switch: the random kits are made of skills generated for this battle (SkillGen.draw_kind) instead
## of the game's own. Implies random kits.
static var fresh_skills := false
## Monster switch (user request 2026-11-17): every monster of a battle has random stats and a random Kin,
## bought with the monster calculation for the points of the multiplayer mode (MonsterDraw). The species
## is only the look. Implies random kits. Drawn by `kit_seed`.
static var random_monsters := false
## Seed of the kit draw; the draft screen draws a new one for every battle.
static var kit_seed := 0
## The opponent's AI prefers a skill it has not used in this battle, as long as the use costs it nothing
## (AiBrain.TRY_BONUS), so every skill of a kit gets played. On by default (user, 2026-11-16).
static var ai_try_all := true
## The opponent fights for the Dragon Veins (user, 2026-11-16): it walks to veins it does not own, keeps
## enemies away from its own (walls, a solid prop on the vein) and breaks what keeps it from an enemy vein
## (AiBrain._vein_score). In the game it also looks one action further (AiBrain.decide). Off = the AI before.
static var ai_veins := true


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
	once_per_turn = true
	zone_cast_push = false
	collision_both = true
	vein_charge = false
	vein_charge_late = false
	step_full_move = false
	stamina = true
	stamina_regen = 0
	stamina_ap = true
	map_props = -1
	map_buttons = 0
	board_size = 0
	stamina_base = 0
	trap_defuse = false
	skill_stamina = false
	strike_push_only = false
	random_kits = false
	fresh_skills = false
	random_monsters = false
	kit_seed = 0
	ai_try_all = true
	ai_veins = true


## The Dragon Vein squares of a board of this size (`wells` of them; none on boards smaller than 7×7).
## Odd boards: evenly spread on the centre row. Even boards have no centre row (draft of 2026-11-15, for
## the 8×8 board switch): mirrored pairs on the two centre rows, so `wells` rounds up to an even number
## (3 → 4 veins); each side has the same number on the row nearer to it.
static func well_squares(size: int) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	if wells <= 0 or size < 7:
		return out
	if size % 2 == 0:
		var pairs := (wells + 1) >> 1
		for i in pairs:
			var x := (size >> 1) - 2 if pairs == 1 else clampi(roundi((i + 0.5) * size / pairs - 0.5) - 1, 0, size - 1)
			for q: Vector2i in [Vector2i(x, size >> 1), Vector2i(size - 1 - x, (size >> 1) - 1)]:
				if not out.has(q):
					out.append(q)
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
