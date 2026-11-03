class_name BattleSetup
extends RefCounted
## Start positions and kits of the playable prototype (GDD §17):
## you (Blaze Tiger) vs. an AI Gloom Wolf on a 5x5 board.


static func _skills(ids: Array) -> Array[SkillDef]:
	var out: Array[SkillDef] = []
	for id in ids:
		out.append(load("res://data/skills/%s.tres" % id))
	return out


static func prototype() -> Battle:
	var tiger := Monster.new(&"tiger", "Blaze Tiger", Aspect.Type.FORCE, Vector2i(4, 0), 6, 7.0, 2,
		_skills(["magma_surge", "lava_field", "bog", "gale", "bark_veil", "raise_wall", "raise_ground"]))
	var wolf := Monster.new(&"wolf", "Gloom Wolf", Aspect.Type.DARK, Vector2i(0, 4), 5, 5.0, 2,
		_skills(["gloom_surge", "mire", "shade_veil"]))
	var board := Board.new(5)
	board.at(Vector2i(1, 3)).object = {"name": "Rock", "hp": 3, "max_hp": 3}
	board.at(Vector2i(3, 1)).object = {"name": "Tree", "hp": 2, "max_hp": 2}
	board.at(Vector2i(1, 1)).elevated = true
	board.at(Vector2i(3, 3)).elevated = true
	var monsters: Array[Monster] = [tiger, wolf]
	return Battle.new(board, monsters)
