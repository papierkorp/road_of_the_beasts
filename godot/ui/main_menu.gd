extends Control
## Start menu: start the battle, settings, quit.

const DRAFT_SCENE := "res://draft.tscn"

var _buttons: VBoxContainer
var _settings: SettingsPanel


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	theme = UiTheme.create()

	var bg := ColorRect.new()
	bg.color = Color(0.075, 0.082, 0.094)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 14)
	center.add_child(col)

	var title := Label.new()
	title.text = "ROAD OF THE BEASTS"
	title.add_theme_font_size_override("font_size", 52)
	title.add_theme_color_override("font_color", UiTheme.ACCENT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(title)
	var sub := Label.new()
	sub.text = "Battle prototype"
	sub.add_theme_color_override("font_color", UiTheme.DIM)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(sub)
	col.add_child(Control.new())

	_buttons = VBoxContainer.new()
	_buttons.add_theme_constant_override("separation", 10)
	col.add_child(_buttons)
	_add_button("Start Battle", func(): get_tree().change_scene_to_file(DRAFT_SCENE))
	_add_button("Settings", _show_settings)
	_add_button("Quit", func(): get_tree().quit())

	_settings = SettingsPanel.new(true)
	_settings.visible = false
	_settings.back_pressed.connect(_show_buttons)
	col.add_child(_settings)


func _add_button(text: String, action: Callable) -> void:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(280, 48)
	b.pressed.connect(action)
	_buttons.add_child(b)


func _show_settings() -> void:
	_buttons.visible = false
	_settings.visible = true


func _show_buttons() -> void:
	_settings.visible = false
	_buttons.visible = true
