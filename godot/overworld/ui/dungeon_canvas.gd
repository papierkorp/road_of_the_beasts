class_name DungeonCanvas
extends Control
## The node map of a dungeon run: layers left to right, paths as lines (Slay-the-Spire style).
## Shows the state of an Expedition and emits `node_pressed` for nodes the player may enter.

signal node_pressed(id: int)

const NODE_SIZE := Vector2(150, 64)
const X0 := 40.0
const X_STEP := 230.0
const Y_MID := 150.0
const Y_STEP := 120.0

var _ex: Expedition
var _buttons := {}                  # node id -> Button


func build(ex: Expedition) -> void:
	_ex = ex
	for c in get_children():
		remove_child(c)
		c.queue_free()
	_buttons.clear()
	custom_minimum_size = Vector2(X0 * 2.0 + X_STEP * (Expedition.LAYER_SIZES.size() - 1) + NODE_SIZE.x, Y_MID * 2.0)
	var choices := ex.choices()
	for n in ex.nodes:
		var layer_size: int = Expedition.LAYER_SIZES[n["layer"]]
		var b := Button.new()
		b.size = NODE_SIZE
		b.custom_minimum_size = NODE_SIZE
		b.position = Vector2(X0 + X_STEP * float(n["layer"]),
			Y_MID + (float(n["col"]) - (layer_size - 1) / 2.0) * Y_STEP - NODE_SIZE.y / 2.0)
		var label := "☠ Boss  %s" % n["mode"] if n["kind"] == &"boss" else "⚔ %s" % n["mode"]
		if ex.is_cleared(n["id"]):
			b.text = "✓ " + label
			b.disabled = true
		elif choices.has(n["id"]):
			b.text = label
			b.toggle_mode = true
			b.button_pressed = n["id"] == ex.selected
			var id: int = n["id"]
			b.pressed.connect(func(): node_pressed.emit(id))
		else:
			b.text = label
			b.disabled = true
		add_child(b)
		_buttons[n["id"]] = b
	queue_redraw()


func _draw() -> void:
	if _ex == null:
		return
	for n in _ex.nodes:
		for nx in n["next"]:
			var a: Button = _buttons[n["id"]]
			var b: Button = _buttons[nx]
			var walked := _ex.is_cleared(n["id"]) and (_ex.is_cleared(nx) or _ex.choices().has(nx))
			draw_line(a.position + a.size / 2.0, b.position + b.size / 2.0,
				UiTheme.ACCENT if walked else Color(UiTheme.DIM.r, UiTheme.DIM.g, UiTheme.DIM.b, 0.5),
				3.0 if walked else 2.0)
