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


## Why Seal Ground cannot be laid on `p` by `side` ("" = it can).
static func lay_error(b: Battle, side: int, p: Variant) -> String:
	if not (p is Vector2i) or not b.board.in_bounds(p):
		return "choose one square on the board"
	var cell := b.board.at(p)
	var g := b.content.ground(cell.ground)
	if g != null and g.immutable:
		return "Seal Ground cannot lie on %s" % g.display_name
	if seal_of(b, side) != NONE:
		return "your Seal Ground already lies on the board (one at a time)"
	return ""


static func lay(b: Battle, side: int, def: TamerSkillDef, p: Vector2i) -> void:
	var cell := b.board.at(p)
	cell.ground = GROUND
	cell.level = 1
	cell.ground_until = 0
	b.seals[p] = {"side": side, "base": def.seal_base}
	b.emit(&"ground_changed", {"pos": p, "ground": GROUND, "level": 1, "result": &"new", "source": def.display_name})
	b.emit(&"seal_laid", {"pos": p, "side": side, "base": def.seal_base})


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
	return chance_at(int(b.seals[p]["base"]), u.hp)


static func chance_at(base: int, hp: int) -> int:
	return clampi(base - BattleExperiment.seal_step * maxi(0, hp - 1), 0, 100)


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


static func _use_up(b: Battle, p: Vector2i, u: BattleUnit) -> void:
	b.seals.erase(p)
	var cell := b.board.at(p)
	cell.ground = GroundDef.PLAIN
	cell.level = 1
	b.emit(&"caught", {"who": u.id, "pos": p})
	b.emit(&"ground_changed", {"pos": p, "ground": cell.ground, "level": 1, "result": &"reset", "source": "Seal"})
