class_name UiTheme
extends RefCounted
## Minimal, flat theme: translucent dark panels, quiet buttons, gold accent.

const TEXT := Color(0.91, 0.89, 0.83)
const DIM := Color(0.62, 0.60, 0.55)
const ACCENT := Color(0.79, 0.64, 0.36)
const PANEL := Color(0.07, 0.08, 0.09, 0.80)


static func _flat(color: Color, radius: int = 4, margin: int = 10) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.set_corner_radius_all(radius)
	sb.set_border_width_all(0)
	sb.set_content_margin_all(margin)
	return sb


static func create() -> Theme:
	var t := Theme.new()
	t.default_font_size = 18

	t.set_color("font_color", "Label", TEXT)

	t.set_stylebox("panel", "PanelContainer", _flat(PANEL, 6, 14))

	t.set_stylebox("normal", "Button", _flat(Color(1, 1, 1, 0.05)))
	t.set_stylebox("hover", "Button", _flat(Color(1, 1, 1, 0.12)))
	t.set_stylebox("pressed", "Button", _flat(Color(ACCENT.r, ACCENT.g, ACCENT.b, 0.28)))
	t.set_stylebox("disabled", "Button", _flat(Color(1, 1, 1, 0.02)))
	t.set_stylebox("focus", "Button", StyleBoxEmpty.new())
	t.set_color("font_color", "Button", TEXT)
	t.set_color("font_hover_color", "Button", Color.WHITE)
	t.set_color("font_pressed_color", "Button", ACCENT)
	t.set_color("font_disabled_color", "Button", Color(DIM.r, DIM.g, DIM.b, 0.45))
	t.set_font_size("font_size", "Button", 16)

	t.set_color("font_color", "CheckButton", TEXT)
	t.set_color("font_hover_color", "CheckButton", Color.WHITE)
	t.set_stylebox("focus", "CheckButton", StyleBoxEmpty.new())
	return t
