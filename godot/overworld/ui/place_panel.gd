class_name PlacePanel
extends VBoxContainer
## What a place of the city offers, as a UI panel (inner world, teleport plaza, market, clan).
## Used by the city map and by the walkable districts; it owns no scene of its own.
## Decisions are free, execution costs: only entering a dungeon spends AP (gdd_overworld §7).

signal changed                      # the game changed (trade, pill, ...): refresh headers

const DUNGEON_SCENE := "res://overworld/dungeon.tscn"

const INFO := {
	&"inner": {"name": "Inner World", "built": true,
		"blurb": "Your spatial space: the monsters you hold, and later cultivation spots, plots and structures (§6.3)."},
	&"plaza": {"name": "Teleport Plaza", "built": true,
		"blurb": "Travel arrays lead to dungeon regions. Entering a dungeon costs 1 AP and includes its battles (§7)."},
	&"market": {"name": "Market District", "built": true,
		"blurb": "The Trader: sell dungeon loot, buy cultivation pills, and play the price swings — they drift every night (§8, §11)."},
	&"clan": {"name": "Clan Compound", "built": false,
		"blurb": "Clan meetings, favor and story events. Phase 2-3 (§8.2)."},
}

var _game: GameState
var _place: StringName = &""
var _note := ""
var _rng := RandomNumberGenerator.new()


static func place_name(id: StringName) -> String:
	return INFO[id]["name"] if INFO.has(id) else String(id)


static func is_built(id: StringName) -> bool:
	return INFO.has(id) and INFO[id]["built"]


func setup(game: GameState) -> void:
	_game = game
	_rng.randomize()
	add_theme_constant_override("separation", 10)


func show_place(id: StringName, note := "") -> void:
	_place = id
	_note = note
	refresh()


func say(note: String) -> void:
	_note = note
	refresh()


func refresh() -> void:
	for c in get_children():
		remove_child(c)
		c.queue_free()
	if _game == null or not INFO.has(_place):
		return
	if _note != "":
		_text(_note, UiTheme.TEXT)
	_text(String(INFO[_place]["name"]).to_upper(), UiTheme.ACCENT, 22)
	_text(INFO[_place]["blurb"], UiTheme.DIM)
	match _place:
		&"inner":
			_build_inner()
		&"plaza":
			_build_plaza()
		&"market":
			_build_market()
		_:
			_text("Not built yet.", UiTheme.DIM)


func _build_inner() -> void:
	_text("YOUR MONSTERS  (%d / %d held)" % [_game.monsters.size(), _game.capacity()], UiTheme.DIM)
	var pill := ItemCatalog.pill_id(int(_game.stage))
	_text("Cultivation pills in your bag: %d  (+%d XP each)" % [_game.item_count(pill), ItemCatalog.pill_xp(pill)], UiTheme.DIM)
	for m in _game.monsters:
		_text(m.sheet_text() + "\n" + m.progress_text(), UiTheme.TEXT)
		var give := _button("Give a cultivation pill", func(): _give_pill(pill, m))
		give.disabled = _game.item_count(pill) < 1 or not m.can_gain_xp()
		add_child(give)


func _build_plaza() -> void:
	if GameSession.expedition != null:
		add_child(_button("Return to the dungeon", _enter_dungeon))
	else:
		var go := _button("Enter a dungeon  (1 AP)", _start_dungeon)
		go.disabled = not _game.can_spend_ap(1)
		add_child(go)


func _build_market() -> void:
	var market := _game.market
	_text("SELL — your bag  (the Trader pays %d%% of today's value)" % roundi(Market.SELL_RATE * 100.0), UiTheme.DIM)
	var any := false
	for id in _game.bag_ids():
		if market.sell_price(id) <= 0:
			continue
		any = true
		var count := _game.item_count(id)
		add_child(_button("%s  ×%d  —  sell one for %d" % [ItemCatalog.display_name(id), count, market.sell_price(id)],
			func(): _trade(market.sell(_game, id))))
	if not any:
		_text("Nothing to sell. Dungeon battles drop materials.", UiTheme.DIM)
	_text("BUY — today's offers", UiTheme.DIM)
	var pill := ItemCatalog.pill_id(int(_game.stage))
	var pb := _button("%s  (+%d XP)  —  %d" % [ItemCatalog.display_name(pill), ItemCatalog.pill_xp(pill), market.buy_price(pill)],
		func(): _trade(market.buy(_game, pill)))
	pb.disabled = _game.money < market.buy_price(pill)
	add_child(pb)
	for id in market.stock:
		var bb := _button("%s  —  %d   (worth %d today)" % [ItemCatalog.display_name(id), market.buy_price(id), market.sell_price(id)],
			func(): _trade(market.buy(_game, id)))
		bb.disabled = _game.money < market.buy_price(id)
		add_child(bb)


func _give_pill(pill: String, m: MonsterInstance) -> void:
	var ups := _game.use_pill(pill, m)
	if ups < 0:
		return
	_note = "%s gains %d XP." % [m.species().display_name, ItemCatalog.pill_xp(pill)]
	if ups > 0:
		_note += " It reaches %s — its stats snap to the new values!" % Stage.sub_tier_name(m.sub_tier)
	SaveGame.save(_game)
	changed.emit()
	refresh()


func _trade(ok: bool) -> void:
	if ok:
		SaveGame.save(_game)
	changed.emit()
	refresh()


func _start_dungeon() -> void:
	if not _game.spend_ap(1):
		return
	GameSession.expedition = Expedition.generate(_game, _rng)
	_enter_dungeon()


func _enter_dungeon() -> void:
	get_tree().change_scene_to_file(DUNGEON_SCENE)


func _text(text: String, color: Color, size_px := 16) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size_px)
	l.add_theme_color_override("font_color", color)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(l)
	return l


func _button(text: String, action: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(300, 46)
	b.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	b.pressed.connect(action)
	return b
