class_name MonsterDraw
extends RefCounted
## Test switch `random_monsters` (user request 2026-11-17): every monster of a battle gets random stats and
## a random Kin, bought with the monster calculation (MonsterDef.points_of, gdd_monsters §2.2) for the
## points of the multiplayer mode. The species picked in the draft is only the look. No rule.
##
##   stats   one random spending of the points: {hp, pace, stamina, reach, tpr, ap}
##   deal    gives every unit of a battle such stats and a Kin, by seed

## What every drawn monster has before the random spending, so that it can use a kit (UnitSheet.problems).
const FLOOR := {"hp": 3, "pace": 1.0, "stamina": 2, "reach": 2, "tpr": 1, "ap": 2}
## The highest value a draw buys (the 7×7 board needs no Reach above 4; a third turn is left out).
const TOP := {"hp": 10, "pace": 4.0, "stamina": 8, "reach": 4, "tpr": 2, "ap": 4}
## How often a stat is tried: [stat, step, weight].
const BUYS: Array = [["hp", 1, 6], ["pace", 0.2, 4], ["stamina", 1, 4], ["reach", 1, 2], ["ap", 1, 2], ["tpr", 1, 1]]
const TRIES := 60


static func cost(s: Dictionary) -> int:
	return MonsterDef.points_of(int(s["hp"]), float(s["pace"]), int(s["stamina"]), int(s["reach"]), int(s["tpr"]), int(s["ap"]))


static func stats(rng: RandomNumberGenerator, points := MonsterDef.MULTIPLAYER_POINTS) -> Dictionary:
	var s := FLOOR.duplicate()
	var total := 0
	for buy: Array in BUYS:
		total += int(buy[2])
	for i in TRIES:
		var roll := rng.randi_range(1, total)
		for buy: Array in BUYS:
			roll -= int(buy[2])
			if roll <= 0:
				_buy(s, buy[0], buy[1], points)
				break
	# what is left goes into Pace, then into whatever still fits
	while _buy(s, "pace", 0.1, points):
		pass
	for buy: Array in BUYS:
		while _buy(s, buy[0], buy[1], points):
			pass
	return s


static func _buy(s: Dictionary, stat: String, step: float, points: int) -> bool:
	var next := s.duplicate()
	if stat == "pace":
		next[stat] = snappedf(float(s[stat]) + step, 0.1)
	else:
		next[stat] = int(s[stat]) + int(step)
	if float(next[stat]) > float(TOP[stat]) + 0.001 or cost(next) > points:
		return false
	s[stat] = next[stat]
	return true


## Gives every unit of the battle drawn stats and a Kin; HP and Stamina start full.
static func deal(b: Battle, draw_seed: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = draw_seed ^ 0x5EED
	for id in b.roster:
		var u: BattleUnit = b.units[id]
		var s := stats(rng)
		var sheet := u.sheet
		sheet.hp = int(s["hp"])
		sheet.pace = float(s["pace"])
		sheet.movement = int(s["stamina"])
		sheet.reach = int(s["reach"])
		sheet.tpr = int(s["tpr"])
		sheet.ap = int(s["ap"])
		sheet.current_hp = -1
		sheet.kin = rng.randi_range(0, MonsterDef.Kin.size() - 1)
		sheet.display_name = "Random %s" % MonsterDef.kin_name(sheet.kin)
		sheet.notes.append("random monster: %d points" % cost(s))
		u.max_hp = sheet.hp
		u.hp = sheet.hp
		u.stamina = sheet.movement
