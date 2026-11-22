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

@export var id: StringName
@export var display_name: String
@export_enum("swap_places", "urgent_order", "second_wind", "life_thread", "beast_swap", "spirit_shield", "domain_glimpse", "seal", "lay", "boon")
var effect: String = SWAP_PLACES
@export_multiline var description: String = ""
## Seal only: the catch chance in percent at 1 HP (docs/battle_ingame.md §7, working value): 50 without upgrades.
@export var seal_base: int = 50
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
