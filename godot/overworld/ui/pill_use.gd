class_name PillUse
extends RefCounted
## Using pills outside a battle (docs/overworld.md §6.2).


static func pills(game: GameState) -> Array[String]:
	var out: Array[String] = []
	for id: String in game.items:
		if Materials.form(id) == "pill":
			out.append(id)
	out.sort()
	return out


## One row per pill and monster it can be given to.
static func add_rows(into: Control, panel: HubPanel) -> int:
	var game := panel.game
	var rows := 0
	for pill in pills(game):
		for m in game.roster:
			if Crafting.use_problem(game, pill, m) != "":
				continue
			rows += 1
			into.add_child(HubUi.button("%s ×%d → %s" % [Materials.display_name(pill, game.values), game.count(pill),
				m.species().display_name], func():
					Crafting.use(game, pill, m)
					panel.hub.refresh(), 560))
	return rows
