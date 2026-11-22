class_name CultivationPanel
extends HubPanel
## Cultivation Hall (docs/vision.md §8): the tree of the Way, a tree per stage.


func title() -> String:
	return "Cultivation Hall"


func pillar() -> String:
	return "Tamer"


func hint() -> String:
	return "Spend Insight in the tree of your Way"


func build(into: VBoxContainer) -> void:
	var def := Cultivation.system(game)
	into.add_child(HubUi.label("%s — %d Insight. A depth of the void won gives one; a stage gives about enough for one branch." % [def.display_name, game.path_points], 22, UiTheme.ACCENT))
	into.add_child(HubUi.dim(def.blurb))
	var list := HubUi.scroll(into)
	_vows(list)
	var content := GameSession.battle_content()
	for s in Stage.Type.size():
		var nodes := def.nodes_of(s)
		if nodes.is_empty():
			continue
		var open := s <= int(game.stage)
		list.add_child(HubUi.label("Tree of %s%s" % [Stage.stage_name(s as Stage.Type), "" if open else " — opens with the breakthrough"], 22, UiTheme.TEXT if open else UiTheme.DIM))
		for branch: Dictionary in def.branches:
			list.add_child(HubUi.label("%s: %s" % [branch["name"], branch["text"]], 18, UiTheme.DIM))
			var row := HubUi.flow()
			list.add_child(row)
			for n: Dictionary in nodes:
				if String(n.get("branch", "")) != String(branch["id"]):
					continue
				var card := HubUi.card(row, 440)
				var id := StringName(n["id"])
				card.add_child(HubUi.label("%s (%d)" % [n["name"], int(n["cost"])], 20, UiTheme.ACCENT))
				var t := content.tamer_skill(n["ref"])
				card.add_child(HubUi.label("Tamer skill: %s" % (t.description if t != null else "?")))
				var why := Cultivation.problem(game, id)
				var b := HubUi.button("Buy" if why == "" else why.capitalize(), func():
					Cultivation.buy(game, id)
					hub.refresh(), 300)
				b.disabled = why != ""
				card.add_child(b)


## The vows (docs/overworld.md §5.3): those taken, and the offer if one is open.
func _vows(list: VBoxContainer) -> void:
	var card := HubUi.card(list)
	card.add_child(HubUi.label("Vows: %d of at most %d" % [game.vows.size(), game.values.vow_cap], 22, UiTheme.ACCENT))
	card.add_child(HubUi.dim("A vow gives something strong and takes something for the rest of the game. Three are offered at the start and after every breakthrough; you take one or none."))
	for id in game.vows:
		var v := game.vow_def(id)
		card.add_child(HubUi.label("%s — %s Price: %s" % [v["name"], v["gain"], v["price"]]))
	if game.vow_offer.is_empty():
		return
	card.add_child(HubUi.label("Offered now:", 20, HubUi.GOOD))
	for id in game.vow_offer:
		var v := game.vow_def(id)
		var row := HubUi.row()
		card.add_child(row)
		row.add_child(HubUi.label("%s\nYou gain: %s\nThe price: %s" % [v["name"], v["gain"], v["price"]]))
		row.add_child(HubUi.button("Swear", func():
			game.take_vow(id)
			hub.refresh(), 160))
	card.add_child(HubUi.button("Take none", func():
		game.take_vow(&"")
		hub.refresh(), 220))
