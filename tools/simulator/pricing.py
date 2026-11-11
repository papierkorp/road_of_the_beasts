#!/usr/bin/env python3
"""Construction-point calculator for monster-skill records (temporary docs tool, stdlib only).

Replaces the retired docs/temp_kalkscript.py. Prices live HERE as a data table that mirrors
docs/gdd_skills.md section 5 (working drafts, NOT validated balance, NOT a price authority).
The GDD owns the rules; `--self-test` compares this table with the GDD's own paper examples
(golden cases), so drift shows up as a failing test instead of a silent wrong number.

Usage (repository root):
  python3 -I tools/simulator/pricing.py --self-test
  python3 -I tools/simulator/pricing.py --example slow_zone
  python3 -I tools/simulator/pricing.py --list-examples
  python3 -I tools/simulator/pricing.py my_skill.json [--slot-level 1]      ('-' reads stdin)

Record notation (compact, derived from the Skills section 2 field groups; not an engine schema):
  {"name": str, "usage": "active" | "passive_boolean" | "event_once_per_round",
   "ap": 1..5 (active only), "round_cap_effective": true|false (only with "once_per_round": true),
   "components": [ {"type": ..., ...}, ... ]}
Exit codes: 0 fits the ceiling, 1 over the ceiling, 2 incomplete/unsupported/invalid.
Unknown or unpriced components FAIL CLOSED (never zero cost). A numeric fit is not approval.
Mend V1 remains the arithmetic-only 32-point paper reference. The current capped-mend sketch
is a separate V2 record (50), with a derived-paper-source in data/golden.json; no repricing or
budget-fit exception. Runtime sim hints/geometry are validated by monsters.py, not this calculator.
"""
import argparse
import json
import sys
import unittest
from pathlib import Path
from decimal import Decimal as D

CEILING = {1: D(24), 2: D(30), 3: D(36)}
AP_EFFICIENCY = {1: D(12), 2: D(6), 3: D(3), 4: D(1), 5: D(0)}
ROUND_LIMIT_FACTOR = D("0.75")
EVENT_ONCE_PER_ROUND = D(12)
PASSIVE_AVAILABILITY = D(12)
HALF = D("0.5")

# Strike Kin packages: (per potentially affected hit cell, once per use)
KIN_PER_CELL = {"beast": D(0), "scaled": D(2), "spirit": D(2), "swarm": D(2), "ancient": D(2), "winged": D(0)}
KIN_ONCE = {"winged": D(3)}
ZONE_RATE = {"slow": D("1.5"), "haste": D("1.5"), "drain_init": D(2), "quicken": D(2),
             "drain_range": D(2), "extend": D(2), "shield": D(1), "mend": D(3)}
GROUND_PER_CELL = {"lava_1": D(4), "thornbed_1": D(4), "blight_1": D(4), "hearth": D(4), "umbra": D(4),
                   "hallowed": D(4), "mossbed": D(6), "mountain_reset": D(5), "mountain_destroy": D(2),
                   "hazard_2_start": D(8), "plain": D(0), "rubble": D(0)}  # last four: sketch / free
MOVE_PRESET = {"run": D(6), "leap": D(8), "glide": D(8), "burrow": D(8), "phase": D(7), "blink": D(10)}
PROP_BASE = {"base": D(4), "sturdy": D(6)}


class Incomplete(ValueError):
    """No defensible numeric result for this input."""


def dec(v, name="value"):
    if isinstance(v, bool) or v is None:
        raise Incomplete(f"{name}: expected a number")
    try:
        out = D(str(v))
    except Exception as exc:
        raise Incomplete(f"{name}: invalid number") from exc
    if not out.is_finite():
        raise Incomplete(f"{name}: expected a finite number")
    return out


def positive_int(v, name):
    if type(v) is not int or v < 1:
        raise Incomplete(f"{name}: expected a positive integer")
    return v


def req(c, *keys):
    miss = [k for k in keys if k not in c]
    if miss:
        raise Incomplete(f"component {c.get('type')}: missing {', '.join(miss)}")


def timing_factor(c):
    t = c.get("timing", "immediate")
    if t == "immediate":
        return D(1)
    if t == "telegraphed_avoidable":
        return HALF
    raise Incomplete(f"unsupported timing: {t}")


# Each handler returns (label, points)
def c_damage(c):  # one-shot damage; ground_air +2 once for Strikes / authorized sources
    req(c, "damage", "cells")
    pts = dec(c["damage"]) * dec(c["cells"]) * 2 * timing_factor(c)
    if c.get("ground_air"):
        pts += 2
    return "damage", pts


def c_strike_extras(c):  # direction choice, distant cells, Kin package
    req(c, "kin", "kin_cells")
    kin = c["kin"]
    if not isinstance(kin, str) or kin not in KIN_PER_CELL:
        raise Incomplete(f"unknown Kin: {kin}")
    pts = KIN_PER_CELL[kin] * dec(c["kin_cells"]) + KIN_ONCE.get(kin, D(0))
    pts += 2 * dec(c.get("distant_cells", 0)) + (2 if c.get("direction") else 0)
    return "strike extras", pts


def c_anchor(c):
    modes = {"free": D(2), "adjacent": D(1), "none": D(0)}
    mode = c.get("mode", "free")
    if not isinstance(mode, str) or mode not in modes:
        raise Incomplete(f"anchor mode not priced: {mode}")
    return "anchor", modes[mode]


def c_marker(c):
    return "surge marker", D(1)


def c_zone(c):
    req(c, "effect", "value", "cells", "rounds")
    e = c["effect"]
    if not isinstance(e, str):
        raise Incomplete("zone effect must be a name")
    for key in ("value", "cells", "rounds"):
        positive_int(c[key], f"zone {key}")
    if e in ("push", "pull"):
        if c["value"] != 1:
            raise Incomplete("zone push/pull always moves exactly one square")
        return f"zone {e}", 2 * dec(c["cells"]) * dec(c["rounds"])
    if e not in ZONE_RATE:
        raise Incomplete(f"zone effect not priced: {e}")
    return f"zone {e}", ZONE_RATE[e] * dec(c["value"]) * dec(c["cells"]) * dec(c["rounds"])


def c_displacement(c):  # immediate 2/cell; telegraphed fixed-footprint avoidable 50 %
    req(c, "cells")
    return "displacement", 2 * dec(c["cells"]) * timing_factor(c)


def c_ground(c):
    req(c, "ground", "cells")
    g = c["ground"]
    if not isinstance(g, str) or g not in GROUND_PER_CELL:
        raise Incomplete(f"ground not priced: {g}")
    return f"ground {g}", GROUND_PER_CELL[g] * dec(c["cells"])


def c_move(c):
    req(c, "preset")
    if not isinstance(c["preset"], str) or c["preset"] not in MOVE_PRESET:
        raise Incomplete(f"movement preset not priced: {c['preset']}")
    return f"move {c['preset']}", MOVE_PRESET[c["preset"]] + 2 * dec(c.get("patches", 0))


def c_self_buff(c):  # Initiative only (4 per +1 per round)
    req(c, "stat", "magnitude", "rounds")
    if c["stat"] != "initiative":
        raise Incomplete("only the Initiative self-buff rate exists")
    return "self initiative", 4 * dec(c["magnitude"]) * dec(c["rounds"])


def c_rotation(c):
    return "rotation permission", D(6)


def c_nullify(c):  # sketch price per protected monster
    return "nullify (sketch)", D(9)


def c_relocate(c):
    req(c, "props")
    return "relocate (provisional)", 6 * dec(c["props"])


def c_prop(c):
    req(c, "tier")
    if c["tier"] not in PROP_BASE:
        raise Incomplete("prop tier")
    pts = PROP_BASE[c["tier"]] + {"ground": D(0), "air": D(2), "both": D(2)}[c.get("layer", "ground")]
    pts += dec(c.get("aftermath_damage_squares", 0)) + dec(c.get("aftermath_push_squares", 0))
    pts += dec(c.get("beam_squares", 0)) * 2
    pts += GROUND_PER_CELL[c.get("aftermath_ground", "plain")]
    pts += 4 if c.get("aura") else 0
    return "prop", pts


def c_air(c):
    return "air coverage", D(2)


HANDLERS = {"damage": c_damage, "strike_extras": c_strike_extras, "anchor": c_anchor, "marker": c_marker,
            "zone": c_zone, "displacement": c_displacement, "ground": c_ground, "move": c_move,
            "self_buff": c_self_buff, "rotation": c_rotation, "nullify": c_nullify, "relocate": c_relocate,
            "prop": c_prop, "air_coverage": c_air}


def availability(rec):
    usage = rec.get("usage")
    if usage == "active":
        ap = positive_int(rec.get("ap"), "ap")
        if ap not in AP_EFFICIENCY:
            raise Incomplete("ap must be 1..5")
        base = AP_EFFICIENCY[ap]
        if rec.get("once_per_round"):
            if "round_cap_effective" not in rec:
                raise Incomplete("round cap: effective-restriction check unresolved")
            return "AP efficiency", base * (ROUND_LIMIT_FACTOR if rec["round_cap_effective"] else 1)
        return "AP efficiency", base
    if usage == "passive_boolean":
        return "passive availability", PASSIVE_AVAILABILITY
    if usage == "event_once_per_round":
        return "event availability (once per round)", EVENT_ONCE_PER_ROUND
    raise Incomplete(f"availability not priced for usage: {usage} (repeatable/team-wide events are unpriced)")


def evaluate(rec, slot_level=1):
    if not isinstance(rec, dict) or not isinstance(rec.get("components"), list) or not rec["components"]:
        raise Incomplete("record needs a non-empty components list")
    if slot_level not in CEILING:
        raise Incomplete("slot level 1..3")
    parts = []
    for c in rec["components"]:
        if not isinstance(c, dict) or not isinstance(c.get("type"), str):
            raise Incomplete("component needs an object with a type name")
        h = HANDLERS.get(c.get("type"))
        if h is None:
            raise Incomplete(f"unsupported component: {c.get('type')}")
        parts.append(h(c))
    parts.append(availability(rec))
    total = sum((p for _, p in parts), D(0))
    return {"name": rec.get("name", "?"), "parts": [(l, str(p)) for l, p in parts], "total": total,
            "ceiling": CEILING[slot_level], "fits": total <= CEILING[slot_level]}


# ---------------------------------------------------------------- data files
DATA = Path(__file__).resolve().parent / "data"


def load_skills():
    """name -> (record, file name); records live in data/skills/*.json (one skill per file)."""
    out = {}
    for f in sorted((DATA / "skills").glob("*.json")):
        rec = json.loads(f.read_text(encoding="utf-8"))
        out[rec["name"]] = (rec, f.name)
    return out


def load_golden():
    return json.loads((DATA / "golden.json").read_text(encoding="utf-8"))


class GoldenTests(unittest.TestCase):
    def test_golden_records(self):
        skills = {f: r for r, f in load_skills().values()}
        golden = load_golden()["skills"]
        self.assertEqual(set(skills), set(golden), "every skill file needs a golden total and vice versa")
        for f, expected in golden.items():
            with self.subTest(f):
                self.assertEqual(evaluate(skills[f])["total"], D(expected))


    def test_zone_and_buff_reference_totals_unchanged(self):
        for name, expected in (("Slow zone 2 rounds", "23"), ("Slow zone 3 rounds", "27.5"),
                               ("Quicken 1, 3 cells, 2 rounds", "26"), ("Shield 2, 3 cells, 2 rounds", "26"),
                               ("Mend 1, 3 cells, 2 rounds", "32"), ("Self Initiative +1, 2 rounds", "20"),
                               ("Adaptive (rotation)", "18")):
            with self.subTest(name):
                self.assertEqual(evaluate(load_skills()[name][0])["total"], D(expected))

    def test_zone_invalid_parameters_and_ap_not_truncated(self):
        for key in ("value", "cells", "rounds"):
            for bad in (0, -1, True, 1.5, "2", None):
                c = dict(type="zone", effect="slow", value=1, cells=3, rounds=2)
                c[key] = bad
                with self.subTest(key=key, bad=bad), self.assertRaises(Incomplete):
                    c_zone(c)
        for effect in ("push", "pull"):
            with self.assertRaises(Incomplete):
                c_zone(dict(type="zone", effect=effect, value=2, cells=3, rounds=2))
        for bad in (True, 1.5, "2", 0, 6):
            with self.subTest(ap=bad), self.assertRaises(Incomplete):
                evaluate(dict(usage="active", ap=bad, components=[{"type": "marker"}]))
        for bad in (float("nan"), float("inf"), "NaN", "-Infinity"):
            with self.subTest(number=bad), self.assertRaises(Incomplete):
                dec(bad)
        for c in ({"type": "zone", "effect": [], "value": 1, "cells": 3, "rounds": 2},
                  {"type": "move", "preset": []}, {"type": "anchor", "mode": []},
                  {"type": "strike_extras", "kin": [], "kin_cells": 1},
                  {"type": "ground", "ground": [], "cells": 3}):
            with self.subTest(component=c), self.assertRaises(Incomplete):
                evaluate(dict(usage="active", ap=1, components=[c]))
        for bad in (None, "damage", {}, {"type": []}):
            with self.subTest(component=bad), self.assertRaises(Incomplete):
                evaluate(dict(usage="active", ap=1, components=[bad]))

    def test_prop_drafts(self):
        for row in load_golden()["props"]:
            with self.subTest(str(row["component"])):
                self.assertEqual(c_prop(row["component"])[1], D(row["expected"]))

    def test_ceiling_findings(self):  # Skills section 5 budget findings
        sk = {n: r for n, (r, _) in load_skills().items()}
        self.assertTrue(evaluate(sk["Scaled Jab"])["fits"])
        self.assertFalse(evaluate(sk["Scaled Arc"])["fits"])
        self.assertTrue(evaluate(sk["Scaled Arc"], 2)["fits"])
        self.assertTrue(evaluate(sk["Beast Storm"], 3)["fits"])

    def test_mountain_candidate_arithmetic(self):  # unapproved 0.5 destruction rate, paper check
        self.assertEqual(15 + 2 * (3 + 4 + D("0.5")), D(30))
        self.assertEqual(15 + 3 * (3 + 4 + D("0.5")), D("37.5"))

    def test_round_limit_and_events(self):
        r = dict(load_skills()["Slow zone 2 rounds"][0], once_per_round=True)
        with self.assertRaises(Incomplete):
            evaluate(r)  # effective-restriction check unresolved
        r["round_cap_effective"] = True
        self.assertEqual(evaluate(r)["total"], D(9) + 2 + D(12) * D("0.75"))
        ev = {"name": "e", "usage": "event_once_per_round", "components": [{"type": "nullify"}]}
        self.assertEqual(evaluate(ev)["total"], D(21))

    def test_fail_closed(self):
        for bad in ({"usage": "active", "ap": 1, "components": [{"type": "teleport_ally"}]},
                    {"usage": "event_repeatable", "components": [{"type": "nullify"}]},
                    {"usage": "active", "ap": 1, "components": [{"type": "zone", "effect": "expose", "value": 1, "cells": 1, "rounds": 1}]},
                    {"usage": "active", "ap": 1, "components": []},
                    {"usage": "active", "ap": 7, "components": [{"type": "marker"}]}):
            with self.subTest(str(bad)), self.assertRaises(Incomplete):
                evaluate(bad)


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("record", nargs="?", help="JSON record file or '-'")
    ap.add_argument("--slot-level", type=int, default=1)
    ap.add_argument("--self-test", action="store_true")
    ap.add_argument("--example")
    ap.add_argument("--list-examples", action="store_true")
    a = ap.parse_args()
    if a.self_test:
        res = unittest.TextTestRunner(verbosity=1).run(unittest.defaultTestLoader.loadTestsFromTestCase(GoldenTests))
        return 0 if res.wasSuccessful() else 2
    if a.list_examples:
        print("\n".join(load_skills()))
        return 0
    try:
        if a.example:
            if a.example not in load_skills():
                raise Incomplete("unknown example (use --list-examples)")
            rec = load_skills()[a.example][0]
        elif a.record:
            rec = json.load(sys.stdin if a.record == "-" else open(a.record, encoding="utf-8"))
        else:
            ap.error("give a record file, --example or --self-test")
        out = evaluate(rec, a.slot_level)
    except (Incomplete, OSError, json.JSONDecodeError) as exc:
        print(json.dumps({"status": "incomplete", "approval": False, "error": str(exc)}))
        return 2
    print(json.dumps({"status": "fit" if out["fits"] else "over_ceiling", "approval": False, "name": out["name"],
                      "parts": out["parts"], "total": str(out["total"]), "ceiling": str(out["ceiling"])}, indent=1))
    return 0 if out["fits"] else 1


if __name__ == "__main__":
    sys.exit(main())
