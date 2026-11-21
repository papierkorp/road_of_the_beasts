class_name NewGameScreen
extends Control
## The start of a game (docs/vision.md §5): the player chooses a cultivation system and one of three eggs.

const HUB_SCENE := "res://overworld/hub.tscn"
const MENU_SCENE := "res://game/menu.tscn"

var _system: StringName = &""
var _egg: StringName = &""
var _body: VBoxContainer


func _ready() -> void:
	var margin := HubUi.page(self)
	_body = HubUi.col(14)
	margin.add_child(_body)
	_build()


func _build() -> void:
	for c in _body.get_children():
		_body.remove_child(c)
		c.queue_free()
	_body.add_child(HubUi.title("A NEW GAME"))
	_body.add_child(HubUi.label("You are an orphan. Choose the way you cultivate, then one of the three eggs of the nest you found."))
	var list := HubUi.scroll(_body)
	list.add_child(HubUi.label("Cultivation system", 22, UiTheme.ACCENT))
	var systems := HubUi.row()
	list.add_child(systems)
	for id in CultivationDef.ids():
		var def := CultivationDef.of(id)
		var names: PackedStringArray = []
		for n: Dictionary in def.nodes:
			names.append(String(n["name"]))
		systems.add_child(_choice("%s\n%s\n\nIts tree: %s" % [def.display_name, def.blurb, ", ".join(names)], _system == id, func():
			_system = id
			_build()))
	list.add_child(HubUi.label("The nest", 22, UiTheme.ACCENT))
	var eggs := HubUi.row()
	list.add_child(eggs)
	for id in GameValues.shared().eggs:
		var def := GameData.monster(id)
		if def == null:
			continue
		eggs.add_child(_choice("%s (%s)\n%s\n\nCan learn: %s\n\n%s" % [def.display_name, MonsterDef.kin_name(def.kin), def.blurb, def.kit_text(), KinDef.of(def.kin).trait_line() if KinDef.of(def.kin) != null else ""], _egg == id, func():
			_egg = id
			_build()))
	var bottom := HubUi.row()
	_body.add_child(bottom)
	bottom.add_child(HubUi.button("Back", func(): get_tree().change_scene_to_file(MENU_SCENE), 160))
	var go := HubUi.button("Begin", _begin, 260)
	go.disabled = _system == &"" or _egg == &""
	bottom.add_child(go)


func _choice(text: String, picked: bool, action: Callable) -> Button:
	var b := Button.new()
	b.toggle_mode = true
	b.button_pressed = picked
	b.text = text
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
	b.custom_minimum_size = Vector2(380, 270)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.pressed.connect(action)
	return b


func _begin() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	GameSession.game = GameState.new_game(rng.randi_range(1, 1 << 30), _system, _egg)
	GameSession.fight = null
	GameSession.hub_panel = &"monsters"
	GameSession.hub_tabs = {&"monsters": &"stats"}
	SaveGame.save(GameSession.game)
	get_tree().change_scene_to_file(HUB_SCENE)
