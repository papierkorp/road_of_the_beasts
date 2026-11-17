extends GdUnitTestSuite
## HUD texts stay short: tokens instead of sentences, built from the data (battle/ui/battle_text.gd).

const H := preload("res://tests/battle/helpers.gd")


func before_test() -> void:
	H.legacy_rules()


func after_test() -> void:
	BattleExperiment.reset()
const MAX_CARD_ROWS := 8
const MAX_LINE := 72


func _values(rows: Array) -> Array:
	return rows.map(func(r): return r[1])


func test_skill_cards_are_a_few_short_lines() -> void:
	H.rule_strikes()
	var c := H.content()
	for id: StringName in c.skills:
		for kin in MonsterDef.Kin.values():
			var rows := BattleText.skill_rows(c, c.skill(id), kin)
			assert_int(rows.size()).is_between(1, MAX_CARD_ROWS)
			for r in rows:
				assert_int(String(r[1]).length()).is_less_equal(MAX_LINE)
	assert_array(BattleText.step_rows()).is_equal([["Cost", "1 AP · any number/turn"], ["Where", "walk · 1 sq"]])


func test_skill_cards_say_what_matters() -> void:
	H.rule_strikes()
	var c := H.content()
	# every card has the same build: Cost, Where, Does, then per created thing a row and below it what the thing does
	assert_array(BattleText.skill_rows(c, c.skill(&"lava_field"))).is_equal([["Cost", "1 AP"], ["Where", "4 sq · within Reach · ■■/■■"],
		["Creates", "ground Lava · 2 rd"], ["", "1 dmg at turn end"]])
	# two things are two blocks
	assert_array(_values(BattleText.skill_rows(c, c.skill(&"coiling_rift")))).contains(["ground Lava · 2 rd", "zone Void Pull · 2 rd", "turn end: pull 1 to centre"])
	assert_array(_values(BattleText.skill_rows(c, c.skill(&"plant_bamboo")))).is_equal(["1 AP", "1 sq · within Reach", "prop Bamboo Stand",
		"2 HP · spiky · destroyed: 1 dmg next to it"])
	# a Strike and a movement that leave something
	assert_array(BattleText.skill_rows(c, c.skill(&"thorn_lash"))).is_equal([["Cost", "2 AP"], ["Where", "Jab · 1 sq next to the user"],
		["Does", "push 1 · 2 dmg to props"], ["Creates", "ground Thornbed · 2 rd"], ["", "1 dmg on entering"]])
	assert_array(BattleText.skill_rows(c, c.skill(&"fire_trail"))).is_equal([["Cost", "2 AP · Stamina 1/sq"], ["Where", "straight line · up to 3 sq"],
		["Passes", "over monsters · only the landing sq counts"], ["Leaves", "ground Lava · 2 rd"], ["", "1 dmg at turn end"]])
	assert_array(_values(BattleText.skill_rows(c, c.skill(&"leap")))).is_equal(["2 AP · Stamina 1/sq", "straight line · up to 3 sq", "over props, monsters · only the landing sq counts"])
	assert_array(_values(BattleText.skill_rows(c, c.skill(&"headbutt")))).is_equal(["2 AP · Stamina 1/sq", "straight line · up to 3 sq", "over props, monsters · only the landing sq counts", "pushes the monster ahead 1"])
	assert_array(BattleText.skill_rows(c, c.skill(&"battle_trance"))).is_equal([["Cost", "1 AP · 1/battle"], ["Where", "the user"], ["Does", "AP +1 · 2 rd"]])
	assert_array(BattleText.skill_rows(c, c.skill(&"immovable"))).is_equal([["Passive", "Ignores push and pull."]])
	# a Strike deals no damage to monsters; the Kin of the user adds nothing
	assert_array(_values(BattleText.skill_rows(c, c.skill(&"strike_jab"), MonsterDef.Kin.BEAST))).is_equal(["2 AP", "Jab · 1 sq next to the user", "push 1 · 2 dmg to props"])
	assert_array(_values(BattleText.skill_rows(c, c.skill(&"strike_jab"), MonsterDef.Kin.SCALED))).is_equal(["2 AP", "Jab · 1 sq next to the user", "push 1 · 2 dmg to props"])
	var limited: BattleSkillDef = c.skill(&"lava_field").duplicate()
	limited.repetition = "once_per_round"
	assert_str(_values(BattleText.skill_rows(c, limited))[0]).is_equal("1 AP · 1/round")
	assert_array(_values(BattleText.skill_rows(c, c.skill(&"basic_jab")))).is_equal(["2 AP", "Jab · 1 sq next to the user", "1 dmg"])


func test_ground_and_prop_lines_come_from_the_data() -> void:
	var c := H.content()
	var grounds := {&"plain": "", &"rubble": "move cost 2", &"voidscar": "1 dmg at turn end", &"lava": "1 dmg at turn end",
		&"thornbed": "1 dmg on entering", &"blight": "2 dmg at round end", &"hearth": "quicken 1", &"mossbed": "heal 1 on entering",
		&"umbra": "extend 1", &"hallowed": "shield 1"}
	for id: StringName in grounds:
		assert_str(BattleText.ground_brief(c.ground(id), 2)).is_equal(grounds[id])
	var props := {&"stone_lion": "heavy · leaves Rubble", &"clay_urn": "destroyed: 1 dmg around it", &"paper_lantern": "leaves Lava",
		&"bronze_gong": "push 1", &"pagoda_column": "spawns Beam · leaves Rubble", &"beam": "", &"wind_chime": "air",
		&"gale_banner": "air · aura quicken 1 (air)", &"pagoda_bridge": "ground+air · leaves Rubble", &"wardstone": "aura shield 1 · leaves Rubble"}
	for id: StringName in props:
		assert_str(BattleText.prop_brief(c, c.prop(id))).is_equal(props[id])
	for id: StringName in c.props:
		assert_int(BattleText.prop_brief(c, c.prop(id)).length()).is_less_equal(40)


func test_the_inspector_shows_only_what_is_notable() -> void:
	var slow := H.zone_skill([FieldEffect.make("slow", 1, 2)], [Vector2i.ZERO], 2, "Slowing").zone
	var b := H.battle([
		[0, Vector2i(3, 3), {"name": "Tiger", "pace": 1.7, "move": 4, "reach": 2, "ap": 3, "skills": ["leap", "strike_jab"]}],
		[1, Vector2i(6, 6), {"name": "Wolf", "reach": 3, "skills": [H.surge([Vector2i.ZERO])]}],
	])
	assert_array(BattleText.cell_rows(b, Vector2i(0, 0))).is_empty()          # an empty Plain square: nothing
	b.set_ground(Vector2i(3, 3), &"lava", 1)
	b.board.at(Vector2i(3, 3)).height = 1
	H.zone_on(b, Vector2i(3, 3), slow, 1, 2)
	b.add_prop(&"stone_lion", Vector2i(4, 3))
	assert_array(BattleText.cell_rows(b, Vector2i(3, 3))).is_equal([
		["Ground", "Lava · 1 dmg at turn end · Mountain · +1 Reach"],
		["Zone", "Slowing II · 2 more rounds"],
		["", ""],
	])
	# a prop names its traits and what it does in terms; the glossary explains them once
	assert_array(BattleText.cell_rows(b, Vector2i(4, 3))).is_equal([["Prop", "Stone Lion · HP 3/3"],
		["", "solid · heavy · spiky"], ["", "destroyed: leaves Rubble"]])
	for row: Array in BattleText.GLOSSARY:
		assert_str(row[0]).is_not_empty()
	# a monster: one stat line, one line for what affects it, one for its kit
	var tiger := H.unit(b, 0)
	tiger.hp = 4
	tiger.nullify = true
	assert_str(BattleText.unit_title(tiger)).is_equal("Tiger · Beast")
	assert_array(_values(BattleText.unit_rows(b, tiger))).is_equal([
		"HP 4/5 · Pace 1.7 · Stamina 4/4 (+1) · Reach 3 · AP 3",
		"extend 1, Nullify",
		"Leap · Jab",
	])
	b.begin()
	b.end_turn()
	assert_bool(b.apply({"type": &"skill", "slot": 0, "anchor": Vector2i(5, 5)})).is_true()
	assert_array(BattleText.cell_rows(b, Vector2i(5, 5))).is_equal([["Surge", "Test Surge · 3 dmg · Wolf"]])


func test_the_cast_preview_is_a_few_merged_lines() -> void:
	var b := H.battle([
		[0, Vector2i(3, 5), {"name": "Tiger", "pace": 1.9, "reach": 3, "ap": 4,
			"skills": ["lava_field", "gloom_rift", H.strike(), "slowing_zone_example"]}],
		[1, Vector2i(3, 4), {"name": "Wolf", "hp": 3}],
	])
	b.board.at(Vector2i(3, 3)).height = 1
	b.begin()
	# ground skill: one merged line instead of one per square
	assert_array(BattleText.preview_lines(b, b.preview({"type": &"skill", "slot": 0, "anchor": Vector2i(3, 3)}))).is_equal(["Lava ×4"])
	# Gloom Rift lays ground since the reshape (no Surges): the same merged line; the hand-made Mountain square takes none
	assert_array(BattleText.preview_lines(b, b.preview({"type": &"skill", "slot": 1, "anchor": Vector2i(3, 3)}))).is_equal(["Lava ×2"])
	assert_array(BattleText.preview_lines(b, b.preview({"type": &"skill", "slot": 1, "anchor": Vector2i(0, 5)}))).is_equal(["Lava ×3"])
	# Strike with a push; a zone; an illegal aim
	assert_array(BattleText.preview_lines(b, b.preview({"type": &"skill", "slot": 2, "dir": H.UP}))).is_equal(["Wolf stays"])
	assert_array(BattleText.preview_lines(b, b.preview({"type": &"skill", "slot": 3, "anchor": Vector2i(3, 4)}))).is_equal(["3 new"])
	assert_array(BattleText.preview_lines(b, b.preview({"type": &"step", "to": Vector2i(2, 5)}))).is_empty()
	assert_array(BattleText.preview_lines(b, b.preview({"type": &"step", "to": Vector2i(3, 4)}))).is_equal(
		["✗ Step moves exactly 1 square onto a free, unblocked square"])
