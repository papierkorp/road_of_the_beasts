class_name SaveGame
extends RefCounted
## One save slot as JSON in user://. Saved at the hub (never mid-expedition).

const PATH := "user://save.json"


static func exists() -> bool:
	return FileAccess.file_exists(PATH)


static func save(state: GameState) -> bool:
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(JSON.stringify(state.to_dict()))
	return true


static func load_game() -> GameState:
	if not exists():
		return null
	var f := FileAccess.open(PATH, FileAccess.READ)
	if f == null:
		return null
	var data = JSON.parse_string(f.get_as_text())
	if typeof(data) != TYPE_DICTIONARY:
		return null
	return GameState.from_dict(data)
