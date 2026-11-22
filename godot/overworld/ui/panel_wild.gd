class_name WildPanel
extends HubPanel
## The wild (docs/vision.md §4): the battles of the look the player has now, each with its battleground, its
## monsters and what a win drops; a new look for a year of the lifespan.


func title() -> String:
	return "Wild"


func pillar() -> String:
	return "Monsters and your Way"


func hint() -> String:
	return "Battles for growth and for what your Way uses"


## What a battle drops for this Way, in words.
func _reward() -> String:
	if game.is_artificer():
		return "parts of a battleground, one unit per monster"
	if game.is_alchemist():
		return "pills, one per monster"
	return "1 Insight from a battle against %d monsters or more" % game.values.wild_insight_from


func build(into: VBoxContainer) -> void:
	var v := game.values
	into.add_child(HubUi.dim("A wild battle costs %d year of your lifespan, won or lost. A win drops: %s. Every wild monster defeated lifts one of your monsters that fought, still stands and is at its step or below — one step, never past High; into the next stage a monster rises only in the void. Every battle starts at full HP. Wild monsters are caught here." % [v.wild_years, _reward()]))
	var list := HubUi.scroll(into)
	var row := HubUi.flow()
	list.add_child(row)
	var open := Wild.open(game)
	for o in Wild.offers(game):
		var id := int(o["id"])
		var card := HubUi.card(row, 500)
		var gone := game.wild_gone.has(id)
		card.add_child(HubUi.label("Battle %d%s" % [id + 1, " — won" if gone else ""], 20, UiTheme.DIM if gone else UiTheme.ACCENT))
		if gone:
			continue
		var f := Fight.new()
		f.own_map = o["map"]
		var foes: Array[MonsterInstance] = []
		foes.assign(o["enemies"])
		f.enemies = foes
		card.add_child(HubUi.fight_view(f, false, 14.0))
		card.add_child(HubUi.dim("Drops: %s" % Wild.drop_text(game, o)))
		var go := HubUi.primary("Prepare the battle", func(): hub.prepare(Wild.fight_for(game, id), func(_f: Fight) -> bool: return Wild.can_fight(game)))
		go.disabled = not Wild.can_fight(game)
		card.add_child(go)
	var again := HubUi.button("Look for other battles: %d year" % v.reroll_years, func():
		Wild.reroll(game)
		hub.refresh(), 360)
	again.disabled = not Wild.can_fight(game)
	into.add_child(again)
	if open.is_empty():
		into.add_child(HubUi.dim("Nothing is open."))
