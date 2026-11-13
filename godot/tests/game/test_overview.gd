extends GdUnitTestSuite
## The debug tables (game/overview.gd) list every skill and monster record and filter by status.


func test_every_skill_record_has_a_row() -> void:
	var c := BattleContent.shared()
	var rows := Overview.skill_rows(c)
	assert_int(rows.size()).is_equal(c.skills.size())
	for r in rows:
		assert_str(r["name"]).is_not_empty()
		assert_str(r["effect"]).is_not_empty()
		for part: String in ["cost", "where", "strike", "move", "self", "ground", "zone", "prop"]:      # the skill card, gdd_skills §2
			assert_str(r[part]).is_not_empty()
		assert_bool(r["in_game"]).is_equal(ContentStatus.in_game(c.skill(StringName(r["id"]))))


func test_every_monster_record_has_a_row() -> void:
	var c := BattleContent.shared()
	var rows := Overview.monster_rows(c)
	assert_int(rows.size()).is_equal(c.monsters.size())
	for r in rows:
		var m := c.monster(StringName(r["id"]))
		assert_str(r["name"]).is_equal(m.display_name)
		assert_int(r["hp"]).is_equal(m.hp)
		assert_str(r["kit"]).is_equal(m.kit_text())


func test_a_skill_reads_as_its_card() -> void:
	var c := BattleContent.shared()
	assert_dict(SkillGen.card(c, c.skill(&"strike_jab"))).is_equal({"cost": "2 AP", "where": "neighbour · jab", "strike": "2 dmg, push 1",
		"move": "—", "self": "—", "ground": "—", "zone": "—", "prop": "—"})
	var snare := SkillGen.card(c, c.skill(&"snare"))
	assert_array([snare["strike"], snare["ground"], snare["zone"], snare["prop"]]).is_equal(["—", "Binding Vines", "—", "—"])
	var coil := SkillGen.card(c, c.skill(&"coiling_rift"))
	assert_array([coil["ground"], coil["zone"]]).is_equal(["Blight", "Void Pull · 2 rd"])      # one skill, two things created
	assert_str(SkillGen.card(c, c.skill(&"plant_bamboo"))["prop"]).is_equal("Bamboo Stand")
	assert_str(SkillGen.card(c, c.skill(&"run"))["move"]).is_equal("walks · Movement")
	assert_str(SkillGen.card(c, c.skill(&"battle_trance"))["self"]).contains("AP +1")
	assert_str(SkillGen.line(c, c.skill(&"thorn_lash"))).is_equal("2 AP · neighbour · jab · strike: 2 dmg, push 1 · creates ground: Thornbed")
	# no Surge and no trap is in the game any more: damage at range comes from ground
	for id in c.skills:
		if ContentStatus.in_game(c.skill(id)):
			assert_bool(c.skill(id).is_marker()).is_false()


func test_the_skill_builder_builds_skills_from_the_parts() -> void:
	var c := BattleContent.shared().copy()
	var lash := SkillGen.build(c, {"name": "Ember Lash", "ap": "2", "strike": "jab", "damage": "2", "ground": "lava", "prop": "bamboo_stand"})
	assert_str(lash.id).is_equal("ember_lash")
	assert_str(lash.content_status).is_equal(ContentStatus.EXPERIMENT)
	assert_str(lash.kind).is_equal("strike")
	assert_str(SkillGen.line(c, lash)).is_equal("2 AP · neighbour · jab · strike: 2 dmg, push 1 · creates ground: Lava")      # no prop under a struck monster
	var wall := SkillGen.build(c, {"name": "Wind Wall", "shape": "line2", "zone": "gale"})
	assert_str(wall.kind).is_equal("zone")                   # a zone alone is a zone skill: it gets its direction
	assert_object(wall.zone).is_same(c.zone(&"gale"))
	var both := SkillGen.build(c, {"name": "Rot Pit", "shape": "block", "ground": "blight", "zone": "void_pull"})
	assert_str(both.kind).is_equal("ground")
	assert_array([SkillGen.card(c, both)["ground"], SkillGen.card(c, both)["zone"]]).is_equal(["Blight", "Void Pull · 2 rd"])
	var run := SkillGen.build(c, {"name": "Thorn Run", "path": "line", "impact": "ahead", "ground": "thornbed"})
	assert_str(run.kind).is_equal("move")
	assert_str(run.impact_push).is_equal("ahead")
	var buff := SkillGen.build(c, {"name": "Swift Mind", "self": "quicken"})
	assert_str(buff.kind).is_equal("buff")
	assert_str(SkillGen.card(c, buff)["self"]).is_equal("initiative +1 · 2 rd")
	var rock := SkillGen.build(c, {"name": "Rooted", "self": "immovable"})
	assert_str(rock.kind).is_equal("passive")
	assert_bool(rock.immovable).is_true()
	assert_str(SkillGen.build(c, {"name": "Nothing"}).kind).is_equal("ground")      # a skill has to do something: Thornbed
	# every field of the builder offers choices; archived grounds, zones and props are not among them
	for field: Array in SkillBuilder.FIELDS:
		assert_bool(SkillBuilder.choices(c, field[0]).size() >= 2).is_true()
	var grounds: Array = SkillBuilder.choices(c, "ground").map(func(ch: Array) -> String: return ch[0])
	assert_bool(grounds.has("snare")).is_true()
	assert_bool(grounds.has("hearth") or grounds.has("dragon_vein") or grounds.has("plain")).is_false()
	assert_bool(SkillBuilder.fields_of({"strike": "jab"}).has("prop")).is_false()
	assert_bool(SkillBuilder.fields_of({}).has("shape")).is_true()
	# a random draw is a Strike, a movement or a skill that creates; never a Surge or trap
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in 24:
		assert_bool(SkillGen.draw(c, rng, i).is_marker()).is_false()


func test_grounds_zones_and_props_have_a_row_per_file() -> void:
	var c := BattleContent.shared()
	var grounds := Overview.ground_rows(c)
	assert_int(grounds.size()).is_equal(c.grounds.size())
	var vines: Dictionary = grounds.filter(func(r: Dictionary) -> bool: return r["id"] == "snare")[0]
	assert_str(vines["effect"]).is_equal("2 dmg on leaving")
	assert_str(vines["sources"]).contains("Snare")
	var vein: Dictionary = grounds.filter(func(r: Dictionary) -> bool: return r["id"] == "dragon_vein")[0]
	assert_str(vein["lasts"]).is_equal("always")
	var zones := Overview.zone_rows(c)
	assert_int(zones.size()).is_equal(c.zones.size())
	var gale: Dictionary = zones.filter(func(r: Dictionary) -> bool: return r["id"] == "gale")[0]
	assert_bool(gale["in_game"]).is_true()
	assert_str(gale["sources"]).contains("Gale")
	var props := Overview.prop_rows(c)
	assert_int(props.size()).is_equal(c.props.size())
	var bamboo: Dictionary = props.filter(func(r: Dictionary) -> bool: return r["id"] == "bamboo_stand")[0]
	assert_str(bamboo["traits"]).contains("spiky")
	assert_str(bamboo["sources"]).contains("Plant Bamboo")
	for r in props:
		assert_str(r["effect"]).is_not_empty()
	# every table of the screen has rows for all of its columns
	var rows := {"skills": Overview.skill_rows(c), "monsters": Overview.monster_rows(c), "grounds": grounds, "zones": zones, "props": props}
	for id: String in Overview.TABLES:
		for col: Array in Overview.TABLES[id]["columns"]:
			assert_bool(rows[id][0].has(col[0])).is_true()
		assert_bool(rows[id][0].has(Overview.TABLES[id]["filter"])).is_true()
	# grounds, zones and props carry a content status: what the reshape retired is archived
	for row: Dictionary in grounds + zones + props:
		assert_str(row["status"]).is_not_empty()
	for pair: Array in [[grounds, "hearth"], [grounds, "hallowed"], [zones, "mending"], [props, "wind_chime"]]:
		var hit: Dictionary = (pair[0] as Array).filter(func(r: Dictionary) -> bool: return r["id"] == pair[1])[0]
		assert_str(hit["status"]).is_equal("archived")
		assert_bool(hit["in_game"]).is_false()
	# nothing the game fields uses an archived ground, zone or prop
	for id in c.skills:
		var sk := c.skill(id)
		if not ContentStatus.in_game(sk):
			continue
		if sk.zone != null:
			assert_bool(ContentStatus.in_game(sk.zone)).is_true()
		for op in sk.board_ops:
			if op.op == BoardOp.GROUND:
				assert_bool(ContentStatus.in_game(c.ground(op.ground))).is_true()
			elif op.op == BoardOp.CREATE_PROP:
				assert_bool(ContentStatus.in_game(c.prop(op.prop))).is_true()
	for id in c.props:
		var pd := c.prop(id)
		if ContentStatus.in_game(pd) and pd.ground_left != &"":
			assert_bool(ContentStatus.in_game(c.ground(pd.ground_left))).is_true()
	for pid: StringName in BattleBoards.SEEDED_PROPS:
		assert_bool(ContentStatus.in_game(c.prop(pid))).is_true()


func test_the_monster_builder_builds_and_checks_a_monster() -> void:
	var c := BattleContent.shared().copy()
	var m := MonsterBuilder.build(c, {"name": "Jade Crane", "kin": MonsterDef.Kin.WINGED, "hp": 4, "initiative": 8.5, "move": 4, "reach": 3,
		"tpr": 2, "ap": 3, "skills": ["glide", "strike_jab", "", "snare"], "blurb": "Pins and strikes."})
	assert_str(m.id).is_equal("jade_crane")
	assert_str(m.content_status).is_equal(ContentStatus.EXPERIMENT)
	assert_array([m.hp, m.move, m.reach, m.tpr, m.ap]).is_equal([4, 4, 3, 2, 3])
	assert_float(m.initiative).is_equal(8.5)
	assert_array(m.skills.map(func(s): return s.id)).is_equal([&"glide", &"strike_jab", &"snare"])      # empty slots drop out
	assert_str(MonsterBuilder.problem(c, m, true)).is_empty()
	# values outside the ranges are pulled in; a kit needs an active skill; an existing id is refused for a new monster
	var wild := MonsterBuilder.build(c, {"name": "Too Much", "hp": 99, "ap": 9, "reach": 0, "skills": ["immovable"]})
	assert_array([wild.hp, wild.ap, wild.reach]).is_equal([10, 5, 2])
	assert_str(MonsterBuilder.problem(c, wild, true)).contains("active")
	assert_str(MonsterBuilder.problem(c, MonsterBuilder.build(c, {"name": "Nothing"}), true)).contains("at least one skill")
	assert_str(MonsterBuilder.problem(c, MonsterBuilder.build(c, {"name": "Blaze Tiger", "skills": ["run"]}), true)).contains("exists")
	# changing an existing monster keeps its id and status
	var tiger: MonsterDef = c.monster(&"blaze_tiger").duplicate()
	var changed := MonsterBuilder.build(c, {"name": "Blaze Tiger", "hp": 6, "skills": ["run", "strike_jab"]}, tiger)
	assert_str(changed.id).is_equal("blaze_tiger")
	assert_str(changed.content_status).is_equal(c.monster(&"blaze_tiger").content_status)
	assert_int(changed.hp).is_equal(6)
