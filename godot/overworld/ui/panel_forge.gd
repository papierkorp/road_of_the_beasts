class_name ForgePanel
extends HubPanel
## Forge (docs/vision.md §7, docs/overworld.md §6.3): a piece is forged from two beast parts. The first says what it
## makes, the second how it acts. The same pair gives a weapon for a tamer slot or parts of the own battleground.
## Everything is shown before it is forged; which Kin gives what is drawn per game.
## The screen reads left to right: what it makes · how it acts · the piece.

## The Kin of the first part (what) and of the second (how) the player has picked.
static var what := 0
static var how := 0


func title() -> String:
	return "Forge"


func pillar() -> String:
	return "Tamer and board"


func hint() -> String:
	return "Forge weapons and parts of your battleground"


## The colour of what a piece lays: the colour of its ground or prop on the board.
func _what_color(index: int) -> Color:
	var w := Crafting.what_of(game.values, index)
	var content := GameSession.battle_content()
	if w.has("prop"):
		var p := content.prop(w["prop"])
		return p.color if p != null else UiTheme.INK_SOFT
	var g := content.ground(w.get("ground", &"plain"))
	return g.color if g != null else UiTheme.INK_SOFT


func _owned(kin: int) -> String:
	return "%s ×%d" % [Materials.display_name(Materials.beast_part(kin), game.values), game.count(Materials.beast_part(kin))]


## A card with one tile per Kin, two in a row.
func _column(into: Control, head: String, current: int, set_it: Callable, tile_of: Callable) -> void:
	var card := HubUi.card(into, 624)
	card.add_child(HubUi.label(head, 20, UiTheme.ACCENT))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	card.add_child(grid)
	for kin in MonsterDef.Kin.size():
		var b: Button = tile_of.call(kin, current == kin, func():
			set_it.call(kin)
			hub.refresh())
		grid.add_child(b)


func build(into: VBoxContainer) -> void:
	var v := game.values
	into.add_child(HubUi.dim("Two beast parts make a piece: the first says what it makes, the second how it acts. What each Kin gives differs from game to game. Beast parts come from every wild monster you defeat."))
	var list := HubUi.scroll(into)
	var cols := HubUi.row(14)
	list.add_child(cols)
	_column(cols, "First part — what it makes", what, func(k: int): what = k, func(kin: int, picked: bool, action: Callable) -> Button:
		var e := Crafting.what_of(v, Crafting.what_index(game, kin))
		var lacking := game.count(Materials.beast_part(kin)) <= 0
		var sign := HubUi.row(6)
		sign.add_child(HubUi.sign("part_%d" % kin, picked, 40))
		sign.add_child(HubUi.swatch(_what_color(Crafting.what_index(game, kin)), 20, UiTheme.PAPER_LIGHT if picked else UiTheme.INK))
		return HubUi.tile(sign, e["name"], e["text"], _owned(kin), picked, action, 290, lacking))
	_column(cols, "Second part — how it acts", how, func(k: int): how = k, func(kin: int, picked: bool, action: Callable) -> Button:
		var e := Crafting.how_of(v, Crafting.how_index(game, kin))
		var lacking := game.count(Materials.beast_part(kin)) <= (1 if kin == what else 0)
		var sign := HubUi.row(6)
		sign.add_child(HubUi.sign("part_%d" % kin, picked, 40))
		sign.add_child(HubUi.squares(int(e.get("count", 1)), int(e.get("uses", 1)), UiTheme.PAPER_LIGHT if picked else UiTheme.INK, 9, UiTheme.PAPER_LIGHT if picked else UiTheme.INK))
		return HubUi.tile(sign, e["name"], e["text"], _owned(kin), picked, action, 290, lacking))

	# the piece: what the two parts give, as it will lie on the board
	var wi := Crafting.what_index(game, what)
	var hi := Crafting.how_index(game, how)
	var h := Crafting.how_of(v, hi)
	var uses := int(h.get("uses", 1))
	var piece := HubUi.card(cols)
	piece.add_child(HubUi.label("The piece", 20, UiTheme.ACCENT))
	piece.add_child(HubUi.title(Crafting.piece_name(v, wi, hi), 30))
	var shown := HubUi.row(10)
	shown.add_child(HubUi.squares(int(h.get("count", 1)), uses, _what_color(wi), 26))
	piece.add_child(shown)
	piece.add_child(HubUi.label(Crafting.piece_text(v, wi, hi), 17))
	var cost := HubUi.row(8)
	cost.add_child(HubUi.label("Costs", 16, UiTheme.DIM, false))
	var need: Dictionary = Crafting.forge_cost(what, how)
	for kin in MonsterDef.Kin.size():
		var item := Materials.beast_part(kin)
		if not need.has(item):
			continue
		var enough := game.count(item) >= int(need[item])
		cost.add_child(UiTheme.icon_rect("part_%d" % kin, 26, UiTheme.INK if enough else UiTheme.WARN))
		cost.add_child(HubUi.label("%s ×%d" % [Materials.display_name(item, v), int(need[item])], 16, UiTheme.TEXT if enough else UiTheme.WARN, false))
	piece.add_child(cost)
	var weapon := HubUi.primary("Forge as a weapon\nfrom a tamer slot, %s" % ("%d times per battle" % uses if uses > 1 else "once per battle"), func():
		Crafting.forge(game, Crafting.WEAPON, what, how)
		hub.refresh(), 0)
	weapon.custom_minimum_size.y = HubUi.TAP + 24
	weapon.disabled = not Crafting.can_forge(game, Crafting.WEAPON, what, how)
	piece.add_child(weapon)
	var part := HubUi.button("Forge for your battleground\n%d × %s for the workshop" % [Crafting.part_units(v, hi), GameSession.part_name(Crafting.board_part(v, wi))], func():
		Crafting.forge(game, Crafting.PART, what, how)
		hub.refresh(), 0)
	part.custom_minimum_size.y = HubUi.TAP + 24
	part.disabled = not Crafting.can_forge(game, Crafting.PART, what, how)
	piece.add_child(part)
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
		var w_index := int(item.get_slice(":", 1))
		var h_index := int(item.get_slice(":", 2))
		var hw := Crafting.how_of(v, h_index)
		var line := HubUi.row(10)
		line.add_child(HubUi.squares(int(hw.get("count", 1)), int(hw.get("uses", 1)), _what_color(w_index), 14))
		line.add_child(HubUi.label("%s ×%d — lays %s" % [Materials.display_name(item, v), game.count(item), Crafting.piece_text(v, w_index, h_index)]))
		pieces.add_child(line)
	if not any:
		pieces.add_child(HubUi.dim("None yet. A weapon is put into a tamer slot when you prepare a battle."))
	var parts: PackedStringArray = []
	for id: String in game.parts:
		parts.append("%d × %s" % [int(game.parts[id]), GameSession.part_name(id)])
	pieces.add_child(HubUi.label("Parts of your battleground: %s" % (", ".join(parts) if not parts.is_empty() else "none")))
