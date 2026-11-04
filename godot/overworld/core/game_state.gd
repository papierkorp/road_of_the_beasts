class_name GameState
extends RefCounted
## The save-game state of the overworld (gdd_overworld §3, §7): day, action points, money,
## the player's cultivation and the individuals they own. Headless, no nodes.
## Imports only shared/ — it never touches the battle.
##
## Phase 1 placeholders (marked, to be replaced by the real systems): the night heals everybody
## fully, the player's stage never changes, XP is collected but does not yet raise sub-tiers.

const START_AP := 3
const STARTER := &"blaze_tiger"

var day := 1
var max_ap := START_AP
var ap := START_AP
var money := 0                      # spirit stones, lowest denomination (gdd_overworld §9.1)
var stage: Stage.Type = Stage.Type.QI_GATHERING
var sub_tier: Stage.SubTier = Stage.SubTier.LOWER
var monsters: Array[MonsterInstance] = []


static func new_game(rng: RandomNumberGenerator, starter: StringName = STARTER) -> GameState:
	var g := GameState.new()
	g.monsters.append(MonsterInstance.roll(GameData.monster(starter), rng, StatShape.Id.NONE, g.stage, g.sub_tier))
	return g


## How many monsters the spatial space holds (gdd_overworld §4.5).
func capacity() -> int:
	match stage:
		Stage.Type.QI_GATHERING:
			return 1
		Stage.Type.FOUNDATION:
			return 3
	return 5


## The battle mode the player can field: 1v1 at Qi Gathering, 3v3 from Foundation.
func battle_mode() -> StringName:
	return &"1v1" if stage == Stage.Type.QI_GATHERING else &"3v3"


## The individuals that go into a battle of `mode` (the same objects, so HP changes stick).
func team_for(mode: StringName) -> Array[MonsterInstance]:
	var out: Array[MonsterInstance] = []
	for m in monsters:
		if out.size() >= BattleRequest.team_size_of(mode):
			break
		out.append(m)
	return out


func can_spend_ap(n: int) -> bool:
	return ap >= n


func spend_ap(n: int) -> bool:
	if ap < n:
		return false
	ap -= n
	return true


func add_money(n: int) -> void:
	money += n


## Night phase: every resolver runs once (gdd_overworld §7). Returns a report for the results screen.
func end_day() -> Dictionary:
	var healed := 0
	for m in monsters:
		if m.current_hp < m.max_hp():
			healed += 1
		m.heal_full()
	day += 1
	ap = max_ap
	return {"day": day, "healed": healed}


func to_dict() -> Dictionary:
	var ms := []
	for m in monsters:
		ms.append(m.to_dict())
	return {"day": day, "max_ap": max_ap, "ap": ap, "money": money, "stage": int(stage),
		"sub_tier": int(sub_tier), "monsters": ms}


static func from_dict(d: Dictionary) -> GameState:
	var g := GameState.new()
	g.day = int(d["day"])
	g.max_ap = int(d["max_ap"])
	g.ap = int(d["ap"])
	g.money = int(d["money"])
	g.stage = int(d["stage"]) as Stage.Type
	g.sub_tier = int(d["sub_tier"]) as Stage.SubTier
	for md in d["monsters"]:
		g.monsters.append(MonsterInstance.from_dict(md))
	return g
