class_name FieldEffect
extends Resource
## One entry of the shared effect vocabulary (gdd_battle §4.6, gdd_skills §4).
## Zones, blessed ground, aura props, timed unit effects and passives all use these tags, so a
## new source of an existing effect is data only. Recipient layers are authored per effect
## (gdd_battle §4.3: there is no default and no global "affects air" flag).

const SLOW := "slow"
const HASTE := "haste"
const DRAIN_INIT := "drain_init"
const QUICKEN := "quicken"
const DRAIN_RANGE := "drain_range"
const EXTEND := "extend"
const PUSH := "push"
const PULL := "pull"
const SHIELD := "shield"
const EXPOSE := "expose"      # reserved: no approved source (gdd_battle §4.6)
const MEND := "mend"

const TAGS: Array[String] = [SLOW, HASTE, DRAIN_INIT, QUICKEN, DRAIN_RANGE, EXTEND, PUSH, PULL, SHIELD, EXPOSE, MEND]
## Every effect but `mend` has an opposite; zones are compared by effects, never by name.
const OPPOSITE := {
	SLOW: HASTE, HASTE: SLOW,
	DRAIN_INIT: QUICKEN, QUICKEN: DRAIN_INIT,
	DRAIN_RANGE: EXTEND, EXTEND: DRAIN_RANGE,
	PUSH: PULL, PULL: PUSH,
	SHIELD: EXPOSE, EXPOSE: SHIELD,
}

@export_enum("slow", "haste", "drain_init", "quicken", "drain_range", "extend", "push", "pull", "shield", "expose", "mend")
var tag: String = SLOW
## Level-to-value (gdd_battle §4.6): value = min(cap, base + level - 1), min 1.
## The definition owns base and cap; level III never implies value 3.
@export var base: int = 1
@export var cap: int = 1
@export var affects_ground: bool = true
@export var affects_air: bool = false


static func make(p_tag: String, p_base := 1, p_cap := -1, p_air := false, p_ground := true) -> FieldEffect:
	var e := FieldEffect.new()
	e.tag = p_tag
	e.base = p_base
	e.cap = p_base if p_cap < 0 else p_cap
	e.affects_air = p_air
	e.affects_ground = p_ground
	return e


func value_at(level: int) -> int:
	return maxi(1, mini(cap, base + level - 1))


func affects_layer(layer: int) -> bool:
	return affects_air if layer == 1 else affects_ground


func text(level := 1) -> String:
	return "%s %d" % [tag, value_at(level)]
