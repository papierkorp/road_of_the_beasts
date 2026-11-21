class_name Cultivation
extends RefCounted
## The tree of the cultivation system (docs/overworld.md §5.3): a tree per stage, opened by the breakthrough; a node
## is bought with path points and gives a tamer skill or a blueprint for a part of the battleground. Also the
## workshop's building of parts from blueprints and materials (docs/battle_ingame.md §3).


static func system(game: GameState) -> CultivationDef:
	return CultivationDef.of(game.system)


## Why a node cannot be bought ("" = it can).
static func problem(game: GameState, node_id: StringName) -> String:
	var def := system(game)
	var n := def.node(node_id) if def != null else {}
	if n.is_empty():
		return "unknown node"
	if game.nodes.has(node_id):
		return "bought"
	if int(n["stage"]) > int(game.stage):
		return "opens at %s" % Stage.stage_name(int(n["stage"]) as Stage.Type)
	var needs := StringName(n.get("needs", &""))
	if needs != &"" and not game.nodes.has(needs):
		return "needs %s" % def.node(needs).get("name", needs)
	if game.path_points < int(n["cost"]):
		return "needs %d path point(s)" % int(n["cost"])
	return ""


static func buy(game: GameState, node_id: StringName) -> bool:
	if problem(game, node_id) != "":
		return false
	var n := system(game).node(node_id)
	game.path_points -= int(n["cost"])
	game.nodes.append(node_id)
	if n["kind"] == "tamer":
		if not game.tamer_skills.has(StringName(n["ref"])):
			game.tamer_skills.append(StringName(n["ref"]))
	elif n["kind"] == "blueprint":
		if not game.blueprints.has(StringName(n["ref"])):
			game.blueprints.append(StringName(n["ref"]))
	game.say("Learned: %s." % n["name"])
	return true


## The materials one unit of a part costs, as the items the player would pay with (the lowest tiers first);
## {} when the player cannot pay.
static func part_payment(game: GameState) -> Dictionary:
	var pay := {}
	for form: String in game.values.bg_part_cost:
		var need := int(game.values.bg_part_cost[form])
		var ids: Array = game.items.keys().filter(func(id: String) -> bool: return Materials.form(id) == form)
		ids.sort_custom(func(a: String, b: String) -> bool: return Materials.tier(a) < Materials.tier(b))
		for id: String in ids:
			var take := mini(need, game.count(id))
			if take > 0:
				pay[id] = take
				need -= take
		if need > 0:
			return {}
	return pay


static func can_build(game: GameState, part: String) -> bool:
	return game.blueprints.has(StringName(part)) and not part_payment(game).is_empty()


## Builds one unit of a part of the battleground from a blueprint and materials.
static func build_part(game: GameState, part: String) -> bool:
	if not can_build(game, part):
		return false
	var pay := part_payment(game)
	for id in pay:
		game.take_item(id, int(pay[id]))
	game.parts[part] = int(game.parts.get(part, 0)) + 1
	return true
