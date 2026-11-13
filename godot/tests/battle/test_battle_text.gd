extends GdUnitTestSuite
## HUD texts stay short: tokens instead of sentences, built from the data (battle/ui/battle_text.gd).

const H := preload("res://tests/battle/helpers.gd")
const MAX_CARD_ROWS := 6
const MAX_LINE := 72


func _values(rows: Array) -> Array:
	return rows.map(func(r): return r[1])


func test_skill_cards_are_a_few_short_lines() -> void:
	var c := H.content()
	for id: StringName in c.skills:
		for kin in MonsterDef.Kin.values():
			var rows := BattleText.skill_rows(c, c.skill(id), kin)
			assert_int(rows.size()).is_between(1, MAX_CARD_ROWS)
			for r in rows:
				assert_int(String(r[1]).length()).is_less_equal(MAX_LINE)
	assert_array(BattleText.step_rows()).is_equal([["", "walk · 1 sq"]])


func test_skill_cards_say_what_matters() -> void:
	var c := H.content()
	# a skill that creates something: where, what it creates, and below it what that thing does
	assert_array(_values(BattleText.skill_rows(c, c.skill(&"lava_field")))).is_equal(["4 sq · within Reach", "creates ground: Lava · 2 rd",
		"  Lava: 1 dmg at turn end (II: 2)"])
	# a stat zone only comes along with something else (user decision 2026-11-13)
	assert_array(_values(BattleText.skill_rows(c, c.skill(&"thornbed")))).is_equal(["3 sq · within Reach", "creates ground: Thornbed · 2 rd",
		"  Thornbed: 1 dmg on entering (II: 2)", "creates zone: Slowing Zone · 2 rd", "  Slowing Zone: while inside: Movement −1"])
	assert_array(_values(BattleText.skill_rows(c, c.skill(&"snare")))).is_equal(["1 sq · within Reach", "creates ground: Binding Vines · 2 rd",
		"  Binding Vines: 2 dmg on leaving"])
	assert_array(_values(BattleText.skill_rows(c, c.skill(&"bog")))).is_equal(["3 sq · within Reach", "creates zone: Bog · 2 rd",
		"  Bog: while inside: Movement −1 · pulls 1 at cast and turn end"])
	assert_array(_values(BattleText.skill_rows(c, c.skill(&"plant_bamboo")))).is_equal(["1 sq · within Reach", "creates prop: Bamboo Stand",
		"  Bamboo Stand: 2 HP · spiky · burst 1"])
	# two things at once
	assert_array(_values(BattleText.skill_rows(c, c.skill(&"coiling_rift")))).is_equal(["4 sq · within Reach", "creates ground: Blight · 2 rd",
		"  Blight: 1 dmg at round end (II: 2)", "creates zone: Void Pull · 2 rd", "  Void Pull: pulls 1 at cast and turn end"])
	# a Strike and a movement that leave something
	assert_array(_values(BattleText.skill_rows(c, c.skill(&"thorn_lash")))).is_equal(["2 dmg · 1 sq", "creates ground: Thornbed · 2 rd",
		"  Thornbed: 1 dmg on entering (II: 2)"])
	assert_array(_values(BattleText.skill_rows(c, c.skill(&"fire_trail")))).is_equal(["straight line · Move", "leaves on its path: ground: Lava · 2 rd",
		"  Lava: 1 dmg at turn end (II: 2)"])
	assert_array(_values(BattleText.skill_rows(c, c.skill(&"leap")))).is_equal(["straight line · Move"])
	assert_array(_values(BattleText.skill_rows(c, c.skill(&"headbutt")))).is_equal(["straight line · Move · pushes the monster ahead"])
	assert_array(_values(BattleText.skill_rows(c, c.skill(&"battle_trance")))).is_equal(["self: AP +1 · 2 rd · 1/battle"])
	assert_array(_values(BattleText.skill_rows(c, c.skill(&"immovable")))).is_equal(["Ignores push and pull."])
	# the Kin twist is one extra line, and only if the Kin has one
	assert_array(_values(BattleText.skill_rows(c, c.skill(&"strike_jab"), MonsterDef.Kin.BEAST))).is_equal(["2 dmg · 1 sq"])
	assert_array(_values(BattleText.skill_rows(c, c.skill(&"strike_jab"), MonsterDef.Kin.SCALED))).is_equal(["2 dmg · 1 sq", "push 1 (WASD)"])
	var limited: BattleSkillDef = c.skill(&"lava_field").duplicate()
	limited.repetition = "once_per_round"
	assert_str(_values(BattleText.skill_rows(c, limited))[0]).is_equal("4 sq · within Reach · 1/round")


func test_ground_and_prop_lines_come_from_the_data() -> void:
	var c := H.content()
	var grounds := {&"plain": "", &"rubble": "move cost 2", &"voidscar": "1 dmg at turn end", &"lava": "2 dmg at turn end",
		&"thornbed": "2 dmg on entering", &"blight": "2 dmg at round end", &"hearth": "quicken 1", &"mossbed": "heal 1 on entering",
		&"umbra": "extend 1", &"hallowed": "shield 1"}
	for id: StringName in grounds:
		assert_str(BattleText.ground_brief(c.ground(id), 2)).is_equal(grounds[id])
	var props := {&"stone_lion": "heavy · leaves Rubble", &"clay_urn": "burst 1", &"paper_lantern": "leaves Lava",
		&"bronze_gong": "push 1", &"pagoda_column": "spawns Beam · leaves Rubble", &"beam": "", &"wind_chime": "air",
		&"gale_banner": "air · aura quicken 1 (air)", &"pagoda_bridge": "ground+air · leaves Rubble", &"wardstone": "aura shield 1 · leaves Rubble"}
	for id: StringName in props:
		assert_str(BattleText.prop_brief(c, c.prop(id))).is_equal(props[id])
	for id: StringName in c.props:
		assert_int(BattleText.prop_brief(c, c.prop(id)).length()).is_less_equal(40)


func test_the_inspector_shows_only_what_is_notable() -> void:
	var slow := H.zone_skill([FieldEffect.make("slow", 1, 2)], [Vector2i.ZERO], 2, "Slowing").zone
	var b := H.battle([
		[0, Vector2i(3, 3), {"name": "Tiger", "init": 7.0, "move": 4, "reach": 2, "ap": 3, "skills": ["leap", "strike_jab"]}],
		[1, Vector2i(6, 6), {"name": "Wolf", "reach": 3, "skills": [H.surge([Vector2i.ZERO])]}],
	])
	assert_array(BattleText.cell_rows(b, Vector2i(0, 0))).is_empty()          # an empty Plain square: nothing
	b.set_ground(Vector2i(3, 3), &"lava", 2)
	b.board.at(Vector2i(3, 3)).height = 1
	H.zone_on(b, Vector2i(3, 3), slow, 1, 2)
	b.add_prop(&"stone_lion", Vector2i(4, 3))
	assert_array(BattleText.cell_rows(b, Vector2i(3, 3))).is_equal([
		["Ground", "Lava II · 2 dmg at turn end · Mountain · +1 Reach"],
		["Zone", "Slowing II · 2 rd · slow 2"],
	])
	assert_array(BattleText.cell_rows(b, Vector2i(4, 3))).is_equal([["Prop", "Stone Lion 3/3 · heavy · leaves Rubble"]])
	# a monster: one stat line, one line for what affects it, one for its kit
	var tiger := H.unit(b, 0)
	tiger.hp = 4
	tiger.nullify = true
	assert_str(BattleText.unit_title(tiger)).is_equal("Tiger · Beast")
	assert_array(_values(BattleText.unit_rows(b, tiger))).is_equal([
		"HP 4/5 · Init 7.0 · Move 2 · Reach 3 · AP 3",
		"slow 2, extend 1, Nullify",
		"Leap · Jab",
	])
	b.begin()
	b.end_turn()
	assert_bool(b.apply({"type": &"skill", "slot": 0, "anchor": Vector2i(5, 5)})).is_true()
	assert_array(BattleText.cell_rows(b, Vector2i(5, 5))).is_equal([["Surge", "Test Surge · 3 dmg · Wolf"]])


func test_the_cast_preview_is_a_few_merged_lines() -> void:
	var b := H.battle([
		[0, Vector2i(3, 5), {"name": "Tiger", "init": 9.0, "reach": 3, "ap": 4, "kin": MonsterDef.Kin.SCALED,
			"skills": ["lava_field", "gloom_rift", H.strike(), "slowing_zone_example"]}],
		[1, Vector2i(3, 4), {"name": "Wolf", "hp": 3}],
	])
	b.board.at(Vector2i(3, 3)).height = 1
	b.begin()
	# ground skill: one merged line instead of one per square
	assert_array(BattleText.preview_lines(b, b.preview({"type": &"skill", "slot": 0, "anchor": Vector2i(3, 3)}))).is_equal(["Lava I ×4"])
	# Gloom Rift lays ground since the reshape (no Surges): the same merged line; the hand-made Mountain square takes none
	assert_array(BattleText.preview_lines(b, b.preview({"type": &"skill", "slot": 1, "anchor": Vector2i(3, 3)}))).is_equal(["3 new", "Blight I ×2"])
	assert_array(BattleText.preview_lines(b, b.preview({"type": &"skill", "slot": 1, "anchor": Vector2i(0, 5)}))).is_equal(["3 new", "Blight I ×3"])
	# Strike with a push; a zone; an illegal aim
	assert_array(BattleText.preview_lines(b, b.preview({"type": &"skill", "slot": 2, "dir": H.UP, "push_dir": H.LEFT}))).is_equal(["Wolf −2", "Wolf → [2,4]"])
	assert_array(BattleText.preview_lines(b, b.preview({"type": &"skill", "slot": 3, "anchor": Vector2i(3, 4)}))).is_equal(["3 new"])
	assert_array(BattleText.preview_lines(b, b.preview({"type": &"step", "to": Vector2i(2, 5)}))).is_empty()
	assert_array(BattleText.preview_lines(b, b.preview({"type": &"step", "to": Vector2i(3, 4)}))).is_equal(
		["✗ Step moves exactly 1 square onto a free, unblocked square"])
