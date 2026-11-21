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


## One row per pill and monster it can be used on.
static func add_rows(into: Control, panel: HubPanel, in_dungeon: bool) -> int:
	var game := panel.game
	var rows := 0
	for pill in pills(game):
		for m in game.roster:
			if Crafting.use_problem(game, pill, m, in_dungeon) != "":
				continue
			rows += 1
			into.add_child(HubUi.button("%s ×%d → %s (HP %d/%d)" % [Materials.display_name(pill, game.values), game.count(pill),
				m.species().display_name, m.current_hp, m.max_hp()], func():
					Crafting.use(game, pill, m, in_dungeon)
					panel.hub.refresh(), 560))
	return rows


## The healing pills the player may take between the battles of a dungeon.
static func add_dungeon_pills(into: VBoxContainer, panel: HubPanel) -> void:
	var box := HubUi.flow()
	if add_rows(box, panel, true) > 0:
		into.add_child(HubUi.label("Pills:", 18, UiTheme.DIM))
		into.add_child(box)
