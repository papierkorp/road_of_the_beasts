class_name TestHelpers
extends RefCounted
## Builders for small hand-made battles in tests.


static func def(id: StringName, overrides: Dictionary = {}) -> MonsterDef:
	var d: MonsterDef = BattleSetup.load_def(id).duplicate()
	for k in overrides:
		d.set(k, overrides[k])
	return d


static func skill(id: String) -> SkillDef:
	return GameData.skill(StringName(id))


static func zone(id: String) -> ZoneDef:
	return GameData.zone(StringName(id))


## specs: [[id, side, pos, overrides?], ...]
static func battle(specs: Array, size: int = 7) -> Battle:
	var board := Board.new(size)
	var ms: Array[Monster] = []
	var i := 0
	for s in specs:
		var ov: Dictionary = s[3] if s.size() > 3 else {}
		ms.append(Monster.new(StringName("m%d" % i), def(s[0], ov), s[1], s[2]))
		i += 1
	return Battle.new(board, ms, 99)


static func zone_on(b: Battle, p: Vector2i, zone_id: String, owner: StringName, dir := Vector2i.UP, anchor := Vector2i.ZERO) -> void:
	b.board.at(p).zone = {"def": zone(zone_id), "gid": "t", "owner": owner, "level": 1,
		"duration": 2, "dir": dir, "anchor": anchor, "native": false}
