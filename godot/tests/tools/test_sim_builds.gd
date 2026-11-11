extends GdUnitTestSuite
## The test builds of the simulation tools (res://tools/data): every sheet is legal, a price
## record only fights with a definition that is exactly what it prices, and a build battle is
## repeatable. These are checks of the tools, not gameplay or balance results.

const Pricing := preload("res://tools/lib/skill_pricing.gd")
const Builds := preload("res://tools/lib/sim_builds.gd")
const Runner := preload("res://tools/lib/sim_runner.gd")
const Bots := preload("res://tools/lib/sim_bots.gd")

## Price references of gdd_skills §5 without a definition (no approved geometry or contract).
const REFERENCE_ONLY: Array[String] = ["eruption_3_cells", "flood_3_cells", "hallowed_cast", "immediate_hazard_ground",
	"mountain_creation_reset", "residue_free_surge", "rift_collapse_2_cells", "rift_collapse_3_cells"]


func _named(skill: String) -> PriceRecord:
	var rec := Pricing.find_record(skill)
	assert_object(rec).override_failure_message("no price record '%s'" % skill).is_not_null()
	return rec


## A private copy of a stored record, so a test can change it.
func _copy(skill: String) -> PriceRecord:
	return _named(skill).duplicate(true)


func _rejected(rec: PriceRecord, why: String) -> void:
	assert_str(Builds.engine_check(rec)["error"]).override_failure_message("accepted although it differs: %s" % why).is_not_empty()


func test_every_test_build_is_legal() -> void:
	assert_int(Builds.list_builds().size()).is_greater(0)
	for build in Builds.list_builds():
		var r := Builds.build(build)
		assert_bool(r["ok"]).override_failure_message("%s: %s" % [build, r["errors"]]).is_true()
		assert_object(r["sheet"]).is_not_null()
		assert_array(r["sheet"].problems()).is_empty()
		# every slot of the shipped builds fights: no slot was dropped
		assert_int((r["sheet"] as UnitSheet).skills.size()).override_failure_message(build).is_equal(Builds.load_build(build).slots.size())


func test_stat_and_skill_spend_are_reported() -> void:
	var r := Builds.build("test_golem_shield")
	assert_str(r["stat_points"]).is_equal("31/31")
	assert_float(r["skill_points"]).is_equal_approx(52.0, 0.0001)        # Jab 14 + Shield 26 + Run 12
	assert_array(r["levels"]).is_equal([1, 1, 2])
	assert_bool(Builds.fully_simulated(r)).is_true()
	# an effect without a decided cap is covered at level I only, so a comparison refuses the build
	assert_bool(Builds.fully_simulated(Builds.build("test_golem_quicken"))).is_false()
	assert_bool(Builds.build("no_such_build")["ok"]).is_false()
	# extra turns are resolved by the battle core: a TPR 2 build is fully simulated
	assert_int((Builds.build("test_hawk_winged_jab")["sheet"] as UnitSheet).tpr).is_equal(2)
	assert_bool(Builds.fully_simulated(Builds.build("test_hawk_winged_jab"))).is_true()


func test_illegal_builds_are_reported() -> void:
	var def: SimBuildDef = Builds.load_build("test_golem_shield").duplicate(true)
	def.hp = 9                                    # one point over the budget and over the Core HP ceiling
	var r := Builds.assemble(def, "changed")
	assert_bool(r["ok"]).is_false()
	assert_array(r["errors"]).contains(["stat points 32 exceed budget 31", "hp 9 above stage ceiling 8"])
	def = Builds.load_build("test_golem_shield").duplicate(true)
	def.kin = MonsterDef.Kin.SCALED                # the kit holds a Strike priced for Beast
	assert_array(Builds.assemble(def, "changed")["errors"]).contains(["slot 1 Beast Jab: Strike Kin beast != monster Kin scaled"])
	def = Builds.load_build("test_golem_shield").duplicate(true)
	def.slots[1].level = 1                         # Shield costs 26, slot level 1 allows 24
	assert_array(Builds.assemble(def, "changed")["errors"]).contains(["slot 2 Shield 2, 3 cells, 2 rounds: 26 points exceed ceiling 24 of slot level 1"])
	def = Builds.load_build("test_golem_shield").duplicate(true)
	def.ap = 2                                     # 3 unspent points are allowed, a missing skill is not
	def.slots.clear()
	assert_array(Builds.assemble(def, "changed")["errors"]).contains(["kit needs 1-4 slots"])
	def.tpr = 4
	assert_bool(Builds.assemble(def, "changed")["ok"]).is_false()
	# the stored build is untouched
	assert_bool(Builds.build("test_golem_shield")["ok"]).is_true()


func test_strike_geometry_is_read_from_the_engine_shapes() -> void:
	# [hit cells, cells outside the adjacent ring, direction choice] of gdd_skills §8.1
	var expect := {&"jab": [1, 0, true], &"thrust": [2, 1, true], &"diagonal_thrust": [2, 1, true], &"pincer": [2, 0, true],
		&"arc": [3, 0, true], &"cleave": [6, 3, true], &"whirl": [4, 0, false], &"cross": [4, 0, false],
		&"storm": [8, 0, false], &"long_whirl": [8, 4, false], &"long_cross": [8, 4, false]}
	for shape: StringName in expect:
		var g := Builds.strike_geometry(shape)
		assert_array([g["cells"], g["distant"], g["direction"]]).override_failure_message(String(shape)).is_equal(expect[shape])


func test_every_record_with_a_definition_prices_exactly_that_definition() -> void:
	var records := Pricing.load_records()
	var without: Array[String] = []
	for id: String in records:
		var rec: PriceRecord = records[id]
		if rec.skill == null:
			without.append(id)
			continue
		assert_str(Builds.engine_check(rec)["error"]).override_failure_message(id).is_empty()
	assert_array(without).contains_exactly_in_any_order(REFERENCE_ONLY)
	# Kin Strikes and movement presets price the content records themselves
	assert_str(_named("Scaled Jab").skill.resource_path).is_equal("res://data/battle/skills/strike_jab.tres")
	assert_object(_named("Scaled Jab").skill).is_same(_named("Beast Jab").skill)
	assert_str(_named("Run").skill.resource_path).is_equal("res://data/battle/skills/run.tres")
	assert_str(_named("Slow zone 2 rounds").skill.resource_path).is_equal("res://data/battle/skills/slowing_zone_example.tres")
	# body-relative variants (gdd_skills §3) are fixtures of their own: adjacent push, or no damage
	var thrust := _named("Scaled Thrust (1 adjacent)").skill
	assert_array([thrust.strike_damage, thrust.kin_effect, thrust.radial_push]).is_equal([2, false, true])
	var shove := _named("Scaled push only").skill
	assert_array([shove.strike_damage, shove.kin_effect, shove.radial_push, shove.self_retreat]).is_equal([0, false, true, false])
	var retreat := _named("Winged retreat only").skill
	assert_array([retreat.strike_damage, retreat.kin_effect, retreat.radial_push, retreat.self_retreat]).is_equal([0, false, false, true])
	var flood := _named("Flood 2 cells").skill
	assert_array([flood.kind, flood.cost(), flood.surge_damage, flood.surge_displacement, flood.footprint.size(), flood.board_ops[0].ground]) \
		.is_equal(["surge", 1, 2, "push", 2, &"thornbed"])
	var shield := _named("Shield 2, 3 cells, 2 rounds").skill
	assert_array([shield.kind, shield.duration, shield.footprint.size()]).is_equal(["zone", 2, 3])
	assert_array([shield.zone.effects[0].tag, shield.zone.effects[0].value_at(1), shield.zone.effects[0].value_at(3)]).is_equal(["shield", 2, 3])
	assert_array([_named("Mend 1, 3 cells, 2 rounds").skill.zone.effects[0].value_at(1),
		_named("Mend 1, 3 cells, 2 rounds").skill.zone.effects[0].value_at(3)]).is_equal([1, 2])
	assert_int(_named("Slow zone 3 rounds").skill.duration).is_equal(3)
	# an undecided cap stays at level I and says so
	var quicken := _named("Quicken 1, 3 cells, 2 rounds")
	assert_int(quicken.skill.zone.effects[0].value_at(3)).is_equal(1)
	assert_bool(" ".join(Builds.engine_check(quicken)["notes"]).contains("NOT SIMULATED")).is_true()
	assert_bool(" ".join(Builds.engine_check(_named("Shield 2, 3 cells, 2 rounds"))["notes"]).contains("TEST FIXTURE")).is_true()


func test_a_record_that_differs_from_its_definition_is_not_simulated() -> void:
	_rejected(_named("Eruption 3 cells"), "no definition")
	var rec := _copy("Eruption 2 cells")
	rec.components[0].damage = 4
	_rejected(rec, "Surge damage 4 priced, 3 defined")
	rec = _copy("Eruption 2 cells")
	rec.skill.footprint.append(Vector2i(2, 0))
	_rejected(rec, "three cells defined, two priced")
	rec = _copy("Eruption 2 cells")
	rec.skill.surge_displacement = "push"
	_rejected(rec, "an unpriced push")
	rec = _copy("Rift 2 cells (no collapse)")
	rec.skill.board_ops.append(BoardOp.make(BoardOp.DESTROY_MOUNTAIN))
	_rejected(rec, "an unpriced Mountain destruction")
	rec = _copy("Flood 2 cells")
	rec.ap = 2
	_rejected(rec, "2 AP priced, 1 AP defined")
	rec = _copy("Beast Arc")
	rec.ap = 2                                     # the engine fixes Strike AP by shape
	_rejected(rec, "Arc at 2 AP")
	rec = _copy("Beast Arc")
	rec.components[1].kin_cells = 2
	_rejected(rec, "Kin cells of another shape")
	rec = _copy("Scaled Thrust (1 adjacent)")
	rec.components[1].kin = "beast"
	_rejected(rec, "a push variant priced for Beast")
	rec = _copy("Shield 2, 3 cells, 2 rounds")
	rec.skill.duration = 3
	_rejected(rec, "three rounds defined, two priced")
	rec = _copy("Shield 2, 3 cells, 2 rounds")
	rec.skill.zone.effects[0].cap = 4
	_rejected(rec, "a Shield cap above the decided 3")
	rec = _copy("Quicken 1, 3 cells, 2 rounds")
	rec.skill.zone.effects[0].cap = 2
	_rejected(rec, "an invented Quicken scaling")
	rec = _copy("Self Initiative +1, 2 rounds")
	rec.components[0].magnitude = 2
	_rejected(rec, "Initiative +2 priced, +1 defined")
	rec = _copy("Run")
	rec.components[0].preset = "blink"
	_rejected(rec, "Blink priced for the Run definition")
	rec = _copy("Slow zone 2 rounds")
	rec.once_per_round = true
	rec.round_cap = "effective"
	_rejected(rec, "a round limit the definition does not have")
	# nothing above changed a stored record or a content definition
	assert_str(Builds.engine_check(_named("Eruption 2 cells"))["error"]).is_empty()
	assert_int(_named("Eruption 2 cells").skill.footprint.size()).is_equal(2)
	assert_str(Builds.engine_check(_named("Beast Arc"))["error"]).is_empty()


func _play(names: Array, bot: String, seed_value: int) -> Battle:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var teams := [[Builds.build(names[0])["sheet"]], [Builds.build(names[1])["sheet"]]]
	var made := Runner.make_battle(&"1v1", teams, "flat", rng)
	assert_str(made["error"]).is_empty()
	var bots: Array[String] = [bot, bot]
	Runner.play(made["battle"], bots, rng)
	return made["battle"]


func test_a_build_battle_ends_and_repeats_for_the_same_seed() -> void:
	for bot in Bots.NAMES:
		var a := _play(["test_tiger_eruption", "test_golem_eruption"], bot, 5)
		var c := _play(["test_tiger_eruption", "test_golem_eruption"], bot, 5)
		assert_bool(a.over).override_failure_message("bot %s did not finish" % bot).is_true()
		assert_str(a.state_hash()).override_failure_message("bot %s is not repeatable" % bot).is_equal(c.state_hash())
	# side 1 starts on the point-mirrored square of side 0
	var rng := RandomNumberGenerator.new()
	var sheet: UnitSheet = Builds.build("test_golem_slow")["sheet"]
	var b: Battle = Runner.make_battle(&"3v3", [[sheet], [sheet]], "flat", rng)["battle"]
	assert_that(b.units[&"b0_test_golem_slow"].pos).is_equal(b.board.mirrored(b.units[&"a0_test_golem_slow"].pos))
	assert_bool(BattleBoards.in_start_area(&"3v3", b.units[&"a0_test_golem_slow"].pos, 0)).is_true()
