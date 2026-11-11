extends GdUnitTestSuite
## Content definitions and extensibility: existing mechanics combine through new data, without
## touching the resolution code (prompt acceptance criterion; gdd_battle §4.7, §4.10).

const H := preload("res://tests/battle/helpers.gd")


func test_the_shipped_content_loads_without_problems() -> void:
	var c := BattleContent.reload_shared()
	assert_array(c.problems).is_empty()
	assert_array(c.grounds.keys()).contains_exactly_in_any_order([&"plain", &"rubble", &"voidscar", &"lava", &"thornbed",
		&"blight", &"hearth", &"mossbed", &"umbra", &"hallowed"])
	assert_int(c.props.size()).is_equal(17)      # the catalogue of gdd_battle §4.10
	assert_int(c.tamer.size()).is_equal(7)       # the confirmed tamer skills of gdd_battle §5.2
	assert_int(c.fingerprint().length()).is_equal(64)
	assert_str(c.fingerprint()).is_equal(BattleContent.reload_shared().fingerprint())


func test_the_catalogue_matches_the_gdd_table() -> void:
	var c := H.content()
	# [hp, layer, ground left]
	var expect := {
		&"stone_lion": [3, "ground", &"rubble"], &"clay_urn": [1, "ground", &"plain"], &"bamboo_stand": [2, "ground", &"plain"],
		&"paper_lantern": [1, "ground", &"lava"], &"peach_tree": [2, "ground", &"mossbed"], &"ancestor_tablet": [2, "ground", &"hallowed"],
		&"bronze_gong": [2, "ground", &"plain"], &"pagoda_column": [3, "ground", &"rubble"], &"beam": [1, "ground", &"plain"],
		&"wind_chime": [1, "air", &""], &"thunder_cloud": [1, "air", &""], &"gale_banner": [2, "air", &""],
		&"pagoda_bridge": [3, "both", &"rubble"], &"shrine": [2, "ground", &"rubble"], &"totem": [2, "ground", &"rubble"],
		&"banner": [2, "ground", &"rubble"], &"wardstone": [2, "ground", &"rubble"],
	}
	for id: StringName in expect:
		var p := c.prop(id)
		assert_array([p.hp, p.layer, p.ground_left]).is_equal(expect[id])
	assert_bool(c.prop(&"stone_lion").heavy).is_true()
	# the four aura props are one template with one effect each
	assert_array([c.prop(&"shrine").aura[0].tag, c.prop(&"totem").aura[0].tag, c.prop(&"banner").aura[0].tag,
		c.prop(&"wardstone").aura[0].tag]).is_equal(["quicken", "extend", "haste", "shield"])
	# damage law values of the hazard grounds
	assert_array([c.ground(&"lava").max_level, c.ground(&"thornbed").max_level, c.ground(&"blight").max_level]).is_equal([2, 2, 2])
	assert_bool(c.ground(&"voidscar").immutable).is_true()
	assert_int(c.ground(&"rubble").move_cost).is_equal(2)


func test_every_test_kit_is_a_legal_four_slot_kit_with_the_reference_sheet() -> void:
	var c := H.content()
	assert_int(c.kits.size()).is_equal(9)
	for id in GameData.monster_ids():
		var kit := c.kit(id)
		assert_object(kit).is_not_null()
		assert_int(kit.skills.size()).is_equal(4)
		var sheet := UnitSheets.from_instance(MonsterInstance.of_species(GameData.monster(id)))
		assert_array(sheet.problems()).is_empty()
		assert_bool(sheet.active_skills().size() >= 1).is_true()
		assert_str(kit.skills[kit.surge_slot].kind).is_equal("surge")
		# gdd_monsters §4.1: every Core High reference individual spends 16 points above base
		var tpr_cost: int = [0, 3, 8, 15][sheet.tpr]
		var ap_cost: int = {2: 6, 3: 9, 4: 14, 5: 21}[sheet.ap]
		var points: int = sheet.hp + int(sheet.initiative) + sheet.movement + (sheet.reach - 1) * 3 + tpr_cost + ap_cost
		assert_int(points).is_equal(31)
	# Swarm Surges are limited to 2 cells (gdd_monsters §3.1)
	assert_int(c.skill(&"bramble_tide").footprint.size()).is_equal(2)
	# basic Surges keep the 1-AP target; slotted movement costs 2 AP
	for id: StringName in c.skills:
		var s := c.skill(id)
		if s.kind == "surge":
			assert_int(s.cost()).is_equal(1)
		if s.kind == "move":
			assert_int(s.cost()).is_equal(2)


func test_a_new_ground_type_is_only_a_new_definition() -> void:
	# A hypothetical ground made of existing behaviour elements: costly to enter, hurts on
	# entry, quickens while standing. No rule module knows its id.
	var c := H.content().copy()
	var mud := GroundDef.new()
	mud.id = &"test_mud"
	mud.display_name = "Test Mud"
	mud.group = "hazard"
	mud.move_cost = 3
	mud.max_level = 2
	mud.triggers = [GroundTrigger.make("on_enter", "damage", 0), GroundTrigger.make("end_of_turn", "heal", 1)] as Array[GroundTrigger]
	mud.effects = [FieldEffect.make("quicken", 2)] as Array[FieldEffect]
	c.add_ground(mud)
	var field := H.board_skill([BoardOp.make("ground", &"test_mud", false)])
	var b := H.battle([[0, Vector2i(3, 3), {"init": 5.0, "move": 3, "ap": 5, "reach": 3, "skills": ["run", field]}], [1, Vector2i(6, 6)]], 7, c)
	b.set_ground(Vector2i(3, 2), &"test_mud", 2)
	b.begin()
	var opts := BattleMoves.options(b, H.unit(b, 0), BattleMoves.profile_of(H.skill("run")))
	assert_int(opts[Vector2i(3, 2)]["cost"]).is_equal(3)                    # movement cost
	assert_int(opts[Vector2i(3, 2)]["harm"]).is_equal(2)                    # previewed entry harm
	assert_bool(b.apply({"type": &"skill", "slot": 0, "to": Vector2i(3, 2)})).is_true()
	assert_int(H.unit(b, 0).hp).is_equal(3)                                 # level II on entry
	assert_float(BattleStats.initiative(b, H.unit(b, 0))).is_equal(7.0)     # while-standing effect
	assert_bool(b.apply({"type": &"skill", "slot": 1, "anchor": Vector2i(4, 2)})).is_true()   # laid by a skill
	assert_str(b.board.at(Vector2i(4, 2)).ground).is_equal("test_mud")
	assert_bool(b.apply({"type": &"skill", "slot": 1, "anchor": Vector2i(4, 2)})).is_true()   # hazards level up
	assert_int(b.board.at(Vector2i(4, 2)).level).is_equal(2)
	b.end_turn()
	assert_int(H.unit(b, 0).hp).is_equal(4)                                 # its end-of-turn trigger
	assert_object(BattleContent.shared().ground(&"test_mud")).is_null()     # the shared registry is untouched


func test_a_new_prop_and_a_new_skill_are_only_new_definitions() -> void:
	var c := H.content().copy()
	var keg := PropDef.new()
	keg.id = &"test_keg"
	keg.display_name = "Test Keg"
	keg.hp = 2
	keg.aftermath = [PropAftermath.make("damage", "cardinal4", 1), PropAftermath.make("push", "cardinal4", 1)] as Array[PropAftermath]
	keg.aura = [FieldEffect.make("slow", 1)] as Array[FieldEffect]
	keg.ground_left = &"thornbed"
	c.add_prop(keg)
	# a Surge that combines existing parts in a new way: pull, a prop created at detonation
	var trap := H.surge([Vector2i.ZERO, Vector2i(1, 0)], 2)
	trap.surge_displacement = "pull"
	trap.board_ops = [BoardOp.make("create_prop", &"test_keg")] as Array[BoardOp]
	var b := H.battle([
		[0, Vector2i(3, 5), {"init": 9.0, "reach": 3, "ap": 4, "kin": MonsterDef.Kin.SWARM, "skills": [trap, H.strike()]}],
		[1, Vector2i(5, 3), {"hp": 9, "move": 3}],
	], 7, c)
	b.begin()
	b.apply({"type": &"skill", "slot": 0, "anchor": Vector2i(4, 3)})        # (4,3) (5,3), anchor (4,3)
	H.until_turn_of(b, &"u0")
	var target := H.unit(b, 1)
	assert_int(target.hp).is_equal(7)
	assert_that(target.pos).is_equal(Vector2i(4, 3))                        # pulled 1 toward the anchor
	assert_str(b.board.at(Vector2i(5, 3)).prop.def.id).is_equal("test_keg")  # placed on the free square only
	assert_object(b.board.at(Vector2i(4, 3)).prop).is_null()
	assert_int(BattleStats.movement(b, target)).is_equal(2)                 # its aura
	b.apply({"type": &"step", "to": Vector2i(4, 5)})
	b.apply({"type": &"step", "to": Vector2i(5, 5)})
	H.until_turn_of(b, &"u0")
	b.apply({"type": &"step", "to": Vector2i(5, 4)})
	b.apply({"type": &"skill", "slot": 1, "dir": H.UP})                     # Gnaw: 4 damage to the keg
	assert_object(b.board.at(Vector2i(5, 3)).prop).is_null()
	assert_int(target.hp).is_equal(6)                                       # its aftermath damage
	assert_that(target.pos).is_equal(Vector2i(3, 3))                        # and its push
	assert_that(H.unit(b, 0).pos).is_equal(Vector2i(5, 5))
	assert_str(b.board.at(Vector2i(5, 3)).ground).is_equal("thornbed")


func test_validation_reports_incomplete_definitions() -> void:
	var c := H.content().copy()
	var bad := BattleSkillDef.new()
	bad.id = &"bad"
	bad.kind = "zone"
	bad.ap_cost = 0
	c.skills[&"bad"] = bad
	var prop := PropDef.new()
	prop.id = &"bad_prop"
	prop.hp = 0
	prop.ground_left = &"nowhere"
	c.props[&"bad_prop"] = prop
	c.validate()
	var text := "\n".join(PackedStringArray(c.problems))
	assert_str(text).contains("skill 'bad' has no display_name")
	assert_str(text).contains("at least 1 AP")
	assert_str(text).contains("without a zone")
	assert_str(text).contains("needs an explicit footprint")
	assert_str(text).contains("every prop needs at least 1 HP")
	assert_str(text).contains("unknown ground 'nowhere'")
