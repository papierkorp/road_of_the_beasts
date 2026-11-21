class_name InventoryPanel
extends HubPanel
## Everything the player owns, in one list. Nothing is done here.


func title() -> String:
	return "Inventory"


func pillar() -> String:
	return "Overview"


func hint() -> String:
	var n := 0
	for k in game.items:
		n += int(game.items[k])
	return "Everything you own\n%d items" % n


func build(into: VBoxContainer) -> void:
	var list := HubUi.scroll(into)
	var you := HubUi.card(list)
	you.add_child(HubUi.label("You", 22, UiTheme.ACCENT))
	var system := CultivationDef.of(game.system)
	you.add_child(HubUi.label("%s · %s · day %d · lifespan %d days · %d path points · %d tamer slot(s)" % [Stage.stage_name(game.stage),
		system.display_name if system != null else "no system", game.day, game.lifespan, game.path_points, game.tamer_slots()]))
	you.add_child(HubUi.dim("You rise a stage only by the breakthrough trial, the last depth of the void. Path points come from the depths of the void and buy the nodes of your cultivation system."))
	var content := BattleContent.shared()
	var names: PackedStringArray = []
	for id in game.tamer_skills:
		var def := content.tamer_skill(id)
		names.append(def.display_name if def != null else String(id))
	you.add_child(HubUi.label("Tamer skills: %s" % ", ".join(names)))

	var mons := HubUi.card(list)
	mons.add_child(HubUi.label("Monsters: %d, eggs: %d (room for %d)" % [game.roster.size(), game.eggs.size(), game.values.roster_cap], 22, UiTheme.ACCENT))
	for m in game.roster:
		mons.add_child(HubUi.label("%s · %s" % [m.title(), m.xp_text()]))

	var groups := {"Materials": [], "Pills": [], "Forged pieces": []}
	var ids: Array = game.items.keys()
	ids.sort()
	for id: String in ids:
		var line := "%d × %s" % [int(game.items[id]), Materials.display_name(id, game.values)]
		var key := "Pills" if id.begins_with("pill:") else ("Forged pieces" if id.begins_with("weapon:") or id.begins_with("armour:") else "Materials")
		groups[key].append(line)
	for key: String in groups:
		var card := HubUi.card(list)
		card.add_child(HubUi.label(key, 22, UiTheme.ACCENT))
		var lines: Array = groups[key]
		card.add_child(HubUi.label("\n".join(PackedStringArray(lines)) if not lines.is_empty() else "none"))

	var ground := HubUi.card(list)
	ground.add_child(HubUi.label("Battleground", 22, UiTheme.ACCENT))
	ground.add_child(HubUi.label(GameSession.battleground_summary()))
	var parts: PackedStringArray = []
	for id: String in game.parts:
		parts.append("%d × %s" % [int(game.parts[id]), GameSession.part_name(id)])
	ground.add_child(HubUi.label("Parts: %s" % (", ".join(parts) if not parts.is_empty() else "none")))
	var prints: PackedStringArray = []
	for id in game.blueprints:
		prints.append(GameSession.part_name(String(id)))
	ground.add_child(HubUi.label("Blueprints: %s" % (", ".join(prints) if not prints.is_empty() else "none")))
