class_name TestHelpers
extends RefCounted
## Builders for small hand-made battles in tests: explicit unit sheets on an empty board, so a
## test states every number it relies on. Nothing here is game content.

const UP := Vector2i(0, -1)
const DOWN := Vector2i(0, 1)
const LEFT := Vector2i(-1, 0)
const RIGHT := Vector2i(1, 0)


static func content() -> BattleContent:
	return BattleContent.shared()


static func skill(id: String) -> BattleSkillDef:
	return content().skill(StringName(id))


## A sheet with plain defaults (HP 5, Init 5.0, Move 2, Reach 2, TPR 1, AP 3, Beast, no skills).
## `skills` may list content ids or BattleSkillDef objects.
static func sheet(o: Dictionary = {}) -> UnitSheet:
	var s := UnitSheet.new()
	s.species_id = o.get("species", &"test")
	s.display_name = o.get("name", "Test")
	s.kin = o.get("kin", MonsterDef.Kin.BEAST)
	s.size = o.get("size", 1)
	s.airborne = o.get("airborne", false)
	s.hp = o.get("hp", 5)
	s.initiative = o.get("init", 5.0)
	s.movement = o.get("move", 2)
	s.reach = o.get("reach", 2)
	s.tpr = o.get("tpr", 1)
	s.ap = o.get("ap", 3)
	s.current_hp = o.get("current_hp", -1)
	s.init_bonus = o.get("init_bonus", 0.0)
	for x in o.get("skills", []):
		s.skills.append(x if x is BattleSkillDef else skill(String(x)))
	return s


## specs: [[side, pos, sheet overrides], ...] → units u0, u1, ... in that order (slot = the
## count of earlier units on the same side). Late-round pressure is off unless a test sets it.
static func battle(specs: Array, size: int = 7, p_content: BattleContent = null) -> Battle:
	var b := Battle.new(Board.new(size), p_content)
	b.voidscar_from = 999
	var slots := [0, 0]
	var i := 0
	for spec: Array in specs:
		var side: int = spec[0]
		var o: Dictionary = spec[2] if spec.size() > 2 else {}
		if not o.has("name"):
			o["name"] = "u%d" % i
		b.add_unit(BattleUnit.new(StringName("u%d" % i), sheet(o), side, slots[side], spec[1]))
		slots[side] += 1
		i += 1
	return b


static func unit(b: Battle, i: int) -> BattleUnit:
	return b.units[StringName("u%d" % i)]


## A Strike record with the given shape (Kin twist on by default).
static func strike(shape := "jab", kin_effect := true) -> BattleSkillDef:
	var s := BattleSkillDef.new()
	s.id = StringName("t_strike_" + shape)
	s.display_name = "Strike " + shape
	s.kind = BattleSkillDef.STRIKE
	s.strike_shape = shape
	s.kin_effect = kin_effect
	return s


## A residue-free test Surge (damage 3) with the given offsets.
## A marker skill: kind trap (`mode` "trap", the default of the tests) or kind surge ("timed").
static func surge(offsets: Array, damage := 3, mode := "trap") -> BattleSkillDef:
	var s := BattleSkillDef.new()
	s.id = &"t_surge"
	s.display_name = "Test Surge"
	s.kind = BattleSkillDef.TRAP if mode == "trap" else BattleSkillDef.SURGE
	s.surge_damage = damage
	var fp: Array[Vector2i] = []
	fp.assign(offsets)
	s.footprint = fp
	return s


static func zone_skill(effects: Array, offsets: Array = [Vector2i.ZERO], duration := 2, id := "t_zone") -> BattleSkillDef:
	var z := BattleZoneDef.new()
	z.id = StringName(id)
	z.display_name = id
	var list: Array[FieldEffect] = []
	list.assign(effects)
	z.effects = list
	var s := BattleSkillDef.new()
	s.id = StringName(id + "_skill")
	s.display_name = id
	s.kind = BattleSkillDef.ZONE
	s.zone = z
	s.duration = duration
	var fp: Array[Vector2i] = []
	fp.assign(offsets)
	s.footprint = fp
	return s


static func board_skill(ops: Array, offsets: Array = [Vector2i.ZERO], id := "t_board") -> BattleSkillDef:
	var s := BattleSkillDef.new()
	s.id = StringName(id)
	s.display_name = id
	s.kind = BattleSkillDef.GROUND
	var list: Array[BoardOp] = []
	list.assign(ops)
	s.board_ops = list
	var fp: Array[Vector2i] = []
	fp.assign(offsets)
	s.footprint = fp
	return s


static func passive(id: String, props: Dictionary) -> BattleSkillDef:
	var s := BattleSkillDef.new()
	s.id = StringName(id)
	s.display_name = id
	s.kind = BattleSkillDef.PASSIVE
	for k in props:
		s.set(k, props[k])
	return s


## Places a zone square directly (level I unless given).
static func zone_on(b: Battle, p: Vector2i, def: BattleZoneDef, gid := 900, level := 1, dir := Vector2i.ZERO,
		anchor := Vector2i.ZERO, duration := 2) -> void:
	var z := BoardZone.new()
	z.def = def
	z.gid = gid
	z.level = level
	z.dir = dir
	z.anchor = anchor
	z.duration = duration
	b.board.at(p).zone = z


## Ends turns until the unit's next turn has started (or the battle is over).
static func until_turn_of(b: Battle, id: StringName) -> void:
	var guard := 0
	b.end_turn()
	while b.turn_owner != id and not b.over and guard < 40:
		b.end_turn()
		guard += 1


static func event_types(b: Battle) -> Array:
	var out := []
	for e in b.events:
		out.append(e["type"])
	return out


static func events_of(b: Battle, type: StringName) -> Array:
	var out := []
	for e in b.events:
		if e["type"] == type:
			out.append(e)
	return out
