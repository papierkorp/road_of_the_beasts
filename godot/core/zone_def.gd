class_name ZoneDef
extends Resource
## Zone definition as data (GDD §7.1). Lives in res://data/zones/*.tres.

@export var id: StringName
@export var display_name: String
@export var aspect: Aspect.Type = Aspect.Type.NATURE
@export var effects: Array[ZoneEffect] = []


## Live effective values for a zone of `level` on a square attuned to `att`.
## Returns Array of {tag: ZoneEffect.Tag, value: int}.
## value = min(cap, base + level - 1) + attunement, min 1; slow capped at 2;
## push/pull are always 1 (GDD §7.1).
func effective(level: int, att: Aspect.Type) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var mod := Aspect.attunement_mod(aspect, att)
	for e in effects:
		var v: int
		if e.tag == ZoneEffect.Tag.PUSH or e.tag == ZoneEffect.Tag.PULL:
			v = 1
		else:
			v = maxi(1, mini(e.cap, e.base + level - 1) + mod)
			if e.tag == ZoneEffect.Tag.SLOW:
				v = mini(2, v)
		out.append({"tag": e.tag, "value": v})
	return out


func shield(level: int, att: Aspect.Type) -> int:
	var total := 0
	for e in effective(level, att):
		if e["tag"] == ZoneEffect.Tag.SHIELD:
			total += e["value"]
	return total
