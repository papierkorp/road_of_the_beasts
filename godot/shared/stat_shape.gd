class_name StatShape
extends RefCounted
## The six stat shapes of an individual monster (gdd_overworld §4.4, gdd_battle §4.5).
##
## A shape is a reference spread on the Core Formation scale plus a min / max range for the three
## "price 1" stats (HP, Initiative, Move). Rolling moves single points between those three stats
## inside the ranges, so the point total of a shape never changes — only where the points sit.
## TPR and Reach are the identity of a shape and are not rolled.
## The rolled Core-scale spread is then snapped to the stage ceilings (`at_stage`).
##
## Tuning to do (data only, see gdd_overworld §12): equalise the point total across shapes
## and balance the ranges with tools/sim.gd.

enum Id { NONE, GLASS_CANNON, ANVIL, SKIRMISHER, BERSERKER, BALANCED, FRAGILE }

## Stats that points may be moved between while rolling (all cost the same).
const POOL := ["hp", "initiative", "move"]
## How many point transfers a roll attempts.
const TRANSFERS := 4

const DATA := {
	Id.GLASS_CANNON: {"name": "Glass cannon", "hp": 2, "initiative": 9, "move": 3, "tpr": 2, "reach": 1,
		"hp_range": [1, 3], "initiative_range": [8, 9], "move_range": [2, 4]},
	Id.ANVIL: {"name": "Anvil", "hp": 8, "initiative": 2, "move": 1, "tpr": 1, "reach": 2,
		"hp_range": [7, 8], "initiative_range": [2, 4], "move_range": [1, 2]},
	Id.SKIRMISHER: {"name": "Skirmisher", "hp": 4, "initiative": 6, "move": 4, "tpr": 1, "reach": 1,
		"hp_range": [3, 5], "initiative_range": [5, 7], "move_range": [3, 4]},
	Id.BERSERKER: {"name": "Berserker", "hp": 5, "initiative": 7, "move": 2, "tpr": 2, "reach": 1,
		"hp_range": [4, 6], "initiative_range": [6, 8], "move_range": [1, 3]},
	Id.BALANCED: {"name": "Balanced", "hp": 5, "initiative": 6, "move": 2, "tpr": 1, "reach": 1,
		"hp_range": [4, 6], "initiative_range": [5, 7], "move_range": [2, 3]},
	Id.FRAGILE: {"name": "Fragile", "hp": 3, "initiative": 6, "move": 2, "tpr": 2, "reach": 1,
		"hp_range": [2, 4], "initiative_range": [5, 7], "move_range": [1, 3]},
}

## Kin lean (gdd_battle §6 "stat lean"): relative weights for the shape a new individual rolls.
const KIN_LEAN := {
	MonsterDef.Kin.BEAST: {Id.SKIRMISHER: 3, Id.BALANCED: 3, Id.BERSERKER: 2, Id.GLASS_CANNON: 1, Id.ANVIL: 1},
	MonsterDef.Kin.WINGED: {Id.GLASS_CANNON: 5, Id.SKIRMISHER: 2, Id.FRAGILE: 1, Id.BALANCED: 1},
	MonsterDef.Kin.SCALED: {Id.ANVIL: 5, Id.BALANCED: 2, Id.BERSERKER: 1},
	MonsterDef.Kin.SWARM: {Id.FRAGILE: 5, Id.BERSERKER: 2, Id.SKIRMISHER: 1, Id.GLASS_CANNON: 1},
	MonsterDef.Kin.SPIRIT: {Id.SKIRMISHER: 3, Id.FRAGILE: 3, Id.GLASS_CANNON: 2, Id.BALANCED: 1},
	MonsterDef.Kin.ANCIENT: {Id.ANVIL: 6, Id.BALANCED: 2, Id.BERSERKER: 1},
}


static func shape_name(s: Id) -> String:
	if s == Id.NONE:
		return "Reference"
	return DATA[s]["name"]


## All shapes an individual can roll.
static func rollable() -> Array[Id]:
	var out: Array[Id] = []
	for s in DATA:
		out.append(s)
	return out


## Weighted pick for a species: its Kin leans towards some shapes, but any shape can appear.
static func pick_for_kin(kin: MonsterDef.Kin, rng: RandomNumberGenerator) -> Id:
	var weights: Dictionary = KIN_LEAN[kin]
	var total := 0
	for s in weights:
		total += int(weights[s])
	var r := rng.randi_range(1, total)
	for s in weights:
		r -= int(weights[s])
		if r <= 0:
			return s
	return Id.BALANCED


## Rolled stats on the Core Formation scale. The sum hp + initiative + move equals the shape's
## reference sum; every value stays inside its range.
static func roll_core(shape: Id, rng: RandomNumberGenerator) -> Dictionary:
	var d: Dictionary = DATA[shape]
	var v := {"hp": int(d["hp"]), "initiative": int(d["initiative"]), "move": int(d["move"])}
	for i in TRANSFERS:
		var from: String = POOL[rng.randi_range(0, POOL.size() - 1)]
		var to: String = POOL[rng.randi_range(0, POOL.size() - 1)]
		if from == to:
			continue
		if v[from] - 1 < int(d[from + "_range"][0]) or v[to] + 1 > int(d[to + "_range"][1]):
			continue
		v[from] -= 1
		v[to] += 1
	return {"hp": v["hp"], "initiative": float(v["initiative"]), "move": v["move"],
		"tpr": int(d["tpr"]), "reach": int(d["reach"])}


## How much of the stage budget a sub-tier fills (HP and Initiative). Prototype values, to be tuned.
const SUB_TIER_FILL := {Stage.SubTier.LOWER: 0.75, Stage.SubTier.MIDDLE: 0.9, Stage.SubTier.HIGH: 1.0}


## Snaps a Core-scale spread to a stage: HP and Initiative scale with the cap and the sub-tier, Move / TPR / Reach
## keep their value but never exceed the cap — and a stat that sat on the Core cap sits on the
## cap of the new stage (so a Berserker's TPR 2 becomes TPR 3 at Soul Tier).
static func at_stage(core: Dictionary, stage: Stage.Type, sub_tier: Stage.SubTier = Stage.SubTier.HIGH) -> Dictionary:
	var cap := Stage.caps(stage)
	var core_cap := Stage.caps(Stage.Type.CORE_FORMATION)
	var fill: float = SUB_TIER_FILL[sub_tier]
	var out := {}
	out["hp"] = clampi(roundi(float(core["hp"]) * float(cap["hp"]) / float(core_cap["hp"]) * fill), 1, int(cap["hp"]))
	out["initiative"] = clampf(snappedf(float(core["initiative"]) * float(cap["initiative"]) / float(core_cap["initiative"]) * fill, 0.1),
		0.1, float(cap["initiative"]))
	for k in ["move", "tpr", "reach"]:
		var value := int(core[k])
		if value >= int(core_cap[k]):
			out[k] = int(cap[k])
		else:
			out[k] = clampi(value, 1, int(cap[k]))
	return out
