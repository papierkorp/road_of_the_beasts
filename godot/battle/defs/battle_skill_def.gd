class_name BattleSkillDef
extends Resource
## One monster skill in the shared model of gdd_skills §2. Lives in
## res://data/skills/<id>.tres. `kind` selects the execution profile (gdd_skills §3);
## the groups below hold the data that profile reads. Nothing here is executable: resolution
## lives in battle/core, so a new skill that recombines existing fields needs no code.
##
## All shipped records are test data / GDD drafts (T10–T12 are open): `content_status` is the
## label the game filters on, `status` a free note on the origin.

const STRIKE := "strike"
const SURGE := "surge"
const TRAP := "trap"
const ZONE := "zone"
const GROUND := "ground"      # immediate board operations (Field, Blessing, Raise Ground, Raise Prop)
const MOVE := "move"
const BUFF := "buff"
const PASSIVE := "passive"

@export var id: StringName
@export var display_name: String
## No default: every record states its kind (a missing one is a content problem).
@export_enum("strike", "surge", "trap", "zone", "ground", "move", "buff", "passive") var kind: String = ""
@export_multiline var description: String = ""
## Where the record stands (ContentStatus): test-only and simulation-only records are never fielded by the game.
@export_enum("approved", "draft", "test", "simulation", "archived") var content_status: String = ContentStatus.DRAFT
## Free note on the origin, e.g. "test data (Skills §10 prior draft)" or "GDD reference (Skills §11)".
@export var status: String = "test data"
## Internal calculation cost in construction points (gdd_skills §5 working drafts): an
## authoring note, not a rule, not a player value and not settled. For a Strike it is the
## Beast (no Kin package) total of its shape; Surge kits have none yet (trap prices open, T02).
## -1 = not calculated.
@export var internal_calc_cost: float = -1.0

@export_group("Usage")
## Battle-AP per use (at least 1; passives ignore it). Strikes take the cost of their shape.
@export var ap_cost: int = 1
## Per equipped instance (gdd_skills §2 Usage and Repetition). once_per_battle is the Major
## Surge profile limit; no multi-round cooldowns exist.
@export_enum("repeatable", "once_per_round", "once_per_battle") var repetition: String = "repeatable"

@export_group("Placement and area")
## reach: anchor within effective Reach (Manhattan) · adjacent: anchor next to the caster ·
## trail: straight line starting next to the caster · caster_ring: the cardinal neighbours.
@export_enum("reach", "adjacent", "trail", "caster_ring") var anchor_mode: String = "reach"
## Explicit offsets from the anchor, fixed board orientation (no rotation, no trimming).
## trail: authored along +x from the anchor and turned into the chosen direction.
@export var footprint: Array[Vector2i] = []
## Surge only: a line footprint is stopped by the first prop along it, starting at the first offset.
@export var line_shaped: bool = false

@export_group("Strike")
@export_enum("jab", "thrust", "diagonal_thrust", "pincer", "arc", "whirl", "cross", "storm", "cleave", "long_whirl", "long_cross")
var strike_shape: String = "jab"
## 2 for every Strike; 0 for a movement-only body-relative variant.
@export var strike_damage: int = 2
## Applies the striker's Kin twist (KinRules). Body-relative variants are separate skills.
@export var kin_effect: bool = true
## Body-relative variant (Scaled): struck monsters next to the origin are pushed 1 outward.
@export var radial_push: bool = false
## Body-relative variant (Winged): retreat 1 opposite the shape centre after the attack.
@export var self_retreat: bool = false

@export_group("Surge")
@export var surge_damage: int = 3
@export var surge_hits_air: bool = false
## Mountain squares in the footprint: hit normally · blank (cannot reach) · the Mountain is
## destroyed through an explicit destroy_mountain board operation (authored below).
@export_enum("hit", "blank") var surge_mountain: String = "hit"
## Struck monsters are pushed in the cast direction or pulled toward the cast anchor.
@export_enum("none", "push", "pull") var surge_displacement: String = "none"
## Surge and trap are separate kinds that share this group (user decisions 2026-11-12, T38):
##   kind surge  cast on any squares, also under monsters; detonates after `surge_turns`
##               finished turns of any monster; replaces a trap on the squares it covers
##   kind trap   set on monster-free squares without a marker; stays until something springs it
## Surge only: turns of any monster that finish after the cast turn before it detonates.
@export var surge_turns: int = 2
## Trap only: what springs it: "any" = a monster, a new
## prop or a new Mountain on its squares; "monsters" = only a monster.
@export_enum("any", "monsters") var trap_trigger: String = "any"

@export_group("Zone / timed effect")
@export var zone: BattleZoneDef
## Rounds a created zone or a timed self effect lasts.
@export var duration: int = 2
## kind buff: effects applied to the caster for `duration` rounds.
@export var buff_effects: Array[FieldEffect] = []

@export_group("Board changes")
@export var board_ops: Array[BoardOp] = []

@export_group("Movement")
@export_enum("walk", "line", "free", "teleport") var move_path: String = "walk"
@export var blocked_by_objects: bool = true
@export var blocked_by_monsters: bool = true
@export var blocked_by_surges: bool = true
## Cannot start or end the move on a Mountain.
@export var blocked_by_height: bool = false
## Rubble and climbing cost 2 movement.
@export var ground_costs: bool = true
## distance = effective Movement + this (min 1).
@export var distance_mod: int = 0
## > 0: a fixed distance that ignores Movement and `slow` (Step: 1).
@export var fixed_distance: int = 0
## Movement with displacement (temp_todo T38): after landing, "ahead" pushes the monster on
## the next square in the travel direction 1 square on (a headbutt), "ring" pushes every
## monster on the eight neighbouring squares 1 square outward (a shockwave).
@export_enum("none", "ahead", "ring") var impact_push: String = "none"

@export_group("Passive")
## Continuous stat effects while equipped (condition below).
@export var passive_effects: Array[FieldEffect] = []
@export_enum("always", "on_mountain") var passive_condition: String = "always"
## Effect tags of other sources this monster ignores (e.g. slow, drain_init).
@export var ignores_effects: Array[String] = []
## Ground types whose triggers this monster ignores.
@export var ignores_grounds: Array[StringName] = []
## Damage types this monster takes less of: strike, surge, collision, collision_self
## (collision_self = only when it is the one pushed or pulled).
@export var reduces_damage: Array[String] = []
@export var reduction: int = 1
## Ignores push and pull.
@export var immovable: bool = false
## Cannot move voluntarily (Step and movement skills).
@export var rooted: bool = false
## Allies orthogonally adjacent cannot be pushed or pulled.
@export var anchors_adjacent_allies: bool = false
## Allies orthogonally adjacent take this much less Surge damage.
@export var guards_adjacent_allies: int = 0
## May rotate its own fixed footprints in battle (rule modifier, gdd_skills §11 Adaptive).
@export var rotate_shapes: bool = false
## Moves through solid props (may not stop on them).
@export var phasing: bool = false
## Event-driven reaction (gdd_battle §2.4): at most once per triggering event.
@export_enum("none", "prop_destroyed_in_reach") var react_event: String = "none"
@export var react_heal: int = 0


func is_active() -> bool:
	return kind != PASSIVE


## Surge or trap: the two kinds that put a marker on the board and detonate.
func is_marker() -> bool:
	return kind == SURGE or kind == TRAP


func is_placed() -> bool:
	return kind == SURGE or kind == TRAP or kind == ZONE or kind == GROUND


func cost() -> int:
	if kind == STRIKE:
		return StrikeShapes.ap(StringName(strike_shape))
	if kind == MOVE and BattleExperiment.move_ap > 0:
		return BattleExperiment.move_ap          # test switch
	return maxi(1, ap_cost)


## A cast-time cardinal direction is needed for push zones and pushing Surges.
func needs_direction() -> bool:
	if kind == ZONE and zone != null:
		return zone.has_tag(FieldEffect.PUSH)
	return is_marker() and surge_displacement == "push"


func needs_anchor() -> bool:
	return is_placed() and anchor_mode != "caster_ring"


func ops_of(op: String) -> Array[BoardOp]:
	var out: Array[BoardOp] = []
	for o in board_ops:
		if o.op == op:
			out.append(o)
	return out


func has_op(op: String) -> bool:
	return not ops_of(op).is_empty()


## True if one of this skill's ground operations may change ground on Mountain squares.
func grounds_mountains() -> bool:
	for o in ops_of(BoardOp.GROUND):
		if o.on_mountain:
			return true
	return false


static func rotated(offset: Vector2i, quarter_turns: int) -> Vector2i:
	var o := offset
	for _i in posmod(quarter_turns, 4):
		o = Vector2i(-o.y, o.x)
	return o


## Authored offsets after `rot` quarter turns (only the Adaptive permission passes rot != 0).
func offsets(rot := 0) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for o in footprint:
		out.append(rotated(o, rot))
	return out


func kind_label() -> String:
	match kind:
		STRIKE:
			return "Strike"
		SURGE:
			return "Surge"
		TRAP:
			return "Trap"
		ZONE:
			return "Zone"
		GROUND:
			return "Board"
		MOVE:
			return "Movement"
		BUFF:
			return "Self buff"
	return "Passive"
