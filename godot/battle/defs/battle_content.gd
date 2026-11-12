class_name BattleContent
extends RefCounted
## Registry of every definition under res://data, loaded once by folder: a new file is new
## content, no code change.
##   grounds/<id>.tres  → GroundDef        props/<id>.tres → PropDef
##   zones/<id>.tres    → BattleZoneDef    skills/<id>.tres → BattleSkillDef
##   tamer/<id>.tres    → TamerSkillDef    monsters/<id>.tres → MonsterDef (species + kit)
## Skills and monsters carry a `content_status` (ContentStatus). Test-only and
## simulation-only records are loaded like anything else, so tools and tests can use them, but
## the game never fields them: a monster of the game may not hold such a skill (`validate`),
## and `game_monster_ids` leaves such monsters out.
## A Battle holds one registry instance, so tests can add or replace definitions in a copy
## without touching the files.

## Bump when a definition changes meaning: replays are only valid for the same content.
const VERSION := "2026-11-12.2"
const ROOT := "res://data"

var grounds := {}
var props := {}
var zones := {}
var skills := {}
var tamer := {}
var monsters := {}
var problems: Array[String] = []

static var _shared: BattleContent = null


static func shared() -> BattleContent:
	if _shared == null:
		_shared = BattleContent.new()
		_shared.load_all()
		for p in _shared.problems:
			push_error("BattleContent: " + p)
	return _shared


static func reload_shared() -> BattleContent:
	_shared = null
	return shared()


## A registry with the same definitions that can be extended independently.
func copy() -> BattleContent:
	var c := BattleContent.new()
	c.grounds = grounds.duplicate()
	c.props = props.duplicate()
	c.zones = zones.duplicate()
	c.skills = skills.duplicate()
	c.tamer = tamer.duplicate()
	c.monsters = monsters.duplicate()
	return c


func ground(id: StringName) -> GroundDef:
	return grounds.get(id)


func prop(id: StringName) -> PropDef:
	return props.get(id)


func zone(id: StringName) -> BattleZoneDef:
	return zones.get(id)


func skill(id: StringName) -> BattleSkillDef:
	return skills.get(id)


func tamer_skill(id: StringName) -> TamerSkillDef:
	return tamer.get(id)


func monster(species_id: StringName) -> MonsterDef:
	return monsters.get(species_id)


## Ids of the monsters the game may offer (no test-only or simulation-only ones), alphabetical.
func game_monster_ids() -> Array:
	var out := []
	for id in sorted_ids(monsters):
		if ContentStatus.in_game(monsters[id]):
			out.append(id)
	return out


func add_ground(def: GroundDef) -> void:
	grounds[def.id] = def


func add_prop(def: PropDef) -> void:
	props[def.id] = def


func load_all() -> void:
	problems.clear()
	grounds = _load_dir("grounds", "GroundDef", "id")
	props = _load_dir("props", "PropDef", "id")
	zones = _load_dir("zones", "BattleZoneDef", "id")
	skills = _load_dir("skills", "BattleSkillDef", "id")
	tamer = _load_dir("tamer", "TamerSkillDef", "id")
	monsters = _load_dir("monsters", "MonsterDef", "id")
	validate()


func _load_dir(folder: String, class_label: String, key: String) -> Dictionary:
	var out := {}
	var dir := ROOT.path_join(folder)
	var files: PackedStringArray = ResourceLoader.list_directory(dir)
	var names: Array[String] = []
	for f in files:
		var file := String(f).trim_suffix(".remap")
		if file.ends_with(".tres"):
			names.append(file)
	names.sort()                              # stable load order
	for file in names:
		var path := dir.path_join(file)
		var res := load(path)
		if res == null or res.get_script() == null or res.get_script().get_global_name() != class_label:
			problems.append("%s is not a %s" % [path, class_label])
			continue
		var id: StringName = res.get(key)
		if String(id).is_empty():
			problems.append("%s has no %s" % [path, key])
			continue
		if id != StringName(file.get_basename()):
			problems.append("%s: %s '%s' does not match the file name" % [path, key, id])
		if out.has(id):
			problems.append("duplicate %s '%s'" % [class_label, id])
		out[id] = res
	return out


## Structural checks of the whole set (references, required parts per profile, ranges).
## A problem blocks nothing at runtime but fails the content test.
func validate() -> void:
	for id in [GroundDef.PLAIN, GroundDef.RUBBLE]:
		if not grounds.has(id):
			problems.append("required ground '%s' is missing" % id)
	for id in grounds:
		var g: GroundDef = grounds[id]
		if g.move_cost < 1 or g.max_level < 1 or g.max_level > 2:
			problems.append("ground '%s': move_cost >= 1 and max_level 1-2 required" % id)
	for id in props:
		var p: PropDef = props[id]
		if p.hp < 1:
			problems.append("prop '%s': every prop needs at least 1 HP" % id)
		if p.ground_left != &"" and not grounds.has(p.ground_left):
			problems.append("prop '%s' leaves unknown ground '%s'" % [id, p.ground_left])
		if p.ground_left != &"" and not p.on_ground():
			problems.append("prop '%s': air props never change ground" % id)
		for a in p.aftermath:
			if a.op == "spawn" and not props.has(a.spawn_prop):
				problems.append("prop '%s' spawns unknown prop '%s'" % [id, a.spawn_prop])
	for id in zones:
		var z: BattleZoneDef = zones[id]
		if z.effects.is_empty():
			problems.append("zone '%s' has no effects" % id)
		for e in z.effects:
			if not e.affects_ground and not e.affects_air:
				problems.append("zone '%s': effect '%s' authors no recipient layer" % [id, e.tag])
	for id in skills:
		_validate_skill(skills[id])
	for id in monsters:
		var m: MonsterDef = monsters[id]
		if m.skills.is_empty() or m.skills.size() > 4:
			problems.append("monster '%s' needs 1-4 kit slots" % id)
		var active := 0
		for s in m.skills:
			if s == null:
				problems.append("monster '%s' has an empty kit slot" % id)
				continue
			if s.is_active():
				active += 1
			if ContentStatus.in_game(m) and not ContentStatus.in_game(s):
				problems.append("monster '%s' holds the test-only or simulation-only skill '%s'" % [id, s.id])
		if active == 0:
			problems.append("monster '%s' needs at least one active skill" % id)


func _validate_skill(s: BattleSkillDef) -> void:
	var where := "skill '%s'" % s.id
	if not [BattleSkillDef.STRIKE, BattleSkillDef.SURGE, BattleSkillDef.TRAP, BattleSkillDef.ZONE, BattleSkillDef.GROUND,
			BattleSkillDef.MOVE, BattleSkillDef.BUFF, BattleSkillDef.PASSIVE].has(s.kind):
		problems.append(where + " states no valid kind")
	if s.display_name.is_empty():
		problems.append(where + " has no display_name")
	if s.is_active() and s.ap_cost < 1:
		problems.append(where + ": an active skill costs at least 1 AP")
	if s.is_placed() and s.anchor_mode != "caster_ring" and s.footprint.is_empty():
		problems.append(where + " needs an explicit footprint")
	var seen := {}
	for o in s.footprint:
		if seen.has(o):
			problems.append(where + " lists a footprint offset twice")
		seen[o] = true
	match s.kind:
		BattleSkillDef.STRIKE:
			if not StrikeShapes.has(StringName(s.strike_shape)):
				problems.append(where + " uses unknown Strike shape '%s'" % s.strike_shape)
			if s.strike_damage < 0 or s.strike_damage > KinRules.STRIKE_DAMAGE:
				problems.append(where + ": Strike damage is 0-2 (damage law)")
		BattleSkillDef.SURGE, BattleSkillDef.TRAP:
			if s.surge_damage < 0:
				problems.append(where + " has negative Surge damage")
		BattleSkillDef.ZONE:
			if s.zone == null:
				problems.append(where + " is a zone skill without a zone")
			if s.duration < 1:
				problems.append(where + " needs a duration of at least 1 round")
		BattleSkillDef.GROUND:
			if s.board_ops.is_empty():
				problems.append(where + " is a board skill without board operations")
		BattleSkillDef.BUFF:
			if s.buff_effects.is_empty():
				problems.append(where + " is a self buff without effects")
	for op in s.board_ops:
		if op.op == BoardOp.GROUND and not grounds.has(op.ground):
			problems.append(where + " lays unknown ground '%s'" % op.ground)
		if op.op == BoardOp.CREATE_PROP and not props.has(op.prop):
			problems.append(where + " creates unknown prop '%s'" % op.prop)
	for g in s.ignores_grounds:
		if not grounds.has(g):
			problems.append(where + " ignores unknown ground '%s'" % g)


## Stable fingerprint of every loaded definition the game can field: equal fingerprints mean
## equal content, so a recorded battle can state which content it was played with. Test-only
## and simulation-only records and the status label itself are left out; a run on test builds names its builds instead.
func fingerprint() -> String:
	var parts: PackedStringArray = [VERSION]
	for table: Dictionary in [grounds, props, zones, skills, tamer, monsters]:
		for id in sorted_ids(table):
			if ContentStatus.in_game(table[id]):
				parts.append(_describe(table[id]))
	return "\n".join(parts).sha256_text()


## The ids of a definition table in alphabetical order. StringNames do not sort by their text
## (`Array.sort()` orders them by an internal value that changes with whatever else is loaded),
## so a fingerprint built on that order would differ between tools for the same content.
static func sorted_ids(table: Dictionary) -> Array:
	var ids := table.keys()
	ids.sort_custom(func(a: StringName, c: StringName) -> bool: return String(a) < String(c))
	return ids


static func _describe(res: Resource) -> String:
	if res == null:
		return "null"
	var parts: PackedStringArray = []
	for p in res.get_property_list():
		if not (p["usage"] & PROPERTY_USAGE_SCRIPT_VARIABLE) or not (p["usage"] & PROPERTY_USAGE_STORAGE):
			continue
		if p["name"] == "content_status" or p["name"] == "internal_calc_cost":
			continue                          # labels and authoring numbers are not rules
		var v = res.get(p["name"])
		parts.append("%s=%s" % [p["name"], _describe_value(v)])
	return "{%s}" % ";".join(parts)


static func _describe_value(v) -> String:
	if v is Resource:
		return _describe(v)
	if v is Array:
		var items: PackedStringArray = []
		for x in v:
			items.append(_describe_value(x))
		return "[%s]" % ",".join(items)
	return var_to_str(v)
