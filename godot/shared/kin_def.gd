class_name KinDef
extends Resource
## What a Kin gives its monsters (docs/monsters.md §3, drafts of docs/content.md §7): one trait no other Kin has,
## the skill groups it can learn and a pool of gifts. One file per Kin: res://data/kins/<kin>.tres.
## The trait and the gifts that name `flags` act in the ingame battle as passives without a slot (the flags are
## fields of BattleSkillDef); a gift without flags is stored and shown only. The groups are not checked yet.

const DIR := "res://data/kins/"
const GROUPS: Array[String] = ["strike", "movement", "self", "ground", "zone", "prop"]

@export var id: StringName
@export var display_name: String
@export var trait_name: String
@export_multiline var trait_text: String
## Fields of BattleSkillDef the trait sets on its passive.
@export var trait_flags: Dictionary = {}
## The skill groups its monsters can learn (four of GROUPS).
@export var learns: PackedStringArray = []
## {"id": StringName, "name": String, "text": String, "flags": Dictionary (optional)}
@export var gifts: Array[Dictionary] = []

static var _cache := {}


static func of(kin: MonsterDef.Kin) -> KinDef:
	var key := String(MonsterDef.Kin.keys()[kin]).to_lower()
	if not _cache.has(key):
		var path := DIR + key + ".tres"
		_cache[key] = load(path) if ResourceLoader.exists(path) else null
	return _cache[key]


## The groups a skill belongs to: what it is (a Strike, a movement, an effect on its user) or, for a skill that
## only lays something, everything it creates (ground, zone, prop). A monster learns it if its Kin learns them all.
static func groups_of(s: BattleSkillDef) -> PackedStringArray:
	match s.kind:
		BattleSkillDef.STRIKE:
			return ["strike"]
		BattleSkillDef.MOVE:
			return ["movement"]
		BattleSkillDef.BUFF, BattleSkillDef.PASSIVE:
			return ["self"]
		BattleSkillDef.ZONE:
			return ["zone"]
		BattleSkillDef.TRAP:
			return ["prop"]
	var out: PackedStringArray = []
	for op in s.board_ops:
		for pair: Array in [[op.prop, "prop"], [op.zone, "zone"], [op.ground, "ground"]]:
			if pair[0] != &"" and not out.has(pair[1]):
				out.append(pair[1])
	return out if not out.is_empty() else PackedStringArray(["ground"])


func can_learn(s: BattleSkillDef) -> bool:
	for g in groups_of(s):
		if not learns.has(g):
			return false
	return true


func gift(gift_id: StringName) -> Dictionary:
	for g: Dictionary in gifts:
		if StringName(g["id"]) == gift_id:
			return g
	return {}


func trait_line() -> String:
	return "%s: %s" % [trait_name, trait_text]


func never_learns() -> PackedStringArray:
	var out: PackedStringArray = []
	for g in GROUPS:
		if not learns.has(g):
			out.append(g)
	return out


static func gift_line(kin: MonsterDef.Kin, gift_id: StringName) -> String:
	var def := of(kin)
	var g: Dictionary = def.gift(gift_id) if def != null else {}
	if g.is_empty():
		return String(gift_id)
	return "%s (%s%s)" % [g["name"], g["text"], "" if not (g.get("flags", {}) as Dictionary).is_empty() else "; not built"]


## The passives a monster of this Kin has without a slot: its trait and the given gifts, as far as they are built.
func passives(gift_ids: Array[StringName]) -> Array[BattleSkillDef]:
	var out: Array[BattleSkillDef] = []
	if not trait_flags.is_empty():
		out.append(_passive(StringName("trait_%s" % id), trait_name, trait_text, trait_flags))
	for gid in gift_ids:
		var g := gift(gid)
		var flags: Dictionary = g.get("flags", {})
		if not flags.is_empty():
			out.append(_passive(StringName("gift_%s" % gid), g["name"], g["text"], flags))
	return out


## A passive without a slot from a name, a text and flags (fields of BattleSkillDef): traits and gifts.
static func make_passive(p_id: StringName, p_name: String, text: String, flags: Dictionary) -> BattleSkillDef:
	return _passive(p_id, p_name, text, flags)


static func _passive(p_id: StringName, p_name: String, text: String, flags: Dictionary) -> BattleSkillDef:
	var s := BattleSkillDef.new()
	s.id = p_id
	s.display_name = p_name
	s.description = text
	s.kind = BattleSkillDef.PASSIVE
	for key: String in flags:
		var value = flags[key]
		if s.get(key) is Array:
			(s.get(key) as Array).assign(value)
		else:
			s.set(key, value)
	return s
