class_name BattleDisplace
extends RefCounted
## Forced movement: push and pull (gdd_battle §6.3, §6.5). One square per call; collision,
## fall and entry effects fire at the moment of the move. Pending Surges never block it.


## Damage of a push or pull against the board edge and into a spiky prop (build rules since
## 2026-11-12, temp_todo T38; the GDDs still say 0 and 1).
const EDGE_DAMAGE := 1
const SPIKY_DAMAGE := 2


## Cardinal pull direction toward `anchor`; ZERO on an exact diagonal or on the anchor itself
## (no unique cardinal direction → no movement). A 2x2 uses its covered square nearest the anchor.
static func pull_dir(u: BattleUnit, anchor: Vector2i) -> Vector2i:
	var from := u.pos
	var best := 1 << 20
	for c in u.cells():
		var d := Board.chebyshev(c, anchor)
		if d < best:
			best = d
			from = c
	var v := anchor - from
	if v == Vector2i.ZERO or absi(v.x) == absi(v.y):
		return Vector2i.ZERO
	if absi(v.x) > absi(v.y):
		return Vector2i(signi(v.x), 0)
	return Vector2i(0, signi(v.y))


## How far along its movement a unit already is: squares left to the board edge in `dir`
## (smaller = further along). Orders "the unit furthest along the movement direction first".
static func room_ahead(b: Battle, u: BattleUnit, dir: Vector2i) -> int:
	var room := 1 << 20
	if dir.x > 0:
		room = mini(room, b.board.size - (u.pos.x + u.size))
	elif dir.x < 0:
		room = mini(room, u.pos.x)
	if dir.y > 0:
		room = mini(room, b.board.size - (u.pos.y + u.size))
	elif dir.y < 0:
		room = mini(room, u.pos.y)
	return room


## Resolves displacement entries [{unit, dir, key?, cause}] one unit at a time: smallest `key`
## first (furthest along / nearest the anchor), ties in current initiative-queue order
## (gdd_battle §6.2 step 3 and tie rule).
static func resolve(b: Battle, entries: Array) -> void:
	var list: Array = []
	for e: Dictionary in entries:
		var u: BattleUnit = b.units.get(e["unit"])
		if u == null or not u.is_alive() or e["dir"] == Vector2i.ZERO:
			continue
		var item := e.duplicate()
		if not item.has("key"):
			item["key"] = room_ahead(b, u, e["dir"])
		item["rank"] = b.queue_rank(u.id)
		list.append(item)
	list.sort_custom(func(a: Dictionary, c: Dictionary) -> bool:
		if a["key"] != c["key"]:
			return a["key"] < c["key"]
		if a["rank"] != c["rank"]:
			return a["rank"] < c["rank"]
		return b.roster.find(a["unit"]) < b.roster.find(c["unit"]))
	for item: Dictionary in list:
		# experiment: a push or pull may move several squares and stops at the first blocker
		for _i in maxi(1, BattleExperiment.push_steps if item.get("multi", false) else 1):
			if not shove(b, b.units[item["unit"]], item["dir"], item.get("cause", "push")):
				break


## Moves `u` one square by force. Returns true if it moved.
static func shove(b: Battle, u: BattleUnit, dir: Vector2i, cause: String) -> bool:
	if u == null or not u.is_alive() or dir == Vector2i.ZERO:
		return false
	if BattleStats.is_immovable(b, u):
		b.emit(&"unmoved", {"who": u.id, "reason": "immovable"})
		return false
	var board := b.board
	var from := u.pos
	var to := from + dir
	var fresh: Array[Vector2i] = []
	for c in u.cells_at(to):
		if not u.covers(c):
			fresh.append(c)
	for c in fresh:
		if not board.in_bounds(c):
			b.emit(&"unmoved", {"who": u.id, "reason": "edge"})      # the void beyond the board: no move, 1 damage
			BattleDamage.apply_round(b, [{"unit": u.id, "base": EDGE_DAMAGE, "type": BattleDamage.COLLISION, "source": "Board edge", "pushed": true}])
			BattleDamage.defeat_step(b)
			return false
	# blockers on the unit's own layer: one collision, each blocker takes 1 (heavy props none)
	var block_units := {}
	var block_props := {}
	for c in fresh:
		var other := board.unit_id_at(c, u.layer)
		if other != &"" and other != u.id:
			block_units[other] = true
		var prop := board.prop_at(c, u.layer)
		if prop != null:
			block_props[prop.uid] = prop
	if not block_units.is_empty() or not block_props.is_empty():
		var own := 1
		for puid in block_props:
			if block_props[puid].def.spiky:
				own = SPIKY_DAMAGE
		var hits: Array = [{"unit": u.id, "base": own, "type": BattleDamage.COLLISION, "source": "Collision", "pushed": true}]
		for id in b.roster:
			if block_units.has(id):
				hits.append({"unit": id, "base": 1, "type": BattleDamage.COLLISION, "source": "Collision"})
		b.emit(&"collision", {"who": u.id, "units": block_units.keys(), "props": block_props.keys(), "cause": cause})
		BattleDamage.apply_round(b, hits)
		var uids := block_props.keys()
		uids.sort()
		for uid in uids:
			var prop: BoardProp = block_props[uid]
			if not prop.def.heavy:
				BattleBoardOps.damage_prop(b, prop, 1)
		BattleDamage.defeat_step(b)
		return false
	var falls := false
	if u.layer == Board.GROUND:
		var all_lower := true
		for c in u.cells():
			var h_from := board.at(c).height
			var h_to := board.at(c + dir).height
			if h_to > h_from:
				b.emit(&"unmoved", {"who": u.id, "reason": "mountain"})   # blocked like a prop, no damage
				return false
			if h_to >= h_from:
				all_lower = false
		falls = all_lower
	b.relocate(u, to)
	b.emit(&"displaced", {"who": u.id, "from": from, "to": to, "cause": cause})
	if falls:
		BattleDamage.apply_round(b, [{"unit": u.id, "base": 1, "type": BattleDamage.FALL, "source": "Fall"}])
		BattleDamage.defeat_step(b)
	if u.is_alive():
		BattleDamage.ground_triggers(b, u, GroundTrigger.ON_ENTER, fresh)
	return true
