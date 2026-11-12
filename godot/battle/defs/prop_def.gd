class_name PropDef
extends Resource
## A prop type (gdd_battle §4.9–§4.11). Lives in res://data/props/<id>.tres.
## Catalogue entries are GDD working drafts (names, HP and aftermath values until T13).

@export var id: StringName
@export var display_name: String
## Internal calculation cost in construction points (gdd_skills §5 working drafts): an
## authoring note, not a rule, not a player value and not settled. Per created prop (creation draft).
## -1 = not calculated.
@export var internal_calc_cost: float = -1.0
## Descriptive class of the catalogue; behaviour comes from the fields below, never from this label.
@export_enum("inert", "burst", "residue", "push", "spawn", "aura") var prop_class: String = "inert"
@export_enum("ground", "air", "both") var layer: String = "ground"
@export var hp: int = 1
## `heavy`: cannot be moved by displacement or relocation and takes no collision damage.
@export var heavy: bool = false
## A monster pushed or pulled into it takes 2 instead of 1 collision damage.
@export var spiky: bool = false
## While it stands: a ground monster that ends its turn orthogonally next to it is pushed 1
## square away from it.
@export var repel: bool = false
@export var creatable_by_skill: bool = true
## While standing: monsters on orthogonal neighbours receive these effects (aura props).
@export var aura: Array[FieldEffect] = []
## On destruction, in this fixed order of kinds: damage, push, spawn (gdd_battle §6.2 step 4a).
@export var aftermath: Array[PropAftermath] = []
## Ground left behind (laid in category (e)); empty = ground unchanged.
@export var ground_left: StringName = &""
@export var ground_left_level: int = 1
@export var color: Color = Color(0.6, 0.58, 0.52)
@export_multiline var description: String = ""


func on_ground() -> bool:
	return layer != "air"


func in_air() -> bool:
	return layer != "ground"


func occupies(p_layer: int) -> bool:
	return in_air() if p_layer == 1 else on_ground()
