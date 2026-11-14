extends "res://tools/progression.gd"
## Authored-sheet discovery experiments; resources remain the only content catalogue.

const DISCOVERY_DEFAULT := "base,mist_step,receding_blow,cloudstep_token,raise_reed_screen,open,screens,split,split_mist,split_cloud"
const CANDIDATES := ["mist_step", "receding_blow", "cloudstep_token", "raise_reed_screen"]
const DISCOVERY_EXTRA := ",both_mist,both_cloud,both_screen,mist_control,split_mist_control,single_vein"


func _run() -> void:
	var parsed := Cli.parse(["help", "self-test"], ["help", "self-test", "seeds", "pairs", "bot", "current-ap", "scenarios"])
	if parsed.error != "":
		_fail(parsed.error)
		return
	var opt: Dictionary = parsed.opt
	if opt.has("help"):
		print("discovery.gd --seeds 501,502 --pairs 4 --bot greedy --current-ap 1|2 (default 2, explicit candidate, not game defaults) --scenarios " + DISCOVERY_DEFAULT + DISCOVERY_EXTRA + " --self-test")
		quit()
		return
	if opt.has("self-test"):
		_self_test()
		return
	var seed_text := String(opt.get("seeds", "501,502"))
	var seeds := Cli.ints(seed_text)
	var pair_text := String(opt.get("pairs", "4"))
	var bot := String(opt.get("bot", "greedy"))
	var ap_text := String(opt.get("current-ap", "2"))
	var scenario_text := String(opt.get("scenarios", DISCOVERY_DEFAULT))
	var scenarios := Cli.names(scenario_text)
	if not parsed.pos.is_empty() or seeds.is_empty() or seeds.size() != seed_text.split(",").size() or not pair_text.is_valid_int() or pair_text.to_int() < 1 or not Bots.NAMES.has(bot) or not ap_text in ["1", "2"] or scenarios.is_empty() or scenarios.size() != scenario_text.split(",").size():
		_fail("Invalid discovery arguments; see --help")
		return
	var seen := {}
	for value in seeds:
		if value < 1 or seen.has(value):
			_fail("Seeds must be positive and unique")
			return
		seen[value] = true
	var results := {}
	for name in scenarios:
		if not Cli.names(DISCOVERY_DEFAULT + DISCOVERY_EXTRA).has(name) or results.has(name):
			_fail("Unknown or duplicate scenario: " + name)
			return
		results[name] = _aggregate()
	BattleExperiment.reset()
	var before := _guard()
	print("# Authored discovery experiment\nAP/TPR/HP/Init/Movement/Reach are authored, full HP, no entry proxy. current-ap=%s is an explicit bilateral ZONE PUSH/PULL candidate (including Bog), NOT normal defaults. All skills use duplicate_deep ALL. Subject A is scored after both side swaps. No prices/budgets asserted." % ap_text)
	print("Harness own SHA256=%s; parent SHA256=%s; content=%s; new resource hashes=%s; Godot=%s" % [FileAccess.get_sha256("res://tools/discovery.gd"), _source_hash(), before.content, _pairs(before.resources), Engine.get_version_info().string])
	print("Maps: base uses canonical RUNNER seeded board. open removes every preplaced prop without aftermath, retains grounds/veins. screens replaces props with exactly two point-mirrored reed_screen pairs. split first relocates veins (1,3),(3,3),(5,3) -> (1,2),(3,3),(5,4), then uses the same screen generator. split_mist/cloud also replace subject movement. Props block movement only; NO ranged cover. No starter grass is added. Map RNG is local, seeded with setup seed; play/setup RNG is untouched by edits.")
	print("single_vein: remove only the two outer Dragon Veins after canonical setup, retaining the centre (3,3), all props, starts and RNG state. No candidate skills or stats change; maps affect both teams. The standard generator still runs first so prop availability cannot confound the count comparison.")
	print("Eligibility: first MOVE for mist/cloud; first positive-damage Jab with no board ops for receding, preserving kin_effect. Winged already retreats: retreat flag does not stack. Screen: first pure CREATE_PROP placement, else first GROUND, else last slot; no extra slots. Only subject changes except both_*. Both teams receive map edits. Schedule: same draw-A/draw-B-excluding-A/setup-seed progression scheme; fresh setup RNG each scenario/swap, divergent play may consume different RNG draws.")
	print("Ablation metadata: mist_control [no trail] / split_mist_control [no trail] replace the same first subject MOVE with a local deep copy of mist_step, clearing ONLY board_ops. Same 2 AP walk/profile; no trail or zone effect. split_mist_control uses identical split geometry. Candidate ID remains mist_step: usage/fielded-slot and round counts in these scenarios count the no-trail CONTROL, not zone-producing Mist Step.")
	var schedule: PackedStringArray = []
	print("\n| Seed | Pair | Subject A | Opponent B | Setup seed |\n|---|---|---|---|---|")
	for value in seeds:
		var draw_rng := RandomNumberGenerator.new()
		draw_rng.seed = value
		for pair in pair_text.to_int():
			var a := BattleSetup.random_enemy([], 3, draw_rng)
			var b := BattleSetup.random_enemy(a, 3, draw_rng)
			var setup_seed := draw_rng.randi_range(1, 1 << 30)
			if a.size() != 3 or b.size() != 3:
				_fail("Need two disjoint teams of three")
				return
			var row := "%d | %d | %s | %s | %d" % [value, pair + 1, _ids(a), _ids(b), setup_seed]
			schedule.append(row)
			print("| " + row + " |")
			for name in scenarios:
				var agg: Dictionary = results[name]
				for swap in 2:
					var subject := _team(a, name, true, ap_text.to_int(), agg)
					var opponent := _team(b, name, false, ap_text.to_int(), agg)
					var rng := RandomNumberGenerator.new()
					rng.seed = setup_seed
					var made := Runner.make_battle(&"3v3", [subject, opponent] if swap == 0 else [opponent, subject], "seeded", rng)
					if made.error != "":
						_fail(made.error)
						return
					var battle: Battle = made.battle
					var error := _map(battle, name, setup_seed)
					if error != "":
						_fail(error)
						return
					agg.maps[_geometry(battle).sha256_text()] = true
					var outcome := Runner.play(battle, [bot, bot], rng)
					_record(agg, battle, outcome, swap)
					_discovery_record(agg, battle)
	print("Schedule SHA256=" + "\n".join(schedule).sha256_text())
	if before != _guard():
		_fail("INVALID MEASUREMENT: content/resources changed")
		return
	_report(scenarios, results)
	print("\n## Discovery diagnostics (both teams pooled)\nNo-own-turn = defeat after FIRST positive damage without a subsequent turn_started for that victim; prior turns do not count. Descriptive response-window metric, NOT an unfairness verdict. Candidate counts are activations/actual fielded slots, not successful effects. Round counts use event round_started. Map fingerprints cover pre-begin grounds/props, excluding units. Parent unilateral class label does not apply to map-only scenarios: maps affect both teams.")
	print("| Scenario | Eligible/unchanged units | Applied slots | Species old→new ledger | No-own-turn defeats/battles | Candidate uses/fielded slots | Candidate activations by round | Battles using candidate | Well/flank HP damage | Map SHA256s |\n|---|---|---|---|---|---|---|---|---|---|")
	for name in scenarios:
		var d: Dictionary = results[name]
		print("| %s | %d/%d | %d | %s | %d/%d | %s | %s | %d/%d | %d/%d | %s |" % [name, d.eligible, d.unchanged, d.applied, _pairs(d.ledger), d.no_response, d.no_response_games, _pairs(d.candidate), _pairs(d.by_round), d.used_games, d.games, d.well, d.flank, _pairs(d.maps)])
	print("DISCOVERY_MEASUREMENT_COMPLETED: final guard matches startup content=%s resources=%s" % [before.content, _pairs(before.resources)])
	quit()


func _aggregate() -> Dictionary:
	var out := super._aggregate()
	out.merge({"eligible": 0, "unchanged": 0, "applied": 0, "ledger": {}, "no_response": 0, "no_response_games": 0, "candidate": {}, "by_round": {}, "used_games": 0, "well": 0, "flank": 0, "maps": {}})
	return out


func _candidate(scenario: String) -> String:
	match scenario:
		"both_mist", "split_mist", "mist_control", "split_mist_control": return "mist_step"
		"both_cloud", "split_cloud": return "cloudstep_token"
		"both_screen": return "raise_reed_screen"
	return scenario if scenario in CANDIDATES else ""


func _slot(skills: Array[BattleSkillDef], id: String) -> int:
	for i in skills.size():
		var s := skills[i]
		if id in ["mist_step", "cloudstep_token"] and s.kind == BattleSkillDef.MOVE:
			return i
		if id == "receding_blow" and s.kind == BattleSkillDef.STRIKE and s.strike_damage > 0 and s.strike_shape == "jab" and s.board_ops.is_empty():
			return i
		if id == "raise_reed_screen" and s.kind == BattleSkillDef.GROUND and not s.board_ops.is_empty():
			var pure := true
			for op in s.board_ops:
				pure = pure and op.op == BoardOp.CREATE_PROP
			if pure:
				return i
	if id == "raise_reed_screen":
		for i in skills.size():
			if skills[i].kind == BattleSkillDef.GROUND:
				return i
		return skills.size() - 1
	return -1


func _team(ids: Array[StringName], scenario: String, subject: bool, current_ap: int, agg: Dictionary) -> Array:
	var out: Array = []
	var candidate := _candidate(scenario) if subject or scenario.begins_with("both_") else ""
	for id in ids:
		var sheet := UnitSheets.from_instance(MonsterInstance.of_species(BattleSetup.load_def(id)))
		sheet.current_hp = -1
		var copies: Array[BattleSkillDef] = []
		for original in sheet.skills:
			var skill := original.duplicate_deep(Resource.DEEP_DUPLICATE_ALL) as BattleSkillDef
			if _current_skill(skill):
				skill.ap_cost = current_ap
			copies.append(skill)
		var slot := _slot(copies, candidate) if candidate != "" else -1
		if slot >= 0:
			agg.eligible += 1
			var old := copies[slot]
			var replacement := BattleContent.shared().skill(StringName(candidate)).duplicate_deep(Resource.DEEP_DUPLICATE_ALL) as BattleSkillDef
			if candidate == "receding_blow":
				replacement.kin_effect = old.kin_effect
			var control := scenario in ["mist_control", "split_mist_control"]
			if control:
				replacement.board_ops.clear()
			copies[slot] = replacement
			agg.applied += 1
			var key := "%s %s→%s%s" % [id, old.id, replacement.id, " [no trail]" if control else ""]
			agg.ledger[key] = int(agg.ledger.get(key, 0)) + 1
		else:
			agg.unchanged += 1
		sheet.skills = copies
		var affordable := 0
		var move := false
		var attack := false
		for skill in copies:
			if not skill.is_active():
				continue
			agg.active += 1
			agg.slots[skill.id] = int(agg.slots.get(skill.id, 0)) + 1
			if skill.cost() <= sheet.ap:
				affordable += 1
				move = move or skill.kind == BattleSkillDef.MOVE
				attack = attack or (skill.kind == BattleSkillDef.STRIKE and skill.strike_damage > 0)
			else:
				agg.unaffordable[skill.id] = int(agg.unaffordable.get(skill.id, 0)) + 1
		agg.affordable += affordable
		agg.noactive += int(affordable == 0)
		agg.units += 1
		agg.move += int(move)
		agg.attack += int(attack)
		out.append(sheet)
	return out


func _legal_screen(b: Battle, p: Vector2i) -> bool:
	if not b.board.in_bounds(p) or b.any_unit_at(p) != null or BattleBoards.in_start_area(&"3v3", p, 0) or BattleBoards.in_start_area(&"3v3", p, 1):
		return false
	if b.board.at(p).ground == GroundDef.WELL:
		return false
	for q in b.board.neighbors(p):
		if b.board.at(q).ground == GroundDef.WELL:
			return false
	return true


func _map(b: Battle, scenario: String, setup_seed: int) -> String:
	if scenario == "single_vein":
		var centre := Vector2i(b.board.size >> 1, b.board.size >> 1)
		for cell in b.board.cells:
			if cell.ground == GroundDef.WELL and cell.pos != centre:
				cell.ground = GroundDef.PLAIN
				cell.level = 1
				cell.owner_side = -1
		if b.board.at(centre).ground != GroundDef.WELL:
			return "single_vein requires a canonical centre Dragon Vein"
		return ""
	if scenario not in ["open", "screens", "split", "split_mist", "split_cloud", "split_mist_control"]:
		return ""
	for prop in b.board.props():
		b.board.remove_prop(prop)
	if scenario == "open":
		return ""
	if scenario.begins_with("split"):
		for cell in b.board.cells:
			if cell.ground == GroundDef.WELL:
				cell.ground = GroundDef.PLAIN
				cell.level = 1
		for p in [Vector2i(1, 2), Vector2i(3, 3), Vector2i(5, 4)]:
			b.board.at(p).ground = GroundDef.WELL
			b.board.at(p).level = 1
	var free: Array[Vector2i] = []
	for cell in b.board.cells:
		var p := cell.pos
		var twin := b.board.mirrored(p)
		if p < twin and _legal_screen(b, p) and _legal_screen(b, twin):
			free.append(p)
	var rng := RandomNumberGenerator.new()
	rng.seed = setup_seed
	for i in range(free.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var temp := free[i]
		free[i] = free[j]
		free[j] = temp
	# Exhaustive finite pair search: prefer no adjacency anywhere, fall back only if impossible.
	for separated in [true, false]:
		for i in free.size():
			for j in range(i + 1, free.size()):
				var positions := [free[i], b.board.mirrored(free[i]), free[j], b.board.mirrored(free[j])]
				var valid := true
				for x in 4:
					for y in range(x + 1, 4):
						if separated and Board.chebyshev(positions[x], positions[y]) <= 1:
							valid = false
				if valid:
					for p in positions:
						b.add_prop(&"reed_screen", p)
					return ""
	return "Cannot fit exactly two legal mirrored screen pairs for seed %d" % setup_seed


func _geometry(b: Battle) -> String:
	var rows: PackedStringArray = []
	for c in b.board.cells:
		rows.append("%s:%s:%d:%s" % [c.pos, c.ground, c.level, c.prop.def.id if c.prop != null else &""])
	return ";".join(rows)


func _discovery_record(agg: Dictionary, b: Battle) -> void:
	var hit := {}
	var responded := {}
	var round_number := 0
	var used := false
	var unanswered := false
	var uses := {}
	var slots := {}
	for u: BattleUnit in b.units.values():
		for skill in u.sheet.skills:
			if String(skill.id) in CANDIDATES:
				slots[skill.id] = int(slots.get(skill.id, 0)) + 1
	for e: Dictionary in b.events:
		match e.type:
			&"round_started": round_number += 1
			&"turn_started":
				if hit.has(e.who): responded[e.who] = true
			&"damage":
				if int(e.amount) > 0: hit[e.target] = true
				if e.kind == BattleDamage.WELL: agg.well += int(e.amount)
				if e.kind == BattleDamage.FLANK: agg.flank += int(e.amount)
			&"defeated":
				if hit.has(e.who) and not responded.has(e.who):
					agg.no_response += 1
					unanswered = true
		if e.type not in [&"cast", &"strike", &"moved"] or not e.has("skill"):
			continue
		var key := String(e.skill)
		if e.type == &"moved":
			for skill in b.units[e.who].sheet.skills:
				if skill.kind == BattleSkillDef.MOVE and skill.display_name == key:
					key = String(skill.id)
					break
		if key in CANDIDATES:
			used = true
			uses[key] = int(uses.get(key, 0)) + 1
			var by_round := "%s/r%d" % [key, round_number]
			agg.by_round[by_round] = int(agg.by_round.get(by_round, 0)) + 1
	for id in slots:
		var tally: Array = agg.candidate.get(id, [0, 0])
		tally[0] += int(uses.get(String(id), 0))
		tally[1] += int(slots[id])
		agg.candidate[id] = tally
	agg.used_games += int(used)
	agg.no_response_games += int(unanswered)


func _guard() -> Dictionary:
	var hashes := {}
	for id in CANDIDATES:
		hashes[id] = FileAccess.get_sha256("res://data/skills/%s.tres" % id)
	hashes.reed_screen = FileAccess.get_sha256("res://data/props/reed_screen.tres")
	var memory := {}
	for id in CANDIDATES:
		memory[id] = _snapshot(BattleContent.shared().skill(StringName(id)))
	memory.reed_screen = _snapshot(BattleContent.shared().prop(&"reed_screen"))
	return {"content": BattleContent.shared().fingerprint(), "resources": hashes, "memory": memory}


func _self_test() -> void:
	BattleExperiment.reset()
	var before := _guard()
	for id in CANDIDATES:
		var skill := BattleContent.shared().skill(StringName(id))
		_check(skill != null and skill.content_status == "simulation" and not ContentStatus.in_game(skill), "actual simulation skill " + id)
	_check(BattleContent.shared().prop(&"reed_screen").content_status == "simulation", "simulation prop")
	var ids: Array[StringName] = GameData.monster_ids()
	for ap in [1, 2]:
		for name in CANDIDATES:
			var agg := _aggregate()
			var sheets := _team(ids, name, true, ap, agg)
			var peers := _team(ids, "base", false, ap, _aggregate())
			for i in ids.size():
				var s: UnitSheet = sheets[i]
				var authored := UnitSheets.from_instance(MonsterInstance.of_species(BattleSetup.load_def(ids[i])))
				for stat in ["hp", "initiative", "movement", "reach", "ap", "tpr"]:
					_check(s.get(stat) == authored.get(stat), "authored " + stat)
				var expected := _slot(authored.skills, name)
				_check(s.skills.size() == authored.skills.size() and s.skills.size() <= 4, "no extra slots")
				var changes := 0
				for k in s.skills.size():
					var skill: BattleSkillDef = s.skills[k]
					changes += int(skill.id != authored.skills[k].id)
					if _current_skill(peers[i].skills[k]):
						_check(peers[i].skills[k].ap_cost == ap, "bilateral current family cost")
					if k != expected:
						_check(skill.id == authored.skills[k].id, "unchanged non-target slot")
					elif name == "receding_blow":
						_check(skill.kin_effect == authored.skills[k].kin_effect, "preserved Kin flag")
					for op_index in skill.board_ops.size():
						var source := BattleContent.shared().skill(skill.id)
						_check(skill.board_ops[op_index] != source.board_ops[op_index], "nested BoardOp isolated")
					_check((String(skill.id) == name) == (k == expected), "deterministic eligibility")
					_check(skill != authored.skills[k] and skill != peers[i].skills[k], "skill copy isolation")
					if skill.zone != null:
						_check(skill.zone != authored.skills[k].zone and skill.zone != peers[i].skills[k].zone, "external zone isolated")
						for effect_index in skill.zone.effects.size():
							_check(skill.zone.effects[effect_index] != authored.skills[k].zone.effects[effect_index], "external zone effect isolated")
						var saved: Variant = _snapshot(authored.skills[k].zone)
						skill.zone.effects.clear()
						_check(_snapshot(authored.skills[k].zone) == saved, "zone mutation isolated")
				_check(changes == int(expected >= 0), "exact replacement count")
	for setup_seed in range(1, 51):
		for name in ["screens", "split"]:
			var rng := RandomNumberGenerator.new()
			rng.seed = setup_seed
			var a := _team(ids.slice(0, 3), "base", true, 2, _aggregate())
			var b := _team(ids.slice(0, 3), "base", false, 2, _aggregate())
			var made := Runner.make_battle(&"3v3", [a, b], "seeded", rng)
			_check(made.error == "", "canonical setup")
			var battle: Battle = made.battle
			var state := rng.state
			var occupants := battle.board.occupants.duplicate(true)
			_check(_map(battle, name, setup_seed) == "", "map fit")
			_check(rng.state == state and battle.board.occupants == occupants, "no RNG/occupancy changes")
			_check(battle.board.props().size() == 4, "exactly four props")
			var wells := 0
			for cell in battle.board.cells:
				if cell.ground == GroundDef.WELL:
					wells += 1
					_check(battle.board.at(battle.board.mirrored(cell.pos)).ground == GroundDef.WELL, "mirrored vein")
				if BattleBoards.in_start_area(&"3v3", cell.pos, 0) or BattleBoards.in_start_area(&"3v3", cell.pos, 1):
					_check(cell.ground == GroundDef.PLAIN, "plain starters")
			_check(wells == 3, "three veins")
			for prop in battle.board.props():
				_check(_legal_screen(battle, prop.pos) and battle.board.prop_at(battle.board.mirrored(prop.pos), Board.GROUND) != null and prop.def.id == &"reed_screen", "legal mirrored screen")
			var geometry := _geometry(battle)
			_check(_map(battle, name, setup_seed) == "" and _geometry(battle) == geometry, "reproducible map")
	_ablation_self_test(ids)
	_single_vein_self_test(ids)
	_action_fixtures()
	_check(before == _guard(), "source guard unchanged")
	print("Discovery self-test: %d passed / %d failed; no bot series; deterministic action fixtures only" % [_test_passes, _test_failures])
	quit(1 if _test_failures else 0)


func _ablation_self_test(ids: Array[StringName]) -> void:
	var before := _guard()
	for ap in [1, 2]:
		for name in ["mist_control", "split_mist_control"]:
			var agg := _aggregate()
			var control := _team(ids, name, true, ap, agg)
			var trail_agg := _aggregate()
			var trail := _team(ids, "mist_step", true, ap, trail_agg)
			var opponent := _team(ids, name, false, ap, _aggregate())
			var base := _team(ids, "base", false, ap, _aggregate())
			_check(agg.eligible == trail_agg.eligible and agg.applied == trail_agg.applied and agg.unchanged == trail_agg.unchanged, "control same replacement eligibility/counts")
			for key: String in agg.ledger:
				_check(key.ends_with(" [no trail]"), "control ledger explicitly labelled")
			for i in ids.size():
				var c: UnitSheet = control[i]
				var t: UnitSheet = trail[i]
				for stat in ["hp", "initiative", "movement", "reach", "ap", "tpr", "current_hp"]:
					_check(c.get(stat) == t.get(stat), "control equal stats " + stat)
				_check(c.skills.size() == t.skills.size(), "control same slot count")
				for k in c.skills.size():
					var snapshot: Dictionary = _snapshot(t.skills[k])
					if t.skills[k].id == &"mist_step":
						_check(not t.skills[k].board_ops.is_empty() and c.skills[k].board_ops.is_empty(), "only control lacks board ops")
						_check(c.skills[k].cost() == 2 and c.skills[k].cost() == t.skills[k].cost() and BattleMoves.profile_of(c.skills[k]) == BattleMoves.profile_of(t.skills[k]), "control exact 2 AP movement profile")
						snapshot.board_ops = []
					_check(_snapshot(c.skills[k]) == snapshot, "control changes ONLY board_ops, retains candidate ID")
					_check(_snapshot(opponent[i].skills[k]) == _snapshot(base[i].skills[k]), "control does not alter opponent")
	var b := _fixture([], Vector2i(1, 6), Vector2i(5, 0))
	BattleBoards.place_wells(b)
	_check(_map(b, "split_mist", 501) == "", "trail split map builds")
	var geometry := _geometry(b)
	_check(_map(b, "split_mist_control", 501) == "" and _geometry(b) == geometry, "control identical split geometry")
	_check(before == _guard(), "ablation leaves source content/resources unchanged")


func _single_vein_self_test(ids: Array[StringName]) -> void:
	for setup_seed in range(1, 21):
		var rng := RandomNumberGenerator.new()
		rng.seed = setup_seed
		var a := _team(ids.slice(0, 3), "base", true, 2, _aggregate())
		var c := _team(ids.slice(0, 3), "base", false, 2, _aggregate())
		var made := Runner.make_battle(&"3v3", [a, c], "seeded", rng)
		var b: Battle = made.battle
		var state := rng.state
		var occupants := b.board.occupants.duplicate(true)
		var props: PackedStringArray = []
		for prop in b.board.props():
			props.append("%s:%s" % [prop.pos, prop.def.id])
		_check(_map(b, "single_vein", setup_seed) == "", "single vein map accepted")
		var after: PackedStringArray = []
		for prop in b.board.props():
			after.append("%s:%s" % [prop.pos, prop.def.id])
		_check(props == after and rng.state == state and b.board.occupants == occupants, "single vein preserves props, RNG and occupants")
		var wells := 0
		for cell in b.board.cells:
			wells += int(cell.ground == GroundDef.WELL)
		_check(wells == 1 and b.board.at(Vector2i(3, 3)).ground == GroundDef.WELL, "exactly one central vein")
	var b := _fixture([], Vector2i(3, 3), Vector2i(3, 0))
	BattleBoards.place_wells(b)
	_check(_map(b, "single_vein", 1) == "", "single vein action fixture map")
	b.begin()
	b.end_turn()
	b.end_turn()
	_check(b.round_number == 2 and b.units[&"u1"].hp == 7, "single vein retains touch ownership and exactly one round-end damage")


# Test-only sheets/positions use existing fixtures; candidate definitions always come from data.
func _fixture(skills: Array, start: Vector2i, enemy: Vector2i, overrides: Dictionary = {}) -> Battle:
	var h := preload("res://tests/battle/helpers.gd")
	var options := {"init": 9.0, "skills": [], "hp": 8, "ap": 4}
	options.merge(overrides, true)
	for id in skills:
		options.skills.append(BattleContent.shared().skill(StringName(id)).duplicate_deep(Resource.DEEP_DUPLICATE_ALL))
	return h.battle([[0, start, options], [1, enemy, {"init": 5.0, "hp": 8, "move": 3}]])


func _action_fixtures() -> void:
	var h := preload("res://tests/battle/helpers.gd")
	var passed := _test_passes
	var failed := _test_failures
	var b := _fixture(["mist_step"], Vector2i(1, 3), Vector2i(1, 2))
	b.begin()
	_check(b.apply({"type": &"skill", "slot": 0, "to": Vector2i(3, 3)}), "mist real move accepted")
	_check(h.unit(b, 0).pos == Vector2i(3, 3) and b.ap == 2, "mist moves and pays 2 AP")
	for p in [Vector2i(1, 3), Vector2i(2, 3)]:
		var zone := b.board.at(p).zone
		_check(zone != null and zone.def.id == &"slowing" and zone.duration == 2, "mist vacated path slowing zone")
	_check(b.board.at(Vector2i(3, 3)).zone == null, "mist landing has no zone")
	_check(b.end_turn() and b.turn_owner == &"u1", "mist enemy gets own turn")
	var movement_before := BattleStats.movement(b, h.unit(b, 1))
	_check(b.apply({"type": &"step", "to": Vector2i(1, 3)}), "enemy walks into actual mist zone")
	_check(BattleStats.movement(b, h.unit(b, 1)) < movement_before and BattleStats.total(b, h.unit(b, 1), FieldEffect.SLOW) > 0, "mist existing Slow reduces enemy effective Movement")
	for kin in [MonsterDef.Kin.BEAST, MonsterDef.Kin.WINGED]:
		b = _fixture(["receding_blow"], Vector2i(3, 3), Vector2i(3, 2), {"kin": kin})
		b.begin()
		_check(b.apply({"type": &"skill", "slot": 0, "dir": Vector2i.UP, "push_dir": Vector2i.UP}), "receding real strike accepted kin=%d" % kin)
		_check(h.unit(b, 1).hp == 6 and h.unit(b, 1).pos == Vector2i(3, 1), "receding exactly 2 damage and target push kin=%d" % kin)
		_check(h.unit(b, 0).pos == Vector2i(3, 4) and b.ap == 2, "receding exactly one retreat, Winged not doubled kin=%d" % kin)
	b = _fixture(["cloudstep_token"], Vector2i(1, 3), Vector2i(6, 6), {"ap": 1, "move": 2})
	b.add_prop(&"reed_screen", Vector2i(2, 3))
	b.begin()
	var action := {"type": &"skill", "slot": 0, "to": Vector2i(5, 3)}
	_check(b.check(action) == "" and b.check({"type": &"skill", "slot": 0, "to": Vector2i(6, 3)}) != "", "cloud legal Movement+2 boundary at 1 AP")
	_check(b.apply(action) and h.unit(b, 0).pos == Vector2i(5, 3), "cloud crosses prop and lands at Movement+2")
	_check(b.ap == 0 and h.unit(b, 0).sheet.ap == 1 and h.unit(b, 0).used_battle.has(0), "cloud pays 1 AP, no AP bonus, slot recorded")
	h.until_turn_of(b, &"u0")
	var repeat := {"type": &"skill", "slot": 0, "to": Vector2i(4, 3)}
	_check(b.turn_owner == &"u0" and b.ap == 1 and b.check(repeat).contains("already used this battle"), "cloud second attempt rejected despite refreshed affordable AP")
	var pos := h.unit(b, 0).pos
	_check(not b.apply(repeat) and h.unit(b, 0).pos == pos and b.ap == 1, "cloud rejected repeat changes neither position nor AP")
	b = _fixture(["raise_reed_screen", "receding_blow"], Vector2i(3, 3), Vector2i(6, 6))
	var cell := b.board.at(Vector2i(3, 2))
	b.set_ground(cell.pos, &"rubble", 1)
	var ground_before := [cell.ground, cell.level, cell.ground_until]
	b.begin()
	_check(b.apply({"type": &"skill", "slot": 0, "anchor": cell.pos}), "screen real placement accepted")
	_check(cell.prop != null and cell.prop.def.id == &"reed_screen" and cell.prop.hp == 1 and b.ap == 3, "screen creates actual 1 HP prop for 1 AP")
	_check(not b.apply({"type": &"step", "to": cell.pos}) and h.unit(b, 0).pos == Vector2i(3, 3) and b.ap == 3, "screen blocks ordinary Step without spending AP")
	var event_start := b.events.size()
	_check(b.apply({"type": &"skill", "slot": 1, "dir": Vector2i.UP}), "real strike destroys screen")
	_check(cell.prop == null and b.board.props().is_empty() and [cell.ground, cell.level, cell.ground_until] == ground_before, "screen destruction leaves ground unchanged, no spawned prop")
	var aftermath := false
	for e: Dictionary in b.events.slice(event_start):
		aftermath = aftermath or e.type in [&"ground_changed", &"zone_changed", &"prop_placed"] or (e.type == &"damage" and e.kind == BattleDamage.AFTERMATH)
	_check(not aftermath and h.unit(b, 0).hp == 8 and h.unit(b, 1).hp == 8, "screen destruction has no aftermath effects")
	# Centre is a positive control for the same end-turn sequence on the split map.
	for vein in [Vector2i(1, 2), Vector2i(3, 3), Vector2i(5, 4)]:
		b = _fixture([], vein + Vector2i.DOWN, Vector2i(3, 0))
		BattleBoards.place_wells(b)
		_check(_map(b, "split", 501) == "", "split real fixture map fits")
		b.begin()
		_check(b.board.at(vein).owner_side == -1 and b.apply({"type": &"step", "to": vein}) and b.board.at(vein).owner_side == 0, "split walking onto vein captures ownership %s" % vein)
		_check(b.apply({"type": &"step", "to": vein + Vector2i.DOWN}), "split owner walks off vein")
		h.until_turn_of(b, &"u0")
		var well_damage := 0
		for e: Dictionary in b.events:
			if e.type == &"damage" and e.kind == BattleDamage.WELL and e.target == &"u1":
				well_damage += int(e.amount)
		_check(b.round_number == 2 and h.unit(b, 1).hp == 7 and well_damage == 1, "split round-end vein %s: expected round=2/HP=7/well=1, got %d/%d/%d (failure blocks split measurements)" % [vein, b.round_number, h.unit(b, 1).hp, well_damage])
	print("Real-action fixtures: %d passed / %d failed (not full skill-gameplay validation)" % [_test_passes - passed, _test_failures - failed])
