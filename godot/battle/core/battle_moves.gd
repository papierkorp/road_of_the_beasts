class_name BattleMoves
extends RefCounted
## Voluntary movement of the caster (gdd_skills §3 Movement): flag profiles, not special cases.
## A profile is a Dictionary read from a movement skill or the universal Step:
##   path walk|line|free|teleport · objects/monsters/surges/height (what blocks) ·
##   ground_costs · distance_mod · fixed (a fixed distance that ignores Movement and slow)
##
## Walk moves square by square in the four cardinal directions and processes every entered
## square; line (eight directions), free and teleport only count the landing square.
## Air-layer monsters fly: only air-layer occupants and the board edge block, every square
## costs 1 and ground is ignored (gdd_battle §4.3).

## Step and slotted movement cost 1 AP (build rule since 2026-11-12, T38; the GDD drafts said 2).
const STEP_AP := 1


## Step cost in play (a test switch may lower it).
static func step_ap() -> int:
	return BattleExperiment.step_ap if BattleExperiment.step_ap > 0 else STEP_AP
const WALK_DIRS: Array[Vector2i] = Board.CARDINAL


static func step_profile() -> Dictionary:
	return {"path": "walk", "objects": true, "monsters": true, "surges": true, "height": false,
		"ground_costs": false, "distance_mod": 0, "fixed": 1}


static func profile_of(s: BattleSkillDef) -> Dictionary:
	return {"path": s.move_path, "objects": s.blocked_by_objects, "monsters": s.blocked_by_monsters,
		"surges": s.blocked_by_surges, "height": s.blocked_by_height, "ground_costs": s.ground_costs,
		"distance_mod": s.distance_mod, "fixed": s.fixed_distance}


static func distance(b: Battle, u: BattleUnit, prof: Dictionary) -> int:
	if int(prof["fixed"]) > 0:
		return int(prof["fixed"])
	return maxi(1, BattleStats.movement(b, u) + int(prof["distance_mod"]))


## Squares newly covered when the body moves from `from` to `to`.
static func fresh_cells(u: BattleUnit, from: Vector2i, to: Vector2i) -> Array[Vector2i]:
	var old := u.cells_at(from)
	var out: Array[Vector2i] = []
	for c in u.cells_at(to):
		if not old.has(c):
			out.append(c)
	return out


static func _in_bounds(b: Battle, u: BattleUnit, origin: Vector2i) -> bool:
	return b.board.in_bounds(origin) and b.board.in_bounds(origin + Vector2i(u.size - 1, u.size - 1))


## May the body pass over `origin` on its way (path blockers of the profile)?
static func _passable(b: Battle, u: BattleUnit, origin: Vector2i, prof: Dictionary) -> bool:
	if not _in_bounds(b, u, origin):
		return false
	var flying := u.layer == Board.AIR
	var through_props: bool = not prof["objects"] or (not flying and BattleStats.phases(u))
	for c in u.cells_at(origin):
		var cell := b.board.at(c)
		if _walled(b, cell):
			return false
		if not through_props or flying:
			if b.board.prop_at(c, u.layer) != null:
				return false
		var other := b.board.unit_id_at(c, u.layer)
		if other != &"" and other != u.id and (prof["monsters"] or flying):
			return false
	return true


## Test switch surge_wall: a square of a charging timed Surge lets no movement in.
static func _walled(b: Battle, cell: BoardCell) -> bool:
	if not BattleExperiment.surge_wall or cell == null or cell.surge < 0:
		return false
	var s := b.surge_by_id(cell.surge)
	return s != null and s.turns_left >= 0


## May the body stop on `origin`? Ignoring path blockers never permits an occupied landing.
static func _landable(b: Battle, u: BattleUnit, origin: Vector2i, prof: Dictionary) -> bool:
	if not _in_bounds(b, u, origin):
		return false
	var flying := u.layer == Board.AIR
	for c in u.cells_at(origin):
		var cell := b.board.at(c)
		if _walled(b, cell):
			return false
		if b.board.prop_at(c, u.layer) != null:
			return false
		var other := b.board.unit_id_at(c, u.layer)
		if other != &"" and other != u.id:
			return false
		if not flying and prof["height"] and cell.is_mountain():
			return false
	return true


## Movement points for one cardinal step: the highest cost among the newly covered squares;
## climbing costs 2 as soon as any covered square climbs (gdd_battle §4.3).
static func _step_cost(b: Battle, u: BattleUnit, from: Vector2i, to: Vector2i, prof: Dictionary) -> int:
	if u.layer == Board.AIR or not prof["ground_costs"]:
		return 1
	var cost := 1
	for c in fresh_cells(u, from, to):
		var g := b.content.ground(b.board.at(c).ground)
		if g != null:
			cost = maxi(cost, g.move_cost)
	var d := to - from
	for c in u.cells_at(from):
		if b.board.at(c + d).height > b.board.at(c).height:
			cost = maxi(cost, 2)
	return cost


static func _entry_harm(b: Battle, u: BattleUnit, from: Vector2i, to: Vector2i) -> int:
	if u.layer == Board.AIR:
		return 0
	return BattleDamage.ground_harm(b, u, GroundTrigger.ON_ENTER, fresh_cells(u, from, to)) \
		+ BattleDamage.ground_harm(b, u, GroundTrigger.ON_LEAVE, u.cells_at(from))


## Reachable destinations: {origin: {cost, harm, path}}. `path` lists the origins entered in
## order (walk) or only the landing square. Among equal destinations the route with the least
## net entry harm wins, then the cheapest, then the first found in a fixed search order.
static func options(b: Battle, u: BattleUnit, prof: Dictionary) -> Dictionary:
	var out := {}
	if not u.is_alive() or BattleStats.is_rooted(u):
		return out
	var flying := u.layer == Board.AIR
	if not flying and prof["height"]:
		for c in u.cells():
			if b.board.at(c).is_mountain():
				return out                    # cannot start the move on a Mountain
	var dist := distance(b, u, prof)
	match String(prof["path"]) if not flying else "walk":
		"walk":
			_walk(b, u, prof, dist, out)
		"line":
			for d in Board.RING8:
				for k in range(1, dist + 1):
					var n: Vector2i = u.pos + d * k
					if not _passable_line(b, u, n, prof):
						break
					if _landable(b, u, n, prof):
						out[n] = {"cost": k, "harm": _entry_harm(b, u, u.pos, n), "path": [n]}
		"free":
			var seen := {u.pos: 0}
			var frontier: Array[Vector2i] = [u.pos]
			while not frontier.is_empty():
				var cur: Vector2i = frontier.pop_front()
				for d in WALK_DIRS:
					var n: Vector2i = cur + d
					if seen.has(n) or seen[cur] + 1 > dist or not _passable(b, u, n, prof):
						continue
					seen[n] = seen[cur] + 1
					frontier.append(n)
					if _landable(b, u, n, prof):
						out[n] = {"cost": seen[n], "harm": _entry_harm(b, u, u.pos, n), "path": [n]}
		"teleport":
			for y in range(u.pos.y - dist, u.pos.y + dist + 1):
				for x in range(u.pos.x - dist, u.pos.x + dist + 1):
					var n := Vector2i(x, y)
					if n != u.pos and _landable(b, u, n, prof):
						out[n] = {"cost": Board.chebyshev(u.pos, n), "harm": _entry_harm(b, u, u.pos, n), "path": [n]}
	return out


## A line ignores the blockers its profile drops; only the board edge always stops it.
static func _passable_line(b: Battle, u: BattleUnit, origin: Vector2i, prof: Dictionary) -> bool:
	if not _in_bounds(b, u, origin):
		return false
	if prof["objects"] or prof["monsters"] or prof["surges"]:
		return _passable(b, u, origin, prof)
	return true


static func _walk(b: Battle, u: BattleUnit, prof: Dictionary, dist: int, out: Dictionary) -> void:
	# label search over (origin, cost): keep the least harm per state
	var best := {}                            # "x,y,cost" -> harm
	var frontier: Array = [[u.pos, 0, 0, []]]
	while not frontier.is_empty():
		var cur: Array = frontier.pop_front()
		var p: Vector2i = cur[0]
		for d in WALK_DIRS:
			var n: Vector2i = p + d
			if n == u.pos or not _passable(b, u, n, prof):
				continue
			var cost: int = cur[1] + _step_cost(b, u, p, n, prof)
			if cost > dist:
				continue
			var harm: int = cur[2] + _entry_harm(b, u, p, n)
			var key := "%d,%d,%d" % [n.x, n.y, cost]
			if best.has(key) and best[key] <= harm:
				continue
			best[key] = harm
			var path: Array = cur[3].duplicate()
			path.append(n)
			if b.board.at(n).surge < 0:
				frontier.append([n, cost, harm, path])     # a walk ends on a trap square
			if _landable(b, u, n, prof):
				var old = out.get(n)
				if old == null or harm < old["harm"] or (harm == old["harm"] and cost < old["cost"]):
					out[n] = {"cost": cost, "harm": harm, "path": path}


## Performs the move to `to` (must be one of `options`). Entry effects fire on every entered
## square for walk and on the landing square otherwise. No fall damage for voluntary movement.
## `known_path` (from `options`, as the AI passes it) skips the second path search.
static func execute(b: Battle, u: BattleUnit, prof: Dictionary, to: Vector2i, label: String, known_path: Array = []) -> bool:
	var path := known_path
	if path.is_empty():
		var opts := options(b, u, prof)
		if not opts.has(to):
			return false
		path = opts[to]["path"]
	var from := u.pos
	b.emit(&"moved", {"who": u.id, "from": from, "to": to, "path": path.duplicate(), "skill": label})
	for n: Vector2i in path:
		if u.layer == Board.GROUND:
			BattleDamage.ground_triggers(b, u, GroundTrigger.ON_LEAVE)
			if not u.is_alive():
				break
		var fresh := fresh_cells(u, u.pos, n)
		b.relocate(u, n)
		if u.layer == Board.GROUND:
			BattleDamage.ground_triggers(b, u, GroundTrigger.ON_ENTER, fresh)
		if not u.is_alive():
			break
	return true


## Displacement caused by landing a movement skill (`impact_push`).
static func impact(b: Battle, u: BattleUnit, s: BattleSkillDef, from: Vector2i, to: Vector2i) -> void:
	if s.impact_push == "none" or not u.is_alive() or u.pos != to or u.size != 1:
		return
	var entries: Array = []
	if s.impact_push == "ahead":
		var v := to - from
		if v == Vector2i.ZERO or (v.x != 0 and v.y != 0 and absi(v.x) != absi(v.y)):
			return                            # only a straight or exactly diagonal run has a direction
		var d := Vector2i(signi(v.x), signi(v.y))
		var t := b.unit_at(to + d, u.layer)
		if t != null:
			entries.append({"unit": t.id, "dir": d, "cause": s.display_name, "multi": true})
	else:
		for d in Board.RING8:
			var t := b.unit_at(to + d, u.layer)
			if t != null:
				entries.append({"unit": t.id, "dir": d, "key": 0, "cause": s.display_name, "multi": true})
	if entries.is_empty():
		return
	BattleDisplace.resolve(b, entries)
	BattlePayload.settle(b)


## Self retreat after a Strike (gdd_skills §3): one square, only the destination is checked,
## moving up onto a Mountain is blocked, moving down causes no fall damage, entry effects
## fire. An illegal destination means the attacker stays: no alternative, no collision.
static func retreat(b: Battle, u: BattleUnit, dir: Vector2i) -> bool:
	var to := u.pos + dir
	var prof := step_profile()
	var ok := not BattleStats.is_rooted(u) and _landable(b, u, to, prof)
	if ok and u.layer == Board.GROUND:
		for c in u.cells():
			if b.board.at(c + dir).height > b.board.at(c).height:
				ok = false
	if not ok:
		b.emit(&"retreat_failed", {"who": u.id})
		return false
	var from := u.pos
	var fresh := fresh_cells(u, from, to)
	b.relocate(u, to)
	b.emit(&"retreated", {"who": u.id, "from": from, "to": to})
	if u.layer == Board.GROUND:
		BattleDamage.ground_triggers(b, u, GroundTrigger.ON_ENTER, fresh)
	return true
