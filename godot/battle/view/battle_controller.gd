extends Node3D
## Wires Battle (rules), BattleView (3D) and BattleHud (UI) together and handles input.
## It turns clicks into action dictionaries, asks `Battle.check` / `Battle.preview` what they
## would do and applies them with `Battle.apply`; it holds no rule of its own.
## You control side 0 whenever one of your monsters is next in the queue; side 1 is the AI.
## Start with `--autoplay` (after `--`) to let the AI play both sides.

const PLAYER_SIDE := 0
const NOWHERE := Vector2i(-1, -1)
const ACT_STEP := &"__step"
const ACT_START := &"__start"
const TAMER_PREFIX := "__tamer:"
const SLOT_PREFIX := "__slot:"

const COL_MOVE := Color(0.36, 0.56, 0.85, 0.5)
const COL_HARM := Color(0.85, 0.45, 0.3, 0.55)
const COL_HIT := Color(0.95, 0.35, 0.3, 0.55)
const COL_AREA := Color(0.79, 0.64, 0.36, 0.65)
const COL_LEVEL := Color(0.92, 0.8, 0.36, 0.7)       # levels up
const COL_REPLACE := Color(0.36, 0.56, 0.85, 0.65)    # replaces what is there
const COL_CANCEL := Color(0.35, 0.82, 0.77, 0.65)     # weakens or cancels an opposite zone
const COL_NOTHING := Color(0.5, 0.5, 0.5, 0.5)        # legal cast, but nothing happens on this square
const COL_RANGE := Color(0.79, 0.64, 0.36, 0.14)
const COL_BAD := Color(0.85, 0.33, 0.33, 0.6)
const COL_PICK := Color(0.45, 0.85, 0.6, 0.55)

var request: BattleRequest
var battle: Battle
var view: BattleView
var hud: BattleHud
var rng := RandomNumberGenerator.new()

var mode := &""                    # &"" | &"step" | &"skill" | &"tamer"
var slot := -1                     # kit slot while mode is &"skill"
var tamer_id: StringName = &""     # loadout skill while mode is &"tamer"
var picked: Array[StringName] = [] # units chosen so far for a tamer skill
var rot := 0                       # quarter turns (Adaptive) / tetromino index (Domain Glimpse)
var aim_dir := Vector2i(0, -1)     # cardinal direction for pushes
var hover := NOWHERE
var placing := false               # pre-battle placement phase (gdd_battle §2.1 step 2)
var placing_pick: StringName = &""
var _ai_running := false
var _tetrominoes: Array[Dictionary] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS      # Esc must work while paused
	rng.randomize()
	if OS.get_cmdline_user_args().has("--autoplay"):
		GameSession.autoplay = true
	request = GameSession.request if GameSession.request != null else BattleRequest.default()
	GameSession.request = request
	battle = BattleSetup.build(request)
	battle.event_emitted.connect(_on_event)
	_tetrominoes = Shapes.orientations([&"I4", &"O4", &"T4", &"S4", &"L4"])
	view = BattleView.new()
	view.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(view)
	view.build(battle)
	hud = BattleHud.new()
	add_child(hud)
	hud.build()
	hud.set_exit_mode(GameSession.return_scene != "")
	hud.action_pressed.connect(_on_action)
	hud.end_turn_pressed.connect(_on_end_turn)
	hud.restart_pressed.connect(func(): get_tree().reload_current_scene())
	hud.resume_pressed.connect(_toggle_pause)
	hud.menu_pressed.connect(_to_menu)
	hud.log_line("%s on %d×%d" % [request.mode, battle.board.size, battle.board.size])
	for u in battle.living(PLAYER_SIDE):
		var notes: PackedStringArray = []
		if u.sheet.init_bonus > 0.0:
			notes.append("+%d init (prepared)" % int(u.sheet.init_bonus))
		notes.append_array(PackedStringArray(u.sheet.notes))
		if not notes.is_empty():
			hud.log_line("%s: %s" % [u.display_name(), BattleText.SEP.join(notes)])
	placing = not GameSession.autoplay and _start_squares().size() > battle.living(PLAYER_SIDE).size()
	if placing:
		hud.log_line("Place your monsters, then start.")
		_refresh()
	else:
		_begin()


func _begin() -> void:
	placing = false
	placing_pick = &""
	battle.begin()
	_refresh()
	_check_ai()


func _active() -> BattleUnit:
	return battle.active()


func _is_player_turn() -> bool:
	var u := _active()
	return u != null and u.side == PLAYER_SIDE and not GameSession.autoplay


func _my_turn() -> bool:
	return not placing and not battle.over and not _ai_running and not get_tree().paused and _is_player_turn()


func _toggle_pause() -> void:
	if battle.over:
		return
	get_tree().paused = not get_tree().paused
	hud.show_pause(get_tree().paused)


func _to_menu() -> void:
	get_tree().paused = false
	var target := GameSession.return_scene if GameSession.return_scene != "" else "res://game/menu.tscn"
	get_tree().change_scene_to_file(target)


# ---------- input ----------

func _unhandled_input(event: InputEvent) -> void:
	if get_tree().paused:
		if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
			_toggle_pause()
		return
	if event is InputEventMouseMotion:
		var c = view.cell_at_screen(event.position)
		hover = c if c != null else NOWHERE
		_refresh()
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_click()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_rotate()
	elif event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_R:
				_rotate()
			KEY_W, KEY_UP:
				_set_dir(Vector2i(0, -1))
			KEY_S, KEY_DOWN:
				_set_dir(Vector2i(0, 1))
			KEY_A, KEY_LEFT:
				_set_dir(Vector2i(-1, 0))
			KEY_D, KEY_RIGHT:
				_set_dir(Vector2i(1, 0))
			KEY_1:
				_on_action(ACT_STEP)
			KEY_2, KEY_3, KEY_4, KEY_5, KEY_6:
				_on_action(StringName(SLOT_PREFIX + str(event.keycode - KEY_2)))
			KEY_SPACE, KEY_ENTER:
				if placing:
					_on_action(ACT_START)
				else:
					_on_end_turn()
			KEY_ESCAPE:
				if mode != &"" or placing_pick != &"":
					_clear_mode()
					placing_pick = &""
					_refresh()
				else:
					_toggle_pause()


func _set_dir(screen: Vector2i) -> void:
	aim_dir = view.board_dir_from_screen(screen)
	_refresh()


func _clear_mode() -> void:
	mode = &""
	slot = -1
	tamer_id = &""
	picked.clear()
	rot = 0


func _skill() -> BattleSkillDef:
	return battle.skill_in_slot(_active(), slot) if mode == &"skill" else null


func _on_action(id: StringName) -> void:
	if placing:
		if id == ACT_START:
			_begin()
		return
	if not _my_turn():
		return
	var u := _active()
	var text := String(id)
	if id == ACT_STEP:
		var again := mode == &"step"
		_clear_mode()
		mode = &"" if again else &"step"
	elif text.begins_with(SLOT_PREFIX):
		var i := int(text.trim_prefix(SLOT_PREFIX))
		var s := battle.skill_in_slot(u, i)
		if s == null or not s.is_active():
			return
		var again := mode == &"skill" and slot == i
		_clear_mode()
		if again:
			pass
		elif s.kind == BattleSkillDef.BUFF:
			if battle.apply({"type": &"skill", "slot": i}):      # no target to choose
				_after_action()
				return
		else:
			mode = &"skill"
			slot = i
	elif text.begins_with(TAMER_PREFIX):
		var tid := StringName(text.trim_prefix(TAMER_PREFIX))
		var again := mode == &"tamer" and tamer_id == tid
		_clear_mode()
		if not again and battle.tamer_skill(PLAYER_SIDE, tid) != null and not battle.tamer_used[PLAYER_SIDE].has(tid):
			mode = &"tamer"
			tamer_id = tid
	_refresh()


func _rotate() -> void:
	if mode == &"tamer":
		rot = (rot + 1) % maxi(1, _tetrominoes.size())
	elif mode == &"skill" and _skill() != null and _skill().is_placed() and BattleStats.can_rotate(_active()):
		rot = (rot + 1) % 4
	_refresh()


## The action the current aim describes, or an empty Dictionary while nothing is aimed.
func _aimed_action() -> Dictionary:
	if not _my_turn():
		return {}
	var u := _active()
	match mode:
		&"step":
			return {"type": &"step", "to": hover} if hover != NOWHERE else {}
		&"skill":
			var s := _skill()
			if s == null:
				return {}
			match s.kind:
				BattleSkillDef.MOVE:
					return {"type": &"skill", "slot": slot, "to": hover} if hover != NOWHERE else {}
				BattleSkillDef.STRIKE:
					var aim := _strike_aim(u, s)
					if aim.is_empty():
						return {}
					return {"type": &"skill", "slot": slot, "dir": aim["dir"], "origin": aim["origin"], "push_dir": aim_dir}
				_:
					if s.anchor_mode == "caster_ring":
						return {"type": &"skill", "slot": slot, "anchor": u.pos, "dir": aim_dir, "rot": rot}
					if hover == NOWHERE:
						return {}
					return {"type": &"skill", "slot": slot, "anchor": hover, "dir": aim_dir, "rot": rot}
		&"tamer":
			return _tamer_action()
	return {}


## Strike direction from the hovered square: the eight directions seen from the body square
## nearest to it. Symmetric shapes need no direction.
func _strike_aim(u: BattleUnit, s: BattleSkillDef) -> Dictionary:
	var shape := StringName(s.strike_shape)
	if StrikeShapes.directions(shape) == StrikeShapes.NO_DIR:
		return {"dir": Vector2i.ZERO, "origin": u.pos}
	if hover == NOWHERE or u.covers(hover):
		return {}
	var origin := u.pos
	var best := 1 << 20
	for c in u.cells():
		var d := Board.chebyshev(c, hover)
		if d < best:
			best = d
			origin = c
	var v := hover - origin
	if v.x != 0 and v.y != 0 and absi(v.x) != absi(v.y):
		return {}
	var dir := Vector2i(signi(v.x), signi(v.y))
	return {"dir": dir, "origin": origin} if StrikeShapes.is_legal_dir(shape, dir) else {}


func _tamer_action() -> Dictionary:
	var def := battle.tamer_skill(PLAYER_SIDE, tamer_id)
	if def == null:
		return {}
	var a := {"type": &"tamer", "side": PLAYER_SIDE, "skill": tamer_id}
	var target := battle.any_unit_at(hover) if hover != NOWHERE else null
	match def.effect:
		TamerSkillDef.DOMAIN_GLIMPSE:
			if hover == NOWHERE or _tetrominoes.is_empty():
				return {}
			var cells: Array = []
			cells.assign(Shapes.footprint(_tetrominoes[rot % _tetrominoes.size()], hover))
			a["cells"] = cells
		TamerSkillDef.SWAP_PLACES:
			if picked.is_empty() or target == null:
				return {}
			a["unit"] = picked[0]
			a["other"] = target.id
		TamerSkillDef.BEAST_SWAP:
			var incoming := _bench_pick(target)
			if target == null or incoming == null:
				return {}
			a["unit"] = target.id
			a["other"] = incoming.id
		_:
			if target == null:
				return {}
			a["unit"] = target.id
	return a


## The bench monster Beast Swap would bring in for `outgoing` (same body size, in bench order).
func _bench_pick(outgoing: BattleUnit) -> BattleUnit:
	if outgoing == null:
		return null
	for id in battle.roster:
		var u: BattleUnit = battle.units[id]
		if u.side == PLAYER_SIDE and not u.on_field and not u.defeated and u.size == outgoing.size:
			return u
	return null


func _click() -> void:
	if placing:
		_placement_click()
		return
	if not _my_turn():
		return
	if mode == &"tamer" and hover != NOWHERE:
		var def := battle.tamer_skill(PLAYER_SIDE, tamer_id)
		var target := battle.any_unit_at(hover)
		if def != null and def.effect == TamerSkillDef.SWAP_PLACES and picked.is_empty():
			if target != null and target.side == PLAYER_SIDE:
				picked.append(target.id)
				_refresh()
			return
	var a := _aimed_action()
	if a.is_empty():
		return
	if battle.apply(a):
		_after_action()


func _on_end_turn() -> void:
	if not _my_turn():
		return
	_clear_mode()
	battle.end_turn()
	_refresh()
	_check_ai()


func _after_action() -> void:
	_clear_mode()
	_refresh()
	if battle.over:
		return
	if not _is_player_turn():
		_check_ai()                # a tamer swap or a defeat can hand the turn over
		return
	if battle.ap > 0:
		return
	await get_tree().create_timer(0.5, false).timeout
	if _my_turn() and battle.ap <= 0 and mode == &"":
		battle.end_turn()
		_refresh()
		_check_ai()


# ---------- pre-battle placement ----------

## Free squares of the player's start area.
func _start_squares() -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for cell in battle.board.cells:
		if BattleBoards.in_start_area(request.mode, cell.pos) and cell.prop == null:
			out.append(cell.pos)
	return out


func _placement_click() -> void:
	if hover == NOWHERE:
		return
	var here := battle.unit_at(hover, Board.GROUND)
	if here == null:
		here = battle.unit_at(hover, Board.AIR)
	if placing_pick == &"":
		if here != null and here.side == PLAYER_SIDE:
			placing_pick = here.id
	else:
		var u: BattleUnit = battle.units[placing_pick]
		if here != null and here.side == PLAYER_SIDE and here.id != u.id and here.size == u.size and here.layer == u.layer:
			var a := u.pos
			var c := here.pos
			battle.lift(u)
			battle.lift(here)
			battle.put(u, c)
			battle.put(here, a)
		elif here == null and _can_start_at(u, hover):
			battle.relocate(u, hover)
		placing_pick = &""
	_refresh()


func _can_start_at(u: BattleUnit, origin: Vector2i) -> bool:
	for c in u.cells_at(origin):
		var cell := battle.board.at(c)
		if cell == null or not BattleBoards.in_start_area(request.mode, c) or battle.board.prop_at(c, u.layer) != null:
			return false
		var other := battle.board.unit_id_at(c, u.layer)
		if other != &"" and other != u.id:
			return false
	return true


# ---------- AI turns ----------

func _check_ai() -> void:
	if battle.over or _ai_running or _is_player_turn():
		return
	_ai_running = true
	while not battle.over and not _is_player_turn():
		var who := battle.turn_owner
		var entry := battle.queue_idx
		var round_no := battle.round_number
		_refresh()
		await get_tree().create_timer(0.6, false).timeout
		var guard := 0
		while not battle.over and battle.turn_owner == who and battle.queue_idx == entry and battle.round_number == round_no \
				and guard < AiBrain.MAX_ACTIONS_PER_TURN:
			guard += 1
			var a := AiBrain.decide(battle, rng)
			if a["type"] == &"end_turn" or not battle.apply(a):
				break
			_refresh()
			await get_tree().create_timer(0.55, false).timeout
		if not battle.over and battle.turn_owner == who and battle.queue_idx == entry and battle.round_number == round_no:
			battle.end_turn()
		_refresh()
	_ai_running = false
	_refresh()


# ---------- refresh ----------

func _refresh() -> void:
	var arrows := {}
	view.set_highlights(_highlights(arrows), arrows)
	view.refresh()
	hud.update(_order_text(), _portrait_text(), _ap_text(), _hint_text(), _preview_text(),
			_inspector(), _actions(), _my_turn(), _banner_text())


func _ap_text() -> String:
	var u := _active()
	if u == null or placing:
		return "AP"
	var total := BattleStats.ap(u)
	var left := battle.ap if _is_player_turn() else 0
	return "AP  " + "●".repeat(left) + "○".repeat(maxi(0, total - left))


func _highlights(arrows: Dictionary) -> Dictionary:
	var out := {}
	if placing:
		for p in _start_squares():
			out[p] = COL_RANGE if placing_pick == &"" else COL_MOVE
		if placing_pick != &"":
			for c in battle.units[placing_pick].cells():
				out[c] = COL_PICK
		return out
	if not _my_turn():
		return out
	var u := _active()
	match mode:
		&"step":
			_move_highlights(BattleMoves.options(battle, u, BattleMoves.step_profile()), out)
		&"skill":
			var s := _skill()
			if s == null:
				return out
			match s.kind:
				BattleSkillDef.MOVE:
					_move_highlights(BattleMoves.options(battle, u, BattleMoves.profile_of(s)), out)
				BattleSkillDef.STRIKE:
					var aim := _strike_aim(u, s)
					if aim.is_empty():
						return out
					var legal := battle.strike_error(u, s, aim["dir"], aim_dir if _needs_push(u, s) else Vector2i(0, -1), aim["origin"]) == ""
					for h in StrikeShapes.hits(StringName(s.strike_shape), aim["dir"]):
						var cell: Vector2i = aim["origin"] + h["o"]
						if battle.board.in_bounds(cell) and not u.covers(cell):
							out[cell] = COL_HIT if legal else COL_BAD
							if legal and _needs_push(u, s) and battle.any_unit_at(cell) != null:
								arrows[cell] = aim_dir
				_:
					_placement_highlights(u, s, out, arrows)
		&"tamer":
			_tamer_highlights(out)
	return out


func _needs_push(u: BattleUnit, s: BattleSkillDef) -> bool:
	return s.kin_effect and KinRules.strike(u.kin()).get("push", false)


func _move_highlights(opts: Dictionary, out: Dictionary) -> void:
	var u := _active()
	for origin: Vector2i in opts:
		for c in u.cells_at(origin):
			if not out.has(c) or int(opts[origin]["harm"]) <= 0:
				out[c] = COL_HARM if int(opts[origin]["harm"]) > 0 else COL_MOVE


func _placement_highlights(u: BattleUnit, s: BattleSkillDef, out: Dictionary, arrows: Dictionary) -> void:
	if s.anchor_mode == "reach":
		var reach := BattleStats.reach(battle, u)
		for cell in battle.board.cells:
			if u.manhattan_to(cell.pos) <= reach:
				out[cell.pos] = COL_RANGE
	var anchor := u.pos if s.anchor_mode == "caster_ring" else hover
	if anchor == NOWHERE:
		return
	var legal := BattleCasting.error(battle, u, s, anchor, aim_dir, rot) == ""
	for c in BattleCasting.cells(u, s, anchor, rot):
		if not battle.board.in_bounds(c):
			continue
		out[c] = _outcome_color(s, battle.board.at(c)) if legal else COL_BAD
		if not legal:
			continue
		if s.needs_direction():
			arrows[c] = aim_dir
		elif (s.kind == BattleSkillDef.ZONE and s.zone != null and s.zone.has_tag(FieldEffect.PULL)) or s.surge_displacement == "pull":
			var v := anchor - c
			if v != Vector2i.ZERO and absi(v.x) != absi(v.y):
				arrows[c] = Vector2i(signi(v.x), 0) if absi(v.x) > absi(v.y) else Vector2i(0, signi(v.y))


## Colour of one footprint square by what the cast does there (new / levels up / replaces /
## weakens or cancels / nothing), read from the same outcome functions the resolution uses.
func _outcome_color(s: BattleSkillDef, cell: BoardCell) -> Color:
	if s.kind == BattleSkillDef.ZONE and s.zone != null:
		match BattleBoardOps.zone_outcome(cell, s.zone)["kind"]:
			&"level":
				return COL_LEVEL
			&"replace":
				return COL_REPLACE
			&"weaken", &"cancel":
				return COL_CANCEL
	elif s.kind == BattleSkillDef.GROUND:
		for op in s.ops_of(BoardOp.GROUND):
			if cell.is_mountain() and not op.on_mountain:
				return COL_NOTHING
			match BattleBoardOps.ground_outcome(battle, cell, op.ground):
				&"level":
					return COL_LEVEL
				&"replace":
					return COL_REPLACE
				&"kept", &"immutable":
					return COL_NOTHING
		if s.has_op(BoardOp.RAISE_MOUNTAIN) and cell.is_mountain():
			return COL_NOTHING
	return COL_AREA


func _tamer_highlights(out: Dictionary) -> void:
	var def := battle.tamer_skill(PLAYER_SIDE, tamer_id)
	if def == null:
		return
	if def.effect == TamerSkillDef.DOMAIN_GLIMPSE:
		var a := _tamer_action()
		if a.is_empty():
			return
		var legal := battle.check(a) == ""
		for c: Vector2i in a["cells"]:
			if battle.board.in_bounds(c):
				out[c] = COL_AREA if legal else COL_BAD
		return
	for u in battle.living(PLAYER_SIDE):
		for c in u.cells():
			out[c] = COL_PICK if picked.has(u.id) else COL_MOVE


func _side_tag(u: BattleUnit) -> String:
	return "◆" if u.side == PLAYER_SIDE else "◇"


func _order_text() -> String:
	if placing:
		return "PLACEMENT"
	var s := "ROUND %d\n" % battle.round_number
	for i in battle.queue.size():
		var e: Dictionary = battle.queue[i]
		var u: BattleUnit = battle.units[e["id"]]
		if not u.is_alive():
			continue
		var mark := "▶ " if i == battle.queue_idx and not battle.over else ("   " if i > battle.queue_idx else " ✓ ")
		s += "%s%s %s  %.1f  %d/%d\n" % [mark, _side_tag(u), u.display_name(), e["init"], u.hp, u.max_hp]
	var orphans := 0
	for sg in battle.surges:
		if sg.orphaned:
			orphans += 1
	if orphans > 0:
		s += "⚠ %d Surge%s next round\n" % [orphans, "" if orphans == 1 else "s"]
	return s.strip_edges()


func _portrait_text() -> String:
	var u := _active()
	if u == null or placing:
		return ""
	return "%s %s%sMove %d%sReach %d" % [_side_tag(u), u.display_name(), BattleText.SEP, BattleStats.movement(battle, u),
		BattleText.SEP, BattleStats.reach(battle, u)]


func _hint_text() -> String:
	if placing:
		return "Click a monster, then a start square · Space starts" if placing_pick == &"" else "Click a start square or a monster to swap"
	if battle.over:
		return ""
	if not _is_player_turn():
		return "%s…" % _active().display_name() if _active() != null else ""
	var u := _active()
	match mode:
		&"step":
			return "Click a blue square"
		&"skill":
			var s := _skill()
			if s == null:
				return ""
			match s.kind:
				BattleSkillDef.MOVE:
					return "Click a blue square"
				BattleSkillDef.STRIKE:
					return "Aim and click" + (" · WASD push" if _needs_push(u, s) else "")
				_:
					var t := "Click to cast"
					if BattleStats.can_rotate(u) and s.anchor_mode != "caster_ring" and s.anchor_mode != "trail":
						t += " · R rotates"
					return t + (" · WASD direction" if s.needs_direction() else "")
		&"tamer":
			var def := battle.tamer_skill(PLAYER_SIDE, tamer_id)
			if def == null:
				return ""
			match def.effect:
				TamerSkillDef.DOMAIN_GLIMPSE:
					return "R changes shape · click places"
				TamerSkillDef.SWAP_PLACES:
					return "Click the %s monster" % ("first" if picked.is_empty() else "second")
				TamerSkillDef.BEAST_SWAP:
					return "Click the monster that leaves"
			return "Click one of your monsters"
	return "1 Step · 2–5 Skills · Space End turn"


func _actions() -> Array:
	var out: Array = []
	if placing:
		out.append({"id": ACT_START, "text": "Start Battle\nSpace", "enabled": true, "selected": false,
			"card": {"title": "Start Battle", "rows": []}})
		return out
	var u := _active()
	if u == null or u.side != PLAYER_SIDE:
		return out
	var mine := _my_turn()
	out.append({"id": ACT_STEP, "text": "Step\n%d AP" % BattleMoves.STEP_AP,
		"enabled": mine and battle.ap >= BattleMoves.STEP_AP and not BattleStats.is_rooted(u),
		"selected": mode == &"step", "card": {"title": "Step", "rows": BattleText.step_rows()}})
	for i in u.sheet.skills.size():
		var s := u.sheet.skills[i]
		var rows := BattleText.skill_rows(battle.content, s, u.kin())
		var why := ""
		if s.is_active() and mine:
			if battle.ap < s.cost():
				why = "needs %d AP, %d left" % [s.cost(), battle.ap]
			else:
				why = battle.usage_error(u, i)
		if why != "":
			rows.push_front(["", "✗ " + why])
		var label := s.display_name
		if s.kind == BattleSkillDef.STRIKE:
			label = "%s (%s)" % [KinRules.strike_name(u.kin()) if s.kin_effect else s.display_name, StrikeShapes.shape_name(StringName(s.strike_shape))]
		out.append({"id": StringName(SLOT_PREFIX + str(i)), "text": "%s\n%s" % [label, "passive" if not s.is_active() else "%d AP" % s.cost()],
			"enabled": mine and s.is_active() and why == "", "selected": mode == &"skill" and slot == i,
			"card": {"title": label, "rows": rows}})
	for def: TamerSkillDef in battle.tamer_loadout[PLAYER_SIDE]:
		var used: bool = battle.tamer_used[PLAYER_SIDE].has(def.id)
		out.append({"id": StringName(TAMER_PREFIX + String(def.id)), "text": "%s\n%s" % [def.display_name, "used" if used else "tamer"],
			"enabled": mine and not used, "selected": mode == &"tamer" and tamer_id == def.id,
			"card": {"title": def.display_name, "rows": [["", def.description], ["", "tamer · 1/battle"]]}})
	return out


func _banner_text() -> String:
	if not battle.over:
		return ""
	if battle.draw:
		return "Draw"
	return "Victory" if battle.winner_side == PLAYER_SIDE else "Defeat"


func _preview_text() -> String:
	if mode == &"" or not _my_turn():
		return ""
	var a := _aimed_action()
	if a.is_empty():
		return ""
	var lines := BattleText.preview_lines(battle, battle.preview(a))
	if mode == &"tamer" and a.has("other") and battle.tamer_skill(PLAYER_SIDE, tamer_id).effect == TamerSkillDef.BEAST_SWAP:
		lines.push_front("%s enters" % BattleText.unit_name(battle, a["other"]))
	return "\n".join(PackedStringArray(lines))


## Only what is notable under the cursor: monsters first, then ground, zone, Surge and props.
## An empty Plain square shows nothing.
func _inspector() -> Dictionary:
	if hover == NOWHERE:
		return {}
	var rows: Array = []
	var title := ""
	for layer in [Board.GROUND, Board.AIR]:
		var occ := battle.unit_at(hover, layer)
		if occ == null:
			continue
		var name_line := "%s %s" % [_side_tag(occ), BattleText.unit_title(occ)]
		if title == "":
			title = name_line
		else:
			rows.append(["", name_line])
		rows.append_array(BattleText.unit_rows(battle, occ))
	rows.append_array(BattleText.cell_rows(battle, hover))
	if rows.is_empty():
		return {}
	return {"title": title if title != "" else "[%d, %d]" % [hover.x, hover.y], "rows": rows, "text": ""}


# ---------- log ----------

func _on_event(e: Dictionary) -> void:
	if GameSession.autoplay and e["type"] in [&"round_started", &"battle_over", &"defeated"]:
		print("[autoplay] ", e)
	match e["type"]:
		&"damage":
			var t: BattleUnit = battle.units[e["target"]]
			view.floating_text(t.pos, "-%d" % e["amount"] if int(e["amount"]) > 0 else "blocked",
				Color(1.0, 0.45, 0.4) if int(e["amount"]) > 0 else Color(0.6, 0.85, 1.0))
		&"healed":
			var t2: BattleUnit = battle.units[e["target"]]
			view.floating_text(t2.pos, "+%d" % e["amount"], Color(0.5, 0.95, 0.6))
		&"battle_over":
			GameSession.last_result = BattleSetup.make_result(battle)
	if e["type"] in [&"turn_started", &"turn_ended", &"zone_changed", &"effect_refreshed", &"queue_changed", &"swapped", &"protected"]:
		return
	var line := BattleText.event_line(battle, e)
	if line != "":
		hud.log_line(line)
