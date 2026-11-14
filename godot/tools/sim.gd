extends SceneTree
## Headless AI-vs-AI battles: a quick look at flow and stalling, never a balance verdict
## (naive AI, unapproved content; gdd_battle §7.2, temp_todo T13).
## Prints one run block in the fixed format of docs/simulation_log.md, ready to paste there.
##
## godot --headless --path godot -s res://tools/sim.gd -- [battles] [mode] [seed] [state] [kits] [options]
##   state: free label of the code state, e.g. "$(git rev-parse --short HEAD) dirty"
##   a fifth argument "kits" also prints the kit set block (once per content fingerprint)
##
## Without options both sides draw random teams from the TEST kits (data/kits) on a
## seeded draft board and play with AiBrain. Options change the setup; the block names it:
##   --team-a / --team-b  fixed teams: monster ids of data/monsters, also simulation-only ones
##                        (comma lists; --team-b defaults to --team-a), on an empty board with
##                        seeded, mirrored start squares
##   --bot-a / --bot-b    greedy (AiBrain, default; hunt = same) | wait | chase | plan | tactic | rush | kite | random
##                        (tools/lib/sim_bots.gd)
##   --board              kit runs: seeded (default) | layout    build runs: flat (default) | layout | seeded
##   --props a,b          build runs: one mirrored pair per prop id
##   --experiment props   build runs: one block without props, then one per catalogue prop
##                        (--pairs N mirrored pairs each, default 2)
##   --experiment bots    one block per bot pairing
##   --trace              one battle, board before every turn and detailed event timeline after battle
##   --variant a,b        open test switches (battle/core/battle_experiment.gd): push=2 /
##                        push=slide (Strike and Surge pushes and pulls move further) ·
##                        kinpush (Beast Strikes push, a Spirit Strike trades squares)
##                        allpush (every Strike pushes 1 away) · step=1 / jab=1 (AP of Step and of
##                        the Jab) · shieldap=2 / noshield (cost of shield zones, or none usable)
##                        · move=N (AP of slotted movement skills) · defap=N (AP of shield and mend
##                        zones) · zonepush (push / pull zones also move at cast) · alltraps /
##                        alltimed (every marker skill of one kind) · turns=N (timer of Surges)
##                        · aggro (the AI closes in more and values support less)
##                        · groundfade=N (ground laid in battle ends with the N-th round; rule 2, 0 = never) ·
##                        trapfade=N (an unsprung trap ends with the N-th round) · trapcap=N (traps
##                        per trap skill and monster; rule 1, 0 = no limit) ·
##                        shield=N (Surge reduction of shield zones) · startback (back-row starts)
##                        · for this run only: swap=old>new (kits), hp=±N, hpmin=N, hpmax=N,
##                        stat=monster.field:value, tprmax=N, apmin=N, surgedmg=±N, strikedmg=N, zoneonce / castonce (zone
##                        skills / all placed skills once per round)
##                        · currentap=N / currentonce (all in-game PUSH/PULL zone skills: positive AP / once per round)
##                        · openmap (remove preplaced props only) · lifethread (one existing Life Thread per fielded unit)
##   --no-kind-a / -b K   the bot of side 0 / 1 never uses skills of kind K (what is the kind worth)
##   --shield-once        test change: every shield zone skill is once per global round
##   --pressure N         late-round pressure starts N rounds later (negative: earlier)
##   --paired             battle i always starts from seed-derived state i, so runs with different
##                        variants play the same teams and boards (their courses still differ)
##   --compact            one table row per run instead of the full block (--compact-head prints
##                        the header row first)
## Side-swapped comparisons of two monsters: res://tools/compare.gd.

const Cli := preload("res://tools/lib/cli.gd")
const Runner := preload("res://tools/lib/sim_runner.gd")
const Bots := preload("res://tools/lib/sim_bots.gd")
const Gen := preload("res://battle/defs/skill_gen.gd")

const MAX_TURNS := 600
var _shield_ap := 0
var _fielded := {}                      # ids of the skills some fielded monster carried
var _defence_ap := 0
var _mix_kits := false
var _mix_skills := false
var _mix_stats := false
var _gen_skills := 0
var _current_ap := 0
var _current_once := false
var _open_map := false
var _life_thread := false
var _generated: Array[BattleSkillDef] = []
const DAMAGE_KINDS := ["strike", "surge", "ground", "collision", "fall", "collapse", "aftermath", "arena", "well", "flank"]
const OPTIONS: Array[String] = ["bot-a", "bot-b", "team-a", "team-b", "board", "props", "experiment", "pairs", "trace", "help",
	"variant", "shield-once", "pressure", "compact", "compact-head", "paired", "no-kind-a", "no-kind-b"]
const HELP := "sim.gd -- [battles] [mode 1v1|2v2|3v3|5v5] [seed] [state] [kits] [--team-a monsters] [--team-b monsters]\n" \
	+ "          [--bot-a B] [--bot-b B] [--board flat|layout|seeded] [--props ids] [--experiment props|bots] [--pairs N] [--trace]"


func _initialize() -> void:
	quit(_run())


func _fail(message: String) -> int:
	print(message)
	return 2


func _run() -> int:
	var args := Cli.parse(["trace", "help", "shield-once", "compact", "compact-head", "paired"], OPTIONS)
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
	setup["variant"] = String(opt.get("variant", ""))
	setup["shield_once"] = opt.has("shield-once")
	setup["pressure"] = String(opt.get("pressure", "0")).to_int()
	setup["compact"] = opt.has("compact") or opt.has("compact-head")
	setup["compact_head"] = opt.has("compact-head")
	setup["paired"] = opt.has("paired")
	setup["debug"] = OS.has_environment("SIM_DEBUG")
	var why := _apply_variant(setup["variant"])
	BattleExperiment.ai_no_kind[0] = String(opt.get("no-kind-a", ""))
	BattleExperiment.ai_no_kind[1] = String(opt.get("no-kind-b", ""))
	setup["no_kind"] = BattleExperiment.ai_no_kind.duplicate()
	if why != "":
		return _fail(why)
	if setup["shield_once"]:
		for id in BattleContent.shared().skills:
			var def: BattleSkillDef = BattleContent.shared().skills[id]
			if def.kind == BattleSkillDef.ZONE and def.zone != null and def.zone.has_tag(FieldEffect.SHIELD):
				def.repetition = "once_per_round"
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
			for id: String in lists[side]:
				var def := GameData.monster(StringName(id))
				if def == null:
					return _fail("unknown monster '%s' (data/monsters)" % id)
				var sheet := UnitSheets.from_instance(MonsterInstance.of_species(def))
				if not sheet.problems().is_empty():
					return _fail("monster %s has no legal sheet: %s" % [id, "; ".join(sheet.problems())])
				team.append(sheet)
			if team.is_empty():
				return _fail("--team-a / --team-b need at least one monster id")
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


## Sets the experiment switches from a comma list ("" = the confirmed rules).
func _apply_variant(text: String) -> String:
	BattleExperiment.reset()
	_current_ap = 0
	_current_once = false
	_open_map = false
	_life_thread = false
	_mix_kits = false
	_mix_skills = false
	_mix_stats = false
	_gen_skills = 0
	for part in Cli.names(text):
		var kv := part.split("=")
		var key := kv[0]
		var val := kv[1] if kv.size() > 1 else ""
		match key:
			"currentap":
				if kv.size() != 2 or not val.is_valid_int() or val.to_int() < 1:
					return "currentap needs a positive integer (got '%s')" % val
				_current_ap = val.to_int()
			"currentonce":
				_current_once = true
			"openmap":
				_open_map = true
			"lifethread":
				_life_thread = true
			"push":
				BattleExperiment.push_steps = 99 if val == "slide" else maxi(1, val.to_int())
			"kinpush":
				BattleExperiment.kin_push = true
			"step":
				BattleExperiment.step_ap = maxi(1, val.to_int())
			"jab":
				BattleExperiment.jab_ap = maxi(1, val.to_int())
			"aggro":
				BattleExperiment.ai_aggressive = true
			"strikedmg":
				for sid in BattleContent.shared().skills:
					var sd: BattleSkillDef = BattleContent.shared().skills[sid]
					if sd.kind == BattleSkillDef.STRIKE and sd.strike_damage > 0:
						sd.strike_damage = clampi(val.to_int(), 0, 4)
			"norotate":
				BattleExperiment.no_rotation = true
			"move":
				BattleExperiment.move_ap = maxi(1, val.to_int())
			"freeap", "freemod":                     # movement skills other than Run: their AP / squares taken off Movement
				for sid in BattleContent.shared().skills:
					var sd: BattleSkillDef = BattleContent.shared().skills[sid]
					if sd.kind == BattleSkillDef.MOVE and sd.id != &"run":
						if key == "freeap":
							sd.ap_cost = maxi(1, val.to_int())
						else:
							sd.distance_mod = -absi(val.to_int())
			"defap":
				_defence_ap = maxi(1, val.to_int())
			"shieldap":
				_shield_ap = maxi(1, val.to_int())
			"groundfade":
				BattleExperiment.ground_rounds = maxi(0, val.to_int())
			"trapfade":
				BattleExperiment.trap_rounds = maxi(1, val.to_int())
			"startback":
				BattleExperiment.start_back = true
			"trapcap":
				BattleExperiment.trap_cap = maxi(0, val.to_int())
			"wells":
				BattleExperiment.wells = maxi(0, val.to_int())
			"noflank":
				BattleExperiment.flank = false
			"tpr1":
				BattleExperiment.tpr_from_round = 1
			"flank":
				BattleExperiment.flank = true
			"delay":                                  # delay | delay=reverse | delay=first (round 1: two-turn monsters and the fastest)
				BattleExperiment.delay_turn = true
				BattleExperiment.delay_reverse = val == "reverse"
				BattleExperiment.delay_first_round = val == "first"
			"mixkits":                                # every monster plays a random kit of the game's monsters
				_mix_kits = true
			"mixskills":                              # every monster plays four random skills (one of them deals damage)
				_mix_skills = true
			"genskills":                              # genskills=N: mixskills draws from N generated skills (tools/lib/skill_gen.gd)
				_gen_skills = maxi(8, val.to_int())
				_mix_skills = true
			"veinhold":                               # a Dragon Vein only works while a monster stands on it (rule before the reshape)
				BattleExperiment.vein_touch = false
			"unfairsurge":                            # a due Surge does not wait for the monsters on it (rule before the reshape)
				BattleExperiment.surge_fair = false
			"mixstats":                               # every monster plays random stats: HP 3-8, initiative 1-9, Movement 1-5, Reach 2-4, TPR 1-2, AP 2-3
				_mix_stats = true
			"calm":                                   # calm=N: no damage in the first N rounds
				BattleExperiment.damage_from_round = maxi(1, val.to_int()) + 1
			"surgewall":
				BattleExperiment.surge_wall = true
			"surgeground":
				BattleExperiment.surge_ground = StringName(val if val != "" else "thornbed")
			"castersurge":
				BattleExperiment.surge_at_caster = true
			"fairsurge":
				BattleExperiment.surge_fair = true
			"tpr2":
				BattleExperiment.tpr_from_round = 2
			"latepressure":
				if val != "none" and val != "idle" and val != "always":
					return "latepressure needs none, idle or always (got '%s')" % val
				BattleExperiment.pressure_mode = val
			"softpressure":
				BattleExperiment.soft_pressure = maxi(1, val.to_int())
			"noshield":
				BattleExperiment.no_shield_zones = true
			"hp":
				for mid in BattleContent.shared().monsters:
					var md: MonsterDef = BattleContent.shared().monsters[mid]
					md.hp = clampi(md.hp + val.to_int(), 1, 10)
			"surgedmg":
				for sid in BattleContent.shared().skills:
					var sd: BattleSkillDef = BattleContent.shared().skills[sid]
					if sd.is_marker():
						sd.surge_damage = maxi(1, sd.surge_damage + val.to_int())
			"swap":
				var pair := val.split(">")
				var skills: Dictionary = BattleContent.shared().skills
				if pair.size() != 2 or not skills.has(StringName(pair[0])) or not skills.has(StringName(pair[1])):
					return "swap needs old>new with two skill ids of data/skills (got '%s')" % val
				for mid in BattleContent.shared().monsters:
					var md: MonsterDef = BattleContent.shared().monsters[mid]
					for i in md.skills.size():
						if md.skills[i].id == StringName(pair[0]):
							md.skills[i] = skills[StringName(pair[1])]
			"stat":                                   # stat=monster.field:value, this run only
				var sv := val.split(":")
				var mf := sv[0].split(".")
				var smd: MonsterDef = BattleContent.shared().monsters.get(StringName(mf[0])) if mf.size() == 2 and sv.size() == 2 else null
				if smd == null or not (mf[1] in smd):
					return "stat needs monster.field:value (got '%s')" % val
				smd.set(mf[1], sv[1].to_float() if mf[1] == "initiative" else sv[1].to_int())
			"hpmin", "hpmax":
				for mid in BattleContent.shared().monsters:
					var md: MonsterDef = BattleContent.shared().monsters[mid]
					md.hp = maxi(md.hp, val.to_int()) if key == "hpmin" else mini(md.hp, maxi(1, val.to_int()))
			"shield":
				for zid in BattleContent.shared().zones:
					for fe: FieldEffect in (BattleContent.shared().zones[zid] as BattleZoneDef).effects:
						if fe.tag == FieldEffect.SHIELD:
							fe.base = maxi(1, val.to_int())
							fe.cap = fe.base
			"tprmax", "apmin":
				for mid in BattleContent.shared().monsters:
					var md: MonsterDef = BattleContent.shared().monsters[mid]
					if key == "tprmax":
						md.tpr = mini(md.tpr, maxi(1, val.to_int()))
					else:
						md.ap = maxi(md.ap, val.to_int())
			"zoneonce", "castonce":
				for sid in BattleContent.shared().skills:
					var sd: BattleSkillDef = BattleContent.shared().skills[sid]
					if sd.kind == BattleSkillDef.ZONE or (key == "castonce" and sd.is_placed()):
						sd.repetition = "once_per_round"
			"alltraps", "alltimed":
				for sid in BattleContent.shared().skills:
					var sd: BattleSkillDef = BattleContent.shared().skills[sid]
					if sd.is_marker():
						sd.kind = BattleSkillDef.TRAP if key == "alltraps" else BattleSkillDef.SURGE
			"turns":
				for sid in BattleContent.shared().skills:
					var sd: BattleSkillDef = BattleContent.shared().skills[sid]
					if sd.kind == BattleSkillDef.SURGE:
						sd.surge_turns = maxi(1, val.to_int())
			_:
				return "unknown variant '%s' (push, kinpush, step, jab, move, freeap, freemod, mixkits, mixskills, mixstats, genskills, veinhold, unfairsurge, calm, surgewall, surgeground, strikedmg, norotate, aggro, defap, shieldap, noshield, softpressure, alltraps, alltimed, turns, hp, hpmin, hpmax, tprmax, apmin, surgedmg, swap, shield, zoneonce, castonce, currentap, currentonce, openmap, lifethread, groundfade, trapfade, startback, trapcap)" % key
	if _defence_ap > 0:
		for sid in BattleContent.shared().skills:
			var sd: BattleSkillDef = BattleContent.shared().skills[sid]
			if sd.kind == BattleSkillDef.ZONE and sd.zone != null and (sd.zone.has_tag(FieldEffect.SHIELD) or sd.zone.has_tag(FieldEffect.MEND)):
				sd.ap_cost = _defence_ap          # protecting and healing zones
	if _shield_ap > 0:
		for sid in BattleContent.shared().skills:
			var sd: BattleSkillDef = BattleContent.shared().skills[sid]
			if sd.kind == BattleSkillDef.ZONE and sd.zone != null and sd.zone.has_tag(FieldEffect.SHIELD):
				sd.ap_cost = _shield_ap           # 99 = nobody can pay for it
	if _current_ap > 0 or _current_once:
		for sid in BattleContent.shared().skills:
			var sd: BattleSkillDef = BattleContent.shared().skills[sid]
			if ContentStatus.in_game(sd) and sd.kind == BattleSkillDef.ZONE and sd.zone != null \
					and (sd.zone.has_tag(FieldEffect.PUSH) or sd.zone.has_tag(FieldEffect.PULL)):
				if _current_ap > 0:
					sd.ap_cost = _current_ap
				if _current_once:
					sd.repetition = "once_per_round"
	return ""


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
	var by_kit := {}                      # mixkits: kit donor -> [played, won]; "body+kit" -> the same
	var kit_of := {}                      # mix variants: unit id -> tags of what it drew in this battle
	var damage := {}                      # kind -> total
	var damage_by_source := {}            # kind -> source -> [damage sum, positive instances]
	var activations := {}                 # skill -> total activation events
	var repeated_activations := {}        # skill -> second and later activations within one turn
	var counts := {&"surge_declared": 0, &"strike": 0, &"cast": 0, &"prop_destroyed": 0, &"defeated": 0}
	var props_placed := {}                # prop id -> count at battle start
	var skills_used := {}                 # skill id -> uses
	var board_size := 0
	var pressure_from := 0
	var extra := {"fired": 0, "fired_hit": 0, "left": 0, "enemy_dmg": 0, "own_dmg": 0, "edge_dmg": 0, "dodges": 0, "early": 0, "surge_kills": 0}
	var void_damage := 0                   # Voidscar part of the ground damage
	var slots_by_kind := {}                # kit slots of all fielded monsters, by skill kind
	var trap_damage := 0                   # trap part of the Surge damage
	var defeats_by := {}                   # last damage kind of every defeated monster
	var ended_by := {}                     # the same for the last defeat of each battle
	var well_held := [0, 0, 0, 0, 0]     # Wellsprings held at round ends by side 0, side 1; round ends counted; bonus squares taken by side 0, side 1
	# battles that reached late-round pressure: [HP leader won, HP leader lost, HP level, Draw or timeout after a lead]
	var lead := [0, 0, 0, 0]
	var length := [0, 0, 0, 0, 0, 0]       # battles under 3 rounds, over 7, over 10; the longest battle; under 2, over 5 (mean target 3–5)
	var round_histogram := {}
	var outliers: Array[String] = []
	var slots_by_skill := {}
	_fielded.clear()
	var unacted := 0                       # monsters defeated before their own first turn
	var unacted_battles := 0
	var first_defeat := [0, 0]             # rounds of the first defeat summed, battles with a defeat
	for i in n:
		if setup["paired"]:
			rng.seed = seed_value * 1000003 + i
		var battle_seed: int = seed_value * 1000003 + i if setup["paired"] else seed_value
		var start_rng_state: int = rng.state
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
		if _open_map:
			# Board-only removal: no destruction, aftermath, RNG draw or regeneration.
			for prop in b.board.props():
				b.board.remove_prop(prop)
		kit_of.clear()
		if _mix_kits or _mix_skills:
			var donors := content.game_monster_ids()
			for mid in BattleContent.sorted_ids(content.monsters):       # plus the simulation-only kits
				if String(mid).begins_with("kit_"):
					donors.append(mid)
			var pool: Array[BattleSkillDef] = []                         # every skill the game can field
			for sid in BattleContent.sorted_ids(content.skills):
				var psd: BattleSkillDef = content.skills[sid]
				if ContentStatus.in_game(psd):
					pool.append(psd)
			if _gen_skills > 0:                                           # generated skills replace the pool
				if _generated.is_empty():
					var grng := RandomNumberGenerator.new()
					grng.seed = 4711
					for gi in _gen_skills:
						_generated.append(Gen.draw(content, grng, gi))
				pool.assign(_generated)
			for id in b.roster:
				var mu: BattleUnit = b.units[id]
				if _mix_kits:
					var donor: StringName = donors[rng.randi_range(0, donors.size() - 1)]
					mu.sheet.skills = content.monster(donor).skills.duplicate()
					kit_of[id] = ["kit:%s" % donor, "pair:%s+%s" % [mu.sheet.species_id, donor]]
					continue
				var drawn: Array[BattleSkillDef] = []
				while drawn.size() < 4:
					var sd: BattleSkillDef = pool[rng.randi_range(0, pool.size() - 1)]
					var harms: bool = (sd.kind == BattleSkillDef.STRIKE and sd.strike_damage > 0) or sd.is_marker()
					if drawn.has(sd) or (drawn.is_empty() and not harms):
						continue                      # the first slot deals damage
					drawn.append(sd)
				mu.sheet.skills = drawn
				var tags: Array = []
				for sd in drawn:
					if sd.has_meta("parts"):
						for part: String in sd.get_meta("parts"):
							tags.append("part:%s" % part)
					else:
						tags.append("skill:%s" % sd.id)
				kit_of[id] = tags
		if _mix_stats:
			for id in b.roster:
				var mu: BattleUnit = b.units[id]
				var sh := mu.sheet
				sh.hp = rng.randi_range(3, 8)
				sh.initiative = float(rng.randi_range(1, 9))
				sh.movement = rng.randi_range(1, 5)
				sh.reach = rng.randi_range(2, 4)
				sh.tpr = rng.randi_range(1, 2)
				sh.ap = rng.randi_range(2, 3)
				mu.max_hp = sh.hp
				mu.hp = sh.hp
				var tags: Array = kit_of.get(id, [])
				tags.append_array(["stat:hp=%d" % sh.hp, "stat:init=%d" % int(sh.initiative), "stat:move=%d" % sh.movement,
					"stat:reach=%d" % sh.reach, "stat:tpr=%d" % sh.tpr, "stat:ap=%d" % sh.ap])
				kit_of[id] = tags
		board_size = b.board.size
		b.voidscar_from += int(setup["pressure"])
		pressure_from = b.voidscar_from
		for prop in b.board.props():
			props_placed[prop.def.id] = int(props_placed.get(prop.def.id, 0)) + 1
		if _life_thread:
			for id in b.roster:
				var unit: BattleUnit = b.units[id]
				if unit.on_field:
					unit.life_thread = true
		b.begin()
		var guard := 0
		var hp_at_pressure: Array = []
		while not b.over and guard < MAX_TURNS:
			var active := b.active()
			if hp_at_pressure.is_empty() and b.round_number > b.voidscar_from:
				hp_at_pressure = [0, 0]              # first turn after pressure began
				for lu in b.living():
					hp_at_pressure[lu.side] += lu.hp
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
		round_histogram[b.round_number] = int(round_histogram.get(b.round_number, 0)) + 1
		if not setup["compact"] and (b.round_number < 2 or b.round_number > 5):
			var teams: Array[PackedStringArray] = [PackedStringArray(), PackedStringArray()]
			for id in b.roster:
				var unit: BattleUnit = b.units[id]
				teams[unit.side].append(String(unit.sheet.species_id))
			var winner := "timeout" if not b.over else ("Draw" if b.draw else "side %d" % b.winner_side)
			outliers.append("| %d | %d | %d | %s | %s | %s | %d |" % [
				i + 1, battle_seed, start_rng_state, ", ".join(teams[0]), ", ".join(teams[1]), winner, b.round_number])
		rounds_total += b.round_number
		length[0] += 1 if b.round_number < 3 else 0
		length[1] += 1 if b.round_number > 7 else 0
		length[2] += 1 if b.round_number > 10 else 0
		length[3] = maxi(length[3], b.round_number)
		length[4] += 1 if b.round_number < 2 else 0
		length[5] += 1 if b.round_number > 5 else 0
		if not hp_at_pressure.is_empty():
			if hp_at_pressure[0] == hp_at_pressure[1]:
				lead[2] += 1
			elif not b.over or b.draw:
				lead[3] += 1
			else:
				var ahead := 0 if hp_at_pressure[0] > hp_at_pressure[1] else 1
				lead[0 if b.winner_side == ahead else 1] += 1
		if b.over and b.round_number <= b.voidscar_from:
			extra["early"] += 1
		var pending := {}                 # surge id -> threatened squares
		var last_surge_victim := {}       # unit id -> true if its last damage was Surge damage
		var last_kind := {}               # unit id -> kind of its last damage ("void" = Voidscar)
		var hit_log := {}                 # unit id -> its damage instances as text (SIM_DEBUG)
		var final_kind := ""
		var acted := {}                   # unit id -> it has started a turn of its own
		var event_round := 1
		var had_defeat := false
		var had_unacted_defeat := false
		var turn_activations := {}
		if setup["trace"]:
			print("Event timeline after battle (round · event dictionary):")
		extra["left"] += b.surges.size()
		for ev in b.events:
			match ev["type"]:
				&"surge_declared":
					var threat: Array[Vector2i] = []
					threat.assign(ev["cells"])
					pending[ev["surge"]] = threat
				&"surge_fired":
					pending.erase(ev["surge"])
					extra["fired"] += 1
					if not (ev.get("struck", []) as Array).is_empty():
						extra["fired_hit"] += 1
				&"moved":
					for sid in pending:
						if pending[sid].has(ev["from"]) and not pending[sid].has(ev["to"]):
							extra["dodges"] += 1
							break
				&"round_started":
					event_round = int(ev["round"])
				&"wells_held":
					well_held[0] += int(ev["held"][0])
					well_held[1] += int(ev["held"][1])
					well_held[2] += 1
				&"turn_started":
					acted[ev["who"]] = true
					turn_activations.clear()
				&"defeated":
					if not acted.has(ev["who"]):
						unacted += 1
						had_unacted_defeat = true
					if setup.get("debug", false):
						print("DBG round %d: %s defeated by %s (acted %s)" % [event_round, ev["who"], last_kind.get(ev["who"], "other"), acted.has(ev["who"])])
						print("DBGHIT round %d | %s | hp %d | %s" % [event_round, b.units[ev["who"]].sheet.species_id, b.units[ev["who"]].max_hp, " + ".join(hit_log.get(ev["who"], PackedStringArray()))])
					if not had_defeat:
						had_defeat = true
						first_defeat[0] += event_round
						first_defeat[1] += 1
					if last_surge_victim.get(ev["who"], false):
						extra["surge_kills"] += 1
					final_kind = String(last_kind.get(ev["who"], "other"))
					defeats_by[final_kind] = int(defeats_by.get(final_kind, 0)) + 1
			if ev["type"] == &"damage":
				if int(ev["amount"]) > 0:
					if setup.get("debug", false):
						if not hit_log.has(ev["target"]):
							hit_log[ev["target"]] = PackedStringArray()
						hit_log[ev["target"]].append("r%d %s %s %d" % [event_round, ev["kind"], ev.get("source", ""), int(ev["amount"])])
					var kind := String(ev["kind"])
					if kind == "surge" and ev.get("trap", false):
						kind = "trap"
						trap_damage += int(ev["amount"])
					elif kind == "ground" and String(ev.get("source", "")) == "Voidscar":
						kind = "void"
						void_damage += int(ev["amount"])
					elif kind == "fall":
						kind = "collision"
					last_kind[ev["target"]] = kind
				last_surge_victim[ev["target"]] = ev["kind"] == "surge" and int(ev["amount"]) > 0
				if ev["kind"] == "surge" and int(ev["amount"]) > 0:
					var by: StringName = ev.get("by", &"")
					var foe: bool = by == &"" or b.units[by].side != b.units[ev["target"]].side
					extra["enemy_dmg" if foe else "own_dmg"] += int(ev["amount"])
					if String(ev.get("source", "")).ends_with("(edge)"):
						extra["edge_dmg"] += int(ev["amount"])
			if setup["trace"] and ev["type"] in [&"turn_started", &"cast", &"strike", &"moved", &"damage", &"collision", &"defeated", &"round_started", &"displaced", &"survived", &"wells_held"]:
				print("round %d · %s" % [event_round, str(ev)])
			if ev["type"] == &"damage":
				var raw_kind := String(ev["kind"])
				var source := String(ev.get("source", ""))
				if not damage_by_source.has(raw_kind):
					damage_by_source[raw_kind] = {}
				var sources: Dictionary = damage_by_source[raw_kind]
				if not sources.has(source):
					sources[source] = [0, 0]
				sources[source][0] += int(ev["amount"])
				if int(ev["amount"]) > 0:
					sources[source][1] += 1
				damage[ev["kind"]] = int(damage.get(ev["kind"], 0)) + int(ev["amount"])
			elif counts.has(ev["type"]):
				counts[ev["type"]] += 1
			if ev["type"] in [&"surge_declared", &"cast", &"strike", &"moved"] and ev.has("skill"):
				var key := String(ev["skill"])
				# Only movement events use display names; resolve against the actor's actual kit.
				if ev["type"] == &"moved" and key != "Step":
					var actor: BattleUnit = b.units[ev["who"]]
					for sk in actor.sheet.skills:
						if sk.kind == BattleSkillDef.MOVE and sk.display_name == key:
							key = String(sk.id)
							break
				skills_used[key] = int(skills_used.get(key, 0)) + 1
				# These are one-per-activation events, not later zone/displacement/damage ticks.
				# Events carry no slot; use actor + resolved skill as the fallback identity.
				if key != "Step":
					var actor_id := String(ev["who"])
					if not turn_activations.has(actor_id):
						turn_activations[actor_id] = {}
					var actor_uses: Dictionary = turn_activations[actor_id]
					activations[key] = int(activations.get(key, 0)) + 1
					if actor_uses.has(key):
						repeated_activations[key] = int(repeated_activations.get(key, 0)) + 1
					actor_uses[key] = true
		if had_unacted_defeat:
			unacted_battles += 1
		if setup.get("debug", false):
			print("DBG end: winner %s after %d rounds" % [str(b.winner_side) if b.over and not b.draw else "none", b.round_number])
		if b.over and final_kind != "":
			ended_by[final_kind] = int(ended_by.get(final_kind, 0)) + 1
		for id in b.roster:
			var u: BattleUnit = b.units[id]
			for sk in u.sheet.skills:              # what the kits offer, by skill kind
				_fielded[sk.id] = true
				var skill_id := String(sk.id)
				slots_by_skill[skill_id] = int(slots_by_skill.get(skill_id, 0)) + 1
				slots_by_kind[sk.kind] = int(slots_by_kind.get(sk.kind, 0)) + 1
			var k := "%s · side %d" % [u.sheet.species_id, u.side] if builds else String(u.sheet.species_id)
			if not by_monster.has(k):
				by_monster[k] = [0, 0]
			by_monster[k][0] += 1
			if b.over and b.winner_side == u.side:
				by_monster[k][1] += 1
			if kit_of.has(id):
				for kk: String in kit_of[id]:
					if not by_kit.has(kk):
						by_kit[kk] = [0, 0]
					by_kit[kk][0] += 1
					if b.over and b.winner_side == u.side:
						by_kit[kk][1] += 1

	var total_damage := 0
	for k in damage:
		total_damage += int(damage[k])
	var per := func(a: int, c: int) -> String: return "%.2f" % (float(a) / c) if c > 0 else "—"
	var share := func(a: int) -> String: return "%d %%" % roundi(100.0 * a / total_damage) if total_damage > 0 else "—"
	var fingerprint := content.fingerprint().left(12)
	var declared: int = counts[&"surge_declared"]
	var surge_total := int(damage.get("surge", 0))
	if setup["compact"]:
		var kinds := ["strike", "surge", "trap", "ground", "collision", "void", "arena"]
		var by := func(table: Dictionary, total: int) -> String:
			var parts: PackedStringArray = []
			for k: String in kinds:
				parts.append(str(roundi(100.0 * int(table.get(k, 0)) / total)) if total > 0 else "—")
			return " / ".join(parts)
		var hazard := int(damage.get("ground", 0)) - void_damage
		var dmg_table := {"strike": int(damage.get("strike", 0)), "surge": surge_total - trap_damage, "trap": trap_damage, "ground": hazard,
			"collision": int(damage.get("collision", 0)) + int(damage.get("fall", 0)), "void": void_damage, "arena": int(damage.get("arena", 0))}
		if setup["compact_head"]:
			print("| Variant | Mode · seed · battles | Side 0 / 1 / Draw / timeout | Mean rounds | Ended before pressure | Last defeat by strike / Surge / trap / hazard ground / collision / Voidscar / arena (%) | All defeats by the same kinds (%) | Damage by the same kinds (%) | Surges and traps cast | detonated on a monster / without one / left at the end | their dmg per cast: enemies / own side | total dmg | Uses per battle: strike / surge / trap / zone / board / move / Step | Kit slots per battle: strike / surge / trap / zone / board / move / passive | Uses per slot and battle: strike / surge / trap / zone / board / move | Most used skill (share of all uses) | Skills never used | Reached pressure: HP leader won / lost / HP level / no winner | Rounds under 3 / over 7 / over 10 (%) · longest | First defeat in round (mean) | Defeated before own first turn (per battle) | Wellspring / surrounded: last defeat · all defeats · damage (%) · Wellsprings held per round end, side 0 / 1 |")
			print("|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|")
		print("| %s | %s · %d · %d | %d / %d / %d / %d | %.1f | %d %% | %s | %s | %s | %s | %s / %s / %s | %s / %s | %s | %s | %s | %s | %s | %s | %d / %d / %d / %d | %d / %d / %d · %d | %s | %s | %s |" % ([
			_variant_text(setup), mode, seed_value, n, wins[0], wins[1], draws, timeouts, float(rounds_total) / n,
			roundi(100.0 * extra["early"] / n), by.call(ended_by, n - timeouts), by.call(defeats_by, counts[&"defeated"]),
			by.call(dmg_table, total_damage), per.call(declared, n), per.call(extra["fired_hit"], n),
			per.call(extra["fired"] - extra["fired_hit"], n), per.call(declared - extra["fired"], n),
			per.call(extra["enemy_dmg"], declared), per.call(extra["own_dmg"], declared), per.call(total_damage, n)] + _usage_columns(content, skills_used, slots_by_kind, n) + lead + [roundi(100.0 * length[0] / n), roundi(100.0 * length[1] / n), roundi(100.0 * length[2] / n), length[3],
			("%.1f" % (float(first_defeat[0]) / first_defeat[1])) if first_defeat[1] > 0 else "—", per.call(unacted, n), _well_column(ended_by, n - timeouts, defeats_by, counts[&"defeated"], damage, total_damage, well_held, n)]))
		return 0

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
		print("| Units | fixed teams (data/monsters): %s (side 0) against %s (side 1) |" % setup["team_names"])
	else:
		print("| Units | random teams from kit set `%s` |" % fingerprint)
	print("| Props placed | %s |" % _pairs(props_placed, n, true))
	if bots == (["greedy", "greedy"] as Array[String]):
		print("| Loadout / AI | no tamer skills · `AiBrain` (one-step evaluation) on both sides |")
	else:
		print("| Loadout / AI | no tamer skills · bots `%s` (side 0) and `%s` (side 1), tools/lib/sim_bots.gd |" % bots)
	if _variant_text(setup) != "build rules":
		print("| Experiment | %s (in-memory simulation variants / battle experiment switches) |" % _variant_text(setup))
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
	print("Damage by raw event kind and source (collision rows are collision damage only; no fall reclassification):")
	print("| Damage kind | Source | Damage sum | Positive instances |")
	print("|---|---|---|---|")
	var source_kinds := damage_by_source.keys()
	source_kinds.sort()
	for kind: String in source_kinds:
		var sources: Dictionary = damage_by_source[kind]
		var source_names := sources.keys()
		source_names.sort()
		for source: String in source_names:
			print("| %s | %s | %d | %d |" % [kind, source if source != "" else "(unspecified)", sources[source][0], sources[source][1]])
	if not damage_by_source.has("collision"):
		print("| collision | (none) | 0 | 0 |")
	print("")
	print("Skill activations (not later zone ticks; repeats count second and later actor + skill activations within the same turn):")
	print("| Skill | Activations | Repeated activations in same turn |")
	print("|---|---|---|")
	var activation_names := activations.keys()
	activation_names.sort()
	for sid: String in activation_names:
		print("| %s | %d | %d |" % [sid, activations[sid], int(repeated_activations.get(sid, 0))])
	print("Defeats before own first turn: %d exact; battles with at least one: %d / %d" % [unacted, unacted_battles, n])
	print("")
	print("| Surges declared | Surge damage per Surge | Strikes | Strike damage per Strike | Zone / board casts |")
	print("|---|---|---|---|---|")
	print("| %d | %s | %d | %s | %d |" % [counts[&"surge_declared"], per.call(int(damage.get("surge", 0)), counts[&"surge_declared"]),
		counts[&"strike"], per.call(int(damage.get("strike", 0)), counts[&"strike"]), counts[&"cast"]])
	print("")
	print("| Ended before pressure | Surge damage on enemies / own side per Surge | Edge share of Surge damage | Leaving moves per Surge | Defeats by Surge per battle |")
	print("|---|---|---|---|---|")
	print("| %d %% | %s / %s | %s | %s | %s |" % [roundi(100.0 * extra["early"] / n), per.call(extra["enemy_dmg"], declared),
		per.call(extra["own_dmg"], declared), ("%d %%" % roundi(100.0 * extra["edge_dmg"] / surge_total)) if surge_total > 0 else "—",
		per.call(extra["dodges"], declared), per.call(extra["surge_kills"], n)])
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
	if not by_kit.is_empty():
		print("")
		print("| Random draw (mixkits / mixskills / mixstats) | Played | Won | Win rate |")
		print("|---|---|---|---|")
		var kk_names := by_kit.keys()
		kk_names.sort()
		for kk: String in kk_names:
			print("| %s | %d | %d | %.2f %% |" % [kk, by_kit[kk][0], by_kit[kk][1], 100.0 * by_kit[kk][1] / by_kit[kk][0]])
	print("")
	print("| Fielded skill | Uses | Fielded slots | Uses/slot |")
	print("|---|---|---|---|")
	var skill_names := slots_by_skill.keys()
	skill_names.sort_custom(func(a: String, c: String) -> bool:
		var ua := int(skills_used.get(a, 0))
		var uc := int(skills_used.get(c, 0))
		return ua > uc if ua != uc else a < c)
	for sid: String in skill_names:
		var uses := int(skills_used.get(sid, 0))
		print("| %s | %d | %d | %s |" % [sid, uses, slots_by_skill[sid], per.call(uses, slots_by_skill[sid])])
	print("Step uses (not a kit slot): %d" % int(skills_used.get("Step", 0)))
	print("")
	print("Reached late-round pressure: HP leader won %d, lost %d, HP level %d, no winner %d" % lead)
	print("Rounds: under 3 in %d %%, over 7 in %d %%, over 10 in %d %% of the battles, longest %d; first defeat in round %s (mean); monsters defeated before their own first turn: %s per battle" % [
		roundi(100.0 * length[0] / n), roundi(100.0 * length[1] / n), roundi(100.0 * length[2] / n), length[3],
		("%.1f" % (float(first_defeat[0]) / first_defeat[1])) if first_defeat[1] > 0 else "—", per.call(unacted, n)])
	print("Mean target 3-5 rounds; outliers <2 / >5: ended in round 1 in %d %%, after round 5 in %d %% of the battles" % [roundi(100.0 * length[4] / n), roundi(100.0 * length[5] / n)])
	print("")
	print("| Exact round count | Battles | Share |")
	print("|---|---|---|")
	var round_keys := round_histogram.keys()
	round_keys.sort()
	for rounds: int in round_keys:
		print("| %d | %d | %.2f %% |" % [rounds, round_histogram[rounds], 100.0 * int(round_histogram[rounds]) / n])
	print("")
	print("Outliers (<2 or >5 rounds), including Draws and timeouts:")
	print("| Battle (1-based) | Seed | RNG state before setup | Team side 0 | Team side 1 | Winner / result | Rounds |")
	print("|---|---|---|---|---|---|---|")
	for line in outliers:
		print(line)
	if outliers.is_empty():
		print("none")
	if label != "":
		print("")
	return 0


## Five compact columns on how the kits are used: uses per kind, slots per kind, uses per slot,
## the most used skill and the fielded skills nobody used. A skill is counted under its kind;
## movement events carry the display name, so both names are looked up.
func _usage_columns(content: BattleContent, used: Dictionary, slots: Dictionary, n: int) -> Array:
	var kind_of := {"Step": "step"}
	for sid in content.skills:
		var sd: BattleSkillDef = content.skills[sid]
		kind_of[String(sid)] = sd.kind
		kind_of[sd.display_name] = sd.kind
	var uses := {}
	var total := 0
	var top := ""
	for key: String in used:
		var k: String = kind_of.get(key, "other")
		uses[k] = int(uses.get(k, 0)) + int(used[key])
		total += int(used[key])
		if top == "" or int(used[key]) > int(used[top]):
			top = key
	var kinds := ["strike", "surge", "trap", "zone", "ground", "move"]
	var a: PackedStringArray = []
	var c: PackedStringArray = []
	var d: PackedStringArray = []
	for k: String in kinds:
		a.append("%.1f" % (float(uses.get(k, 0)) / n))
		c.append("%.1f" % (float(slots.get(k, 0)) / n))
		d.append("%.2f" % (float(uses.get(k, 0)) / float(slots[k])) if int(slots.get(k, 0)) > 0 else "—")
	a.append("%.1f" % (float(uses.get("step", 0)) / n))
	c.append("%.1f" % (float(slots.get("passive", 0)) / n))
	var unused: PackedStringArray = []
	for sid in content.skills:
		var sd: BattleSkillDef = content.skills[sid]
		if sd.is_active() and not used.has(String(sid)) and not used.has(sd.display_name) and _fielded.has(sid):
			unused.append(String(sid))
	unused.sort()
	return [" / ".join(a), " / ".join(c), " / ".join(d),
		("%s %d %%" % [top, roundi(100.0 * int(used[top]) / total)]) if total > 0 else "—",
		", ".join(unused) if not unused.is_empty() else "none"]


## The experiment switches and test changes of a run in one phrase.
func _variant_text(setup: Dictionary) -> String:
	var parts: PackedStringArray = []
	if setup["variant"] != "":
		parts.append(setup["variant"])
	if setup["shield_once"]:
		parts.append("shield-once")
	if int(setup["pressure"]) != 0:
		parts.append("pressure %+d" % int(setup["pressure"]))
	for side in 2:
		if setup["no_kind"][side] != "":
			parts.append("side %d without %s" % [side, setup["no_kind"][side]])
	var bots: Array[String] = setup["bots"]
	if bots != (["greedy", "greedy"] as Array[String]):
		parts.append("bots %s" % (bots[0] if bots[0] == bots[1] else "%s / %s" % bots))
	return "build rules" if parts.is_empty() else " + ".join(parts)


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
	for id: StringName in content.game_monster_ids():
		var m := content.monster(id)
		var names: PackedStringArray = []
		for s in m.skills:
			names.append(String(s.id))
		parts.append("%s %d/%.0f/%d/%d/%d/%d: %s" % [id, m.hp, m.initiative, m.move, m.tpr, m.reach, m.ap, ", ".join(names)])
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


## Compact column of the Wellspring draft: share of last defeats, of all defeats and of the damage
## by Wellsprings / by being surrounded, and the Wellsprings held per round end by each side.
func _well_column(ended_by: Dictionary, ended: int, defeats_by: Dictionary, defeats: int, damage: Dictionary, total: int, held: Array, battles: int) -> String:
	if BattleExperiment.wells <= 0 and not BattleExperiment.flank:
		return "—"
	var pct := func(table: Dictionary, k: String, of: int) -> String: return str(roundi(100.0 * int(table.get(k, 0)) / of)) if of > 0 else "—"
	var per_round := "—"
	if int(held[2]) > 0:
		per_round = "%.2f / %.2f" % [float(held[0]) / held[2], float(held[1]) / held[2]]
	return "%s / %s · %s / %s · %s / %s · %s" % [pct.call(ended_by, "well", ended), pct.call(ended_by, "flank", ended),
		pct.call(defeats_by, "well", defeats), pct.call(defeats_by, "flank", defeats), pct.call(damage, "well", total), pct.call(damage, "flank", total), per_round]
