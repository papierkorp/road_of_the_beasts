class_name GameData
extends RefCounted
## The single place where all content lives (GDD §16).
##
## The species registry of the overworld: res://data/monsters/<id>.tres → MonsterDef (species,
## reference stats and kit in one file). Skills, zones, grounds, props and the rest of
## res://data are loaded by BattleContent; there is one definition of each, no legacy copy.
## Drop a new file into the folder and it is picked up automatically — no code changes.
## `validate()` checks the whole set (ids, required fields, references, shapes) at startup and in the tests.

const MONSTER_DIR := "res://data/monsters"

static var _monsters := {}     # id -> MonsterDef
static var _loaded := false
static var _problems: Array[String] = []


static func _ensure() -> void:
	if _loaded:
		return
	_loaded = true
	_problems.clear()
	_monsters = _load_dir(MONSTER_DIR, "MonsterDef")
	_validate_all()
	for p in _problems:
		push_error("GameData: " + p)


## Loads every .tres in a folder (also exported builds, where files end in .remap) keyed by `id`.
static func _load_dir(dir: String, class_label: String) -> Dictionary:
	var out := {}
	var files := ResourceLoader.list_directory(dir) if ResourceLoader.has_method("list_directory") else DirAccess.get_files_at(dir)
	for f in files:
		var file := String(f).trim_suffix(".remap")
		if not file.ends_with(".tres"):
			continue
		var path := dir.path_join(file)
		var res := load(path)
		if res == null or res.get_script() == null or res.get_script().get_global_name() != class_label:
			_problems.append("%s is not a %s" % [path, class_label])
			continue
		var id: StringName = res.get("id")
		if String(id).is_empty():
			_problems.append("%s has no id" % path)
			continue
		if id != StringName(file.get_basename()):
			_problems.append("%s: id '%s' doesn't match the file name" % [path, id])
		if out.has(id):
			_problems.append("duplicate %s id '%s'" % [class_label, id])
		out[id] = res
	return out


static func monster(id: StringName) -> MonsterDef:
	_ensure()
	return _monsters.get(id)


## The roster the game offers (approved and draft monsters). Order: by aspect (Force, Nature, Dark), then name.
static func monster_ids() -> Array[StringName]:
	_ensure()
	var ids: Array[StringName] = []
	for id in _monsters:
		if ContentStatus.in_game(_monsters[id]):      # no test-only or simulation-only monsters
			ids.append(id)
	ids.sort_custom(func(a: StringName, b: StringName) -> bool:
		var da: MonsterDef = _monsters[a]
		var db: MonsterDef = _monsters[b]
		if da.aspect != db.aspect:
			return da.aspect < db.aspect
		return da.display_name < db.display_name)
	return ids


## All problems found in the data set (empty = valid).
static func problems() -> Array[String]:
	_ensure()
	return _problems


static func reload() -> void:
	_loaded = false
	_ensure()


static func _validate_all() -> void:
	for id in _monsters:
		var m: MonsterDef = _monsters[id]
		var where := "monster '%s'" % id
		if m.skills.is_empty() or m.skills.size() > 4:
			_problems.append(where + " needs 1-4 kit slots")
		var active := 0
		for s in m.skills:
			if s == null:
				_problems.append(where + " has an empty kit slot")
			elif s.is_active():
				active += 1
		if active == 0:
			_problems.append(where + " needs at least one active skill")
