class_name RosterPanel
extends HubPanel
## The roster and its order, and the eggs.


func build(into: VBoxContainer) -> void:
	into.add_child(HubUi.dim("%d of %d places taken. The order is the order a team is filled in. A monster rises a step by a wild battle won against a monster of its step or above, into the next stage by a battle won in the void, and never past your stage." % [game.roster.size() + game.eggs.size(), game.roster_cap()]))
	var list := HubUi.scroll(into)
	var waiting := Wild.can_rise(game)
	if not waiting.is_empty():
		var rise := HubUi.card(list)
		rise.add_child(HubUi.label("Rises to give: %d — the last battle left fewer than monsters that could take one. Choose who rises; what you do not give is lost with the next battle." % game.rises.size(), 20, HubUi.GOOD))
		var who := HubUi.flow()
		rise.add_child(who)
		for m in waiting:
			who.add_child(HubUi.button("%s (%s %s) rises" % [m.species().display_name, Stage.stage_name(m.stage), Stage.sub_tier_name(m.sub_tier)], func():
				Wild.give(game, m)
				hub.refresh(), 420))
	for i in game.roster.size():
		var m := game.roster[i]
		var card := HubUi.card(list)
		card.add_child(HubUi.monster_head(m))
		card.add_child(HubUi.label("Kit: %s" % m.kit_text()))
		card.add_child(HubUi.dim(HubUi.kin_lines(m)))
		card.add_child(HubUi.dim("%s · %d stat points and %d development steps unspent" % [m.growth_text(), m.unspent, m.dev_steps]))
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
		card.add_child(HubUi.label("Egg: %s — hatches after %d more battle(s). You shape what hatches: its stat points and its skills." % [def.display_name if def != null else e["species"], int(e["battles"])]))
