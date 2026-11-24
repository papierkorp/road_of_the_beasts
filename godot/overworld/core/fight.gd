class_name Fight
extends RefCounted
## One battle the hub asks for, as plain data: where it comes from, the battleground, both teams and what the Way
## brings. `game/` turns it into a BattleRequest; the overworld never touches the battle (docs/architecture.md §1).

const WILD := &"wild"
const VOID := &"void"
## The part that is Seal Ground (docs/battle_ingame.md §7): the Artificer lays it like any other part.
const SEAL_PART := "seal"

var place: StringName = WILD
var title := ""
## The battleground as plain data in the format of `MapData`: generated for this battle, or the Artificer's own
## battleground in the void.
var own_map := {}
var enemies: Array[MonsterInstance] = []
## A wild side has no tamer: its monsters die at 0 HP and can be caught on Seal Ground.
var wild := true
## How many monsters the player may field (the free squares of the start area).
var max_team := 1
var team: Array[MonsterInstance] = []
## The tamer slots: tamer skills of the Formation, or the skills of the pills the Alchemist carries.
var tamer: Array[StringName] = []
## Loadout entries that come from an item: tamer skill id -> the pill it stands for.
var tamer_items := {}
## The options of Seal the Formation bought (docs/overworld.md §5.4).
var seal_options: Array = []
## Parts the Artificer may lay before this battle (0 = none: another Way, or the void, where the board is their own),
## and those laid: "x,y" -> part id ("ground:<id>", "prop:<id>", "zone:<id>" or SEAL_PART).
var carry := 0
var parts := {}
var roll_seed := 0
## What the place needs to read the result: the battle of the wild, the depth.
var ref := {}
## The stage of the place.
var stage := 0
## What a win gives, as text for the list (the place decides the loot itself).
var loot_text := ""


## Seal Ground lies in the wild alone: nothing is caught in the void (docs/battle_ingame.md §7).
func allows_seal() -> bool:
	return place != VOID


func enemy_text() -> String:
	var names: PackedStringArray = []
	for e in enemies:
		names.append(e.title())
	return ", ".join(names)


## How many of a part are laid.
func laid(part: String) -> int:
	var n := 0
	for key in parts:
		if String(parts[key]) == part:
			n += 1
	return n
