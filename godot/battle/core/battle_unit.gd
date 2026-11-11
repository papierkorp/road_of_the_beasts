class_name BattleUnit
extends RefCounted
## Runtime state of one monster in a battle. The sheet is read-only; everything that changes
## during the encounter lives here.

var id: StringName
var sheet: UnitSheet
## 0 = player, 1 = enemy.
var side: int = 0
## Loadout / start slot within the side (ties in the queue, gdd_battle §2.2).
var slot: int = 0
## Index in the request's team (bench units: -1); never changes, unlike `slot`.
var team_index: int = -1
## Origin square; a 2x2 body covers pos .. pos + (1, 1).
var pos := Vector2i.ZERO
var size: int = 1
var layer: int = Board.GROUND
var hp: int = 1
var max_hp: int = 1
## false: on the bench (Beast Swap) and not part of the fight right now.
var on_field: bool = true
var defeated: bool = false
## Timed unit effects: [{key, tag, value, ends_round}] (gdd_battle §3.1). The same key only
## refreshes; different keys add.
var effects: Array[Dictionary] = []
## One Nullify per monster, no stacking (gdd_battle §6.1).
var nullify: bool = false
## Survive effect of Life Thread.
var life_thread: bool = false
## Usage bookkeeping per equipped skill instance: slot -> round of the last use / used at all.
var used_round := {}
var used_battle := {}
var kills: int = 0


func _init(p_id: StringName = &"", p_sheet: UnitSheet = null, p_side := 0, p_slot := 0, p_pos := Vector2i.ZERO) -> void:
	id = p_id
	sheet = p_sheet
	side = p_side
	slot = p_slot
	pos = p_pos
	if p_sheet != null:
		size = p_sheet.size
		layer = Board.AIR if p_sheet.airborne else Board.GROUND
		max_hp = p_sheet.hp
		hp = p_sheet.hp if p_sheet.current_hp < 0 else clampi(p_sheet.current_hp, 1, p_sheet.hp)


func is_alive() -> bool:
	return on_field and not defeated


func display_name() -> String:
	return sheet.display_name


func kin() -> int:
	return sheet.kin


## Squares covered when the origin is `origin`, in row order.
func cells_at(origin: Vector2i) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for dy in size:
		for dx in size:
			out.append(origin + Vector2i(dx, dy))
	return out


func cells() -> Array[Vector2i]:
	return cells_at(pos)


func covers(p: Vector2i) -> bool:
	return p.x >= pos.x and p.y >= pos.y and p.x < pos.x + size and p.y < pos.y + size


## Distance between bodies is measured from the nearest covered square (gdd_battle §4.3).
func manhattan_to(p: Vector2i) -> int:
	var dx := maxi(0, maxi(pos.x - p.x, p.x - (pos.x + size - 1)))
	var dy := maxi(0, maxi(pos.y - p.y, p.y - (pos.y + size - 1)))
	return dx + dy


func chebyshev_to(p: Vector2i) -> int:
	var dx := maxi(0, maxi(pos.x - p.x, p.x - (pos.x + size - 1)))
	var dy := maxi(0, maxi(pos.y - p.y, p.y - (pos.y + size - 1)))
	return maxi(dx, dy)


## True if `p` is orthogonally adjacent to at least one covered square (and not covered).
func orth_adjacent_to(p: Vector2i) -> bool:
	return manhattan_to(p) == 1


func passives() -> Array[BattleSkillDef]:
	return sheet.passives()


func clone() -> BattleUnit:
	var u := BattleUnit.new()
	u.id = id
	u.sheet = sheet
	u.side = side
	u.slot = slot
	u.team_index = team_index
	u.pos = pos
	u.size = size
	u.layer = layer
	u.hp = hp
	u.max_hp = max_hp
	u.on_field = on_field
	u.defeated = defeated
	u.effects = effects.duplicate(true)
	u.nullify = nullify
	u.life_thread = life_thread
	u.used_round = used_round.duplicate()
	u.used_battle = used_battle.duplicate()
	u.kills = kills
	return u
