class_name BattleProps
extends RefCounted
## What props do and when (build draft of 2026-11-14, user direction; not a GDD rule yet):
##   destroyed  at the removal step of a payload (the aftermath of gdd_battle §4.10)
##   hit        it lost HP and still stands: in the next board step
##   enter      a ground monster came onto a walkable prop (a trap): at once, the prop is used up
##   round_end  every round while it stands, in two steps (user decision 2026-11-15: the round end moves first and
##              acts afterwards): its pushes and pulls before round-end ground, everything else after it and
##              before the Dragon Veins
## A prop acts on squares it does not lie on: that is what sets it apart from ground and zones.
## Everything one moment collects resolves as one simultaneous step: damage, defeat, new props,
## ground, zones, then pushes and pulls.


static func new_step() -> Dictionary:
	return {"hits": [], "pushes": [], "spawns": [], "grounds": [], "zones": []}


static func is_empty(step: Dictionary) -> bool:
	for key in step:
		if not step[key].is_empty():
			return false
	return true


## Adds what `prop` does at `when` to `step` and returns how many of its lines that were. `part`: "" = all of
## them, "move" = only pushes and pulls, "act" = everything but pushes and pulls.
static func collect(b: Battle, prop: BoardProp, when: String, step: Dictionary, part := "") -> int:
	var lines := 0
	for a in prop.def.actions(when):
		if part != "" and (part == "move") != (a.op == "push" or a.op == "pull"):
			continue
		if when == Moment.ROUND_END and a.op == "damage":
			continue                              # it hits whoever ends a turn in its shape instead (turn_end_hits)
		lines += 1
		var per_unit := {}                    # unit id -> summed offset (once per prop and unit)
		var per_prop := {}                    # uid of another prop -> summed offset (pushes and pulls move props too)
		if a.op == "zone":
			b._next_gid += 1
		for o in a.offsets():
			var q: Vector2i = prop.pos + o
			if not b.board.in_bounds(q):
				continue
			match a.op:
				"spawn":
					var child := b.content.prop(a.spawn_prop)
					if o != Vector2i.ZERO and BattleBoardOps.can_place_prop(b, child, q):
						step["spawns"].append([child, q])
				"ground":
					step["grounds"].append([q, a.ground, prop.def.display_name])
				"zone":
					step["zones"].append([q, a.zone, a.zone_rounds, prop.pos, b._next_gid])
				_:
					for u in BattleBoardOps.units_in_reach_of(b, prop.def, q):
						per_unit[u.id] = per_unit.get(u.id, Vector2i.ZERO) + o
					if a.op == "push" or a.op == "pull":
						var other := b.board.prop_at(q, Board.GROUND)
						if other != null and other != prop and other.hp > 0:
							per_prop[other.uid] = per_prop.get(other.uid, Vector2i.ZERO) + o
		for uid in per_prop:
			var dp := BattlePayload._eight_dir(per_prop[uid])
			if a.op == "pull":
				dp = -dp
			step["pushes"].append({"prop": uid, "dir": dp, "key": 0, "cause": prop.def.display_name})
		for id in b.roster:
			if not per_unit.has(id):
				continue
			if a.op == "damage":
				step["hits"].append({"unit": id, "base": a.amount, "type": BattleDamage.AFTERMATH, "source": prop.def.display_name})
			elif a.op == "push":
				step["pushes"].append({"unit": id, "dir": BattlePayload._eight_dir(per_unit[id]), "key": 0, "cause": prop.def.display_name, "kind": "prop"})
			elif a.op == "pull":
				step["pushes"].append({"unit": id, "dir": -BattlePayload._eight_dir(per_unit[id]), "key": 0, "cause": prop.def.display_name, "kind": "prop"})
	return lines


## Everything of a step after its damage round and defeat step.
static func finish(b: Battle, step: Dictionary) -> void:
	for s: Array in step["spawns"]:
		BattleBoardOps.place_prop(b, s[0], s[1])
	for g: Array in step["grounds"]:
		var c := b.board.at(g[0])
		if c != null and not c.is_mountain():
			BattleBoardOps.lay_ground(b, c, g[1], g[2])
	for z: Array in step["zones"]:
		var zdef := b.content.zone(z[1])
		if zdef != null:
			BattleBoardOps.land_zone(b, b.board.at(z[0]), zdef, z[4], &"", z[2], Vector2i.ZERO, z[3])
	BattleDisplace.resolve(b, step["pushes"])


static func run(b: Battle, step: Dictionary) -> void:
	BattleDamage.apply_round(b, step["hits"])
	BattleDamage.defeat_step(b)
	finish(b, step)


static func has_pending_hits(b: Battle) -> bool:
	for prop in b.board.props():
		if prop.struck:
			return true
	return false


## Props that lost HP and still stand act now, all of them in one step.
static func resolve_hits(b: Battle) -> void:
	var step := new_step()
	for prop in b.board.props():
		if not prop.struck:
			continue
		prop.struck = false
		if prop.hp > 0:
			collect(b, prop, Moment.HIT, step)
	if not is_empty(step):
		run(b, step)


## A ground monster came onto `cells`: every trap there springs and is used up.
static func enter(b: Battle, u: BattleUnit, cells: Array[Vector2i]) -> void:
	if not u.is_alive() or u.layer != Board.GROUND:
		return
	var step := new_step()
	var sprung: Array[BoardProp] = []
	for c in cells:
		var prop := b.board.prop_at(c, Board.GROUND)
		if prop != null and prop.hp > 0 and prop.def.is_trap() and not sprung.has(prop):
			collect(b, prop, Moment.ENTER, step)
			sprung.append(prop)
	if sprung.is_empty():
		return
	for prop in sprung:
		prop.hp = 0
		prop.struck = false
		b.emit(&"trap_sprung", {"pos": prop.pos, "prop": prop.def.id, "who": u.id})
	run(b, step)
	BattlePayload.settle(b)


## Damage a ground monster would take from the traps on `cells` when it enters them (pure: used
## by the movement search and the AI; traps are open information).
static func enter_harm(b: Battle, u: BattleUnit, cells: Array[Vector2i]) -> int:
	var harm := 0
	for c in cells:
		var prop := b.board.prop_at(c, Board.GROUND)
		if prop == null or prop.hp <= 0 or not prop.def.is_trap():
			continue
		for a in prop.def.actions(Moment.ENTER):
			if a.op == "damage" and a.shape == "self":
				harm += BattleDamage.amount(b, u, a.amount, BattleDamage.AFTERMATH)
	return harm


## Round end: every standing prop with a round-end operation acts, all in one step.
## The round-end lines of every standing prop, one simultaneous step per call. `moves` true: their pushes and
## pulls (Storm Drum); false: everything else (the damage of an Ember Brazier, created props, ground, zones).
static func round_end(b: Battle, moves: bool) -> void:
	var step := new_step()
	var acted := 0
	for prop in b.board.props():
		if prop.hp > 0 and collect(b, prop, Moment.ROUND_END, step, "move" if moves else "act") > 0:
			acted += 1
	if acted == 0:
		return
	b.emit(&"props_acted", {"count": acted})
	run(b, step)
	BattlePayload.settle(b)


## Nothing but Dragon Veins and surrounding deals damage at the round end: the round-end damage line of every
## standing prop hits `u` when it ends its turn inside the prop's shape.
static func turn_end_hits(b: Battle, u: BattleUnit) -> Array:
	var hits: Array = []
	if not u.is_alive():
		return hits
	for prop in b.board.props():
		if prop.hp <= 0:
			continue
		for a in prop.def.actions(Moment.ROUND_END):
			if a.op != "damage":
				continue
			for o in a.offsets():
				if u.covers(prop.pos + o) and BattleBoardOps.units_in_reach_of(b, prop.def, prop.pos + o).has(u):
					hits.append({"unit": u.id, "base": a.amount, "type": BattleDamage.AFTERMATH, "source": prop.def.display_name})
					break
	return hits
