class_name BattleSetup
extends RefCounted
## Boards, start areas and teams (GDD §1, §13). Point-symmetric boards so both sides are equal.
## The draft screen writes the player's pick into the static vars; the battle scene reads them.

const ROSTER: Array[StringName] = [
	&"blaze_tiger", &"ember_hawk", &"forge_golem",
	&"moss_turtle", &"thorn_mites", &"grove_wisp",
	&"gloom_wolf", &"dusk_moth", &"hollow_serpent",
]

static var player_pick: Array[StringName] = []
static var enemy_pick: Array[StringName] = []
static var mode: StringName = &"3v3"
## Let the AI play both sides (headless smoke tests: --autoplay).
static var autoplay := false


static func load_def(id: StringName) -> MonsterDef:
	return load("res://data/monsters/%s.tres" % id)


static func team_size(m: StringName) -> int:
	return 1 if m == &"1v1" else 3


## Random enemy team from the monsters the player didn't pick.
static func random_enemy(pick: Array[StringName], size: int, rng: RandomNumberGenerator) -> Array[StringName]:
	var pool: Array[StringName] = []
	for id in ROSTER:
		if not pick.has(id):
			pool.append(id)
	var out: Array[StringName] = []
	while out.size() < size and not pool.is_empty():
		out.append(pool.pop_at(rng.randi_range(0, pool.size() - 1)))
	return out


static func create(p_mode: StringName, player: Array[StringName], enemy: Array[StringName]) -> Battle:
	var board: Board
	var starts_player: Array[Vector2i] = []
	var voidscar_from := 6
	if p_mode == &"1v1":
		board = Board.new(5)
		starts_player = [Vector2i(0, 4)]
		_mirror_props(board, {Vector2i(1, 3): "Rock", Vector2i(3, 1): "Tree"}, false)
		board.at(Vector2i(1, 1)).elevated = true
		board.at(Vector2i(3, 3)).elevated = true
	else:
		board = Board.new(7)
		starts_player = [Vector2i(1, 5), Vector2i(3, 6), Vector2i(5, 5)]
		voidscar_from = 8
		_mirror_props(board, {Vector2i(2, 2): "Rock", Vector2i(4, 2): "Tree", Vector2i(0, 3): "Wall"}, true)
		for p in [Vector2i(3, 3), Vector2i(1, 3), Vector2i(5, 3)]:
			board.at(p).elevated = true
	var monsters: Array[Monster] = []
	for i in mini(player.size(), starts_player.size()):
		monsters.append(Monster.new(StringName("p%d_%s" % [i, player[i]]), load_def(player[i]), 0, starts_player[i]))
	for i in mini(enemy.size(), starts_player.size()):
		var s := starts_player[i]
		var mirrored := Vector2i(board.size - 1 - s.x, board.size - 1 - s.y)
		monsters.append(Monster.new(StringName("e%d_%s" % [i, enemy[i]]), load_def(enemy[i]), 1, mirrored))
	return Battle.new(board, monsters, voidscar_from)


## Places each prop and (if `mirror`) its point-symmetric twin.
static func _mirror_props(board: Board, props: Dictionary, mirror: bool) -> void:
	for p: Vector2i in props:
		board.at(p).object = Square.make_prop(props[p])
		if mirror:
			var q := Vector2i(board.size - 1 - p.x, board.size - 1 - p.y)
			board.at(q).object = Square.make_prop(props[p])


## Default teams when the battle scene is started directly (no draft).
static func default_battle() -> Battle:
	var p: Array[StringName] = [&"blaze_tiger", &"moss_turtle", &"gloom_wolf"]
	var e: Array[StringName] = [&"hollow_serpent", &"grove_wisp", &"ember_hawk"]
	if not player_pick.is_empty():
		p = player_pick.duplicate()
	if not enemy_pick.is_empty():
		e = enemy_pick.duplicate()
	var size := team_size(mode)
	p = p.slice(0, size)
	e = e.slice(0, size)
	return create(mode, p, e)
