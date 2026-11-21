class_name BattlegroundJob
extends RefCounted
## What the map editor edits when the hub opens it for the player's own battleground (docs/battle_ingame.md §3):
## the map, the parts the player owns and the limits. The limits are test values of the hub game (T56).

var map: MapDef
## Part id -> number owned ("ground:<id>", "prop:<id>", "zone:<id>").
var parts := {}
var budget := 0
## What a placed part counts toward the budget: ground, dragon_vein, prop, zone.
var weights := {}
var min_side := MapDef.MIN_SIDE
var max_side := MapDef.MAX_SIDE
## Free squares the start area of the opponent needs at least.
var enemy_starts := 1
var return_scene := ""
## Set by the editor when the player saved a legal battleground.
var saved := false


static func part_of_ground(id: StringName) -> String:
	return "ground:%s" % id


## The parts a map uses: part id -> number.
static func used(m: MapDef) -> Dictionary:
	var out := {}
	for p: Vector2i in m.grounds:
		var k := "ground:%s" % m.grounds[p]
		out[k] = int(out.get(k, 0)) + 1
	for p: Vector2i in m.props:
		var k2 := "prop:%s" % m.props[p]
		out[k2] = int(out.get(k2, 0)) + 1
	for p: Vector2i in m.zones:
		var k3 := "zone:%s" % m.zones[p].get("zone", &"")
		out[k3] = int(out.get(k3, 0)) + 1
	return out


func weight_of(part: String) -> int:
	if part == "ground:dragon_vein":
		return int(weights.get("dragon_vein", 0))
	return int(weights.get(part.get_slice(":", 0), 0))


func cost(m: MapDef) -> int:
	var sum := 0
	var u := used(m)
	for part in u:
		sum += weight_of(part) * int(u[part])
	return sum


## Whether every free square of the opponent's start area reaches the player's start area over squares that exist
## and hold no solid prop.
static func enemy_reaches_player(m: MapDef, content: BattleContent) -> bool:
	var goals := m.free_starts(content, 0)
	var from := m.free_starts(content, 1)
	if goals.is_empty() or from.is_empty():
		return false
	var seen := {}
	var open: Array[Vector2i] = [goals[0]]
	seen[goals[0]] = true
	while not open.is_empty():
		var p: Vector2i = open.pop_back()
		for d: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var q := p + d
			if seen.has(q) or not m.has_square(q):
				continue
			var prop: PropDef = content.prop(m.props[q]) if m.props.has(q) else null
			if prop != null and prop.solid:
				continue
			seen[q] = true
			open.append(q)
	for p in from:
		if not seen.has(p):
			return false
	return true


## What keeps the map from being the player's battleground ([] = legal).
func problems(m: MapDef, content: BattleContent) -> PackedStringArray:
	var out := m.problems(content)
	if m.width < min_side or m.height < min_side or m.width > max_side or m.height > max_side:
		out.append("width and height must lie between %d and %d" % [min_side, max_side])
	var u := used(m)
	for part in u:
		if int(u[part]) > int(parts.get(part, 0)):
			out.append("%s: %d placed, %d owned" % [part.get_slice(":", 1).capitalize(), int(u[part]), int(parts.get(part, 0))])
	if cost(m) > budget:
		out.append("budget: %d of %d used" % [cost(m), budget])
	if m.free_starts(content, 1).size() < enemy_starts:
		out.append("the start area of the opponent needs %d free squares" % enemy_starts)
	if out.is_empty() and not enemy_reaches_player(m, content):
		out.append("the opponent cannot reach your start area")
	return out
