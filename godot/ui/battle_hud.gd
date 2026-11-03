class_name BattleHud
extends CanvasLayer
## Battle HUD built in code: turn order, AP, skill bar, hint, cast preview,
## square inspector, log and the end banner. Emits signals only; no rules.

signal skill_pressed(id: StringName)
signal end_turn_pressed
signal restart_pressed

const MOVE_ID := &"__move"

var _buttons := {}                 # id -> Button
var _order: Label
var _ap: Label
var _hint: Label
var _preview: Label
var _inspector: Label
var _log: Label
var _banner: Control
var _banner_text: Label
var _end_button: Button
var _lines: Array[String] = []


func build(skills: Array[SkillDef]) -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	_order = _label(root, Vector2(16, 10))
	_hint = _label(root, Vector2(16, 40))
	_preview = _label(root, Vector2(16, 70))
	_preview.add_theme_color_override("font_color", Color(0.9, 0.78, 0.45))

	var side := PanelContainer.new()
	side.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
	side.offset_left = -300
	side.offset_right = 0
	side.offset_top = 10
	side.offset_bottom = -100
	root.add_child(side)
	_inspector = Label.new()
	_inspector.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	side.add_child(_inspector)

	_log = _label(root, Vector2(16, 0))
	_log.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_log.offset_left = 16
	_log.offset_top = -330
	_log.offset_bottom = -100
	_log.add_theme_color_override("font_color", Color(0.65, 0.63, 0.58))

	var bar := PanelContainer.new()
	bar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bar.offset_top = -84
	root.add_child(bar)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	bar.add_child(row)
	_ap = Label.new()
	_ap.custom_minimum_size = Vector2(90, 0)
	row.add_child(_ap)
	_add_button(row, MOVE_ID, "Move\n1 AP")
	for s in skills:
		_add_button(row, s.id, s.display_name)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)
	_end_button = Button.new()
	_end_button.text = "End Turn"
	_end_button.pressed.connect(func(): end_turn_pressed.emit())
	row.add_child(_end_button)

	_banner = ColorRect.new()
	(_banner as ColorRect).color = Color(0.07, 0.08, 0.09, 0.85)
	_banner.set_anchors_preset(Control.PRESET_FULL_RECT)
	_banner.visible = false
	root.add_child(_banner)
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	_banner.add_child(box)
	_banner_text = Label.new()
	_banner_text.add_theme_font_size_override("font_size", 48)
	box.add_child(_banner_text)
	var again := Button.new()
	again.text = "Fight Again"
	again.pressed.connect(func(): restart_pressed.emit())
	box.add_child(again)


func _label(parent: Control, pos: Vector2) -> Label:
	var l := Label.new()
	l.position = pos
	parent.add_child(l)
	return l


func _add_button(parent: Control, id: StringName, text: String) -> void:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(104, 60)
	b.pressed.connect(func(): skill_pressed.emit(id))
	parent.add_child(b)
	_buttons[id] = b


## One call per refresh. `skill_states`: id -> {enabled, selected, text}.
func update(order_text: String, ap_text: String, hint: String, preview: String,
		inspector: String, skill_states: Dictionary, can_end: bool, banner: String) -> void:
	_order.text = order_text
	_ap.text = ap_text
	_hint.text = hint
	_preview.text = preview
	_inspector.text = inspector
	_end_button.disabled = not can_end
	for id in _buttons:
		var st: Dictionary = skill_states.get(id, {})
		var b: Button = _buttons[id]
		b.disabled = not st.get("enabled", false)
		b.text = st.get("text", b.text)
		b.modulate = Color(1, 0.85, 0.5) if st.get("selected", false) else Color.WHITE
	_banner.visible = banner != ""
	_banner_text.text = banner


func log_line(text: String) -> void:
	_lines.push_front("› " + text)
	if _lines.size() > 12:
		_lines.pop_back()
	var out := ""
	for l in _lines:
		out = l + "\n" + out
	_log.text = out.strip_edges()
