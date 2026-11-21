class_name SaveGame
extends RefCounted
## One save slot as JSON in user://, written whenever the hub is shown. What a finished game leaves for the next one
## is kept apart from it (docs/overworld.md §7): user://legacy.json counts the games; nothing is opened by it yet.

const PATH := "user://save.json"
const LEGACY_PATH := "user://legacy.json"


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


static func erase() -> void:
	if exists():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))


static func legacy() -> Dictionary:
	if not FileAccess.file_exists(LEGACY_PATH):
		return {"lost": 0, "won": 0}
	var f := FileAccess.open(LEGACY_PATH, FileAccess.READ)
	var data = JSON.parse_string(f.get_as_text()) if f != null else null
	if typeof(data) != TYPE_DICTIONARY:
		return {"lost": 0, "won": 0}
	return {"lost": int(data.get("lost", 0)), "won": int(data.get("won", 0))}


## A game ended: count it and remove its save.
static func record_end(outcome: StringName) -> void:
	var l := legacy()
	var key := "won" if outcome == GameState.WON else "lost"
	l[key] = int(l[key]) + 1
	var f := FileAccess.open(LEGACY_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(l))
	erase()
