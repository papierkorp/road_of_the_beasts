class_name WildRoamer
extends RefCounted
## A visible wild monster in a dungeon room (gdd_overworld §6.2): wanders around and chases the
## player once they come close. Touching it starts the battle — there are no random encounters.
## Pure movement on a DistrictMap, no nodes.

const WANDER_SPEED := 1.2
const CHASE_SPEED := 2.6
const AGGRO_RADIUS := 4.0
const LOSE_RADIUS := 5.6            # a chaser gives up a little later than it noticed you
const TOUCH_RADIUS := 0.85
const BODY_RADIUS := 0.3

var pos := Vector2.ZERO
var facing := Vector2.ZERO          # direction of the last move (zero until it moved)
var target := Vector2.ZERO
var wait := 0.0
var chasing := false


static func create(at: Vector2, map: DistrictMap, rng: RandomNumberGenerator) -> WildRoamer:
	var r := WildRoamer.new()
	r.pos = at
	r.target = map.random_free_point(rng)
	r.wait = rng.randf_range(0.0, 2.0)
	return r


func touches(player: Vector2) -> bool:
	return pos.distance_to(player) <= TOUCH_RADIUS


func update(delta: float, map: DistrictMap, player: Vector2, rng: RandomNumberGenerator) -> void:
	var to_player := player - pos
	var limit := LOSE_RADIUS if chasing else AGGRO_RADIUS
	chasing = to_player.length() <= limit
	if chasing:
		_step(to_player.normalized(), CHASE_SPEED * delta, map)
		return
	if wait > 0.0:
		wait -= delta
		return
	var to_target := target - pos
	if to_target.length() < 0.15:
		wait = rng.randf_range(1.0, 3.0)
		target = map.random_free_point(rng)
		return
	if not _step(to_target.normalized(), minf(to_target.length(), WANDER_SPEED * delta), map):
		target = map.random_free_point(rng)          # stuck behind something


func _step(dir: Vector2, distance: float, map: DistrictMap) -> bool:
	var next := map.move(pos, dir * distance, BODY_RADIUS)
	if next == pos:
		return false
	facing = (next - pos).normalized()
	pos = next
	return true
