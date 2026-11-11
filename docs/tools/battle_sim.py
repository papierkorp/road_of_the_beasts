#!/usr/bin/env python3
"""Reduced CLI battle simulator for Road of the Beasts (temporary docs tool).

Purpose: cheap bot-vs-bot indications for the CURRENT DRAFT rules (docs/gdd_battle.md,
docs/gdd_skills.md). It is NOT the game, NOT balance validation and NOT price validation.
Standard library only. Usage: python3 -I docs/tools/battle_sim.py --help

Modelled (reduced): square board, Plain/Rubble/Lava/Thornbed/Blight/Mossbed/Hallowed/Hearth/
Umbra/Voidscar ground, ground-layer prop catalogue (Battle 4.10) with aftermath, initiative
queue with ties, AP, Walk, Jab Strike, one-cell-pair Surge profiles (Eruption/Flood/Rift),
payload order 6.2 (damage, defeat, removals incl. aftermath/Gong push, ground), late-round
Voidscar pressure, battle end/Draw.
NOT modelled: Mountains/height, air layer, 2x2 bodies, zones, extra turns (TPR), passives,
tamer skills, skill-created props, Kin effects, upgrades, Nullify.
"""
import argparse
import random
from collections import Counter, defaultdict

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


class Mon:
    def __init__(s, uid, side, slot, pos, arch):
        s.uid, s.side, s.slot, s.pos = uid, side, slot, pos
        s.hp = s.maxhp = arch["hp"]
        s.init, s.move, s.reach, s.ap = arch["init"], arch["move"], arch["reach"], arch["ap"]
        s.alive = True


class Battle:
    def __init__(s, size, props, archs, surge, bots, rng, voidscar_round=None, max_rounds=40):
        s.n, s.rng, s.surge_kind, s.bots = size, rng, surge, bots
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
                s.mons.append(Mon(f"{'AB'[side]}{slot + 1}", side, slot, spots[slot], ARCH[a]))
        s.surges = []  # dict(caster, cells, kind)
        s.round, s.max_rounds = 0, max_rounds
        s.voidscar_round = voidscar_round or (6 if size <= 5 else 8)
        s.stats = Counter()
        s.first_tie_done = False
        s.over, s.winner = False, None

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

    def eff_init(s, m):
        v = m.init + s.aura_near(m.pos, "init") + (1 if s.ground[m.pos][0] == "hearth" else 0)
        return max(0.1, v)

    def eff_move(s, m):
        return max(1, m.move + s.aura_near(m.pos, "move"))

    def eff_reach(s, m):
        return max(1, m.reach + s.aura_near(m.pos, "reach") + (1 if s.ground[m.pos][0] == "umbra" else 0))

    def surge_cut(s, m):
        return s.aura_near(m.pos, "ward") + (1 if s.ground[m.pos][0] == "hallowed" else 0)

    def living(s, side=None):
        return [m for m in s.mons if m.alive and (side is None or m.side == side)]

    def damage(s, m, amt, tag):
        if amt <= 0 or not m.alive:
            return
        m.hp -= amt
        s.stats["dmg_" + tag] += amt

    def heal(s, m, amt):
        m.hp = min(m.maxhp, m.hp + amt)

    def defeat(s):
        for m in s.mons:
            if m.alive and m.hp <= 0:
                m.alive = False
                s.stats["defeats"] += 1

    def check_end(s):
        a, b = len(s.living(0)), len(s.living(1))
        if a == 0 or b == 0:
            s.over = True
            s.winner = None if a == 0 and b == 0 else (0 if b == 0 else 1)
            s.surges = []

    # ---------- payload resolution (Battle 6.2) ----------
    def payload(s, hits, residue, kind):
        """hits: list of (cell, amount, is_surge). residue: (cell list, ground) or None."""
        for cell, amt, is_surge in hits:
            m = s.mon_at(cell)
            if m:
                cut = s.surge_cut(m) if is_surge else 0
                s.damage(m, max(0, amt - cut), kind)
            pr = s.props.get(cell)
            if pr:
                pr["hp"] -= 2
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
            q = s.queue()
            for m in q:
                if s.over:
                    break
                if m.alive:
                    s.turn(m)
            if s.over:
                break
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

    def turn(s, m):
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
        g, lvl = s.ground[m.pos]
        if g == "lava":
            s.damage(m, lvl, "lava")
        s.defeat()
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
            return 1
        if kind == "jab":
            c = (m.pos[0] + act[1][0], m.pos[1] + act[1][1])
            if s.inb(c):
                s.payload([(c, 2, False)], None, "strike")
            return 2
        if kind == "surge":
            s.surges.append(dict(caster=m, cells=act[1], kind=s.surge_kind))
            return 1
        return 99


# ---------- movement and bots ----------
def step_cost(b, p):
    return 2 if b.ground[p][0] == "rubble" else 1


def reachable(b, m):
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
    if ap >= 2:
        for d in DIRS8:
            c = (m.pos[0] + d[0], m.pos[1] + d[1])
            t = b.mon_at(c)
            if t and t.side != m.side:
                return ("jab", d)
    if ap >= 1 and not any(x["caster"] is m for x in b.surges):
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
    if ap >= 1 and not getattr(m, "_moved", False):
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
    if dist <= 1 and ap >= 2:
        for d in DIRS8:
            t = b.mon_at((m.pos[0] + d[0], m.pos[1] + d[1]))
            if t and t.side != m.side:
                return ("jab", d)
    act = bot_rush(b, m, ap)
    if act and act[0] == "walk" and dist <= 2:
        paths = reachable(b, m)
        far = max(paths, key=lambda p: (max(abs(p[0] - e.pos[0]), abs(p[1] - e.pos[1])), -len(paths[p])))
        if far != m.pos:
            m._moved = True
            return ("walk", paths[far])
    return act


def bot_random(b, m, ap):
    opts = []
    if ap >= 2:
        opts += [("jab", d) for d in DIRS8]
    if ap >= 1:
        for _ in range(6):
            a = (m.pos[0] + b.rng.randint(-2, 2), m.pos[1] + b.rng.randint(-2, 2))
            cells = surge_cells(b, a) if b.inb(a) else None
            if cells and abs(a[0] - m.pos[0]) + abs(a[1] - m.pos[1]) <= b.eff_reach(m):
                opts.append(("surge", cells))
        paths = reachable(b, m)
        if len(paths) > 1:
            tgt = b.rng.choice(sorted(paths))
            if paths[tgt]:
                opts.append(("walk", paths[tgt]))
    if not opts or b.rng.random() < 0.15:
        return None
    return b.rng.choice(opts)


def candidates(b, m, ap):
    out = []
    if ap >= 2:
        out += [("jab", d) for d in DIRS8 if b.inb((m.pos[0] + d[0], m.pos[1] + d[1]))]
    if ap >= 1:
        if not any(x["caster"] is m for x in b.surges):
            for dx in range(-3, 4):
                for dy in range(-3, 4):
                    a = (m.pos[0] + dx, m.pos[1] + dy)
                    if abs(dx) + abs(dy) <= b.eff_reach(m) and b.inb(a):
                        cells = surge_cells(b, a)
                        if cells:
                            out.append(("surge", cells))
        paths = reachable(b, m)
        out += [("walk", p) for q, p in paths.items() if p and q != m.pos]
    return out


def evaluate(b, side):
    me = sum(max(0, m.hp) for m in b.living(side))
    foe = sum(max(0, m.hp) for m in b.living(1 - side))
    score = me - foe
    for x in b.surges:  # pending surges: expected damage on current occupants
        for c in x["cells"]:
            t = b.mon_at(c)
            if t:
                val = SURGES[b.surge_kind][0] * 0.6
                score += val if x["caster"].side != t.side and t.side != side else 0
                score += val if t.side != side and x["caster"].side == side else 0
                score -= val if t.side == side else 0
    if b.over:
        score += 50 if b.winner == side else (-50 if b.winner is not None else 0)
    e = [m for m in b.living(1 - side)]
    mine = b.living(side)
    if e and mine:
        score -= 0.1 * min(max(abs(a.pos[0] - c.pos[0]), abs(a.pos[1] - c.pos[1])) for a in mine for c in e)
    return score


def bot_greedy(b, m, ap):
    """One-step lookahead on a deep copy: picks the action with the best heuristic board score."""
    import copy
    base = evaluate(b, m.side)
    best, best_score = None, base + 0.05
    for act in candidates(b, m, ap):
        c = copy.deepcopy(b)
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


def play(args, seed, names, surge=None, swap=False):
    rng = random.Random(seed)
    bots = [BOTS[args.bot_a], BOTS[args.bot_b]]
    if args.arch == "random":
        archs = [[rng.choice(sorted(ARCH))], [rng.choice(sorted(ARCH))]]
    else:
        archs = [args.arch.split(","), args.arch.split(",")]
    b = Battle(args.size, make_props(args.size, names, rng), archs, surge or args.surge, bots, rng)
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
    ap.add_argument("--props", default="", help="comma list of prop names, one mirrored pair each")
    ap.add_argument("--experiment", choices=["props", "surges", "bots", "none"], default="none")
    args = ap.parse_args()
    if args.experiment == "props":
        experiment(args, "no props", [])
        for name in PROPS:
            if name != "beam":
                experiment(args, f"pair of {name}", [name])
    elif args.experiment == "surges":
        for k in SURGES:
            experiment(args, f"surge {k}", [x for x in args.props.split(",") if x], k)
    elif args.experiment == "bots":
        for a in BOTS:
            for c in BOTS:
                args.bot_a, args.bot_b = a, c
                experiment(args, f"{a} vs {c}", [x for x in args.props.split(",") if x])
    else:
        experiment(args, "custom", [x for x in args.props.split(",") if x])


if __name__ == "__main__":
    main()
