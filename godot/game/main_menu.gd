extends Control
## Start menu: a new game or the saved one (the hub game), the battle menu (ingame prototype and multiplayer battle), overview (debug tables of skills and monsters), settings, quit.

const BATTLE_MENU_SCENE := "res://battle/battle_menu.tscn"
const NEW_GAME_SCENE := "res://overworld/new_game.tscn"
const HUB_SCENE := "res://overworld/hub.tscn"
const OVERVIEW_SCENE := "res://game/overview.tscn"

var _buttons: VBoxContainer
var _settings: SettingsPanel


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = UiTheme.create()

	var bg := ColorRect.new()
	bg.color = UiTheme.BG
	bg.material = UiTheme.paper_material()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 14)
	center.add_child(col)

	# the name in the title font, signed with a cinnabar seal
	var head := HBoxContainer.new()
	head.alignment = BoxContainer.ALIGNMENT_CENTER
	head.add_theme_constant_override("separation", 22)
	col.add_child(head)
	var title := Label.new()
	title.text = "Road of the Beasts"
	title.add_theme_font_size_override("font_size", 84)
	title.add_theme_color_override("font_color", UiTheme.INK)
	if UiTheme.title_font() != null:
		title.add_theme_font_override("font", UiTheme.title_font())
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	head.add_child(title)
	head.add_child(UiTheme.icon_rect("seal", 78, UiTheme.CINNABAR))
	var sub := Label.new()
	sub.text = "Phase 1 prototype"
	sub.add_theme_color_override("font_color", UiTheme.DIM)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(sub)
	col.add_child(Control.new())

	_buttons = VBoxContainer.new()
	_buttons.add_theme_constant_override("separation", 10)
	col.add_child(_buttons)
	_add_button("New Game", func(): get_tree().change_scene_to_file(NEW_GAME_SCENE))
	var cont := _add_button("Continue", _continue_game)
	cont.disabled = not SaveGame.exists()
	_add_button("Battle", func(): get_tree().change_scene_to_file(BATTLE_MENU_SCENE))
	_add_button("Overview", func(): get_tree().change_scene_to_file(OVERVIEW_SCENE))
	_add_button("Settings", _show_settings)
	_add_button("Quit", func(): get_tree().quit())

	_settings = SettingsPanel.new(true)
	_settings.visible = false
	_settings.back_pressed.connect(_show_buttons)
	col.add_child(_settings)


func _add_button(text: String, action: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(320, 60)
	b.pressed.connect(action)
	_buttons.add_child(b)
	return b


func _continue_game() -> void:
	var g := SaveGame.load_game()
	if g == null:
		return
	GameSession.game = g
	GameSession.fight = null
	GameSession.hub_panel = &""
	get_tree().change_scene_to_file(HUB_SCENE)


func _show_settings() -> void:
	_buttons.visible = false
	_settings.visible = true


func _show_buttons() -> void:
	_settings.visible = false
	_buttons.visible = true
