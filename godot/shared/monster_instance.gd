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

## XP needed to reach the next sub-tier (prototype values, tuning: gdd_overworld §12). The High
## bar can fill but only a breakthrough trial (not built yet) leads to the next stage.
const XP_TO_NEXT := {Stage.SubTier.LOWER: 60, Stage.SubTier.MIDDLE: 120}
const HIGH_BAR := 200

var species_id: StringName
var shape: StatShape.Id = StatShape.Id.NONE
var stage: Stage.Type = Stage.Type.CORE_FORMATION
var sub_tier: Stage.SubTier = Stage.SubTier.HIGH
var xp := 0
## The rolled spread on the Core Formation scale; stats are re-snapped from it when the sub-tier
## or stage changes. Empty for reference individuals (their stats are fixed).
var core := {}
## Resolved stats: hp, pace, move, tpr, reach.
var stats := {}
## Full at the start of every battle (docs/vision.md §4).
var current_hp := 1

## ---- The points model of the hub game (docs/monsters.md §2.2, §5) ----
## An individual made by `grown()` buys its stats with points: `stats` then also holds "ap", and "move" is its
## Stamina. Every step of growth gives STEP_POINTS to spend freely (`unspent`) and, at some steps, development
## steps for its skill slots (`dev_steps`, `slot_levels`; docs/skills.md §8).
const STEP_POINTS := 5
const START_POINTS := 25
const STEPS := 15
## Steps (0-based, the step reached) that give a development step outright. The first step of a stage gives a
## choice instead (docs/monsters.md §5).
const DEV_STEP_AT: Array[int] = [13, 14]
const START_SLOTS := 4
const MAX_SLOTS := 6
## What a monster chooses from at a stage breakthrough (docs/monsters.md §5): every monster the same, one of them.
const BREADTH := "slot"
const DEPTH := "depth"
const LORE := "lore"
const RESHAPE := "reshape"
const CHOICES: Array[String] = [BREADTH, DEPTH, LORE, RESHAPE]
const CHOICE_NAMES := {BREADTH: "Breadth: a new slot", DEPTH: "Depth: a development step",
	LORE: "Lore: a skill of another species of its Kin", RESHAPE: "Reshape: spend its stat points anew"}
## What a grown monster has before any point is spent, so that it can use a kit; and the top of each stat.
const FLOOR := {"hp": 3, "pace": 1.0, "move": 2, "reach": 2, "tpr": 1, "ap": 2}
## Reach ends at 4 here: the unit sheet of the battle takes 2–4 (UnitSheet.problems).
const TOP := {"hp": 10, "pace": 10.0, "move": 10, "reach": 4, "tpr": 3, "ap": 5}
const STAT_ORDER: Array[String] = ["hp", "pace", "move", "reach", "ap", "tpr"]
const STAT_NAMES := {"hp": "HP", "pace": "Pace", "move": "Stamina", "reach": "Reach", "ap": "AP", "tpr": "Turns"}
var unspent := 0
var dev_steps := 0
## Development level per kit slot (1–3); a missing entry is level 1.
var slot_levels: Array[int] = []
## The options chosen per kit slot (SkillDev): one per level above the first. Fewer than that means a choice is
## open: after a development step taken without one, or after the slot took another skill.
var slot_opts: Array = []
## Stat points it gained from pills, beyond the points of its step (docs/overworld.md §6.2).
var bonus_points := 0
## Open kit slots (4 at the start, up to 6) and what fills them: ids of skills of the species.
var slots := START_SLOTS
var kit: Array[StringName] = []
## Hatched and not yet in a battle: the player still shapes it freely (docs/overworld.md §4.1).
var fresh := false
## It fought in the last wild battle won and still stood: the player may give it a rise that battle left.
var may_rise := false
## Picks left at a stage breakthrough, and what was already picked in the running one (a vow may give two).
var choice_picks := 0
var choice_taken: Array[String] = []
## Skills of other species of its Kin it took as Lore: they join what it can learn.
var lore: Array[StringName] = []


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
		p_stage := Stage.Type.QI_GATHERING, p_sub_tier := Stage.SubTier.LOWER) -> MonsterInstance:
	var m := MonsterInstance.new()
	m.species_id = def.id
	m.shape = p_shape if p_shape != StatShape.Id.NONE else StatShape.pick_for_kin(def.kin, rng)
	m.stage = p_stage
	m.sub_tier = p_sub_tier
	m.core = StatShape.roll_core(m.shape, rng)
	m.stats = StatShape.at_stage(m.core, p_stage, p_sub_tier)
	m.current_hp = m.max_hp()
	return m


## A new individual of the points model at `step` (0 = Qi Gathering Lower … 14 = Immortal High): the floor, then
## the points of its step spent at random. How a stat shape splits the points is not defined (T03).
static func grown(def: MonsterDef, rng: RandomNumberGenerator, step := 0) -> MonsterInstance:
	var m := MonsterInstance.new()
	m.species_id = def.id
	step = clampi(step, 0, STEPS - 1)
	m.stage = (step / 3) as Stage.Type
	m.sub_tier = (step % 3) as Stage.SubTier
	m.stats = FLOOR.duplicate()
	m.unspent = START_POINTS + STEP_POINTS * step - m.points_spent()
	m._gains_up_to(step)
	m.spend_at_random(rng)
	while m.choice_picks > 0:
		var open: Array[String] = []
		for c in CHOICES:
			if m.can_choose(c):
				open.append(c)
		if open.is_empty():
			m.choice_picks = 0
			break
		m.choose(open[rng.randi_range(0, open.size() - 1)], &"", rng)
	var list := m.learnable()
	while m.kit.size() < m.slots and not list.is_empty():
		var at := rng.randi_range(0, list.size() - 1)
		m.kit.append(list[at].id)
		list.remove_at(at)
	var guard := 0
	while m.dev_steps > 0 and guard < 32:         # a wild monster has developed its slots
		guard += 1
		var slot := rng.randi_range(0, maxi(0, m.kit.size() - 1))
		var open := m.open_options(slot)
		if not m.kit.is_empty() and m.slot_level(slot) < SkillDev.MAX_LEVEL and not open.is_empty():
			m.develop_slot(slot, open[rng.randi_range(0, open.size() - 1)])
	m.current_hp = m.max_hp()
	return m


## A monster from an egg (docs/overworld.md §4.1): nothing is spent and no skill is chosen; the player shapes it.
static func hatched(def: MonsterDef, step := 0) -> MonsterInstance:
	var m := MonsterInstance.new()
	m.species_id = def.id
	step = clampi(step, 0, STEPS - 1)
	m.stage = (step / 3) as Stage.Type
	m.sub_tier = (step % 3) as Stage.SubTier
	m.stats = FLOOR.duplicate()
	m.unspent = START_POINTS + STEP_POINTS * step - m.points_spent()
	m._gains_up_to(step)
	m.fresh = true
	m.current_hp = m.max_hp()
	return m


## What the steps up to `step` gave besides points: development steps and breakthrough choices.
func _gains_up_to(step: int) -> void:
	for i in range(1, step + 1):
		if DEV_STEP_AT.has(i):
			dev_steps += 1
		if i % 3 == 0:
			choice_picks += 1


## The skills this monster can learn: the list of its species within the groups of its Kin, and what it took as Lore.
func learnable() -> Array[BattleSkillDef]:
	var out := species().learn_list()
	for s in _kin_skills():
		if lore.has(s.id) and not out.has(s):
			out.append(s)
	return out


## The skills the other species of its Kin can learn.
func _kin_skills() -> Array[BattleSkillDef]:
	var out: Array[BattleSkillDef] = []
	var kin := species().kin
	for id in GameData.species_ids(kin == MonsterDef.Kin.VOID):
		var other := GameData.monster(id)
		if other == null or other.kin != kin or other.id == species_id:
			continue
		for s in other.learn_list():
			if not out.has(s):
				out.append(s)
	return out


## What Lore offers: skills of other species of its Kin that it cannot learn yet.
func lore_options() -> Array[BattleSkillDef]:
	var mine := learnable()
	var out: Array[BattleSkillDef] = []
	for s in _kin_skills():
		var known := false
		for m in mine:
			if m.id == s.id:
				known = true
		if not known:
			out.append(s)
	return out


func _skill(skill_id: StringName) -> BattleSkillDef:
	var def := species()
	for s in def.learnable + def.skills:
		if s != null and s.id == skill_id:
			return s
	if lore.has(skill_id):
		for s in _kin_skills():
			if s.id == skill_id:
				return s
	return null


func can_learn(skill_id: StringName) -> bool:
	for s in learnable():
		if s.id == skill_id:
			return not kit.has(skill_id)
	return false


## The skills in its slots, in slot order.
func kit_skills() -> Array[BattleSkillDef]:
	var out: Array[BattleSkillDef] = []
	if not uses_points():
		for s in species().skills:
			if s != null:
				out.append(s)
		return out
	for skill_id in kit:
		var s := _skill(skill_id)
		if s != null:
			out.append(s)
	return out


func kit_text() -> String:
	var names: PackedStringArray = []
	for s in kit_skills():
		names.append(s.display_name)
	return " · ".join(names) if not names.is_empty() else "no skill yet"


## Puts a learnable skill into a free slot.
func learn(skill_id: StringName) -> bool:
	if kit.size() >= slots or not can_learn(skill_id):
		return false
	kit.append(skill_id)
	return true


## Takes the skill out of a slot: only while the monster is fresh from the egg. The slots behind move up.
func unlearn(slot: int) -> bool:
	if not fresh or slot < 0 or slot >= kit.size():
		return false
	kit.remove_at(slot)
	if slot < slot_levels.size():
		slot_levels.remove_at(slot)
	if slot < slot_opts.size():
		slot_opts.remove_at(slot)
	return true


## Another skill in a slot (the relearning pill, docs/skills.md §8): the slot keeps its level, and its options are
## chosen anew from the new skill.
func relearn(slot: int, skill_id: StringName) -> bool:
	if slot < 0 or slot >= kit.size() or not can_learn(skill_id):
		return false
	kit[slot] = skill_id
	if slot < slot_opts.size():
		slot_opts[slot] = []
	return true


## The skills it brings into a battle: those of its slots with the options of each slot applied (SkillDev).
func battle_skills() -> Array[BattleSkillDef]:
	var out: Array[BattleSkillDef] = []
	var raw := kit_skills()
	for slot in raw.size():
		out.append(SkillDev.developed(raw[slot], slot_options(slot)) if uses_points() else raw[slot])
	return out


## The options chosen for a slot.
func slot_options(slot: int) -> Array:
	return slot_opts[slot] if slot >= 0 and slot < slot_opts.size() else []


## The options the skill of a slot can still take.
func open_options(slot: int) -> Array[String]:
	var raw := kit_skills()
	if slot < 0 or slot >= raw.size():
		return [] as Array[String]
	return SkillDev.open_options(raw[slot], slot_options(slot))


## Options the player may still choose for a slot without a development step: its level allows more than it has
## (the slot took another skill, or a step was taken while the skill had nothing to offer).
func open_picks(slot: int) -> int:
	return mini(slot_level(slot) - 1 - slot_options(slot).size(), open_options(slot).size())


## Chooses an option for a slot whose level already allows one.
func pick_option(slot: int, option: String) -> bool:
	if open_picks(slot) <= 0 or not open_options(slot).has(option):
		return false
	while slot_opts.size() <= slot:
		slot_opts.append([])
	(slot_opts[slot] as Array).append(option)
	return true


func can_choose(choice: String) -> bool:
	if choice_taken.size() >= CHOICES.size():
		choice_taken.clear()
	if choice_picks <= 0 or choice_taken.has(choice) or not CHOICES.has(choice):
		return false
	match choice:
		BREADTH:
			return slots < MAX_SLOTS
		LORE:
			return not lore_options().is_empty()
		RESHAPE:
			return uses_points()
	return true


## What it is offered at a stage breakthrough: the same for every monster.
func offered() -> Array[String]:
	return CHOICES.duplicate()


## Takes one of the offer at a stage breakthrough. `gift` names the skill for LORE; without one it is drawn. RESHAPE gives every point back; with `rng` (a wild monster) they are spent at once.
func choose(choice: String, gift: StringName = &"", rng: RandomNumberGenerator = null) -> bool:
	if not can_choose(choice):
		return false
	match choice:
		BREADTH:
			slots += 1
		DEPTH:
			dev_steps += 1
		LORE:
			var options := lore_options()
			if gift == &"":
				gift = options[rng.randi_range(0, options.size() - 1) if rng != null else 0].id
			var found := false
			for s in options:
				if s.id == gift:
					found = true
			if not found:
				return false
			lore.append(gift)
		RESHAPE:
			refund_points()
			if rng != null:
				spend_at_random(rng)
				current_hp = max_hp()
	choice_picks -= 1
	choice_taken.append(choice)
	if choice_picks == 0:
		choice_taken.clear()
	return true


func uses_points() -> bool:
	return stats.has("ap")


func step() -> int:
	return int(stage) * 3 + int(sub_tier)




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
	unspent = START_POINTS + STEP_POINTS * step() + bonus_points - points_spent()
	current_hp = mini(current_hp, max_hp())


## Growth of the points model (docs/monsters.md §2.3): a rise is the next step (+5 points). Within a stage every
## rise is open; from High a monster rises into the next stage only while that stage is at or below `tamer_stage`.
## Returns whether it rose.
func rise(tamer_stage: Stage.Type) -> bool:
	if not can_step(tamer_stage):
		return false
	if sub_tier == Stage.SubTier.HIGH:
		stage = (int(stage) + 1) as Stage.Type
		sub_tier = Stage.SubTier.LOWER
		choice_picks += 1
	else:
		sub_tier = (int(sub_tier) + 1) as Stage.SubTier
	unspent += STEP_POINTS
	if DEV_STEP_AT.has(step()):
		dev_steps += 1
	return true


## Whether a rise would lift it a step now: it is not at the top and not held at High by its tamer's stage.
func can_step(tamer_stage: Stage.Type) -> bool:
	return step() < STEPS - 1 and not (sub_tier == Stage.SubTier.HIGH and int(stage) >= int(tamer_stage))


## Where it stands and what lifts it next.
func growth_text() -> String:
	if step() >= STEPS - 1:
		return "at the top"
	return "rises by a battle won in the void" if sub_tier == Stage.SubTier.HIGH else "rises by a wild battle won against a monster of its step or above"


func slot_level(slot: int) -> int:
	return slot_levels[slot] if slot < slot_levels.size() else 1


## Spends a development step on a kit slot (levels 1–3) and takes an option of the skill's kind for it
## (docs/skills.md §8). Without `option` the level rises and the choice stays open (`open_picks`).
func develop_slot(slot: int, option := "") -> bool:
	if dev_steps <= 0 or slot < 0 or slot >= kit.size() or slot_level(slot) >= SkillDev.MAX_LEVEL:
		return false
	if option != "" and not open_options(slot).has(option):
		return false
	while slot_levels.size() <= slot:
		slot_levels.append(1)
	slot_levels[slot] += 1
	dev_steps -= 1
	if option != "":
		while slot_opts.size() <= slot:
			slot_opts.append([])
		(slot_opts[slot] as Array).append(option)
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
	return {"species": String(species_id), "shape": int(shape), "stage": int(stage),
		"sub_tier": int(sub_tier), "xp": xp, "stats": stats.duplicate(), "core": core.duplicate(), "current_hp": current_hp,
		"unspent": unspent, "dev_steps": dev_steps, "slot_levels": slot_levels.duplicate(),
		"slots": slots, "kit": kit.map(func(k: StringName) -> String: return String(k)), "fresh": fresh,
		"choice_picks": choice_picks, "choice_taken": choice_taken.duplicate(), "slot_opts": slot_opts.duplicate(true), "bonus_points": bonus_points,
		"lore": lore.map(func(s: StringName) -> String: return String(s)), "may_rise": may_rise}


static func from_dict(d: Dictionary) -> MonsterInstance:
	var m := MonsterInstance.new()
	m.species_id = StringName(d["species"])
	m.shape = int(d["shape"]) as StatShape.Id
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
	m.slots = int(d.get("slots", START_SLOTS))
	for k in d.get("kit", []):
		if k is String:
			m.kit.append(StringName(k))
		elif int(k) >= 0 and int(k) < m.species().skills.size():      # a save from before skill ids
			m.kit.append(m.species().skills[int(k)].id)
	m.fresh = bool(d.get("fresh", false))
	m.may_rise = bool(d.get("may_rise", false))
	m.choice_picks = int(d.get("choice_picks", 0))
	m.bonus_points = int(d.get("bonus_points", 0))
	for opts in d.get("slot_opts", []):
		var list: Array = []
		for o in opts:
			list.append(String(o))
		m.slot_opts.append(list)
	for s in d.get("lore", []):
		m.lore.append(StringName(s))
	for taken in d.get("choice_taken", []):
		m.choice_taken.append(String(taken))
	return m
