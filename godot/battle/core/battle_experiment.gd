class_name BattleExperiment
extends RefCounted
## Open test switches of the battle (temp_todo T38). The whole build is an experiment, so they
## apply to every battle; the draft screen and tools/sim.gd set them. Two of them carry build
## rules since 2026-11-12 (user decision after simulation S011) and keep their switch only to
## compare: `ground_rounds` = 2 and `ai_hunt` = true.

## Turns the free rotation of placed shapes off again (to compare).
static var no_rotation := false
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
## No damage of any kind before this round (1 = off; 2 = round 1 is for positioning only).
static var damage_from_round := 2
## true (GDD rule of the reshape of 2026-11-13, kept by the user after S028): a Dragon Vein belongs to
## the side that touched it last and deals its damage for that side whether or not a monster stands
## on it. false = only while a monster stands on it at the round end (measured in S028).
static var vein_touch := true
## Late-round pressure: "idle" (build rule) only at the end of a round in which nobody holds a
## Wellspring · "always" as before 2026-11-13 · "none" never.
static var pressure_mode := "none"
## The rule since 2026-11-14 (user decision): every slotted skill at most `usage_limit` times per turn of its
## monster (1 unless the skill says more; Step is not slotted). No switch of the game or the tools any more
## (user, 2026-11-17); only the older rule tests turn it off (tests/battle/helpers.gd legacy_rules).
static var once_per_turn := true
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
## Board switch: mirrored prop pairs a board starts with (-1 = as the layout or its seed says, 0 = none).
static var map_props := -1
## Board switch (user request 2026-11-15): side length of the board, for every mode (0 = the size of the mode;
## the draft offers 8 and 9; a size not larger than the mode's is ignored). Start squares, the fixed test
## layout and the number of seeded prop pairs follow the size (BattleBoards.mode_data).
static var board_size := 0
## Board switch (user idea, 2026-11-15): mirrored pairs of "button" squares the board starts with: walkable
## rune props without damage that act on the board when a monster collects them (0 = none).
static var map_buttons := 0

# ---------- What is left of the review pack of 2026-11-17 (test switches, on by default; no rules; docs/todo T44) ----------
# `damage_from_round` 2 (round 1 is for position), `pressure_mode` "none" (no late-round pressure) and the
# stronger veins below. `pack(false)` gives the rules of battle.md back.

## From this round on an owned Dragon Vein deals `vein_late_damage` instead of 1 (0 = never). 3 since S039
## (measured with 5, 4 and 3; with round 1 free of damage, 3 gave the fewest battles over 5 rounds).
static var vein_late_round := 3
static var vein_late_damage := 2

## View switch (user request 2026-11-17, to compare): dragging with the middle mouse button also tilts the camera
## up and down (BattleView). false = the fixed tilt of 40°.
static var free_camera := true


## Switches what is left of the review pack on (the build default) or off (the rules of battle.md).
static func pack(on: bool) -> void:
	vein_late_round = 3 if on else 0
	vein_late_damage = 2
	damage_from_round = 2 if on else 1
	pressure_mode = "none" if on else "idle"


## Vein damage in this round.
static func vein_damage(round_number: int) -> int:
	return vein_late_damage if vein_late_round > 0 and round_number >= vein_late_round else 1


## The three switches below are off here and checked by default in the draft of the multiplayer mode (user,
## 2026-11-17; DraftScreen): it plays random monsters with kits of skills generated for the battle. Battles
## started elsewhere, the rule tests and the tools play the monsters as they are.
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


static func reset() -> void:
	no_rotation = false
	ai_aggressive = false
	ai_hunt = true
	ai_hunt_behind = false
	ai_careful = false
	ai_no_kind = ["", ""]
	soft_pressure = 0
	ground_rounds = 2
	start_back = false
	wells = 3
	flank = true
	tpr_from_round = 2
	vein_touch = true
	once_per_turn = true
	stamina = true
	stamina_regen = 0
	map_props = -1
	map_buttons = 0
	board_size = 0
	free_camera = true
	random_kits = false
	fresh_skills = false
	random_monsters = false
	kit_seed = 0
	pack(true)


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


## Every switch of this file with its value now and its build default: [[name, value, default], ...], in the
## order of the file. The battle screen shows it (pause menu) and tools/sim.gd prints it with every run.
static func settings() -> Array:
	var script: Script = BattleExperiment
	var names: PackedStringArray = []
	for line in script.source_code.split("\n"):
		if line.begins_with("static var "):
			names.append(line.trim_prefix("static var ").get_slice(" ", 0).get_slice(":", 0))
	var now := {}
	for n in names:
		now[n] = script.get(n)
		if now[n] is Array:
			now[n] = (now[n] as Array).duplicate()
	reset()
	var out: Array = []
	for n in names:
		out.append([n, now[n], script.get(n)])
	for n in names:
		script.set(n, now[n])
	return out


## The settings as lines: first what differs from the build default, then the defaults.
static func settings_lines() -> PackedStringArray:
	var changed: PackedStringArray = []
	var same: PackedStringArray = []
	for row: Array in settings():
		if str(row[1]) != str(row[2]):
			changed.append("%s = %s   (default %s)" % [row[0], str(row[1]), str(row[2])])
		else:
			same.append("%s = %s" % [row[0], str(row[1])])
	var lines: PackedStringArray = ["Changed from the build default: %s" % ("none" if changed.is_empty() else str(changed.size()))]
	lines.append_array(changed)
	lines.append("")
	lines.append("Build defaults in use:")
	lines.append_array(same)
	return lines


## One line for a run block: only what differs from the build default.
static func settings_changed_text() -> String:
	var changed: PackedStringArray = []
	for row: Array in settings():
		if str(row[1]) != str(row[2]):
			changed.append("%s=%s" % [row[0], str(row[1])])
	return "build defaults" if changed.is_empty() else ", ".join(changed)


## One line with every switch and its value.
static func settings_all_text() -> String:
	var all: PackedStringArray = []
	for row: Array in settings():
		all.append("%s=%s" % [row[0], str(row[1])])
	return ", ".join(all)
