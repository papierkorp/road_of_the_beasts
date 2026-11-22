extends GdUnitTestSuite
## The Kin traits of the hub game (docs/content.md §7) in a battle: each is a passive
## without a slot that the unit sheet of a grown monster carries.

const H := preload("res://tests/battle/helpers.gd")
const K := MonsterDef.Kin


func before_test() -> void:
	H.legacy_rules()


func after_test() -> void:
	BattleExperiment.reset()


func test_aloft_spares_a_winged_monster_the_ground_it_enters() -> void:
	for with_trait in [true, false]:
		var o := {"pace": 1.9, "trait": K.WINGED} if with_trait else {"pace": 1.9}
		var b := H.battle([[0, Vector2i(3, 3), o], [1, Vector2i(6, 6)]])
		BattleBoardOps.lay_ground(b, b.board.at(Vector2i(3, 2)), &"thornbed")
		b.begin()
		assert_bool(b.apply({"type": &"step", "to": Vector2i(3, 2)})).is_true()
		assert_int(H.unit(b, 0).hp).is_equal(5 if with_trait else 4)


func test_aloft_does_not_spare_ground_at_the_end_of_the_turn() -> void:
	var b := H.battle([[0, Vector2i(3, 3), {"pace": 1.9, "trait": K.WINGED}], [1, Vector2i(6, 6)]])
	BattleBoardOps.lay_ground(b, b.board.at(Vector2i(3, 3)), &"lava")
	b.begin()
	b.end_turn()
	assert_int(H.unit(b, 0).hp).is_equal(4)


func test_armoured_takes_no_collision_damage_when_it_is_the_one_moved() -> void:
	var b := H.battle([[0, Vector2i(1, 3), {"pace": 1.9, "ap": 4, "skills": [H.strike()]}],
		[1, Vector2i(0, 3), {"trait": K.SCALED}], [1, Vector2i(1, 2), {"trait": K.SCALED}], [1, Vector2i(1, 1)]])
	b.begin()
	b.apply({"type": &"skill", "slot": 0, "dir": H.LEFT})
	assert_int(H.unit(b, 1).hp).is_equal(5)      # against the board edge: nothing
	b.apply({"type": &"skill", "slot": 0, "dir": H.UP})
	assert_int(H.unit(b, 2).hp).is_equal(5)      # moved into a monster: nothing for it
	assert_int(H.unit(b, 3).hp).is_equal(4)      # the monster it was moved into takes its damage


func test_scatter_swaps_a_swarm_monster_with_the_ally_it_steps_onto() -> void:
	var b := H.battle([[0, Vector2i(3, 3), {"pace": 1.9, "trait": K.SWARM}], [0, Vector2i(3, 2), {"pace": 1.1}],
		[1, Vector2i(4, 3), {"pace": 1.0}]])
	b.begin()
	assert_str(b.check({"type": &"step", "to": Vector2i(4, 3)})).is_not_empty()       # never with an enemy
	assert_bool(b.apply({"type": &"step", "to": Vector2i(3, 2)})).is_true()
	assert_that(H.unit(b, 0).pos).is_equal(Vector2i(3, 2))
	assert_that(H.unit(b, 1).pos).is_equal(Vector2i(3, 3))
	assert_int(b.ap).is_equal(2)
	assert_that(b.unit_at(Vector2i(3, 3), Board.GROUND)).is_equal(H.unit(b, 1))


func test_a_monster_without_scatter_cannot_step_onto_an_ally() -> void:
	var b := H.battle([[0, Vector2i(3, 3), {"pace": 1.9}], [0, Vector2i(3, 2), {"pace": 1.1}], [1, Vector2i(6, 6)]])
	b.begin()
	assert_str(b.check({"type": &"step", "to": Vector2i(3, 2)})).is_not_empty()


func test_bodiless_walks_through_monsters_and_never_ends_on_one() -> void:
	var b := H.battle([[0, Vector2i(3, 3), {"pace": 1.9, "move": 4, "trait": K.SPIRIT, "skills": ["run"]}],
		[1, Vector2i(3, 2)], [1, Vector2i(2, 3)], [1, Vector2i(4, 3)], [1, Vector2i(3, 4)]])
	b.begin()
	var opts := BattleMoves.options(b, H.unit(b, 0), BattleMoves.profile_of(H.skill("run")))
	assert_bool(opts.has(Vector2i(3, 1))).is_true()
	assert_bool(opts.has(Vector2i(3, 2))).is_false()
	var plain := H.battle([[0, Vector2i(3, 3), {"pace": 1.9, "move": 4, "skills": ["run"]}],
		[1, Vector2i(3, 2)], [1, Vector2i(2, 3)], [1, Vector2i(4, 3)], [1, Vector2i(3, 4)]])
	plain.begin()
	assert_bool(BattleMoves.options(plain, H.unit(plain, 0), BattleMoves.profile_of(H.skill("run"))).is_empty()).is_true()


func test_bulwark_covers_the_square_behind_a_stone_monster() -> void:
	for with_trait in [true, false]:
		var front := {"hp": 9, "trait": K.STONE} if with_trait else {"hp": 9}
		var b := H.battle([[0, Vector2i(3, 5), {"pace": 1.9, "skills": [H.strike("thrust")]}], [1, Vector2i(3, 4), front],
			[1, Vector2i(3, 3), {"hp": 9}]])
		b.begin()
		assert_bool(b.apply({"type": &"skill", "slot": 0, "dir": H.UP})).is_true()
		# covered: the monster behind is not struck, so the Stone monster is pushed into it
		assert_that(H.unit(b, 2).pos).is_equal(Vector2i(3, 3) if with_trait else Vector2i(3, 2))
		assert_int(H.unit(b, 2).hp).is_equal(8 if with_trait else 9)


func test_rooted_growth_makes_the_ground_of_a_flora_monster_last_a_round_longer() -> void:
	var b := H.battle([[0, Vector2i(3, 3), {"trait": K.FLORA}], [1, Vector2i(6, 6)]])
	b.begin()
	assert_int(BattlePayload._ground_bonus(b, {"owner": H.unit(b, 0).id})).is_equal(1)
	assert_int(BattlePayload._ground_bonus(b, {"owner": H.unit(b, 1).id})).is_equal(0)
	var cell := b.board.at(Vector2i(1, 1))
	BattleBoardOps.lay_ground(b, cell, &"thornbed", "", 1)
	assert_int(cell.ground_until).is_equal(b.round_number + BattleExperiment.ground_rounds)


func test_unmoored_is_not_moved_by_a_zone() -> void:
	var push := H.content().zone(&"push_zone")
	for with_trait in [true, false]:
		var o := {"pace": 1.9, "trait": K.VOID} if with_trait else {"pace": 1.9}
		var b := H.battle([[0, Vector2i(3, 3), o], [1, Vector2i(6, 6)]])
		H.zone_on(b, Vector2i(3, 3), push, 1, 1, H.RIGHT)
		b.begin()
		b.end_turn()
		assert_that(H.unit(b, 0).pos).is_equal(Vector2i(3, 3) if with_trait else Vector2i(4, 3))


func test_follow_up_lets_a_beast_step_for_free_onto_the_square_its_strike_cleared() -> void:
	var b := H.battle([[0, Vector2i(3, 3), {"pace": 1.9, "ap": 3, "trait": K.BEAST, "skills": [H.strike()]}], [1, Vector2i(3, 2)]])
	b.begin()
	b.apply({"type": &"skill", "slot": 0, "dir": H.UP})
	assert_int(b.ap).is_equal(1)
	assert_int(b.step_cost(H.unit(b, 0), Vector2i(3, 2))).is_equal(0)
	assert_int(b.step_cost(H.unit(b, 0), Vector2i(2, 3))).is_equal(1)
	assert_bool(b.apply({"type": &"step", "to": Vector2i(3, 2)})).is_true()
	assert_int(b.ap).is_equal(1)
	assert_that(H.unit(b, 0).pos).is_equal(Vector2i(3, 2))
	assert_int(b.step_cost(H.unit(b, 0), Vector2i(3, 3))).is_equal(1)      # used up


func test_follow_up_lapses_with_any_other_action() -> void:
	var b := H.battle([[0, Vector2i(3, 3), {"pace": 1.9, "ap": 4, "trait": K.BEAST, "skills": [H.strike()]}], [1, Vector2i(3, 2)]])
	b.begin()
	b.apply({"type": &"skill", "slot": 0, "dir": H.UP})
	b.apply({"type": &"step", "to": Vector2i(2, 3)})
	assert_int(b.ap).is_equal(1)
	assert_int(b.step_cost(H.unit(b, 0), Vector2i(3, 3))).is_equal(1)


func test_only_a_grown_monster_carries_the_trait_of_its_kin() -> void:
	var turtle := GameData.monster(&"moss_turtle")
	var grown := UnitSheets.from_instance(MonsterInstance.hatched(turtle))
	assert_int(grown.innate.size()).is_equal(1)
	assert_int(BattleStats.passive_reduction(BattleUnit.new(&"x", grown), "collision_self")).is_equal(2)
	assert_int(UnitSheets.from_instance(MonsterInstance.of_species(turtle)).innate.size()).is_equal(0)
	var later := MonsterInstance.hatched(GameData.monster(&"grove_wisp"), 3)
	assert_int(UnitSheets.from_instance(later).innate.size()).is_equal(1)       # the trait and nothing else: a Kin has no further passives
