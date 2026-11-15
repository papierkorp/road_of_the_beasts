extends GdUnitTestSuite
## One shape field per skill (gdd_skills §2, §8.1; user decisions 2026-11-15): a base shape around the
## user, or a free shape of N squares at an anchor that the player arranges before the battle.

const H := preload("res://tests/battle/helpers.gd")


func before_test() -> void:
	BattleExperiment.reset()


func after_test() -> void:
	BattleExperiment.reset()


func _ground_at(b: Battle, cells: Array) -> Array:
	var out := []
	for c: Vector2i in cells:
		out.append(String(b.board.at(c).ground))
	return out


func test_a_free_arrangement_needs_its_squares_the_anchor_and_a_connection() -> void:
	var line: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)]
	assert_str(BattleShapes.arrangement_error(line, 3)).is_equal("")
	assert_str(BattleShapes.arrangement_error(line, 4)).contains("4 squares")
	assert_str(BattleShapes.arrangement_error([Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)], 3)).contains("anchor")
	assert_str(BattleShapes.arrangement_error([Vector2i(0, 0), Vector2i(1, 1), Vector2i(2, 2)], 3)).contains("connected")   # corners do not connect
	assert_str(BattleShapes.arrangement_error([Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 0)], 3)).contains("twice")
	assert_str(BattleShapes.arrangement_text([Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1)])).is_equal("■■/■·")


func test_a_sheet_plays_its_own_arrangement_and_the_species_keeps_the_default() -> void:
	var thornbed := H.skill("thornbed")                                       # 3 squares, default: an angle
	var default_cells := thornbed.footprint.duplicate()
	var b := H.battle([[0, Vector2i(3, 5), {"pace": 1.9, "reach": 3, "ap": 3, "skills": [thornbed]}], [1, Vector2i(6, 0)]])
	var me := H.unit(b, 0)
	UnitSheets.arrange(me.sheet, {0: [Vector2i(0, 0), Vector2i(-1, 0), Vector2i(1, 0)]})          # a line through the anchor
	assert_array(thornbed.footprint).is_equal(default_cells)                   # the shared record is untouched
	assert_bool(me.sheet.skills[0] != thornbed).is_true()
	b.begin()
	assert_bool(b.apply({"type": &"skill", "slot": 0, "anchor": Vector2i(3, 2)})).is_true()
	assert_array(_ground_at(b, [Vector2i(2, 2), Vector2i(3, 2), Vector2i(4, 2), Vector2i(3, 3)])).is_equal(["thornbed", "thornbed", "thornbed", "plain"])
	UnitSheets.arrange(me.sheet, {0: [Vector2i(0, 0), Vector2i(2, 0), Vector2i(1, 1)]})           # not connected: ignored
	assert_array(me.sheet.skills[0].footprint).is_equal([Vector2i(0, 0), Vector2i(-1, 0), Vector2i(1, 0)])
	assert_str(BattleText.rows_to_text(BattleText.skill_rows(b.content, me.sheet.skills[0]))).contains("■■■")   # the card shows it


func test_an_arranged_shape_still_turns_in_quarter_turns() -> void:
	var b := H.battle([[0, Vector2i(3, 5), {"pace": 1.9, "reach": 3, "ap": 3, "skills": ["thornbed"]}], [1, Vector2i(6, 0)]])
	UnitSheets.arrange(H.unit(b, 0).sheet, {0: [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)]})
	b.begin()
	assert_bool(b.apply({"type": &"skill", "slot": 0, "anchor": Vector2i(3, 2), "rot": 1})).is_true()
	assert_array(_ground_at(b, [Vector2i(3, 2), Vector2i(3, 3), Vector2i(3, 4), Vector2i(4, 2)])).is_equal(["thornbed", "thornbed", "thornbed", "plain"])


func test_a_battle_request_carries_the_arrangements_of_both_teams() -> void:
	var r := BattleRequest.default()                                           # blaze_tiger plays Lava Field (2×2 block)
	var slot := -1
	var tiger := GameData.monster(&"blaze_tiger")
	for i in tiger.skills.size():
		if tiger.skills[i].id == &"lava_field":
			slot = i
	assert_bool(slot >= 0).is_true()
	var row: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)]
	r.player_shapes = {0: {slot: row}}
	var b := BattleSetup.build(r)
	var mine: BattleUnit = b.units[&"p0_blaze_tiger"]
	assert_array(mine.sheet.skills[slot].footprint).is_equal(row)
	assert_array(tiger.skills[slot].footprint).is_not_equal(row)
	var editor_store := {}
	assert_str(ShapeEditor.store_arrangement(editor_store, &"blaze_tiger", slot, tiger.skills[slot], row)).is_equal("")
	assert_array(ShapeEditor.arrangement(editor_store, &"blaze_tiger", slot, tiger.skills[slot])).is_equal(row)
	var back: Array[Vector2i] = []
	back.assign(tiger.skills[slot].footprint)
	ShapeEditor.store_arrangement(editor_store, &"blaze_tiger", slot, tiger.skills[slot], back)   # the default clears the entry
	assert_bool((editor_store[&"blaze_tiger"] as Dictionary).has(slot)).is_false()
	assert_bool(ShapeEditor.free_slots(tiger).has(slot)).is_true()


func test_a_base_shape_around_the_user_creates_what_the_skill_names() -> void:
	# Cinder Dive: a line of 3 from the user (a Jab with two extensions), in any of the 8 directions
	var b := H.battle([[0, Vector2i(1, 5), {"pace": 1.9, "ap": 4, "skills": ["cinder_dive"]}], [1, Vector2i(6, 0)]])
	b.begin()
	var dive := H.skill("cinder_dive")
	assert_array([dive.is_free_shape(), dive.shape_squares(), dive.shape_label()]).is_equal([false, 3, "Jab +2"])
	assert_str(b.check({"type": &"skill", "slot": 0, "anchor": Vector2i(3, 5)})).contains("start next to")      # not a neighbour
	assert_str(b.check({"type": &"skill", "slot": 0, "anchor": Vector2i(0, 5)})).contains("does not fit")       # runs off the board
	assert_bool(b.apply({"type": &"skill", "slot": 0, "anchor": Vector2i(2, 4)})).is_true()                    # diagonally up-right
	assert_array(_ground_at(b, [Vector2i(2, 4), Vector2i(3, 3), Vector2i(4, 2), Vector2i(1, 5)])).is_equal(["lava", "lava", "lava", "plain"])
	assert_int(BattleCasting.anchors(b, H.unit(b, 0), dive, Vector2i.ZERO).size()).is_equal(3)                 # up, up-right, right fit on the board


func test_a_shape_around_the_whole_user_needs_no_aim() -> void:
	var ring := H.board_skill([BoardOp.make("ground", &"thornbed", false)], [], "t_ring")
	ring.shape = "whirl"
	var b := H.battle([[0, Vector2i(3, 3), {"pace": 1.9, "ap": 4, "skills": [ring]}], [1, Vector2i(6, 0)]])
	b.begin()
	assert_bool(ring.needs_anchor()).is_false()
	assert_array(BattleCasting.anchors(b, H.unit(b, 0), ring, Vector2i.ZERO)).is_equal([Vector2i(3, 3)])
	assert_bool(b.apply({"type": &"skill", "slot": 0, "anchor": Vector2i(3, 3)})).is_true()
	assert_array(_ground_at(b, [Vector2i(3, 2), Vector2i(4, 3), Vector2i(3, 4), Vector2i(2, 3), Vector2i(3, 3), Vector2i(4, 4)])).is_equal(
		["thornbed", "thornbed", "thornbed", "thornbed", "plain", "plain"])
	ring.shape_extension = 1                                                                  # Whirl +1: two squares on every arm
	assert_int(BattleCasting.cells(H.unit(b, 0), ring, Vector2i(3, 3)).size()).is_equal(8)


# --- one sheet for ground, zones and props (BoardSheet) ---

func test_ground_zones_and_props_read_as_the_same_sheet() -> void:
	var c := H.content()
	var lava := BoardSheet.ground(c.ground(&"lava"))
	assert_array([lava["kind"], lava["lies"], lava["move_cost"], lava["levels"]]).is_equal(["ground", "ground layer", 1, 2])
	assert_str(BoardSheet.lines_text(c, lava)).is_equal("at the end of its turn: damage = level")
	assert_str(BoardSheet.lines_text(c, BoardSheet.ground(c.ground(&"snare")))).is_equal("on leaving: 2 damage")
	assert_str(BoardSheet.lines_text(c, BoardSheet.ground(c.ground(&"mossbed")))).is_equal("on entering: heals 1")
	var bog := BoardSheet.zone(c.zone(&"bog"))
	assert_str(BoardSheet.lines_text(c, bog)).is_equal("while inside: Movement −1\nat the end of its turn: pull 1")
	assert_str(BoardSheet.lines_text(c, BoardSheet.zone(c.zone(&"mire")))).contains("while inside: Pace −0.1")
	var urn := BoardSheet.prop(c.prop(&"clay_urn"))
	assert_array([urn["kind"], urn["lies"], urn["hp"]]).is_equal(["prop", "occupant, solid", 1])
	assert_str(BoardSheet.lines_text(c, urn)).is_equal("when destroyed: 1 damage on Storm (8 sq)")
	assert_str(BoardSheet.lines_text(c, BoardSheet.prop(c.prop(&"bamboo_stand")))).is_equal("when destroyed: 1 damage on Whirl (4 sq)")
	assert_str(BoardSheet.lines_text(c, BoardSheet.prop(c.prop(&"spike_trap")))).contains("on entering: ")
	assert_str(BoardSheet.lines_text(c, BoardSheet.prop(c.prop(&"peach_tree")))).is_equal("when destroyed: creates Mossbed")
	assert_str(BoardSheet.prop(c.prop(&"spike_trap"))["ends"]).contains("used up when entered")


func test_the_roles_of_the_three_kinds_are_checked_for_the_game() -> void:
	var c := H.content()
	for id in c.grounds:
		if ContentStatus.in_game(c.grounds[id]):
			assert_array(BoardSheet.role_problems(BoardSheet.ground(c.grounds[id]))).is_empty()
	for id in c.zones:
		if ContentStatus.in_game(c.zones[id]):
			assert_array(BoardSheet.role_problems(BoardSheet.zone(c.zones[id]))).is_empty()
	for id in c.props:
		if ContentStatus.in_game(c.props[id]):
			assert_array(BoardSheet.role_problems(BoardSheet.prop(c.props[id]))).is_empty()
	# ground changes no stat, a zone deals no damage, ground and zones act on their own square only
	var hearth := BoardSheet.ground(c.ground(&"hearth"))                        # archived stat ground
	assert_str(", ".join(BoardSheet.role_problems(hearth))).contains("no moment of a ground")
	var burning := BattleZoneDef.new()
	burning.id = &"t_burning"
	burning.effects = [FieldEffect.make("mend", 1)] as Array[FieldEffect]
	assert_str(", ".join(BoardSheet.role_problems(BoardSheet.zone(burning)))).contains("not an effect of a zone")
	assert_array(Moment.MOMENTS["ground"]).is_equal([Moment.ENTER, Moment.LEAVE, Moment.TURN_END, Moment.ROUND_END])   # no turn or round start


func test_a_prop_acts_on_the_round_shapes_of_the_shared_vocabulary() -> void:
	var a := PropAftermath.make("damage", "whirl", 1)
	assert_array(a.offsets()).contains_exactly_in_any_order([Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)])
	a.shape = "cross"
	assert_array(a.offsets()).contains_exactly_in_any_order([Vector2i(1, -1), Vector2i(1, 1), Vector2i(-1, 1), Vector2i(-1, -1)])
	a.shape = "storm"
	a.extension = 1
	assert_int(a.offsets().size()).is_equal(16)
	a.shape = "block"
	assert_int(a.offsets().size()).is_equal(25)                                                # the 5×5 of the Moss Rune's bigger sister
	a.extension = 0
	assert_bool(a.offsets().has(Vector2i.ZERO)).is_true()                                      # a block includes its own square
	a.shape = "self"
	assert_array(a.offsets()).is_equal([Vector2i.ZERO])
