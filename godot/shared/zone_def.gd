class_name ZoneDef
extends Resource
## Zone definition as data (GDD §7.1, §7.3, §9.5). Lives in res://data/zones/*.tres.

@export var id: StringName
@export var display_name: String
@export var aspect: Aspect.Type = Aspect.Type.NATURE
@export var effects: Array[ZoneEffect] = []

@export_group("Aspect side effects (§9.5)")
## Shockwave: +x collision damage when this zone pushes someone into a prop.
@export var collision_bonus: int = 0
## Kiln Shell: occupants ignore Lava.
@export var ignores_lava: bool = false
## Bark Veil: a prop on the square gets +1 HP once.
@export var heals_props: bool = false
## Shade Veil: Strike damage on this square -x.
@export var strike_shield: int = 0


func has_tag(t: ZoneEffect.Tag) -> bool:
	for e in effects:
		if e.tag == t:
			return true
	return false


## True if any effect of this zone is the opposite of any effect of `other` (GDD §7.3).
func opposes(other: ZoneDef) -> bool:
	for e in effects:
		for f in other.effects:
			if ZoneEffect.OPPOSITE.get(e.tag, -1) == f.tag:
				return true
	return false


## Live effective values: [{tag, value}].
## value = min(cap, base + level - 1) + attunement, min 1; slow capped at 2; push/pull always 1.
func effective(level: int, att: Aspect.Type, native: bool = false) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var mod := Aspect.attunement_mod(aspect, att, native)
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


func value_of(t: ZoneEffect.Tag, level: int, att: Aspect.Type, native: bool = false) -> int:
	var total := 0
	for e in effective(level, att, native):
		if e["tag"] == t:
			total += e["value"]
	return total
