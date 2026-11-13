extends GdUnitTestSuite
## Surges as traps (build rule since 2026-11-12, temp_todo T38): placement, what springs
## them, and the payload of a detonation (profiles, reductions, order: gdd_battle §6.1, §6.2;
## gdd_skills §3 Surge). The GDDs still describe a timed detonation.

const H := preload("res://tests/battle/helpers.gd")


func _cast(b: Battle, slot: int, anchor: Vector2i, dir := Vector2i.ZERO) -> bool:
	return b.apply({"type": &"skill", "slot": slot, "anchor": anchor, "dir": dir})


## Arms the active monster's Surge on squares that may hold monsters and detonates it at once:
## for the payload tests, which do not care how a trap was sprung.
func _fire(b: Battle, slot: int, anchor: Vector2i, dir := Vector2i.ZERO) -> void:
	var u := b.active()
	b._declare_surge(u, u.sheet.skills[slot], {"slot": slot, "anchor": anchor, "dir": dir})
	BattleTurn.detonate(b, b.surges.duplicate())


func test_a_trap_needs_free_squares_and_springs_when_a_monster_steps_in() -> void:
	var b := H.battle([
		[0, Vector2i(3, 6), {"init": 9.0, "reach": 3, "skills": [H.surge([Vector2i.ZERO])]}],
		[1, Vector2i(3, 3), {"init": 5.0, "hp": 8}],
	])
	b.begin()
	assert_str(b.check({"type": &"skill", "slot": 0, "anchor": Vector2i(3, 3)})).contains("monster-free")
	assert_bool(_cast(b, 0, Vector2i(3, 4))).is_true()
	assert_int(b.board.at(Vector2i(3, 4)).surge).is_equal(1)
	assert_int(b.ap).is_equal(2)                 # declared for its authored 1 AP
	b.end_turn()
	assert_bool(b.apply({"type": &"step", "to": Vector2i(3, 4)})).is_true()   # walking in is allowed
	assert_int(H.unit(b, 1).hp).is_equal(5)      # and springs it at once
	assert_int(b.surges.size()).is_equal(0)
	assert_int(b.board.at(Vector2i(3, 4)).surge).is_equal(-1)


func test_a_timed_surge_is_cast_on_monsters_and_fires_after_its_turns() -> void:
	var burst := H.surge([Vector2i.ZERO], 3, "timed")       # 2 turns
	var b := H.battle([
		[0, Vector2i(3, 6), {"init": 9.0, "reach": 3, "skills": [burst]}],
		[1, Vector2i(3, 3), {"init": 5.0, "hp": 8}],
		[1, Vector2i(6, 0), {"init": 4.0, "hp": 8}],
	])
	b.begin()
	assert_bool(_cast(b, 0, Vector2i(3, 3))).is_true()      # under a monster: allowed
	assert_int(b.surges[0].turns_left).is_equal(2)
	b.end_turn()                                            # the cast turn does not count
	assert_int(H.unit(b, 1).hp).is_equal(8)
	b.end_turn()                                            # first finished turn (the target's own)
	assert_int(H.unit(b, 1).hp).is_equal(8)
	b.end_turn()                                            # second finished turn: it fires between turns
	assert_int(H.unit(b, 1).hp).is_equal(5)
	assert_int(b.surges.size()).is_equal(0)


func test_a_surge_replaces_trap_squares_and_a_trap_is_laid_only_on_free_squares() -> void:
	var burst := H.surge([Vector2i.ZERO, Vector2i(1, 0)], 3, "timed")
	var trap := H.surge([Vector2i.ZERO, Vector2i(1, 0), Vector2i(2, 0)], 2, "trap")
	var b := H.battle([
		[0, Vector2i(3, 6), {"init": 9.0, "reach": 4, "ap": 5, "skills": [burst, trap]}],
		[1, Vector2i(0, 0), {"init": 5.0, "hp": 8}],
	])
	b.begin()
	assert_bool(_cast(b, 1, Vector2i(2, 4))).is_true()      # trap on (2,4) (3,4) (4,4)
	assert_bool(_cast(b, 0, Vector2i(3, 4))).is_true()      # Surge on (3,4) (4,4): replaces those trap squares
	var the_trap := b.surge_by_id(1)
	assert_array(the_trap.cells).is_equal([Vector2i(2, 4)]) # the rest of the trap stays
	assert_int(b.board.at(Vector2i(3, 4)).surge).is_equal(2)
	assert_str(b.check({"type": &"skill", "slot": 0, "anchor": Vector2i(4, 4)})).contains("already holds a Surge")
	# a second trap over the Surge is laid only on the free square (5,4); (3,4) (4,4) keep the Surge
	assert_bool(_cast(b, 1, Vector2i(3, 4))).is_true()
	assert_array(b.surge_by_id(3).cells).is_equal([Vector2i(5, 4)])
	assert_int(b.board.at(Vector2i(4, 4)).surge).is_equal(2)
	assert_str(b.check({"type": &"skill", "slot": 1, "anchor": Vector2i(3, 4)})).contains("every square")


func test_a_timed_surge_can_be_left_before_it_fires() -> void:
	var burst := H.surge([Vector2i.ZERO], 3, "timed")
	var b := H.battle([
		[0, Vector2i(3, 6), {"init": 9.0, "reach": 3, "skills": [burst]}],
		[1, Vector2i(3, 3), {"init": 5.0, "hp": 8}],
	])
	b.begin()
	_cast(b, 0, Vector2i(3, 3))
	b.end_turn()
	assert_bool(b.apply({"type": &"step", "to": Vector2i(2, 3)})).is_true()   # walking out is allowed
	b.end_turn()
	b.end_turn()
	assert_int(H.unit(b, 1).hp).is_equal(8)                 # it fired on an empty square
	assert_int(b.surges.size()).is_equal(0)


func test_a_trap_never_fires_by_itself_and_outlives_its_caster() -> void:
	var b := H.battle([
		[0, Vector2i(3, 5), {"init": 9.0, "current_hp": 1, "reach": 3, "skills": [H.surge([Vector2i.ZERO])]}],
		[1, Vector2i(3, 4), {"init": 5.0, "hp": 8, "skills": [H.strike()]}],
		[0, Vector2i(0, 6), {"init": 1.0}],
	])
	b.begin()
	_cast(b, 0, Vector2i(3, 3))
	b.end_turn()
	assert_bool(b.apply({"type": &"skill", "slot": 0, "dir": H.DOWN})).is_true()
	assert_bool(H.unit(b, 0).defeated).is_true()
	assert_bool(b.surges[0].orphaned).is_true()  # the caster is gone, the trap stays
	for i in 9:
		b.end_turn()                             # three rounds pass
	assert_bool(b.round_number >= 4).is_true()
	assert_int(b.surges.size()).is_equal(1)
	assert_int(H.unit(b, 1).hp).is_equal(8)
	H.until_turn_of(b, &"u1")
	b.apply({"type": &"step", "to": Vector2i(3, 3)})
	assert_int(H.unit(b, 1).hp).is_equal(5)


func test_a_second_trap_skill_is_laid_only_on_free_squares_and_the_same_one_moves() -> void:
	var b := H.battle([
		[0, Vector2i(3, 5), {"init": 9.0, "reach": 3, "ap": 3, "skills": [H.surge([Vector2i.ZERO, Vector2i(1, 0)]), H.surge([Vector2i.ZERO, Vector2i(1, 0)])]}],
		[1, Vector2i(6, 0), {"hp": 8}],
	])
	b.begin()
	assert_bool(_cast(b, 0, Vector2i(3, 3))).is_true()   # (3,3) (4,3)
	assert_bool(_cast(b, 1, Vector2i(4, 3))).is_true()   # another trap skill: only (5,3) is free
	assert_int(b.surges.size()).is_equal(2)
	assert_array(b.surges[1].cells).is_equal([Vector2i(5, 3)])
	assert_int(b.board.at(Vector2i(4, 3)).surge).is_equal(1)   # the first trap keeps its square
	assert_int(b.ap).is_equal(1)
	assert_bool(_cast(b, 0, Vector2i(2, 4))).is_true()   # the first skill again: its trap moves (one per skill)
	assert_int(b.surges.size()).is_equal(2)
	assert_int(b.board.at(Vector2i(3, 3)).surge).is_equal(-1)
	assert_int(b.board.at(Vector2i(2, 4)).surge).is_greater(0)


func test_a_pushed_monster_springs_the_trap_and_a_walk_ends_on_it() -> void:
	var eruption := H.surge([Vector2i.ZERO])
	eruption.board_ops = [BoardOp.make("ground", &"lava", false)] as Array[BoardOp]
	var b := H.battle([
		[0, Vector2i(3, 6), {"init": 9.0, "reach": 4, "ap": 4, "kin": MonsterDef.Kin.SCALED, "skills": [eruption, H.strike()]}],
		[1, Vector2i(3, 5), {"init": 5.0, "hp": 8, "move": 3, "skills": ["run"]}],
	])
	b.begin()
	_cast(b, 0, Vector2i(3, 4))
	var opts := BattleMoves.options(b, H.unit(b, 1), BattleMoves.profile_of(H.skill("run")))
	assert_bool(opts.has(Vector2i(3, 4))).is_true()     # a walk may end on the trap
	assert_bool(opts.has(Vector2i(3, 3))).is_false()    # but not pass through it (around is too far)
	# Tail Sweep pushes the enemy onto the trap: Strike 2, then the trap's 3
	assert_bool(b.apply({"type": &"skill", "slot": 1, "dir": H.UP, "push_dir": H.UP})).is_true()
	assert_that(H.unit(b, 1).pos).is_equal(Vector2i(3, 4))
	assert_int(H.unit(b, 1).hp).is_equal(3)
	assert_str(b.board.at(Vector2i(3, 4)).ground).is_equal("lava")   # its residue lands after the detonation


func test_a_new_prop_or_mountain_springs_a_trap_unless_only_monsters_do() -> void:
	for monsters_only in [false, true]:
		var eruption := H.surge([Vector2i.ZERO, Vector2i(1, 0)])
		eruption.board_ops = [BoardOp.make("ground", &"lava", false)] as Array[BoardOp]
		eruption.trap_trigger = "monsters" if monsters_only else "any"
		var wall := H.board_skill([BoardOp.make("create_prop", &"stone_lion")])
		var b := H.battle([
			[0, Vector2i(3, 5), {"init": 9.0, "reach": 3, "skills": [eruption]}],
			[1, Vector2i(3, 2), {"init": 5.0, "hp": 8, "skills": [wall]}],
		])
		b.begin()
		_cast(b, 0, Vector2i(3, 3))                  # (3,3) and (4,3)
		b.end_turn()
		assert_bool(_cast(b, 0, Vector2i(3, 3))).is_true()   # a prop may be raised on a trap
		var lion := b.board.at(Vector2i(3, 3)).prop
		if monsters_only:
			assert_int(b.surges.size()).is_equal(1)      # still set
			assert_int(lion.hp).is_equal(3)
		else:
			assert_int(b.surges.size()).is_equal(0)      # sprung: the way to disarm a trap
			assert_int(lion.hp).is_equal(1)              # the new prop intercepts
			assert_str(b.board.at(Vector2i(3, 3)).ground).is_equal("plain")   # no residue under a prop
			assert_str(b.board.at(Vector2i(4, 3)).ground).is_equal("lava")    # everything else resolves


func test_eruption_hits_a_mountain_but_leaves_no_residue_there() -> void:
	var eruption := H.surge([Vector2i.ZERO, Vector2i(1, 0)])
	eruption.board_ops = [BoardOp.make("ground", &"lava", false)] as Array[BoardOp]
	var b := H.battle([[0, Vector2i(3, 5), {"init": 9.0, "reach": 3, "skills": [eruption]}], [1, Vector2i(4, 3), {"hp": 8}]])
	b.board.at(Vector2i(4, 3)).height = 1
	b.begin()
	_fire(b, 0, Vector2i(3, 3))
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
	assert_str(b.check({"type": &"skill", "slot": 0, "anchor": Vector2i(1, 3)})).contains("push direction")
	_fire(b, 0, Vector2i(3, 3), H.RIGHT)
	assert_that(H.unit(b, 1).pos).is_equal(Vector2i(4, 2))
	assert_int(H.unit(b, 1).hp).is_equal(6)      # pushed out before the Thornbed is laid
	assert_int(H.unit(b, 2).hp).is_equal(8)      # on the Mountain: the square is blanked
	assert_that(H.unit(b, 2).pos).is_equal(Vector2i(3, 3))
	assert_int(H.unit(b, 3).hp).is_equal(4)      # 2 + 2 collision with the spiky Stone Lion; no entry damage
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
	_fire(b, 0, Vector2i(3, 3), H.RIGHT)
	# the front unit moves first, so the one behind does not collide with it
	assert_that(H.unit(b, 2).pos).is_equal(Vector2i(5, 3))
	assert_that(H.unit(b, 1).pos).is_equal(Vector2i(4, 3))
	assert_array([H.unit(b, 1).hp, H.unit(b, 2).hp]).is_equal([4, 4])


func test_rift_destroys_the_mountain_with_collapse_damage_and_its_own_ground() -> void:
	var b := H.battle([[0, Vector2i(3, 6), {"init": 9.0, "reach": 3, "skills": ["gloom_rift"]}], [1, Vector2i(3, 3), {"hp": 8}]])
	b.board.at(Vector2i(3, 3)).height = 1
	b.begin()
	_fire(b, 0, Vector2i(3, 3))                  # vertical I3: (3,2) (3,3) (3,4)
	assert_int(H.unit(b, 1).hp).is_equal(4)      # 3 Surge + 1 environmental collapse
	assert_bool(b.board.at(Vector2i(3, 3)).is_mountain()).is_false()
	assert_str(b.board.at(Vector2i(3, 3)).ground).is_equal("blight")   # the Rift's own ground, not Rubble
	assert_int(b.board.at(Vector2i(3, 3)).level).is_equal(1)
	assert_str(b.board.at(Vector2i(3, 2)).ground).is_equal("blight")


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
	_fire(b, 0, Vector2i(1, 3), H.DOWN)
	assert_int(H.unit(b, 1).hp).is_equal(7)      # 3 - 2 zone shield
	assert_int(H.unit(b, 2).hp).is_equal(6)      # 3 - 1 Hallowed
	assert_int(H.unit(b, 3).hp).is_equal(8)      # 3 - 2 - 1 = 0
	assert_int(H.unit(b, 4).hp).is_equal(6)      # 3 - 1 Wardstone aura
	assert_that(H.unit(b, 3).pos).is_equal(Vector2i(3, 4))      # a hit of 0 still pushes
	assert_str(b.board.at(Vector2i(2, 3)).ground).is_equal("hallowed")   # nothing consumed


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
		_fire(b, 0, Vector2i(1, 1))
		assert_object(b.board.at(Vector2i(1, 1)).prop).is_null()
		assert_str(b.board.at(Vector2i(1, 1)).ground).is_equal("plain")   # the Urn leaves Plain, in (e)
		assert_bool(H.unit(b, 2).defeated).is_true()
		if thread:
			assert_bool(H.unit(b, 1).defeated).is_false()
			assert_int(H.unit(b, 1).hp).is_equal(1)
			assert_bool(H.unit(b, 1).life_thread).is_false()             # consumed
		else:
			assert_bool(H.unit(b, 1).defeated).is_true()


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
	_fire(b, 0, Vector2i(3, 5))                  # (3,5) (3,4) (3,3)
	_fire(b, 1, Vector2i(5, 6))                  # horizontal I3: (4,6) (5,6) (6,6)
	assert_int(lion.hp).is_equal(1)              # ordinary Surge hit on a prop: 2
	assert_int(H.unit(b, 1).hp).is_equal(8)      # beyond the first prop of the line: spared
	assert_str(b.board.at(Vector2i(3, 5)).ground).is_equal("lava")
	assert_str(b.board.at(Vector2i(3, 4)).ground).is_equal("plain")    # no residue under a standing prop
	assert_str(b.board.at(Vector2i(3, 3)).ground).is_equal("plain")    # spared squares get nothing
	assert_int(lion2.hp).is_equal(1)             # other shapes only lose the blocked square


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
	_fire(b, 0, Vector2i(2, 3))
	assert_int(H.unit(b, 1).hp).is_equal(8)
	assert_bool(H.unit(b, 1).nullify).is_false() # consumed
	assert_int(H.unit(b, 2).hp).is_equal(8)
	assert_bool(H.unit(b, 2).nullify).is_true()  # already 0 after the sum: nothing consumed
	_fire(b, 0, Vector2i(2, 3))
	assert_int(H.unit(b, 1).hp).is_equal(5)      # later Surges hit normally


func test_mountain_rule_lets_ground_surges_hit_adjacent_flyers_fixed_at_cast() -> void:
	for on_mountain in [true, false]:
		var b := H.battle([
			[0, Vector2i(3, 3), {"init": 9.0, "ap": 3, "skills": [H.surge([Vector2i.ZERO])]}],
			[1, Vector2i(3, 2), {"hp": 8, "airborne": true}],
		])
		b.board.at(Vector2i(3, 3)).height = 1 if on_mountain else 0
		b.begin()
		assert_bool(_cast(b, 0, Vector2i(3, 2))).is_true()  # a flyer does not block or spring a ground trap
		assert_int(b.surges.size()).is_equal(1)
		b.apply({"type": &"step", "to": Vector2i(3, 4)})    # leaving the Mountain later changes nothing
		BattleTurn.detonate(b, b.surges.duplicate())
		assert_int(H.unit(b, 1).hp).is_equal(5 if on_mountain else 8)
