extends Control
## Battle sandbox draft: pick 1, 2 or 3 of the nine reference monsters; the AI gets a random
## team from the rest. Everything offered here is TEST DATA (test kits of gdd_skills §10,
## reference sheets of gdd_monsters §4.1); the tamer skills are a test loadout, not an unlock.

const BATTLE_SCENE := "res://battle/battle.tscn"
## Test loadout size: the third tamer slot opens at Immortal (gdd_overworld §6.3).
const MAX_TAMER := 3

var _picked: Array[StringName] = []
var _cards := {}                    # id -> Button
var _status: Label
var _start3: Button
var _start2: Button
var _start1: Button
var _tamer: Array[StringName] = []
var _tamer_buttons := {}            # id -> Button
var _random_board: CheckBox


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = UiTheme.create()

	var bg := ColorRect.new()
	bg.color = Color(0.075, 0.082, 0.094)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
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
		b.custom_minimum_size = Vector2(380, 150)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.add_theme_font_size_override("font_size", 13)
		b.text = _card_text(def)
		b.toggled.connect(func(on: bool): _toggle(id, on))
		grid.add_child(b)
		_cards[id] = b

	var loadout := HBoxContainer.new()
	loadout.add_theme_constant_override("separation", 8)
	col.add_child(loadout)
	var loadout_label := Label.new()
	loadout_label.text = "Test loadout (tamer skills, max %d):" % MAX_TAMER
	loadout_label.add_theme_color_override("font_color", UiTheme.DIM)
	loadout.add_child(loadout_label)
	var content := BattleContent.shared()
	var tamer_ids := content.tamer.keys()
	tamer_ids.sort()
	for tid: StringName in tamer_ids:
		var def := content.tamer_skill(tid)
		var tb := Button.new()
		tb.toggle_mode = true
		tb.text = def.display_name
		tb.tooltip_text = def.description
		tb.add_theme_font_size_override("font_size", 13)
		tb.toggled.connect(func(on: bool): _toggle_tamer(tid, on))
		loadout.add_child(tb)
		_tamer_buttons[tid] = tb
	_random_board = CheckBox.new()
	_random_board.text = "Random board"
	_random_board.tooltip_text = "Off: the fixed test layout of the mode. On: a seeded, point-symmetric layout."
	loadout.add_child(_random_board)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	col.add_child(row)
	var back := Button.new()
	back.text = "Back"
	back.custom_minimum_size = Vector2(160, 46)
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://game/menu.tscn"))
	row.add_child(back)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)
	_start1 = Button.new()
	_start1.text = "Duel 1v1 (5×5)"
	_start1.custom_minimum_size = Vector2(200, 46)
	_start1.pressed.connect(func(): _start(&"1v1"))
	row.add_child(_start1)
	_start2 = Button.new()
	_start2.text = "Battle 2v2 (6×6)"
	_start2.custom_minimum_size = Vector2(200, 46)
	_start2.pressed.connect(func(): _start(&"2v2"))
	row.add_child(_start2)
	_start3 = Button.new()
	_start3.text = "Battle 3v3 (7×7)"
	_start3.custom_minimum_size = Vector2(220, 46)
	_start3.pressed.connect(func(): _start(&"3v3"))
	row.add_child(_start3)
	_update()


func _card_text(d: MonsterDef) -> String:
	var sheet := UnitSheets.from_instance(MonsterInstance.of_species(d))
	var rows := BattleText.sheet_rows(BattleContent.shared(), sheet)
	return "%s\n%s\n%s" % [d.display_name.to_upper(), BattleText.rows_to_text(rows), d.blurb]


func _toggle(id: StringName, on: bool) -> void:
	if on and not _picked.has(id):
		if _picked.size() >= 3:
			_cards[id].set_pressed_no_signal(false)
			return
		_picked.append(id)
	elif not on:
		_picked.erase(id)
	_update()


func _toggle_tamer(id: StringName, on: bool) -> void:
	if on and not _tamer.has(id):
		if _tamer.size() >= MAX_TAMER:
			_tamer_buttons[id].set_pressed_no_signal(false)
			return
		_tamer.append(id)
	elif not on:
		_tamer.erase(id)


func _update() -> void:
	_status.text = "Picked %d / 3: %s   ·   1 = duel, 2 = 2v2, 3 = 3v3   ·   test kits" % [
		_picked.size(), ", ".join(PackedStringArray(_picked.map(func(i): return BattleSetup.load_def(i).display_name))) if not _picked.is_empty() else "—"]
	_start3.disabled = _picked.size() != 3
	_start2.disabled = _picked.size() != 2
	_start1.disabled = _picked.size() != 1


func _start(m: StringName) -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var enemy := BattleSetup.random_enemy(_picked, BattleSetup.team_size(m), rng)
	var r := BattleRequest.from_ids(m, _picked.duplicate(), enemy)
	r.player_tamer = _tamer.duplicate()
	if _random_board.button_pressed:
		r.board_seed = rng.randi_range(1, 1 << 30)
	if _tamer.has(&"beast_swap"):
		# Beast Swap needs someone to bring in: one unused species as a test bench
		var used: Array[StringName] = _picked.duplicate()
		used.append_array(enemy)
		var bench := BattleSetup.random_enemy(used, 1, rng)
		r.player_bench = BattleSetup.references(bench)
	GameSession.start_battle(r)
	get_tree().change_scene_to_file(BATTLE_SCENE)
