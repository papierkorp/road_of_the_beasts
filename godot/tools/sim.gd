extends SceneTree
## Headless AI-vs-AI simulation for balancing and smoke tests.
## godot --headless -s res://tools/sim.gd -- [battles] [mode] [seed]

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var n := int(args[0]) if args.size() > 0 else 20
	var mode := StringName(args[1]) if args.size() > 1 else &"3v3"
	var rng := RandomNumberGenerator.new()
	rng.seed = int(args[2]) if args.size() > 2 else 1
	var wins := [0, 0, 0]
	var rounds_total := 0
	var timeouts := 0
	var by_monster := {}
	var event_counts := {}
	for i in n:
		var size := BattleSetup.team_size(mode)
		var p := BattleSetup.random_enemy([] as Array[StringName], size, rng)
		var e := BattleSetup.random_enemy(p, size, rng)
		var b := BattleSetup.create(mode, p, e)
		b.begin()
		var guard := 0
		while not b.over and guard < 400:
			AiBrain.play_turn(b, b.turn_owner, rng)
			guard += 1
		if not b.over:
			timeouts += 1
		wins[b.winner_side + 1 if b.over else 0] += 1
		rounds_total += b.round_number
		for ev in b.events:
			event_counts[ev["type"]] = event_counts.get(ev["type"], 0) + 1
			if ev["type"] == &"cast":
				var k2 := "cast:" + String(ev["skill"])
				event_counts[k2] = event_counts.get(k2, 0) + 1
			if ev["type"] == &"damage":
				var k3 := "dmg:" + String(ev["source"])
				event_counts[k3] = event_counts.get(k3, 0) + ev["amount"]
		for id in b.roster:
			var m: Monster = b.monsters[id]
			var k := String(m.def.id)
			if not by_monster.has(k):
				by_monster[k] = [0, 0]
			by_monster[k][0] += 1
			if b.over and b.winner_side == m.side:
				by_monster[k][1] += 1
	print("battles=%d mode=%s  side0=%d side1=%d draw/timeout=%d (timeouts %d)  avg rounds=%.1f" % [
		n, mode, wins[1], wins[2], wins[0], timeouts, float(rounds_total) / n])
	for k in by_monster:
		print("  %-16s played %3d  win %5.1f%%" % [k, by_monster[k][0], 100.0 * by_monster[k][1] / by_monster[k][0]])
	var keys := event_counts.keys()
	keys.sort()
	var line := "  events:"
	for k in keys:
		line += " %s=%d" % [k, event_counts[k]]
	print(line)
	quit()
