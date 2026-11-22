extends Control
## The battle menu: the two battles of the game (docs/battle_ingame.md §1). They share the rule core and nothing else.

const INGAME_SCENE := "res://battle/ingame/ingame_prototype.tscn"
const MULTIPLAYER_SCENE := "res://battle/draft.tscn"
const MENU_SCENE := "res://game/menu.tscn"


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
	var title := Label.new()
	title.text = "BATTLE"
	title.add_theme_font_size_override("font_size", 44)
	title.add_theme_color_override("font_color", UiTheme.ACCENT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(title)
	col.add_child(Control.new())
	_button(col, "Ingame Prototype", "The battle of the game: grown monsters, sides of different strength. A test battle without the overworld.", INGAME_SCENE)
	_button(col, "Multiplayer", "The fair battle: every monster has the same points. Draft, builders and test switches.", MULTIPLAYER_SCENE)
	_button(col, "Back", "", MENU_SCENE)


func _button(parent: Control, text: String, hint: String, scene: String) -> void:
	var b := Button.new()
	b.text = text
	b.tooltip_text = hint
	b.custom_minimum_size = Vector2(280, 48)
	b.pressed.connect(func(): get_tree().change_scene_to_file(scene))
	parent.add_child(b)
