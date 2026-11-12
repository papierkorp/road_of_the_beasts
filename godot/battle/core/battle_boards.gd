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
## which late-round pressure starts. Voidscar start: 1v1 round 6 and 3v3 round 8 are GDD
## values; the 2v2 and 5v5 values are drafts (the GDD only says it scales with board size).
const MODES := {
	&"1v1": {"size": 5, "starts": [Vector2i(0, 4)], "start_rows": 1, "corner": true,
		"mountains": [Vector2i(1, 1), Vector2i(3, 3)],
		"props": {Vector2i(1, 3): &"stone_lion"}, "pairs": [1, 1], "voidscar_from": 6},
	&"2v2": {"size": 6, "starts": [Vector2i(1, 5), Vector2i(4, 5)], "start_rows": 1, "corner": false,
		"mountains": [Vector2i(2, 2), Vector2i(3, 3)],
		"props": {Vector2i(0, 3): &"clay_urn", Vector2i(4, 1): &"stone_lion"}, "pairs": [1, 2], "voidscar_from": 7},
	&"3v3": {"size": 7, "starts": [Vector2i(1, 5), Vector2i(3, 6), Vector2i(5, 5)], "start_rows": 2, "corner": false,
		"mountains": [Vector2i(3, 3), Vector2i(1, 3), Vector2i(5, 3)],
		"props": {Vector2i(2, 2): &"stone_lion", Vector2i(4, 2): &"clay_urn", Vector2i(0, 3): &"shrine"},
		"pairs": [2, 3], "voidscar_from": 8},
	&"5v5": {"size": 9, "starts": [Vector2i(0, 7), Vector2i(2, 8), Vector2i(4, 7), Vector2i(6, 8), Vector2i(8, 7)],
		"start_rows": 2, "corner": false,
		"mountains": [Vector2i(4, 4), Vector2i(2, 4), Vector2i(6, 4)],
		"props": {Vector2i(3, 2): &"stone_lion", Vector2i(5, 2): &"clay_urn", Vector2i(1, 4): &"shrine", Vector2i(4, 3): &"bamboo_stand"},
		"pairs": [3, 4], "voidscar_from": 10},
}
## Ground-layer catalogue entries a seeded board may pre-place (no child props).
const SEEDED_PROPS: Array[StringName] = [&"stone_lion", &"clay_urn", &"bamboo_stand", &"paper_lantern",
	&"peach_tree", &"ancestor_tablet", &"bronze_gong", &"pagoda_column", &"shrine", &"totem", &"banner", &"wardstone",
	&"vortex_urn", &"storm_drum"]


static func has_mode(mode: StringName) -> bool:
	return MODES.has(mode)


static func mode_data(mode: StringName) -> Dictionary:
	return MODES.get(mode, MODES[&"3v3"])


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
	for p: Vector2i in d["mountains"]:
		b.board.at(p).height = 1
	var starts: Array[Vector2i] = []
	starts.assign(d["starts"])
	var props: Dictionary = d["props"] if seed_value == 0 else _seeded_props(b, mode, d, starts, seed_value)
	var squares := props.keys()
	squares.sort()
	for p: Vector2i in squares:
		var twin := b.board.mirrored(p)
		if p == twin:
			continue                          # the centre never holds a prop
		b.add_prop(props[p], p)
		b.add_prop(props[p], twin)
	return starts


static func _seeded_props(b: Battle, mode: StringName, d: Dictionary, starts: Array[Vector2i], seed_value: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var size: int = d["size"]
	var free: Array[Vector2i] = []
	for y in size:
		for x in size:
			var p := Vector2i(x, y)
			var twin := b.board.mirrored(p)
			if p == twin or p > twin:
				continue                      # one square of every mirrored pair
			if b.board.at(p).is_mountain() or b.board.at(twin).is_mountain():
				continue
			var near_start := false
			for s in starts:
				if Board.chebyshev(s, p) <= 1 or Board.chebyshev(s, twin) <= 1:
					near_start = true
			if not near_start and not in_start_area(mode, p, 0) and not in_start_area(mode, p, 1):
				free.append(p)
	var pairs := rng.randi_range(int(d["pairs"][0]), int(d["pairs"][1]))
	var out := {}
	while out.size() < pairs and not free.is_empty():
		var p: Vector2i = free.pop_at(rng.randi_range(0, free.size() - 1))
		out[p] = SEEDED_PROPS[rng.randi_range(0, SEEDED_PROPS.size() - 1)]
	return out
