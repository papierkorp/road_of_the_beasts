class_name MapDef
extends Resource
## A battleground of the ingame battle (docs/battle_ingame.md §3), made in the map editor. Lives in
## res://data/maps/<id>.tres. A rectangle of `width` × `height` squares, less the `missing` ones; what lies on it,
## and where each side may place its monsters. Coordinates count from the top left square of the rectangle.

const DIR := "res://data/maps"
const MIN_SIDE := 3
const MAX_SIDE := 12

@export var id: StringName
@export var display_name: String = ""
@export var width: int = 7
@export var height: int = 7
## Squares of the rectangle that are no part of the board.
@export var missing: Array[Vector2i] = []
## Vector2i -> ground id (a Dragon Vein is the ground `dragon_vein`). Squares not named are Plain.
@export var grounds: Dictionary = {}
## Vector2i -> prop id.
@export var props: Dictionary = {}
## Vector2i -> {"zone": id, "dir": Vector2i (a push zone pushes this way), "rounds": int (0 = the whole battle)}.
@export var zones: Dictionary = {}
## Where side 0 (the player) and side 1 may place their monsters.
@export var start_a: Array[Vector2i] = []
@export var start_b: Array[Vector2i] = []


func has_square(p: Vector2i) -> bool:
	return p.x >= 0 and p.y >= 0 and p.x < width and p.y < height and not missing.has(p)


func start_area(side: int) -> Array[Vector2i]:
	return start_a if side == 0 else start_b


## Squares of a start area a monster can stand on, in row order.
func free_starts(content: BattleContent, side: int) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for p in start_area(side):
		if not has_square(p):
			continue
		var prop: PropDef = content.prop(props[p]) if props.has(p) else null
		if prop == null or not prop.solid:
			out.append(p)
	out.sort()
	return out


## What keeps the map from being played ([] = playable).
func problems(content: BattleContent) -> PackedStringArray:
	var out: PackedStringArray = []
	if width < MIN_SIDE or height < MIN_SIDE or width > MAX_SIDE or height > MAX_SIDE:
		out.append("width and height must lie between %d and %d" % [MIN_SIDE, MAX_SIDE])
	for side in 2:
		if free_starts(content, side).is_empty():
			out.append("%s has no free square in its start area" % ("your side" if side == 0 else "the enemy side"))
	for p: Vector2i in start_a:
		if start_b.has(p):
			out.append("square %d, %d lies in both start areas" % [p.x, p.y])
			break
	for p: Vector2i in grounds:
		if content.ground(grounds[p]) == null:
			out.append("unknown ground %s" % grounds[p])
	for p: Vector2i in props:
		if content.prop(props[p]) == null:
			out.append("unknown prop %s" % props[p])
	for p: Vector2i in zones:
		if content.zone(zones[p].get("zone", &"")) == null:
			out.append("unknown zone %s" % zones[p].get("zone", &""))
	return out


## Everything outside the rectangle or on a missing square is dropped (after a change of size or outline).
func trim() -> void:
	for layer: Dictionary in [grounds, props, zones]:
		for p: Vector2i in layer.keys():
			if not has_square(p):
				layer.erase(p)
	for area: Array[Vector2i] in [start_a, start_b]:
		for p: Vector2i in area.duplicate():
			if not has_square(p):
				area.erase(p)
	for p: Vector2i in missing.duplicate():
		if p.x >= width or p.y >= height:
			missing.erase(p)


static func slug(text: String) -> StringName:
	var out := ""
	for ch in text.strip_edges().to_lower():
		out += ch if (ch >= "a" and ch <= "z") or (ch >= "0" and ch <= "9") else "_"
	while out.contains("__"):
		out = out.replace("__", "_")
	return StringName(out.trim_prefix("_").trim_suffix("_"))


## Ids of the saved maps, sorted.
static func ids() -> Array[StringName]:
	var out: Array[StringName] = []
	if DirAccess.dir_exists_absolute(DIR):
		for f in DirAccess.get_files_at(DIR):
			if f.ends_with(".tres"):
				out.append(StringName(f.trim_suffix(".tres")))
	out.sort_custom(func(a: StringName, c: StringName) -> bool: return String(a) < String(c))
	return out


static func load_map(map_id: StringName) -> MapDef:
	var path := "%s/%s.tres" % [DIR, map_id]
	if not ResourceLoader.exists(path):
		return null
	return ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as MapDef


## Writes the map to res://data/maps/<id>.tres: "" or the problem.
func save() -> String:
	if String(id) == "":
		return "the map needs a name"
	DirAccess.make_dir_recursive_absolute(DIR)
	var path := "%s/%s.tres" % [DIR, id]
	var err := ResourceSaver.save(self, path)
	return "" if err == OK else "could not write %s (error %d)" % [path, err]
