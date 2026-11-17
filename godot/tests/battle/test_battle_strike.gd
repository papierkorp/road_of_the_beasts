extends GdUnitTestSuite
## Strike shapes, Kin twists and the body-relative variants (gdd_skills §3, §8.1).

const H := preload("res://tests/battle/helpers.gd")


func before_test() -> void:
	H.legacy_rules()


func after_test() -> void:
	BattleExperiment.reset()


func _offsets(shape: StringName, d: Vector2i, extension := 0) -> Array:
	var out := []
	for h in BattleShapes.hits(shape, d, extension):
		out.append(h["o"])
	out.sort()
	return out


func test_six_base_shapes_follow_the_orientation_table() -> void:
	assert_array(_offsets(&"jab", Vector2i(1, -1))).is_equal([Vector2i(1, -1)])
	assert_array(_offsets(&"pincer", H.RIGHT)).is_equal([Vector2i(-1, 0), Vector2i(1, 0)])
	assert_array(_offsets(&"arc", H.UP)).is_equal([Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1)])
	# diagonal Arc is the wedge (dx,0), (dx,dy), (0,dy)
	assert_array(_offsets(&"arc", Vector2i(1, -1))).is_equal([Vector2i(0, -1), Vector2i(1, -1), Vector2i(1, 0)])
	assert_array([_offsets(&"whirl", Vector2i.ZERO).size(), _offsets(&"cross", Vector2i.ZERO).size(),
		_offsets(&"storm", Vector2i.ZERO).size()]).is_equal([4, 4, 8])
	assert_array([BattleShapes.directions(&"jab").size(), BattleShapes.directions(&"pincer").size(), BattleShapes.directions(&"arc").size(),
		BattleShapes.directions(&"whirl").size()]).is_equal([8, 8, 8, 1])


func test_an_extension_adds_one_square_behind_every_square() -> void:
	# Jab +1 is the earlier Thrust and Diagonal Thrust in one: 8 directions
	assert_array(_offsets(&"jab", H.UP, 1)).is_equal([Vector2i(0, -2), Vector2i(0, -1)])
	assert_array(_offsets(&"jab", Vector2i(1, 1), 1)).is_equal([Vector2i(1, 1), Vector2i(2, 2)])
	assert_int(BattleShapes.directions(&"jab", 1).size()).is_equal(8)
	assert_array(_offsets(&"jab", H.RIGHT, 2)).is_equal([Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)])
	assert_array(_offsets(&"pincer", H.RIGHT, 1)).is_equal([Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(2, 0)])
	# Arc +1 is the earlier Cleave: the whole row moves on in the facing direction, straight only
	assert_array(_offsets(&"arc", H.UP, 1)).is_equal([Vector2i(-1, -2), Vector2i(-1, -1), Vector2i(0, -2),
		Vector2i(0, -1), Vector2i(1, -2), Vector2i(1, -1)])
	assert_bool(BattleShapes.is_legal_dir(&"arc", Vector2i(1, 1), 1)).is_false()
	assert_bool(BattleShapes.is_legal_dir(&"arc", Vector2i(1, 1), 0)).is_true()
	# Whirl +1 and Cross +1 are the earlier Long Whirl and Long Cross; Storm +1 is the star of 16
	assert_array(_offsets(&"whirl", Vector2i.ZERO, 1)).contains_exactly_in_any_order([Vector2i(0, -1), Vector2i(0, -2), Vector2i(1, 0), Vector2i(2, 0),
		Vector2i(0, 1), Vector2i(0, 2), Vector2i(-1, 0), Vector2i(-2, 0)])
	assert_int(_offsets(&"cross", Vector2i.ZERO, 1).size()).is_equal(8)
	assert_int(_offsets(&"storm", Vector2i.ZERO, 1).size()).is_equal(16)
	assert_bool(_offsets(&"storm", Vector2i.ZERO, 1).has(Vector2i(2, 1))).is_false()        # no square off the eight lines
	# every extended square knows the square in front of it (a solid prop there shields it)
	for h in BattleShapes.hits(&"storm", Vector2i.ZERO, 2):
		var o: Vector2i = h["o"]
		var unit := Vector2i(signi(o.x), signi(o.y))
		assert_that(h["front"]).is_equal(BattleShapes.NONE if o == unit else o - unit)
	# names and the draft AP the Strikes of the data were authored with
	assert_array([BattleShapes.shape_name(&"jab", 1), BattleShapes.shape_name(&"arc", 1), BattleShapes.shape_name(&"storm", 1)]).is_equal(["Thrust", "Cleave", "Storm +1"])
	assert_array([BattleShapes.draft_ap(&"jab"), BattleShapes.draft_ap(&"arc"), BattleShapes.draft_ap(&"storm"), BattleShapes.draft_ap(&"arc", 1),
		BattleShapes.draft_ap(&"storm", 1)]).is_equal([2, 3, 4, 5, -1])


func test_a_strike_costs_the_ap_on_its_card() -> void:
	var shove := H.content().skill(&"shove")
	assert_int(shove.cost()).is_equal(1)                                   # a Jab without damage: 1 AP on its card
	assert_array([H.content().skill(&"strike_jab").cost(), H.content().skill(&"strike_thrust").cost(), H.content().skill(&"thorn_lash").cost()]).is_equal([2, 3, 2])
	assert_str(H.content().skill(&"strike_thrust").shape_label()).is_equal("Thrust")


func test_retreat_exists_only_for_shapes_with_a_centre_direction() -> void:
	assert_that(BattleShapes.retreat_dir(&"jab", H.UP)).is_equal(H.DOWN)
	assert_that(BattleShapes.retreat_dir(&"jab", H.RIGHT, 1)).is_equal(H.LEFT)
	assert_that(BattleShapes.retreat_dir(&"arc", Vector2i(1, -1))).is_equal(Vector2i(-1, 1))
	assert_that(BattleShapes.retreat_dir(&"arc", H.UP, 1)).is_equal(H.DOWN)
	for shape: StringName in [&"pincer", &"whirl", &"cross", &"storm"]:
		for extension in [0, 1]:
			assert_that(BattleShapes.retreat_dir(shape, H.UP if shape == &"pincer" else Vector2i.ZERO, extension)).is_equal(Vector2i.ZERO)


func test_a_strike_pushes_any_monster_in_the_shape_allies_included_and_deals_no_damage() -> void:
	var b := H.battle([
		[0, Vector2i(3, 3), {"pace": 1.9, "ap": 4, "skills": [H.strike()]}],
		[0, Vector2i(3, 2), {"pace": 1.1}],
		[1, Vector2i(4, 4), {"pace": 1.1}],
	])
	b.begin()
	assert_bool(b.apply({"type": &"skill", "slot": 0, "dir": H.UP})).is_true()
	assert_that(H.unit(b, 1).pos).is_equal(Vector2i(3, 1))   # the ally is pushed too
	assert_int(H.unit(b, 1).hp).is_equal(5)                  # a Strike deals no damage to monsters
	assert_int(b.ap).is_equal(2)                 # Jab: 2 AP
	assert_bool(b.apply({"type": &"skill", "slot": 0, "dir": Vector2i(1, 1)})).is_true()   # diagonal
	assert_that(H.unit(b, 2).pos).is_equal(Vector2i(5, 5))
	assert_int(H.unit(b, 2).hp).is_equal(5)
	assert_that(H.unit(b, 0).pos).is_equal(Vector2i(3, 3))   # the striker is never struck


func test_a_strike_needs_one_square_on_the_board_and_drops_the_rest() -> void:
	var b := H.battle([[0, Vector2i(0, 3), {"pace": 1.9, "ap": 5, "skills": [H.strike(), H.strike("whirl")]}], [1, Vector2i(1, 3)]])
	b.begin()
	assert_str(b.check({"type": &"skill", "slot": 0, "dir": H.LEFT})).contains("no square of the shape")
	assert_str(b.check({"type": &"skill", "slot": 1, "dir": Vector2i.ZERO})).is_empty()          # half of the Whirl lies on the board
	assert_str(b.check({"type": &"skill", "slot": 0, "dir": H.RIGHT})).is_empty()
	assert_str(b.check({"type": &"skill", "slot": 0, "dir": Vector2i(2, 0)})).contains("cannot be aimed")


func test_a_solid_prop_takes_the_hit_and_blocks_the_cell_behind_it() -> void:
	var b := H.battle([[0, Vector2i(3, 5), {"pace": 1.9, "skills": [H.strike("thrust")]}], [1, Vector2i(3, 3)]])
	var lion := b.add_prop(&"stone_lion", Vector2i(3, 4))
	b.begin()
	assert_bool(b.apply({"type": &"skill", "slot": 0, "dir": H.UP})).is_true()
	assert_int(lion.hp).is_equal(1)              # 3 - 2
	assert_int(H.unit(b, 1).hp).is_equal(5)      # behind the prop: not hit
	assert_int(b.ap).is_equal(0)                 # Thrust: 3 AP


func test_collision_with_a_monster_damages_both_and_the_board_edge_the_pushed_one() -> void:
	var striker := {"pace": 1.9, "ap": 4, "skills": [H.strike()]}
	var b := H.battle([[0, Vector2i(1, 3), striker], [1, Vector2i(0, 3), {"hp": 9}]])
	b.begin()
	b.apply({"type": &"skill", "slot": 0, "dir": H.LEFT})
	assert_int(H.unit(b, 1).hp).is_equal(8)      # against the board edge: no move, 1
	assert_that(H.unit(b, 1).pos).is_equal(Vector2i(0, 3))
	var c := H.battle([[0, Vector2i(3, 3), striker], [1, Vector2i(3, 2), {"hp": 9}], [1, Vector2i(3, 1), {"hp": 9}]])
	c.begin()
	c.apply({"type": &"skill", "slot": 0, "dir": H.UP})
	assert_int(H.unit(c, 1).hp).is_equal(8)      # 1 collision
	assert_int(H.unit(c, 2).hp).is_equal(8)      # the monster it was pushed into: 1
	assert_that(H.unit(c, 1).pos).is_equal(Vector2i(3, 2))


func test_damage_modifiers_sum_in_one_step_and_are_floored_at_zero() -> void:
	var hide := H.passive("t_thick_hide", {"reduces_damage": ["strike", "collision"] as Array[String]})
	var hide2 := H.passive("t_thick_hide_2", {"reduces_damage": ["collision"] as Array[String]})
	var hide3 := H.passive("t_thick_hide_3", {"reduces_damage": ["collision"] as Array[String]})
	var b := H.battle([[0, Vector2i(3, 3), {"pace": 1.9, "ap": 4, "skills": [H.strike()]}], [1, Vector2i(3, 2), {"skills": [hide]}],
		[1, Vector2i(2, 3), {"skills": [hide, hide2, hide3]}]])
	b.add_prop(&"stone_lion", Vector2i(3, 1))    # spiky: 2 collision damage
	b.add_prop(&"stone_lion", Vector2i(1, 3))
	b.begin()
	b.apply({"type": &"skill", "slot": 0, "dir": H.UP})
	assert_int(H.unit(b, 1).hp).is_equal(4)      # 2 - 1
	b.apply({"type": &"skill", "slot": 0, "dir": H.LEFT})
	assert_int(H.unit(b, 2).hp).is_equal(5)      # 2 - 3, floored at 0
	assert_int(H.events_of(b, &"collision").size()).is_equal(2)   # the hit still happened


func test_a_strike_without_damage_pushes_adjacent_targets_outward_only() -> void:
	var shove := H.strike("storm", false)
	shove.strike_push = true
	shove.strike_damage = 0                      # movement-only variant: no damage at all
	var b := H.battle([
		[0, Vector2i(3, 3), {"pace": 1.9, "ap": 4, "skills": [shove]}],
		[1, Vector2i(3, 2)], [1, Vector2i(4, 4)], [1, Vector2i(2, 3)],
	])
	b.add_prop(&"clay_urn", Vector2i(4, 3))
	b.begin()
	assert_bool(b.apply({"type": &"skill", "slot": 0, "dir": Vector2i.ZERO})).is_true()
	assert_that(H.unit(b, 1).pos).is_equal(Vector2i(3, 1))
	assert_that(H.unit(b, 2).pos).is_equal(Vector2i(5, 5))   # diagonal, coupled to the hit offset
	assert_that(H.unit(b, 3).pos).is_equal(Vector2i(1, 3))
	assert_array([H.unit(b, 1).hp, H.unit(b, 2).hp, H.unit(b, 3).hp]).is_equal([5, 5, 5])
	assert_int(b.board.at(Vector2i(5, 3)).prop.hp).is_equal(1)   # no damage source, the prop is untouched, but pushed outward too (2026-11-14)


func test_strikes_reach_the_air_layer() -> void:
	var b := H.battle([[0, Vector2i(3, 3), {"pace": 1.9, "skills": [H.strike()]}], [1, Vector2i(3, 2), {"airborne": true}]])
	b.begin()
	b.apply({"type": &"skill", "slot": 0, "dir": H.UP})
	assert_that(H.unit(b, 1).pos).is_equal(Vector2i(3, 1))


# --- decision of 2026-11-15: damage and push are both optional parts of a Strike ---

func test_a_strike_without_push_damages_props_and_moves_nothing() -> void:
	var blow := H.strike("storm", false)
	blow.strike_push = false
	var b := H.battle([
		[0, Vector2i(3, 3), {"pace": 1.9, "ap": 4, "skills": [blow, H.strike()]}],
		[1, Vector2i(3, 2)], [1, Vector2i(4, 4)],
	])
	b.add_prop(&"clay_urn", Vector2i(4, 3))
	b.add_prop(&"stone_lion", Vector2i(2, 3))
	b.begin()
	assert_bool(b.apply({"type": &"skill", "slot": 0, "dir": Vector2i.ZERO})).is_true()
	assert_array([H.unit(b, 1).pos, H.unit(b, 2).pos]).is_equal([Vector2i(3, 2), Vector2i(4, 4)])   # nobody moved
	assert_array([H.unit(b, 1).hp, H.unit(b, 2).hp]).is_equal([4, 4])                               # nothing from the Strike, 1 from the urn that burst next to them
	assert_object(b.board.at(Vector2i(4, 3)).prop).is_null()                                        # the urn (1 HP) is destroyed in place
	assert_int(b.board.at(Vector2i(2, 3)).prop.hp).is_equal(1)                                      # the lion took 2 and stands
	assert_int(H.events_of(b, &"collision").size()).is_equal(0)
