class_name DungeonPanel
extends HubPanel
## Dungeon Gate (docs/vision.md §4, §6): start a run or a harvest; during a run the map of nodes.


func title() -> String:
	return "Dungeon Gate"


func pillar() -> String:
	return "Tamer and kits"


func hint() -> String:
	return "A run, or a harvest"


func build(into: VBoxContainer) -> void:
	if DungeonRun.running(game):
		_build_run(into)
		return
	into.add_child(HubUi.dim("A run costs %d AP, a harvest %d AP. HP stay from battle to battle; leaving keeps the loot, a defeat keeps %d%% of it. A battle here gives plants and a beast part per monster defeated, but no monster XP; the last battle holds the most." % [game.values.dungeon_ap, game.values.harvest_ap, game.values.dungeon_defeat_keeps]))
	var list := HubUi.scroll(into)
	for s in DungeonRun.stages(game):
		var card := HubUi.card(list)
		card.add_child(HubUi.label("Dungeon of %s" % Stage.stage_name(s as Stage.Type), 22, UiTheme.ACCENT))
		var done := DungeonRun.mastered(game, s)
		card.add_child(HubUi.label("Challenge: %s — %s" % [DungeonRun.challenge_text(game, s), "met" if done else "open"], 20, HubUi.GOOD if done else UiTheme.TEXT))
		var row := HubUi.row()
		card.add_child(row)
		var go := HubUi.button("Start a run (%d AP)" % game.values.dungeon_ap, func():
			DungeonRun.start(game, s)
			hub.refresh(), 320)
		go.disabled = not DungeonRun.can_start(game)
		row.add_child(go)
		var harvest := HubUi.button("Harvest without a battle (%d AP)" % game.values.harvest_ap, func():
			DungeonRun.harvest(game, s)
			hub.refresh(), 420)
		harvest.disabled = not DungeonRun.can_harvest(game, s)
		row.add_child(harvest)
		if not DungeonRun.can_start(game):
			card.add_child(HubUi.dim("A run needs %d AP." % game.values.dungeon_ap))


func _build_run(into: VBoxContainer) -> void:
	var top := HubUi.row()
	into.add_child(top)
	top.add_child(HubUi.label("Gathered: %s" % Materials.list_text(game.dungeon["loot"], game.values)))
	top.add_child(HubUi.button("Leave with the loot", func():
		DungeonRun.leave(game)
		hub.refresh(), 280))
	var hp: PackedStringArray = []
	for m in game.roster:
		hp.append("%s %d/%d" % [m.species().display_name, m.current_hp, m.max_hp()])
	into.add_child(HubUi.label("Your monsters: %s" % " · ".join(hp)))
	PillUse.add_dungeon_pills(into, self)
	if not DungeonRun.team_stands(game):
		into.add_child(HubUi.label("No monster can fight any more: leave the dungeon.", 20, HubUi.WARN))
	var list := HubUi.scroll(into)
	var open := DungeonRun.choices(game)
	var done := DungeonRun.path(game)
	var layer := -1
	var row: HBoxContainer = null
	for n in DungeonRun.nodes(game):
		if int(n["layer"]) != layer:
			layer = int(n["layer"])
			list.add_child(HubUi.label("Layer %d" % (layer + 1), 18, UiTheme.DIM))
			row = HubUi.row()
			list.add_child(row)
		var card := HubUi.card(row)
		var id := int(n["id"])
		var state := "cleared" if done.has(id) else ("open" if open.has(id) else "")
		var names := {DungeonRun.BATTLE: "Battle", DungeonRun.REST: "Rest", DungeonRun.LAST: "Last battle"}
		card.add_child(HubUi.label("%s%s" % [names[n["kind"]], " — " + state if state != "" else ""], 20, UiTheme.ACCENT if state == "open" else UiTheme.DIM))
		if n["kind"] == DungeonRun.REST:
			card.add_child(HubUi.label("Every monster that stands regains %d HP." % game.values.rest_heal))
			if state == "open":
				card.add_child(HubUi.button("Rest", func():
					DungeonRun.rest(game, id)
					hub.refresh()))
			continue
		var f := Fight.new()
		f.map_id = n["map"]
		card.add_child(HubUi.label("Battleground: %s" % GameSession.map_summary(f)))
		for e: MonsterInstance in n["enemies"]:
			card.add_child(HubUi.label(HubUi.monster_lines(e, false)))
		card.add_child(HubUi.dim("Loot: %s, and a beast part per monster defeated" % Materials.list_text(n["loot"], game.values)))
		if state == "open":
			var go := HubUi.button("Prepare the battle", func(): hub.prepare(DungeonRun.fight_for(game, id), func(_f: Fight) -> bool: return true))
			go.disabled = not DungeonRun.team_stands(game)
			card.add_child(go)
		var leads: PackedStringArray = []
		for t in n["next"]:
			leads.append("node %d" % (int(t) + 1))
		card.add_child(HubUi.dim("Node %d%s" % [id + 1, " → " + ", ".join(leads) if not leads.is_empty() else ""]))
