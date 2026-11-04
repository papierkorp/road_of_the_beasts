class_name WorldMapScreen
extends Control
## The city as a map of places (gdd_overworld §6.1, §11 "node-based map v1").
## Click a place to see what it offers; the Inner World (monsters, cultivation pills), the Teleport
## Plaza (dungeon) and the Market (Trader) are built so far. Decisions are free, execution costs: only entering a dungeon spends AP (§7).

const SCENE := "res://overworld/overworld.tscn"
const DUNGEON_SCENE := "res://overworld/dungeon.tscn"
const MENU_SCENE := "res://game/menu.tscn"
const MAP_SIZE := Vector2(760, 440)
const PLACE_SIZE := Vector2(190, 64)

## pos = centre on the map. `built` places are usable, the others only announce what comes.
const PLACES := [
	{"id": &"inner", "name": "Inner World", "pos": Vector2(150, 300), "built": true,
		"blurb": "Your spatial space: the monsters you hold, and later cultivation spots, plots and structures (§6.3)."},
	{"id": &"plaza", "name": "Teleport Plaza", "pos": Vector2(380, 120), "built": true,
		"blurb": "Travel arrays lead to dungeon regions. Entering a dungeon costs 1 AP and includes its battles (§7)."},
	{"id": &"market", "name": "Market District", "pos": Vector2(610, 300), "built": true,
		"blurb": "The Trader: sell dungeon loot, buy cultivation pills, and play the price swings — they drift every night (§8, §11)."},
	{"id": &"clan", "name": "Clan Compound", "pos": Vector2(380, 380), "built": false,
		"blurb": "Clan meetings, favor and story events. Phase 2-3 (§8.2)."},
]

var _game: GameState
var _map: Control
var _header: Label
var _detail: VBoxContainer
var _selected: StringName = &"plaza"
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
		var b := Button.new()
		b.text = String(p["name"]) + ("" if p["built"] else "  (soon)")
		b.size = PLACE_SIZE
		b.custom_minimum_size = PLACE_SIZE
		b.position = p["pos"] - PLACE_SIZE / 2.0
		var id: StringName = p["id"]
		b.pressed.connect(func(): _select(id))
		_map.add_child(b)
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	row.add_child(scroll)
	_detail = VBoxContainer.new()
	_detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail.add_theme_constant_override("separation", 10)
	scroll.add_child(_detail)

	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation", 12)
	col.add_child(bar)
	bar.add_child(_button("End day  (night passes)", _end_day))
	bar.add_child(_button("Save and quit to menu", _to_menu))
	GameSession.state_changed.connect(_refresh)
	_refresh()


func _draw_map() -> void:
	var plaza: Dictionary = _place(&"plaza")
	for p in PLACES:
		if p["id"] != &"plaza":
			_map.draw_line(plaza["pos"], p["pos"], Color(UiTheme.DIM.r, UiTheme.DIM.g, UiTheme.DIM.b, 0.5), 2.0)


func _place(id: StringName) -> Dictionary:
	for p in PLACES:
		if p["id"] == id:
			return p
	return {}


func _select(id: StringName) -> void:
	_selected = id
	_refresh()


func _refresh() -> void:
	_header.text = "Day %d  ·  AP %d / %d  ·  %d spirit stones  ·  %s %s" % [_game.day, _game.ap, _game.max_ap,
		_game.money, Stage.stage_name(_game.stage), Stage.sub_tier_name(_game.sub_tier)]
	for c in _detail.get_children():
		_detail.remove_child(c)
		c.queue_free()
	if _note != "":
		_text(_note, UiTheme.TEXT)
	var p := _place(_selected)
	_text(String(p["name"]).to_upper(), UiTheme.ACCENT, 22)
	_text(p["blurb"], UiTheme.DIM)
	match _selected:
		&"inner":
			_text("YOUR MONSTERS  (%d / %d held)" % [_game.monsters.size(), _game.capacity()], UiTheme.DIM)
			var pill := ItemCatalog.pill_id(int(_game.stage))
			_text("Cultivation pills in your bag: %d  (+%d XP each)" % [_game.item_count(pill), ItemCatalog.pill_xp(pill)], UiTheme.DIM)
			for m in _game.monsters:
				_text(m.sheet_text() + "\n" + m.progress_text(), UiTheme.TEXT)
				var give := _button("Give a cultivation pill", func(): _give_pill(pill, m))
				give.disabled = _game.item_count(pill) < 1 or not m.can_gain_xp()
				_detail.add_child(give)
		&"market":
			_build_market()
		&"plaza":
			if GameSession.expedition != null:
				_detail.add_child(_button("Return to the dungeon", _enter_dungeon))
			else:
				var go := _button("Enter a dungeon  (1 AP)", _start_dungeon)
				go.disabled = not _game.can_spend_ap(1)
				_detail.add_child(go)
		_:
			_text("Not built yet.", UiTheme.DIM)


func _give_pill(pill: String, m: MonsterInstance) -> void:
	var ups := _game.use_pill(pill, m)
	if ups < 0:
		return
	_note = "%s gains %d XP." % [m.species().display_name, ItemCatalog.pill_xp(pill)]
	if ups > 0:
		_note += " It reaches %s — its stats snap to the new values!" % Stage.sub_tier_name(m.sub_tier)
	SaveGame.save(_game)
	_refresh()


func _build_market() -> void:
	var market := _game.market
	_text("SELL — your bag  (the Trader pays %d%% of today's value)" % roundi(Market.SELL_RATE * 100.0), UiTheme.DIM)
	var any := false
	for id in _game.bag_ids():
		if market.sell_price(id) <= 0:
			continue
		any = true
		var count := _game.item_count(id)
		var b := _button("%s  ×%d  —  sell one for %d" % [ItemCatalog.display_name(id), count, market.sell_price(id)],
			func(): _trade(market.sell(_game, id)))
		_detail.add_child(b)
	if not any:
		_text("Nothing to sell. Dungeon battles drop materials.", UiTheme.DIM)
	_text("BUY — today's offers", UiTheme.DIM)
	var pill := ItemCatalog.pill_id(int(_game.stage))
	var pb := _button("%s  (+%d XP)  —  %d" % [ItemCatalog.display_name(pill), ItemCatalog.pill_xp(pill), market.buy_price(pill)],
		func(): _trade(market.buy(_game, pill)))
	pb.disabled = _game.money < market.buy_price(pill)
	_detail.add_child(pb)
	for id in market.stock:
		var bb := _button("%s  —  %d   (worth %d today)" % [ItemCatalog.display_name(id), market.buy_price(id), market.sell_price(id)],
			func(): _trade(market.buy(_game, id)))
		bb.disabled = _game.money < market.buy_price(id)
		_detail.add_child(bb)


func _trade(ok: bool) -> void:
	if ok:
		SaveGame.save(_game)
	_refresh()


func _start_dungeon() -> void:
	if not _game.spend_ap(1):
		return
	GameSession.expedition = Expedition.generate(_game, _rng)
	_enter_dungeon()


func _enter_dungeon() -> void:
	get_tree().change_scene_to_file(DUNGEON_SCENE)


func _end_day() -> void:
	if GameSession.expedition != null:
		_note = "Finish or leave the dungeon first."
		_refresh()
		return
	var report := _game.end_day(_rng)
	_note = "The night passes. Day %d begins; %d monster(s) recovered." % [report["day"], report["healed"]]
	SaveGame.save(_game)
	_refresh()


func _to_menu() -> void:
	if GameSession.expedition == null:
		SaveGame.save(_game)
	get_tree().change_scene_to_file(MENU_SCENE)


func _text(text: String, color: Color, size_px := 16) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size_px)
	l.add_theme_color_override("font_color", color)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail.add_child(l)
	return l


func _button(text: String, action: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(300, 46)
	b.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	b.pressed.connect(action)
	return b
