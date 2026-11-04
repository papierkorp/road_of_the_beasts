class_name ZoneEffect
extends Resource
## One effect tag of a zone definition (GDD §7.3). Every tag has an opposite;
## zones are compared by their effects, never by their names.

## New tags are appended so existing .tres files keep their numbers.
enum Tag { SLOW, DRAIN_INIT, DRAIN_RANGE, PULL, PUSH, SHIELD, HASTE, QUICKEN, EXTEND, EXPOSE }

const OPPOSITE := {
	Tag.SLOW: Tag.HASTE, Tag.HASTE: Tag.SLOW,
	Tag.DRAIN_INIT: Tag.QUICKEN, Tag.QUICKEN: Tag.DRAIN_INIT,
	Tag.DRAIN_RANGE: Tag.EXTEND, Tag.EXTEND: Tag.DRAIN_RANGE,
	Tag.PUSH: Tag.PULL, Tag.PULL: Tag.PUSH,
	Tag.SHIELD: Tag.EXPOSE, Tag.EXPOSE: Tag.SHIELD,
}

@export var tag: Tag = Tag.SLOW
@export var base: int = 1
@export var cap: int = 1


static func label(t: Tag) -> String:
	return Tag.keys()[t].to_lower()
