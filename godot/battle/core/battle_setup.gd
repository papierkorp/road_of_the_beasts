class_name BattleSetup
extends RefCounted
## Builds a Battle from a BattleRequest and reads a BattleResult out of it: the only place
## where the battle touches the shared request / result contract (gdd_overworld §8).


static func load_def(id: StringName) -> MonsterDef:
	return GameData.monster(id)


static func team_size(m: StringName) -> int:
	return BattleRequest.team_size_of(m)


## Random enemy team from the species the player did not pick (draft screen, tools).
static func random_enemy(pick: Array[StringName], size: int, rng: RandomNumberGenerator) -> Array[StringName]:
	var pool: Array[StringName] = []
	for id in GameData.monster_ids():
		if not pick.has(id):
			pool.append(id)
	var out: Array[StringName] = []
	while out.size() < size and not pool.is_empty():
		out.append(pool.pop_at(rng.randi_range(0, pool.size() - 1)))
	return out


## Reference individuals for a list of species ids.
static func references(ids: Array[StringName]) -> Array[MonsterInstance]:
	var out: Array[MonsterInstance] = []
	for id in ids:
		out.append(MonsterInstance.of_species(load_def(id)))
	return out


static func create(p_mode: StringName, player: Array[StringName], enemy: Array[StringName]) -> Battle:
	return create_from_units(p_mode, references(player), references(enemy))


static func create_from_units(p_mode: StringName, player: Array[MonsterInstance], enemy: Array[MonsterInstance]) -> Battle:
	var r := BattleRequest.new()
	r.mode = p_mode
	r.player_team = player
	r.enemy_team = enemy
	return build(r)


## The one entry point for the battle scene: teams are cut to the mode's size.
static func build(request: BattleRequest) -> Battle:
	var content := BattleContent.shared()
	var b := Battle.new(null, content)
	var starts := BattleBoards.build(b, request.mode, request.board_seed)
	var size := mini(request.team_size(), starts.size())
	for side in 2:
		var team: Array[MonsterInstance] = request.player_team if side == 0 else request.enemy_team
		var prefix := "p" if side == 0 else "e"
		for i in mini(team.size(), size):
			var sheet := UnitSheets.from_instance(team[i], content)
			if side == 0 and request.prep_init.has(i):
				sheet.init_bonus = float(request.prep_init[i])      # battle-prep pill (gdd_overworld §6.6)
			var pos := starts[i]
			if side == 0 and i < request.player_starts.size() and _legal_start(b, request, request.player_starts, i):
				pos = request.player_starts[i]
			if side == 1:
				pos = b.board.mirrored(pos) - Vector2i(sheet.size - 1, sheet.size - 1)
			var u := BattleUnit.new(StringName("%s%d_%s" % [prefix, i, team[i].species_id]), sheet, side, i, pos)
			u.team_index = i
			b.add_unit(u)
		var bench: Array[MonsterInstance] = request.player_bench if side == 0 else request.enemy_bench
		for i in bench.size():
			var sheet := UnitSheets.from_instance(bench[i], content)
			var u := BattleUnit.new(StringName("%sb%d_%s" % [prefix, i, bench[i].species_id]), sheet, side, size + i, Vector2i.ZERO)
			b.add_unit(u, false)
		var loadout: Array[StringName] = request.player_tamer if side == 0 else request.enemy_tamer
		for id in loadout:
			var def := content.tamer_skill(id)
			if def != null and not b.tamer_loadout[side].has(def):
				b.tamer_loadout[side].append(def)
	return b


## A chosen start square must lie in the start area, be free and not repeat an earlier choice.
static func _legal_start(b: Battle, request: BattleRequest, chosen: Array[Vector2i], i: int) -> bool:
	var p := chosen[i]
	if not BattleBoards.in_start_area(request.mode, p):
		return false
	var cell := b.board.at(p)
	if cell == null or cell.prop != null:
		return false
	for k in i:
		if chosen[k] == p:
			return false
	return true


## Reads a (finished) battle into the facts the overworld needs: winner or Draw, HP left per
## monster, who fell, and the tamer skills that were used. Facts, not rewards.
static func make_result(b: Battle) -> BattleResult:
	var r := BattleResult.new()
	r.over = b.over
	r.winner_side = b.winner_side
	r.draw = b.draw
	r.rounds = b.round_number
	for id in b.roster:
		var u: BattleUnit = b.units[id]
		var entry := {"species": u.sheet.species_id, "index": u.team_index, "hp_left": maxi(u.hp, 0),
			"max_hp": u.max_hp, "alive": not u.defeated, "fielded": u.on_field or u.defeated}
		if u.side == 0:
			r.player.append(entry)
		else:
			r.enemy.append(entry)
	var by_index := func(a: Dictionary, c: Dictionary) -> bool: return a["index"] < c["index"]
	r.player.sort_custom(by_index)
	r.enemy.sort_custom(by_index)
	for id in b.tamer_used[0]:
		r.used_tamer.append(id)
	return r
