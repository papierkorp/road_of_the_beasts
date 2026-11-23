class_name MonsterLook
extends RefCounted
## The colour a monster is drawn in: the colour of its aspect. Its body is built by `MonsterBody`.


static func aspect_color(a: Aspect.Type) -> Color:
	match a:
		Aspect.Type.FORCE:
			return Color(0.89, 0.35, 0.23)
		Aspect.Type.NATURE:
			return Color(0.31, 0.68, 0.50)
		Aspect.Type.DARK:
			return Color(0.54, 0.39, 0.79)
	return Color(0.6, 0.6, 0.6)
