class_name MonsterInstance
extends RefCounted
## One individual monster the player owns or meets (gdd_overworld §4.3): a fixed species plus
## what makes this monster unique — stat shape, rarity, stage / sub-tier / XP, resolved stats
## and current HP. It owns no battle rules.
##
## The battle never sees an instance: `to_battle_unit()` resolves it into a finished unit sheet
## (a MonsterDef copy with this individual's stats), which is what `Monster` already consumes.
##
## Not yet modelled (later steps): evolution picks, artifacts, extra passives, 2nd utility slot.

enum Rarity { NORMAL, RARE, EPIC, LEGENDARY }

var species_id: StringName
var shape: StatShape.Id = StatShape.Id.NONE
var rarity: Rarity = Rarity.NORMAL
var stage: Stage.Type = Stage.Type.CORE_FORMATION
var sub_tier: Stage.SubTier = Stage.SubTier.HIGH
var xp := 0
## Resolved stats: hp, initiative, move, tpr, reach.
var stats := {}
## Persists between battles of an expedition (gdd_overworld §10.2).
var current_hp := 1


## The species' own numbers, unrolled: the "reference individual" of gdd_battle §6.2.
## Keeps the existing roster, tests and the draft behaving exactly as before.
static func reference(def: MonsterDef) -> MonsterInstance:
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
	m.stats = StatShape.at_stage(StatShape.roll_core(m.shape, rng), p_stage)
	m.current_hp = m.max_hp()
	return m


func max_hp() -> int:
	return int(stats["hp"])


func species() -> MonsterDef:
	return GameData.monster(species_id)


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
	return d


func to_dict() -> Dictionary:
	return {"species": String(species_id), "shape": int(shape), "rarity": int(rarity), "stage": int(stage),
		"sub_tier": int(sub_tier), "xp": xp, "stats": stats.duplicate(), "current_hp": current_hp}


static func from_dict(d: Dictionary) -> MonsterInstance:
	var m := MonsterInstance.new()
	m.species_id = StringName(d["species"])
	m.shape = int(d["shape"]) as StatShape.Id
	m.rarity = int(d["rarity"]) as Rarity
	m.stage = int(d["stage"]) as Stage.Type
	m.sub_tier = int(d["sub_tier"]) as Stage.SubTier
	m.xp = int(d["xp"])
	m.stats = (d["stats"] as Dictionary).duplicate()
	m.current_hp = int(d["current_hp"])
	return m
