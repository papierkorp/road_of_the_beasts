class_name SettingsPanel
extends VBoxContainer
## Fullscreen, window size and volume. Used by the main menu and the pause menu.

signal back_pressed

var _fullscreen: CheckButton
var _size: OptionButton
var _volume: HSlider


func _init(with_back: bool = false) -> void:
	add_theme_constant_override("separation", 12)

	_fullscreen = CheckButton.new()
	_fullscreen.text = "Fullscreen (F11)"
	_fullscreen.toggled.connect(func(on: bool): GameSettings.set_fullscreen(on))
	add_child(_fullscreen)

	var size_row := HBoxContainer.new()
	var size_label := Label.new()
	size_label.text = "Window size"
	size_label.custom_minimum_size = Vector2(140, 0)
	size_row.add_child(size_label)
	_size = OptionButton.new()
	for s in GameSettings.SIZES:
		_size.add_item("%d × %d" % [s.x, s.y])
	_size.item_selected.connect(func(i: int): GameSettings.set_size_index(i))
	size_row.add_child(_size)
	add_child(size_row)

	var vol_row := HBoxContainer.new()
	var vol_label := Label.new()
	vol_label.text = "Volume"
	vol_label.custom_minimum_size = Vector2(140, 0)
	vol_row.add_child(vol_label)
	_volume = HSlider.new()
	_volume.min_value = 0.0
	_volume.max_value = 1.0
	_volume.step = 0.05
	_volume.custom_minimum_size = Vector2(220, 24)
	_volume.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_volume.value_changed.connect(func(v: float): GameSettings.set_volume(v))
	vol_row.add_child(_volume)
	add_child(vol_row)

	if with_back:
		var back := Button.new()
		back.text = "Back"
		back.pressed.connect(func(): back_pressed.emit())
		add_child(back)


func _ready() -> void:
	GameSettings.changed.connect(_sync)
	_sync()


func _sync() -> void:
	_fullscreen.set_pressed_no_signal(GameSettings.fullscreen)
	_size.select(GameSettings.size_index)
	_volume.set_value_no_signal(GameSettings.volume)
