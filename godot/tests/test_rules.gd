extends GdUnitTestSuite
## Rules from GDD §7.3, §7.6, §11.2. Requires gdUnit4.

const F := Aspect.Type.FORCE
const D := Aspect.Type.DARK


func _skill(id: String) -> SkillDef:
	return load("res://data/skills/%s.tres" % id)


func _cast(b: Board, owner: StringName, id: String, cells: Array[Vector2i]) -> Dictionary:
	return Rules.cast(b, owner, _skill(id), cells, "g1")


func test_zone_new_levelup_replace_cancel() -> void:
	var b := Board.new(5)
	var p: Array[Vector2i] = [Vector2i(1, 1)]
	_cast(b, &"tiger", "bog", p)
	assert_int(b.at(p[0]).zone["level"]).is_equal(1)
	_cast(b, &"tiger", "bog", p)                       # same zone levels up
	assert_int(b.at(p[0]).zone["level"]).is_equal(2)
	_cast(b, &"tiger", "mire", p)                      # anything else replaces
	assert_str(b.at(p[0]).zone["def"].id).is_equal("mire")
	assert_int(b.at(p[0]).zone["level"]).is_equal(1)
	_cast(b, &"tiger", "bog", p)
	_cast(b, &"tiger", "gale", p)                      # opposed cancels
	assert_object(b.at(p[0]).zone).is_null()


func test_level_caps_at_three() -> void:
	var b := Board.new(5)
	var p: Array[Vector2i] = [Vector2i(0, 0)]
	for i in 5:
		_cast(b, &"tiger", "bark_veil", p)
	assert_int(b.at(p[0]).zone["level"]).is_equal(3)


func test_lava_levels_and_attunement() -> void:
	var b := Board.new(5)
	var p: Array[Vector2i] = [Vector2i(2, 2)]
	_cast(b, &"tiger", "lava_field", p)
	assert_int(b.at(p[0]).lava_level).is_equal(1)
	assert_int(b.at(p[0]).attunement).is_equal(F)
	_cast(b, &"tiger", "lava_field", p)
	_cast(b, &"tiger", "lava_field", p)
	assert_int(b.at(p[0]).lava_level).is_equal(2)      # capped


func test_bog_cools_and_gale_fans_lava() -> void:
	var b := Board.new(5)
	var p: Array[Vector2i] = [Vector2i(2, 2), Vector2i(3, 2)]
	_cast(b, &"tiger", "lava_field", p)
	var r := _cast(b, &"tiger", "bog", [p[0]])
	assert_int(r["cool"]).is_equal(1)
	assert_int(b.at(p[0]).ground).is_equal(Square.GroundType.RUBBLE)
	r = _cast(b, &"tiger", "gale", [p[1]])
	assert_int(r["fan"]).is_equal(1)
	assert_int(b.at(p[1]).lava_level).is_equal(2)


func test_surge_cannot_claim_enemy_surge_square() -> void:
	var b := Board.new(5)
	var p: Array[Vector2i] = [Vector2i(1, 1)]
	_cast(b, &"tiger", "magma_surge", p)
	var r := _cast(b, &"wolf", "gloom_surge", p)
	assert_int(r["counts"].get(&"lost", 0)).is_equal(1)
	assert_str(b.at(p[0]).surge["owner"]).is_equal("tiger")


func test_surge_damages_then_repaints() -> void:
	var b := Board.new(5)
	var p: Array[Vector2i] = [Vector2i(1, 1)]
	b.occupants[p[0]] = &"wolf"
	_cast(b, &"tiger", "magma_surge", p)
	var ev := Rules.fire_due(b, &"wolf")               # fires after the opponent's turn
	assert_int(ev.size()).is_equal(1)
	assert_int(ev[0]["amount"]).is_equal(3)
	assert_int(b.at(p[0]).attunement).is_equal(F)
	assert_object(b.at(p[0]).surge).is_null()


func test_own_attunement_adds_one_hostile_removes_one() -> void:
	var b := Board.new(5)
	var p: Array[Vector2i] = [Vector2i(1, 1)]
	b.occupants[p[0]] = &"wolf"
	b.at(p[0]).attunement = F
	_cast(b, &"tiger", "magma_surge", p)
	assert_int(Rules.fire_due(b, &"wolf")[0]["amount"]).is_equal(4)
	b.at(p[0]).attunement = D                          # Dark beats Force
	_cast(b, &"tiger", "magma_surge", p)
	assert_int(Rules.fire_due(b, &"wolf")[0]["amount"]).is_equal(2)


func test_elevated_blanks_surge_and_keeps_attunement() -> void:
	var b := Board.new(5)
	var p: Array[Vector2i] = [Vector2i(1, 1)]
	b.occupants[p[0]] = &"wolf"
	b.at(p[0]).elevated = true
	_cast(b, &"tiger", "magma_surge", p)
	assert_int(Rules.fire_due(b, &"wolf").size()).is_equal(0)
	assert_int(b.at(p[0]).attunement).is_equal(Aspect.Type.NONE)


func test_veil_absorbs_surge() -> void:
	var b := Board.new(5)
	var p: Array[Vector2i] = [Vector2i(1, 1)]
	b.occupants[p[0]] = &"wolf"
	_cast(b, &"wolf", "shade_veil", p)
	_cast(b, &"wolf", "shade_veil", p)                 # level 2: shield 3
	_cast(b, &"tiger", "magma_surge", p)
	var ev := Rules.fire_due(b, &"wolf")
	assert_str(ev[0]["type"]).is_equal("absorbed")


func test_prop_shatters_with_debris() -> void:
	var b := Board.new(5)
	var rock := Vector2i(2, 2)
	b.at(rock).object = {"name": "Tree", "hp": 2, "max_hp": 2}
	b.occupants[Vector2i(2, 3)] = &"wolf"              # neighbour of the tree
	b.at(Vector2i(1, 2)).elevated = true
	_cast(b, &"tiger", "magma_surge", [rock])
	var ev := Rules.fire_due(b, &"wolf")
	var types := ev.map(func(e): return e["type"])
	assert_bool(types.has(&"shatter")).is_true()
	assert_bool(types.has(&"collapse")).is_true()
	assert_int(b.at(rock).ground).is_equal(Square.GroundType.RUBBLE)
	var debris := ev.filter(func(e): return e["type"] == &"damage")
	assert_int(debris[0]["amount"]).is_equal(1)
	assert_bool(b.at(Vector2i(1, 2)).elevated).is_false()


func test_zone_expires_and_repaints() -> void:
	var b := Board.new(5)
	var p: Array[Vector2i] = [Vector2i(0, 0)]
	_cast(b, &"wolf", "mire", p)
	assert_int(Rules.tick_zones(b)).is_equal(0)
	assert_int(Rules.tick_zones(b)).is_equal(1)
	assert_object(b.at(p[0]).zone).is_null()
	assert_int(b.at(p[0]).attunement).is_equal(D)


func test_raise_ground_cleanses() -> void:
	var b := Board.new(5)
	var p: Array[Vector2i] = [Vector2i(2, 2)]
	_cast(b, &"tiger", "lava_field", p)
	_cast(b, &"tiger", "raise_ground", p)
	var sq := b.at(p[0])
	assert_bool(sq.elevated).is_true()
	assert_int(sq.ground).is_equal(Square.GroundType.PLAIN)
	assert_int(sq.attunement).is_equal(Aspect.Type.NONE)
