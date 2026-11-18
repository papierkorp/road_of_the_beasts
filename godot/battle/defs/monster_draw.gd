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
## The highest values of a monster of the ingame battle: the ranges of the sheet (AP 5, a third turn).
const INGAME_TOP := {"hp": 10, "pace": 4.0, "stamina": 8, "reach": 4, "tpr": 3, "ap": 5}
## How often a stat is tried: [stat, step, weight].
const BUYS: Array = [["hp", 1, 6], ["pace", 0.2, 4], ["stamina", 1, 4], ["reach", 1, 2], ["ap", 1, 2], ["tpr", 1, 1]]
const TRIES := 60
## Names of drawn monsters: "Random Alpha", "Random Beta", … in roster order (the Kin plays no part in a battle).
const LETTERS: Array[String] = ["Alpha", "Beta", "Gamma", "Delta", "Epsilon", "Zeta", "Eta", "Theta", "Iota", "Kappa", "Lambda", "Mu"]


static func cost(s: Dictionary) -> int:
	return MonsterDef.points_of(int(s["hp"]), float(s["pace"]), int(s["stamina"]), int(s["reach"]), int(s["tpr"]), int(s["ap"]))


static func stats(rng: RandomNumberGenerator, points := MonsterDef.MULTIPLAYER_POINTS, top: Dictionary = TOP) -> Dictionary:
	var s := FLOOR.duplicate()
	var total := 0
	for buy: Array in BUYS:
		total += int(buy[2])
	for i in TRIES:
		var roll := rng.randi_range(1, total)
		for buy: Array in BUYS:
			roll -= int(buy[2])
			if roll <= 0:
				_buy(s, buy[0], buy[1], points, top)
				break
	# what is left goes into Pace, then into whatever still fits
	while _buy(s, "pace", 0.1, points, top):
		pass
	for buy: Array in BUYS:
		while _buy(s, buy[0], buy[1], points, top):
			pass
	return s


static func _buy(s: Dictionary, stat: String, step: float, points: int, top: Dictionary = TOP) -> bool:
	var next := s.duplicate()
	if stat == "pace":
		next[stat] = snappedf(float(s[stat]) + step, 0.1)
	else:
		next[stat] = int(s[stat]) + int(step)
	if float(next[stat]) > float(top[stat]) + 0.001 or cost(next) > points:
		return false
	s[stat] = next[stat]
	return true


## Gives every unit of the battle drawn stats and a Kin; HP and Stamina start full. `points_by_side` (ingame
## prototype): the points of side 0 and side 1, bought up to `top`; empty = the points of the multiplayer mode.
## `mirror`: a unit of side 1 gets the stats and the Kin of the unit of side 0 in the same slot.
static func deal(b: Battle, draw_seed: int, points_by_side: Array[int] = [], top: Dictionary = TOP, mirror := false) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = draw_seed ^ 0x5EED
	var first := {}                               # slot -> [stats, kin, letter] of side 0
	var drawn := 0
	for id in b.roster:
		var u: BattleUnit = b.units[id]
		var s: Dictionary
		var kin: int
		var letter := drawn
		if mirror and u.side == 1 and first.has(u.slot):
			s = first[u.slot][0]
			kin = first[u.slot][1]
			letter = first[u.slot][2]                 # the same monster carries the same name on both sides
		else:
			drawn += 1
			s = stats(rng) if points_by_side.size() < 2 else stats(rng, points_by_side[u.side], top)
			kin = rng.randi_range(0, MonsterDef.Kin.size() - 1)
			if u.side == 0:
				first[u.slot] = [s, kin, letter]
		var sheet := u.sheet
		sheet.hp = int(s["hp"])
		sheet.pace = float(s["pace"])
		sheet.movement = int(s["stamina"])
		sheet.reach = int(s["reach"])
		sheet.tpr = int(s["tpr"])
		sheet.ap = int(s["ap"])
		sheet.current_hp = -1
		sheet.kin = kin
		sheet.display_name = "Random %s" % LETTERS[letter % LETTERS.size()]
		sheet.notes.append("random monster: %d points" % cost(s))
		u.max_hp = sheet.hp
		u.hp = sheet.hp
		u.stamina = sheet.movement
