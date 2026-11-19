extends GdUnitTestSuite
## The growth preview (game/growth_model.gd) follows docs/vision.md §8: where the player chooses and what is given.


## Answers every open choice with its first option.
func _answer_all(m: GrowthModel) -> void:
	while not m.pending.is_empty():
		m.choose(0)


func _to_stage(m: GrowthModel, stage: int) -> void:
	while m.stage() < stage:
		m.advance()
		_answer_all(m)


func test_a_sub_tier_asks_nothing_and_a_breakthrough_asks_for_the_arc_end_first() -> void:
	var m := GrowthModel.new()
	m.advance()
	m.advance()
	assert_int(m.step).is_equal(2)
	assert_bool(m.pending.is_empty()).is_true()
	m.advance()
	assert_int(m.step).is_equal(2)                      # the breakthrough waits for the choice at the end of the arc
	assert_int(m.pending.size()).is_equal(1)
	m.choose(1)                                         # stay unseen
	assert_int(m.stage()).is_equal(1)
	assert_int(m.shown).is_equal(0)
	assert_int(m.pending.size()).is_equal(2)            # the insight and a tamer skill; the step follows the skill


func test_five_breakthroughs_give_five_insights_and_the_slots_of_the_frame() -> void:
	var m := GrowthModel.new()
	var slots: Array[int] = [m.tamer_slots()]
	for s in range(1, 6):
		_to_stage(m, s)
		slots.append(m.tamer_slots())
	assert_array(slots).is_equal([1, 2, 3, 3, 4, 4])
	assert_int(m.insights.size()).is_equal(5)
	assert_int((m.skills["Seal"] as Array).size()).is_equal(2)      # Seal reaches level 3 and takes no third step


func test_the_internal_world_never_passes_the_tamer_and_limits_the_monsters() -> void:
	var m := GrowthModel.new()
	assert_str(m.world_block()).is_not_empty()
	for i in GrowthModel.WORLD_HOLDS[0]:
		m.catch_monster()
		m.choose(0)
	assert_str(m.catch_block()).is_not_empty()
	_to_stage(m, 1)
	m.raise_world()
	assert_int(m.world).is_equal(1)
	assert_str(m.catch_block()).is_empty()
	assert_str(m.world_block()).is_not_empty()


func test_a_monster_stops_at_the_tamers_stage_and_at_its_rarity() -> void:
	var m := GrowthModel.new()
	m.catch_monster()
	m.choose(0)                                         # Normal: ends at Core Formation
	m.advance_monster(0)
	m.advance_monster(0)
	assert_str(m.monster_block(0)).contains("tamer")
	_to_stage(m, 5)
	while m.monster_block(0) == "":
		m.advance_monster(0)
	assert_int(int(m.monsters[0]["step"])).is_equal(8)  # Core Formation High
	assert_int(int(m.monsters[0]["dev"])).is_equal(2)   # one step per new stage
	assert_str(m.monster_block(0)).contains("Normal")


func test_stat_points_are_spent_at_the_prices_of_the_monster_rules() -> void:
	var m := GrowthModel.new()
	m.catch_monster()
	m.choose(0)
	var mon: Dictionary = m.monsters[0]
	assert_int(GrowthModel.points_total(mon)).is_equal(25)
	assert_int(GrowthModel.buy_cost(mon, "hp")).is_equal(5)
	assert_int(GrowthModel.buy_cost(mon, "tpr")).is_equal(15)       # a second turn at AP 1
	for i in 4:
		assert_bool(m.buy(0, "hp")).is_true()
	assert_bool(m.buy(0, "ap")).is_true()                           # 20 + 5
	assert_bool(m.buy(0, "pace")).is_false()                        # nothing left
	m.advance_monster(0)
	assert_bool(m.buy(0, "pace", 10)).is_false()                    # +1 Pace costs 10, 5 are free
	assert_bool(m.buy(0, "reach")).is_true()


func test_a_development_step_asks_for_a_slot_and_then_for_an_option() -> void:
	var m := GrowthModel.new()
	_to_stage(m, 1)
	m.catch_monster()
	m.choose(2)                                         # Epic: two steps per new stage
	for i in 3:
		m.advance_monster(0)
	assert_int(int(m.monsters[0]["dev"])).is_equal(2)
	m.develop(0)
	m.choose(0)
	assert_int(m.pending.size()).is_equal(1)            # the option of the slot
	m.choose(0)
	assert_int(int(m.monsters[0]["dev"])).is_equal(1)
	assert_int((m.monsters[0]["slots"][0] as Array).size()).is_equal(1)


func test_the_ladder_lists_every_stage() -> void:
	var rows := GrowthModel.ladder_rows()
	assert_int(rows.size()).is_equal(6)
	assert_str(rows[0][3]).is_equal("—")
	assert_str(rows[1][3]).contains("1 of 3 insights")
