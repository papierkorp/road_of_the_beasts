#!/usr/bin/env python3
"""Throwaway price experiment for Road of the Beasts (stdlib only, not the Godot game).

Run: python3 -I tools/simulator/battle_sim.py --help
Equal-cost, side-swapped runs: python3 -I tools/simulator/compare.py --help
Reusable inputs: data/skills/*.json and data/monsters/*.json; rules/prices remain in docs/.

Reduced coverage: 1x1 ground bodies, flat square boards, props/aftermath, ground triggers,
AP, movement presets, Strike shapes, one two-cell Surge profile per monster, zones
(Slow/Shield/Mend scaling, base-only unresolved stat effects, end-turn push/pull), Focus,
and Adaptive rotation of centred I3 zones. Mossbed heals on every entry; Mend heals
min(2, zone level). Same-effect Focus copies refresh, never stack. Bots are crude.

NOT SIMULATED: Mountains, air, 2x2, extra turns, tamer/loadout effects, Nullify, other
passives, full Surge scheduling/geometry and skill-created props. Unknown effect scaling
is not invented. Legacy --arch retains its old 1-AP walk and simplified rules; no durable
regression harness. More limitations in README.md. No full-model completion target:
this gives price indications only, never rule, content, balance or price approval.
"""
import argparse
import random
import sys
from pathlib import Path
from collections import Counter, defaultdict


sys.path.insert(0, str(Path(__file__).resolve().parent))
DIRS8 = [(1, 0), (-1, 0), (0, 1), (0, -1), (1, 1), (1, -1), (-1, 1), (-1, -1)]
DIRS4 = DIRS8[:4]
HAZ = {"lava": "end", "thorn": "enter", "blight": "start"}

# prop: hp, heavy, aura, on_destroy, ground left
PROPS = {
    "stone_lion": dict(hp=3, heavy=True, ground="rubble"),
    "clay_urn": dict(hp=1, burst=8, ground="plain"),
    "bamboo": dict(hp=2, burst=4, ground="plain"),
    "lantern": dict(hp=1, ground="lava"),
    "peach": dict(hp=2, ground="mossbed"),
    "tablet": dict(hp=2, ground="hallowed"),
    "gong": dict(hp=2, push=True, ground="plain"),
    "column": dict(hp=3, spawn=True, ground="rubble"),
    "beam": dict(hp=1, ground="plain"),
    "shrine": dict(hp=2, aura="init", ground="rubble"),
    "totem": dict(hp=2, aura="reach", ground="rubble"),
    "banner": dict(hp=2, aura="move", ground="rubble"),
    "wardstone": dict(hp=2, aura="ward", ground="rubble"),
}
SURGES = {"eruption": (3, "lava"), "flood": (2, "thorn"), "rift": (3, "blight")}
ARCH = {
    "brawler": dict(hp=7, init=4.0, move=2, reach=2, ap=3),
    "caster": dict(hp=4, init=7.0, move=3, reach=3, ap=3),
    "balanced": dict(hp=5, init=5.0, move=3, reach=3, ap=3),
}


ZONE_OPPOSITE = {"slow": "haste", "haste": "slow", "drain_init": "quicken", "quicken": "drain_init",
                 "drain_range": "extend", "extend": "drain_range", "push": "pull", "pull": "push",
                 "shield": "expose", "expose": "shield"}  # Battle 4.6; mend has none
ZONE_MAX_LEVEL = 3  # Battle 4.6: same zone levels up to III



class NotSimulated(ValueError):
    """The record/rule needs behaviour that no GDD decision defines; the engine fails closed instead of guessing."""


class Mon:
    def __init__(s, uid, side, slot, pos, arch):
        s.uid, s.side, s.slot, s.pos = uid, side, slot, pos
        s.hp = s.maxhp = arch["hp"]
        s.init, s.move, s.reach, s.ap = arch["init"], arch["move"], arch["reach"], arch["ap"]
        s.alive = True
        s.strikes = arch.get("strikes", [dict(shape="jab", kin="beast", dmg=2, ap=2, push="all")])
        s.movement = arch.get("movement", "legacy")  # legacy | step | run | leap | glide | burrow | phase | blink
        s.walk_ap = arch.get("walk_ap", 1)
        s.surge_ap = arch.get("surge_ap", 1)
        s.pen, s.pen_next = 0, 0  # Spirit Strike: initiative -1 next round
        s.skind = arch.get("surge", "default")  # 'default' = global --surge, 'none' = cannot cast
        s.zone_kit = arch.get("zones", [])  # monsters.py engine handoff (record-driven zones)
        s.rotate = arch.get("rotate", False)  # Adaptive: owner-only boolean permission, while participating
        s.buff_kit = arch.get("buffs", [])  # self Initiative buffs
        s.buffs = {}  # effect id -> dict(mag, expire); owner is implicit, equipped copies refresh
        s.last_cast = {}  # kit index -> round of the last cast (once_per_round)


    def copy(s):
        n = object.__new__(Mon)
        n.__dict__.update(s.__dict__)
        n.buffs = {k: dict(v) for k, v in s.buffs.items()}
        n.last_cast = dict(s.last_cast)
        return n


class Battle:
    def __init__(s, size, props, archs, surge, bots, rng, voidscar_round=None, max_rounds=40):
        s.n, s.rng, s.surge_kind, s.bots = size, rng, surge, bots
        s.zones = {}  # cell -> dict(defn, level, left, aim, side, caster)

        s.zone_serial = 0
        s.ground = {(x, y): ("plain", 0) for x in range(size) for y in range(size)}
        s.props = {}
        for pos, name in props.items():
            s.props[pos] = dict(name=name, hp=PROPS[name]["hp"])
        s.mons = []
        far = size - 1
        area = [[(0, 0), (0, 1), (1, 0), (1, 1)], [(far, far), (far, far - 1), (far - 1, far), (far - 1, far - 1)]]
        for side in (0, 1):
            spots = area[side][:]
            rng.shuffle(spots)
            for slot, a in enumerate(archs[side]):
                s.mons.append(Mon(f"{'AB'[side]}{slot + 1}", side, slot, spots[slot], a if isinstance(a, dict) else ARCH[a]))
        s.surges = []  # dict(caster, cells, kind)
        s.round, s.max_rounds = 0, max_rounds
        s.voidscar_round = voidscar_round or (6 if size <= 5 else 8)
        s.stats = Counter()
        s.first_tie_done = False
        s.over, s.winner = False, None

    def clone(s):
        c = object.__new__(Battle)
        c.__dict__.update(s.__dict__)
        c.ground = dict(s.ground)
        c.props = {k: dict(v) for k, v in s.props.items()}
        c.zones = {k: dict(v, aim=dict(v["aim"])) for k, v in s.zones.items()}
        c.rng = random.Random(0)
        c.rng.setstate(s.rng.getstate())
        c.mons = []
        cmap = {}
        for m in s.mons:
            n = m.copy()
            c.mons.append(n)
            cmap[m.uid] = n
        c.surges = [dict(x, caster=cmap[x["caster"].uid], cells=list(x["cells"])) for x in s.surges]

        c.stats = Counter(s.stats)
        return c

    # ---------- helpers ----------
    def inb(s, p):
        return 0 <= p[0] < s.n and 0 <= p[1] < s.n

    def mon_at(s, p):
        for m in s.mons:
            if m.alive and m.pos == p:
                return m
        return None

    def adj4(s, p):
        return [(p[0] + d[0], p[1] + d[1]) for d in DIRS4 if s.inb((p[0] + d[0], p[1] + d[1]))]

    def ring(s, p, dirs):
        return [(p[0] + d[0], p[1] + d[1]) for d in dirs if s.inb((p[0] + d[0], p[1] + d[1]))]

    def aura_near(s, p, kind):
        c = 0
        for q in s.adj4(p):
            pr = s.props.get(q)
            if pr and PROPS[pr["name"]].get("aura") == kind:
                c += 1
        return c

    # ---------- zones (Battle 4.6) ----------
    def zone_val(s, ent, effect):
        """Effective value of one effect of a zone entry. mend = min(2, level) (decided); a missing cap means only level I is
        authored, so any higher level fails closed instead of inferring a scaling."""
        if effect["effect"] == "mend":
            return min(2, ent["level"])
        if effect["effect"] in ("push", "pull"):
            return 1
        if effect["cap"] is None:
            if ent["level"] > 1:
                raise NotSimulated(f"{effect['effect']}: level {ent['level']} has no authored cap/scaling")
            return effect["base"]
        return max(1, min(effect["cap"], effect["base"] + ent["level"] - 1))

    def zone_at(s, p, effect):
        """Sum of the effective values of `effect` on square p (0 without a zone). One zone per square."""
        ent = s.zones.get(p)
        if not ent:
            return 0
        return sum(s.zone_val(ent, e) for e in ent["defn"]["effects"] if e["effect"] == effect)

    def eff_init(s, m):
        v = m.init - m.pen + s.aura_near(m.pos, "init") + (1 if s.ground[m.pos][0] == "hearth" else 0)
        v += s.zone_at(m.pos, "quicken") - s.zone_at(m.pos, "drain_init") + sum(b["mag"] for b in m.buffs.values())
        return max(0.1, v)

    def eff_move(s, m):
        return max(1, m.move + s.aura_near(m.pos, "move") + s.zone_at(m.pos, "haste") - s.zone_at(m.pos, "slow"))

    def eff_reach(s, m):
        return max(1, m.reach + s.aura_near(m.pos, "reach") + (1 if s.ground[m.pos][0] == "umbra" else 0)
                   + s.zone_at(m.pos, "extend") - s.zone_at(m.pos, "drain_range"))

    def surge_cut(s, m):
        """Value reductions of Surge damage (zone shield, Hallowed, Wardstone) add (Battle 6.1)."""
        return s.aura_near(m.pos, "ward") + (1 if s.ground[m.pos][0] == "hallowed" else 0) + s.zone_at(m.pos, "shield")

    def zone_cells(s, defn, anchor):
        cells = [(anchor[0] + dx, anchor[1] + dy) for dx, dy in defn["offsets"]]
        return cells if all(s.inb(c) for c in cells) else None  # fixed footprint, all on board, no clipping

    def zone_opposite(s, a, b):
        ta = {e["effect"] for e in a["effects"]}
        tb = {e["effect"] for e in b["effects"]}
        return any(ZONE_OPPOSITE.get(t) in tb for t in ta)

    def zone_land(s, cell, new):
        """Battle 4.6 table: none -> new; same definition -> level up (max III) and full duration; opposite -> levels
        subtract (equal cancel, higher stays with the difference); anything else -> replaced (level I)."""
        ex = s.zones.get(cell)
        if ex is None:
            s.zones[cell] = new
        elif ex["defn"]["id"] == new["defn"]["id"]:
            ent = dict(new, level=min(ZONE_MAX_LEVEL, ex["level"] + 1))
            for e in ent["defn"]["effects"]:
                s.zone_val(ent, e)  # fail closed when a level > I has no authored scaling
            s.zones[cell] = ent
        elif s.zone_opposite(ex["defn"], new["defn"]):
            diff = ex["level"] - new["level"]
            if diff == 0:
                del s.zones[cell]
            elif diff > 0:
                s.zones[cell] = dict(ex, level=diff)  # clock unchanged
            else:
                s.zones[cell] = dict(new, level=-diff)
        else:
            s.zones[cell] = new

    def zone_castable(s, m, z, anchor):
        """Anchor within effective Reach (Manhattan, Skills 2/4), whole footprint on board, no level > I for cap-less effects."""
        if abs(anchor[0] - m.pos[0]) + abs(anchor[1] - m.pos[1]) > s.eff_reach(m):
            return False
        cells = s.zone_cells(z, anchor)
        if cells is None:
            return False
        if any(e["cap"] is None for e in z["effects"] if e["effect"] not in ("push", "pull", "mend")):
            for c in cells:
                ex = s.zones.get(c)
                if ex and ex["defn"]["id"] == z["id"]:
                    return False  # would reach level II of a cap-less effect
        return True

    def cast_zone(s, m, z, anchor, aim):
        if not s.zone_castable(m, z, anchor):
            raise NotSimulated("illegal zone cast")
        if any(e["effect"] == "push" for e in z["effects"]) and aim.get("dir") not in DIRS4:
            raise NotSimulated("zone push needs a cardinal cast direction")
        if any(e["effect"] == "pull" for e in z["effects"]) and not s.inb(aim["anchor"]):
            raise NotSimulated("zone pull needs a fixed on-board anchor")
        s.zone_serial += 1
        for c in s.zone_cells(z, anchor):
            s.zone_land(c, dict(defn=z, level=1, left=z["rounds"], aim=dict(aim), side=m.side,
                               caster=m.uid, gid=s.zone_serial))

    def end_displace(s, m):
        """End of turn, step 1 (Battle 2.4/6.5): zone push/pull moves one cardinal square; pull toward the anchor fixed at cast
        (no move on an exact diagonal or when already on the anchor)."""
        ent = s.zones.get(m.pos)
        if not ent:
            return
        vx = vy = 0
        for e in ent["defn"]["effects"]:
            if e["effect"] == "push":
                vx, vy = vx + ent["aim"]["dir"][0], vy + ent["aim"]["dir"][1]
            elif e["effect"] == "pull":
                dx, dy = ent["aim"]["anchor"][0] - m.pos[0], ent["aim"]["anchor"][1] - m.pos[1]
                if (dx == 0 and dy == 0) or abs(dx) == abs(dy):
                    continue
                if abs(dx) > abs(dy):
                    vx += (dx > 0) - (dx < 0)
                else:
                    vy += (dy > 0) - (dy < 0)
        if abs(vx) + abs(vy) == 1:  # opposite directions cancel; a perpendicular sum is no cardinal move
            s.push(m, (vx, vy))
            s.defeat()

    def end_mend(s, m):
        """End of turn, step 3: heal min(2, zone level) from the zone on the (post-displacement) square; never revives."""
        if m.alive:
            h = s.zone_at(m.pos, "mend")
            if h:
                before = m.hp
                s.heal(m, h)
                s.stats["healed_mend"] += m.hp - before

    def round_end(s):
        """Battle 2.4 round end: zones -1 round (removed at 0). Timed unit effects (Battle 3.1): a buff of N rounds lasts until the
        round end of the N-th following round."""
        for c in list(s.zones):
            s.zones[c]["left"] -= 1
            if s.zones[c]["left"] <= 0:
                del s.zones[c]
        for m in s.mons:
            m.buffs = {k: b for k, b in m.buffs.items() if b["expire"] > s.round}

    def living(s, side=None):
        return [m for m in s.mons if m.alive and (side is None or m.side == side)]

    def damage(s, m, amt, tag):
        if amt <= 0 or not m.alive:
            return
        m.hp -= amt
        s.stats["dmg_" + tag] += amt

    def heal(s, m, amt):
        if m.alive and m.hp > 0:
            m.hp = min(m.maxhp, m.hp + max(0, amt))

    def defeat(s):
        for m in s.mons:
            if m.alive and m.hp <= 0:

                m.alive = False
                m.buffs.clear()

                s.stats["defeats"] += 1

    def check_end(s):
        a, b = len(s.living(0)), len(s.living(1))
        if a == 0 or b == 0:
            s.over = True
            s.winner = None if a == 0 and b == 0 else (0 if b == 0 else 1)
            s.surges = []

    # ---------- payload resolution (Battle 6.2) ----------

    def payload(s, hits, residue, kind):
        """hits: (cell, amount, is_surge[, prop damage]); residue: (cells, ground) or None."""
        for hit in hits:
            cell, amt, is_surge = hit[:3]
            m = s.mon_at(cell)
            if m:
                cut = s.surge_cut(m) if is_surge else 0
                s.damage(m, max(0, amt - cut), kind)
            pr = s.props.get(cell)
            if pr:
                pr["hp"] -= hit[3] if len(hit) > 3 else 2
        s.defeat()
        s.resolve_removals(kind)
        ops = []
        if residue:
            ops.append(residue)
        for cells, g in ops:
            for c in cells:
                s.lay(c, g)
        s.check_end()

    def lay(s, c, g):
        cur = s.ground[c]
        if cur[0] == "voidscar":
            return
        if g in HAZ:
            lvl = min(2, cur[1] + 1) if cur[0] == g else 1
            s.ground[c] = (g, lvl)
        else:
            s.ground[c] = (g, 0)

    def resolve_removals(s, kind):
        for _ in range(6):
            dead = [p for p, pr in s.props.items() if pr["hp"] <= 0]
            if not dead:
                return
            snapshot = set(s.props)
            dmg, spawn, push, ground = defaultdict(int), [], [], []
            for p in dead:
                d = PROPS[s.props[p]["name"]]
                if d.get("burst"):
                    for c in s.ring(p, DIRS8 if d["burst"] == 8 else DIRS4):
                        dmg[c] += 1
                if d.get("spawn"):
                    for c in s.ring(p, DIRS4):
                        if c not in snapshot and not s.mon_at(c):
                            spawn.append(c)
                if d.get("push"):
                    push.append(p)
                ground.append((p, d["ground"]))
                s.stats["destroyed_" + s.props[p]["name"]] += 1
            for c, a in dmg.items():
                m = s.mon_at(c)
                if m:
                    s.damage(m, a, "aftermath")
            for p in dead:
                del s.props[p]
            s.defeat()
            for c in spawn:
                if c not in s.props:
                    s.props[c] = dict(name="beam", hp=PROPS["beam"]["hp"])
            for p in push:
                for m in sorted(s.living(), key=lambda q: q.uid):
                    dx, dy = m.pos[0] - p[0], m.pos[1] - p[1]
                    if max(abs(dx), abs(dy)) == 1:
                        s.push(m, (dx, dy))
            s.defeat()
            for p, g in ground:
                s.lay(p, g)

    def push(s, m, d):
        dest = (m.pos[0] + d[0], m.pos[1] + d[1])
        if not s.inb(dest):
            return
        if dest in s.props:
            s.damage(m, 1, "collision")
            if not PROPS[s.props[dest]["name"]].get("heavy"):
                s.props[dest]["hp"] -= 1
            return
        o = s.mon_at(dest)
        if o:
            s.damage(m, 1, "collision")
            s.damage(o, 1, "collision")
            return
        m.pos = dest
        s.on_enter(m)

    # ---------- ground triggers ----------
    def on_enter(s, m):
        g, lvl = s.ground[m.pos]
        if g == "thorn":
            s.damage(m, lvl, "thornbed")
        elif g == "mossbed":
            s.heal(m, 1)

    # ---------- Strikes (Skills 8.1) ----------

    def strike(s, m, sk, d):
        cells, _ = strike_cells(s, m, sk["shape"], d)
        amt, kin = sk["dmg"], sk["kin"]
        prop_amt = 0 if amt == 0 else (4 if kin == "swarm" else 2)
        hits = [(c, amt, False, prop_amt) for c in cells]
        targets = [x for x in (s.mon_at(c) for c in cells) if x and x is not m]
        s.payload(hits, None, "strike")
        if not m.alive or s.over:
            return sk["ap"]
        alive = [x for x in targets if x.alive]
        if kin == "scaled":  # push away from the attacker (direction choice simplified to 'away')
            alive.sort(key=lambda x: -max(abs(x.pos[0] - m.pos[0]), abs(x.pos[1] - m.pos[1])))
            for x in alive:
                dx, dy = x.pos[0] - m.pos[0], x.pos[1] - m.pos[1]
                if sk.get("push") == "adjacent" and max(abs(dx), abs(dy)) != 1:
                    continue
                s.push(x, ((dx > 0) - (dx < 0), (dy > 0) - (dy < 0)))
            s.defeat()
        elif kin == "spirit":
            for x in alive:
                x.pen_next = 1
        if kin == "winged" and m.alive:
            r = retreat_vector(sk["shape"], d)
            if r:
                dest = (m.pos[0] + r[0], m.pos[1] + r[1])
                claimed = {c for u in s.surges for c in u["cells"]}
                if s.inb(dest) and dest not in s.props and not s.mon_at(dest) and dest not in claimed:
                    m.pos = dest
                    s.on_enter(m)
                    s.defeat()
        s.check_end()
        return sk["ap"]


    # ---------- turn flow ----------
    def queue(s):
        ms = s.living()
        ms.sort(key=lambda m: (-s.eff_init(m), -m.init))
        out, i = [], 0
        while i < len(ms):
            j = i
            while j < len(ms) and (s.eff_init(ms[j]), ms[j].init) == (s.eff_init(ms[i]), ms[i].init):
                j += 1
            grp = ms[i:j]
            by = {0: sorted([m for m in grp if m.side == 0], key=lambda m: m.slot),
                  1: sorted([m for m in grp if m.side == 1], key=lambda m: m.slot)}
            side = 0
            while by[0] or by[1]:
                if by[side]:
                    out.append(by[side].pop(0))
                side = 1 - side
            i = j
        return out

    def run(s):
        while not s.over and s.round < s.max_rounds:
            s.round += 1
            s.stats["rounds"] = s.round
            for m in s.mons:
                m.pen, m.pen_next = m.pen_next, 0
            for m in s.queue():
                if s.over:
                    break
                if m.alive:
                    s.turn(m)
            if s.over:
                break
            s.round_end()
            s.pressure()
            s.check_end()
        if not s.over:
            s.over, s.winner = True, None
            s.stats["timeout"] = 1
        return s.winner

    def pressure(s):
        if s.round < s.voidscar_round:
            return
        free = [c for c, g in s.ground.items() if g[0] != "voidscar"]
        if not free:
            for m in s.living():
                s.damage(m, 1, "collapse")
            s.defeat()
            return
        dist = {c: min(max(abs(c[0] - m.pos[0]), abs(c[1] - m.pos[1])) for m in s.living()) for c in free}
        top = max(dist.values())
        for c, d in dist.items():
            if d == top:
                s.ground[c] = ("voidscar", 0)

    def render(s):
        rows = []
        sym = {"plain": ".", "rubble": ",", "lava": "L", "thorn": "T", "blight": "B", "mossbed": "m",
               "hallowed": "h", "hearth": "H", "umbra": "u", "voidscar": "#"}
        for y in range(s.n):
            row = ""
            for x in range(s.n):
                m = s.mon_at((x, y))
                if m:
                    row += m.uid[0].lower() if m.side else m.uid[0]
                elif (x, y) in s.props:
                    row += s.props[(x, y)]["name"][0].upper()
                else:
                    row += sym[s.ground[(x, y)][0]]
            rows.append(row)
        return "\n".join(rows)


    def turn(s, m):
        if getattr(s, "trace", False):
            print(f"-- round {s.round} {m.uid} hp {m.hp}\n{s.render()}")
        mine = [x for x in s.surges if x["caster"] is m]
        if mine:
            hits = [(c, SURGES[x["kind"]][0], True) for x in mine for c in x["cells"]]
            res = None
            for x in mine:
                res = (x["cells"], SURGES[x["kind"]][1]) if res is None else res
            s.surges = [x for x in s.surges if x["caster"] is not m]
            s.payload(hits, res, "surge")
            if s.over or not m.alive:
                return
        g, lvl = s.ground[m.pos]
        if g == "blight":
            s.damage(m, lvl, "blight")
        if g == "voidscar":
            s.damage(m, 1, "voidscar")
        s.defeat()
        s.check_end()
        if s.over or not m.alive:
            return
        ap = m.ap
        for _ in range(12):

            act = s.bots[m.side](s, m, ap)
            if not act:
                break
            ap -= s.do(m, act)
            if s.over or not m.alive:
                return
        s.end_displace(m)  # end of turn: 1. push/pull -> 2. end-turn ground damage -> 3. mend
        s.check_end()
        if s.over or not m.alive:
            return
        g, lvl = s.ground[m.pos]
        if g == "lava":
            s.damage(m, lvl, "lava")
        s.defeat()
        s.end_mend(m)
        s.check_end()

    def do(s, m, act):
        kind = act[0]
        if kind == "step":
            m.pos = act[1]
            s.on_enter(m)
            s.defeat()
            s.check_end()
            return 0  # movement cost is move points, tracked in bot via path length
        if kind == "walk":
            for p in act[1]:
                m.pos = p
                s.on_enter(m)
                s.defeat()
                if not m.alive:
                    break
            s.check_end()
            return m.walk_ap
        if kind == "strike":
            return s.strike(m, m.strikes[act[1]], act[2])
        if kind == "surge":
            s.surges.append(dict(caster=m, cells=act[1], kind=s.surge_kind if m.skind == "default" else m.skind))
            return m.surge_ap
        if kind == "zone":
            z = m.zone_kit[act[1]]
            if z.get("once_per_round") and m.last_cast.get(act[1]) == s.round:
                raise NotSimulated("zone equipped copy has already been used this round")
            z = zone_variant(m, z, act[3].get("rotation", 0))
            s.cast_zone(m, z, act[2], act[3])
            if z.get("once_per_round"):
                m.last_cast[act[1]] = s.round
            s.stats["cast_zone"] += 1
            return z["ap"]
        if kind == "buff":
            b = m.buff_kit[act[1]]
            # Battle 3.1: same effect of the same owner refreshes, even from another equipped copy.
            m.buffs[b["id"]] = dict(mag=b["magnitude"], expire=s.round + b["rounds"])
            s.stats["cast_buff"] += 1
            return b["ap"]
        return 99


def zone_variant(m, z, turns=0):
    """Adaptive rotates the owner's eligible fixed I3 only; no mirrors or Strike edits."""
    if type(turns) is not int or turns not in (0, 1, 2, 3):
        raise NotSimulated("rotation must be an integer number of quarter turns")
    if not turns:
        return z
    eligible = ({(-1, 0), (0, 0), (1, 0)}, {(0, -1), (0, 0), (0, 1)})
    if not m.alive or not m.rotate or set(z["offsets"]) not in eligible:
        raise NotSimulated("Adaptive rotation NOT SIMULATED for this owner/shape")
    offsets = list(z["offsets"])
    for _ in range(turns):
        offsets = [(-y, x) for x, y in offsets]
    return dict(z, offsets=offsets)


def utility_candidates(b, m, ap):
    out = []
    for i, z in enumerate(m.zone_kit):
        if ap < z["ap"] or (z.get("once_per_round") and m.last_cast.get(i) == b.round):
            continue
        variants, seen = [], set()
        for turns in (range(4) if m.rotate else (0,)):
            variant = zone_variant(m, z, turns)
            geometry = frozenset(variant["offsets"])
            if geometry not in seen:
                seen.add(geometry)
                variants.append((turns, variant))
        for x in range(b.n):
            for y in range(b.n):
                anchor = (x, y)
                for turns, variant in variants:
                    if not b.zone_castable(m, variant, anchor):
                        continue
                    dirs = DIRS4 if any(e["effect"] == "push" for e in z["effects"]) else [(1, 0)]
                    for d in dirs:
                        out.append(("zone", i, anchor, dict(dir=d, anchor=anchor, rotation=turns)))
    for i, buff in enumerate(m.buff_kit):
        if ap >= buff["ap"]:
            out.append(("buff", i))
    return out


def best_utility(b, m, ap):
    best, score = None, evaluate(b, m.side) + 0.05
    for act in utility_candidates(b, m, ap):
        c = b.clone()
        cm = next(t for t in c.mons if t.uid == m.uid)
        c.do(cm, act)
        value = evaluate(c, m.side)
        if value > score:
            best, score = act, value
    return best




# ---------- Strike shapes (Skills 8.1; rays are ordered outward so a solid prop stops the rest of its ray) ----------
SYMMETRIC = {"whirl", "cross", "storm", "long_whirl", "long_cross"}
CARD = [(1, 0), (-1, 0), (0, 1), (0, -1)]
DIAG = [(1, 1), (1, -1), (-1, 1), (-1, -1)]


def shape_rays(shape, d):
    """List of rays (offset lists) for direction d, or None if shape/direction is not legal (diagonal Cleave undefined)."""
    card = d is not None and (d[0] == 0 or d[1] == 0)
    sc = lambda c, k: (c[0] * k, c[1] * k)
    if shape == "jab":
        return [[d]]
    if shape == "thrust":
        return [[d, sc(d, 2)]] if card else None
    if shape == "diagonal_thrust":
        return [[d, sc(d, 2)]] if not card else None
    if shape == "pincer":
        return [[d], [sc(d, -1)]]
    if shape == "arc":
        if card:
            p = (abs(d[1]), abs(d[0]))
            return [[d], [(d[0] + p[0], d[1] + p[1])], [(d[0] - p[0], d[1] - p[1])]]
        return [[(d[0], 0)], [d], [(0, d[1])]]
    if shape == "whirl":
        return [[c] for c in CARD]
    if shape == "cross":
        return [[c] for c in DIAG]
    if shape == "storm":
        return [[c] for c in CARD + DIAG]
    if shape == "cleave":
        if not card:
            return None
        p = (abs(d[1]), abs(d[0]))
        return [[(d[0] + k * p[0], d[1] + k * p[1]), (2 * d[0] + k * p[0], 2 * d[1] + k * p[1])] for k in (-1, 0, 1)]
    if shape == "long_whirl":
        return [[c, sc(c, 2)] for c in CARD]
    if shape == "long_cross":
        return [[c, sc(c, 2)] for c in DIAG]
    raise ValueError("unknown strike shape " + shape)


def strike_dirs(shape):
    return [None] if shape in SYMMETRIC else [d for d in DIRS8 if shape_rays(shape, d)]


def strike_cells(b, m, shape, d):
    """(hit cells with prop blocking/clipped to the board, all unclipped offsets)."""
    rays = shape_rays(shape, d)
    cells, offs = [], []
    for ray in rays:
        blocked = False
        for o in ray:
            offs.append(o)
            if blocked:
                continue
            c = (m.pos[0] + o[0], m.pos[1] + o[1])
            if not b.inb(c):
                continue
            cells.append(c)
            if c in b.props:
                blocked = True
    return cells, offs


def retreat_vector(shape, d):
    """Opposite of the hit-shape centre, only if the centre lies on one of the eight directions (Skills 3)."""
    offs = [o for ray in shape_rays(shape, d) for o in ray]
    mx, my = sum(o[0] for o in offs), sum(o[1] for o in offs)
    if (mx, my) == (0, 0) or not (mx == 0 or my == 0 or abs(mx) == abs(my)):
        return None
    return (-((mx > 0) - (mx < 0)), -((my > 0) - (my < 0)))


def best_strike(b, m, ap):
    best = None
    for i, sk in enumerate(m.strikes):
        if ap < sk["ap"]:
            continue
        for d in strike_dirs(sk["shape"]):
            cells, _ = strike_cells(b, m, sk["shape"], d)
            foes = own = 0
            for c in cells:
                t = b.mon_at(c)
                if t and t is not m:
                    foes, own = (foes + 1, own) if t.side != m.side else (foes, own + 1)
            score = foes * 2 - own * 3
            if score > 0 and (best is None or score > best[0]):
                best = (score, ("strike", i, d))
    return best[1] if best else None


# ---------- movement and bots ----------
def step_cost(b, p):
    return 2 if b.ground[p][0] == "rubble" else 1


def reachable(b, m):
    if m.movement in ("legacy", "run"):
        return reachable_walk(b, m)
    claimed = {c for x in b.surges for c in x["cells"]}
    ok = lambda q: b.inb(q) and q not in b.props and not b.mon_at(q) and q not in claimed \
        and b.ground[q][0] not in HAZ and b.ground[q][0] != "voidscar"
    mv, out = b.eff_move(m), {m.pos: []}
    if m.movement == "step":
        for q in b.adj4(m.pos):
            if ok(q):
                out[q] = [q]
    elif m.movement == "leap":  # straight line, ignores props/monsters/surges on the way, only the landing counts
        for d in DIRS8:
            for k in range(1, mv + 1):
                q = (m.pos[0] + d[0] * k, m.pos[1] + d[1] * k)
                if ok(q):
                    out[q] = [q]
    elif m.movement == "blink":  # any free square within Movement - 2 (min 1)
        r = max(1, mv - 2)
        for x in range(m.pos[0] - r, m.pos[0] + r + 1):
            for y in range(m.pos[1] - r, m.pos[1] + r + 1):
                if ok((x, y)):
                    out[(x, y)] = [(x, y)]
    elif m.movement in ("glide", "burrow", "phase"):
        # glide: free path, blocked by surges; burrow: free path, nothing blocks; phase: walk blocked by monsters/surges
        r = max(1, mv - 1)
        seen, frontier = {m.pos: 0}, [m.pos]
        while frontier:
            cur = frontier.pop(0)
            for q in b.adj4(cur):
                if not b.inb(q) or q in seen:
                    continue
                if m.movement != "burrow" and q in claimed:
                    continue
                if m.movement == "phase" and b.mon_at(q):
                    continue
                cost = seen[cur] + (step_cost(b, q) if m.movement == "phase" else 1)
                if cost <= r:
                    seen[q] = cost
                    frontier.append(q)
        for q in seen:
            if q != m.pos and ok(q):
                out[q] = [q] if m.movement != "phase" else [q]
    return out


def reachable_walk(b, m):
    """Dijkstra over move points, avoids solid props, monsters, pending surge squares and hazards."""
    claimed = {c for x in b.surges for c in x["cells"]}
    best, path, frontier = {m.pos: 0}, {m.pos: []}, [m.pos]
    limit = b.eff_move(m)
    while frontier:
        cur = frontier.pop(0)
        for q in b.adj4(cur):
            if q in b.props or b.mon_at(q) or q in claimed or b.ground[q][0] in HAZ or b.ground[q][0] == "voidscar":
                continue
            cost = best[cur] + step_cost(b, q)
            if cost <= limit and cost < best.get(q, 99):
                best[q], path[q] = cost, path[cur] + [q]
                frontier.append(q)
    return path


def enemy_list(b, m):
    return [e for e in b.living(1 - m.side)]


def nearest(b, m):
    es = enemy_list(b, m)
    return min(es, key=lambda e: (max(abs(e.pos[0] - m.pos[0]), abs(e.pos[1] - m.pos[1])), e.uid)) if es else None


def surge_cells(b, anchor):
    cells = [anchor, (anchor[0] + 1, anchor[1])]
    claimed = {c for x in b.surges for c in x["cells"]}
    cells = [c for c in cells if b.inb(c) and c not in b.props]
    if anchor in claimed or not cells or anchor not in cells:
        return None
    return [c for c in cells if c not in claimed]


def bot_rush(b, m, ap):
    e = nearest(b, m)
    if not e:
        return None
    act = best_strike(b, m, ap) or best_utility(b, m, ap)
    if act:
        return act
    if ap >= m.surge_ap and m.skind != "none" and not any(x["caster"] is m for x in b.surges):
        best = None
        for dx in range(-3, 4):
            for dy in range(-3, 4):
                a = (m.pos[0] + dx, m.pos[1] + dy)
                if abs(dx) + abs(dy) > b.eff_reach(m) or not b.inb(a):
                    continue
                cells = surge_cells(b, a)
                if not cells:
                    continue
                foes = sum(1 for c in cells if (t := b.mon_at(c)) and t.side != m.side)
                own = sum(1 for c in cells if (t := b.mon_at(c)) and t.side == m.side)
                score = foes * 2 - own * 3
                if score > 0 and (not best or score > best[0]):
                    best = (score, cells)
        if best:
            return ("surge", best[1])
    if ap >= m.walk_ap and not getattr(m, "_moved", False):
        paths = reachable(b, m)
        tgt = min(paths, key=lambda p: (max(abs(p[0] - e.pos[0]), abs(p[1] - e.pos[1])), len(paths[p])))
        if tgt != m.pos and paths[tgt]:
            m._moved = True
            return ("walk", paths[tgt])
    m._moved = False
    return None


def bot_kite(b, m, ap):
    e = nearest(b, m)
    if not e:
        return None
    dist = max(abs(e.pos[0] - m.pos[0]), abs(e.pos[1] - m.pos[1]))
    if dist <= 3:
        act = best_strike(b, m, ap)
        if act:
            return act
    act = bot_rush(b, m, ap)
    if act and act[0] == "walk" and dist <= 2:
        paths = reachable(b, m)
        far = max(paths, key=lambda p: (max(abs(p[0] - e.pos[0]), abs(p[1] - e.pos[1])), -len(paths[p])))
        if far != m.pos:
            m._moved = True
            return ("walk", paths[far])
    return act


def bot_random(b, m, ap):
    opts = utility_candidates(b, m, ap)
    opts += [("strike", i, d) for i, sk in enumerate(m.strikes) if ap >= sk["ap"] for d in strike_dirs(sk["shape"])]
    if ap >= m.surge_ap:
        for _ in range(6 if m.skind != "none" else 0):
            a = (m.pos[0] + b.rng.randint(-2, 2), m.pos[1] + b.rng.randint(-2, 2))
            cells = surge_cells(b, a) if b.inb(a) else None
            if cells and abs(a[0] - m.pos[0]) + abs(a[1] - m.pos[1]) <= b.eff_reach(m):
                opts.append(("surge", cells))
    if ap >= m.walk_ap:
        paths = reachable(b, m)
        if len(paths) > 1:
            tgt = b.rng.choice(sorted(paths))
            if paths[tgt]:
                opts.append(("walk", paths[tgt]))
    if not opts or b.rng.random() < 0.15:
        return None
    return b.rng.choice(opts)


def candidates(b, m, ap):
    out = utility_candidates(b, m, ap)
    out += [("strike", i, d) for i, sk in enumerate(m.strikes) if ap >= sk["ap"] for d in strike_dirs(sk["shape"])]
    if ap >= m.surge_ap:
        if m.skind != "none" and not any(x["caster"] is m for x in b.surges):
            for dx in range(-3, 4):
                for dy in range(-3, 4):
                    a = (m.pos[0] + dx, m.pos[1] + dy)
                    if abs(dx) + abs(dy) <= b.eff_reach(m) and b.inb(a):
                        cells = surge_cells(b, a)
                        if cells:
                            out.append(("surge", cells))
    if ap >= m.walk_ap:
        paths = reachable(b, m)
        out += [("walk", p) for q, p in paths.items() if p and q != m.pos]
    return out


def evaluate(b, side):
    me = sum(max(0, m.hp) for m in b.living(side))
    foe = sum(max(0, m.hp) for m in b.living(1 - side))
    score = me - foe
    for m in b.living():
        sign = 1 if m.side == side else -1
        score += sign * 0.5 * sum(v["mag"] for v in m.buffs.values())
        z = b.zones.get(m.pos)
        if z:
            weights = {"slow": -0.2, "haste": 0.2, "drain_init": -0.45, "quicken": 0.45,
                       "drain_range": -0.25, "extend": 0.25, "shield": 0.15}
            for e in z["defn"]["effects"]:
                val = b.zone_val(z, e)
                score += sign * weights.get(e["effect"], 0) * val
                if e["effect"] == "mend":
                    score += sign * 0.6 * min(val, m.maxhp - m.hp)
    for x in b.surges:  # pending surges: expected damage on current occupants
        for c in x["cells"]:
            t = b.mon_at(c)
            if t:
                val = SURGES[x["kind"]][0] * 0.6
                score += val if x["caster"].side != t.side and t.side != side else 0
                score += val if t.side != side and x["caster"].side == side else 0
                score -= val if t.side == side else 0
    if b.over:
        score += 50 if b.winner == side else (-50 if b.winner is not None else 0)
    e = [m for m in b.living(1 - side)]
    mine = b.living(side)
    if e and mine:
        score -= 0.15 * sum(min(max(abs(a.pos[0] - c.pos[0]), abs(a.pos[1] - c.pos[1])) for c in e) for a in mine)
    return score


def bot_greedy(b, m, ap):
    """One-step lookahead on a deep copy: picks the action with the best heuristic board score."""
    base = evaluate(b, m.side)
    best, best_score = None, base + 0.05
    for act in candidates(b, m, ap):
        c = b.clone()
        cm = next(x for x in c.mons if x.uid == m.uid)
        c.bots = [lambda *a: None, lambda *a: None]
        c.do(cm, act)
        sc = evaluate(c, m.side) + b.rng.random() * 0.01
        if sc > best_score:
            best, best_score = act, sc
    return best


BOTS = {"rush": bot_rush, "kite": bot_kite, "random": bot_random, "greedy": bot_greedy}


def make_props(size, names, rng):
    """Point-mirrored pairs on non-start, non-centre squares."""
    spots = [(x, y) for x in range(size) for y in range(size)
             if (x, y) != ((size - 1) // 2, (size - 1) // 2) and (x + y) not in (0, 1, 2 * size - 2, 2 * size - 3)
             and (x, y) < (size - 1 - x, size - 1 - y)]
    rng.shuffle(spots)
    out = {}
    for name, p in zip(names, spots):
        out[p] = name
        out[(size - 1 - p[0], size - 1 - p[1])] = name
    return out


def monster_sheet(name):
    import monsters  # builder: data/monsters + data/skills; refuses illegal sheets
    r = monsters.build(name)
    if not r["ok"]:
        raise SystemExit(f"monster {name} is not legal: {r['errors']}")
    for w in r["warnings"]:
        if "NOT SIMULATED" in w:
            print(f"[{name}] {w}")
    return r["sheet"]


def play(args, seed, names, surge=None, swap=False, trace=False):
    rng = random.Random(seed)
    bots = [BOTS[args.bot_a], BOTS[args.bot_b]]
    if args.mon_a or args.mon_b:
        archs = [[monster_sheet(n) for n in side.split(",")] for side in (args.mon_a or args.mon_b, args.mon_b or args.mon_a)]
    elif args.arch == "random":
        archs = [[rng.choice(sorted(ARCH))], [rng.choice(sorted(ARCH))]]
    else:
        archs = [args.arch.split(","), args.arch.split(",")]
    if swap:
        archs, bots = list(reversed(archs)), list(reversed(bots))
    b = Battle(args.size, make_props(args.size, names, rng), archs, surge or args.surge, bots, rng)
    b.trace = trace
    w = b.run()
    return w, b


def experiment(args, label, names, surge=None):
    res, rounds, stats = Counter(), 0, Counter()
    for g in range(args.games):
        w, b = play(args, args.seed + g, names, surge)
        res["draw" if w is None else "A" if w == 0 else "B"] += 1
        rounds += b.round
        stats.update({k: v for k, v in b.stats.items() if k != "rounds"})
    n = args.games
    dmg = {k[4:]: round(v / n, 2) for k, v in stats.items() if k.startswith("dmg_")}
    des = {k[10:]: round(v / n, 2) for k, v in stats.items() if k.startswith("destroyed_")}
    print(f"{label:34s} A {res['A'] / n:5.1%}  B {res['B'] / n:5.1%}  draw {res['draw'] / n:5.1%}  "
          f"rounds {rounds / n:5.1f}  timeout {stats['timeout'] / n:4.1%}")
    print(f"{'':34s} dmg/game {dmg}  props destroyed/game {des}")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--games", type=int, default=300)
    ap.add_argument("--size", type=int, default=5, choices=[5, 6, 7, 9])
    ap.add_argument("--seed", type=int, default=1)
    ap.add_argument("--surge", choices=sorted(SURGES), default="eruption")
    ap.add_argument("--bot-a", choices=sorted(BOTS), default="rush")
    ap.add_argument("--bot-b", choices=sorted(BOTS), default="rush")
    ap.add_argument("--arch", default="random", help="'random' (one random archetype per side per game) or a comma list used by both sides, e.g. brawler,caster,balanced")
    ap.add_argument("--mon-a", default="", help="comma list of data/monsters names for side A (legal sheets only); overrides --arch")
    ap.add_argument("--mon-b", default="", help="same for side B (defaults to side A's list)")

    ap.add_argument("--props", default="", help="comma list of prop names, one mirrored pair each")
    ap.add_argument("--pairs", type=int, default=2, help="mirrored pairs per prop in --experiment props")
    ap.add_argument("--trace", action="store_true", help="print the board before each turn of one game (seed)")
    ap.add_argument("--experiment", choices=["props", "surges", "bots", "none"], default="none")
    args = ap.parse_args()

    if args.games < 1:
        ap.error("--games must be positive")
    if args.experiment == "props":
        experiment(args, "no props", [])
        for name in PROPS:
            if name != "beam":
                experiment(args, f"{args.pairs} pair(s) of {name}", [name] * args.pairs)
    elif args.experiment == "surges":
        for k in SURGES:
            experiment(args, f"surge {k}", [x for x in args.props.split(",") if x], k)
    elif args.experiment == "bots":
        for a in BOTS:
            for c in BOTS:
                args.bot_a, args.bot_b = a, c
                experiment(args, f"{a} vs {c}", [x for x in args.props.split(",") if x])
    elif args.trace:
        w, b = play(args, args.seed, [x for x in args.props.split(",") if x], trace=True)
        print("winner", w, "rounds", b.round, dict(b.stats))
    else:
        experiment(args, "custom", [x for x in args.props.split(",") if x])


if __name__ == "__main__":
    try:
        sys.exit(main())
    except NotSimulated as exc:
        print(f"NOT SIMULATED: {exc}", file=sys.stderr)
        sys.exit(2)
