extends Control
## Pre-battle draft (GDD §3): pick 3 of the 9 roster monsters (or 1 for a duel).
## The AI gets a random team from the monsters you didn't pick.

const BATTLE_SCENE := "res://main.tscn"

var _picked: Array[StringName] = []
var _cards := {}                    # id -> Button
var _status: Label
var _start3: Button
var _start1: Button


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	theme = UiTheme.create()

	var bg := ColorRect.new()
	bg.color = Color(0.075, 0.082, 0.094)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 40)
	add_child(margin)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 16)
	margin.add_child(col)

	var title := Label.new()
	title.text = "CHOOSE YOUR TEAM"
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", UiTheme.ACCENT)
	col.add_child(title)
	_status = Label.new()
	_status.add_theme_color_override("font_color", UiTheme.DIM)
	col.add_child(_status)

	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	col.add_child(scroll)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(grid)
	for id in GameData.monster_ids():
		var def := BattleSetup.load_def(id)
		var b := Button.new()
		b.toggle_mode = true
		b.custom_minimum_size = Vector2(380, 250)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.add_theme_font_size_override("font_size", 13)
		b.text = _card_text(def)
		b.toggled.connect(func(on: bool): _toggle(id, on))
		grid.add_child(b)
		_cards[id] = b

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	col.add_child(row)
	var back := Button.new()
	back.text = "Back"
	back.custom_minimum_size = Vector2(160, 46)
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://menu.tscn"))
	row.add_child(back)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)
	_start1 = Button.new()
	_start1.text = "Duel 1v1 (5×5)"
	_start1.custom_minimum_size = Vector2(200, 46)
	_start1.pressed.connect(func(): _start(&"1v1"))
	row.add_child(_start1)
	_start3 = Button.new()
	_start3.text = "Battle 3v3 (7×7)"
	_start3.custom_minimum_size = Vector2(220, 46)
	_start3.pressed.connect(func(): _start(&"3v3"))
	row.add_child(_start3)
	_update()


func _card_text(d: MonsterDef) -> String:
	var rows := InfoText.monster_rows(d)
	return "%s\n%s\n%s" % [d.display_name.to_upper(), InfoText.rows_to_text(rows), d.blurb]


func _toggle(id: StringName, on: bool) -> void:
	if on and not _picked.has(id):
		if _picked.size() >= 3:
			_cards[id].set_pressed_no_signal(false)
			return
		_picked.append(id)
	elif not on:
		_picked.erase(id)
	_update()


func _update() -> void:
	_status.text = "Picked %d / 3: %s   ·   1 pick = duel, 3 picks = team battle. The enemy gets a random team from the rest." % [
		_picked.size(), ", ".join(PackedStringArray(_picked.map(func(i): return BattleSetup.load_def(i).display_name))) if not _picked.is_empty() else "—"]
	_start3.disabled = _picked.size() != 3
	_start1.disabled = _picked.size() != 1


func _start(m: StringName) -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	BattleSetup.mode = m
	BattleSetup.player_pick = _picked.duplicate()
	BattleSetup.enemy_pick = BattleSetup.random_enemy(_picked, BattleSetup.team_size(m), rng)
	get_tree().change_scene_to_file(BATTLE_SCENE)
