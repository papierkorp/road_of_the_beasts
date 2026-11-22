extends GdUnitTestSuite
## The board rules of 2026-11-22 (docs/battle.md §4.2, §4.5, §4.6): a zone moves whoever arrives in it, a Dragon
## Vein damages its own square, ground damages props, and the two traps.

const H := preload("res://tests/battle/helpers.gd")


func before_test() -> void:
	H.legacy_rules()


func after_test() -> void:
	BattleExperiment.reset()


func _push_zone(b: Battle, p: Vector2i, dir: Vector2i) -> void:
	H.zone_on(b, p, H.content().zone(&"push_zone"), 900, 1, dir)


func test_a_step_into_a_push_zone_is_moved_on_at_once_and_only_once() -> void:
	var b := H.battle([[0, Vector2i(3, 5), {"pace": 1.9}], [1, Vector2i(6, 0)]])
	_push_zone(b, Vector2i(3, 4), H.UP)
	_push_zone(b, Vector2i(3, 3), H.UP)
	b.begin()
	b.apply({"type": &"step", "to": Vector2i(3, 4)})
	assert_that(H.unit(b, 0).pos).is_equal(Vector2i(3, 3))        # moved on once: the second zone does not chain
	b.end_turn()
	assert_that(H.unit(b, 0).pos).is_equal(Vector2i(3, 2))        # the move at the end of the turn comes on top


func test_a_step_against_the_current_is_thrown_back() -> void:
	var b := H.battle([[0, Vector2i(3, 5), {"pace": 1.9}], [1, Vector2i(6, 0)]])
	_push_zone(b, Vector2i(3, 4), H.DOWN)
	b.begin()
	b.apply({"type": &"step", "to": Vector2i(3, 4)})
	assert_that(H.unit(b, 0).pos).is_equal(Vector2i(3, 5))
	assert_int(b.ap).is_equal(2)                                  # the AP of the Step is spent


func test_a_zone_that_pushes_into_a_wall_is_a_collision_on_arriving() -> void:
	var b := H.battle([[0, Vector2i(3, 5), {"pace": 1.9}], [1, Vector2i(6, 0)]])
	_push_zone(b, Vector2i(3, 4), H.UP)
	var wall := b.add_prop(&"earth_wall", Vector2i(3, 3))
	b.begin()
	b.apply({"type": &"step", "to": Vector2i(3, 4)})
	assert_that(H.unit(b, 0).pos).is_equal(Vector2i(3, 4))
	assert_int(H.unit(b, 0).hp).is_equal(4)
	assert_int(wall.hp).is_equal(1)


func test_a_strike_into_a_zone_moves_two_squares() -> void:
	var b := H.battle([[0, Vector2i(3, 5), {"pace": 1.9, "skills": [H.strike("jab")]}], [1, Vector2i(3, 4)]])
	_push_zone(b, Vector2i(3, 3), H.UP)
	_push_zone(b, Vector2i(3, 2), H.UP)
	b.begin()
	b.apply({"type": &"skill", "slot": 0, "dir": H.UP})
	assert_that(H.unit(b, 1).pos).is_equal(Vector2i(3, 2))        # pushed 1, moved on 1, no chain
	assert_int(H.unit(b, 1).hp).is_equal(5)


func test_a_movement_skill_crosses_a_zone_and_counts_only_its_landing() -> void:
	var b := H.battle([[0, Vector2i(3, 5), {"pace": 1.9, "move": 4, "ap": 4, "skills": ["run"]}], [1, Vector2i(6, 0)]])
	_push_zone(b, Vector2i(3, 4), H.DOWN)
	_push_zone(b, Vector2i(3, 2), H.LEFT)
	b.begin()
	assert_bool(b.apply({"type": &"skill", "slot": 0, "to": Vector2i(3, 3)})).is_true()
	assert_that(H.unit(b, 0).pos).is_equal(Vector2i(3, 3))        # walked across the current
	assert_bool(b.apply({"type": &"step", "to": Vector2i(3, 2)})).is_true()
	assert_that(H.unit(b, 0).pos).is_equal(Vector2i(2, 2))


func test_a_dragon_vein_damages_the_monster_and_the_prop_on_it() -> void:
	var b := H.battle([[0, Vector2i(3, 3), {"pace": 1.9}], [1, Vector2i(6, 0)]])
	b.set_ground(Vector2i(3, 3), GroundDef.WELL)
	b.set_ground(Vector2i(1, 3), GroundDef.WELL)                  # nobody owns this one
	var wall := b.add_prop(&"earth_wall", Vector2i(1, 3))
	b.begin()
	b.end_turn()
	b.end_turn()
	assert_int(b.round_number).is_equal(2)
	assert_int(H.unit(b, 0).hp).is_equal(4)                       # its own vein costs it 1
	assert_int(H.unit(b, 1).hp).is_equal(4)                       # and still hits the nearest enemy
	assert_int(wall.hp).is_equal(1)
	b.end_turn()
	b.end_turn()
	assert_object(b.board.prop_at(Vector2i(1, 3), Board.GROUND)).is_null()   # the vein wore the wall away
	assert_int(H.unit(b, 0).hp).is_equal(3)


func test_end_of_turn_ground_damages_a_prop_at_the_round_end() -> void:
	var b := H.battle([[0, Vector2i(3, 6), {}], [1, Vector2i(3, 0), {}]])
	var wall := b.add_prop(&"earth_wall", Vector2i(3, 3))
	b.set_ground(Vector2i(3, 3), &"lava")
	b.begin()
	b.end_turn()
	b.end_turn()
	assert_int(b.round_number).is_equal(2)
	assert_int(wall.hp).is_equal(1)


func test_a_prop_on_damage_ground_is_a_bomb_with_a_clock() -> void:
	var b := H.battle([[0, Vector2i(3, 6), {}], [1, Vector2i(3, 2), {}]])
	b.add_prop(&"clay_urn", Vector2i(3, 3))
	b.set_ground(Vector2i(3, 3), &"lava")
	b.begin()
	b.end_turn()
	b.end_turn()
	assert_object(b.board.prop_at(Vector2i(3, 3), Board.GROUND)).is_null()
	assert_int(H.unit(b, 1).hp).is_equal(4)                       # the urn burst at the round end


func test_a_pushed_prop_takes_the_ground_it_leaves_and_enters() -> void:
	var b := H.battle([[0, Vector2i(0, 6), {}], [1, Vector2i(6, 0), {}]])
	var lion := b.add_prop(&"bronze_gong", Vector2i(2, 3))
	b.set_ground(Vector2i(2, 4), &"entry_damage")
	BattleDisplace.shove_prop(b, lion, H.DOWN, "test")
	assert_that(lion.pos).is_equal(Vector2i(2, 4))
	assert_int(lion.hp).is_equal(1)                               # entry ground: 1
	var wall := b.add_prop(&"earth_wall", Vector2i(4, 3))
	b.set_ground(Vector2i(4, 3), &"exit_damage")
	BattleDisplace.shove_prop(b, wall, H.DOWN, "test")
	assert_int(wall.hp).is_equal(0)                               # exit ground: 2, it falls where it stood
	assert_that(wall.pos).is_equal(Vector2i(4, 3))
	BattlePayload.settle(b)
	assert_object(b.board.prop_at(Vector2i(4, 3), Board.GROUND)).is_null()


func test_heal_ground_does_nothing_to_a_prop_and_a_created_prop_has_not_entered() -> void:
	var b := H.battle([[0, Vector2i(0, 6), {}], [1, Vector2i(6, 0), {}]])
	b.set_ground(Vector2i(2, 3), &"entry_damage")
	var wall := b.add_prop(&"earth_wall", Vector2i(2, 3))
	assert_int(wall.hp).is_equal(2)                               # placed, not pushed in
	BattleBoardOps.damage_prop(b, wall, 1)
	b.set_ground(Vector2i(2, 4), &"entry_heal")
	BattleDisplace.shove_prop(b, wall, H.DOWN, "test")
	assert_that(wall.pos).is_equal(Vector2i(2, 4))
	assert_int(wall.hp).is_equal(1)


func test_a_burst_trap_hits_the_squares_around_and_not_who_sprang_it() -> void:
	var b := H.battle([[0, Vector2i(3, 4), {"pace": 1.9}], [1, Vector2i(2, 2)], [1, Vector2i(3, 2)], [1, Vector2i(6, 6)]])
	b.add_prop(&"burst_trap", Vector2i(3, 3))
	b.begin()
	b.apply({"type": &"step", "to": Vector2i(3, 3)})
	assert_array([H.unit(b, 0).hp, H.unit(b, 1).hp, H.unit(b, 2).hp, H.unit(b, 3).hp]).is_equal([5, 4, 4, 5])
	assert_object(b.board.at(Vector2i(3, 3)).prop).is_null()


func test_a_vortex_trap_pulls_its_four_neighbours_only_and_every_collision_counts() -> void:
	var b := H.battle([[0, Vector2i(3, 4), {"pace": 1.9, "hp": 9}], [1, Vector2i(2, 3)], [1, Vector2i(4, 3)], [1, Vector2i(3, 2)], [1, Vector2i(2, 2)]])
	b.add_prop(&"vortex_trap", Vector2i(3, 3))
	b.begin()
	b.apply({"type": &"step", "to": Vector2i(3, 3)})
	assert_int(H.unit(b, 0).hp).is_equal(6)                       # three neighbours, three collisions
	assert_array([H.unit(b, 1).hp, H.unit(b, 2).hp, H.unit(b, 3).hp]).is_equal([4, 4, 4])
	assert_int(H.unit(b, 4).hp).is_equal(5)                       # the diagonal square is outside the shape
	assert_that(H.unit(b, 4).pos).is_equal(Vector2i(2, 2))
