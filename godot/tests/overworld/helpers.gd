class_name HubTestHelpers
extends RefCounted
## Builders for the tests of the hub game: a game of each Way and the result of a battle that was not played.

const ARTIFICER := GameState.ARTIFICER
const FORMATION := GameState.FORMATION
const ALCHEMIST := GameState.ALCHEMIST


static func game(way: StringName = FORMATION, seed_value := 41, egg: StringName = &"blaze_tiger") -> GameState:
	return GameState.new_game(seed_value, way, egg)


## The result of a battle: won (every enemy died, the team stands with `hp` or full HP) or lost. `caught` lists
## the indexes of enemies that were caught instead of killed.
static func result(f: Fight, won: bool, hp := -1, caught: Array = []) -> BattleResult:
	var r := BattleResult.new()
	r.over = true
	r.winner_side = 0 if won else 1
	r.rounds = 4
	for i in f.team.size():
		r.player.append({"index": i, "hp_left": (f.team[i].max_hp() if hp < 0 else hp) if won else 0, "alive": won})
	for i in f.enemies.size():
		r.enemy.append({"index": i, "hp_left": 0, "alive": false, "caught": caught.has(i), "died": won and not caught.has(i)})
	return r


## Fights a battle of the look at the wild (the first one still open when `id` is gone) and reads it back.
static func wild_fight(g: GameState, id: int, won: bool, caught: Array = []) -> Fight:
	if g.wild_gone.has(id):
		id = int(Wild.open(g)[0]["id"])
	var f := Wild.fight_for(g, id)
	f.team = g.default_team(f.max_team)
	Places.resolve(g, f, result(f, won, -1, caught))
	return f


## Fights the battle the void offers now and reads it back.
static func void_fight(g: GameState, won: bool) -> Fight:
	var f := VoidPlace.fight(g)
	f.team = g.default_team(f.max_team)
	Places.resolve(g, f, result(f, won, 1))
	return f
