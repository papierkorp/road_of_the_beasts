class_name PriceComponent
extends Resource
## One priced part of a skill price record (gdd_skills §5 "Component Price Sheet").
## `type` selects the rate; the groups below hold the values that rate reads, the same way
## `BattleSkillDef.kind` selects a profile. Data only: the rates and the arithmetic live in
## res://tools/lib/skill_pricing.gd, and a value that has no rate there is refused, never free.

const DAMAGE := "damage"
const STRIKE_EXTRAS := "strike_extras"
const ANCHOR := "anchor"
const MARKER := "marker"
const ZONE := "zone"
const DISPLACEMENT := "displacement"
const GROUND := "ground"
const MOVE := "move"
const SELF_BUFF := "self_buff"
const ROTATION := "rotation"
const NULLIFY := "nullify"
const RELOCATE := "relocate"
const PROP := "prop"
const AIR_COVERAGE := "air_coverage"

@export_enum("damage", "strike_extras", "anchor", "marker", "zone", "displacement", "ground", "move", "self_buff",
	"rotation", "nullify", "relocate", "prop", "air_coverage") var type: String = DAMAGE

@export_group("Cells, rounds, timing")
## Potentially affected cells of a damage, zone, displacement or ground component.
@export var cells: int = 0
## Rounds a zone or a self buff lasts.
@export var rounds: int = 0
## Damage and displacement: a telegraphed, avoidable effect is priced at half.
@export_enum("immediate", "telegraphed_avoidable") var timing: String = "immediate"

@export_group("Damage")
## Damage per struck monster.
@export var damage: int = 0
## Ground and air recipients (+2 once; Strikes and authorized sources).
@export var ground_air: bool = false

@export_group("Strike extras")
## The Kin package this Strike is priced with.
@export_enum("beast", "winged", "scaled", "swarm", "spirit", "ancient") var kin: String = "beast"
## Hit cells the Kin package can affect.
@export var kin_cells: int = 0
## Hit cells outside the adjacent ring.
@export var distant_cells: int = 0
## The chosen direction changes the hit cells.
@export var direction: bool = false

@export_group("Anchor")
@export_enum("free", "adjacent", "none") var anchor_mode: String = "free"

@export_group("Zone")
@export_enum("slow", "haste", "drain_init", "quicken", "drain_range", "extend", "push", "pull", "shield", "expose", "mend")
var effect: String = "slow"
## The authored level-I value.
@export var value: int = 0

@export_group("Ground")
## A ground package of the rate table (level-I hazards, blessed ground, Mountain operations).
@export_enum("plain", "rubble", "lava_1", "thornbed_1", "blight_1", "hearth", "umbra", "hallowed", "mossbed",
	"mountain_reset", "mountain_destroy", "hazard_2_start") var ground: String = "plain"

@export_group("Movement")
@export_enum("run", "leap", "glide", "burrow", "phase", "blink") var preset: String = "run"
@export var patches: int = 0

@export_group("Self buff")
@export_enum("initiative") var stat: String = "initiative"
@export var magnitude: int = 0

@export_group("Relocate")
@export var props: int = 0

@export_group("Prop creation")
@export_enum("base", "sturdy") var prop_tier: String = "base"
@export_enum("ground", "air", "both") var prop_layer: String = "ground"
@export var aftermath_damage_squares: int = 0
@export var aftermath_push_squares: int = 0
@export var beam_squares: int = 0
@export_enum("plain", "rubble", "lava_1", "thornbed_1", "blight_1", "hearth", "umbra", "hallowed", "mossbed",
	"mountain_reset", "mountain_destroy", "hazard_2_start") var aftermath_ground: String = "plain"
@export var aura: bool = false


## A component built in code (tests): `fields` maps property names to values.
static func make(p_type: String, fields: Dictionary = {}) -> PriceComponent:
	var c := PriceComponent.new()
	c.type = p_type
	for key: String in fields:
		c.set(key, fields[key])
	return c
