class_name FightBridge
extends RefCounted
## Turns a fight of the hub game (plain data of the overworld) into the request of the battle. `game/` is the only
## part that knows both halves (docs/architecture.md §1).


static func _point(key: String) -> Vector2i:
	var xy := key.split(",")
	return Vector2i(int(xy[0]), int(xy[1]))


## The battleground a fight is fought on: the board of the fight with the parts the Artificer laid on it. A part
## replaces what lay there; a push zone laid as a part points at the opponent. Seal Ground is shown as ground here
## and laid by the battle itself (`seals_of`).
static func map_of(f: Fight) -> MapDef:
	var m := MapData.from_dict(f.own_map)
	for key: String in f.parts:
		var p := _point(key)
		if not m.has_square(p):
			continue
		var part := String(f.parts[key])
		var id := StringName(part.get_slice(":", 1))
		match part.get_slice(":", 0):
			"ground":
				m.grounds[p] = id
			"prop":
				m.props[p] = id
			"zone":
				m.zones[p] = {"zone": id, "dir": Vector2i(0, -1), "rounds": 0}
			Fight.SEAL_PART:
				m.grounds[p] = &"seal"
	return m


## The squares on which the player's Seal Ground lies from the start.
static func seals_of(f: Fight) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for key: String in f.parts:
		if String(f.parts[key]) == Fight.SEAL_PART:
			out.append(_point(key))
	return out


## An ingame battle on a battleground with the monsters as they are (their stats, their current HP).
static func request_of(f: Fight) -> BattleRequest:
	var r := BattleRequest.new()
	r.battle_kind = BattleRequest.INGAME
	r.map = map_of(f)
	r.player_seals = seals_of(f)
	for p in r.player_seals:                      # the battle lays the seal itself: the map holds plain ground there
		r.map.grounds.erase(p)
	r.player_team = f.team
	r.enemy_team = f.enemies
	r.player_tamer = f.tamer.duplicate()
	r.enemy_wild = f.wild
	r.roll_seed = f.roll_seed
	return r
