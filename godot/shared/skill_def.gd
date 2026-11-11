class_name SkillDef
extends Resource
## LEGACY species skill of the overworld model (skill evolution, datasheets). Lives in
## res://data/skills/*.tres. The battle no longer resolves these: it reads BattleSkillDef
## records (res://data/battle/skills) through the unit-sheet adapter (battle/core/unit_sheets.gd).

enum Kind { SURGE, ZONE, GROUND, HEIGHT, PROP }
## Ground laid by a legacy Field skill (numbers are stored in the .tres files).
enum GroundType { PLAIN, RUBBLE, VOIDSCAR, LAVA, THORNBED, BLIGHT }
enum SurgeType { NONE, ERUPTION, FLOOD, RIFT }
enum Twist { NONE, POUNCE, TRAIL, RING, LOB, WIDE, SLOW_BURN, LINGERING, CONSTRICT }

const SURGE_BASE_DAMAGE := {SurgeType.ERUPTION: 3, SurgeType.FLOOD: 2, SurgeType.RIFT: 3}

@export var id: StringName
@export var display_name: String
## Archetype from GDD §9.4.1 (Surge, Field, Snare, Current, Hex, Veil, Raise Prop, Raise Ground, …)
@export var archetype: StringName
@export var kind: Kind = Kind.ZONE
@export var aspect: Aspect.Type = Aspect.Type.NONE
## kind ZONE
@export var zone: ZoneDef
## kind GROUND (Field): the hazard ground it lays
@export var ground_type: GroundType = GroundType.LAVA
## Exactly one shape family. Its orientation is fixed in battle (absolute on the board);
## shapes are tuned outside battle (overworld). Passive Adaptive may rotate in battle.
@export var shapes: Array[StringName] = []
@export var orientation: int = 0
@export var cast_range: int = 3
## kind SURGE
@export var surge_type: SurgeType = SurgeType.NONE
@export var twist: Twist = Twist.NONE
## Currents (push) and Flood: the caster sets a direction at cast
@export var directional: bool = false
@export_multiline var description: String = ""

## Set by skill evolution (gdd_overworld §4.7); runtime only, never stored in the .tres files.
var range_bonus := 0        # cast range +1
var duration_bonus := 0     # zones last +1 round
var damage_penalty := 0     # a widened Surge deals less


static func ground_aspect_of(t: GroundType) -> Aspect.Type:
	match t:
		GroundType.LAVA:
			return Aspect.Type.FORCE
		GroundType.THORNBED:
			return Aspect.Type.NATURE
		GroundType.BLIGHT:
			return Aspect.Type.DARK
	return Aspect.Type.NONE


func orientations() -> Array[Dictionary]:
	return Shapes.orientations(shapes)


static func kind_name(k: Kind) -> String:
	return Kind.keys()[k].capitalize()


func is_pull() -> bool:
	return kind == Kind.ZONE and zone != null and zone.has_tag(ZoneEffect.Tag.PULL)


## Push zones and Floods take a direction; pull zones use their anchor.
func needs_direction() -> bool:
	return directional


## Surge damage per square before attunement and shields (GDD §9.3, twists §9.4.2).
func surge_value() -> int:
	var v: int = SURGE_BASE_DAMAGE.get(surge_type, 0)
	match twist:
		Twist.LOB, Twist.WIDE, Twist.LINGERING, Twist.CONSTRICT:
			v -= 1
		Twist.SLOW_BURN:
			v += 1
	return maxi(0, v - damage_penalty)


## Anchor range before Elevated bonus and drains.
func base_range() -> int:
	match twist:
		Twist.POUNCE:
			return 1
		Twist.RING:
			return 0
		Twist.LOB:
			return cast_range + range_bonus + 2
	return cast_range + range_bonus


## How many of the caster's turn starts until the Surge fires.
func fire_delay() -> int:
	return 2 if twist == Twist.SLOW_BURN else 1


func residue_rounds() -> int:
	return 3 if twist == Twist.LINGERING else 2


static func surge_type_name(t: SurgeType) -> String:
	return SurgeType.keys()[t].capitalize()


static func twist_name(t: Twist) -> String:
	if t == Twist.NONE:
		return ""
	var n: String = Twist.keys()[t].to_lower().replace("_", "-")
	return n.left(1).to_upper() + n.substr(1)
