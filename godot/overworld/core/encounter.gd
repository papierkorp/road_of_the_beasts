class_name Encounter
extends RefCounted
## Who struck first when the player and a wild monster touch (gdd_overworld §6.2):
## touching a monster from behind gives your side a small round-1 initiative bonus — and the
## same goes for a monster that catches you from behind. Pure geometry on the ground plane.

const BEHIND := -0.2


## 0 = the player attacked from behind, 1 = the monster did, -1 = a head-on meeting.
## `*_facing` is the direction each one last moved (zero = unknown, counts as not behind).
static func ambush_side(player_pos: Vector2, player_facing: Vector2, mon_pos: Vector2, mon_facing: Vector2) -> int:
	var to_player := player_pos - mon_pos
	if to_player.length() < 0.001:
		return -1
	to_player = to_player.normalized()
	# the monster's back is turned to the player
	if mon_facing.length() > 0.01 and mon_facing.normalized().dot(to_player) < BEHIND:
		return 0
	# the player's back is turned to the monster
	if player_facing.length() > 0.01 and player_facing.normalized().dot(-to_player) < BEHIND:
		return 1
	return -1
