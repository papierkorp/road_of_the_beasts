extends GdUnitTestSuite
## Strike shapes, Kin twists and the body-relative variants (gdd_skills §3, §8.1).

const H := preload("res://tests/battle/helpers.gd")


func _offsets(shape: StringName, d: Vector2i) -> Array:
	var out := []
	for h in StrikeShapes.hits(shape, d):
		out.append(h["o"])
	out.sort()
	return out


func test_shape_offsets_follow_the_orientation_table() -> void:
	assert_array(_offsets(&"jab", Vector2i(1, -1))).is_equal([Vector2i(1, -1)])
	assert_array(_offsets(&"thrust", H.UP)).is_equal([Vector2i(0, -2), Vector2i(0, -1)])
	assert_array(_offsets(&"pincer", H.RIGHT)).is_equal([Vector2i(-1, 0), Vector2i(1, 0)])
	assert_array(_offsets(&"arc", H.UP)).is_equal([Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1)])
	# diagonal Arc is the wedge (dx,0), (dx,dy), (0,dy)
	assert_array(_offsets(&"arc", Vector2i(1, -1))).is_equal([Vector2i(0, -1), Vector2i(1, -1), Vector2i(1, 0)])
	assert_array(_offsets(&"cleave", H.UP)).is_equal([Vector2i(-1, -2), Vector2i(-1, -1), Vector2i(0, -2),
		Vector2i(0, -1), Vector2i(1, -2), Vector2i(1, -1)])
	assert_int(_offsets(&"storm", Vector2i.ZERO).size()).is_equal(8)
	assert_int(_offsets(&"long_cross", Vector2i.ZERO).size()).is_equal(8)
	# legal directions and battle-AP per shape
	assert_bool(StrikeShapes.is_legal_dir(&"thrust", Vector2i(1, 1))).is_false()
	assert_bool(StrikeShapes.is_legal_dir(&"diagonal_thrust", Vector2i(1, 1))).is_true()
	assert_bool(StrikeShapes.is_legal_dir(&"cleave", Vector2i(1, 1))).is_false()   # cardinal only
	assert_array([StrikeShapes.ap(&"jab"), StrikeShapes.ap(&"arc"), StrikeShapes.ap(&"storm"), StrikeShapes.ap(&"cleave")]).is_equal([2, 3, 4, 5])


func test_retreat_exists_only_for_shapes_with_a_centre_direction() -> void:
	assert_that(StrikeShapes.retreat_dir(&"jab", H.UP)).is_equal(H.DOWN)
	assert_that(StrikeShapes.retreat_dir(&"thrust", H.RIGHT)).is_equal(H.LEFT)
	assert_that(StrikeShapes.retreat_dir(&"arc", Vector2i(1, -1))).is_equal(Vector2i(-1, 1))
	assert_that(StrikeShapes.retreat_dir(&"cleave", H.UP)).is_equal(H.DOWN)
	for shape in [&"pincer", &"whirl", &"cross", &"storm", &"long_whirl", &"long_cross"]:
		assert_that(StrikeShapes.retreat_dir(shape, H.UP if shape == &"pincer" else Vector2i.ZERO)).is_equal(Vector2i.ZERO)


func test_jab_deals_two_to_any_monster_in_the_shape_allies_included() -> void:
	var b := H.battle([
		[0, Vector2i(3, 3), {"init": 9.0, "ap": 4, "skills": [H.strike()]}],
		[0, Vector2i(3, 2), {"init": 1.0}],
		[1, Vector2i(4, 4), {"init": 1.0}],
	])
	b.begin()
	assert_bool(b.apply({"type": &"skill", "slot": 0, "dir": H.UP})).is_true()
	assert_int(H.unit(b, 1).hp).is_equal(3)      # the ally
	assert_int(b.ap).is_equal(2)                 # Jab: 2 AP
	assert_bool(b.apply({"type": &"skill", "slot": 0, "dir": Vector2i(1, 1)})).is_true()   # diagonal
	assert_int(H.unit(b, 2).hp).is_equal(3)
	assert_int(H.unit(b, 0).hp).is_equal(5)      # the striker is never hit


func test_the_whole_shape_must_lie_on_the_board() -> void:
	var b := H.battle([[0, Vector2i(0, 3), {"init": 9.0, "ap": 5, "skills": [H.strike(), H.strike("whirl")]}], [1, Vector2i(1, 3)]])
	b.begin()
	assert_str(b.check({"type": &"skill", "slot": 0, "dir": H.LEFT})).contains("does not fit")
	assert_str(b.check({"type": &"skill", "slot": 1, "dir": Vector2i.ZERO})).contains("does not fit")
	assert_str(b.check({"type": &"skill", "slot": 0, "dir": H.RIGHT})).is_empty()
	assert_str(b.check({"type": &"skill", "slot": 0, "dir": Vector2i(2, 0)})).contains("cannot be aimed")


func test_a_solid_prop_takes_the_hit_and_blocks_the_cell_behind_it() -> void:
	var b := H.battle([[0, Vector2i(3, 5), {"init": 9.0, "skills": [H.strike("thrust")]}], [1, Vector2i(3, 3)]])
	var lion := b.add_prop(&"stone_lion", Vector2i(3, 4))
	b.begin()
	assert_bool(b.apply({"type": &"skill", "slot": 0, "dir": H.UP})).is_true()
	assert_int(lion.hp).is_equal(1)              # 3 - 2
	assert_int(H.unit(b, 1).hp).is_equal(5)      # behind the prop: not hit
	assert_int(b.ap).is_equal(0)                 # Thrust: 3 AP


func test_winged_dive_retreats_opposite_the_shape_and_fails_quietly() -> void:
	var winged := {"init": 9.0, "ap": 4, "kin": MonsterDef.Kin.WINGED, "skills": [H.strike()]}
	var b := H.battle([[0, Vector2i(3, 3), winged], [1, Vector2i(3, 2), {"hp": 9}]])
	b.set_ground(Vector2i(3, 4), &"thornbed", 1)
	b.begin()
	assert_bool(b.apply({"type": &"skill", "slot": 0, "dir": H.UP})).is_true()
	assert_int(H.unit(b, 1).hp).is_equal(7)
	assert_that(H.unit(b, 0).pos).is_equal(Vector2i(3, 4))   # one square opposite the hit
	assert_int(H.unit(b, 0).hp).is_equal(4)                  # the retreat is an entry: Thornbed I
	# an empty hit pattern still retreats; a blocked destination means it simply stays
	b.add_prop(&"stone_lion", Vector2i(3, 5))
	assert_bool(b.apply({"type": &"skill", "slot": 0, "dir": H.UP})).is_true()
	assert_that(H.unit(b, 0).pos).is_equal(Vector2i(3, 4))
	assert_int(H.unit(b, 0).hp).is_equal(4)                  # no collision damage for a failed retreat
	assert_int(H.events_of(b, &"retreat_failed").size()).is_equal(1)


func test_retreat_cannot_climb_and_takes_no_fall_damage() -> void:
	var winged := {"init": 9.0, "ap": 4, "kin": MonsterDef.Kin.WINGED, "skills": [H.strike()]}
	var b := H.battle([[0, Vector2i(3, 3), winged], [1, Vector2i(6, 6)]])
	b.board.at(Vector2i(3, 4)).height = 1
	b.begin()
	b.apply({"type": &"skill", "slot": 0, "dir": H.UP})
	assert_that(H.unit(b, 0).pos).is_equal(Vector2i(3, 3))   # up onto a Mountain: blocked
	b.apply({"type": &"skill", "slot": 0, "dir": H.LEFT})
	assert_that(H.unit(b, 0).pos).is_equal(Vector2i(4, 3))
	var c := H.battle([[0, Vector2i(3, 3), winged], [1, Vector2i(6, 6)]])
	c.board.at(Vector2i(3, 3)).height = 1
	c.begin()
	c.apply({"type": &"skill", "slot": 0, "dir": H.UP})
	assert_that(H.unit(c, 0).pos).is_equal(Vector2i(3, 4))   # down from a Mountain
	assert_int(H.unit(c, 0).hp).is_equal(5)                  # voluntary: no fall damage


func test_scaled_tail_sweep_pushes_in_the_chosen_direction_with_collision() -> void:
	var scaled := {"init": 9.0, "ap": 4, "kin": MonsterDef.Kin.SCALED, "skills": [H.strike()]}
	var b := H.battle([[0, Vector2i(3, 3), scaled], [1, Vector2i(3, 2), {"hp": 9}]])
	var lion := b.add_prop(&"stone_lion", Vector2i(5, 2))
	var urn := b.add_prop(&"bamboo_stand", Vector2i(3, 0))
	b.begin()
	assert_str(b.check({"type": &"skill", "slot": 0, "dir": H.UP})).contains("push direction")
	assert_bool(b.apply({"type": &"skill", "slot": 0, "dir": H.UP, "push_dir": H.RIGHT})).is_true()
	assert_that(H.unit(b, 1).pos).is_equal(Vector2i(4, 2))
	assert_int(H.unit(b, 1).hp).is_equal(7)
	# pushed into the heavy, spiky Stone Lion: 2 Strike + 2 collision, the heavy prop takes none
	assert_bool(b.apply({"type": &"skill", "slot": 0, "dir": Vector2i(1, -1), "push_dir": H.RIGHT})).is_true()
	assert_that(H.unit(b, 1).pos).is_equal(Vector2i(4, 2))
	assert_int(H.unit(b, 1).hp).is_equal(3)
	assert_int(lion.hp).is_equal(3)
	assert_int(urn.hp).is_equal(2)


func test_collision_with_a_monster_damages_both_and_the_board_edge_the_pushed_one() -> void:
	var scaled := {"init": 9.0, "ap": 4, "kin": MonsterDef.Kin.SCALED, "skills": [H.strike()]}
	var b := H.battle([[0, Vector2i(1, 3), scaled], [1, Vector2i(0, 3), {"hp": 9}], [1, Vector2i(0, 2), {"hp": 9}]])
	b.begin()
	b.apply({"type": &"skill", "slot": 0, "dir": H.LEFT, "push_dir": H.LEFT})
	assert_int(H.unit(b, 1).hp).is_equal(6)      # against the board edge: no move, 2 Strike + 1
	assert_that(H.unit(b, 1).pos).is_equal(Vector2i(0, 3))
	b.apply({"type": &"skill", "slot": 0, "dir": H.LEFT, "push_dir": H.UP})
	assert_int(H.unit(b, 1).hp).is_equal(3)      # 2 + 1 collision
	assert_int(H.unit(b, 2).hp).is_equal(8)      # the monster it was pushed into: 1
	assert_that(H.unit(b, 1).pos).is_equal(Vector2i(0, 3))


func test_swarm_gnaw_deals_four_to_props() -> void:
	var swarm := {"init": 9.0, "kin": MonsterDef.Kin.SWARM, "skills": [H.strike()]}
	var b := H.battle([[0, Vector2i(3, 3), swarm], [1, Vector2i(6, 6)]])
	b.add_prop(&"stone_lion", Vector2i(3, 2))
	b.set_ground(Vector2i(3, 2), &"lava", 1)
	b.begin()
	b.apply({"type": &"skill", "slot": 0, "dir": H.UP})
	assert_object(b.board.at(Vector2i(3, 2)).prop).is_null()    # 3 HP, 4 damage
	assert_str(b.board.at(Vector2i(3, 2)).ground).is_equal("rubble")   # the ground it leaves


func test_spirit_siphon_costs_the_target_one_initiative_next_round_only() -> void:
	var spirit := {"init": 9.0, "ap": 4, "kin": MonsterDef.Kin.SPIRIT, "skills": [H.strike()]}
	var b := H.battle([[0, Vector2i(3, 3), spirit], [1, Vector2i(3, 2), {"init": 6.0, "hp": 9}], [1, Vector2i(6, 6), {"init": 5.5}]])
	b.begin()
	b.apply({"type": &"skill", "slot": 0, "dir": H.UP})
	b.apply({"type": &"skill", "slot": 0, "dir": H.UP})         # same source: refresh, not -2
	for i in 3:
		b.end_turn()
	assert_int(b.round_number).is_equal(2)
	assert_array(b.queue.map(func(e): return [e["id"], e["init"]])).is_equal([[&"u0", 9.0], [&"u2", 5.5], [&"u1", 5.0]])
	for i in 3:
		b.end_turn()
	assert_int(b.round_number).is_equal(3)
	assert_array(b.queue.map(func(e): return e["id"])).is_equal([&"u0", &"u1", &"u2"])


func test_ancient_slam_destroys_the_mountain_under_the_target() -> void:
	var ancient := {"init": 9.0, "kin": MonsterDef.Kin.ANCIENT, "skills": [H.strike()]}
	var b := H.battle([[0, Vector2i(3, 3), ancient], [1, Vector2i(3, 2), {"hp": 9}]])
	b.board.at(Vector2i(3, 2)).height = 1
	b.set_ground(Vector2i(3, 2), &"lava", 1)
	b.begin()
	b.apply({"type": &"skill", "slot": 0, "dir": H.UP})
	assert_that(H.unit(b, 1).pos).is_equal(Vector2i(3, 1))   # every Strike pushes: off the Mountain
	assert_int(H.unit(b, 1).hp).is_equal(6)      # 2 Strike + 1 fall; the collapse finds nobody
	assert_bool(b.board.at(Vector2i(3, 2)).is_mountain()).is_false()   # the square where it was struck
	assert_str(b.board.at(Vector2i(3, 2)).ground).is_equal("rubble")   # no authored ground → Rubble


func test_damage_modifiers_sum_in_one_step_and_zero_damage_still_hits() -> void:
	var hide := H.passive("t_thick_hide", {"reduces_damage": ["strike", "collision"] as Array[String]})
	var hide2 := H.passive("t_thick_hide_2", {"reduces_damage": ["strike"] as Array[String]})
	var scaled := {"init": 9.0, "ap": 4, "kin": MonsterDef.Kin.SCALED, "skills": [H.strike()]}
	var b := H.battle([[0, Vector2i(3, 3), scaled], [1, Vector2i(3, 2), {"skills": [hide]}], [1, Vector2i(2, 3), {"skills": [hide, hide2]}]])
	b.add_prop(&"stone_lion", Vector2i(3, 0))
	b.begin()
	b.apply({"type": &"skill", "slot": 0, "dir": H.UP, "push_dir": H.UP})
	assert_int(H.unit(b, 1).hp).is_equal(4)      # 2 - 1
	assert_that(H.unit(b, 1).pos).is_equal(Vector2i(3, 1))
	b.apply({"type": &"skill", "slot": 0, "dir": H.LEFT, "push_dir": H.LEFT})
	assert_int(H.unit(b, 2).hp).is_equal(5)      # 2 - 2 = 0, floored
	assert_that(H.unit(b, 2).pos).is_equal(Vector2i(1, 3))   # the push still applies


func test_radial_push_variant_moves_adjacent_targets_outward_only() -> void:
	var shove := H.strike("storm", false)
	shove.radial_push = true
	shove.strike_damage = 0                      # movement-only variant: no damage at all
	var b := H.battle([
		[0, Vector2i(3, 3), {"init": 9.0, "ap": 4, "skills": [shove]}],
		[1, Vector2i(3, 2)], [1, Vector2i(4, 4)], [1, Vector2i(2, 3)],
	])
	b.add_prop(&"clay_urn", Vector2i(4, 3))
	b.begin()
	assert_bool(b.apply({"type": &"skill", "slot": 0, "dir": Vector2i.ZERO})).is_true()
	assert_that(H.unit(b, 1).pos).is_equal(Vector2i(3, 1))
	assert_that(H.unit(b, 2).pos).is_equal(Vector2i(5, 5))   # diagonal, coupled to the hit offset
	assert_that(H.unit(b, 3).pos).is_equal(Vector2i(1, 3))
	assert_array([H.unit(b, 1).hp, H.unit(b, 2).hp, H.unit(b, 3).hp]).is_equal([5, 5, 5])
	assert_int(b.board.at(Vector2i(4, 3)).prop.hp).is_equal(1)   # no damage source, the prop is untouched


func test_strikes_reach_the_air_layer() -> void:
	var b := H.battle([[0, Vector2i(3, 3), {"init": 9.0, "skills": [H.strike()]}], [1, Vector2i(3, 2), {"airborne": true}]])
	b.begin()
	b.apply({"type": &"skill", "slot": 0, "dir": H.UP})
	assert_int(H.unit(b, 1).hp).is_equal(3)
