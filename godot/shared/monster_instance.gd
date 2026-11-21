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
## Resolved stats: hp, pace, move, tpr, reach.
var stats := {}
## Persists between the battles of a dungeon run (docs/vision.md §4).
var current_hp := 1

## ---- The points model of the hub game (docs/monsters.md §2.2, §5) ----
## An individual made by `grown()` buys its stats with points: `stats` then also holds "ap", and "move" is its
## Stamina. Every step of growth gives STEP_POINTS to spend freely (`unspent`) and, at some steps, development
## steps for its skill slots (`dev_steps`, `slot_levels`; docs/skills.md §8).
const STEP_POINTS := 5
const START_POINTS := 25
const STEPS := 18
## XP from one step to the next (docs/monsters.md §5, working values).
const XP_STEPS: Array[int] = [60, 120, 200, 150, 300, 500, 400, 800, 1300, 1000, 2000, 3200, 2500, 5000, 8000, 6000, 12000]
## Steps (0-based, the step reached) that give a development step.
const DEV_STEP_AT: Array[int] = [3, 6, 9, 12, 13, 14, 15, 16, 17]
## What a grown monster has before any point is spent, so that it can use a kit; and the top of each stat.
const FLOOR := {"hp": 3, "pace": 1.0, "move": 2, "reach": 2, "tpr": 1, "ap": 2}
## Reach ends at 4 here: the unit sheet of the battle takes 2–4 (UnitSheet.problems).
const TOP := {"hp": 10, "pace": 10.0, "move": 10, "reach": 4, "tpr": 3, "ap": 5}
const STAT_ORDER: Array[String] = ["hp", "pace", "move", "reach", "ap", "tpr"]
const STAT_NAMES := {"hp": "HP", "pace": "Pace", "move": "Stamina", "reach": "Reach", "ap": "AP", "tpr": "Turns"}
## The last stage a rarity reaches (docs/monsters.md §4).
const LAST_STAGE := {Rarity.NORMAL: Stage.Type.CORE_FORMATION, Rarity.RARE: Stage.Type.SOUL, Rarity.EPIC: Stage.Type.IMMORTAL,
	Rarity.LEGENDARY: Stage.Type.SOVEREIGN}
var unspent := 0
var dev_steps := 0
## Development level per kit slot (1–3); a missing entry is level 1.
var slot_levels: Array[int] = []
var armour: StringName = &""


## The species' own numbers, unrolled: the "reference individual" of gdd_battle §6.2.
## Keeps the existing roster, tests and the draft behaving exactly as before.
static func of_species(def: MonsterDef) -> MonsterInstance:
	var m := MonsterInstance.new()
	m.species_id = def.id
	m.stats = {"hp": def.hp, "pace": def.pace, "move": def.move, "tpr": def.tpr, "reach": def.reach}
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


## A new individual of the points model at `step` (0 = Qi Gathering Lower … 17 = Sovereign High): the floor, then
## the points of its step spent at random. How a stat shape splits the points is not defined (T03).
static func grown(def: MonsterDef, rng: RandomNumberGenerator, step := 0, p_rarity := Rarity.NORMAL) -> MonsterInstance:
	var m := MonsterInstance.new()
	m.species_id = def.id
	m.rarity = p_rarity
	step = clampi(step, 0, STEPS - 1)
	m.stage = (step / 3) as Stage.Type
	m.sub_tier = (step % 3) as Stage.SubTier
	m.stats = FLOOR.duplicate()
	m.unspent = START_POINTS + STEP_POINTS * step - m.points_spent()
	for i in step + 1:
		if DEV_STEP_AT.has(i):
			m.dev_steps += m.steps_per_gain()
	m.spend_at_random(rng)
	m.current_hp = m.max_hp()
	return m


func uses_points() -> bool:
	return stats.has("ap")


func step() -> int:
	return int(stage) * 3 + int(sub_tier)


func steps_per_gain() -> int:
	return 2 if rarity >= Rarity.EPIC else 1


func points_spent() -> int:
	return MonsterDef.points_of(int(stats["hp"]), float(stats["pace"]), int(stats["move"]), int(stats["reach"]), int(stats["tpr"]), int(stats["ap"]))


func _raised(stat: String) -> Dictionary:
	var next := stats.duplicate()
	if stat == "pace":
		next[stat] = snappedf(float(stats[stat]) + 0.1, 0.1)
	else:
		next[stat] = int(stats[stat]) + 1
	return next


## What the next step of a stat costs (-1 = the stat is at its top).
func price_of(stat: String) -> int:
	if not uses_points() or float(stats[stat]) >= float(TOP[stat]) - 0.001:
		return -1
	var n := _raised(stat)
	return MonsterDef.points_of(int(n["hp"]), float(n["pace"]), int(n["move"]), int(n["reach"]), int(n["tpr"]), int(n["ap"])) - points_spent()


func can_buy(stat: String) -> bool:
	var price := price_of(stat)
	return price >= 0 and price <= unspent


func buy(stat: String) -> bool:
	if not can_buy(stat):
		return false
	unspent -= price_of(stat)
	stats = _raised(stat)
	if stat == "hp":
		current_hp += 1
	return true


## Spends what is left at random (wild monsters, a new individual); what no stat takes stays unspent.
func spend_at_random(rng: RandomNumberGenerator) -> void:
	var weights := {"hp": 6, "pace": 4, "move": 4, "reach": 1, "ap": 2, "tpr": 1}
	for i in 80:
		var open: Array[String] = []
		for stat in STAT_ORDER:
			if can_buy(stat):
				for k in int(weights[stat]):
					open.append(stat)
		if open.is_empty():
			return
		buy(open[rng.randi_range(0, open.size() - 1)])


## Reshape (docs/monsters.md §2.3): every point comes back and is spent anew by the player.
func refund_points() -> void:
	if not uses_points():
		return
	stats = FLOOR.duplicate()
	unspent = START_POINTS + STEP_POINTS * step() - points_spent()
	current_hp = mini(current_hp, max_hp())


## XP of the points model: a full bar is the next step (+5 points). At High the monster breaks through by itself
## while it stays at or below `tamer_stage` and the last stage of its rarity. Returns the steps gained.
func gain_xp(amount: int, tamer_stage: Stage.Type) -> int:
	var ups := 0
	xp += amount
	while step() < STEPS - 1 and xp >= XP_STEPS[step()]:
		var top: int = mini(int(tamer_stage), int(LAST_STAGE[rarity]))
		if sub_tier == Stage.SubTier.HIGH and int(stage) >= top:
			xp = XP_STEPS[step()]
			break
		xp -= XP_STEPS[step()]
		if sub_tier == Stage.SubTier.HIGH:
			stage = (int(stage) + 1) as Stage.Type
			sub_tier = Stage.SubTier.LOWER
		else:
			sub_tier = (int(sub_tier) + 1) as Stage.SubTier
		unspent += STEP_POINTS
		if DEV_STEP_AT.has(step()):
			dev_steps += steps_per_gain()
		ups += 1
	return ups


func xp_text() -> String:
	if step() >= STEPS - 1:
		return "at the top"
	return "XP %d / %d" % [xp, XP_STEPS[step()]]


func slot_level(slot: int) -> int:
	return slot_levels[slot] if slot < slot_levels.size() else 1


## Spends a development step on a kit slot (levels 1–3). The options of a skill are not defined, so a level
## changes nothing in a battle yet.
func develop_slot(slot: int) -> bool:
	if dev_steps <= 0 or slot < 0 or slot >= species().skills.size() or slot_level(slot) >= 3:
		return false
	while slot_levels.size() <= slot:
		slot_levels.append(1)
	slot_levels[slot] += 1
	dev_steps -= 1
	return true


func stats_text() -> String:
	if not uses_points():
		return "HP %d/%d   Pace %.1f   Move %d   TPR %d   Reach %d" % [current_hp, max_hp(), float(stats["pace"]),
			int(stats["move"]), int(stats["tpr"]), int(stats["reach"])]
	return "HP %d/%d · Pace %.1f · Stamina %d · Reach %d · AP %d · Turns %d" % [current_hp, max_hp(), float(stats["pace"]),
		int(stats["move"]), int(stats["reach"]), int(stats["ap"]), int(stats["tpr"])]


func title() -> String:
	var def := species()
	return "%s (%s, %s %s)" % [def.display_name, MonsterDef.kin_name(def.kin), Stage.stage_name(stage), Stage.sub_tier_name(sub_tier)]


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
	d.pace = float(stats["pace"])
	d.move = int(stats["move"])
	d.tpr = int(stats["tpr"])
	d.reach = int(stats["reach"])
	return d


## The full datasheet as text (identity, stats, kit) — what the pre-battle screen and the
## inner world show. No hidden information (gdd_battle pillar 6).
func sheet_text(with_kit := true) -> String:
	var def := species()
	var head := "%s — %s %s · %s" % [def.display_name, Aspect.NAMES[def.aspect], MonsterDef.kin_name(def.kin),
		StatShape.shape_name(shape)]
	var line := "HP %d/%d   Pace %.1f   Move %d   TPR %d   Reach %d" % [current_hp, max_hp(),
		float(stats["pace"]), int(stats["move"]), int(stats["tpr"]), int(stats["reach"])]
	if not with_kit:
		return head + "\n" + line
	var kit := "Kit: %s" % def.kit_text()
	return head + "\n" + line + "\n" + kit


func to_dict() -> Dictionary:
	return {"species": String(species_id), "shape": int(shape), "rarity": int(rarity), "stage": int(stage),
		"sub_tier": int(sub_tier), "xp": xp, "stats": stats.duplicate(), "core": core.duplicate(), "current_hp": current_hp,
		"unspent": unspent, "dev_steps": dev_steps, "slot_levels": slot_levels.duplicate(), "armour": String(armour)}


static func from_dict(d: Dictionary) -> MonsterInstance:
	var m := MonsterInstance.new()
	m.species_id = StringName(d["species"])
	m.shape = int(d["shape"]) as StatShape.Id
	m.rarity = int(d["rarity"]) as Rarity
	m.stage = int(d["stage"]) as Stage.Type
	m.sub_tier = int(d["sub_tier"]) as Stage.SubTier
	m.xp = int(d["xp"])
	var st: Dictionary = d["stats"]
	# Saves from before 2026-11-15 hold "initiative" on the earlier 1–9 scale (StatShape.pace_from_pool).
	var saved_pace: float = float(st["pace"]) if st.has("pace") else StatShape.pace_from_pool(float(st.get("initiative", 5.0)))
	m.stats = {"hp": int(st["hp"]), "pace": saved_pace, "move": int(st["move"]),
		"tpr": int(st["tpr"]), "reach": int(st["reach"])}
	var c: Dictionary = d.get("core", {})
	if not c.is_empty():
		m.core = {"hp": int(c["hp"]), "pace": float(c.get("pace", c.get("initiative", 5.0))), "move": int(c["move"]),
			"tpr": int(c["tpr"]), "reach": int(c["reach"])}
	if st.has("ap"):
		m.stats["ap"] = int(st["ap"])
	m.current_hp = int(d["current_hp"])
	m.unspent = int(d.get("unspent", 0))
	m.dev_steps = int(d.get("dev_steps", 0))
	for l in d.get("slot_levels", []):
		m.slot_levels.append(int(l))
	m.armour = StringName(d.get("armour", ""))
	return m
