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

@export var id: StringName
@export var display_name: String
@export_enum("swap_places", "urgent_order", "second_wind", "life_thread", "beast_swap", "spirit_shield", "domain_glimpse")
var effect: String = SWAP_PLACES
@export_multiline var description: String = ""
