class_name Square
extends RefCounted
## One board square: the stack from GDD §7 (ground, object, surge, zone).

enum GroundType { PLAIN, RUBBLE, VOIDSCAR, LAVA, THORNBED, BLIGHT }

const PERMANENT := -1

var pos := Vector2i.ZERO

# Ground layer (the board's memory, GDD §7.4)
var ground: GroundType = GroundType.PLAIN
var level := 1               # aspect grounds: 1-2 = damage per trigger
var timer := PERMANENT       # rounds left for timed ground (Surge residue), PERMANENT otherwise
var elevated := false
var attunement: Aspect.Type = Aspect.Type.NONE

# Layers
## {name, hp, max_hp, tags: Array[String], burning: bool, healed: bool} or null
var object = null
## {owner, type, aspect, name, value, turns_left, dir, anchor, gid, twist, residue, native, painter} or null
var surge = null
## {def: ZoneDef, gid, owner, level, duration, dir, anchor, native} or null
var zone = null


func _init(p: Vector2i = Vector2i.ZERO) -> void:
	pos = p


static func ground_aspect_of(t: GroundType) -> Aspect.Type:
	match t:
		GroundType.LAVA:
			return Aspect.Type.FORCE
		GroundType.THORNBED:
			return Aspect.Type.NATURE
		GroundType.BLIGHT:
			return Aspect.Type.DARK
	return Aspect.Type.NONE


static func ground_name(t: GroundType) -> String:
	return GroundType.keys()[t].capitalize()


func ground_aspect() -> Aspect.Type:
	return ground_aspect_of(ground)


func is_aspect_ground() -> bool:
	return ground_aspect() != Aspect.Type.NONE


func has_tag(tag: String) -> bool:
	return object != null and object["tags"].has(tag)


## Attunement can't be held by Voidscar, Rubble or Elevated squares (GDD §7.5).
func set_attunement(a: Aspect.Type) -> void:
	if ground == GroundType.VOIDSCAR or ground == GroundType.RUBBLE or elevated:
		return
	attunement = a


## Lays an aspect ground (GDD §7.4). `rounds` = PERMANENT (Field) or a residue timer.
## Same type: +1 level (max II), the longer lifetime wins. Other type: replaced. Voidscar: refused.
func lay_ground(t: GroundType, rounds: int) -> bool:
	if ground == GroundType.VOIDSCAR:
		return false
	if ground == t:
		level = mini(2, level + 1)
		if timer != PERMANENT:
			timer = PERMANENT if rounds == PERMANENT else maxi(timer, rounds)
	else:
		ground = t
		level = 1
		timer = rounds
	set_attunement(ground_aspect_of(t))
	return true


## Back to Plain (attunement stays unless the caller changes it).
func clear_ground() -> void:
	if ground == GroundType.VOIDSCAR:
		return
	ground = GroundType.PLAIN
	level = 1
	timer = PERMANENT


## Shattered prop, collapsed Elevated: neutral Rubble.
func make_rubble() -> void:
	elevated = false
	ground = GroundType.RUBBLE
	level = 1
	timer = PERMANENT
	attunement = Aspect.Type.NONE


static func make_prop(prop_name: String) -> Dictionary:
	match prop_name:
		"Wall":
			return {"name": "Wall", "hp": 2, "max_hp": 2, "tags": ["brittle"], "burning": false, "healed": false}
		"Tree":
			return {"name": "Tree", "hp": 2, "max_hp": 2, "tags": ["flammable"], "burning": false, "healed": false}
		"Rock":
			return {"name": "Rock", "hp": 3, "max_hp": 3, "tags": ["heavy"], "burning": false, "healed": false}
		"Pillar":
			return {"name": "Pillar", "hp": 99, "max_hp": 99, "tags": ["indestructible", "heavy"], "burning": false, "healed": false}
	return {"name": prop_name, "hp": 1, "max_hp": 1, "tags": [], "burning": false, "healed": false}
