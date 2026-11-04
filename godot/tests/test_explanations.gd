extends GdUnitTestSuite
## Previews and error messages: the player always learns what a cast does, or why it can't.


func _battle() -> Battle:
	var b := TestHelpers.battle([
		[&"gloom_wolf", 0, Vector2i(3, 3), {"initiative": 9.0}],
		[&"forge_golem", 1, Vector2i(3, 1)],
	])
	b.begin()
	return b


func test_out_of_range_names_the_distance() -> void:
	var b := _battle()
	var e := b.placement_error(&"m0", GameData.skill(&"mire"), 0, Vector2i(6, 6))
	assert_str(e).contains("out of range")
	assert_str(e).contains("range is 3")


func test_ground_skill_on_prop_explains_why() -> void:
	var b := TestHelpers.battle([
		[&"thorn_mites", 0, Vector2i(3, 3), {"initiative": 9.0}],
		[&"forge_golem", 1, Vector2i(6, 6)],
	])
	b.begin()
	b.board.at(Vector2i(3, 2)).object = Square.make_prop("Rock")
	var thorn := GameData.skill(&"thornbed")
	var found := ""
	for y in 7:
		for x in 7:
			if b.placement_cells(&"m0", thorn, 0, Vector2i(x, y)).is_empty():
				var e := b.placement_error(&"m0", thorn, 0, Vector2i(x, y))
				if e.contains("Rock"):
					found = e
	assert_str(found).contains("prop-free")


func test_second_surge_is_refused_with_reason() -> void:
	var b := _battle()
	b.cast(&"m0", GameData.skill(&"gloom_rift"), 0, Vector2i(3, 2))
	assert_str(b.cast_error(&"m0", GameData.skill(&"gloom_rift"))).contains("already has a charging Surge")


func test_preview_says_when_an_opposite_zone_cancels() -> void:
	var b := TestHelpers.battle([
		[&"grove_wisp", 0, Vector2i(3, 3), {"initiative": 9.0}],
		[&"forge_golem", 1, Vector2i(6, 6)],
	])
	b.begin()
	TestHelpers.zone_on(b, Vector2i(3, 2), "void_pull", &"m1")
	var gale := GameData.skill(&"gale")
	var cells := b.placement_cells(&"m0", gale, 0, Vector2i(3, 2))
	assert_bool(cells.is_empty()).is_false()
	var text := "\n".join(PackedStringArray(CastPreview.lines(b, b.monsters[&"m0"], gale, cells, Vector2i.RIGHT, Vector2i(3, 2))))
	assert_str(text).contains("CANCELS enemy Void Pull")
	assert_str(text).contains("push ↔ pull")


func test_preview_explains_triangle_rule_both_ways() -> void:
	var b := TestHelpers.battle([
		[&"grove_wisp", 0, Vector2i(3, 3), {"initiative": 9.0}],
		[&"forge_golem", 1, Vector2i(6, 6)],
	])
	b.begin()
	b.board.at(Vector2i(3, 2)).lay_ground(Square.GroundType.LAVA, Square.PERMANENT)
	var gale := GameData.skill(&"gale")
	var cells := b.placement_cells(&"m0", gale, 0, Vector2i(3, 2))
	var text := "\n".join(PackedStringArray(CastPreview.lines(b, b.monsters[&"m0"], gale, cells, Vector2i.RIGHT, Vector2i(3, 2))))
	assert_str(text).contains("Lava stays (Nature can't touch Force)")


func test_strike_error_reasons() -> void:
	var b := _battle()
	assert_str(b.strike_error(&"m0", Vector2i(3, 1))).contains("out of Reach")
	assert_str(b.strike_error(&"m0", Vector2i(0, 0))).contains("nothing to hit")


func test_square_rows_explain_ground_and_colour() -> void:
	var b := _battle()
	var sq := b.board.at(Vector2i(0, 0))
	sq.lay_ground(Square.GroundType.LAVA, 2)
	var text := InfoText.rows_to_text(InfoText.square_rows(b, sq))
	assert_str(text).contains("Lava I — 1 damage to whoever ENDS its turn here · 2 rounds left")
	assert_str(text).contains("Scorched (Force) — Force zones and Surges are +1 stronger here, Nature ones −1 weaker")
	sq.lay_ground(Square.GroundType.BLIGHT, Square.PERMANENT)
	text = InfoText.rows_to_text(InfoText.square_rows(b, sq))
	assert_str(text).contains("Cursed (Dark) — Dark zones and Surges are +1 stronger here, Force ones −1 weaker")
	assert_str(text).contains("STARTS its turn here · permanent")
