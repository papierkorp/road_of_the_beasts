class_name StructureDef
extends RefCounted
## A buildable structure of the Inner World (gdd_overworld §6.4): one schema, content as
## configurations ("archetypes over uniques"). Built in StructureCatalog.

enum Category { CULTIVATION, GROWING, HOUSING, PRODUCTION, SPECIAL }

var id: StringName
var display_name := ""
var category: Category = Category.SPECIAL
var size := Vector2i(1, 1)            # footprint in grid cells
var aspect: Aspect.Type = Aspect.Type.NONE
var color := Color(0.5, 0.5, 0.55)
var height := 1.0
var blurb := ""
## Materials needed to construct it from a blueprint: [{aspect: Aspect.Type (NONE = any), count}]
var recipe: Array[Dictionary] = []
var price := 0                        # spirit stones when the Trader sells it ready-made
var idle_xp := 0                      # cultivation: XP per night for the assigned monster
var water := false                    # counts as water for adjacency bonuses


static func category_name(c: Category) -> String:
	return Category.keys()[c].capitalize()


func recipe_text() -> String:
	var parts: Array[String] = []
	for r in recipe:
		var a: Aspect.Type = r["aspect"]
		parts.append("%d %s" % [r["count"], "any" if a == Aspect.Type.NONE else Aspect.NAMES[a]])
	return ", ".join(PackedStringArray(parts))
