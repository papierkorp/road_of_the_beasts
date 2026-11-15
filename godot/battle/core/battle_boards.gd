class_name BattleBoards
extends RefCounted
## Battlefields per mode (gdd_battle §1.1, §4.1): point-symmetric around the centre, contested
## Mountains near it, props only as mirrored pairs and never on the centre square.
##
## The board generator contract is still open (T21). Seed 0 gives one fixed TEST layout per
## mode; any other seed draws prop types and squares with a seeded generator under the decided
## symmetry rules. Generation is setup, not battle resolution: the rules never see the seed.

## size, player start squares in slot order (enemy starts are their mirror images), start-area
## rows from the player's back edge, contested Mountains, fixed prop pairs (one square each;
## the twin is mirrored), draft number of mirrored pairs for seeded boards and the round in
## which late-round pressure starts. Voidscar start: 1v1 round 6, 2v2 round 6, 3v3 round 8 and 5v5 round 8 (user decision 2026-11-14; GDD
## values, working drafts).
const MODES := {
	&"1v1": {"size": 5, "starts": [Vector2i(0, 4)], "start_rows": 1, "corner": true,
		"mountains": [Vector2i(1, 1), Vector2i(3, 3)],
		"props": {Vector2i(1, 3): &"stone_lion"}, "pairs": [1, 1], "voidscar_from": 6},
	&"2v2": {"size": 6, "starts": [Vector2i(1, 5), Vector2i(4, 5)], "start_rows": 1, "corner": false,
		"mountains": [Vector2i(2, 2), Vector2i(3, 3)],
		"props": {Vector2i(0, 3): &"clay_urn", Vector2i(4, 1): &"stone_lion"}, "pairs": [1, 2], "voidscar_from": 6},
	&"3v3": {"size": 7, "starts": [Vector2i(1, 5), Vector2i(3, 6), Vector2i(5, 5)], "start_rows": 2, "corner": false,
		"mountains": [Vector2i(3, 3), Vector2i(1, 3), Vector2i(5, 3)],
		"props": {Vector2i(2, 2): &"stone_lion", Vector2i(4, 2): &"clay_urn", Vector2i(0, 3): &"peach_tree"},
		"pairs": [2, 3], "voidscar_from": 8},
	&"5v5": {"size": 9, "starts": [Vector2i(0, 7), Vector2i(2, 8), Vector2i(4, 7), Vector2i(6, 8), Vector2i(8, 7)],
		"start_rows": 2, "corner": false,
		"mountains": [Vector2i(4, 4), Vector2i(2, 4), Vector2i(6, 4)],
		"props": {Vector2i(3, 2): &"stone_lion", Vector2i(5, 2): &"clay_urn", Vector2i(1, 4): &"peach_tree", Vector2i(4, 3): &"bamboo_stand"},
		"pairs": [3, 4], "voidscar_from": 8},
}
## Ground-layer catalogue entries a seeded board may pre-place (no child props).
const SEEDED_PROPS: Array[StringName] = [&"stone_lion", &"clay_urn", &"bamboo_stand", &"paper_lantern",
	&"peach_tree", &"ancestor_tablet", &"bronze_gong", &"pagoda_column", &"earth_wall", &"thorn_idol", &"ember_brazier",
	&"vortex_urn", &"storm_drum"]
## "Button" squares (board switch `map_buttons`, user idea 2026-11-15): walkable rune props without
## damage that act on the board when a monster collects them.
const BUTTON_PROPS: Array[StringName] = [&"moss_rune", &"bog_rune", &"wall_rune"]


static func has_mode(mode: StringName) -> bool:
	return MODES.has(mode)


static func mode_data(mode: StringName) -> Dictionary:
	var d: Dictionary = MODES.get(mode, MODES[&"3v3"])
	if BattleExperiment.board_size > int(d["size"]):
		return _resized(d, BattleExperiment.board_size)
	return d


## A mode on a larger board (board switch `board_size`): the start squares keep their distance from the
## back edge and spread over the wider rows, the fixed test layout moves with the centre, and a seeded
## board draws one more prop pair per two extra squares of side length.
static func _resized(d: Dictionary, size: int) -> Dictionary:
	var from: int = d["size"]
	var out := d.duplicate(true)
	out["size"] = size
	var starts: Array = []
	for s: Vector2i in d["starts"]:
		starts.append(Vector2i(roundi(float(s.x) * (size - 1) / (from - 1)), s.y + size - from))
	out["starts"] = starts
	var shift := (size - from) >> 1
	var props := {}
	for p: Vector2i in d["props"]:
		props[p + Vector2i(shift, shift)] = d["props"][p]
	out["props"] = props
	var more := (size - from + 1) >> 1
	out["pairs"] = [int(d["pairs"][0]) + more, int(d["pairs"][1]) + more]
	return out


static func team_size(mode: StringName) -> int:
	return (mode_data(mode)["starts"] as Array).size()


## True if `p` lies in the player's start area (gdd_battle §4.1 table).
static func in_start_area(mode: StringName, p: Vector2i, side := 0) -> bool:
	var d := mode_data(mode)
	var size: int = d["size"]
	var q := p if side == 0 else Vector2i(size - 1 - p.x, size - 1 - p.y)
	if q.x < 0 or q.y < 0 or q.x >= size or q.y >= size:
		return false
	if d["corner"]:
		return q == Vector2i(0, size - 1)
	return q.y >= size - int(d["start_rows"])


## Builds the board into `b` and returns the player's default start squares.
static func build(b: Battle, mode: StringName, seed_value := 0) -> Array[Vector2i]:
	var d := mode_data(mode)
	var size: int = d["size"]
	b.board = Board.new(size)
	b.voidscar_from = d["voidscar_from"]
	# no height since the reshape of 2026-11-13: the Mountains of the layouts are not placed
	place_wells(b)
	var starts: Array[Vector2i] = []
	starts.assign(d["starts"])
	var props: Dictionary = d["props"]
	if BattleExperiment.map_props >= 0:            # board switch: that many mirrored pairs, drawn by the seed
		props = _seeded_props(b, mode, d, starts, seed_value if seed_value != 0 else 1, BattleExperiment.map_props)
	elif seed_value != 0:
		props = _seeded_props(b, mode, d, starts, seed_value)
	var squares := props.keys()
	squares.sort()
	for p: Vector2i in squares:
		var twin := b.board.mirrored(p)
		if p == twin:
			continue                          # the centre never holds a prop (props come in mirrored pairs)
		b.add_prop(props[p], p)               # also on a Dragon Vein: it is ordinary ground that nothing changes (user decision 2026-11-15)
		b.add_prop(props[p], twin)
	if BattleExperiment.map_buttons > 0:
		_seeded_buttons(b, mode, d, starts, seed_value if seed_value != 0 else 1)
	return starts


## Board switch: `map_buttons` mirrored pairs of button squares on free squares outside the start
## areas, never on a Dragon Vein or a prop; the rune type and the squares come from the seed.
static func _seeded_buttons(b: Battle, mode: StringName, d: Dictionary, starts: Array[Vector2i], seed_value: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value * 7919 + 17
	var squares := _pair_squares(b, mode, d, starts, false)
	var free: Array[Vector2i] = squares[0]
	free.append_array(squares[1])
	var placed := 0
	while placed < BattleExperiment.map_buttons and not free.is_empty():
		var p: Vector2i = free.pop_at(rng.randi_range(0, free.size() - 1))
		var twin := b.board.mirrored(p)
		if b.board.at(p).prop != null or b.board.at(twin).prop != null:
			continue
		var id := BUTTON_PROPS[rng.randi_range(0, BUTTON_PROPS.size() - 1)]
		if b.content.prop(id) == null:
			continue
		b.add_prop(id, p)
		b.add_prop(id, twin)
		placed += 1


## One square of every mirrored pair a board may start a prop on: [free, spare]; spare squares
## lie next to a start square and are used only when the free ones run out. `veins` = false leaves
## out the pairs with a Dragon Vein (button squares).
static func _pair_squares(b: Battle, mode: StringName, d: Dictionary, starts: Array[Vector2i], veins := true) -> Array:
	var size: int = d["size"]
	var free: Array[Vector2i] = []
	var spare: Array[Vector2i] = []
	for y in size:
		for x in size:
			var p := Vector2i(x, y)
			var twin := b.board.mirrored(p)
			if p == twin or p > twin:
				continue                      # one square of every mirrored pair
			if b.board.at(p).is_mountain() or b.board.at(twin).is_mountain():
				continue
			if not veins and (b.board.at(p).ground == GroundDef.WELL or b.board.at(twin).ground == GroundDef.WELL):
				continue
			var near_start := false
			for s in starts:
				if Board.chebyshev(s, p) <= 1 or Board.chebyshev(s, twin) <= 1:
					near_start = true
			if in_start_area(mode, p, 0) or in_start_area(mode, p, 1):
				continue
			if near_start:
				spare.append(p)
			else:
				free.append(p)
	return [free, spare]


## Turns the Dragon Vein squares of the board size into Dragon Veins (BattleExperiment.well_squares).
static func place_wells(b: Battle) -> void:
	for p in BattleExperiment.well_squares(b.board.size):
		var cell := b.board.at(p)
		cell.ground = GroundDef.WELL
		cell.level = 1
		cell.height = 0


static func _seeded_props(b: Battle, mode: StringName, d: Dictionary, starts: Array[Vector2i], seed_value: int, fixed_pairs := -1) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var squares := _pair_squares(b, mode, d, starts)
	var free: Array[Vector2i] = squares[0]
	var spare: Array[Vector2i] = squares[1]       # only the prop pairs switch fills squares next to a start square
	var pairs := rng.randi_range(int(d["pairs"][0]), int(d["pairs"][1]))
	if fixed_pairs >= 0:
		pairs = fixed_pairs
	var out := {}
	while out.size() < pairs and not (free.is_empty() and (fixed_pairs < 0 or spare.is_empty())):
		if free.is_empty():
			free = spare
			spare = []
		var p: Vector2i = free.pop_at(rng.randi_range(0, free.size() - 1))
		out[p] = SEEDED_PROPS[rng.randi_range(0, SEEDED_PROPS.size() - 1)]
	return out
