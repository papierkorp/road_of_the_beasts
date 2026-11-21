extends CanvasLayer
## Developer cheat menu: the action `toggle_cheats` or the button in the bottom-right corner opens it on any screen. Changes the running game
## (GameSession.game) and tells the screens to refresh via GameSession.state_changed.

var _panel: PanelContainer
var _message: Label
var _buttons: VBoxContainer
var _key_was_down := false
var _last_toggle_frame := -1


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS      # works while a battle is paused
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	_panel = PanelContainer.new()
	_panel.theme = UiTheme.create()
	_panel.visible = false
	# pinned above the opener in the bottom-right corner and growing up and to the left
	_panel.anchor_left = 1.0
	_panel.anchor_right = 1.0
	_panel.anchor_top = 1.0
	_panel.anchor_bottom = 1.0
	_panel.offset_right = -16.0
	_panel.offset_bottom = -64.0
	_panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	root.add_child(_panel)
	# always-visible fallback: a small translucent button in the bottom-right corner
	var opener := Button.new()
	opener.theme = UiTheme.create()
	opener.text = "☰"
	opener.tooltip_text = "Cheats (%s)" % UiTheme.key_text(&"toggle_cheats")
	opener.modulate = Color(1, 1, 1, 0.45)
	opener.anchor_left = 1.0
	opener.anchor_right = 1.0
	opener.anchor_top = 1.0
	opener.anchor_bottom = 1.0
	opener.offset_left = -64.0
	opener.offset_right = -12.0
	opener.offset_top = -56.0
	opener.offset_bottom = -12.0
	opener.pressed.connect(_toggle)
	root.add_child(opener)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 6)
	_panel.add_child(col)
	var title := Label.new()
	title.text = "CHEATS  (%s)" % UiTheme.key_text(&"toggle_cheats")
	title.add_theme_color_override("font_color", UiTheme.ACCENT)
	col.add_child(title)
	_message = Label.new()
	_message.add_theme_color_override("font_color", UiTheme.DIM)
	_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_message.custom_minimum_size = Vector2(300, 0)
	col.add_child(_message)
	_buttons = VBoxContainer.new()
	_buttons.add_theme_constant_override("separation", 4)
	col.add_child(_buttons)
	_add("Refill AP", func(g): return Cheats.refill_ap(g))
	_add("+3 years of lifespan", func(g): return Cheats.add_lifespan(g, 3))
	_add("Last year of the lifespan", func(g): return Cheats.last_day(g))
	_add("+100 XP for all monsters", func(g): return Cheats.give_xp(g, 100))
	_add("Tamer: next stage", func(g): return Cheats.stage_up(g))
	_add("Monsters: next stage", func(g): return Cheats.monsters_stage_up(g))
	_add("Heal all monsters", func(g): return Cheats.heal_all(g))
	_add("+3 path points", func(g): return Cheats.give_points(g, 3))
	_add("+3 of every material", func(g): return Cheats.give_materials(g, 3))


## The key is the input action "toggle_cheats" (Project Settings → Input Map): F10 and ` by default.
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_cheats") and not event.is_echo():
		_toggle()
		get_viewport().set_input_as_handled()


## Second path that doesn't depend on event routing: poll the action.
func _process(_delta: float) -> void:
	var down := Input.is_action_pressed(&"toggle_cheats")
	if down and not _key_was_down:
		_toggle()
	_key_was_down = down


func _toggle() -> void:
	var frame := Engine.get_process_frames()
	if frame == _last_toggle_frame:          # _input and _process may both see the same key press
		return
	_last_toggle_frame = frame
	print("[cheats] menu toggled")
	_panel.visible = not _panel.visible
	_message.text = "" if GameSession.game != null else "No game running — start or continue a game first."


func _add(text: String, action: Callable) -> void:
	var b := Button.new()
	b.text = text
	b.pressed.connect(func(): _run(action))
	_buttons.add_child(b)


func _run(action: Callable) -> void:
	var state := GameSession.game
	if state == null:
		_message.text = "No game running — start or continue a game first."
		return
	_message.text = String(action.call(state))
	GameSession.state_changed.emit()
