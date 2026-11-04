extends SceneTree
## Headless UI smoke test: draft → battle, then plays the player's side through the real
## controller input path (hover, previews, inspector, click) using the AI to pick actions.
## godot --headless -s res://tools/smoke_ui.gd -- [mode] [seed]

var _frames := 0
var _stage := 0
var _rng := RandomNumberGenerator.new()
var _mode := &"3v3"
var _player_actions := 0


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	_mode = StringName(args[0]) if args.size() > 0 else &"3v3"
	_rng.seed = int(args[1]) if args.size() > 1 else 7
	change_scene_to_file("res://draft.tscn")


func _process(_delta: float) -> bool:
	_frames += 1
	if _frames > 40000:
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
		print("[smoke] draft pick: ", pick)
		scene._start(_mode)
		_stage = 1
		return false
	if _stage == 1 and scene.has_method("_my_turn"):
		var c = scene
		if c.battle.over:
			print("[smoke] battle over, winner side %d after %d rounds, player actions %d" % [
				c.battle.winner_side, c.battle.round_number, _player_actions])
			return true
		if c._my_turn():
			_play_one(c)
	return false


func _play_one(c) -> void:
	var b: Battle = c.battle
	var m: Monster = b.active()
	# exercise every mode's highlight / preview / inspector code on every square
	for act in [c.ACT_MOVE, c.ACT_STRIKE] + m.skills().map(func(s): return s.id):
		c._clear_mode()
		c._on_action(act)
		for sq: Square in b.board.all_squares():
			c.hover = sq.pos
			c._refresh()
		c._rotate()
		c._set_dir(Vector2i(1, 0))
	c._clear_mode()
	var a := AiBrain.decide(b, m.id, _rng)
	match a["type"]:
		&"move":
			c._on_action(c.ACT_MOVE)
			c.hover = a["to"]
		&"strike":
			c._on_action(c.ACT_STRIKE)
			c.hover = a["target"]
			c.aim_dir = a["dir"]
		&"cast":
			c._on_action(a["skill"].id)
			c.orient = a["oi"]
			c.hover = a["anchor"]
			c.aim_dir = a["dir"]
		_:
			c._on_end_turn()
			return
	var before := b.ap
	c._click()
	_player_actions += 1
	if b.ap == before and not b.over and b.turn_owner == m.id:
		print("[smoke] click did nothing for ", a["type"], " -> ending turn")
		c._on_end_turn()
