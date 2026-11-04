class_name Expedition
extends RefCounted
## One dungeon run as a node map (gdd_overworld §6.2, §11 "Slay-the-Spire style").
## Layers of battle nodes, the player picks a path; the last layer is a boss node.
## HP persists from node to node (§10.2). It builds BattleRequests and reads BattleResults —
## it never touches the battle itself.
##
## Phase 1: only battle and boss nodes, flat money reward and XP, one material drop per wild
## monster (by its kin); at most 2 nodes per layer. Rest nodes and catching come later.

const LAYER_SIZES := [2, 2, 2, 1]
const REWARD_PER_LAYER := 10        # spirit stones, times the layer number
const BOSS_MULTIPLIER := 2
const XP_PER_WIN := 10

## Node: {id, layer, col, kind (&"battle" | &"boss"), mode, enemies: Array[MonsterInstance], reward, next: Array[int]}
var nodes: Array[Dictionary] = []
var current := -1                   # last cleared node (-1 = not entered yet)
var selected := -1                  # node the player is about to fight
var finished := false
var victory := false
var money_earned := 0
var blueprint_reward: StringName = &""   # the boss drops this blueprint (none if everything is known)
var last_loot := {}                 # item id -> count, of the last victory
var last_ups: Array[String] = []    # "Name reached Middle", of the last victory
var _team: Array[MonsterInstance] = []
var _path: Array[int] = []          # cleared nodes in order


static func generate(state: GameState, rng: RandomNumberGenerator) -> Expedition:
	var e := Expedition.new()
	var unknown: Array[StringName] = []
	for sid in StructureCatalog.ids():
		if not state.owns_structure(sid):
			unknown.append(sid)
	if not unknown.is_empty():
		e.blueprint_reward = unknown[rng.randi_range(0, unknown.size() - 1)]
	var mode := state.battle_mode()
	var ids := GameData.monster_ids()
	var layers: Array = []
	for l in LAYER_SIZES.size():
		var row: Array[int] = []
		var boss: bool = l == LAYER_SIZES.size() - 1
		for c in int(LAYER_SIZES[l]):
			var enemies: Array[MonsterInstance] = []
			for k in BattleRequest.team_size_of(mode):
				var def := GameData.monster(ids[rng.randi_range(0, ids.size() - 1)])
				enemies.append(MonsterInstance.roll(def, rng, StatShape.Id.NONE, state.stage, state.sub_tier))
			var next: Array[int] = []
			e.nodes.append({"id": e.nodes.size(), "layer": l, "col": c, "kind": &"boss" if boss else &"battle",
				"mode": mode, "enemies": enemies, "next": next,
				"reward": REWARD_PER_LAYER * (l + 1) * (BOSS_MULTIPLIER if boss else 1)})
			row.append(e.nodes.size() - 1)
		layers.append(row)
	# paths: straight on, sometimes also across (every node of the next layer stays reachable)
	for l in LAYER_SIZES.size() - 1:
		var here: Array = layers[l]
		var there: Array = layers[l + 1]
		for c in here.size():
			var straight := mini(c, there.size() - 1)
			var nx: Array[int] = [there[straight]]
			if there.size() > 1 and rng.randf() < 0.5:
				nx.append(there[1 - straight])
			e.nodes[here[c]]["next"] = nx
	return e


## Nodes the player may enter next.
func choices() -> Array[int]:
	var out: Array[int] = []
	if finished:
		return out
	if current < 0:
		for n in nodes:
			if n["layer"] == 0:
				out.append(n["id"])
	else:
		for i in nodes[current]["next"]:
			out.append(i)
	return out


## What to tell the player after a battle of the current node (`before` = `current` before it).
func result_note(before: int) -> String:
	var note := ""
	if finished and victory:
		note = "Dungeon cleared! +%d spirit stones in total." % money_earned
		if blueprint_reward != &"":
			note += " Blueprint found: %s!" % StructureCatalog.def(blueprint_reward).display_name
	elif finished:
		note = "Your team fell. The run ends here — the night will heal you."
	elif current != before:
		note = "Victory! Choose your next door."
	if current != before:
		note += "  " + loot_text()
		if not last_ups.is_empty():
			note += "\n" + ", ".join(PackedStringArray(last_ups)) + " — stats snap to the new values!"
	return note


func loot_text() -> String:
	var parts: Array[String] = []
	for id in last_loot:
		parts.append("%s ×%d" % [ItemCatalog.display_name(String(id)), int(last_loot[id])])
	return "Loot: " + (", ".join(PackedStringArray(parts)) if not parts.is_empty() else "nothing") + "."


func select(id: int) -> bool:
	if not choices().has(id):
		return false
	selected = id
	return true


func node(id: int) -> Dictionary:
	return nodes[id] if id >= 0 and id < nodes.size() else {}


## A node counts as cleared when it lies on the path walked so far.
func is_cleared(id: int) -> bool:
	return _path.has(id)


## The request for the selected node. `team` is the player's pick (default: the first monsters).
func request_for(state: GameState, team: Array[MonsterInstance] = []) -> BattleRequest:
	var r := BattleRequest.new()
	var n := node(selected)
	if n.is_empty():
		return r
	_team = team if not team.is_empty() else state.team_for(n["mode"])
	r.mode = n["mode"]
	r.player_team = _team
	r.enemy_team = n["enemies"]
	return r


## Reads the finished battle of the selected node: HP persists, victory pays and moves on.
func apply_result(state: GameState, result: BattleResult) -> void:
	var n := node(selected)
	if finished or n.is_empty() or not result.over:
		return
	var team := _team if not _team.is_empty() else state.team_for(n["mode"])
	result.apply_hp(team, 0)
	if result.player_won():
		state.add_money(n["reward"])
		money_earned += n["reward"]
		last_loot = {}
		for e: MonsterInstance in n["enemies"]:
			var sp := e.species()
			var loot := ItemCatalog.material_id(sp.kin, sp.aspect, int(e.stage))
			state.add_item(loot)
			last_loot[loot] = int(last_loot.get(loot, 0)) + 1
		last_ups = []
		for m in team:
			if m.current_hp > 0 and m.add_xp(XP_PER_WIN) > 0:
				last_ups.append("%s reached %s" % [m.species().display_name, Stage.sub_tier_name(m.sub_tier)])
		current = selected
		_path.append(selected)
		selected = -1
		if (n["next"] as Array).is_empty():
			finished = true
			victory = true
			if blueprint_reward != &"":
				state.add_item(ItemCatalog.blueprint_id(blueprint_reward))
	else:
		finished = true
		victory = false
