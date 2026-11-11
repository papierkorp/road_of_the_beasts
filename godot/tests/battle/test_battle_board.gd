extends GdUnitTestSuite
## Zones, ground, height and props (gdd_battle §3.1, §4.5–§4.11, §6.2 step 4).

const H := preload("res://tests/battle/helpers.gd")


func _zone(effects: Array, id: String) -> BattleZoneDef:
	return H.zone_skill(effects, [Vector2i.ZERO], 2, id).zone


func _land(b: Battle, p: Vector2i, def: BattleZoneDef, gid: int, duration := 2) -> StringName:
	return BattleBoardOps.land_zone(b, b.board.at(p), def, gid, &"u0", duration, Vector2i.ZERO, Vector2i.ZERO)


func test_zone_landing_new_level_up_replace() -> void:
	var b := H.battle([[0, Vector2i(0, 0)], [1, Vector2i(6, 6)]])
	var slow := _zone([FieldEffect.make("slow", 1, 2)], "slow")
	var veil := _zone([FieldEffect.make("shield", 2, 3)], "veil")
	var p := Vector2i(3, 3)
	assert_str(_land(b, p, slow, 1)).is_equal("new")
	assert_int(b.board.at(p).zone.level).is_equal(1)
	b.board.at(p).zone.duration = 1
	assert_str(_land(b, p, slow, 2)).is_equal("level")
	assert_array([b.board.at(p).zone.level, b.board.at(p).zone.duration, b.board.at(p).zone.gid]).is_equal([2, 2, 2])
	_land(b, p, slow, 3)
	_land(b, p, slow, 4)
	assert_int(b.board.at(p).zone.level).is_equal(3)       # max III
	# a different definition without an opposite effect replaces at level I
	assert_str(_land(b, p, veil, 5)).is_equal("replace")
	assert_array([String(b.board.at(p).zone.def.id), b.board.at(p).zone.level]).is_equal(["veil", 1])


func test_opposite_zones_subtract_levels_and_keep_the_survivors_clock() -> void:
	var b := H.battle([[0, Vector2i(0, 0)], [1, Vector2i(6, 6)]])
	var slow_pull := _zone([FieldEffect.make("slow", 1, 2), FieldEffect.make("pull", 1)], "slow_pull")
	var push := _zone([FieldEffect.make("push", 1)], "push")
	var p := Vector2i(3, 3)
	_land(b, p, slow_pull, 1)
	assert_str(_land(b, p, push, 2)).is_equal("cancel")    # equal levels cancel: the square is empty
	assert_object(b.board.at(p).zone).is_null()
	for g in [3, 4, 5]:
		_land(b, p, slow_pull, g)                           # level III
	b.board.at(p).zone.duration = 1
	assert_str(_land(b, p, push, 6)).is_equal("weaken")
	var z := b.board.at(p).zone
	assert_array([String(z.def.id), z.level, z.duration, z.gid]).is_equal(["slow_pull", 2, 1, 5])
	# compared by effects, never by name
	var quick := _zone([FieldEffect.make("quicken", 1), FieldEffect.make("haste", 1)], "a")
	var drain := _zone([FieldEffect.make("drain_init", 1), FieldEffect.make("slow", 1)], "b")
	assert_bool(quick.opposes(drain)).is_true()
	assert_bool(slow_pull.opposes(quick)).is_true()        # slow ↔ haste
	assert_bool(push.opposes(quick)).is_false()


func test_zone_values_come_from_base_cap_and_level() -> void:
	var slow := FieldEffect.make("slow", 1, 2)
	var shield := FieldEffect.make("shield", 2, 3)
	var push := FieldEffect.make("push", 1)
	var mend := FieldEffect.make("mend", 1, 2)
	assert_array([slow.value_at(1), slow.value_at(2), slow.value_at(3)]).is_equal([1, 2, 2])
	assert_array([shield.value_at(1), shield.value_at(2), shield.value_at(3)]).is_equal([2, 3, 3])
	assert_array([push.value_at(1), push.value_at(3)]).is_equal([1, 1])
	assert_array([mend.value_at(1), mend.value_at(2), mend.value_at(3)]).is_equal([1, 2, 2])


func test_zones_affect_everyone_inside_and_never_touch_ground() -> void:
	var mire: BattleZoneDef = H.content().zone(&"mire")     # slow 1, drain_init 2 (3), drain_range 1
	var b := H.battle([[0, Vector2i(2, 2), {"move": 1, "reach": 2, "init": 5.0}], [1, Vector2i(3, 2), {"move": 3, "reach": 3, "init": 5.0}]])
	b.set_ground(Vector2i(2, 2), &"lava", 2)
	H.zone_on(b, Vector2i(2, 2), mire)
	H.zone_on(b, Vector2i(3, 2), mire, 901, 2)
	var mine := H.unit(b, 0)
	var theirs := H.unit(b, 1)
	assert_array([BattleStats.movement(b, mine), BattleStats.reach(b, mine)]).is_equal([1, 1])   # floors: min 1
	assert_float(BattleStats.initiative(b, mine)).is_equal(3.0)
	assert_array([BattleStats.movement(b, theirs), BattleStats.reach(b, theirs)]).is_equal([2, 2])
	assert_float(BattleStats.initiative(b, theirs)).is_equal(2.0)                               # level II: -3
	assert_array([String(b.board.at(Vector2i(2, 2)).ground), b.board.at(Vector2i(2, 2)).level]).is_equal(["lava", 2])


func test_different_sources_add_and_the_same_source_never_adds_twice() -> void:
	var b := H.battle([[0, Vector2i(3, 3), {"init": 4.0, "reach": 2, "move": 2}], [1, Vector2i(6, 6)]])
	var u := H.unit(b, 0)
	b.set_ground(Vector2i(3, 3), &"hearth")                 # quicken 1
	b.add_prop(&"shrine", Vector2i(3, 2))                   # quicken 1, orthogonally adjacent
	b.add_prop(&"shrine", Vector2i(2, 3))                   # a second Shrine is another source
	b.add_prop(&"shrine", Vector2i(4, 4))                   # diagonal: no aura
	assert_float(BattleStats.initiative(b, u)).is_equal(7.0)
	b.apply_effect(u, "buff:focus:u0", "quicken", 1, 2)
	b.apply_effect(u, "buff:focus:u0", "quicken", 1, 2)    # refresh only
	assert_float(BattleStats.initiative(b, u)).is_equal(8.0)
	b.add_prop(&"totem", Vector2i(4, 3))                    # extend 1
	b.board.at(Vector2i(3, 3)).height = 1                   # Mountain: +1 Reach
	assert_int(BattleStats.reach(b, u)).is_equal(4)
	b.set_ground(Vector2i(3, 3), &"umbra")
	assert_int(BattleStats.reach(b, u)).is_equal(5)
	assert_float(BattleStats.initiative(b, u)).is_equal(7.0)   # Hearth is gone, the rest stays


func test_aura_props_work_for_enemies_too_and_end_with_the_prop() -> void:
	var b := H.battle([[0, Vector2i(3, 3), {"move": 2}], [1, Vector2i(5, 4), {"move": 2}]])
	var banner := b.add_prop(&"banner", Vector2i(4, 3))     # haste 1
	b.set_ground(Vector2i(5, 4), &"plain")
	assert_int(BattleStats.movement(b, H.unit(b, 0))).is_equal(3)
	assert_int(BattleStats.movement(b, H.unit(b, 1))).is_equal(2)   # diagonal neighbour: nothing
	b.relocate(H.unit(b, 1), Vector2i(5, 3))
	assert_int(BattleStats.movement(b, H.unit(b, 1))).is_equal(3)
	b.board.remove_prop(banner)
	assert_int(BattleStats.movement(b, H.unit(b, 0))).is_equal(2)


func test_ground_same_type_levels_hazards_and_different_type_replaces() -> void:
	var b := H.battle([[0, Vector2i(0, 0)], [1, Vector2i(6, 6)]])
	var c := b.board.at(Vector2i(3, 3))
	assert_str(BattleBoardOps.lay_ground(b, c, &"lava")).is_equal("new")
	assert_str(BattleBoardOps.lay_ground(b, c, &"lava")).is_equal("level")
	assert_str(BattleBoardOps.lay_ground(b, c, &"lava")).is_equal("kept")        # max II
	assert_array([String(c.ground), c.level]).is_equal(["lava", 2])
	assert_str(BattleBoardOps.lay_ground(b, c, &"thornbed")).is_equal("replace")
	assert_array([String(c.ground), c.level]).is_equal(["thornbed", 1])
	BattleBoardOps.lay_ground(b, c, &"hearth")
	assert_str(BattleBoardOps.lay_ground(b, c, &"hearth")).is_equal("kept")      # blessed ground has no levels
	assert_array([String(c.ground), c.level]).is_equal(["hearth", 1])
	c.ground = &"voidscar"
	assert_str(BattleBoardOps.lay_ground(b, c, &"lava")).is_equal("immutable")   # nothing changes Voidscar
	assert_str(c.ground).is_equal("voidscar")


func test_field_skills_need_prop_free_squares_and_may_cover_mountains() -> void:
	var b := H.battle([[0, Vector2i(3, 5), {"init": 9.0, "reach": 3, "ap": 3, "skills": ["lava_field"]}], [1, Vector2i(6, 6)]])
	b.add_prop(&"clay_urn", Vector2i(2, 4))
	b.board.at(Vector2i(4, 3)).height = 1
	b.begin()
	assert_str(b.check({"type": &"skill", "slot": 0, "anchor": Vector2i(2, 4)})).contains("prop-free")
	assert_str(b.check({"type": &"skill", "slot": 0, "anchor": Vector2i(6, 5)})).contains("does not fit")
	assert_str(b.check({"type": &"skill", "slot": 0, "anchor": Vector2i(3, 1)})).contains("out of Reach")
	assert_bool(b.apply({"type": &"skill", "slot": 0, "anchor": Vector2i(3, 3)})).is_true()   # O4: (3,3) (4,3) (3,4) (4,4)
	for p in [Vector2i(3, 3), Vector2i(4, 3), Vector2i(3, 4), Vector2i(4, 4)]:
		assert_array([String(b.board.at(p).ground), b.board.at(p).level]).is_equal(["lava", 1])
	assert_bool(b.board.at(Vector2i(4, 3)).is_mountain()).is_true()
	b.apply({"type": &"skill", "slot": 0, "anchor": Vector2i(3, 3)})
	assert_int(b.board.at(Vector2i(3, 3)).level).is_equal(2)


func test_raise_ground_creates_a_mountain_and_resets_ground_but_not_voidscar() -> void:
	var b := H.battle([[0, Vector2i(3, 5), {"init": 9.0, "reach": 3, "ap": 3, "skills": ["raise_ground"]}], [1, Vector2i(6, 6)]])
	b.set_ground(Vector2i(3, 3), &"lava", 2)
	b.set_ground(Vector2i(3, 4), &"voidscar")
	b.begin()
	assert_bool(b.apply({"type": &"skill", "slot": 0, "anchor": Vector2i(3, 3)})).is_true()   # I2: (3,3) (3,4)
	assert_array([String(b.board.at(Vector2i(3, 3)).ground), b.board.at(Vector2i(3, 3)).height]).is_equal(["plain", 1])
	assert_array([String(b.board.at(Vector2i(3, 4)).ground), b.board.at(Vector2i(3, 4)).height]).is_equal(["voidscar", 1])
	b.set_ground(Vector2i(3, 3), &"thornbed", 1)
	b.apply({"type": &"skill", "slot": 0, "anchor": Vector2i(3, 3)})     # a second creation does nothing
	assert_str(b.board.at(Vector2i(3, 3)).ground).is_equal("thornbed")


func _strike_setup(prop: StringName, extra: Array = []) -> Battle:
	var specs: Array = [[0, Vector2i(3, 4), {"init": 9.0, "ap": 5, "kin": MonsterDef.Kin.SWARM, "skills": [H.strike()]}]]
	specs.append_array(extra)
	var b := H.battle(specs)
	b.add_prop(prop, Vector2i(3, 3))
	return b


func test_burst_props_damage_their_pattern_once_and_never_other_props() -> void:
	var b := _strike_setup(&"clay_urn", [[1, Vector2i(2, 2)], [1, Vector2i(3, 2)], [1, Vector2i(5, 3)]])
	var neighbour := b.add_prop(&"clay_urn", Vector2i(4, 3))
	b.set_ground(Vector2i(3, 3), &"lava", 2)
	b.begin()
	b.apply({"type": &"skill", "slot": 0, "dir": H.UP})
	assert_array([H.unit(b, 1).hp, H.unit(b, 2).hp, H.unit(b, 3).hp]).is_equal([4, 4, 5])   # ring of 8
	assert_int(H.unit(b, 0).hp).is_equal(4)                 # the striker stands in the ring too
	assert_int(neighbour.hp).is_equal(1)                    # no chain reaction
	assert_str(b.board.at(Vector2i(3, 3)).ground).is_equal("plain")   # the Urn leaves Plain
	var c := _strike_setup(&"bamboo_stand", [[1, Vector2i(2, 2)], [1, Vector2i(3, 2)]])
	c.begin()
	c.apply({"type": &"skill", "slot": 0, "dir": H.UP})
	assert_array([H.unit(c, 1).hp, H.unit(c, 2).hp, H.unit(c, 0).hp]).is_equal([5, 4, 4])   # cardinal only


func test_residue_props_leave_their_ground_except_on_mountain_and_voidscar() -> void:
	var expect := {&"paper_lantern": "lava", &"peach_tree": "mossbed", &"ancestor_tablet": "hallowed", &"stone_lion": "rubble"}
	for prop: StringName in expect:
		var b := _strike_setup(prop, [[1, Vector2i(6, 6)]])
		b.begin()
		b.apply({"type": &"skill", "slot": 0, "dir": H.UP})
		assert_object(b.board.at(Vector2i(3, 3)).prop).is_null()
		assert_str(b.board.at(Vector2i(3, 3)).ground).is_equal(expect[prop])
	var m := _strike_setup(&"paper_lantern", [[1, Vector2i(6, 6)]])
	m.board.at(Vector2i(3, 3)).height = 1
	m.begin()
	m.apply({"type": &"skill", "slot": 0, "dir": H.UP})
	assert_str(m.board.at(Vector2i(3, 3)).ground).is_equal("plain")     # never changes a Mountain square
	var v := _strike_setup(&"peach_tree", [[1, Vector2i(6, 6)]])
	v.set_ground(Vector2i(3, 3), &"voidscar")
	v.begin()
	v.apply({"type": &"skill", "slot": 0, "dir": H.UP})
	assert_str(v.board.at(Vector2i(3, 3)).ground).is_equal("voidscar")


func test_bronze_gong_pushes_its_neighbours_outward_with_ordinary_collisions() -> void:
	# T04 walkthrough 6
	var b := _strike_setup(&"bronze_gong", [[1, Vector2i(2, 2)], [1, Vector2i(3, 2)], [1, Vector2i(4, 3)]])
	var lion := b.add_prop(&"stone_lion", Vector2i(5, 3))
	b.begin()
	b.apply({"type": &"skill", "slot": 0, "dir": H.UP})
	assert_that(H.unit(b, 1).pos).is_equal(Vector2i(1, 1))    # diagonal neighbour: pushed diagonally away
	assert_that(H.unit(b, 2).pos).is_equal(Vector2i(3, 1))
	assert_that(H.unit(b, 3).pos).is_equal(Vector2i(4, 3))    # into the Stone Lion: collision
	assert_int(H.unit(b, 3).hp).is_equal(4)
	assert_int(lion.hp).is_equal(3)                           # heavy: no collision damage
	assert_that(H.unit(b, 0).pos).is_equal(Vector2i(3, 5))    # the striker below the Gong is pushed as well


func test_pagoda_column_spawns_beams_only_on_free_cardinal_neighbours() -> void:
	var b := _strike_setup(&"pagoda_column", [[1, Vector2i(2, 3)]])
	b.add_prop(&"clay_urn", Vector2i(4, 3))
	b.begin()
	b.apply({"type": &"skill", "slot": 0, "dir": H.UP})     # Gnaw: 4 damage, the Column has 3 HP
	assert_str(b.board.at(Vector2i(3, 2)).prop.def.id).is_equal("beam")
	assert_object(b.board.at(Vector2i(2, 3)).prop).is_null()            # a monster stands there
	assert_str(b.board.at(Vector2i(4, 3)).prop.def.id).is_equal("clay_urn")   # a prop stands there
	assert_object(b.board.at(Vector2i(3, 4)).prop).is_null()            # the striker stands there
	assert_str(b.board.at(Vector2i(3, 3)).ground).is_equal("rubble")
	assert_bool(H.content().prop(&"beam").creatable_by_skill).is_false()


func test_a_prop_at_zero_hp_blocks_until_the_removal_step() -> void:
	# Arc hits the Bamboo Stand (2 HP → 0) and the target next to it; the Scaled push then
	# collides with the still-standing prop; only afterwards the Stand is removed and bursts.
	var b := H.battle([
		[0, Vector2i(3, 3), {"init": 9.0, "ap": 3, "kin": MonsterDef.Kin.SCALED, "skills": [H.strike("arc")]}],
		[1, Vector2i(3, 2), {"hp": 9}],
	])
	b.add_prop(&"bamboo_stand", Vector2i(4, 2))
	b.begin()
	b.apply({"type": &"skill", "slot": 0, "dir": H.UP, "push_dir": H.RIGHT})
	assert_that(H.unit(b, 1).pos).is_equal(Vector2i(3, 2))
	assert_int(H.unit(b, 1).hp).is_equal(5)                 # 2 Strike + 1 collision + 1 aftermath
	assert_object(b.board.at(Vector2i(4, 2)).prop).is_null()
	var order := H.event_types(b)
	assert_bool(order.find(&"collision") < order.find(&"prop_destroyed")).is_true()


func test_relocate_contract_moves_one_light_prop_one_orthogonal_square() -> void:
	var b := H.battle([[0, Vector2i(0, 0)], [1, Vector2i(6, 6)]])
	var urn := b.add_prop(&"bamboo_stand", Vector2i(3, 3))
	var lion := b.add_prop(&"stone_lion", Vector2i(1, 1))
	urn.hp = 1
	assert_bool(BattleBoardOps.relocate_prop(b, urn, H.RIGHT)).is_true()
	assert_object(b.board.at(Vector2i(3, 3)).prop).is_null()
	assert_array([b.board.at(Vector2i(4, 3)).prop == urn, urn.hp]).is_equal([true, 1])    # keeps its HP, no aftermath
	assert_bool(BattleBoardOps.relocate_prop(b, urn, Vector2i(1, 1))).is_false()         # orthogonal only
	assert_bool(BattleBoardOps.relocate_prop(b, lion, H.RIGHT)).is_false()               # heavy props are not eligible
	b.relocate(H.unit(b, 0), Vector2i(5, 3))
	assert_bool(BattleBoardOps.relocate_prop(b, urn, H.RIGHT)).is_false()                # not onto a monster
	assert_that(urn.pos).is_equal(Vector2i(4, 3))


func test_event_passives_react_after_the_payload_once_per_event_in_queue_order() -> void:
	var scavenger := H.passive("t_scavenger", {"react_event": "prop_destroyed_in_reach", "react_heal": 1})
	var b := H.battle([
		[0, Vector2i(3, 4), {"init": 9.0, "ap": 4, "kin": MonsterDef.Kin.SWARM, "current_hp": 2, "reach": 2, "skills": [H.strike(), scavenger]}],
		[1, Vector2i(3, 1), {"init": 5.0, "current_hp": 2, "reach": 2, "skills": [scavenger]}],
		[1, Vector2i(6, 6), {"init": 4.0, "current_hp": 2, "reach": 2, "skills": [scavenger]}],
	])
	b.add_prop(&"stone_lion", Vector2i(3, 3))
	b.begin()
	b.apply({"type": &"skill", "slot": 0, "dir": H.UP})
	assert_int(H.unit(b, 0).hp).is_equal(3)                 # 1 away
	assert_int(H.unit(b, 1).hp).is_equal(3)                 # 2 away: within Reach 2
	assert_int(H.unit(b, 2).hp).is_equal(2)                 # out of Reach
	var heals := H.events_of(b, &"healed")
	assert_array(heals.map(func(e): return e["target"])).is_equal([&"u0", &"u1"])
	var order := H.event_types(b)
	assert_bool(order.find(&"prop_destroyed") < order.find(&"healed")).is_true()
