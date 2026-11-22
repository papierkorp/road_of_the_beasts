class_name WorkshopPanel
extends HubPanel
## Battleground Workshop (docs/battle_ingame.md §3): shape the battleground for the void in the map editor, from the
## parts the forge made.


func title() -> String:
	return "Battleground Workshop"


func pillar() -> String:
	return "Board"


func hint() -> String:
	return "Shape your battleground"


func build(into: VBoxContainer) -> void:
	var v := game.values
	into.add_child(HubUi.dim("Your battleground counts in the void only. Limits: %d to %d squares a side, a budget of %d at this stage, at least %d free start squares for the opponent, who must be able to reach you." % [v.bg_min_side, v.bg_max_side, GameValues.at(v.bg_budget, int(game.stage)), v.bg_enemy_starts]))
	var list := HubUi.scroll(into)
	var ground := HubUi.card(list)
	ground.add_child(HubUi.label("Your battleground: %s" % GameSession.battleground_summary(), 20, UiTheme.ACCENT))
	ground.add_child(MiniBoard.of(MapData.from_dict(game.battleground), 34.0))
	var problems := GameSession.battleground_problems()
	ground.add_child(HubUi.label("Legal." if problems.is_empty() else "Not legal: %s" % "; ".join(problems), 20, HubUi.GOOD if problems.is_empty() else HubUi.WARN))
	ground.add_child(HubUi.primary("Shape the battleground", func(): GameSession.edit_battleground(), 320))
	var parts := HubUi.card(list)
	parts.add_child(HubUi.label("Parts", 20, UiTheme.ACCENT))
	var weights: PackedStringArray = []
	for k in v.bg_weights:
		weights.append("%s %d" % [String(k).replace("_", " "), int(v.bg_weights[k])])
	parts.add_child(HubUi.dim("A placed part counts toward the budget: %s. Parts are forged from two beast parts." % ", ".join(weights)))
	var ids: Array[String] = []
	for p: String in game.parts:
		ids.append(p)
	ids.sort()
	for part in ids:
		parts.add_child(HubUi.signed(HubUi.swatch(HubUi.part_color(part), 24), "%s — owned: %d" % [GameSession.part_name(part), int(game.parts.get(part, 0))]))
	if ids.is_empty():
		parts.add_child(HubUi.dim("None yet."))
	parts.add_child(HubUi.button("To the Forge", hub.open.bind(&"forge", &""), 240))
