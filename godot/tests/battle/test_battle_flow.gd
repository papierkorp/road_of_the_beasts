extends GdUnitTestSuite
## Turn queue, Surge clock, residue, Strike, displacement (GDD §4.3, §9.3, §11, §12).

const UP := Vector2i(0, -1)


## Ends turns until `id`'s next turn has started.
func _until_next_turn_of(b: Battle, id: StringName) -> void:
	b.end_turn()
	var guard := 0
	while b.turn_owner != id and not b.over and guard < 20:
		b.end_turn()
		guard += 1


func test_one_queue_for_both_sides_by_initiative_with_extra_turns() -> void:
	var b := TestHelpers.battle([
		[&"gloom_wolf", 0, Vector2i(0, 6)],           # 6.0
		[&"ember_hawk", 1, Vector2i(6, 0)],           # 9.0, TPR 2
		[&"forge_golem", 1, Vector2i(5, 0)],          # 2.0
	])
	b.begin()
	var order: Array = b.queue.map(func(e): return [e["id"], e["init"]])
	# the extra turn ties at 6.0 with the wolf; higher base initiative goes first (GDD §4.3)
	assert_array(order).is_equal([[&"m1", 9.0], [&"m1", 6.0], [&"m0", 6.0], [&"m2", 2.0]])


func test_initiative_ties_alternate_between_sides() -> void:
	var b := TestHelpers.battle([
		[&"gloom_wolf", 0, Vector2i(0, 6)],
		[&"gloom_wolf", 1, Vector2i(6, 0)],
	])
	b.begin()
	var first: StringName = b.queue[0]["id"]
	b.end_turn()
	b.end_turn()                                       # round 2
	assert_str(b.queue[0]["id"]).is_not_equal(first)


func test_surge_fires_at_the_start_of_the_casters_next_turn() -> void:
	var b := TestHelpers.battle([
		[&"gloom_wolf", 0, Vector2i(3, 6)],
		[&"forge_golem", 1, Vector2i(3, 3)],
		[&"moss_turtle", 1, Vector2i(6, 0)],
	])
	b.begin()
	assert_str(b.turn_owner).is_equal("m0")
	assert_bool(b.cast(&"m0", TestHelpers.skill("gloom_rift"), 0, Vector2i(3, 4))).is_true()   # vertical I3 3,3..3,5
	b.end_turn()                                       # golem, then turtle act — Surge still pending
	assert_bool(b.has_charging(&"m0")).is_true()
	b.end_turn()
	b.end_turn()                                       # round 2: wolf's turn starts → fires
	assert_str(b.turn_owner).is_equal("m0")
	assert_bool(b.has_charging(&"m0")).is_false()
	assert_int(b.monsters[&"m1"].hp).is_equal(8 - 3)


func test_slow_burn_waits_one_more_turn() -> void:
	var b := TestHelpers.battle([
		[&"moss_turtle", 0, Vector2i(3, 6), {"initiative": 9.0}],
		[&"gloom_wolf", 1, Vector2i(0, 0)],
	])
	b.begin()
	assert_bool(b.cast(&"m0", TestHelpers.skill("tidal_shell"), 0, Vector2i(3, 4), UP)).is_true()
	b.end_turn()
	b.end_turn()                                       # turtle's next turn: 1 left
	assert_bool(b.has_charging(&"m0")).is_true()
	b.end_turn()
	b.end_turn()                                       # turn after: fires
	assert_bool(b.has_charging(&"m0")).is_false()


func test_rift_lays_timed_blight_and_collapses_elevated() -> void:
	var b := TestHelpers.battle([
		[&"gloom_wolf", 0, Vector2i(3, 6), {"initiative": 9.0}],
		[&"forge_golem", 1, Vector2i(3, 3)],
	])
	b.board.at(Vector2i(3, 3)).elevated = true
	b.begin()
	assert_bool(b.cast(&"m0", TestHelpers.skill("gloom_rift"), 0, Vector2i(3, 4))).is_true()   # 3,3..3,5
	_until_next_turn_of(b, &"m0")
	assert_int(b.monsters[&"m1"].hp).is_equal(5)        # still damaged on Elevated
	assert_int(b.board.at(Vector2i(3, 3)).ground).is_equal(Square.GroundType.RUBBLE)
	assert_int(b.board.at(Vector2i(3, 5)).ground).is_equal(Square.GroundType.BLIGHT)
	assert_int(b.board.at(Vector2i(3, 5)).timer).is_equal(2)


func test_flood_cannot_reach_elevated_and_pushes_the_struck() -> void:
	var b := TestHelpers.battle([
		[&"grove_wisp", 0, Vector2i(0, 6), {"initiative": 9.0}],
		[&"gloom_wolf", 1, Vector2i(3, 3)],
		[&"forge_golem", 1, Vector2i(5, 3)],
	])
	b.board.at(Vector2i(5, 3)).elevated = true
	b.begin()
	var surge := TestHelpers.skill("spring_burst")             # L3, Lob, Flood
	var placed := false
	for pl in b.all_placements(&"m0", surge):
		if pl["cells"].has(Vector2i(3, 3)):
			placed = b.cast(&"m0", surge, pl["oi"], pl["anchor"], Vector2i(1, 0))
			break
	assert_bool(placed).is_true()
	while b.turn_owner != &"m0" or b.has_charging(&"m0") and b.round_number == 1:
		b.end_turn()
	assert_int(b.monsters[&"m1"].hp).is_equal(5 - 1)
	assert_vector(Vector2(b.monsters[&"m1"].pos)).is_equal(Vector2(4, 3))   # pushed east


func test_bite_reach_and_line_of_sight() -> void:
	var b := TestHelpers.battle([
		[&"gloom_wolf", 0, Vector2i(2, 2), {"reach": 2}],
		[&"forge_golem", 1, Vector2i(4, 2)],
	])
	b.begin()
	assert_bool(b.can_strike(&"m0", Vector2i(4, 2))).is_true()
	b.board.at(Vector2i(3, 2)).object = Square.make_prop("Rock")
	assert_bool(b.can_strike(&"m0", Vector2i(4, 2))).is_false()   # blocked
	assert_bool(b.can_strike(&"m0", Vector2i(3, 2))).is_true()    # the prop itself


func test_strike_costs_two_ap_pack_hunter_one() -> void:
	var b := TestHelpers.battle([
		[&"gloom_wolf", 0, Vector2i(2, 2)],
		[&"forge_golem", 1, Vector2i(3, 2)],
		[&"moss_turtle", 0, Vector2i(3, 3)],
	])
	b.begin()
	assert_int(b.strike_cost(&"m0", Vector2i(3, 2))).is_equal(1)   # ally next to the target
	b.monsters[&"m2"].hp = 0
	b.board.occupants.erase(Vector2i(3, 3))
	assert_int(b.strike_cost(&"m0", Vector2i(3, 2))).is_equal(2)


func test_tail_sweep_pushes_into_prop_for_collision() -> void:
	var b := TestHelpers.battle([
		[&"hollow_serpent", 0, Vector2i(2, 2), {"initiative": 9.0}],
		[&"gloom_wolf", 1, Vector2i(3, 2)],
	])
	b.board.at(Vector2i(4, 2)).object = Square.make_prop("Wall")
	b.begin()
	assert_bool(b.strike(&"m0", Vector2i(3, 2), Vector2i(1, 0))).is_true()
	assert_int(b.monsters[&"m1"].hp).is_equal(5 - 1 - 1)      # strike + collision
	assert_int(b.board.at(Vector2i(4, 2)).object["hp"]).is_equal(1)


func test_push_zone_fires_at_end_of_occupants_turn() -> void:
	var b := TestHelpers.battle([
		[&"gloom_wolf", 0, Vector2i(3, 3), {"initiative": 9.0}],
		[&"forge_golem", 1, Vector2i(6, 6)],
	])
	TestHelpers.zone_on(b, Vector2i(3, 3), "gale", &"m1", Vector2i(-1, 0))
	b.begin()
	assert_vector(Vector2(b.monsters[&"m0"].pos)).is_equal(Vector2(3, 3))
	b.end_turn()
	assert_vector(Vector2(b.monsters[&"m0"].pos)).is_equal(Vector2(2, 3))


func test_pushed_off_elevated_takes_fall_damage() -> void:
	var b := TestHelpers.battle([
		[&"gloom_wolf", 0, Vector2i(3, 3), {"initiative": 9.0}],
		[&"forge_golem", 1, Vector2i(6, 6)],
	])
	b.board.at(Vector2i(3, 3)).elevated = true
	TestHelpers.zone_on(b, Vector2i(3, 3), "gale", &"m1", Vector2i(1, 0))
	b.begin()
	b.end_turn()
	assert_int(b.monsters[&"m0"].hp).is_equal(4)


func test_thornbed_hurts_on_enter_lava_at_end_blight_at_start() -> void:
	var b := TestHelpers.battle([
		[&"gloom_wolf", 0, Vector2i(0, 0), {"initiative": 9.0}],
		[&"forge_golem", 1, Vector2i(6, 6)],
	])
	b.board.at(Vector2i(1, 0)).lay_ground(Square.GroundType.THORNBED, Square.PERMANENT)
	b.begin()
	assert_bool(b.move(&"m0", Vector2i(1, 0))).is_true()
	assert_int(b.monsters[&"m0"].hp).is_equal(4)
	b.board.at(Vector2i(1, 0)).lay_ground(Square.GroundType.LAVA, Square.PERMANENT)
	b.end_turn()
	assert_int(b.monsters[&"m0"].hp).is_equal(3)


func test_eruption_ignites_tree_which_burns_down_to_timed_lava() -> void:
	var b := TestHelpers.battle([
		[&"ember_hawk", 0, Vector2i(3, 6), {"initiative": 9.5, "tpr": 1}],
		[&"forge_golem", 1, Vector2i(0, 0)],
	])
	b.board.at(Vector2i(3, 4)).object = Square.make_prop("Tree")
	b.begin()
	assert_bool(b.cast(&"m0", TestHelpers.skill("cinder_dive"), 0, Vector2i(3, 4))).is_true()   # trail 3,5..3,3
	b.end_turn()
	b.end_turn()
	assert_bool(b.board.at(Vector2i(3, 4)).object["burning"]).is_true()
	b.end_turn()
	b.end_turn()                                       # next round end: burns down
	assert_object(b.board.at(Vector2i(3, 4)).object).is_null()
	assert_int(b.board.at(Vector2i(3, 4)).ground).is_equal(Square.GroundType.LAVA)


func test_twists_ring_pounce_trail_placement() -> void:
	var b := TestHelpers.battle([
		[&"forge_golem", 0, Vector2i(3, 3)],
		[&"blaze_tiger", 0, Vector2i(0, 0)],
		[&"ember_hawk", 1, Vector2i(6, 6)],
	])
	b.begin()
	assert_int(b.all_placements(&"m0", TestHelpers.skill("crucible")).size()).is_equal(1)
	assert_int(b.placement_cells(&"m0", TestHelpers.skill("crucible"), 0, Vector2i.ZERO).size()).is_equal(4)
	for pl in b.all_placements(&"m1", TestHelpers.skill("magma_pounce")):
		assert_int(Board.manhattan(Vector2i(0, 0), pl["anchor"])).is_equal(1)
	for pl in b.all_placements(&"m2", TestHelpers.skill("cinder_dive")):
		var near := 99
		for c: Vector2i in pl["cells"]:
			near = mini(near, Board.manhattan(Vector2i(6, 6), c))
		assert_int(near).is_equal(1)


func test_every_action_costs_ap_and_one_charging_surge() -> void:
	var b := TestHelpers.battle([
		[&"gloom_wolf", 0, Vector2i(3, 6), {"initiative": 9.0}],
		[&"forge_golem", 1, Vector2i(3, 0)],
	])
	b.begin()
	assert_bool(b.cast(&"m0", TestHelpers.skill("mire"), 0, Vector2i(3, 4))).is_true()
	assert_int(b.ap).is_equal(1)
	assert_bool(b.cast(&"m0", TestHelpers.skill("gloom_rift"), 0, Vector2i(3, 4))).is_true()
	assert_int(b.ap).is_equal(0)
	assert_bool(b.can_cast(&"m0", TestHelpers.skill("gloom_rift"))).is_false()


func test_dead_casters_surge_still_fires() -> void:
	var b := TestHelpers.battle([
		[&"dusk_moth", 0, Vector2i(3, 6), {"initiative": 9.0, "tpr": 1}],
		[&"forge_golem", 1, Vector2i(3, 3)],
	])
	b.begin()
	b.cast(&"m0", TestHelpers.skill("eclipse"), 0, Vector2i(3, 4))      # I4 vertical through the golem
	b.monsters[&"m0"].hp = 0
	b.board.occupants.erase(Vector2i(3, 6))
	b.end_turn()
	b.end_turn()
	assert_int(b.monsters[&"m1"].hp).is_less(8)
