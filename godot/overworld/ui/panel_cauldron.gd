class_name CauldronPanel
extends HubPanel
## Cauldron (docs/vision.md §7): two or three plants that share a property give a pill with that effect.

static var picked: Array[String] = []


func title() -> String:
	return "Cauldron"


func pillar() -> String:
	return "Tamer"


func hint() -> String:
	return "Brew pills from plants"


func _known_text(plant: StringName) -> String:
	var names: PackedStringArray = []
	for p in Crafting.known_of(game, plant):
		names.append(String(Crafting.property(game.values, StringName(p)).get("name", p)))
	for i in game.values.properties_per_plant - names.size():
		names.append("?")
	return ", ".join(names)


func build(into: VBoxContainer) -> void:
	into.add_child(HubUi.dim("Every plant has %d properties, drawn anew for every game. Two or three different plants that share a property give a pill with that effect; plants that share nothing are lost. A property is unknown until you made a pill with it." % game.values.properties_per_plant))
	picked = picked.filter(func(item: String) -> bool: return game.count(item) > 0)
	var list := HubUi.scroll(into)
	var plants := HubUi.card(list)
	plants.add_child(HubUi.label("Your plants — pick two or three", 20, UiTheme.ACCENT))
	var flow := HubUi.flow()
	plants.add_child(flow)
	var any := false
	var ids: Array = game.items.keys()
	ids.sort()
	for item: String in ids:
		if Materials.form(item) != "plant":
			continue
		any = true
		var b := HubUi.button("%s ×%d\n%s" % [Materials.display_name(item, game.values), game.count(item), _known_text(Crafting.plant_of(item))], func():
			if picked.has(item):
				picked.erase(item)
			elif picked.size() < 3:
				picked.append(item)
			hub.refresh(), 360)
		b.custom_minimum_size.y = HubUi.TAP + 24
		b.toggle_mode = true
		b.button_pressed = picked.has(item)
		flow.add_child(b)
	if not any:
		plants.add_child(HubUi.dim("No plants yet: they come from the dungeon."))
	var brew := HubUi.button("Brew", func():
		Crafting.brew(game, picked.duplicate())
		hub.refresh(), 260)
	brew.disabled = not Crafting.can_brew(game, picked)
	plants.add_child(brew)
	var pills := HubUi.card(list)
	pills.add_child(HubUi.label("Your pills", 20, UiTheme.ACCENT))
	for pill in PillUse.pills(game):
		var uses: PackedStringArray = []
		for p in Crafting.pill_properties(pill):
			uses.append(String(Crafting.property(game.values, StringName(p)).get("pill", p)))
		pills.add_child(HubUi.label("%s ×%d — %s" % [Materials.display_name(pill, game.values), game.count(pill), "; ".join(uses)]))
	if PillUse.pills(game).is_empty():
		pills.add_child(HubUi.dim("None yet."))
	var use := HubUi.flow()
	if PillUse.add_rows(use, self, false) > 0:
		pills.add_child(HubUi.label("Use here:", 18, UiTheme.DIM))
		pills.add_child(use)
	pills.add_child(HubUi.dim("Healing pills are taken between the battles of a dungeon. A pill that acts in a battle is put into a tamer slot when you prepare the battle and is used up when taken. The relearning pill can be brewed but not used yet."))
