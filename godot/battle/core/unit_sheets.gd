class_name UnitSheets
extends RefCounted
## Adapter: resolves an individual of the shared (overworld) monster model into the finished
## unit sheet the battle reads (gdd_overworld §8 battle request). The battle core itself never
## sees a MonsterInstance.
##
## The overworld still runs the pre-revision monster model. Decided mapping (user, 2026-11-11,
## "strict to the GDD"):
##   - kit: the species' TEST kit from res://data/battle/kits (no approved kits exist, T10–T12)
##   - reference individuals (no rolled spread): the Core Formation High sheet of
##     gdd_monsters §4.1 stored with the kit
##   - rolled individuals: their own HP / Initiative / Movement / TPR; AP = 2 (the GDD base
##     value, the overworld has no AP stat); Reach raised to the GDD minimum of 2
##   - evolution picks act only where the GDD allows them: Shape / Size inside the caps and
##     zone duration +1. Twists that change damage, range, delay or residue duration, cast
##     range +1 and the aspect are not applied. Everything dropped is listed in `notes`.
##   - Winged individuals at Soul Tier or above are on the air layer (gdd_battle §4.3).

const BASE_AP := 2
const MIN_REACH := 2
const MAX_FOOTPRINT := 4


static func from_instance(inst: MonsterInstance, content: BattleContent = null) -> UnitSheet:
	var c := content if content != null else BattleContent.shared()
	var def := inst.species()
	var kit := c.kit(inst.species_id)
	var s := UnitSheet.new()
	s.species_id = inst.species_id
	s.display_name = def.display_name
	s.kin = def.kin
	s.look = def
	var is_reference := inst.core.is_empty() and inst.shape == StatShape.Id.NONE
	if is_reference and kit != null:
		s.hp = kit.hp
		s.initiative = kit.initiative
		s.movement = kit.movement
		s.tpr = kit.tpr
		s.reach = kit.reach
		s.ap = kit.ap
		s.current_hp = -1 if inst.current_hp >= inst.max_hp() else clampi(inst.current_hp, 1, kit.hp)
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
	if kit == null:
		s.notes.append("no battle kit: Step only")
		return s
	s.skills = kit.skills.duplicate()
	_apply_evolutions(s, kit, inst, c)
	return s


static func _apply_evolutions(s: UnitSheet, kit: BattleKitDef, inst: MonsterInstance, c: BattleContent) -> void:
	for pick: Dictionary in inst.evolutions:
		var which := StringName(pick["skill"])
		var slot := kit.surge_slot if which == Evolution.SURGE else kit.utility_slot
		var arg := String(pick["arg"])
		var family := StringName(pick["family"])
		if slot < 0 or slot >= s.skills.size():
			s.notes.append("pick %s %s: no slot" % [family, arg])
			continue
		match family:
			&"swap":
				var other := c.skill(StringName(arg))
				if other == null or other.kind == BattleSkillDef.SURGE or not other.is_active():
					s.notes.append("swap %s: no battle record" % arg)
				else:
					s.skills[slot] = other
			&"shape":
				var note := _reshape(s, slot, arg)
				if note != "":
					s.notes.append(note)
			&"value":
				var cur: BattleSkillDef = s.skills[slot]
				if arg == "duration" and cur.kind == BattleSkillDef.ZONE:
					var copy: BattleSkillDef = cur.duplicate()
					copy.duration = cur.duration + 1
					s.skills[slot] = copy
				else:
					s.notes.append("pick value %s: not applied" % arg)
			_:
				s.notes.append("pick %s %s: not applied" % [family, arg])


## Shape / Size pick "<family>:<orientation>[:w]" of the legacy model as an explicit footprint.
static func _reshape(s: UnitSheet, slot: int, arg: String) -> String:
	var cur: BattleSkillDef = s.skills[slot]
	var parts := arg.split(":")
	var family := StringName(parts[0])
	if not cur.is_placed() or cur.anchor_mode == "caster_ring" or not Shapes.BASE.has(family):
		return "pick shape %s: not applied" % arg
	var cells: Array = Shapes.BASE[family]
	if cells.size() > MAX_FOOTPRINT:
		return "pick shape %s: over %d cells" % [arg, MAX_FOOTPRINT]
	var offsets: Array[Vector2i] = []
	if cur.anchor_mode == "trail":
		for i in cells.size():
			offsets.append(Vector2i(i, 0))    # a trail stays a straight line from the caster
	else:
		var orients := Shapes.orientations([family])
		var o: Dictionary = orients[clampi(int(parts[1]) if parts.size() > 1 else 0, 0, orients.size() - 1)]
		for cell: Vector2i in o["cells"]:
			offsets.append(cell - o["anchor"])
	var copy: BattleSkillDef = cur.duplicate()
	copy.footprint = offsets
	s.skills[slot] = copy
	return ""


## Footprint offsets of a legacy shape family and orientation (anchor = its centre-most cell).
static func legacy_footprint(family: StringName, orientation: int) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	var orients := Shapes.orientations([family])
	var o: Dictionary = orients[clampi(orientation, 0, orients.size() - 1)]
	for cell: Vector2i in o["cells"]:
		out.append(cell - o["anchor"])
	return out
