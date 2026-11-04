class_name DistrictScreen
extends WalkScreen
## A walkable city district (gdd_overworld §6.1). Your first monster follows you (§6.2); in the
## Inner World all your monsters wander freely (§6.3). What a place offers is shown in a PlacePanel,
## so the menu map and the streets share the same content.

const SCENE := "res://overworld/district.tscn"
const MAP_SCENE := "res://overworld/overworld.tscn"

const FOLLOW_GAP := 1.3
const WANDER_SPEED := 1.2

var _follower: Node3D
var _follower_pos := Vector2.ZERO
var _wanderers: Array[Dictionary] = []     # {node, pos, target, wait}
var _panel: PlacePanel


func _make_map() -> DistrictMap:
	var m := DistrictMap.of(GameSession.district)
	GameSession.district = m.id
	return m


func _spawn_point() -> Vector2:
	return _map.spawn_for(GameSession.arrive_from)


func _after_ready() -> void:
	_panel = PlacePanel.new()
	_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_panel.setup(_game)
	_panel.changed.connect(_refresh_header)
	_side_body.add_child(_panel)
	if GameSession.arrive_from == &"start":
		_say("WASD to walk, E to use things.", 5.0)


func _top_buttons() -> Array[Button]:
	return [
		hud_button("End day", _end_day),
		hud_button("City map", func(): get_tree().change_scene_to_file(MAP_SCENE)),
		hud_button("Menu", _save_and_menu),
	]


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


func _update_actors(delta: float) -> void:
	_move_follower(delta)
	_move_wanderers(delta)


func _on_state_changed() -> void:
	_refresh_header()
	if _side.visible:
		_panel.refresh()


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
			w["target"] = _map.random_free_point(_rng)
			continue
		var next := _map.move(from, to_target.normalized() * minf(to_target.length(), WANDER_SPEED * delta), 0.3)
		if next == from:
			w["target"] = _map.random_free_point(_rng)       # stuck behind something
		w["pos"] = next
		var node: Node3D = w["node"]
		node.position = Vector3(next.x, 0.0, next.y)
		node.rotation.y = atan2(to_target.x, to_target.y)


func _interact_with(thing: Dictionary) -> void:
	var parts := String(thing["action"]).split(":")
	var arg := StringName(parts[1])
	match parts[0]:
		"panel":
			_panel.show_place(arg)
			_open_side()
		"goto":
			_go(arg)
		"locked":
			_say(String(thing["label"]))


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
		_panel.refresh()
	_say("The night passes. Day %d begins; %d monster(s) recovered." % [report["day"], report["healed"]], 5.0)


func _save_and_menu() -> void:
	if GameSession.expedition == null:
		SaveGame.save(_game)
	_to_menu()
