class_name Stage
extends RefCounted
## Cultivation stages and sub-tiers (gdd_overworld §4.1) with the stat ceilings per stage (§4.6).
## Shared by player and monsters. The damage law of the battle is never scaled by stage.

enum Type { QI_GATHERING, FOUNDATION, CORE_FORMATION, SOUL, IMMORTAL, SOVEREIGN }
enum SubTier { LOWER, MIDDLE, HIGH }

const NAMES := {
	Type.QI_GATHERING: "Qi Gathering",
	Type.FOUNDATION: "Foundation",
	Type.CORE_FORMATION: "Core Formation",
	Type.SOUL: "Soul Tier",
	Type.IMMORTAL: "Immortal",
	Type.SOVEREIGN: "Sovereign",
}

const _SOUL_CAPS := {"hp": 10, "initiative": 10.0, "tpr": 3, "move": 4, "reach": 3}

## Hard caps per stage. Soul and everything above share the last column of the GDD table
## (they already sit on the absolute scale: HP 1-10, Init 0.1-10.0, TPR 1-3, Reach 1-3).
const CAPS := {
	Type.QI_GATHERING: {"hp": 4, "initiative": 5.0, "tpr": 1, "move": 3, "reach": 1},
	Type.FOUNDATION: {"hp": 6, "initiative": 7.0, "tpr": 2, "move": 3, "reach": 2},
	Type.CORE_FORMATION: {"hp": 8, "initiative": 9.0, "tpr": 2, "move": 4, "reach": 2},
}


static func caps(stage: Type) -> Dictionary:
	return CAPS.get(stage, _SOUL_CAPS)


static func stage_name(stage: Type) -> String:
	return NAMES[stage]


static func sub_tier_name(t: SubTier) -> String:
	return SubTier.keys()[t].capitalize()
