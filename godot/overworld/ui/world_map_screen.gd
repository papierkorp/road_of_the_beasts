class_name WorldMapScreen
extends Control
## The city as a map of places (gdd_overworld §11 "node-based map v1") — the menu view next to the
## walkable districts. Click a place to see what it offers (PlacePanel).

const SCENE := "res://overworld/overworld.tscn"
const DISTRICT_SCENE := "res://overworld/district.tscn"
const MENU_SCENE := "res://game/menu.tscn"
const MAP_SIZE := Vector2(760, 440)
const PLACE_SIZE := Vector2(190, 64)

## pos = centre on the map.
const PLACES := [
	{"id": &"inner", "pos": Vector2(150, 300)},
	{"id": &"plaza", "pos": Vector2(380, 120)},
	{"id": &"market", "pos": Vector2(610, 300)},
	{"id": &"clan", "pos": Vector2(380, 380)},
]

var _game: GameState
var _map: Control
var _header: Label
var _panel: PlacePanel
var _selected: StringName = &"plaza"
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = UiTheme.create()
	_rng.randomize()
	_game = GameSession.game
	if _game == null:
		get_tree().change_scene_to_file.call_deferred(MENU_SCENE)
		return
	var bg := ColorRect.new()
	bg.color = Color(0.075, 0.082, 0.094)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 32)
	add_child(margin)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 14)
	margin.add_child(col)

	_header = Label.new()
	_header.add_theme_font_size_override("font_size", 26)
	_header.add_theme_color_override("font_color", UiTheme.ACCENT)
	col.add_child(_header)

	var row := HBoxContainer.new()
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 24)
	col.add_child(row)
	_map = Control.new()
	_map.custom_minimum_size = MAP_SIZE
	_map.draw.connect(_draw_map)
	row.add_child(_map)
	for p in PLACES:
		var id: StringName = p["id"]
		var b := Button.new()
		b.text = PlacePanel.place_name(id) + ("" if PlacePanel.is_built(id) else "  (soon)")
		b.size = PLACE_SIZE
		b.custom_minimum_size = PLACE_SIZE
		b.position = p["pos"] - PLACE_SIZE / 2.0
		b.pressed.connect(func(): _select(id))
		_map.add_child(b)
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	row.add_child(scroll)
	_panel = PlacePanel.new()
	_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_panel.setup(_game)
	_panel.changed.connect(_refresh_header)
	scroll.add_child(_panel)

	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation", 12)
	col.add_child(bar)
	bar.add_child(_button("Walk the streets", _walk))
	bar.add_child(_button("End day  (night passes)", _end_day))
	bar.add_child(_button("Save and quit to menu", _to_menu))
	GameSession.state_changed.connect(_on_state_changed)
	_refresh_header()
	_panel.show_place(_selected)


func _draw_map() -> void:
	var plaza := _pos_of(&"plaza")
	for p in PLACES:
		if p["id"] != &"plaza":
			_map.draw_line(plaza, p["pos"], Color(UiTheme.DIM.r, UiTheme.DIM.g, UiTheme.DIM.b, 0.5), 2.0)


func _pos_of(id: StringName) -> Vector2:
	for p in PLACES:
		if p["id"] == id:
			return p["pos"]
	return Vector2.ZERO


func _select(id: StringName) -> void:
	_selected = id
	_panel.show_place(id)


func _on_state_changed() -> void:
	_refresh_header()
	_panel.refresh()


func _refresh_header() -> void:
	_header.text = "Day %d  ·  AP %d / %d  ·  %d spirit stones  ·  %s %s" % [_game.day, _game.ap, _game.max_ap,
		_game.money, Stage.stage_name(_game.stage), Stage.sub_tier_name(_game.sub_tier)]


func _walk() -> void:
	GameSession.district = &"plaza"
	GameSession.arrive_from = &"start"
	get_tree().change_scene_to_file(DISTRICT_SCENE)


func _end_day() -> void:
	if GameSession.expedition != null:
		_panel.say("Finish or leave the dungeon first.")
		return
	var report := _game.end_day(_rng)
	SaveGame.save(_game)
	_refresh_header()
	_panel.say("The night passes. Day %d begins; %d monster(s) recovered." % [report["day"], report["healed"]])


func _to_menu() -> void:
	if GameSession.expedition == null:
		SaveGame.save(_game)
	get_tree().change_scene_to_file(MENU_SCENE)


func _button(text: String, action: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(300, 46)
	b.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	b.pressed.connect(action)
	return b
