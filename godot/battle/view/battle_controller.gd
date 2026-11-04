extends Node3D
## Wires Battle (rules), BattleView (3D) and BattleHud (UI) together and handles input.
## You control side 0 whenever one of your monsters is next in the queue; side 1 is the AI.
## Start with `--autoplay` (after `--`) to let the AI play both sides.

const PLAYER_SIDE := 0
const NOWHERE := Vector2i(-1, -1)
const ACT_MOVE := &"__move"
const ACT_STRIKE := &"__strike"

var request: BattleRequest
var battle: Battle
var view: BattleView
var hud: BattleHud
var rng := RandomNumberGenerator.new()

var mode := &""                    # &"" | &"move" | &"strike" | &"place"
var skill: SkillDef = null
var orient := 0
var aim_dir := Vector2i.UP         # board direction for pushes / Floods / Tail Sweep
var hover := NOWHERE
var _ai_running := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS      # Esc must work while paused
	rng.randomize()
	if OS.get_cmdline_user_args().has("--autoplay"):
		GameSession.autoplay = true
	request = GameSession.request if GameSession.request != null else BattleRequest.default()
	GameSession.request = request
	battle = BattleSetup.build(request)
	battle.event_emitted.connect(_on_event)
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
	hud.log_line("%s on %d×%d — zones steer, ground scars, Surges burn and repaint." % [
		request.mode, battle.board.size, battle.board.size])
	if battle.ambush_side >= 0:
		hud.log_line("%s struck from behind: +%d initiative in round 1." % ["You" if battle.ambush_side == PLAYER_SIDE else "The wild monsters", int(Battle.AMBUSH_BONUS)])
	battle.begin()
	_refresh()
	_check_ai()


func _active() -> Monster:
	return battle.active()


func _is_player_turn() -> bool:
	var m := _active()
	return m != null and m.side == PLAYER_SIDE and not GameSession.autoplay


func _my_turn() -> bool:
	return not battle.over and not _ai_running and not get_tree().paused and _is_player_turn()


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
				_on_action(ACT_MOVE)
			KEY_2:
				_on_action(ACT_STRIKE)
			KEY_3, KEY_4:
				var m := _active()
				if m != null:
					var list := m.skills()
					var i: int = event.keycode - KEY_3
					if i < list.size():
						_on_action(list[i].id)
			KEY_SPACE:
				_on_end_turn()
			KEY_ESCAPE:
				if mode != &"":
					_clear_mode()
					_refresh()
				else:
					_toggle_pause()


func _set_dir(screen: Vector2i) -> void:
	aim_dir = view.board_dir_from_screen(screen)
	_refresh()


func _clear_mode() -> void:
	mode = &""
	skill = null


func _on_action(id: StringName) -> void:
	if not _my_turn():
		return
	var m := _active()
	if id == ACT_MOVE:
		mode = &"" if mode == &"move" else &"move"
		skill = null
	elif id == ACT_STRIKE:
		mode = &"" if mode == &"strike" else &"strike"
		skill = null
	else:
		var s := m.skill_by_id(id)
		if s == null or not battle.can_cast(m.id, s):
			return
		if mode == &"place" and skill == s:
			_clear_mode()
		else:
			mode = &"place"
			skill = s
			orient = battle.effective_orientation(m, s, 0)
	_refresh()


func _rotate() -> void:
	if mode != &"place" or skill == null or not battle.can_rotate(battle.turn_owner, skill):
		return
	orient = (orient + 1) % skill.orientations().size()
	_refresh()


func _click() -> void:
	if not _my_turn() or hover == NOWHERE:
		return
	var m := _active()
	var done := false
	match mode:
		&"move":
			done = battle.move(m.id, hover)
		&"strike":
			done = battle.strike(m.id, hover, aim_dir)
		&"place":
			if skill != null:
				done = battle.cast(m.id, skill, orient, _anchor_for(skill), aim_dir)
	if done:
		_after_action()


## Ring Surges have no aim: they always centre on the caster.
func _anchor_for(s: SkillDef) -> Vector2i:
	if s.twist == SkillDef.Twist.RING:
		return _active().pos
	return hover


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
	if battle.over or battle.ap > 0:
		return
	await get_tree().create_timer(0.5, false).timeout
	if _my_turn() and battle.ap <= 0:
		battle.end_turn()
		_refresh()
		_check_ai()


# ---------- AI turns ----------

func _check_ai() -> void:
	if battle.over or _ai_running or _is_player_turn():
		return
	_ai_running = true
	while not battle.over and not _is_player_turn():
		var who := battle.turn_owner
		_refresh()
		await get_tree().create_timer(0.6, false).timeout
		var guard := 0
		while battle.can_act(who) and guard < 6:
			guard += 1
			if not AiBrain.execute(battle, who, AiBrain.decide(battle, who, rng)):
				break
			_refresh()
			await get_tree().create_timer(0.55, false).timeout
		if not battle.over and battle.turn_owner == who:
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
	var left := battle.ap if _is_player_turn() else 0
	return "AP  " + "●".repeat(left) + "○".repeat(maxi(0, Battle.AP_PER_TURN - left))


func _highlights(arrows: Dictionary) -> Dictionary:
	var out := {}
	if not _my_turn():
		return out
	var m := _active()
	match mode:
		&"move":
			var opts := battle.move_options(m)
			for c in opts:
				out[c] = Color(0.85, 0.45, 0.3, 0.55) if opts[c]["thorn"] > 0 else Color(0.36, 0.56, 0.85, 0.5)
		&"strike":
			for c in battle.strike_targets(m.id):
				out[c] = Color(0.95, 0.35, 0.3, 0.55)
			if m.kin() == MonsterDef.Kin.SCALED and hover != NOWHERE and battle.can_strike(m.id, hover):
				arrows[hover] = aim_dir
		&"place":
			if skill == null:
				return out
			if skill.twist != SkillDef.Twist.RING and skill.twist != SkillDef.Twist.POUNCE:
				var r := battle.skill_range(m, skill)
				for sq: Square in battle.board.all_squares():
					if Board.manhattan(m.pos, sq.pos) <= r:
						out[sq.pos] = Color(0.79, 0.64, 0.36, 0.16)
			if hover == NOWHERE and skill.twist != SkillDef.Twist.RING:
				return out
			var cells := battle.placement_cells(m.id, skill, orient, _anchor_for(skill))
			if cells.is_empty():
				if not skill.orientations().is_empty():
					for c in Shapes.footprint(skill.orientations()[battle.effective_orientation(m, skill, orient)], hover):
						if battle.board.in_bounds(c):
							out[c] = Color(0.85, 0.33, 0.33, 0.6)
				return out
			for c in cells:
				out[c] = _cast_color(Rules.preview_cell(skill, battle.board.at(c))["kind"])
				if skill.needs_direction():
					arrows[c] = aim_dir
				elif skill.is_pull() or skill.twist == SkillDef.Twist.CONSTRICT:
					arrows[c] = Battle._step_toward(c, _anchor_for(skill))
	return out


func _cast_color(kind: StringName) -> Color:
	match kind:
		&"level":
			return Color(0.88, 0.75, 0.38, 0.65)
		&"replace":
			return Color(0.36, 0.56, 0.85, 0.65)
		&"cancel":
			return Color(0.35, 0.82, 0.77, 0.65)
		&"lost":
			return Color(0.85, 0.33, 0.33, 0.65)
		&"ignite":
			return Color(1.0, 0.5, 0.15, 0.7)
	return Color(0.79, 0.64, 0.36, 0.65)


func _side_tag(m: Monster) -> String:
	return "◆" if m.side == PLAYER_SIDE else "◇"


func _order_text() -> String:
	var s := "ROUND %d   ·   %s\n" % [battle.round_number, "your side ◆ / enemy ◇"]
	for i in battle.queue.size():
		var e: Dictionary = battle.queue[i]
		var m: Monster = battle.monsters[e["id"]]
		if not m.is_alive() and not e["ghost"]:
			continue
		var mark := "▶ " if i == battle.queue_idx and not battle.over else ("   " if i > battle.queue_idx else " ✓ ")
		var extra := " (Surge only)" if e["ghost"] else ""
		s += "%s%s %s  %.1f  HP %d/%d%s\n" % [mark, _side_tag(m), m.display_name(), e["init"], m.hp, m.max_hp, extra]
	return s.strip_edges()


func _portrait_text() -> String:
	var m := _active()
	if m == null:
		return ""
	var d := m.def
	var s := "%s %s — %s %s\n" % [_side_tag(m), d.display_name, Aspect.NAMES[d.aspect], MonsterDef.kin_name(d.kin)]
	s += "HP %d/%d · Init %.1f · Move %d · Reach %d · TPR %d\n" % [m.hp, m.max_hp,
			battle.effective_stat(m, Battle.Stat.INIT), int(battle.effective_stat(m, Battle.Stat.MOVE)),
			battle.reach(m), d.tpr]
	s += "Passive: %s · hover a skill for its card" % d.passive_name()
	return s


func _hint_text() -> String:
	if battle.over:
		return ""
	if not _is_player_turn():
		return "%s is acting…" % _active().display_name() if _active() != null else ""
	match mode:
		&"move":
			return "Blue squares — click to move (orange = Thornbed on the way). Esc cancels."
		&"strike":
			var t := "Red squares — click to Strike."
			if _active().kin() == MonsterDef.Kin.SCALED:
				t += " WASD sets the Tail Sweep push direction."
			return t
		&"place":
			if skill == null:
				return ""
			var t2 := "Aim %s." % skill.display_name
			if battle.can_rotate(_active().id, skill):
				t2 += " R / right-click rotates (Adaptive)."
			else:
				t2 += " Fixed shape."
			if skill.needs_direction():
				t2 += " WASD sets the push direction (%s)." % _dir_name(aim_dir)
			if skill.is_pull():
				t2 += " Pulls toward the anchor (centre cell)."
			return t2 + " Click casts · Esc cancels."
	return "1 Move · 2 Strike · 3 Surge · 4 Utility · Space ends turn · Q/E camera · Esc pause"


func _dir_name(d: Vector2i) -> String:
	match d:
		Vector2i(0, -1):
			return "north"
		Vector2i(0, 1):
			return "south"
		Vector2i(-1, 0):
			return "west"
	return "east"


func _actions() -> Array:
	var out: Array = []
	var m := _active()
	if m == null or m.side != PLAYER_SIDE:
		return out
	var mine := _my_turn()
	out.append({"id": ACT_MOVE, "text": "Move\n1 AP", "enabled": mine and battle.ap >= 1,
		"selected": mode == &"move", "card": {"title": "Move", "rows": InfoText.move_rows(battle, m)}})
	var can_strike := mine and not battle.strike_targets(m.id).is_empty()
	var strike_rows := InfoText.strike_rows(battle, m)
	if mine and not can_strike:
		strike_rows.push_front(["Unavailable", "no enemy or prop within Reach %d%s" % [battle.reach(m),
				" (or not enough AP)" if battle.ap < 2 else ""]])
	out.append({"id": ACT_STRIKE, "text": "%s\n%s" % [m.def.strike_name(), "2 AP"], "enabled": can_strike,
		"selected": mode == &"strike", "card": {"title": "Strike — " + m.def.strike_name(), "rows": strike_rows}})
	for s in m.skills():
		var rows := InfoText.skill_rows(s, battle, m)
		var why := battle.cast_error(m.id, s) if mine else ""
		if why != "":
			rows.push_front(["Unavailable", why])
		var charging := s.kind == SkillDef.Kind.SURGE and battle.has_charging(m.id)
		out.append({"id": s.id, "text": s.display_name + ("\ncharging" if charging else "\n1 AP"),
			"enabled": mine and battle.can_cast(m.id, s), "selected": mode == &"place" and skill == s,
			"card": {"title": s.display_name, "rows": rows}})
	return out


func _banner_text() -> String:
	if not battle.over:
		return ""
	if battle.winner_side == PLAYER_SIDE:
		return "Victory"
	return "Draw" if battle.winner_side < 0 else "Defeat"


func _preview_text() -> String:
	if not _my_turn() or hover == NOWHERE:
		return ""
	var m := _active()
	if mode == &"strike":
		if not battle.can_strike(m.id, hover):
			return "Strike — " + battle.strike_error(m.id, hover)
		var t := battle.monster_at(hover)
		var dmg := battle.strike_damage(m.id, hover)
		var who: String = t.display_name() if t != null else battle.board.at(hover).object["name"]
		return "%s on %s — %d damage%s · %d AP" % [m.def.strike_name(), who, dmg,
				" (kills)" if t != null and dmg >= t.hp else "", battle.strike_cost(m.id, hover)]
	if mode == &"move":
		var opts := battle.move_options(m)
		if opts.has(hover) and opts[hover]["thorn"] > 0:
			return "Move — %d Thornbed damage on the way" % opts[hover]["thorn"]
		return ""
	if mode != &"place" or skill == null:
		return ""
	var anchor := _anchor_for(skill)
	var cells := battle.placement_cells(m.id, skill, orient, anchor)
	if cells.is_empty():
		return "%s — can't place here:\n%s" % [skill.display_name, battle.placement_error(m.id, skill, orient, anchor)]
	var s := "%s — %d squares" % [skill.display_name, cells.size()]
	if skill.kind == SkillDef.Kind.SURGE:
		s += " · %s %d dmg, fires at the start of your %s" % [SkillDef.surge_type_name(skill.surge_type),
				skill.surge_value() + m.momentum_bonus, "next turn" if skill.fire_delay() == 1 else "turn after next"]
	for line in CastPreview.lines(battle, m, skill, cells, aim_dir, anchor):
		s += "\n• " + line
	return s


func _inspector() -> Dictionary:
	if hover == NOWHERE:
		return {}
	var sq := battle.board.at(hover)
	var occ := battle.monster_at(hover)
	var rows: Array = []
	var title := "Square [%d, %d]" % [hover.x, hover.y]
	if occ != null:
		title = "%s %s  ·  [%d, %d]" % [_side_tag(occ), occ.display_name(), hover.x, hover.y]
		rows = InfoText.monster_rows(occ.def, occ, battle)
		rows.append(["", ""])
	rows.append_array(InfoText.square_rows(battle, sq))
	return {"title": title, "rows": rows, "text": ""}


# ---------- log ----------

func _name(id: StringName) -> String:
	var m: Monster = battle.monsters.get(id)
	return m.display_name() if m != null else String(id)


func _on_event(e: Dictionary) -> void:
	if GameSession.autoplay and e["type"] in [&"round_started", &"battle_over", &"slain"]:
		print("[autoplay] ", e)
	match e["type"]:
		&"moved":
			hud.log_line("%s moves to [%d,%d]" % [_name(e["who"]), e["to"].x, e["to"].y])
		&"cast":
			var sk: SkillDef = battle.monsters[e["who"]].skill_by_id(e["skill"])
			var verb := "declares" if sk.kind == SkillDef.Kind.SURGE else "casts"
			var detail := ""
			if e.has("result"):
				var parts := []
				var names := {&"new": "new", &"level": "levelled up", &"replace": "replaced",
					&"cancel": "cancelled (opposite)", &"lost": "no effect", &"ignite": "ignited"}
				for k in e["result"]["counts"]:
					parts.append("%d %s" % [e["result"]["counts"][k], names.get(k, String(k))])
				for k in ["cleared", "boosted", "ignited", "extinguished", "healed"]:
					if e["result"][k] > 0 and not (k == "ignited" and e["result"]["counts"].has(&"ignite")):
						parts.append("%d ground/prop %s" % [e["result"][k], k])
				detail = ": " + ", ".join(PackedStringArray(parts))
			elif e.get("lost", 0) > 0:
				detail = ": %d squares already claimed" % e["lost"]
			hud.log_line("%s %s %s%s" % [_name(e["who"]), verb, sk.display_name, detail])
		&"surge_fired":
			hud.log_line("%s's %s fires!" % [_name(e["who"]), e["name"]])
		&"strike":
			hud.log_line("%s strikes [%d,%d]" % [_name(e["who"]), e["target"].x, e["target"].y])
		&"damage":
			view.floating_text(battle.monsters[e["target"]].pos, "-%d" % e["amount"], Color(1.0, 0.45, 0.4))
			hud.log_line("%s takes %d (%s)" % [_name(e["target"]), e["amount"], e["source"]])
		&"absorbed":
			view.floating_text(battle.monsters[e["target"]].pos, "blocked", Color(0.6, 0.85, 1.0))
			hud.log_line("%s is unharmed." % _name(e["target"]))
		&"blanked":
			hud.log_line("The Flood can't reach the high ground at [%d,%d]." % [e["pos"].x, e["pos"].y])
		&"ignite":
			hud.log_line("A Tree catches fire at [%d,%d]." % [e["pos"].x, e["pos"].y])
		&"extinguish":
			hud.log_line("A burning Tree is put out.")
		&"burned_down":
			hud.log_line("A Tree burns down → Lava at [%d,%d]." % [e["pos"].x, e["pos"].y])
		&"shatter":
			hud.log_line("A prop shatters → Rubble, debris flies!")
		&"collapse":
			hud.log_line("The high ground at [%d,%d] collapses." % [e["pos"].x, e["pos"].y])
		&"slain":
			hud.log_line("%s is slain!" % _name(e["who"]))
		&"displaced":
			hud.log_line("%s is moved to [%d,%d]" % [_name(e["who"]), e["to"].x, e["to"].y])
		&"collision":
			hud.log_line("%s slams into the %s!" % [_name(e["who"]), e["prop"]])
		&"pinned":
			hud.log_line("%s is pinned against the edge." % _name(e["who"]))
		&"zones_faded":
			hud.log_line("%d zone squares fade and repaint the ground." % e["count"])
		&"voidscar":
			hud.log_line("Voidscar spreads to [%d,%d]." % [e["pos"].x, e["pos"].y])
		&"round_started":
			hud.log_line("Round %d — %s acts first." % [e["round"], _name(e["first"])])
		&"battle_over":
			GameSession.last_result = BattleSetup.make_result(battle)
			hud.log_line("The battle is over.")
