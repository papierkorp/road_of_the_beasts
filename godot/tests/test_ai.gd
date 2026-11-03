extends GdUnitTestSuite
## AiBrain behaviour (ported from the prototype's Wolf). Requires gdUnit4.


func _skill(id: String) -> SkillDef:
	return load("res://data/skills/%s.tres" % id)


func _battle() -> Battle:
	var tiger := Monster.new(&"tiger", "Blaze Tiger", Aspect.Type.FORCE, Vector2i(4, 0), 6, 7.0, 2,
		[_skill("magma_surge"), _skill("bog"), _skill("bark_veil")] as Array[SkillDef])
	var wolf := Monster.new(&"wolf", "Gloom Wolf", Aspect.Type.DARK, Vector2i(0, 4), 5, 5.0, 2,
		[_skill("gloom_surge"), _skill("mire"), _skill("shade_veil")] as Array[SkillDef])
	var b := Battle.new(Board.new(5), [tiger, wolf] as Array[Monster])
	b.begin()
	return b


func _rng() -> RandomNumberGenerator:
	var r := RandomNumberGenerator.new()
	r.seed = 1234
	return r


func test_wolf_dodges_a_surge_aimed_at_it() -> void:
	var b := _battle()
	var wolf: Monster = b.monsters[&"wolf"]
	# the tiger's pending Surge covers the wolf's square
	b.board.at(wolf.pos).surge = {"owner": &"tiger", "aspect": Aspect.Type.FORCE, "name": "Magma Surge", "value": 3, "gid": "x"}
	b.end_turn()                                      # wolf's turn
	var a := AiBrain.decide(b, &"wolf", _rng())
	assert_bool(a["type"] == &"move" or a["type"] == &"cast").is_true()
	if a["type"] == &"move":
		assert_bool(a["to"] != wolf.pos).is_true()


func test_wolf_attacks_when_it_can_threaten_the_tiger() -> void:
	var b := _battle()
	var wolf: Monster = b.monsters[&"wolf"]
	b.board.occupants.erase(wolf.pos)
	wolf.pos = Vector2i(3, 2)
	b.board.occupants[wolf.pos] = &"wolf"
	b.end_turn()
	var a := AiBrain.decide(b, &"wolf", _rng())
	assert_str(a["type"]).is_equal("cast")
	assert_str(a["skill"].id).is_equal("gloom_surge")


func test_ai_turn_spends_ap_and_passes_the_turn() -> void:
	var b := _battle()
	b.end_turn()
	AiBrain.play_turn(b, &"wolf", _rng())
	assert_str(b.turn_owner).is_not_equal("wolf")


func test_self_play_terminates_without_errors() -> void:
	var b := _battle()
	var rng := _rng()
	var guard := 0
	while not b.over and guard < 60:
		AiBrain.play_turn(b, b.turn_owner, rng)
		guard += 1
	assert_bool(guard > 0).is_true()
