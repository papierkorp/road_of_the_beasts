extends Node
## Window and audio settings, persisted to user://settings.cfg. F11 toggles fullscreen anywhere.

signal changed

const PATH := "user://settings.cfg"
const SIZES: Array[Vector2i] = [Vector2i(1280, 720), Vector2i(1600, 900), Vector2i(1920, 1080), Vector2i(2560, 1440)]

var fullscreen := false
var size_index := 1
var volume := 0.8          # 0..1, master bus


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS    # keep working while the game is paused
	_load()
	apply()


func apply() -> void:
	var win := get_window()
	if fullscreen:
		win.mode = Window.MODE_FULLSCREEN
	else:
		win.mode = Window.MODE_WINDOWED
		win.size = SIZES[size_index]
		var screen := DisplayServer.window_get_current_screen()
		var area := DisplayServer.screen_get_size(screen)
		win.position = DisplayServer.screen_get_position(screen) + Vector2i((Vector2(area - win.size) / 2.0).floor())
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(volume, 0.0001)))
	changed.emit()


func set_fullscreen(on: bool) -> void:
	fullscreen = on
	apply()
	_save()


func set_size_index(i: int) -> void:
	size_index = clampi(i, 0, SIZES.size() - 1)
	apply()
	_save()


func set_volume(v: float) -> void:
	volume = clampf(v, 0.0, 1.0)
	apply()
	_save()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F11:
		set_fullscreen(not fullscreen)


func _load() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) != OK:
		return
	fullscreen = cfg.get_value("window", "fullscreen", fullscreen)
	size_index = clampi(int(cfg.get_value("window", "size_index", size_index)), 0, SIZES.size() - 1)
	volume = clampf(float(cfg.get_value("audio", "volume", volume)), 0.0, 1.0)


func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("window", "fullscreen", fullscreen)
	cfg.set_value("window", "size_index", size_index)
	cfg.set_value("audio", "volume", volume)
	cfg.save(PATH)
