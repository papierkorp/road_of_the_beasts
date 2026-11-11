extends GdUnitTestSuite
## 2x2 bodies and the air layer (gdd_battle §4.3, §4.7, §4.10, §6.3; gdd_skills §3).

const H := preload("res://tests/battle/helpers.gd")


func _big(pos: Vector2i, side := 0, o: Dictionary = {}) -> Array:
	var sheet := {"size": 2, "hp": 9, "init": 9.0 if side == 0 else 5.0}
	sheet.merge(o, true)
	return [side, pos, sheet]


func test_a_2x2_covers_four_squares_and_measures_from_the_nearest_one() -> void:
	var b := H.battle([_big(Vector2i(2, 2)), [1, Vector2i(6, 6)]])
	var u := H.unit(b, 0)
	assert_array(u.cells()).is_equal([Vector2i(2, 2), Vector2i(3, 2), Vector2i(2, 3), Vector2i(3, 3)])
	for c in u.cells():
		assert_str(b.board.unit_id_at(c, Board.GROUND)).is_equal("u0")
	assert_int(u.manhattan_to(Vector2i(5, 3))).is_equal(2)
	assert_int(u.chebyshev_to(Vector2i(5, 5))).is_equal(2)
	assert_bool(u.orth_adjacent_to(Vector2i(4, 2))).is_true()
	assert_bool(u.orth_adjacent_to(Vector2i(4, 4))).is_false()


func test_mixed_ground_every_type_once_and_the_highest_hazard_level() -> void:
	var b := H.battle([_big(Vector2i(2, 2)), [1, Vector2i(6, 6)]])
	b.set_ground(Vector2i(2, 2), &"lava", 1)
	b.set_ground(Vector2i(3, 2), &"lava", 2)
	b.set_ground(Vector2i(2, 3), &"blight", 1)
	b.begin()
	assert_int(H.unit(b, 0).hp).is_equal(8)      # Blight I once at the start of the turn
	b.end_turn()
	assert_int(H.unit(b, 0).hp).is_equal(6)      # Lava once, at its highest level II


func test_entry_triggers_use_only_newly_covered_squares_and_net_with_healing() -> void:
	var b := H.battle([_big(Vector2i(2, 2), 0, {"ap": 4, "current_hp": 5}), [1, Vector2i(6, 6)]])
	b.set_ground(Vector2i(3, 2), &"thornbed", 2)  # already covered: leaving or keeping it triggers nothing
	b.set_ground(Vector2i(4, 2), &"thornbed", 1)
	b.set_ground(Vector2i(4, 3), &"mossbed")
	b.set_ground(Vector2i(5, 2), &"thornbed", 2)
	b.begin()
	assert_bool(b.apply({"type": &"step", "to": Vector2i(3, 2)})).is_true()
	assert_int(H.unit(b, 0).hp).is_equal(5)      # Thornbed I and Mossbed net to 0
	assert_bool(b.apply({"type": &"step", "to": Vector2i(4, 2)})).is_true()
	assert_int(H.unit(b, 0).hp).is_equal(3)      # only the new column: Thornbed II


func test_mountain_bonus_needs_all_four_squares_and_any_climb_costs_two() -> void:
	var b := H.battle([_big(Vector2i(2, 2), 0, {"reach": 2, "move": 2, "skills": ["run"]}), [1, Vector2i(6, 6)]])
	var u := H.unit(b, 0)
	for p in [Vector2i(2, 2), Vector2i(3, 2), Vector2i(2, 3)]:
		b.board.at(p).height = 1
	assert_int(BattleStats.reach(b, u)).is_equal(2)
	b.board.at(Vector2i(3, 3)).height = 1
	assert_int(BattleStats.reach(b, u)).is_equal(3)
	b.board.at(Vector2i(2, 5)).height = 1
	var opts := BattleMoves.options(b, u, BattleMoves.profile_of(H.skill("run")))
	assert_int(opts[Vector2i(2, 3)]["cost"]).is_equal(1)
	assert_bool(opts.has(Vector2i(2, 4))).is_false()        # 1 + 2 for the climb of one covered square
	assert_int(opts[Vector2i(4, 2)]["cost"]).is_equal(2)


func test_a_body_needs_every_covered_square_to_be_legal() -> void:
	var b := H.battle([_big(Vector2i(2, 2), 0, {"move": 3, "skills": ["run"]}), [1, Vector2i(5, 3)]])
	b.add_prop(&"clay_urn", Vector2i(2, 1))
	var opts := BattleMoves.options(b, H.unit(b, 0), BattleMoves.profile_of(H.skill("run")))
	assert_bool(opts.has(Vector2i(2, 1))).is_false()        # a prop on one newly covered square
	assert_bool(opts.has(Vector2i(4, 2))).is_false()        # a monster on one covered square
	assert_bool(opts.has(Vector2i(3, 2))).is_true()
	assert_bool(opts.has(Vector2i(6, 2))).is_false()        # off the board


func test_pushing_a_2x2_is_one_collision_and_each_blocker_takes_one() -> void:
	var wave := H.surge([Vector2i.ZERO], 1)
	wave.surge_displacement = "push"
	var b := H.battle([
		[0, Vector2i(0, 4), {"init": 9.0, "reach": 4, "skills": [wave]}],
		_big(Vector2i(2, 2), 1), [1, Vector2i(4, 2), {"hp": 5}],
	])
	var urn := b.add_prop(&"bamboo_stand", Vector2i(4, 3))
	b.begin()
	assert_bool(b.apply({"type": &"skill", "slot": 0, "anchor": Vector2i(2, 3), "dir": H.RIGHT})).is_true()
	H.until_turn_of(b, &"u0")
	assert_that(H.unit(b, 1).pos).is_equal(Vector2i(2, 2))  # no move
	assert_int(H.unit(b, 1).hp).is_equal(7)                 # 1 Surge + 1 collision, once
	assert_int(H.unit(b, 2).hp).is_equal(4)
	assert_int(urn.hp).is_equal(1)


func test_2x2_falls_only_if_all_four_squares_land_lower_and_cannot_be_pushed_uphill() -> void:
	var b := H.battle([[0, Vector2i(0, 6)], _big(Vector2i(2, 2), 1)])
	var u := H.unit(b, 1)
	for p in u.cells():
		b.board.at(p).height = 1
	assert_bool(BattleDisplace.shove(b, u, H.RIGHT, "test")).is_true()
	assert_int(u.hp).is_equal(9)                 # a partial fall moves without fall damage
	b.board.at(Vector2i(5, 2)).height = 1
	assert_bool(BattleDisplace.shove(b, u, H.RIGHT, "test")).is_false()   # one covered square would climb
	assert_int(u.hp).is_equal(9)
	assert_that(u.pos).is_equal(Vector2i(3, 2))


func test_each_distinct_zone_applies_once_and_different_zones_add() -> void:
	var slow_a := H.zone_skill([FieldEffect.make("slow", 1, 2)], [Vector2i.ZERO], 2, "slow_a").zone
	var slow_b := H.zone_skill([FieldEffect.make("slow", 1, 2)], [Vector2i.ZERO], 2, "slow_b").zone
	var b := H.battle([_big(Vector2i(2, 2), 0, {"move": 4}), [1, Vector2i(6, 6)]])
	var u := H.unit(b, 0)
	for p in u.cells():
		H.zone_on(b, p, slow_a, 10)              # one cast covering all four squares
	assert_int(BattleStats.movement(b, u)).is_equal(3)
	H.zone_on(b, Vector2i(3, 3), slow_b, 11)     # a second zone on one square adds as another source
	assert_int(BattleStats.movement(b, u)).is_equal(2)


func test_zone_pushes_under_a_2x2_cancel_or_combine_to_one_cardinal_step() -> void:
	var push := H.zone_skill([FieldEffect.make("push", 1)]).zone
	var b := H.battle([_big(Vector2i(2, 2)), [1, Vector2i(6, 6)]])
	var u := H.unit(b, 0)
	H.zone_on(b, Vector2i(2, 2), push, 1, 1, H.RIGHT)
	H.zone_on(b, Vector2i(3, 2), push, 2, 1, H.RIGHT)
	assert_that(BattleTurn.zone_step(b, u)).is_equal(H.RIGHT)        # equal directions do not add distance
	H.zone_on(b, Vector2i(2, 3), push, 3, 1, H.LEFT)
	assert_that(BattleTurn.zone_step(b, u)).is_equal(H.RIGHT)        # one pair cancels, one remains
	H.zone_on(b, Vector2i(3, 3), push, 4, 1, H.LEFT)
	assert_that(BattleTurn.zone_step(b, u)).is_equal(Vector2i.ZERO)
	H.zone_on(b, Vector2i(3, 3), push, 4, 1, H.UP)
	assert_that(BattleTurn.zone_step(b, u)).is_equal(Vector2i.ZERO)  # right and up remain: not one cardinal direction
	H.zone_on(b, Vector2i(3, 2), push, 2, 1, H.UP)
	assert_that(BattleTurn.zone_step(b, u)).is_equal(H.UP)           # right + left cancel, up (twice) remains once


func test_one_hit_per_monster_per_payload_and_separate_payloads_add() -> void:
	var b := H.battle([
		[0, Vector2i(1, 3), {"init": 9.0, "reach": 4, "ap": 5, "skills": [H.strike("arc"), H.surge([Vector2i.ZERO, Vector2i(0, 1)])]}],
		_big(Vector2i(2, 2), 1, {"hp": 10}),
	])
	b.set_ground(Vector2i(3, 3), &"hallowed")
	b.begin()
	b.apply({"type": &"skill", "slot": 0, "dir": H.RIGHT})   # Arc covers (2,2) (2,3) (2,4): two body squares
	assert_int(H.unit(b, 1).hp).is_equal(8)                  # struck once
	b.apply({"type": &"skill", "slot": 1, "anchor": Vector2i(3, 2)})   # (3,2) (3,3)
	b.apply({"type": &"skill", "slot": 1, "anchor": Vector2i(2, 2)})   # (2,2) (2,3)
	H.until_turn_of(b, &"u0")
	# two Surges, each once: (3 - 1 Hallowed under any covered square) twice
	assert_int(H.unit(b, 1).hp).is_equal(4)


func test_a_2x2_striker_picks_its_origin_square_and_never_hits_itself() -> void:
	var b := H.battle([_big(Vector2i(2, 2), 0, {"ap": 5, "skills": [H.strike("thrust")]}), [1, Vector2i(5, 3)], [1, Vector2i(2, 0)]])
	b.begin()
	assert_str(b.check({"type": &"skill", "slot": 0, "dir": H.RIGHT, "origin": Vector2i(4, 4)})).contains("square of the striker")
	assert_bool(b.apply({"type": &"skill", "slot": 0, "dir": H.RIGHT, "origin": Vector2i(3, 3)})).is_true()   # (4,3) (5,3)
	assert_int(H.unit(b, 1).hp).is_equal(3)
	assert_int(H.unit(b, 0).hp).is_equal(9)


func test_radial_push_of_a_2x2_target_uses_the_mean_of_its_adjacent_hit_squares() -> void:
	var shove := H.strike("storm", false)
	shove.radial_push = true
	shove.strike_damage = 0
	var b := H.battle([[0, Vector2i(3, 4), {"init": 9.0, "ap": 4, "skills": [shove]}], _big(Vector2i(3, 2), 1), _big(Vector2i(1, 4), 1)])
	b.begin()
	b.apply({"type": &"skill", "slot": 0, "dir": Vector2i.ZERO})
	# covered hit squares (3,3) and (4,3): offsets (0,-1) + (1,-1) → not on one of the 8 directions
	assert_that(H.unit(b, 1).pos).is_equal(Vector2i(3, 2))
	# covered hit squares (2,4) and (2,5): offsets (-1,0) + (-1,1) → no push either
	assert_that(H.unit(b, 2).pos).is_equal(Vector2i(1, 4))
	var c := H.battle([[0, Vector2i(3, 4), {"init": 9.0, "ap": 4, "skills": [shove]}], _big(Vector2i(2, 2), 1)])
	c.begin()
	c.apply({"type": &"skill", "slot": 0, "dir": Vector2i.ZERO})
	# covered hit squares (2,3) and (3,3): offsets (-1,-1) + (0,-1) → off the 8 directions too;
	# a body centred on the origin's column is pushed straight
	assert_that(H.unit(c, 1).pos).is_equal(Vector2i(2, 2))
	var d := H.battle([[0, Vector2i(3, 4), {"init": 9.0, "ap": 4, "skills": [shove]}], _big(Vector2i(2, 2), 1), [0, Vector2i(6, 6)]])
	H.unit(d, 1).pos = Vector2i(2, 2)
	d.begin()
	var shove_arc := H.strike("jab", false)
	shove_arc.radial_push = true
	shove_arc.strike_damage = 0
	H.unit(d, 0).sheet.skills[0] = shove_arc
	d.apply({"type": &"skill", "slot": 0, "dir": H.UP})      # only (3,3) is hit: offset (0,-1)
	assert_that(H.unit(d, 1).pos).is_equal(Vector2i(2, 1))


# ---------- air layer ----------

func test_flyers_ignore_ground_and_fly_over_ground_obstacles() -> void:
	var b := H.battle([
		[0, Vector2i(3, 3), {"init": 9.0, "airborne": true, "move": 3, "ap": 4, "reach": 2, "skills": ["run"]}],
		[1, Vector2i(3, 2)], [1, Vector2i(6, 6)],
	])
	var u := H.unit(b, 0)
	b.set_ground(Vector2i(3, 3), &"lava", 2)
	b.board.at(Vector2i(3, 3)).height = 1
	b.set_ground(Vector2i(4, 3), &"thornbed", 2)
	b.set_ground(Vector2i(5, 3), &"rubble")
	b.add_prop(&"stone_lion", Vector2i(2, 3))
	b.add_prop(&"wind_chime", Vector2i(3, 4))
	assert_int(BattleStats.reach(b, u)).is_equal(2)          # no Mountain bonus in the air
	var opts := BattleMoves.options(b, u, BattleMoves.profile_of(H.skill("run")))
	assert_bool(opts.has(Vector2i(3, 2))).is_true()          # above a ground monster
	assert_bool(opts.has(Vector2i(2, 3))).is_true()          # above a ground prop
	assert_bool(opts.has(Vector2i(3, 4))).is_false()         # an air prop blocks flight
	assert_bool(opts.has(Vector2i(3, 5))).is_false()         # ... and the way through it (3 steps around are 3: allowed)
	assert_int(opts[Vector2i(6, 3)]["cost"]).is_equal(3)     # Rubble costs a flyer nothing extra
	b.begin()
	assert_bool(b.apply({"type": &"skill", "slot": 0, "to": Vector2i(5, 3)})).is_true()
	assert_int(u.hp).is_equal(5)                             # flew over Thornbed II
	b.set_ground(Vector2i(5, 3), &"lava", 2)
	b.end_turn()
	assert_int(u.hp).is_equal(5)                             # and ends its turn above Lava


func test_surges_and_zone_effects_reach_the_air_only_when_authored() -> void:
	var ground_surge := H.surge([Vector2i.ZERO])
	var air_surge := H.surge([Vector2i.ZERO])
	air_surge.surge_hits_air = true
	var slow_ground := H.zone_skill([FieldEffect.make("slow", 1, 2)]).zone
	var slow_air := H.zone_skill([FieldEffect.make("slow", 1, 2, true)], [Vector2i.ZERO], 2, "slow_air").zone
	var b := H.battle([
		[0, Vector2i(3, 5), {"init": 9.0, "reach": 3, "ap": 3, "skills": [ground_surge, air_surge]}],
		[1, Vector2i(3, 3), {"airborne": true, "hp": 8, "move": 3}], [1, Vector2i(4, 3), {"airborne": true, "hp": 8, "move": 3}],
		[1, Vector2i(3, 3), {"hp": 8}],
	])
	H.zone_on(b, Vector2i(3, 3), slow_ground)
	H.zone_on(b, Vector2i(4, 3), slow_air, 901)
	assert_int(BattleStats.movement(b, H.unit(b, 1))).is_equal(3)
	assert_int(BattleStats.movement(b, H.unit(b, 2))).is_equal(2)
	b.begin()
	b.apply({"type": &"skill", "slot": 0, "anchor": Vector2i(3, 3)})
	b.apply({"type": &"skill", "slot": 1, "anchor": Vector2i(4, 3)})
	H.until_turn_of(b, &"u0")
	assert_int(H.unit(b, 1).hp).is_equal(8)      # above a ground-only Surge
	assert_int(H.unit(b, 3).hp).is_equal(5)      # the ground monster on the same square
	assert_int(H.unit(b, 2).hp).is_equal(5)      # the Surge with authored air recipients


func test_air_props_live_on_the_air_layer_only() -> void:
	var b := H.battle([
		[0, Vector2i(3, 4), {"init": 9.0, "ap": 4, "skills": [H.strike()]}],
		[1, Vector2i(2, 2), {"airborne": true, "init": 5.0}], [1, Vector2i(4, 2), {"init": 5.0}], [1, Vector2i(3, 2), {"init": 5.0}],
	])
	b.add_prop(&"thunder_cloud", Vector2i(3, 3))
	b.add_prop(&"gale_banner", Vector2i(2, 1))
	assert_object(b.board.at(Vector2i(3, 3)).prop).is_null()
	assert_float(BattleStats.initiative(b, H.unit(b, 1))).is_equal(6.0)   # Gale Banner: air neighbours only
	b.add_prop(&"gale_banner", Vector2i(4, 1))
	assert_float(BattleStats.initiative(b, H.unit(b, 2))).is_equal(5.0)
	b.begin()
	assert_str(b.check({"type": &"step", "to": Vector2i(3, 3)})).is_empty()   # a ground monster may walk below it
	b.apply({"type": &"skill", "slot": 0, "dir": H.UP})      # Strikes hit air props
	assert_object(b.board.at(Vector2i(3, 3)).air_prop).is_null()
	assert_int(H.unit(b, 1).hp).is_equal(4)      # Thunder Cloud aftermath: air-layer monsters only
	assert_int(H.unit(b, 2).hp).is_equal(5)
	assert_int(H.unit(b, 3).hp).is_equal(5)
	assert_str(b.board.at(Vector2i(3, 3)).ground).is_equal("plain")       # air props never change ground
	# the Pagoda Bridge occupies both layers of its square
	var bridge := b.add_prop(&"pagoda_bridge", Vector2i(5, 5))
	assert_bool(b.board.prop_at(Vector2i(5, 5), Board.GROUND) == bridge and b.board.prop_at(Vector2i(5, 5), Board.AIR) == bridge).is_true()
	assert_object(b.add_prop(&"wind_chime", Vector2i(5, 5))).is_null()
