class_name WorkshopPanel
extends HubPanel
## Battleground Workshop (docs/battle_ingame.md §3): build parts from blueprints and materials, and shape the
## battleground for the void in the map editor.


func title() -> String:
	return "Battleground Workshop"


func pillar() -> String:
	return "Board"


func hint() -> String:
	return "Build and shape your battleground"


func build(into: VBoxContainer) -> void:
	var v := game.values
	into.add_child(HubUi.dim("Your battleground counts in the void only. Limits: %d to %d squares a side, a budget of %d at this stage, at least %d free start squares for the opponent, who must be able to reach you." % [v.bg_min_side, v.bg_max_side, GameValues.at(v.bg_budget, int(game.stage)), v.bg_enemy_starts]))
	var list := HubUi.scroll(into)
	var ground := HubUi.card(list)
	ground.add_child(HubUi.label("Your battleground: %s" % GameSession.battleground_summary(), 20, UiTheme.ACCENT))
	var problems := GameSession.battleground_problems()
	ground.add_child(HubUi.label("Legal." if problems.is_empty() else "Not legal: %s" % "; ".join(problems), 20, HubUi.GOOD if problems.is_empty() else HubUi.WARN))
	ground.add_child(HubUi.button("Shape the battleground", func(): GameSession.edit_battleground(), 320))
	var parts := HubUi.card(list)
	parts.add_child(HubUi.label("Parts", 20, UiTheme.ACCENT))
	var weights: PackedStringArray = []
	for k in v.bg_weights:
		weights.append("%s %d" % [String(k).replace("_", " "), int(v.bg_weights[k])])
	parts.add_child(HubUi.dim("A placed part counts toward the budget: %s. One unit costs: %s." % [", ".join(weights), _cost_text()]))
	var ids: Array[String] = []
	for p: String in game.parts:
		ids.append(p)
	for b in game.blueprints:
		if not ids.has(String(b)):
			ids.append(String(b))
	ids.sort()
	for part in ids:
		var row := HubUi.row()
		parts.add_child(row)
		var known := game.blueprints.has(StringName(part))
		row.add_child(HubUi.label("%s — owned: %d%s" % [GameSession.part_name(part), int(game.parts.get(part, 0)), "" if known else " (no blueprint)"]))
		var b := HubUi.button("Build one", func():
			Cultivation.build_part(game, part)
			hub.refresh(), 200)
		b.disabled = not Cultivation.can_build(game, part)
		row.add_child(b)
	if game.blueprints.is_empty():
		parts.add_child(HubUi.dim("Blueprints come from the tree in the Cultivation Hall."))


func _cost_text() -> String:
	var out: PackedStringArray = []
	for form: String in game.values.bg_part_cost:
		out.append("%d %s" % [int(game.values.bg_part_cost[form]), form])
	return ", ".join(out)
