#!/usr/bin/env python3
"""Temporary, offline GDD arithmetic checker (Python standard library only).

Examples (run from the repository root):
  python3 docs/temp_kalkscript.py --self-test
  python3 docs/temp_kalkscript.py --example slow
  python3 docs/temp_kalkscript.py --example surge --slot-level 2
  python3 docs/temp_kalkscript.py --example ground --slot-level 2
  python3 docs/temp_kalkscript.py --example zone_push --slot-level 2
  python3 docs/temp_kalkscript.py --example jab --export-example > docs/temp_skill.json
  python3 docs/temp_kalkscript.py docs/temp_skill.json

JSON is a temporary notation for the existing 14 field groups, not a second
skill schema or engine format. --export-example shows the supported notation.
Only explicitly supported resolved subsets are calculated. Unsupported inputs
fail closed. A numeric fit is NOT content, access, interaction or balance approval.
No battle state is read, no files are modified, and no prototype is executed.
"""

import argparse
import copy
import json
import re
import sys
import unittest
from decimal import Decimal, InvalidOperation
from pathlib import Path

GDD = Path(__file__).resolve().with_name("gdd_monsters.md")
GROUPS = set("metadata access usage_type execution targeting placement area effects "
             "persistence board_changes interactions usage upgrades evaluation".split())
D = Decimal


class Incomplete(ValueError):
    """No defensible numeric result can be returned for this input."""


def number(value):
    if isinstance(value, bool) or not isinstance(value, (int, Decimal, str)):
        raise Incomplete("Expected a finite decimal number, not a boolean/float.")
    try:
        result = D(value)
    except InvalidOperation as exc:
        raise Incomplete("Invalid decimal number.") from exc
    if not result.is_finite():
        raise Incomplete("Non-finite numbers are forbidden.")
    return result


def unique_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise Incomplete("Duplicate JSON field: " + key)
        result[key] = value
    return result


def integer(value, minimum=0):
    n = number(value)
    if n != n.to_integral_value() or n < minimum:
        raise Incomplete("Expected an integer >= " + str(minimum))
    return int(n)


def only_keys(record, required, optional=()):
    if not isinstance(record, dict):
        raise Incomplete("Expected an object with fields: " + ", ".join(required))
    if set(record) - set(required) - set(optional) or set(required) - set(record):
        raise Incomplete("Unsupported/missing fields: expected " + ", ".join(required))


class Prices:
    """Read owning GDD tables; never silently fall back to embedded prices."""

    def __init__(self, text):
        self.text = text

    def section(self, heading):
        lines = self.text.splitlines()
        title = next((i for i, line in enumerate(lines) if line == heading), None)
        if title is None:
            raise Incomplete("GDD heading changed/missing: " + heading)
        level = len(heading) - len(heading.lstrip("#"))
        end = next((i for i in range(title + 1, len(lines))
                    if re.match(r"^#{1," + str(level) + r"} ", lines[i])), len(lines))
        return "\n".join(lines[title + 1:end])

    def row(self, heading, label):
        section = self.section(heading)
        if heading == "### 4.5 Construction Points and AP Efficiency":
            section = section.split("\n#### ", 1)[0]
        rows = [line.split("|")[2].strip()
                for line in section.splitlines()
                if line.startswith("| " + label + " |")]
        if len(rows) != 1:
            raise Incomplete("GDD price row changed/missing/ambiguous: " + label)
        return rows[0]

    def scalar(self, heading, label, pattern):
        value = self.row(heading, label)
        match = re.fullmatch(pattern, value)
        if not match:
            raise Incomplete("Unsupported GDD price expression for " + label + ": " + value)
        return number(match.group(1))

    def component(self, label, pattern):
        return self.scalar("#### Component Price Sheet", label, pattern)

    def ap(self, ap):
        return self.scalar("#### AP-Efficiency Working Scale", str(ap), r"([0-9.]+)")

    def ceiling(self, level):
        return self.scalar("### 4.5 Construction Points and AP Efficiency", str(level),
                           r"([0-9.]+) points \([^)]*\)")

    def round_factor(self):
        section = self.section("#### Round-Limited Availability Calibration")
        match = re.search(r"use \*\*([0-9.]+)% of its AP-efficiency component\*\*", section)
        if not match:
            raise Incomplete("Round-limit valuation wording changed; review the parser.")
        return number(match.group(1)) / 100


def example(name):
    skill = {
        "metadata": {"id": "calculation_reference", "kind": "zone", "rule_profile": "zone"},
        "access": {"reference": "GDD reference only; not a learn-list approval"},
        "usage_type": "active",
        "execution": {"activation": "player_action", "timing": "immediate"},
        "targeting": {"type": "tile", "distance_source": "caster_reach", "line_of_sight": "not_required"},
        "placement": {"anchor": "selected_tile", "direction_selection": "none"},
        "area": {"offsets": [[-1, 0], [0, 0], [1, 0]], "cell_count": 3,
                 "orientation_policy": "fixed_board", "boundary_rule": "all_cells_on_board"},
        "effects": [{"type": "slow", "value": 1, "recipients": ["ground"]}],
        "persistence": {"duration": 2, "clock": "round_end"},
        "board_changes": [],
        "interactions": {"reference": "Unmodified owning GDD profile; 1x1 reference bodies only"},
        "usage": {"ap_cost": 1, "repetition": "repeatable"},
        "upgrades": [],
        "evaluation": None,
    }
    if name == "surge":
        skill["metadata"].update(kind="surge", rule_profile="minor_surge_residue_free")
        skill["execution"]["timing"] = "telegraphed_delayed"
        skill["effects"] = [{"type": "damage", "value": 3, "recipients": ["ground"]}]
        skill["persistence"] = {"until": "resolution"}
    elif name in ("zone_push", "zone_pull"):
        skill["effects"] = [{"type": "displacement", "mode": "push", "steps": 1,
                             "direction": [1, 0], "recipients": ["ground"]}]
        if name == "zone_pull":
            skill["effects"][0] = {"type": "displacement", "mode": "pull", "steps": 1,
                                   "anchor": "cast_anchor", "recipients": ["ground"]}
    elif name in ("ground", "hallowed", "mountain"):
        skill["metadata"].update(kind="ground", rule_profile="ground")
        skill["effects"] = []
        skill["persistence"] = {"type": "permanent"}
        skill["board_changes"] = [{"type": "ground", "ground": "Lava", "level": 1}]
        if name == "hallowed":
            skill["board_changes"] = [{"type": "ground", "ground": "Hallowed"}]
            skill["usage"]["ap_cost"] = 2
        elif name == "mountain":
            skill["board_changes"] = [{"type": "create_mountain"}]
    elif name == "jab":
        skill["metadata"].update(kind="strike", rule_profile="strike", kin="Beast")
        skill["targeting"] = {"type": "self"}
        skill["placement"] = {"anchor": "caster_body", "direction_selection": "one_of_eight"}
        skill["area"].update(offsets=[[1, 0]], cell_count=1,
                             orientation_policy="strike_direction_selection")
        skill["effects"] = [{"type": "damage", "value": 2, "recipients": ["ground", "air"]}]
        skill["persistence"] = None
        skill["usage"]["ap_cost"] = 2
    return skill


def calculate(skill, prices, level):
    if not isinstance(skill, dict) or set(skill) != GROUPS:
        raise Incomplete("Input must contain exactly the existing 14 GDD field groups.")
    if skill["evaluation"] is not None or skill["upgrades"] != []:
        raise Incomplete("Supply evaluation=null and an already resolved variant (upgrades=[]).")

    if skill["usage_type"] != "active":
        raise Incomplete("Passive/event evaluation is not implemented in this checker; unsupported effects are not free.")
    only_keys(skill["metadata"], ("id", "kind", "rule_profile"), ("kin",))
    only_keys(skill["access"], ("reference",))
    only_keys(skill["interactions"], ("reference",))
    # References assert the unmodified profile. This tool cannot prove legality.
    if skill["access"] != example("slow")["access"] or skill["interactions"] != example("slow")["interactions"]:
        raise Incomplete("Only the documented unmodified reference contracts are supported.")
    kind = skill["metadata"]["kind"]
    names = {"zone": "slow", "surge": "surge", "strike": "jab", "ground": "ground"}
    if kind not in names:
        raise Incomplete("Unsupported profile; use zone, ground, residue-free Surge or Beast Jab references.")
    base = example(names[kind])
    if kind != "ground" and skill["board_changes"] != []:
        raise Incomplete("This profile grants no supported authored board payload; concrete Surge reactions remain incomplete.")
    for group in ("execution", "targeting", "placement"):
        if skill[group] != base[group]:
            raise Incomplete("Unsupported " + group + " variant; no inferred price/permission.")
    expected_metadata = base["metadata"].copy()
    expected_metadata["id"] = skill["metadata"]["id"]
    if skill["metadata"] != expected_metadata:
        raise Incomplete("Unsupported profile/Kin combination.")
    area = skill["area"]
    only_keys(area, ("offsets", "cell_count", "orientation_policy", "boundary_rule"))
    if area["orientation_policy"] != base["area"]["orientation_policy"] or area["boundary_rule"] != "all_cells_on_board":
        raise Incomplete("Unsupported orientation/boundary contract.")
    offsets = area["offsets"]
    if not isinstance(offsets, list) or not offsets:
        raise Incomplete("Explicit nonempty offsets are required.")
    cells = []
    for xy in offsets:
        if not isinstance(xy, list) or len(xy) != 2:
            raise Incomplete("Offsets must be integer [dx, dy] pairs.")
        pair = tuple(number(v) for v in xy)
        if any(v != v.to_integral_value() for v in pair):
            raise Incomplete("Fractional footprint offsets are invalid.")
        cells.append(pair)
    if len(set(cells)) != len(cells) or integer(area["cell_count"], 1) != len(cells):
        raise Incomplete("Duplicate offsets or cell_count mismatch.")
    c = D(len(cells))
    if kind == "strike" and (cells != [(D(1), D(0))]):
        raise Incomplete("Only the explicit cardinal Beast Jab reference is supported.")
    if kind != "strike" and not 2 <= len(cells) <= 4:
        raise Incomplete("Ordinary reference footprints must have 2–4 cells.")
    effects = skill["effects"]
    if not isinstance(effects, list):
        raise Incomplete("Effects must be a list of typed definitions.")
    if kind == "ground":
        if effects:
            raise Incomplete("Ground occupant effects are included in the board package; no duplicate/additional payload supported.")
    elif kind == "zone":
        if not 1 <= len(effects) <= 2:
            raise Incomplete("Supported zones contain slow, one displacement, or both.")
    elif effects != base["effects"]:
        raise Incomplete("Unsupported effect/value/recipients; no new source or damage upgrade inferred.")
    if kind == "ground":
        operations = skill["board_changes"]
        if not isinstance(operations, list) or len(operations) != 1:
            raise Incomplete("Exactly one supported board package is required; no independent cleanse or reaction charges.")
        operation = operations[0]
        if operation == {"type": "create_mountain"}:
            board_label = "Mountain creation with coupled Plain reset"
        else:
            only_keys(operation, ("type", "ground"), ("level",))
            if operation["type"] != "ground":
                raise Incomplete("Unsupported board operation.")
            ground = operation["ground"]
            if ground in ("Lava", "Thornbed", "Blight"):
                if integer(operation.get("level"), 1) != 1:
                    raise Incomplete("Only authored level-I hazard packages are supported.")
                board_label = "Lava I / Thornbed I / Blight I, immediate cast or delayed aftermath"
            elif ground in ("Hearth", "Umbra", "Hallowed"):
                if "level" in operation:
                    raise Incomplete("Blessed ground has no authored level.")
                board_label = "Hallowed" if ground == "Hallowed" else "Hearth / Umbra"
                base["usage"]["ap_cost"] = 2
            else:
                raise Incomplete("Unresolved/unsupported ground (including Mossbed loops); not a zero-cost package.")
    usage = skill["usage"]
    only_keys(usage, ("ap_cost", "repetition"))
    ap = integer(usage["ap_cost"], 1)
    if ap != base["usage"]["ap_cost"]:
        raise Incomplete("This checker retains the reference's original AP price.")
    if usage["repetition"] not in ("repeatable", "once_per_global_round"):
        raise Incomplete("Unknown repetition policy.")
    rows = []

    def charge(source, label, amount):
        rows.append({"source": source, "component": label, "points": amount})

    if kind == "zone":
        only_keys(skill["persistence"], ("duration", "clock"))
        rounds = integer(skill["persistence"]["duration"], 1)
        if skill["persistence"]["clock"] != "round_end" or rounds not in (2, 3):
            raise Incomplete("Only the reference's 2 rounds or bounded +1-round candidate is supported.")
        seen = set()
        for i, effect in enumerate(effects):
            if not isinstance(effect, dict):
                raise Incomplete("Expected a typed effect object.")
            effect_type = effect.get("type")
            if effect_type not in ("slow", "displacement") or effect_type in seen:
                raise Incomplete("Unknown or duplicate zone component; no inferred stacking or free effects.")
            seen.add(effect_type)
            if effect_type == "slow":
                if effect != example("slow")["effects"][0]:
                    raise Incomplete("Only the existing Slow base-1 ground-recipient contract is supported.")
                rate = prices.scalar("#### Zone, Protection and Healing Costs", "slow / haste",
                                     r"([0-9.]+) × V × C × R")
                amount = rate * number(effect["value"]) * c * rounds
            else:
                mode = effect.get("mode")
                if integer(effect.get("steps"), 1) != 1 or effect.get("recipients") != ["ground"]:
                    raise Incomplete("Zone displacement requires one step and ground recipients.")
                if mode == "push":
                    only_keys(effect, ("type", "mode", "steps", "direction", "recipients"))
                    direction = effect["direction"]
                    if not isinstance(direction, list) or len(direction) != 2:
                        raise Incomplete("Push direction must be a fixed cardinal vector.")
                    if tuple(number(v) for v in direction) not in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                        raise Incomplete("Only cardinal one-square directions are supported.")
                elif mode == "pull":
                    only_keys(effect, ("type", "mode", "steps", "anchor", "recipients"))
                    if effect["anchor"] != "cast_anchor":
                        raise Incomplete("Only the fixed cast-anchor pull contract is supported.")
                else:
                    raise Incomplete("Only zone push/pull displacement is supported.")
                rate = prices.scalar("#### Zone, Protection and Healing Costs", "Zone push / pull",
                                     r"([0-9.]+) × C × R")
                amount = rate * c * rounds
            charge("effects[" + str(i) + "], area, persistence", effect_type + " zone package", amount)
    elif kind == "ground":
        if skill["persistence"] != {"type": "permanent"}:
            raise Incomplete("Ground/height packages already include permanent lifetime.")
        rate = prices.scalar("#### Ground and Board Costs", board_label, r"([0-9.]+) × C")
        charge("board_changes[0], area, persistence", board_label, rate * c)
    else:
        if skill["persistence"] != base["persistence"]:
            raise Incomplete("Unsupported persistence or extra lifetime.")
        rate = prices.component("One-shot damage", r"damage × cells × ([0-9.]+)")
        timing = prices.component("Telegraphed, avoidable Surge timing" if kind == "surge" else "Immediate timing",
                                  r"([0-9.]+)% of damage base price") / 100
        charge("effects[0], area, execution", "One-shot reference damage", rate * number(effects[0]["value"]) * c * timing)
    if kind in ("zone", "surge", "ground"):
        charge("targeting, placement", "Free board anchor", prices.component("Free board anchor within Reach, no LOS", r"\+([0-9.]+)"))
    if kind == "strike":
        charge("placement", "Footprint direction", prices.component("Strike footprint-direction choice", r"\+([0-9.]+)"))
        charge("effects[0].recipients", "Ground + air coverage", prices.component("Ground + air damage coverage", r"\+([0-9.]+) per damage effect"))
    if kind == "surge":
        charge("execution", "Complete charging marker", prices.component("Charging Surge blocking", r"\+([0-9.]+) per complete marker"))
    availability = prices.ap(ap)
    if usage["repetition"] == "once_per_global_round":
        if area["offsets"] != base["area"]["offsets"]:
            raise Incomplete("Effective round restriction not established for non-reference geometry.")
        # Supported reference geometries admit multiple casts for legal users;
        # they have no independent charging cap. Do not extrapolate to new profiles.
        availability *= prices.round_factor()
    charge("usage", "Active availability", availability)
    total = sum((r["points"] for r in rows), D(0))
    ceiling = prices.ceiling(level)
    return {"status": "arithmetic_only", "skill": skill["metadata"]["id"],
            "slot_level": level, "components": rows, "total": total,
            "ceiling": ceiling, "within_ceiling": total <= ceiling,
            "approval": False,
            "limitations": ["No content/access/geometry/interaction/balance approval.",
                            "1x1 references only; access/interactions are referenced, not mechanically verified.",
                            "No live state, probabilities or observed trigger counts used.",
                            "Component sums do not resolve event order, source permissions or prop interactions.",
                            "Unsupported effects and operations must not be omitted to obtain a passing result."]}


def encode(value):
    if isinstance(value, Decimal):
        return str(value)
    raise TypeError("Cannot encode " + type(value).__name__)


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    source = parser.add_mutually_exclusive_group(required=True)
    source.add_argument("input", nargs="?", type=Path, help="Resolved JSON reference record; - reads stdin")
    source.add_argument("--example", choices=("slow", "surge", "jab", "zone_push", "zone_pull", "ground", "hallowed", "mountain"))
    source.add_argument("--self-test", action="store_true")
    parser.add_argument("--export-example", action="store_true", help="Print input JSON instead of a report")
    parser.add_argument("--slot-level", type=int, choices=(1, 2, 3), default=1)
    args = parser.parse_args()
    if args.export_example and not args.example:
        parser.error("--export-example requires --example")
    if args.self_test:
        suite = unittest.defaultTestLoader.loadTestsFromTestCase(Checks)
        return 0 if unittest.TextTestRunner(verbosity=2).run(suite).wasSuccessful() else 2
    try:
        prices = Prices(GDD.read_text(encoding="utf-8"))
        skill = example(args.example) if args.example else json.loads(
            sys.stdin.read() if str(args.input) == "-" else args.input.read_text(encoding="utf-8"),
            parse_float=D, object_pairs_hook=unique_object,
            parse_constant=lambda s: (_ for _ in ()).throw(Incomplete("Non-finite JSON: " + s)))
        if args.export_example:
            print(json.dumps(skill, indent=2, default=encode))
            return 0
        result = calculate(skill, prices, args.slot_level)
        print(json.dumps(result, indent=2, default=encode))
        return 0 if result["within_ceiling"] else 1
    except (Incomplete, OSError, ValueError, KeyError, TypeError, RecursionError) as exc:
        print(json.dumps({"status": "incomplete", "approval": False, "error": str(exc)}), file=sys.stderr)
        return 2


class Checks(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.prices = Prices(GDD.read_text(encoding="utf-8"))

    def test_documented_references(self):
        for name, total in (("slow", "23"), ("surge", "24"), ("jab", "14")):
            with self.subTest(name=name):
                report = calculate(example(name), self.prices, 1)
                self.assertEqual(report["total"], D(total))
                self.assertFalse(report["approval"])

    def test_fractional_total_and_ceiling(self):
        s = example("slow")
        s["persistence"]["duration"] = 3
        self.assertEqual(calculate(s, self.prices, 1)["total"], D("27.5"))
        self.assertFalse(calculate(s, self.prices, 1)["within_ceiling"])
        self.assertTrue(calculate(s, self.prices, 2)["within_ceiling"])

    def test_round_cap_changes_only_availability(self):
        for name in ("slow", "surge", "jab"):
            s = example(name)
            before = calculate(s, self.prices, 1)
            s["usage"]["repetition"] = "once_per_global_round"
            after = calculate(s, self.prices, 1)
            self.assertEqual(before["components"][:-1], after["components"][:-1])
            self.assertEqual(after["components"][-1]["points"], before["components"][-1]["points"] * D("0.75"))

    def test_duplicate_instances_have_identical_independent_reports(self):
        a = example("slow")
        a["usage"]["repetition"] = "once_per_global_round"
        b = copy.deepcopy(a)
        b["metadata"]["id"] = "second_equipped_copy"
        self.assertEqual(calculate(a, self.prices, 1)["total"], calculate(b, self.prices, 1)["total"])

    def test_fail_closed(self):
        variants = []
        s = example("slow"); s["board_changes"] = [{"type": "unknown"}]; variants.append(s)
        s = example("slow"); s["effects"].append({"type": "heal"}); variants.append(s)
        s = example("slow"); s["effects"][0]["recipients"] = ["allies"]; variants.append(s)
        s = example("slow"); s["area"]["offsets"][0] = [0, 0]; variants.append(s)
        s = example("slow"); s["area"]["cell_count"] = 4; variants.append(s)
        s = example("slow"); s["usage_type"] = "passive"; variants.append(s)
        s = example("slow"); s["usage"]["ap_cost"] = 0; variants.append(s)
        s = example("slow"); s["evaluation"] = {"total": 0}; variants.append(s)
        s = example("slow"); s["effects"][0]["free_extra"] = True; variants.append(s)
        for i, s in enumerate(variants):
            with self.subTest(case=i), self.assertRaises(Incomplete):
                calculate(s, self.prices, 1)

    def test_gdd_price_change_is_read(self):
        text = self.prices.text.replace("damage × cells × 2 |", "damage × cells × 2.5 |")
        self.assertEqual(calculate(example("surge"), Prices(text), 1)["total"], D("26.25"))

    def test_missing_gdd_rate_is_not_zero(self):
        changed = Prices(self.prices.text.replace("| One-shot damage |", "| Renamed damage |"))
        with self.assertRaises(Incomplete):
            calculate(example("surge"), changed, 1)

    def test_duplicate_json_keys_rejected(self):
        with self.assertRaises(Incomplete):
            json.loads('{"effects": [], "effects": []}', object_pairs_hook=unique_object)

    def test_custom_geometry_has_no_automatic_round_discount(self):
        s = example("surge")
        s["area"]["offsets"] = [[0, 0], [1, 0], [2, 0]]
        s["usage"]["repetition"] = "once_per_global_round"
        with self.assertRaises(Incomplete):
            calculate(s, self.prices, 1)

    def test_ground_and_displacement_references(self):
        for name, total in (("ground", "26"), ("hallowed", "20"), ("mountain", "29"),
                            ("zone_push", "26"), ("zone_pull", "26")):
            with self.subTest(name=name):
                self.assertEqual(calculate(example(name), self.prices, 1)["total"], D(total))

    def test_cardinal_directions_have_same_cost(self):
        for direction in ([1, 0], [-1, 0], [0, 1], [0, -1]):
            s = example("zone_push")
            s["effects"][0]["direction"] = direction
            self.assertEqual(calculate(s, self.prices, 2)["total"], D("26"))
        s["effects"][0]["direction"] = [1, 1]
        with self.assertRaises(Incomplete):
            calculate(s, self.prices, 2)

    def test_composed_zone_charges_shared_costs_once(self):
        s = example("slow")
        s["effects"].extend(example("zone_push")["effects"])
        report = calculate(s, self.prices, 2)
        self.assertEqual(report["total"], D("35"))
        self.assertEqual(len(report["components"]), 4)
        s["effects"].reverse()
        self.assertEqual(calculate(s, self.prices, 2)["total"], D("35"))
        s["usage"]["repetition"] = "once_per_global_round"
        self.assertEqual(calculate(s, self.prices, 2)["total"], D("32"))

    def test_ground_price_changes_are_read(self):
        text = self.prices.text.replace("| 4 × C | Permanent hazard package;", "| 4.5 × C | Permanent hazard package;")
        self.assertNotEqual(text, self.prices.text)
        self.assertEqual(calculate(example("ground"), Prices(text), 1)["total"], D("27.5"))

    def test_new_round_caps_change_only_availability(self):
        for name in ("ground", "hallowed", "mountain", "zone_push", "zone_pull"):
            s = example(name)
            before = calculate(s, self.prices, 2)
            s["usage"]["repetition"] = "once_per_global_round"
            after = calculate(s, self.prices, 2)
            self.assertEqual(before["components"][:-1], after["components"][:-1])
            self.assertEqual(after["components"][-1]["points"], before["components"][-1]["points"] * D("0.75"))

    def test_no_ground_or_displacement_shortcuts(self):
        variants = []
        for ground in ("Mossbed", "Water", "Voidscar", "Unknown"):
            s = example("ground"); s["board_changes"][0]["ground"] = ground; variants.append(s)
        s = example("ground"); s["board_changes"][0]["level"] = 2; variants.append(s)
        s = example("ground"); s["board_changes"][0]["level"] = True; variants.append(s)
        s = example("ground"); s["effects"] = example("surge")["effects"]; variants.append(s)
        s = example("ground"); s["persistence"] = {"duration": 2}; variants.append(s)
        s = example("mountain"); s["board_changes"].append({"type": "cleanse"}); variants.append(s)
        s = example("zone_push"); s["effects"][0]["steps"] = 2; variants.append(s)
        s = example("zone_push"); s["effects"][0]["steps"] = True; variants.append(s)
        s = example("zone_push"); s["effects"][0]["direction"] = [True, 0]; variants.append(s)
        s = example("zone_pull"); s["effects"][0]["anchor"] = "tracking_unit"; variants.append(s)
        s = example("slow"); s["effects"] *= 2; variants.append(s)
        s = example("surge"); s["effects"].extend(example("zone_push")["effects"]); variants.append(s)
        for i, s in enumerate(variants):
            with self.subTest(case=i), self.assertRaises(Incomplete):
                calculate(s, self.prices, 1)

    def test_missing_board_or_displacement_price_fails_closed(self):
        for name, label in (("ground", "Lava I / Thornbed I / Blight I, immediate cast or delayed aftermath"),
                            ("zone_push", "Zone push / pull")):
            changed = Prices(self.prices.text.replace("| " + label + " |", "| Removed row |"))
            with self.subTest(name=name), self.assertRaises(Incomplete):
                calculate(example(name), changed, 1)

    def test_nonfinite_numbers_rejected(self):
        for value in (True, "NaN", "Infinity", "not a number"):
            with self.subTest(value=value), self.assertRaises(Incomplete):
                number(value)


if __name__ == "__main__":
    sys.exit(main())
