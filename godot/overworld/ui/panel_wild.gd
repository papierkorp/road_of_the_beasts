class_name WildPanel
extends HubPanel
## Wild Gate (docs/vision.md §4, §6): today's encounters of a zone; a battle costs day AP.

static var zone := -1


func title() -> String:
	return "Wild Gate"


func pillar() -> String:
	return "Monster: roster"


func hint() -> String:
	return "Single battles for day AP; catch monsters"


func build(into: VBoxContainer) -> void:
	var zones := WildArea.zones(game)
	if not zones.has(zone):
		zone = zones[-1]
	var pick := HubUi.row()
	into.add_child(pick)
	pick.add_child(HubUi.label("Zone:", 20, UiTheme.TEXT, false))
	for z in zones:
		var b := HubUi.button(Stage.stage_name(z as Stage.Type), func():
			zone = z
			hub.refresh(), 200)
		b.toggle_mode = true
		b.button_pressed = z == zone
		pick.add_child(b)
	into.add_child(HubUi.dim("A battle costs %d day AP and starts at full HP. The list is drawn anew every night." % game.values.wild_ap))
	var list := HubUi.scroll(into)
	for e in WildArea.encounters(game, zone):
		var card := HubUi.card(list)
		var f := e.fight
		var head := f.title
		if e.rare:
			head += " — appears in %d day(s)" % e.appears_in if e.appears_in > 0 else " — stays %d more day(s)" % e.stays
		card.add_child(HubUi.label(head, 22, UiTheme.ACCENT if not e.rare else HubUi.GOOD))
		card.add_child(HubUi.label("Battleground: %s" % GameSession.map_summary(f)))
		for m in f.enemies:
			card.add_child(HubUi.label(HubUi.monster_lines(m)))
		card.add_child(HubUi.dim("A win gives: %s" % f.loot_text))
		var go := HubUi.button("Gone" if e.gone else "Prepare the battle (%d AP)" % game.values.wild_ap, hub.prepare.bind(f, func(_f: Fight) -> bool: return WildArea.pay(game)), 320)
		go.disabled = e.gone or e.appears_in > 0 or game.ap < game.values.wild_ap or game.forced_trial
		card.add_child(go)
