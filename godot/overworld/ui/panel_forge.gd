class_name ForgePanel
extends HubPanel
## Forge (docs/vision.md §7, docs/overworld.md §6.3): a piece is forged from two beast parts. The first says what it
## makes, the second how it acts. The same pair gives a weapon for a tamer slot or parts of the own battleground.
## Everything is shown before it is forged; which Kin gives what is drawn per game.

## The Kin of the first part (what) and of the second (how) the player has picked.
static var what := 0
static var how := 0


func title() -> String:
	return "Forge"


func pillar() -> String:
	return "Tamer and board"


func hint() -> String:
	return "Forge weapons and parts of your battleground"


## A row of toggles, one per Kin, with what its beast part gives in this place of the pair.
func _pick(into: Control, label: String, current: int, set_it: Callable, entry_of: Callable) -> void:
	into.add_child(HubUi.label(label, 20, UiTheme.ACCENT))
	var row := HubUi.flow()
	into.add_child(row)
	for kin in MonsterDef.Kin.size():
		var e: Dictionary = entry_of.call(kin)
		var have := game.count(Materials.beast_part(kin))
		var b := HubUi.button("%s ×%d\n%s: %s" % [Materials.display_name(Materials.beast_part(kin), game.values), have, e["name"], e["text"]], func():
			set_it.call(kin)
			hub.refresh(), 400)
		b.custom_minimum_size.y = HubUi.TAP + 24
		b.toggle_mode = true
		b.button_pressed = current == kin
		row.add_child(b)


func build(into: VBoxContainer) -> void:
	var v := game.values
	into.add_child(HubUi.dim("A piece takes two beast parts: the first says what it makes, the second how it acts. What each Kin gives differs from game to game; you see what you get before you forge. Beast parts come from every wild monster you defeat, in the dungeon and in the wild area."))
	var list := HubUi.scroll(into)
	var pick := HubUi.card(list)
	_pick(pick, "First part — what it makes", what, func(k: int): what = k, func(k: int) -> Dictionary: return Crafting.what_of(v, Crafting.what_index(game, k)))
	_pick(pick, "Second part — how it acts", how, func(k: int): how = k, func(k: int) -> Dictionary: return Crafting.how_of(v, Crafting.how_index(game, k)))
	var wi := Crafting.what_index(game, what)
	var hi := Crafting.how_index(game, how)
	var piece := HubUi.card(list)
	piece.add_child(HubUi.label("%s — %s" % [Crafting.piece_name(v, wi, hi), Crafting.piece_text(v, wi, hi)], 22, UiTheme.ACCENT))
	piece.add_child(HubUi.label("Costs: %s" % Materials.list_text(Crafting.forge_cost(what, how), v)))
	var row := HubUi.row()
	piece.add_child(row)
	var uses := int(Crafting.how_of(v, hi).get("uses", 1))
	var weapon := HubUi.button("Forge as a weapon\nlaid from a tamer slot, %s" % ("%d times per battle" % uses if uses > 1 else "once per battle"), func():
		Crafting.forge(game, Crafting.WEAPON, what, how)
		hub.refresh(), 420)
	weapon.custom_minimum_size.y = HubUi.TAP + 24
	weapon.disabled = not Crafting.can_forge(game, Crafting.WEAPON, what, how)
	row.add_child(weapon)
	var part := HubUi.button("Forge for your battleground\n%d × %s to place in the workshop" % [Crafting.part_units(v, hi), GameSession.part_name(Crafting.board_part(v, wi))], func():
		Crafting.forge(game, Crafting.PART, what, how)
		hub.refresh(), 520)
	part.custom_minimum_size.y = HubUi.TAP + 24
	part.disabled = not Crafting.can_forge(game, Crafting.PART, what, how)
	row.add_child(part)
	if game.vow_has("no_weapons"):
		piece.add_child(HubUi.dim("Your vow forbids weapons."))
	var pieces := HubUi.card(list)
	pieces.add_child(HubUi.label("Your weapons", 20, UiTheme.ACCENT))
	var ids: Array = game.items.keys()
	ids.sort()
	var any := false
	for item: String in ids:
		if Materials.form(item) != Crafting.WEAPON:
			continue
		any = true
		pieces.add_child(HubUi.label("%s ×%d — lays %s" % [Materials.display_name(item, v), game.count(item),
			Crafting.piece_text(v, int(item.get_slice(":", 1)), int(item.get_slice(":", 2)))]))
	if not any:
		pieces.add_child(HubUi.dim("None yet. A weapon is put into a tamer slot when you prepare a battle."))
	var parts: PackedStringArray = []
	for id: String in game.parts:
		parts.append("%d × %s" % [int(game.parts[id]), GameSession.part_name(id)])
	pieces.add_child(HubUi.label("Parts of your battleground: %s" % (", ".join(parts) if not parts.is_empty() else "none")))
