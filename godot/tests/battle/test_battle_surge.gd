extends GdUnitTestSuite
## Surge scheduling, profiles, reductions and execution-time legality
## (gdd_battle §2.2, §6.1, §6.2; gdd_skills §3 Surge).

const H := preload("res://tests/battle/helpers.gd")


func _cast(b: Battle, slot: int, anchor: Vector2i, dir := Vector2i.ZERO) -> bool:
	return b.apply({"type": &"skill", "slot": slot, "anchor": anchor, "dir": dir})


func _index(b: Battle, type: StringName, from := 0) -> int:
	for i in range(from, b.events.size()):
		if b.events[i]["type"] == type:
			return i
	return -1


func test_surge_detonates_at_the_start_of_the_casters_next_turn() -> void:
	var b := H.battle([
		[0, Vector2i(3, 6), {"init": 9.0, "reach": 3, "skills": [H.surge([Vector2i.ZERO])]}],
		[1, Vector2i(3, 3), {"init": 5.0, "hp": 8}],
		[1, Vector2i(6, 0), {"init": 4.0}],
	])
	b.begin()
	assert_bool(_cast(b, 0, Vector2i(3, 3))).is_true()
	assert_int(b.board.at(Vector2i(3, 3)).surge).is_equal(1)
	assert_int(b.ap).is_equal(2)                 # declared for its authored 1 AP
	b.end_turn()
	b.end_turn()
	assert_int(H.unit(b, 1).hp).is_equal(8)      # both enemies acted, still pending
	b.end_turn()                                 # round 2: the caster's entry starts
	assert_int(b.round_number).is_equal(2)
	assert_int(H.unit(b, 1).hp).is_equal(5)
	assert_int(b.surges.size()).is_equal(0)
	assert_int(b.board.at(Vector2i(3, 3)).surge).is_equal(-1)
	# before the start effects and the AP of that turn
	var fired := _index(b, &"surge_fired")
	assert_bool(fired >= 0 and fired < _index(b, &"turn_started", fired)).is_true()


func test_an_extra_turn_entry_detonates_it_in_the_same_round() -> void:
	var b := H.battle([
		[0, Vector2i(3, 6), {"init": 9.0, "tpr": 2, "reach": 3, "skills": [H.surge([Vector2i.ZERO])]}],
		[1, Vector2i(3, 3), {"init": 7.0, "hp": 8}],
	])
	b.begin()
	_cast(b, 0, Vector2i(3, 3))
	b.end_turn()                                 # enemy at 7.0
	b.end_turn()                                 # caster's extra entry at 6.0
	assert_int(b.round_number).is_equal(1)
	assert_str(b.turn_owner).is_equal("u0")
	assert_int(H.unit(b, 1).hp).is_equal(5)


func test_a_dead_casters_surge_fires_at_the_start_of_the_next_round_before_the_queue() -> void:
	var b := H.battle([
		[0, Vector2i(3, 4), {"init": 9.0, "current_hp": 1, "skills": [H.surge([Vector2i.ZERO])]}],
		[1, Vector2i(3, 3), {"init": 5.0, "hp": 8, "skills": [H.strike()]}],
		[0, Vector2i(0, 6), {"init": 1.0}],
	])
	b.begin()
	_cast(b, 0, Vector2i(3, 3))
	b.end_turn()
	assert_bool(b.apply({"type": &"skill", "slot": 0, "dir": H.DOWN})).is_true()
	assert_bool(H.unit(b, 0).defeated).is_true()
	assert_int(b.surges.size()).is_equal(1)      # not cancelled by the caster's death
	assert_bool(b.surges[0].orphaned).is_true()
	b.end_turn()
	b.end_turn()                                 # the last unit of round 1 → round 2
	assert_int(b.round_number).is_equal(2)
	assert_int(H.unit(b, 1).hp).is_equal(5)
	var round2 := -1
	for i in b.events.size():
		if b.events[i]["type"] == &"round_started" and b.events[i]["round"] == 2:
			round2 = i
	var fired := _index(b, &"surge_fired", round2)
	assert_bool(round2 >= 0 and fired > round2 and fired < _index(b, &"turn_started", round2)).is_true()


func test_concurrent_casts_are_allowed_but_never_overlap() -> void:
	var b := H.battle([
		[0, Vector2i(3, 5), {"init": 9.0, "reach": 3, "ap": 3, "skills": [H.surge([Vector2i.ZERO, Vector2i(1, 0)])]}],
		[1, Vector2i(3, 3), {"hp": 8}], [1, Vector2i(4, 2), {"hp": 8}],
	])
	b.begin()
	assert_bool(_cast(b, 0, Vector2i(3, 3))).is_true()
	assert_str(b.check({"type": &"skill", "slot": 0, "anchor": Vector2i(4, 3)})).contains("already claimed")
	assert_bool(_cast(b, 0, Vector2i(3, 2))).is_true()   # same skill instance, second pending cast
	assert_int(b.surges.size()).is_equal(2)
	H.until_turn_of(b, &"u0")
	assert_int(H.unit(b, 1).hp).is_equal(5)
	assert_int(H.unit(b, 2).hp).is_equal(5)


func test_eruption_hits_a_mountain_but_leaves_no_residue_there() -> void:
	var eruption := H.surge([Vector2i.ZERO, Vector2i(1, 0)])
	eruption.board_ops = [BoardOp.make("ground", &"lava", false)] as Array[BoardOp]
	var b := H.battle([[0, Vector2i(3, 5), {"init": 9.0, "reach": 3, "skills": [eruption]}], [1, Vector2i(4, 3), {"hp": 8}]])
	b.board.at(Vector2i(4, 3)).height = 1
	b.begin()
	_cast(b, 0, Vector2i(3, 3))
	H.until_turn_of(b, &"u0")
	assert_int(H.unit(b, 1).hp).is_equal(5)
	assert_str(b.board.at(Vector2i(3, 3)).ground).is_equal("lava")
	assert_int(b.board.at(Vector2i(3, 3)).level).is_equal(1)
	assert_str(b.board.at(Vector2i(4, 3)).ground).is_equal("plain")
	assert_bool(b.board.at(Vector2i(4, 3)).is_mountain()).is_true()


func test_flood_cannot_reach_mountains_and_pushes_before_its_residue_lands() -> void:
	# Tidal Shell: vertical I3, 2 damage, push in the cast direction, Thornbed I
	var b := H.battle([
		[0, Vector2i(0, 3), {"init": 9.0, "reach": 3, "skills": ["tidal_shell"]}],
		[1, Vector2i(3, 2), {"hp": 8}], [1, Vector2i(3, 3), {"hp": 8}], [1, Vector2i(3, 4), {"hp": 8}],
	])
	b.board.at(Vector2i(3, 3)).height = 1
	b.add_prop(&"stone_lion", Vector2i(4, 4))
	b.begin()
	assert_str(b.check({"type": &"skill", "slot": 0, "anchor": Vector2i(3, 3)})).contains("push direction")
	assert_bool(_cast(b, 0, Vector2i(3, 3), H.RIGHT)).is_true()
	H.until_turn_of(b, &"u0")
	assert_that(H.unit(b, 1).pos).is_equal(Vector2i(4, 2))
	assert_int(H.unit(b, 1).hp).is_equal(6)      # pushed out before the Thornbed is laid
	assert_int(H.unit(b, 2).hp).is_equal(8)      # on the Mountain: the square is blanked
	assert_that(H.unit(b, 2).pos).is_equal(Vector2i(3, 3))
	assert_int(H.unit(b, 3).hp).is_equal(5)      # 2 + 1 collision with the Stone Lion; no entry damage
	assert_that(H.unit(b, 3).pos).is_equal(Vector2i(3, 4))
	assert_str(b.board.at(Vector2i(3, 2)).ground).is_equal("thornbed")
	assert_str(b.board.at(Vector2i(3, 4)).ground).is_equal("thornbed")
	assert_str(b.board.at(Vector2i(3, 3)).ground).is_equal("plain")


func test_displacement_resolves_the_unit_furthest_along_first() -> void:
	var wave := H.surge([Vector2i.ZERO, Vector2i(1, 0)], 1)
	wave.surge_displacement = "push"
	var b := H.battle([
		[0, Vector2i(3, 5), {"init": 9.0, "reach": 3, "skills": [wave]}],
		[1, Vector2i(3, 3)], [1, Vector2i(4, 3)],
	])
	b.begin()
	_cast(b, 0, Vector2i(3, 3), H.RIGHT)
	H.until_turn_of(b, &"u0")
	# the front unit moves first, so the one behind does not collide with it
	assert_that(H.unit(b, 2).pos).is_equal(Vector2i(5, 3))
	assert_that(H.unit(b, 1).pos).is_equal(Vector2i(4, 3))
	assert_array([H.unit(b, 1).hp, H.unit(b, 2).hp]).is_equal([4, 4])


func test_rift_destroys_the_mountain_with_collapse_damage_and_its_own_ground() -> void:
	var b := H.battle([[0, Vector2i(3, 6), {"init": 9.0, "reach": 3, "skills": ["gloom_rift"]}], [1, Vector2i(3, 3), {"hp": 8}]])
	b.board.at(Vector2i(3, 3)).height = 1
	b.begin()
	_cast(b, 0, Vector2i(3, 3))                  # vertical I3: (3,2) (3,3) (3,4)
	H.until_turn_of(b, &"u0")
	assert_int(H.unit(b, 1).hp).is_equal(4)      # 3 Surge + 1 environmental collapse
	assert_bool(b.board.at(Vector2i(3, 3)).is_mountain()).is_false()
	assert_str(b.board.at(Vector2i(3, 3)).ground).is_equal("blight")   # the Rift's own ground, not Rubble
	assert_int(b.board.at(Vector2i(3, 3)).level).is_equal(1)
	assert_str(b.board.at(Vector2i(3, 2)).ground).is_equal("blight")


func test_props_intercept_and_a_line_footprint_stops_at_the_first_prop() -> void:
	# Cinder Dive: straight trail of 3 from the caster, line-shaped
	var b := H.battle([
		[0, Vector2i(3, 6), {"init": 9.0, "skills": ["cinder_dive", "delayed_burst_reference"], "reach": 3}],
		[1, Vector2i(3, 3), {"hp": 8}], [1, Vector2i(5, 5), {"hp": 8}],
	])
	var lion := b.add_prop(&"stone_lion", Vector2i(3, 4))
	var lion2 := b.add_prop(&"stone_lion", Vector2i(5, 6))
	b.begin()
	assert_str(b.check({"type": &"skill", "slot": 0, "anchor": Vector2i(3, 4)})).contains("start next to")
	assert_bool(_cast(b, 0, Vector2i(3, 5))).is_true()          # (3,5) (3,4) (3,3)
	assert_bool(_cast(b, 1, Vector2i(5, 6))).is_true()          # horizontal I3: (4,6) (5,6) (6,6)
	H.until_turn_of(b, &"u0")
	assert_int(lion.hp).is_equal(1)              # ordinary Surge hit on a prop: 2
	assert_int(H.unit(b, 1).hp).is_equal(8)      # beyond the first prop of the line: spared
	assert_str(b.board.at(Vector2i(3, 5)).ground).is_equal("lava")
	assert_str(b.board.at(Vector2i(3, 4)).ground).is_equal("plain")    # no residue under a standing prop
	assert_str(b.board.at(Vector2i(3, 3)).ground).is_equal("plain")    # spared squares get nothing
	assert_int(lion2.hp).is_equal(1)             # other shapes only lose the blocked square


func test_value_reductions_add_and_a_zero_damage_hit_still_displaces() -> void:
	var wave := H.surge([Vector2i.ZERO, Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)])
	wave.surge_displacement = "push"
	var veil: BattleZoneDef = H.content().zone(&"bark_veil")       # shield 2 (3 at level II+)
	var b := H.battle([
		[0, Vector2i(1, 5), {"init": 9.0, "reach": 3, "skills": [wave]}],
		[1, Vector2i(1, 3), {"hp": 8}], [1, Vector2i(2, 3), {"hp": 8}], [1, Vector2i(3, 3), {"hp": 8}], [1, Vector2i(4, 3), {"hp": 8}],
	])
	H.zone_on(b, Vector2i(1, 3), veil, 1, 1, Vector2i.ZERO, Vector2i.ZERO, 9)
	b.set_ground(Vector2i(2, 3), &"hallowed")
	H.zone_on(b, Vector2i(3, 3), veil, 2, 1, Vector2i.ZERO, Vector2i.ZERO, 9)
	b.set_ground(Vector2i(3, 3), &"hallowed")
	b.add_prop(&"wardstone", Vector2i(4, 2))
	b.begin()
	_cast(b, 0, Vector2i(1, 3), H.DOWN)
	H.until_turn_of(b, &"u0")
	assert_int(H.unit(b, 1).hp).is_equal(7)      # 3 - 2 zone shield
	assert_int(H.unit(b, 2).hp).is_equal(6)      # 3 - 1 Hallowed
	assert_int(H.unit(b, 3).hp).is_equal(8)      # 3 - 2 - 1 = 0
	assert_int(H.unit(b, 4).hp).is_equal(6)      # 3 - 1 Wardstone aura
	assert_that(H.unit(b, 3).pos).is_equal(Vector2i(3, 4))      # a hit of 0 still pushes
	assert_str(b.board.at(Vector2i(2, 3)).ground).is_equal("hallowed")   # nothing consumed


func test_nullify_overrides_the_next_surge_damage_of_at_least_one() -> void:
	var veil: BattleZoneDef = H.content().zone(&"bark_veil")
	var b := H.battle([
		[0, Vector2i(2, 5), {"init": 9.0, "reach": 3, "ap": 3, "skills": [H.surge([Vector2i.ZERO, Vector2i(1, 0)])]}],
		[1, Vector2i(2, 3), {"hp": 8}], [1, Vector2i(3, 3), {"hp": 8}],
	])
	H.zone_on(b, Vector2i(3, 3), veil, 1, 3, Vector2i.ZERO, Vector2i.ZERO, 9)   # shield 3
	H.unit(b, 1).nullify = true
	H.unit(b, 2).nullify = true
	b.begin()
	_cast(b, 0, Vector2i(2, 3))
	H.until_turn_of(b, &"u0")
	assert_int(H.unit(b, 1).hp).is_equal(8)
	assert_bool(H.unit(b, 1).nullify).is_false() # consumed
	assert_int(H.unit(b, 2).hp).is_equal(8)
	assert_bool(H.unit(b, 2).nullify).is_true()  # already 0 after the sum: nothing consumed
	_cast(b, 0, Vector2i(2, 3))
	H.until_turn_of(b, &"u0")
	assert_int(H.unit(b, 1).hp).is_equal(5)      # later Surges hit normally


func test_legality_is_checked_at_detonation_not_at_cast() -> void:
	var eruption := H.surge([Vector2i.ZERO, Vector2i(1, 0)])
	eruption.board_ops = [BoardOp.make("ground", &"lava", false)] as Array[BoardOp]
	var wall := H.board_skill([BoardOp.make("create_prop", &"stone_lion")])
	var b := H.battle([
		[0, Vector2i(3, 5), {"init": 9.0, "reach": 3, "skills": [eruption]}],
		[1, Vector2i(3, 2), {"init": 5.0, "hp": 8, "skills": [wall]}],
	])
	b.begin()
	_cast(b, 0, Vector2i(3, 3))                  # (3,3) and (4,3)
	b.end_turn()
	assert_bool(_cast(b, 0, Vector2i(3, 3))).is_true()   # a prop may be raised under a charging Surge
	b.end_turn()
	var lion := b.board.at(Vector2i(3, 3)).prop
	assert_int(lion.hp).is_equal(1)              # the new prop intercepts
	assert_str(b.board.at(Vector2i(3, 3)).ground).is_equal("plain")   # residue is no longer legal there
	assert_str(b.board.at(Vector2i(4, 3)).ground).is_equal("lava")    # everything else resolves normally


func test_leaving_avoids_the_damage_and_charging_surges_block_voluntary_paths() -> void:
	var eruption := H.surge([Vector2i.ZERO])
	eruption.board_ops = [BoardOp.make("ground", &"lava", false)] as Array[BoardOp]
	var b := H.battle([
		[0, Vector2i(3, 6), {"init": 9.0, "reach": 3, "skills": [eruption]}],
		[1, Vector2i(3, 3), {"init": 5.0, "hp": 8, "move": 3, "skills": ["run"]}],
	])
	b.begin()
	_cast(b, 0, Vector2i(3, 4))
	b.end_turn()
	var opts := BattleMoves.options(b, H.unit(b, 1), BattleMoves.profile_of(H.skill("run")))
	assert_bool(opts.has(Vector2i(3, 4))).is_false()    # cannot enter the charging square
	assert_bool(opts.has(Vector2i(3, 5))).is_false()    # nor walk through it (3 steps around are too far)
	assert_bool(b.apply({"type": &"skill", "slot": 0, "to": Vector2i(3, 1)})).is_true()
	b.end_turn()
	assert_int(H.unit(b, 1).hp).is_equal(8)
	assert_str(b.board.at(Vector2i(3, 4)).ground).is_equal("lava")   # the residue still lands


func test_mountain_rule_lets_ground_surges_hit_adjacent_flyers_fixed_at_cast() -> void:
	for on_mountain in [true, false]:
		var b := H.battle([
			[0, Vector2i(3, 3), {"init": 9.0, "ap": 3, "skills": [H.surge([Vector2i.ZERO])]}],
			[1, Vector2i(3, 2), {"hp": 8, "airborne": true}],
		])
		b.board.at(Vector2i(3, 3)).height = 1 if on_mountain else 0
		b.begin()
		_cast(b, 0, Vector2i(3, 2))
		b.apply({"type": &"step", "to": Vector2i(3, 4)})    # leaving the Mountain later changes nothing
		H.until_turn_of(b, &"u0")
		assert_int(H.unit(b, 1).hp).is_equal(5 if on_mountain else 8)


func test_lethal_prop_aftermath_and_the_survive_effect() -> void:
	# T04 walkthroughs 1 and 2: the Surge deals 2 to the Clay Urn and to M (3 HP); the Urn
	# stays until the removal step, then its ring hits M and N (1 HP) simultaneously.
	for thread in [false, true]:
		var burst := H.surge([Vector2i.ZERO, Vector2i(0, 1)], 2)
		var b := H.battle([
			[0, Vector2i(1, 4), {"init": 9.0, "reach": 3, "skills": [burst]}],
			[1, Vector2i(1, 2), {"hp": 3}],          # M on B3
			[1, Vector2i(2, 2), {"hp": 1}],          # N on C3
			[1, Vector2i(6, 6), {"hp": 5}],
		])
		b.add_prop(&"clay_urn", Vector2i(1, 1))      # B2
		b.set_ground(Vector2i(1, 1), &"lava", 1)
		H.unit(b, 1).life_thread = thread
		b.begin()
		_cast(b, 0, Vector2i(1, 1))
		H.until_turn_of(b, &"u0")
		assert_object(b.board.at(Vector2i(1, 1)).prop).is_null()
		assert_str(b.board.at(Vector2i(1, 1)).ground).is_equal("plain")   # the Urn leaves Plain, in (e)
		assert_bool(H.unit(b, 2).defeated).is_true()
		if thread:
			assert_bool(H.unit(b, 1).defeated).is_false()
			assert_int(H.unit(b, 1).hp).is_equal(1)
			assert_bool(H.unit(b, 1).life_thread).is_false()             # consumed
		else:
			assert_bool(H.unit(b, 1).defeated).is_true()
