class_name BattleBoardOps
extends RefCounted
## Board state transitions (gdd_battle §4.5–§4.11): zone landing, ground, height and props.
## Each function changes one square and reports what happened; ordering between operations
## belongs to BattlePayload (gdd_battle §6.2 step 4).


# ---------- zones (gdd_battle §4.6) ----------

## What `def` does to a square that may already hold a zone: {kind, level}.
## kind: new | level | weaken | cancel | replace.
static func zone_outcome(cell: BoardCell, def: BattleZoneDef) -> Dictionary:
	var z := cell.zone
	if z == null:
		return {"kind": &"new", "level": 1}
	if z.def.id == def.id:
		return {"kind": &"level", "level": mini(BattleZoneDef.MAX_LEVEL, z.level + 1)}
	if z.def.opposes(def) or def.opposes(z.def):
		# levels subtract; the new cast arrives at level I
		return {"kind": &"cancel", "level": 0} if z.level <= 1 else {"kind": &"weaken", "level": z.level - 1}
	return {"kind": &"replace", "level": 1}


static func land_zone(b: Battle, cell: BoardCell, def: BattleZoneDef, gid: int, owner: StringName,
		duration: int, dir: Vector2i, anchor: Vector2i) -> StringName:
	var out := zone_outcome(cell, def)
	match out["kind"]:
		&"cancel":
			cell.zone = null
		&"weaken":
			cell.zone.level = out["level"]          # the higher zone stays, its clock unchanged
		_:
			var z := BoardZone.new()
			z.def = def
			z.gid = gid
			z.owner = owner
			z.level = out["level"]
			z.duration = duration
			z.dir = dir
			z.anchor = anchor
			cell.zone = z
	b.emit(&"zone_changed", {"pos": cell.pos, "result": out["kind"], "zone": def.id, "level": out["level"]})
	return out["kind"]


# ---------- ground (gdd_battle §4.7) ----------

## What laying `ground` does on this square: new | level | kept | replace | immutable.
static func ground_outcome(b: Battle, cell: BoardCell, ground: StringName) -> StringName:
	var cur := b.content.ground(cell.ground)
	if cur != null and cur.immutable:
		return &"immutable"
	if cell.ground == ground:
		var g := b.content.ground(ground)
		return &"level" if g != null and cell.level < g.max_level else &"kept"
	return &"new" if cell.ground == GroundDef.PLAIN else &"replace"


## Same type: hazards +1 level up to their maximum, blessed ground stays. Different type:
## replaced at level I. Voidscar is never replaced.
static func lay_ground(b: Battle, cell: BoardCell, ground: StringName, source := "") -> StringName:
	var out := ground_outcome(b, cell, ground)
	match out:
		&"level":
			cell.level += 1
		&"new", &"replace":
			cell.ground = ground
			cell.level = 1
	if out != &"kept" and out != &"immutable":
		var laid := b.content.ground(cell.ground)
		var fades := BattleExperiment.ground_rounds > 0 and cell.ground != GroundDef.PLAIN and (laid == null or not laid.immutable)
		cell.ground_until = b.round_number + BattleExperiment.ground_rounds - 1 if fades else 0
	if out != &"kept" and out != &"immutable":
		b.emit(&"ground_changed", {"pos": cell.pos, "ground": cell.ground, "level": cell.level,
			"result": out, "source": source})
	return out


# ---------- height (gdd_battle §4.7) ----------

## Mountain creation with its coupled reset to Plain (Voidscar stays). Needs a prop-free
## square; a second creation on a Mountain does nothing.
static func raise_mountain(b: Battle, cell: BoardCell) -> bool:
	if cell.is_mountain() or cell.prop != null or GroundDef.is_reserved(cell.ground):
		return false
	cell.height = 1
	var cur := b.content.ground(cell.ground)
	if cur == null or not cur.immutable:
		cell.ground = GroundDef.PLAIN
		cell.level = 1
		cell.ground_until = 0
	b.emit(&"mountain_raised", {"pos": cell.pos})
	return true


## Removes a Mountain. `keep_ground`: the destroying skill authors its own ground for the
## square (laid later in category (e)); otherwise the square becomes Rubble. Voidscar stays.
static func destroy_mountain(b: Battle, cell: BoardCell, keep_ground: bool) -> bool:
	if not cell.is_mountain():
		return false
	cell.height = 0
	var cur := b.content.ground(cell.ground)
	if not keep_ground and (cur == null or not cur.immutable):
		cell.ground = GroundDef.RUBBLE
		cell.level = 1
		cell.ground_until = 0
	b.emit(&"mountain_destroyed", {"pos": cell.pos})
	return true


# ---------- props (gdd_battle §4.9–§4.10) ----------

## True if a prop of this type may be placed here: its layers are free of props and monsters.
static func can_place_prop(b: Battle, def: PropDef, p: Vector2i) -> bool:
	if def == null or not b.board.in_bounds(p) or GroundDef.is_reserved(b.board.at(p).ground):
		return false
	for layer in [Board.GROUND, Board.AIR]:
		if not def.occupies(layer):
			continue
		if b.board.prop_at(p, layer) != null or b.board.unit_id_at(p, layer) != &"":
			return false
	return true


static func place_prop(b: Battle, def: PropDef, p: Vector2i) -> BoardProp:
	if not can_place_prop(b, def, p):
		return null
	var prop := BoardProp.new(b.next_prop_uid(), def, p)
	b.board.put_prop(prop)
	b.emit(&"prop_placed", {"pos": p, "prop": def.id})
	return prop


## A prop at 0 HP stays on the board until the next removal step; further damage changes nothing.
static func damage_prop(b: Battle, prop: BoardProp, amount: int) -> void:
	if prop == null or amount <= 0 or prop.hp <= 0:
		return
	prop.hp = maxi(0, prop.hp - amount)
	b.emit(&"prop_hit", {"pos": prop.pos, "prop": prop.def.id, "amount": amount, "hp": prop.hp})


## Relocate contract (gdd_skills §4): one eligible prop moves exactly one square orthogonally
## onto a legal empty square; heavy props are not eligible; an illegal move does nothing.
## The prop keeps its HP and triggers no aftermath. No approved source uses this yet.
static func relocate_prop(b: Battle, prop: BoardProp, dir: Vector2i) -> bool:
	if prop == null or prop.hp <= 0 or prop.def.heavy or not Board.CARDINAL.has(dir):
		return false
	var to := prop.pos + dir
	var from := prop.pos
	b.board.remove_prop(prop)
	if not can_place_prop(b, prop.def, to):
		b.board.put_prop(prop)
		return false
	prop.pos = to
	b.board.put_prop(prop)
	b.emit(&"prop_moved", {"from": from, "to": to, "prop": prop.def.id})
	return true


## Units an aftermath or aura of this prop reaches on square `p`: those on the prop's layer(s).
static func units_in_reach_of(b: Battle, def: PropDef, p: Vector2i) -> Array[BattleUnit]:
	var out: Array[BattleUnit] = []
	for layer in [Board.GROUND, Board.AIR]:
		if def.occupies(layer):
			var u := b.unit_at(p, layer)
			if u != null and not out.has(u):
				out.append(u)
	return out
