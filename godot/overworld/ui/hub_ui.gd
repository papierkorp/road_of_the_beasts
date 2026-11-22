class_name HubUi
extends RefCounted
## Small builders for the screens of the hub game. Sizes are chosen for a finger as well as a mouse: no control is
## lower than TAP, and nothing is shown only on hover.

const TAP := 60
const BG := UiTheme.BG
const WARN := UiTheme.WARN
const GOOD := UiTheme.GOOD


static func theme() -> Theme:
	var t := UiTheme.create()
	t.default_font_size = 20
	t.set_font_size("font_size", "Button", 20)
	return t


## Fills a screen with the background and returns a margin container to build in.
static func page(root: Control) -> MarginContainer:
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.theme = theme()
	root.add_child(UiTheme.paper_rect())
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 24)
	root.add_child(margin)
	return margin


static func label(text: String, size := 20, color := UiTheme.TEXT, wrap := true) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	if wrap:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return l


## A title in the brush font.
static func title(text: String, size := 34) -> Label:
	var l := label(text, size, UiTheme.TEXT, false)
	if UiTheme.title_font() != null:
		l.add_theme_font_override("font", UiTheme.title_font())
	return l


static func dim(text: String) -> Label:
	return label(text, 18, UiTheme.DIM)


static func button(text: String, action: Callable, width := 220) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(width, TAP)
	if width > 0:
		b.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN      # a button is as wide as it says, not as wide as its column
	b.pressed.connect(action)
	return b


## The button of the one action a screen is about.
static func primary(text: String, action: Callable, width := 220) -> Button:
	var b := button(text, action, width)
	b.theme_type_variation = &"PrimaryButton"
	return b


## A tile to pick: a sign on the left, beside it a name in the title font, a line of text and what the player owns
## of it. A picked tile is inked through. The column of the tile is returned as meta "body" for more rows.
static func tile(sign: Control, name: String, text: String, owned: String, picked: bool, action: Callable, width := 290, lacking := false) -> Button:
	var b := Button.new()
	b.toggle_mode = true
	b.button_pressed = picked
	b.custom_minimum_size = Vector2(width, 118)
	b.pressed.connect(action)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 10)
	b.add_child(margin)
	var line := row(12)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(line)
	if sign != null:
		sign.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		line.add_child(sign)
	var body := col(1)
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.alignment = BoxContainer.ALIGNMENT_CENTER
	line.add_child(body)
	var paper := UiTheme.PAPER_LIGHT
	var head := title(name, 21)
	head.add_theme_color_override("font_color", paper if picked else UiTheme.TEXT)
	body.add_child(head)
	if text != "":
		body.add_child(label(text, 14, Color(paper, 0.8) if picked else UiTheme.DIM))
	if owned != "":
		body.add_child(label(owned, 14, (Color(0.95, 0.62, 0.55) if picked else UiTheme.WARN) if lacking else (Color(0.93, 0.8, 0.5) if picked else UiTheme.ACCENT)))
	for l in body.get_children():
		(l as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.set_meta("body", body)
	return b


## A sign of the icon set for a tile: paper-coloured on a picked tile.
static func sign(icon: String, picked := false, size := 46, ink := UiTheme.INK) -> TextureRect:
	return UiTheme.icon_rect(icon, size, UiTheme.PAPER_LIGHT if picked else ink)


## A painted square of the board in small: the colour of a ground or a prop with an ink edge.
static func swatch(color: Color, size := 18, edge := UiTheme.INK) -> Panel:
	var p := Panel.new()
	p.custom_minimum_size = Vector2(size, size)
	p.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.border_color = edge
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(2)
	p.add_theme_stylebox_override("panel", sb)
	return p


## A line of `count` squares, shown once per use: how far and how often a forged piece lays.
static func squares(count: int, uses: int, color: Color, size := 14, edge := UiTheme.INK) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 5)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.custom_minimum_size = Vector2(4 * size + 9, 0)
	for _u in maxi(1, uses):
		var line := HBoxContainer.new()
		line.add_theme_constant_override("separation", 3)
		line.mouse_filter = Control.MOUSE_FILTER_IGNORE
		for _i in maxi(1, count):
			line.add_child(swatch(color, size, edge))
		box.add_child(line)
	return box


## A small slip with a word: a property that is known, one that is not ("?"), a flaw.
static func chip(text: String, ink: Color, filled := false) -> PanelContainer:
	var p := PanelContainer.new()
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = ink if filled else Color(ink, 0.10)
	sb.border_color = ink
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(9)
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 1
	sb.content_margin_bottom = 1
	p.add_theme_stylebox_override("panel", sb)
	var l := label(text, 15, UiTheme.PAPER_LIGHT if filled else ink, false)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(l)
	return p


static func col(sep := 10) -> VBoxContainer:
	var c := VBoxContainer.new()
	c.add_theme_constant_override("separation", sep)
	c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return c


static func row(sep := 12) -> HBoxContainer:
	var r := HBoxContainer.new()
	r.add_theme_constant_override("separation", sep)
	return r


static func flow(sep := 12) -> HFlowContainer:
	var f := HFlowContainer.new()
	f.add_theme_constant_override("h_separation", sep)
	f.add_theme_constant_override("v_separation", sep)
	f.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return f


## A panel with a column inside; returns the column.
static func card(parent: Control, min_width := 0) -> VBoxContainer:
	var p := PanelContainer.new()
	p.custom_minimum_size = Vector2(min_width, 0)
	if min_width == 0:
		p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(p)
	var c := col(6)
	p.add_child(c)
	return c


## A scrolling column that takes the rest of the height.
static func scroll(parent: Control) -> VBoxContainer:
	var s := ScrollContainer.new()
	s.size_flags_vertical = Control.SIZE_EXPAND_FILL
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	parent.add_child(s)
	var c := col(12)
	s.add_child(c)
	return c


## The sign of a Kin in an ink disc: the Kin is shown by the part its beasts leave (assets/icons/part_<kin>.svg).
static func kin_sign(kin: int, size := 64) -> PanelContainer:
	var disc := PanelContainer.new()
	disc.custom_minimum_size = Vector2(size, size)
	disc.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	disc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = UiTheme.INK
	sb.set_corner_radius_all(size)
	sb.set_content_margin_all(size * 0.2)
	disc.add_theme_stylebox_override("panel", sb)
	disc.add_child(UiTheme.icon_rect("part_%d" % kin, int(size * 0.6), UiTheme.PAPER_LIGHT))
	return disc


## One stat: its sign, its value and its name below.
static func stat(icon: String, value: String, name: String, ink := UiTheme.INK) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 0)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var top := row(6)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(UiTheme.icon_rect(icon, 22, ink))
	top.add_child(label(value, 21, ink, false))
	box.add_child(top)
	box.add_child(label(name, 13, UiTheme.DIM, false))
	return box


## The head of a monster: the sign of its Kin, its name, its Kin and stage, and its stats with their signs.
static func monster_head(m: MonsterInstance) -> HBoxContainer:
	var def := m.species()
	var head := row(16)
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	head.add_child(kin_sign(def.kin))
	var text := col(4)
	text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	head.add_child(text)
	var names := row(12)
	names.add_child(title(def.display_name, 26))
	var sub := label("%s · %s %s" % [MonsterDef.kin_name(def.kin), Stage.stage_name(m.stage), Stage.sub_tier_name(m.sub_tier)], 16, UiTheme.ACCENT, false)
	sub.size_flags_vertical = Control.SIZE_SHRINK_END
	names.add_child(sub)
	text.add_child(names)
	var stats := row(26)
	var hurt := m.current_hp < m.max_hp()
	stats.add_child(stat("stat_hp", "%d/%d" % [m.current_hp, m.max_hp()], "HP", UiTheme.CINNABAR if hurt else UiTheme.INK))
	stats.add_child(stat("stat_pace", "%.1f" % float(m.stats["pace"]), "Pace"))
	stats.add_child(stat("stat_stamina", "%d" % int(m.stats["move"]), "Stamina"))
	stats.add_child(stat("stat_reach", "%d" % int(m.stats["reach"]), "Reach"))
	if m.uses_points():
		stats.add_child(stat("stat_ap", "%d" % int(m.stats["ap"]), "AP"))
	stats.add_child(stat("stat_turns", "%d" % int(m.stats["tpr"]), "Turns"))
	text.add_child(stats)
	return head


## A skill in a list: the sign of its kind in the colour of the kind, its name and what it does.
static func skill_line(s: BattleSkillDef, head: String, text: String) -> HBoxContainer:
	var content := GameSession.battle_content()
	var kind := BattleText.kind_id(content, s)
	var line := row(12)
	line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sign := UiTheme.icon_rect("kind_" + kind, 34, BattleText.kind_color(content, s))
	sign.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	line.add_child(sign)
	var body := col(0)
	body.add_child(label(head, 19))
	body.add_child(label(text, 15, UiTheme.DIM))
	line.add_child(body)
	return line


## The colour of a part of a battleground ("ground:<id>", "prop:<id>", "zone:<id>") on the board.
static func part_color(part: String) -> Color:
	var c := BattleContent.shared()
	var id := StringName(part.get_slice(":", 1))
	match part.get_slice(":", 0):
		"ground":
			return c.ground(id).color if c.ground(id) != null else UiTheme.INK_SOFT
		"prop":
			return c.prop(id).color if c.prop(id) != null else UiTheme.INK_SOFT
	return c.zone(id).color if c.zone(id) != null else UiTheme.INK_SOFT


## A line with a sign in front: for lists of things the player owns.
static func signed(sign: Control, text: String, size := 18, color := UiTheme.TEXT) -> HBoxContainer:
	var line := row(10)
	line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sign.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	line.add_child(sign)
	line.add_child(label(text, size, color))
	return line


## The sign of an item of the inventory: a beast part, a plant, a pill, a forged weapon.
static func item_sign(item: String, size := 28) -> Control:
	match Materials.form(item):
		"plant":
			return UiTheme.icon_rect("plant", size, UiTheme.JADE)
		"pill":
			return UiTheme.icon_rect("pill", size, UiTheme.CINNABAR)
		"part":
			return UiTheme.icon_rect("part_%d" % int(item.get_slice(":", 1)), size)
	return UiTheme.icon_rect("building_forge", size)


## A monster in one line for a list of opponents: the sign of its Kin, its name, its stats with their signs, its kit.
static func monster_line(m: MonsterInstance, with_kit := true) -> HBoxContainer:
	var def := m.species()
	var line := row(12)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line.add_child(kin_sign(def.kin, 44))
	var text := col(0)
	text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line.add_child(text)
	var top := row(14)
	top.add_child(title(def.display_name, 20))
	var hurt := m.current_hp < m.max_hp()
	for part: Array in [["stat_hp", "%d/%d" % [m.current_hp, m.max_hp()], UiTheme.CINNABAR if hurt else UiTheme.INK], ["stat_pace", "%.1f" % float(m.stats["pace"]), UiTheme.INK],
			["stat_stamina", "%d" % int(m.stats["move"]), UiTheme.INK], ["stat_reach", "%d" % int(m.stats["reach"]), UiTheme.INK],
			["stat_ap", "%d" % int(m.stats["ap"]), UiTheme.INK], ["stat_turns", "%d" % int(m.stats["tpr"]), UiTheme.INK]]:
		var pair := row(4)
		pair.add_child(UiTheme.icon_rect(part[0], 17, part[2]))
		pair.add_child(label(part[1], 17, part[2], false))
		top.add_child(pair)
	text.add_child(top)
	if with_kit:
		text.add_child(label("%s · %s %s · %s" % [MonsterDef.kin_name(def.kin), Stage.stage_name(m.stage), Stage.sub_tier_name(m.sub_tier), m.kit_text()], 15, UiTheme.DIM))
	return line


## A fight before it is fought: its battleground painted small, and beside it the opponents.
static func fight_view(f: Fight, with_kit := true, cell := 20.0) -> HBoxContainer:
	var view := row(18)
	var map := FightBridge.map_of(f)
	var left := VBoxContainer.new()
	left.add_theme_constant_override("separation", 4)
	left.add_child(MiniBoard.of(map, cell))
	if map != null:
		var size := label("%d×%d · %d against %d" % [map.width, map.height, map.start_a.size(), map.start_b.size()], 14, UiTheme.DIM, false)
		left.add_child(size)
	view.add_child(left)
	var foes := col(8)
	for e in f.enemies:
		foes.add_child(monster_line(e, with_kit))
	view.add_child(foes)
	return view


## The sheet of a monster as lines: who it is, its stats, its kit.
static func monster_lines(m: MonsterInstance, with_kit := true) -> String:
	var text := "%s\n%s" % [m.title(), m.stats_text()]
	if with_kit:
		text += "\nKit: %s" % m.kit_text()
	return text


## The Kin of a monster: its trait, what it never learns, its gifts.
static func kin_lines(m: MonsterInstance) -> String:
	var kin := KinDef.of(m.species().kin)
	if kin == null:
		return ""
	var text := "%s trait — %s Never learns: %s." % [kin.display_name, kin.trait_line(), ", ".join(kin.never_learns())]
	if not m.gifts.is_empty():
		var names: PackedStringArray = []
		for g in m.gifts:
			names.append(KinDef.gift_line(m.species().kin, g))
		text += "\nGifts: %s" % ", ".join(names)
	return text


## What waits for a decision of the player on this monster ("" = nothing).
static func todo_text(m: MonsterInstance) -> String:
	var parts: PackedStringArray = []
	if m.fresh:
		parts.append("fresh from the egg: shape it under Stats and Skills")
	if m.unspent > 0:
		parts.append("%d stat points to spend" % m.unspent)
	if m.kit.size() < m.slots and m.kit.size() < m.learnable().size():
		parts.append("%d free slot(s)" % (m.slots - m.kit.size()))
	if m.choice_picks > 0:
		parts.append("a breakthrough choice waits")
	if m.gift_picks > 0:
		parts.append("a gift to choose")
	if m.dev_steps > 0:
		parts.append("%d development step(s)" % m.dev_steps)
	return "To decide: %s." % "; ".join(parts) if not parts.is_empty() else ""
