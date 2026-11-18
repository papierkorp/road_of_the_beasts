extends Control
## Start screen of the multiplayer battle (docs/battle.md §1): always 3v3 on a generated, point-symmetric 7×7 board,
## no tamer skills. The multiplayer battle has no fixed monsters and skills: every monster is drawn for the points of
## the multiplayer mode and plays a kit of skills generated for this battle. Two start buttons: random monsters for
## both sides, each side its own, or the same monsters for both. The species is only the look. The alternating draft of monsters and skills is not built here; it
## comes with the rebuild (docs/architecture.md §4).

const BATTLE_SCENE := "res://battle/battle.tscn"

var _status: Label
var _start_random: Button
var _start_same: Button

## Board and value switches (test values, no rules): label, min, max, unused, tooltip -> SpinBox.
var _numbers := {}
const NUMBERS := [
	["Board size", 7, 9, 0, "Side length of the board: 7 = the board of the mode, 8 = 8×8 (no centre row: the Dragon Veins lie in mirrored pairs on the two centre rows), 9 = 9×9 (Dragon Veins on the centre row as on 7×7)."],
	["Dragon Veins", 0, 7, 0, "Dragon Vein squares on the centre row (7×7 and larger boards only; 0 = none; the build rule is 3). An even board (8×8) has them in mirrored pairs on its two centre rows, so the number rounds up to an even one."],
	["Veins deal 2 from round", 0, 9, 0, "From this round on an owned Dragon Vein deals 2 instead of 1 (build default 3; S039 measured 5, 4 and 3). 0 = never: always 1 (the rule)."],
	["Prop pairs", -1, 8, 0, "Mirrored prop pairs the board starts with: -1 = the fixed test layout (or the random board's own number), 0 = no props, N = that many pairs of random prop types on random squares."],
	["Stamina per round", 0, 5, 0, "0 = the rule: every monster recovers the whole number of its Pace, at least 1. N = every monster recovers N at the end of a round (to compare, S029)."],
	["Button pairs", 0, 4, 0, "Mirrored pairs of button squares the board starts with: walkable runes without damage that act on the board when a monster collects them (Moss Rune: Mossbed 3×3 · Bog Rune: Bog zone around it · Wall Rune: Earth Walls on its cardinal neighbours). 0 = none."],
]


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
	title.text = "MULTIPLAYER"
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", UiTheme.ACCENT)
	col.add_child(title)
	_status = Label.new()
	_status.add_theme_color_override("font_color", UiTheme.DIM)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(_status)

	var nums := HFlowContainer.new()
	nums.add_theme_constant_override("h_separation", 8)
	nums.add_theme_constant_override("v_separation", 2)
	col.add_child(nums)
	var nums_label := Label.new()
	nums_label.text = "Board and values (test):"
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

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(spacer)
	var row := HFlowContainer.new()
	row.alignment = FlowContainer.ALIGNMENT_END
	row.add_theme_constant_override("h_separation", 12)
	row.add_theme_constant_override("v_separation", 8)
	col.add_child(row)
	var back := Button.new()
	back.text = "Back"
	back.custom_minimum_size = Vector2(160, 46)
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://battle/battle_menu.tscn"))
	row.add_child(back)
	var build := Button.new()
	build.text = "Monster builder"
	build.custom_minimum_size = Vector2(200, 46)
	build.tooltip_text = "Create a monster or change one and save it: stats, Kin and skills. New skills are made in the skill builder, reachable from there. A saved monster is not fielded by this screen."
	build.pressed.connect(func(): get_tree().change_scene_to_file("res://game/monster_builder.tscn"))
	row.add_child(build)
	_start_same = Button.new()
	_start_same.text = "Same monsters for both sides"
	_start_same.tooltip_text = "3v3: monster 1, 2 and 3 of both sides are the same random monsters."
	_start_same.custom_minimum_size = Vector2(280, 46)
	_start_same.pressed.connect(func(): _start(&"3v3", true))
	row.add_child(_start_same)
	_start_random = Button.new()
	_start_random.text = "Random monsters for both sides"
	_start_random.tooltip_text = "3v3: every monster of both sides is drawn on its own."
	_start_random.custom_minimum_size = Vector2(280, 46)
	_start_random.pressed.connect(func(): _start(&"3v3", false))
	row.add_child(_start_random)
	_update()


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


## Sets the board and value switches from the number fields.
func _apply_experiments() -> void:
	BattleExperiment.reset()
	var side := int((_numbers["Board size"] as SpinBox).value)
	BattleExperiment.board_size = side if side >= 8 else 0
	BattleExperiment.wells = int((_numbers["Dragon Veins"] as SpinBox).value)
	BattleExperiment.vein_late_round = int((_numbers["Veins deal 2 from round"] as SpinBox).value)
	BattleExperiment.map_props = int((_numbers["Prop pairs"] as SpinBox).value)
	BattleExperiment.stamina_regen = int((_numbers["Stamina per round"] as SpinBox).value)
	BattleExperiment.map_buttons = int((_numbers["Button pairs"] as SpinBox).value)
	if _status != null:
		_update()                                 # the text names the board size


func _update() -> void:
	var side_length := int(BattleBoards.mode_data(&"3v3")["size"])
	_status.text = "3v3 on %d×%d. Every monster is random and costs %d points." % [side_length, side_length, MonsterDef.MULTIPLAYER_POINTS]


## The request of a multiplayer battle: random species as the look, drawn monsters and kits, a generated board.
static func request(m: StringName, mirror: bool, rng: RandomNumberGenerator) -> BattleRequest:
	var size := BattleSetup.team_size(m)
	var mine := BattleSetup.random_enemy([], size, rng)
	var r := BattleRequest.from_ids(m, mine, BattleSetup.random_enemy(mine, size, rng))
	r.battle_kind = BattleRequest.MULTIPLAYER
	r.draw_seed = rng.randi_range(1, 1 << 30)
	r.mirror_draw = mirror
	r.board_seed = rng.randi_range(1, 1 << 30)       # the multiplayer board: generated, point-symmetric
	return r


func _start(m: StringName, same := false) -> void:
	_apply_experiments()
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	GameSession.start_battle(request(m, same, rng))
	get_tree().change_scene_to_file(BATTLE_SCENE)
