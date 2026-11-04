extends GdUnitTestSuite
## Visible dungeon (gdd_overworld §6.2): ambush geometry, roaming wild monsters, room layouts.

const STEP := 0.3


func _rng(seed_value := 12) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng


func _doors(n: int) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for i in n:
		out.append({"id": 10 + i, "label": "Door %d" % i})
	return out


func _reachable(m: DistrictMap, from: Vector2) -> Dictionary:
	var seen := {}
	var queue: Array[Vector2i] = [Vector2i(roundi(from.x / STEP), roundi(from.y / STEP))]
	seen[queue[0]] = true
	while not queue.is_empty():
		var c: Vector2i = queue.pop_back()
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var n: Vector2i = c + d
			if seen.has(n) or m.blocked(Vector2(n.x, n.y) * STEP):
				continue
			seen[n] = true
			queue.append(n)
	return seen


# ---------- ambush ----------

func test_hitting_a_monster_from_behind_is_a_player_ambush() -> void:
	# the monster walks to +x, the player stands behind it
	assert_int(Encounter.ambush_side(Vector2(4, 5), Vector2(1, 0), Vector2(5, 5), Vector2(1, 0))).is_equal(0)


func test_being_caught_from_behind_is_an_enemy_ambush() -> void:
	# the player runs away to -x while the monster chases them
	assert_int(Encounter.ambush_side(Vector2(4, 5), Vector2(-1, 0), Vector2(5, 5), Vector2(-1, 0))).is_equal(1)


func test_a_head_on_meeting_gives_nobody_the_first_move() -> void:
	assert_int(Encounter.ambush_side(Vector2(4, 5), Vector2(1, 0), Vector2(5, 5), Vector2(-1, 0))).is_equal(-1)


func test_unknown_facing_is_never_behind() -> void:
	assert_int(Encounter.ambush_side(Vector2(4, 5), Vector2.ZERO, Vector2(5, 5), Vector2.ZERO)).is_equal(-1)


# ---------- roamers ----------

func test_a_roamer_wanders_and_never_leaves_free_ground() -> void:
	var m := DistrictMap.room(3, _doors(2))
	var rng := _rng()
	var r := WildRoamer.create(Vector2(11, 5), m, rng)
	var far_player := Vector2(1.5, 9.0)
	var start := r.pos
	var moved := false
	for i in 2000:
		r.update(0.05, m, far_player, rng)
		assert_bool(m.blocked(r.pos, WildRoamer.BODY_RADIUS - 0.01)).is_false()
		if r.pos.distance_to(start) > 1.0:
			moved = true
		assert_bool(r.chasing).is_false()
	assert_bool(moved).is_true()


func test_a_roamer_chases_a_close_player_and_touches_them() -> void:
	var m := DistrictMap.room(3, _doors(1))
	var rng := _rng()
	var player := Vector2(11, 5)
	var r := WildRoamer.create(Vector2(11, 8), m, rng)
	r.wait = 0.0
	var touched := false
	for i in 400:
		r.update(0.05, m, player, rng)
		if r.touches(player):
			touched = true
			break
	assert_bool(touched).is_true()
	assert_bool(r.chasing).is_true()


func test_a_chaser_gives_up_when_the_player_gets_far_away() -> void:
	var m := DistrictMap.room(3, _doors(1))
	var rng := _rng()
	var r := WildRoamer.create(Vector2(11, 5), m, rng)
	r.update(0.05, m, Vector2(11, 8), rng)
	assert_bool(r.chasing).is_true()
	r.update(0.05, m, Vector2(1.0, 1.0), rng)
	assert_bool(r.chasing).is_false()


# ---------- rooms ----------

func test_a_room_has_a_leave_portal_and_one_door_per_choice() -> void:
	for n in [0, 1, 2]:
		var m := DistrictMap.room(5, _doors(n))
		var doors := 0
		var leave := 0
		for t in m.things:
			if String(t["action"]).begins_with("door:"):
				doors += 1
			elif t["action"] == &"leave":
				leave += 1
		assert_int(doors).is_equal(n)
		assert_int(leave).is_equal(1)


func test_a_door_names_its_node() -> void:
	var m := DistrictMap.room(5, _doors(2))
	var found := {}
	for t in m.things:
		if String(t["action"]).begins_with("door:"):
			found[String(t["action"])] = t["label"]
	assert_str(found["door:10"]).is_equal("Door 0")
	assert_str(found["door:11"]).is_equal("Door 1")


func test_the_same_seed_gives_the_same_room() -> void:
	var a := DistrictMap.room(9, _doors(2))
	var b := DistrictMap.room(9, _doors(2))
	assert_int(a.things.size()).is_equal(b.things.size())
	for i in a.things.size():
		assert_object(a.things[i]["pos"]).is_equal(b.things[i]["pos"])


func test_every_door_and_the_portal_can_be_reached_from_the_entrance() -> void:
	for seed_value in 20:
		for n in [0, 1, 2]:
			var m := DistrictMap.room(seed_value, _doors(n))
			var seen := _reachable(m, m.spawn_for(&"start"))
			assert_bool(m.blocked(m.spawn_for(&"start"))).is_false()
			for t in m.things:
				if t["action"] == &"":
					continue
				var ok := false
				for c in seen:
					if DistrictMap.distance_to(t, Vector2(c.x, c.y) * STEP) <= DistrictMap.REACH:
						ok = true
						break
				assert_bool(ok).is_true()


func test_there_is_room_for_wild_monsters_in_the_east() -> void:
	var m := DistrictMap.room(4, _doors(0))
	var rng := _rng()
	for i in 30:
		var p := m.random_free_point(rng, 0.5, Rect2(8.0, 1.0, 7.0, 8.0))
		assert_float(p.x).is_greater_equal(8.0)
		assert_bool(m.blocked(p, 0.5)).is_false()


# ---------- notes ----------

func test_the_result_note_tells_loot_and_the_end_of_the_run() -> void:
	var g := GameState.new_game(_rng())
	var e := Expedition.generate(g, _rng())
	var win := BattleResult.new()
	win.over = true
	win.winner_side = 0
	win.player.append({"species": &"blaze_tiger", "index": 0, "hp_left": 3, "max_hp": 4, "alive": true})
	e.select(e.choices()[0])
	e.request_for(g)
	var before := e.current
	e.apply_result(g, win)
	var note := e.result_note(before)
	assert_str(note).contains("Victory")
	assert_str(note).contains("Loot:")
	var lose := BattleResult.new()
	lose.over = true
	lose.winner_side = 1
	lose.player.append({"species": &"blaze_tiger", "index": 0, "hp_left": 0, "max_hp": 4, "alive": false})
	e.select(e.choices()[0])
	e.request_for(g)
	var before2 := e.current
	e.apply_result(g, lose)
	assert_str(e.result_note(before2)).contains("team fell")
