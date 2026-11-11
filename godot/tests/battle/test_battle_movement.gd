extends GdUnitTestSuite
## Movement presets as flag profiles (gdd_skills §3 Movement, §8.2).

const H := preload("res://tests/battle/helpers.gd")


func _opts(b: Battle, i: int, preset: String) -> Dictionary:
	return BattleMoves.options(b, H.unit(b, i), BattleMoves.profile_of(H.skill(preset)))


func _mover(move := 2, o: Dictionary = {}) -> Array:
	var sheet := {"init": 9.0, "move": move, "ap": 4, "skills": ["run", "leap", "glide", "burrow", "phase", "blink"]}
	sheet.merge(o, true)
	return [0, Vector2i(3, 3), sheet]


func test_run_walks_orthogonally_and_pays_for_rubble_and_climbing() -> void:
	var b := H.battle([_mover(2), [1, Vector2i(6, 6)]])
	assert_int(_opts(b, 0, "run").size()).is_equal(12)      # every square within 2 orthogonal steps
	b.set_ground(Vector2i(3, 2), &"rubble")                 # costs 2
	b.board.at(Vector2i(4, 3)).height = 1                   # climbing costs 2
	var opts := _opts(b, 0, "run")
	assert_int(opts[Vector2i(3, 2)]["cost"]).is_equal(2)
	assert_int(opts[Vector2i(4, 3)]["cost"]).is_equal(2)
	assert_bool(opts.has(Vector2i(3, 1))).is_false()
	assert_bool(opts.has(Vector2i(5, 3))).is_false()
	assert_bool(opts.has(Vector2i(4, 2))).is_false()        # behind the Rubble and the climb: 3 either way
	assert_int(opts.size()).is_equal(9)


func test_run_is_blocked_by_props_monsters_and_slowed_by_zones() -> void:
	var slow := H.zone_skill([FieldEffect.make("slow", 1, 2)])
	var b := H.battle([_mover(3), [1, Vector2i(3, 2)], [1, Vector2i(6, 6)]])
	b.add_prop(&"clay_urn", Vector2i(2, 3))
	var opts := _opts(b, 0, "run")
	assert_bool(opts.has(Vector2i(3, 2))).is_false()        # occupied
	assert_bool(opts.has(Vector2i(2, 3))).is_false()
	assert_bool(opts.has(Vector2i(3, 1))).is_false()        # around the monster: 4 steps
	assert_bool(opts.has(Vector2i(1, 3))).is_false()        # around the prop: 4 steps
	assert_bool(opts.has(Vector2i(6, 3))).is_true()
	H.zone_on(b, Vector2i(3, 3), slow.zone, 1, 2)           # slow 2: Movement 3 → 1
	assert_array(_opts(b, 0, "run").keys()).contains_exactly_in_any_order([Vector2i(4, 3), Vector2i(3, 4)])


func test_leap_is_a_straight_line_that_only_counts_the_landing_square() -> void:
	var b := H.battle([_mover(3), [1, Vector2i(3, 2)], [1, Vector2i(6, 6)]])
	b.add_prop(&"stone_lion", Vector2i(4, 4))
	var opts := _opts(b, 0, "leap")
	assert_bool(opts.has(Vector2i(3, 1))).is_true()         # over the monster
	assert_bool(opts.has(Vector2i(3, 0))).is_true()
	assert_bool(opts.has(Vector2i(3, 2))).is_false()        # no occupied landing
	assert_bool(opts.has(Vector2i(5, 5))).is_true()         # diagonal line over the prop
	assert_bool(opts.has(Vector2i(4, 4))).is_false()
	assert_bool(opts.has(Vector2i(5, 4))).is_false()        # not a straight line
	assert_bool(opts.has(Vector2i(0, 3))).is_true()
	assert_bool(opts.has(Vector2i(6, 0))).is_true()         # exactly Movement 3 along the diagonal


func test_glide_burrow_phase_and_blink_drop_restrictions_for_distance() -> void:
	var b := H.battle([_mover(3), [1, Vector2i(3, 2)], [1, Vector2i(6, 6)]])
	b.add_prop(&"stone_lion", Vector2i(4, 3))
	b.board.at(Vector2i(2, 3)).height = 1
	b.board.at(Vector2i(3, 4)).surge = 77                   # a charging Surge square
	# Glide: any path, Movement - 1 = 2; charging Surges block the path
	var glide := _opts(b, 0, "glide")
	assert_bool(glide.has(Vector2i(3, 1))).is_true()        # over the monster
	assert_bool(glide.has(Vector2i(5, 3))).is_true()        # over the prop
	assert_bool(glide.has(Vector2i(3, 4))).is_false()
	assert_bool(glide.has(Vector2i(3, 5))).is_false()       # only reachable through the Surge square
	assert_bool(glide.has(Vector2i(2, 3))).is_true()        # may land on a Mountain
	# Burrow: nothing blocks, but it cannot end (or start) on a Mountain
	var burrow := _opts(b, 0, "burrow")
	assert_bool(burrow.has(Vector2i(3, 5))).is_true()
	assert_bool(burrow.has(Vector2i(2, 3))).is_false()
	b.board.at(Vector2i(3, 3)).height = 1
	assert_int(_opts(b, 0, "burrow").size()).is_equal(0)
	b.board.at(Vector2i(3, 3)).height = 0
	# Phase: walks through props (not onto them), monsters still block
	var phase := _opts(b, 0, "phase")
	assert_bool(phase.has(Vector2i(5, 3))).is_true()
	assert_bool(phase.has(Vector2i(4, 3))).is_false()
	assert_bool(phase.has(Vector2i(3, 1))).is_false()
	# Blink: any free square within Movement - 2 = 1 (board distance, so diagonals count);
	# it is not blocked by charging Surges and may land in one
	var blink := _opts(b, 0, "blink")
	assert_array(blink.keys()).contains_exactly_in_any_order([Vector2i(2, 2), Vector2i(4, 2), Vector2i(2, 3), Vector2i(2, 4),
		Vector2i(3, 4), Vector2i(4, 4)])


func test_every_movement_skill_moves_at_least_one_square() -> void:
	var b := H.battle([_mover(1), [1, Vector2i(6, 6)]])
	assert_int(_opts(b, 0, "blink").size()).is_equal(8)     # Movement 1 - 2, floored at 1
	assert_int(_opts(b, 0, "glide").size()).is_equal(4)


func test_walking_takes_the_route_with_the_least_entry_harm() -> void:
	var b := H.battle([_mover(4), [1, Vector2i(6, 6)]])
	b.set_ground(Vector2i(3, 2), &"thornbed", 2)
	b.begin()
	var opts := _opts(b, 0, "run")
	assert_int(opts[Vector2i(3, 1)]["harm"]).is_equal(0)    # around the Thornbed in 4 steps
	assert_int(opts[Vector2i(3, 2)]["harm"]).is_equal(2)
	assert_bool(b.apply({"type": &"skill", "slot": 0, "to": Vector2i(3, 1)})).is_true()
	assert_int(H.unit(b, 0).hp).is_equal(5)
	assert_int(b.ap).is_equal(2)                            # slotted movement: 2 AP
	assert_bool(b.apply({"type": &"skill", "slot": 0, "to": Vector2i(3, 2)})).is_true()
	assert_int(H.unit(b, 0).hp).is_equal(3)                 # Thornbed II on entry


func test_walk_fires_entry_effects_on_every_square_other_paths_only_on_landing() -> void:
	var b := H.battle([_mover(3, {"hp": 9}), [1, Vector2i(6, 6)]])
	b.set_ground(Vector2i(4, 3), &"thornbed", 1)
	b.set_ground(Vector2i(5, 3), &"thornbed", 1)
	b.add_prop(&"stone_lion", Vector2i(4, 2))
	b.add_prop(&"stone_lion", Vector2i(4, 4))
	b.add_prop(&"stone_lion", Vector2i(5, 2))
	b.add_prop(&"stone_lion", Vector2i(5, 4))
	b.begin()
	assert_bool(b.apply({"type": &"skill", "slot": 0, "to": Vector2i(6, 3)})).is_true()      # Run through both
	assert_int(H.unit(b, 0).hp).is_equal(7)
	assert_bool(b.apply({"type": &"skill", "slot": 1, "to": Vector2i(4, 3)})).is_true()      # Leap back: landing only
	assert_int(H.unit(b, 0).hp).is_equal(6)


func test_rooted_passive_forbids_step_and_movement_skills() -> void:
	var turret := H.passive("t_turret", {"rooted": true, "passive_effects": [FieldEffect.make("extend", 1)] as Array[FieldEffect]})
	var b := H.battle([[0, Vector2i(3, 3), {"init": 9.0, "reach": 2, "skills": ["run", turret]}], [1, Vector2i(6, 6)]])
	b.begin()
	assert_str(b.check({"type": &"step", "to": Vector2i(3, 2)})).contains("cannot move")
	assert_str(b.check({"type": &"skill", "slot": 0, "to": Vector2i(3, 2)})).contains("cannot move")
	assert_int(BattleStats.reach(b, H.unit(b, 0))).is_equal(3)


func test_kit_movement_matches_the_kin_table() -> void:
	# gdd_skills §8.2: Leap Beast, Glide Winged, Burrow Scaled/Swarm, Phase Spirit, Run all but Spirit
	var expect := {&"blaze_tiger": &"leap", &"ember_hawk": &"glide", &"moss_turtle": &"run", &"thorn_mites": &"burrow",
		&"grove_wisp": &"phase", &"gloom_wolf": &"run", &"dusk_moth": &"glide", &"hollow_serpent": &"burrow"}
	for species: StringName in expect:
		var kit := H.content().kit(species)
		assert_str(kit.skills[0].id).is_equal(expect[species])
	var golem := H.content().kit(&"forge_golem")
	for s in golem.skills:
		assert_str(s.kind).is_not_equal("move")             # Step only
