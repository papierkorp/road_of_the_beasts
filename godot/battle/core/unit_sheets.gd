class_name UnitSheets
extends RefCounted
## Adapter: resolves an individual of the shared (overworld) monster model into the finished
## unit sheet the battle reads (gdd_overworld §8 battle request). The battle core itself never
## sees a MonsterInstance.
##
## Mapping (the overworld still rolls individuals with the pre-revision stat model):
##   - kit: the species' kit from its MonsterDef (test data, T10–T12)
##   - reference individuals (no rolled spread): the species' reference sheet
##   - rolled individuals: their own HP / Initiative / Movement / TPR; AP = 2 (the GDD base
##     value, the overworld has no AP stat); Reach raised to the GDD minimum of 2
##   - Winged individuals at Soul Tier or above are on the air layer (gdd_battle §4.3).
## Slot development (gdd_skills §6) is not built; the legacy skill evolution was removed.

const BASE_AP := 2
const MIN_REACH := 2


static func from_instance(inst: MonsterInstance, _content: BattleContent = null) -> UnitSheet:
	var def := inst.species()
	var s := UnitSheet.new()
	s.species_id = inst.species_id
	s.display_name = def.display_name
	s.kin = def.kin
	s.look = def
	var is_reference := inst.core.is_empty() and inst.shape == StatShape.Id.NONE
	if is_reference:
		s.hp = def.hp
		s.initiative = def.initiative
		s.movement = def.move
		s.tpr = def.tpr
		s.reach = def.reach
		s.ap = def.ap
		s.current_hp = -1 if inst.current_hp >= inst.max_hp() else clampi(inst.current_hp, 1, def.hp)
	else:
		s.hp = clampi(int(inst.stats["hp"]), 1, 10)
		s.initiative = clampf(float(inst.stats["initiative"]), 0.1, 10.0)
		s.movement = maxi(1, int(inst.stats["move"]))
		s.tpr = clampi(int(inst.stats["tpr"]), 1, 3)
		s.reach = clampi(int(inst.stats["reach"]), MIN_REACH, 4)
		s.ap = BASE_AP
		s.current_hp = clampi(inst.current_hp, 1, s.hp)
		s.notes.append("AP %d (base)" % BASE_AP)
		if int(inst.stats["reach"]) < MIN_REACH:
			s.notes.append("Reach raised to %d" % MIN_REACH)
		s.airborne = def.kin == MonsterDef.Kin.WINGED and int(inst.stage) >= int(Stage.Type.SOUL)
	if def.skills.is_empty():
		s.notes.append("no kit: Step only")
		return s
	s.skills = def.skills.duplicate()
	return s
