class_name FavorPanel
extends VBoxContainer
## The factions' side of the city (gdd_overworld §8.2): standing and favor, the requests to fill,
## licenses, the guild's perks and the beasts for hire. One faction (an envoy) or all (the notice board).

signal changed

var _game: GameState
var _faction: StringName = &""
var _note := ""


func setup(game: GameState) -> void:
	_game = game
	add_theme_constant_override("separation", 10)


## `faction` = a faction id, or &"all" for the notice board.
func show_faction(faction: StringName, note := "") -> void:
	_faction = faction
	_note = note
	refresh()


func refresh() -> void:
	for c in get_children():
		remove_child(c)
		c.queue_free()
	if _game == null or _faction == &"":
		return
	if _note != "":
		_text(_note, UiTheme.TEXT)
	if _faction == &"all":
		for f in FactionCatalog.ids():
			_block(f)
	else:
		_block(_faction)


func _block(f: StringName) -> void:
	_text(FactionCatalog.faction_name(f).to_upper(), UiTheme.ACCENT, 22)
	if _faction != &"all":
		_text("%s speaks for them." % FactionCatalog.envoy_name(f), UiTheme.DIM)
	_text(FactionCatalog.blurb(f), UiTheme.DIM)
	var standing := _game.standing_of(f)
	var rank := _game.rank_of(f)
	var next := FactionCatalog.to_next_rank(standing)
	_text("Rank: %s  ·  favor to spend: %d  ·  earned in total: %d%s" % [FactionCatalog.rank_name(rank), _game.favor_of(f),
		standing, ("  (next rank in %d)" % next) if next > 0 else ""], UiTheme.TEXT)
	_perks(f, rank)
	_text("REQUESTS", UiTheme.DIM)
	var any := false
	for q in _game.quests:
		if StringName(q["faction"]) != f:
			continue
		any = true
		var uid := int(q["uid"])
		_text(QuestBoard.text(q), UiTheme.TEXT)
		var b := _button("Deliver  (you have %d)" % _game.item_count(String(q["item"])), func(): _deliver(uid))
		b.disabled = not _game.can_deliver(uid)
		add_child(b)
	if not any:
		_text("No requests right now — new ones appear every night.", UiTheme.DIM)
	_licenses(f)
	_recruits(f)


func _perks(f: StringName, rank: int) -> void:
	if f != FactionCatalog.GUILD:
		return
	var d := _game.market.discount()
	_text("Trader discount: %d%%.  %s" % [roundi(d * 100.0), "Rare blueprint at the Trader today: %s."
		% StructureCatalog.def(_game.market.blueprint_offer).display_name if _game.market.blueprint_offer != &""
		else ("The Trader offers rare blueprints from rank 2 — and the offer changes by the night." if rank >= 2
		else "At rank 2 the Trader offers rare blueprints.")], UiTheme.TEXT)


func _licenses(f: StringName) -> void:
	for id in FactionCatalog.LICENSES:
		var lic: Dictionary = FactionCatalog.LICENSES[id]
		if StringName(lic["faction"]) != f:
			continue
		if _game.has_license(id):
			_text("✓ %s" % lic["name"], UiTheme.TEXT)
		else:
			var b := _button("Buy the %s — %d favor" % [lic["name"], int(lic["cost"])], func(): _buy_license(id))
			b.disabled = _game.favor_of(f) < int(lic["cost"])
			add_child(b)


func _recruits(f: StringName) -> void:
	for i in _game.recruits.size():
		var r: Dictionary = _game.recruits[i]
		if StringName(r["faction"]) != f:
			continue
		_text("FOR HIRE — %d favor" % int(r["cost"]), UiTheme.DIM)
		_text((r["monster"] as MonsterInstance).sheet_text(), UiTheme.TEXT)
		var b := _button("Recruit", func(): _recruit(i))
		b.disabled = not _game.can_recruit(i)
		add_child(b)
		if _game.monsters.size() >= _game.capacity():
			_text("Your spatial space is full (it holds %d). A breakthrough makes room." % _game.capacity(), UiTheme.DIM)


func _deliver(uid: int) -> void:
	var q := _game.quest(uid)
	if q.is_empty():
		return
	var favor := int(q["favor"])
	var money := int(q["money"])
	if not _game.deliver_quest(uid):
		return
	_note = "Delivered. +%d favor%s." % [favor, (", +%d spirit stones" % money) if money > 0 else ""]
	SaveGame.save(_game)
	changed.emit()
	refresh()


func _buy_license(id: StringName) -> void:
	if not _game.buy_license(id):
		return
	_note = "You now hold the %s." % FactionCatalog.LICENSES[id]["name"]
	SaveGame.save(_game)
	changed.emit()
	refresh()


func _recruit(i: int) -> void:
	var who := (_game.recruits[i]["monster"] as MonsterInstance).species().display_name
	if not _game.recruit(i):
		return
	_note = "%s joins you!" % who
	SaveGame.save(_game)
	changed.emit()
	refresh()


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
	b.custom_minimum_size = Vector2(300, 42)
	b.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	b.pressed.connect(action)
	return b
