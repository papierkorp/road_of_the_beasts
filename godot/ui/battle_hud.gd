class_name BattleHud
extends CanvasLayer
## Minimal flat HUD: round/turn order (top-left), hint (top), skill bar (bottom),
## fading log (bottom-left), square inspector (only while hovering a square),
## cast preview that follows the cursor, end banner and pause menu.
## Emits signals only; it knows no rules.

signal action_pressed(id: StringName)
signal end_turn_pressed
signal restart_pressed
signal resume_pressed
signal menu_pressed

const LOG_LINES := 6

var _buttons := {}                 # id -> Button
var _button_row: HBoxContainer
var _action_ids: Array = []
var _portrait: Label
var _order: Label
var _hint: Label
var _ap: Label
var _end_button: Button
var _inspector_panel: PanelContainer
var _inspector: Label
var _preview_panel: PanelContainer
var _preview: Label
var _log_box: VBoxContainer
var _banner: Control
var _banner_text: Label
var _pause: Control


func build() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS     # pause menu must work while the tree is paused
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
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
	_log_box.offset_top = -280
	_log_box.offset_bottom = -116
	_log_box.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_log_box.alignment = BoxContainer.ALIGNMENT_END
	_ignore(_log_box)
	root.add_child(_log_box)


func _build_bar(root: Control) -> void:
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	center.offset_top = -104
	center.offset_bottom = -16
	_ignore(center)
	root.add_child(center)
	var panel := PanelContainer.new()
	center.add_child(panel)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	panel.add_child(row)
	_ap = Label.new()
	_ap.custom_minimum_size = Vector2(80, 0)
	_ap.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_ap.add_theme_color_override("font_color", UiTheme.ACCENT)
	row.add_child(_ap)
	_button_row = HBoxContainer.new()
	_button_row.add_theme_constant_override("separation", 8)
	row.add_child(_button_row)
	_end_button = Button.new()
	_end_button.text = "End Turn"
	_end_button.custom_minimum_size = Vector2(110, 56)
	_end_button.pressed.connect(func(): end_turn_pressed.emit())
	row.add_child(_end_button)


## Rebuilds the action buttons when the set of actions changes (a new monster's turn).
func _sync_buttons(actions: Array) -> void:
	var ids: Array = actions.map(func(a): return a["id"])
	if ids == _action_ids:
		return
	_action_ids = ids
	for c in _button_row.get_children():
		c.queue_free()
	_buttons.clear()
	for a in actions:
		var b := Button.new()
		b.custom_minimum_size = Vector2(118, 56)
		var id: StringName = a["id"]
		b.pressed.connect(func(): action_pressed.emit(id))
		_button_row.add_child(b)
		_buttons[id] = b


func _build_inspector(root: Control) -> void:
	_inspector_panel = PanelContainer.new()
	_inspector_panel.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	_inspector_panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_inspector_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	_inspector_panel.offset_right = -20
	_inspector_panel.offset_left = -340
	_inspector_panel.visible = false
	_ignore(_inspector_panel)
	root.add_child(_inspector_panel)
	_inspector = Label.new()
	_inspector.custom_minimum_size = Vector2(290, 0)
	_inspector.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_inspector.add_theme_font_size_override("font_size", 15)
	_ignore(_inspector)
	_inspector_panel.add_child(_inspector)


func _build_preview(root: Control) -> void:
	_preview_panel = PanelContainer.new()
	_preview_panel.visible = false
	_ignore(_preview_panel)
	root.add_child(_preview_panel)
	_preview = Label.new()
	_preview.custom_minimum_size = Vector2(240, 0)
	_preview.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_preview.add_theme_font_size_override("font_size", 15)
	_preview.add_theme_color_override("font_color", UiTheme.ACCENT)
	_ignore(_preview)
	_preview_panel.add_child(_preview)


func _build_banner(root: Control) -> void:
	var dim := ColorRect.new()
	dim.color = Color(0.05, 0.055, 0.065, 0.8)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.visible = false
	root.add_child(dim)
	_banner = dim
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.add_child(center)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 14)
	center.add_child(col)
	_banner_text = Label.new()
	_banner_text.add_theme_font_size_override("font_size", 56)
	_banner_text.add_theme_color_override("font_color", UiTheme.ACCENT)
	_banner_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(_banner_text)
	col.add_child(_menu_button("Fight Again", func(): restart_pressed.emit()))
	col.add_child(_menu_button("Main Menu", func(): menu_pressed.emit()))


func _build_pause(root: Control) -> void:
	var dim := ColorRect.new()
	dim.color = Color(0.05, 0.055, 0.065, 0.75)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.visible = false
	root.add_child(dim)
	_pause = dim
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.add_child(center)
	var panel := PanelContainer.new()
	center.add_child(panel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 14)
	panel.add_child(col)
	var title := Label.new()
	title.text = "PAUSED"
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", UiTheme.ACCENT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(title)
	col.add_child(_menu_button("Resume", func(): resume_pressed.emit()))
	col.add_child(SettingsPanel.new(false))
	col.add_child(_menu_button("Main Menu", func(): menu_pressed.emit()))


func _menu_button(text: String, action: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(260, 46)
	b.pressed.connect(action)
	return b


func show_pause(on: bool) -> void:
	_pause.visible = on


## One call per refresh. `actions`: [{id, text, enabled, selected, tooltip}].
## An empty `inspector` or `preview` hides that panel.
func update(order_text: String, portrait: String, ap_text: String, hint: String, preview: String,
		inspector: String, actions: Array, can_end: bool, banner: String) -> void:
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
		b.tooltip_text = a.get("tooltip", "")
		b.modulate = UiTheme.ACCENT if a.get("selected", false) else Color.WHITE
	_banner.visible = banner != ""
	_banner_text.text = banner

	_inspector_panel.visible = inspector != ""
	_inspector.text = inspector
	_preview_panel.visible = preview != ""
	_preview.text = preview
	if preview != "":
		var vp := get_viewport().get_visible_rect().size
		var pos := get_viewport().get_mouse_position() + Vector2(24, 24)
		pos.x = minf(pos.x, vp.x - _preview_panel.size.x - 8.0)
		pos.y = minf(pos.y, vp.y - _preview_panel.size.y - 120.0)
		_preview_panel.position = pos


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
