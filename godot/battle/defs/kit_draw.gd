class_name KitDraw
extends RefCounted
## Random kits for trying things out (test switches "Random kits" and "New skills every battle" of the
## multiplayer mode, tools/skill_impact.gd). A kit template names no skill: it only says how many skills of
## each kind a kit holds. The kinds are those of SkillGen.KINDS: strike, move, zone, ground, prop.
## Nothing here is content: a drawn kit lives on the unit sheet of one battle and is never written to a file.

## Kit templates: six slots each, at least one Strike and one movement skill.
const TEMPLATES := [
	{"name": "Balanced", "strike": 2, "move": 1, "zone": 1, "ground": 1, "prop": 1},
	{"name": "Bruiser", "strike": 3, "move": 2, "zone": 0, "ground": 1, "prop": 0},
	{"name": "Skirmisher", "strike": 2, "move": 2, "zone": 1, "ground": 0, "prop": 1},
	{"name": "Controller", "strike": 1, "move": 1, "zone": 2, "ground": 2, "prop": 0},
	{"name": "Trapper", "strike": 1, "move": 1, "zone": 0, "ground": 1, "prop": 3},
	{"name": "Shaper", "strike": 1, "move": 1, "zone": 1, "ground": 1, "prop": 2},
]


## The kind of a skill: one of SkillGen.KINDS, "self" for a self buff, "" for passives and retired kinds.
static func kind_of(content: BattleContent, s: BattleSkillDef) -> String:
	match s.kind:
		BattleSkillDef.STRIKE:
			return "strike"
		BattleSkillDef.MOVE:
			return "move"
		BattleSkillDef.BUFF:
			return "self"                             # no template counts self buffs; SkillCalc and the measuring runs do
		BattleSkillDef.ZONE:
			return "zone"
		BattleSkillDef.GROUND:
			if s.has_op(BoardOp.CREATE_PROP):
				return "prop"
			for op in s.ops_of(BoardOp.CREATE_ZONE):
				var z := content.zone(op.zone)
				if z != null and (z.has_tag(FieldEffect.PUSH) or z.has_tag(FieldEffect.PULL) or z.has_tag(FieldEffect.ERODE)):
					return "zone"
			return "ground" if s.has_op(BoardOp.GROUND) else ("zone" if s.has_op(BoardOp.CREATE_ZONE) else "")
	return ""


## The skills of the game by kind: {kind: [BattleSkillDef]}.
static func pools(content: BattleContent) -> Dictionary:
	var out := {}
	for kind in SkillGen.KINDS:
		out[kind] = []
	for id: StringName in BattleContent.sorted_ids(content.skills):
		var s: BattleSkillDef = content.skills[id]
		var kind := kind_of(content, s)
		if ContentStatus.in_game(s) and out.has(kind):
			out[kind].append(s)
	return out


static func template(rng: RandomNumberGenerator) -> Dictionary:
	return TEMPLATES[rng.randi_range(0, TEMPLATES.size() - 1)]


## A kit by a template. `fresh` = every skill is newly generated (SkillGen.draw_kind with `ap`, see there);
## otherwise the skills are drawn from the game's own, none twice. The first Strike deals damage.
## `number` makes the ids of generated skills unique within a battle.
static func kit(content: BattleContent, rng: RandomNumberGenerator, tpl: Dictionary, fresh: bool, number := 0, ap := -1) -> Array[BattleSkillDef]:
	var out: Array[BattleSkillDef] = []
	var from := {} if fresh else pools(content)
	for kind in SkillGen.KINDS:
		for i in int(tpl.get(kind, 0)):
			var must_hit: bool = kind == "strike" and i == 0
			var s: BattleSkillDef = null
			for attempt in 40:
				var c: BattleSkillDef
				if fresh:
					c = SkillGen.draw_kind(content, rng, kind, number * 10 + out.size(), ap)
				else:
					var pool: Array = from[kind]
					if pool.is_empty():
						break
					c = pool[rng.randi_range(0, pool.size() - 1)]
				if out.has(c) or (must_hit and c.strike_damage <= 0):
					continue
				s = c
				break
			if s != null:
				if fresh:
					s.content_status = ContentStatus.EXPERIMENT
				out.append(s)
	return out


## Gives every monster of a battle that has not begun a kit by a template of its own (`BattleSetup.build`
## calls this when a kit switch is on). The same seed gives the same kits.
## `mirror`: a unit of side 1 plays the kit of the unit of side 0 in the same slot.
static func deal(b: Battle, kit_seed: int, fresh: bool, ap := -1, mirror := false) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = kit_seed
	var number := 0
	var first := {}                               # slot -> [template, skills] of side 0
	for id in b.roster:
		var u: BattleUnit = b.units[id]
		var tpl: Dictionary
		if mirror and u.side == 1 and first.has(u.slot):
			tpl = first[u.slot][0]
			var same: Array[BattleSkillDef] = []
			same.assign(first[u.slot][1])
			u.sheet.skills = same
		else:
			tpl = template(rng)
			u.sheet.skills = kit(b.content, rng, tpl, fresh, number, ap)
			if u.side == 0:
				first[u.slot] = [tpl, u.sheet.skills]
		u.sheet.notes.append("random kit: %s" % tpl["name"])
		u.sheet.set_meta("kit_template", tpl["name"])
		number += 1
