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
	return pull_dir_cell(from, anchor)


## The same for a single square (a prop).
static func pull_dir_cell(from: Vector2i, anchor: Vector2i) -> Vector2i:
	var v := anchor - from
	if v == Vector2i.ZERO or absi(v.x) == absi(v.y):
		return Vector2i.ZERO
	if absi(v.x) > absi(v.y):
		return Vector2i(signi(v.x), 0)
	return Vector2i(0, signi(v.y))


## How far along its movement a unit already is: squares left to the board edge in `dir`
## (smaller = further along). Orders "the unit furthest along the movement direction first".
static func room_ahead(b: Battle, u: BattleUnit, dir: Vector2i) -> int:
	return room_at(b, u.pos, u.size, dir)


static func room_at(b: Battle, pos: Vector2i, size: int, dir: Vector2i) -> int:
	var room := 1 << 20
	if dir.x > 0:
		room = mini(room, b.board.size - (pos.x + size))
	elif dir.x < 0:
		room = mini(room, pos.x)
	if dir.y > 0:
		room = mini(room, b.board.size - (pos.y + size))
	elif dir.y < 0:
		room = mini(room, pos.y)
	return room


## The standing prop with this uid, or null.
static func prop_by_uid(b: Battle, uid: int) -> BoardProp:
	for p in b.board.props():
		if p.uid == uid:
			return p
	return null


## Resolves displacement entries [{unit, dir, key?, cause}] one unit at a time: smallest `key`
## first (furthest along / nearest the anchor), ties in current pace-queue order
## (gdd_battle §6.2 step 3 and tie rule).
static func resolve(b: Battle, entries: Array) -> void:
	var list: Array = []
	for e: Dictionary in entries:
		var item := e.duplicate()
		if e.has("prop"):
			# a prop is moved like a monster (user decision 2026-11-14); it ranks after every monster
			var pr := prop_by_uid(b, int(e["prop"]))
			if pr == null or pr.hp <= 0 or e["dir"] == Vector2i.ZERO:
				continue
			if not item.has("key"):
				item["key"] = room_at(b, pr.pos, 1, e["dir"])
			item["rank"] = 1000000 + pr.uid
			list.append(item)
			continue
		var u: BattleUnit = b.units.get(e["unit"])
		if u == null or not u.is_alive() or e["dir"] == Vector2i.ZERO:
			continue
		if not item.has("key"):
			item["key"] = room_ahead(b, u, e["dir"])
		item["rank"] = b.queue_rank(u.id)
		list.append(item)
	list.sort_custom(func(a: Dictionary, c: Dictionary) -> bool:
		if a["key"] != c["key"]:
			return a["key"] < c["key"]
		if a["rank"] != c["rank"]:
			return a["rank"] < c["rank"]
		if a.has("prop") or c.has("prop"):
			return int(a.get("prop", -1)) < int(c.get("prop", -1))
		return b.roster.find(a["unit"]) < b.roster.find(c["unit"]))
	for item: Dictionary in list:
		for _i in 1:
			if item.has("prop"):
				var pr := prop_by_uid(b, int(item["prop"]))
				if pr == null or not shove_prop(b, pr, item["dir"], item.get("cause", "push")):
					break
			elif not shove(b, b.units[item["unit"]], item["dir"], item.get("cause", "push"), item.get("kind", "strike")):
				break


## Moves `u` one square by force. Returns true if it moved. `kind` is where the force comes from: "strike" (a
## Strike or another skill), "zone" or "prop"; a passive may hold against one of them.
static func shove(b: Battle, u: BattleUnit, dir: Vector2i, cause: String, kind := "strike") -> bool:
	if u == null or not u.is_alive() or dir == Vector2i.ZERO:
		return false
	if BattleStats.is_immovable(b, u, kind):
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
		var prop := board.solid_at(c, u.layer)
		if prop != null:
			block_props[prop.uid] = prop
	if not block_units.is_empty() or not block_props.is_empty():
		var own := 1
		for puid in block_props:
			if block_props[puid].def.spiky:
				own = SPIKY_DAMAGE
		for other_id in block_units:
			if BattleStats.has_flag(b.units[other_id], &"spiky_body"):
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
	if u.layer == Board.GROUND:
		BattleDamage.ground_triggers(b, u, Moment.LEAVE)      # being moved is movement
		if not u.is_alive():
			return true
	b.relocate(u, to)
	b.emit(&"displaced", {"who": u.id, "from": from, "to": to, "cause": cause})
	if falls:
		BattleDamage.apply_round(b, [{"unit": u.id, "base": 1, "type": BattleDamage.FALL, "source": "Fall"}])
		BattleDamage.defeat_step(b)
	if u.is_alive():
		BattleDamage.ground_triggers(b, u, Moment.ENTER, fresh)
	return true


## Moves a prop one square by force (user decision 2026-11-14: push and pull count for props).
## A `heavy` prop cannot be moved. A blocked move (board edge, monster, other prop) is no move and
## is one collision: the prop takes 1, a monster in the way takes 1 (2 from a `spiky` prop; with
## another prop in the way takes 1 (heavy none). Ground and zones never act on a
## prop and nothing triggers when it is entered. Returns true if it moved.
static func shove_prop(b: Battle, prop: BoardProp, dir: Vector2i, cause: String) -> bool:
	if prop == null or prop.hp <= 0 or dir == Vector2i.ZERO:
		return false
	if prop.def.heavy:
		b.emit(&"unmoved", {"prop": prop.def.id, "pos": prop.pos, "reason": "heavy"})
		return false
	var to := prop.pos + dir
	var blocker_unit: BattleUnit = null
	var blocker_prop: BoardProp = null
	if b.board.in_bounds(to):
		blocker_unit = b.unit_at(to, Board.GROUND)
		blocker_prop = b.board.prop_at(to, Board.GROUND)
	var sprung := BattleProps.new_step()
	if blocker_prop != null and blocker_unit == null and BattleBoardOps.springs(prop.def, blocker_prop):
		sprung = BattleBoardOps.spring_at(b, prop.def, to)     # the prop rolls onto the trap and springs it
		blocker_prop = null
	var blocked := not b.board.in_bounds(to) or blocker_unit != null or blocker_prop != null
	if blocked:
		b.emit(&"collision", {"prop": prop.def.id, "pos": prop.pos, "cause": cause,
			"units": [blocker_unit.id] if blocker_unit != null else [], "props": []})
		BattleBoardOps.damage_prop(b, prop, 1)
		if blocker_unit != null:
			BattleDamage.apply_round(b, [{"unit": blocker_unit.id, "base": SPIKY_DAMAGE if prop.def.spiky else 1,
				"type": BattleDamage.COLLISION, "source": "Collision"}])
		if blocker_prop != null and not blocker_prop.def.heavy:
			BattleBoardOps.damage_prop(b, blocker_prop, 1)
		BattleDamage.defeat_step(b)
		return false
	var from := prop.pos
	b.board.remove_prop(prop)
	prop.pos = to
	b.board.put_prop(prop)
	b.emit(&"prop_moved", {"from": from, "to": to, "prop": prop.def.id, "cause": cause})
	if not BattleProps.is_empty(sprung):
		BattleProps.run(b, sprung)
	return true
