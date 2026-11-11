class_name UnitSheet
extends RefCounted
## The finished unit sheet a battle resolves (gdd_monsters §1.2, gdd_overworld §8 request):
## resolved stats, kit, current HP and pre-battle modifiers. The battle reads nothing else
## about a monster; who built the sheet (overworld adapter, draft, test) does not matter.

var species_id: StringName
var display_name: String = ""
var kin: int = MonsterDef.Kin.BEAST
## Body size in squares per side: 1 (1x1) or 2 (2x2, Soul+).
var size: int = 1
## Permanently on the air layer (Soul+ Winged, gdd_battle §4.3).
var airborne: bool = false

var hp: int = 5
var initiative: float = 5.0
var movement: int = 2
var reach: int = 2
var tpr: int = 1
var ap: int = 2
## -1 = full HP.
var current_hp: int = -1
## Slots in order; passives occupy slots too.
var skills: Array[BattleSkillDef] = []
## Pre-battle initiative modifier for this whole battle (battle-prep pill, gdd_overworld §6.6).
var init_bonus: float = 0.0
## Look hint for the view only (never read by the rules).
var look: MonsterDef = null
## What the adapter could not carry over (shown before the battle, never a rule).
var notes: Array[String] = []


func active_skills() -> Array[BattleSkillDef]:
	var out: Array[BattleSkillDef] = []
	for s in skills:
		if s.is_active():
			out.append(s)
	return out


func passives() -> Array[BattleSkillDef]:
	var out: Array[BattleSkillDef] = []
	for s in skills:
		if not s.is_active():
			out.append(s)
	return out


## Kit and stat checks against the confirmed ranges (gdd_monsters §2.1, gdd_skills §1).
func problems() -> Array[String]:
	var out: Array[String] = []
	if hp < 1 or hp > 10:
		out.append("HP %d outside 1-10" % hp)
	if initiative < 0.1 or initiative > 10.0:
		out.append("Initiative %.1f outside 0.1-10.0" % initiative)
	if reach < 2 or reach > 4:
		out.append("Reach %d outside 2-4" % reach)
	if tpr < 1 or tpr > 3:
		out.append("TPR %d outside 1-3" % tpr)
	if ap < 2 or ap > 5:
		out.append("AP %d outside 2-5" % ap)
	if movement < 1:
		out.append("Movement %d below 1" % movement)
	if size != 1 and size != 2:
		out.append("size must be 1 or 2")
	if skills.size() > 5:
		out.append("more than 5 slots")
	if skills.size() == 5 and skills[4].is_active():
		out.append("the 5th slot is passive-only")
	for s in skills:
		if s == null:
			out.append("empty skill reference")
	return out
