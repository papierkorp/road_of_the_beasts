class_name KinDef
extends Resource
## What a Kin gives its monsters (docs/monsters.md §3, drafts of docs/content.md §7): one trait no other Kin has,
## the skill groups it can learn and a pool of gifts. One file per Kin: res://data/kins/<kin>.tres.
## Trait, groups and gifts are shown in the hub; the battle does not read them yet.

const DIR := "res://data/kins/"
const GROUPS: Array[String] = ["strike", "movement", "self", "ground", "zone", "prop"]

@export var id: StringName
@export var display_name: String
@export var trait_name: String
@export_multiline var trait_text: String
## The skill groups its monsters can learn (four of GROUPS).
@export var learns: PackedStringArray = []
## {"id": StringName, "name": String, "text": String}
@export var gifts: Array[Dictionary] = []

static var _cache := {}


static func of(kin: MonsterDef.Kin) -> KinDef:
	var key := String(MonsterDef.Kin.keys()[kin]).to_lower()
	if not _cache.has(key):
		var path := DIR + key + ".tres"
		_cache[key] = load(path) if ResourceLoader.exists(path) else null
	return _cache[key]


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
	return "%s (%s)" % [g["name"], g["text"]] if not g.is_empty() else String(gift_id)
