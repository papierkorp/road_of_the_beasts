extends GdUnitTestSuite
## The ingame prototype (docs/battle_ingame.md §1): monsters drawn for the points of each side.


func after_test() -> void:
	BattleExperiment.reset()


func _cost(u: BattleUnit) -> int:
	var s := u.sheet
	return MonsterDef.points_of(s.hp, s.pace, s.movement, s.reach, s.tpr, s.ap)


func test_each_side_is_drawn_for_its_own_points() -> void:
	for draw: int in [1, 2, 3]:
		var rng := RandomNumberGenerator.new()
		rng.seed = draw
		var r := IngamePrototype.request(&"3v3", [30, 95], rng)
		assert_that(r.battle_kind).is_equal(BattleRequest.INGAME)
		var b := BattleSetup.build(r)
		assert_int(b.living(0).size()).is_equal(3)
		assert_int(b.living(1).size()).is_equal(3)
		for u in b.living():
			var points := 30 if u.side == 0 else 95
			assert_int(_cost(u)).is_between(points - 4, points)
			assert_array(u.sheet.problems()).is_empty()
			assert_bool(u.sheet.active_skills().size() >= 1).is_true()


func test_the_draw_reaches_the_top_of_the_ingame_ranges_and_the_multiplayer_draw_does_not() -> void:
	var ap := 0
	var tpr := 0
	for draw in 60:
		var rng := RandomNumberGenerator.new()
		rng.seed = draw
		var s := MonsterDraw.stats(rng, 110, MonsterDraw.INGAME_TOP)
		ap = maxi(ap, int(s["ap"]))
		tpr = maxi(tpr, int(s["tpr"]))
		var plain := MonsterDraw.stats(rng, 110)
		assert_int(int(plain["ap"])).is_less_equal(4)
		assert_int(int(plain["tpr"])).is_less_equal(2)
	assert_int(ap).is_equal(5)
	assert_int(tpr).is_equal(3)


func test_a_multiplayer_request_draws_every_monster_for_the_multiplayer_points() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	var r := IngamePrototype.request(&"3v3", [25, 110], rng)
	r.battle_kind = BattleRequest.MULTIPLAYER            # side points belong to the ingame battle only
	var b := BattleSetup.build(r)
	for u in b.living():
		assert_int(_cost(u)).is_between(MonsterDef.MULTIPLAYER_POINTS - 4, MonsterDef.MULTIPLAYER_POINTS)
		assert_int(u.sheet.ap).is_less_equal(4)
		assert_int(u.sheet.tpr).is_less_equal(2)


func _same(a: BattleUnit, c: BattleUnit) -> bool:
	var x := a.sheet
	var y := c.sheet
	if [x.hp, x.pace, x.movement, x.reach, x.tpr, x.ap, x.kin] != [y.hp, y.pace, y.movement, y.reach, y.tpr, y.ap, y.kin]:
		return false
	if x.skills.size() != y.skills.size():
		return false
	for i in x.skills.size():
		if x.skills[i] != y.skills[i]:
			return false
	return true


func test_a_mirrored_draw_gives_both_sides_the_same_monsters_and_kits() -> void:
	for draw: int in [1, 2, 3]:
		var r := BattleRequest.from_ids(&"3v3", [&"blaze_tiger", &"ember_hawk", &"dusk_moth"], [&"forge_golem", &"gloom_wolf", &"grove_wisp"])
		r.draw_seed = draw
		r.mirror_draw = true
		var b := BattleSetup.build(r)
		var mine := b.living(0)
		var theirs := b.living(1)
		for i in 3:
			assert_bool(_same(mine[i], theirs[i])).is_true()
		r.mirror_draw = false
		var apart := BattleSetup.build(r)
		var equal := 0
		for i in 3:
			if _same(apart.living(0)[i], apart.living(1)[i]):
				equal += 1
		assert_int(equal).is_less(3)


func test_the_points_name_their_stage() -> void:
	assert_str(IngamePrototype.stage_name(25)).is_equal("Qi Gathering Lower")
	assert_str(IngamePrototype.stage_name(60)).is_equal("Core Formation Middle")
	assert_str(IngamePrototype.stage_name(110)).is_equal("Sovereign High")


func test_drawn_monsters_are_named_by_letters_and_a_mirrored_pair_shares_its_name() -> void:
	var r := BattleRequest.from_ids(&"3v3", [&"blaze_tiger", &"ember_hawk", &"dusk_moth"], [&"forge_golem", &"gloom_wolf", &"grove_wisp"])
	r.draw_seed = 4
	var apart := BattleSetup.build(r)
	var names: Array = apart.living().map(func(u: BattleUnit): return u.sheet.display_name)
	assert_array(names).is_equal(["Random Alpha", "Random Beta", "Random Gamma", "Random Delta", "Random Epsilon", "Random Zeta"])
	r.mirror_draw = true
	var same := BattleSetup.build(r)
	names = same.living().map(func(u: BattleUnit): return u.sheet.display_name)
	assert_array(names).is_equal(["Random Alpha", "Random Beta", "Random Gamma", "Random Alpha", "Random Beta", "Random Gamma"])


func test_a_generated_strike_always_does_something() -> void:
	var c := BattleContent.shared()
	for draw in 400:
		var rng := RandomNumberGenerator.new()
		rng.seed = draw
		var s := SkillGen.draw_kind(c, rng, "strike", draw)
		assert_bool(s.strike_push or s.hits_props() or not s.board_ops.is_empty()).is_true()
