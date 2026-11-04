class_name Aspect
extends RefCounted
## Aspect triangle: Force > Nature > Dark > Force (GDD §5).

enum Type { NONE, FORCE, NATURE, DARK }

const ATTUNEMENT_NAMES := {
	Type.FORCE: "Scorched",
	Type.NATURE: "Overgrown",
	Type.DARK: "Cursed",
}

const NAMES := {
	Type.NONE: "Neutral",
	Type.FORCE: "Force",
	Type.NATURE: "Nature",
	Type.DARK: "Dark",
}


## True if `a` beats `b`.
static func beats(a: Type, b: Type) -> bool:
	return (
		(a == Type.FORCE and b == Type.NATURE)
		or (a == Type.NATURE and b == Type.DARK)
		or (a == Type.DARK and b == Type.FORCE)
	)


## Strength modifier of a zone/Surge of `aspect` on a square attuned to `att` (GDD §7.5):
## +1 on its own aspect, -1 if the square's aspect beats it, else 0.
## `native` (passive Native Ground): +2 on its own aspect and never -1.
static func attunement_mod(aspect: Type, att: Type, native: bool = false) -> int:
	if att == Type.NONE or aspect == Type.NONE:
		return 0
	if att == aspect:
		return 2 if native else 1
	if beats(att, aspect):
		return 0 if native else -1
	return 0
