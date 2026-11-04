extends CanvasLayer
## Developer cheat menu: F10 (or `) opens / closes it on any screen. Gives resources to the running game
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
	# pinned to the top-right corner and growing to the left, so it never leaves the window
	_panel.anchor_left = 1.0
	_panel.anchor_right = 1.0
	_panel.anchor_top = 0.0
	_panel.anchor_bottom = 0.0
	_panel.offset_right = -16.0
	_panel.offset_top = 56.0
	_panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_panel.grow_vertical = Control.GROW_DIRECTION_END
	root.add_child(_panel)
	# always-visible fallback: a small translucent button in the top-right corner
	var opener := Button.new()
	opener.theme = UiTheme.create()
	opener.text = "☰"
	opener.tooltip_text = "Cheats (F10 or `)"
	opener.modulate = Color(1, 1, 1, 0.45)
	opener.anchor_left = 1.0
	opener.anchor_right = 1.0
	opener.offset_left = -52.0
	opener.offset_right = -16.0
	opener.offset_top = 12.0
	opener.offset_bottom = 44.0
	opener.pressed.connect(_toggle)
	root.add_child(opener)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 6)
	_panel.add_child(col)
	var title := Label.new()
	title.text = "CHEATS  (F10 or `)"
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
	_add("+1000 spirit stones", func(s): return Cheats.give_money(s, 1000))
	_add("+5 of every pill", func(s): return Cheats.give_pills(s, 5))
	_add("+5 of every material", func(s): return Cheats.give_materials(s, 5))
	_add("Stage up (player and monsters)", func(s): return Cheats.stage_up(s))
	_add("All blueprints", func(s): return Cheats.give_blueprints(s))
	_add("+100 XP for all monsters", func(s): return Cheats.give_xp(s, 100))
	_add("Refill AP", func(s): return Cheats.refill_ap(s))
	_add("Heal all monsters", func(s): return Cheats.heal_all(s))
	_add("Next day (market moves)", func(s): return Cheats.next_day(s))


## The key is the input action "toggle_cheats" (Project Settings → Input Map): F10 and ` by default.
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_cheats") and not event.is_echo():
		_toggle()
		get_viewport().set_input_as_handled()


## Second path that doesn't depend on the input map or on event routing: poll the keys directly.
func _process(_delta: float) -> void:
	var down := Input.is_physical_key_pressed(KEY_F10) or Input.is_physical_key_pressed(KEY_QUOTELEFT)
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
