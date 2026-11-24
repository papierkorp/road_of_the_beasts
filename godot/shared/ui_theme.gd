class_name UiTheme
extends RefCounted
## The look of every screen: ink on paper. A warm paper ground, ink-black text and lines, an ochre accent for
## headings and numbers, cinnabar for the one thing that matters on a screen and for warnings, jade for what is good.
## Fonts: a serif with brush endings for titles, a plain sans for everything that is read (assets/fonts, SIL Open
## Font License).

const PAPER := Color(0.937, 0.902, 0.824)
const PAPER_LIGHT := Color(0.968, 0.945, 0.886)
const PAPER_SHADE := Color(0.893, 0.851, 0.757)
const INK := Color(0.122, 0.11, 0.098)
const INK_SOFT := Color(0.40, 0.365, 0.32)
const CINNABAR := Color(0.706, 0.208, 0.169)
const JADE := Color(0.20, 0.50, 0.42)
const OCHRE := Color(0.56, 0.39, 0.10)
## The two sides of a battle: ink blue for the player, cinnabar for the opponent.
const SIDE := [Color(0.20, 0.36, 0.56), Color(0.706, 0.208, 0.169)]

const TEXT := INK
const DIM := INK_SOFT
const ACCENT := OCHRE
const PANEL := PAPER_LIGHT
const BG := PAPER
const WARN := CINNABAR
const GOOD := JADE

const TITLE_FONT := "res://assets/fonts/ShipporiMincho-Bold-Latin.ttf"
const TEXT_FONT := "res://assets/fonts/SourceSans3.ttf"
const PAPER_SHADER := "res://assets/shaders/paper.gdshader"
const ICONS := "res://assets/icons/%s.svg"

static var _title: Font = null
static var _text: Font = null
static var _paper: ShaderMaterial = null


static func _box(fill: Color, line: Color, width := 2, radius := 3, margin := 10) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = fill
	sb.border_color = line
	sb.set_border_width_all(width)
	sb.border_width_bottom = width + (1 if width > 0 else 0)      # a brush stroke is heavier where it ends
	sb.set_corner_radius_all(radius)
	sb.set_content_margin_all(margin)
	sb.anti_aliasing = true
	return sb


## The font of titles; null while the font files are not imported (the engine font is used then).
static func title_font() -> Font:
	if _title == null and ResourceLoader.exists(TITLE_FONT):
		_title = load(TITLE_FONT)
	return _title


static func text_font(weight := 500) -> Font:
	if _text == null and ResourceLoader.exists(TEXT_FONT):
		var v := FontVariation.new()
		v.base_font = load(TEXT_FONT)
		v.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"): weight}
		_text = v
	return _text


## The paper ground of a screen as a material for a ColorRect that fills it.
static func paper_material() -> ShaderMaterial:
	if _paper == null and ResourceLoader.exists(PAPER_SHADER):
		_paper = ShaderMaterial.new()
		_paper.shader = load(PAPER_SHADER)
	return _paper


## A ColorRect that fills its parent with the paper ground.
static func paper_rect() -> ColorRect:
	var bg := ColorRect.new()
	bg.color = BG
	bg.material = paper_material()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return bg


## An icon of the set (assets/icons), drawn in white so it takes any ink through `modulate`; null if it is missing.
static func icon(name: String) -> Texture2D:
	var path := ICONS % name
	return load(path) if ResourceLoader.exists(path) else null


## An icon as a control of `size` pixels in the given ink.
static func icon_rect(name: String, size := 48, ink := INK) -> TextureRect:
	var r := TextureRect.new()
	r.texture = icon(name)
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	r.custom_minimum_size = Vector2(size, size)
	r.modulate = ink
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r


## A phone or tablet: no window to size, and controls are pressed with a finger.
static func handheld() -> bool:
	return OS.has_feature("mobile")


static func create() -> Theme:
	var t := Theme.new()
	t.default_font_size = 18
	if text_font() != null:
		t.default_font = text_font()

	t.set_color("font_color", "Label", TEXT)
	t.set_color("default_color", "RichTextLabel", TEXT)

	var panel := _box(PANEL, Color(INK, 0.85), 2, 4, 14)
	panel.shadow_color = Color(INK, 0.14)
	panel.shadow_size = 6
	panel.shadow_offset = Vector2(0, 3)
	t.set_stylebox("panel", "PanelContainer", panel)
	t.set_stylebox("panel", "Panel", panel)
	t.set_stylebox("panel", "PopupPanel", panel)
	t.set_stylebox("panel", "PopupMenu", panel)
	t.set_stylebox("panel", "AcceptDialog", panel)
	t.set_stylebox("embedded_border", "Window", panel)
	t.set_color("title_color", "Window", TEXT)

	# a button is a paper slip with an ink line; pressed or chosen it is inked through
	for kind: String in ["Button", "OptionButton", "MenuButton"]:
		t.set_stylebox("normal", kind, _box(PAPER_LIGHT, Color(INK, 0.7)))
		t.set_stylebox("hover", kind, _box(Color(1.0, 0.985, 0.94), INK))
		t.set_stylebox("pressed", kind, _box(INK, INK))
		t.set_stylebox("hover_pressed", kind, _box(INK.lightened(0.12), INK))
		t.set_stylebox("disabled", kind, _box(Color(PAPER_SHADE, 0.45), Color(INK, 0.2)))
		t.set_stylebox("focus", kind, StyleBoxEmpty.new())
		t.set_color("font_color", kind, TEXT)
		t.set_color("font_hover_color", kind, TEXT)
		t.set_color("font_focus_color", kind, TEXT)
		t.set_color("font_pressed_color", kind, PAPER_LIGHT)
		t.set_color("font_hover_pressed_color", kind, PAPER_LIGHT)
		t.set_color("font_disabled_color", kind, Color(INK_SOFT, 0.55))
		t.set_color("icon_normal_color", kind, INK)
		t.set_color("icon_hover_color", kind, INK)
		t.set_color("icon_pressed_color", kind, PAPER_LIGHT)
		t.set_color("icon_disabled_color", kind, Color(INK_SOFT, 0.55))
		t.set_font_size("font_size", kind, 16)
	# the one action a screen is about: a cinnabar seal
	t.set_type_variation("PrimaryButton", "Button")
	t.set_stylebox("normal", "PrimaryButton", _box(CINNABAR, CINNABAR.darkened(0.35)))
	t.set_stylebox("hover", "PrimaryButton", _box(CINNABAR.lightened(0.12), CINNABAR.darkened(0.35)))
	t.set_stylebox("pressed", "PrimaryButton", _box(CINNABAR.darkened(0.3), INK))
	t.set_stylebox("disabled", "PrimaryButton", _box(Color(CINNABAR, 0.25), Color(INK, 0.15)))
	for state: String in ["font_color", "font_hover_color", "font_focus_color", "font_pressed_color"]:
		t.set_color(state, "PrimaryButton", PAPER_LIGHT)
	t.set_color("font_disabled_color", "PrimaryButton", Color(PAPER_LIGHT, 0.8))
	t.set_color("font_color", "PopupMenu", TEXT)
	t.set_color("font_hover_color", "PopupMenu", PAPER_LIGHT)
	t.set_color("font_disabled_color", "PopupMenu", Color(INK_SOFT, 0.55))
	t.set_stylebox("hover", "PopupMenu", _box(INK, INK, 0, 2, 4))

	for kind: String in ["CheckButton", "CheckBox"]:
		t.set_color("font_color", kind, TEXT)
		t.set_color("font_hover_color", kind, TEXT)
		t.set_color("font_pressed_color", kind, TEXT)
		t.set_color("font_hover_pressed_color", kind, TEXT)
		t.set_color("font_focus_color", kind, TEXT)
		t.set_stylebox("focus", kind, StyleBoxEmpty.new())
		t.set_stylebox("normal", kind, _box(Color(PAPER_SHADE, 0.6), Color(INK, 0.35), 1))
		t.set_stylebox("pressed", kind, _box(PAPER_SHADE, Color(INK, 0.7), 1))
		t.set_stylebox("hover", kind, _box(PAPER_LIGHT, Color(INK, 0.7), 1))
		t.set_stylebox("hover_pressed", kind, _box(PAPER_LIGHT, INK, 1))

	# the marks of check boxes and switches, drawn in ink (assets/icons)
	if icon("check_on") != null:
		for state: String in ["checked", "checked_disabled"]:
			t.set_icon(state, "CheckBox", icon("check_on"))
			t.set_icon(state, "CheckButton", icon("toggle_on"))
		for state: String in ["unchecked", "unchecked_disabled"]:
			t.set_icon(state, "CheckBox", icon("check_off"))
			t.set_icon(state, "CheckButton", icon("toggle_off"))
		t.set_constant("icon_max_width", "CheckBox", 24)
		t.set_constant("icon_max_width", "CheckButton", 44)

	for kind: String in ["LineEdit", "TextEdit"]:
		t.set_stylebox("normal", kind, _box(PAPER_LIGHT, Color(INK, 0.55), 1, 2, 8))
		t.set_stylebox("focus", kind, _box(PAPER_LIGHT, INK, 2, 2, 8))
		t.set_stylebox("read_only", kind, _box(Color(PAPER_SHADE, 0.6), Color(INK, 0.3), 1, 2, 8))
		t.set_color("font_color", kind, TEXT)
		t.set_color("font_readonly_color", kind, INK_SOFT)
		t.set_color("font_uneditable_color", kind, INK_SOFT)
		t.set_color("font_placeholder_color", kind, Color(INK_SOFT, 0.6))
		t.set_color("caret_color", kind, INK)
		t.set_color("selection_color", kind, Color(OCHRE, 0.35))

	for part: String in ["up_icon_modulate", "down_icon_modulate", "up_hover_icon_modulate", "down_hover_icon_modulate", "up_pressed_icon_modulate", "down_pressed_icon_modulate"]:
		t.set_color(part, "SpinBox", INK)
	t.set_constant("modulate_arrow", "OptionButton", 1)

	# tables and lists (the overview, the builders): paper with ink text, the chosen row inked through
	for kind: String in ["Tree", "ItemList"]:
		t.set_stylebox("panel", kind, _box(PAPER_LIGHT, Color(INK, 0.7), 1, 2, 4))
		t.set_stylebox("focus", kind, StyleBoxEmpty.new())
		t.set_stylebox("selected", kind, _box(INK, INK, 0, 2, 2))
		t.set_stylebox("selected_focus", kind, _box(INK, INK, 0, 2, 2))
		t.set_stylebox("hovered", kind, _box(Color(INK, 0.08), Color(INK, 0.0), 0, 2, 2))
		t.set_color("font_color", kind, TEXT)
		t.set_color("font_hovered_color", kind, TEXT)
		t.set_color("font_selected_color", kind, PAPER_LIGHT)
		t.set_color("font_disabled_color", kind, Color(INK_SOFT, 0.6))
		t.set_color("guide_color", kind, Color(INK, 0.12))
	t.set_stylebox("title_button_normal", "Tree", _box(INK, INK, 0, 0, 6))
	t.set_stylebox("title_button_hover", "Tree", _box(INK.lightened(0.15), INK, 0, 0, 6))
	t.set_stylebox("title_button_pressed", "Tree", _box(INK.lightened(0.25), INK, 0, 0, 6))
	t.set_color("title_button_color", "Tree", PAPER_LIGHT)
	t.set_color("children_hl_line_color", "Tree", Color(INK, 0.3))
	t.set_color("relationship_line_color", "Tree", Color(INK, 0.2))
	t.set_stylebox("panel", "TooltipPanel", _box(PAPER_LIGHT, INK, 1, 3, 8))
	t.set_color("font_color", "TooltipLabel", TEXT)

	var groove := _box(Color(INK, 0.25), Color(INK, 0.0), 0, 2, 2)
	t.set_stylebox("slider", "HSlider", groove)
	t.set_stylebox("grabber_area", "HSlider", _box(INK, INK, 0, 2, 2))
	t.set_stylebox("grabber_area_highlight", "HSlider", _box(INK, INK, 0, 2, 2))
	for bar: String in ["VScrollBar", "HScrollBar"]:
		t.set_stylebox("scroll", bar, _box(Color(INK, 0.08), Color(INK, 0.0), 0, 3, 3))
		t.set_stylebox("grabber", bar, _box(Color(INK, 0.45), Color(INK, 0.0), 0, 3, 3))
		t.set_stylebox("grabber_highlight", bar, _box(Color(INK, 0.65), Color(INK, 0.0), 0, 3, 3))
		t.set_stylebox("grabber_pressed", bar, _box(INK, INK, 0, 3, 3))
	return t


## The first key or button bound to an input action, as text for a hint or a button ("Space", "G"). Keys are
## never written into code or texts: they live in the Input Map (Project Settings) and are read from there.
static func key_text(action: StringName) -> String:
	if not InputMap.has_action(action):
		return "?"
	for e in InputMap.action_get_events(action):
		if e is InputEventKey:
			var code: Key = e.physical_keycode if e.physical_keycode != KEY_NONE else e.keycode
			return OS.get_keycode_string(code)        # the key of the US layout for a physical key: the same on every display server
		if e is InputEventMouseButton:
			return {MOUSE_BUTTON_LEFT: "Left click", MOUSE_BUTTON_RIGHT: "Right click", MOUSE_BUTTON_MIDDLE: "Middle button",
				MOUSE_BUTTON_WHEEL_UP: "Wheel up", MOUSE_BUTTON_WHEEL_DOWN: "Wheel down"}.get(e.button_index, "Mouse %d" % e.button_index)
	return "?"
