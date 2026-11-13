class_name Overview
extends Control
## Debug overview: one table per content kind (skills, monsters, grounds, zones, props), one row per Resource file under
## res://data (read through BattleContent), whatever its content status. Skills are shown as their
## card (gdd_skills §2: cost · where · strike · movement · on itself · creates ground / zone / prop,
## SkillGen.card); what a ground, zone or prop does stands in its own table. It
## decides and prices nothing; stat prices are open, so no point totals are shown.
## Click a column title to sort (again: reverse); the tooltip of a row holds its notes.
## "Skill builder" opens game/skill_builder.gd, which writes new skill files.

const MENU_SCENE := "res://game/menu.tscn"
const BUILDER_SCENE := "res://game/skill_builder.tscn"
## Per table: title, the row key the dropdown filters on with its label, and the columns as
## [row key, title, minimum width, expands, numeric].
const TABLES := {
	"skills": {
		"title": "Skills", "filter": "kind", "filter_all": "All kinds",
		"columns": [
			["name", "Skill", 190, false, false],
			["kind", "Kind", 100, false, false],
			["cost", "Cost", 110, false, false],
			["where", "Where", 200, false, false],
			["strike", "Strike", 130, false, false],
			["move", "Movement", 200, true, false],
			["self", "On itself", 170, true, false],
			["ground", "Creates ground", 140, false, false],
			["zone", "Creates zone", 140, false, false],
			["prop", "Creates prop", 130, false, false],
			["status", "Status", 100, false, false],
			["monsters", "Used by", 180, true, false],
			["id", "Id", 190, false, false],
		],
	},
	"monsters": {
		"title": "Monsters", "filter": "kin", "filter_all": "All kins",
		"columns": [
			["name", "Monster", 190, false, false],
			["kin", "Kin", 90, false, false],
			["strike", "Kin Strike", 110, false, false],
			["hp", "HP", 50, false, true],
			["initiative", "Init", 60, false, true],
			["move", "Move", 60, false, true],
			["tpr", "TPR", 50, false, true],
			["reach", "Reach", 65, false, true],
			["ap", "AP", 50, false, true],
			["kit", "Kit", 420, true, false],
			["status", "Status", 100, false, false],
			["id", "Id", 190, false, false],
		],
	},
	"grounds": {
		"title": "Grounds", "filter": "group", "filter_all": "All groups",
		"columns": [
			["name", "Ground", 190, false, false],
			["group", "Group", 100, false, false],
			["effect", "Effect (acts at a moment)", 360, true, false],
			["move_cost", "Move cost", 100, false, true],
			["levels", "Levels", 80, false, true],
			["lasts", "Lasts", 150, false, false],
			["sources", "Laid by", 360, true, false],
			["status", "Status", 100, false, false],
			["id", "Id", 160, false, false],
		],
	},
	"zones": {
		"title": "Zones", "filter": "group", "filter_all": "All zones",
		"columns": [
			["name", "Zone", 190, false, false],
			["effect", "Effect (while inside)", 420, true, false],
			["sources", "Left by", 420, true, false],
			["status", "Status", 100, false, false],
			["id", "Id", 160, false, false],
		],
	},
	"props": {
		"title": "Props", "filter": "class", "filter_all": "All classes",
		"columns": [
			["name", "Prop", 190, false, false],
			["class", "Class", 90, false, false],
			["hp", "HP", 50, false, true],
			["traits", "Traits", 170, false, false],
			["effect", "Effect", 420, true, false],
			["ground_left", "Leaves", 130, false, false],
			["sources", "Placed by", 260, true, false],
			["status", "Status", 100, false, false],
			["id", "Id", 160, false, false],
		],
	},
}

var _data := {}                 # table id → Array[Dictionary]
var _table := "skills"
var _tabs := {}                 # table id → Button
var _tree: Tree
var _count: Label
var _filter: OptionButton
var _game_only: CheckButton
var _sort_col := 0
var _sort_desc := false


## One Dictionary per skill, alphabetical by id. Text columns hold Strings; "ap" and "calc"
## hold numbers (-1 = none), "in_game" the ContentStatus filter result.
static func skill_rows(c: BattleContent) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for id in BattleContent.sorted_ids(c.skills):
		var s: BattleSkillDef = c.skills[id]
		var lines: PackedStringArray = []
		if s.kind == BattleSkillDef.STRIKE and StrikeShapes.has(StringName(s.strike_shape)):
			lines.append(StrikeShapes.shape_name(StringName(s.strike_shape)))
		for r in BattleText.skill_rows(c, s):
			lines.append(String(r[1]))
		var users: PackedStringArray = []
		for mid in BattleContent.sorted_ids(c.monsters):
			var m: MonsterDef = c.monsters[mid]
			if m.skills.has(s):
				users.append(m.display_name)
		var parts := SkillGen.card(c, s)
		out.append({
			"id": String(id),
			"name": s.display_name,
			"kind": s.kind_label(),
			"cost": parts["cost"],
			"where": parts["where"],
			"strike": parts["strike"],
			"move": parts["move"],
			"self": parts["self"],
			"ground": parts["ground"],
			"zone": parts["zone"],
			"prop": parts["prop"],
			"effect": BattleText.SEP.join(lines),
			"calc": s.internal_calc_cost,
			"status": s.content_status,
			"in_game": ContentStatus.in_game(s),
			"monsters": ", ".join(users),
			"tooltip": _notes([s.description, BattleText.SEP.join(lines), s.status]),
		})
	return out


## One Dictionary per monster, alphabetical by id: the reference stats of its MonsterDef
## (gdd_monsters §4.1) and its kit as skill names.
static func monster_rows(c: BattleContent) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for id in BattleContent.sorted_ids(c.monsters):
		var m: MonsterDef = c.monsters[id]
		out.append({
			"id": String(id),
			"name": m.display_name,
			"kin": MonsterDef.kin_name(m.kin),
			"strike": m.strike_name(),
			"hp": m.hp,
			"initiative": m.initiative,
			"move": m.move,
			"tpr": m.tpr,
			"reach": m.reach,
			"ap": m.ap,
			"kit": m.kit_text(),
			"status": m.content_status,
			"in_game": ContentStatus.in_game(m),
			"tooltip": _notes([m.blurb, m.notes]),
		})
	return out


## "5", "7.5", "—" for a negative (missing) number.
static func num_text(v: float) -> String:
	return "—" if v < 0 else String.num(v, 1).trim_suffix(".0")


## Names of the game's skills that create something: by ground id, zone id and prop id.
static func _makers(c: BattleContent) -> Dictionary:
	var out := {"ground": {}, "zone": {}, "prop": {}}
	for id in BattleContent.sorted_ids(c.skills):
		var s: BattleSkillDef = c.skills[id]
		if not ContentStatus.in_game(s):
			continue
		if s.zone != null:
			_note(out["zone"], s.zone.id, s.display_name)
		for op in s.board_ops:
			match op.op:
				BoardOp.GROUND:
					_note(out["ground"], op.ground, s.display_name)
				BoardOp.CREATE_ZONE:
					_note(out["zone"], op.zone, s.display_name)
				BoardOp.CREATE_PROP:
					_note(out["prop"], op.prop, s.display_name)
	for id in BattleContent.sorted_ids(c.props):
		var d: PropDef = c.props[id]
		if d.ground_left != &"" and d.ground_left != GroundDef.PLAIN:
			_note(out["ground"], d.ground_left, "prop " + d.display_name)
	return out


static func _note(table: Dictionary, key: StringName, label: String) -> void:
	if not table.has(key):
		table[key] = PackedStringArray()
	if not table[key].has(label):
		table[key].append(label)


## One Dictionary per ground file, alphabetical by id.
static func ground_rows(c: BattleContent) -> Array[Dictionary]:
	var makers: Dictionary = _makers(c)["ground"]
	var out: Array[Dictionary] = []
	for id in BattleContent.sorted_ids(c.grounds):
		var g: GroundDef = c.grounds[id]
		var lasts := "always" if g.immutable else ("board start: stays · laid in battle: %d rounds" % BattleExperiment.ground_rounds if BattleExperiment.ground_rounds > 0 else "until changed")
		if id == GroundDef.PLAIN:
			lasts = "—"
		var brief := BattleText.ground_brief(g, g.max_level)
		out.append({
			"id": String(id), "name": g.display_name, "group": g.group,
			"effect": brief if brief != "" else "—",
			"move_cost": g.move_cost, "levels": g.max_level, "lasts": lasts,
			"sources": ", ".join(makers.get(id, PackedStringArray())),
			"status": g.content_status, "in_game": ContentStatus.in_game(g), "tooltip": _notes([g.description]),
		})
	return out


## One Dictionary per zone file, alphabetical by id.
static func zone_rows(c: BattleContent) -> Array[Dictionary]:
	var makers: Dictionary = _makers(c)["zone"]
	var out: Array[Dictionary] = []
	for id in BattleContent.sorted_ids(c.zones):
		var z: BattleZoneDef = c.zones[id]
		out.append({
			"id": String(id), "name": z.display_name, "group": "zone",
			"effect": BattleText.effects_text(z.effects),
			"sources": ", ".join(makers.get(id, PackedStringArray())),
			"status": z.content_status, "in_game": ContentStatus.in_game(z), "tooltip": BattleText.effects_text(z.effects),
		})
	return out


## One Dictionary per prop file, alphabetical by id.
static func prop_rows(c: BattleContent) -> Array[Dictionary]:
	var makers: Dictionary = _makers(c)["prop"]
	var out: Array[Dictionary] = []
	for id in BattleContent.sorted_ids(c.props):
		var d: PropDef = c.props[id]
		var traits: PackedStringArray = []
		if d.heavy:
			traits.append("heavy")
		if d.spiky:
			traits.append("spiky")
		if d.repel:
			traits.append("repels")
		if not d.creatable_by_skill:
			traits.append("board only")
		var left := c.ground(d.ground_left)
		var brief := BattleText.prop_brief(c, d)
		out.append({
			"id": String(id), "name": d.display_name, "class": d.prop_class, "hp": d.hp,
			"traits": ", ".join(traits),
			"effect": brief if brief != "" else "blocks the way",
			"ground_left": left.display_name if left != null else "—",
			"sources": ", ".join(makers.get(id, PackedStringArray())),
			"status": d.content_status, "in_game": ContentStatus.in_game(d), "tooltip": _notes([d.description, brief]),
		})
	return out


static func _notes(parts: Array) -> String:
	var lines: PackedStringArray = []
	for p: String in parts:
		if p.strip_edges() != "":
			lines.append(p.strip_edges())
	return "\n".join(lines)


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = UiTheme.create()
	var content := BattleContent.shared()
	_data = {"skills": skill_rows(content), "monsters": monster_rows(content), "grounds": ground_rows(content),
		"zones": zone_rows(content), "props": prop_rows(content)}

	var bg := ColorRect.new()
	bg.color = Color(0.075, 0.082, 0.094)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 24)
	add_child(margin)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	margin.add_child(col)

	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation", 16)
	col.add_child(bar)
	var back := Button.new()
	back.text = "Back"
	back.pressed.connect(_back)
	bar.add_child(back)
	var title := Label.new()
	title.text = "OVERVIEW"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", UiTheme.ACCENT)
	bar.add_child(title)
	for id: String in TABLES:
		var tab := Button.new()
		tab.text = TABLES[id]["title"]
		tab.toggle_mode = true
		tab.custom_minimum_size = Vector2(100, 0)
		tab.pressed.connect(show_table.bind(id))
		bar.add_child(tab)
		_tabs[id] = tab
	_filter = OptionButton.new()
	_filter.custom_minimum_size = Vector2(160, 0)
	_filter.item_selected.connect(func(_i): _refresh())
	bar.add_child(_filter)
	_game_only = CheckButton.new()
	_game_only.text = "In game only (approved / draft / experiment)"
	_game_only.toggled.connect(func(_on): _refresh())
	bar.add_child(_game_only)
	var builder := Button.new()
	builder.text = "Skill builder"
	builder.pressed.connect(func(): get_tree().change_scene_to_file(BUILDER_SCENE))
	bar.add_child(builder)
	var monsters := Button.new()
	monsters.text = "Monster builder"
	monsters.pressed.connect(func():
		MonsterBuilder.return_scene = "res://game/overview.tscn"
		get_tree().change_scene_to_file(MonsterBuilder.SCENE))
	bar.add_child(monsters)
	_count = Label.new()
	_count.add_theme_color_override("font_color", UiTheme.DIM)
	bar.add_child(_count)

	_tree = Table.new()
	_tree.column_titles_visible = true
	_tree.hide_root = true
	_tree.select_mode = Tree.SELECT_ROW
	_tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_tree.column_title_clicked.connect(_on_title_clicked)
	col.add_child(_tree)

	var hint := Label.new()
	hint.text = "One row per Resource file under res://data. Click a column title to sort; hover a row for its notes. A skill only delivers: it strikes, moves or acts on its user and creates ground, a zone or a prop; what those do and when stands in their own tables. Monster stats = the species' reference sheet; stat prices are open, so no point totals. Grounds act at a moment, zones while a monster stands inside; props block the way and act when destroyed. Greyed rows are not in the game (status test, simulation or archived)."
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART     # without it the long line widens the whole screen
	hint.add_theme_color_override("font_color", UiTheme.DIM)
	hint.add_theme_font_size_override("font_size", 14)
	col.add_child(hint)
	show_table(_table)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_back()


func _back() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)


func _columns() -> Array:
	return TABLES[_table]["columns"]


## Switches to a table: its columns, its filter values (the ones that occur), sorted by name.
func show_table(id: String) -> void:
	_table = id
	for t: String in _tabs:
		_tabs[t].button_pressed = t == id
	_sort_col = 0
	_sort_desc = false
	var values := {}
	for r: Dictionary in _data[id]:
		values[r[TABLES[id]["filter"]]] = true
	var options := values.keys()
	options.sort()
	_filter.clear()
	_filter.add_item(TABLES[id]["filter_all"])
	for v: String in options:
		_filter.add_item(v)
	var cols := _columns()
	_tree.clear()
	_tree.columns = cols.size()
	for i in cols.size():
		_tree.set_column_custom_minimum_width(i, cols[i][2])
		_tree.set_column_expand(i, cols[i][3])
		_tree.set_column_clip_content(i, true)
		_tree.set_column_title_alignment(i, HORIZONTAL_ALIGNMENT_LEFT)
	_refresh()


func _on_title_clicked(column: int, _button: int) -> void:
	_sort_desc = not _sort_desc if column == _sort_col else false
	_sort_col = column
	_refresh()


## The rows of the current table that pass the filters, in the current sort order (ties: by id).
func visible_rows() -> Array[Dictionary]:
	var filter_key: String = TABLES[_table]["filter"]
	var wanted := "" if _filter.selected <= 0 else _filter.get_item_text(_filter.selected)
	var out: Array[Dictionary] = []
	for r: Dictionary in _data[_table]:
		if (wanted == "" or r[filter_key] == wanted) and (r["in_game"] or not _game_only.button_pressed):
			out.append(r)
	var key: String = _columns()[_sort_col][0]
	var numeric: bool = _columns()[_sort_col][4]
	out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var x = a[key] if numeric else String(a[key]).to_lower()
		var y = b[key] if numeric else String(b[key]).to_lower()
		if x == y:
			return a["id"] < b["id"]
		return x > y if _sort_desc else x < y)
	return out


func _refresh() -> void:
	var cols := _columns()
	for i in cols.size():
		var mark := "" if i != _sort_col else (" ▼" if _sort_desc else " ▲")
		_tree.set_column_title(i, cols[i][1] + mark)
	_tree.clear()
	var root := _tree.create_item()
	var shown := visible_rows()
	for r in shown:
		var item := _tree.create_item(root)
		for i in cols.size():
			var v = r[cols[i][0]]
			var text := String(v) if v is String else num_text(v)
			item.set_text(i, text)
			if cols[i][3]:                            # the wide text columns break long texts into lines
				item.set_autowrap_mode(i, TextServer.AUTOWRAP_WORD_SMART)
			var table: Array = r.get(cols[i][0] + "_table", [])
			if table.is_empty():
				item.set_tooltip_text(i, r["tooltip"] if r["tooltip"] != "" else text)
			else:
				# a cell with a "<key>_table" entry shows that table as its tooltip (Table below)
				item.set_metadata(i, table)
				item.set_tooltip_text(i, "\n".join(table.map(func(line: Array) -> String: return "  ".join(line))))
			if not r["in_game"]:
				item.set_custom_color(i, UiTheme.DIM)
	_count.text = "%d of %d %s" % [shown.size(), _data[_table].size(), String(TABLES[_table]["title"]).to_lower()]


## The Tree of the screen: a cell whose metadata holds table lines shows them as a small table
## instead of the plain text tooltip.
class Table extends Tree:
	func _make_custom_tooltip(_for_text: String) -> Object:
		var at := get_local_mouse_position()
		var item := get_item_at_position(at)
		var column := get_column_at_position(at)
		if item == null or column < 0 or not item.get_metadata(column) is Array:
			return null
		return Overview.table_tooltip(item.get_metadata(column))


## A grid of labels from table lines: first line = header, last line = total; numbers right-aligned.
static func table_tooltip(lines: Array) -> Control:
	var grid := GridContainer.new()
	grid.columns = lines[0].size()
	grid.add_theme_constant_override("h_separation", 22)
	grid.add_theme_constant_override("v_separation", 4)
	for n in lines.size():
		for i in grid.columns:
			var cell := Label.new()
			cell.text = lines[n][i]
			if i == 1 or i == grid.columns - 1:
				cell.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			if n == 0:
				cell.add_theme_color_override("font_color", UiTheme.DIM)
			elif n == lines.size() - 1:
				cell.add_theme_color_override("font_color", UiTheme.ACCENT)
			else:
				cell.add_theme_color_override("font_color", UiTheme.TEXT)
			grid.add_child(cell)
	return grid
