extends GdUnitTestSuite
## GameData registry, fixed shapes / Adaptive, and the hover cards.


func test_data_set_is_valid() -> void:
	GameData.reload()
	assert_array(GameData.problems()).is_empty()
	assert_int(GameData.monster_ids().size()).is_equal(9)
	assert_object(GameData.skill(&"gloom_rift")).is_not_null()
	assert_object(GameData.zone(&"mire")).is_not_null()


func test_roster_order_is_by_aspect() -> void:
	var ids := GameData.monster_ids()
	var last := Aspect.Type.NONE
	for id in ids:
		var a := GameData.monster(id).aspect
		assert_bool(a >= last).is_true()
		last = a


func test_shapes_are_fixed_without_adaptive() -> void:
	var b := TestHelpers.battle([
		[&"gloom_wolf", 0, Vector2i(3, 3)],
		[&"forge_golem", 1, Vector2i(6, 6)],
	])
	b.begin()
	var mire := GameData.skill(&"mire")                 # T4: 4 orientations
	assert_bool(b.can_rotate(&"m0", mire)).is_false()
	var a := b.placement_cells(&"m0", mire, 0, Vector2i(3, 2))
	var c := b.placement_cells(&"m0", mire, 2, Vector2i(3, 2))
	assert_array(a).is_equal(c)                         # requested orientation is ignored
	var orients := {}
	for pl in b.all_placements(&"m0", mire):
		orients[pl["oi"]] = true
	assert_int(orients.size()).is_equal(1)


func test_adaptive_may_rotate() -> void:
	var b := TestHelpers.battle([
		[&"grove_wisp", 0, Vector2i(3, 3)],
		[&"forge_golem", 1, Vector2i(6, 6)],
	])
	b.begin()
	var surge := GameData.skill(&"spring_burst")        # L3: 4 orientations
	assert_bool(b.can_rotate(&"m0", surge)).is_true()
	var orients := {}
	for pl in b.all_placements(&"m0", surge):
		orients[pl["oi"]] = true
	assert_int(orients.size()).is_equal(4)


func test_every_skill_and_monster_has_a_card() -> void:
	for id in GameData.skill_ids():
		var rows := InfoText.skill_rows(GameData.skill(id))
		assert_int(rows.size()).is_greater(5)
		assert_str(rows[0][0]).is_equal("Affects")
	for id in GameData.monster_ids():
		var rows := InfoText.monster_rows(GameData.monster(id))
		assert_int(rows.size()).is_greater(8)


func test_surge_card_shows_damage_and_residue() -> void:
	var text := InfoText.rows_to_text(InfoText.skill_rows(GameData.skill(&"tidal_shell")))
	assert_str(text).contains("Damage: 3 per square")
	assert_str(text).contains("Residue: Thornbed I for 2 rounds")
	assert_str(text).contains("Slow-burn")
