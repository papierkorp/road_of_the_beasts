class_name SkillGen
extends RefCounted
## The skill card (gdd_skills §2) as code. A skill only delivers: it costs, it has a place, it may
## strike, move its user or act on its user, and it creates ground, a zone or a prop. What those
## do and when is written once, in the ground, zone and prop definitions. No Surges, no traps.
##   card      the parts of any skill definition as text (overview, skill builder)
##   build     a skill from chosen parts (the in-game skill builder, game/skill_builder.gd)
##   draw_kind a random legal skill of one kind (strike, move, zone, ground, prop) for the random kits
##             (KitDraw) and the measuring runs; its parts are kept as meta "parts", so a run reports
##             results per part. `draw` takes the kinds in turn.
## A built or drawn skill is content only once it is saved under res://data/skills; none has a price.

## Free shapes the skill builder offers by name.
const SHAPES := {
	"one": [Vector2i(0, 0)],
	"line2": [Vector2i(0, 0), Vector2i(0, 1)],
	"line3": [Vector2i(0, -1), Vector2i(0, 0), Vector2i(0, 1)],
	"block": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)],
	"angle": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1)],
	"cross": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)],
}


static func _pick(rng: RandomNumberGenerator, list: Array) -> Variant:
	return list[rng.randi_range(0, list.size() - 1)]


## The five kinds a kit template counts (KitDraw): what a skill is for.
const KINDS: Array[String] = ["strike", "move", "zone", "ground", "prop"]
## Strike shapes a draw may take: [base shape, extensions].
const STRIKE_SHAPES := [["jab", 0], ["jab", 1], ["pincer", 0], ["arc", 0], ["arc", 1], ["whirl", 0], ["cross", 0], ["storm", 0]]
## Base shapes around the user for a skill that creates: [base shape, extensions].
const AROUND_SHAPES := [["jab", 1], ["jab", 2], ["arc", 0], ["whirl", 0], ["cross", 0], ["storm", 0]]
## Free shapes by number of squares (default arrangements; the anchor (0, 0) is one of the squares).
const FREE_SHAPES := {
	1: [[Vector2i(0, 0)]],
	2: [[Vector2i(0, 0), Vector2i(0, 1)]],
	3: [[Vector2i(0, -1), Vector2i(0, 0), Vector2i(0, 1)], [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1)]],
	4: [[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)], [Vector2i(0, -1), Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2)]],
	5: [[Vector2i(0, 0), Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]],
}
## What a draw chooses from, as data: the overview's Generator table shows exactly these lists (a value that
## stands twice is drawn twice as often).
const STRIKE_DAMAGE := [0, 1, 1, 2, 2, 2]
const STRIKE_PUSH := [true, true, false]
const STRIKE_PROPS := [true, true, false]          # damages the props in its shape, as a part of its own
const LEAVES := ["none", "none", "none", "ground", "zone"]     # what a Strike or a movement leaves behind
const MOVE_PATHS := ["walk", "walk", "line", "line", "free"]
const MOVE_RANGES := [2, 3, 3, 4, 5]
const MOVE_DIAGONAL_ONE_IN := 4                    # one straight line in four may run diagonally
const MOVE_IMPACT := ["none", "none", "ahead", "ring"]         # straight lines only
const ZONE_WITH_GROUND := 0.25                     # a zone skill that also lays ground
const GROUND_WITH_ZONE := 0.3                      # a ground skill that also leaves a zone
const AROUND_CHANCE := 0.3                         # a ground skill on a base shape around the user
const FREE_SQUARES_MAX := 5
const ANCHOR_MODES := ["reach", "reach", "reach", "adjacent"]
const SELF_VALUES := [1, 1, 2]
const SELF_ROUNDS := [1, 2, 2, 3]
const PROP_COUNTS := [1, 1, 1, 2, 3]
const ZONE_ROUNDS := [1, 2, 2, 3]
const USES := ["turn", "turn", "turn", "turn", "turn", "turn", "twice", "round", "battle"]
## Timed effects on the user a generated self buff may give (the experiments on AP and turns are left out).
const SELF_TAGS: Array[String] = ["quicken", "haste", "extend", "refresh"]
const MOVE_NAMES := {"walk": "Run", "line": "Leap", "free": "Glide"}


## One random legal skill for `sim.gd --variant genskills=N` and the skill builder: the kinds in turn.
static func draw_named(content: BattleContent, rng: RandomNumberGenerator, index: int) -> BattleSkillDef:
	var s := draw(content, rng, index)
	s.content_status = ContentStatus.EXPERIMENT
	return s


static func draw(content: BattleContent, rng: RandomNumberGenerator, index: int) -> BattleSkillDef:
	return draw_kind(content, rng, KINDS[index % KINDS.size()], index)


## Zones a skill may create: [those that move a monster or wear props down, those that only change stats]. A zone that only
## changes stats is never a skill of its own (gdd_skills §2); it comes with ground, a Strike or a movement.
static func zone_ids(content: BattleContent) -> Array:
	var moving: Array[StringName] = []
	var stats: Array[StringName] = []
	for id: StringName in BattleContent.sorted_ids(content.zones):
		var z: BattleZoneDef = content.zones[id]
		if not ContentStatus.in_game(z) or z.battle == "ingame":
			continue
		if z.has_tag(FieldEffect.PUSH) or z.has_tag(FieldEffect.PULL) or z.has_tag(FieldEffect.ERODE):
			moving.append(id)
		else:
			stats.append(id)
	return [moving, stats]


## Grounds a skill may lay: hazard and blessed grounds of the game.
static func ground_ids(content: BattleContent) -> Array[StringName]:
	var out: Array[StringName] = []
	for id: StringName in BattleContent.sorted_ids(content.grounds):
		var g: GroundDef = content.grounds[id]
		if ContentStatus.in_game(g) and g.battle != "ingame" and (g.group != "neutral" or g.no_props) and not g.immutable and not GroundDef.is_reserved(id):
			out.append(id)
	return out


## Props a skill may create.
static func prop_ids(content: BattleContent) -> Array[StringName]:
	var out: Array[StringName] = []
	for id: StringName in BattleContent.sorted_ids(content.props):
		var p: PropDef = content.props[id]
		if ContentStatus.in_game(p) and p.creatable_by_skill and p.content_status != ContentStatus.EXPERIMENT:
			out.append(id)
	return out


## One random legal skill of a kind (KINDS). Its parts (SkillCalc.part_names) are kept as meta "parts",
## so a run can report results per part. `ap` > 0 fixes the AP cost; 0 draws 1–3
## whatever the skill does (a measuring run wants cost and strength independent); -1 takes the AP the
## draft price list gives it (SkillCalc), as the game switch "New skills every battle" does.
## The skill lives in memory only (status `simulation` unless the caller sets another).
static func draw_kind(content: BattleContent, rng: RandomNumberGenerator, kind: String, index: int, ap := 0) -> BattleSkillDef:
	var s := BattleSkillDef.new()
	s.id = StringName("gen_%03d_%s" % [index, kind])
	s.content_status = ContentStatus.SIMULATION
	s.status = "generated (SkillGen.draw_kind); lives in memory only"
	var zones: Array = zone_ids(content)
	var any_zone: Array[StringName] = []
	any_zone.append_array(zones[0])
	any_zone.append_array(zones[1])
	var label := ""
	var ground := &""
	var zone := &""
	match kind:
		"strike":
			s.kind = BattleSkillDef.STRIKE
			var drawn: Array = _pick(rng, STRIKE_SHAPES)
			s.shape = drawn[0]
			s.shape_extension = drawn[1]
			s.strike_damage = _pick(rng, STRIKE_DAMAGE)
			s.strike_push = _pick(rng, STRIKE_PUSH)
			s.strike_props = 1 if _pick(rng, STRIKE_PROPS) else 0
			var leaves: String = _pick(rng, LEAVES)
			if not s.strike_push and s.strike_props == 0 and leaves == "none":
				s.strike_push = true                  # a Strike does something: its damage number deals nothing to a monster
			if leaves == "ground":
				ground = _pick(rng, ground_ids(content))
			elif leaves == "zone":
				zone = _pick(rng, any_zone)
			label = BattleShapes.shape_name(s.shape_id(), s.shape_extension)       # named by what it does
			label += " Push Strike" if s.strike_push else (" Prop Strike" if s.strike_props == 1 else " Touch")
		"move":
			s.kind = BattleSkillDef.MOVE
			s.move_path = _pick(rng, MOVE_PATHS)
			if s.move_path != "walk":
				s.blocked_by_objects = false
				s.blocked_by_monsters = false
				s.blocked_by_surges = false
				s.ground_costs = false
			s.move_range = _pick(rng, MOVE_RANGES)
			s.move_diagonal = s.move_path == "line" and rng.randi_range(1, MOVE_DIAGONAL_ONE_IN) == 1     # one line in four may run diagonally
			s.impact_push = _pick(rng, MOVE_IMPACT) if s.move_path == "line" else "none"
			var left: String = _pick(rng, LEAVES)
			if left == "ground":
				ground = _pick(rng, ground_ids(content))
			elif left == "zone":
				zone = _pick(rng, any_zone)            # a push zone left behind pushes the way the monster went
			label = "%s %d" % ["Headbutt" if s.impact_push == "ahead" else ("Quake Leap" if s.impact_push == "ring" else MOVE_NAMES[s.move_path]), s.move_range]
		"zone":
			s.kind = BattleSkillDef.GROUND
			zone = _pick(rng, zones[0])
			if rng.randf() < ZONE_WITH_GROUND:
				ground = _pick(rng, ground_ids(content))
			label = _draw_shape(rng, s, FREE_SQUARES_MAX, false)   # a free shape: the player turns it, and with it the push
		"ground":
			s.kind = BattleSkillDef.GROUND
			ground = _pick(rng, ground_ids(content))
			if rng.randf() < GROUND_WITH_ZONE and not zones[1].is_empty():     # empty since a zone changes no stat
				zone = _pick(rng, zones[1])
			label = _draw_shape(rng, s, FREE_SQUARES_MAX)
		"self":
			s.kind = BattleSkillDef.BUFF
			var fx := FieldEffect.new()
			fx.tag = _pick(rng, SELF_TAGS)
			fx.base = _pick(rng, SELF_VALUES)
			fx.cap = fx.base
			s.buff_effects.append(fx)
			s.duration = _pick(rng, SELF_ROUNDS)
			label = "%s %d" % [String(fx.tag).capitalize(), fx.base]
		"prop":
			s.kind = BattleSkillDef.GROUND
			var pid: StringName = _pick(rng, prop_ids(content))
			var count: int = _pick(rng, PROP_COUNTS)
			var fp: Array[Vector2i] = []
			fp.assign(FREE_SHAPES[count][0])
			s.footprint = fp
			s.board_ops.append(BoardOp.make(BoardOp.CREATE_PROP, pid))
			label = content.prop(pid).display_name + ("" if count == 1 else " ×%d" % count)
	var rounds: int = _pick(rng, ZONE_ROUNDS)
	if zone != &"" and kind == "zone" and ground == &"":
		s.kind = BattleSkillDef.ZONE                 # a zone skill proper: a push zone gets its direction from the player
		s.zone = content.zone(zone)
		s.duration = rounds
	elif zone != &"":
		var op := BoardOp.new()
		op.op = BoardOp.CREATE_ZONE
		op.zone = zone
		op.zone_rounds = rounds
		s.board_ops.append(op)
	if ground != &"":
		s.board_ops.append(BoardOp.make(BoardOp.GROUND, ground))
	var made: PackedStringArray = []
	if ground != &"":
		made.append(content.ground(ground).display_name)
	if zone != &"":
		made.append(content.zone(zone).display_name)
	if kind == "strike" or kind == "move":
		label = " + ".join(PackedStringArray([label]) + made)      # "Cleave Push Strike + Exit Damage Ground"
	elif kind != "prop" and kind != "self":
		label = "%s %s" % [" + ".join(made), label]
	# use: most skills once per turn; some twice, some once per round or battle
	var use: String = _pick(rng, USES)
	match use:
		"twice":
			s.usage_limit = 2
		"round":
			s.repetition = "once_per_round"
		"battle":
			s.repetition = "once_per_battle"
	if ap > 0:
		s.ap_cost = ap
	elif ap == 0:
		s.ap_cost = rng.randi_range(1, 3)
	else:
		s.ap_cost = SkillCalc.fair_ap(content, s)
	s.set_meta("parts", SkillCalc.part_names(content, s))
	s.display_name = label
	s.description = line(content, s)
	return s


## Draws where a skill creates: a free shape of 1 to `most` squares at an anchor (within Reach or next to the
## user) or a base shape around the user. Returns the words for its name.
static func _draw_shape(rng: RandomNumberGenerator, s: BattleSkillDef, most: int, around := true) -> String:
	if around and rng.randf() < AROUND_CHANCE:
		var drawn: Array = _pick(rng, AROUND_SHAPES)
		s.shape = drawn[0]
		s.shape_extension = drawn[1]
		return BattleShapes.shape_name(s.shape_id(), s.shape_extension)
	var count := rng.randi_range(1, most)
	var fp: Array[Vector2i] = []
	fp.assign(_pick(rng, FREE_SHAPES[count]))
	s.footprint = fp
	s.anchor_mode = _pick(rng, ANCHOR_MODES)
	return "%d%s" % [count, " near" if s.anchor_mode == "adjacent" else ""]


const ANCHORS := {"reach": "within Reach", "adjacent": "next to the caster"}


## Where a skill creates something: a free shape at its anchor, or a base shape around the user.
static func place_words(s: BattleSkillDef) -> String:
	if s.is_free_shape():
		return "%s · %d sq" % [ANCHORS.get(s.anchor_mode, s.anchor_mode), maxi(1, s.footprint.size())]
	if s.shape_id() == BattleShapes.JAB:
		return "line from the user · %d sq" % s.shape_squares()
	return "%s around the user · %d sq" % [s.shape_label(), s.shape_squares()]
const PATHS := {"walk": "walks", "line": "straight line", "free": "any path", "teleport": "any free square"}
const SELF_EFFECTS := {"quicken": "Pace +0.1", "haste": "movement skills −1 Stamina", "extend": "Reach +1", "refresh": "Stamina +1 at the round end", "vigor": "AP +1 (experiment)", "tempo": "one more turn (experiment)"}
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
			out["where"] = "neighbour · %s" % s.shape_label()
			var does: PackedStringArray = []
			if s.strike_damage > 0:
				does.append("%d dmg" % s.strike_damage)
			if s.strike_push:
				does.append("push 1")
			out["strike"] = ", ".join(does) if not does.is_empty() else "no damage, no push"
		BattleSkillDef.SURGE, BattleSkillDef.TRAP:
			out["where"] = place_words(s)
			out["strike"] = "%d dmg %s (retired kind)" % [s.surge_damage, "after time" if s.kind == BattleSkillDef.SURGE else "on entering"]
		BattleSkillDef.ZONE, BattleSkillDef.GROUND:
			out["where"] = place_words(s)
			if s.kind == BattleSkillDef.ZONE and s.zone != null:
				zones.append("%s · %d rd" % [s.zone.display_name, s.duration])
		BattleSkillDef.MOVE:
			out["where"] = "path"
			var dist := "Movement" if s.fixed_distance <= 0 else str(s.fixed_distance)
			if s.fixed_distance <= 0 and s.distance_mod != 0:
				dist += " %+d" % s.distance_mod
			if BattleExperiment.stamina and s.fixed_distance <= 0:     # the rule: a range on the skill, paid in Stamina
				dist = "up to %d sq, Stamina per sq" % (s.move_range if s.move_range > 0 else 3)
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
## strike ("" | a base shape of BattleShapes, extended as "jab+1") with damage (0–2) and push ("yes" | "no"), path ("" | walk | line | free) with impact
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
		var named: Array = BattleShapes.LEGACY.get(strike, strike.split("+"))     # "arc", "jab+1", or an earlier name ("thrust")
		s.shape = String(named[0])
		s.shape_extension = int(named[1]) if named.size() > 1 else 0
		s.strike_damage = clampi(int(spec.get("damage", 2)), 0, 2)
		s.strike_push = String(spec.get("push", "yes")) != "no"
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
	if slot < 0 or slot >= 6:
		return "a kit has six slots"
	while m.skills.size() <= slot:
		m.skills.append(s)
	m.skills[slot] = s
	var path := "%s/monsters/%s.tres" % [BattleContent.ROOT, monster_id]
	var err := ResourceSaver.save(m, path)
	return "" if err == OK else "could not write %s (error %d)" % [path, err]
