extends GdUnitTestSuite
## Tamer skills of the battle loadout (gdd_battle §5.2, §6.1; gdd_overworld §6.4).

const H := preload("res://tests/battle/helpers.gd")


func before_test() -> void:
	H.legacy_rules()


func after_test() -> void:
	BattleExperiment.reset()


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
	var b := _battle([[0, Vector2i(3, 3), {"pace": 1.9, "current_hp": 2}], [1, Vector2i(6, 6), {"pace": 1.5}]], [&"second_wind"])
	b.begin()
	assert_bool(_use(b, &"second_wind", {"unit": &"u0"})).is_true()
	assert_int(H.unit(b, 0).hp).is_equal(3)
	assert_int(b.ap).is_equal(3)                 # no AP, no turn
	assert_str(b.check({"type": &"tamer", "side": 0, "skill": &"second_wind", "unit": &"u0"})).contains("already used")
	assert_str(b.check({"type": &"tamer", "side": 0, "skill": &"life_thread", "unit": &"u0"})).contains("not in the loadout")
	var c := _battle([[0, Vector2i(3, 3), {"pace": 1.1}], [1, Vector2i(6, 6), {"pace": 1.5}]], [&"second_wind"])
	c.begin()                                    # the enemy acts first
	assert_str(c.check({"type": &"tamer", "side": 0, "skill": &"second_wind", "unit": &"u0"})).contains("own monsters")
	assert_array(BattleSetup.make_result(b).used_tamer).is_equal([&"second_wind"])


func test_second_wind_never_heals_above_max() -> void:
	var b := _battle([[0, Vector2i(3, 3), {"pace": 1.9}], [1, Vector2i(6, 6)]], [&"second_wind"])
	b.begin()
	_use(b, &"second_wind", {"unit": &"u0"})
	assert_int(H.unit(b, 0).hp).is_equal(5)


func test_swap_places_trades_squares_and_counts_as_entering() -> void:
	var b := _battle([[0, Vector2i(2, 2), {"pace": 1.9}], [0, Vector2i(5, 5), {"pace": 1.8}], [1, Vector2i(6, 0)]], [&"swap_places"])
	b.set_ground(Vector2i(5, 5), &"thornbed", 1)
	b.set_ground(Vector2i(2, 2), &"mossbed")
	H.unit(b, 1).hp = 3
	b.begin()
	assert_bool(_use(b, &"swap_places", {"unit": &"u0", "other": &"u1"})).is_true()
	assert_that(H.unit(b, 0).pos).is_equal(Vector2i(5, 5))
	assert_that(H.unit(b, 1).pos).is_equal(Vector2i(2, 2))
	assert_int(H.unit(b, 0).hp).is_equal(4)      # entered Thornbed
	assert_int(H.unit(b, 1).hp).is_equal(4)      # entered Mossbed
	assert_str(b.board.unit_id_at(Vector2i(5, 5), Board.GROUND)).is_equal("u0")


func test_swap_places_needs_two_small_ground_monsters() -> void:
	var b := _battle([[0, Vector2i(2, 2), {"pace": 1.9}], [0, Vector2i(4, 4), {"size": 2}], [0, Vector2i(0, 6), {"airborne": true}], [1, Vector2i(6, 0)]], [&"swap_places"])
	b.begin()
	assert_str(b.check({"type": &"tamer", "side": 0, "skill": &"swap_places", "unit": &"u0", "other": &"u1"})).contains("1x1")
	assert_str(b.check({"type": &"tamer", "side": 0, "skill": &"swap_places", "unit": &"u0", "other": &"u2"})).contains("ground-layer")
	assert_str(b.check({"type": &"tamer", "side": 0, "skill": &"swap_places", "unit": &"u0", "other": &"u3"})).contains("own monsters")


func test_urgent_order_moves_a_waiting_monster_directly_after_the_current_turn() -> void:
	BattleExperiment.tpr_from_round = 1       # extra turns as from round 2 on
	var b := _battle([
		[0, Vector2i(0, 6), {"pace": 1.9}], [1, Vector2i(6, 0), {"pace": 1.7}], [1, Vector2i(5, 0), {"pace": 1.6}],
		[0, Vector2i(1, 6), {"pace": 1.2, "tpr": 2}],
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
	var b := _battle([[0, Vector2i(0, 6), {"pace": 1.9}], [0, Vector2i(1, 6), {"pace": 1.8}], [1, Vector2i(6, 0), {"pace": 1.1}]], [&"urgent_order"])
	b.begin()
	b.end_turn()                                 # u1 is acting now, u0 has acted
	assert_str(b.check({"type": &"tamer", "side": 0, "skill": &"urgent_order", "unit": &"u0"})).contains("already acted")


func test_spirit_shield_and_life_thread_protect_one_monster() -> void:
	var b := _battle([
		[0, Vector2i(3, 3), {"pace": 1.9, "hp": 3}],
		[1, Vector2i(3, 5), {"pace": 1.5, "reach": 3, "ap": 3, "skills": [H.surge([Vector2i.ZERO]), H.strike()]}],
	], [&"spirit_shield", &"life_thread"])
	b.begin()
	assert_bool(_use(b, &"spirit_shield", {"unit": &"u0"})).is_true()
	assert_str(b.check({"type": &"tamer", "side": 0, "skill": &"spirit_shield", "unit": &"u0"})).is_not_empty()
	assert_bool(_use(b, &"life_thread", {"unit": &"u0"})).is_true()
	b.end_turn()
	# the enemy's Surge is armed under the protected monster and sprung at once
	var fire := func() -> void:
		b._declare_surge(H.unit(b, 1), H.unit(b, 1).sheet.skills[0], {"slot": 0, "anchor": Vector2i(3, 3)})
		BattleTurn.detonate(b, b.surges.duplicate())
		b.check_over()
	fire.call()
	assert_int(H.unit(b, 0).hp).is_equal(3)      # the Surge damage became 0
	assert_bool(H.unit(b, 0).nullify).is_false()
	fire.call()
	assert_int(H.unit(b, 0).hp).is_equal(1)      # lethal 3 damage: Life Thread leaves 1 HP
	assert_bool(H.unit(b, 0).defeated).is_false()
	fire.call()
	assert_bool(H.unit(b, 0).defeated).is_true() # later lethal damage defeats normally


func test_domain_glimpse_clears_zones_and_ground_on_any_tetromino() -> void:
	var slow := H.zone_skill([FieldEffect.make("slow", 1, 2)]).zone
	var b := _battle([[0, Vector2i(0, 6), {"pace": 1.9}], [1, Vector2i(3, 3), {"hp": 5}]], [&"domain_glimpse"])
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


func test_beast_swap_takes_square_and_queue_entry_and_leaves_its_traps_set() -> void:
	var b := _battle([
		[0, Vector2i(0, 6), {"pace": 1.9}],
		[0, Vector2i(3, 5), {"pace": 1.6, "reach": 3, "skills": [H.surge([Vector2i.ZERO])]}],
		[1, Vector2i(3, 3), {"pace": 1.8, "hp": 8}],
	], [&"beast_swap"])
	var bench := BattleUnit.new(&"bench", H.sheet({"pace": 1.3, "hp": 6, "current_hp": 4, "name": "Bench"}), 0, 2, Vector2i.ZERO)
	b.add_unit(bench, false)
	var big := BattleUnit.new(&"big", H.sheet({"size": 2, "name": "Big"}), 0, 3, Vector2i.ZERO)
	b.add_unit(big, false)
	b.begin()
	assert_array(b.queue.map(func(e): return e["id"])).is_equal([&"u0", &"u2", &"u1"])   # the bench does not queue
	assert_str(b.check({"type": &"tamer", "side": 0, "skill": &"beast_swap", "unit": &"u1", "other": &"big"})).contains("same body size")
	assert_str(b.check({"type": &"tamer", "side": 0, "skill": &"beast_swap", "unit": &"u0", "other": &"bench"})).contains("turn is running")
	b.end_turn()
	b.end_turn()                                 # u1's turn: it sets a trap next to the enemy
	b.apply({"type": &"skill", "slot": 0, "anchor": Vector2i(3, 4)})
	b.end_turn()                                 # round 2, u0's turn
	assert_bool(_use(b, &"beast_swap", {"unit": &"u1", "other": &"bench"})).is_true()
	assert_that(bench.pos).is_equal(Vector2i(3, 5))
	assert_int(bench.hp).is_equal(4)             # arrives with its current HP
	assert_bool(H.unit(b, 1).on_field).is_false()
	assert_bool(H.unit(b, 1).defeated).is_false()
	assert_array(b.queue.map(func(e): return e["id"])).is_equal([&"u0", &"u2", &"bench"])  # the pending entry
	assert_bool(b.surges[0].orphaned).is_true()  # the trap of the swapped-out monster stays set
	b.end_turn()
	assert_bool(b.apply({"type": &"step", "to": Vector2i(3, 4)})).is_true()   # the enemy walks into it
	assert_int(H.unit(b, 2).hp).is_equal(5)
	# the swapped-out monster does not count as fallen
	var r := BattleSetup.make_result(b)
	assert_int(r.survivors(0)).is_equal(4)


# ---------- weapons and pills of the hub game ----------

func test_a_weapon_lays_ground_on_a_straight_line() -> void:
	var b := _battle([[0, Vector2i(3, 3), {"pace": 1.9}], [1, Vector2i(6, 6)]], [&"ember_line"])
	b.begin()
	var a := {"type": &"tamer", "side": 0, "skill": &"ember_line"}
	a["cells"] = [Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)]
	assert_str(b.check(a)).contains("straight line")
	a["cells"] = [Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1), Vector2i(4, 1)]
	assert_str(b.check(a)).contains("up to 3")
	a["cells"] = [Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)]
	assert_bool(b.apply(a)).is_true()
	for p: Vector2i in a["cells"]:
		assert_str(String(b.board.at(p).ground)).is_equal("lava")
	assert_str(b.check(a)).contains("already used")


func test_a_weapon_sets_a_prop_that_lapses_like_a_created_one() -> void:
	var b := _battle([[0, Vector2i(3, 3), {"pace": 1.9}], [1, Vector2i(6, 6)]], [&"stone_wall"])
	b.begin()
	assert_str(b.check({"type": &"tamer", "side": 0, "skill": &"stone_wall", "cells": [Vector2i(3, 3)]})).contains("free square")
	assert_bool(b.apply({"type": &"tamer", "side": 0, "skill": &"stone_wall", "cells": [Vector2i(3, 2)]})).is_true()
	var wall := b.board.prop_at(Vector2i(3, 2), Board.GROUND)
	assert_object(wall).is_not_null()
	assert_int(wall.until).is_equal(b.round_number + BoardProp.CREATED_ROUNDS - 1)


func test_an_anchoring_pill_holds_a_monster_until_the_round_ends() -> void:
	var b := _battle([[0, Vector2i(3, 3), {"pace": 1.9, "ap": 4, "skills": [H.strike()]}], [0, Vector2i(3, 2), {"pace": 1.1}],
		[1, Vector2i(6, 6), {"pace": 1.0}]], [&"pill_anchoring"])
	b.begin()
	assert_bool(b.apply({"type": &"tamer", "side": 0, "skill": &"pill_anchoring", "unit": &"u1"})).is_true()
	b.apply({"type": &"skill", "slot": 0, "dir": H.UP})
	assert_that(H.unit(b, 1).pos).is_equal(Vector2i(3, 2))
	H.until_turn_of(b, &"u0")                              # the next round: the pill has worn off
	b.apply({"type": &"skill", "slot": 0, "dir": H.UP})
	assert_that(H.unit(b, 1).pos).is_equal(Vector2i(3, 1))


func test_a_swiftness_pill_raises_the_pace() -> void:
	var b := _battle([[0, Vector2i(3, 3), {"pace": 1.5}], [1, Vector2i(6, 6)]], [&"pill_swiftness"])
	b.begin()
	assert_bool(b.apply({"type": &"tamer", "side": 0, "skill": &"pill_swiftness", "unit": &"u0"})).is_true()
	assert_float(BattleStats.pace(b, H.unit(b, 0))).is_equal_approx(1.8, 0.001)


func test_a_loadout_entry_with_two_uses_is_spent_after_the_second() -> void:
	var b := _battle([[0, Vector2i(3, 3), {"pace": 1.9}], [1, Vector2i(6, 6)]], [&"root_snare"])
	b.tamer_uses[0][&"root_snare"] = 2
	b.begin()
	assert_bool(b.apply({"type": &"tamer", "side": 0, "skill": &"root_snare", "cells": [Vector2i(1, 1)]})).is_true()
	assert_bool(b.tamer_spent(0, &"root_snare")).is_false()
	assert_bool(b.apply({"type": &"tamer", "side": 0, "skill": &"root_snare", "cells": [Vector2i(2, 2)]})).is_true()
	assert_str(b.check({"type": &"tamer", "side": 0, "skill": &"root_snare", "cells": [Vector2i(4, 4)]})).contains("already used")


func test_a_bitter_pill_costs_the_monster_it_is_given_to_one_hp_but_never_its_last() -> void:
	var b := _battle([[0, Vector2i(3, 3), {"pace": 1.9, "hp": 3}], [1, Vector2i(6, 6)]], [&"pill_swiftness", &"pill_anchoring"])
	b.tamer_bitter[0] = [&"pill_swiftness", &"pill_anchoring"]
	b.begin()
	var u: BattleUnit = H.unit(b, 0)
	u.hp = 2
	assert_bool(b.apply({"type": &"tamer", "side": 0, "skill": &"pill_swiftness", "unit": u.id})).is_true()
	assert_int(u.hp).is_equal(1)
	assert_bool(b.apply({"type": &"tamer", "side": 0, "skill": &"pill_anchoring", "unit": u.id})).is_true()
	assert_int(u.hp).is_equal(1)                           # never its last HP
	assert_bool(u.is_alive()).is_true()


func test_a_passive_holds_against_one_kind_of_push_only() -> void:
	var b := _battle([[0, Vector2i(3, 3), {"pace": 1.9, "ap": 4, "skills": [H.strike()]}], [0, Vector2i(3, 2), {"pace": 1.1, "skills": ["braced"]}],
		[0, Vector2i(5, 2), {"pace": 1.0, "skills": ["grounded"]}], [1, Vector2i(6, 6), {"pace": 1.0}]], [])
	b.begin()
	b.apply({"type": &"skill", "slot": 0, "dir": H.UP})
	assert_that(H.unit(b, 1).pos).is_equal(Vector2i(3, 2))             # Braced: a Strike does not move it
	assert_bool(BattleStats.is_immovable(b, H.unit(b, 1), "zone")).is_false()
	assert_bool(BattleDisplace.shove(b, H.unit(b, 1), H.UP, "zone", "zone")).is_true()      # a zone does
	assert_that(H.unit(b, 1).pos).is_equal(Vector2i(3, 1))
	assert_bool(BattleDisplace.shove(b, H.unit(b, 2), H.UP, "zone", "zone")).is_false()     # Grounded: no zone moves it
	assert_bool(BattleDisplace.shove(b, H.unit(b, 2), H.UP, "a prop", "prop")).is_true()    # a prop does
	for id: StringName in [&"braced", &"grounded", &"weighted"]:
		assert_bool(H.content().skill(id).immovable).is_false()        # no passive of the game holds against every push


## A forged weapon for the tests: a tamer skill of the source "weapon" that lays Snare on one square.
func _weapon(b: Battle) -> TamerSkillDef:
	var w: TamerSkillDef = H.content().tamer_skill(&"root_snare").duplicate()
	w.id = &"test_weapon"
	w.source = "weapon"
	b.tamer_loadout[0].append(w)
	return w


func test_whetstone_gives_every_used_weapon_one_more_use_and_second_dose_every_pill() -> void:
	var b := _battle([[0, Vector2i(3, 3), {"pace": 1.9}], [1, Vector2i(6, 6)]], [&"whetstone", &"second_dose", &"pill_swiftness"])
	var w := _weapon(b)
	b.begin()
	assert_str(b.check({"type": &"tamer", "side": 0, "skill": &"whetstone", "unit": &"u0"})).contains("no weapon was used")
	assert_bool(b.apply({"type": &"tamer", "side": 0, "skill": w.id, "cells": [Vector2i(1, 1)]})).is_true()
	assert_bool(b.tamer_spent(0, w.id)).is_true()
	assert_bool(b.apply({"type": &"tamer", "side": 0, "skill": &"whetstone", "unit": &"u0"})).is_true()
	assert_bool(b.tamer_spent(0, w.id)).is_false()
	assert_bool(b.tamer_spent(0, &"whetstone")).is_true()                  # the skill itself is used once
	assert_bool(b.apply({"type": &"tamer", "side": 0, "skill": w.id, "cells": [Vector2i(2, 2)]})).is_true()
	assert_bool(b.tamer_spent(0, w.id)).is_true()
	assert_str(b.check({"type": &"tamer", "side": 0, "skill": &"second_dose", "unit": &"u0"})).contains("no pill was used")
	assert_bool(b.apply({"type": &"tamer", "side": 0, "skill": &"pill_swiftness", "unit": &"u0"})).is_true()
	assert_bool(b.apply({"type": &"tamer", "side": 0, "skill": &"second_dose", "unit": &"u0"})).is_true()
	assert_bool(b.tamer_spent(0, &"pill_swiftness")).is_false()
	assert_bool(b.tamer_spent(0, w.id)).is_true()                          # Second Dose renews pills, not weapons


func test_long_reach_lets_the_next_weapon_lay_one_square_more() -> void:
	var b := _battle([[0, Vector2i(3, 3), {"pace": 1.9}], [1, Vector2i(6, 6)]], [&"long_reach", &"root_snare"])
	var w := _weapon(b)
	b.tamer_uses[0][w.id] = 2
	b.begin()
	var two := {"type": &"tamer", "side": 0, "skill": w.id, "cells": [Vector2i(1, 1), Vector2i(1, 2)]}
	assert_str(b.check(two)).contains("up to 1")
	assert_bool(b.apply({"type": &"tamer", "side": 0, "skill": &"long_reach", "unit": &"u0"})).is_true()
	assert_int(b.lay_count(0, w)).is_equal(2)
	assert_int(b.lay_count(0, H.content().tamer_skill(&"root_snare"))).is_equal(1)      # a tamer skill is no weapon
	assert_bool(b.apply(two)).is_true()
	assert_str(String(b.board.at(Vector2i(1, 2)).ground)).is_equal("snare")
	assert_int(b.lay_count(0, w)).is_equal(1)                              # spent on that weapon


func test_shared_dose_spreads_the_next_pill_to_the_own_monsters_next_to_its_taker() -> void:
	var b := _battle([[0, Vector2i(3, 3), {"pace": 1.9}], [0, Vector2i(3, 2), {"pace": 1.1}], [0, Vector2i(5, 5), {"pace": 1.0}],
		[1, Vector2i(6, 6), {"pace": 0.9}]], [&"shared_dose", &"pill_anchoring", &"pill_warding"])
	b.begin()
	assert_bool(b.apply({"type": &"tamer", "side": 0, "skill": &"shared_dose", "unit": &"u0"})).is_true()
	assert_bool(b.apply({"type": &"tamer", "side": 0, "skill": &"pill_anchoring", "unit": &"u0"})).is_true()
	assert_bool(BattleStats.is_immovable(b, H.unit(b, 0))).is_true()
	assert_bool(BattleStats.is_immovable(b, H.unit(b, 1))).is_true()       # next to the taker
	assert_bool(BattleStats.is_immovable(b, H.unit(b, 2))).is_false()      # too far
	assert_bool(b.apply({"type": &"tamer", "side": 0, "skill": &"pill_warding", "unit": &"u0"})).is_true()
	assert_bool(H.unit(b, 0).nullify).is_true()
	assert_bool(H.unit(b, 1).nullify).is_false()                           # only the next pill spreads
