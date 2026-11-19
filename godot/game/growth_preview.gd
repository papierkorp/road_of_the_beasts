extends Control
## Growth preview: a test screen that walks through the growth of docs/vision.md §8 by clicking. Every click shows
## what it gives to everyone, where the player chooses and where the rules have a gap (GrowthModel). Not the game.

const MENU_SCENE := "res://game/menu.tscn"
const KIND_COLOR := {"choice": "c9a35c", "fixed": "e8e3d4", "gap": "e0876a", "note": "9e998c"}
const KIND_MARK := {"choice": "CHOICE", "fixed": "GIVEN", "gap": "GAP", "note": "NOTE"}
const BUYS := [["hp", 1, "+1 HP"], ["pace", 1, "+0.1 Pace"], ["pace", 10, "+1 Pace"], ["stam", 1, "+1 Stamina"],
	["reach", 1, "+1 Reach"], ["ap", 1, "+1 AP"], ["tpr", 1, "+1 turn"]]

var _m := GrowthModel.new()
var _tamer: VBoxContainer
var _monsters: VBoxContainer
var _log: RichTextLabel
var _overlay: ColorRect
var _dialog: VBoxContainer
var _ladder := false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = UiTheme.create()
	var bg := ColorRect.new()
	bg.color = Color(0.075, 0.082, 0.094)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side: String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 16)
	add_child(margin)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	margin.add_child(col)

	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 12)
	col.add_child(head)
	var title := _label(head, "GROWTH PREVIEW", UiTheme.ACCENT, 28)
	title.autowrap_mode = TextServer.AUTOWRAP_OFF
	var hint := _label(head, "A test screen with draft values: click a step and see what it gives. Gold is a choice, white is given to everyone, red is a gap in the rules.", UiTheme.DIM)
	hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_button(head, "The whole ladder", func(): _ladder = true).autowrap_mode = TextServer.AUTOWRAP_OFF
	_button(head, "Start over", func(): _m = GrowthModel.new()).autowrap_mode = TextServer.AUTOWRAP_OFF
	_button(head, "Back", func(): get_tree().change_scene_to_file(MENU_SCENE)).autowrap_mode = TextServer.AUTOWRAP_OFF
	head.add_child(Control.new())
	head.get_child(-1).custom_minimum_size = Vector2(44, 0)      # room for the cheat button in the corner

	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 10)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(body)
	_tamer = _column(body)
	_monsters = _column(body)
	var log_panel := PanelContainer.new()
	log_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(log_panel)
	var log_col := VBoxContainer.new()
	log_panel.add_child(log_col)
	_label(log_col, "WHAT EACH CLICK GAVE", UiTheme.ACCENT)
	_log = RichTextLabel.new()
	_log.bbcode_enabled = true
	_log.scroll_following = true
	_log.size_flags_vertical = Control.SIZE_EXPAND_FILL
	log_col.add_child(_log)

	_overlay = ColorRect.new()
	_overlay.color = Color(0.03, 0.035, 0.04, 0.92)
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_overlay)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.add_child(center)
	var panel := PanelContainer.new()
	center.add_child(panel)
	_dialog = VBoxContainer.new()
	_dialog.add_theme_constant_override("separation", 8)
	panel.add_child(_dialog)
	_refresh()


func _column(parent: Control) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(panel)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel.add_child(scroll)
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 6)
	scroll.add_child(box)
	return box


func _label(parent: Control, text: String, color: Color = UiTheme.TEXT, size: int = 0) -> Label:
	var l := Label.new()
	l.text = text
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(60, 0)
	l.add_theme_color_override("font_color", color)
	if size > 0:
		l.add_theme_font_size_override("font_size", size)
	parent.add_child(l)
	return l


## A button; `block` says why it cannot be pressed and is shown on it.
func _button(parent: Control, text: String, action: Callable, block: String = "") -> Button:
	var b := Button.new()
	b.text = text if block == "" else "%s — %s" % [text, block]
	b.disabled = block != ""
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	b.custom_minimum_size = Vector2(60, 0)
	b.pressed.connect(func(): action.call(); _refresh())
	parent.add_child(b)
	return b


func _clear(box: Control) -> void:
	for c in box.get_children():
		box.remove_child(c)
		c.queue_free()


func _refresh() -> void:
	_fill_tamer()
	_fill_monsters()
	var text := ""
	for e: Dictionary in _m.entries:
		text += "[color=#%s][b]%s[/b]  %s[/color]\n" % [KIND_COLOR[e["kind"]], KIND_MARK[e["kind"]], e["text"]]
	_log.text = text
	_fill_dialog()


func _fill_tamer() -> void:
	_clear(_tamer)
	var m := _m
	_label(_tamer, "TAMER", UiTheme.ACCENT)
	_label(_tamer, GrowthModel.step_name(m.step), UiTheme.TEXT, 24)
	_label(_tamer, "Arc: %s" % GrowthModel.ARCS[m.stage()])
	_label(_tamer, "Tamer slots: %d (a tamer skill, a weapon or a pill each, once per battle)" % m.tamer_slots())
	_label(_tamer, "Visible weight: %d (a placeholder count)" % m.visible_weight())
	_button(_tamer, m.advance_text(), m.advance, "" if m.step < 17 else "done")
	_label(_tamer, "Insights, %d of 5: %s" % [m.insights.size(), ", ".join(m.insights) if not m.insights.is_empty() else "none yet"], UiTheme.DIM)
	var learned: Array[String] = []
	for n: String in m.skills:
		var opts: Array = m.skills[n]
		learned.append("%s level %d%s" % [n, opts.size() + 1, "" if opts.is_empty() else " (%s)" % ", ".join(opts)])
	_label(_tamer, "Tamer skills: %s" % "; ".join(learned), UiTheme.DIM)

	_tamer.add_child(HSeparator.new())
	_label(_tamer, "INTERNAL WORLD", UiTheme.ACCENT)
	_label(_tamer, "Stage %d. Grid %d×%d, holds %d monsters, %d own battlegrounds (placeholder numbers)." % [
		m.world + 1, GrowthModel.WORLD_GRID[m.world], GrowthModel.WORLD_GRID[m.world], GrowthModel.WORLD_HOLDS[m.world], GrowthModel.WORLD_GROUNDS[m.world]])
	_label(_tamer, "How many monsters fight: as many as the battleground allows and this world holds.", UiTheme.DIM)
	_button(_tamer, "Raise the Internal World (materials)", m.raise_world, m.world_block())

	_tamer.add_child(HSeparator.new())
	_label(_tamer, "LADDERS OF DEEDS", UiTheme.ACCENT)
	_label(_tamer, "No choice and no points: you climb by doing, and day AP limit how much.", UiTheme.DIM)
	_label(_tamer, "Alchemy rank: %s" % GrowthModel.CRAFT_RANKS[m.alchemy])
	_button(_tamer, "Pass the Alchemy Hall's trial", m.pass_trial.bind("alchemy"), "" if m.alchemy < 5 else "highest rank")
	_label(_tamer, "Smithing rank: %s" % GrowthModel.CRAFT_RANKS[m.smith])
	_button(_tamer, "Pass the Smiths' Hall's trial", m.pass_trial.bind("smith"), "" if m.smith < 5 else "highest rank")
	_label(_tamer, "House: %s" % ("none" if m.house == "" else "%s; wings: %s" % [m.house, ", ".join(m.wings) if not m.wings.is_empty() else "none"]))
	if m.house == "":
		_button(_tamer, "Found the house", m.found_house, m.house_block())
	else:
		_button(_tamer, "Add a wing", m.add_wing, "" if m.wings.size() < GrowthModel.WINGS.size() else "all wings stand")


func _fill_monsters() -> void:
	_clear(_monsters)
	var m := _m
	_label(_monsters, "MONSTERS  %d of %d" % [m.monsters.size(), GrowthModel.WORLD_HOLDS[m.world]], UiTheme.ACCENT)
	_button(_monsters, "Add a monster", m.catch_monster, m.catch_block())
	for i in m.monsters.size():
		var mon: Dictionary = m.monsters[i]
		_monsters.add_child(HSeparator.new())
		_label(_monsters, "%s · %s · %s" % [mon["name"], GrowthModel.RARITIES[mon["rarity"]], GrowthModel.step_name(mon["step"])], UiTheme.TEXT, 20)
		var total := GrowthModel.points_total(mon)
		var spent := GrowthModel.points_spent(mon)
		_label(_monsters, "HP %d · Pace %.1f · Stamina %d · Reach %d · AP %d · Turns %d" % [mon["hp"], int(mon["pace"]) / 10.0, mon["stam"], mon["reach"], mon["ap"], mon["tpr"]])
		_label(_monsters, "Stat points: %d free of %d" % [total - spent, total], UiTheme.ACCENT if total > spent else UiTheme.DIM)
		var flow := HFlowContainer.new()
		_monsters.add_child(flow)
		for b: Array in BUYS:
			var cost := GrowthModel.buy_cost(mon, b[0], b[1])
			var btn := _button(flow, "%s (%s)" % [b[2], str(cost) if cost >= 0 else "max"], m.buy.bind(i, b[0], b[1]))
			btn.autowrap_mode = TextServer.AUTOWRAP_OFF
			btn.disabled = cost < 0 or spent + cost > total
		var levels: Array[String] = []
		for s in 6:
			var opts: Array = mon["slots"][s]
			levels.append("%d: L%d%s" % [s + 1, opts.size() + 1, "" if opts.is_empty() else " (%s)" % ", ".join(opts)])
		_label(_monsters, "Skill slots  %s" % "  ".join(levels), UiTheme.DIM)
		if int(mon["learn"]) > 0:
			_label(_monsters, "Learnable list: +%d skills" % mon["learn"], UiTheme.DIM)
		_button(_monsters, "Develop a skill slot (%d steps)" % mon["dev"], m.develop.bind(i), "" if int(mon["dev"]) > 0 else "no step")
		_button(_monsters, "Advance to the next step", m.advance_monster.bind(i), m.monster_block(i))


func _fill_dialog() -> void:
	_clear(_dialog)
	_overlay.visible = _ladder or not _m.pending.is_empty()
	if not _m.pending.is_empty():
		var c: Dictionary = _m.pending[0]
		_label(_dialog, c["title"], UiTheme.ACCENT, 24).custom_minimum_size = Vector2(620, 0)
		_label(_dialog, c["text"], UiTheme.DIM)
		for i in (c["options"] as Array).size():
			var o: Dictionary = c["options"][i]
			_button(_dialog, o["label"], _m.choose.bind(i)).custom_minimum_size = Vector2(620, 44)
			_label(_dialog, o["text"], UiTheme.DIM)
		if _m.pending.size() > 1:
			_label(_dialog, "%d more choice(s) follow." % (_m.pending.size() - 1), UiTheme.DIM)
	elif _ladder:
		_label(_dialog, "THE WHOLE LADDER", UiTheme.ACCENT, 24)
		_label(_dialog, "What the tamer gets at the breakthrough into each stage (draft). Monsters, the Internal World and the ladders of deeds grow beside it.", UiTheme.DIM)
		var grid := GridContainer.new()
		grid.columns = 5
		grid.add_theme_constant_override("h_separation", 18)
		grid.add_theme_constant_override("v_separation", 8)
		_dialog.add_child(grid)
		var widths := [150, 190, 60, 330, 380]
		var heads := ["Stage", "Arc", "Slots", "The player chooses", "Opens besides"]
		for i in 5:
			_label(grid, heads[i], UiTheme.ACCENT).custom_minimum_size = Vector2(widths[i], 0)
		for row: Array in GrowthModel.ladder_rows():
			for i in 5:
				_label(grid, row[i]).custom_minimum_size = Vector2(widths[i], 0)
		_button(_dialog, "Close", func(): _ladder = false)
