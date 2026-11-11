class_name BattleZoneDef
extends Resource
## A zone definition (gdd_battle §4.6). Lives in res://data/battle/zones/<id>.tres.
## The zone's duration belongs to the skill that casts it; the board state stores the level.

const MAX_LEVEL := 3

@export var id: StringName
@export var display_name: String
@export var effects: Array[FieldEffect] = []
@export var color: Color = Color(0.5, 0.7, 0.9)


func effect(tag: String) -> FieldEffect:
	for e in effects:
		if e.tag == tag:
			return e
	return null


func has_tag(tag: String) -> bool:
	return effect(tag) != null


## True if any effect of this zone is the opposite of any effect of `other`.
func opposes(other: BattleZoneDef) -> bool:
	for e in effects:
		for f in other.effects:
			if FieldEffect.OPPOSITE.get(e.tag, "") == f.tag:
				return true
	return false


func effects_text(level := 1) -> String:
	var parts: PackedStringArray = []
	for e in effects:
		parts.append(e.text(level))
	return ", ".join(parts)
