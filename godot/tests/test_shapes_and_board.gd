extends GdUnitTestSuite
## Shape orientation counts follow GDD §7.7; placement follows the prototype.


func test_orientation_counts() -> void:
	assert_int(Shapes.orientations([&"I2"]).size()).is_equal(2)
	assert_int(Shapes.orientations([&"I3"]).size()).is_equal(2)
	assert_int(Shapes.orientations([&"L3"]).size()).is_equal(4)
	assert_int(Shapes.orientations([&"O4"]).size()).is_equal(1)
	assert_int(Shapes.orientations([&"T4"]).size()).is_equal(4)
	assert_int(Shapes.orientations([&"S4"]).size()).is_equal(4)
	assert_int(Shapes.orientations([&"L4"]).size()).is_equal(8)


func test_orientations_are_normalised() -> void:
	for o in Shapes.orientations([&"T4", &"L4"]):
		var min_x := 99
		var min_y := 99
		for c: Vector2i in o["cells"]:
			min_x = mini(min_x, c.x)
			min_y = mini(min_y, c.y)
		assert_int(min_x).is_equal(0)
		assert_int(min_y).is_equal(0)
		assert_bool(o["cells"].has(o["anchor"])).is_true()


func test_footprint_centres_on_anchor() -> void:
	var i3 := Shapes.orientations([&"I3"])[0]
	var fp := Shapes.footprint(i3, Vector2i(2, 2))
	assert_bool(fp.has(Vector2i(2, 2))).is_true()
	assert_int(fp.size()).is_equal(3)


func test_range_and_bounds() -> void:
	var b := Board.new(5)
	var i3 := Shapes.orientations([&"I3"])[0]
	assert_int(b.valid_placement(Board.Placement.AREA, Vector2i(0, 0), 3, i3, Vector2i(2, 2)).size()).is_equal(3)
	assert_int(b.valid_placement(Board.Placement.AREA, Vector2i(0, 0), 3, i3, Vector2i(4, 4)).size()).is_equal(0) # out of range
	assert_int(b.valid_placement(Board.Placement.AREA, Vector2i(4, 0), 3, i3, Vector2i(4, 0)).size()).is_equal(0) # off the board


func test_props_block_area_but_not_surge() -> void:
	var b := Board.new(5)
	b.at(Vector2i(2, 2)).object = {"name": "Rock", "hp": 3, "max_hp": 3}
	var i3 := Shapes.orientations([&"I3"])[0]
	var caster := Vector2i(2, 0)
	assert_int(b.valid_placement(Board.Placement.AREA, caster, 3, i3, Vector2i(2, 2)).size()).is_equal(0)
	assert_int(b.valid_placement(Board.Placement.SURGE, caster, 3, i3, Vector2i(2, 2)).size()).is_equal(3)
	assert_int(b.valid_placement(Board.Placement.PROP, caster, 3, i3, Vector2i(2, 2)).size()).is_equal(0)


func test_prop_needs_free_squares() -> void:
	var b := Board.new(5)
	b.occupants[Vector2i(2, 2)] = &"wolf"
	var i2 := Shapes.orientations([&"I2"])[0]
	assert_int(b.valid_placement(Board.Placement.PROP, Vector2i(2, 0), 3, i2, Vector2i(2, 2)).size()).is_equal(0)
