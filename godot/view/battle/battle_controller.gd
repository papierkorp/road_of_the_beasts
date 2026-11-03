extends Node3D
## Wires Battle (rules), BattleView (3D) and BattleHud (UI) together and handles input.
## You play the Blaze Tiger; the Gloom Wolf is driven by AiBrain.

const PLAYER := &"tiger"
const NOWHERE := Vector2i(-1, -1)

var battle: Battle
var view: BattleView
var hud: BattleHud
var rng := RandomNumberGenerator.new()

var mode := &""                    # &"" | &"move" | &"place"
var skill: SkillDef = null
var orient := 0
var hover := NOWHERE
var _ai_running := false


func _ready() -> void:
	rng.randomize()
	battle = BattleSetup.prototype()
	battle.event_emitted.connect(_on_event)
	view = BattleView.new()
	add_child(view)
	view.build(battle)
	hud = BattleHud.new()
	add_child(hud)
	hud.build(battle.monsters[PLAYER].skills)
	hud.skill_pressed.connect(_on_skill_pressed)
	hud.end_turn_pressed.connect(_on_end_turn)
	hud.restart_pressed.connect(func(): get_tree().reload_current_scene())
	hud.log_line("Round 1 — zones steer, lava scars, Surges burn and repaint.")
	battle.begin()
	_refresh()
	_check_ai()


# ---------- input ----------

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var c = view.cell_at_screen(event.position)
		hover = c if c != null else NOWHERE
		_refresh()
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_click()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_rotate()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_R:
		_rotate()


func _my_turn() -> bool:
	return not battle.over and not _ai_running and battle.turn_owner == PLAYER


func _on_skill_pressed(id: StringName) -> void:
	if not _my_turn():
		return
	if id == BattleHud.MOVE_ID:
		mode = &"" if mode == &"move" else &"move"
		skill = null
	else:
		var s: SkillDef = battle.monsters[PLAYER].skill_by_id(id)
		if s == null or not battle.can_cast(PLAYER, s):
			return
		if mode == &"place" and skill == s:
			mode = &""
			skill = null
		else:
			mode = &"place"
			skill = s
			orient = 0
	_refresh()


func _rotate() -> void:
	if mode != &"place" or skill == null:
		return
	orient = (orient + 1) % skill.orientations().size()
	_refresh()


func _click() -> void:
	if not _my_turn() or hover == NOWHERE:
		return
	var done := false
	if mode == &"move":
		done = battle.move(PLAYER, hover)
	elif mode == &"place" and skill != null:
		done = battle.cast(PLAYER, skill, orient, hover)
	if done:
		_after_action()


func _on_end_turn() -> void:
	if not _my_turn():
		return
	mode = &""
	skill = null
	battle.end_turn()
	_refresh()
	_check_ai()


func _after_action() -> void:
	mode = &""
	skill = null
	_refresh()
	if battle.over or battle.ap > 0:
		return
	await get_tree().create_timer(0.55).timeout
	if _my_turn() and battle.ap <= 0:
		battle.end_turn()
		_refresh()
		_check_ai()


# ---------- AI turns ----------

func _check_ai() -> void:
	if battle.over or _ai_running or battle.turn_owner == PLAYER:
		return
	_ai_running = true
	while not battle.over and battle.turn_owner != PLAYER:
		var who := battle.turn_owner
		await get_tree().create_timer(0.8).timeout
		while battle.can_act(who):
			var a := AiBrain.decide(battle, who, rng)
			var ok := false
			match a["type"]:
				&"move":
					ok = battle.move(who, a["to"])
				&"cast":
					ok = battle.cast(who, a["skill"], a["oi"], a["anchor"])
			if not ok:
				break
			_refresh()
			await get_tree().create_timer(0.7).timeout
		if not battle.over:
			battle.end_turn()
		_refresh()
	_ai_running = false
	_refresh()


# ---------- refresh ----------

func _refresh() -> void:
	view.set_highlights(_highlights())
	view.refresh()
	hud.update(_order_text(), "AP  %d / %d" % [battle.ap if battle.turn_owner == PLAYER else 0, Battle.AP_PER_TURN],
			_hint_text(), _preview_text(), _inspector_text(), _skill_states(),
			_my_turn(), _banner_text())


func _highlights() -> Dictionary:
	var out := {}
	if not _my_turn():
		return out
	var me: Monster = battle.monsters[PLAYER]
	if mode == &"move":
		for c in battle.reachable(me, int(battle.effective_stat(me, Battle.Stat.MOVE))):
			out[c] = Color(0.36, 0.56, 0.85, 0.5)
	elif mode == &"place" and skill != null:
		var rng_cells := battle.skill_range(me, skill)
		for sq: Square in battle.board.all_squares():
			if Board.manhattan(me.pos, sq.pos) <= rng_cells:
				out[sq.pos] = Color(0.79, 0.64, 0.36, 0.18)
		if hover != NOWHERE:
			var cells := battle.placement_cells(PLAYER, skill, orient, hover)
			if cells.is_empty():
				for c in Shapes.footprint(skill.orientations()[orient], hover):
					if battle.board.in_bounds(c):
						out[c] = Color(0.85, 0.33, 0.33, 0.6)
			else:
				for c in cells:
					out[c] = _cast_color(Rules.preview_cell(skill, battle.board.at(c))["kind"])
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
	return Color(0.79, 0.64, 0.36, 0.65)


func _order_text() -> String:
	var s := "ROUND %d   ·   " % battle.round_number
	for id in battle.order:
		var m: Monster = battle.monsters[id]
		var mark := "▶ " if id == battle.turn_owner and not battle.over else ""
		s += "%s%s  INIT %d  HP %d/%d%s     " % [mark, m.display_name,
				int(battle.effective_stat(m, Battle.Stat.INIT)), m.hp, m.max_hp,
				"  ⚠ charging" if battle.has_charging(id) else ""]
	return s


func _hint_text() -> String:
	if mode == &"move":
		return "Blue squares — click to move."
	if mode == &"place" and skill != null:
		return "Aim %s (%d orientations). R / right-click rotates, left-click casts." % [
				skill.display_name, skill.orientations().size()]
	if _my_turn():
		return "Zones control movement for 2 rounds. Lava changes the ground for good. Surges burn, then repaint."
	return "%s is acting…" % battle.monsters[battle.turn_owner].display_name


func _skill_states() -> Dictionary:
	var out := {}
	var mine := _my_turn()
	out[BattleHud.MOVE_ID] = {"enabled": mine and battle.ap >= 1, "selected": mode == &"move",
			"text": "Move\n1 AP"}
	var me: Monster = battle.monsters[PLAYER]
	for s in me.skills:
		var cd: int = me.cooldowns.get(s.id, 0)
		out[s.id] = {"enabled": mine and battle.can_cast(PLAYER, s),
				"selected": mode == &"place" and skill == s,
				"text": s.display_name + ("\nCD %d" % cd if cd > 0 else "")}
	return out


func _banner_text() -> String:
	if not battle.over:
		return ""
	return "Victory" if battle.winner == PLAYER else "Defeat"


func _preview_text() -> String:
	if mode != &"place" or skill == null or hover == NOWHERE or not _my_turn():
		return ""
	var me: Monster = battle.monsters[PLAYER]
	var cells := battle.placement_cells(PLAYER, skill, orient, hover)
	if cells.is_empty():
		var why := "can't go here"
		var fp := Shapes.footprint(skill.orientations()[orient], hover)
		if Board.manhattan(me.pos, hover) > battle.skill_range(me, skill):
			why = "out of range (%d)" % battle.skill_range(me, skill)
		elif fp.any(func(c: Vector2i): return not battle.board.in_bounds(c)):
			why = "doesn't fit on the board"
		elif fp.any(func(c: Vector2i): return battle.board.in_bounds(c) and battle.board.at(c).object != null):
			why = "blocked by a prop"
		else:
			why = "square is occupied"
		return "%s: invalid — %s" % [skill.display_name, why]
	var counts := {}
	var plus := 0
	var minus := 0
	var cool := 0
	var fan := 0
	var dmg_min := 99
	var dmg_max := 0
	for c in cells:
		var sq := battle.board.at(c)
		var kind: StringName = Rules.preview_cell(skill, sq)["kind"]
		counts[kind] = counts.get(kind, 0) + 1
		if skill.kind == SkillDef.Kind.ZONE:
			var mod := Aspect.attunement_mod(skill.aspect, sq.attunement)
			if mod > 0: plus += 1
			if mod < 0: minus += 1
			var r := Rules.zone_on_ground(skill, sq)
			if r == &"cool": cool += 1
			if r == &"fan": fan += 1
		if skill.kind == SkillDef.Kind.SURGE and kind != &"lost":
			var d := 0 if sq.object != null else sq.surge_damage(skill.aspect, skill.value)
			dmg_min = mini(dmg_min, d)
			dmg_max = maxi(dmg_max, d)
	var s := "%s — %d squares" % [skill.display_name, cells.size()]
	if skill.kind == SkillDef.Kind.SURGE:
		s += " · damage %s per square (after ground + Veil), then repaints" % (
				str(dmg_max) if dmg_min == dmg_max else "%d–%d" % [dmg_min, dmg_max])
	for k in counts:
		if k != &"new":
			s += " · %s ×%d" % [k, counts[k]]
	if plus > 0: s += " · stronger (own attunement) ×%d" % plus
	if minus > 0: s += " · weaker (hostile attunement) ×%d" % minus
	if cool > 0: s += " · cools Lava ×%d" % cool
	if fan > 0: s += " · fans Lava ×%d" % fan
	return s


func _inspector_text() -> String:
	if hover == NOWHERE:
		return "Square stack\n\nhover a square"
	var sq := battle.board.at(hover)
	var s := "Square [%d, %d]\n\n" % [hover.x, hover.y]
	var occ = battle.board.occupants.get(hover)
	s += "Air: —\n"
	s += "Object: %s\n" % (("%s %d/%d HP" % [sq.object["name"], sq.object["hp"], sq.object["max_hp"]]) if sq.object != null else "—")
	if occ != null:
		s += "Monster: %s\n" % battle.monsters[occ].display_name
	if sq.surge != null:
		var sg: Dictionary = sq.surge
		s += "Surge: %s (%s) fires after %s's next turn; %d dmg here, then repaints\n" % [
				sg["name"], battle.monsters[sg["owner"]].display_name,
				"the opponent", sq.surge_damage(sg["aspect"], sg["value"])]
	else:
		s += "Surge: —\n"
	if sq.zone != null:
		var z: Dictionary = sq.zone
		s += "Zone: %s %s · %d round(s) left\n" % [z["def"].display_name, BattleView.ROMAN[z["level"] - 1], z["duration"]]
		for e in z["def"].effective(z["level"], sq.attunement):
			s += "  • %s %d\n" % [ZoneEffect.Tag.keys()[e["tag"]].to_lower(), e["value"]]
	else:
		s += "Zone: —\n"
	s += "Ground: %s" % Square.GroundType.keys()[sq.ground].capitalize()
	if sq.ground == Square.GroundType.LAVA:
		s += " %s (burns %d)" % [BattleView.ROMAN[sq.lava_level - 1], sq.lava_level]
	if sq.elevated:
		s += " · Elevated (halts Surges, +1 range)"
	if sq.attunement != Aspect.Type.NONE:
		s += "\nAttuned: %s" % Aspect.ATTUNEMENT_NAMES[sq.attunement]
	return s


# ---------- log ----------

func _name(id: StringName) -> String:
	return battle.monsters[id].display_name


func _on_event(e: Dictionary) -> void:
	match e["type"]:
		&"moved":
			hud.log_line("%s moves to [%d,%d]" % [_name(e["who"]), e["to"].x, e["to"].y])
		&"cast":
			var sk := battle.monsters[e["who"]].skill_by_id(e["skill"])
			hud.log_line("%s %s %s (%d squares)" % [_name(e["who"]),
					"declares" if sk.kind == SkillDef.Kind.SURGE else "casts", sk.display_name, e["cells"].size()])
		&"damage":
			hud.log_line("%s takes %d damage (%s)" % [_name(e["target"]), e["amount"], e["source"]])
		&"absorbed":
			hud.log_line("%s is unharmed — the Veil absorbs the Surge." % _name(e["target"]))
		&"prop_hit":
			hud.log_line("A Surge slams a prop (%d HP left)." % e["hp"])
		&"shatter":
			hud.log_line("A prop shatters → Rubble, debris flies!")
		&"collapse":
			hud.log_line("Debris collapses the high ground at [%d,%d]." % [e["pos"].x, e["pos"].y])
		&"slain":
			hud.log_line("%s is slain!" % _name(e["who"]))
		&"displaced":
			hud.log_line("%s is %s to [%d,%d]" % [_name(e["who"]), "pushed" if e["push"] else "pulled", e["to"].x, e["to"].y])
		&"collision":
			hud.log_line("%s is slammed into the %s!" % [_name(e["who"]), e["prop"]])
		&"pinned":
			hud.log_line("%s is pinned against the edge." % _name(e["who"]))
		&"zones_faded":
			hud.log_line("%d zone squares fade and repaint the ground." % e["count"])
		&"voidscar":
			hud.log_line("Voidscar spreads to [%d,%d] — the arena is shrinking" % [e["pos"].x, e["pos"].y])
		&"round_started":
			hud.log_line("Round %d — %s acts first." % [e["round"], _name(e["first"])])
