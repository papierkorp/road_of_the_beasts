class_name Overview
extends Control
## Debug overview: one table per content kind (skills, monsters), one row per record under
## res://data, whatever its content status. Reads the definitions and BattleText only; it
## decides and prices nothing.
## Click a column title to sort (again: reverse); the tooltip of a row holds its notes, the one
## of a monster's "Stat pts" cell a second table with how the points come about.

const MENU_SCENE := "res://game/menu.tscn"
const USAGE := {"repeatable": "", "once_per_round": "1/round", "once_per_battle": "1/battle"}
## Per table: title, the row key the dropdown filters on with its label, and the columns as
## [row key, title, minimum width, expands, numeric].
const TABLES := {
	"skills": {
		"title": "Skills", "filter": "kind", "filter_all": "All kinds",
		"columns": [
			["name", "Skill", 190, false, false],
			["kind", "Kind", 100, false, false],
			["ap", "AP", 50, false, true],
			["usage", "Use", 90, false, false],
			["effect", "Effect", 420, true, false],
			["calc", "Calc", 60, false, true],
			["status", "Status", 100, false, false],
			["monsters", "Used by", 260, true, false],
			["id", "Id", 190, false, false],
		],
	},
	"monsters": {
		"title": "Monsters", "filter": "kin", "filter_all": "All kins",
		"columns": [
			["name", "Monster", 190, false, false],
			["kin", "Kin", 90, false, false],
			["strike", "Kin Strike", 110, false, false],
			["shape", "Shape", 120, false, false],
			["hp", "HP", 50, false, true],
			["initiative", "Init", 60, false, true],
			["move", "Move", 60, false, true],
			["tpr", "TPR", 50, false, true],
			["reach", "Reach", 65, false, true],
			["ap", "AP", 50, false, true],
			["points", "Stat pts", 85, false, true],
			["kit", "Kit", 420, true, false],
			["status", "Status", 100, false, false],
			["id", "Id", 190, false, false],
		],
	},
}

## Absolute stat point costs per value (gdd_monsters §2.2, working draft).
const TPR_POINTS := {1: 3, 2: 8, 3: 15}
const AP_POINTS := {2: 6, 3: 9, 4: 14, 5: 21}

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
		out.append({
			"id": String(id),
			"name": s.display_name,
			"kind": s.kind_label(),
			"ap": s.cost() if s.is_active() else -1,
			"usage": USAGE.get(s.repetition, s.repetition) if s.is_active() else "",
			"effect": BattleText.SEP.join(lines),
			"calc": s.internal_calc_cost,
			"status": s.content_status,
			"in_game": ContentStatus.in_game(s),
			"monsters": ", ".join(users),
			"tooltip": _notes([s.description, s.status]),
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
			"shape": StatShape.shape_name(m.reference_shape as StatShape.Id) if m.reference_shape != StatShape.Id.NONE else "—",
			"hp": m.hp,
			"initiative": m.initiative,
			"move": m.move,
			"tpr": m.tpr,
			"reach": m.reach,
			"ap": m.ap,
			"points": stat_points(m.hp, m.initiative, m.move, m.reach, m.tpr, m.ap),
			"points_table": stat_table(m.hp, m.initiative, m.move, m.reach, m.tpr, m.ap),
			"kit": m.kit_text(),
			"status": m.content_status,
			"in_game": ContentStatus.in_game(m),
			"tooltip": _notes([m.blurb, m.notes]),
		})
	return out


## Absolute stat point total of a stat line by the working-draft prices of gdd_monsters §2.2
## (base 15 included; the Core Formation High reference budget is 31): HP, Initiative and
## Movement 1 per point, Reach 3 per point above 1, TPR and AP by their step tables.
## -1 if TPR or AP lies outside the priced steps. A display aid, not a rule or a check.
static func stat_points(hp: int, initiative: float, move: int, reach: int, tpr: int, ap: int) -> float:
	var total := 0.0
	for line in stat_breakdown(hp, initiative, move, reach, tpr, ap):
		if line[3] < 0:
			return -1.0
		total += line[3]
	return total


## How `stat_points` comes about: one line [stat, value, price rule, points] per stat
## (points -1 = this value has no price step).
static func stat_breakdown(hp: int, initiative: float, move: int, reach: int, tpr: int, ap: int) -> Array:
	return [
		["HP", hp, "1 per point", float(hp)],
		["Init", initiative, "1 per point", initiative],
		["Move", move, "1 per point", float(move)],
		["Reach", reach, "3 per point above 1", (reach - 1) * 3.0],
		["TPR", tpr, "steps 3 / 8 / 15", float(TPR_POINTS.get(tpr, -1))],
		["AP", ap, "from AP 2: 6 / 9 / 14 / 21", float(AP_POINTS.get(ap, -1))],
	]


## "5", "7.5", "—" for a negative (missing) number.
static func num_text(v: float) -> String:
	return "—" if v < 0 else String.num(v, 1).trim_suffix(".0")


## The breakdown as tooltip table lines [[cell, ...], ...] with a header and a total line.
static func stat_table(hp: int, initiative: float, move: int, reach: int, tpr: int, ap: int) -> Array:
	var out: Array = [["Stat", "Value", "Price (draft)", "Points"]]
	for line in stat_breakdown(hp, initiative, move, reach, tpr, ap):
		out.append([line[0], num_text(line[1]), line[2], num_text(line[3])])
	out.append(["Total", "", "base 15 included", num_text(stat_points(hp, initiative, move, reach, tpr, ap))])
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
	_data = {"skills": skill_rows(content), "monsters": monster_rows(content)}

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
		tab.custom_minimum_size = Vector2(120, 0)
		tab.pressed.connect(show_table.bind(id))
		bar.add_child(tab)
		_tabs[id] = tab
	_filter = OptionButton.new()
	_filter.custom_minimum_size = Vector2(160, 0)
	_filter.item_selected.connect(func(_i): _refresh())
	bar.add_child(_filter)
	_game_only = CheckButton.new()
	_game_only.text = "In game only (approved / draft)"
	_game_only.toggled.connect(func(_on): _refresh())
	bar.add_child(_game_only)
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
	hint.text = "Click a column title to sort. Hover a row for its notes. Calc = internal_calc_cost (authoring note, not a price). Monster stats = reference individual, Shape = the stat shape it was built with; hover Stat pts for the breakdown; Stat pts = gdd_monsters §2.2 draft prices (Core High budget 31)."
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
