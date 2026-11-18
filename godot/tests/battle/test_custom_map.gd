extends GdUnitTestSuite
## Custom maps of the ingame battle (MapDef, MapEditor.paint, BattleBoards.build_map).


func after_test() -> void:
	BattleExperiment.reset()


## 5 wide, 4 high; the square (2, 1) is taken out; you start on the left column, the enemy on the right.
func _map() -> MapDef:
	var m := MapDef.new()
	m.id = &"t_map"
	m.display_name = "Test map"
	m.width = 5
	m.height = 4
	MapEditor.paint(m, "Remove square", Vector2i(2, 1))
	for y in 4:
		MapEditor.paint(m, "Start area: you", Vector2i(0, y))
	MapEditor.paint(m, "Start area: enemy", Vector2i(4, 0))
	MapEditor.paint(m, "Start area: enemy", Vector2i(4, 3))
	MapEditor.paint(m, "Dragon Vein", Vector2i(2, 2))
	MapEditor.paint(m, "Ground", Vector2i(1, 0), {"ground": &"lava"})
	MapEditor.paint(m, "Prop", Vector2i(3, 1), {"prop": &"earth_wall"})
	MapEditor.paint(m, "Zone", Vector2i(1, 3), {"zone": &"push_zone", "dir": Vector2i(1, 0), "rounds": 0})
	MapEditor.paint(m, "Zone", Vector2i(3, 3), {"zone": &"push_zone", "dir": Vector2i(-1, 0), "rounds": 2})
	return m


func _request(m: MapDef, mine: int, theirs: int) -> BattleRequest:
	var r := BattleRequest.new()
	var ids: Array[StringName] = [&"blaze_tiger", &"ember_hawk", &"dusk_moth", &"forge_golem", &"gloom_wolf"]
	r.player_team = BattleSetup.references(ids.slice(0, mine))
	r.enemy_team = BattleSetup.references(ids.slice(mine, mine + theirs))
	r.battle_kind = BattleRequest.INGAME
	r.map = m
	return r


func test_the_tools_paint_a_map_and_a_removed_square_loses_what_lay_on_it() -> void:
	var m := _map()
	assert_array(m.problems(BattleContent.shared())).is_empty()
	assert_bool(m.has_square(Vector2i(2, 1))).is_false()
	MapEditor.paint(m, "Ground", Vector2i(2, 1), {"ground": &"lava"})
	assert_bool(m.grounds.has(Vector2i(2, 1))).is_false()             # nothing lies on a missing square
	MapEditor.paint(m, "Remove square", Vector2i(1, 0))
	assert_bool(m.grounds.has(Vector2i(1, 0))).is_false()
	MapEditor.paint(m, "Restore square", Vector2i(1, 0))
	assert_bool(m.has_square(Vector2i(1, 0))).is_true()
	MapEditor.paint(m, "Start area: enemy", Vector2i(0, 0))           # a square lies in one start area only
	assert_bool(m.start_a.has(Vector2i(0, 0))).is_false()
	var empty := MapDef.new()
	assert_int(empty.problems(BattleContent.shared()).size()).is_equal(2)   # no start areas yet


func test_a_battle_on_the_map_has_its_outline_content_and_unequal_teams() -> void:
	var b := BattleSetup.build(_request(_map(), 3, 1))
	# 5×4 sits in the middle of a 5×5 grid: no shift in x, none in y (integer half of 1 is 0)
	assert_int(b.board.size).is_equal(5)
	assert_bool(b.board.in_bounds(Vector2i(2, 1))).is_false()         # the removed square
	assert_bool(b.board.in_bounds(Vector2i(0, 4))).is_false()         # outside the rectangle
	assert_object(b.board.at(Vector2i(2, 1))).is_null()
	assert_array(b.board.veins()).is_equal([Vector2i(2, 2)])
	assert_str(b.board.at(Vector2i(1, 0)).ground).is_equal("lava")
	assert_object(b.board.at(Vector2i(3, 1)).prop).is_not_null()
	assert_int(b.board.at(Vector2i(1, 3)).zone.duration).is_greater(1000)   # the whole battle
	assert_int(b.board.at(Vector2i(3, 3)).zone.duration).is_equal(2)
	assert_that(b.board.at(Vector2i(1, 3)).zone.dir).is_equal(Vector2i(1, 0))
	assert_int(b.living(0).size()).is_equal(3)
	assert_int(b.living(1).size()).is_equal(1)
	for u in b.living():
		assert_bool((b.start_areas[u.side] as Array).has(u.pos)).is_true()


func test_a_side_fields_no_more_monsters_than_its_start_area_holds() -> void:
	var b := BattleSetup.build(_request(_map(), 2, 3))
	assert_int(b.living(0).size()).is_equal(2)
	assert_int(b.living(1).size()).is_equal(2)                         # two enemy start squares
	var seen := {}
	for u in b.living():
		assert_bool(seen.has(u.pos)).is_false()
		seen[u.pos] = true


func test_a_missing_square_blocks_like_the_board_edge_and_the_battle_plays_to_its_end() -> void:
	var m := _map()
	var b := BattleSetup.build(_request(m, 2, 2))
	b.begin()
	var mover := b.active()
	for d in Board.CARDINAL:
		if not b.board.in_bounds(mover.pos + d):
			assert_str(b.check({"type": &"step", "to": mover.pos + d})).is_not_empty()
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	var guard := 0
	while not b.over and guard < 400:
		guard += 1
		AiBrain.play_turn(b, b.turn_owner, rng, true)
	assert_bool(b.over).is_true()
	for u in b.living():
		assert_bool(b.board.in_bounds(u.pos)).is_true()


func test_a_map_survives_saving_and_loading() -> void:
	var m := _map()
	var path := "user://t_map_roundtrip.tres"
	assert_int(ResourceSaver.save(m, path)).is_equal(OK)
	var back := ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as MapDef
	assert_int(back.width).is_equal(5)
	assert_array(back.missing).is_equal([Vector2i(2, 1)])
	assert_str(back.grounds[Vector2i(2, 2)]).is_equal("dragon_vein")
	assert_that(back.zones[Vector2i(1, 3)]["dir"]).is_equal(Vector2i(1, 0))
	assert_array(back.start_b).contains_exactly_in_any_order([Vector2i(4, 0), Vector2i(4, 3)])
	assert_str(MapDef.slug("  My First Map! ")).is_equal("my_first_map")
