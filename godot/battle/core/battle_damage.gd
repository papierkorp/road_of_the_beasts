class_name BattleDamage
extends RefCounted
## The damage law in one place (gdd_battle §6.1): one calculation per damage instance,
## simultaneous rounds, defeat as a separate step, healing that never exceeds max HP.

const STRIKE := "strike"
const SURGE := "surge"
const GROUND := "ground"          # hazard ground and Voidscar triggers
const COLLISION := "collision"
const FALL := "fall"
const COLLAPSE := "collapse"      # Mountain collapse (environmental)
const AFTERMATH := "aftermath"    # prop aftermath
const ARENA := "arena"            # late-round collapse of the whole arena
const WELL := "well"              # test rule: a held Wellspring at the end of a round
const FLANK := "flank"            # test rule: two enemies next to a monster at the end of a round


## damage = base + increases - reductions, summed in one step, floored at 0. Each source only
## modifies the damage types it names. `pushed`: the unit is the one being pushed or pulled.
static func amount(b: Battle, u: BattleUnit, base: int, type: String, pushed := false) -> int:
	if b.round_number < BattleExperiment.damage_from_round:
		return 0                              # test switch: the first rounds are for positioning only
	# `expose` is reserved (no approved source); the vocabulary entry is honoured if authored.
	var increase := BattleStats.total(b, u, FieldEffect.EXPOSE)
	var reduce := 0
	match type:
		SURGE:
			reduce = BattleStats.surge_reduction(b, u)
		STRIKE:
			reduce = BattleStats.passive_reduction(u, STRIKE)
		COLLISION:
			reduce = BattleStats.passive_reduction(u, COLLISION)
			if pushed:
				reduce += BattleStats.passive_reduction(u, "collision_self")
	return maxi(0, base + increase - reduce)


## Applies simultaneous damage (and same-timing healing) and returns {unit id: damage dealt}.
## hits:  [{unit, base, type, source, pushed?}] · heals: [{unit, amount, source}]
## Damage from several sources on one target adds; HP = min(max, HP - damage + healing).
## Defeat is not resolved here: the caller runs `defeat_step` when its phase says so.
static func apply_round(b: Battle, hits: Array, heals: Array = []) -> Dictionary:
	var dealt := {}
	var healed := {}
	for h: Dictionary in hits:
		var u: BattleUnit = b.units.get(h["unit"])
		if u == null or not u.is_alive():
			continue
		var type: String = h["type"]
		var amt := amount(b, u, int(h["base"]), type, bool(h.get("pushed", false)))
		# Nullify (gdd_battle §6.1): an override after the sum, consumed by the first Surge
		# damage instance of at least 1; a hit already reduced to 0 consumes nothing.
		if type == SURGE and amt >= 1 and u.nullify:
			u.nullify = false
			amt = 0
			b.emit(&"nullified", {"target": u.id, "source": h.get("source", "")})
		dealt[u.id] = int(dealt.get(u.id, 0)) + amt
		b.emit(&"damage", {"target": u.id, "amount": amt, "base": int(h["base"]), "kind": type,
			"source": h.get("source", ""), "by": h.get("by", &""), "trap": h.get("trap", false)})
	for h: Dictionary in heals:
		var u: BattleUnit = b.units.get(h["unit"])
		if u == null or not u.is_alive():
			continue
		healed[u.id] = int(healed.get(u.id, 0)) + int(h["amount"])
	var touched := {}
	for id in dealt:
		touched[id] = true
	for id in healed:
		touched[id] = true
	for id in b.roster:                       # stable order
		if not touched.has(id):
			continue
		var u: BattleUnit = b.units[id]
		var before := u.hp
		u.hp = mini(u.max_hp, u.hp - int(dealt.get(id, 0)) + int(healed.get(id, 0)))
		var gain := u.hp - (before - int(dealt.get(id, 0)))
		if gain > 0:
			b.emit(&"healed", {"target": id, "amount": gain})
	return dealt


## Removes every unit at 0 HP or below (gdd_battle §6.2 step 2). Life Thread turns the first
## fall of its bearer into 1 HP and is consumed. Returns the defeated ids in roster order.
static func defeat_step(b: Battle) -> Array[StringName]:
	var out: Array[StringName] = []
	for id in b.roster:
		var u: BattleUnit = b.units[id]
		if not u.is_alive() or u.hp > 0:
			continue
		if u.life_thread:
			u.life_thread = false
			u.hp = 1
			b.emit(&"survived", {"target": id})
			continue
		b.defeat(u)
		out.append(id)
	return out


static func heal(b: Battle, u: BattleUnit, amt: int, source: String) -> int:
	if u == null or not u.is_alive() or amt <= 0:
		return 0
	var gain := mini(u.max_hp, u.hp + amt) - u.hp
	u.hp += gain
	b.emit(&"healed", {"target": u.id, "amount": gain, "source": source})
	return gain


## Net harm a ground-layer body would take from the triggers of `timing` on `cells`
## (damage minus healing; each ground type once at its highest level). Pure: used by the
## movement search and previews.
static func ground_harm(b: Battle, u: BattleUnit, timing: String, cells: Array[Vector2i]) -> int:
	var parts := ground_effects(b, u, timing, cells)
	var harm := 0
	for h: Dictionary in parts["hits"]:
		harm += amount(b, u, int(h["base"]), GROUND)
	for h: Dictionary in parts["heals"]:
		harm -= int(h["amount"])
	return harm


## Damage and healing entries of the ground under `cells` at `timing`, each type once.
static func ground_effects(b: Battle, u: BattleUnit, timing: String, cells: Array[Vector2i]) -> Dictionary:
	var hits: Array = []
	var heals: Array = []
	var grounds := BattleStats.grounds_under(b, u, cells)
	var ids := grounds.keys()
	ids.sort()
	for gid: StringName in ids:
		var g := b.content.ground(gid)
		if g == null or BattleStats.ignores_ground(u, gid):
			continue
		for t in g.triggers_at(timing):
			var v := t.value_at(grounds[gid])
			if t.kind == "heal":
				heals.append({"unit": u.id, "amount": v, "source": g.display_name})
			else:
				hits.append({"unit": u.id, "base": v, "type": GROUND, "source": g.display_name})
	return {"hits": hits, "heals": heals}


## Fires the ground triggers of `timing` for one unit, simultaneously and net, then the defeat
## step. `extra_heals` joins the same round (zone mend under a 2x2 body, gdd_battle §4.3).
static func ground_triggers(b: Battle, u: BattleUnit, timing: String, cells: Array[Vector2i] = [],
		extra_heals: Array = []) -> void:
	if not u.is_alive():
		return
	var over: Array[Vector2i] = cells if not cells.is_empty() else u.cells()
	var parts := ground_effects(b, u, timing, over)
	var heals: Array = parts["heals"]
	heals.append_array(extra_heals)
	if parts["hits"].is_empty() and heals.is_empty():
		return
	apply_round(b, parts["hits"], heals)
	defeat_step(b)
