extends SceneTree
## Construction-point calculator for skill price records and test builds (gdd_skills §5 drafts;
## an authoring check, not a price authority and never a balance verdict).
##
##   godot --headless --path godot -s res://tools/price.gd -- --list-examples
##   godot --headless --path godot -s res://tools/price.gd -- --example "Slow zone 2 rounds" [--slot-level 2]
##   godot --headless --path godot -s res://tools/price.gd -- scaled_arc [--slot-level 2]
##   godot --headless --path godot -s res://tools/price.gd -- --list-builds
##   godot --headless --path godot -s res://tools/price.gd -- --build test_golem_shield[,more]
##
## A record is named by its id (file name in res://tools/data/prices), its display name or the
## path of a PriceRecord .tres file. Exit codes: 0 fits the ceiling / legal build, 1 over the
## ceiling / illegal build, 2 incomplete, unsupported or unknown. A numeric fit is not approval.
## The rate table is res://tools/lib/skill_pricing.gd.

const Pricing := preload("res://tools/lib/skill_pricing.gd")
const Builds := preload("res://tools/lib/sim_builds.gd")
const Cli := preload("res://tools/lib/cli.gd")

const HELP := "price.gd -- --list-examples | --example NAME | RECORD  [--slot-level 1..3]\n" \
	+ "price.gd -- --list-builds | --build ID[,ID...]"


func _initialize() -> void:
	quit(_run())


func _run() -> int:
	var args := Cli.parse(["list-examples", "list-builds", "help"], ["list-examples", "list-builds", "help", "example", "slot-level", "build"])
	var opt: Dictionary = args["opt"]
	if args["error"] != "" or opt.has("help"):
		print(args["error"] if args["error"] != "" else HELP)
		return 2 if args["error"] != "" else 0
	if opt.has("list-examples"):
		var records := Pricing.load_records()
		for id: String in records:
			print("%-32s %s" % [id, (records[id] as PriceRecord).display_name])
		return 0
	if opt.has("list-builds"):
		print("\n".join(Builds.list_builds()))
		return 0
	if opt.has("build"):
		var code := 0
		for id in Cli.names(opt["build"]):
			var result := Builds.build(id)
			print("\n".join(Builds.report(result)))
			if not result["ok"]:
				code = 1
		return code
	var wanted := String(opt.get("example", args["pos"][0] if not args["pos"].is_empty() else ""))
	if wanted == "":
		print(HELP)
		return 2
	var record := Pricing.find_record(wanted)
	if record == null and wanted.ends_with(".tres") and ResourceLoader.exists(wanted):
		record = load(wanted) as PriceRecord
	if record == null:
		return _incomplete("unknown record '%s' (use --list-examples)" % wanted)
	var level_text := String(opt.get("slot-level", "1"))
	if not level_text.is_valid_int():
		return _incomplete("slot level 1..3")
	var out := Pricing.evaluate(record, level_text.to_int())
	if not out["ok"]:
		return _incomplete(out["error"])
	print("%s: %s of %s at slot level %s -> %s (no approval)" % [out["name"], Pricing.fmt(out["total"]), Pricing.fmt(out["ceiling"]),
		level_text, "fits" if out["fits"] else "OVER THE CEILING"])
	for p: Array in out["parts"]:
		print("  %-36s %s" % [p[0], Pricing.fmt(p[1])])
	if record.paper_total >= 0.0:
		print("  %-36s %s" % ["GDD paper total", Pricing.fmt(record.paper_total)])
	var check := Builds.engine_check(record)
	if check["error"] != "":
		print("  definition: NOT SIMULATED (%s)" % check["error"])
	else:
		print("  definition: %s" % (record.skill.resource_path if not record.skill.resource_path.contains("::") else "fixture embedded in the record"))
		for note: String in check["notes"]:
			print("  note: %s" % note)
	return 0 if out["fits"] else 1


func _incomplete(message: String) -> int:
	print("incomplete (no price, no approval): %s" % message)
	return 2
