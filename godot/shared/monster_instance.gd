class_name MonsterInstance
extends RefCounted
## One individual monster the player owns or meets (gdd_overworld §4.3): a fixed species plus
## what makes this monster unique — stat shape, rarity, stage / sub-tier / XP, resolved stats
## and current HP. It owns no battle rules.
##
## The battle never sees an instance: `to_battle_unit()` resolves it into a finished unit sheet
## (a MonsterDef copy with this individual's stats), which is what `Monster` already consumes.
##
## Not yet modelled (later steps): artifacts, extra passives, 2nd utility slot.

enum Rarity { NORMAL, RARE, EPIC, LEGENDARY }

## XP needed to reach the next sub-tier (prototype values, tuning: gdd_overworld §12). The High
## bar can fill but only a breakthrough trial (not built yet) leads to the next stage.
const XP_TO_NEXT := {Stage.SubTier.LOWER: 60, Stage.SubTier.MIDDLE: 120}
const HIGH_BAR := 200

var species_id: StringName
var shape: StatShape.Id = StatShape.Id.NONE
var rarity: Rarity = Rarity.NORMAL
var stage: Stage.Type = Stage.Type.CORE_FORMATION
var sub_tier: Stage.SubTier = Stage.SubTier.HIGH
var xp := 0
## The rolled spread on the Core Formation scale; stats are re-snapped from it when the sub-tier
## or stage changes. Empty for reference individuals (their stats are fixed).
var core := {}
## Skill evolution picks (gdd_overworld §4.7): [{slot, skill, family, arg}], see Evolution.
var evolutions: Array[Dictionary] = []
## Resolved stats: hp, initiative, move, tpr, reach.
var stats := {}
## Persists between battles of an expedition (gdd_overworld §10.2).
var current_hp := 1


## The species' own numbers, unrolled: the "reference individual" of gdd_battle §6.2.
## Keeps the existing roster, tests and the draft behaving exactly as before.
static func of_species(def: MonsterDef) -> MonsterInstance:
	var m := MonsterInstance.new()
	m.species_id = def.id
	m.stats = {"hp": def.hp, "initiative": def.initiative, "move": def.move, "tpr": def.tpr, "reach": def.reach}
	m.current_hp = def.hp
	return m


## A new individual: shape rolled inside its ranges, snapped to the stage ceilings.
## `shape` NONE picks one by the species' Kin lean.
static func roll(def: MonsterDef, rng: RandomNumberGenerator, p_shape := StatShape.Id.NONE,
		p_stage := Stage.Type.QI_GATHERING, p_sub_tier := Stage.SubTier.LOWER, p_rarity := Rarity.NORMAL) -> MonsterInstance:
	var m := MonsterInstance.new()
	m.species_id = def.id
	m.shape = p_shape if p_shape != StatShape.Id.NONE else StatShape.pick_for_kin(def.kin, rng)
	m.rarity = p_rarity
	m.stage = p_stage
	m.sub_tier = p_sub_tier
	m.core = StatShape.roll_core(m.shape, rng)
	m.stats = StatShape.at_stage(m.core, p_stage, p_sub_tier)
	m.current_hp = m.max_hp()
	return m


func max_hp() -> int:
	return int(stats["hp"])


func species() -> MonsterDef:
	return GameData.monster(species_id)


func xp_needed() -> int:
	return XP_TO_NEXT.get(sub_tier, HIGH_BAR)


func can_gain_xp() -> bool:
	return not (sub_tier == Stage.SubTier.HIGH and xp >= HIGH_BAR)


## Adds XP; a full bar is a sub-tier up and the stats snap to the new values. Returns the ups.
func add_xp(amount: int) -> int:
	var ups := 0
	xp += amount
	while sub_tier != Stage.SubTier.HIGH and xp >= xp_needed():
		xp -= xp_needed()
		sub_tier = (int(sub_tier) + 1) as Stage.SubTier
		ups += 1
	if sub_tier == Stage.SubTier.HIGH:
		xp = mini(xp, HIGH_BAR)
	if ups > 0:
		resnap()
	return ups


## Recomputes the stats from the rolled spread for the current stage and sub-tier. The extra
## max HP is healed; reference individuals keep their fixed stats.
func resnap() -> void:
	if core.is_empty():
		return
	var old_max := max_hp()
	stats = StatShape.at_stage(core, stage, sub_tier)
	var gain := max_hp() - old_max
	current_hp = mini(max_hp(), current_hp + maxi(gain, 0))


## A full XP bar at High sub-tier plus a ritual lifts the monster to the next stage (§4.1).
func can_break_through(player_stage: Stage.Type) -> bool:
	return sub_tier == Stage.SubTier.HIGH and xp >= HIGH_BAR and int(stage) < int(player_stage)


func break_through() -> void:
	stage = (int(stage) + 1) as Stage.Type
	sub_tier = Stage.SubTier.LOWER
	xp = 0
	resnap()


# ---------- skill evolution ----------

func evo_slots() -> int:
	return Evolution.slot_count(stage)


func slot_picks(slot: int) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for p in evolutions:
		if int(p["slot"]) == slot:
			out.append(p)
	return out


func picks_left(slot: int) -> int:
	if slot < 0 or slot >= evo_slots():
		return 0
	return Evolution.picks_per_slot(rarity) - slot_picks(slot).size()


## The paths this slot offers, fixed per individual: a seeded shuffle of the paths that are still
## open given the picks of EARLIER slots, cut to the rarity's number of offers (§5).
func slot_offers(slot: int) -> Array[Dictionary]:
	var before: Array[Dictionary] = []
	for p in evolutions:
		if int(p["slot"]) < slot:
			before.append(p)
	var rng := RandomNumberGenerator.new()
	rng.seed = ("%s|%s|%d" % [species_id, str(core), slot]).hash()
	var order := Evolution.all_paths()
	for i in range(order.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp := order[i]
		order[i] = order[j]
		order[j] = tmp
	var out: Array[Dictionary] = []
	for path in order:
		if out.size() >= Evolution.offers_per_slot(rarity):
			break
		if not Evolution.variants(species(), path["skill"], path["family"], before).is_empty():
			out.append(path)
	return out


## The variants of an offered path right now (empty if it is closed or taken).
func path_variants(skill: StringName, family: StringName) -> Array[Dictionary]:
	return Evolution.variants(species(), skill, family, evolutions)


func is_offered(slot: int, skill: StringName, family: StringName) -> bool:
	for path in slot_offers(slot):
		if path["skill"] == skill and path["family"] == family:
			return true
	return false


func can_pick(slot: int, skill: StringName, family: StringName, arg: String) -> bool:
	if picks_left(slot) <= 0 or not is_offered(slot, skill, family):
		return false
	for v in path_variants(skill, family):
		if v["arg"] == arg:
			return true
	return false


func pick(slot: int, skill: StringName, family: StringName, arg: String) -> bool:
	if not can_pick(slot, skill, family, arg):
		return false
	evolutions.append({"slot": slot, "skill": String(skill), "family": String(family), "arg": arg})
	return true


func reset_evolutions() -> void:
	evolutions.clear()


func progress_text() -> String:
	var s := "%s · %s" % [Stage.stage_name(stage), Stage.sub_tier_name(sub_tier)]
	if sub_tier == Stage.SubTier.HIGH and xp >= HIGH_BAR:
		return s + " — XP bar full (a breakthrough trial is needed)"
	return s + " — XP %d / %d" % [xp, xp_needed()]


func heal_full() -> void:
	current_hp = max_hp()


## The finished unit sheet the battle works with: the species with this individual's stats.
## It is a copy — changing it never touches the species file.
func to_battle_unit() -> MonsterDef:
	var d: MonsterDef = species().duplicate()
	d.hp = int(stats["hp"])
	d.initiative = float(stats["initiative"])
	d.move = int(stats["move"])
	d.tpr = int(stats["tpr"])
	d.reach = int(stats["reach"])
	d.surge = Evolution.current_skill(d, Evolution.SURGE, evolutions)
	d.utility = Evolution.current_skill(d, Evolution.UTILITY, evolutions)
	return d


## The full datasheet as text (identity, stats, kit) — what the pre-battle screen and the
## inner world show. No hidden information (gdd_battle pillar 6).
func sheet_text(with_kit := true) -> String:
	var def := species()
	var head := "%s — %s %s · %s" % [def.display_name, Aspect.NAMES[def.aspect], MonsterDef.kin_name(def.kin),
		StatShape.shape_name(shape)]
	var line := "HP %d/%d   Init %.1f   Move %d   TPR %d   Reach %d" % [current_hp, max_hp(),
		float(stats["initiative"]), int(stats["move"]), int(stats["tpr"]), int(stats["reach"])]
	if not with_kit:
		return head + "\n" + line
	var kit := "Surge: %s · Utility: %s · Passive: %s · Strike: %s" % [def.surge.display_name,
		def.utility.display_name, def.passive_name(), def.strike_name()]
	return head + "\n" + line + "\n" + kit


func to_dict() -> Dictionary:
	return {"species": String(species_id), "shape": int(shape), "rarity": int(rarity), "stage": int(stage),
		"sub_tier": int(sub_tier), "xp": xp, "stats": stats.duplicate(), "core": core.duplicate(), "evolutions": evolutions.duplicate(true), "current_hp": current_hp}


static func from_dict(d: Dictionary) -> MonsterInstance:
	var m := MonsterInstance.new()
	m.species_id = StringName(d["species"])
	m.shape = int(d["shape"]) as StatShape.Id
	m.rarity = int(d["rarity"]) as Rarity
	m.stage = int(d["stage"]) as Stage.Type
	m.sub_tier = int(d["sub_tier"]) as Stage.SubTier
	m.xp = int(d["xp"])
	var st: Dictionary = d["stats"]
	m.stats = {"hp": int(st["hp"]), "initiative": float(st["initiative"]), "move": int(st["move"]),
		"tpr": int(st["tpr"]), "reach": int(st["reach"])}
	var c: Dictionary = d.get("core", {})
	if not c.is_empty():
		m.core = {"hp": int(c["hp"]), "initiative": float(c["initiative"]), "move": int(c["move"]),
			"tpr": int(c["tpr"]), "reach": int(c["reach"])}
	for e in d.get("evolutions", []):
		m.evolutions.append({"slot": int(e["slot"]), "skill": String(e["skill"]), "family": String(e["family"]), "arg": String(e["arg"])})
	m.current_hp = int(d["current_hp"])
	return m
