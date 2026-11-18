class_name IngamePrototype
extends Control
## Ingame prototype (docs/battle_ingame.md §1, docs/todo T46): a test battle of the ingame battle without the
## overworld. Each side gets monsters drawn for its own points (a stage of growth), so the sides may differ in
## strength; the species is only the look and every monster plays a kit of skills generated for the battle. It plays
## the core rules with the build defaults and none of the switches of the multiplayer draft. No rule.

const BATTLE_SCENE := "res://battle/battle.tscn"
const SELF_SCENE := "res://battle/ingame/ingame_prototype.tscn"
const MENU_SCENE := "res://battle/battle_menu.tscn"
## The points of growth (docs/monsters.md §2.2): 25 at the start, +5 with each of the 18 steps.
const POINTS_MIN := 25
const POINTS_MAX := 110
const POINTS_STEP := 5
const STAGES: Array[String] = ["Qi Gathering", "Foundation", "Core Formation", "Soul Tier", "Immortal", "Sovereign"]
const TIERS: Array[String] = ["Lower", "Middle", "High"]

## What the screen showed last, kept while the game runs.
static var points: Array[int] = [60, 60]
static var board_size := 7

var _points: Array[SpinBox] = []
var _stage: Array[Label] = []
var _board: SpinBox


## "Core Formation Middle" for 60 points.
static func stage_name(p: int) -> String:
	var step := clampi((p - POINTS_MIN) / POINTS_STEP, 0, STAGES.size() * TIERS.size() - 1)
	return "%s %s" % [STAGES[step / TIERS.size()], TIERS[step % TIERS.size()]]


## The request of a prototype battle: random species as the look, monsters drawn for the points of each side.
static func request(mode: StringName, side_points: Array[int], rng: RandomNumberGenerator) -> BattleRequest:
	var size := BattleSetup.team_size(mode)
	var mine := BattleSetup.random_enemy([], size, rng)
	var r := BattleRequest.from_ids(mode, mine, BattleSetup.random_enemy(mine, size, rng))
	r.battle_kind = BattleRequest.INGAME
	r.side_points = side_points.duplicate()
	r.draw_seed = rng.randi_range(1, 1 << 30)
	r.board_seed = rng.randi_range(1, 1 << 30)
	return r


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
	title.text = "INGAME PROTOTYPE"
	title.add_theme_font_size_override("font_size", 40)
	title.add_theme_color_override("font_color", UiTheme.ACCENT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(title)
	var sub := Label.new()
	sub.text = "Grown monsters, sides of different strength. Random monsters and kits for the points of each side."
	sub.add_theme_color_override("font_color", UiTheme.DIM)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(sub)

	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 10)
	col.add_child(grid)
	for side in 2:
		grid.add_child(_label("Your points" if side == 0 else "Enemy points"))
		var sb := SpinBox.new()
		sb.min_value = POINTS_MIN
		sb.max_value = POINTS_MAX
		sb.step = POINTS_STEP
		sb.value = points[side]
		sb.tooltip_text = "The points every monster of this side is bought with: 25 at the start of the game, +5 with each step of growth, 110 at the end."
		sb.value_changed.connect(func(_v: float): _changed())
		grid.add_child(sb)
		_points.append(sb)
		var stage := _label("")
		stage.add_theme_color_override("font_color", UiTheme.DIM)
		grid.add_child(stage)
		_stage.append(stage)
	grid.add_child(_label("Board size"))
	_board = SpinBox.new()
	_board.min_value = 7
	_board.max_value = 9
	_board.value = board_size
	_board.tooltip_text = "Side length of the board for 3v3 (7 = the board of the mode). Battlegrounds of other outlines are not built yet."
	_board.value_changed.connect(func(_v: float): _changed())
	grid.add_child(_board)
	grid.add_child(_label(""))

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	col.add_child(row)
	for pair: Array in [[&"1v1", "Duel 1v1"], [&"2v2", "Battle 2v2"], [&"3v3", "Battle 3v3"]]:
		var b := Button.new()
		b.text = pair[1]
		b.custom_minimum_size = Vector2(160, 46)
		b.pressed.connect(_start.bind(pair[0]))
		row.add_child(b)
	var back := Button.new()
	back.text = "Back"
	back.custom_minimum_size = Vector2(160, 46)
	back.pressed.connect(func(): get_tree().change_scene_to_file(MENU_SCENE))
	row.add_child(back)
	_changed()


func _label(text: String) -> Label:
	var l := Label.new()
	l.text = text
	return l


func _changed() -> void:
	for side in 2:
		points[side] = int(_points[side].value)
		_stage[side].text = stage_name(points[side])
	board_size = int(_board.value)


func _start(mode: StringName) -> void:
	_changed()
	BattleExperiment.reset()                        # the ingame battle plays none of the switches of the multiplayer draft
	BattleExperiment.board_size = board_size if board_size >= 8 else 0
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	GameSession.start_battle(request(mode, points, rng), SELF_SCENE)
	get_tree().change_scene_to_file(BATTLE_SCENE)
