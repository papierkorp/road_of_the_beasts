class_name CultivationPanel
extends HubPanel
## Cultivation Hall (docs/vision.md §8): the tree of the Way, a tree per stage.


func title() -> String:
	return "Cultivation Hall"


func pillar() -> String:
	return "The Way"


func hint() -> String:
	return "Spend Insight in the tree of your Way"


func build(into: VBoxContainer) -> void:
	var def := Cultivation.system(game)
	var head := HubUi.row(14)
	head.add_child(UiTheme.icon_rect(String(def.id), 56))
	var words := HubUi.col(2)
	words.add_child(HubUi.label("%s — %d Insight. A depth of the void won gives one%s." % [def.display_name, game.path_points, ", a larger battle of the wild too" if game.is_formation() else ""], 22, UiTheme.ACCENT))
	words.add_child(HubUi.dim(def.blurb))
	head.add_child(words)
	into.add_child(head)
	var list := HubUi.scroll(into)
	_boons(list)
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
				var owned := game.nodes.has(id)
				card.add_child(HubUi.signed(UiTheme.icon_rect("tamer", 34, UiTheme.JADE if owned else UiTheme.INK), "%s · %d Insight" % [n["name"], int(n["cost"])], 20, UiTheme.ACCENT))
				if String(n.get("kind", "")) == "tamer":
					var t := content.tamer_skill(n["ref"])
					card.add_child(HubUi.label("Tamer skill: %s" % (t.description if t != null else "?")))
				elif String(n.get("kind", "")) == "seal":
					card.add_child(HubUi.label("Seal option (a development step, %d at most): %s" % [TamerSkillDef.SEAL_MAX_OPTIONS, String(n.get("text", ""))]))
				else:
					card.add_child(HubUi.label(String(n.get("text", ""))))
				var why := Cultivation.problem(game, id)
				var b := HubUi.button("Buy" if why == "" else why.capitalize(), func():
					Cultivation.buy(game, id)
					hub.refresh(), 300)
				b.disabled = why != ""
				card.add_child(b)


## The boons (docs/overworld.md §5.1): one is taken at every breakthrough.
func _boons(list: VBoxContainer) -> void:
	if game.boons.is_empty() and not game.boon_pick:
		return
	var card := HubUi.card(list)
	var names: PackedStringArray = []
	for id in game.boons:
		names.append(String(game.vow_def(id)["name"]))
	card.add_child(HubUi.label("Boons: %s" % (", ".join(names) if not names.is_empty() else "none yet"), 22, UiTheme.ACCENT))
	if not game.boon_pick:
		return
	card.add_child(HubUi.label("Your breakthrough offers a boon. Choose one:", 20, HubUi.GOOD))
	for b: Dictionary in game.values.boons:
		var id := StringName(b["id"])
		var row := HubUi.row()
		card.add_child(row)
		var text := HubUi.col(0)
		text.add_child(HubUi.title(String(b["name"]), 21))
		text.add_child(HubUi.label(String(b["text"]), 17, HubUi.GOOD))
		row.add_child(text)
		row.add_child(HubUi.button("Take", func():
			game.take_boon(id)
			hub.refresh(), 160))


## The vows (docs/overworld.md §5.3): those taken, and the offer if one is open.
func _vows(list: VBoxContainer) -> void:
	var card := HubUi.card(list)
	card.add_child(HubUi.label("Vows: %d of at most %d" % [game.vows.size(), game.values.vow_cap], 22, UiTheme.ACCENT))
	card.add_child(HubUi.dim("A vow gives something strong and takes something for the rest of the game. Three are offered at the start and after every breakthrough; you take one or none."))
	for id in game.vows:
		var v := game.vow_def(id)
		card.add_child(HubUi.signed(UiTheme.icon_rect("vow", 30, UiTheme.CINNABAR), "%s — %s Price: %s" % [v["name"], v["gain"], v["price"]]))
	if game.vow_offer.is_empty():
		return
	card.add_child(HubUi.label("Offered now:", 20, HubUi.GOOD))
	for id in game.vow_offer:
		var v := game.vow_def(id)
		var row := HubUi.row()
		card.add_child(row)
		var seal := UiTheme.icon_rect("vow", 40, Color(UiTheme.CINNABAR, 0.55))
		seal.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(seal)
		var text := HubUi.col(0)
		text.add_child(HubUi.title(String(v["name"]), 21))
		text.add_child(HubUi.label("You gain: %s" % v["gain"], 17, HubUi.GOOD))
		text.add_child(HubUi.label("The price: %s" % v["price"], 17, HubUi.WARN))
		row.add_child(text)
		row.add_child(HubUi.button("Swear", func():
			game.take_vow(id)
			hub.refresh(), 160))
	card.add_child(HubUi.button("Take none", func():
		game.take_vow(&"")
		hub.refresh(), 220))
