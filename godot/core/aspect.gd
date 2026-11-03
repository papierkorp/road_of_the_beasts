class_name Aspect
extends RefCounted
## Aspect triangle: Force > Nature > Dark > Force (GDD §5).

enum Type { NONE, FORCE, NATURE, DARK }

const ATTUNEMENT_NAMES := {
	Type.FORCE: "Scorched",
	Type.NATURE: "Overgrown",
	Type.DARK: "Cursed",
}


## True if `a` beats `b`.
static func beats(a: Type, b: Type) -> bool:
	return (
		(a == Type.FORCE and b == Type.NATURE)
		or (a == Type.NATURE and b == Type.DARK)
		or (a == Type.DARK and b == Type.FORCE)
	)


## Strength modifier of a zone/Surge of `aspect` on a square attuned to `att`:
## +1 on its own aspect, -1 if the square's aspect beats it, else 0 (GDD §7.6).
static func attunement_mod(aspect: Type, att: Type) -> int:
	if att == Type.NONE:
		return 0
	if att == aspect:
		return 1
	return -1 if beats(att, aspect) else 0
