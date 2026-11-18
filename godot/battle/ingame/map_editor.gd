class_name MapEditor
extends Control
## Map editor of the ingame battle (docs/battle_ingame.md §3, docs/todo T46): make a battleground and save it as a
## MapDef under res://data/maps. A rectangle of a chosen width and height; single squares can be taken out, so the
## outline is free. On the squares: ground (a Dragon Vein is a ground), one prop, one zone with its direction and
## its rounds, and the start areas of both sides. The ingame prototype plays the saved maps. No rule.

const MENU_SCENE := "res://battle/ingame/ingame_prototype.tscn"
const CELL := 52
const TOOLS: Array[String] = ["Ground", "Dragon Vein", "Prop", "Zone", "Start area: you", "Start area: enemy",
	"Remove square", "Restore square", "Clear square"]
const DIRS := {"north": Vector2i(0, -1), "east": Vector2i(1, 0), "south": Vector2i(0, 1), "west": Vector2i(-1, 0)}
const ARROWS := {Vector2i(0, -1): "↑", Vector2i(1, 0): "→", Vector2i(0, 1): "↓", Vector2i(-1, 0): "←"}
const NEW := "— new map —"

var map := MapDef.new()
var _content: BattleContent
var _pick: OptionButton
var _name: LineEdit
var _width: SpinBox
var _height: SpinBox
var _tool: OptionButton
var _ground: OptionButton
var _prop: OptionButton
var _zone: OptionButton
var _dir: OptionButton
var _rounds: SpinBox
var _grid: GridContainer
var _message: Label
var _buttons := {}                   # Vector2i -> Button
var _loading := false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = UiTheme.create()
	_content = BattleContent.shared()
	var bg := ColorRect.new()
	bg.color = Color(0.075, 0.082, 0.094)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 28)
	add_child(margin)
	var split := HBoxContainer.new()
	split.add_theme_constant_override("separation", 28)
	margin.add_child(split)

	var form := VBoxContainer.new()
	form.custom_minimum_size = Vector2(330, 0)
	form.add_theme_constant_override("separation", 8)
	split.add_child(form)
	var title := Label.new()
	title.text = "MAP EDITOR"
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", UiTheme.ACCENT)
	form.add_child(title)
	_pick = OptionButton.new()
	_pick.item_selected.connect(func(_i: int): _load_picked())
	form.add_child(_row("Map", _pick))
	_name = LineEdit.new()
	_name.placeholder_text = "name of the map"
	form.add_child(_row("Name", _name))
	_width = _spin(MapDef.MIN_SIDE, MapDef.MAX_SIDE, map.width)
	form.add_child(_row("Width", _width))
	_height = _spin(MapDef.MIN_SIDE, MapDef.MAX_SIDE, map.height)
	form.add_child(_row("Height", _height))
	for sb: SpinBox in [_width, _height]:
		sb.value_changed.connect(func(_v: float): _resize())
	_tool = _options(TOOLS)
	form.add_child(_row("Tool", _tool))
	_ground = OptionButton.new()
	for id in BattleContent.sorted_ids(_content.grounds):
		var g: GroundDef = _content.grounds[id]
		if ContentStatus.in_game(g) and id != GroundDef.WELL:
			_ground.add_item(g.display_name)
			_ground.set_item_metadata(_ground.item_count - 1, id)
	form.add_child(_row("Ground", _ground))
	_prop = OptionButton.new()
	for id in BattleContent.sorted_ids(_content.props):
		var pd: PropDef = _content.props[id]
		if ContentStatus.in_game(pd):
			_prop.add_item(pd.display_name)
			_prop.set_item_metadata(_prop.item_count - 1, id)
	form.add_child(_row("Prop", _prop))
	_zone = OptionButton.new()
	for id in BattleContent.sorted_ids(_content.zones):
		var zd: BattleZoneDef = _content.zones[id]
		if ContentStatus.in_game(zd):
			_zone.add_item(zd.display_name)
			_zone.set_item_metadata(_zone.item_count - 1, id)
	form.add_child(_row("Zone", _zone))
	_dir = _options(DIRS.keys())
	_dir.tooltip_text = "The way a push zone pushes. A pull zone pulls toward the middle of all its squares."
	form.add_child(_row("Zone direction", _dir))
	_rounds = _spin(0, 20, 0)
	_rounds.tooltip_text = "How many rounds the zone lasts. 0 = the whole battle."
	form.add_child(_row("Zone rounds", _rounds))
	for box: OptionButton in [_ground, _prop, _zone]:
		box.item_selected.connect(_select_tool.bind(box))
	var hint := Label.new()
	hint.text = "Click or drag over the squares. Each square holds one ground, one prop and one zone."
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_color_override("font_color", UiTheme.DIM)
	hint.add_theme_font_size_override("font_size", 13)
	form.add_child(hint)
	_message = Label.new()
	_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_message.add_theme_font_size_override("font_size", 13)
	form.add_child(_message)
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	form.add_child(spacer)
	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 10)
	form.add_child(buttons)
	for pair: Array in [["Back", func(): get_tree().change_scene_to_file(MENU_SCENE)], ["Save", _save]]:
		var b := Button.new()
		b.text = pair[0]
		b.custom_minimum_size = Vector2(150, 44)
		b.pressed.connect(pair[1])
		buttons.add_child(b)

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.add_child(scroll)
	_grid = GridContainer.new()
	_grid.add_theme_constant_override("h_separation", 2)
	_grid.add_theme_constant_override("v_separation", 2)
	scroll.add_child(_grid)
	_fill_pick(&"")
	_build_grid()


func _row(label: String, field: Control) -> Control:
	var row := HBoxContainer.new()
	var l := Label.new()
	l.text = label
	l.custom_minimum_size = Vector2(120, 0)
	row.add_child(l)
	field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(field)
	return row


func _spin(low: int, high: int, value: int) -> SpinBox:
	var sb := SpinBox.new()
	sb.min_value = low
	sb.max_value = high
	sb.value = value
	return sb


func _options(items: Array) -> OptionButton:
	var ob := OptionButton.new()
	for item: String in items:
		ob.add_item(item)
	return ob


## Choosing a ground, prop or zone also chooses its tool.
func _select_tool(_index: int, box: OptionButton) -> void:
	_tool.select(TOOLS.find("Ground" if box == _ground else ("Prop" if box == _prop else "Zone")))


func _fill_pick(selected: StringName) -> void:
	_pick.clear()
	_pick.add_item(NEW)
	for id in MapDef.ids():
		_pick.add_item(String(id))
		if id == selected:
			_pick.select(_pick.item_count - 1)


func _load_picked() -> void:
	var text := _pick.get_item_text(_pick.selected)
	var loaded: MapDef = null if text == NEW else MapDef.load_map(StringName(text))
	map = loaded if loaded != null else MapDef.new()
	_loading = true
	_name.text = map.display_name
	_width.value = map.width
	_height.value = map.height
	_loading = false
	_build_grid()


func _resize() -> void:
	if _loading:
		return
	map.width = int(_width.value)
	map.height = int(_height.value)
	map.trim()
	_build_grid()


func _build_grid() -> void:
	for child in _grid.get_children():
		child.queue_free()
	_buttons.clear()
	_grid.columns = map.width
	for y in map.height:
		for x in map.width:
			var p := Vector2i(x, y)
			var b := Button.new()
			b.custom_minimum_size = Vector2(CELL, CELL)
			b.clip_text = true
			b.add_theme_font_size_override("font_size", 11)
			b.pressed.connect(_apply.bind(p))
			b.mouse_entered.connect(_drag.bind(p))
			_grid.add_child(b)
			_buttons[p] = b
	_show_all()


## Dragging with the select button held paints like a click.
func _drag(p: Vector2i) -> void:
	if Input.is_action_pressed(&"battle_select"):
		_apply(p)


## Applies the chosen tool to one square of the map.
func _apply(p: Vector2i) -> void:
	paint(map, TOOLS[_tool.selected], p, {
		"ground": _ground.get_selected_metadata(), "prop": _prop.get_selected_metadata(), "zone": _zone.get_selected_metadata(),
		"dir": DIRS[_dir.get_item_text(_dir.selected)], "rounds": int(_rounds.value)})
	_show(p)
	_status()


## One stroke of a tool on a map (also used by the tests): `with` names the chosen ground, prop, zone, dir, rounds.
static func paint(m: MapDef, tool: String, p: Vector2i, with: Dictionary = {}) -> void:
	if p.x < 0 or p.y < 0 or p.x >= m.width or p.y >= m.height:
		return
	if tool == "Restore square":
		m.missing.erase(p)
		return
	if tool == "Remove square":
		if not m.missing.has(p):
			m.missing.append(p)
		m.trim()
		return
	if not m.has_square(p):
		return
	match tool:
		"Ground":
			if with.get("ground", GroundDef.PLAIN) == GroundDef.PLAIN:
				m.grounds.erase(p)
			else:
				m.grounds[p] = with["ground"]
		"Dragon Vein":
			m.grounds[p] = GroundDef.WELL
		"Prop":
			m.props[p] = with.get("prop", &"")
		"Zone":
			m.zones[p] = {"zone": with.get("zone", &""), "dir": with.get("dir", Vector2i.ZERO), "rounds": int(with.get("rounds", 0))}
		"Start area: you", "Start area: enemy":
			var mine := m.start_a if tool == "Start area: you" else m.start_b
			var other := m.start_b if tool == "Start area: you" else m.start_a
			other.erase(p)
			if not mine.has(p):
				mine.append(p)
		"Clear square":
			m.grounds.erase(p)
			m.props.erase(p)
			m.zones.erase(p)
			m.start_a.erase(p)
			m.start_b.erase(p)


func _show_all() -> void:
	for p: Vector2i in _buttons:
		_show(p)
	_status()


## The look of one square: the colour of its ground, and short marks for what lies on it.
func _show(p: Vector2i) -> void:
	var b: Button = _buttons[p]
	var colour := Color(0.1, 0.1, 0.11)
	var lines: PackedStringArray = []
	var tip: PackedStringArray = ["%d, %d" % [p.x, p.y]]
	if map.has_square(p):
		var g := _content.ground(map.grounds.get(p, GroundDef.PLAIN))
		colour = g.color if g != null else Color(0.42, 0.44, 0.4)
		if g != null and g.id != GroundDef.PLAIN:
			tip.append(g.display_name)
			if g.id == GroundDef.WELL:
				lines.append("VEIN")
		if map.props.has(p):
			var pd := _content.prop(map.props[p])
			lines.append("■ " + (pd.display_name.left(5) if pd != null else "?"))
			tip.append("prop: " + (pd.display_name if pd != null else String(map.props[p])))
		if map.zones.has(p):
			var entry: Dictionary = map.zones[p]
			var zd := _content.zone(entry.get("zone", &""))
			var pushes := zd != null and zd.has_tag(FieldEffect.PUSH)
			lines.append("~ " + (ARROWS.get(entry.get("dir", Vector2i.ZERO), "") if pushes else "") + (zd.display_name.left(4) if zd != null else "?"))
			tip.append("zone: %s, %s" % [zd.display_name if zd != null else "?", "whole battle" if int(entry.get("rounds", 0)) == 0 else "%d rounds" % int(entry["rounds"])])
		if map.start_a.has(p):
			lines.append("YOU")
		if map.start_b.has(p):
			lines.append("ENEMY")
	else:
		tip.append("no square")
	var box := StyleBoxFlat.new()
	box.bg_color = colour
	box.set_corner_radius_all(3)
	if map.start_a.has(p) or map.start_b.has(p):
		box.set_border_width_all(3)
		box.border_color = Color(0.35, 0.65, 1.0) if map.start_a.has(p) else Color(1.0, 0.45, 0.4)
	for state in ["normal", "hover", "pressed", "focus"]:
		b.add_theme_stylebox_override(state, box)
	b.text = "\n".join(lines)
	b.tooltip_text = "\n".join(tip)


func _status() -> void:
	var problems := map.problems(_content)
	_message.add_theme_color_override("font_color", Color(0.85, 0.63, 0.3) if not problems.is_empty() else UiTheme.DIM)
	_message.text = "Not playable yet: " + "; ".join(problems) if not problems.is_empty() else \
		"Playable: up to %d of your monsters against up to %d." % [map.free_starts(_content, 0).size(), map.free_starts(_content, 1).size()]


func _save() -> void:
	map.display_name = _name.text.strip_edges()
	map.id = MapDef.slug(map.display_name)
	var why := map.save()
	if why != "":
		_message.text = why
		return
	_fill_pick(map.id)
	_status()
	_message.text = "Saved res://data/maps/%s.tres. %s" % [map.id, _message.text]
