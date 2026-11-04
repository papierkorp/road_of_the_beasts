class_name GameState
extends RefCounted
## The save-game state of the overworld (gdd_overworld §3, §7): day, action points, money,
## the player's cultivation and the individuals they own. Headless, no nodes.
## Imports only shared/ — it never touches the battle.
##
## Phase 1 placeholders (marked, to be replaced by the real systems): the night heals everybody
## fully and the player's own stage never changes (monsters rise through sub-tiers with XP).

const START_AP := 3
const STARTER := &"blaze_tiger"

var day := 1
var max_ap := START_AP
var ap := START_AP
var money := 0                      # spirit stones, lowest denomination (gdd_overworld §9.1)
var stage: Stage.Type = Stage.Type.QI_GATHERING
var sub_tier: Stage.SubTier = Stage.SubTier.LOWER
var monsters: Array[MonsterInstance] = []
var items := {}                     # item id -> count (ItemCatalog)
var market: Market
var structures: Array[Dictionary] = []   # placed in the Inner World: see BuildGrid
var _next_uid := 1


static func new_game(rng: RandomNumberGenerator, starter: StringName = STARTER) -> GameState:
	var g := GameState.new()
	g.monsters.append(MonsterInstance.roll(GameData.monster(starter), rng, StatShape.Id.NONE, g.stage, g.sub_tier))
	g.market = Market.create(int(g.stage), rng)
	# the first recipes: a place to meditate and a place to grow herbs
	g.add_item(ItemCatalog.blueprint_id(&"meditation_stone"))
	g.add_item(ItemCatalog.blueprint_id(&"herb_plot"))
	return g


## How many monsters the spatial space holds (gdd_overworld §4.5).
func capacity() -> int:
	match stage:
		Stage.Type.QI_GATHERING:
			return 1
		Stage.Type.FOUNDATION:
			return 3
	return 5


## The battle mode the player can field: 1v1 at Qi Gathering, 3v3 from Foundation.
func battle_mode() -> StringName:
	return &"1v1" if stage == Stage.Type.QI_GATHERING else &"3v3"


## The individuals that go into a battle of `mode` (the same objects, so HP changes stick).
func team_for(mode: StringName) -> Array[MonsterInstance]:
	var out: Array[MonsterInstance] = []
	for m in monsters:
		if out.size() >= BattleRequest.team_size_of(mode):
			break
		out.append(m)
	return out


func can_spend_ap(n: int) -> bool:
	return ap >= n


func spend_ap(n: int) -> bool:
	if ap < n:
		return false
	ap -= n
	return true


func add_money(n: int) -> void:
	money += n


func spend_money(n: int) -> bool:
	if money < n:
		return false
	money -= n
	return true


func add_item(id: String, n := 1) -> void:
	items[id] = item_count(id) + n


func remove_item(id: String, n := 1) -> bool:
	if item_count(id) < n:
		return false
	items[id] = item_count(id) - n
	if items[id] <= 0:
		items.erase(id)
	return true


func item_count(id: String) -> int:
	return int(items.get(id, 0))


## Ids of everything in the bag, sorted.
func bag_ids() -> Array[String]:
	var out: Array[String] = []
	for id in items:
		out.append(String(id))
	out.sort()
	return out


## Feeds a cultivation pill to a monster: XP, maybe a sub-tier up. Returns the sub-tier ups,
## or -1 when it didn't work (no such pill, not a pill, or the XP bar is already full).
func use_pill(id: String, m: MonsterInstance) -> int:
	if ItemCatalog.kind_of(id) != ItemCatalog.Kind.PILL or not m.can_gain_xp() or item_count(id) < 1:
		return -1
	remove_item(id)
	return m.add_xp(ItemCatalog.pill_xp(id))


## Night phase: every resolver runs once (gdd_overworld §7). Returns a report for the results screen.
# ---------- structures (gdd_overworld §6.4) ----------

func has_blueprint(sid: StringName) -> bool:
	return item_count(ItemCatalog.blueprint_id(sid)) > 0


## Whether the structure is known, built, or waiting in the bag (blueprints are not consumed).
func owns_structure(sid: StringName) -> bool:
	if has_blueprint(sid) or item_count(ItemCatalog.structure_item_id(sid)) > 0:
		return true
	for s in structures:
		if StringName(s["id"]) == sid:
			return true
	return false


## Materials a recipe would use, or an empty dictionary when they are not all there.
## Specific aspects are paid first, "any" with the cheapest materials left; only materials of
## tiers up to the player's stage count.
func recipe_payment(def: StructureDef) -> Dictionary:
	return materials_payment(def.recipe)


## The same for any list of requirements [{aspect, count}].
func materials_payment(requirements: Array) -> Dictionary:
	var counts := {}
	for id in bag_ids():
		if ItemCatalog.kind_of(id) == ItemCatalog.Kind.MATERIAL and ItemCatalog.tier_of(id) <= int(stage):
			counts[id] = item_count(id)
	var paid := {}
	var reqs := requirements.duplicate()
	reqs.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a["aspect"] != Aspect.Type.NONE) > int(b["aspect"] != Aspect.Type.NONE))
	for r in reqs:
		var need: int = r["count"]
		var ids := counts.keys()
		ids.sort_custom(func(a: String, b: String) -> bool: return ItemCatalog.base_value(a) < ItemCatalog.base_value(b))
		for id in ids:
			if need <= 0:
				break
			if r["aspect"] != Aspect.Type.NONE and ItemCatalog.material_aspect(id) != r["aspect"]:
				continue
			var take := mini(need, int(counts[id]))
			counts[id] = int(counts[id]) - take
			paid[id] = int(paid.get(id, 0)) + take
			need -= take
		if need > 0:
			return {}
	return paid


func can_construct(sid: StringName) -> bool:
	return StructureCatalog.has(sid) and has_blueprint(sid) and ap >= 1 \
		and not recipe_payment(StructureCatalog.def(sid)).is_empty()


## Blueprint + materials + 1 AP (gdd_overworld §7 "Build"): the finished structure goes to the bag.
func construct(sid: StringName) -> bool:
	if not can_construct(sid):
		return false
	var paid := recipe_payment(StructureCatalog.def(sid))
	for id in paid:
		remove_item(id, int(paid[id]))
	spend_ap(1)
	add_item(ItemCatalog.structure_item_id(sid))
	return true


func structure(uid: int) -> Dictionary:
	for s in structures:
		if int(s["uid"]) == uid:
			return s
	return {}


## Places a structure from the bag. Free (decisions are free); returns the uid or -1.
func place_structure(sid: StringName, cell: Vector2i, rot: bool) -> int:
	var def := StructureCatalog.def(sid)
	if def == null or item_count(ItemCatalog.structure_item_id(sid)) < 1 or not BuildGrid.can_place(self, def, cell, rot):
		return -1
	remove_item(ItemCatalog.structure_item_id(sid))
	var uid := _next_uid
	_next_uid += 1
	structures.append({"uid": uid, "id": String(sid), "x": cell.x, "y": cell.y, "rot": rot,
		"assigned": -1, "plant": "", "grown": 0})
	return uid


## Takes a structure back into the bag (never lost). A growing plot can't be picked up.
func pick_up_structure(uid: int) -> bool:
	var s := structure(uid)
	if s.is_empty() or String(s["plant"]) != "":
		return false
	structures.erase(s)
	add_item(ItemCatalog.structure_item_id(StringName(s["id"])))
	return true


## Moves a structure to another cell (free); false if it doesn't fit.
func move_structure(uid: int, cell: Vector2i, rot: bool) -> bool:
	var s := structure(uid)
	if s.is_empty() or not BuildGrid.can_place(self, StructureCatalog.def(StringName(s["id"])), cell, rot, uid):
		return false
	s["x"] = cell.x
	s["y"] = cell.y
	s["rot"] = rot
	return true


## Sends a monster to meditate at a cultivation spot (a monster sits at one spot only).
func assign_monster(uid: int, monster_index: int) -> bool:
	var s := structure(uid)
	if s.is_empty() or StructureCatalog.def(StringName(s["id"])).category != StructureDef.Category.CULTIVATION:
		return false
	if monster_index >= monsters.size():
		return false
	for other in structures:
		if int(other["assigned"]) == monster_index:
			other["assigned"] = -1
	s["assigned"] = monster_index
	return true


func plant(uid: int, material: String) -> bool:
	var s := structure(uid)
	if s.is_empty() or StructureCatalog.def(StringName(s["id"])).category != StructureDef.Category.GROWING:
		return false
	if String(s["plant"]) != "" or ItemCatalog.kind_of(material) != ItemCatalog.Kind.MATERIAL or not remove_item(material):
		return false
	s["plant"] = material
	s["grown"] = 0
	return true


## Harvests a ready plot: the planted material, three times. Returns the item id or "".
func harvest(uid: int) -> String:
	var s := structure(uid)
	if s.is_empty() or not StructureRules.is_ready(self, s):
		return ""
	var id := String(s["plant"])
	add_item(id, StructureRules.HARVEST_YIELD)
	s["plant"] = ""
	s["grown"] = 0
	return id


# ---------- evolution and breakthrough (gdd_overworld §4.1, §4.7) ----------

const EVOLUTION_PILLAR := &"evolution_pillar"
const RESPEC_MATERIALS := 4
const BREAKTHROUGH_MATERIALS := 5
const MONSTER_BREAKTHROUGH_MATERIALS := 3


func has_pillar() -> bool:
	for s in structures:
		if StringName(s["id"]) == EVOLUTION_PILLAR:
			return true
	return false


## A skill evolution costs 1 AP (§7 "Train") and is done at the Evolution Pillar.
func can_evolve() -> bool:
	return has_pillar() and ap >= 1


func evolve(monster_index: int, slot: int, skill: StringName, family: StringName, arg: String) -> bool:
	if not can_evolve() or monster_index < 0 or monster_index >= monsters.size():
		return false
	if not monsters[monster_index].pick(slot, skill, family, arg):
		return false
	spend_ap(1)
	return true


func respec_requirements(monster_index: int) -> Array:
	return [{"aspect": monsters[monster_index].species().aspect, "count": RESPEC_MATERIALS}]


## Taking the evolutions back ("exchange, not just upgrade"): 1 AP and materials of its aspect.
func can_respec(monster_index: int) -> bool:
	return has_pillar() and ap >= 1 and monster_index >= 0 and monster_index < monsters.size() \
		and not monsters[monster_index].evolutions.is_empty() \
		and not materials_payment(respec_requirements(monster_index)).is_empty()


func respec(monster_index: int) -> bool:
	if not can_respec(monster_index):
		return false
	var paid := materials_payment(respec_requirements(monster_index))
	for id in paid:
		remove_item(id, int(paid[id]))
	spend_ap(1)
	monsters[monster_index].reset_evolutions()
	return true


## The monster that makes the player's breakthrough possible: at the player's stage, High, bar full.
func breakthrough_monster() -> int:
	for i in monsters.size():
		var m := monsters[i]
		if m.stage == stage and m.sub_tier == Stage.SubTier.HIGH and m.xp >= MonsterInstance.HIGH_BAR:
			return i
	return -1


func can_break_through() -> bool:
	return int(stage) < int(Stage.Type.SOVEREIGN) and ap >= 1 and breakthrough_monster() >= 0 \
		and not materials_payment([{"aspect": Aspect.Type.NONE, "count": BREAKTHROUGH_MATERIALS}]).is_empty()


## The player's breakthrough: 1 AP and materials; AP grows, the buildable area grows, new tier
## of materials, and the first one unlocks the Evolution Pillar (a milestone blueprint).
func break_through() -> bool:
	if not can_break_through():
		return false
	var paid := materials_payment([{"aspect": Aspect.Type.NONE, "count": BREAKTHROUGH_MATERIALS}])
	for id in paid:
		remove_item(id, int(paid[id]))
	spend_ap(1)
	advance_stage()
	return true


## Stage + 1 without any cost (the breakthrough and the cheat menu use it).
func advance_stage() -> void:
	stage = (int(stage) + 1) as Stage.Type
	sub_tier = Stage.SubTier.LOWER
	max_ap += 1
	ap += 1
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	market.add_tier(int(stage), rng)
	if stage == Stage.Type.FOUNDATION and not owns_structure(EVOLUTION_PILLAR):
		add_item(ItemCatalog.blueprint_id(EVOLUTION_PILLAR))


func can_monster_break_through(monster_index: int) -> bool:
	return ap >= 1 and monster_index >= 0 and monster_index < monsters.size() \
		and monsters[monster_index].can_break_through(stage) \
		and not materials_payment([{"aspect": Aspect.Type.NONE, "count": MONSTER_BREAKTHROUGH_MATERIALS}]).is_empty()


func monster_break_through(monster_index: int) -> bool:
	if not can_monster_break_through(monster_index):
		return false
	var paid := materials_payment([{"aspect": Aspect.Type.NONE, "count": MONSTER_BREAKTHROUGH_MATERIALS}])
	for id in paid:
		remove_item(id, int(paid[id]))
	spend_ap(1)
	monsters[monster_index].break_through()
	return true


## The structure part of the night: meditating monsters gain XP, plants grow. Returns report lines.
func _night_structures() -> Array[String]:
	var notes: Array[String] = []
	for s in structures:
		var def := StructureCatalog.def(StringName(s["id"]))
		if def.category == StructureDef.Category.CULTIVATION:
			var idx := int(s["assigned"])
			if idx < 0 or idx >= monsters.size() or not monsters[idx].can_gain_xp():
				continue
			var info := StructureRules.idle_xp(self, s)
			var ups := monsters[idx].add_xp(int(info["xp"]))
			notes.append("%s meditates at the %s: +%d XP%s" % [monsters[idx].species().display_name, def.display_name,
				int(info["xp"]), (" — reaches %s!" % Stage.sub_tier_name(monsters[idx].sub_tier)) if ups > 0 else ""])
		elif def.category == StructureDef.Category.GROWING and String(s["plant"]) != "":
			s["grown"] = int(s["grown"]) + 1
			if StructureRules.is_ready(self, s):
				notes.append("%s on the %s is ready to harvest." % [ItemCatalog.display_name(String(s["plant"])), def.display_name])
	return notes


func end_day(rng: RandomNumberGenerator = null) -> Dictionary:
	if rng == null:
		rng = RandomNumberGenerator.new()
		rng.randomize()
	var healed := 0
	var notes := _night_structures()
	for m in monsters:
		if m.current_hp < m.max_hp():
			healed += 1
		m.heal_full()
	day += 1
	ap = max_ap
	market.new_day(rng)
	return {"day": day, "healed": healed, "notes": notes}


func to_dict() -> Dictionary:
	var ms := []
	for m in monsters:
		ms.append(m.to_dict())
	return {"day": day, "max_ap": max_ap, "ap": ap, "money": money, "stage": int(stage),
		"sub_tier": int(sub_tier), "monsters": ms, "items": items.duplicate(), "market": market.to_dict(),
		"structures": structures.duplicate(true), "next_uid": _next_uid}


static func from_dict(d: Dictionary) -> GameState:
	var g := GameState.new()
	g.day = int(d["day"])
	g.max_ap = int(d["max_ap"])
	g.ap = int(d["ap"])
	g.money = int(d["money"])
	g.stage = int(d["stage"]) as Stage.Type
	g.sub_tier = int(d["sub_tier"]) as Stage.SubTier
	for md in d["monsters"]:
		g.monsters.append(MonsterInstance.from_dict(md))
	for id in d.get("items", {}):
		g.items[String(id)] = int(d["items"][id])
	g._next_uid = int(d.get("next_uid", 1))
	for sd in d.get("structures", []):
		g.structures.append({"uid": int(sd["uid"]), "id": String(sd["id"]), "x": int(sd["x"]), "y": int(sd["y"]),
			"rot": bool(sd["rot"]), "assigned": int(sd["assigned"]), "plant": String(sd["plant"]), "grown": int(sd["grown"])})
	if d.has("market"):
		g.market = Market.from_dict(d["market"])
	else:
		var rng := RandomNumberGenerator.new()
		rng.randomize()
		g.market = Market.create(int(g.stage), rng)
	return g
