class_name PriceRecord
extends Resource
## The construction-point price record of one skill (gdd_skills §5 working drafts): what the
## skill is charged for, how it is available and, where one exists, the definition it prices.
## Lives in res://tools/data/prices/<id>.tres; the file name is the id.
##
## A record is an authoring reference, not game content and not approval. The calculation is
## res://tools/lib/skill_pricing.gd; `paper_total` is the GDD's own paper result, kept next to
## the components so a rate that drifts from the GDD shows up as a failing test.

const ACTIVE := "active"
const PASSIVE_BOOLEAN := "passive_boolean"
const EVENT_ONCE_PER_ROUND := "event_once_per_round"

@export var display_name: String = ""
## Availability basis. Repeatable or team-wide events have no price and are refused.
@export_enum("active", "passive_boolean", "event_once_per_round") var usage: String = ACTIVE
## Battle-AP per use (active records only).
@export var ap: int = 1
@export var once_per_round: bool = false
## Whether the round cap really restricts the skill (then availability is priced at 75 %).
## "unresolved" has no defensible number and fails closed.
@export_enum("unresolved", "effective", "not_effective") var round_cap: String = "unresolved"
@export var components: Array[PriceComponent] = []
## Total of the GDD's paper calculation for this record; negative = the GDD gives none.
@export var paper_total: float = -1.0
@export_multiline var note: String = ""

@export_group("Engine definition")
## The definition this record prices and a test build fights with: a content record of
## res://data/battle/skills or a fixture embedded here. Empty = a price reference only; a
## build with such a slot is reported as NOT SIMULATED. For a Strike the Kin comes from the
## monster, so one Strike definition serves the price records of several Kins.
@export var skill: BattleSkillDef
## Set when the definition uses geometry or values the GDD has not specified or approved.
@export_multiline var fixture: String = ""
