class_name ShapeEditor
extends AcceptDialog
## Arranging free shapes before the battle (gdd_skills §2, user decision 2026-11-15): a skill that creates
## ground, a zone or props at an anchor names only how many squares. Here the player lays them out:
## touching over an edge or a corner, the anchor square (marked) among them. In battle the shape is fixed and
## still turns in quarter turns; the opponent sees it on the skill card.
##
## Arrangements live in a dictionary {monster id: {kit slot: Array[Vector2i]}} the caller owns. Only a
## legal arrangement that differs from the default is stored.

const RADIUS := 3
const CELL := 26

var _store: Dictionary = {}


## Kit slots of a monster whose skill is a free shape of two or more squares.
static func free_slots(def: MonsterDef) -> Array[int]:
	var out: Array[int] = []
	for i in def.skills.size():
		var s: BattleSkillDef = def.skills[i]
		if s != null and s.is_placed() and s.is_free_shape() and s.footprint.size() >= 2:
			out.append(i)
	return out


## The arrangement stored for a skill, or its default.
static func arrangement(store: Dictionary, id: StringName, slot: int, s: BattleSkillDef) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	out.assign((store.get(id, {}) as Dictionary).get(slot, s.footprint))
	return out


## Stores `cells` for the skill if they are a legal arrangement; a default or illegal one clears the entry.
## Returns "" or why the cells are not legal.
static func store_arrangement(store: Dictionary, id: StringName, slot: int, s: BattleSkillDef, cells: Array[Vector2i]) -> String:
	var why := BattleShapes.arrangement_error(cells, s.footprint.size())
	var same := why == ""
	for c in s.footprint:
		same = same and cells.has(c)
	if why != "" or same:
		if store.has(id):
			(store[id] as Dictionary).erase(slot)
		return why
	if not store.has(id):
		store[id] = {}
	store[id][slot] = cells.duplicate()
	return ""


func setup(ids: Array[StringName], store: Dictionary) -> void:
	_store = store
	title = "Arrange shapes"
	ok_button_text = "Done"
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(760, 520)
	add_child(scroll)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 14)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(col)
	var hint := Label.new()
	hint.text = "A skill that creates ground, a zone or props at a distance names only its number of squares. Lay them out here: every square touches another over an edge or a corner, the marked anchor square among them. In battle the shape is fixed (R still turns it) and the opponent sees it on the skill card."
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.custom_minimum_size = Vector2(720, 0)
	col.add_child(hint)
	var any := false
	for id in ids:
		var def := BattleSetup.load_def(id)
		for slot in free_slots(def):
			col.add_child(_block(id, def, slot))
			any = true
	if not any:
		var none := Label.new()
		none.text = "No picked monster has a skill with a free shape of two or more squares."
		col.add_child(none)


func _block(id: StringName, def: MonsterDef, slot: int) -> Control:
	var s: BattleSkillDef = def.skills[slot]
	var cells := arrangement(_store, id, slot, s)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	var grid := GridContainer.new()
	grid.columns = RADIUS * 2 + 1
	grid.add_theme_constant_override("h_separation", 1)
	grid.add_theme_constant_override("v_separation", 1)
	row.add_child(grid)
	var side := VBoxContainer.new()
	row.add_child(side)
	var name_label := Label.new()
	name_label.text = "%s · %s (%d squares)" % [def.display_name, s.display_name, s.footprint.size()]
	side.add_child(name_label)
	var status := Label.new()
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.custom_minimum_size = Vector2(420, 0)
	side.add_child(status)
	var buttons := {}
	var refresh := func() -> void:
		var why := store_arrangement(_store, id, slot, s, cells)
		status.text = ("Not used yet: %s. The default stays until then." % why) if why != "" else "Arranged: %s" % BattleShapes.arrangement_text(cells)
		for p: Vector2i in buttons:
			(buttons[p] as Button).set_pressed_no_signal(cells.has(p))
	for y in range(-RADIUS, RADIUS + 1):
		for x in range(-RADIUS, RADIUS + 1):
			var p := Vector2i(x, y)
			var b := Button.new()
			b.toggle_mode = true
			b.custom_minimum_size = Vector2(CELL, CELL)
			b.text = "◆" if p == Vector2i.ZERO else ""
			b.tooltip_text = "the anchor square (always part of the shape)" if p == Vector2i.ZERO else ""
			b.toggled.connect(func(on: bool) -> void:
				if p == Vector2i.ZERO:
					on = true
				if on and not cells.has(p):
					cells.append(p)
				elif not on:
					cells.erase(p)
				refresh.call())
			grid.add_child(b)
			buttons[p] = b
	var reset := Button.new()
	reset.text = "Default"
	reset.pressed.connect(func() -> void:
		cells.assign(s.footprint)
		refresh.call())
	side.add_child(reset)
	refresh.call()
	return row
