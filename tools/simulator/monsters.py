#!/usr/bin/env python3
"""Assemble reusable JSON monster test sheets for the reduced price experiment (stdlib).

  python3 -I tools/simulator/monsters.py --list
  python3 -I tools/simulator/monsters.py test_golem_eruption
  python3 -I tools/simulator/monsters.py --self-test

Checks stat spend/ceilings and priced skill slots, not species access or progression
reachability. Unsupported record components are reported as NOT SIMULATED, never silently
converted into another action. TPR > 1 remains unmodelled, not illegal. The Godot game
will use its own implementation; these compact price records can serve as templates.

Zone handoff: id, ap, rounds, effects [{effect, base, cap}], offsets, once_per_round,
source slot. None cap means level I only, not permission to infer stronger values.
Mend uses its level-I price (32 points for the example) and heals min(2, zone level).
Only Focus (+1 Initiative / 2 rounds / 1 AP) and Adaptive owner rotation are supported
among self/passive examples. Non-Slow I3 geometry is explicitly an unapproved fixture.
Results are indications only, not content, balance or price approval.
"""
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import pricing  # noqa: E402

DATA = Path(__file__).resolve().parent / "data"
BASE_POINTS = 15
BUDGET = {("qi", "lower"): 4, ("qi", "middle"): 5, ("qi", "high"): 6,
          ("foundation", "lower"): 10, ("foundation", "middle"): 11, ("foundation", "high"): 12,
          ("core", "lower"): 14, ("core", "middle"): 15, ("core", "high"): 16,
          ("soul", "lower"): 18, ("soul", "middle"): 19, ("soul", "high"): 20}
CEIL = {  # Monsters section 2.3: hp, init, tpr, move, reach, ap
    "qi": (4, 5.0, 1, 3, 2, 2), "foundation": (6, 7.0, 2, 4, 3, 2),
    "core": (8, 9.0, 2, 5, 3, 3), "soul": (10, 10.0, 3, 5, 4, 3)}
TPR_PRICE = {1: 3, 2: 8, 3: 15}
AP_PRICE = {2: 6, 3: 9, 4: 14, 5: 21}


def stat_points(s):
    return s["hp"] + s["init"] + s["move"] + (s["reach"] - 1) * 3 + TPR_PRICE[s["tpr"]] + AP_PRICE[s["ap"]]


def load_monster(name):
    return json.loads((DATA / "monsters" / f"{name}.json").read_text(encoding="utf-8"))


def list_monsters():
    return sorted(p.stem for p in (DATA / "monsters").glob("*.json"))


class NotSimulated(ValueError):
    """A complete record cannot be represented by the reduced engine interface."""


def whole(value, label, minimum=1):
    if type(value) is not int or value < minimum:
        raise NotSimulated(f"{label}: expected integer >= {minimum}")
    return value


def only_keys(obj, allowed, label):
    if not isinstance(obj, dict):
        raise NotSimulated(f"{label}: expected an object")
    extra = obj.keys() - set(allowed)
    if extra:
        raise NotSimulated(f"{label}: unsupported field(s) {', '.join(sorted(extra))}")


COMPONENT_FIELDS = {
    "damage": {"type", "damage", "cells", "ground_air", "timing"},
    "strike_extras": {"type", "kin", "kin_cells", "distant_cells", "direction"},
    "anchor": {"type", "mode"}, "marker": {"type"},
    "ground": {"type", "ground", "cells"},
    "displacement": {"type", "cells", "timing"},
    "move": {"type", "preset", "patches"},
    "zone": {"type", "effect", "value", "cells", "rounds"},
    "self_buff": {"type", "stat", "magnitude", "rounds"},
}
STRIKE_GEOMETRY = {  # hit cells, distant cells, direction choice; cross-checked against engine below
    "jab": (1, 0, True), "thrust": (2, 1, True), "diagonal_thrust": (2, 1, True),
    "pincer": (2, 0, True), "arc": (3, 0, True), "cleave": (6, 3, True),
    "whirl": (4, 0, False), "cross": (4, 0, False), "storm": (8, 0, False),
    "long_whirl": (8, 4, False), "long_cross": (8, 4, False),
}
# Only resolved bounds are numeric. No extrapolation from zone level III or stat ceilings.
ZONE_BOUNDS = {"slow": (1, 2), "haste": (None, None),
               "drain_init": (None, None), "quicken": (None, None),
               "drain_range": (None, None), "extend": (None, None),
               "push": (1, 1), "pull": (1, 1), "shield": (2, 3), "mend": (1, 2)}


def sim_action(rec, source):
    """Return (action, payload, coverage notes), or reject the WHOLE hinted record."""
    hint = rec.get("sim")
    if not isinstance(hint, dict):
        raise NotSimulated("no executable sim hint; passive candidates need resolved contracts/prices")
    if hint.get("action") == "not_simulated":
        raise NotSimulated(hint.get("reason", "explicitly unsupported record"))
    if hint.get("action") == "passive":
        only_keys(rec, {"name", "usage", "components", "sim", "note", "paper_source"}, "passive record")
        only_keys(hint, {"action", "permission"}, "passive hint")
        if not isinstance(rec.get("name"), str) or not rec["name"].strip():
            raise NotSimulated("record needs a non-empty name")
        if (rec.get("usage") != "passive_boolean" or hint.get("permission") != "rotate"
                or rec.get("components") != [{"type": "rotation"}]):
            raise NotSimulated("only continuous owner rotation with exactly one rotation component is supported")
        return "passive", {"rotate": True}, []
    if rec.get("usage") != "active":
        raise NotSimulated("only continuous owner rotation is supported; other passive/event effects are not implemented")
    only_keys(rec, {"name", "usage", "ap", "components", "sim", "once_per_round",
                    "round_cap_effective", "note", "paper_source"}, "record")
    if not isinstance(rec.get("name"), str) or not rec["name"].strip():
        raise NotSimulated("record needs a non-empty name")
    ap = whole(rec.get("ap"), "AP")
    if ap > 5:
        raise NotSimulated("AP must be 1..5")
    once = rec.get("once_per_round", False)
    if type(once) is not bool:
        raise NotSimulated("once_per_round must be boolean")
    if "round_cap_effective" in rec and (not once or type(rec["round_cap_effective"]) is not bool):
        raise NotSimulated("round_cap_effective requires a boolean and once_per_round")
    if once and "round_cap_effective" not in rec:
        raise NotSimulated("round-cap effectiveness unresolved")
    action = hint.get("action")
    if not isinstance(action, str):
        raise NotSimulated("sim action must be a name")
    if once and action != "zone":
        raise NotSimulated("round-limited non-zone actions are not represented by the engine interface")
    comps = rec.get("components")
    if not isinstance(comps, list) or not comps:
        raise NotSimulated("non-empty components required")
    by_type = {}
    for c in comps:
        if not isinstance(c, dict) or not isinstance(c.get("type"), str) or c["type"] not in COMPONENT_FIELDS:
            raise NotSimulated(f"unsupported component {c!r}")
        only_keys(c, COMPONENT_FIELDS[c["type"]], c["type"])
        by_type.setdefault(c["type"], []).append(c)

    def package(**counts):
        if {t: len(cs) for t, cs in by_type.items()} != counts:
            raise NotSimulated(f"{action}: complete component package does not match {counts}")

    if action == "zone":
        only_keys(hint, {"action", "offsets", "effects", "fixture"}, "zone hint")
        zc = by_type.get("zone", [])
        package(zone=len(zc), anchor=1)
        if not zc or by_type["anchor"][0].get("mode", "free") != "free":
            raise NotSimulated("zones require effects and a free board anchor")
        raw = hint.get("offsets")
        if not isinstance(raw, list) or not raw:
            raise NotSimulated("zone requires explicit non-empty fixed offsets")
        offsets = []
        for p in raw:
            if not isinstance(p, (list, tuple)) or len(p) != 2 or any(type(v) is not int for v in p):
                raise NotSimulated("zone offsets must be integer (dx, dy) pairs")
            offsets.append(tuple(p))
        if len(set(offsets)) != len(offsets):
            raise NotSimulated("duplicate zone offsets")
        effects = hint.get("effects")
        if not isinstance(effects, list) or len(effects) != len(zc):
            raise NotSimulated("every zone component needs exactly one effect hint")
        rounds, pending, notes, output = None, list(zc), [], []
        for effect in effects:
            only_keys(effect, {"effect", "base", "cap"}, "zone effect")
            tag = effect.get("effect")
            if not isinstance(tag, str) or tag not in ZONE_BOUNDS or any(e["effect"] == tag for e in output):
                raise NotSimulated(f"unsupported/duplicate zone effect {tag!r}")
            matches = [c for c in pending if c.get("effect") == tag]
            if len(matches) != 1:
                raise NotSimulated(f"zone effect {tag}: component/hint mismatch")
            c = matches[0]
            pending.remove(c)
            duration = whole(c.get("rounds"), "zone rounds")
            if rounds is not None and rounds != duration:
                raise NotSimulated("zone effects must share one clock")
            rounds = duration
            if whole(c.get("cells"), "zone cells") != len(offsets):
                raise NotSimulated("zone cells do not match fixed geometry")
            base = whole(effect.get("base"), "zone base")
            expected_base, cap = ZONE_BOUNDS[tag]
            if "cap" not in effect or effect["cap"] != cap or (cap is not None and type(effect["cap"]) is not int):
                raise NotSimulated(f"{tag}: cap must be {cap!r}; no invented scaling")
            if expected_base is not None and base != expected_base:
                raise NotSimulated(f"{tag}: base must be {expected_base}")
            if whole(c.get("value"), "zone priced value") != base:
                raise NotSimulated(f"{tag}: price must use its authored level-I value {base}")
            if cap is None:
                notes.append(f"{tag}: only base level I covered; level > I NOT SIMULATED (cap/scaling unresolved)")
            output.append(dict(effect=tag, base=base, cap=cap))
        fixture = hint.get("fixture")
        if fixture is not None:
            if not isinstance(fixture, str) or not fixture.strip():
                raise NotSimulated("fixture label must describe the unapproved geometry")
            notes.append(f"TEST FIXTURE, no GDD geometry approval: {fixture}")
        return action, dict(id=rec["name"], ap=ap, rounds=rounds, effects=output,
                            offsets=offsets, once_per_round=once, source=source), notes
    if action == "buff":
        only_keys(hint, {"action"}, "buff hint")
        package(self_buff=1)
        c = by_type["self_buff"][0]
        if (c.get("stat") != "initiative" or ap != 1
                or whole(c.get("magnitude"), "Initiative magnitude") != 1
                or whole(c.get("rounds"), "buff rounds") != 2):
            raise NotSimulated("only the Focus example (+1 Initiative, 2 rounds, 1 AP) is supported")
        return action, dict(id=rec["name"], ap=ap, magnitude=1, rounds=2, source=source), []
    if action == "move":
        only_keys(hint, {"action", "preset"}, "move hint")
        package(move=1)
        c = by_type["move"][0]
        if (not isinstance(c.get("preset"), str) or c["preset"] not in pricing.MOVE_PRESET
                or c["preset"] != hint.get("preset")
                or type(c.get("patches", 0)) is not int or c.get("patches", 0) != 0):
            raise NotSimulated("movement hint must match an unpatched preset")
        return action, dict(movement=c["preset"], walk_ap=ap), []
    if action == "strike":
        only_keys(hint, {"action", "shape", "push"}, "strike hint")
        geometry = STRIKE_GEOMETRY.get(hint["shape"]) if isinstance(hint.get("shape"), str) else None
        if geometry is None:
            raise NotSimulated("unknown Strike geometry")
        has_damage = "damage" in by_type
        package(**({"damage": 1, "strike_extras": 1} if has_damage else {"strike_extras": 1}))
        cells, distant, direction = geometry
        ex = by_type["strike_extras"][0]
        kin, push = ex.get("kin"), hint.get("push", "all")
        if (not isinstance(kin, str) or kin not in pricing.KIN_PER_CELL or push not in ("all", "adjacent")
                or (push != "all" and kin != "scaled")):
            raise NotSimulated("unsupported Kin/push hint")
        kin_cells = cells - distant if kin == "scaled" and push == "adjacent" else cells
        if (type(ex.get("direction")) is not bool or ex["direction"] != direction
                or whole(ex.get("kin_cells"), "Kin cells") != kin_cells
                or whole(ex.get("distant_cells", 0), "distant cells", 0) != distant):
            raise NotSimulated("Strike extras do not match shape/Kin geometry")
        dmg = 0
        if has_damage:
            c = by_type["damage"][0]
            if (whole(c.get("damage"), "Strike damage") != 2 or whole(c.get("cells"), "damage cells") != cells
                    or c.get("ground_air") is not True or c.get("timing", "immediate") != "immediate"):
                raise NotSimulated("Strike damage must match fixed 2, ground/air, immediate shape cells")
            dmg = 2
        elif kin not in ("scaled", "winged") or hint["shape"] != "jab":
            raise NotSimulated("only authored Jab-shaped movement-only references supported")
        notes = ["Mountain destruction effect NOT SIMULATED (no Mountains)"] if kin == "ancient" else []
        return action, dict(shape=hint["shape"], kin=kin, dmg=dmg, ap=ap, push=push), notes
    if action == "surge":
        only_keys(hint, {"action", "profile"}, "surge hint")
        profile = hint.get("profile")
        if profile not in ("eruption", "flood", "rift"):
            raise NotSimulated("unsupported Surge profile")
        package(**dict(damage=1, anchor=1, marker=1, ground=1,
                       **({"displacement": 1} if profile == "flood" else {})))
        damage = by_type["damage"][0]
        ground = by_type["ground"][0]
        if (whole(damage.get("damage"), "Surge damage") != (2 if profile == "flood" else 3)
                or whole(damage.get("cells"), "Surge cells") != 2
                or damage.get("timing") != "telegraphed_avoidable" or damage.get("ground_air", False) is not False
                or ground.get("ground") != {"eruption": "lava_1", "flood": "thornbed_1", "rift": "blight_1"}[profile]
                or whole(ground.get("cells"), "ground cells") != 2
                or by_type["anchor"][0].get("mode", "free") != "free"):
            raise NotSimulated("Surge hint must match the complete two-cell ground-layer profile")
        if profile == "flood":
            c = by_type["displacement"][0]
            if whole(c.get("cells"), "push cells") != 2 or c.get("timing") != "telegraphed_avoidable":
                raise NotSimulated("Flood displacement does not match the profile")
        return action, dict(surge=profile, surge_ap=ap), []
    raise NotSimulated(f"unknown sim action {action!r}")


def build(name):
    m = load_monster(name)
    skills = pricing.load_skills()
    errors, warnings, slots = [], [], []
    st = m["stats"]
    try:
        spent = stat_points(st)
        budget = BASE_POINTS + BUDGET[(m["stage"], m["subtier"])]
    except (KeyError, TypeError) as exc:
        return dict(name=name, errors=[f"stats/stage not priced: {exc}"], warnings=[], slots=[], ok=False)
    if spent > budget:
        errors.append(f"stat points {spent} exceed budget {budget}")
    elif spent < budget:
        warnings.append(f"{budget - spent} unspent stat point(s) (allowed, player spends freely)")
    c = CEIL[m["stage"]]
    for key, cap, lbl in zip(("hp", "init", "tpr", "move", "reach", "ap"), c, ("hp", "init", "tpr", "move", "reach", "ap")):
        if st[key] > cap:
            errors.append(f"{lbl} {st[key]} above stage ceiling {cap}")

    if st["tpr"] != 1:
        warnings.append(f"TPR {st['tpr']}: NOT SIMULATED (engine executes one turn per round)")

    if not 1 <= len(m["slots"]) <= 4:
        errors.append("kit needs 1-4 slots")
    actives = 0
    sim = {"strikes": [], "surge": None, "surge_ap": 1, "movement": None, "walk_ap": 2,
           "zones": [], "buffs": [], "rotate": False}
    for i, slot in enumerate(m["slots"], 1):
        entry = skills.get(slot["skill"])
        if entry is None:
            errors.append(f"slot {i}: unknown skill {slot['skill']!r}; NOT SIMULATED (no priced record; unresolved candidates are not free perks)")
            continue
        rec, _ = entry
        try:
            ev = pricing.evaluate(rec, slot.get("level", 1))
        except pricing.Incomplete as exc:
            errors.append(f"slot {i} {rec['name']}: incomplete pricing ({exc}); NOT SIMULATED")
            continue
        if rec.get("usage") == "active":
            actives += 1
            if rec["ap"] > st["ap"]:
                errors.append(f"slot {i} {rec['name']}: costs {rec['ap']} AP, monster has {st['ap']}")
        if not ev["fits"]:
            errors.append(f"slot {i} {rec['name']}: {ev['total']} points exceed ceiling {ev['ceiling']} of slot level {slot.get('level', 1)}")
        for comp in rec["components"]:
            if comp.get("type") == "strike_extras" and comp["kin"] != m["kin"]:
                errors.append(f"slot {i} {rec['name']}: Strike Kin {comp['kin']} != monster Kin {m['kin']}")
        try:
            act, payload, notes = sim_action(rec, i)
            if act == "strike":
                sim["strikes"].append(payload)
            elif act in ("zone", "buff"):
                sim["zones" if act == "zone" else "buffs"].append(payload)
            elif act == "passive":
                sim["rotate"] = sim["rotate"] or payload["rotate"]
            elif act == "surge" and sim["surge"] is not None:
                raise NotSimulated("additional Surge slot: engine has only one Surge field")
            elif act == "move" and sim["movement"] is not None:
                raise NotSimulated("additional movement slot: engine has only one movement field")
            else:
                sim.update(payload)
            warnings.extend(f"slot {i} {rec['name']}: {note}" for note in notes)
        except NotSimulated as exc:
            warnings.append(f"slot {i} {rec['name']}: NOT SIMULATED ({exc})")
        slots.append(dict(skill=rec["name"], level=slot.get("level", 1), points=str(ev["total"]), ceiling=str(ev["ceiling"])))
    if actives == 0:
        errors.append("kit needs at least one active skill")
    sheet = dict(hp=st["hp"], init=float(st["init"]), move=st["move"], reach=st["reach"], ap=st["ap"],
                 strikes=sim["strikes"], surge=sim["surge"] or "none", surge_ap=sim["surge_ap"],
                 movement=sim["movement"] or "step", walk_ap=sim["walk_ap"],
                 zones=sim["zones"], buffs=sim["buffs"], rotate=sim["rotate"])
    return dict(name=name, kin=m["kin"], stage=f"{m['stage']} {m['subtier']}", stat_points=f"{spent:g}/{budget}",
                slots=slots, errors=errors, warnings=warnings, sheet=sheet, ok=not errors)


def self_test():
    for name in list_monsters():
        result = build(name)
        assert result["ok"], (name, result["errors"])
    print(f"OK: {len(list_monsters())} monster sheets; priced slots and reduced coverage checked")
    return 0


def main():
    a = sys.argv[1:]
    if not a or a[0] in ("-h", "--help"):
        print(__doc__)
        return 0
    if a[0] == "--self-test":
        return self_test()
    if a[0] == "--list":
        print("\n".join(list_monsters()))
        return 0
    names = a[1:] if a[0] == "--compare" else a
    rc = 0
    for n in names:
        r = build(n)
        print(json.dumps(r, indent=1, ensure_ascii=False))
        rc |= 0 if r["ok"] else 1
    return rc


if __name__ == "__main__":
    sys.exit(main())
