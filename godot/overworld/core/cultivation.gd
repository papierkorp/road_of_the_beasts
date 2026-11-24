class_name Cultivation
extends RefCounted
## The tree of the Way (docs/overworld.md §5.3): a tree per stage, opened by the breakthrough; a node is bought with
## Insight. A node of the Formation gives a tamer skill ("tamer") or an option of Seal ("seal": a development step,
## at most two); a node of the Artificer or the Alchemist is a
## perk ("perk"): its effects are read where they act (`GameState.node_sum`), and "reveal" acts once, when bought.


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
	if String(n["kind"]) == "seal":
		if not game.can_catch():
			return "your vow forbids the seal"
		if game.seal_options().size() >= TamerSkillDef.SEAL_MAX_OPTIONS:
			return "Seal is at level %d" % (TamerSkillDef.SEAL_MAX_OPTIONS + 1)
	if game.path_points < int(n["cost"]):
		return "needs %d Insight" % int(n["cost"])
	return ""


static func buy(game: GameState, node_id: StringName) -> bool:
	if problem(game, node_id) != "":
		return false
	var n := system(game).node(node_id)
	game.path_points -= int(n["cost"])
	game.nodes.append(node_id)
	if n["kind"] == "tamer" and not game.tamer_skills.has(StringName(n["ref"])):
		game.tamer_skills.append(StringName(n["ref"]))
	game.say("Learned: %s." % n["name"])
	return true
