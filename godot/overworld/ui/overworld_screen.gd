class_name OverworldScreen
extends Control
## Phase 1 hub (gdd_overworld §11): day, action points, money, your monsters and a dungeon run
## as a chain of battle nodes. Plain code-built UI like the draft screen; no art yet.
## Decisions are free, execution costs: only starting an expedition spends AP (§7).

const SCENE := "res://overworld/overworld.tscn"
const BATTLE_SCENE := "res://battle/battle.tscn"
const MENU_SCENE := "res://game/menu.tscn"

var _game: GameState
var _content: VBoxContainer
var _note := ""
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
		margin.add_theme_constant_override("margin_" + side, 40)
	add_child(margin)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	margin.add_child(scroll)
	_content = VBoxContainer.new()
	_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content.add_theme_constant_override("separation", 14)
	scroll.add_child(_content)

	_apply_battle_result()
	_refresh()


## Back from a battle of the running expedition: HP persists, victory pays, the chain advances.
func _apply_battle_result() -> void:
	var ex := GameSession.expedition
	var res := GameSession.last_result
	if ex == null or res == null:
		return
	GameSession.last_result = null
	var before := ex.index
	ex.apply_result(_game, res)
	if ex.finished and ex.victory:
		_note = "Expedition cleared! +%d spirit stones in total." % ex.money_earned
	elif ex.finished:
		_note = "Your team fell. The expedition ends — the night will heal you."
	elif ex.index > before:
		_note = "Victory! Node %d cleared." % ex.index


func _refresh() -> void:
	for c in _content.get_children():
		_content.remove_child(c)
		c.queue_free()
	_label(_header_text(), 28, UiTheme.ACCENT)
	if _note != "":
		_label(_note, 18, UiTheme.TEXT)
	_label("YOUR MONSTERS  (%d / %d held)" % [_game.monsters.size(), _game.capacity()], 16, UiTheme.DIM)
	for m in _game.monsters:
		_label(_monster_text(m), 16, UiTheme.TEXT)
	var ex := GameSession.expedition
	if ex != null:
		_build_expedition(ex)
	else:
		_build_hub_actions()


func _header_text() -> String:
	return "Day %d  ·  AP %d / %d  ·  %d spirit stones  ·  %s %s" % [_game.day, _game.ap, _game.max_ap,
		_game.money, Stage.stage_name(_game.stage), Stage.sub_tier_name(_game.sub_tier)]


func _monster_text(m: MonsterInstance) -> String:
	var def := m.species()
	return "%s — %s %s · %s\n    HP %d/%d   Init %.1f   Move %d   TPR %d   Reach %d   ·   XP %d" % [
		def.display_name, Aspect.NAMES[def.aspect], MonsterDef.kin_name(def.kin), StatShape.shape_name(m.shape),
		m.current_hp, m.max_hp(), float(m.stats["initiative"]), int(m.stats["move"]),
		int(m.stats["tpr"]), int(m.stats["reach"]), m.xp]


func _build_hub_actions() -> void:
	_label("DUNGEON & DAY", 16, UiTheme.DIM)
	var go := _button("Start expedition  (1 AP)", func(): _start_expedition())
	go.disabled = not _game.can_spend_ap(1)
	_content.add_child(go)
	_content.add_child(_button("End day  (night passes)", func(): _end_day()))
	_content.add_child(_button("Main menu", func(): _to_menu()))


func _build_expedition(ex: Expedition) -> void:
	_label("EXPEDITION — %d battles, HP carries over" % ex.nodes.size(), 16, UiTheme.DIM)
	for i in ex.nodes.size():
		var n: Dictionary = ex.nodes[i]
		var marker := "✓" if i < ex.index else ("►" if i == ex.index and not ex.finished else "·")
		var names: Array[String] = []
		for e: MonsterInstance in n["enemies"]:
			names.append("%s (%s)" % [e.species().display_name, StatShape.shape_name(e.shape)])
		_label("%s  %d. %s — %s   reward %d" % [marker, i + 1, n["mode"], ", ".join(PackedStringArray(names)), n["reward"]],
			16, UiTheme.TEXT if i >= ex.index else UiTheme.DIM)
	if not ex.finished:
		var fight := _button("Fight node %d" % (ex.index + 1), func(): _fight(ex))
		_content.add_child(fight)
	else:
		_content.add_child(_button("Return to the hub", func(): _finish_expedition()))


func _start_expedition() -> void:
	if not _game.spend_ap(1):
		return
	GameSession.expedition = Expedition.generate(_game, _rng)
	_note = "You step through the travel array."
	_refresh()


func _fight(ex: Expedition) -> void:
	var request := ex.request_for(_game)
	var problem := request.problem()
	if problem != "":
		_note = "Can't fight: " + problem
		_refresh()
		return
	GameSession.start_battle(request, SCENE)
	get_tree().change_scene_to_file(BATTLE_SCENE)


func _finish_expedition() -> void:
	GameSession.expedition = null
	_note = ""
	SaveGame.save(_game)
	_refresh()


func _end_day() -> void:
	var report := _game.end_day()
	_note = "The night passes. Day %d begins; %d monster(s) recovered." % [report["day"], report["healed"]]
	SaveGame.save(_game)
	_refresh()


func _to_menu() -> void:
	SaveGame.save(_game)
	get_tree().change_scene_to_file(MENU_SCENE)


func _label(text: String, size_px: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size_px)
	l.add_theme_color_override("font_color", color)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_content.add_child(l)
	return l


func _button(text: String, action: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(320, 46)
	b.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	b.pressed.connect(action)
	return b
