class_name DistrictMap
extends RefCounted
## The layout of one walkable city district (gdd_overworld §6.1): a small flat area with solid
## buildings and gates. Pure geometry on the ground plane (x, z), no nodes — the scene only draws
## it. Movement slides along walls; `nearest_action` tells what the player can use right now.
##
## Actions (a StringName on a thing): "panel:<place>" opens a PlacePanel, "faction:<id>" a FavorPanel,
## "goto:<area>" leads to another area, "info:<district>.<building>" says what a building is for,
## "take:<key>" takes a resource of a wild area, "locked:<place>" is announced but closed. Empty = decoration.
## The areas of the city are laid out in CityAreas; the Internal World and the dungeon room here.

const PLAYER_RADIUS := 0.35
const REACH := 1.3

var id: StringName
var title := ""
var size := Vector2(16, 12)
var ground := Color(0.30, 0.28, 0.26)
## {id, name, pos (centre), size, height, color, solid, action, label}
var things: Array[Dictionary] = []
## Where the player appears, by where they came from ("start" is the default).
var arrivals := {}
## The zones of a wild area: {name, stage, rect}. Empty anywhere else.
var zones: Array[Dictionary] = []
## Open sky above, or a closed dark place.
var sky := true


## A dungeon room: entrance (leave portal) on the west, doors to the next nodes on the east and a
## few pillars. The same seed gives the same room. `doors`: [{id: node id, label}].
static func room(seed_value: int, doors: Array[Dictionary]) -> DistrictMap:
	var m := DistrictMap.new()
	m.id = &"room"
	m.title = "Dungeon"
	m.size = Vector2(16, 10)
	m.ground = Color(0.18, 0.17, 0.2)
	m.sky = false
	m.arrivals = {&"start": Vector2(2.6, 5.0)}
	m._add("leave", "Teleport out", Vector2(0.8, 5.0), Vector2(1.6, 3.0), 2.0, Color(0.45, 0.35, 0.7), &"leave",
		"Teleport back to the city")
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var slots: Array[Vector2] = [Vector2(6, 2.5), Vector2(6, 7.5), Vector2(9, 3.5), Vector2(9, 6.5), Vector2(12, 2.5), Vector2(12, 7.5)]
	for i in 3:
		var at: Vector2 = slots.pop_at(rng.randi_range(0, slots.size() - 1))
		m._add("pillar_%d" % i, "", at, Vector2(1.0, 1.0), 1.8, Color(0.42, 0.42, 0.46))
	for i in doors.size():
		var y := 5.0 + (float(i) - (doors.size() - 1) / 2.0) * 3.2
		m._add("door_%d" % i, "Door", Vector2(15.2, y), Vector2(1.6, 2.4), 2.0, Color(0.7, 0.5, 0.25),
			StringName("door:%d" % int(doors[i]["id"])), String(doors[i]["label"]))
	return m


static func ids() -> Array[StringName]:
	var out := CityAreas.ids()
	out.append(&"inner")
	return out


## The area with this id; an unknown id gives the hub of the city (CityAreas).
static func of(district_id: StringName) -> DistrictMap:
	if district_id != &"inner":
		return CityAreas.build(district_id)
	# the grid area (BuildGrid) is free ground; the strip below holds the stone and the gate
	var m := DistrictMap.new()
	m.id = &"inner"
	m.title = "Internal World"
	m.size = Vector2(16, 13)
	m.ground = Color(0.20, 0.27, 0.22)
	m.arrivals = {&"start": Vector2(8, 10.9), &"city": Vector2(8, 10.9)}
	m._add("stone", "Cultivation Stone", Vector2(12.6, 11.2), Vector2(1.6, 1.6), 1.2, Color(0.55, 0.62, 0.75), &"panel:inner", "Look at your monsters")
	m._add("gate", "Return to the city", Vector2(8, 12.2), Vector2(3.6, 1.0), 2.0, Color(0.35, 0.55, 0.75), &"goto:city", "Return to the city")
	return m


## A flat patch of ground that blocks nothing (the zone of a wild area).
func _patch(thing_id: String, thing_name: String, rect: Rect2, color: Color) -> void:
	things.append({"id": thing_id, "name": thing_name, "pos": rect.get_center(), "size": rect.size, "height": 0.04,
		"color": color, "solid": false, "action": &"", "label": "", "patch": true})


## Leaves out the resources the player took and that have not come back yet (GameState.taken).
func remove_taken(taken: Dictionary) -> void:
	things = things.filter(func(t: Dictionary) -> bool: return not (t.has("node") and taken.has(String(t["id"]))))


## The structures the player built in the Inner World become solid things you can use.
func add_structures(structures: Array[Dictionary]) -> void:
	for s in structures:
		var d := StructureCatalog.def(StringName(s["id"]))
		var r := BuildGrid.world_rect(d, Vector2i(int(s["x"]), int(s["y"])), bool(s["rot"]))
		_add("s%d" % int(s["uid"]), d.display_name, r.get_center(), r.size - Vector2(0.3, 0.3), d.height, d.color,
			StringName("structure:%d" % int(s["uid"])), "Use the %s" % d.display_name)


func _add(thing_id: String, thing_name: String, pos: Vector2, thing_size: Vector2, height: float, color: Color,
		action: StringName = &"", label := "") -> void:
	things.append({"id": thing_id, "name": thing_name, "pos": pos, "size": thing_size, "height": height,
		"color": color, "solid": true, "action": action, "label": label})


func spawn_for(from: StringName) -> Vector2:
	return arrivals.get(from, arrivals[&"start"])


## Distance from a point to the rectangle of a thing (0 inside).
static func distance_to(thing: Dictionary, p: Vector2) -> float:
	var half: Vector2 = thing["size"] / 2.0
	var d: Vector2 = (p - thing["pos"]).abs() - half
	return Vector2(maxf(d.x, 0.0), maxf(d.y, 0.0)).length()


func blocked(p: Vector2, radius := PLAYER_RADIUS) -> bool:
	if p.x < radius or p.y < radius or p.x > size.x - radius or p.y > size.y - radius:
		return true
	for t in things:
		if t["solid"] and distance_to(t, p) < radius:
			return true
	return false


## Moves by `delta` and slides along walls: full step, else along x only, else along z only.
func move(from: Vector2, delta: Vector2, radius := PLAYER_RADIUS) -> Vector2:
	var to := from + delta
	if not blocked(to, radius):
		return to
	var along_x := Vector2(to.x, from.y)
	if not blocked(along_x, radius):
		return along_x
	var along_z := Vector2(from.x, to.y)
	if not blocked(along_z, radius):
		return along_z
	return from


## The closest usable thing within reach of the player, or an empty dictionary.
func nearest_action(p: Vector2, reach := REACH) -> Dictionary:
	var best := {}
	var best_d := reach
	for t in things:
		if t["action"] == &"":
			continue
		var d := distance_to(t, p)
		if d <= best_d:
			best_d = d
			best = t
	return best


## A free spot away from everything (for wandering monsters).
func random_free_point(rng: RandomNumberGenerator, radius := 0.5, region := Rect2()) -> Vector2:
	var area := region if region.has_area() else Rect2(Vector2.ZERO, size)
	for i in 40:
		var p := Vector2(rng.randf_range(area.position.x + radius, area.end.x - radius),
			rng.randf_range(area.position.y + radius, area.end.y - radius))
		if not blocked(p, radius + 0.2):
			return p
	return size / 2.0
