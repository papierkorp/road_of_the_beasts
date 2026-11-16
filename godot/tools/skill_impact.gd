extends SceneTree
## Measures what the parts of a skill are worth (temp_todo T02): bot battles between two teams of the same
## monsters whose kits are random (KitDraw templates, skills generated for the battle), every pairing
## played twice with the kits swapped between the sides. Indications for a price list, never a verdict.
##
##   godot --headless --path godot -s res://tools/skill_impact.gd -- run <pairs> <seed> <out file> [options]
##       --bot greedy|plan     the bot of both sides (default plan), with the switch `ai_try_all`
##       --mode 1v1|2v2|3v3    default 3v3
##       --ap random|fair      AP of the generated skills: 1–3 whatever they do (default; cost and strength
##                             independent) or what the draft price list gives them (SkillCalc.fair_ap)
##       --buffs 0|1           1: half of the monsters swap one skill for a generated self buff (default 0)
##       --set a=1,b=2         test switches of BattleExperiment by name (stamina_base=1,trap_defuse=1)
##       --drop 0|1            1 (default): a kit loses 0–2 of its six skills, so the worth of a skill
##                             as such can be read; 0: every kit is full
##   godot --headless --path godot -s res://tools/skill_impact.gd -- fit <out files…> [--no-ap] [--prices]
##       reads the rows of any number of runs and prints the tables: what one more unit of a part adds to
##       the win rate and to the HP margin (least squares over all parts at once), how often the bots used
##       it and what a use did at once.
##       --no-ap    leaves the AP cost out of the fit: for runs with `--ap fair`, where a part that still
##                  adds to the win rate is priced too low and one that takes from it too high
##       --prices   also prints a price list in points (SkillCalc.PRICES): the win rate one AP costs is 10
##                  points, a Jab with 2 damage and push is 20 points, a ground, zone, prop or shape is
##                  pulled toward the mean of its group by as much as its own value is uncertain
##
## A row of the out file: "B <win> <margin> <rounds> <part>=<amount> …" (side 0 minus side 1), or
## "U <part> <fielded> <used> <uses> <enemy damage> <own damage> <displaced>".

const Bots := preload("res://tools/lib/sim_bots.gd")
const MAX_TURNS := 400
const MAX_ACTIONS := 8
## Combination tags of a skill (a kit that holds two different tags gets the part "combo:a+b").
const TAGS: Array[String] = ["push", "pull", "hazard", "trap", "solid", "slow", "area", "dash"]
## Parts the fit leaves out, because the others are read against them: a Strike is a Jab unless it names
## another shape, a movement walks unless it names another path, and a skill that creates is told by what
## it creates.
const BASELINE: Array[String] = ["shape:jab", "path:walk", "kind:zone", "kind:ground", "kind:prop"]


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var code := 1
	if args.size() >= 4 and args[0] == "run":
		code = _run(args)
	elif args.size() >= 2 and args[0] == "fit":
		var files: PackedStringArray = []
		for a in args.slice(1):
			if not a.begins_with("--"):
				files.append(a)
		code = _fit(files, args.has("--no-ap"), args.has("--prices"))
	elif args.size() >= 1 and args[0] == "prices":
		code = _prices()
	else:
		print("skill_impact.gd -- prices")
		print("skill_impact.gd -- run <pairs> <seed> <out file> [--bot greedy|plan] [--mode 3v3] [--ap random|fair] [--drop 0|1]")
		print("skill_impact.gd -- fit <out files…>")
	quit(code)


## Every skill of the data folder that is not archived, with what the draft price list makes of it.
func _prices() -> int:
	var content := BattleContent.shared()
	var ids: Array = []
	for key in content.skills.keys():
		ids.append(String(key))
	ids.sort()
	print("| Skill | Kind | Points | Fair AP | AP on the card |")
	print("|---|---|---|---|---|")
	for id: String in ids:
		var s: BattleSkillDef = content.skills[id]
		var kind := KitDraw.kind_of(content, s)
		if s.content_status == "archived" or kind == "":
			continue
		print("| %s | %s | %d | %d | %d |" % [id, kind, roundi(SkillCalc.points(content, s)), SkillCalc.fair_ap(content, s), s.ap_cost])
	return 0


static func _option(args: PackedStringArray, name: String, fallback: String) -> String:
	var at := args.find("--" + name)
	return args[at + 1] if at >= 0 and at + 1 < args.size() else fallback


## The combination tags of one skill.
static func tags_of(content: BattleContent, s: BattleSkillDef) -> Array[String]:
	var out: Array[String] = []
	var zones: Array[StringName] = []
	if s.kind == BattleSkillDef.ZONE and s.zone != null:
		zones.append(s.zone.id)
	for op in s.ops_of(BoardOp.CREATE_ZONE):
		zones.append(op.zone)
	if (s.kind == BattleSkillDef.STRIKE and s.strike_push) or (s.kind == BattleSkillDef.MOVE and s.impact_push != "none"):
		out.append("push")
	for zid in zones:
		var z := content.zone(zid)
		if z == null:
			continue
		if z.has_tag(FieldEffect.PUSH) and not out.has("push"):
			out.append("push")
		if z.has_tag(FieldEffect.PULL) and not out.has("pull"):
			out.append("pull")
		if (z.has_tag(FieldEffect.SLOW) or z.has_tag(FieldEffect.DRAIN_PACE) or z.has_tag(FieldEffect.DRAIN_RANGE)) and not out.has("slow"):
			out.append("slow")
	for op in s.ops_of(BoardOp.GROUND):
		var g := content.ground(op.ground)
		if g != null and g.is_hazard() and not out.has("hazard"):
			out.append("hazard")
	for op in s.ops_of(BoardOp.CREATE_PROP):
		var p := content.prop(op.prop)
		if p == null:
			continue
		var tag := "trap" if p.is_trap() else ("solid" if p.solid else "")
		if tag != "" and not out.has(tag):
			out.append(tag)
	if s.kind == BattleSkillDef.STRIKE and s.strike_damage > 0 and s.shape_squares() >= 3:
		out.append("area")
	if s.kind == BattleSkillDef.MOVE and s.move_path != "walk":
		out.append("dash")
	return out


## The parts of a whole kit: the sum of its skills' parts, the AP they cost, and its combinations.
static func kit_parts(content: BattleContent, kit: Array[BattleSkillDef]) -> Dictionary:
	var f := {}
	var tags := {}
	for s in kit:
		var sf := SkillCalc.features(content, s)
		for key: String in sf:
			if not BASELINE.has(key):
				f[key] = float(f.get(key, 0.0)) + float(sf[key])
		f["ap"] = float(f.get("ap", 0.0)) + float(s.ap_cost)
		for t in tags_of(content, s):
			tags[t] = true
	for i in TAGS.size():
		for k in range(i + 1, TAGS.size()):
			if tags.has(TAGS[i]) and tags.has(TAGS[k]):
				f["combo:%s+%s" % [TAGS[i], TAGS[k]]] = 1.0
	return f


func _run(args: PackedStringArray) -> int:
	var pairs := int(args[1])
	var seed_value := int(args[2])
	var out := FileAccess.open(args[3], FileAccess.WRITE)
	if out == null:
		printerr("cannot write %s" % args[3])
		return 1
	var bot := _option(args, "bot", "plan")
	var mode := StringName(_option(args, "mode", "3v3"))
	var ap := 0 if _option(args, "ap", "random") == "random" else -1
	var drop := _option(args, "drop", "1") == "1"
	var buffs := _option(args, "buffs", "0") == "1"
	var switches := _option(args, "set", "")
	var content := BattleContent.shared()
	var size := BattleSetup.team_size(mode)
	var usage := {}                        # part -> [fielded, used, uses, enemy damage, own damage, displaced]
	var done := 0
	var rounds_total := 0
	var short := 0
	var long := 0
	var wins := [0, 0, 0]
	BattleExperiment.reset()
	BattleExperiment.ai_try_all = true
	for pair in switches.split(",", false):
		var key := pair.get_slice("=", 0)
		if not key in ["stamina_base", "trap_defuse"]:
			printerr("unknown switch '%s' (stamina_base, trap_defuse)" % key)
			return 1
		if key == "stamina_base":
			BattleExperiment.stamina_base = int(pair.get_slice("=", 1))
		else:
			BattleExperiment.trap_defuse = int(pair.get_slice("=", 1)) != 0
	out.store_line("# skill_impact run: pairs %d seed %d bot %s mode %s ap %s drop %s buffs %s set %s content %s" % [
		pairs, seed_value, bot, mode, "random" if ap == 0 else "fair", drop, buffs, switches if switches != "" else "-", content.fingerprint()])
	for j in pairs:
		var rng := RandomNumberGenerator.new()
		rng.seed = seed_value * 1000003 + j
		var team := BattleSetup.random_enemy([] as Array[StringName], size, rng)
		var board_seed := rng.randi_range(1, 1 << 30)
		var kits: Array = [[], []]
		var parts: Array = [{}, {}]
		for side in 2:
			for i in size:
				var kit := KitDraw.kit(content, rng, KitDraw.template(rng), true, side * size + i, ap)
				if drop:
					for _n in [0, 0, 1, 1, 2][rng.randi_range(0, 4)]:
						if kit.size() > 2:
							kit.remove_at(rng.randi_range(1, kit.size() - 1))     # the first Strike stays
				if buffs and rng.randf() < 0.5 and kit.size() > 2:
					kit[rng.randi_range(1, kit.size() - 1)] = SkillGen.draw_kind(content, rng, "self", 900 + side * size + i, ap)
				kits[side].append(kit)
				var kp := kit_parts(content, kit)
				for key: String in kp:
					parts[side][key] = float(parts[side].get(key, 0.0)) + float(kp[key])
		for order in 2:
			var r := BattleRequest.from_ids(mode, team, team)
			r.board_seed = board_seed
			var b := BattleSetup.build(r)
			for id in b.roster:
				var u: BattleUnit = b.units[id]
				u.sheet.skills = kits[(u.side + order) % 2][u.team_index]
			var play := RandomNumberGenerator.new()
			play.seed = rng.seed + 17 + order
			b.begin()
			var used := {}                 # unit id -> {slot -> [uses, enemy damage, own damage, displaced]}
			var guard := 0
			while not b.over and guard < MAX_TURNS:
				_turn(bot, b, play, used)
				guard += 1
			var hp := [0.0, 0.0]
			var full := [0.0, 0.0]
			for id in b.roster:
				var u: BattleUnit = b.units[id]
				hp[u.side] += float(maxi(u.hp, 0))
				full[u.side] += float(u.max_hp)
				var mine: Dictionary = used.get(id, {})
				for slot in u.sheet.skills.size():
					var row: Array = mine.get(slot, [0, 0, 0, 0])
					var names := SkillCalc.part_names(content, u.sheet.skills[slot])
					for t in tags_of(content, u.sheet.skills[slot]):
						names.append("tag:%s" % t)
					for part in names:
						if not usage.has(part):
							usage[part] = [0, 0, 0, 0, 0, 0]
						var acc: Array = usage[part]
						acc[0] += 1
						acc[1] += 1 if row[0] > 0 else 0
						acc[2] += row[0]
						acc[3] += row[1]
						acc[4] += row[2]
						acc[5] += row[3]
			var win: float = 0.5 if (not b.over or b.draw) else (1.0 if b.winner_side == 0 else 0.0)
			var margin: float = hp[0] / full[0] - hp[1] / full[1]
			var cells: PackedStringArray = ["B", "%.1f" % win, "%.3f" % margin, str(b.round_number)]
			var mine_f: Dictionary = parts[order]
			var their_f: Dictionary = parts[1 - order]
			var keys := {}
			for key in mine_f:
				keys[key] = true
			for key in their_f:
				keys[key] = true
			for key: String in keys:
				var d := float(mine_f.get(key, 0.0)) - float(their_f.get(key, 0.0))
				if not is_zero_approx(d):
					cells.append("%s=%s" % [key, String.num(d, 2)])
			out.store_line(" ".join(cells))
			done += 1
			rounds_total += b.round_number
			short += 1 if b.round_number < 3 else 0
			long += 1 if b.round_number > 5 else 0
			wins[0 if win > 0.75 else (1 if win < 0.25 else 2)] += 1
	for part: String in usage:
		var acc: Array = usage[part]
		out.store_line("U %s %d %d %d %d %d %d" % [part, acc[0], acc[1], acc[2], acc[3], acc[4], acc[5]])
	out.close()
	print("%d battles · side 0 won %d, side 1 %d, Draw or timeout %d · mean rounds %.2f · under 3 rounds: %d · over 5: %d" % [
		done, wins[0], wins[1], wins[2], float(rounds_total) / maxi(1, done), short, long])
	return 0


## One turn of the active monster, action by action, so that what an action did at once (damage,
## displacement) can be put down to the skill that was used.
func _turn(bot: String, b: Battle, rng: RandomNumberGenerator, used: Dictionary) -> void:
	var owner := b.turn_owner
	var entry := b.queue_idx
	var round_no := b.round_number
	var guard := 0
	while not b.over and b.turn_owner == owner and b.queue_idx == entry and b.round_number == round_no and guard < MAX_ACTIONS:
		guard += 1
		var u := b.active()
		if u == null:
			break
		var a: Dictionary = Bots._plan(b, rng) if bot == "plan" else AiBrain.decide(b, rng)
		if a["type"] == &"end_turn":
			break
		var from := b.events.size()
		if not b.apply(a):
			break
		if a["type"] != &"skill":
			continue
		if not used.has(u.id):
			used[u.id] = {}
		var slot := int(a["slot"])
		if not used[u.id].has(slot):
			used[u.id][slot] = [0, 0, 0, 0]
		var row: Array = used[u.id][slot]
		row[0] += 1
		for i in range(from, b.events.size()):
			var ev: Dictionary = b.events[i]
			if ev["type"] == &"damage":
				var t: BattleUnit = b.units.get(ev["target"])
				if t != null:
					row[1 if t.side != u.side else 2] += int(ev["amount"])
			elif ev["type"] == &"displaced" and ev.get("who", u.id) != u.id:
				row[3] += 1
	if not b.over and b.turn_owner == owner and b.queue_idx == entry and b.round_number == round_no:
		b.end_turn()


# ---------- fit ----------

func _fit(files: PackedStringArray, no_ap := false, prices := false) -> int:
	var index := {"(side 0)": 0}           # part -> column
	var names: Array[String] = ["(side 0)"]
	var rows: Array = []                   # [win, margin, rounds, {column: amount}]
	var usage := {}
	var heads: PackedStringArray = []
	for path in files:
		var f := FileAccess.open(path, FileAccess.READ)
		if f == null:
			printerr("cannot read %s" % path)
			return 1
		while not f.eof_reached():
			var line := f.get_line()
			if line.begins_with("#"):
				if not heads.has(line.get_slice(" seed ", 0) + line.substr(line.find(" bot "))):
					heads.append(line.get_slice(" seed ", 0) + line.substr(line.find(" bot ")))
				continue
			var cells := line.split(" ", false)
			if cells.size() < 4:
				continue
			if cells[0] == "U":
				if not usage.has(cells[1]):
					usage[cells[1]] = [0, 0, 0, 0, 0, 0]
				for i in 6:
					usage[cells[1]][i] += int(cells[2 + i])
				continue
			var x := {0: 1.0}
			for i in range(4, cells.size()):
				var key := cells[i].get_slice("=", 0)
				if no_ap and key == "ap":
					continue
				if not index.has(key):
					index[key] = names.size()
					names.append(key)
				x[index[key]] = float(cells[i].get_slice("=", 1))
			rows.append([float(cells[1]), float(cells[2]), int(cells[3]), x])
	var n := names.size()
	var m := rows.size()
	if m < n:
		printerr("too few battles (%d) for %d parts" % [m, n])
		return 1
	# normal equations with a light ridge (kits have a fixed number of slots, so some parts add up)
	var xtx: Array = []
	for i in n:
		var zero := PackedFloat64Array()
		zero.resize(n)
		xtx.append(zero)
	var xty := [PackedFloat64Array(), PackedFloat64Array()]
	xty[0].resize(n)
	xty[1].resize(n)
	var seen := PackedInt32Array()
	seen.resize(n)
	var rounds := 0
	var short := 0
	var long := 0
	var side0 := 0.0
	for row: Array in rows:
		var x: Dictionary = row[3]
		rounds += int(row[2])
		short += 1 if row[2] < 3 else 0
		long += 1 if row[2] > 5 else 0
		side0 += row[0]
		for i: int in x:
			seen[i] += 1
			xty[0][i] += x[i] * (row[0] - 0.5) * 100.0
			xty[1][i] += x[i] * row[1] * 100.0
			var line: PackedFloat64Array = xtx[i]
			for k: int in x:
				line[k] += x[i] * x[k]
	for i in n:
		xtx[i][i] += 1.0
	var inv := _invert(xtx)
	if inv.is_empty():
		printerr("the parts cannot be told apart (singular)")
		return 1
	var beta := [PackedFloat64Array(), PackedFloat64Array()]
	for t in 2:
		beta[t].resize(n)
		for i in n:
			var sum := 0.0
			for k in n:
				sum += inv[i][k] * xty[t][k]
			beta[t][i] = sum
	var rss := [0.0, 0.0]
	for row: Array in rows:
		var x: Dictionary = row[3]
		var fit := [0.0, 0.0]
		for i: int in x:
			fit[0] += beta[0][i] * x[i]
			fit[1] += beta[1][i] * x[i]
		rss[0] += pow((row[0] - 0.5) * 100.0 - fit[0], 2)
		rss[1] += pow(row[1] * 100.0 - fit[1], 2)
	var sigma := [sqrt(rss[0] / (m - n)), sqrt(rss[1] / (m - n))]
	for h in heads:
		print(h)
	print("%d battles · side 0 won %.1f %% · mean rounds %.2f · under 3 rounds: %d · over 5: %d" % [
		m, 100.0 * side0 / m, float(rounds) / m, short, long])
	print("")
	print("| Part | Battles it differed in | Win rate per unit (points) | ± | HP margin per unit (points) | ± | Fielded | Used at least once | Uses per fielding | Enemy damage per use | Own damage per use | Displaced per use |")
	print("|---|---|---|---|---|---|---|---|---|---|---|---|")
	var order := range(1, n)
	order.sort_custom(func(a: int, c: int) -> bool: return names[a] < names[c])
	order.push_front(0)
	for i: int in order:
		var u: Array = usage.get(names[i], [])
		var use_cells := "— | — | — | — | — | —"
		if not u.is_empty() and u[0] > 0:
			use_cells = "%d | %d %% | %.2f | %s | %s | %s" % [u[0], roundi(100.0 * u[1] / u[0]), float(u[2]) / u[0],
				"%.2f" % (float(u[3]) / u[2]) if u[2] > 0 else "—", "%.2f" % (float(u[4]) / u[2]) if u[2] > 0 else "—",
				"%.2f" % (float(u[5]) / u[2]) if u[2] > 0 else "—"]
		print("| %s | %d | %+.2f | %.2f | %+.2f | %.2f | %s |" % [names[i], seen[i], beta[0][i], sigma[0] * sqrt(inv[i][i]),
			beta[1][i], sigma[1] * sqrt(inv[i][i]), use_cells])
	var extra: Array = usage.keys().filter(func(k: String) -> bool: return not index.has(k))
	extra.sort()
	if not extra.is_empty():
		print("")
		print("| Value of a part / tag | Fielded | Used at least once | Uses per fielding | Enemy damage per use | Own damage per use | Displaced per use |")
		print("|---|---|---|---|---|---|---|")
		for key: String in extra:
			var u: Array = usage[key]
			print("| %s | %d | %d %% | %.2f | %s | %s | %s |" % [key, u[0], roundi(100.0 * u[1] / maxi(1, u[0])), float(u[2]) / maxi(1, u[0]),
				"%.2f" % (float(u[3]) / u[2]) if u[2] > 0 else "—", "%.2f" % (float(u[4]) / u[2]) if u[2] > 0 else "—",
				"%.2f" % (float(u[5]) / u[2]) if u[2] > 0 else "—"])
	if prices and index.has("ap"):
		_print_prices(names, index, beta[0], inv, sigma[0])
	return 0


## A price list from the fit. Scale: the win rate one AP of cost takes is POINTS_PER_AP points. Zero point:
## a Jab with 2 damage and push is worth the 2 AP of the draft, so every kind carries the same offset.
func _print_prices(names: Array[String], index: Dictionary, beta: PackedFloat64Array, inv: Array, sigma: float) -> void:
	var per_ap := -beta[index["ap"]]
	print("")
	print("One AP of cost takes %.2f points of win rate (± %.2f)." % [per_ap, sigma * sqrt(inv[index["ap"]][index["ap"]])])
	if per_ap <= 0.0:
		print("No price list: AP cost does not lower the win rate in this run.")
		return
	var scale := SkillCalc.POINTS_PER_AP / per_ap
	var value := {}
	var error := {}
	for i in names.size():
		value[names[i]] = beta[i] * scale
		error[names[i]] = sigma * sqrt(inv[i][i]) * scale
	# groups: pull every member toward the group mean by as much as it is uncertain
	for group: String in ["ground:", "zone:", "prop:", "shape:"]:
		var members: Array = names.filter(func(k: String) -> bool: return k.begins_with(group))
		if members.size() < 3:
			continue
		var mean := 0.0
		var noise := 0.0
		for k: String in members:
			mean += value[k] / members.size()
			noise += pow(error[k], 2) / members.size()
		var spread := 0.0
		for k: String in members:
			spread += pow(value[k] - mean, 2) / (members.size() - 1)
		var real := maxf(0.0, spread - noise)
		for k: String in members:
			value[k] = mean + real / (real + pow(error[k], 2)) * (value[k] - mean)
		print("%s mean %.1f, spread between members %.1f (of which noise %.1f)" % [group, mean, sqrt(spread), sqrt(noise)])
	var offset: float = float(value.get("kind:strike", 0.0)) + 2.0 * float(value.get("damage", 0.0)) + float(value.get("push", 0.0)) - 2.0 * SkillCalc.POINTS_PER_AP
	value["kind:strike"] = float(value.get("kind:strike", 0.0)) - offset
	value["kind:move"] = float(value.get("kind:move", 0.0)) - offset
	if value.has("kind:self"):
		value["kind:self"] = float(value["kind:self"]) - offset
	for kind in ["zone", "ground", "prop"]:
		value["kind:%s" % kind] = -offset
	var keys: Array = value.keys().filter(func(k: String) -> bool: return k != "ap" and k != "(side 0)" and not k.begins_with("combo:"))
	keys.sort()
	print("")
	print("const PRICES := {")
	var row: PackedStringArray = []
	for k: String in keys:
		row.append("\"%s\": %.1f" % [k, snappedf(value[k], 0.5)])
		if row.size() == 5:
			print("\t" + ", ".join(row) + ",")
			row.clear()
	if not row.is_empty():
		print("\t" + ", ".join(row) + ",")
	print("}")
	print("")
	print("| Combination in one kit | Points | ± |")
	print("|---|---|---|")
	for k: String in names:
		if k.begins_with("combo:"):
			print("| %s | %+.1f | %.1f |" % [k.trim_prefix("combo:"), value[k], error[k]])


## Inverse of a symmetric positive matrix (Gauss-Jordan with pivoting); [] if it is singular.
static func _invert(a: Array) -> Array:
	var n := a.size()
	var m: Array = []
	for i in n:
		var row := PackedFloat64Array()
		row.resize(2 * n)
		for k in n:
			row[k] = a[i][k]
		row[n + i] = 1.0
		m.append(row)
	for col in n:
		var pivot := col
		for r in range(col + 1, n):
			if absf(m[r][col]) > absf(m[pivot][col]):
				pivot = r
		if absf(m[pivot][col]) < 1e-9:
			return []
		var swap: PackedFloat64Array = m[col]
		m[col] = m[pivot]
		m[pivot] = swap
		var lead: PackedFloat64Array = m[col]
		var d := lead[col]
		for k in 2 * n:
			lead[k] /= d
		for r in n:
			if r == col:
				continue
			var line: PackedFloat64Array = m[r]
			var factor := line[col]
			if factor == 0.0:
				continue
			for k in range(col, 2 * n):
				line[k] -= factor * lead[k]
	var out: Array = []
	for i in n:
		out.append((m[i] as PackedFloat64Array).slice(n, 2 * n))
	return out
