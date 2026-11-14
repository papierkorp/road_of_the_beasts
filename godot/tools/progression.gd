extends SceneTree
## Paired, teamwide interventions; no content edits, prices or progression rules.

const Runner := preload("res://tools/lib/sim_runner.gd")
const Bots := preload("res://tools/lib/sim_bots.gd")
const Cli := preload("res://tools/lib/cli.gd")
const DEFAULT_SCENARIOS := "base,hp,initiative,movement,reach,ap,tpr,strike_ground,hp_ap,hp_tpr,ap_tpr,ap_tpr_ground,both_ap_tpr,both_ap_tpr_ground"
const SCENARIOS := DEFAULT_SCENARIOS + ",both_hp,both_ap,both_tpr,both_strike_ground,both_hp_ap,both_hp_tpr,both_hp_ap_tpr,both_hp_ap_tpr_ground"
const CAPS := {"hp": 10, "initiative": 10, "movement": 5, "reach": 4, "ap": 5, "tpr": 3}


func _initialize() -> void:
	call_deferred("_run")


func _fail(message: String) -> void:
	printerr(message)
	quit(1)


func _run() -> void:
	var parsed := Cli.parse(["help", "self-test"], ["help", "self-test", "seeds", "pairs", "bot", "current-ap", "scenarios"])
	if parsed.error != "":
		_fail(parsed.error)
		return
	var opt: Dictionary = parsed.opt
	if opt.has("help"):
		print("godot --headless --path godot -s res://tools/progression.gd -- --seeds 401,402 --pairs 4 --bot greedy --current-ap 1 --scenarios " + DEFAULT_SCENARIOS)
		print("Allowed scenarios: " + SCENARIOS)
		print("--self-test: isolated sheet/resource assertions only; no battles")
		quit()
		return
	if opt.has("self-test"):
		_self_test()
		return
	var seed_text := String(opt.get("seeds", "401,402"))
	var seeds := Cli.ints(seed_text)
	var pair_text := String(opt.get("pairs", "4"))
	var bot := String(opt.get("bot", "greedy"))
	var current_text := String(opt.get("current-ap", "1"))
	var scenario_text := String(opt.get("scenarios", DEFAULT_SCENARIOS))
	var scenarios := Cli.names(scenario_text)
	if not parsed.pos.is_empty() or seeds.is_empty() or seed_text.split(",").size() != seeds.size() \
			or not pair_text.is_valid_int() or pair_text.to_int() < 1 \
			or not current_text in ["1", "2"] or not Bots.NAMES.has(bot) or scenarios.is_empty() \
			or scenario_text.split(",").size() != scenarios.size():
		_fail("Expected positive --seeds / --pairs, known --bot, --current-ap 1|2 and nonempty --scenarios; no positional arguments")
		return
	var seen_seeds := {}
	for seed_value in seeds:
		if seed_value < 1 or seen_seeds.has(seed_value):
			_fail("Seeds must be positive and unique")
			return
		seen_seeds[seed_value] = true
	var results := {}
	for name in scenarios:
		if not Cli.names(SCENARIOS).has(name) or results.has(name):
			_fail("Unknown or duplicate scenario: " + name)
			return
		results[name] = _aggregate()
	BattleExperiment.reset()
	var source_fingerprint := BattleContent.shared().fingerprint()
	print("# Progression intervention experiment")
	print("\nCommand: `godot --headless --path godot -s res://tools/progression.gd -- --seeds %s --pairs %s --bot %s --current-ap %s --scenarios %s`" % [seed_text, pair_text, bot, current_text, scenario_text])
	print("\nHarness SHA-256 (current progression.gd only; not a full engine/source fingerprint): `%s`; content `%s`; Godot `%s`." % [_source_hash(), source_fingerprint, Engine.get_version_info().string])
	print("\n**Entry action-economy proxy, not approved starting monster/frame/budget/stage.** Every fresh reference sheet: AP=2, TPR=1, authored HP/Initiative/Movement/Reach/kit, full HP. GameData's in-game pool includes user content (including asdf if in-game); no curated exclusions. Prices remain working values; no stat-price or budget assertions.")
	print("Uniform teamwide interventions, not single-monster odds or equal-cost allocations. Unilateral scenarios upgrade all three subject A members; both_* upgrades all six and is bilateral escalation, NOT unilateral value. Stat increments +1 capped at HP/Init 10, Movement/AP 5, Reach 4, TPR 3; never lower an already over-cap authored value. strike_ground: proposed content variant, NOT an approved slot choice; append existing Thornbed only to damaging STRIKE slots with NO ground BoardOp, preserving existing ground, AP, damage, shape and all other fields. current-ap matches sim.gd currentap: any in-game ZONE with PUSH or PULL, including mixed-effect zones such as Bog, on both teams using local deep copies.")
	print("\n3v3 seeded boards, mirrored placement, two full-team side swaps per seed/pair, same bot both sides. Each seed owns a draw RNG: draw A, then B excluding A, then setup seed; reset a fresh run RNG to that setup seed for EVERY scenario/swap. Play RNG continues after identical setup draws; divergent actions need not consume identical random draws. Guard: %d bot turns." % Runner.MAX_TURNS)
	print("\n## Source roster (authored stats; before proxy)\n\n| ID | HP/Init/Move/Reach/AP/TPR | Kit ID:effective cost |\n|---|---|---|")
	for id in GameData.monster_ids():
		var sheet := UnitSheets.from_instance(MonsterInstance.of_species(BattleSetup.load_def(id)))
		var kit: PackedStringArray = []
		for skill in sheet.skills:
			kit.append("%s:%d" % [skill.id, skill.cost()])
		print("| %s | %s/%s/%s/%s/%s/%s | %s |" % [id, sheet.hp, sheet.initiative, sheet.movement, sheet.reach, sheet.ap, sheet.tpr, ", ".join(kit)])
	print("\n## Canonical draw schedule\n\n| Seed | Pair | Subject A | Opponent B | Setup seed |\n|---|---|---|---|---|")
	for seed_value in seeds:
		var draw_rng := RandomNumberGenerator.new()
		draw_rng.seed = seed_value
		for pair in pair_text.to_int():
			var a := BattleSetup.random_enemy([], 3, draw_rng)
			var b := BattleSetup.random_enemy(a, 3, draw_rng)
			var setup_seed := draw_rng.randi_range(1, 1 << 30)
			if a.size() != 3 or b.size() != 3:
				_fail("In-game pool cannot provide two disjoint teams of three")
				return
			print("| %d | %d | %s | %s | %d |" % [seed_value, pair + 1, _ids(a), _ids(b), setup_seed])
			for name in scenarios:
				var agg: Dictionary = results[name]
				for swap in 2:
					var subject := _team(a, name, true, current_text.to_int(), agg)
					var opponent := _team(b, name, false, current_text.to_int(), agg)
					var rng := RandomNumberGenerator.new()
					rng.seed = setup_seed
					var made := Runner.make_battle(&"3v3", [subject, opponent] if swap == 0 else [opponent, subject], "seeded", rng)
					if made.error != "":
						_fail(made.error)
						return
					var battle: Battle = made.battle
					var outcome := Runner.play(battle, [bot, bot], rng)
					_record(agg, battle, outcome, swap)
	var final_fingerprint := BattleContent.shared().fingerprint()
	if final_fingerprint != source_fingerprint:
		_fail("INVALID MEASUREMENT: source content fingerprint changed: %s -> %s" % [source_fingerprint, final_fingerprint])
		return
	_report(scenarios, results)
	print("\nPROGRESSION_MEASUREMENT_COMPLETED: final content fingerprint `%s` matches startup `%s`." % [final_fingerprint, source_fingerprint])
	quit()


func _ids(ids: Array[StringName]) -> String:
	return ",".join(PackedStringArray(ids))


func _aggregate() -> Dictionary:
	return {"games": 0, "wins": 0, "losses": 0, "draws": 0, "timeouts": 0, "rounds": 0, "short": 0, "long": 0, "longest": 0,
		"hist": {}, "unacted": 0, "unacted_games": 0, "first_turns": 0, "first_n": 0, "collision": 0, "damage": 0,
		"activations": 0, "repeats": 0, "uses": {}, "slots": {}, "affordable": 0, "active": 0, "noactive": 0,
		"units": 0, "move": 0, "attack": 0, "unaffordable": {}, "deltas": {}, "strike_ground": {}}


func _team(ids: Array[StringName], scenario: String, subject: bool, current_ap: int, agg: Dictionary) -> Array:
	var out: Array = []
	var upgrade := subject or scenario.begins_with("both_")
	var parts := scenario.trim_prefix("both_").split("_")
	for id in ids:
		var sheet := UnitSheets.from_instance(MonsterInstance.of_species(BattleSetup.load_def(id)))
		sheet.ap = 2
		sheet.tpr = 1
		sheet.current_hp = -1
		if upgrade:
			for stat: String in CAPS:
				if not parts.has(stat):
					continue
				_increment(sheet, stat, agg)
		var copies: Array[BattleSkillDef] = []
		for original in sheet.skills:
			var skill := original.duplicate_deep(Resource.DEEP_DUPLICATE_ALL) as BattleSkillDef
			if _current_skill(skill):
				skill.ap_cost = current_ap
			if upgrade and parts.has("ground"):
				_strike_ground(skill, agg)
			copies.append(skill)
		sheet.skills = copies
		var affordable := 0
		var has_move := false
		var has_attack := false
		for skill in copies:
			if not skill.is_active():
				continue
			agg.active += 1
			agg.slots[skill.id] = int(agg.slots.get(skill.id, 0)) + 1
			if skill.cost() <= sheet.ap:
				affordable += 1
				has_move = has_move or skill.kind == BattleSkillDef.MOVE
				has_attack = has_attack or (skill.kind == BattleSkillDef.STRIKE and skill.strike_damage > 0)
			else:
				agg.unaffordable[skill.id] = int(agg.unaffordable.get(skill.id, 0)) + 1
		agg.affordable += affordable
		agg.noactive += int(affordable == 0)
		agg.units += 1
		agg.move += int(has_move)
		agg.attack += int(has_attack)
		out.append(sheet)
	return out


func _current_skill(skill: BattleSkillDef) -> bool:
	return ContentStatus.in_game(skill) and skill.kind == BattleSkillDef.ZONE and skill.zone != null \
		and (skill.zone.has_tag(FieldEffect.PUSH) or skill.zone.has_tag(FieldEffect.PULL))


func _record(agg: Dictionary, battle: Battle, outcome: Dictionary, subject_side: int) -> void:
	agg.games += 1
	if outcome.timeout:
		agg.timeouts += 1
	elif outcome.draw:
		agg.draws += 1
	elif outcome.winner == subject_side:
		agg.wins += 1
	else:
		agg.losses += 1
	var rounds := int(outcome.rounds)
	agg.rounds += rounds
	agg.short += int(rounds < 2)
	agg.long += int(rounds > 5)
	agg.longest = maxi(agg.longest, rounds)
	agg.hist[rounds] = int(agg.hist.get(rounds, 0)) + 1
	var acted := {}
	var turn_uses := {}
	var turns := 0
	var first := false
	var unacted := false
	for event: Dictionary in battle.events:
		match event.type:
			&"round_started":
				turn_uses.clear()
			&"turn_started":
				turns += 1
				acted[event.who] = true
				turn_uses.clear()
			&"defeated":
				if not acted.has(event.who):
					agg.unacted += 1
					unacted = true
				if not first:
					agg.first_turns += turns
					agg.first_n += 1
					first = true
			&"damage":
				agg.damage += int(event.amount)
				if event.kind == BattleDamage.COLLISION:
					agg.collision += int(event.amount)
		if event.type not in [&"surge_declared", &"cast", &"strike", &"moved"] or not event.has("skill"):
			continue
		var key := String(event.skill)
		if event.type == &"moved" and key != "Step":
			var actor: BattleUnit = battle.units[event.who]
			for skill in actor.sheet.skills:
				if skill.kind == BattleSkillDef.MOVE and skill.display_name == key:
					key = String(skill.id)
					break
		if key == "Step":
			continue
		var identity := "%s/%s" % [event.who, key]
		agg.activations += 1
		agg.repeats += int(turn_uses.has(identity))
		turn_uses[identity] = true
		agg.uses[key] = int(agg.uses.get(key, 0)) + 1
	agg.unacted_games += int(unacted)


func _pairs(values: Dictionary) -> String:
	var keys := values.keys()
	keys.sort()
	var out: PackedStringArray = []
	for key in keys:
		out.append("%s:%s" % [key, values[key]])
	return ", ".join(out) if not out.is_empty() else "—"


func _mean(total: float, count: int) -> String:
	return "%.2f" % (total / count) if count > 0 else "—"


func _report(scenarios: Array[String], results: Dictionary) -> void:
	print("\n## Aggregate\n\nScore=(wins+0.5×true draws)/(games−timeouts); timeouts separate. Rounds include timeout partial rounds; histograms allow exact weighted means. Defeat/damage/activation metrics cover BOTH teams; first-defeat turns count turn_started events through the first defeat, omitting games with none. Collision is collision HP damage (not collision events). Repeat=second/later activation of same actor+skill within one turn, including slotted movement, excluding Step; event fallback matches sim.gd, not distinct slot identity.")
	print("\n| Scenario | Class | Games | A W/L/D/timeout | Score | Mean rounds | <2/>5/max | Pre-first-turn defeats/games | Turns to first defeat (n) | Collision/total damage | Repeats/activations | Round histogram |\n|---|---|---|---|---|---|---|---|---|---|---|---|")
	for name in scenarios:
		var a: Dictionary = results[name]
		print("| %s | %s | %d | %d/%d/%d/%d | %s | %s | %d/%d/%d | %d/%d | %s (%d) | %d/%d | %d/%d (%s) | %s |" % [name, "bilateral" if name.begins_with("both_") else "control" if name == "base" else "unilateral", a.games, a.wins, a.losses, a.draws, a.timeouts, _mean(a.wins + 0.5 * a.draws, a.games - a.timeouts), _mean(a.rounds, a.games), a.short, a.long, a.longest, a.unacted, a.unacted_games, _mean(a.first_turns, a.first_n), a.first_n, a.collision, a.damage, a.repeats, a.activations, _mean(a.repeats, a.activations), _pairs(a.hist)])
	print("\n## Start affordability and actual interventions\n\nBoth teams pooled, repeated per game. Affordability only: cost≤sheet AP, NOT target legality; no assumption that a low-stage kit should be fully affordable. Move/attack counts units with an affordable slotted MOVE/damaging STRIKE (not universal Step). Stat deltas: attempted/applied sum/changed count/cap-blocked count, per upgraded member. strike_ground: eligible damaging STRIKE attempts/applied/not_applied (existing ground); proposed content variant, not an approved slot choice. No rounding of exact counts.")
	print("\n| Scenario | Affordable/active slots | No affordable active/units | Has move/attack | Unaffordable ID:slot count | Stat delta attempted/sum/changed/blocked | strike_ground counts |\n|---|---|---|---|---|---|---|")
	for name in scenarios:
		var a: Dictionary = results[name]
		print("| %s | %d/%d | %d/%d | %d/%d | %s | %s | %s |" % [name, a.affordable, a.active, a.noactive, a.units, a.move, a.attack, _pairs(a.unaffordable), _pairs(a.deltas), _pairs(a.strike_ground)])
	print("\n## Active skill usage\n\nAll equipped active IDs, not just top skills; activations/start slots pooled over both teams and games (not success rates).\n\n| Scenario | ID:activations/start slots |\n|---|---|")
	for name in scenarios:
		var a: Dictionary = results[name]
		var counts := {}
		for id in a.slots:
			counts[id] = "%d/%d" % [int(a.uses.get(String(id), 0)), int(a.slots[id])]
		print("| %s | %s |" % [name, _pairs(counts)])
	print("\nLimitations: small, bot- and roster-dependent teamwide interventions; paired draws are not independent per swap. Not human agency/fun/fairness validation, single-monster causal odds, equal-price comparisons, approved progression or balance/price evidence.")


func _source_hash() -> String:
	return FileAccess.get_sha256("res://tools/progression.gd")


# Shared intervention primitives keep the self-test on the actual _team code path.
func _increment(sheet: UnitSheet, stat: String, agg: Dictionary) -> void:
	var before := float(sheet.get(stat))
	var delta := maxf(0.0, minf(1.0, float(CAPS[stat]) - before))
	sheet.set(stat, before + delta)
	if not agg.deltas.has(stat):
		agg.deltas[stat] = [0, 0.0, 0, 0]
	var tally: Array = agg.deltas[stat]
	tally[0] += 1
	tally[1] += delta
	tally[2] += int(delta > 0)
	tally[3] += int(delta < 1)


func _strike_ground(skill: BattleSkillDef, agg: Dictionary) -> void:
	if skill.kind != BattleSkillDef.STRIKE or skill.strike_damage <= 0:
		return
	if not agg.strike_ground.has("attempted"):
		agg.strike_ground = {"attempted": 0, "applied": 0, "not_applied": 0}
	agg.strike_ground.attempted += 1
	if not skill.has_op(BoardOp.GROUND):
		skill.board_ops.append(BoardOp.make(BoardOp.GROUND, &"thornbed"))
		agg.strike_ground.applied += 1
	else:
		agg.strike_ground.not_applied += 1


var _test_passes := 0
var _test_failures := 0


func _check(condition: bool, label: String) -> void:
	if condition:
		_test_passes += 1
	else:
		_test_failures += 1
		printerr("FAIL: " + label)


# Value snapshots include nested resources, not instance IDs or resource paths.
func _snapshot(value: Variant) -> Variant:
	if value is Resource:
		var fields := {}
		for property in value.get_property_list():
			if int(property.usage) & PROPERTY_USAGE_STORAGE and property.name not in ["script", "resource_path"]:
				fields[property.name] = _snapshot(value.get(property.name))
		return fields
	if value is Array:
		var items: Array = []
		for item in value:
			items.append(_snapshot(item))
		return items
	return value


func _self_test() -> void:
	BattleExperiment.reset()
	var content := BattleContent.shared()
	var fingerprint := content.fingerprint()
	var ids: Array[StringName] = GameData.monster_ids()
	_check(not ids.is_empty(), "in-game roster available")
	var sources := {}
	for id in ids:
		sources[id] = _snapshot(BattleSetup.load_def(id))
	var source_skills := {}
	for id in content.skills:
		source_skills[id] = _snapshot(content.skills[id])
	for current_ap in [1, 2]:
		var base := _team(ids, "base", true, current_ap, _aggregate())
		var peer := _team(ids, "base", false, current_ap, _aggregate())
		var grounded := _team(ids, "strike_ground", true, current_ap, _aggregate())
		for i in ids.size():
			var sheet: UnitSheet = base[i]
			_check(sheet.ap == 2 and sheet.tpr == 1 and sheet.current_hp == -1, "%s baseline AP/TPR/HP" % ids[i])
			var authored := UnitSheets.from_instance(MonsterInstance.of_species(BattleSetup.load_def(ids[i])))
			_check(sheet.hp == authored.hp and sheet.initiative == authored.initiative and sheet.movement == authored.movement and sheet.reach == authored.reach, "%s baseline authored stats" % ids[i])
			for stat: String in CAPS:
				var upgraded: UnitSheet = _team([ids[i]], stat, true, current_ap, _aggregate())[0]
				for field: String in CAPS:
					var expected := float(sheet.get(field))
					if field == stat:
						expected = maxf(expected, minf(expected + 1, CAPS[field]))
					_check(is_equal_approx(float(upgraded.get(field)), expected), "%s %s changes only %s" % [ids[i], stat, field])
			for slot in sheet.skills.size():
				var original: BattleSkillDef = BattleSetup.load_def(ids[i]).skills[slot]
				var skill := sheet.skills[slot]
				var other: BattleSkillDef = peer[i].skills[slot]
				var ground: BattleSkillDef = grounded[i].skills[slot]
				var family := ContentStatus.in_game(original) and original.kind == BattleSkillDef.ZONE and original.zone != null \
					and (original.zone.has_tag(FieldEffect.PUSH) or original.zone.has_tag(FieldEffect.PULL))
				_check(_current_skill(original) == family and skill.ap_cost == (current_ap if family else original.ap_cost), "%s exact current-ap family" % original.id)
				var expected := original.duplicate_deep(Resource.DEEP_DUPLICATE_ALL) as BattleSkillDef
				if family:
					expected.ap_cost = current_ap
				if original.kind == BattleSkillDef.STRIKE and original.strike_damage > 0 and not original.has_op(BoardOp.GROUND):
					expected.board_ops.append(BoardOp.make(BoardOp.GROUND, &"thornbed"))
				_check(_snapshot(ground) == _snapshot(expected), "%s ground variant preserves every other field" % original.id)
				_check(skill != original and skill != other and skill != ground, "%s fresh skill identity" % original.id)
				var original_state: Variant = _snapshot(original)
				var peer_state: Variant = _snapshot(other)
				skill.ap_cost += 7
				for op in skill.board_ops:
					op.ground = &"self_test_only"
				if skill.zone != null and not skill.zone.effects.is_empty():
					skill.zone.effects[0].base += 7
				_check(_snapshot(original) == original_state and _snapshot(other) == peer_state, "%s nested copy isolation" % original.id)
	for stat: String in CAPS:
		for initial in [float(CAPS[stat]) - 1, float(CAPS[stat]), float(CAPS[stat]) + 1]:
			var sheet := UnitSheet.new()
			sheet.set(stat, initial)
			var agg := _aggregate()
			_increment(sheet, stat, agg)
			var delta := 1 if initial < CAPS[stat] else 0
			_check(float(sheet.get(stat)) == initial + delta and agg.deltas[stat] == [1, float(delta), delta, 1 - delta], "%s cap and exact counters at %s" % [stat, initial])
	var family_probe := BattleSkillDef.new()
	family_probe.kind = BattleSkillDef.ZONE
	family_probe.content_status = "experiment"
	family_probe.zone = BattleZoneDef.new()
	family_probe.zone.effects.append(FieldEffect.make(FieldEffect.SLOW))
	_check(not _current_skill(family_probe), "slow-only zone excluded")
	for tag in [FieldEffect.PUSH, FieldEffect.PULL]:
		family_probe.zone.effects.append(FieldEffect.make(tag))
		_check(_current_skill(family_probe), "mixed displacement zone included: " + tag)
		family_probe.zone.effects.pop_back()
	family_probe.zone.effects.append(FieldEffect.make(FieldEffect.PULL))
	family_probe.content_status = "archived"
	_check(not _current_skill(family_probe), "archived displacement zone excluded")
	family_probe.content_status = "experiment"
	family_probe.kind = BattleSkillDef.STRIKE
	_check(not _current_skill(family_probe), "non-zone displacement excluded")
	family_probe.kind = BattleSkillDef.ZONE
	family_probe.zone = null
	_check(not _current_skill(family_probe), "null zone excluded")
	var synthetic := BattleSkillDef.new()
	synthetic.kind = BattleSkillDef.STRIKE
	synthetic.ap_cost = 4
	var synthetic_cost := synthetic.cost()
	var agg := _aggregate()
	_strike_ground(synthetic, agg)
	_strike_ground(synthetic, agg)
	_check(synthetic.ops_of(BoardOp.GROUND).size() == 1 and synthetic.board_ops[0].ground == &"thornbed" and synthetic.ap_cost == 4 and synthetic.cost() == synthetic_cost, "ground appended once; AP preserved")
	_check(agg.strike_ground == {"attempted": 2, "applied": 1, "not_applied": 1}, "ground exact counters")
	for kind in [BattleSkillDef.STRIKE, BattleSkillDef.MOVE]:
		var excluded := BattleSkillDef.new()
		excluded.kind = kind
		excluded.strike_damage = 0 if kind == BattleSkillDef.STRIKE else 2
		_strike_ground(excluded, agg)
		_check(excluded.board_ops.is_empty() and agg.strike_ground.attempted == 2, "exclude zero-damage Strike and non-Strike")
	var existing := BattleSkillDef.new()
	existing.kind = BattleSkillDef.STRIKE
	existing.board_ops.append(BoardOp.make(BoardOp.GROUND, &"plain"))
	var existing_state: Variant = _snapshot(existing)
	_strike_ground(existing, agg)
	_check(_snapshot(existing) == existing_state and agg.strike_ground.not_applied == 2, "existing ground untouched")
	for id in ids:
		_check(_snapshot(BattleSetup.load_def(id)) == sources[id], "%s source resource unchanged" % id)
	for id in content.skills:
		_check(_snapshot(content.skills[id]) == source_skills[id], "%s source skill unchanged" % id)
	_check(content.fingerprint() == fingerprint, "source resource fingerprint unchanged")
	print("Self-test: %d passed, %d failed; no battles played." % [_test_passes, _test_failures])
	quit(1 if _test_failures > 0 else 0)
