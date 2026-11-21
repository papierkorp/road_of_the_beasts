class_name ForgePanel
extends HubPanel
## Forge (docs/vision.md §7): a piece has a body of ore, a core of a beast part and an optional temper of an essence.

static var kind := Crafting.ARMOUR
static var ore := ""
static var part := ""
static var essence := ""


func title() -> String:
	return "Forge"


func pillar() -> String:
	return "Tamer and kits"


func hint() -> String:
	return "Forge weapons and armour"


func _pick(into: Control, label: String, form: String, current: String, set_it: Callable, optional := false) -> void:
	into.add_child(HubUi.label(label, 18, UiTheme.DIM))
	var flow := HubUi.flow()
	into.add_child(flow)
	var ids: Array = game.items.keys()
	ids.sort()
	var any := false
	for item: String in ids:
		if Materials.form(item) != form:
			continue
		any = true
		var text := "%s ×%d" % [Materials.display_name(item, game.values), game.count(item)]
		if form == "part":
			text += "\ngives: %s" % game.known.get("core:%s:%d" % [kind, int(item.get_slice(":", 1))], "?")
		elif form == "essence":
			text += "\ngives: %s" % game.known.get("temper:%d" % Materials.tier(item), "?")
		var b := HubUi.button(text, func():
			set_it.call("" if current == item and optional else item)
			hub.refresh(), 320)
		b.custom_minimum_size.y = HubUi.TAP + (24 if form != "ore" else 0)
		b.toggle_mode = true
		b.button_pressed = current == item
		flow.add_child(b)
	if not any:
		flow.add_child(HubUi.dim("none"))


func build(into: VBoxContainer) -> void:
	into.add_child(HubUi.dim("The ore sets the tier, the beast part what the piece gives, the essence one variation. What a part gives is drawn anew for every game and found by forging. A piece changes nothing in a battle yet."))
	for item: String in [ore, part, essence]:
		if item != "" and game.count(item) < 1:
			ore = "" if item == ore else ore
			part = "" if item == part else part
			essence = "" if item == essence else essence
	var list := HubUi.scroll(into)
	var make := HubUi.card(list)
	var kinds := HubUi.row()
	make.add_child(kinds)
	for k: String in [Crafting.ARMOUR, Crafting.WEAPON]:
		var b := HubUi.button("Armour (a monster: one more passive)" if k == Crafting.ARMOUR else "Weapon (the tamer: a skill)", func():
			kind = k
			hub.refresh(), 420)
		b.toggle_mode = true
		b.button_pressed = kind == k
		kinds.add_child(b)
	_pick(make, "Body: ore", "ore", ore, func(v: String): ore = v)
	_pick(make, "Core: a beast part (wild area)", "part", part, func(v: String): part = v)
	_pick(make, "Temper: an essence (optional; the last battle of a dungeon)", "essence", essence, func(v: String): essence = v, true)
	var go := HubUi.button("Forge", func():
		Crafting.forge(game, kind, ore, part, essence)
		hub.refresh(), 260)
	go.disabled = not Crafting.can_forge(game, kind, ore, part, essence)
	make.add_child(go)
	var pieces := HubUi.card(list)
	pieces.add_child(HubUi.label("Your pieces", 20, UiTheme.ACCENT))
	var ids: Array = game.items.keys()
	ids.sort()
	var any := false
	for item: String in ids:
		if not Materials.form(item) in [Crafting.WEAPON, Crafting.ARMOUR]:
			continue
		any = true
		var row := HubUi.flow()
		pieces.add_child(row)
		row.add_child(HubUi.label("%s ×%d" % [Materials.display_name(item, game.values), game.count(item)], 20, UiTheme.TEXT, false))
		if Materials.form(item) == Crafting.ARMOUR:
			for m in game.roster:
				row.add_child(HubUi.button("Put on %s" % m.species().display_name, func():
					Crafting.wear(game, m, item)
					hub.refresh(), 280))
	if not any:
		pieces.add_child(HubUi.dim("None yet."))
	for m in game.roster:
		if m.armour != &"":
			var row := HubUi.row()
			pieces.add_child(row)
			row.add_child(HubUi.label("%s wears %s" % [m.species().display_name, Materials.display_name(String(m.armour), game.values)]))
			row.add_child(HubUi.button("Take off", func():
				Crafting.wear(game, m, "")
				hub.refresh(), 160))
