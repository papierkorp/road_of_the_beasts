class_name BattleCatch
extends RefCounted
## Catching on the board (docs/battle_ingame.md §7): the ingame battle only.
##
## - A side without a tamer is wild (`Battle.wild`). A wild monster at 0 HP dies, unless it stands on Seal Ground of
##   the other side: then it is caught. A monster with a tamer never dies (its contract); it is only defeated.
## - Seal Ground (ground `seal`) is laid by the Seal tamer skill or a seal item: it replaces the ground of its square,
##   nothing changes it, it does not fade and it lies until it catches or the battle ends. One per tamer at a time.
## - A wild monster that ends its turn on Seal Ground is caught with a chance: the base of the seal at 1 HP,
##   `BattleExperiment.seal_step` points less for every further HP.
##
## The roll is the one chance of a battle. It is seeded (`Battle.roll_seed`, `Battle.rolls`), so a battle replays the
## same; a dry run (`Battle.muted`: previews, the AI) never rolls and shows only the chance.

const GROUND := &"seal"
const NONE := Vector2i(-999, -999)
## What the options of Seal lay (docs/overworld.md §5.4).
const WALL := &"earth_wall"
const PULL_ZONE := &"void_pull"
const PULL_ROUNDS := 2


## Why `def` cannot lay Seal Ground on `cells` for `side` ("" = it can): one square, or two adjacent ones for a
## Wide Seal.
static func lay_error(b: Battle, side: int, cells: Array, def: TamerSkillDef) -> String:
	var most := maxi(1, def.seal_squares if def != null else 1)
	if cells.is_empty() or cells.size() > most:
		return "choose one square on the board" if most == 1 else "choose one square or two adjacent squares"
	for p in cells:
		if not (p is Vector2i) or not b.board.in_bounds(p):
			return "choose a square on the board"
		var g := b.content.ground(b.board.at(p).ground)
		if g != null and g.immutable:
			return "Seal Ground cannot lie on %s" % g.display_name
	if cells.size() == 2:
		var d: Vector2i = cells[1] - cells[0]
		if absi(d.x) + absi(d.y) != 1:
			return "the two squares of a Wide Seal must touch over an edge"
	if seal_of(b, side) != NONE:
		return "your Seal Ground already lies on the board (one at a time)"
	return ""


static func lay(b: Battle, side: int, def: TamerSkillDef, cells: Array) -> void:
	var step := def.seal_step if def.seal_step > 0 else BattleExperiment.seal_step
	for p: Vector2i in cells:
		var cell := b.board.at(p)
		cell.ground = GROUND
		cell.level = 1
		cell.ground_until = 0
		b.seals[p] = {"side": side, "base": def.seal_base, "step": step}
		b.emit(&"ground_changed", {"pos": p, "ground": GROUND, "level": 1, "result": &"new", "source": def.display_name})
		b.emit(&"seal_laid", {"pos": p, "side": side, "base": def.seal_base})
	if def.seal_walls:                            # Walled Seal: an Earth Wall on every free square around it
		var wall := b.content.prop(WALL)
		for p: Vector2i in cells:
			for d in Board.RING8:
				var q: Vector2i = p + d
				if wall == null or cells.has(q) or not b.board.in_bounds(q) or b.any_unit_at(q) != null:
					continue
				var made := BattleBoardOps.place_prop(b, wall, q)
				if made != null:
					made.until = b.round_number + BoardProp.CREATED_ROUNDS - 1
	if def.seal_pull:                             # Drawing Seal: a pull zone toward it on its four neighbours
		var zone := b.content.zone(PULL_ZONE)
		for p: Vector2i in cells:
			for d in Board.CARDINAL:
				var q: Vector2i = p + d
				if zone != null and b.board.in_bounds(q) and not cells.has(q):
					b._next_gid += 1
					BattleBoardOps.land_zone(b, b.board.at(q), zone, b._next_gid, &"", PULL_ROUNDS, Vector2i.ZERO, p)


## The square of the Seal Ground `side` has on the board, or NONE.
static func seal_of(b: Battle, side: int) -> Vector2i:
	for p: Vector2i in b.seals:
		if int(b.seals[p]["side"]) == side:
			return p
	return NONE


## The square of an enemy Seal Ground under a wild monster, or NONE.
static func seal_under(b: Battle, u: BattleUnit) -> Vector2i:
	if not b.wild[u.side]:
		return NONE
	for c in u.cells():
		if b.seals.has(c) and int(b.seals[c]["side"]) != u.side:
			return c
	return NONE


## The chance in percent that `u` is caught at the end of its turn as it stands now; -1 = it stands on no Seal
## Ground it could be caught on.
static func chance(b: Battle, u: BattleUnit) -> int:
	var p := seal_under(b, u)
	if p == NONE or not u.is_alive():
		return -1
	return chance_at(int(b.seals[p]["base"]), u.hp, int(b.seals[p].get("step", BattleExperiment.seal_step)))


static func chance_at(base: int, hp: int, step := -1) -> int:
	return clampi(base - (step if step >= 0 else BattleExperiment.seal_step) * maxi(0, hp - 1), 0, 100)


## The end of a wild monster's turn: the roll.
static func turn_end(b: Battle, u: BattleUnit) -> void:
	var ch := chance(b, u)
	if ch < 0:
		return
	if b.muted or ch == 0:
		b.emit(&"catch_chance", {"who": u.id, "chance": ch})
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([b.roll_seed, b.rolls])
	b.rolls += 1
	var roll := rng.randi_range(1, 100)
	var caught := roll <= ch
	b.emit(&"catch_roll", {"who": u.id, "chance": ch, "roll": roll, "caught": caught})
	if caught:
		var p := seal_under(b, u)
		u.caught = true
		b.defeat(u)
		_use_up(b, p, u)


## Called by `Battle.defeat` before the monster leaves its square: a wild monster on enemy Seal Ground is caught,
## any other wild monster dies. Monsters with a tamer are only defeated.
static func on_defeat(b: Battle, u: BattleUnit) -> void:
	if u.caught or not b.wild[u.side]:
		return
	var p := seal_under(b, u)
	if p == NONE:
		u.died = true
		b.emit(&"died", {"who": u.id})
		return
	u.caught = true
	_use_up(b, p, u)


## A catch uses up the whole Seal Ground of its side: both squares of a Wide Seal.
static func _use_up(b: Battle, p: Vector2i, u: BattleUnit) -> void:
	var side := int(b.seals[p]["side"])
	b.emit(&"caught", {"who": u.id, "pos": p})
	for q: Vector2i in b.seals.keys():
		if int(b.seals[q]["side"]) != side:
			continue
		b.seals.erase(q)
		var cell := b.board.at(q)
		cell.ground = GroundDef.PLAIN
		cell.level = 1
		b.emit(&"ground_changed", {"pos": q, "ground": cell.ground, "level": 1, "result": &"reset", "source": "Seal"})
