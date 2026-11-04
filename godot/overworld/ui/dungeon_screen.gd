class_name DungeonScreen
extends Control
## A dungeon run as a node map (gdd_overworld §6.2, §11): pick a path, look at the wild monsters'
## full datasheets, choose your team, fight. HP carries over from node to node.

const SCENE := "res://overworld/dungeon.tscn"
const BATTLE_SCENE := "res://battle/battle.tscn"
const CITY_SCENE := "res://overworld/overworld.tscn"

var _game: GameState
var _ex: Expedition
var _header: Label
var _canvas: DungeonCanvas
var _info: VBoxContainer
var _note := ""
var _checks: Array[CheckBox] = []
var _team_label: Label
var _fight: Button


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = UiTheme.create()
	_game = GameSession.game
	_ex = GameSession.expedition
	if _game == null or _ex == null:
		get_tree().change_scene_to_file.call_deferred(CITY_SCENE)
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
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	margin.add_child(scroll)
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 14)
	scroll.add_child(col)
	_header = Label.new()
	_header.add_theme_font_size_override("font_size", 26)
	_header.add_theme_color_override("font_color", UiTheme.ACCENT)
	col.add_child(_header)
	_canvas = DungeonCanvas.new()
	_canvas.node_pressed.connect(_on_node)
	col.add_child(_canvas)
	_info = VBoxContainer.new()
	_info.add_theme_constant_override("separation", 10)
	col.add_child(_info)
	_apply_battle_result()
	_refresh()


## Back from a battle of this run: HP persists, victory pays, the path advances.
func _apply_battle_result() -> void:
	var res := GameSession.last_result
	if res == null:
		return
	GameSession.last_result = null
	var before := _ex.current
	_ex.apply_result(_game, res)
	if _ex.finished and _ex.victory:
		_note = "Dungeon cleared! +%d spirit stones in total." % _ex.money_earned
	elif _ex.finished:
		_note = "Your team fell. The run ends here — the night will heal you."
	elif _ex.current != before:
		_note = "Victory! Choose where to go next."


func _refresh() -> void:
	_header.text = "DUNGEON  ·  Day %d  ·  AP %d / %d  ·  %d spirit stones" % [_game.day, _game.ap, _game.max_ap, _game.money]
	_canvas.build(_ex)
	for c in _info.get_children():
		_info.remove_child(c)
		c.queue_free()
	_checks.clear()
	if _note != "":
		_text(_note, UiTheme.TEXT)
	if _ex.finished:
		_button("Return to the city", func(): _leave())
		return
	if _ex.selected < 0:
		_text("Choose your next node on the map.", UiTheme.DIM)
		_button("Retreat to the city  (the AP is spent)", func(): _leave())
		return
	_build_node_panel()


func _build_node_panel() -> void:
	var n := _ex.node(_ex.selected)
	_text("%s — %s   reward %d spirit stones" % [("BOSS" if n["kind"] == &"boss" else "BATTLE"), n["mode"], n["reward"]],
		UiTheme.ACCENT)
	_text("WILD MONSTERS  (full datasheets — no hidden information)", UiTheme.DIM)
	for e: MonsterInstance in n["enemies"]:
		_text(e.sheet_text(), UiTheme.TEXT)
	var team_size := BattleRequest.team_size_of(n["mode"])
	_text("YOUR TEAM", UiTheme.DIM)
	for i in _game.monsters.size():
		var m := _game.monsters[i]
		var cb := CheckBox.new()
		cb.text = m.sheet_text(false).replace("\n", "   ")
		cb.button_pressed = i < team_size
		cb.toggled.connect(func(_on: bool): _update_team())
		_info.add_child(cb)
		_checks.append(cb)
	_team_label = _text("", UiTheme.DIM)
	_fight = _button("Fight", func(): _start_battle())
	_update_team()


func _picked() -> Array[MonsterInstance]:
	var out: Array[MonsterInstance] = []
	for i in _checks.size():
		if _checks[i].button_pressed:
			out.append(_game.monsters[i])
	return out


func _update_team() -> void:
	var team_size := BattleRequest.team_size_of(_ex.node(_ex.selected)["mode"])
	var count := _picked().size()
	_team_label.text = "Team %d / %d" % [count, team_size]
	_fight.disabled = count < 1 or count > team_size


func _on_node(id: int) -> void:
	_ex.select(id)
	_note = ""
	_refresh()


func _start_battle() -> void:
	var request := _ex.request_for(_game, _picked())
	var problem := request.problem()
	if problem != "":
		_note = "Can't fight: " + problem
		_refresh()
		return
	GameSession.start_battle(request, SCENE)
	get_tree().change_scene_to_file(BATTLE_SCENE)


func _leave() -> void:
	GameSession.expedition = null
	SaveGame.save(_game)
	get_tree().change_scene_to_file(CITY_SCENE)


func _text(text: String, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_color_override("font_color", color)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_info.add_child(l)
	return l


func _button(text: String, action: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(320, 46)
	b.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	b.pressed.connect(action)
	_info.add_child(b)
	return b
