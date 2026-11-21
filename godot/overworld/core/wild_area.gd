class_name WildArea
extends RefCounted
## The wild area (docs/vision.md §4): a list of today's encounters per zone, one zone per stage. Every night the list
## is drawn anew; an encounter that was won, or whose monster was caught, is gone. Rare encounters are announced
## ahead and stay a few days. Every battle starts at full HP and costs day AP.

## An encounter of the list: the fight, whether it is gone, and for a rare one the days until it appears or leaves.
class Entry:
	var fight: Fight
	var gone := false
	var rare := false
	## Days until a rare encounter appears (0 = it is here).
	var appears_in := 0
	var stays := 0


static func _key(zone: int, index: int) -> int:
	return zone * 100 + index


## The zones the player may enter: one per stage reached.
static func zones(game: GameState) -> Array[int]:
	var out: Array[int] = []
	for z in mini(int(game.stage), Stage.Type.IMMORTAL) + 1:
		out.append(z)
	return out


static func _fight(game: GameState, zone: int, tag: String, with_day: bool, rare := false) -> Fight:
	var rng := game.rng_for(tag, with_day)
	var map := Places.pick_map(game.values, rng, zone)
	var f := Fight.new()
	f.place = Fight.WILD
	f.stage = zone
	f.map_id = map["id"]
	f.max_team = int(map["mine"])
	f.wild = true
	f.roll_seed = rng.randi_range(1, 1 << 30)
	if rare:
		f.enemies = Places.monsters(rng, 1, GameState.step_of(zone, 2), MonsterInstance.Rarity.RARE)
		f.loot_text = "monster XP, a beast part, an egg of this species; it can be caught (Rare)"
	else:
		var n := Places.enemy_count(game.values.wild_enemies, zone, rng, int(map["theirs"]))
		f.enemies = Places.monsters(rng, n, GameState.step_of(zone, rng.randi_range(0, 2)))
		f.loot_text = "monster XP, a beast part per monster defeated; they can be caught"
	return f


## Today's encounters of a zone, the rare one last if one is announced or here.
static func encounters(game: GameState, zone: int) -> Array[Entry]:
	var out: Array[Entry] = []
	for i in game.values.wild_encounters:
		var e := Entry.new()
		e.fight = _fight(game, zone, "wild%d_%d" % [zone, i], true)
		e.fight.title = "Wild encounter %d" % (i + 1)
		e.fight.ref = {"zone": zone, "index": i}
		e.gone = game.wild_gone.has(_key(zone, i))
		out.append(e)
	var rare := rare_entry(game, zone)
	if rare != null:
		out.append(rare)
	return out


## The rare encounter that is announced or here, or null. Rare encounter k appears on day k × rare_every.
static func rare_entry(game: GameState, zone: int) -> Entry:
	var v := game.values
	if v.rare_every <= 0 or zone != int(game.stage):
		return null
	@warning_ignore("integer_division")
	for k in [game.day / v.rare_every, game.day / v.rare_every + 1]:
		if k < 1:
			continue
		var first: int = k * v.rare_every
		if game.day < first - v.rare_announce or game.day >= first + v.rare_stays:
			continue
		var e := Entry.new()
		e.rare = true
		e.appears_in = maxi(0, first - game.day)
		e.stays = first + v.rare_stays - maxi(game.day, first)
		e.fight = _fight(game, zone, "rare%d_%d" % [zone, k], false, true)
		e.fight.title = "Rare encounter"
		e.fight.ref = {"zone": zone, "rare": k}
		e.gone = game.rare_gone.has(k)
		return e
	return null


## Pays for a battle; false when the player cannot afford it.
static func pay(game: GameState) -> bool:
	return game.spend_ap(game.values.wild_ap)


static func resolve(game: GameState, f: Fight, result: BattleResult, won: bool) -> void:
	var caught := Places.caught(f, result)
	if won or not caught.is_empty():
		if f.ref.has("rare"):
			game.rare_gone.append(int(f.ref["rare"]))
		else:
			game.wild_gone.append(_key(int(f.ref["zone"]), int(f.ref["index"])))
	for m in caught:
		m.heal_full()
		if game.add_monster(m):
			game.say("Caught: %s." % m.title())
		else:
			game.say("%s was caught, but %s: it went free." % [m.species().display_name, "your vow forbids its Kin" if game.kin_banned(int(m.species().kin)) else "the roster is full"])
	if won:
		var loot := {}
		for e in result.enemy:
			var i: int = e["index"]
			if bool(e.get("died", false)) and i < f.enemies.size():
				var part := Materials.beast_part(int(f.enemies[i].species().kin))
				loot[part] = int(loot.get(part, 0)) + 1
		for id in loot:
			game.add_item(id, int(loot[id]))
		game.say("%s won. Loot: %s." % [f.title, Materials.list_text(loot, game.values)])
		for line in game.award_xp(f.team, f.stage):
			game.say(line)
		var roll := game.rng_for("egg%d_%s" % [game.day, f.ref]).randi_range(1, 100)
		var egg := (f.ref.has("rare") or roll <= game.values.egg_chance or game.vow_has("wild_egg")) and not game.vow_has("no_wild_eggs")
		if egg and not f.enemies.is_empty() and game.add_egg(f.enemies[0].species_id):
			game.say("You found an egg: %s." % f.enemies[0].species().display_name)
	else:
		game.say("%s lost. The AP are spent." % f.title)
	for m in game.roster:                    # every battle of the wild area starts at full HP
		m.heal_full()
