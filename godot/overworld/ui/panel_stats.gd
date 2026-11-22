class_name StatsPanel
extends HubPanel
## The stat points of each monster (docs/monsters.md §2.2): every step of growth gives points the player spends.


## The sign of each stat (assets/icons).
const STAT_ICONS := {"hp": "stat_hp", "pace": "stat_pace", "move": "stat_stamina", "reach": "stat_reach", "ap": "stat_ap", "tpr": "stat_turns"}


func build(into: VBoxContainer) -> void:
	into.add_child(HubUi.dim("Every step of growth gives %d stat points. A monster fresh from the egg can take its points back until its first battle." % MonsterInstance.STEP_POINTS))
	var list := HubUi.scroll(into)
	for m in game.roster:
		var card := HubUi.card(list)
		card.add_child(HubUi.monster_head(m))
		card.add_child(HubUi.label("%s · %d stat points unspent" % [m.xp_text(), m.unspent], 18, HubUi.GOOD if m.unspent > 0 else UiTheme.DIM))
		var row := HubUi.flow()
		card.add_child(row)
		for stat in MonsterInstance.STAT_ORDER:
			var price := m.price_of(stat)
			var text := "%s +%s (%d)" % [MonsterInstance.STAT_NAMES[stat], "0.1" if stat == "pace" else "1", price] if price >= 0 else "%s at its top" % MonsterInstance.STAT_NAMES[stat]
			var b := HubUi.button(text, func():
				m.buy(stat)
				hub.refresh(), 210)
			b.disabled = not m.can_buy(stat)
			b.icon = UiTheme.icon(STAT_ICONS.get(stat, ""))
			b.add_theme_constant_override("icon_max_width", 22)
			row.add_child(b)
		if m.fresh:
			row.add_child(HubUi.button("Take all points back", func():
				m.refund_points()
				m.heal_full()
				hub.refresh(), 260))
