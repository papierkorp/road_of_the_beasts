class_name BattleRequest
extends RefCounted
## Everything the battle needs, decided before it starts (gdd_overworld §1.3).
## The overworld (or the draft screen) builds one; `BattleSetup.build()` turns it into a Battle.
## Lives in shared/ because both halves use it — it is the contract between them.
## The battle never reaches back into the caller — it only reads this and reports a BattleResult.
##
## Not yet carried (later steps): board parameters, pills / arrays, tamer slots, ambush bonus.

var mode: StringName = &"3v3"
var player_team: Array[MonsterInstance] = []
var enemy_team: Array[MonsterInstance] = []


## Species ids → reference individuals (the roster numbers as before).
static func from_ids(p_mode: StringName, player: Array[StringName], enemy: Array[StringName]) -> BattleRequest:
	var r := BattleRequest.new()
	r.mode = p_mode
	r.player_team = _references(player)
	r.enemy_team = _references(enemy)
	return r


static func _references(ids: Array[StringName]) -> Array[MonsterInstance]:
	var out: Array[MonsterInstance] = []
	for id in ids:
		out.append(MonsterInstance.of_species(GameData.monster(id)))
	return out


## Monsters per side: a duel is 1v1, everything else is a team battle (2v2 / 5v5 not built yet).
static func team_size_of(m: StringName) -> int:
	return 1 if m == &"1v1" else 3


## Fixed teams for starting the battle scene directly (no draft).
static func default() -> BattleRequest:
	var p: Array[StringName] = [&"blaze_tiger", &"moss_turtle", &"gloom_wolf"]
	var e: Array[StringName] = [&"hollow_serpent", &"grove_wisp", &"ember_hawk"]
	return from_ids(&"3v3", p, e)


func team_size() -> int:
	return team_size_of(mode)


## Empty string when the request can be fought, otherwise the reason it can't.
func problem() -> String:
	if player_team.is_empty() or enemy_team.is_empty():
		return "both sides need at least one monster"
	for m in player_team + enemy_team:
		if m.species() == null:
			return "unknown species '%s'" % m.species_id
	return ""
