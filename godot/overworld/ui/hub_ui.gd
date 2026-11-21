class_name HubUi
extends RefCounted
## Small builders for the screens of the hub game. Sizes are chosen for a finger as well as a mouse: no control is
## lower than TAP, and nothing is shown only on hover.

const TAP := 60
const BG := Color(0.075, 0.082, 0.094)
const WARN := Color(0.95, 0.45, 0.4)
const GOOD := Color(0.55, 0.9, 0.6)


static func theme() -> Theme:
	var t := UiTheme.create()
	t.default_font_size = 20
	t.set_font_size("font_size", "Button", 20)
	return t


## Fills a screen with the background and returns a margin container to build in.
static func page(root: Control) -> MarginContainer:
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.theme = theme()
	var bg := ColorRect.new()
	bg.color = BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(bg)
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


static func title(text: String) -> Label:
	return label(text, 30, UiTheme.ACCENT, false)


static func dim(text: String) -> Label:
	return label(text, 18, UiTheme.DIM)


static func button(text: String, action: Callable, width := 220) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(width, TAP)
	b.pressed.connect(action)
	return b


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
