class_name DistrictScreen
extends WalkScreen
## A walkable area of the city (docs/overworld.md §3): the hub, a district, a wild area or the Internal World.
## Your first monster follows you; in the Internal World all your monsters wander freely; in a wild area wild
## monsters wander in their zones (they cannot be fought there yet). A building opens a panel, leads to another
## area or says what it is meant for; a resource of a wild area is taken for 1 day AP.

const SCENE := "res://overworld/district.tscn"

const FOLLOW_GAP := 1.3
const WANDER_SPEED := 1.2

var _follower: Node3D
var _follower_pos := Vector2.ZERO
var _wanderers: Array[Dictionary] = []     # {node, pos, target, wait}
var _panel: PlacePanel
var _structures: StructurePanel
var _favor: FavorPanel
var _info: VBoxContainer
var _cursor: MeshInstance3D
var _cursor_mat: StandardMaterial3D


func _make_map() -> DistrictMap:
	var m := DistrictMap.of(GameSession.district)
	GameSession.district = m.id
	if m.id == &"inner":
		m.add_structures(_game.structures)
	m.remove_taken(_game.taken)
	return m


func _spawn_point() -> Vector2:
	if GameSession.resume_pos.x >= 0.0:
		var p := GameSession.resume_pos
		GameSession.resume_pos = Vector2(-1.0, -1.0)
		if not _map.blocked(p):
			return p
	return _map.spawn_for(GameSession.arrive_from)


func _after_ready() -> void:
	_panel = PlacePanel.new()
	_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_panel.setup(_game)
	_panel.changed.connect(_refresh_header)
	_side_body.add_child(_panel)
	_structures = StructurePanel.new()
	_structures.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_structures.setup(_game)
	_structures.visible = false
	_structures.changed.connect(_on_state_changed)
	_structures.place_requested.connect(_on_place_requested)
	_side_body.add_child(_structures)
	_favor = FavorPanel.new()
	_favor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_favor.setup(_game)
	_favor.visible = false
	_favor.changed.connect(_on_state_changed)
	_side_body.add_child(_favor)
	_info = VBoxContainer.new()
	_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_info.add_theme_constant_override("separation", 10)
	_info.visible = false
	_side_body.add_child(_info)
	if _map.id == &"inner":
		_build_overlay()
		if GameSession.build_mode:
			_show_build_panel()
	else:
		GameSession.build_mode = false
	if GameSession.arrive_from == &"start":
		_say("%s%s%s%s to walk, %s to use things. Hold %s and move the mouse to look around, %s / %s to zoom." % [
			UiTheme.key_text(&"walk_up"), UiTheme.key_text(&"walk_left"), UiTheme.key_text(&"walk_down"), UiTheme.key_text(&"walk_right"),
			UiTheme.key_text(&"interact"), UiTheme.key_text(&"world_look"), UiTheme.key_text(&"camera_zoom_in"), UiTheme.key_text(&"camera_zoom_out")], 9.0)
	elif not _map.zones.is_empty():
		_say("Walking is free. Taking a resource costs 1 day AP; it grows back after some nights. A zone above your stage gives nothing.", 7.0)


func _top_buttons() -> Array[Button]:
	var out: Array[Button] = []
	if _map.id == &"inner":
		out.append(hud_button("Build (B)", _toggle_build))
		if GameSession.build_mode:
			out.append(hud_button("Build menu", _show_build_panel))
	out.append(hud_button("End day", _end_day))
	if _map.id != CityAreas.HUB:
		out.append(hud_button("To the city", func(): _go(CityAreas.HUB)))
	out.append(hud_button("Menu", _save_and_menu))
	return out


func _build_actors() -> void:
	if _map.id == &"inner":
		for m in _game.monsters:
			var node := MonsterLook.make_body(m.species())
			add_child(node)
			var start := _map.random_free_point(_rng)
			node.position = Vector3(start.x, 0.0, start.y)
			_wanderers.append({"node": node, "pos": start, "target": _map.random_free_point(_rng), "wait": _rng.randf_range(0.0, 2.0)})
	elif not _game.monsters.is_empty():
		_follower = MonsterLook.make_body(_game.monsters[0].species())
		_follower_pos = _map.move(_pos, Vector2(0.0, FOLLOW_GAP), 0.3)
		_follower.position = Vector3(_follower_pos.x, 0.0, _follower_pos.y)
		add_child(_follower)
	# wild monsters of a wild area: two per zone, each stays in its zone; the same ones every visit
	var species := GameData.monster_ids()
	for z in _map.zones.size():
		var region: Rect2 = (_map.zones[z]["rect"] as Rect2).grow(-1.0)
		for i in 2:
			var node := MonsterLook.make_body(GameData.monster(species[(z * 2 + i + String(_map.id).length()) % species.size()]))
			node.scale = Vector3.ONE * (1.0 + 0.25 * z)
			add_child(node)
			var start := _map.random_free_point(_rng, 0.5, region)
			node.position = Vector3(start.x, 0.0, start.y)
			_wanderers.append({"node": node, "pos": start, "target": _map.random_free_point(_rng, 0.5, region), "wait": _rng.randf_range(0.0, 2.0), "region": region})


func _update_actors(delta: float) -> void:
	_move_follower(delta)
	_move_wanderers(delta)
	_update_cursor()


func _on_state_changed() -> void:
	_refresh_header()
	if _side.visible:
		_panel.refresh()
		if _favor.visible:
			_favor.refresh()


func _move_follower(delta: float) -> void:
	if _follower == null:
		return
	var to_player := _pos - _follower_pos
	var d := to_player.length()
	if d > FOLLOW_GAP:
		var step := minf(d - FOLLOW_GAP, SPEED * 1.1 * delta)
		_follower_pos = _map.move(_follower_pos, to_player.normalized() * step, 0.3)
		_follower.rotation.y = atan2(to_player.x, to_player.y)
	_follower.position = Vector3(_follower_pos.x, 0.0, _follower_pos.y)


func _move_wanderers(delta: float) -> void:
	for w in _wanderers:
		if w["wait"] > 0.0:
			w["wait"] -= delta
			continue
		var from: Vector2 = w["pos"]
		var to_target: Vector2 = w["target"] - from
		if to_target.length() < 0.15:
			w["wait"] = _rng.randf_range(1.0, 3.0)
			w["target"] = _map.random_free_point(_rng, 0.5, w.get("region", Rect2()))
			continue
		var next := _map.move(from, to_target.normalized() * minf(to_target.length(), WANDER_SPEED * delta), 0.3)
		if next == from:
			w["target"] = _map.random_free_point(_rng, 0.5, w.get("region", Rect2()))       # stuck behind something
		w["pos"] = next
		var node: Node3D = w["node"]
		node.position = Vector3(next.x, 0.0, next.y)
		node.rotation.y = atan2(to_target.x, to_target.y)


func _interact_with(thing: Dictionary) -> void:
	var parts := String(thing["action"]).split(":")
	var arg := StringName(parts[1])
	match parts[0]:
		"panel":
			_show_only(_panel)
			_panel.show_place(arg)
			_open_side()
		"faction":
			_show_only(_favor)
			_favor.show_faction(arg)
			_open_side()
		"structure":
			_show_only(_structures)
			_structures.show_structure(int(parts[1]))
			_open_side()
		"info":
			_show_info(arg)
		"take":
			_take(thing)
		"goto":
			_go(arg)
		"locked":
			_say(String(thing["label"]))


func _show_only(panel: Control) -> void:
	for p: Control in [_panel, _structures, _favor, _info]:
		p.visible = p == panel


## What a building is meant for (CityAreas.info): its name, its group and a text.
func _show_info(key: StringName) -> void:
	var d := CityAreas.info(key)
	if d.is_empty():
		return
	for c in _info.get_children():
		_info.remove_child(c)
		c.queue_free()
	for line: Array in [[String(d["name"]).to_upper(), UiTheme.ACCENT, 22], [d["group"], UiTheme.DIM, 0], [d["text"], UiTheme.TEXT, 0]]:
		var l := Label.new()
		l.text = line[0]
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.add_theme_color_override("font_color", line[1])
		if line[2] > 0:
			l.add_theme_font_size_override("font_size", line[2])
		_info.add_child(l)
	_show_only(_info)
	_open_side()


## Takes a resource of a wild area: 1 day AP, and it is gone until it has grown back.
func _take(thing: Dictionary) -> void:
	var node: Dictionary = thing["node"]
	var why := _game.take_resource(String(thing["id"]), node["item"], node["nights"], node["stage"])
	if why != "":
		_say(why)
		return
	SaveGame.save(_game)
	_reload_here()


func _go(district: StringName) -> void:
	if not DistrictMap.ids().has(district):
		_say("Not built yet.")
		return
	GameSession.arrive_from = _map.id
	GameSession.district = district
	get_tree().reload_current_scene()


func _end_day() -> void:
	if GameSession.expedition != null:
		_say("Finish or leave the dungeon first.")
		return
	var report := _game.end_day(_rng)
	SaveGame.save(_game)
	_refresh_header()
	if _side.visible:
		if _panel.visible:
			_panel.refresh()
		if _structures.visible:
			_structures.refresh()
	var text := "The night passes. Day %d begins; %d monster(s) recovered." % [report["day"], report["healed"]]
	for line in report["notes"]:
		text += "\n" + String(line)
	_say(text, 8.0)


func _save_and_menu() -> void:
	if GameSession.expedition == null:
		SaveGame.save(_game)
	_to_menu()


# ---------- build mode (gdd_overworld §6.4) ----------

func _may_look() -> bool:
	return not GameSession.build_mode        # in build mode that button picks a structure up


func _extra_input(event: InputEvent) -> bool:
	if _map.id != &"inner":
		return false
	if event.is_action_pressed(&"build_toggle"):
		_toggle_build()
		return true
	if GameSession.build_mode and event.is_action_pressed(&"build_rotate"):
		GameSession.build_rot = not GameSession.build_rot
		_show_build_panel()
		return true
	if GameSession.build_mode and event.is_action_pressed(&"build_place"):
		_build_click()
		return true
	if GameSession.build_mode and event.is_action_pressed(&"build_pick_up"):
		_build_pick_up()
		return true
	return false


func _toggle_build() -> void:
	GameSession.build_mode = not GameSession.build_mode
	GameSession.build_item = &""
	_reload_here()


func _reload_here() -> void:
	GameSession.resume_pos = _pos
	get_tree().reload_current_scene()


func _show_build_panel() -> void:
	_show_only(_structures)
	_structures.show_build(GameSession.build_item, GameSession.build_rot)
	_open_side(true, false)       # the build menu doesn't stop you from walking


func _on_place_requested(sid: StringName) -> void:
	GameSession.build_item = sid
	_show_build_panel()


## The grid of the buildable area (it grows with the stage) and the placing cursor.
func _build_overlay() -> void:
	if not GameSession.build_mode:
		return
	var area := BuildGrid.region(_game.stage)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1, 1, 1, 0.10)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for x in range(area.position.x, area.end.x):
		for y in range(area.position.y, area.end.y):
			var mi := MeshInstance3D.new()
			var box := BoxMesh.new()
			box.size = Vector3(BuildGrid.CELL - 0.1, 0.02, BuildGrid.CELL - 0.1)
			mi.mesh = box
			mi.material_override = mat
			mi.position = Vector3((x + 0.5) * BuildGrid.CELL, 0.01, (y + 0.5) * BuildGrid.CELL)
			add_child(mi)
	_cursor = MeshInstance3D.new()
	_cursor.mesh = BoxMesh.new()
	_cursor_mat = StandardMaterial3D.new()
	_cursor_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_cursor_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_cursor.material_override = _cursor_mat
	_cursor.visible = false
	add_child(_cursor)


func _mouse_cell() -> Vector2i:
	var mouse := get_viewport().get_mouse_position()
	var origin := _camera.project_ray_origin(mouse)
	var dir := _camera.project_ray_normal(mouse)
	if absf(dir.y) < 0.0001:
		return Vector2i(-99, -99)
	var hit := origin + dir * (-origin.y / dir.y)
	return BuildGrid.cell_at(Vector2(hit.x, hit.z))


func _update_cursor() -> void:
	if _cursor == null:
		return
	_cursor.visible = GameSession.build_item != &"" and not _structures_hovered()
	if not _cursor.visible:
		return
	var def := StructureCatalog.def(GameSession.build_item)
	var cell := _mouse_cell()
	var rect := BuildGrid.world_rect(def, cell, GameSession.build_rot)
	var fits := BuildGrid.can_place(_game, def, cell, GameSession.build_rot)
	_cursor_mat.albedo_color = Color(0.3, 0.9, 0.4, 0.45) if fits else Color(0.95, 0.3, 0.3, 0.45)
	(_cursor.mesh as BoxMesh).size = Vector3(rect.size.x - 0.1, 0.15, rect.size.y - 0.1)
	_cursor.position = Vector3(rect.get_center().x, 0.08, rect.get_center().y)


## The cursor hides while the mouse is over the side panel.
func _structures_hovered() -> bool:
	return _side.visible and _side.get_global_rect().has_point(get_viewport().get_mouse_position())


func _build_click() -> void:
	if GameSession.build_item == &"":
		var s := BuildGrid.at_cell(_game, _mouse_cell())
		if not s.is_empty():
			_show_only(_structures)
			_structures.show_structure(int(s["uid"]))
			_open_side()
		return
	var sid := GameSession.build_item
	if _game.place_structure(sid, _mouse_cell(), GameSession.build_rot) < 0:
		_say("It doesn't fit there.")
		return
	if _game.item_count(ItemCatalog.structure_item_id(sid)) == 0:
		GameSession.build_item = &""
	SaveGame.save(_game)
	_reload_here()


func _build_pick_up() -> void:
	var s := BuildGrid.at_cell(_game, _mouse_cell())
	if s.is_empty():
		return
	if not _game.pick_up_structure(int(s["uid"])):
		_say("A growing plot can't be picked up — harvest it first.")
		return
	SaveGame.save(_game)
	_reload_here()
