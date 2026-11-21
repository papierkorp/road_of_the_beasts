class_name ForgePanel
extends HubPanel
## Forge (docs/vision.md §7): a piece has a body of ore, a core of a beast part and an optional temper of an essence.
## The list shows every piece that exists and what it needs; nothing is found by trying.

static var ore := ""
static var essence := ""


func title() -> String:
	return "Forge"


func pillar() -> String:
	return "Tamer and kits"


func hint() -> String:
	return "Forge weapons and armour"


func _owned(form: String) -> Array[String]:
	var out: Array[String] = []
	var ids: Array = game.items.keys()
	ids.sort()
	for item: String in ids:
		if Materials.form(item) == form:
			out.append(item)
	return out


## A row of toggles for the ore (the tier) or the essence (the temper) the next piece is forged with.
func _pick(into: Control, label: String, form: String, current: String, set_it: Callable, optional := false) -> void:
	var row := HubUi.flow()
	into.add_child(row)
	row.add_child(HubUi.label(label, 20, UiTheme.TEXT, false))
	var owned := _owned(form)
	for item in owned:
		var text := "%s ×%d" % [Materials.display_name(item, game.values), game.count(item)]
		if form == "essence":
			var t := Crafting.temper_of(game, Materials.tier(item))
			text += " — %s: %s" % [t["name"], t["text"]]
		var b := HubUi.button(text, func():
			set_it.call("" if current == item and optional else item)
			hub.refresh(), 360)
		b.toggle_mode = true
		b.button_pressed = current == item
		row.add_child(b)
	if owned.is_empty():
		row.add_child(HubUi.dim("none" if optional else "none: ore comes from dungeons"))


func build(into: VBoxContainer) -> void:
	into.add_child(HubUi.dim("You see what you get before you forge. The beast part sets what the piece gives, the ore its tier, an essence adds one variation. A weapon fills a tamer slot, an armour is worn by a monster. A piece changes nothing in a battle yet."))
	var ores := _owned("ore")
	if not ores.has(ore):
		ore = ores[-1] if not ores.is_empty() else ""
	if essence != "" and game.count(essence) < 1:
		essence = ""
	var list := HubUi.scroll(into)
	var make := HubUi.card(list)
	_pick(make, "Body:", "ore", ore, func(v: String): ore = v)
	_pick(make, "Temper (optional):", "essence", essence, func(v: String): essence = v, true)
	for k: String in [Crafting.WEAPON, Crafting.ARMOUR]:
		var card := HubUi.card(list)
		card.add_child(HubUi.label(("Weapons: a skill for a tamer slot" + (" — your vow forbids them" if game.vow_has("no_weapons") else "")) if k == Crafting.WEAPON else "Armour: one more passive for a monster", 22, UiTheme.ACCENT))
		for kin in MonsterDef.Kin.size():
			var p := Materials.beast_part(kin)
			var core := Crafting.core_of(game, k, kin)
			var row := HubUi.row()
			card.add_child(row)
			var have := game.count(p)
			row.add_child(HubUi.label("%s — %s\nNeeds 1 ore and 1 %s (you have %d)" % [core["name"], core["text"], Materials.display_name(p, game.values), have],
				20, UiTheme.TEXT if have > 0 else UiTheme.DIM))
			var go := HubUi.button("Forge", func():
				Crafting.forge(game, k, ore, p, essence)
				hub.refresh(), 160)
			go.disabled = not Crafting.can_forge(game, k, ore, p, essence)
			row.add_child(go)
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
