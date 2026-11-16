extends GdUnitTestSuite
## Random kits by a template (KitDraw), generated skills (SkillGen.draw_kind), the two kit switches of the
## multiplayer mode and the draft skill calculation (SkillCalc). Test switches and an authoring aid, no rules.

const H := preload("res://tests/battle/helpers.gd")


func after_test() -> void:
	BattleExperiment.reset()


func _rng(seed_value: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng


func test_a_template_names_six_slots_with_a_strike_and_a_movement() -> void:
	for tpl: Dictionary in KitDraw.TEMPLATES:
		var slots := 0
		for kind in SkillGen.KINDS:
			slots += int(tpl[kind])
		assert_int(slots).is_equal(6)
		assert_bool(tpl["strike"] >= 1 and tpl["move"] >= 1).is_true()


func test_a_kit_of_the_games_skills_follows_its_template() -> void:
	var c := H.content()
	var pools := KitDraw.pools(c)
	for tpl: Dictionary in KitDraw.TEMPLATES:
		var kit := KitDraw.kit(c, _rng(3), tpl, false)
		var count := {}
		for s in kit:
			assert_bool(ContentStatus.in_game(s)).is_true()
			assert_int(kit.count(s)).is_equal(1)
			var kind := KitDraw.kind_of(c, s)
			count[kind] = int(count.get(kind, 0)) + 1
		for kind in SkillGen.KINDS:
			assert_int(int(count.get(kind, 0))).is_equal(mini(int(tpl[kind]), (pools[kind] as Array).size()))
		assert_bool(kit[0].kind == BattleSkillDef.STRIKE and kit[0].strike_damage > 0).is_true()


func test_a_generated_skill_is_legal_and_of_the_kind_asked_for() -> void:
	var c := H.content().copy()
	var rng := _rng(11)
	for i in 200:
		var kind: String = SkillGen.KINDS[i % SkillGen.KINDS.size()]
		for ap: int in [0, -1]:
			var s := SkillGen.draw_kind(c, rng, kind, i, ap)
			c.problems.clear()
			c._validate_skill(s)
			assert_array(c.problems).is_empty()
			assert_str(KitDraw.kind_of(c, s)).is_equal(kind)
			assert_bool(s.ap_cost >= 1 and s.ap_cost <= 5).is_true()
			assert_str(s.display_name).is_not_empty()
			assert_bool(s.is_marker()).is_false()
			if kind == "zone":                      # a zone that only changes stats is never a skill of its own
				var zones := s.ops_of(BoardOp.CREATE_ZONE).map(func(op: BoardOp) -> StringName: return op.zone)
				if s.zone != null:
					zones.append(s.zone.id)
				assert_bool(zones.any(func(z: StringName) -> bool: return c.zone(z).has_tag(FieldEffect.PUSH) or c.zone(z).has_tag(FieldEffect.PULL) or c.zone(z).has_tag(FieldEffect.ERODE))).is_true()


func test_a_fresh_kit_holds_generated_skills_only() -> void:
	var c := H.content()
	var kit := KitDraw.kit(c, _rng(5), KitDraw.TEMPLATES[0], true, 2)
	assert_int(kit.size()).is_equal(6)
	var ids := {}
	for s in kit:
		assert_bool(c.skills.has(s.id)).is_false()
		ids[s.id] = true
	assert_int(ids.size()).is_equal(6)
	assert_bool(kit[0].strike_damage > 0).is_true()


func _kits(b: Battle) -> Array:
	var out: Array = []
	for id in b.roster:
		out.append((b.units[id] as BattleUnit).sheet.skills.map(func(s: BattleSkillDef) -> String: return "%s %d" % [s.display_name, s.ap_cost]))
	return out


func test_the_kit_switches_replace_every_kit_by_seed() -> void:
	var team: Array[StringName] = [&"blaze_tiger", &"moss_turtle", &"dusk_moth"]
	var r := BattleRequest.from_ids(&"3v3", team, team)
	var own := _kits(BattleSetup.build(r))
	BattleExperiment.random_kits = true
	BattleExperiment.kit_seed = 21
	var drawn := _kits(BattleSetup.build(r))
	assert_array(drawn).is_not_equal(own)
	assert_array(_kits(BattleSetup.build(r))).is_equal(drawn)          # "Fight Again" repeats the kits
	BattleExperiment.kit_seed = 22
	assert_array(_kits(BattleSetup.build(r))).is_not_equal(drawn)
	BattleExperiment.fresh_skills = true
	var b := BattleSetup.build(r)
	for id in b.roster:
		for s: BattleSkillDef in (b.units[id] as BattleUnit).sheet.skills:
			assert_bool(H.content().skills.has(s.id)).is_false()
	BattleExperiment.reset()
	assert_array(_kits(BattleSetup.build(r))).is_equal(own)


func test_a_battle_with_generated_kits_plays_to_its_end() -> void:
	var team: Array[StringName] = [&"gloom_wolf", &"forge_golem", &"ember_hawk"]
	for kit_seed: int in [1, 2, 3]:
		BattleExperiment.reset()
		BattleExperiment.fresh_skills = true
		BattleExperiment.ai_try_all = true
		BattleExperiment.kit_seed = kit_seed
		var b := BattleSetup.build(BattleRequest.from_ids(&"3v3", team, team))
		var rng := _rng(kit_seed)
		b.begin()
		var guard := 0
		while not b.over and guard < 400:
			AiBrain.play_turn(b, b.turn_owner, rng)
			guard += 1
		assert_bool(b.over).is_true()


func test_the_ai_prefers_a_skill_it_has_not_used() -> void:
	var b := H.battle([[0, Vector2i(3, 6), {"skills": [H.skill("run")]}], [1, Vector2i(3, 0), {}]])
	b.begin()
	var u := H.unit(b, 0)
	var use := {"type": &"skill", "slot": 0}
	assert_float(AiBrain.try_bonus(u, use)).is_equal(0.0)
	BattleExperiment.ai_try_all = true
	assert_float(AiBrain.try_bonus(u, use)).is_equal(AiBrain.TRY_BONUS)
	assert_float(AiBrain.try_bonus(u, {"type": &"step"})).is_equal(0.0)
	u.used_battle[0] = true
	assert_float(AiBrain.try_bonus(u, use)).is_equal(0.0)


func test_the_calculation_reads_the_parts_of_a_skill() -> void:
	var c := H.content()
	var jab := SkillCalc.features(c, c.skill(&"strike_jab"))
	assert_dict(jab).is_equal({"kind:strike": 1.0, "shape:jab": 1.0, "damage": 2.0, "damage×extra": 0.0, "push": 1.0, "push×extra": 0.0})
	var field := SkillCalc.features(c, c.skill(&"lava_field"))
	assert_dict(field).is_equal({"kind:ground": 1.0, "ground:lava": 1.0, "ground×extra": 3.0})
	var trail := SkillCalc.features(c, c.skill(&"fire_trail"))
	assert_float(trail["leaves:move"]).is_equal(1.0)
	assert_float(trail["ground×extra"]).is_equal(2.0)                  # range 3: the squares it leaves
	assert_dict(SkillCalc.features(c, c.skill(&"immovable"))).is_empty()   # passives and self buffs are not priced
	for id: StringName in BattleContent.sorted_ids(c.skills):
		var s: BattleSkillDef = c.skills[id]
		if ContentStatus.in_game(s) and KitDraw.kind_of(c, s) != "":
			assert_bool(SkillCalc.fair_ap(c, s) >= SkillCalc.MIN_AP and SkillCalc.fair_ap(c, s) <= SkillCalc.MAX_AP).is_true()
			var total := 0.0
			for row: Array in SkillCalc.lines(c, s):
				total += row[2]
			assert_float(SkillCalc.points(c, s)).is_equal_approx(total, 0.001)


# ---------- ideas of 2026-11-16: test switches and experiment content, no rules ----------

func _op(kind: String, id: StringName) -> BoardOp:
	return BoardOp.make(kind, id)


func test_a_stamina_base_cost_is_paid_on_top_of_the_squares() -> void:
	var b := H.battle([[0, Vector2i(3, 6), {"skills": [H.skill("run")], "move": 3}], [1, Vector2i(3, 0), {}]])
	b.begin()
	var u := H.unit(b, 0)
	var pool := u.stamina
	BattleExperiment.stamina_base = 1
	var far := BattleMoves.options(b, u, BattleMoves.profile_of(H.skill("run")))
	for to: Vector2i in far:
		assert_bool(u.manhattan_to(to) <= pool - 1).is_true()        # the base cost shortens the way
	assert_bool(b.apply({"type": &"skill", "slot": 0, "to": Vector2i(3, 5)})).is_true()
	assert_int(u.stamina).is_equal(pool - 2)
	u.stamina = 1
	u.used_turn.clear()
	assert_str(b.check({"type": &"skill", "slot": 0, "to": Vector2i(3, 4)})).is_not_empty()


func test_shifting_sand_takes_no_prop() -> void:
	var sand := H.board_skill([_op(BoardOp.GROUND, &"shifting_sand")], [Vector2i.ZERO], "t_sand")
	var wall := H.board_skill([_op(BoardOp.CREATE_PROP, &"earth_wall")], [Vector2i.ZERO], "t_wall")
	var b := H.battle([[0, Vector2i(3, 6), {"skills": [sand, wall], "reach": 4, "ap": 5}], [1, Vector2i(3, 0), {}]])
	b.add_prop(&"earth_wall", Vector2i(3, 4))
	b.begin()
	assert_bool(b.apply({"type": &"skill", "slot": 0, "anchor": Vector2i(3, 4)})).is_true()
	assert_object(b.board.prop_at(Vector2i(3, 4), Board.GROUND)).is_null()         # the wall standing there breaks
	b.apply({"type": &"skill", "slot": 1, "anchor": Vector2i(3, 4)})
	assert_object(b.board.prop_at(Vector2i(3, 4), Board.GROUND)).is_null()         # and none can be created on it
	var gong := b.add_prop(&"bronze_gong", Vector2i(3, 3))
	BattleDisplace.shove_prop(b, gong, Vector2i(0, 1), "test")
	BattlePayload.settle(b)
	assert_object(b.board.prop_at(Vector2i(3, 4), Board.GROUND)).is_null()         # a prop pushed onto it breaks
	assert_object(b.board.prop_at(Vector2i(3, 3), Board.GROUND)).is_null()


func test_a_solid_prop_buries_a_trap_with_the_switch() -> void:
	var wall := H.board_skill([_op(BoardOp.CREATE_PROP, &"earth_wall")], [Vector2i.ZERO], "t_wall")
	for on: bool in [false, true]:
		BattleExperiment.trap_defuse = on
		var b := H.battle([[0, Vector2i(3, 6), {"skills": [wall], "reach": 4}], [1, Vector2i(3, 0), {}]])
		b.add_prop(&"spike_trap", Vector2i(3, 4))
		b.add_prop(&"spike_trap", Vector2i(1, 4))
		var gong := b.add_prop(&"bronze_gong", Vector2i(1, 3))
		b.begin()
		b.apply({"type": &"skill", "slot": 0, "anchor": Vector2i(3, 4)})
		assert_str(String(b.board.prop_at(Vector2i(3, 4), Board.GROUND).def.id)).is_equal("earth_wall" if on else "spike_trap")
		BattleDisplace.shove_prop(b, gong, Vector2i(0, 1), "test")
		assert_str(String(b.board.prop_at(Vector2i(1, 4), Board.GROUND).def.id)).is_equal("bronze_gong" if on else "spike_trap")
		assert_int(H.events_of(b, &"trap_defused").size()).is_equal(2 if on else 0)
		assert_int(H.events_of(b, &"trap_sprung").size()).is_equal(0)


func test_an_erosion_zone_wears_props_down_at_the_round_end() -> void:
	var b := H.battle([[0, Vector2i(3, 6), {}], [1, Vector2i(3, 0), {}]])
	var wall := b.add_prop(&"earth_wall", Vector2i(3, 3))
	H.zone_on(b, Vector2i(3, 3), H.content().zone(&"erosion"))
	b.begin()
	var hp := wall.hp
	b.end_turn()
	b.end_turn()
	assert_int(b.round_number).is_equal(2)
	assert_int(wall.hp).is_equal(hp - 1)
	assert_int(H.unit(b, 0).hp).is_equal(H.unit(b, 0).max_hp)


func test_springwater_updraft_and_deep_breath_give_stamina_back() -> void:
	var b := H.battle([[0, Vector2i(3, 6), {"skills": [H.skill("deep_breath")], "move": 4, "pace": 1.9}], [1, Vector2i(3, 0), {"pace": 1.0}]])
	b.set_ground(Vector2i(3, 5), &"springwater")
	b.begin()
	var u := H.unit(b, 0)
	u.stamina = 0
	assert_bool(b.apply({"type": &"step", "to": Vector2i(3, 5)})).is_true()
	assert_int(u.stamina).is_equal(1)                                       # Springwater: +1 on entering
	assert_int(BattleStats.recovery(b, u)).is_equal(1)
	assert_bool(b.apply({"type": &"skill", "slot": 0})).is_true()
	assert_int(BattleStats.recovery(b, u)).is_equal(3)                      # Deep Breath: +2 at the round end
	H.zone_on(b, Vector2i(3, 5), H.content().zone(&"updraft"))
	assert_int(BattleStats.recovery(b, u)).is_equal(4)                      # Updraft: +1 while inside
	b.end_turn()
	b.end_turn()
	assert_int(u.stamina).is_equal(4)                                       # never above the pool


func test_the_log_says_why_a_monster_fell() -> void:
	var b := H.battle([[0, Vector2i(3, 4), {"skills": [H.skill("strike_jab")], "pace": 1.9, "ap": 5}],
		[1, Vector2i(3, 3), {"hp": 3, "pace": 1.0}]])
	b.set_ground(Vector2i(3, 2), &"lava")
	b.begin()
	var target := H.unit(b, 1)
	b.apply({"type": &"skill", "slot": 0, "dir": Vector2i(0, -1), "origin": Vector2i(3, 4)})   # 2 damage, pushed onto Lava
	b.end_turn()
	b.end_turn()                                                            # the target's turn ends on Lava
	assert_bool(target.defeated).is_true()
	var rows := BattleText.hp_history(b, target.id)
	assert_str(rows[0][2]).is_equal("Jab by %s −2" % H.unit(b, 0).display_name())
	assert_int(rows[0][3]).is_equal(1)
	assert_str(rows[rows.size() - 1][2]).is_equal("defeated")
	var line := BattleText.defeat_line(b, target.id)
	assert_str(line).contains("falls: Lava")
	assert_str(line).contains("Earlier this round: Jab by")
	assert_bool(BattleText.hp_history_lines(b, target.id).size() >= 3).is_true()
