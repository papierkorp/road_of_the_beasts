extends Node
## A phone or tablet (`UiTheme.handheld()`): everything is drawn larger, and no screen lies under the camera cutout.
## Autoload; does nothing on a PC.
##
## Every screen is laid out for 1920 × 1080. On a handheld the same layout is scaled by `SCALE`, so a screen has
## about 720 units of height there: text and buttons get the size a finger and an eye at arm's length need.
## A screen is a Control that fills the window (the scene itself, or the first Control under a CanvasLayer); it is
## moved in from the left and right edge by the cutout, its paper ground stays under the whole display.
## Lists are scrolled by dragging their content. The back button of the device does what the action `battle_cancel`
## does (in a battle: cancel the chosen action, else the pause menu); it never closes the game.

const SCALE := 1.5

var _inset := 0.0


func _ready() -> void:
	if not UiTheme.handheld():
		return
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.content_scale_factor = SCALE
	get_tree().node_added.connect(_on_node_added)
	get_tree().root.size_changed.connect(_refit)
	_refit.call_deferred()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST and UiTheme.handheld():
		for pressed in [true, false]:
			var e := InputEventAction.new()
			e.action = &"battle_cancel"
			e.pressed = pressed
			Input.parse_input_event(e)


## The width the cutout takes at the left and right edge, in units of the layout. Both edges get the larger of
## the two, so a screen stays centred and turning the phone over changes nothing.
func inset() -> float:
	return _inset


func _measure() -> float:
	var win := get_tree().root
	var safe := DisplayServer.get_display_safe_area()
	var full := DisplayServer.window_get_size()
	if safe.size.x <= 0 or full.x <= 0:
		return 0.0
	var px := maxi(safe.position.x, full.x - safe.end.x)
	return maxf(0.0, px * win.get_visible_rect().size.x / float(full.x))


func _refit() -> void:
	_inset = _measure()
	_fit_below(get_tree().root)


func _fit_below(node: Node) -> void:
	for child in node.get_children():
		if child is Control:
			_fit(child)
		elif not child is Window:
			_fit_below(child)


func _on_node_added(node: Node) -> void:
	if node is Control:
		_let_scroll(node)
	if node is Control and not node.get_parent() is Control:
		if not node.is_node_ready():
			node.ready.connect(_fit.bind(node), CONNECT_ONE_SHOT)
		else:
			_fit(node)


func _fit(screen: Control) -> void:
	if not is_instance_valid(screen) or screen.anchor_left != 0.0 or screen.anchor_right != 1.0 or _is_paper(screen):
		return
	if screen.get_parent() == get_node_or_null("/root/CheatMenu"):
		return      # its opener sits in the bottom corner beside the screens, where it covers none of their buttons
	screen.offset_left = _inset
	screen.offset_right = -_inset
	for child in screen.get_children():
		if _is_paper(child):
			child.offset_left = -_inset
			child.offset_right = _inset


func _is_paper(node: Node) -> bool:
	return node is ColorRect and node.material != null and node.material == UiTheme.paper_material()


## A finger scrolls a list by dragging anything in it: what stands in a ScrollContainer hands its touches on to it
## (a button is still pressed by a tap; the container takes the press back once the drag begins).
func _let_scroll(c: Control) -> void:
	if c.mouse_filter != Control.MOUSE_FILTER_STOP or c is ScrollContainer or c is ScrollBar or c is Range \
			or c is LineEdit or c is TextEdit:
		return
	var up := c.get_parent()
	while up is Control:
		if up is ScrollContainer:
			c.mouse_filter = Control.MOUSE_FILTER_PASS
			if c is OptionButton or c is MenuButton:      # opens when the finger lifts, so a drag that begins on it scrolls
				c.action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
			return
		up = up.get_parent()
