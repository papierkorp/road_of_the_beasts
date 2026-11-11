class_name BattleRequest
extends RefCounted
## Everything the battle needs, decided before it starts (gdd_overworld §1.3).
## The overworld (or the draft screen) builds one; `BattleSetup.build()` turns it into a Battle.
## Lives in shared/ because both halves use it — it is the contract between them.
## The battle never reaches back into the caller — it only reads this and reports a BattleResult.
##
## Not yet carried (open: T18/T19/T21): medicines, arrays, the board generator contract.

var mode: StringName = &"3v3"
var player_team: Array[MonsterInstance] = []
var enemy_team: Array[MonsterInstance] = []
## LEGACY: side that attacked from behind on the overworld. The ambush bonus was dropped from
## the design (gdd_overworld §2.2); the battle ignores this field.
var ambush_side := -1
## Battle-prep pills (gdd_overworld §6.6): player team index -> initiative bonus for this battle.
var prep_init := {}
## Board parameter: 0 = the fixed layout of the mode, anything else a seeded layout.
var board_seed := 0
## Pre-battle placement (gdd_battle §2.1): chosen start squares per player slot inside the
## start area; missing or illegal entries fall back to the default squares.
var player_starts: Array[Vector2i] = []
## Battle loadout (gdd_battle §5.2): slotted tamer skill ids per side. Wild monsters have none.
var player_tamer: Array[StringName] = []
var enemy_tamer: Array[StringName] = []
## Monsters available to Beast Swap (not on the field at the start).
var player_bench: Array[MonsterInstance] = []
var enemy_bench: Array[MonsterInstance] = []


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


## Monsters per side (gdd_battle §1.1); unknown modes are the standard 3v3.
static func team_size_of(m: StringName) -> int:
	match m:
		&"1v1":
			return 1
		&"2v2":
			return 2
		&"5v5":
			return 5
	return 3


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
