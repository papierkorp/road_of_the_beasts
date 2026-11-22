class_name BattleHud
extends CanvasLayer
## Minimal flat HUD: round/turn order (top-left), hint (top), action bar with the tamer panel beside it (bottom),
## fading log (bottom-left), square inspector (only while hovering a square),
## cast preview that follows the cursor, end banner and pause menu.
## Emits signals only; it knows no rules.

signal action_pressed(id: StringName)
signal end_turn_pressed
signal wait_pressed
signal heal_pressed
signal restart_pressed
signal resume_pressed
signal menu_pressed

const LOG_LINES := 8
## Action bar (user layout 2026-11-15): Step stands over both rows, then a small gap, then the kit in columns of
## two buttons; the side's tamer skills have a panel of their own beside the monster's bar.
const BAR_BUTTON := Vector2(118, 66)       # 66: what a button with its two text lines needs
const BAR_GAP := 8
const SKILL_ROWS := 2
const SKILL_COLUMNS := 3           # six kit slots (gdd_skills §1); a larger kit adds columns
## Height at the bottom edge that belongs to the bar: log, cards, inspector and cast preview stay above it.
const BAR_ROOM := 196.0

var _buttons := {}                 # id -> Button
var _step_box: BoxContainer
var _skill_grid: GridContainer
var _tamer_panel: PanelContainer
var _tamer_grid: GridContainer
var _action_ids: Array = []
var _portrait: Label
var _order: Label
var _hint: Label
var _ap: Label
var _end_button: Button
var _wait_button: Button
var _heal_button: Button
var _glossary: AcceptDialog
var _inspector_panel: PanelContainer
var _inspector_title: Label
var _inspector_grid: GridContainer
var _inspector: Label
var _card_panel: PanelContainer
var _card_title: Label
var _card_note: Label
var _card_grid: GridContainer
var _cards := {}                   # action id -> {title, rows}
var _hover_id: StringName = &""
var _preview_panel: PanelContainer
var _preview: Label
var _log_box: VBoxContainer
var _fallen_box: HFlowContainer
var _banner: Control
var _banner_text: Label
var _banner_restart: Button
var _banner_menu: Button
var _pause: Control


func build() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS     # pause menu must work while the tree is paused
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.theme = UiTheme.create()
	add_child(root)

	_order = Label.new()
	_order.position = Vector2(24, 16)
	root.add_child(_order)

	_hint = Label.new()
	_hint.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_hint.offset_left = -480
	_hint.offset_right = 480
	_hint.offset_top = 16
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.add_theme_color_override("font_color", UiTheme.DIM)
	_hint.add_theme_font_size_override("font_size", 15)
	root.add_child(_hint)

	_portrait = Label.new()
	_portrait.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_portrait.offset_left = -360
	_portrait.offset_right = -24
	_portrait.offset_top = 16
	_portrait.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_portrait.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_portrait.add_theme_font_size_override("font_size", 15)
	root.add_child(_portrait)

	_build_log(root)
	_build_bar(root)
	_build_inspector(root)
	_build_preview(root)
	_build_banner(root)
	_build_pause(root)


func _ignore(c: Control) -> void:
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _build_log(root: Control) -> void:
	_log_box = VBoxContainer.new()
	_log_box.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_log_box.offset_left = 24
	_log_box.offset_right = 520
	_log_box.offset_top = -(BAR_ROOM + 200.0)
	_log_box.offset_bottom = -BAR_ROOM
	_log_box.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_log_box.alignment = BoxContainer.ALIGNMENT_END
	_ignore(_log_box)
	root.add_child(_log_box)
	_fallen_box = HFlowContainer.new()            # fallen monsters, each a button to its HP history
	_fallen_box.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_fallen_box.offset_left = 24
	_fallen_box.offset_right = 520
	_fallen_box.offset_top = -(BAR_ROOM + 244.0)
	_fallen_box.offset_bottom = -(BAR_ROOM + 208.0)
	_fallen_box.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_fallen_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_fallen_box)


## The monster's bar (AP · Step · kit · End Turn) and, apart from it, the panel of the side's tamer skills.
func _build_bar(root: Control) -> void:
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	center.offset_top = -(BAR_ROOM - 12.0)
	center.offset_bottom = -16
	center.grow_vertical = Control.GROW_DIRECTION_BEGIN     # a taller bar grows upward, never below the screen edge
	_ignore(center)
	root.add_child(center)
	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation", 24)
	_ignore(bar)
	center.add_child(bar)
	var panel := PanelContainer.new()
	bar.add_child(panel)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", BAR_GAP)
	panel.add_child(row)
	_ap = Label.new()
	_ap.custom_minimum_size = Vector2(80, 0)
	_ap.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_ap.add_theme_color_override("font_color", UiTheme.ACCENT)
	row.add_child(_ap)
	_step_box = VBoxContainer.new()               # Step over the Basic Jab (user layout to try, 2026-11-17)
	_step_box.add_theme_constant_override("separation", BAR_GAP)
	row.add_child(_step_box)
	row.add_child(_bar_gap())
	_skill_grid = _bar_grid()
	row.add_child(_skill_grid)
	row.add_child(_bar_gap())
	var side_box := VBoxContainer.new()           # Wait over Heal, End Turn to their right over both rows (user layout, 2026-11-18)
	side_box.add_theme_constant_override("separation", BAR_GAP)
	row.add_child(side_box)
	_wait_button = Button.new()                   # postpone this turn to the end of the round
	_wait_button.text = "Wait"
	_wait_button.tooltip_text = "Postpone this turn to the end of the round (once a round, before doing anything). Monsters that waited act in reverse order."
	_wait_button.custom_minimum_size = Vector2(110, BAR_BUTTON.y)
	_wait_button.visible = false
	_wait_button.pressed.connect(func(): wait_pressed.emit())
	side_box.add_child(_wait_button)
	_heal_button = Button.new()                   # Heal: Stamina for HP
	_heal_button.text = "Heal"
	_heal_button.custom_minimum_size = Vector2(110, BAR_BUTTON.y)
	_heal_button.visible = false
	_heal_button.pressed.connect(func(): heal_pressed.emit())
	side_box.add_child(_heal_button)
	_end_button = Button.new()
	_end_button.text = "End Turn"
	_end_button.custom_minimum_size = Vector2(110, BAR_BUTTON.y * 2 + BAR_GAP)
	_end_button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_end_button.pressed.connect(func(): end_turn_pressed.emit())
	row.add_child(_end_button)
	_tamer_panel = PanelContainer.new()
	_tamer_panel.visible = false
	bar.add_child(_tamer_panel)
	_tamer_grid = _bar_grid()
	_tamer_grid.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_tamer_panel.add_child(_tamer_grid)


## A button over all rows of the bar (Step, End Turn).
func _tall() -> Vector2:
	return Vector2(BAR_BUTTON.x, BAR_BUTTON.y * SKILL_ROWS + BAR_GAP * (SKILL_ROWS - 1))


## The small gap that sets Step and End Turn apart from the kit.
func _bar_gap() -> Control:
	var gap := Control.new()
	gap.custom_minimum_size = Vector2(6, 0)
	_ignore(gap)
	return gap


func _bar_grid() -> GridContainer:
	var grid := GridContainer.new()
	grid.add_theme_constant_override("h_separation", BAR_GAP)
	grid.add_theme_constant_override("v_separation", BAR_GAP)
	return grid


## Rebuilds the action buttons when the set of actions changes (a new monster's turn). Every action names its
## group: "step" (one button over both rows), "tamer" (the panel of its own) or "skill" (the kit; the default).
func _sync_buttons(actions: Array) -> void:
	var ids: Array = actions.map(func(a): return a["id"])
	if ids == _action_ids:
		return
	_action_ids = ids
	for box: Control in [_step_box, _skill_grid, _tamer_grid]:
		for c in box.get_children():
			box.remove_child(c)
			c.queue_free()
	_buttons.clear()
	var steps: Array = []
	var skills: Array = []
	var tamer: Array = []
	for a in actions:
		match StringName(a.get("group", &"skill")):
			&"step":
				steps.append(a)
			&"tamer":
				tamer.append(a)
			_:
				skills.append(a)
	for a in steps:
		_step_box.add_child(_action_button(a["id"], _tall() if steps.size() == 1 else BAR_BUTTON))
	_step_box.visible = not steps.is_empty()
	_fill_columns(_skill_grid, skills, SKILL_COLUMNS)
	_fill_columns(_tamer_grid, tamer, 1)
	_tamer_panel.visible = not tamer.is_empty()


## Lays `list` into `grid` in columns of SKILL_ROWS: the first column from top to bottom, then the next. A
## GridContainer fills row by row, so the cells are added in that order; an empty cell keeps the block's shape.
func _fill_columns(grid: GridContainer, list: Array, min_columns: int) -> void:
	grid.visible = not list.is_empty()
	if list.is_empty():
		return
	var columns := maxi(min_columns, ceili(float(list.size()) / SKILL_ROWS))
	grid.columns = columns
	for r in SKILL_ROWS:
		for c in columns:
			var i := c * SKILL_ROWS + r
			if i < list.size():
				grid.add_child(_action_button(list[i]["id"], BAR_BUTTON))
			else:
				var empty := Control.new()
				empty.custom_minimum_size = BAR_BUTTON
				_ignore(empty)
				grid.add_child(empty)


## Gives every cell of a block the width of its widest button, so the columns line up whatever the names are.
func _even_widths(grid: GridContainer) -> void:
	var widest := BAR_BUTTON.x
	for c in grid.get_children():
		if c is Button:
			widest = maxf(widest, (c as Button).get_minimum_size().x)
	for c in grid.get_children():
		(c as Control).custom_minimum_size.x = widest


## A coloured stripe on the left edge and under the button says what kind of skill it is (BattleText.KINDS).
func _kind_stripe(b: Button, color: Variant) -> void:
	if color == null or b.has_meta("kind_color") and b.get_meta("kind_color") == color:
		return
	b.set_meta("kind_color", color)
	for kind: String in BattleText.KINDS:             # the sign of the kind beside the name (assets/icons)
		if BattleText.KINDS[kind][1] == color:
			b.icon = UiTheme.icon("kind_" + kind)
			b.add_theme_constant_override("icon_max_width", 30)
			for state in ["icon_normal_color", "icon_hover_color", "icon_focus_color"]:
				b.add_theme_color_override(state, color)
	for state in ["normal", "hover", "pressed", "disabled"]:
		var sb := b.get_theme_stylebox(state)
		if not (sb is StyleBoxFlat):
			continue
		var own: StyleBoxFlat = sb.duplicate()
		var c: Color = color
		if state == "disabled":
			c = c.darkened(0.45)
		own.border_color = c
		own.border_width_left = 6
		own.border_width_bottom = 2
		b.add_theme_stylebox_override(state, own)


func _action_button(id: StringName, min_size: Vector2) -> Button:
	var b := Button.new()
	b.custom_minimum_size = min_size
	b.pressed.connect(func(): action_pressed.emit(id))
	b.mouse_entered.connect(func(): _hover_id = id; _show_card())
	b.mouse_exited.connect(func():
		if _hover_id == id:
			_hover_id = &""
			_show_card())
	_buttons[id] = b
	return b


func _build_inspector(root: Control) -> void:
	_inspector_panel = PanelContainer.new()
	_inspector_panel.visible = false
	_ignore(_inspector_panel)
	root.add_child(_inspector_panel)
	var box := VBoxContainer.new()
	_ignore(box)
	_inspector_panel.add_child(box)
	_inspector_title = _card_label(box, 17, UiTheme.ACCENT)
	_inspector_grid = _make_grid(box)
	_inspector = Label.new()
	_inspector.custom_minimum_size = Vector2(260, 0)
	_inspector.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_inspector.add_theme_font_size_override("font_size", 14)
	_inspector.add_theme_color_override("font_color", UiTheme.DIM)
	_ignore(_inspector)
	box.add_child(_inspector)

	# skill card above the action bar
	_card_panel = PanelContainer.new()
	_card_panel.visible = false
	_ignore(_card_panel)
	root.add_child(_card_panel)
	var cbox := VBoxContainer.new()
	_ignore(cbox)
	_card_panel.add_child(cbox)
	_card_title = _card_label(cbox, 18, UiTheme.ACCENT)
	_card_note = _card_label(cbox, 14, Color(1.0, 0.42, 0.38))      # why the skill cannot be used now: over the whole width
	_card_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_card_note.custom_minimum_size = Vector2(300, 0)
	_card_note.visible = false
	_card_grid = _make_grid(cbox)


func _card_label(parent: Control, size_px: int, color: Color) -> Label:
	var l := Label.new()
	l.add_theme_font_size_override("font_size", size_px)
	l.add_theme_color_override("font_color", color)
	_ignore(l)
	parent.add_child(l)
	return l


func _make_grid(parent: Control) -> GridContainer:
	var g := GridContainer.new()
	g.columns = 2
	g.add_theme_constant_override("h_separation", 14)
	g.add_theme_constant_override("v_separation", 3)
	_ignore(g)
	parent.add_child(g)
	return g


## Renders [[label, value], ...] as a two-column table.
func _fill_grid(g: GridContainer, rows: Array, value_width: float = 270.0) -> void:
	for c in g.get_children():
		g.remove_child(c)
		c.queue_free()
	for r in rows:
		var k := Label.new()
		k.text = r[0]
		k.add_theme_font_size_override("font_size", 14)
		k.add_theme_color_override("font_color", UiTheme.DIM)
		k.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		_ignore(k)
		g.add_child(k)
		var v := Label.new()
		v.text = r[1]
		v.add_theme_font_size_override("font_size", 14)
		v.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		v.custom_minimum_size = Vector2(value_width, 0)
		_ignore(v)
		g.add_child(v)


func _show_card() -> void:
	var card: Dictionary = _cards.get(_hover_id, {})
	_card_panel.visible = not card.is_empty()
	if card.is_empty():
		return
	_card_title.text = card["title"]
	var note := String(card.get("note", ""))
	_card_note.text = "✗ " + note
	_card_note.visible = note != ""
	_fill_grid(_card_grid, card["rows"])
	_place_card.call_deferred()


## Right edge, below the monster panel, always fully on screen.
func _place_inspector() -> void:
	_inspector_panel.reset_size()
	var vp := get_viewport().get_visible_rect().size
	var sz := _inspector_panel.get_combined_minimum_size()
	_inspector_panel.size = sz
	var top := _portrait.position.y + _portrait.size.y + 12.0
	var y := clampf((vp.y - sz.y) / 2.0, top, maxf(top, vp.y - BAR_ROOM - sz.y))
	_inspector_panel.position = Vector2(vp.x - sz.x - 20.0, y)


## Keep the whole card on screen, centred above the action bar.
func _place_card() -> void:
	_card_panel.reset_size()
	var vp := get_viewport().get_visible_rect().size
	var sz := _card_panel.get_combined_minimum_size()
	_card_panel.size = sz
	_card_panel.position = Vector2(roundf((vp.x - sz.x) / 2.0), maxf(8.0, vp.y - BAR_ROOM - sz.y))


func _build_preview(root: Control) -> void:
	_preview_panel = PanelContainer.new()
	_preview_panel.visible = false
	_ignore(_preview_panel)
	root.add_child(_preview_panel)
	_preview = Label.new()
	_preview.custom_minimum_size = Vector2(260, 0)
	_preview.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_preview.add_theme_font_size_override("font_size", 15)
	_preview.add_theme_color_override("font_color", UiTheme.ACCENT)
	_ignore(_preview)
	_preview_panel.add_child(_preview)


func _build_banner(root: Control) -> void:
	var dim := ColorRect.new()
	dim.color = Color(UiTheme.PAPER, 0.88)            # a veil of paper over the board
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.visible = false
	root.add_child(dim)
	_banner = dim
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.add_child(center)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 14)
	center.add_child(col)
	_banner_text = Label.new()
	_banner_text.add_theme_font_size_override("font_size", 72)
	_banner_text.add_theme_color_override("font_color", UiTheme.INK)
	if UiTheme.title_font() != null:
		_banner_text.add_theme_font_override("font", UiTheme.title_font())
	_banner_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(_banner_text)
	_banner_restart = _menu_button("Fight Again", func(): restart_pressed.emit())
	col.add_child(_banner_restart)
	_banner_menu = _menu_button("Main Menu", func(): menu_pressed.emit())
	col.add_child(_banner_menu)


func _build_pause(root: Control) -> void:
	var dim := ColorRect.new()
	dim.color = Color(UiTheme.PAPER, 0.8)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.visible = false
	root.add_child(dim)
	_pause = dim
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.add_child(center)
	var panel := PanelContainer.new()
	center.add_child(panel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 14)
	panel.add_child(col)
	var title := Label.new()
	title.text = "Paused"
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", UiTheme.INK)
	if UiTheme.title_font() != null:
		title.add_theme_font_override("font", UiTheme.title_font())
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(title)
	col.add_child(_menu_button("Resume", func(): resume_pressed.emit()))
	col.add_child(SettingsPanel.new(false))
	col.add_child(_menu_button("Rules of this battle", _show_rules))
	col.add_child(_menu_button("Glossary (%s)" % UiTheme.key_text(&"battle_glossary"), show_glossary))
	col.add_child(_menu_button("Main Menu", func(): menu_pressed.emit()))


func _menu_button(text: String, action: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(260, 46)
	b.pressed.connect(action)
	return b


## When the battle was started from the overworld the end banner continues there instead.
func set_exit_mode(from_overworld: bool) -> void:
	_banner_restart.visible = not from_overworld
	_banner_menu.text = "Continue" if from_overworld else "Main Menu"


## The Heal button: enabled when the acting monster can heal.
func set_heal(shown: bool, enabled: bool, why: String = "") -> void:
	_heal_button.visible = shown
	_heal_button.disabled = not enabled
	_heal_button.text = "Heal [%s]" % UiTheme.key_text(&"battle_heal")
	_heal_button.tooltip_text = why


func show_pause(on: bool) -> void:
	_pause.visible = on


## The Wait button (test switch `delay_turn`): shown while the switch is on, enabled when the turn can be postponed.
## `left` >= 0 (test switch `wait_by_pace`): the Waits the acting monster has left in this battle.
func set_wait(shown: bool, enabled: bool, left: int = -1, why: String = "") -> void:
	_wait_button.visible = shown
	_wait_button.disabled = not enabled
	_wait_button.text = "Wait" if left < 0 else "Wait (%d)" % left
	_wait_button.tooltip_text = why


## One call per refresh. `actions`: [{id, text, enabled, selected, tooltip, group}] (group: step | skill | tamer).
## An empty `inspector` or `preview` hides that panel.
## `inspector`: {title, rows, text} — empty dictionary hides it.
## Each action may carry "card": {title, rows} shown while the mouse is over its button.
func update(order_text: String, portrait: String, ap_text: String, hint: String, preview: String,
		inspector: Dictionary, actions: Array, can_end: bool, banner: String) -> void:
	_order.text = order_text
	_portrait.text = portrait
	_ap.text = ap_text
	_hint.text = hint
	_end_button.disabled = not can_end
	_sync_buttons(actions)
	for a in actions:
		var b: Button = _buttons.get(a["id"])
		if b == null:
			continue
		b.disabled = not a.get("enabled", false)
		b.text = a.get("text", "")
		_kind_stripe(b, a.get("color", null))
		b.tooltip_text = a.get("tooltip", "")
		b.modulate = Color(1.0, 0.84, 0.55) if a.get("selected", false) else Color.WHITE      # the chosen action: a wash of ochre
		if a.has("card"):
			_cards[a["id"]] = a["card"]
	_even_widths(_skill_grid)
	_even_widths(_tamer_grid)
	_banner.visible = banner != ""
	_banner_text.text = banner

	if _hover_id != &"":
		_show_card()
	_inspector_panel.visible = not inspector.is_empty()
	if not inspector.is_empty():
		_inspector_title.text = inspector.get("title", "")
		_fill_grid(_inspector_grid, inspector.get("rows", []), 270.0)
		_inspector.text = inspector.get("text", "")
		_inspector.visible = _inspector.text != ""
		_place_inspector.call_deferred()
	_preview_panel.visible = preview != ""
	_preview.text = preview
	if preview != "":
		var vp := get_viewport().get_visible_rect().size
		var pos := get_viewport().get_mouse_position() + Vector2(24, 24)
		pos.x = minf(pos.x, vp.x - _preview_panel.size.x - 8.0)
		pos.y = minf(pos.y, vp.y - _preview_panel.size.y - BAR_ROOM - 4.0)
		_preview_panel.position = pos


## The test switches of this battle and the build defaults (BattleExperiment.settings_lines), as a window
## whose text can be selected and copied.
func _show_rules() -> void:
	var dialog := AcceptDialog.new()
	dialog.title = "Rules of this battle: test switches and build defaults"
	dialog.process_mode = Node.PROCESS_MODE_ALWAYS
	var text := TextEdit.new()
	text.editable = false
	text.text = "\n".join(BattleExperiment.settings_lines())
	text.custom_minimum_size = Vector2(620, 520)
	dialog.add_child(text)
	add_child(dialog)
	dialog.confirmed.connect(dialog.queue_free)
	dialog.canceled.connect(dialog.queue_free)
	dialog.popup_centered()


## Every term of the cards and the inspector, explained once (BattleText.GLOSSARY). Pause menu and key G.
func show_glossary() -> void:
	if _glossary != null and is_instance_valid(_glossary):
		_glossary.queue_free()
		_glossary = null
		return
	var dialog := AcceptDialog.new()
	dialog.title = "Glossary: what the words on cards and squares mean"
	dialog.process_mode = Node.PROCESS_MODE_ALWAYS
	var text := TextEdit.new()
	text.editable = false
	text.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	text.text = BattleText.glossary_text()
	text.custom_minimum_size = Vector2(760, 600)
	dialog.add_child(text)
	add_child(dialog)
	_glossary = dialog
	dialog.confirmed.connect(dialog.queue_free)
	dialog.canceled.connect(dialog.queue_free)
	dialog.popup_centered()


## Adds a fallen monster to the row above the log: a button that opens everything that changed its HP.
func add_fallen(title: String, lines: PackedStringArray) -> void:
	var button := Button.new()
	button.text = "✝ " + title
	button.tooltip_text = "Why did %s fall? Click for everything that changed its HP." % title
	button.add_theme_font_size_override("font_size", 13)
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(func() -> void:
		var dialog := AcceptDialog.new()
		dialog.title = "%s: what happened" % title
		dialog.dialog_text = "\n".join(lines)
		dialog.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(dialog)
		dialog.confirmed.connect(dialog.queue_free)
		dialog.canceled.connect(dialog.queue_free)
		dialog.popup_centered())
	_fallen_box.add_child(button)


func log_line(text: String) -> void:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 15)
	l.add_theme_color_override("font_color", UiTheme.DIM)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_log_box.add_child(l)
	while _log_box.get_child_count() > LOG_LINES:
		var old := _log_box.get_child(0)
		_log_box.remove_child(old)
		old.queue_free()
	# older lines fade out
	var n := _log_box.get_child_count()
	for i in n:
		(_log_box.get_child(i) as Control).modulate.a = 0.25 + 0.75 * float(i + 1) / float(n)
