extends GdUnitTestSuite
## Tamer skills of the battle loadout (gdd_battle §5.2, §6.1; gdd_overworld §6.4).

const H := preload("res://tests/battle/helpers.gd")


func _battle(specs: Array, skills: Array) -> Battle:
	var b := H.battle(specs)
	for id: StringName in skills:
		b.tamer_loadout[0].append(H.content().tamer_skill(id))
	return b


func _use(b: Battle, skill: StringName, extra: Dictionary = {}) -> bool:
	var a := {"type": &"tamer", "side": 0, "skill": skill}
	a.merge(extra)
	return b.apply(a)


func test_window_own_turn_only_once_per_battle_and_free() -> void:
	var b := _battle([[0, Vector2i(3, 3), {"init": 9.0, "current_hp": 2}], [1, Vector2i(6, 6), {"init": 5.0}]], [&"second_wind"])
	b.begin()
	assert_bool(_use(b, &"second_wind", {"unit": &"u0"})).is_true()
	assert_int(H.unit(b, 0).hp).is_equal(3)
	assert_int(b.ap).is_equal(3)                 # no AP, no turn
	assert_str(b.check({"type": &"tamer", "side": 0, "skill": &"second_wind", "unit": &"u0"})).contains("already used")
	assert_str(b.check({"type": &"tamer", "side": 0, "skill": &"life_thread", "unit": &"u0"})).contains("not in the loadout")
	var c := _battle([[0, Vector2i(3, 3), {"init": 1.0}], [1, Vector2i(6, 6), {"init": 5.0}]], [&"second_wind"])
	c.begin()                                    # the enemy acts first
	assert_str(c.check({"type": &"tamer", "side": 0, "skill": &"second_wind", "unit": &"u0"})).contains("own monsters")
	assert_array(BattleSetup.make_result(b).used_tamer).is_equal([&"second_wind"])


func test_second_wind_never_heals_above_max() -> void:
	var b := _battle([[0, Vector2i(3, 3), {"init": 9.0}], [1, Vector2i(6, 6)]], [&"second_wind"])
	b.begin()
	_use(b, &"second_wind", {"unit": &"u0"})
	assert_int(H.unit(b, 0).hp).is_equal(5)


func test_swap_places_trades_squares_and_counts_as_entering() -> void:
	var b := _battle([[0, Vector2i(2, 2), {"init": 9.0}], [0, Vector2i(5, 5), {"init": 8.0}], [1, Vector2i(6, 0)]], [&"swap_places"])
	b.set_ground(Vector2i(5, 5), &"thornbed", 2)
	b.set_ground(Vector2i(2, 2), &"mossbed")
	H.unit(b, 1).hp = 3
	b.begin()
	assert_bool(_use(b, &"swap_places", {"unit": &"u0", "other": &"u1"})).is_true()
	assert_that(H.unit(b, 0).pos).is_equal(Vector2i(5, 5))
	assert_that(H.unit(b, 1).pos).is_equal(Vector2i(2, 2))
	assert_int(H.unit(b, 0).hp).is_equal(3)      # entered Thornbed II
	assert_int(H.unit(b, 1).hp).is_equal(4)      # entered Mossbed
	assert_str(b.board.unit_id_at(Vector2i(5, 5), Board.GROUND)).is_equal("u0")


func test_swap_places_needs_two_small_ground_monsters() -> void:
	var b := _battle([[0, Vector2i(2, 2), {"init": 9.0}], [0, Vector2i(4, 4), {"size": 2}], [0, Vector2i(0, 6), {"airborne": true}], [1, Vector2i(6, 0)]], [&"swap_places"])
	b.begin()
	assert_str(b.check({"type": &"tamer", "side": 0, "skill": &"swap_places", "unit": &"u0", "other": &"u1"})).contains("1x1")
	assert_str(b.check({"type": &"tamer", "side": 0, "skill": &"swap_places", "unit": &"u0", "other": &"u2"})).contains("ground-layer")
	assert_str(b.check({"type": &"tamer", "side": 0, "skill": &"swap_places", "unit": &"u0", "other": &"u3"})).contains("own monsters")


func test_urgent_order_moves_a_waiting_monster_directly_after_the_current_turn() -> void:
	var b := _battle([
		[0, Vector2i(0, 6), {"init": 9.0}], [1, Vector2i(6, 0), {"init": 7.0}], [1, Vector2i(5, 0), {"init": 6.0}],
		[0, Vector2i(1, 6), {"init": 2.0, "tpr": 2}],
	], [&"urgent_order"])
	b.begin()
	assert_array(b.queue.map(func(e): return e["id"])).is_equal([&"u0", &"u1", &"u2", &"u3", &"u3"])
	assert_bool(_use(b, &"urgent_order", {"unit": &"u3"})).is_true()
	# the original main entry is removed (no double action); the extra-turn entry stays
	assert_array(b.queue.map(func(e): return e["id"])).is_equal([&"u0", &"u3", &"u1", &"u2", &"u3"])
	b.end_turn()
	assert_str(b.turn_owner).is_equal("u3")
	for i in 4:
		b.end_turn()
	assert_int(b.round_number).is_equal(2)       # the round-end re-sort is unchanged
	assert_array(b.queue.map(func(e): return e["id"])).is_equal([&"u0", &"u1", &"u2", &"u3", &"u3"])


func test_urgent_order_needs_a_monster_that_has_not_acted() -> void:
	var b := _battle([[0, Vector2i(0, 6), {"init": 9.0}], [0, Vector2i(1, 6), {"init": 8.0}], [1, Vector2i(6, 0), {"init": 1.0}]], [&"urgent_order"])
	b.begin()
	b.end_turn()                                 # u1 is acting now, u0 has acted
	assert_str(b.check({"type": &"tamer", "side": 0, "skill": &"urgent_order", "unit": &"u0"})).contains("already acted")


func test_spirit_shield_and_life_thread_protect_one_monster() -> void:
	var b := _battle([
		[0, Vector2i(3, 3), {"init": 9.0, "hp": 3}],
		[1, Vector2i(3, 5), {"init": 5.0, "reach": 3, "ap": 3, "skills": [H.surge([Vector2i.ZERO]), H.strike()]}],
	], [&"spirit_shield", &"life_thread"])
	b.begin()
	assert_bool(_use(b, &"spirit_shield", {"unit": &"u0"})).is_true()
	assert_str(b.check({"type": &"tamer", "side": 0, "skill": &"spirit_shield", "unit": &"u0"})).is_not_empty()
	assert_bool(_use(b, &"life_thread", {"unit": &"u0"})).is_true()
	b.end_turn()
	b.apply({"type": &"skill", "slot": 0, "anchor": Vector2i(3, 3)})
	H.until_turn_of(b, &"u1")
	assert_int(H.unit(b, 0).hp).is_equal(3)      # the Surge damage became 0
	assert_bool(H.unit(b, 0).nullify).is_false()
	b.apply({"type": &"skill", "slot": 0, "anchor": Vector2i(3, 3)})
	H.until_turn_of(b, &"u1")
	assert_int(H.unit(b, 0).hp).is_equal(1)      # lethal 3 damage: Life Thread leaves 1 HP
	assert_bool(H.unit(b, 0).defeated).is_false()
	b.apply({"type": &"skill", "slot": 0, "anchor": Vector2i(3, 3)})
	H.until_turn_of(b, &"u1")
	assert_bool(H.unit(b, 0).defeated).is_true() # later lethal damage defeats normally


func test_domain_glimpse_clears_zones_and_ground_on_any_tetromino() -> void:
	var slow := H.zone_skill([FieldEffect.make("slow", 1, 2)]).zone
	var b := _battle([[0, Vector2i(0, 6), {"init": 9.0}], [1, Vector2i(3, 3), {"hp": 5}]], [&"domain_glimpse"])
	var cells: Array = [Vector2i(3, 2), Vector2i(3, 3), Vector2i(3, 4), Vector2i(4, 4)]   # an L, far from the tamer's monster
	for p: Vector2i in cells:
		H.zone_on(b, p, slow)
		b.set_ground(p, &"lava", 2)
	b.set_ground(Vector2i(3, 2), &"voidscar")
	b.board.at(Vector2i(3, 4)).height = 1
	b.add_prop(&"stone_lion", Vector2i(4, 4))
	b.board.at(Vector2i(3, 3)).surge = 5
	b.begin()
	assert_str(b.check({"type": &"tamer", "side": 0, "skill": &"domain_glimpse", "cells": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(4, 0)]})).contains("tetromino")
	assert_str(b.check({"type": &"tamer", "side": 0, "skill": &"domain_glimpse", "cells": [Vector2i(6, 6), Vector2i(7, 6), Vector2i(6, 5), Vector2i(6, 4)]})).contains("tetromino")
	assert_bool(_use(b, &"domain_glimpse", {"cells": cells})).is_true()
	for p: Vector2i in cells:
		assert_object(b.board.at(p).zone).is_null()
	assert_str(b.board.at(Vector2i(3, 3)).ground).is_equal("plain")
	assert_str(b.board.at(Vector2i(3, 2)).ground).is_equal("voidscar")    # Voidscar stays
	assert_int(b.board.at(Vector2i(3, 4)).height).is_equal(1)             # Mountains stay
	assert_object(b.board.at(Vector2i(4, 4)).prop).is_not_null()          # props stay
	assert_int(b.board.at(Vector2i(3, 3)).surge).is_equal(5)              # Surge markers stay
	assert_int(H.unit(b, 1).hp).is_equal(5)


func test_beast_swap_takes_square_and_queue_entry_and_orphans_the_surges() -> void:
	var b := _battle([
		[0, Vector2i(0, 6), {"init": 9.0}],
		[0, Vector2i(3, 5), {"init": 6.0, "reach": 3, "skills": [H.surge([Vector2i.ZERO])]}],
		[1, Vector2i(3, 3), {"init": 8.0, "hp": 8}],
	], [&"beast_swap"])
	var bench := BattleUnit.new(&"bench", H.sheet({"init": 3.0, "hp": 6, "current_hp": 4, "name": "Bench"}), 0, 2, Vector2i.ZERO)
	b.add_unit(bench, false)
	var big := BattleUnit.new(&"big", H.sheet({"size": 2, "name": "Big"}), 0, 3, Vector2i.ZERO)
	b.add_unit(big, false)
	b.begin()
	assert_array(b.queue.map(func(e): return e["id"])).is_equal([&"u0", &"u2", &"u1"])   # the bench does not queue
	assert_str(b.check({"type": &"tamer", "side": 0, "skill": &"beast_swap", "unit": &"u1", "other": &"big"})).contains("same body size")
	assert_str(b.check({"type": &"tamer", "side": 0, "skill": &"beast_swap", "unit": &"u0", "other": &"bench"})).contains("turn is running")
	b.end_turn()
	b.end_turn()                                 # u1's turn: it declares a Surge
	b.apply({"type": &"skill", "slot": 0, "anchor": Vector2i(3, 3)})
	b.end_turn()                                 # round 2, u0's turn
	assert_bool(_use(b, &"beast_swap", {"unit": &"u1", "other": &"bench"})).is_true()
	assert_that(bench.pos).is_equal(Vector2i(3, 5))
	assert_int(bench.hp).is_equal(4)             # arrives with its current HP
	assert_bool(H.unit(b, 1).on_field).is_false()
	assert_bool(H.unit(b, 1).defeated).is_false()
	assert_array(b.queue.map(func(e): return e["id"])).is_equal([&"u0", &"u2", &"bench"])  # the pending entry
	assert_bool(b.surges[0].orphaned).is_true()
	assert_int(H.unit(b, 2).hp).is_equal(8)
	b.end_turn()
	b.end_turn()
	assert_str(b.turn_owner).is_equal("bench")
	assert_int(H.unit(b, 2).hp).is_equal(8)      # not at the swapped-in monster's turn
	b.end_turn()                                 # round 3 starts: the orphaned Surge detonates
	assert_int(H.unit(b, 2).hp).is_equal(5)
	# the swapped-out monster does not count as fallen
	var r := BattleSetup.make_result(b)
	assert_int(r.survivors(0)).is_equal(4)
