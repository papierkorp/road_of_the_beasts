class_name TrainingPanel
extends HubPanel
## Training Ground (docs/vision.md §6, docs/monsters.md §2.2): the player spends the stat points of each step.


func title() -> String:
	return "Training Ground"


func pillar() -> String:
	return "Monster: growth"


func hint() -> String:
	return "Spend stat points"


func build(into: VBoxContainer) -> void:
	into.add_child(HubUi.dim("Every step of growth gives %d stat points. A monster grows by the XP of the battles it fought and never past your stage." % MonsterInstance.STEP_POINTS))
	var list := HubUi.scroll(into)
	for m in game.roster:
		var card := HubUi.card(list)
		card.add_child(HubUi.label(m.title(), 22, UiTheme.ACCENT))
		card.add_child(HubUi.label("%s\n%s · %d stat points unspent" % [m.stats_text(), m.xp_text(), m.unspent]))
		var row := HubUi.flow()
		card.add_child(row)
		for stat in MonsterInstance.STAT_ORDER:
			var price := m.price_of(stat)
			var text := "%s +%s (%d)" % [MonsterInstance.STAT_NAMES[stat], "0.1" if stat == "pace" else "1", price] if price >= 0 else "%s at its top" % MonsterInstance.STAT_NAMES[stat]
			var b := HubUi.button(text, func():
				m.buy(stat)
				hub.refresh(), 210)
			b.disabled = not m.can_buy(stat)
			row.add_child(b)
