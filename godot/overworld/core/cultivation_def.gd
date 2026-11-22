class_name CultivationDef
extends Resource
## A Way the player chooses at the start (docs/vision.md §8, docs/overworld.md §5.3):
## res://data/cultivation/<id>.tres. A tree per stage; a node is bought with Insight. Test content (T57).

const DIR := "res://data/cultivation"

@export var id: StringName
@export var display_name: String = ""
@export_multiline var blurb: String = ""
## The two branches of its trees: {"id", "name", "text"}. The Insight of a stage buys about one of them.
@export var branches: Array = []
## {"id", "stage" (the tree it belongs to), "branch", "name", "kind": "tamer", "ref": tamer skill id,
## "cost": Insight, "needs": id of the node that must be bought first, or ""}. A development step of a tamer skill
## is a node by the rules, but is not built.
@export var nodes: Array = []

static var _all := {}


static func ids() -> Array[StringName]:
	_ensure()
	var out: Array[StringName] = []
	for k in _all:
		out.append(k)
	out.sort_custom(func(a: StringName, b: StringName) -> bool: return String(a) < String(b))
	return out


static func of(system: StringName) -> CultivationDef:
	_ensure()
	return _all.get(system)


static func _ensure() -> void:
	if not _all.is_empty():
		return
	var files := ResourceLoader.list_directory(DIR)
	for f in files:
		var file := String(f).trim_suffix(".remap")
		if file.ends_with(".tres"):
			var def := load(DIR.path_join(file)) as CultivationDef
			if def != null:
				_all[def.id] = def


func node(node_id: StringName) -> Dictionary:
	for n: Dictionary in nodes:
		if StringName(n["id"]) == node_id:
			return n
	return {}


func nodes_of(stage: int) -> Array:
	return nodes.filter(func(n: Dictionary) -> bool: return int(n["stage"]) == stage)
