extends RefCounted
## Construction-point calculator for skill price records: an authoring check, never a battle
## rule (gdd_skills §2 "Evaluation Contract", §5). Use it through
## `const Pricing := preload("res://tools/lib/skill_pricing.gd")`.
##
## The rates below mirror the working drafts of docs/gdd_skills.md §5. They are NOT validated
## balance and NOT a price authority: the GDD owns the rules. Every record under
## res://tools/data/prices carries the GDD's own paper total, and `tests/tools/test_pricing.gd`
## compares the two, so drift shows up as a failing test. When a §5 rate changes, update this
## table and the `paper_total` of the affected records together.
##
## Anything without a rate FAILS CLOSED (no price, never zero cost): an unknown component or
## name, a missing amount, an unresolved round cap, a repeatable or team-wide event. A numeric
## fit is not approval.

const RECORDS := "res://tools/data/prices"

const CEILING := {1: 24.0, 2: 30.0, 3: 36.0}
const AP_EFFICIENCY := {1: 12.0, 2: 6.0, 3: 3.0, 4: 1.0, 5: 0.0}
const ROUND_LIMIT_FACTOR := 0.75
const EVENT_ONCE_PER_ROUND := 12.0
const PASSIVE_AVAILABILITY := 12.0
const TIMING := {"immediate": 1.0, "telegraphed_avoidable": 0.5}

## Strike Kin packages: per potentially affected hit cell, and once per use.
const KIN_PER_CELL := {"beast": 0.0, "scaled": 2.0, "spirit": 2.0, "swarm": 2.0, "ancient": 2.0, "winged": 0.0}
const KIN_ONCE := {"winged": 3.0}
const ANCHOR := {"free": 2.0, "adjacent": 1.0, "none": 0.0}
## Per value, cell and round. `push` / `pull` are priced separately (2 per cell and round);
## `expose` is reserved and has no rate.
const ZONE_RATE := {"slow": 1.5, "haste": 1.5, "drain_init": 2.0, "quicken": 2.0,
	"drain_range": 2.0, "extend": 2.0, "shield": 1.0, "mend": 3.0}
## Per cell. The last four entries are sketch rates or free.
const GROUND_PER_CELL := {"lava_1": 4.0, "thornbed_1": 4.0, "blight_1": 4.0, "hearth": 4.0, "umbra": 4.0,
	"hallowed": 4.0, "mossbed": 6.0, "mountain_reset": 5.0, "mountain_destroy": 2.0,
	"hazard_2_start": 8.0, "plain": 0.0, "rubble": 0.0}
const MOVE_PRESET := {"run": 6.0, "leap": 8.0, "glide": 8.0, "burrow": 8.0, "phase": 7.0, "blink": 10.0}
const PROP_BASE := {"base": 4.0, "sturdy": 6.0}
const PROP_LAYER := {"ground": 0.0, "air": 2.0, "both": 2.0}

const EPS := 0.000001


## Shortest exact text of a point value: 23, 27.5, 37.5.
static func fmt(v: float) -> String:
	if absf(v - roundf(v)) < EPS:
		return str(int(roundf(v)))
	return ("%.3f" % v).rstrip("0").rstrip(".")


static func same(a: float, b: float) -> bool:
	return absf(a - b) < EPS


## A required amount of at least `minimum`; anything lower is reported and counts as 0.
static func _amount(value: int, minimum: int, label: String, err: Array) -> float:
	if value < minimum:
		err.append("%s: needs a value of at least %d" % [label, minimum])
		return 0.0
	return float(value)


## The rate of a named entry; an unknown name is reported.
static func _rate(table: Dictionary, name: String, label: String, err: Array) -> float:
	if not table.has(name):
		err.append("%s not priced: %s" % [label, name])
		return 0.0
	return table[name]


# ---------- components ----------

## Price of one component: {"label", "points"}; problems are appended to `err`.
static func component(c: PriceComponent, err: Array) -> Dictionary:
	if c == null:
		err.append("empty component")
		return {}
	match c.type:
		PriceComponent.DAMAGE:
			# one-shot damage per cell; ground and air recipients +2 once
			var pts := _amount(c.damage, 1, "damage", err) * _amount(c.cells, 1, "damage cells", err) * 2.0 \
				* _rate(TIMING, c.timing, "timing", err)
			return {"label": "damage", "points": pts + (2.0 if c.ground_air else 0.0)}
		PriceComponent.STRIKE_EXTRAS:
			# Kin package, cells outside the adjacent ring, direction choice
			var pts := _rate(KIN_PER_CELL, c.kin, "Kin", err) * _amount(c.kin_cells, 1, "Kin cells", err) + float(KIN_ONCE.get(c.kin, 0.0))
			pts += 2.0 * _amount(c.distant_cells, 0, "distant cells", err)
			return {"label": "strike extras", "points": pts + (2.0 if c.direction else 0.0)}
		PriceComponent.ANCHOR:
			return {"label": "anchor", "points": _rate(ANCHOR, c.anchor_mode, "anchor mode", err)}
		PriceComponent.MARKER:
			return {"label": "surge marker", "points": 1.0}
		PriceComponent.ZONE:
			var value := _amount(c.value, 1, "zone value", err)
			var area := _amount(c.cells, 1, "zone cells", err) * _amount(c.rounds, 1, "zone rounds", err)
			if c.effect == FieldEffect.PUSH or c.effect == FieldEffect.PULL:
				if c.value != 1:
					err.append("zone push/pull always moves exactly one square")
				return {"label": "zone %s" % c.effect, "points": 2.0 * area}
			return {"label": "zone %s" % c.effect, "points": _rate(ZONE_RATE, c.effect, "zone effect", err) * value * area}
		PriceComponent.DISPLACEMENT:
			# immediate 2 per cell; telegraphed and avoidable on a fixed footprint 50 %
			return {"label": "displacement", "points": 2.0 * _amount(c.cells, 1, "displacement cells", err) * _rate(TIMING, c.timing, "timing", err)}
		PriceComponent.GROUND:
			return {"label": "ground %s" % c.ground, "points": _rate(GROUND_PER_CELL, c.ground, "ground", err) * _amount(c.cells, 1, "ground cells", err)}
		PriceComponent.MOVE:
			return {"label": "move %s" % c.preset, "points": _rate(MOVE_PRESET, c.preset, "movement preset", err) + 2.0 * _amount(c.patches, 0, "patches", err)}
		PriceComponent.SELF_BUFF:
			# Initiative only: 4 per +1 and round
			if c.stat != "initiative":
				err.append("only the Initiative self-buff rate exists")
			return {"label": "self initiative", "points": 4.0 * _amount(c.magnitude, 1, "self-buff magnitude", err) * _amount(c.rounds, 1, "self-buff rounds", err)}
		PriceComponent.ROTATION:
			return {"label": "rotation permission", "points": 6.0}
		PriceComponent.NULLIFY:
			# sketch price per protected monster
			return {"label": "nullify (sketch)", "points": 9.0}
		PriceComponent.RELOCATE:
			return {"label": "relocate (provisional)", "points": 6.0 * _amount(c.props, 1, "relocated props", err)}
		PriceComponent.PROP:
			# prop creation draft (gdd_skills §5 "Prop creation price drafts")
			var pts := _rate(PROP_BASE, c.prop_tier, "prop tier", err) + _rate(PROP_LAYER, c.prop_layer, "prop layer", err)
			pts += _amount(c.aftermath_damage_squares, 0, "aftermath damage squares", err)
			pts += _amount(c.aftermath_push_squares, 0, "aftermath push squares", err)
			pts += 2.0 * _amount(c.beam_squares, 0, "beam squares", err)
			pts += _rate(GROUND_PER_CELL, c.aftermath_ground, "prop aftermath ground", err)
			return {"label": "prop", "points": pts + (4.0 if c.aura else 0.0)}
		PriceComponent.AIR_COVERAGE:
			return {"label": "air coverage", "points": 2.0}
	err.append("unsupported component: %s" % c.type)
	return {}


static func availability(rec: PriceRecord, err: Array) -> Dictionary:
	match rec.usage:
		PriceRecord.ACTIVE:
			if not AP_EFFICIENCY.has(rec.ap):
				err.append("ap must be 1..5")
				return {}
			var base: float = AP_EFFICIENCY[rec.ap]
			if rec.once_per_round:
				if rec.round_cap != "effective" and rec.round_cap != "not_effective":
					err.append("round cap: effective-restriction check unresolved")
					return {}
				if rec.round_cap == "effective":
					base *= ROUND_LIMIT_FACTOR
			return {"label": "AP efficiency", "points": base}
		PriceRecord.PASSIVE_BOOLEAN:
			return {"label": "passive availability", "points": PASSIVE_AVAILABILITY}
		PriceRecord.EVENT_ONCE_PER_ROUND:
			return {"label": "event availability (once per round)", "points": EVENT_ONCE_PER_ROUND}
	err.append("availability not priced for usage: %s (repeatable/team-wide events are unpriced)" % rec.usage)
	return {}


# ---------- evaluation ----------

static func _incomplete(message: String) -> Dictionary:
	return {"ok": false, "error": message, "name": "?", "parts": [], "total": 0.0, "ceiling": 0.0, "fits": false}


## Prices a record against the ceiling of `slot_level`:
## {ok, error, name, parts: [[label, points]], total, ceiling, fits}. `ok` false means there
## is no defensible number (incomplete or unsupported input), never a zero price.
static func evaluate(rec: PriceRecord, slot_level: int = 1) -> Dictionary:
	if rec == null or rec.components.is_empty():
		return _incomplete("record needs a non-empty components list")
	if not CEILING.has(slot_level):
		return _incomplete("slot level 1..3")
	var err: Array[String] = []
	var parts: Array = []
	var total := 0.0
	for c in rec.components:
		var part := component(c, err)
		if not err.is_empty():
			return _incomplete(err[0])
		parts.append([part["label"], part["points"]])
		total += float(part["points"])
	var av := availability(rec, err)
	if not err.is_empty():
		return _incomplete(err[0])
	parts.append([av["label"], av["points"]])
	total += float(av["points"])
	var ceiling: float = CEILING[slot_level]
	return {"ok": true, "error": "", "name": rec.display_name, "parts": parts, "total": total,
		"ceiling": ceiling, "fits": total <= ceiling + EPS}


# ---------- records ----------

## Ids (file names without extension) of the .tres files in a folder, alphabetical.
static func ids_in(folder: String) -> Array[String]:
	var out: Array[String] = []
	for f in ResourceLoader.list_directory(folder):
		var file := String(f).trim_suffix(".remap")
		if file.ends_with(".tres"):
			out.append(file.get_basename())
	out.sort()
	return out


## id -> PriceRecord for every record under res://tools/data/prices.
static func load_records() -> Dictionary:
	var out := {}
	for id in ids_in(RECORDS):
		var rec := load(RECORDS.path_join(id + ".tres")) as PriceRecord
		if rec == null:
			push_error("%s/%s.tres is not a PriceRecord" % [RECORDS, id])
			continue
		out[id] = rec
	return out


## A record by id or by display name; null if there is none.
static func find_record(name: String) -> PriceRecord:
	var records := load_records()
	if records.has(name):
		return records[name]
	for id: String in records:
		if (records[id] as PriceRecord).display_name == name:
			return records[id]
	return null
