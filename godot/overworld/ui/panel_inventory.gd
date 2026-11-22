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
	you.add_child(HubUi.label("%s · %s · year %d · %d years left to live · %d Insight · %d tamer slot(s)" % [Stage.stage_name(game.stage),
		system.display_name if system != null else "no Way", game.day, game.lifespan, game.path_points, game.tamer_slots()]))
	you.add_child(HubUi.dim("You rise a stage only by the breakthrough trial, the last depth of the void. Insight comes from the depths of the void and buys the nodes of your Way."))
	var content := GameSession.battle_content()
	var names: PackedStringArray = []
	for id in game.tamer_skills:
		var def := content.tamer_skill(id)
		names.append(def.display_name if def != null else String(id))
	you.add_child(HubUi.label("Tamer skills: %s" % ", ".join(names)))

	var mons := HubUi.card(list)
	mons.add_child(HubUi.label("Monsters: %d, eggs: %d (room for %d)" % [game.roster.size(), game.eggs.size(), game.roster_cap()], 22, UiTheme.ACCENT))
	for m in game.roster:
		mons.add_child(HubUi.monster_line(m))
		mons.add_child(HubUi.dim("%s bloodline · %s" % [m.bloodline_name(), m.xp_text()]))

	var groups := {"Materials": [], "Pills": [], "Weapons": []}
	var ids: Array = game.items.keys()
	ids.sort()
	for id: String in ids:
		var key := "Pills" if id.begins_with("pill:") else ("Weapons" if id.begins_with("weapon:") else "Materials")
		groups[key].append(id)
	for key: String in groups:
		var card := HubUi.card(list)
		card.add_child(HubUi.label(key, 22, UiTheme.ACCENT))
		var owned: Array = groups[key]
		var flow := HubUi.flow(18)
		card.add_child(flow)
		for id: String in owned:
			var line := HubUi.signed(HubUi.item_sign(id), "%s ×%d" % [Materials.display_name(id, game.values), int(game.items[id])])
			line.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
			line.custom_minimum_size.x = 330
			flow.add_child(line)
		if owned.is_empty():
			card.add_child(HubUi.dim("none"))

	var ground := HubUi.card(list)
	ground.add_child(HubUi.label("Battleground", 22, UiTheme.ACCENT))
	ground.add_child(MiniBoard.of(MapData.from_dict(game.battleground), 22.0))
	ground.add_child(HubUi.label(GameSession.battleground_summary()))
	var parts: PackedStringArray = []
	for id: String in game.parts:
		parts.append("%d × %s" % [int(game.parts[id]), GameSession.part_name(id)])
	ground.add_child(HubUi.label("Parts: %s" % (", ".join(parts) if not parts.is_empty() else "none")))
