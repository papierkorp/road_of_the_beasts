class_name StructurePanel
extends VBoxContainer
## The panels of the building system (gdd_overworld §6.4): what a placed structure does (assign a
## monster, plant, harvest) and the build menu (structures in the bag, blueprints, constructing).
## Placing and moving are free, constructing costs the materials and 1 AP (§7 "Build").

signal changed                          # the game state changed (AP, items, ...)
signal place_requested(structure: StringName)

var _game: GameState
var _uid := -1
var _build := false
var _placing: StringName = &""
var _rotated := false
var _note := ""


func setup(game: GameState) -> void:
	_game = game
	add_theme_constant_override("separation", 10)


func show_structure(uid: int, note := "") -> void:
	_build = false
	_uid = uid
	_note = note
	refresh()


func show_build(placing: StringName, rotated: bool, note := "") -> void:
	_build = true
	_placing = placing
	_rotated = rotated
	_note = note
	refresh()


func refresh() -> void:
	for c in get_children():
		remove_child(c)
		c.queue_free()
	if _game == null:
		return
	if _note != "":
		_text(_note, UiTheme.TEXT)
	if _build:
		_build_menu()
	else:
		_structure_view()


# ---------- a placed structure ----------

func _structure_view() -> void:
	var s := _game.structure(_uid)
	if s.is_empty():
		return
	var def := StructureCatalog.def(StringName(s["id"]))
	_text(def.display_name.to_upper(), UiTheme.ACCENT, 22)
	_text("%s · %s" % [StructureDef.category_name(def.category), Aspect.NAMES[def.aspect]], UiTheme.DIM)
	_text(def.blurb, UiTheme.DIM)
	for line in StructureRules.bonus_lines(_game, s):
		_text("• " + line, UiTheme.TEXT)
	match def.category:
		StructureDef.Category.CULTIVATION:
			_cultivation(s)
		StructureDef.Category.GROWING:
			_growing(s)
	if def.id == GameState.EVOLUTION_PILLAR:
		_evolution_view()
	elif def.id == &"refining_furnace":
		_furnace(s)
	elif def.id == &"pill_stall":
		_stall(s)


func _cultivation(s: Dictionary) -> void:
	var idx := int(s["assigned"])
	if idx >= 0 and idx < _game.monsters.size():
		var info := StructureRules.idle_xp(_game, s)
		_text("%s meditates here: +%d XP every night." % [_game.monsters[idx].species().display_name, int(info["xp"])], UiTheme.TEXT)
		add_child(_button("Send it away", func(): _assign(-1)))
	else:
		_text("Nobody meditates here yet.", UiTheme.DIM)
	_text("SEND A MONSTER", UiTheme.DIM)
	for i in _game.monsters.size():
		var m := _game.monsters[i]
		var b := _button("%s  (%s)" % [m.species().display_name, m.progress_text()], func(): _assign(i))
		b.disabled = i == idx or not m.can_gain_xp()
		add_child(b)


func _assign(idx: int) -> void:
	var s := _game.structure(_uid)
	if idx < 0:
		s["assigned"] = -1
	elif not _game.assign_monster(_uid, idx):
		return
	SaveGame.save(_game)
	changed.emit()
	refresh()


func _growing(s: Dictionary) -> void:
	var plant := String(s["plant"])
	if plant == "":
		_text("PLANT A MATERIAL  (one is used up, you harvest %d)" % StructureRules.HARVEST_YIELD, UiTheme.DIM)
		var any := false
		for id in _game.bag_ids():
			if ItemCatalog.kind_of(id) != ItemCatalog.Kind.MATERIAL:
				continue
			any = true
			add_child(_button("%s  ×%d" % [ItemCatalog.display_name(id), _game.item_count(id)], func(): _plant(id)))
		if not any:
			_text("You have no materials. Dungeon battles drop them.", UiTheme.DIM)
		return
	var need := StructureRules.grow_nights(_game, s)
	_text("Growing: %s — night %d of %d." % [ItemCatalog.display_name(plant), mini(int(s["grown"]), need), need], UiTheme.TEXT)
	if StructureRules.is_ready(_game, s):
		add_child(_button("Harvest  (+%d)" % StructureRules.HARVEST_YIELD, _harvest))


func _plant(id: String) -> void:
	if _game.plant(_uid, id):
		SaveGame.save(_game)
		changed.emit()
		refresh()


func _harvest() -> void:
	var id := _game.harvest(_uid)
	if id == "":
		return
	_note = "Harvested %d × %s." % [StructureRules.HARVEST_YIELD, ItemCatalog.display_name(id)]
	SaveGame.save(_game)
	changed.emit()
	refresh()


# ---------- production: furnace and stall (gdd_overworld §8 Producer) ----------

func _furnace(s: Dictionary) -> void:
	var uid := int(s["uid"])
	var order := StringName(s["order"])
	_text("STANDING ORDER — made every night from the materials in your bag (free)", UiTheme.DIM)
	_text("Now: %s" % (RecipeCatalog.recipe_name(order) if order != &"" else "nothing"), UiTheme.TEXT)
	for id in RecipeCatalog.ids():
		var yield_now := _game.batch_yield(s, id)
		_text("%s — %s → %d pill(s)%s" % [RecipeCatalog.recipe_name(id), RecipeCatalog.inputs_text(id), yield_now,
			"  (fine batch: a Qi Spring is next to it)" if yield_now > RecipeCatalog.batch_yield(id) else ""], UiTheme.TEXT)
		var ob := _button("Make %s every night" % RecipeCatalog.recipe_name(id), func(): _set_order(uid, id))
		ob.disabled = order == id
		add_child(ob)
		var wb := _button("Work now: one batch  (1 AP)", func(): _work(uid, id))
		wb.disabled = _game.ap < 1 or not _game.can_produce(uid, id)
		add_child(wb)
	if order != &"":
		add_child(_button("Clear the order", func(): _set_order(uid, &"")))


func _set_order(uid: int, id: StringName) -> void:
	if _game.set_order(uid, id):
		SaveGame.save(_game)
		changed.emit()
		refresh()


func _work(uid: int, id: StringName) -> void:
	var made := _game.work_furnace(uid, id)
	if made.is_empty():
		return
	_note = "You work the furnace: %d × %s." % [int(made["count"]), ItemCatalog.display_name(String(made["item"]))]
	SaveGame.save(_game)
	changed.emit()
	refresh()


func _stall(s: Dictionary) -> void:
	var uid := int(s["uid"])
	_text("Customers tonight: %d. Each buys the most valuable pill on the shelf." % _game.customers_per_night(s), UiTheme.TEXT)
	_text("TODAY'S PRICES", UiTheme.DIM)
	for id in ItemCatalog.pills_of_tier(int(_game.stage)):
		_text("%s — %d" % [ItemCatalog.display_name(id), _game.market.shop_price(id)], UiTheme.TEXT)
	_text("ON THE SHELF", UiTheme.DIM)
	var shelf: Dictionary = s["shelf"]
	if shelf.is_empty():
		_text("Empty.", UiTheme.DIM)
	for id in shelf:
		var item := String(id)
		add_child(_button("%s ×%d — take back" % [ItemCatalog.display_name(item), int(shelf[id])], func(): _shelve(uid, item, -int(shelf[item]))))
	_text("PUT ON THE SHELF", UiTheme.DIM)
	var any := false
	for id in _game.bag_ids():
		if ItemCatalog.kind_of(id) != ItemCatalog.Kind.PILL:
			continue
		any = true
		var item2 := id
		add_child(_button("%s ×%d — put all on the shelf" % [ItemCatalog.display_name(id), _game.item_count(id)],
			func(): _shelve(uid, item2, _game.item_count(item2))))
	if not any:
		_text("No pills in your bag. The Refining Furnace makes them.", UiTheme.DIM)


func _shelve(uid: int, item: String, n: int) -> void:
	if _game.stock_shelf(uid, item, n):
		SaveGame.save(_game)
		changed.emit()
		refresh()


# ---------- the Evolution Pillar (gdd_overworld §4.7) ----------

func _evolution_view() -> void:
	_text("Slot development is not built yet: the old skill evolution was removed with the legacy skill model, "
		+ "and the slot development of the GDD (Skills §6) still needs its rules (temp_todo T05).", UiTheme.DIM)


# ---------- the build menu ----------

func _build_menu() -> void:
	_text("BUILD MODE", UiTheme.ACCENT, 22)
	_text("Left click: place · Right click: pick up · R: rotate · B: leave. Placing and moving are free; constructing costs materials and 1 AP.", UiTheme.DIM)
	var region := BuildGrid.region(_game.stage)
	_text("Buildable area at %s: %d × %d cells — it grows with your stage." % [Stage.stage_name(_game.stage), region.size.x, region.size.y], UiTheme.DIM)
	if _placing != &"":
		_text("Placing: %s%s" % [StructureCatalog.def(_placing).display_name, "  (rotated)" if _rotated else ""], UiTheme.TEXT)
		add_child(_button("Stop placing", func(): place_requested.emit(&"")))
	_text("IN YOUR BAG — ready to place", UiTheme.DIM)
	var any := false
	for id in _game.bag_ids():
		if ItemCatalog.kind_of(id) != ItemCatalog.Kind.STRUCTURE:
			continue
		any = true
		var sid := ItemCatalog.structure_of(id)
		var def := StructureCatalog.def(sid)
		add_child(_button("Place: %s  ×%d  (%d×%d cells)" % [def.display_name, _game.item_count(id), def.size.x, def.size.y],
			func(): place_requested.emit(sid)))
	if not any:
		_text("Nothing waiting. Construct something below.", UiTheme.DIM)
	_text("BLUEPRINTS — AP %d / %d" % [_game.ap, _game.max_ap], UiTheme.DIM)
	var known := false
	for id in _game.bag_ids():
		if ItemCatalog.kind_of(id) != ItemCatalog.Kind.BLUEPRINT:
			continue
		known = true
		var sid2 := ItemCatalog.structure_of(id)
		var def2 := StructureCatalog.def(sid2)
		_text("%s — needs %s" % [def2.display_name, def2.recipe_text()], UiTheme.TEXT)
		var need := _game.missing_license(sid2)
		if need != &"":
			var lic: Dictionary = FactionCatalog.LICENSES[need]
			_text("Needs the %s (%s, %d favor) — buy it at their envoy." % [lic["name"], FactionCatalog.faction_name(lic["faction"]), int(lic["cost"])], UiTheme.DIM)
		var b := _button("Construct %s  (1 AP)" % def2.display_name, func(): _construct(sid2))
		b.disabled = not _game.can_construct(sid2)
		add_child(b)
	if not known:
		_text("No blueprints yet. Clear a dungeon: its boss drops one. The Trader sometimes sells ready-made structures.", UiTheme.DIM)


func _construct(sid: StringName) -> void:
	if not _game.construct(sid):
		return
	_note = "Built the %s — it waits in your bag." % StructureCatalog.def(sid).display_name
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
