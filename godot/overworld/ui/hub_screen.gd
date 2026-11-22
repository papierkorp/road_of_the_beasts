class_name HubScreen
extends Control
## The hub (docs/vision.md §6): one screen with the buildings; a tap opens a building and its actions. The head
## shows the day, the day AP, the stage and the lifespan. The hub also reads the result of a fight it sent into the
## battle scene (GameSession.fight) and saves the game whenever it is shown.

const MENU_SCENE := "res://game/menu.tscn"
const OVER_SCENE := "res://overworld/game_over.tscn"
## The buildings in the order of the screen: id -> the script of its panel.
const BUILDINGS := {}

var game: GameState
var _head: HBoxContainer
var _body: VBoxContainer
var _log: Label
var _panel: HubPanel = null
var _panel_id: StringName = &""
## A fight the player is preparing (team and loadout) and what starts it.
var _preparing: Fight = null
var _on_start: Callable


func _ready() -> void:
	game = GameSession.game
	if game == null:
		get_tree().change_scene_to_file.call_deferred(MENU_SCENE)
		return
	if GameSession.fight != null:
		Places.resolve(game, GameSession.fight, GameSession.last_result)
		GameSession.fight = null
	GameSession.take_battleground()
	SaveGame.save(game)
	if game.is_over():
		get_tree().change_scene_to_file.call_deferred(OVER_SCENE)
		return
	var margin := HubUi.page(self)
	var main := HubUi.col(14)
	margin.add_child(main)
	var head_panel := PanelContainer.new()
	main.add_child(head_panel)
	_head = HubUi.row(24)
	head_panel.add_child(_head)
	_body = HubUi.col(12)
	_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main.add_child(_body)
	_log = HubUi.dim("")
	main.add_child(_log)
	GameSession.state_changed.connect(refresh)
	_panel_id = GameSession.hub_panel if panels().has(GameSession.hub_panel) else &""
	refresh()


func panels() -> Dictionary:
	return {&"monsters": MonstersPanel, &"gates": GatesPanel, &"cultivation": CultivationPanel, &"workshop": WorkshopPanel,
		&"cauldron": CauldronPanel, &"forge": ForgePanel, &"inventory": InventoryPanel}


func _make_panel(id: StringName) -> HubPanel:
	var p: HubPanel = panels()[id].new()
	p.hub = self
	p.game = game
	p.id = id
	return p


## Opens a building (&"" = the hub itself), and one of its tabs when `tab` names one.
func open(id: StringName, tab: StringName = &"") -> void:
	if id != &"" and not panels().has(id):
		id = &""
	if tab != &"":
		GameSession.hub_tabs[id] = tab
	_panel_id = id
	_preparing = null
	GameSession.hub_panel = id
	refresh()


## Rebuilds the whole screen from the state.
func refresh() -> void:
	if game.is_over():
		SaveGame.save(game)
		get_tree().change_scene_to_file.call_deferred(OVER_SCENE)
		return
	_build_head()
	for c in _body.get_children():
		_body.remove_child(c)
		c.queue_free()
	if _preparing != null:
		_build_prepare()
	elif _panel_id == &"":
		_build_buildings()
	else:
		_panel = _make_panel(_panel_id)
		var top := HubUi.row()
		top.add_child(HubUi.button("← Hub", open.bind(&""), 140))
		top.add_child(HubUi.title(_panel.title()))
		_body.add_child(top)
		_panel.build(_body)
	var last: Array[String] = game.messages.slice(maxi(0, game.messages.size() - 3))
	_log.text = "\n".join(PackedStringArray(last))


func _build_head() -> void:
	for c in _head.get_children():
		_head.remove_child(c)
		c.queue_free()
	_head.add_child(HubUi.label("Year %d" % game.day, 22, UiTheme.TEXT, false))
	_head.add_child(HubUi.label("AP %d / %d" % [game.ap, game.max_ap()], 22, UiTheme.ACCENT, false))
	_head.add_child(HubUi.label(Stage.stage_name(game.stage), 22, UiTheme.TEXT, false))
	var left := "%d %s left to live" % [game.lifespan, "year" if game.lifespan == 1 else "years"] if not game.forced_trial else "Lifespan over: take the trial"
	_head.add_child(HubUi.label(left, 22, HubUi.WARN if game.lifespan <= 2 else UiTheme.TEXT, false))
	var system := CultivationDef.of(game.system)
	_head.add_child(HubUi.label(system.display_name if system != null else "", 18, UiTheme.DIM, false))
	var gap := Control.new()
	gap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_head.add_child(gap)
	var end := HubUi.primary("End year", _end_day, 160)
	end.disabled = not game.can_end_day()
	_head.add_child(end)
	_head.add_child(HubUi.button("Menu", func(): get_tree().change_scene_to_file(MENU_SCENE), 110))


func _build_buildings() -> void:
	if game.forced_trial:
		_body.add_child(HubUi.label("Your lifespan has run out. Only the void is open (Gates): take the breakthrough trial.", 22, HubUi.WARN))
	if not game.vow_offer.is_empty():
		_body.add_child(HubUi.button("A vow is offered: see it in the Cultivation Hall", open.bind(&"cultivation", &""), 620))
	var grid := GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 14)
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_body.add_child(grid)
	for id: StringName in panels():
		var p := _make_panel(id)
		var b := Button.new()
		b.custom_minimum_size = Vector2(0, 190)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.size_flags_vertical = Control.SIZE_EXPAND_FILL
		b.disabled = game.forced_trial and id != &"gates" and id != &"inventory"
		b.pressed.connect(open.bind(id))
		grid.add_child(b)
		var inner := HubUi.col(6)
		inner.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 12)
		inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
		inner.alignment = BoxContainer.ALIGNMENT_CENTER
		b.add_child(inner)
		var sign := CenterContainer.new()
		sign.mouse_filter = Control.MOUSE_FILTER_IGNORE
		sign.add_child(UiTheme.icon_rect("building_%s" % id, 84, Color(UiTheme.INK, 0.35) if b.disabled else UiTheme.INK))
		inner.add_child(sign)
		for l: Label in [HubUi.title(p.title(), 28), HubUi.label(p.pillar(), 15, UiTheme.ACCENT), HubUi.label(p.hint(), 17, UiTheme.DIM)]:
			l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			l.mouse_filter = Control.MOUSE_FILTER_IGNORE
			inner.add_child(l)


func _end_day() -> void:
	if game.end_day():
		SaveGame.save(game)
	refresh()


# ---------- preparing a fight ----------

## Shows a fight before it starts: the battleground, the opponents, the team and the tamer slots. `on_start` pays
## for it (day AP) and returns false when the player cannot afford it.
func prepare(f: Fight, on_start: Callable) -> void:
	_preparing = f
	_on_start = on_start
	if not f.ref.has("capped"):                 # a vow may take a place of the team
		f.max_team = game.team_cap(f.max_team)
		f.ref["capped"] = true
	if f.team.is_empty():
		f.team = game.default_team(f.max_team)
	if f.tamer.is_empty():
		f.tamer = game.default_loadout()
	refresh()


func _build_prepare() -> void:
	var f := _preparing
	var top := HubUi.row()
	top.add_child(HubUi.button("← Back", func():
		_preparing = null
		refresh(), 140))
	top.add_child(HubUi.title(f.title))
	_body.add_child(top)
	var list := HubUi.scroll(_body)
	var place := HubUi.card(list)
	place.add_child(HubUi.fight_view(f, true, 26.0))
	place.add_child(HubUi.dim("Battleground: %s" % GameSession.map_summary(f)))
	if f.loot_text != "":
		place.add_child(HubUi.label("A win gives: %s" % f.loot_text))
	if f.wild:
		place.add_child(HubUi.dim("Wild monsters: they can be caught on Seal Ground."))
	var mine := HubUi.card(list)
	mine.add_child(HubUi.label("Your team: %d of at most %d" % [f.team.size(), f.max_team], 20, UiTheme.ACCENT))
	var team := HubUi.flow(10)
	mine.add_child(team)
	for m in game.roster:
		var on := f.team.has(m)
		var b := HubUi.tile(HubUi.sign("part_%d" % m.species().kin, on, 44), m.species().display_name, "%s\nKit: %s" % [m.stats_text(), m.kit_text()], HubUi.todo_text(m), on, func():
			if f.team.has(m):
				f.team.erase(m)
			else:
				f.team.append(m)
			refresh(), 500)
		b.custom_minimum_size.y = 132
		b.disabled = m.current_hp <= 0 or (not on and f.team.size() >= f.max_team)
		team.add_child(b)
	var slots := HubUi.card(list)
	slots.add_child(HubUi.label("Tamer slots: %d of %d filled — a tamer skill, a weapon or a pill each, once in the battle" % [f.tamer.size(), game.tamer_slots()], 20, UiTheme.ACCENT))
	var content := GameSession.battle_content()
	for id in game.tamer_skills:
		var def := content.tamer_skill(id)
		var b := Button.new()
		b.toggle_mode = true
		b.button_pressed = f.tamer.has(id)
		b.disabled = not f.tamer.has(id) and not _fits(f, id, "")
		b.text = "%s: %s" % [def.display_name, def.description] if def != null else String(id)
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.custom_minimum_size = Vector2(0, HubUi.TAP)
		b.toggled.connect(func(on: bool):
			if on and not f.tamer.has(id):
				f.tamer.append(id)
			elif not on:
				f.tamer.erase(id)
			refresh())
		slots.add_child(b)
	var why := game.team_problem(f.team)
	if why != "":
		_body.add_child(HubUi.label("Not yet: %s." % why, 20, HubUi.WARN))
	var items := Crafting.battle_items(game)
	for id: StringName in items:
		var def := content.tamer_skill(id)
		if def == null:
			continue
		var item: String = items[id]
		var b := Button.new()
		b.toggle_mode = true
		b.button_pressed = f.tamer.has(id)
		b.disabled = not f.tamer.has(id) and not _fits(f, id, item)
		var uses := Crafting.battle_uses(game, item)
		var flaw := Crafting.flaw_def(game.values, Materials.flaw(item))
		b.text = "%s ×%d — %s (%s%s)%s" % [Materials.display_name(item, game.values), game.count(item), def.description, def.source_text(),
			", %d uses" % uses if uses > 1 else "", " — flaw: %s" % flaw["text"] if not flaw.is_empty() else ""]
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.custom_minimum_size = Vector2(0, HubUi.TAP)
		b.toggled.connect(func(on: bool):
			if on and not f.tamer.has(id):
				f.tamer.append(id)
				f.tamer_items[id] = item
				if uses > 1:
					f.tamer_uses[id] = uses
			elif not on:
				f.tamer.erase(id)
				f.tamer_items.erase(id)
				f.tamer_uses.erase(id)
			refresh())
		slots.add_child(b)
	var go := HubUi.primary("Fight", _start_fight, 260)
	go.disabled = f.team.is_empty() or why != ""
	_body.add_child(go)


## Whether one more loadout entry fits the tamer slots.
func _fits(f: Fight, id: StringName, _item: String) -> bool:
	var loadout := f.tamer.duplicate()
	loadout.append(id)
	return game.loadout_fits(loadout)


func _start_fight() -> void:
	var f := _preparing
	if f == null or f.team.is_empty() or game.team_problem(f.team) != "" or not bool(_on_start.call(f)):
		refresh()
		return
	_preparing = null
	SaveGame.save(game)
	GameSession.start_fight(f)
