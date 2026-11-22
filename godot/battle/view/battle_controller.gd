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
var aim_dir := Vector2i(0, -1)     # cardinal direction of a placed skill that needs one
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
	if not GameSession.autoplay:
		battle.choice_sides = [PLAYER_SIDE]       # you pick the target of a tied Dragon Vein yourself (2026-11-14)
	battle.event_emitted.connect(_on_event)
	_tetrominoes = Shapes.orientations([&"I4", &"O4", &"T4", &"S4", &"L4"])
	view = BattleView.new()
	view.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(view)
	view.build(battle)
	hud = BattleHud.new()
	add_child(hud)
	hud.build()
	view.bottom_room = BattleHud.BAR_ROOM         # the board sits in the middle of the room above the bar
	hud.set_exit_mode(GameSession.return_scene != "")
	hud.action_pressed.connect(_on_action)
	hud.end_turn_pressed.connect(_on_end_turn)
	hud.wait_pressed.connect(_on_wait)
	hud.heal_pressed.connect(_on_heal)
	hud.restart_pressed.connect(func(): get_tree().reload_current_scene())
	hud.resume_pressed.connect(_toggle_pause)
	hud.menu_pressed.connect(_to_menu)
	if request.map != null:
		hud.log_line("%s (%d×%d), %d against %d" % [request.map.display_name, request.map.width, request.map.height, battle.living(0).size(), battle.living(1).size()])
	else:
		hud.log_line("%s on %d×%d" % [request.mode, battle.board.size, battle.board.size])
	for u in battle.living(PLAYER_SIDE):
		var notes: PackedStringArray = []
		if u.sheet.pace_bonus > 0.0:
			notes.append("+%.1f Pace (prepared)" % u.sheet.pace_bonus)
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


## The round end waits for you to pick the enemy a Dragon Vein of yours hits.
func _awaiting_choice() -> bool:
	return not battle.pending_choice.is_empty() and int(battle.pending_choice["side"]) == PLAYER_SIDE and not GameSession.autoplay


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
		if event.is_action_pressed(&"battle_cancel"):
			_toggle_pause()
		return
	# every key and button is an action of the Input Map (Project Settings), never a key in the code
	if event is InputEventMouseMotion:
		var c = view.cell_at_screen(event.position)
		hover = c if c != null else NOWHERE
		_refresh()
	elif event.is_action_pressed(&"battle_select"):
		_click()
	elif event.is_action_pressed(&"battle_rotate"):
		_rotate()
	elif event.is_action_pressed(&"battle_aim_north"):
		_set_dir(Vector2i(0, -1))
	elif event.is_action_pressed(&"battle_aim_south"):
		_set_dir(Vector2i(0, 1))
	elif event.is_action_pressed(&"battle_aim_west"):
		_set_dir(Vector2i(-1, 0))
	elif event.is_action_pressed(&"battle_aim_east"):
		_set_dir(Vector2i(1, 0))
	elif event.is_action_pressed(&"battle_step"):
		_on_action(ACT_STEP)
	elif event.is_action_pressed(&"battle_heal"):
		_on_heal()
	elif event.is_action_pressed(&"battle_glossary"):
		hud.show_glossary()
	elif event.is_action_pressed(&"battle_confirm"):
		if placing:
			_on_action(ACT_START)
		else:
			_on_end_turn()
	elif event.is_action_pressed(&"battle_cancel"):
		if mode != &"" or placing_pick != &"":
			_clear_mode()
			placing_pick = &""
			_refresh()
		else:
			_toggle_pause()
	else:
		for i in 6:                                   # the six kit slots, in the order of the bar's columns
			if event.is_action_pressed(StringName("battle_skill_%d" % (i + 1))):
				_on_action(StringName(SLOT_PREFIX + str(i)))
				return


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
		if not again and battle.tamer_skill(PLAYER_SIDE, tid) != null and not battle.tamer_spent(PLAYER_SIDE, tid):
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
					return {"type": &"skill", "slot": slot, "dir": aim["dir"], "origin": aim["origin"]}
				_:
					if not s.is_free_shape():             # a base shape around the user: aimed like a Strike
						var around := _strike_aim(u, s)
						if around.is_empty():
							return {}
						return {"type": &"skill", "slot": slot, "anchor": u.pos + around["dir"], "dir": aim_dir, "rot": rot}
					if hover == NOWHERE:
						return {}
					return {"type": &"skill", "slot": slot, "anchor": hover, "dir": aim_dir, "rot": rot}
		&"tamer":
			return _tamer_action()
	return {}


## Direction of a base shape (a Strike, or something created around the user) from the hovered square:
## the eight directions seen from the body square nearest to it. Shapes around the whole user need none.
func _strike_aim(u: BattleUnit, s: BattleSkillDef) -> Dictionary:
	if s.shape_dirs() == BattleShapes.NO_DIR:
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
	return {"dir": dir, "origin": origin} if BattleShapes.is_legal_dir(s.shape_id(), dir, s.shape_extension) else {}


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
		TamerSkillDef.SEAL:
			if hover == NOWHERE:
				return {}
			a["cells"] = [hover]
		TamerSkillDef.LAY:
			if hover == NOWHERE:
				return {}
			var line: Array = []
			var along: Vector2i = Board.CARDINAL[rot % Board.CARDINAL.size()]
			for k in battle.lay_count(PLAYER_SIDE, def):
				if battle.board.in_bounds(hover + along * k):
					line.append(hover + along * k)
			a["cells"] = line
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
	if _awaiting_choice():
		var picked_unit := battle.any_unit_at(hover) if hover != NOWHERE else null
		if picked_unit != null and battle.pending_choice["options"].has(picked_unit.id):
			battle.apply({"type": &"choose_target", "unit": picked_unit.id})
			_refresh()
			_check_ai()
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


## Heal: the acting monster spends Stamina and heals (docs/battle.md §2.4).
func _on_heal() -> void:
	if placing or not _my_turn() or battle.check({"type": &"heal"}) != "":
		return
	_clear_mode()
	battle.apply({"type": &"heal"})
	_refresh()


## Test switch `delay_turn`: the running turn moves to the end of the round.
func _on_wait() -> void:
	if not _my_turn() or battle.check({"type": &"delay"}) != "":
		return
	_clear_mode()
	battle.apply({"type": &"delay"})
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
		if battle.board.in_bounds(cell.pos) and BattleBoards.may_start(battle, request.mode, cell.pos) and cell.prop == null:
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
		if cell == null or not BattleBoards.may_start(battle, request.mode, c) or battle.board.prop_at(c, u.layer) != null:
			return false
		var other := battle.board.unit_id_at(c, u.layer)
		if other != &"" and other != u.id:
			return false
	return true


# ---------- AI turns ----------

func _check_ai() -> void:
	if battle.over or _ai_running or _is_player_turn() or _awaiting_choice():
		return
	_ai_running = true
	while not battle.over and not _is_player_turn() and not _awaiting_choice():
		var who := battle.turn_owner
		var entry := battle.queue_idx
		var round_no := battle.round_number
		_refresh()
		await get_tree().create_timer(0.6, false).timeout
		var guard := 0
		while not battle.over and battle.turn_owner == who and battle.queue_idx == entry and battle.round_number == round_no \
				and guard < AiBrain.MAX_ACTIONS_PER_TURN:
			guard += 1
			var a := AiBrain.decide(battle, rng, true)
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
	var wait_why := battle.check({"type": &"delay"}) if _my_turn() else ""
	var wait_unit := battle.active() if _my_turn() else null
	hud.set_wait(not placing, _my_turn() and wait_why == "", battle.waits_left(wait_unit) if wait_unit != null else -1, wait_why)
	var heal_why := battle.check({"type": &"heal"}) if _my_turn() and not placing else ""
	var heal_text := "Heal: costs %d Stamina and no AP, heals %d HP. Once per turn." % [Battle.HEAL_STAMINA, Battle.HEAL_HP]
	hud.set_heal(not placing, _my_turn() and not placing and heal_why == "", heal_text if heal_why == "" else "%s\n%s" % [heal_text, heal_why])

func _ap_text() -> String:
	var u := _active()
	if u == null or placing:
		return "AP"
	var total := BattleStats.ap(u)
	var left := battle.ap if _is_player_turn() else 0
	return "AP  " + "●".repeat(left) + "○".repeat(maxi(0, total - left))


func _highlights(arrows: Dictionary) -> Dictionary:
	var out := _action_highlights(arrows)
	if not placing and not _awaiting_choice():
		_prop_hover_highlights(out, arrows)
	return out


## Hovering a prop shows where its operations land (2026-11-15): walls and other spawns, ground,
## zones, damage squares and push / pull arrows, for every moment it acts at. Open information,
## shown in any mode on squares no action highlight uses.
func _prop_hover_highlights(out: Dictionary, arrows: Dictionary) -> void:
	if hover == NOWHERE:
		return
	var prop := battle.board.prop_at(hover, Board.GROUND)
	if prop == null or prop.hp <= 0:
		return
	for a in prop.def.aftermath:
		if a == null:
			continue
		for o in a.offsets():
			var q: Vector2i = prop.pos + o
			if not battle.board.in_bounds(q) or out.has(q):
				continue
			var cell := battle.board.at(q)
			match a.op:
				"spawn":
					if o != Vector2i.ZERO and BattleBoardOps.can_place_prop(battle, battle.content.prop(a.spawn_prop), q):
						out[q] = COL_AREA
				"ground":
					if cell.ground != battle.voidscar_ground and cell.ground != GroundDef.WELL:
						out[q] = COL_REPLACE
				"zone":
					out[q] = COL_CANCEL
				"damage":
					out[q] = COL_HIT
				_:
					if o != Vector2i.ZERO and battle.any_unit_at(q) != null:
						out[q] = COL_HARM
						var d := BattlePayload._eight_dir(o)
						arrows[q] = d if a.op == "push" else -d


func _action_highlights(arrows: Dictionary) -> Dictionary:
	var out := {}
	if placing:
		for p in _start_squares():
			out[p] = COL_RANGE if placing_pick == &"" else COL_MOVE
		if placing_pick != &"":
			for c in battle.units[placing_pick].cells():
				out[c] = COL_PICK
		return out
	if _awaiting_choice():
		for id: StringName in battle.pending_choice["options"]:
			for c in battle.units[id].cells():
				out[c] = COL_PICK
		out[battle.pending_choice["pos"]] = COL_AREA
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
					var legal := battle.strike_error(u, s, aim["dir"], aim["origin"]) == ""
					for h in s.shape_hits(aim["dir"]):
						var cell: Vector2i = aim["origin"] + h["o"]
						if battle.board.in_bounds(cell) and not u.covers(cell):
							out[cell] = COL_HIT if legal else COL_BAD
				_:
					_placement_highlights(u, s, out, arrows)
		&"tamer":
			_tamer_highlights(out)
	return out


func _move_highlights(opts: Dictionary, out: Dictionary) -> void:
	var u := _active()
	for origin: Vector2i in opts:
		for c in u.cells_at(origin):
			if not out.has(c) or int(opts[origin]["harm"]) <= 0:
				out[c] = COL_HARM if int(opts[origin]["harm"]) > 0 else COL_MOVE


func _placement_highlights(u: BattleUnit, s: BattleSkillDef, out: Dictionary, arrows: Dictionary) -> void:
	if s.is_free_shape() and s.anchor_mode == "reach":
		var reach := BattleStats.reach(battle, u)
		for cell in battle.board.cells:
			if u.manhattan_to(cell.pos) <= reach:
				out[cell.pos] = COL_RANGE
	var anchor := hover
	if not s.is_free_shape():                     # a base shape around the user: aimed like a Strike
		var around := _strike_aim(u, s)
		anchor = NOWHERE if around.is_empty() else u.pos + around["dir"]
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
		elif BattleCasting.pushes_by_rotation(battle, s):
			arrows[c] = BattleCasting.rot_dir(u, s, rot)      # the push zone it leaves points where the shape points
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
	if def.effect == TamerSkillDef.DOMAIN_GLIMPSE or def.effect == TamerSkillDef.SEAL or def.effect == TamerSkillDef.LAY:
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
		s += "%s%s %s  %.1f  %d/%d\n" % [mark, _side_tag(u), u.display_name(), e["pace"], u.hp, u.max_hp]
	return s.strip_edges() + _forecast_text()


## What the round end would do on the board as it stands (BattleTurn.round_end_forecast): who is hit by what and
## who falls. Shown under the queue all the time; the turns still to come can change it.
func _forecast_text() -> String:
	if battle.over or _awaiting_choice():
		return ""
	var f := BattleTurn.round_end_forecast(battle)
	if f["hits"].is_empty():
		return "\n\nIF THE ROUND ENDED NOW\nnobody is hit"
	var per := {}                                   # unit id -> ["Dragon Vein −1", ...]
	for h: Dictionary in f["hits"]:
		if not per.has(h["unit"]):
			per[h["unit"]] = []
		per[h["unit"]].append("%s −%d" % [h["source"], h["amount"]])
	var s := "\n\nIF THE ROUND ENDED NOW"
	for id in battle.roster:
		if per.has(id):
			var u: BattleUnit = battle.units[id]
			s += "\n%s %s: %s%s" % [_side_tag(u), u.display_name(), ", ".join(per[id]), "  FALLS" if f["falls"].has(id) else ""]
	return s


func _portrait_text() -> String:
	var u := _active()
	if u == null or placing:
		return ""
	return "%s %s%s%s%sReach %d" % [_side_tag(u), u.display_name(), BattleText.SEP, BattleText.move_text(battle, u),
		BattleText.SEP, BattleStats.reach(battle, u)]


func _hint_text() -> String:
	if placing:
		return "Click a monster, then a start square · %s starts" % UiTheme.key_text(&"battle_confirm") if placing_pick == &"" else "Click a start square or a monster to swap"
	if battle.over:
		return ""
	if _awaiting_choice():
		return "Dragon Vein: click the enemy it hits (green)"
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
					return "Aim and click"
				_:
					var t := "Click to cast"
					if BattleStats.can_rotate(u) and s.is_free_shape():
						t += " · R rotates"
					return t + (" · %s direction" % _aim_keys() if s.needs_direction() else "")
		&"tamer":
			var def := battle.tamer_skill(PLAYER_SIDE, tamer_id)
			if def == null:
				return ""
			match def.effect:
				TamerSkillDef.DOMAIN_GLIMPSE:
					return "R changes shape · click places"
				TamerSkillDef.SEAL:
					var why := battle.check(_tamer_action()) if hover != NOWHERE else ""
					return why if why != "" else "Click a square to lay Seal Ground (%d%% at 1 HP)" % def.seal_base
				TamerSkillDef.LAY:
					var lay_why := battle.check(_tamer_action()) if hover != NOWHERE else ""
					return lay_why if lay_why != "" else ("Click a square" + (" · R turns the line" if battle.lay_count(PLAYER_SIDE, def) > 1 else ""))
				TamerSkillDef.SWAP_PLACES:
					return "Click the %s monster" % ("first" if picked.is_empty() else "second")
				TamerSkillDef.BEAST_SWAP:
					return "Click the monster that leaves"
				TamerSkillDef.RENEW, TamerSkillDef.EXTEND, TamerSkillDef.SPREAD:
					return "Click one of your monsters to confirm"
			return "Click one of your monsters"
	return "%s Step · %s–%s Skills · %s End turn" % [UiTheme.key_text(&"battle_step"), UiTheme.key_text(&"battle_skill_1"),
		UiTheme.key_text(&"battle_skill_6"), UiTheme.key_text(&"battle_confirm")]


## The four aim keys as the Input Map has them ("WASD").
func _aim_keys() -> String:
	return "".join([&"battle_aim_north", &"battle_aim_west", &"battle_aim_south", &"battle_aim_east"].map(
		func(a: StringName) -> String: return UiTheme.key_text(a)))


func _actions() -> Array:
	var out: Array = []
	if placing:
		out.append({"id": ACT_START, "group": &"step", "text": "Start Battle\n%s" % UiTheme.key_text(&"battle_confirm"), "enabled": true, "selected": false,
			"card": {"title": "Start Battle", "rows": []}})
		return out
	var u := _active()
	if u == null or u.side != PLAYER_SIDE:
		return out
	var mine := _my_turn()
	out.append({"id": ACT_STEP, "group": &"step", "text": "Step\nMove · %d AP" % BattleMoves.step_ap(), "color": BattleText.KINDS["move"][1],
		"enabled": mine and battle.ap >= battle.min_step_cost(u) and not BattleStats.is_rooted(u),
		"selected": mode == &"step", "card": {"title": "Step", "rows": BattleText.step_rows()}})
	var basic := battle.skill_in_slot(u, Battle.BASIC_SLOT)
	if basic != null:                             # test switch: the Basic Jab stands beside Step, not in the kit
		var no := "" if not mine else ("needs %d AP, %d left" % [basic.cost(), battle.ap] if battle.ap < basic.cost() else battle.usage_error(u, Battle.BASIC_SLOT))
		var basic_rows := BattleText.skill_rows(battle.content, basic)

		out.append({"id": StringName(SLOT_PREFIX + str(Battle.BASIC_SLOT)), "group": &"step", "text": "%s\nStrike · %d AP" % [basic.display_name, basic.cost()], "color": BattleText.kind_color(battle.content, basic),
			"enabled": mine and no == "", "selected": mode == &"skill" and slot == Battle.BASIC_SLOT,
			"card": {"title": basic.display_name, "rows": basic_rows, "note": no}})
	for i in u.sheet.skills.size():
		var s := u.sheet.skills[i]
		var rows := BattleText.skill_rows(battle.content, s)
		var why := ""
		if s.is_active() and mine:
			if battle.ap < s.cost():
				why = "needs %d AP, %d left" % [s.cost(), battle.ap]
			else:
				why = battle.usage_error(u, i)
		var kind_row := BattleText.kind_row(battle.content, s)
		if not kind_row.is_empty():
			rows.push_front(kind_row)
		var kind_word := BattleText.kind_label(battle.content, s)
		var label := s.display_name
		if s.kind == BattleSkillDef.STRIKE:
			label = "%s (%s)" % [s.display_name, s.shape_label()]
		out.append({"id": StringName(SLOT_PREFIX + str(i)), "group": &"skill", "color": BattleText.kind_color(battle.content, s),
			"text": "%s\n%s%s" % [label, (kind_word + " · ") if kind_word != "" and s.is_active() else "", "Passive" if not s.is_active() else (("%d AP + Stamina" % s.cost() if s.cost() > 0 else "Stamina") if s.uses_stamina() else "%d AP" % s.cost())],
			"enabled": mine and s.is_active() and why == "", "selected": mode == &"skill" and slot == i,
			"card": {"title": label, "rows": rows, "note": why}})
	for def: TamerSkillDef in battle.tamer_loadout[PLAYER_SIDE]:
		var used: bool = battle.tamer_spent(PLAYER_SIDE, def.id)
		out.append({"id": StringName(TAMER_PREFIX + String(def.id)), "group": &"tamer", "text": "%s\n%s" % [def.display_name, "used" if used else "tamer"],
			"enabled": mine and not used, "selected": mode == &"tamer" and tamer_id == def.id,
			"card": {"title": def.display_name, "rows": [["", def.description], ["", def.source_text()]]}})
	return out


func _banner_text() -> String:
	if not battle.over:
		return ""
	if battle.draw:
		return "Draw"
	return "Victory" if battle.winner_side == PLAYER_SIDE else "Defeat"


## Preview of the Dragon Vein choice: what each option would look like after the round end,
## from a dry run on a copy (so surround damage and the like are included).
func _choice_preview_text() -> String:
	var over_unit := battle.any_unit_at(hover) if hover != NOWHERE else null
	var lines: Array[String] = ["Dragon Vein hits one of:"]
	for id: StringName in battle.pending_choice["options"]:
		var u: BattleUnit = battle.units[id]
		var sim := battle.clone()
		sim.apply({"type": &"choose_target", "unit": id})
		var after: BattleUnit = sim.units[id]
		var result := "falls" if not after.is_alive() else "%d → %d HP" % [u.hp, after.hp]
		lines.append("%s%s: %s" % ["▶ " if over_unit != null and over_unit.id == id else "   ", u.display_name(), result])
	return "\n".join(lines)


func _preview_text() -> String:
	if _awaiting_choice():
		return _choice_preview_text()
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
		&"defeated":
			hud.add_fallen(BattleText.unit_name(battle, e["who"]), BattleText.hp_history_lines(battle, e["who"]))
		&"battle_over":
			GameSession.last_result = BattleSetup.make_result(battle)
	if e["type"] in [&"turn_started", &"turn_ended", &"zone_changed", &"effect_refreshed", &"queue_changed", &"swapped", &"protected"]:
		return
	var line := BattleText.event_line(battle, e)
	if line != "":
		hud.log_line(line)
