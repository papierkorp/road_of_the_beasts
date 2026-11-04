class_name DungeonRoomScreen
extends WalkScreen
## A dungeon as walkable rooms (gdd_overworld §6.2). Each node of the Expedition is a room:
##  - the hall (nothing to fight): doors to the next nodes, a portal back to the city;
##  - a battle room: the node's wild monsters roam visibly — no random encounters. They chase you
##    when you come close; touching one starts the battle. Hitting it from behind (or being hit
##    from behind) gives a small round-1 initiative bonus (Encounter).
## The monsters' kin and aspect show in their shape and colour; their full datasheets are shown
## before the fight, together with your team pick — no hidden information.

const SCENE := "res://overworld/dungeon_room.tscn"
const BATTLE_SCENE := "res://battle/battle.tscn"
const CITY_SCENE := "res://overworld/district.tscn"
const MAP_SCENE := "res://overworld/dungeon.tscn"

var _ex: Expedition
var _roamers: Array[WildRoamer] = []
var _bodies: Array[Node3D] = []
var _in_battle_room := false
var _encountering := false
var _ambush := -1
var _checks: Array[CheckBox] = []
var _prep_checks: Array[CheckBox] = []
var _team_label: Label
var _fight: Button


func _can_start() -> bool:
	return GameSession.expedition != null


func _fallback_scene() -> String:
	return CITY_SCENE


func _make_map() -> DistrictMap:
	_ex = GameSession.expedition
	_apply_battle_result()
	_in_battle_room = not _ex.finished and _ex.selected >= 0
	var doors: Array[Dictionary] = []
	if not _in_battle_room:
		for id in _ex.choices():
			var n := _ex.node(id)
			var label := "%s — %s, reward %d" % ["Boss door" if n["kind"] == &"boss" else "Door",
				String(n["mode"]).to_upper(), n["reward"]]
			if n["kind"] == &"boss" and _ex.blueprint_reward != &"":
				label += " + %s blueprint" % StructureCatalog.def(_ex.blueprint_reward).display_name
			doors.append({"id": id, "label": label})
	var seed_value := (_ex.selected + 1) * 31 + (_ex.current + 2) * 7 + _ex.nodes.size()
	var m := DistrictMap.room(seed_value, doors)
	if _in_battle_room:
		m.title = "Dungeon — %s %s" % ["boss room" if _ex.node(_ex.selected)["kind"] == &"boss" else "battle room",
			String(_ex.node(_ex.selected)["mode"])]
	else:
		m.title = "Dungeon — hall"
	return m


## Back from a battle of this run: HP persists, victory pays, the path advances.
var _note := ""


func _apply_battle_result() -> void:
	var res := GameSession.last_result
	if res == null:
		return
	GameSession.last_result = null
	var before := _ex.current
	_ex.apply_result(_game, res)
	_note = _ex.result_note(before)


func _after_ready() -> void:
	if _note != "":
		_say(_note, 9.0)
	elif _ex.finished:
		_say("The dungeon is over — teleport out to return to the city.", 6.0)
	elif _in_battle_room:
		_say("Wild monsters roam here. Touch one to fight — strike from behind for +1 initiative.", 6.0)
	else:
		_say("Choose a door.", 4.0)


func _top_buttons() -> Array[Button]:
	return [
		hud_button("Dungeon map", func(): get_tree().change_scene_to_file(MAP_SCENE)),
		hud_button("Menu", _to_menu),
	]


func _build_actors() -> void:
	if not _in_battle_room:
		return
	var node := _ex.node(_ex.selected)
	var boss: bool = node["kind"] == &"boss"
	var region := Rect2(8.0, 1.0, 7.0, 8.0)
	for e: MonsterInstance in node["enemies"]:
		var body := MonsterLook.make_body(e.species())
		if boss:
			body.scale = Vector3.ONE * 1.4
		var label := Label3D.new()
		label.text = "%s\n%s %s" % [e.species().display_name, Aspect.NAMES[e.species().aspect], MonsterDef.kin_name(e.species().kin)]
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.pixel_size = 0.01
		label.font_size = 32
		label.outline_size = 8
		label.no_depth_test = true
		label.modulate = MonsterLook.aspect_color(e.species().aspect).lerp(Color.WHITE, 0.5)
		label.position = Vector3(0.0, 1.7 if not boss else 2.2, 0.0)
		body.add_child(label)
		add_child(body)
		var r := WildRoamer.create(_map.random_free_point(_rng, 0.5, region), _map, _rng)
		body.position = Vector3(r.pos.x, 0.0, r.pos.y)
		_roamers.append(r)
		_bodies.append(body)


func _update_actors(delta: float) -> void:
	if _encountering or _side.visible:
		return
	for i in _roamers.size():
		var r := _roamers[i]
		r.update(delta, _map, _pos, _rng)
		_bodies[i].position = Vector3(r.pos.x, 0.0, r.pos.y)
		if r.facing != Vector2.ZERO:
			_bodies[i].rotation.y = atan2(r.facing.x, r.facing.y)
		if r.touches(_pos):
			_begin_encounter(r)
			return


# ---------- encounter ----------

func _begin_encounter(roamer: WildRoamer) -> void:
	_encountering = true
	_ambush = Encounter.ambush_side(_pos, _facing, roamer.pos, roamer.facing)
	_build_encounter_panel()


## Datasheets, ambush, healing and prep pills, team pick. Rebuilt after a pill, keeping your picks.
func _build_encounter_panel() -> void:
	var keep: Array[bool] = []
	for c in _checks:
		keep.append(c.button_pressed)
	var keep_prep: Array[bool] = []
	for c in _prep_checks:
		keep_prep.append(c.button_pressed)
	_clear_side()
	_checks.clear()
	_prep_checks.clear()
	var node := _ex.node(_ex.selected)
	_text("%s — %s   reward %d spirit stones" % [("BOSS" if node["kind"] == &"boss" else "WILD MONSTERS"),
		String(node["mode"]).to_upper(), node["reward"]], UiTheme.ACCENT, 20)
	match _ambush:
		0:
			_text("You struck from behind! +%d initiative for your team in round 1." % int(Battle.AMBUSH_BONUS), UiTheme.TEXT)
		1:
			_text("They caught you from behind! +%d initiative for the wild monsters in round 1." % int(Battle.AMBUSH_BONUS), UiTheme.TEXT)
		_:
			_text("A head-on meeting — nobody gets the first move.", UiTheme.DIM)
	_text("FULL DATASHEETS — no hidden information", UiTheme.DIM)
	for e: MonsterInstance in node["enemies"]:
		_text(e.sheet_text(), UiTheme.TEXT)
	var team_size := BattleRequest.team_size_of(node["mode"])
	_text("YOUR TEAM", UiTheme.DIM)
	for i in _game.monsters.size():
		var cb := CheckBox.new()
		cb.text = _game.monsters[i].sheet_text(false).replace("\n", "   ")
		cb.button_pressed = keep[i] if i < keep.size() else i < team_size
		cb.toggled.connect(func(_on: bool): _update_team())
		_side_body.add_child(cb)
		_checks.append(cb)
	_team_label = _text("", UiTheme.DIM)

	var heal := ItemCatalog.healing_pill_id(int(_game.stage))
	var prep := ItemCatalog.prep_pill_id(int(_game.stage))
	_text("HEALING PILLS in your bag: %d  (+%d HP each)" % [_game.item_count(heal), ItemCatalog.HEAL_AMOUNT], UiTheme.DIM)
	for i in _game.monsters.size():
		var m := _game.monsters[i]
		if m.current_hp < m.max_hp():
			var hb := Button.new()
			hb.text = "Heal %s  (HP %d / %d)" % [m.species().display_name, m.current_hp, m.max_hp()]
			hb.custom_minimum_size = Vector2(300, 40)
			hb.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
			hb.disabled = _game.item_count(heal) < 1
			hb.pressed.connect(func(): _heal(heal, i))
			_side_body.add_child(hb)
	_text("BATTLE-PREP PILLS in your bag: %d  (+%d initiative for the whole battle, used up when the fight starts)"
		% [_game.item_count(prep), ItemCatalog.PREP_INIT], UiTheme.DIM)
	for i in _game.monsters.size():
		var pc := CheckBox.new()
		pc.text = "Prep pill for %s" % _game.monsters[i].species().display_name
		pc.button_pressed = keep_prep[i] if i < keep_prep.size() else false
		pc.toggled.connect(func(_on: bool): _update_team())
		_side_body.add_child(pc)
		_prep_checks.append(pc)

	_fight = Button.new()
	_fight.text = "Fight"
	_fight.custom_minimum_size = Vector2(300, 46)
	_fight.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_fight.pressed.connect(_start_battle)
	_side_body.add_child(_fight)
	_update_team()
	_open_side(false)


func _heal(pill: String, i: int) -> void:
	if _game.use_healing_pill(pill, _game.monsters[i]):
		SaveGame.save(_game)
		_build_encounter_panel()


func _picked() -> Array[MonsterInstance]:
	var out: Array[MonsterInstance] = []
	for i in _checks.size():
		if _checks[i].button_pressed:
			out.append(_game.monsters[i])
	return out


func _update_team() -> void:
	var team_size := BattleRequest.team_size_of(_ex.node(_ex.selected)["mode"])
	var count := _picked().size()
	_team_label.text = "Team %d / %d" % [count, team_size]
	_fight.disabled = count < 1 or count > team_size
	# only as many prep pills as you have
	var pills := _game.item_count(ItemCatalog.prep_pill_id(int(_game.stage)))
	var used := 0
	for c in _prep_checks:
		if c.button_pressed:
			used += 1
	for c in _prep_checks:
		c.disabled = used >= pills and not c.button_pressed


func _start_battle() -> void:
	var team := _picked()
	var request := _ex.request_for(_game, team)
	request.ambush_side = _ambush
	var prep := ItemCatalog.prep_pill_id(int(_game.stage))
	for i in _prep_checks.size():
		if _prep_checks[i].button_pressed and team.has(_game.monsters[i]) and _game.remove_item(prep):
			request.prep_init[team.find(_game.monsters[i])] = ItemCatalog.PREP_INIT
	var problem := request.problem()
	if problem != "":
		_say("Can't fight: " + problem)
		return
	GameSession.start_battle(request, SCENE)
	get_tree().change_scene_to_file(BATTLE_SCENE)


func _text(text: String, color: Color, size_px := 16) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size_px)
	l.add_theme_color_override("font_color", color)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_side_body.add_child(l)
	return l


# ---------- doors and portal ----------

func _interact_with(thing: Dictionary) -> void:
	var parts := String(thing["action"]).split(":")
	match parts[0]:
		"door":
			if _ex.select(int(parts[1])):
				get_tree().reload_current_scene()
		"leave":
			_leave()


func _leave() -> void:
	GameSession.expedition = null
	GameSession.district = &"plaza"
	GameSession.arrive_from = &"dungeon"
	SaveGame.save(_game)
	get_tree().change_scene_to_file(CITY_SCENE)
