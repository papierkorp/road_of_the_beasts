class_name TamerSkillDef
extends Resource
## A tamer skill slotted into the battle loadout (gdd_battle §5.2, gdd_overworld §6.4).
## Once per battle, free, usable during the turn of one of the tamer's own monsters.
## Each `effect` is a unique mechanic resolved in battle/core/battle_tamer.gd.

const SWAP_PLACES := "swap_places"
const URGENT_ORDER := "urgent_order"
const SECOND_WIND := "second_wind"
const LIFE_THREAD := "life_thread"
const BEAST_SWAP := "beast_swap"
const SPIRIT_SHIELD := "spirit_shield"
const DOMAIN_GLIMPSE := "domain_glimpse"
## Seal Ground (docs/battle_ingame.md §7): catching on the board.
const SEAL := "seal"
## Lays ground or sets a prop on chosen squares (tamer skills of the Way of the Formation).
const LAY := "lay"
## A timed effect on one own monster (pills of the hub game): `boon` names it.
const BOON := "boon"
const BOON_SWIFT := "swift"          # Pace up until the end of the next round
const BOON_ANCHOR := "anchor"        # not pushed or pulled until the end of this round
## One enemy monster loses Pace points for the next round (docs/overworld.md §5.4).
const QI_SUPPRESSION := "qi_suppression"
## The options of Seal (docs/overworld.md §5.4): at most two of them, one per level above the first.
const SEAL_WIDE := "wide"
const SEAL_STRONG := "strong"
const SEAL_PATIENT := "patient"
const SEAL_DRAWING := "drawing"
const SEAL_WALLED := "walled"
const SEAL_OPTIONS: Array[String] = [SEAL_WIDE, SEAL_STRONG, SEAL_PATIENT, SEAL_DRAWING, SEAL_WALLED]
const SEAL_MAX_OPTIONS := 2
const SEAL_STRONG_BASE := 65
const SEAL_PATIENT_STEP := 5

@export var id: StringName
@export var display_name: String
@export_enum("swap_places", "urgent_order", "second_wind", "life_thread", "beast_swap", "spirit_shield", "domain_glimpse", "seal", "lay", "boon", "qi_suppression")
var effect: String = SWAP_PLACES
@export_multiline var description: String = ""
## Seal only: the catch chance in percent at 1 HP (docs/battle_ingame.md §7, working value): 50 without upgrades.
@export var seal_base: int = 50
## Seal only: points less per further HP (0 = the working value `BattleExperiment.seal_step`), the squares it lays
## (2 = two adjacent squares), whether it also pulls like a pull zone and whether it walls its squares in.
@export var seal_step: int = 0
@export var seal_squares: int = 1
@export var seal_pull: bool = false
@export var seal_walls: bool = false
## Lay only: what is laid (one of the two) and on how many squares at most; several squares form a straight line.
@export var lay_ground: StringName = &""
@export var lay_prop: StringName = &""
@export var lay_count: int = 1
## Boon only: which one and how strong.
@export_enum("swift", "anchor") var boon: String = BOON_SWIFT
@export var boon_value: int = 1
## "skill" = a tamer skill, "pill" = a pill, used up when taken.
@export_enum("skill", "pill") var source: String = "skill"


func source_text() -> String:
	return "pill · used up when taken" if source == "pill" else "tamer · 1/battle"


## A copy of a Seal skill with the options taken (docs/overworld.md §5.4); the record itself is never changed.
func with_seal_options(options: Array) -> TamerSkillDef:
	if effect != SEAL or options.is_empty():
		return self
	var out: TamerSkillDef = duplicate()
	for o in options:
		match String(o):
			SEAL_WIDE:
				out.seal_squares = 2
			SEAL_STRONG:
				out.seal_base = maxi(out.seal_base, SEAL_STRONG_BASE)
			SEAL_PATIENT:
				out.seal_step = SEAL_PATIENT_STEP
			SEAL_DRAWING:
				out.seal_pull = true
			SEAL_WALLED:
				out.seal_walls = true
	return out
