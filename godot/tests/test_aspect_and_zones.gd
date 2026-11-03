extends GdUnitTestSuite
## Unit tests for the headless battle core (GDD §7, §16). Requires the gdUnit4 addon.

const F := Aspect.Type.FORCE
const N := Aspect.Type.NATURE
const D := Aspect.Type.DARK
const NONE := Aspect.Type.NONE


func test_triangle() -> void:
	assert_bool(Aspect.beats(F, N)).is_true()
	assert_bool(Aspect.beats(N, D)).is_true()
	assert_bool(Aspect.beats(D, F)).is_true()
	assert_bool(Aspect.beats(N, F)).is_false()


func test_attunement_mod() -> void:
	assert_int(Aspect.attunement_mod(F, NONE)).is_equal(0)
	assert_int(Aspect.attunement_mod(F, F)).is_equal(1)
	assert_int(Aspect.attunement_mod(F, D)).is_equal(-1) # Dark beats Force
	assert_int(Aspect.attunement_mod(F, N)).is_equal(0)


func test_bog_levels_and_slow_cap() -> void:
	var bog: ZoneDef = load("res://data/zones/bog.tres")
	var lvl1 := bog.effective(1, NONE)
	assert_int(lvl1[0]["value"]).is_equal(1) # slow
	var lvl3 := bog.effective(3, NONE)
	assert_int(lvl3[0]["value"]).is_equal(2) # slow capped at 2
	assert_int(lvl3[1]["value"]).is_equal(1) # pull always 1


func test_attunement_changes_zone_value_min_one() -> void:
	var mire: ZoneDef = load("res://data/zones/mire.tres")
	# Mire is Dark: +1 on Dark, -1 on Nature-attuned (Nature beats Dark)
	assert_int(mire.effective(1, D)[1]["value"]).is_equal(3) # drain_init 2+1
	assert_int(mire.effective(1, N)[1]["value"]).is_equal(1) # 2-1
	assert_int(mire.effective(1, N)[0]["value"]).is_equal(1) # slow min 1


func test_veil_cuts_surge_damage() -> void:
	var sq := Square.new(Vector2i(1, 1))
	sq.zone = {"def": load("res://data/zones/veil_n.tres"), "level": 1}
	assert_int(sq.surge_damage(F, 3)).is_equal(1) # 3 - shield 2
	sq.zone["level"] = 2
	assert_int(sq.surge_damage(F, 3)).is_equal(0) # shield 3


func test_elevated_blanks_surge() -> void:
	var sq := Square.new()
	sq.elevated = true
	assert_int(sq.surge_damage(F, 3)).is_equal(0)


func test_rubble_cannot_hold_attunement() -> void:
	var sq := Square.new()
	sq.ground = Square.GroundType.RUBBLE
	sq.set_attunement(F)
	assert_int(sq.attunement).is_equal(NONE)
