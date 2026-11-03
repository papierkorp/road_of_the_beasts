extends GdUnitTestSuite
## Turn flow from GDD §3 / §14 / §13.1. Requires gdUnit4.


func _skill(id: String) -> SkillDef:
	return load("res://data/skills/%s.tres" % id)


func _battle() -> Battle:
	var tiger := Monster.new(&"tiger", "Blaze Tiger", Aspect.Type.FORCE, Vector2i(4, 0), 6, 7.0, 2,
		[_skill("magma_surge"), _skill("lava_field"), _skill("bog"), _skill("gale")] as Array[SkillDef])
	var wolf := Monster.new(&"wolf", "Gloom Wolf", Aspect.Type.DARK, Vector2i(0, 4), 5, 5.0, 2,
		[_skill("gloom_surge"), _skill("mire"), _skill("shade_veil")] as Array[SkillDef])
	var b := Battle.new(Board.new(5), [tiger, wolf] as Array[Monster])
	b.begin()
	return b


func test_higher_initiative_goes_first_and_gets_2_ap() -> void:
	var b := _battle()
	assert_str(b.turn_owner).is_equal("tiger")
	assert_int(b.ap).is_equal(2)


func test_move_costs_ap_and_respects_obstacles() -> void:
	var b := _battle()
	b.board.at(Vector2i(3, 0)).object = {"name": "Rock", "hp": 3, "max_hp": 3}
	assert_bool(b.move(&"tiger", Vector2i(3, 0))).is_false()
	assert_bool(b.move(&"tiger", Vector2i(4, 2))).is_true()
	assert_int(b.ap).is_equal(1)
	assert_bool(b.board.occupants.has(Vector2i(4, 2))).is_true()
	assert_bool(b.board.occupants.has(Vector2i(4, 0))).is_false()


func test_rubble_costs_two_movement() -> void:
	var b := _battle()
	b.board.at(Vector2i(4, 1)).ground = Square.GroundType.RUBBLE
	var r := b.reachable(b.monsters[&"tiger"], 2)
	assert_bool(r.has(Vector2i(4, 1))).is_true()
	assert_bool(r.has(Vector2i(4, 2))).is_false()


func test_one_charging_surge_per_monster() -> void:
	var b := _battle()
	var surge := _skill("magma_surge")
	assert_bool(b.cast(&"tiger", surge, 0, Vector2i(3, 1))).is_true()
	assert_bool(b.can_cast(&"tiger", surge)).is_false()


func test_cooldown_blocks_recast_until_it_ticks() -> void:
	var b := _battle()
	var bog := _skill("bog")
	assert_bool(b.cast(&"tiger", bog, 0, Vector2i(3, 1))).is_true()
	assert_bool(b.can_cast(&"tiger", bog)).is_false()


func test_surge_fires_after_opponent_turn() -> void:
	var b := _battle()
	b.cast(&"tiger", _skill("magma_surge"), 0, Vector2i(3, 1))
	b.end_turn()                                   # wolf's turn starts
	assert_str(b.turn_owner).is_equal("wolf")
	b.end_turn()                                   # end of wolf's turn: the Surge detonates
	assert_bool(b.board.at(Vector2i(3, 1)).surge == null).is_true()
	assert_int(b.round_number).is_equal(2)


func test_surge_kills_and_ends_battle() -> void:
	var b := _battle()
	var wolf: Monster = b.monsters[&"wolf"]
	b.board.occupants.erase(wolf.pos)
	wolf.pos = Vector2i(3, 1)
	b.board.occupants[wolf.pos] = &"wolf"
	wolf.hp = 3
	b.cast(&"tiger", _skill("magma_surge"), 0, Vector2i(3, 1))
	b.end_turn()
	b.end_turn()
	assert_bool(b.over).is_true()
	assert_str(b.winner).is_equal("tiger")


func test_lava_burns_at_end_of_own_turn() -> void:
	var b := _battle()
	var t: Monster = b.monsters[&"tiger"]
	b.board.at(t.pos).ground = Square.GroundType.LAVA
	b.board.at(t.pos).lava_level = 2
	b.end_turn()
	assert_int(t.hp).is_equal(4)


func test_mire_drains_initiative_and_flips_order() -> void:
	var b := _battle()
	var t: Monster = b.monsters[&"tiger"]
	b.board.at(t.pos).zone = {"def": load("res://data/zones/mire.tres"), "gid": "x", "owner": &"wolf", "level": 1, "duration": 2}
	assert_float(b.effective_stat(t, Battle.Stat.INIT)).is_equal(5.0)   # 7 - 2
	t.initiative = 6.0
	assert_float(b.effective_stat(t, Battle.Stat.INIT)).is_equal(4.0)


func test_elevated_adds_range() -> void:
	var b := _battle()
	var t: Monster = b.monsters[&"tiger"]
	assert_int(b.skill_range(t, _skill("bog"))).is_equal(3)
	b.board.at(t.pos).elevated = true
	assert_int(b.skill_range(t, _skill("bog"))).is_equal(4)


func test_gale_pushes_into_prop_for_collision_damage() -> void:
	var b := _battle()
	var t: Monster = b.monsters[&"tiger"]
	# I3 gale patch along x at y=0 covering (3,0)(4,0)(5?) -> use a custom patch left of the tiger
	var gale: ZoneDef = load("res://data/zones/gale.tres")
	for x in [2, 3, 4]:
		b.board.at(Vector2i(x, 0)).zone = {"def": gale, "gid": "p", "owner": &"wolf", "level": 1, "duration": 2}
	# patch centre is (3,0); tiger on (4,0) is pushed away along +x, i.e. off the board
	b.end_turn()
	b.end_turn()                                    # back to tiger: start-of-turn push
	assert_bool(b.events.any(func(e): return e["type"] == &"pinned")).is_true()


func test_voidscar_spreads_from_round_six() -> void:
	var b := _battle()
	b.round_number = 5
	b._end_round()
	var scars := b.board.all_squares().filter(func(s: Square): return s.ground == Square.GroundType.VOIDSCAR)
	assert_int(scars.size()).is_equal(1)
