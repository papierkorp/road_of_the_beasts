extends SceneTree
## Side-swapped comparison of two monsters of data/monsters (also simulation-only ones): an
## indication of how two sheets or kits do against each other, never balance validation.
##
##   godot --headless --path godot -s res://tools/compare.gd -- [--monsters a,b] [--seeds 1,2,3]
##         [--pairs-per-seed 10] [--sizes 5,7] [--bot greedy|plan|rush|kite|random] [--board flat|layout]
##
## Nothing is priced or checked against a budget: skill prices are not settled, and finding
## out what plays well comes first (temp_todo T02/T13). The table shows the stat points of
## both sheets (gdd_monsters §2.2 prices) as information only. Each side fields one monster.
## Every seed is played twice with swapped sides on the same mirrored start squares, with the
## same bot and no tamer skills. A Draw (or timeout) scores 0.5. SD and range describe the
## seed-block mean scores of monster A, not confidence intervals.
##
## Reading: high Draw rates or bot stalling make a 50/50 score meaningless.
## Record the command, seeds, game count and limits under T13 in docs/temp_todo.md.

const Cli := preload("res://tools/lib/cli.gd")
const Runner := preload("res://tools/lib/sim_runner.gd")
const Bots := preload("res://tools/lib/sim_bots.gd")

const OPTIONS: Array[String] = ["monsters", "seeds", "pairs-per-seed", "sizes", "bot", "board", "help"]
const DEFAULT_PAIRS := [["forge_golem", "moss_turtle"], ["blaze_tiger", "forge_golem"], ["gloom_wolf", "hollow_serpent"]]
const HELP := "compare.gd -- [--monsters a,b] [--seeds 1,2,3] [--pairs-per-seed 10] [--sizes 5,7] [--bot greedy] [--board flat|layout]"


func _initialize() -> void:
	quit(_run())


func _fail(message: String) -> int:
	print(message)
	return 2


func _run() -> int:
	var args := Cli.parse(["help"], OPTIONS)
	var opt: Dictionary = args["opt"]
	if args["error"] != "" or opt.has("help") or not args["pos"].is_empty():
		print(args["error"] if args["error"] != "" else HELP)
		return 0 if opt.has("help") and args["error"] == "" else 2
	var blocks := Cli.ints(opt.get("seeds", "1,2,3"))
	var sizes := Cli.ints(opt.get("sizes", "5,7"))
	var per_seed_text := String(opt.get("pairs-per-seed", "10"))
	var bot := String(opt.get("bot", "greedy"))
	var board := String(opt.get("board", "flat"))
	if blocks.is_empty() or _has_repeats(blocks) or not per_seed_text.is_valid_int() or per_seed_text.to_int() < 1:
		return _fail("use distinct seed blocks and --pairs-per-seed >= 1")
	var per_seed := per_seed_text.to_int()
	if sizes.is_empty() or _has_repeats(sizes):
		return _fail("--sizes must contain distinct values from 5,6,7,9")
	for size in sizes:
		if not Runner.MODE_OF_SIZE.has(size):
			return _fail("--sizes must contain distinct values from 5,6,7,9")
	if not Bots.NAMES.has(bot):
		return _fail("unknown bot '%s' (%s)" % [bot, ", ".join(Bots.NAMES)])
	if board != "flat" and board != "layout":
		return _fail("--board must be flat or layout (a seeded board would differ between the two games of a seed)")
	var pairs: Array = DEFAULT_PAIRS
	if opt.has("monsters"):
		var chosen := Cli.names(opt["monsters"])
		if chosen.size() != 2 or chosen[0] == chosen[1]:
			return _fail("--monsters requires exactly two distinct ids: a,b")
		pairs = [chosen]
	var builds := {}                          # id -> {sheet, points}
	for pair: Array in pairs:
		for name: String in pair:
			if builds.has(name):
				continue
			var def := GameData.monster(StringName(name))
			if def == null:
				return _fail("unknown monster: %s (data/monsters)" % name)
			var sheet := UnitSheets.from_instance(MonsterInstance.of_species(def))
			if not sheet.problems().is_empty():
				return _fail("%s: %s" % [name, "; ".join(sheet.problems())])
			builds[name] = {"sheet": sheet, "points": _stat_points(sheet)}
	# distinct game seeds per seed block
	var schedule: Array = []
	var used := {}
	for block in blocks:
		var rng := RandomNumberGenerator.new()
		rng.seed = block
		var seeds: Array[int] = []
		while seeds.size() < per_seed:
			var seed_value := (rng.randi() << 31) ^ rng.randi()
			if not used.has(seed_value):
				used[seed_value] = true
				seeds.append(seed_value)
		schedule.append(seeds)
	var rows: Array = [["Monster A", "Monster B", "Size", "Stat points A/B", "Games", "Wins A/B/draws", "Score A", "Seed SD",
		"Seed range", "Rounds mean", "Timeouts"]]
	for pair: Array in pairs:
		for size in sizes:
			var row := _row(pair, builds, size, schedule, bot, board)
			if row.is_empty():
				return 2
			rows.append(row)
	print("Bot-vs-bot indications only; no balance validation, nothing priced. Content %s." % BattleContent.VERSION)
	print("Bot %s; blocks %s; %d paired seeds/block; board %s, mirrored starts, no tamer skills." % [bot, blocks, per_seed, board])
	print("Draw = 0.5; sample SD/range describe A's seed-block means (one block: SD n/a).")
	print(Cli.table(rows))
	return 0


func _has_repeats(values: Array[int]) -> bool:
	var seen := {}
	for v in values:
		if seen.has(v):
			return true
		seen[v] = true
	return false


## One table row: both builds on one board size over the whole seed schedule.
func _row(pair: Array, builds: Dictionary, size: int, schedule: Array, bot: String, board: String) -> Array:
	var mode: StringName = Runner.MODE_OF_SIZE[size]
	var bots: Array[String] = [bot, bot]
	var wins_a := 0
	var wins_b := 0
	var draws := 0
	var rounds := 0
	var timeouts := 0
	var block_means: Array[float] = []
	for seeds: Array[int] in schedule:
		var block_score := 0.0
		for seed_value in seeds:
			for swapped in 2:
				var names: Array = [pair[1], pair[0]] if swapped == 1 else [pair[0], pair[1]]
				var teams := [[builds[names[0]]["sheet"]], [builds[names[1]]["sheet"]]]
				var rng := RandomNumberGenerator.new()
				rng.seed = seed_value
				var made := Runner.make_battle(mode, teams, board, rng)
				if made["error"] != "":
					print("%s/%s, size %d, seed %d: %s" % [pair[0], pair[1], size, seed_value, made["error"]])
					return []
				var b: Battle = made["battle"]
				var result := Runner.play(b, bots, rng)
				rounds += int(result["rounds"])
				if result["timeout"]:
					timeouts += 1
				if int(result["winner"]) < 0:
					draws += 1
					block_score += 0.5
				elif int(result["winner"]) == swapped:
					wins_a += 1
					block_score += 1.0
				else:
					wins_b += 1
		block_means.append(block_score / (2.0 * seeds.size()))
	var games := wins_a + wins_b + draws
	return [pair[0], pair[1], str(size), "%d/%d" % [builds[pair[0]]["points"], builds[pair[1]]["points"]], str(games),
		"%d/%d/%d" % [wins_a, wins_b, draws], "%.3f" % ((wins_a + 0.5 * draws) / games),
		"%.3f" % _sample_sd(block_means) if block_means.size() > 1 else "n/a",
		"%.3f..%.3f" % [block_means.min(), block_means.max()], "%.2f" % (float(rounds) / games), str(timeouts)]


## Stat points of a sheet at the gdd_monsters §2.2 prices (information only).
func _stat_points(s: UnitSheet) -> int:
	var tpr_cost: int = [0, 3, 8, 15][clampi(s.tpr, 1, 3)]
	var ap_cost: int = {2: 6, 3: 9, 4: 14, 5: 21}.get(s.ap, 6)
	return s.hp + int(s.initiative) + s.movement + (s.reach - 1) * 3 + tpr_cost + ap_cost


func _sample_sd(values: Array[float]) -> float:
	var mean := 0.0
	for v in values:
		mean += v
	mean /= values.size()
	var sum := 0.0
	for v in values:
		sum += (v - mean) * (v - mean)
	return sqrt(sum / (values.size() - 1))
