extends SceneTree
## Equal-cost, side-swapped comparison of two test builds (tools/data/builds): an
## indication for a price question, never balance validation or price approval.
##
##   godot --headless --path godot -s res://tools/compare.gd -- [--builds a,b] [--seeds 1,2,3]
##         [--pairs-per-seed 10] [--sizes 5,7] [--bot greedy|rush|kite|random] [--board flat|layout]
##
## Both builds must have equal exact stat spend, equal summed skill prices and the same
## slot-level distribution; illegal or partly simulated builds are refused. Each build fields
## one monster. Every seed is played twice with swapped sides on the same mirrored start
## squares, with the same bot and no tamer skills. A Draw (or timeout) scores 0.5. SD and range
## describe the seed-block mean scores of build A, not confidence intervals.
##
## Reading: different stat allocations at equal spend probe the whole build, not the marginal
## value of a shared skill; high Draw rates or bot stalling make a 50/50 score meaningless.
## Record the command, seeds, game count and limits under T13 in docs/temp_todo.md.

const Cli := preload("res://tools/lib/cli.gd")
const Pricing := preload("res://tools/lib/skill_pricing.gd")
const Builds := preload("res://tools/lib/sim_builds.gd")
const Runner := preload("res://tools/lib/sim_runner.gd")
const Bots := preload("res://tools/lib/sim_bots.gd")

const OPTIONS: Array[String] = ["builds", "seeds", "pairs-per-seed", "sizes", "bot", "board", "help"]
const DEFAULT_PAIRS := [["test_golem_eruption", "test_golem_rift"], ["test_tiger_eruption", "test_golem_eruption"],
	["test_tiger_shield", "test_golem_shield"]]
const HELP := "compare.gd -- [--builds a,b] [--seeds 1,2,3] [--pairs-per-seed 10] [--sizes 5,7] [--bot greedy] [--board flat|layout]"


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
	if opt.has("builds"):
		var chosen := Cli.names(opt["builds"])
		if chosen.size() != 2 or chosen[0] == chosen[1]:
			return _fail("--builds requires exactly two distinct names: a,b")
		pairs = [chosen]
	var builds := {}
	for pair: Array in pairs:
		for name: String in pair:
			if builds.has(name):
				continue
			if not Builds.list_builds().has(name):
				return _fail("unknown build: %s" % name)
			var result := Builds.build(name)
			if not Builds.fully_simulated(result):
				var why: Array[String] = result["errors"].duplicate()
				for w: String in result["warnings"]:
					if w.to_upper().contains("NOT SIMULATED"):
						why.append(w)
				return _fail("%s: %s" % [name, "; ".join(why)])
			for w: String in result["warnings"]:
				print("NOTE %s: %s" % [name, w])
			builds[name] = result
	for pair: Array in pairs:
		var a: Dictionary = builds[pair[0]]
		var c: Dictionary = builds[pair[1]]
		if not Pricing.same(a["stat_spent"], c["stat_spent"]) or not Pricing.same(a["skill_points"], c["skill_points"]) or a["levels"] != c["levels"]:
			return _fail("%s vs %s: unequal stat/skill spend or slot levels: %s/%s %s != %s/%s %s" % [pair[0], pair[1],
				Pricing.fmt(a["stat_spent"]), Pricing.fmt(a["skill_points"]), a["levels"],
				Pricing.fmt(c["stat_spent"]), Pricing.fmt(c["skill_points"]), c["levels"]])
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
	var rows: Array = [["Build A", "Build B", "Size", "Stat/skill spend", "Games", "Wins A/B/draws", "Score A", "Seed SD",
		"Seed range", "Rounds mean", "Timeouts"]]
	for pair: Array in pairs:
		for size in sizes:
			var row := _row(pair, builds, size, schedule, bot, board)
			if row.is_empty():
				return 2
			rows.append(row)
	print("Bot-vs-bot indications only; no balance validation or price approval. Content %s." % BattleContent.VERSION)
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
	var a: Dictionary = builds[pair[0]]
	return [pair[0], pair[1], str(size), "%s/%s" % [Pricing.fmt(a["stat_spent"]), Pricing.fmt(a["skill_points"])], str(games),
		"%d/%d/%d" % [wins_a, wins_b, draws], "%.3f" % ((wins_a + 0.5 * draws) / games),
		"%.3f" % _sample_sd(block_means) if block_means.size() > 1 else "n/a",
		"%.3f..%.3f" % [block_means.min(), block_means.max()], "%.2f" % (float(rounds) / games), str(timeouts)]


func _sample_sd(values: Array[float]) -> float:
	var mean := 0.0
	for v in values:
		mean += v
	mean /= values.size()
	var sum := 0.0
	for v in values:
		sum += (v - mean) * (v - mean)
	return sqrt(sum / (values.size() - 1))
