class_name MapGen
extends RefCounted
## The generator of battlegrounds (docs/vision.md §4, docs/battle_ingame.md §3): every battle of the wild and of the
## void is fought on a board made for it, point-mirrored, so both sides meet the same distances. It returns plain
## data in the format of `MapData`; the overworld never touches a MapDef. A first version with test values
## (GameValues.gen_*): the rules name no generator yet.


static func _key(p: Vector2i) -> String:
	return "%d,%d" % [p.x, p.y]


## The entries of a per-stage list ({"id", "stage"}) a stage may use.
static func _open(list: Array, stage: int) -> Array[String]:
	var out: Array[String] = []
	for e: Dictionary in list:
		if int(e.get("stage", 0)) <= stage:
			out.append(String(e["id"]))
	return out


## A battleground for `mine` monsters of the player against `theirs`: a square of 5 to 7 squares a side with Dragon
## Veins on its middle, and ground, props and (from later stages) zones as mirrored pairs.
static func generate(rng: RandomNumberGenerator, values: GameValues, stage: int, mine: int, theirs: int) -> Dictionary:
	var side := clampi(5 + rng.randi_range(0, 1) + (1 if stage >= 2 else 0), maxi(5, maxi(mine, theirs)), 7)
	var d := {"w": side, "h": side, "missing": [], "grounds": {}, "props": {}, "zones": {}, "start_a": [], "start_b": []}
	var taken := {}
	var first := (side - mine) >> 1
	for i in mine:
		d["start_a"].append([first + i, side - 1])
		taken[Vector2i(first + i, side - 1)] = true
	first = (side - theirs) >> 1
	for i in theirs:
		d["start_b"].append([side - 1 - first - i, 0])
		taken[Vector2i(side - 1 - first - i, 0)] = true
	# Dragon Veins: on the middle row of an odd board (the centre, or a pair, or all three), a mirrored pair on the
	# two middle rows of an even one
	var veins: Array[Vector2i] = []
	if side % 2 == 1:
		var mid := side >> 1
		var kind := rng.randi_range(0, 2)
		if kind != 1:
			veins.append(Vector2i(mid, mid))
		if kind != 0:
			var off := rng.randi_range(1, mid - 1) if mid > 1 else 1
			veins.append(Vector2i(mid - off, mid))
			veins.append(Vector2i(mid + off, mid))
	else:
		var x := rng.randi_range(0, side - 1)
		veins.append(Vector2i(x, (side >> 1) - 1))
		veins.append(Vector2i(side - 1 - x, side >> 1))
	for p in veins:
		d["grounds"][_key(p)] = String(GroundDef.WELL)
		taken[p] = true
	# what lies on the board, as mirrored pairs on free squares between the start rows
	var plans: Array = [["grounds", _open(values.gen_grounds, stage), 1 + rng.randi_range(0, 1) + (stage >> 1)],
		["props", _open(values.gen_props, stage), 1 + rng.randi_range(0, 1)],
		["zones", _open(values.gen_zones, stage), rng.randi_range(0, 1)]]
	for plan: Array in plans:
		var ids: Array[String] = plan[1]
		for i in int(plan[2]):
			if ids.is_empty():
				break
			var id := ids[rng.randi_range(0, ids.size() - 1)]
			var p := Vector2i(rng.randi_range(0, side - 1), rng.randi_range(1, side - 2))
			var q := Vector2i(side - 1 - p.x, side - 1 - p.y)
			if taken.has(p) or taken.has(q):
				continue
			taken[p] = true
			taken[q] = true
			for at: Vector2i in ([p] if p == q else [p, q]):
				if String(plan[0]) == "zones":         # a push zone points at the middle of the board: both halves alike
					var dir := [0, 1] if at.y < (side >> 1) else [0, -1]
					d["zones"][_key(at)] = {"zone": id, "dir": dir, "rounds": 0}
				else:
					d[plan[0]][_key(at)] = id
	return d
