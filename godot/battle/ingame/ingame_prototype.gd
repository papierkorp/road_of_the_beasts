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
## The custom map played last ("" = the generated board of the mode) and the monsters per side on it.
static var map_id: StringName = &""
static var team: Array[int] = [3, 3]
const EDITOR_SCENE := "res://battle/ingame/map_editor.tscn"
const GENERATED := "— generated board —"

var _points: Array[SpinBox] = []
var _stage: Array[Label] = []
var _board: SpinBox
var _map: OptionButton
var _team: Array[SpinBox] = []
var _map_note: Label
var _start_map: Button


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


## The request of a battle on a custom map: `mine` and `theirs` monsters, as far as the start areas have room.
static func map_request(map: MapDef, mine: int, theirs: int, side_points: Array[int], rng: RandomNumberGenerator) -> BattleRequest:
	var content := BattleContent.shared()
	mine = clampi(mine, 1, map.free_starts(content, 0).size())
	theirs = clampi(theirs, 1, map.free_starts(content, 1).size())
	var pool: Array[StringName] = GameData.monster_ids().duplicate()
	var looks: Array[StringName] = []                # the species is only the look: repeat when the pool is small
	for i in mine + theirs:
		looks.append(pool[rng.randi_range(0, pool.size() - 1)])
	var r := BattleRequest.new()
	r.player_team = BattleSetup.references(looks.slice(0, mine))
	r.enemy_team = BattleSetup.references(looks.slice(mine))
	r.battle_kind = BattleRequest.INGAME
	r.side_points = side_points.duplicate()
	r.draw_seed = rng.randi_range(1, 1 << 30)
	r.map = map
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
	grid.add_child(_label("Map"))
	_map = OptionButton.new()
	_map.add_item(GENERATED)
	for id in MapDef.ids():
		_map.add_item(String(id))
		if id == map_id:
			_map.select(_map.item_count - 1)
	_map.tooltip_text = "A battleground made in the map editor. On a map the teams may differ in size."
	_map.item_selected.connect(func(_i: int): _changed())
	grid.add_child(_map)
	_map_note = _label("")
	_map_note.add_theme_color_override("font_color", UiTheme.DIM)
	grid.add_child(_map_note)
	for side in 2:
		grid.add_child(_label("Your monsters" if side == 0 else "Enemy monsters"))
		var count := SpinBox.new()
		count.min_value = 1
		count.max_value = 8
		count.value = team[side]
		count.tooltip_text = "Monsters of this side on a custom map; at most as many as its start area has free squares."
		count.value_changed.connect(func(_v: float): _changed())
		grid.add_child(count)
		_team.append(count)
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
	_start_map = Button.new()
	_start_map.text = "Battle on the map"
	_start_map.custom_minimum_size = Vector2(190, 46)
	_start_map.pressed.connect(_start_on_map)
	row.add_child(_start_map)
	var row2 := HBoxContainer.new()
	row2.alignment = BoxContainer.ALIGNMENT_CENTER
	row2.add_theme_constant_override("separation", 12)
	col.add_child(row2)
	var editor := Button.new()
	editor.text = "Map editor"
	editor.custom_minimum_size = Vector2(160, 46)
	editor.pressed.connect(func(): get_tree().change_scene_to_file(EDITOR_SCENE))
	row2.add_child(editor)
	var back := Button.new()
	back.text = "Back"
	back.custom_minimum_size = Vector2(160, 46)
	back.pressed.connect(func(): get_tree().change_scene_to_file(MENU_SCENE))
	row2.add_child(back)
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
	if _map == null or _start_map == null:
		return
	var text := _map.get_item_text(_map.selected)
	map_id = &"" if text == GENERATED else StringName(text)
	for side in 2:
		team[side] = int(_team[side].value)
	var map := _picked_map()
	var why := "" if map == null else "; ".join(map.problems(BattleContent.shared()))
	_start_map.disabled = map == null or why != ""
	_map_note.text = "" if map == null else (why if why != "" else "%d×%d, room for %d against %d" % [map.width, map.height,
		map.free_starts(BattleContent.shared(), 0).size(), map.free_starts(BattleContent.shared(), 1).size()])


func _picked_map() -> MapDef:
	return null if map_id == &"" else MapDef.load_map(map_id)


func _start_on_map() -> void:
	_changed()
	var map := _picked_map()
	if map == null or not map.problems(BattleContent.shared()).is_empty():
		return
	BattleExperiment.reset()
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	GameSession.start_battle(map_request(map, team[0], team[1], points, rng), SELF_SCENE)
	get_tree().change_scene_to_file(BATTLE_SCENE)


func _start(mode: StringName) -> void:
	_changed()
	BattleExperiment.reset()                        # the ingame battle plays none of the switches of the multiplayer draft
	BattleExperiment.board_size = board_size if board_size >= 8 else 0
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	GameSession.start_battle(request(mode, points, rng), SELF_SCENE)
	get_tree().change_scene_to_file(BATTLE_SCENE)
