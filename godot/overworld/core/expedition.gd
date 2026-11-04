class_name Expedition
extends RefCounted
## One dungeon run (gdd_overworld §6.2, §7, §10.2): a chain of battle nodes with visible wild
## monsters. HP persists from node to node, the run ends after the last node or on defeat.
## It builds BattleRequests and reads BattleResults — it never touches the battle itself.
##
## Phase 1: straight chain of battles, flat money reward, flat XP. Branching, loot and
## catching come later.

const NODE_COUNT := 3
const REWARD_PER_NODE := 10         # spirit stones, times the node number
const XP_PER_WIN := 10

var nodes: Array[Dictionary] = []   # {mode, enemies: Array[MonsterInstance], reward}
var index := 0
var finished := false
var victory := false
var money_earned := 0


static func generate(state: GameState, rng: RandomNumberGenerator) -> Expedition:
	var e := Expedition.new()
	var mode := state.battle_mode()
	var ids := GameData.monster_ids()
	for i in NODE_COUNT:
		var enemies: Array[MonsterInstance] = []
		for k in BattleRequest.team_size_of(mode):
			var def := GameData.monster(ids[rng.randi_range(0, ids.size() - 1)])
			enemies.append(MonsterInstance.roll(def, rng, StatShape.Id.NONE, state.stage, state.sub_tier))
		e.nodes.append({"mode": mode, "enemies": enemies, "reward": REWARD_PER_NODE * (i + 1)})
	return e


func current_node() -> Dictionary:
	return nodes[index] if index < nodes.size() else {}


func request_for(state: GameState) -> BattleRequest:
	var n := current_node()
	var r := BattleRequest.new()
	r.mode = n["mode"]
	r.player_team = state.team_for(n["mode"])
	r.enemy_team = n["enemies"]
	return r


## Reads the finished battle of the current node: HP persists, victory pays and advances.
func apply_result(state: GameState, result: BattleResult) -> void:
	if finished or index >= nodes.size() or not result.over:
		return
	var n := nodes[index]
	var team := state.team_for(n["mode"])
	result.apply_hp(team, 0)
	if result.player_won():
		state.add_money(n["reward"])
		money_earned += n["reward"]
		for m in team:
			if m.current_hp > 0:
				m.xp += XP_PER_WIN
		index += 1
		if index >= nodes.size():
			finished = true
			victory = true
	else:
		finished = true
		victory = false
