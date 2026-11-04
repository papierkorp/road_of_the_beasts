extends Control
## Start menu: start the battle, settings, quit.

const DRAFT_SCENE := "res://battle/draft.tscn"
const OVERWORLD_SCENE := "res://overworld/district.tscn"

var _buttons: VBoxContainer
var _settings: SettingsPanel


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = UiTheme.create()

	var bg := ColorRect.new()
	bg.color = Color(0.075, 0.082, 0.094)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
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
	sub.text = "Phase 1 prototype"
	sub.add_theme_color_override("font_color", UiTheme.DIM)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(sub)
	col.add_child(Control.new())

	_buttons = VBoxContainer.new()
	_buttons.add_theme_constant_override("separation", 10)
	col.add_child(_buttons)
	_add_button("New Game", _new_game)
	var cont := _add_button("Continue", _continue_game)
	cont.disabled = not SaveGame.exists()
	_add_button("Battle Prototype", func(): get_tree().change_scene_to_file(DRAFT_SCENE))
	_add_button("Settings", _show_settings)
	_add_button("Quit", func(): get_tree().quit())

	_settings = SettingsPanel.new(true)
	_settings.visible = false
	_settings.back_pressed.connect(_show_buttons)
	col.add_child(_settings)


func _add_button(text: String, action: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(280, 48)
	b.pressed.connect(action)
	_buttons.add_child(b)
	return b


func _new_game() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	GameSession.game = GameState.new_game(rng)
	GameSession.expedition = null
	GameSession.district = &"plaza"
	GameSession.arrive_from = &"start"
	SaveGame.save(GameSession.game)
	get_tree().change_scene_to_file(OVERWORLD_SCENE)


func _continue_game() -> void:
	var g := SaveGame.load_game()
	if g == null:
		return
	GameSession.game = g
	GameSession.expedition = null
	GameSession.district = &"plaza"
	GameSession.arrive_from = &"start"
	get_tree().change_scene_to_file(OVERWORLD_SCENE)


func _show_settings() -> void:
	_buttons.visible = false
	_settings.visible = true


func _show_buttons() -> void:
	_settings.visible = false
	_buttons.visible = true
