extends GdUnitTestSuite
## The construction-point calculator against the GDD's own paper examples (gdd_skills §5):
## every price record under res://tools/data/prices carries the GDD's paper total, so a rate
## that drifts from the GDD fails here instead of producing a silent wrong number. A passing
## run shows that the rate table and the GDD agree, nothing about balance. Update the rates
## and the paper totals together.

const Pricing := preload("res://tools/lib/skill_pricing.gd")


func _named(skill: String) -> PriceRecord:
	var rec := Pricing.find_record(skill)
	assert_object(rec).override_failure_message("no price record '%s'" % skill).is_not_null()
	return rec


## A record built in code from components (active, 1 AP unless said otherwise).
func _record(parts: Array, usage := PriceRecord.ACTIVE, ap := 1) -> PriceRecord:
	var rec := PriceRecord.new()
	rec.display_name = "test"
	rec.usage = usage
	rec.ap = ap
	var list: Array[PriceComponent] = []
	list.assign(parts)
	rec.components = list
	return rec


func _total(rec: PriceRecord, slot_level := 1) -> float:
	var out := Pricing.evaluate(rec, slot_level)
	assert_bool(out["ok"]).override_failure_message("%s: %s" % [rec.display_name, out["error"]]).is_true()
	return out["total"]


func _refused(rec: PriceRecord, why: String) -> void:
	assert_bool(Pricing.evaluate(rec)["ok"]).override_failure_message("priced although incomplete: %s" % why).is_false()


func test_every_price_record_matches_its_paper_total() -> void:
	var records := Pricing.load_records()
	assert_int(records.size()).is_greater(0)
	for id: String in records:
		var rec: PriceRecord = records[id]
		# every record needs the GDD's paper total next to its components
		assert_bool(rec.paper_total >= 0.0).override_failure_message("%s has no paper total" % id).is_true()
		assert_float(_total(rec)).override_failure_message(id).is_equal_approx(rec.paper_total, 0.0001)


func test_zone_and_buff_reference_totals() -> void:
	var expect := {"Slow zone 2 rounds": 23.0, "Slow zone 3 rounds": 27.5, "Quicken 1, 3 cells, 2 rounds": 26.0,
		"Shield 2, 3 cells, 2 rounds": 26.0, "Mend 1, 3 cells, 2 rounds": 32.0, "Self Initiative +1, 2 rounds": 20.0,
		"Adaptive (rotation)": 18.0}
	for skill: String in expect:
		assert_float(_total(_named(skill))).override_failure_message(skill).is_equal_approx(expect[skill], 0.0001)
	# a record is found by its id as well as by its display name
	assert_object(Pricing.find_record("slow_zone_2_rounds")).is_same(_named("Slow zone 2 rounds"))
	assert_object(Pricing.find_record("no such record")).is_null()


func test_missing_amounts_and_unknown_names_are_refused() -> void:
	for key: String in ["value", "cells", "rounds"]:
		for bad: int in [0, -1]:
			var fields := {"effect": "slow", "value": 1, "cells": 3, "rounds": 2}
			fields[key] = bad
			_refused(_record([PriceComponent.make(PriceComponent.ZONE, fields)]), "zone %s %d" % [key, bad])
	for effect: String in ["push", "pull"]:
		_refused(_record([PriceComponent.make(PriceComponent.ZONE, {"effect": effect, "value": 2, "cells": 3, "rounds": 2})]), "zone %s 2" % effect)
	for bad: int in [0, 6, -1]:
		_refused(_record([PriceComponent.make(PriceComponent.MARKER)], PriceRecord.ACTIVE, bad), "ap %d" % bad)
	var cases := {
		"damage without cells": PriceComponent.make(PriceComponent.DAMAGE, {"damage": 3}),
		"damage without damage": PriceComponent.make(PriceComponent.DAMAGE, {"cells": 2}),
		"unknown timing": PriceComponent.make(PriceComponent.DAMAGE, {"damage": 3, "cells": 2, "timing": "later"}),
		"unknown Kin": PriceComponent.make(PriceComponent.STRIKE_EXTRAS, {"kin": "dragon", "kin_cells": 1}),
		"Kin package without cells": PriceComponent.make(PriceComponent.STRIKE_EXTRAS, {"kin": "scaled"}),
		"negative distant cells": PriceComponent.make(PriceComponent.STRIKE_EXTRAS, {"kin": "beast", "kin_cells": 1, "distant_cells": -1}),
		"unknown anchor": PriceComponent.make(PriceComponent.ANCHOR, {"anchor_mode": "wide"}),
		"unknown ground": PriceComponent.make(PriceComponent.GROUND, {"ground": "swamp", "cells": 3}),
		"ground without cells": PriceComponent.make(PriceComponent.GROUND, {"ground": "lava_1"}),
		"unknown preset": PriceComponent.make(PriceComponent.MOVE, {"preset": "swim"}),
		"self buff of another stat": PriceComponent.make(PriceComponent.SELF_BUFF, {"stat": "reach", "magnitude": 1, "rounds": 2}),
		"self buff without magnitude": PriceComponent.make(PriceComponent.SELF_BUFF, {"rounds": 2}),
		"relocate without props": PriceComponent.make(PriceComponent.RELOCATE),
		"displacement without cells": PriceComponent.make(PriceComponent.DISPLACEMENT),
		"empty component": null,
	}
	for why: String in cases:
		_refused(_record([cases[why]]), why)


func test_prop_creation_drafts() -> void:
	# gdd_skills §5 "Prop creation price drafts": [fields, expected points]
	var rows := [
		[{"prop_tier": "sturdy"}, 6.0],
		[{"prop_tier": "base", "aftermath_damage_squares": 8}, 12.0],
		[{"prop_tier": "base", "aftermath_ground": "mossbed"}, 10.0],
		[{"prop_tier": "sturdy", "beam_squares": 4}, 14.0],
		[{"prop_tier": "base", "aura": true}, 8.0],
		[{"prop_tier": "base", "prop_layer": "air", "aftermath_damage_squares": 8}, 14.0],
		[{"prop_tier": "sturdy", "prop_layer": "both"}, 8.0],
	]
	for row: Array in rows:
		var err: Array[String] = []
		var part := Pricing.component(PriceComponent.make(PriceComponent.PROP, row[0]), err)
		assert_array(err).is_empty()
		assert_float(part["points"]).override_failure_message(str(row[0])).is_equal_approx(row[1], 0.0001)


func test_ceiling_findings() -> void:
	# gdd_skills §5 budget findings
	assert_bool(Pricing.evaluate(_named("Scaled Jab"))["fits"]).is_true()
	assert_bool(Pricing.evaluate(_named("Scaled Arc"))["fits"]).is_false()
	assert_bool(Pricing.evaluate(_named("Scaled Arc"), 2)["fits"]).is_true()
	assert_bool(Pricing.evaluate(_named("Beast Storm"), 3)["fits"]).is_true()
	assert_bool(Pricing.evaluate(_named("Scaled Jab"), 4)["ok"]).is_false()      # slot levels are 1-3


func test_mountain_candidate_arithmetic() -> void:
	# paper check of the unapproved 0.5 destruction rate (gdd_skills §5 calibration proposal)
	assert_float(15 + 2 * (3 + 4 + 0.5)).is_equal(30.0)
	assert_float(15 + 3 * (3 + 4 + 0.5)).is_equal(37.5)


func test_round_limit_and_event_availability() -> void:
	var r: PriceRecord = _named("Slow zone 2 rounds").duplicate(true)
	r.once_per_round = true
	_refused(r, "round cap unresolved")           # the effective-restriction check is unresolved
	r.round_cap = "effective"
	assert_float(_total(r)).is_equal_approx(9.0 + 2.0 + 12.0 * 0.75, 0.0001)
	r.round_cap = "not_effective"
	assert_float(_total(r)).is_equal_approx(23.0, 0.0001)
	assert_float(_total(_record([PriceComponent.make(PriceComponent.NULLIFY)], PriceRecord.EVENT_ONCE_PER_ROUND))).is_equal_approx(21.0, 0.0001)
	# the stored record is untouched by the copy
	assert_bool(_named("Slow zone 2 rounds").once_per_round).is_false()


func test_unknown_or_unpriced_input_fails_closed() -> void:
	_refused(_record([PriceComponent.make("teleport_ally")]), "unknown component type")
	_refused(_record([PriceComponent.make(PriceComponent.NULLIFY)], "event_repeatable"), "repeatable event")
	_refused(_record([PriceComponent.make(PriceComponent.ZONE, {"effect": "expose", "value": 1, "cells": 1, "rounds": 1})]), "reserved zone effect")
	_refused(_record([]), "no components")
	_refused(_record([PriceComponent.make(PriceComponent.MARKER)], PriceRecord.ACTIVE, 7), "ap 7")
	_refused(_record([PriceComponent.make(PriceComponent.PROP, {"prop_layer": "underground"})]), "unknown prop layer")
	_refused(_record([PriceComponent.make(PriceComponent.PROP, {"prop_tier": "huge"})]), "unknown prop tier")
	_refused(null, "no record")
