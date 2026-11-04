class_name BattleSetup
extends RefCounted
## Boards, start areas and teams (GDD §1, §13). Point-symmetric boards so both sides are equal.
## A BattleRequest (see battle_request.gd) describes the fight; `build()` makes the Battle.


static func load_def(id: StringName) -> MonsterDef:
	return GameData.monster(id)


static func team_size(m: StringName) -> int:
	return 1 if m == &"1v1" else 3


## Random enemy team from the monsters the player didn't pick.
static func random_enemy(pick: Array[StringName], size: int, rng: RandomNumberGenerator) -> Array[StringName]:
	var pool: Array[StringName] = []
	for id in GameData.monster_ids():
		if not pick.has(id):
			pool.append(id)
	var out: Array[StringName] = []
	while out.size() < size and not pool.is_empty():
		out.append(pool.pop_at(rng.randi_range(0, pool.size() - 1)))
	return out


## Reference individuals (the species' own numbers) for a list of species ids.
static func references(ids: Array[StringName]) -> Array[MonsterInstance]:
	var out: Array[MonsterInstance] = []
	for id in ids:
		out.append(MonsterInstance.reference(load_def(id)))
	return out


static func create(p_mode: StringName, player: Array[StringName], enemy: Array[StringName]) -> Battle:
	return create_from_units(p_mode, references(player), references(enemy))


## The one entry point for the battle scene: teams are cut to the mode's size.
static func build(request: BattleRequest) -> Battle:
	var size := request.team_size()
	var p: Array[MonsterInstance] = request.player_team.slice(0, size)
	var e: Array[MonsterInstance] = request.enemy_team.slice(0, size)
	return create_from_units(request.mode, p, e)


## Builds a battle from individuals: each becomes a finished unit sheet at its current HP.
static func create_from_units(p_mode: StringName, player: Array[MonsterInstance], enemy: Array[MonsterInstance]) -> Battle:
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
		var pm := Monster.new(StringName("p%d_%s" % [i, player[i].species_id]), player[i].to_battle_unit(), 0, starts_player[i], player[i].current_hp)
		pm.team_index = i
		monsters.append(pm)
	for i in mini(enemy.size(), starts_player.size()):
		var s := starts_player[i]
		var mirrored := Vector2i(board.size - 1 - s.x, board.size - 1 - s.y)
		var em := Monster.new(StringName("e%d_%s" % [i, enemy[i].species_id]), enemy[i].to_battle_unit(), 1, mirrored, enemy[i].current_hp)
		em.team_index = i
		monsters.append(em)
	return Battle.new(board, monsters, voidscar_from)


## Places each prop and (if `mirror`) its point-symmetric twin.
static func _mirror_props(board: Board, props: Dictionary, mirror: bool) -> void:
	for p: Vector2i in props:
		board.at(p).object = Square.make_prop(props[p])
		if mirror:
			var q := Vector2i(board.size - 1 - p.x, board.size - 1 - p.y)
			board.at(q).object = Square.make_prop(props[p])

