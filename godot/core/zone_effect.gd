class_name ZoneEffect
extends Resource
## One effect tag of a zone definition (GDD §7.1 / §7.4), e.g. slow base 1 cap 2.

enum Tag { SLOW, DRAIN_INIT, DRAIN_RANGE, PULL, PUSH, SHIELD }

@export var tag: Tag = Tag.SLOW
@export var base: int = 1
@export var cap: int = 1
