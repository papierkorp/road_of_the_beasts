extends GdUnitTestSuite
## GDD §7.3 (opposites, triangle rule) and §7.4 (ground).



func _cast(b: Board, skill_id: String, cells: Array[Vector2i]) -> Dictionary:
	return Rules.cast(b, &"x", TestHelpers.skill(skill_id), cells, "g", Vector2i.RIGHT, cells[0])


func test_opposite_effects_cancel_by_tag_not_name() -> void:
	var b := Board.new(5)
	var p: Array[Vector2i] = [Vector2i(1, 1)]
	_cast(b, "bog", p)
	_cast(b, "gale", p)                                   # pull vs push
	assert_object(b.at(p[0]).zone).is_null()
	_cast(b, "shockwave", p)
	_cast(b, "void_pull", p)                              # push vs pull, different names
	assert_object(b.at(p[0]).zone).is_null()


func test_same_zone_levels_up_to_three_other_replaces() -> void:
	var b := Board.new(5)
	var p: Array[Vector2i] = [Vector2i(0, 0)]
	for i in 4:
		_cast(b, "bark_veil", p)
	assert_int(b.at(p[0]).zone["level"]).is_equal(3)
	_cast(b, "mire", p)
	assert_str(b.at(p[0]).zone["def"].id).is_equal("mire")
	assert_int(b.at(p[0]).zone["level"]).is_equal(1)


func test_triangle_rule_clears_boosts_or_ignores() -> void:
	var b := Board.new(5)
	var p: Array[Vector2i] = [Vector2i(2, 2)]
	b.at(p[0]).lay_ground(Square.GroundType.THORNBED, Square.PERMANENT)
	_cast(b, "shockwave", p)                              # Force beats Nature → cleared
	assert_int(b.at(p[0]).ground).is_equal(Square.GroundType.PLAIN)
	assert_int(b.at(p[0]).attunement).is_equal(Aspect.Type.FORCE)
	b.at(p[0]).lay_ground(Square.GroundType.LAVA, Square.PERMANENT)
	_cast(b, "gale", p)                                   # Force beats Nature → Nature can't touch Lava
	assert_int(b.at(p[0]).ground).is_equal(Square.GroundType.LAVA)
	_cast(b, "mire", p)                                   # Dark beats Force → smothered
	assert_int(b.at(p[0]).ground).is_equal(Square.GroundType.PLAIN)
	b.at(p[0]).lay_ground(Square.GroundType.BLIGHT, Square.PERMANENT)
	_cast(b, "shade_veil", p)                             # same aspect → +1 level
	assert_int(b.at(p[0]).level).is_equal(2)


func test_ground_same_type_levels_permanent_beats_timed_other_replaces() -> void:
	var sq := Square.new()
	sq.lay_ground(Square.GroundType.LAVA, 2)
	assert_int(sq.timer).is_equal(2)
	sq.lay_ground(Square.GroundType.LAVA, Square.PERMANENT)
	assert_int(sq.level).is_equal(2)
	assert_int(sq.timer).is_equal(Square.PERMANENT)
	sq.lay_ground(Square.GroundType.THORNBED, 2)
	assert_int(sq.ground).is_equal(Square.GroundType.THORNBED)
	assert_int(sq.level).is_equal(1)
	assert_int(sq.attunement).is_equal(Aspect.Type.NATURE)


func test_voidscar_refuses_ground() -> void:
	var sq := Square.new()
	sq.ground = Square.GroundType.VOIDSCAR
	assert_bool(sq.lay_ground(Square.GroundType.LAVA, 2)).is_false()


func test_timed_ground_expires_to_plain_and_keeps_colour() -> void:
	var b := Board.new(5)
	b.at(Vector2i(1, 1)).lay_ground(Square.GroundType.BLIGHT, 2)
	Rules.tick_ground(b)
	assert_int(b.at(Vector2i(1, 1)).ground).is_equal(Square.GroundType.BLIGHT)
	Rules.tick_ground(b)
	assert_int(b.at(Vector2i(1, 1)).ground).is_equal(Square.GroundType.PLAIN)
	assert_int(b.at(Vector2i(1, 1)).attunement).is_equal(Aspect.Type.DARK)


func test_field_on_tree_ignites_instead_of_lava() -> void:
	var b := Board.new(5)
	b.at(Vector2i(1, 1)).object = Square.make_prop("Tree")
	var r := _cast(b, "lava_field", [Vector2i(1, 1)] as Array[Vector2i])
	assert_int(r["ignited"]).is_equal(1)
	assert_bool(b.at(Vector2i(1, 1)).object["burning"]).is_true()


func test_zones_may_lie_on_props_bark_veil_heals_once() -> void:
	var b := Board.new(5)
	b.at(Vector2i(1, 1)).object = Square.make_prop("Wall")
	var p: Array[Vector2i] = [Vector2i(1, 1)]
	_cast(b, "bark_veil", p)
	_cast(b, "bark_veil", p)
	assert_object(b.at(p[0]).zone).is_not_null()
	assert_int(b.at(p[0]).object["hp"]).is_equal(3)


func test_native_ground_doubles_own_bonus_and_ignores_minus() -> void:
	assert_int(Aspect.attunement_mod(Aspect.Type.DARK, Aspect.Type.DARK, true)).is_equal(2)
	assert_int(Aspect.attunement_mod(Aspect.Type.DARK, Aspect.Type.NATURE, true)).is_equal(0)
	assert_int(Aspect.attunement_mod(Aspect.Type.DARK, Aspect.Type.NATURE)).is_equal(-1)


func test_shape_counts_including_i4() -> void:
	assert_int(Shapes.orientations([&"I4"]).size()).is_equal(2)
	assert_int(Shapes.orientations([&"L4"]).size()).is_equal(8)
	assert_int(Shapes.orientations([&"T4"]).size()).is_equal(4)
