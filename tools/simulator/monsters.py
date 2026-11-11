#!/usr/bin/env python3
"""Monster builder: assembles a battle sheet from data/monsters/*.json and data/skills/*.json (stdlib only).

A monster file is a TEST SHEET (stats + up to 4 skill slots with explicit slot levels). It makes no claim about
which slot levels are reachable at a stage (open: T05) and is not a roster entry. The builder checks, per the
docs (Monsters section 2, Skills sections 1/5), and reports errors (illegal) and warnings (open rules):
  - stat points (value x price) against the stage/sub-tier budget, stage ceilings, AP 4-5 needs TPR 1
  - kit: 1-4 slots, at least one active, skill price <= ceiling of the slot level (pricing.py), skill AP <= monster AP,
    Strike Kin equals monster Kin; skills without a price are incomplete (fail closed)
  - 'sim' hints: which skills the reduced simulator can execute; others are reported as NOT SIMULATED

  python3 -I tools/simulator/monsters.py --list
  python3 -I tools/simulator/monsters.py test_golem_eruption     (prints the sheet; exit 1 on errors)
  python3 -I tools/simulator/monsters.py --compare test_golem_eruption test_golem_rift
Results are indications only, never balance or content approval.
"""
import json
import sys
import unittest
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
    if st["ap"] >= 4 and st["tpr"] != 1:
        errors.append("AP 4-5 requires TPR 1")
    if st["tpr"] >= 2 and st["ap"] >= 3:
        warnings.append("TPR 2+ with AP 3: open rule conflict (T03)")
    if not 1 <= len(m["slots"]) <= 4:
        errors.append("kit needs 1-4 slots")
    actives = 0
    sim = {"strikes": [], "surge": None, "surge_ap": 1, "movement": None, "walk_ap": 2}
    for i, slot in enumerate(m["slots"], 1):
        entry = skills.get(slot["skill"])
        if entry is None:
            errors.append(f"slot {i}: unknown skill {slot['skill']!r}")
            continue
        rec, _ = entry
        try:
            ev = pricing.evaluate(rec, slot.get("level", 1))
        except pricing.Incomplete as exc:
            errors.append(f"slot {i} {rec['name']}: incomplete pricing ({exc})")
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
        hint = rec.get("sim", {})
        act = hint.get("action")
        if act == "strike":
            kin = next(c["kin"] for c in rec["components"] if c["type"] == "strike_extras")
            dmg = next((int(c["damage"]) for c in rec["components"] if c["type"] == "damage"), 0)
            sim["strikes"].append(dict(shape=hint["shape"], kin=kin, dmg=dmg, ap=rec["ap"], push=hint.get("push", "all")))
            if kin == "ancient":
                warnings.append(f"slot {i} {rec['name']}: Mountain destruction effect NOT SIMULATED (no Mountains)")
        elif act == "surge":
            sim["surge"], sim["surge_ap"] = hint["profile"], rec["ap"]
        elif act == "move":
            sim["movement"], sim["walk_ap"] = hint["preset"], rec["ap"]
        else:
            warnings.append(f"slot {i} {rec['name']}: NOT SIMULATED (no executable sim hint)")
        slots.append(dict(skill=rec["name"], level=slot.get("level", 1), points=str(ev["total"]), ceiling=str(ev["ceiling"])))
    if actives == 0:
        errors.append("kit needs at least one active skill")
    sheet = dict(hp=st["hp"], init=float(st["init"]), move=st["move"], reach=st["reach"], ap=st["ap"],
                 strikes=sim["strikes"], surge=sim["surge"] or "none", surge_ap=sim["surge_ap"],
                 movement=sim["movement"] or "step", walk_ap=sim["walk_ap"])
    return dict(name=name, kin=m["kin"], stage=f"{m['stage']} {m['subtier']}", stat_points=f"{spent:g}/{budget}",
                slots=slots, errors=errors, warnings=warnings, sheet=sheet, ok=not errors)


class BuilderTests(unittest.TestCase):
    def test_reference_stats_are_31_points(self):  # Monsters section 4.1 reference individuals
        for s in ((5, 7, 4, 2, 1, 3), (2, 9, 3, 2, 2, 2), (8, 4, 1, 3, 1, 3), (3, 6, 2, 3, 2, 2)):
            self.assertEqual(stat_points(dict(zip(("hp", "init", "move", "reach", "tpr", "ap"), s))), 31)

    def test_test_sheets_are_legal(self):
        for n in list_monsters():
            with self.subTest(n):
                self.assertTrue(build(n)["ok"], build(n)["errors"])

    def test_engine_shapes_match_priced_cells(self):  # price inputs (hit/distant cells) vs. engine geometry
        import battle_sim as bs
        for rec, fname in pricing.load_skills().values():
            h = rec.get("sim", {})
            if h.get("action") != "strike":
                continue
            dmg = next((c for c in rec["components"] if c["type"] == "damage"), None)
            ex = next(c for c in rec["components"] if c["type"] == "strike_extras")
            cells = dmg["cells"] if dmg else 1
            for d in bs.strike_dirs(h["shape"]):
                offs = [o for ray in bs.shape_rays(h["shape"], d) for o in ray]
                with self.subTest(fname, d=d):
                    self.assertEqual(len(offs), cells)
                    self.assertEqual(sum(1 for o in offs if max(abs(o[0]), abs(o[1])) > 1), ex.get("distant_cells", 0))
                    self.assertEqual(len(set(offs)), len(offs))

    def test_illegal_cases_are_caught(self):
        base = load_monster("test_golem_eruption")
        import tempfile
        d = Path(tempfile.mkdtemp())
        global DATA
        old, DATA = DATA, d
        try:
            (d / "monsters").mkdir()
            bad = dict(base, name="bad", stats=dict(base["stats"], hp=9))
            bad["slots"] = [{"skill": "Eruption 2 cells", "level": 1}, {"skill": "Scaled Jab", "level": 1}]
            (d / "monsters" / "bad.json").write_text(json.dumps(bad), encoding="utf-8")
            r = build("bad")
            text = " ".join(r["errors"])
            self.assertFalse(r["ok"])
            for needle in ("exceed budget", "ceiling 8", "exceed ceiling 24", "Kin scaled"):
                self.assertIn(needle, text)
        finally:
            DATA = old


def main():
    a = sys.argv[1:]
    if not a or a[0] in ("-h", "--help"):
        print(__doc__)
        return 0
    if a[0] == "--self-test":
        r = unittest.TextTestRunner(verbosity=1).run(unittest.defaultTestLoader.loadTestsFromTestCase(BuilderTests))
        return 0 if r.wasSuccessful() else 2
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
