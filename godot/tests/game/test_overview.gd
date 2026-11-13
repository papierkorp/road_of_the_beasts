extends GdUnitTestSuite
## The debug tables (game/overview.gd) list every skill and monster record and filter by status.


func test_every_skill_record_has_a_row() -> void:
	var c := BattleContent.shared()
	var rows := Overview.skill_rows(c)
	assert_int(rows.size()).is_equal(c.skills.size())
	for r in rows:
		assert_str(r["name"]).is_not_empty()
		assert_str(r["effect"]).is_not_empty()
		assert_bool(r["in_game"]).is_equal(ContentStatus.in_game(c.skill(StringName(r["id"]))))


func test_every_monster_record_has_a_row() -> void:
	var c := BattleContent.shared()
	var rows := Overview.monster_rows(c)
	assert_int(rows.size()).is_equal(c.monsters.size())
	for r in rows:
		var m := c.monster(StringName(r["id"]))
		assert_str(r["name"]).is_equal(m.display_name)
		assert_int(r["hp"]).is_equal(m.hp)
		assert_str(r["kit"]).is_equal(m.kit_text())
		assert_float(r["points"]).is_greater(0.0)
		assert_str(r["shape"]).is_not_equal("—")
	# the shape label of MonsterDef follows StatShape.Id
	var golem: Array = rows.filter(func(row: Dictionary) -> bool: return row["id"] == "forge_golem")
	assert_str(golem[0]["shape"]).is_equal("Anvil")
	var shape_names: Array = []
	for shape in StatShape.rollable():
		shape_names.append(StatShape.shape_name(shape))
	for p in MonsterDef.new().get_property_list():
		if p["name"] == "reference_shape":
			assert_array(Array(String(p["hint_string"]).split(",")).slice(1)).is_equal(shape_names)


func test_stat_points_follow_the_draft_prices() -> void:
	# gdd_monsters §2.2: base line 1 / 1.0 / 1 / Reach 2 / TPR 1 / AP 2 = 15 points
	assert_float(Overview.stat_points(1, 1.0, 1, 2, 1, 2)).is_equal(15.0)
	assert_float(Overview.stat_points(5, 7.0, 4, 2, 1, 3)).is_equal(31.0)
	assert_float(Overview.stat_points(2, 9.5, 3, 1, 3, 5)).is_equal(50.5)
	assert_float(Overview.stat_points(5, 5.0, 2, 2, 1, 1)).is_equal(-1.0)


func test_the_stat_point_tooltip_lists_every_stat_and_the_total() -> void:
	var lines := Overview.stat_table(5, 7.0, 4, 2, 1, 3)
	assert_array(lines).is_equal([
		["Stat", "Value", "Price (draft)", "Points"],
		["HP", "5", "1 per point", "5"],
		["Init", "7", "1 per point", "7"],
		["Move", "4", "1 per point", "4"],
		["Reach", "2", "3 per point above 1", "3"],
		["TPR", "1", "steps 3 / 8 / 15", "3"],
		["AP", "3", "from AP 2: 6 / 9 / 14 / 21", "9"],
		["Total", "", "base 15 included", "31"],
	])
	var grid: GridContainer = auto_free(Overview.table_tooltip(lines))
	assert_int(grid.get_child_count()).is_equal(lines.size() * 4)


func test_the_screen_switches_filters_and_sorts() -> void:
	var c := BattleContent.shared()
	var screen: Overview = auto_free(load("res://game/overview.tscn").instantiate())
	add_child(screen)
	var all := screen.visible_rows()
	assert_int(all.size()).is_equal(c.skills.size())
	assert_int(screen._tree.get_root().get_child_count()).is_equal(all.size())
	screen._game_only.button_pressed = true
	for r in screen.visible_rows():
		assert_bool(r["in_game"]).is_true()
	screen._game_only.button_pressed = false
	screen._on_title_clicked(2, MOUSE_BUTTON_LEFT)      # AP ascending
	var by_ap := screen.visible_rows()
	for i in range(1, by_ap.size()):
		assert_int(by_ap[i]["ap"]).is_greater_equal(by_ap[i - 1]["ap"])

	screen.show_table("monsters")
	assert_int(screen._tree.columns).is_equal(Overview.TABLES["monsters"]["columns"].size())
	assert_int(screen._tree.get_root().get_child_count()).is_equal(c.monsters.size())
	var points_col: int = Overview.TABLES["monsters"]["columns"].map(func(col: Array) -> String: return col[0]).find("points")
	var first := screen._tree.get_root().get_child(0)
	assert_array(first.get_metadata(points_col)).has_size(8)
	assert_object(first.get_metadata(0)).is_null()
	screen._filter.select(1)                            # first kin that occurs
	screen._refresh()
	var kin := screen._filter.get_item_text(1)
	assert_array(screen.visible_rows()).is_not_empty()
	for r in screen.visible_rows():
		assert_str(r["kin"]).is_equal(kin)
