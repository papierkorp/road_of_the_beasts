class_name GameData
extends RefCounted
## The single place where all content lives (GDD §16).
##
## Every monster, skill and zone is one Resource file with a fixed template (its script class):
##   res://data/monsters/<id>.tres → MonsterDef
##   res://data/skills/<id>.tres   → SkillDef
##   res://data/zones/<id>.tres    → ZoneDef
## Drop a new file into the folder and it is picked up automatically — no code changes.
## `validate()` checks the whole set (ids, required fields, references, shapes) at startup and in the tests.

const MONSTER_DIR := "res://data/monsters"
const SKILL_DIR := "res://data/skills"
const ZONE_DIR := "res://data/zones"

static var _monsters := {}     # id -> MonsterDef
static var _skills := {}       # id -> SkillDef
static var _zones := {}        # id -> ZoneDef
static var _loaded := false
static var _problems: Array[String] = []


static func _ensure() -> void:
	if _loaded:
		return
	_loaded = true
	_problems.clear()
	_zones = _load_dir(ZONE_DIR, "ZoneDef")
	_skills = _load_dir(SKILL_DIR, "SkillDef")
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


static func skill(id: StringName) -> SkillDef:
	_ensure()
	return _skills.get(id)


static func zone(id: StringName) -> ZoneDef:
	_ensure()
	return _zones.get(id)


## Roster order: by aspect (Force, Nature, Dark), then name.
static func monster_ids() -> Array[StringName]:
	_ensure()
	var ids: Array[StringName] = []
	for id in _monsters:
		ids.append(id)
	ids.sort_custom(func(a: StringName, b: StringName) -> bool:
		var da: MonsterDef = _monsters[a]
		var db: MonsterDef = _monsters[b]
		if da.aspect != db.aspect:
			return da.aspect < db.aspect
		return da.display_name < db.display_name)
	return ids


static func skill_ids() -> Array[StringName]:
	_ensure()
	var ids: Array[StringName] = []
	for id in _skills:
		ids.append(id)
	ids.sort()
	return ids


## All problems found in the data set (empty = valid).
static func problems() -> Array[String]:
	_ensure()
	return _problems


static func reload() -> void:
	_loaded = false
	_ensure()


static func _validate_all() -> void:
	for id in _zones:
		var z: ZoneDef = _zones[id]
		if z.effects.is_empty():
			_problems.append("zone '%s' has no effects" % id)
	for id in _skills:
		var s: SkillDef = _skills[id]
		var where := "skill '%s'" % id
		if s.display_name.is_empty():
			_problems.append(where + " has no display_name")
		if s.archetype == &"":
			_problems.append(where + " has no archetype")
		var ring := s.kind == SkillDef.Kind.SURGE and s.twist == SkillDef.Twist.RING
		if not ring:
			if s.shapes.size() != 1:
				_problems.append(where + " must have exactly one shape family (fixed shapes)")
			for f in s.shapes:
				if not Shapes.BASE.has(f):
					_problems.append(where + " uses unknown shape '%s'" % f)
			if not s.shapes.is_empty() and s.orientation >= s.orientations().size():
				_problems.append(where + " orientation %d out of range" % s.orientation)
		match s.kind:
			SkillDef.Kind.SURGE:
				if s.surge_type == SkillDef.SurgeType.NONE:
					_problems.append(where + " is a Surge without surge_type")
			SkillDef.Kind.ZONE:
				if s.zone == null:
					_problems.append(where + " is a zone skill without zone")
				elif s.zone.aspect != s.aspect:
					_problems.append(where + " aspect differs from its zone's aspect")
			SkillDef.Kind.GROUND:
				if Square.ground_aspect_of(s.ground_type) != s.aspect:
					_problems.append(where + " lays ground of another aspect")
	for id in _monsters:
		var m: MonsterDef = _monsters[id]
		var where := "monster '%s'" % id
		if m.surge == null or m.surge.kind != SkillDef.Kind.SURGE:
			_problems.append(where + " needs a Surge skill")
		elif m.surge.aspect != m.aspect:
			_problems.append(where + " Surge has another aspect")
		if m.utility == null:
			_problems.append(where + " needs a utility skill")
		elif m.utility.kind == SkillDef.Kind.SURGE:
			_problems.append(where + " utility can't be a Surge")
		if not MonsterDef.PASSIVE_TEXT.has(m.passive):
			_problems.append(where + " has unknown passive '%s'" % m.passive)
		if m.hp < 1 or m.hp > 10 or m.reach < 1 or m.reach > 3 or m.tpr < 1 or m.tpr > 3:
			_problems.append(where + " stats out of range (HP 1-10, Reach 1-3, TPR 1-3)")
