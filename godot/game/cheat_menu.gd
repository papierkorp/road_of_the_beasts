extends CanvasLayer
## Developer cheat menu: F10 opens / closes it on any screen. Gives resources to the running game
## (GameSession.game) and tells the screens to refresh via GameSession.state_changed.

var _panel: PanelContainer
var _message: Label
var _buttons: VBoxContainer


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS      # works while a battle is paused
	_panel = PanelContainer.new()
	_panel.theme = UiTheme.create()
	_panel.visible = false
	_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_panel.position += Vector2(-16, 16)
	add_child(_panel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 6)
	_panel.add_child(col)
	var title := Label.new()
	title.text = "CHEATS  (F10)"
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
	_add("+5 cultivation pills", func(s): return Cheats.give_pills(s, 5))
	_add("+5 of every material", func(s): return Cheats.give_materials(s, 5))
	_add("+100 XP for all monsters", func(s): return Cheats.give_xp(s, 100))
	_add("Refill AP", func(s): return Cheats.refill_ap(s))
	_add("Heal all monsters", func(s): return Cheats.heal_all(s))
	_add("Next day (market moves)", func(s): return Cheats.next_day(s))


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F10:
		_panel.visible = not _panel.visible
		_message.text = "" if GameSession.game != null else "No game running — start or continue a game first."
		get_viewport().set_input_as_handled()


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
