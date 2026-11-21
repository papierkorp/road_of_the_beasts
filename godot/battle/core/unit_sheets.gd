class_name UnitSheets
extends RefCounted
## Adapter: resolves an individual of the shared (overworld) monster model into the finished
## unit sheet the battle reads (gdd_overworld §8 battle request). The battle core itself never
## sees a MonsterInstance.
##
## Mapping (the overworld still rolls individuals with the pre-revision stat model):
##   - kit: the species' kit from its MonsterDef (test data, T10–T12)
##   - reference individuals (no rolled spread): the species' reference sheet
##   - rolled individuals: their own HP / Pace / Movement / TPR; AP = 2 (the GDD base
##     value, the overworld has no AP stat); Reach raised to the GDD minimum of 2
##   - Winged individuals at Nascent Soul or above are on the air layer (gdd_battle §4.3).
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
		s.pace = def.pace
		s.movement = def.move
		s.tpr = def.tpr
		s.reach = def.reach
		s.ap = def.ap
		s.current_hp = -1 if inst.current_hp >= inst.max_hp() else clampi(inst.current_hp, 1, def.hp)
	elif inst.uses_points():                     # the points model of the hub game: every stat is bought
		s.hp = clampi(int(inst.stats["hp"]), 1, 10)
		s.pace = clampf(float(inst.stats["pace"]), 0.1, 10.0)
		s.movement = maxi(1, int(inst.stats["move"]))
		s.tpr = clampi(int(inst.stats["tpr"]), 1, 3)
		s.reach = maxi(1, int(inst.stats["reach"]))
		s.ap = clampi(int(inst.stats["ap"]), 1, 5)
		s.current_hp = clampi(inst.current_hp, 1, s.hp)
	else:
		s.hp = clampi(int(inst.stats["hp"]), 1, 10)
		s.pace = clampf(float(inst.stats["pace"]), 0.1, 10.0)
		s.movement = maxi(1, int(inst.stats["move"]))
		s.tpr = clampi(int(inst.stats["tpr"]), 1, 3)
		s.reach = clampi(int(inst.stats["reach"]), MIN_REACH, 4)
		s.ap = BASE_AP
		s.current_hp = clampi(inst.current_hp, 1, s.hp)
		s.notes.append("AP %d (base)" % BASE_AP)
		if int(inst.stats["reach"]) < MIN_REACH:
			s.notes.append("Reach raised to %d" % MIN_REACH)
		# no air layer since the reshape of 2026-11-13: Winged monsters stand on the ground
	if inst.uses_points():                       # the hub game: the trait of its Kin and its gifts act without a slot
		var kin := KinDef.of(def.kin)
		if kin != null:
			s.innate = kin.passives(inst.gifts)
		var worn: Dictionary = inst.armour_passive.get("flags", {})
		if not worn.is_empty():                    # the passive of the armour it wears
			s.innate.append(KinDef.make_passive(&"armour", String(inst.armour_passive.get("name", "Armour")), String(inst.armour_passive.get("text", "")), worn))
	var kit := inst.kit_skills()
	if kit.is_empty():
		s.notes.append("no kit: Step only")
		return s
	s.skills = kit
	return s


## Gives the sheet its own arrangement of free shapes (BattleRequest.player_shapes): `by_slot` maps a kit
## slot to the squares of that skill, as offsets from the anchor. The sheet then holds its own copy of
## the skill, the species file is untouched. An illegal arrangement leaves the default.
static func arrange(sheet: UnitSheet, by_slot: Dictionary) -> void:
	for key in by_slot:
		var slot := int(key)
		if slot < 0 or slot >= sheet.skills.size():
			continue
		var s := sheet.skills[slot]
		if s == null or not s.is_placed() or not s.is_free_shape():
			continue
		var cells: Array[Vector2i] = []
		cells.assign(by_slot[key])
		if BattleShapes.arrangement_error(cells, s.footprint.size()) != "":
			continue
		var own: BattleSkillDef = s.duplicate()
		own.footprint = cells
		sheet.skills[slot] = own
