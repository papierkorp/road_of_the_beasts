extends GdUnitTestSuite
## Walkable district layouts (gdd_overworld §6.1): geometry, wiring between districts, reachability.

const STEP := 0.3


func _reachable(m: DistrictMap, from: Vector2) -> Dictionary:
	var seen := {}
	var queue: Array[Vector2i] = [Vector2i(roundi(from.x / STEP), roundi(from.y / STEP))]
	seen[queue[0]] = true
	while not queue.is_empty():
		var c: Vector2i = queue.pop_back()
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var n: Vector2i = c + d
			if seen.has(n):
				continue
			if m.blocked(Vector2(n.x, n.y) * STEP):
				continue
			seen[n] = true
			queue.append(n)
	return seen


func test_every_district_has_a_start_and_free_arrival_points() -> void:
	for id in DistrictMap.ids():
		var m := DistrictMap.of(id)
		assert_str(String(m.id)).is_equal(String(id))
		assert_bool(m.arrivals.has(&"start")).is_true()
		for from in m.arrivals:
			assert_bool(m.blocked(m.arrivals[from])).is_false()


func test_things_lie_inside_the_district() -> void:
	for id in DistrictMap.ids():
		var m := DistrictMap.of(id)
		for t in m.things:
			var half: Vector2 = t["size"] / 2.0
			var p: Vector2 = t["pos"]
			assert_float(p.x - half.x).is_greater_equal(-0.01)
			assert_float(p.y - half.y).is_greater_equal(-0.01)
			assert_float(p.x + half.x).is_less_equal(m.size.x + 0.01)
			assert_float(p.y + half.y).is_less_equal(m.size.y + 0.01)


func test_gates_lead_somewhere_and_back() -> void:
	for id in DistrictMap.ids():
		var m := DistrictMap.of(id)
		for t in m.things:
			var parts := String(t["action"]).split(":")
			if parts[0] == "goto":
				var target := StringName(parts[1])
				assert_bool(DistrictMap.ids().has(target)).is_true()
				assert_bool(DistrictMap.of(target).arrivals.has(id)).is_true()
			elif parts[0] == "panel":
				assert_bool(PlacePanel.is_built(StringName(parts[1]))).is_true()


func test_walls_stop_and_slide() -> void:
	var m := DistrictMap.of(&"plaza")
	var p := Vector2(8, 9)
	assert_object(m.move(p, Vector2(0.5, 0))).is_equal(Vector2(8.5, 9))
	# towards the left edge: never leaves the district
	var q := p
	for i in 100:
		q = m.move(q, Vector2(-0.5, 0))
	assert_float(q.x).is_greater_equal(DistrictMap.PLAYER_RADIUS - 0.001)
	# sliding along the clan gate (south wall): the blocked axis stops, the free one continues
	var edge := Vector2(8, 11.65 - 0.0)
	var slid := m.move(Vector2(6.0, 10.4), Vector2(0.5, 0.5))
	assert_float(slid.x).is_greater(6.0)
	assert_bool(m.blocked(edge)).is_true()


func test_the_trader_can_be_used_when_standing_in_front() -> void:
	var m := DistrictMap.of(&"market")
	assert_bool(m.nearest_action(Vector2(7, 4.4)).is_empty()).is_false()
	assert_str(String(m.nearest_action(Vector2(7, 4.4))["action"])).is_equal("panel:market")
	assert_bool(m.nearest_action(Vector2(7, 9)).is_empty()).is_true()


func test_every_usable_thing_can_be_reached_on_foot() -> void:
	for id in DistrictMap.ids():
		var m := DistrictMap.of(id)
		var seen := _reachable(m, m.spawn_for(&"start"))
		for t in m.things:
			if t["action"] == &"":
				continue
			var ok := false
			for c in seen:
				if DistrictMap.distance_to(t, Vector2(c.x, c.y) * STEP) <= DistrictMap.REACH:
					ok = true
					break
			assert_bool(ok).is_true()


func test_every_arrival_point_is_connected_to_the_rest() -> void:
	for id in DistrictMap.ids():
		var m := DistrictMap.of(id)
		var seen := _reachable(m, m.spawn_for(&"start"))
		for from in m.arrivals:
			var a: Vector2 = m.arrivals[from]
			assert_bool(seen.has(Vector2i(roundi(a.x / STEP), roundi(a.y / STEP)))).is_true()


func test_a_random_free_point_is_not_blocked() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	for id in DistrictMap.ids():
		var m := DistrictMap.of(id)
		for i in 20:
			assert_bool(m.blocked(m.random_free_point(rng), 0.5)).is_false()
