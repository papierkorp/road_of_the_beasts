class_name SkillGen
extends RefCounted
## The skill card (gdd_skills §2) as code. A skill only delivers: it costs, it has a place, it may
## strike, move its user or act on its user, and it creates ground, a zone or a prop. What those
## do and when is written once, in the ground, zone and prop definitions. No Surges, no traps.
##   card      the parts of any skill definition as text (overview, skill builder)
##   build     a skill from chosen parts (the in-game skill builder, game/skill_builder.gd)
##   draw      a random legal skill for `sim.gd --variant genskills=N`; its parts are kept as meta
##             "parts", so a run reports win rates per part
## A built or drawn skill is content only once it is saved under res://data/skills; none has a price.

const SHAPES := {
	"one": [Vector2i(0, 0)],
	"line2": [Vector2i(0, 0), Vector2i(0, 1)],
	"line3": [Vector2i(0, -1), Vector2i(0, 0), Vector2i(0, 1)],
	"block": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)],
	"angle": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1)],
	"cross": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)],
}
const GROUNDS: Array[StringName] = [&"lava", &"thornbed", &"blight", &"snare", &"mossbed"]
const ZONES: Array[StringName] = [&"gale", &"void_pull", &"mire", &"bog", &"tailwind", &"slowing"]
const WHEN: Array[String] = ["strike", "ground", "zone", "move"]


static func _pick(rng: RandomNumberGenerator, list: Array) -> Variant:
	return list[rng.randi_range(0, list.size() - 1)]


## One random legal skill: a Strike, a movement, or a skill that creates ground, a zone or a prop.
static func draw_named(content: BattleContent, rng: RandomNumberGenerator, index: int) -> BattleSkillDef:
	var s := draw(content, rng, index)
	s.content_status = ContentStatus.EXPERIMENT
	return s


static func draw(content: BattleContent, rng: RandomNumberGenerator, index: int) -> BattleSkillDef:
	var s := BattleSkillDef.new()
	var parts: Array[String] = []
	var when: String = WHEN[index % WHEN.size()]                 # every kind equally often
	s.id = StringName("gen_%02d_%s" % [index, when])
	s.display_name = "Gen %d %s" % [index, when]
	s.content_status = ContentStatus.SIMULATION
	s.kind = when
	parts.append("kind=%s" % when)
	var stays := "none"
	match when:
		"strike":
			s.strike_shape = _pick(rng, ["jab", "jab", "thrust", "arc"])
			s.strike_damage = _pick(rng, [0, 2, 2])
			s.ap_cost = 2 if s.strike_shape == "jab" else 3
			parts.append("strike=%s" % s.strike_shape)
			parts.append("damage=%d" % s.strike_damage)
			stays = _pick(rng, ["none", "none", "ground"])
		"ground":
			var shape2: String = _pick(rng, SHAPES.keys())
			var fp2: Array[Vector2i] = []
			fp2.assign(SHAPES[shape2])
			s.footprint = fp2
			s.ap_cost = _pick(rng, [1, 2])
			parts.append("shape=%s" % shape2)
			stays = _pick(rng, ["ground", "ground", "prop"])
		"zone":
			var shape3: String = _pick(rng, ["one", "line2", "line3", "block", "angle"])
			var fp3: Array[Vector2i] = []
			fp3.assign(SHAPES[shape3])
			s.footprint = fp3
			s.ap_cost = _pick(rng, [1, 2])
			var zid: StringName = _pick(rng, ZONES)
			s.zone = content.zone(zid)
			s.duration = 2
			parts.append("shape=%s" % shape3)
			parts.append("stays=zone:%s" % zid)
		"move":
			s.move_path = _pick(rng, ["walk", "line", "free"])
			if s.move_path != "walk":
				s.blocked_by_objects = false
				s.blocked_by_monsters = false
				s.blocked_by_surges = false
				s.ground_costs = false
			s.ap_cost = 1 if s.move_path == "walk" else 2
			s.impact_push = _pick(rng, ["none", "none", "ahead", "ring"]) if s.move_path == "line" else "none"
			parts.append("path=%s" % s.move_path)
			parts.append("impact=%s" % s.impact_push)
			stays = _pick(rng, ["none", "none", "ground"])
	if stays == "ground":
		var g: StringName = _pick(rng, GROUNDS)
		s.board_ops.append(BoardOp.make(BoardOp.GROUND, g))
		parts.append("stays=ground:%s" % g)
	elif stays == "zone":
		var z: StringName = _pick(rng, ZONES)
		var op := BoardOp.new()
		op.op = BoardOp.CREATE_ZONE
		op.zone = z
		s.board_ops.append(op)
		parts.append("stays=zone:%s" % z)
	elif stays == "prop":
		var pr: StringName = _pick(rng, [&"bamboo_stand", &"bronze_gong"])
		s.board_ops.append(BoardOp.make(BoardOp.CREATE_PROP, pr))
		s.footprint = [Vector2i(0, 0)] as Array[Vector2i]
		parts.append("stays=prop:%s" % pr)
	elif when != "zone":
		parts.append("stays=none")
	parts.append("ap=%d" % s.ap_cost)
	s.description = " · ".join(parts)
	s.set_meta("parts", parts)
	return s


const ANCHORS := {"reach": "within Reach", "adjacent": "next to the caster", "trail": "line from the caster", "caster_ring": "ring around the caster"}
const PATHS := {"walk": "walks", "line": "straight line", "free": "any path", "teleport": "any free square"}
const SELF_EFFECTS := {"quicken": "initiative +1", "haste": "Movement +1", "extend": "Reach +1", "vigor": "AP +1 (experiment)", "tempo": "one more turn (experiment)"}
const NO := "—"


## The parts of a skill as text: {cost, where, strike, move, self, ground, zone, prop}. "—" = no.
## Retired kinds (Surge, trap) show their hit under "strike" with their timing.
static func card(c: BattleContent, s: BattleSkillDef) -> Dictionary:
	var out := {"cost": NO, "where": "self", "strike": NO, "move": NO, "self": NO, "ground": NO, "zone": NO, "prop": NO}
	if s.is_active():
		out["cost"] = "%d AP" % s.cost()
		if s.repetition == "once_per_round":
			out["cost"] += " · 1/round"
		elif s.repetition == "once_per_battle":
			out["cost"] += " · 1/battle"
	var grounds: PackedStringArray = []
	var zones: PackedStringArray = []
	var props: PackedStringArray = []
	match s.kind:
		BattleSkillDef.STRIKE:
			out["where"] = "neighbour · %s" % s.strike_shape
			out["strike"] = ("%d dmg, push 1" % s.strike_damage) if s.strike_damage > 0 else "push 1"
		BattleSkillDef.SURGE, BattleSkillDef.TRAP:
			out["where"] = "%s · %d sq" % [ANCHORS.get(s.anchor_mode, s.anchor_mode), s.footprint.size()]
			out["strike"] = "%d dmg %s (retired kind)" % [s.surge_damage, "after time" if s.kind == BattleSkillDef.SURGE else "on entering"]
		BattleSkillDef.ZONE, BattleSkillDef.GROUND:
			out["where"] = "%s · %d sq" % [ANCHORS.get(s.anchor_mode, s.anchor_mode), maxi(1, s.footprint.size())]
			if s.kind == BattleSkillDef.ZONE and s.zone != null:
				zones.append("%s · %d rd" % [s.zone.display_name, s.duration])
		BattleSkillDef.MOVE:
			out["where"] = "path"
			var dist := "Movement" if s.fixed_distance <= 0 else str(s.fixed_distance)
			if s.fixed_distance <= 0 and s.distance_mod != 0:
				dist += " %+d" % s.distance_mod
			var move: PackedStringArray = ["%s · %s" % [PATHS.get(s.move_path, s.move_path), dist]]
			if not s.blocked_by_objects or not s.blocked_by_monsters:
				move.append("over props and monsters")
			if s.impact_push == "ahead":
				move.append("pushes the monster ahead")
			elif s.impact_push == "ring":
				move.append("pushes all neighbours on landing")
			out["move"] = ", ".join(move)
		BattleSkillDef.BUFF:
			var fx: PackedStringArray = []
			for e in s.buff_effects:
				fx.append("%s · %d rd" % [SELF_EFFECTS.get(e.tag, "%s %d" % [e.tag, e.value_at(1)]), s.duration])
			out["self"] = ", ".join(fx)
		BattleSkillDef.PASSIVE:
			out["self"] = "always: %s" % s.description
	for op in s.board_ops:
		match op.op:
			BoardOp.GROUND:
				var g := c.ground(op.ground)
				grounds.append(g.display_name if g != null else String(op.ground))
			BoardOp.CREATE_PROP:
				var pd := c.prop(op.prop)
				props.append(pd.display_name if pd != null else String(op.prop))
			BoardOp.CREATE_ZONE:
				var z := c.zone(op.zone)
				zones.append("%s · %d rd" % [z.display_name if z != null else String(op.zone), op.zone_rounds])
			BoardOp.RAISE_MOUNTAIN:
				grounds.append("Mountain (removed)")
	if not grounds.is_empty():
		out["ground"] = ", ".join(grounds)
	if not zones.is_empty():
		out["zone"] = ", ".join(zones)
	if not props.is_empty():
		out["prop"] = ", ".join(props)
	return out


## One line for a skill: its card without the empty parts.
static func line(c: BattleContent, s: BattleSkillDef) -> String:
	var parts := card(c, s)
	var out: PackedStringArray = [parts["cost"], parts["where"]]
	for key: String in ["strike", "move", "self"]:
		if parts[key] != NO:
			out.append("%s: %s" % [key, parts[key]])
	for key: String in ["ground", "zone", "prop"]:
		if parts[key] != NO:
			out.append("creates %s: %s" % [key, parts[key]])
	return " · ".join(out)


## A skill from chosen parts. `spec`: name, ap, use (repeatable | once_per_round | once_per_battle),
## strike ("" | jab | thrust | arc) with damage (0–2), path ("" | walk | line | free) with impact
## (none | ahead | ring), self ("" | quicken | haste | extend | vigor | tempo | immovable), shape (key
## of SHAPES), ground / zone / prop (an id or ""). The kind follows from the parts: a Strike, else a
## movement, else an effect on the user, else a skill that only creates (a zone alone is a zone
## skill, so that a push zone gets its direction).
static func build(c: BattleContent, spec: Dictionary) -> BattleSkillDef:
	var s := BattleSkillDef.new()
	var label := String(spec.get("name", "New Skill")).strip_edges()
	if label == "":
		label = "New Skill"
	s.display_name = label
	s.id = StringName(label.to_snake_case().replace(" ", "_").validate_filename())
	s.content_status = ContentStatus.EXPERIMENT
	s.status = "built in the skill builder (gdd_skills §2 skill card); experiment, not priced"
	s.ap_cost = clampi(int(spec.get("ap", 1)), 1, 5)
	s.repetition = String(spec.get("use", "repeatable"))
	var fp: Array[Vector2i] = []
	fp.assign(SHAPES.get(String(spec.get("shape", "one")), SHAPES["one"]))
	var ground := String(spec.get("ground", ""))
	var zone := String(spec.get("zone", ""))
	var prop := String(spec.get("prop", ""))
	var strike := String(spec.get("strike", ""))
	var path := String(spec.get("path", ""))
	var own := String(spec.get("self", ""))
	if strike != "":
		s.kind = BattleSkillDef.STRIKE
		s.strike_shape = strike
		s.strike_damage = clampi(int(spec.get("damage", 2)), 0, 2)
		prop = ""                                 # a struck square holds a monster: no prop there
	elif path != "":
		s.kind = BattleSkillDef.MOVE
		s.move_path = path
		if path != "walk":
			s.blocked_by_objects = false
			s.blocked_by_monsters = false
			s.blocked_by_surges = false
			s.ground_costs = false
		s.impact_push = String(spec.get("impact", "none")) if path == "line" else "none"
		prop = ""
	elif own == "immovable":
		s.kind = BattleSkillDef.PASSIVE
		s.immovable = true
		s.description = "Ignores push and pull."
		return s
	elif own != "":
		s.kind = BattleSkillDef.BUFF
		var fx := FieldEffect.new()
		fx.tag = own
		s.buff_effects.append(fx)
		s.duration = 2
		s.description = line(c, s)
		return s
	elif zone != "" and ground == "" and prop == "":
		s.kind = BattleSkillDef.ZONE
		s.footprint = fp
		s.zone = c.zone(StringName(zone))
		s.duration = 2
		zone = ""
	else:
		s.kind = BattleSkillDef.GROUND
		s.footprint = [Vector2i(0, 0)] as Array[Vector2i] if prop != "" else fp
		if ground == "" and zone == "" and prop == "":
			ground = "thornbed"                   # a skill has to do something
	if ground != "":
		s.board_ops.append(BoardOp.make(BoardOp.GROUND, StringName(ground)))
	if zone != "":
		var op := BoardOp.new()
		op.op = BoardOp.CREATE_ZONE
		op.zone = StringName(zone)
		s.board_ops.append(op)
	if prop != "":
		s.board_ops.append(BoardOp.make(BoardOp.CREATE_PROP, StringName(prop)))
	s.description = line(c, s)
	return s


## Writes a skill to res://data/skills/<id>.tres and registers it in the content: "" or the problem.
static func save(c: BattleContent, s: BattleSkillDef) -> String:
	if String(s.id) == "":
		return "the skill needs a name"
	var path := "%s/skills/%s.tres" % [BattleContent.ROOT, s.id]
	var err := ResourceSaver.save(s, path)
	if err != OK:
		return "could not write %s (error %d)" % [path, err]
	s.take_over_path(path)
	c.skills[s.id] = s
	return ""


## Puts a saved skill into a kit slot of a monster and writes the monster file: "" or the problem.
static func assign(c: BattleContent, s: BattleSkillDef, monster_id: StringName, slot: int) -> String:
	var m := c.monster(monster_id)
	if m == null:
		return "unknown monster %s" % monster_id
	if slot < 0 or slot >= 4:
		return "a kit has four slots"
	while m.skills.size() <= slot:
		m.skills.append(s)
	m.skills[slot] = s
	var path := "%s/monsters/%s.tres" % [BattleContent.ROOT, monster_id]
	var err := ResourceSaver.save(m, path)
	return "" if err == OK else "could not write %s (error %d)" % [path, err]
