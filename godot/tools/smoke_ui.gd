extends SceneTree
## Headless UI smoke test: draft → placement → battle, then plays the player's side through
## the real controller input path (hover, highlights, previews, inspector, click), using the
## AI only to choose what to aim at.
## godot --headless -s res://tools/smoke_ui.gd -- [mode] [seed]

var _frames := 0
var _stage := 0
var _rng := RandomNumberGenerator.new()
var _mode := &"3v3"
var _player_actions := 0
var _refused := 0


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	_mode = StringName(args[0]) if args.size() > 0 else &"3v3"
	_rng.seed = int(args[1]) if args.size() > 1 else 7
	change_scene_to_file("res://battle/draft.tscn")


func _process(_delta: float) -> bool:
	_frames += 1
	if _frames > 60000:
		print("[smoke] timeout, player actions: ", _player_actions)
		return true
	var scene := current_scene
	if scene == null:
		return false
	if _stage == 0 and scene.name == "Draft" and _frames > 5:
		var size := BattleSetup.team_size(_mode)
		var pick := BattleSetup.random_enemy([] as Array[StringName], size, _rng)
		for id in pick:
			scene._toggle(id, true)
		for tid: StringName in [&"second_wind", &"spirit_shield", &"domain_glimpse"]:
			scene._toggle_tamer(tid, true)
		print("[smoke] draft pick: ", pick)
		scene._start(_mode)
		_stage = 1
		return false
	if _stage == 1 and scene.has_method("_my_turn"):
		var c = scene
		if c.placing:
			_place(c)
			return false
		if c.battle.over:
			print("[smoke] battle over, winner side %d (draw %s) after %d rounds, player actions %d, refused clicks %d" % [
				c.battle.winner_side, c.battle.draw, c.battle.round_number, _player_actions, _refused])
			return true
		if c._my_turn():
			_play_one(c)
	return false


## Moves one monster inside the start area through the placement clicks, then starts.
func _place(c) -> void:
	var b: Battle = c.battle
	var mine := b.living(0)
	var free: Vector2i = c.NOWHERE
	for p: Vector2i in c._start_squares():
		if b.any_unit_at(p) == null:
			free = p
			break
	if free != c.NOWHERE and not mine.is_empty():
		c.hover = mine[0].pos
		c._click()
		c.hover = free
		c._refresh()
		c._click()
		print("[smoke] placed %s at %s" % [mine[0].display_name(), free])
	c._on_action(c.ACT_START)


func _play_one(c) -> void:
	var b: Battle = c.battle
	var u: BattleUnit = b.active()
	# exercise every mode's highlight / preview / inspector code on every square
	var acts: Array = [c.ACT_STEP]
	for i in u.sheet.skills.size():
		if u.sheet.skills[i].is_active() and u.sheet.skills[i].kind != BattleSkillDef.BUFF:
			acts.append(StringName(c.SLOT_PREFIX + str(i)))
	for def: TamerSkillDef in b.tamer_loadout[0]:
		acts.append(StringName(c.TAMER_PREFIX + String(def.id)))
	for act: StringName in acts:
		c._clear_mode()
		c._on_action(act)
		for cell in b.board.cells:
			c.hover = cell.pos
			c._refresh()
		c._rotate()
		c._set_dir(Vector2i(1, 0))
		c.hud._hover_id = act
		c.hud._show_card()
	c.hud._hover_id = &""
	c.hud._show_card()
	c._clear_mode()
	# one tamer skill through the real click path, early in the battle
	if b.round_number == 2 and not b.tamer_used[0].has(&"second_wind") and b.tamer_skill(0, &"second_wind") != null:
		c._on_action(StringName(c.TAMER_PREFIX + "second_wind"))
		c.hover = u.pos
		c._refresh()
		c._click()
		_player_actions += 1
		return
	var a := AiBrain.decide(b, _rng)
	var before := b.actions.size()
	match a["type"]:
		&"step":
			c._on_action(c.ACT_STEP)
			c.hover = a["to"]
		&"skill":
			var s: BattleSkillDef = u.sheet.skills[a["slot"]]
			c._on_action(StringName(c.SLOT_PREFIX + str(a["slot"])))
			match s.kind:
				BattleSkillDef.MOVE:
					c.hover = a["to"]
				BattleSkillDef.STRIKE:
					c.hover = a["origin"] + a["dir"]
					c.aim_dir = a["push_dir"] if a["push_dir"] != Vector2i.ZERO else c.aim_dir
				BattleSkillDef.BUFF:
					_player_actions += 1
					return                      # applied by the button itself
				_:
					c.hover = a["anchor"]
					c.rot = a["rot"]
					c.aim_dir = a["dir"] if a["dir"] != Vector2i.ZERO else c.aim_dir
		_:
			c._on_end_turn()
			return
	c._refresh()
	c._click()
	_player_actions += 1
	if b.actions.size() == before and not b.over and b.turn_owner == u.id:
		_refused += 1
		print("[smoke] click did nothing for ", a, " -> ending turn")
		c._on_end_turn()
