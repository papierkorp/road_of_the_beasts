class_name CauldronPanel
extends HubPanel
## Cauldron (docs/vision.md §7): two or three plants that share a property give a pill with that effect.
## The screen reads left to right: the plants with what is known of them · the cauldron · the pills.

static var picked: Array[String] = []

## A colour per plant, in the order of the list of plants: a look hint, never a rule.
const PLANT_INKS: Array[Color] = [Color(0.36, 0.45, 0.62), Color(0.47, 0.33, 0.22), Color(0.72, 0.5, 0.12), Color(0.42, 0.45, 0.5),
	Color(0.25, 0.55, 0.62), Color(0.72, 0.28, 0.18), Color(0.45, 0.28, 0.58), Color(0.3, 0.52, 0.3)]


func title() -> String:
	return "Cauldron"


func pillar() -> String:
	return "Tamer"


func hint() -> String:
	return "Brew pills from plants"


func _plant_ink(plant: StringName) -> Color:
	for i in game.values.plants.size():
		if StringName(game.values.plants[i]["id"]) == plant:
			return PLANT_INKS[i % PLANT_INKS.size()]
	return UiTheme.JADE


## What the player knows of a plant, as slips: its properties (unknown ones as "?") and its flaw.
func _known_chips(plant: StringName, on_ink: bool) -> HFlowContainer:
	var flow := HFlowContainer.new()
	flow.add_theme_constant_override("h_separation", 5)
	flow.add_theme_constant_override("v_separation", 4)
	flow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flow.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var jade := Color(0.6, 0.88, 0.78) if on_ink else UiTheme.JADE
	var dim := Color(UiTheme.PAPER_LIGHT, 0.7) if on_ink else UiTheme.DIM
	var red := Color(0.95, 0.62, 0.55) if on_ink else UiTheme.WARN
	var known: Array = Crafting.known_of(game, plant)
	for p in known:
		flow.add_child(HubUi.chip(String(Crafting.property(game.values, StringName(p)).get("name", p)), jade))
	for i in game.values.properties_per_plant - known.size():
		flow.add_child(HubUi.chip("?", dim))
	var flaw := Crafting.flaw_def(game.values, Crafting.known_flaw(game, plant))
	flow.add_child(HubUi.chip("flaw: %s" % flaw.get("name", "?"), red if not flaw.is_empty() else dim))
	return flow


## What the picked plants are known to share: a hint from what was found, never from what is hidden.
func _shared_text() -> String:
	if picked.size() < 2:
		return "Pick two or three different plants."
	var shared: Array = Crafting.known_of(game, Crafting.plant_of(picked[0])).duplicate()
	for item in picked:
		var mine: Array = Crafting.known_of(game, Crafting.plant_of(item))
		shared = shared.filter(func(p) -> bool: return mine.has(p))
	if shared.is_empty():
		return "Nothing you know of is shared: the brew will tell."
	var names: PackedStringArray = []
	for p in shared:
		names.append(String(Crafting.property(game.values, StringName(p)).get("name", p)))
	return "Known to share: %s." % ", ".join(names)


func build(into: VBoxContainer) -> void:
	into.add_child(HubUi.dim("Every plant has %d properties and one flaw, drawn anew for every game. Plants that share a property give a pill with that effect; plants that share nothing are lost. A flaw every plant has goes into the pill. What a plant holds is unknown until a pill showed it." % game.values.properties_per_plant))
	picked = picked.filter(func(item: String) -> bool: return game.count(item) > 0)
	var list := HubUi.scroll(into)
	var cols := HubUi.row(14)
	list.add_child(cols)

	var plants := HubUi.card(cols, 664)
	plants.add_child(HubUi.label("Your plants", 20, UiTheme.ACCENT))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	plants.add_child(grid)
	var any := false
	var ids: Array = game.items.keys()
	ids.sort()
	for item: String in ids:
		if Materials.form(item) != "plant":
			continue
		any = true
		var plant := Crafting.plant_of(item)
		var on := picked.has(item)
		var full := Materials.display_name(item, game.values)       # "Moonleaf (Qi Gathering)": the name, then its tier
		var tier := full.get_slice(" (", 1).trim_suffix(")") if full.contains(" (") else ""
		var b := HubUi.tile(HubUi.sign("plant", on, 46, _plant_ink(plant)), full.get_slice(" (", 0), "", "%s×%d" % [tier + " · " if tier != "" else "", game.count(item)], on, func():
			if picked.has(item):
				picked.erase(item)
			elif picked.size() < 3:
				picked.append(item)
			hub.refresh(), 310)
		(b.get_meta("body") as VBoxContainer).add_child(_known_chips(plant, on))
		grid.add_child(b)
	if not any:
		plants.add_child(HubUi.dim("No plants yet: they come from the dungeon."))

	var right := HubUi.col(14)
	cols.add_child(right)
	var pot := HubUi.card(right)
	pot.add_child(HubUi.label("In the cauldron", 20, UiTheme.ACCENT))
	var slots := HubUi.row(10)
	pot.add_child(slots)
	for i in 3:
		var slot := PanelContainer.new()
		slot.custom_minimum_size = Vector2(150, 96)
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(UiTheme.INK, 0.05)
		sb.border_color = Color(UiTheme.INK, 0.45 if i < picked.size() else 0.2)
		sb.set_border_width_all(2)
		sb.set_corner_radius_all(48)
		sb.set_content_margin_all(8)
		slot.add_theme_stylebox_override("panel", sb)
		slots.add_child(slot)
		var inner := HubUi.col(0)
		inner.alignment = BoxContainer.ALIGNMENT_CENTER
		slot.add_child(inner)
		if i < picked.size():
			var plant := Crafting.plant_of(picked[i])
			var centre := CenterContainer.new()
			centre.add_child(UiTheme.icon_rect("plant", 40, _plant_ink(plant)))
			inner.add_child(centre)
			var name := HubUi.label(Materials.display_name(picked[i], game.values).get_slice(" (", 0), 15, UiTheme.TEXT)
			name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			inner.add_child(name)
		else:
			var empty := HubUi.label("third, if you like" if i == 2 else "a plant", 14, Color(UiTheme.DIM, 0.7))
			empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			inner.add_child(empty)
	pot.add_child(HubUi.label(_shared_text(), 17, UiTheme.DIM))
	var brew := HubUi.primary("Brew", func():
		Crafting.brew(game, picked.duplicate())
		hub.refresh(), 260)
	brew.disabled = not Crafting.can_brew(game, picked)
	pot.add_child(brew)

	var pills := HubUi.card(right)
	pills.add_child(HubUi.label("Your pills", 20, UiTheme.ACCENT))
	for pill in PillUse.pills(game):
		var uses: PackedStringArray = []
		for p in Crafting.pill_properties(pill):
			uses.append(String(Crafting.property(game.values, StringName(p)).get("pill", p)))
		var line := HubUi.row(10)
		line.add_child(UiTheme.icon_rect("pill", 30, UiTheme.CINNABAR))
		var text := HubUi.col(2)
		text.add_child(HubUi.label("%s ×%d" % [Materials.display_name(pill, game.values), game.count(pill)], 18))
		text.add_child(HubUi.label("; ".join(uses), 15, UiTheme.DIM))
		var flaw := Crafting.flaw_def(game.values, Materials.flaw(pill))
		if not flaw.is_empty():
			text.add_child(HubUi.label("Flaw: %s" % flaw["text"], 15, UiTheme.WARN))
		line.add_child(text)
		pills.add_child(line)
	if PillUse.pills(game).is_empty():
		pills.add_child(HubUi.dim("None yet."))
	var use := HubUi.flow()
	if PillUse.add_rows(use, self, false) > 0:
		pills.add_child(HubUi.label("Use here:", 18, UiTheme.DIM))
		pills.add_child(use)
	pills.add_child(HubUi.dim("Healing pills are taken between the battles of a dungeon. A pill that acts in a battle goes into a tamer slot when you prepare the battle. The relearning pill can be brewed but not used yet."))
