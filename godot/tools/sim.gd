extends SceneTree
## Headless AI-vs-AI battles: a quick look at flow and stalling, never a balance verdict
## (naive AI, unapproved content; gdd_battle §7.2, temp_todo T13).
## Prints one run block in the fixed format of docs/simulation_log.md, ready to paste there.
##
## godot --headless --path godot -s res://tools/sim.gd -- [battles] [mode] [seed] [state] [kits] [options]
##   state: free label of the code state, e.g. "$(git rev-parse --short HEAD) dirty"
##   a fifth argument "kits" also prints the kit set block (once per content fingerprint)
##
## Without options both sides draw random teams from the TEST kits (data/battle/kits) on a
## seeded draft board and play with AiBrain. Options change the setup; the block names it:
##   --team-a / --team-b  test builds (tools/data/builds, comma lists of ids; --team-b defaults
##                        to --team-a) on an empty board with seeded, mirrored start squares
##   --bot-a / --bot-b    greedy (AiBrain, default) | rush | kite | random (tools/lib/sim_bots.gd)
##   --board              kit runs: seeded (default) | layout    build runs: flat (default) | layout | seeded
##   --props a,b          build runs: one mirrored pair per prop id
##   --experiment props   build runs: one block without props, then one per catalogue prop
##                        (--pairs N mirrored pairs each, default 2)
##   --experiment bots    one block per bot pairing
##   --trace              one battle, with the board printed before every turn
## Equal-cost, side-swapped comparisons of two builds: res://tools/compare.gd.

const Cli := preload("res://tools/lib/cli.gd")
const Builds := preload("res://tools/lib/sim_builds.gd")
const Runner := preload("res://tools/lib/sim_runner.gd")
const Bots := preload("res://tools/lib/sim_bots.gd")

const MAX_TURNS := 600
const DAMAGE_KINDS := ["strike", "surge", "ground", "collision", "fall", "collapse", "aftermath", "arena"]
const OPTIONS: Array[String] = ["bot-a", "bot-b", "team-a", "team-b", "board", "props", "experiment", "pairs", "trace", "help"]
const HELP := "sim.gd -- [battles] [mode 1v1|2v2|3v3|5v5] [seed] [state] [kits] [--team-a builds] [--team-b builds]\n" \
	+ "          [--bot-a B] [--bot-b B] [--board flat|layout|seeded] [--props ids] [--experiment props|bots] [--pairs N] [--trace]"


func _initialize() -> void:
	quit(_run())


func _fail(message: String) -> int:
	print(message)
	return 2


func _run() -> int:
	var args := Cli.parse(["trace", "help"], OPTIONS)
	var opt: Dictionary = args["opt"]
	if args["error"] != "" or opt.has("help"):
		print(args["error"] if args["error"] != "" else HELP)
		return 2 if args["error"] != "" else 0
	var pos: Array[String] = args["pos"]
	var setup := {
		"battles": int(pos[0]) if pos.size() > 0 else 20,
		"mode": StringName(pos[1]) if pos.size() > 1 else &"3v3",
		"seed": int(pos[2]) if pos.size() > 2 else 1,
		"state": pos[3] if pos.size() > 3 else "not given",
		"kits": pos.size() > 4 and pos[4] == "kits",
		"bots": [String(opt.get("bot-a", "greedy")), String(opt.get("bot-b", "greedy"))] as Array[String],
		"teams": [], "team_names": ["", ""], "props": [] as Array[StringName], "trace": opt.has("trace"), "options": "",
	}
	if setup["battles"] < 1 or not BattleBoards.has_mode(setup["mode"]):
		return _fail("battles must be positive and the mode one of 1v1, 2v2, 3v3, 5v5")
	for bot: String in setup["bots"]:
		if not Bots.NAMES.has(bot):
			return _fail("unknown bot '%s' (%s)" % [bot, ", ".join(Bots.NAMES)])
	var builds := opt.has("team-a") or opt.has("team-b")
	if builds:
		var lists := [Cli.names(opt.get("team-a", opt.get("team-b", ""))), Cli.names(opt.get("team-b", opt.get("team-a", "")))]
		for side in 2:
			var team: Array[UnitSheet] = []
			for build: String in lists[side]:
				var result := Builds.build(build)
				if not result["ok"]:
					return _fail("build %s is not legal: %s" % [build, "; ".join(result["errors"])])
				for w: String in result["warnings"]:
					if w.to_upper().contains("NOT SIMULATED"):
						print("[%s] %s" % [build, w])
				team.append(result["sheet"])
			if team.is_empty():
				return _fail("--team-a / --team-b need at least one build name")
			setup["teams"].append(team)
			setup["team_names"][side] = ", ".join(lists[side])
	setup["board"] = String(opt.get("board", "flat" if builds else "seeded"))
	if not Runner.BOARDS.has(setup["board"]) or (not builds and setup["board"] == "flat"):
		return _fail("--board: kit runs take seeded or layout, build runs flat, layout or seeded")
	for id in Cli.names(opt.get("props", "")):
		setup["props"].append(StringName(id))
	var experiment := String(opt.get("experiment", ""))
	if (not setup["props"].is_empty() or experiment == "props") and not builds:
		return _fail("--props and --experiment props need --team-a (kit runs use the mode's boards)")
	if setup["trace"]:
		setup["battles"] = 1
	# the options as typed, for the Command row of the block
	for key in OPTIONS:
		if opt.has(key) and key != "experiment" and key != "pairs":
			setup["options"] += " --%s%s" % [key, "" if typeof(opt[key]) == TYPE_BOOL else " " + String(opt[key])]
	match experiment:
		"":
			return _series(setup, "")
		"bots":
			for a in Bots.NAMES:
				for c in Bots.NAMES:
					setup["bots"] = [a, c] as Array[String]
					if _series(setup, "%s vs %s" % [a, c]) != 0:
						return 2
			return 0
		"props":
			var pairs := String(opt.get("pairs", "2"))
			if not pairs.is_valid_int() or pairs.to_int() < 1:
				return _fail("--pairs must be a positive number")
			if _series(setup, "no props") != 0:
				return 2
			for id in BattleBoards.SEEDED_PROPS:
				var list: Array[StringName] = []
				for i in pairs.to_int():
					list.append(id)
				setup["props"] = list
				if _series(setup, "%d pair(s) of %s" % [pairs.to_int(), id]) != 0:
					return 2
			return 0
	return _fail("unknown experiment '%s' (props, bots)" % experiment)


## Plays one run and prints its block. Every run of an experiment restarts from the same seed.
func _series(setup: Dictionary, label: String) -> int:
	var n: int = setup["battles"]
	var mode: StringName = setup["mode"]
	var seed_value: int = setup["seed"]
	var bots: Array[String] = setup["bots"]
	var builds: bool = not setup["teams"].is_empty()
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var content := BattleContent.shared()
	var wins := [0, 0]
	var draws := 0
	var timeouts := 0
	var rounds_total := 0
	var by_monster := {}                  # species -> [played, won]
	var damage := {}                      # kind -> total
	var counts := {&"surge_declared": 0, &"strike": 0, &"cast": 0, &"prop_destroyed": 0, &"defeated": 0}
	var props_placed := {}                # prop id -> count at battle start
	var skills_used := {}                 # skill id -> uses
	var board_size := 0
	var pressure_from := 0
	for i in n:
		var b: Battle
		if builds:
			var made := Runner.make_battle(mode, setup["teams"], setup["board"], rng, setup["props"])
			if made["error"] != "":
				return _fail(made["error"])
			b = made["battle"]
		else:
			var size := BattleSetup.team_size(mode)
			var p := BattleSetup.random_enemy([] as Array[StringName], size, rng)
			var e := BattleSetup.random_enemy(p, size, rng)
			var r := BattleRequest.from_ids(mode, p, e)
			r.board_seed = rng.randi_range(1, 1 << 30) if setup["board"] == "seeded" else 0
			b = BattleSetup.build(r)
		board_size = b.board.size
		pressure_from = b.voidscar_from
		for prop in b.board.props():
			props_placed[prop.def.id] = int(props_placed.get(prop.def.id, 0)) + 1
		b.begin()
		var guard := 0
		while not b.over and guard < MAX_TURNS:
			var active := b.active()
			if setup["trace"]:
				print(Runner.render(b))
			Bots.play_turn(bots[active.side] if active != null else bots[0], b, rng)
			guard += 1
		if not b.over:
			timeouts += 1
		elif b.draw:
			draws += 1
		else:
			wins[b.winner_side] += 1
		rounds_total += b.round_number
		for ev in b.events:
			if ev["type"] == &"damage":
				damage[ev["kind"]] = int(damage.get(ev["kind"], 0)) + int(ev["amount"])
			elif counts.has(ev["type"]):
				counts[ev["type"]] += 1
			if ev["type"] in [&"surge_declared", &"cast", &"strike", &"moved"] and ev.has("skill"):
				var key := String(ev["skill"])
				skills_used[key] = int(skills_used.get(key, 0)) + 1
		for id in b.roster:
			var u: BattleUnit = b.units[id]
			var k := "%s · side %d" % [u.sheet.species_id, u.side] if builds else String(u.sheet.species_id)
			if not by_monster.has(k):
				by_monster[k] = [0, 0]
			by_monster[k][0] += 1
			if b.over and b.winner_side == u.side:
				by_monster[k][1] += 1

	var total_damage := 0
	for k in damage:
		total_damage += int(damage[k])
	var per := func(a: int, c: int) -> String: return "%.2f" % (float(a) / c) if c > 0 else "—"
	var share := func(a: int) -> String: return "%d %%" % roundi(100.0 * a / total_damage) if total_damage > 0 else "—"
	var fingerprint := content.fingerprint().left(12)

	if setup["kits"]:
		print("**Kit set `%s`** (content `%s`; HP/Init/Move/TPR/Reach/AP: slots)" % [fingerprint, BattleContent.VERSION])
		print("")
		for line in _kits(content):
			print("- " + line)
		print("")
	print("#### Run · %s · seed %d · %d battles%s" % [mode, seed_value, n, " · " + label if label != "" else ""])
	print("")
	print("| Field | Value |")
	print("|---|---|")
	print("| State | %s · content `%s` · kit set `%s` |" % [setup["state"], BattleContent.VERSION, fingerprint])
	print("| Command | `sim.gd -- %d %s %d%s` |" % [n, mode, seed_value, setup["options"]])
	print("| Setup | %s on %d×%d, late-round pressure from round %d, %s |" % [mode, board_size, board_size, pressure_from, _setup_text(setup, builds)])
	if builds:
		print("| Units | test builds (tools/data/builds): %s (side 0) against %s (side 1) |" % setup["team_names"])
	else:
		print("| Units | random teams from kit set `%s` |" % fingerprint)
	print("| Props placed | %s |" % _pairs(props_placed, n, true))
	if bots == (["greedy", "greedy"] as Array[String]):
		print("| Loadout / AI | no tamer skills · `AiBrain` (one-step evaluation) on both sides |")
	else:
		print("| Loadout / AI | no tamer skills · bots `%s` (side 0) and `%s` (side 1), tools/lib/sim_bots.gd |" % bots)
	print("| Not covered | 2×2 and air units, tamer skills, human play%s |" % (", Mountains" if builds and setup["board"] == "flat" else ""))
	print("")
	print("| Battles | Side 0 / side 1 / Draw / timeout | Mean rounds | Defeats per battle | Props destroyed per battle |")
	print("|---|---|---|---|---|")
	print("| %d | %d / %d / %d / %d | %.1f | %s | %s |" % [n, wins[0], wins[1], draws, timeouts, float(rounds_total) / n,
		per.call(counts[&"defeated"], n), per.call(counts[&"prop_destroyed"], n)])
	print("")
	var head := "| Damage"
	var rule := "|---"
	var row := "| share"
	var row2 := "| per battle"
	for k: String in DAMAGE_KINDS:
		head += " | %s" % k
		rule += "|---"
		row += " | %s" % share.call(int(damage.get(k, 0)))
		row2 += " | %s" % per.call(int(damage.get(k, 0)), n)
	print(head + " | total |")
	print(rule + "|---|")
	print(row + " | 100 % |")
	print(row2 + " | %s |" % per.call(total_damage, n))
	print("")
	print("| Surges declared | Surge damage per Surge | Strikes | Strike damage per Strike | Zone / board casts |")
	print("|---|---|---|---|---|")
	print("| %d | %s | %d | %s | %d |" % [counts[&"surge_declared"], per.call(int(damage.get("surge", 0)), counts[&"surge_declared"]),
		counts[&"strike"], per.call(int(damage.get("strike", 0)), counts[&"strike"]), counts[&"cast"]])
	print("")
	print("| Monster | Played | Win rate |")
	print("|---|---|---|")
	var names := by_monster.keys()
	names.sort_custom(func(a: String, c: String) -> bool:
		var ra: float = float(by_monster[a][1]) / float(by_monster[a][0])
		var rc: float = float(by_monster[c][1]) / float(by_monster[c][0])
		return ra > rc if ra != rc else a < c)
	for k: String in names:
		print("| %s | %d | %d %% |" % [k, by_monster[k][0], roundi(100.0 * by_monster[k][1] / by_monster[k][0])])
	print("")
	print("Skill uses per battle: %s" % _pairs(skills_used, n, false))
	if label != "":
		print("")
	return 0


## Board and team part of the Setup row.
func _setup_text(setup: Dictionary, builds: bool) -> String:
	var board := "seeded draft boards"
	match setup["board"]:
		"layout":
			board = "fixed test layout (board seed 0)"
		"flat":
			board = "empty board without Mountains"
	if not builds:
		return board + ", random teams without repeats"
	var props := ""
	if not (setup["props"] as Array).is_empty():
		var ids: PackedStringArray = []
		for id: StringName in setup["props"]:
			ids.append(String(id))
		props = ", one mirrored pair each of %s" % ", ".join(ids)
	return "%s%s, seeded start squares mirrored between the sides" % [board, props]


## One line per test kit, in id order: "species 5/7/4/1/2/3: skill, skill, …".
func _kits(content: BattleContent) -> PackedStringArray:
	var parts: PackedStringArray = []
	for id: StringName in BattleContent.sorted_ids(content.kits):
		var kit := content.kit(id)
		var names: PackedStringArray = []
		for s in kit.skills:
			names.append(String(s.id))
		parts.append("%s %d/%.0f/%d/%d/%d/%d: %s" % [id, kit.hp, kit.initiative, kit.movement, kit.tpr, kit.reach, kit.ap, ", ".join(names)])
	return parts


## "name 1.23, name 0.50" sorted by value, as a per-battle average.
func _pairs(table: Dictionary, n: int, per_battle_label: bool) -> String:
	var keys := table.keys()
	keys.sort_custom(func(a, c) -> bool: return int(table[a]) > int(table[c]) if table[a] != table[c] else String(a) < String(c))
	var parts: PackedStringArray = []
	for k in keys:
		parts.append("%s %.2f" % [k, float(table[k]) / n])
	if parts.is_empty():
		return "none"
	return ", ".join(parts) + (" (per battle)" if per_battle_label else "")
