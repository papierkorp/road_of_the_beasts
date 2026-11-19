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
			elif parts[0] == "faction":
				assert_bool(FactionCatalog.DATA.has(StringName(parts[1]))).is_true()


func test_walls_stop_and_slide() -> void:
	var m := DistrictMap.of(&"guild")
	var p := Vector2(20, 20)
	assert_object(m.move(p, Vector2(0.5, 0))).is_equal(Vector2(20.5, 20))
	# towards the left edge: never leaves the district
	var q := Vector2(12, 24)
	for i in 100:
		q = m.move(q, Vector2(-0.5, 0))
	assert_float(q.x).is_greater_equal(DistrictMap.PLAYER_RADIUS - 0.001)
	# sliding along the city gate (south wall): the blocked axis stops, the free one continues
	var slid := m.move(Vector2(19.0, 27.9), Vector2(0.5, 0.5))
	assert_float(slid.x).is_greater(19.0)
	assert_float(slid.y).is_equal_approx(27.9, 0.001)
	assert_bool(m.blocked(Vector2(20, 29))).is_true()


func test_the_traders_can_be_used_when_standing_in_front() -> void:
	var m := DistrictMap.of(&"guild")
	var front := Vector2(9.8, 15.5)                     # east of Trader's Row, the building in the west slot
	assert_str(String(m.nearest_action(front)["action"])).is_equal("panel:market")
	assert_bool(m.nearest_action(Vector2(20, 20)).is_empty()).is_true()


func test_the_hub_leads_into_every_area_and_an_unknown_id_gives_the_hub() -> void:
	var hub := DistrictMap.of(&"nowhere")
	assert_str(String(hub.id)).is_equal("city")
	var targets := {}
	for t in hub.things:
		if String(t["action"]).begins_with("goto:"):
			targets[String(t["action"]).trim_prefix("goto:")] = true
	for id in DistrictMap.ids():
		if id != &"city":
			assert_bool(targets.has(String(id))).is_true()


func test_every_building_without_a_function_says_what_it_is_for() -> void:
	for id in DistrictMap.ids():
		for t in DistrictMap.of(id).things:
			var parts := String(t["action"]).split(":")
			if parts[0] == "info":
				var d := CityAreas.info(StringName(parts[1]))
				assert_str(String(d.get("name", ""))).is_equal(t["name"])
				assert_str(String(d.get("text", ""))).is_not_empty()
	assert_bool(CityAreas.info(&"guild.nothing").is_empty()).is_true()


func test_a_wild_area_has_three_zones_with_resources_and_the_taken_ones_are_gone() -> void:
	for id: StringName in CityAreas.WILDS:
		var m := DistrictMap.of(id)
		assert_int(m.zones.size()).is_equal(3)
		var nodes: Array[Dictionary] = []
		for t in m.things:
			if t.has("node"):
				nodes.append(t)
				var zone: Dictionary = m.zones[int(String(t["id"]).split("/")[1])]
				assert_bool((zone["rect"] as Rect2).has_point(t["pos"])).is_true()
				assert_int(int(t["node"]["stage"])).is_equal(int(zone["stage"]))
				assert_str(ItemCatalog.display_name(t["node"]["item"])).is_not_empty()
		assert_int(nodes.size()).is_equal(12)
		assert_object(DistrictMap.of(id).things).is_equal(m.things)         # the layout is always the same
		m.remove_taken({String(nodes[0]["id"]): 1})
		assert_bool(m.things.has(nodes[0])).is_false()
		assert_bool(m.things.has(nodes[1])).is_true()


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
