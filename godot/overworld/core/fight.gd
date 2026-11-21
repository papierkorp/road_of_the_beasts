class_name Fight
extends RefCounted
## One battle the hub asks for, as plain data: where it comes from, the battleground, both teams and what the tamer
## brings. `game/` turns it into a BattleRequest; the overworld never touches the battle (docs/architecture.md §1).

const WILD := &"wild"
const DUNGEON := &"dungeon"
const VOID := &"void"

var place: StringName = WILD
var title := ""
## A battleground of res://data/maps, or "" when `own_map` holds the player's own battleground (the void).
var map_id: StringName = &""
var own_map := {}
var enemies: Array[MonsterInstance] = []
## A wild side has no tamer: its monsters die at 0 HP and can be caught on Seal Ground.
var wild := true
## How many monsters the player may field (the free squares of the start area).
var max_team := 1
var team: Array[MonsterInstance] = []
var tamer: Array[StringName] = []
## Loadout entries that come from an item: tamer skill id -> the weapon or pill it stands for.
var tamer_items := {}
## Uses per battle of a loadout entry that has more than one: tamer skill id -> uses.
var tamer_uses := {}
var roll_seed := 0
## What the place needs to read the result: the index of the encounter, the node of the dungeon, the depth.
var ref := {}
## The stage of the place (XP and loot).
var stage := 0
## What a win gives, as text for the list (the place decides the loot itself).
var loot_text := ""


func enemy_text() -> String:
	var parts: PackedStringArray = []
	for e in enemies:
		parts.append(e.title())
	return ", ".join(parts)
