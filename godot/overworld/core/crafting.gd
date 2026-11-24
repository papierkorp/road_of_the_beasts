class_name Crafting
extends RefCounted
## What the Ways bring to a battle and to the monsters (docs/overworld.md §6): the pills of the Alchemist and the
## parts the Artificer lays. Nothing is made: pills and parts drop from the battles of the wild (Wild).

## The property whose pill turns a square into Seal Ground: the Alchemist's way to catch.
const BINDING := &"binding"


static func property(values: GameValues, id: StringName) -> Dictionary:
	for p: Dictionary in values.properties:
		if StringName(p["id"]) == id:
			return p
	return {}


## What the Alchemist starts with: Binding pills.
static func start_alchemist(game: GameState) -> void:
	if game.values.alchemist_start_pills > 0:
		game.add_item(Materials.pill(BINDING), game.values.alchemist_start_pills)


# ---------- pills for a monster ----------

## Tempering pills a monster takes at most.
static func pill_cap(game: GameState) -> int:
	return game.values.pill_points_cap + game.node_sum("pill_cap")


## Why a pill cannot be given to a monster ("" = it can). Pills that act in a battle go into a tamer slot; the
## relearning pill needs a slot and a skill: `relearn`.
static func use_problem(game: GameState, pill: String, m: MonsterInstance) -> String:
	if game.count(pill) < 1:
		return "none left"
	if not game.is_alchemist():
		return "your Way has no pills"
	if not m.uses_points():
		return "no use here"
	var can := false
	match String(Materials.property_of(pill)):
		"change":
			can = true
		"growth":
			can = m.sub_tier != Stage.SubTier.HIGH and m.can_step(game.stage)
		"tempering":
			can = m.bonus_points < pill_cap(game)
		"honing":
			can = true
	return "" if can else "no use here"


## Gives a pill to a monster outside a battle.
static func use(game: GameState, pill: String, m: MonsterInstance) -> bool:
	if use_problem(game, pill, m) != "":
		return false
	game.take_item(pill)
	match String(Materials.property_of(pill)):
		"change":
			m.refund_points()
		"growth":
			game.lift(m)
		"tempering":
			var n := mini(game.values.pill_points, pill_cap(game) - m.bonus_points)
			m.bonus_points += n
			m.unspent += n
		"honing":
			m.dev_steps += 1
	game.say("%s took %s." % [m.species().display_name, Materials.display_name(pill, game.values)])
	return true


## A pill of Clarity the player owns ("" = none).
static func clarity_pill(game: GameState) -> String:
	var pill := Materials.pill(&"clarity")
	return pill if game.is_alchemist() and game.count(pill) > 0 else ""


## The relearning pill (docs/skills.md §8): a slot of a monster takes another skill it can learn; the slot keeps
## its level and its options are chosen anew.
static func relearn(game: GameState, m: MonsterInstance, slot: int, skill_id: StringName) -> bool:
	var pill := clarity_pill(game)
	if pill == "" or not m.relearn(slot, skill_id):
		return false
	game.take_item(pill)
	game.say("%s took %s: slot %d now holds another skill." % [m.species().display_name, Materials.display_name(pill, game.values), slot + 1])
	return true


# ---------- parts ----------

## Whether a vow keeps a part from being laid: no zone, no prop.
static func part_banned(game: GameState, part: String) -> bool:
	var kind := part.get_slice(":", 0)
	return (kind == "zone" and game.vow_has("no_zones")) or (kind == "prop" and game.vow_has("no_props")) \
		or (part == Fight.SEAL_PART and not game.can_catch())


## Why a part cannot be laid on a square of a fight before the battle ("" = it can). A part may lie on any square
## of the board (docs/overworld.md §5.3); the limits are what the Artificer carries and owns.
static func lay_problem(game: GameState, f: Fight, key: String, part: String) -> String:
	if not game.is_artificer() or f.carry <= 0:
		return "nothing to lay here"
	if part_banned(game, part):
		return "your vow forbids it"
	if part == Fight.SEAL_PART and not f.allows_seal():
		return "nothing is caught in the void"
	var others := f.parts.size() - f.laid(Fight.SEAL_PART) - (1 if f.parts.has(key) and String(f.parts[key]) != Fight.SEAL_PART else 0)
	if part != Fight.SEAL_PART and others >= f.carry:                # Seal Ground is laid beside the parts carried
		return "you carry %d part(s) into a battle" % f.carry
	var laid := f.laid(part) - (1 if String(f.parts.get(key, "")) == part else 0)
	if part == Fight.SEAL_PART:
		return "one Seal Ground at a time" if laid >= 1 else ""
	if laid >= int(game.parts.get(part, 0)):
		return "you own no more of it"
	return ""


## Lays a part on a square of a fight, or takes it up again (`part` ""). The part is not used up.
static func lay(game: GameState, f: Fight, key: String, part: String) -> bool:
	if part == "":
		f.parts.erase(key)
		return true
	if lay_problem(game, f, key, part) != "":
		return false
	f.parts[key] = part
	return true


# ---------- what goes into a battle ----------

## The tamer skill a pill brings into a battle (&"" = none): the Alchemist's pills alone.
static func battle_skill_of(game: GameState, item: String) -> StringName:
	if Materials.form(item) != "pill" or not game.is_alchemist():
		return &""
	var p := Materials.property_of(item)
	if p == BINDING and not game.can_catch():
		return &""
	return StringName(property(game.values, p).get("skill", ""))


## The pills the player can put into tamer slots: tamer skill id -> item.
static func battle_items(game: GameState) -> Dictionary:
	var out := {}
	var ids: Array = game.items.keys()
	ids.sort()
	for item: String in ids:
		var skill := battle_skill_of(game, item)
		if skill != &"":
			out[skill] = item
	return out


## After a battle: every pill that was taken is used up.
static func spend_used(game: GameState, f: Fight, result: BattleResult) -> void:
	var used: Array = result.used_tamer if result != null else []
	for id in f.tamer_items:
		var item := String(f.tamer_items[id])
		if Materials.form(item) == "pill" and used.has(id) and game.take_item(item):
			game.say("%s was used up." % Materials.display_name(item, game.values))
