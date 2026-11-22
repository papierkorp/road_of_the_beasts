class_name FightBridge
extends RefCounted
## Turns a fight of the hub game (plain data of the overworld) into the request of the battle. `game/` is the only
## part that knows both halves (docs/architecture.md §1).


## The battleground a fight is fought on.
static func map_of(f: Fight) -> MapDef:
	return MapData.from_dict(f.own_map) if f.map_id == &"" else MapDef.load_map(f.map_id)


## An ingame battle on a battleground with the monsters as they are (their stats, their current HP).
static func request_of(f: Fight) -> BattleRequest:
	Forged.ensure(GameValues.shared())          # a forged weapon in the loadout is a tamer skill the battle must know
	var r := BattleRequest.new()
	r.battle_kind = BattleRequest.INGAME
	r.map = map_of(f)
	r.player_team = f.team
	r.enemy_team = f.enemies
	r.player_tamer = f.tamer.duplicate()
	r.player_tamer_uses = f.tamer_uses.duplicate()
	r.player_tamer_bitter = Crafting.bitter_entries(f)
	r.enemy_wild = f.wild
	r.roll_seed = f.roll_seed
	return r
