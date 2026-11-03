class_name Square
extends RefCounted
## One board square: the stack from GDD §7 (ground, object, surge, zone, air).

enum GroundType { PLAIN, RUBBLE, VOIDSCAR, LAVA }

var pos := Vector2i.ZERO

# Ground (permanent, the board's memory)
var ground: GroundType = GroundType.PLAIN
var lava_level := 1          # 1-2, only for LAVA
var elevated := false        # height
var attunement: Aspect.Type = Aspect.Type.NONE

# Layers
var object = null            # {name, hp, max_hp} or null (becomes a Resource later)
var surge = null             # {owner, aspect, name, value, fire_after, gid} or null
var zone = null              # {def: ZoneDef, gid, owner, level, duration} or null


func _init(p: Vector2i = Vector2i.ZERO) -> void:
	pos = p


## Attunement can't be held by Voidscar, Rubble or Elevated squares (GDD §7.6).
func set_attunement(a: Aspect.Type) -> void:
	if ground == GroundType.VOIDSCAR or ground == GroundType.RUBBLE or elevated:
		return
	attunement = a


## Surge damage on this square for a Surge of `aspect`/`value` (GDD §11.2).
func surge_damage(aspect: Aspect.Type, value: int) -> int:
	if elevated:
		return 0
	var shield := 0
	if zone != null:
		shield = zone["def"].shield(zone["level"], attunement)
	return maxi(0, value + Aspect.attunement_mod(aspect, attunement) - shield)
