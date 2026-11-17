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
## Free shapes the player arranged: monster id -> {kit slot -> Array[Vector2i]} (ShapeEditor).
var _shapes := {}
var _tamer_buttons := {}            # id -> Button
var _random_board: CheckBox
## Open test switches (temp_todo T38): label -> CheckBox. They apply to every battle.
var _experiments := {}
const EXPERIMENTS := [
	["Dragon Veins: last touch owns", "GDD rule: a vein deals its round-end damage for the side that touched it last, whether or not a monster stands on it; the board shows the owner. Off = a monster has to stand on it at the round end (S028)."],
	["Free camera", "View switch, to compare: dragging with the middle mouse button also tilts the camera up and down (left and right turns it, as before). Off = the fixed tilt."],
	["Random monsters", "Monster switch: every monster of the battle, yours too, gets random stats and a random Kin, bought with the monster calculation for 60 points. The monster you pick is only the look. Each also plays a random kit (see Random kits)."],
	["Random kits", "Kit switch: every monster of the battle, yours too, plays a random kit instead of its own. Each monster draws a kit template (Balanced, Bruiser, Skirmisher, Controller, Trapper, Shaper) that only says how many Strikes, movement, zone, ground and prop skills it holds; the skills are drawn from the game's own. A new draw for every battle; 'Fight Again' repeats the same kits."],
	["New skills every battle", "Kit switch: the random kits are made of skills generated for this battle instead of the game's own. Their AP follow the draft price list (SkillCalc). Nothing is saved."],
]

## The review pack of 2026-11-17 (docs/todo T44): label, tooltip, switch of BattleExperiment, value when the box is
## on, value when it is off. All on by default; none is a rule. They get their check boxes after EXPERIMENTS.
const PACK := [
	["Pack: no damage in round 1", "Round 1 is for position: nothing deals damage before round 2. Off = damage from round 1 (the rule).", "damage_from_round", 2, 1],
	["Pack: no late-round pressure", "No Voidscar spreads. Off = late-round pressure runs while nobody owns a Dragon Vein (the rule).", "pressure_mode", "none", "idle"],
]

## Board and value switches: label, min, max, unused, tooltip -> SpinBox.
var _numbers := {}
const NUMBERS := [
	["Board size", 7, 9, 0, "Side length of the board: 7 = the board of the mode, 8 = 8×8 (no centre row: the Dragon Veins lie in mirrored pairs on the two centre rows), 9 = 9×9 (Dragon Veins on the centre row as on 7×7)."],
	["Dragon Veins", 0, 7, 0, "Dragon Vein squares on the centre row (7×7 and larger boards only; 0 = none; the build rule is 3). An even board (8×8) has them in mirrored pairs on its two centre rows, so the number rounds up to an even one."],
	["Veins deal 2 from round", 0, 9, 0, "From this round on an owned Dragon Vein deals 2 instead of 1 (build default 3; S039 measured 5, 4 and 3). 0 = never: always 1 (the rule)."],
	["Prop pairs", -1, 8, 0, "Mirrored prop pairs the board starts with: -1 = the fixed test layout (or the random board's own number), 0 = no props, N = that many pairs of random prop types on random squares."],
	["Stamina per round", 0, 5, 0, "0 = the rule: every monster recovers the whole number of its Pace, at least 1. N = every monster recovers N at the end of a round (to compare, S029)."],
	["Button pairs", 0, 4, 0, "Mirrored pairs of button squares the board starts with: walkable runes without damage that act on the board when a monster collects them (Moss Rune: Mossbed 3×3 · Bog Rune: Bog zone around it · Wall Rune: Earth Walls on its cardinal neighbours). 0 = none."],
]

## The first time the draft opens it checks the three random switches (user, 2026-11-17: the multiplayer mode
## plays random monsters with generated kits by default); afterwards the boxes keep what the user set.
static var _opened := false


func _ready() -> void:
	if not _opened:
		_opened = true
		BattleExperiment.random_monsters = true
		BattleExperiment.random_kits = true
		BattleExperiment.fresh_skills = true
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
		b.custom_minimum_size = Vector2(300, 150)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.add_theme_font_size_override("font_size", 13)
		b.text = _card_text(def)
		b.toggled.connect(func(on: bool): _toggle(id, on))
		grid.add_child(b)
		_cards[id] = b

	var loadout := HFlowContainer.new()
	loadout.add_theme_constant_override("h_separation", 8)
	loadout.add_theme_constant_override("v_separation", 4)
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

	var lab := HFlowContainer.new()
	lab.add_theme_constant_override("h_separation", 8)
	lab.add_theme_constant_override("v_separation", 2)
	col.add_child(lab)
	var lab_label := Label.new()
	lab_label.text = "Test switches:"
	lab_label.add_theme_color_override("font_color", UiTheme.DIM)
	lab.add_child(lab_label)
	for item: Array in EXPERIMENTS:
		var cb := CheckBox.new()
		cb.text = item[0]
		cb.tooltip_text = item[1]
		cb.add_theme_font_size_override("font_size", 13)
		cb.button_pressed = _experiment_on(item[0])
		cb.toggled.connect(func(_on: bool): _apply_experiments())
		lab.add_child(cb)
		_experiments[item[0]] = cb
	var switches: Script = BattleExperiment
	for item: Array in PACK:
		var cb := CheckBox.new()
		cb.text = item[0]
		cb.tooltip_text = item[1]
		cb.add_theme_font_size_override("font_size", 13)
		cb.button_pressed = switches.get(item[2]) == item[3]
		cb.toggled.connect(func(_on: bool): _apply_experiments())
		lab.add_child(cb)
		_experiments[item[0]] = cb

	var nums := HFlowContainer.new()
	nums.add_theme_constant_override("h_separation", 8)
	nums.add_theme_constant_override("v_separation", 2)
	col.add_child(nums)
	var nums_label := Label.new()
	nums_label.text = "Board and values:"
	nums_label.add_theme_color_override("font_color", UiTheme.DIM)
	nums.add_child(nums_label)
	for item: Array in NUMBERS:
		var nl := Label.new()
		nl.text = item[0]
		nl.tooltip_text = item[4]
		nl.mouse_filter = Control.MOUSE_FILTER_STOP
		nl.add_theme_font_size_override("font_size", 13)
		nums.add_child(nl)
		var sb := SpinBox.new()
		sb.min_value = item[1]
		sb.max_value = item[2]
		sb.value = _number_now(item[0])
		sb.tooltip_text = item[4]
		sb.value_changed.connect(func(_v: float): _apply_experiments())
		nums.add_child(sb)
		_numbers[item[0]] = sb

	var row := HFlowContainer.new()
	row.alignment = FlowContainer.ALIGNMENT_END
	row.add_theme_constant_override("h_separation", 12)
	row.add_theme_constant_override("v_separation", 8)
	col.add_child(row)
	var back := Button.new()
	back.text = "Back"
	back.custom_minimum_size = Vector2(160, 46)
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://game/menu.tscn"))
	row.add_child(back)
	var build := Button.new()
	build.text = "Monster builder"
	build.custom_minimum_size = Vector2(200, 46)
	build.tooltip_text = "Create a monster or change one: stats, Kin and the four skills. New skills are made in the skill builder, reachable from there."
	build.pressed.connect(func(): get_tree().change_scene_to_file("res://game/monster_builder.tscn"))
	row.add_child(build)
	var shapes := Button.new()
	shapes.text = "Arrange shapes"
	shapes.custom_minimum_size = Vector2(200, 46)
	shapes.tooltip_text = "Lay out the squares of the picked monsters' skills that create ground, a zone or props at a distance (free shapes). Without it every skill uses its default arrangement."
	shapes.pressed.connect(_open_shapes)
	row.add_child(shapes)
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


## Whether the switch behind a check box is on at the moment.
func _experiment_on(label: String) -> bool:
	match label:
		"Dragon Veins: last touch owns":
			return BattleExperiment.vein_touch
		"Free camera":
			return BattleExperiment.free_camera
		"Random kits":
			return BattleExperiment.random_kits
		"Random monsters":
			return BattleExperiment.random_monsters
		"New skills every battle":
			return BattleExperiment.fresh_skills
	return false


## The value a number switch has at the moment.
func _number_now(label: String) -> int:
	match label:
		"Board size":
			return BattleExperiment.board_size if BattleExperiment.board_size >= 8 else 7
		"Dragon Veins":
			return BattleExperiment.wells
		"Veins deal 2 from round":
			return BattleExperiment.vein_late_round
		"Prop pairs":
			return BattleExperiment.map_props
		"Button pairs":
			return BattleExperiment.map_buttons
	return BattleExperiment.stamina_regen


## Sets the experiment switches from the check boxes and refreshes the cards (kits can change).
func _apply_experiments() -> void:
	var on := func(label: String) -> bool: return (_experiments[label] as CheckBox).button_pressed
	BattleExperiment.reset()
	var switches: Script = BattleExperiment
	for item: Array in PACK:
		switches.set(item[2], item[3] if on.call(item[0]) else item[4])
	BattleExperiment.vein_touch = on.call("Dragon Veins: last touch owns")
	BattleExperiment.free_camera = on.call("Free camera")
	BattleExperiment.random_kits = on.call("Random kits")
	BattleExperiment.random_monsters = on.call("Random monsters")
	BattleExperiment.fresh_skills = on.call("New skills every battle")
	var side := int((_numbers["Board size"] as SpinBox).value)
	BattleExperiment.board_size = side if side >= 8 else 0
	BattleExperiment.wells = int((_numbers["Dragon Veins"] as SpinBox).value)
	BattleExperiment.vein_late_round = int((_numbers["Veins deal 2 from round"] as SpinBox).value)
	BattleExperiment.map_props = int((_numbers["Prop pairs"] as SpinBox).value)
	BattleExperiment.stamina_regen = int((_numbers["Stamina per round"] as SpinBox).value)
	BattleExperiment.map_buttons = int((_numbers["Button pairs"] as SpinBox).value)
	for id in _cards:
		(_cards[id] as Button).text = _card_text(BattleSetup.load_def(id))
	if _start3 != null:
		_update()                                 # the start buttons name the board size


## Opens the editor for the free shapes of the picked monsters (ShapeEditor).
func _open_shapes() -> void:
	var editor := ShapeEditor.new()
	add_child(editor)
	editor.setup(_picked, _shapes)
	editor.confirmed.connect(editor.queue_free)
	editor.canceled.connect(editor.queue_free)
	editor.popup_centered()


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
	_status.text = "Picked %d / 3: %s   ·   1 = duel, 2 = 2v2, 3 = 3v3   ·   %s" % [
		_picked.size(), ", ".join(PackedStringArray(_picked.map(func(i): return BattleSetup.load_def(i).display_name))) if not _picked.is_empty() else "—",
		"random kits: the kits on the cards are not used" if BattleExperiment.random_kits or BattleExperiment.fresh_skills or BattleExperiment.random_monsters else "test kits"]
	for pair: Array in [[_start1, &"1v1", "Duel 1v1"], [_start2, &"2v2", "Battle 2v2"], [_start3, &"3v3", "Battle 3v3"]]:
		var side_length := int(BattleBoards.mode_data(pair[1])["size"])
		(pair[0] as Button).text = "%s (%d×%d)" % [pair[2], side_length, side_length]
	_start3.disabled = _picked.size() != 3
	_start2.disabled = _picked.size() != 2
	_start1.disabled = _picked.size() != 1


func _start(m: StringName) -> void:
	_apply_experiments()
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	BattleExperiment.kit_seed = rng.randi_range(1, 1 << 30)       # a new kit draw for every battle
	var enemy := BattleSetup.random_enemy(_picked, BattleSetup.team_size(m), rng)
	var r := BattleRequest.from_ids(m, _picked.duplicate(), enemy)
	r.player_tamer = _tamer.duplicate()
	for i in _picked.size():
		if _shapes.has(_picked[i]):
			r.player_shapes[i] = (_shapes[_picked[i]] as Dictionary).duplicate(true)
	if _random_board.button_pressed or BattleExperiment.map_props > 0 or BattleExperiment.map_buttons > 0:
		r.board_seed = rng.randi_range(1, 1 << 30)
	if _tamer.has(&"beast_swap"):
		# Beast Swap needs someone to bring in: one unused species as a test bench
		var used: Array[StringName] = _picked.duplicate()
		used.append_array(enemy)
		var bench := BattleSetup.random_enemy(used, 1, rng)
		r.player_bench = BattleSetup.references(bench)
	GameSession.start_battle(r)
	get_tree().change_scene_to_file(BATTLE_SCENE)
