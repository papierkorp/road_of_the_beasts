extends RefCounted
## Shared pieces of the headless simulation tools (sim.gd, compare.gd): boards for test builds,
## the bot game loop and the board printout. Setup helpers only; no battle rule lives here.
## Use it through `const Runner := preload("res://tools/lib/sim_runner.gd")`.

const Bots := preload("res://tools/lib/sim_bots.gd")

## Board sizes of the modes (gdd_battle §1.1); a test build may field any team on any of them.
const MODE_OF_SIZE := {5: &"1v1", 6: &"2v2", 7: &"3v3", 9: &"5v5"}
const BOARDS: Array[String] = ["flat", "layout", "seeded"]
const MAX_TURNS := 600
const GROUND_SYMBOL := {&"plain": ".", &"rubble": ",", &"lava": "~", &"thornbed": "*", &"blight": "%", &"mossbed": "\"",
	&"hallowed": "+", &"hearth": "=", &"umbra": "-", &"voidscar": "#"}


## Free squares of side 0's start area (gdd_battle §4.1), shuffled by `rng`.
static func start_squares(b: Battle, mode: StringName, rng: RandomNumberGenerator) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for cell in b.board.cells:
		if BattleBoards.in_start_area(mode, cell.pos, 0) and cell.prop == null and not cell.is_mountain():
			out.append(cell.pos)
	for i in range(out.size() - 1, 0, -1):
		var k := rng.randi_range(0, i)
		var swap := out[i]
		out[i] = out[k]
		out[k] = swap
	return out


## One point-mirrored pair per listed prop on random squares outside the start areas and the centre.
static func add_prop_pairs(b: Battle, mode: StringName, props: Array[StringName], rng: RandomNumberGenerator) -> String:
	var free: Array[Vector2i] = []
	for cell in b.board.cells:
		var twin := b.board.mirrored(cell.pos)
		if cell.pos == twin or cell.pos > twin or cell.is_mountain() or b.board.at(twin).is_mountain():
			continue
		if BattleBoards.in_start_area(mode, cell.pos, 0) or BattleBoards.in_start_area(mode, cell.pos, 1) \
				or BattleBoards.in_start_area(mode, twin, 0) or BattleBoards.in_start_area(mode, twin, 1):
			continue
		free.append(cell.pos)
	for id in props:
		if b.content.prop(id) == null:
			return "unknown prop '%s'" % id
		if free.is_empty():
			return "no free square left for prop '%s'" % id
		var p: Vector2i = free.pop_at(rng.randi_range(0, free.size() - 1))
		b.add_prop(id, p)
		b.add_prop(id, b.board.mirrored(p))
	return ""


## A battle between two teams of unit sheets: {"battle": Battle, "error": String}.
##   flat    empty board of the mode's size (optionally with mirrored prop pairs)
##   layout  the mode's fixed test layout (BattleBoards seed 0: Mountains and props)
##   seeded  a seeded draft board of the mode
## Side 0 starts on seeded squares of its start area; side 1 on the point-mirrored squares, so
## a side swap replays the same geometry. Late-round pressure starts as the mode defines.
static func make_battle(mode: StringName, teams: Array, board: String, rng: RandomNumberGenerator,
		props: Array[StringName] = []) -> Dictionary:
	if not BattleBoards.has_mode(mode):
		return {"battle": null, "error": "unknown mode '%s'" % mode}
	var b := Battle.new(null, BattleContent.shared())
	match board:
		"flat":
			var data := BattleBoards.mode_data(mode)
			b.board = Board.new(int(data["size"]))
			b.voidscar_from = int(data["voidscar_from"])
			BattleBoards.place_wells(b)
		"layout":
			BattleBoards.build(b, mode, 0)
		"seeded":
			BattleBoards.build(b, mode, rng.randi_range(1, 1 << 30))
		_:
			return {"battle": null, "error": "unknown board '%s'" % board}
	if not props.is_empty():
		var problem := add_prop_pairs(b, mode, props, rng)
		if problem != "":
			return {"battle": null, "error": problem}
	var squares := start_squares(b, mode, rng)
	for side in 2:
		var team: Array = teams[side]
		if team.size() > squares.size():
			return {"battle": null, "error": "the %s start area holds %d monsters, the team has %d" % [mode, squares.size(), team.size()]}
		for i in team.size():
			var sheet: UnitSheet = team[i]
			var pos := squares[i] if side == 0 else b.board.mirrored(squares[i]) - Vector2i(sheet.size - 1, sheet.size - 1)
			b.add_unit(BattleUnit.new(StringName("%s%d_%s" % ["ab"[side], i, sheet.species_id]), sheet, side, i, pos))
	return {"battle": b, "error": ""}


## Plays a prepared battle to its end with one bot per side: {"winner": 0 | 1 | -1 (Draw or
## timeout), "draw", "timeout", "rounds"}. `trace` prints the board before every turn.
static func play(b: Battle, bots: Array[String], rng: RandomNumberGenerator, trace := false) -> Dictionary:
	b.begin()
	var guard := 0
	while not b.over and guard < MAX_TURNS:
		var u := b.active()
		if trace:
			print(render(b))
		Bots.play_turn(bots[u.side] if u != null else Bots.NAMES[0], b, rng)
		guard += 1
	return {"winner": b.winner_side if b.over else -1, "draw": b.over and b.draw, "timeout": not b.over, "rounds": b.round_number}


## ASCII board: side 0 as A, B, ... and side 1 as a, b, ... by slot; o prop, ^ Mountain,
## ! charging Surge, otherwise the ground (. plain , rubble ~ lava * thornbed % blight
## " mossbed + hallowed = hearth - umbra # voidscar).
static func render(b: Battle) -> String:
	var lines: PackedStringArray = []
	var u := b.active()
	lines.append("-- round %d  %s  AP %d" % [b.round_number, u.id if u != null else &"-", b.ap])
	for y in b.board.size:
		var row := ""
		for x in b.board.size:
			var p := Vector2i(x, y)
			var cell := b.board.at(p)
			var who := b.any_unit_at(p)
			if who != null:
				row += char((65 if who.side == 0 else 97) + who.slot)
			elif cell.prop != null or cell.air_prop != null:
				row += "o"
			elif cell.surge >= 0:
				row += "!"
			elif cell.is_mountain():
				row += "^"
			else:
				row += GROUND_SYMBOL.get(cell.ground, "?")
		lines.append(row)
	var hp: PackedStringArray = []
	for id in b.roster:
		var unit: BattleUnit = b.units[id]
		if unit.is_alive():
			hp.append("%s %d/%d" % [char((65 if unit.side == 0 else 97) + unit.slot), unit.hp, unit.max_hp])
	lines.append("   " + "  ".join(hp))
	return "\n".join(lines)
