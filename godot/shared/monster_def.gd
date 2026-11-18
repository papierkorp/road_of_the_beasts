class_name MonsterDef
extends Resource
## A species with its kit, in one file: res://data/monsters/<id>.tres (gdd_monsters §1.1, §4.1).
## Everything here is test data: no kit or learn list is approved (temp_todo T10–T12).
## The stats are the Core Formation High reference individual of gdd_monsters §4.1.

enum Kin { BEAST, WINGED, SCALED, SWARM, SPIRIT, ANCIENT }

@export var id: StringName
@export var display_name: String
## ContentStatus: a test-only or simulation-only monster is never offered by the game.
@export_enum("approved", "draft", "experiment", "test", "simulation", "archived") var content_status: String = ContentStatus.DRAFT
@export var kin: Kin = Kin.BEAST
## Look and overworld material family only; no battle rule reads it (aspects are removed, T01).
@export var aspect: Aspect.Type = Aspect.Type.FORCE

@export_group("Reference individual (gdd_monsters §4.1)")
## The stat shape (frame, gdd_monsters §2.2) the reference stats below were built with: an
## authoring label from the §4.1 table, 0 = not stated. The values follow StatShape.Id; no
## rule reads it (a shape belongs to the individual, not to the species).
@export_enum("None", "Glass cannon", "Anvil", "Skirmisher", "Berserker", "Balanced", "Fragile") var reference_shape: int = 0
@export var hp: int = 5
@export var pace: float = 1.2
@export var move: int = 2
@export var tpr: int = 1
@export var reach: int = 2
@export var ap: int = 2

@export_group("Kit")
## Up to 6 slots, active or passive, at least one active (user decision 2026-11-14; gdd_skills §1: the multiplayer mode plays with all six open). Step needs no slot.
@export var skills: Array[BattleSkillDef] = []

@export_multiline var blurb: String = ""
@export_multiline var notes: String = ""


static func kin_name(k: Kin) -> String:
	return Kin.keys()[k].capitalize()


## "Skill · Skill · Skill" for datasheets.
func kit_text() -> String:
	var names: PackedStringArray = []
	for s in skills:
		if s != null:
			names.append(s.display_name)
	return " · ".join(names)


## Stat prices of gdd_monsters §2.2 (user decision 2026-11-15; untested starting values): every stat starts at 1
## (Pace 1.0) and each step above costs points. Display only: nothing in the game checks a budget.
const PRICE_PACE_POINT := 1          # per 0.1 Pace
const PRICE_STAMINA := 2
const PRICE_HP := 5
const PRICE_REACH := 5
const PRICE_AP_STEPS: Array[int] = [5, 10, 15, 20]      # the steps to AP 2, 3, 4, 5
const MULTIPLAYER_POINTS := 60       # what every monster of the multiplayer mode may cost


## The lines of the calculation, [label, points] each, for the given stat values. A second turn costs 10 + 5 per AP
## of the monster, a third twice that.
static func point_lines(p_hp: int, p_pace: float, p_stamina: int, p_reach: int, p_tpr: int, p_ap: int) -> Array:
	var ap_cost := 0
	for i in clampi(p_ap - 1, 0, PRICE_AP_STEPS.size()):
		ap_cost += PRICE_AP_STEPS[i]
	var turn := 10 + 5 * p_ap
	var turns_cost := 0 if p_tpr <= 1 else (turn if p_tpr == 2 else turn * 3)
	return [["HP %d" % p_hp, maxi(0, p_hp - 1) * PRICE_HP], ["Pace %s" % String.num(p_pace, 1), maxi(0, roundi((p_pace - 1.0) * 10.0)) * PRICE_PACE_POINT],
		["Stamina %d" % p_stamina, maxi(0, p_stamina - 1) * PRICE_STAMINA], ["Reach %d" % p_reach, maxi(0, p_reach - 1) * PRICE_REACH],
		["AP %d" % p_ap, ap_cost], ["Turns %d" % p_tpr, turns_cost]]


static func points_of(p_hp: int, p_pace: float, p_stamina: int, p_reach: int, p_tpr: int, p_ap: int) -> int:
	var sum := 0
	for line: Array in point_lines(p_hp, p_pace, p_stamina, p_reach, p_tpr, p_ap):
		sum += int(line[1])
	return sum


## What this monster's stats cost.
func stat_points() -> int:
	return points_of(hp, pace, move, reach, tpr, ap)
