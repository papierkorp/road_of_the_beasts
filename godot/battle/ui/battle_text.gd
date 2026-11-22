class_name BattleText
extends RefCounted
## Short text for the HUD: skill cards, the square inspector, the cast preview and log lines.
## Presentation only: it reads definitions, state and events and never decides a rule.
##
## House rule: tokens, not sentences. One line per fact ("3 dmg · next turn · 4 sq"), built
## from the data so new content gets its text for free. A card has at most three lines; the
## inspector shows only what is notable about a square.

const ROMAN := ["I", "II", "III"]
const SEP := " · "
const DIR_NAMES := {
	Vector2i(0, -1): "north", Vector2i(1, -1): "north-east", Vector2i(1, 0): "east", Vector2i(1, 1): "south-east",
	Vector2i(0, 1): "south", Vector2i(-1, 1): "south-west", Vector2i(-1, 0): "west", Vector2i(-1, -1): "north-west",
}
const TIMING := {Moment.TURN_START: "at turn start", Moment.ENTER: "on entering", Moment.TURN_END: "at turn end", Moment.ROUND_END: "at round end", Moment.LEAVE: "on leaving"}
const PATHS := {"walk": "walk", "line": "straight line", "free": "any path", "teleport": "teleport"}


static func pos(p: Vector2i) -> String:
	return "[%d,%d]" % [p.x, p.y]


static func dir_name(d: Vector2i) -> String:
	return DIR_NAMES.get(d, "—")


static func rows_to_text(rows: Array) -> String:
	var lines: PackedStringArray = []
	for r in rows:
		lines.append("%s: %s" % [r[0], r[1]] if r[0] != "" else String(r[1]))
	return "\n".join(lines)


static func unit_name(b: Battle, id: StringName) -> String:
	var u: BattleUnit = b.units.get(id)
	return u.display_name() if u != null else String(id)


# ---------- definitions ----------

## What kind of skill it is, for the action bar and the card: a word, its colour and one line that says what
## skills of that kind do. Kinds: strike · move · ground · zone · prop · self · passive.
const KINDS := {
	"strike": ["Strike", Color(0.71, 0.21, 0.17), "acts now on the squares of its shape, next to the user"],
	"move": ["Move", Color(0.20, 0.36, 0.56), "moves the user; costs Stamina per square"],
	"ground": ["Ground", Color(0.66, 0.44, 0.10), "lays ground on squares within Reach; ground acts at its moment"],
	"zone": ["Zone", Color(0.45, 0.28, 0.60), "lays a zone within Reach; it moves a monster that arrives or ends its turn inside"],
	"prop": ["Prop", Color(0.38, 0.36, 0.33), "creates a prop on free squares within Reach"],
	"self": ["Self", Color(0.20, 0.50, 0.42), "an effect on the user"],
	"passive": ["Passive", Color(0.20, 0.50, 0.42), "always on, costs nothing"],
}


static func kind_id(c: BattleContent, s: BattleSkillDef) -> String:
	if s.kind == BattleSkillDef.PASSIVE:
		return "passive"
	return KitDraw.kind_of(c, s)


static func kind_label(c: BattleContent, s: BattleSkillDef) -> String:
	var k: Array = KINDS.get(kind_id(c, s), [])
	return k[0] if not k.is_empty() else ""


static func kind_color(c: BattleContent, s: BattleSkillDef) -> Color:
	var k: Array = KINDS.get(kind_id(c, s), [])
	return k[1] if not k.is_empty() else Color.WHITE


## The first row of a skill card: ["Kind", "Strike"]. What the word means stands once in the glossary.
static func kind_row(c: BattleContent, s: BattleSkillDef) -> Array:
	var k: Array = KINDS.get(kind_id(c, s), [])
	return ["Kind", k[0]] if not k.is_empty() else []


## What a prop is and does in terms, one line each: its traits, then one line per thing it does ("destroyed: 1 dmg
## around it"), then when it lapses. The terms are explained once in the glossary (GLOSSARY).
const PROP_WHEN := {"destroyed": "destroyed", "hit": "hit", "enter": "entered", "round_end": "round end"}
const PROP_WHERE := {"self": "own sq", "whirl": "next to it", "cross": "diagonal", "storm": "around it", "block": "on and around it"}
static func prop_lines(c: BattleContent, d: PropDef, _hp := -1, until := 0) -> PackedStringArray:
	var out: PackedStringArray = []
	var traits: PackedStringArray = ["trap" if d.is_trap() else ("solid" if d.solid else "walkable")]
	if d.heavy:
		traits.append("heavy")
	if d.spiky:
		traits.append("spiky")
	out.append(SEP.join(traits))
	for a in d.aftermath:
		if a == null:
			continue
		var where: String = PROP_WHERE.get(a.shape, a.shape) + (" ×%d" % (a.extension + 1) if a.extension > 0 and a.shape != "self" else "")
		var when: String = PROP_WHEN.get(a.when, a.when)
		if a.when == Moment.ROUND_END and a.op == "damage":
			when = "turn end"
		var what := ""
		match a.op:
			"damage":
				what = "%d dmg %s" % [a.amount, where]
			"push":
				what = "push 1 %s" % where
			"pull":
				what = "pull 1 %s" % where
			"spawn":
				var child := c.prop(a.spawn_prop)
				what = "+ %s %s" % [child.display_name if child != null else String(a.spawn_prop), where]
			"ground":
				var laid := c.ground(a.ground)
				what = "ground %s %s" % [laid.display_name if laid != null else String(a.ground), where]
			"zone":
				var made := c.zone(a.zone)
				what = "zone %s %s · %d rd" % [made.display_name if made != null else String(a.zone), where, a.zone_rounds]
		out.append("%s: %s" % [when, what])
	if d.ground_left != &"" and d.ground_left != GroundDef.PLAIN:
		var g := c.ground(d.ground_left)
		out.append("destroyed: leaves %s" % (g.display_name if g != null else String(d.ground_left)))
	if until > 0:
		out.append("lapses after round %d" % until)
	return out


## Every term of the cards and the inspector, explained once: [[term, meaning], ...] in groups (a row with an
## empty meaning is a heading). Shown by the pause menu (Glossary) and the key G.
const GLOSSARY := [
	["KINDS OF SKILLS", ""],
	["Strike", "acts now on the squares of its shape, next to the user: pushes, and damages if the card says so"],
	["Move", "moves the user; costs AP and 1 Stamina per square (Step: no Stamina)"],
	["Ground", "lays ground on squares within Reach; ground acts at its moment and lasts 2 rounds"],
	["Zone", "lays a zone within Reach; it moves a monster that arrives or ends its turn inside"],
	["Prop", "creates a prop on free squares within Reach"],
	["Self", "an effect on the user for some rounds"],
	["Passive", "always on, costs nothing"],
	["MOVEMENT", ""],
	["walk", "square by square, orthogonally; every square on the way counts (ground, traps, Dragon Veins)"],
	["straight line", "one direction; only the landing square counts, the squares on the way are not touched"],
	["any path", "free path; only the landing square counts"],
	["over props / monsters", "the movement passes them; without it they block the way"],
	["also diagonal", "a straight line may run along a diagonal"],
	["MOMENTS", ""],
	["on entering / on leaving", "when a monster walks, is pushed or is pulled onto or off the square"],
	["turn end", "when the monster standing there ends its own turn"],
	["round end", "after the last turn of the round"],
	["destroyed / hit / entered", "when a prop loses its last HP / loses HP and still stands / a monster comes onto a trap"],
	["PROPS", ""],
	["solid", "blocks the square and shields the square behind it from a Strike; a monster pushed into it takes 1 and so does the prop"],
	["walkable", "blocks nothing; a monster can stand on it"],
	["trap", "walkable; acts once when a monster enters it and is then used up"],
	["heavy", "cannot be pushed or pulled and takes no collision damage"],
	["spiky", "a monster pushed into it takes 2 instead of 1"],
	["lapses", "a prop a skill created goes away without effect at the end of that round"],
	["next to it / diagonal / around it", "the 4 neighbour squares / the 4 diagonal squares / all 8 squares"],
	["ZONES", ""],
	["push 1", "a monster whose move ends inside, or that ends its turn inside, is moved 1 square in the zone's direction (arrow)"],
	["pull 1 to centre", "a monster whose move ends inside, or that ends its turn inside, is moved 1 square toward the zone's centre square; on the centre it stays"],
	["BOARD", ""],
	["collision", "a pushed monster that cannot move takes 1 (board edge, prop, monster); a monster in the way takes 1 too"],
	["Dragon Vein", "belongs to the side that touched it last; at the round end it hits the nearest enemy of its owner"],
	["surrounded", "two or more enemies on the eight neighbour squares at the round end: 1 damage"],
	["Reach", "how far away a skill may lay ground, a zone or a prop, in orthogonal steps"],
	["Stamina", "pays for movement skills; recovers by the whole number of Pace at the round end"],
	["Wait", "postpone this turn to the end of the round; monsters that waited act in reverse order"],
]


static func glossary_text() -> String:
	var lines: PackedStringArray = []
	for row: Array in GLOSSARY:
		lines.append(("\n" + row[0]) if row[1] == "" else "%s — %s" % [row[0], row[1]])
	return "\n".join(lines).strip_edges()


## "slow 1, shield 2" (an effect that only reaches the air layer is marked).
static func effects_text(effects: Array, level := 1) -> String:
	var parts: PackedStringArray = []
	for e: FieldEffect in effects:
		parts.append(e.text(level) + ("" if e.affects_ground else " (air)"))
	return ", ".join(parts)


## What a ground does, from its data: "2 dmg at turn end", "heal 1 on enter", "quicken 1".
static func ground_brief(g: GroundDef, level := 1) -> String:
	var parts: PackedStringArray = []
	if g.move_cost > 1:
		parts.append("move cost %d" % g.move_cost)
	for t in g.triggers:
		var does := "%d dmg" % t.value_at(level)
		if t.kind == "heal":
			does = "heal %d" % t.value_at(level)
		elif t.kind == "stamina":
			does = "Stamina +%d" % t.value_at(level)
		parts.append("%s %s" % [does, TIMING.get(t.timing, t.timing)])
	if not g.effects.is_empty():
		parts.append(effects_text(g.effects, level))
	if g.no_props:
		parts.append("no prop can be placed here")
	return SEP.join(parts)


## What a prop does, from its data: "heavy · leaves Rubble", "burst 1", "aura quicken 1".
static func prop_brief(c: BattleContent, d: PropDef) -> String:
	var parts: PackedStringArray = []
	if d.layer == "air":
		parts.append("air")
	elif d.layer == "both":
		parts.append("ground+air")
	if not d.solid:
		parts.append("trap" if d.is_trap() else "walkable")
	if d.heavy:
		parts.append("heavy")
	if not d.aura.is_empty():
		parts.append("aura " + effects_text(d.aura))
	for a in d.aftermath:
		var at: String = {"hit": "hit: ", "enter": "entered: ", "round_end": "round end: "}.get(a.when, "")
		match a.op:
			"damage":
				parts.append("%s%d dmg %s" % [at if at != "" else "destroyed: ", a.amount, {"self": "to who enters", "whirl": "next to it", "cross": "diagonal", "storm": "around it", "block": "on and around it"}.get(a.shape, a.shape)])
			"push":
				parts.append("%spush %d" % [at, a.amount])
			"pull":
				if at != "":
					parts.append("%spull %d" % [at, a.amount])
			"spawn":
				var child := c.prop(a.spawn_prop)
				parts.append("%sspawns %s" % [at, child.display_name if child != null else String(a.spawn_prop)])
			"ground":
				var laid := c.ground(a.ground)
				parts.append("%slays %s" % [at, laid.display_name if laid != null else String(a.ground)])
			"zone":
				var made := c.zone(a.zone)
				parts.append("%s%s zone" % [at, made.display_name if made != null else String(a.zone)])
	if d.ground_left != &"" and d.ground_left != GroundDef.PLAIN:
		var g := c.ground(d.ground_left)
		parts.append("leaves %s" % (g.display_name if g != null else String(d.ground_left)))
	return SEP.join(parts)


## Board operations as tokens: "Lava I", "Mountain", "breaks Mountain", "+ Stone Lion".
static func ops_tokens(c: BattleContent, ops: Array, residue := false) -> PackedStringArray:
	var parts: PackedStringArray = []
	for op: BoardOp in ops:
		match op.op:
			BoardOp.GROUND:
				var g := c.ground(op.ground)
				var label := g.label(1) if g != null else String(op.ground)
				parts.append("leaves " + label if residue else label)
			BoardOp.RAISE_MOUNTAIN:
				parts.append("Mountain")
			BoardOp.DESTROY_MOUNTAIN:
				parts.append("breaks Mountain")
			BoardOp.CREATE_PROP:
				var p := c.prop(op.prop)
				parts.append("+ " + (p.display_name if p != null else String(op.prop)))
	return parts


## Where a skill creates something: "3 sq · within Reach · ■■/■·" (a free shape as arranged) or "3 sq · line from the user" /
## "4 sq · Whirl around the user" (a base shape).
static func _area(s: BattleSkillDef) -> String:
	if s.is_free_shape():
		var where := "%d sq" % s.footprint.size() + SEP + ("within Reach" if s.anchor_mode == "reach" else "adjacent")
		return where if s.footprint.size() < 2 else where + SEP + BattleShapes.arrangement_text(s.footprint)
	if s.shape_id() == BattleShapes.JAB:
		return "%d sq" % s.shape_squares() + SEP + "line from the user"
	return "%d sq" % s.shape_squares() + SEP + s.shape_label() + " around the user"


## An effect in plain words: "movement skills +1 Stamina", "Pace +0.2", "push 1".
static func effect_words(e: FieldEffect, level := 1) -> String:
	var v := e.value_at(level)
	match e.tag:
		FieldEffect.SLOW:
			return "movement skills +%d Stamina" % v
		FieldEffect.HASTE:
			return "movement skills −%d Stamina" % v
		FieldEffect.DRAIN_PACE:
			return "Pace −%.1f" % (v * BattleStats.PACE_POINT)
		FieldEffect.QUICKEN:
			return "Pace +%.1f" % (v * BattleStats.PACE_POINT)
		FieldEffect.DRAIN_RANGE:
			return "Reach −%d" % v
		FieldEffect.EXTEND:
			return "Reach +%d" % v
		FieldEffect.VIGOR:
			return "AP +%d" % v
		FieldEffect.SAP:
			return "AP −%d" % v
		FieldEffect.TEMPO:
			return "+%d turn next round" % v
		FieldEffect.REFRESH:
			return "Stamina +%d at the round end" % v
		FieldEffect.ANCHOR:
			return "cannot be pushed or pulled"
	return e.text(level)


## What a zone does, short for a card: "while inside: movement skills +1 Stamina · turn end: pull 1 to centre".
## `full` writes the push and the pull as whole sentences (the square inspector).
static func zone_brief(z: BattleZoneDef, level := 1, full := false) -> String:
	var inside: PackedStringArray = []
	var moves: PackedStringArray = []
	for e: FieldEffect in z.effects:
		if e.tag == FieldEffect.PUSH:
			moves.append("a monster whose move ends inside, or that ends its turn inside, is pushed 1 square in the zone's direction (arrow)" if full else "on arriving, turn end: push 1")
		elif e.tag == FieldEffect.PULL:
			moves.append("a monster whose move ends inside, or that ends its turn inside, is pulled 1 square toward the zone's centre square (arrow); on the centre it stays" if full else "on arriving, turn end: pull 1 to centre")
	var parts: PackedStringArray = []
	if not inside.is_empty():
		parts.append("while inside: " + ", ".join(inside))
	parts.append_array(moves)
	return SEP.join(parts)


## What a ground does, with its levels: "1 dmg on enter (II: 2)".
static func ground_words(g: GroundDef) -> String:
	var text := ground_brief(g, 1)
	if g.max_level > 1 and not g.triggers.is_empty():
		text += " (II: %d)" % g.triggers[0].value_at(2)
	return text if text != "" else "no effect"


## What a prop is, for a card: "2 HP · spiky · burst 1".
static func prop_words(c: BattleContent, d: PropDef) -> String:
	var parts: PackedStringArray = ["%d HP" % d.hp]
	if d.spiky:
		parts.append("spiky")
	var brief := prop_brief(c, d)
	if brief != "":
		parts.append(brief)
	return SEP.join(parts)


## The rows of what a skill creates, the same for every skill: per ground, zone or prop one row
## [label, "zone Updraft · 1 rd"] and below it one row ["", what that thing does] (its definition, not the
## skill, holds that). `label` is "Creates", or "Leaves" for what a movement leaves on its path.
static func created_rows(c: BattleContent, s: BattleSkillDef, label := "Creates") -> Array:
	var rows: Array = []
	var rounds := BattleExperiment.ground_rounds
	if s.kind == BattleSkillDef.ZONE and s.zone != null:
		rows.append([label, "zone %s%s%d rd" % [s.zone.display_name, SEP, s.duration]])
		rows.append(["", zone_brief(s.zone)])
	for op: BoardOp in s.board_ops:
		match op.op:
			BoardOp.GROUND:
				var g := c.ground(op.ground)
				if g == null:
					continue
				rows.append([label, "ground %s%s" % [g.display_name, (SEP + "%d rd" % rounds) if rounds > 0 else ""]])
				rows.append(["", ground_words(g)])
			BoardOp.CREATE_ZONE:
				var z := c.zone(op.zone)
				if z == null:
					continue
				rows.append([label, "zone %s%s%d rd" % [z.display_name, SEP, op.zone_rounds]])
				rows.append(["", zone_brief(z)])
			BoardOp.CREATE_PROP:
				var d := c.prop(op.prop)
				if d == null:
					continue
				rows.append([label, "prop %s" % d.display_name])
				rows.append(["", prop_words(c, d)])
	return rows


## What a use costs: "1 AP", "1 AP · Stamina 1/sq", "2 AP · 1 Stamina · 1/round".
static func cost_text(s: BattleSkillDef) -> String:
	var parts: PackedStringArray = []
	if s.cost() > 0 or not s.uses_stamina():
		parts.append("%d AP" % s.cost())
	if s.uses_stamina():
		parts.append("Stamina 1/sq")
	if s.usage_limit > 1:
		parts.append("%d/turn" % s.usage_limit)
	elif s.usage_limit <= 0:
		parts.append("any number/turn")
	var rep: String = {"once_per_round": "1/round", "once_per_battle": "1/battle"}.get(s.repetition, "")
	if rep != "":
		parts.append(rep)
	return SEP.join(parts)


## The card of a skill, the same build for every skill (user request 2026-11-17). Rows [label, text], always
## in this order; a row that has nothing to say is left out:
##   Cost     AP, Stamina, uses
##   Where    the shape and where it lies, or the path and range of a movement
##   Does     what the skill does itself: damage, push, an effect on the user
##   Creates  one row per ground, zone or prop, and below each what that thing does ("Leaves" for a movement)
static func skill_rows(c: BattleContent, s: BattleSkillDef) -> Array:
	var rows: Array = []
	if s.kind == BattleSkillDef.PASSIVE:
		return [["Passive", s.description if s.description != "" else "passive"]]
	rows.append(["Cost", cost_text(s)])
	match s.kind:
		BattleSkillDef.STRIKE:
			rows.append(["Where", "%s%s%d sq next to the user" % [s.shape_label(), SEP, s.shape_squares()]])
			var does: PackedStringArray = []
			var push := "push 1" if s.strike_push else ""
			if s.push_only():
				if push != "":
					does.append(push)
				if s.hits_props():
					does.append("%d dmg to props" % BattleSkillDef.STRIKE_PROP_DAMAGE)
				elif push == "":
					does.append("no dmg, no push")
			else:
				if s.strike_damage > 0:
					does.append("%d dmg" % s.strike_damage)
				if push != "":
					does.append(push)
				if does.is_empty():
					does.append("no dmg, no push")
				if s.strike_props == 0 and s.strike_damage > 0:
					does.append("spares props")
				elif s.strike_props == 1 and s.strike_damage == 0:
					does.append("props: %d" % BattleSkillDef.STRIKE_PROP_DAMAGE)
			if s.self_retreat:
				does.append("then retreat 1")
			rows.append(["Does", SEP.join(does)])
			rows.append_array(created_rows(c, s))
		BattleSkillDef.SURGE, BattleSkillDef.TRAP:            # retired kinds, kept for archived records
			rows.append(["Where", _area(s)])
			var parts: PackedStringArray = ["%d dmg" % s.surge_damage, "trap" if s.kind == BattleSkillDef.TRAP else "in %d turns" % s.surge_turns]
			if s.surge_displacement != "none":
				parts.append(s.surge_displacement + " 1")
			parts.append_array(ops_tokens(c, s.board_ops, true))
			rows.append(["Does", SEP.join(parts)])
		BattleSkillDef.ZONE, BattleSkillDef.GROUND:
			rows.append(["Where", _area(s)])
			rows.append_array(created_rows(c, s))
		BattleSkillDef.MOVE:
			var reach := s.fixed_distance if s.fixed_distance > 0 else (s.move_range if s.move_range > 0 else 3)
			var where: PackedStringArray = [PATHS.get(s.move_path, s.move_path) + (" (also diagonal)" if s.move_path == "line" and s.move_diagonal else ""),
				("up to %d sq" % reach) if BattleExperiment.stamina else ("Move" + ("" if s.distance_mod == 0 else " %d" % s.distance_mod))]
			rows.append(["Where", SEP.join(where)])
			var over: PackedStringArray = []
			if not s.blocked_by_objects:
				over.append("props")
			if not s.blocked_by_monsters:
				over.append("monsters")
			rows.append(["Passes", ("over " + ", ".join(over) if not over.is_empty() else "nothing") + SEP + ("every sq on the way counts" if s.move_path == "walk" else "only the landing sq counts")])
			if s.impact_push == "ahead":
				rows.append(["Does", "pushes the monster ahead 1"])
			elif s.impact_push == "ring":
				rows.append(["Does", "pushes all neighbours 1 on landing"])
			rows.append_array(created_rows(c, s, "Leaves"))
		BattleSkillDef.BUFF:
			var fx: PackedStringArray = []
			for e in s.buff_effects:
				fx.append(effect_words(e))
			rows.append(["Where", "the user"])
			rows.append(["Does", "%s%s%s" % [", ".join(fx), SEP, "%d rd" % s.duration if s.duration > 0 else "this round"]])
	return rows


## The card of Step, built like a skill card.
static func step_rows() -> Array:
	return [["Cost", "%d AP%sany number/turn" % [BattleMoves.step_ap(), SEP]], ["Where", "walk" + SEP + "1 sq"]]


## The pre-battle datasheet: one stat line and the kit.
static func sheet_rows(_c: BattleContent, s: UnitSheet) -> Array:
	var kit: PackedStringArray = []
	for k in s.skills:
		kit.append(k.display_name)
	return [
		["", "%s%sHP %d%sPace %.1f%s%s %d%sReach %d%sAP %d%s" % [MonsterDef.kin_name(s.kin) + (SEP + s.rank if s.rank != "" else ""), SEP, s.hp, SEP, s.pace, SEP,
			"Stamina" if BattleExperiment.stamina else "Move", s.movement, SEP, s.reach, SEP, s.ap, "" if s.tpr <= 1 else SEP + "TPR %d" % s.tpr]],
		["", SEP.join(kit)],
	] + innate_rows(s)


# ---------- state ----------

## What is left of the Stamina pool and what comes back per round: "Stamina 2/4 (+1)"; "Move 3" with the pool switched off.
static func move_text(b: Battle, u: BattleUnit) -> String:
	if BattleExperiment.stamina:
		return "Stamina %d/%d (+%d)" % [u.stamina, u.sheet.movement, BattleStats.recovery(b, u)]
	return "Move %d" % BattleStats.movement(b, u)


static func unit_title(u: BattleUnit) -> String:
	return "%s%s%s%s%s" % [u.display_name(), SEP + MonsterDef.kin_name(u.kin()), SEP + u.sheet.rank if u.sheet.rank != "" else "", SEP + "2×2" if u.size == 2 else "",
		SEP + "air" if u.layer == Board.AIR else ""]


## A monster under the cursor: live stats, what affects it, its kit. No sources, no sentences.
static func unit_rows(b: Battle, u: BattleUnit) -> Array:
	var rows: Array = [["", "HP %d/%d%sPace %.1f%s%s%sReach %d%sAP %d%s" % [u.hp, u.max_hp, SEP, BattleStats.pace(b, u), SEP,
		move_text(b, u), SEP, BattleStats.reach(b, u), SEP, u.sheet.ap, "" if u.sheet.tpr <= 1 else SEP + "TPR %d" % u.sheet.tpr]]]
	var totals := {}
	var order: Array = []
	for c in BattleStats.contributions(b, u):
		if not totals.has(c["tag"]):
			order.append(c["tag"])
		totals[c["tag"]] = int(totals.get(c["tag"], 0)) + int(c["value"])
	var marks: PackedStringArray = []
	for tag: String in order:
		marks.append("%s %d" % [tag, totals[tag]])
	if u.nullify:
		marks.append("Nullify")
	if u.life_thread:
		marks.append("Life Thread")
	if b.wild[u.side]:
		marks.append("wild")
		var ch := BattleCatch.chance(b, u)
		if ch >= 0:
			marks.append("on Seal Ground: catch %d%% at its turn end" % ch)
	if not marks.is_empty():
		rows.append(["", ", ".join(marks)])
	var kit: PackedStringArray = []
	for k in u.sheet.skills:
		kit.append(k.display_name)
	if not kit.is_empty():
		rows.append(["", SEP.join(kit)])
	rows.append_array(innate_rows(u.sheet))
	return rows


## The Kin trait of a monster (a passive without a slot), with what it does.
static func innate_rows(s: UnitSheet) -> Array:
	var rows: Array = []
	for p in s.innate:
		rows.append(["", "%s: %s" % [p.display_name, p.description]])
	return rows


static func _prop_row(c: BattleContent, prop: BoardProp) -> Array:
	var brief := prop_brief(c, prop.def)
	return ["Prop", "%s %d/%d%s" % [prop.def.display_name, prop.hp, prop.def.hp, SEP + brief if brief != "" else ""]]


## A prop on a square, for the inspector: its name and HP, then one row per sentence of `prop_lines`.
static func prop_rows(c: BattleContent, prop: BoardProp) -> Array:
	var rows: Array = [["Prop", "%s · HP %d/%d" % [prop.def.display_name, prop.hp, prop.def.hp]]]
	for line in prop_lines(c, prop.def, prop.hp, prop.until):
		rows.append(["", line])
	return rows


## Where a push or pull zone moves a monster that arrives or ends its turn on square `p`, with the compass direction:
## "here: push north", "here: pull east (to centre)", "here: no pull (diagonal to the centre)". "" for other zones.
static func zone_way(z: BoardZone, p: Vector2i) -> String:
	var parts: PackedStringArray = []
	if z.def.has_tag(FieldEffect.PUSH) and z.dir != Vector2i.ZERO:
		parts.append("push %s" % dir_name(z.dir))
	if z.def.has_tag(FieldEffect.PULL):
		var d := BattleDisplace.pull_dir_cell(p, z.anchor)
		if d != Vector2i.ZERO:
			parts.append("pull %s (to centre)" % dir_name(d))
		elif p != z.anchor:
			parts.append("no pull (diagonal to the centre)")
	return "here: " + ", ".join(parts) if not parts.is_empty() else ""


## What is notable about a square, one line per layer. An empty Plain square has nothing to say.
static func cell_rows(b: Battle, p: Vector2i) -> Array:
	var cell := b.board.at(p)
	var rows: Array = []
	var g := b.content.ground(cell.ground)
	if cell.ground != GroundDef.PLAIN or cell.is_mountain():
		var parts: PackedStringArray = []
		if cell.ground != GroundDef.PLAIN and g != null:
			var brief := ground_brief(g, cell.level)
			parts.append(g.label(cell.level) + (SEP + brief if brief != "" else ""))
		if cell.is_mountain():
			parts.append("Mountain" + SEP + "+1 Reach")
		rows.append(["Ground", SEP.join(parts)])
	if cell.zone != null:
		var z := cell.zone
		var left := "the whole battle" if z.rounds_text() == "" else "%d more round%s" % [z.duration, "" if z.duration == 1 else "s"]
		rows.append(["Zone", "%s %s%s%s" % [z.def.display_name, ROMAN[z.level - 1], SEP, left]])
		rows.append(["", zone_brief(z.def, z.level) + (SEP + "centre" if z.def.has_tag(FieldEffect.PULL) and z.anchor == p else "")])
		var way := zone_way(z, p)
		if way != "":
			rows.append(["", way])
	if cell.surge >= 0:
		var s := b.surge_by_id(cell.surge)
		if s != null:
			rows.append(["Surge", "%s%s%d dmg%s%s" % [s.skill.display_name, SEP, s.skill.surge_damage, SEP,
				"trap" if s.orphaned else unit_name(b, s.owner)]])
	if cell.prop != null:
		rows.append_array(prop_rows(b.content, cell.prop))
	if cell.air_prop != null and cell.air_prop != cell.prop:
		rows.append_array(prop_rows(b.content, cell.air_prop))
	return rows


# ---------- log ----------

## What kind of damage it was, where the source does not say it.
const DAMAGE_KIND := {"ground": "ground", "collision": "collision", "aftermath": "prop", "arena": "late-round pressure",
	"well": "Dragon Vein", "flank": "surrounded", "fall": "fall", "collapse": "collapse", "surge": "Surge"}


## One damage event in words: "Jab by Gloom Wolf −2", "Lava (ground) −1", "Collision −1".
static func damage_words(b: Battle, e: Dictionary) -> String:
	var source := String(e.get("source", ""))
	var kind: String = DAMAGE_KIND.get(String(e.get("kind", "")), "")
	var text := source if source != "" else kind.capitalize()
	if kind != "" and source != "" and source.to_lower() != kind and not (kind == "collision" or kind == "well" or kind == "flank" or kind == "fall"):
		text += " (%s)" % kind
	var by: StringName = e.get("by", &"")
	if by != &"" and by != e["target"]:
		text += " by %s" % unit_name(b, by)
	return "%s %s" % [text, "blocked" if int(e["amount"]) == 0 else "−%d" % int(e["amount"])]


## Everything that changed the HP of a monster, in order: rows [round, whose turn it was, what happened, HP after].
## `upto` = only the first so many events of the battle (-1 = all).
static func hp_history(b: Battle, id: StringName, upto := -1) -> Array:
	var out: Array = []
	var u: BattleUnit = b.units.get(id)
	if u == null:
		return out
	var hp := u.max_hp if u.sheet.current_hp < 0 else u.sheet.current_hp
	var round_no := 1
	var turn := ""
	var n := b.events.size() if upto < 0 else mini(upto, b.events.size())
	for i in n:
		var e: Dictionary = b.events[i]
		match e["type"]:
			&"round_started":
				round_no = int(e["round"])
				turn = "round start"
			&"turn_started":
				turn = "%s's turn" % unit_name(b, e["who"])
			&"turn_ended":
				turn = "end of %s's turn" % unit_name(b, e["who"])
			&"props_acted", &"wells_held":
				turn = "round end"
			&"damage":
				if e["target"] == id:
					hp -= int(e["amount"])
					out.append([round_no, turn, damage_words(b, e), hp])
			&"healed":
				if e["target"] == id and int(e["amount"]) > 0:
					hp = mini(u.max_hp, hp + int(e["amount"]))
					out.append([round_no, turn, "%s +%d" % [e.get("source", "healed"), int(e["amount"])], hp])
			&"survived":
				if e["target"] == id:
					hp = 1
					out.append([round_no, turn, "Life Thread: survives", hp])
			&"defeated":
				if e["who"] == id:
					out.append([round_no, turn, "defeated", 0])
	return out


## The history as text lines: "Round 3 · Gloom Wolf's turn · Jab by Gloom Wolf −2 · 1 HP".
static func hp_history_lines(b: Battle, id: StringName) -> PackedStringArray:
	var out: PackedStringArray = []
	for row: Array in hp_history(b, id):
		out.append("Round %d%s%s%s%s%s" % [row[0], SEP, row[1], SEP, row[2], "" if row[2] == "defeated" else "%s%d HP" % [SEP, maxi(0, row[3])]])
	return out


## Why a monster fell: the hit that did it and what else it took in that round.
## "Blaze Tiger falls: Lava (ground) −1. Earlier this round: Jab by Gloom Wolf −2, Collision −1."
static func defeat_line(b: Battle, id: StringName) -> String:
	var rows := hp_history(b, id).filter(func(r: Array) -> bool: return r[2] != "defeated")
	var name := unit_name(b, id)
	if rows.is_empty():
		return "%s falls" % name
	var last: Array = rows[rows.size() - 1]
	var earlier: PackedStringArray = []
	for i in rows.size() - 1:
		if rows[i][0] == last[0] and String(rows[i][2]).contains("−"):
			earlier.append(rows[i][2])
	var text := "%s falls: %s (%s)" % [name, last[2], last[1]]
	if not earlier.is_empty():
		text += ". Earlier this round: " + ", ".join(earlier)
	return text


## One log line for an event, or "" if the event is not worth a line.
static func event_line(b: Battle, e: Dictionary) -> String:
	match e["type"]:
		&"defeated":
			return defeat_line(b, e["who"])
		&"damage":
			return "%s: %s" % [unit_name(b, e["target"]), damage_words(b, e)]
		&"round_started":
			var first: String = unit_name(b, e["queue"][0]) if not (e["queue"] as Array).is_empty() else "nobody"
			return "Round %d — %s first" % [e["round"], first]
		&"move_blocked":
			return "%s stops at %s: the way is blocked" % [unit_name(b, e["who"]), pos(e["at"])]
		&"moved":
			return "%s: %s → %s" % [unit_name(b, e["who"]), e["skill"], pos(e["to"])]
		&"strike":
			return "%s strikes%s" % [unit_name(b, e["who"]), " " + dir_name(e["dir"]) if e["dir"] != Vector2i.ZERO else ""]
		&"cast":
			return "%s: %s" % [unit_name(b, e["who"]), _skill_name(b, e["who"], e["skill"])]
		&"surge_declared":
			return "%s declares %s" % [unit_name(b, e["who"]), _skill_name(b, e["who"], e["skill"])]
		&"surge_fired":
			return "%s fires!" % _skill_name(b, e["who"], e["skill"])
		&"tamer_skill":
			var t := b.content.tamer_skill(e["skill"])
			return "%s: %s" % ["Tamer" if int(e["side"]) == 0 else "Enemy tamer", t.display_name if t != null else String(e["skill"])]
		&"surge_lapsed":
			return "A trap lapses"
		&"seal_laid":
			return "Seal Ground at %s (%d%% at 1 HP)" % [pos(e["pos"]), e["base"]]
		&"catch_roll":
			return "%s: catch %d%% — rolled %d, %s" % [unit_name(b, e["who"]), e["chance"], e["roll"], "caught!" if e["caught"] else "breaks free"]
		&"catch_chance":
			return "%s stands on Seal Ground: catch %d%%" % [unit_name(b, e["who"]), e["chance"]]
		&"caught":
			return "%s is caught" % unit_name(b, e["who"])
		&"died":
			return "%s dies (wild, off Seal Ground)" % unit_name(b, e["who"])
		&"zones_faded":
			return "%d zone sq fade" % e["count"]
		&"battle_over":
			return "The battle is over."
	return brief(b, e)


static func _skill_name(b: Battle, who: StringName, skill_id: StringName) -> String:
	var u: BattleUnit = b.units.get(who)
	if u != null:
		for s in u.sheet.skills:
			if s.id == skill_id:
				return s.display_name
	var s2 := b.content.skill(skill_id)
	return s2.display_name if s2 != null else String(skill_id)


static func _prop_name(b: Battle, id: StringName) -> String:
	var p := b.content.prop(id)
	return p.display_name if p != null else String(id)


## The outcome of one event in a few words ("Tiger −2", "Tiger → [4,2]", "Lava I"); "" if it
## says nothing a player needs. Used by the log and, grouped, by the cast preview.
static func brief(b: Battle, e: Dictionary) -> String:
	match e["type"]:
		&"damage":
			return "%s blocked" % unit_name(b, e["target"]) if int(e["amount"]) == 0 else "%s −%d" % [unit_name(b, e["target"]), e["amount"]]
		&"nullified":
			return "%s nullified" % unit_name(b, e["target"])
		&"healed":
			return "%s +%d" % [unit_name(b, e["target"]), e["amount"]]
		&"survived":
			return "%s survives at 1 HP" % unit_name(b, e["target"])
		&"defeated":
			return "%s falls" % unit_name(b, e["who"])
		&"displaced", &"retreated":
			var way := ""
			if e.has("from"):                         # the compass direction of the move
				var step: Vector2i = e["to"] - e["from"]
				way = " %s" % dir_name(Vector2i(signi(step.x), signi(step.y)))
			return "%s%s → %s%s" % [unit_name(b, e["who"]), way, pos(e["to"]), " (zone)" if String(e.get("cause", "")) == "zone" else ""]
		&"retreat_failed":
			return "%s cannot retreat" % unit_name(b, e["who"])
		&"collision":
			return "%s collides" % (unit_name(b, e["who"]) if e.has("who") else _prop_name(b, e["prop"]))
		&"unmoved":
			return "%s stays" % (unit_name(b, e["who"]) if e.has("who") else _prop_name(b, e["prop"]))
		&"blanked":
			return "Mountain blocks"
		&"prop_moved":
			return "%s → %s" % [_prop_name(b, e["prop"]), pos(e["to"])]
		&"choice_needed":
			return "Dragon Vein: choose the target"
		&"choice_made":
			return "Dragon Vein target: %s" % unit_name(b, e["unit"])
		&"prop_hit":
			return "%s −%d" % [_prop_name(b, e["prop"]), e["amount"]]
		&"prop_destroyed":
			return "%s breaks" % _prop_name(b, e["prop"])
		&"vein_taken":
			return "%s takes a Dragon Vein" % unit_name(b, e["who"])
		&"trap_sprung":
			return "%s springs %s" % [unit_name(b, e["who"]) if e.get("who", &"") != &"" else _prop_name(b, e["by"]), _prop_name(b, e["prop"])]
		&"stamina_recovered":
			return "%s Stamina +%d" % [unit_name(b, e["who"]), e["amount"]]
		&"heal_used":
			return "%s heals: Stamina −%d" % [unit_name(b, e["who"]), e["spent"]]
		&"prop_placed":
			return "+ %s" % _prop_name(b, e["prop"])
		&"mountain_raised":
			return "+ Mountain"
		&"mountain_destroyed":
			return "Mountain breaks"
		&"ground_changed":
			var g := b.content.ground(e["ground"])
			return g.label(int(e["level"])) if g != null else String(e["ground"])
		&"effect_applied":
			return "%s: %s %d" % [unit_name(b, e["target"]), e["tag"], e["value"]]
		&"beast_swapped":
			return "%s ⇄ %s" % [unit_name(b, e["out"]), unit_name(b, e["in"])]
	return ""


# ---------- cast preview ----------

## Zone changes of a dry run, grouped: "2 new, 1 levels up → II".
static func _zone_summary(events: Array) -> String:
	var counts := {}
	var order: Array = []
	for e: Dictionary in events:
		if e["type"] != &"zone_changed":
			continue
		var label := String(e["result"])
		match e["result"]:
			&"level", &"weaken":
				label = "%s → %s" % ["level up" if e["result"] == &"level" else "weakens", ROMAN[clampi(int(e["level"]), 1, 3) - 1]]
			&"cancel":
				label = "cancels"
			&"replace":
				label = "replaces"
		if not counts.has(label):
			order.append(label)
		counts[label] = int(counts.get(label, 0)) + 1
	var parts: PackedStringArray = []
	for label: String in order:
		parts.append("%d %s" % [counts[label], label])
	return ", ".join(parts)


static func _briefs(b: Battle, events: Array) -> Array[String]:
	var out: Array[String] = []
	for e: Dictionary in events:
		var line := brief(b, e)
		if line != "":
			out.append(line)
	return _merge(out)


## Lines of a cast preview from `Battle.preview`: what happens now and, for a Surge, what its
## detonation would do if nothing changed until then. Equal lines are merged ("Lava I ×4").
static func preview_lines(b: Battle, p: Dictionary) -> Array[String]:
	var out: Array[String] = []
	if not p["ok"]:
		out.append("✗ " + String(p["error"]))
		return out
	var after: Battle = p["after"]
	var zones := _zone_summary(p["events"])
	if zones != "":
		out.append(zones)
	out.append_array(_briefs(after, p["events"]))
	var fired: Array = p["forecast"]
	if not fired.is_empty():
		var later := _briefs(after, fired)
		out.append("when it fires:" if not later.is_empty() else "when it fires: no hit")
		for line in later:
			out.append("  " + line)
	return out


static func _merge(src: Array[String]) -> Array[String]:
	var counts := {}
	var order: Array[String] = []
	for l in src:
		if not counts.has(l):
			order.append(l)
		counts[l] = int(counts.get(l, 0)) + 1
	var out: Array[String] = []
	for l in order:
		out.append(l + (" ×%d" % counts[l] if counts[l] > 1 else ""))
	return out
