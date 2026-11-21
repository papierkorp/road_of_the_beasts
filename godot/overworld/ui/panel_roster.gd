class_name RosterPanel
extends HubPanel
## The roster and its order, and the eggs.


func build(into: VBoxContainer) -> void:
	into.add_child(HubUi.dim("%d of %d places taken. The order is the order a team is filled in. A monster grows only by the XP of the battles it fought, and never past your stage." % [game.roster.size() + game.eggs.size(), game.values.roster_cap]))
	var list := HubUi.scroll(into)
	for i in game.roster.size():
		var m := game.roster[i]
		var card := HubUi.card(list)
		card.add_child(HubUi.label(HubUi.monster_lines(m)))
		card.add_child(HubUi.dim(HubUi.kin_lines(m)))
		card.add_child(HubUi.dim("%s · %s · %d stat points and %d development steps unspent" % [MonsterInstance.Rarity.keys()[m.rarity].capitalize(), m.xp_text(), m.unspent, m.dev_steps]))
		var todo := HubUi.todo_text(m)
		if todo != "":
			card.add_child(HubUi.label(todo, 20, HubUi.GOOD))
		var row := HubUi.row()
		card.add_child(row)
		var up := HubUi.button("Move up", func():
			game.roster.remove_at(i)
			game.roster.insert(i - 1, m)
			hub.refresh(), 160)
		up.disabled = i == 0
		row.add_child(up)
		var free := HubUi.button("Release", func():
			game.roster.remove_at(i)
			game.say("%s was released." % m.species().display_name)
			hub.refresh(), 160)
		free.disabled = game.roster.size() <= 1
		row.add_child(free)
	for e in game.eggs:
		var card := HubUi.card(list)
		var def := GameData.monster(StringName(e["species"]))
		card.add_child(HubUi.label("Egg: %s — hatches in %d year(s). You shape what hatches: its stat points and its skills." % [def.display_name if def != null else e["species"], int(e["nights"])]))
