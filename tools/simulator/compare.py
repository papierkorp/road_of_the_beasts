"""Throwaway equal-cost JSON build experiment; stdlib only, no balance/price approval.
Each individual seed plays both sides. SD/range use seed-block mean scores.
Run: python3 -I tools/simulator/compare.py --seeds 1,2,3 --pairs-per-seed 10 --sizes 5,7 --bot greedy
"""
import argparse
import json
import random
import sys
from collections import Counter
from copy import deepcopy
from decimal import Decimal
from pathlib import Path
from statistics import stdev

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parent))
import battle_sim as bs
import monsters

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--seeds", type=lambda s: tuple(map(int, s.split(","))), default=(1, 2, 3))
parser.add_argument("--pairs-per-seed", type=int, default=10)
parser.add_argument("--sizes", type=lambda s: tuple(map(int, s.split(","))), default=(5, 7))
parser.add_argument("--bot", choices=("greedy", "rush"), default="greedy")
parser.add_argument("--builds", type=lambda s: tuple(n.strip() for n in s.split(",")), help="exactly two JSON stems: a,b")
args = parser.parse_args()
if args.pairs_per_seed < 1 or len(set(args.seeds)) != len(args.seeds):
    parser.error("use distinct seed blocks and --pairs-per-seed >= 1")
if len(set(args.sizes)) != len(args.sizes) or any(n not in (5, 6, 7, 9) for n in args.sizes):
    parser.error("--sizes must contain distinct values from 5,6,7,9")
if args.builds and (len(args.builds) != 2 or not all(args.builds) or args.builds[0] == args.builds[1]):
    parser.error("--builds requires exactly two distinct names: a,b")
pairs = [args.builds] if args.builds else [
    ("test_golem_eruption", "test_golem_rift"),
    ("test_tiger_eruption", "test_golem_eruption"),
    ("test_tiger_shield", "test_golem_shield")]
builds = {}
for name in dict.fromkeys(n for pair in pairs for n in pair):
    if name not in monsters.list_monsters():
        parser.error(f"unknown build: {name}")
    try:
        result: dict = monsters.build(name)
        errors = result["errors"] + [w for w in result["warnings"] if "NOT SIMULATED" in w.upper()]
        if not result["ok"] or errors:
            parser.error(f"{name}: {'; '.join(errors)}")
        raw = json.loads((monsters.DATA / "monsters" / f"{name}.json").read_text(), parse_float=Decimal)
        stats = Decimal(monsters.stat_points(raw["stats"]))
        skills = sum((Decimal(s["points"]) for s in result["slots"]), Decimal(0))
        levels = tuple(sorted(s["level"] for s in result["slots"]))
        builds[name] = (result["sheet"], stats, skills, levels)
        for warning in result["warnings"]:
            print(f"NOTE {name}: {warning}", file=sys.stderr)
    except (OSError, KeyError, TypeError, ValueError) as exc:
        parser.error(f"{name}: {exc}")
for a, b in pairs:
    if builds[a][1:] != builds[b][1:]:
        parser.error(f"{a} vs {b}: unequal stat/skill spend or slot levels: {builds[a][1:]} != {builds[b][1:]}")

schedule, used = [], set()
for block in args.seeds:
    rng, seeds = random.Random(block), []
    while len(seeds) < args.pairs_per_seed:
        seed = rng.getrandbits(64)
        if seed not in used:
            seeds.append(seed)
            used.add(seed)
    schedule.append((block, seeds))
rows = []
for a, b in pairs:
    for size in args.sizes:
        counts, block_means, rounds, timeouts = Counter(), [], 0, 0
        for block, seeds in schedule:
            block_score = 0
            for seed in seeds:
                for swapped in (0, 1):
                    names = (b, a) if swapped else (a, b)
                    rosters = [[deepcopy(builds[n][0])] for n in names]
                    rng = random.Random(seed)
                    start = rng.choice(((0, 0), (0, 1), (1, 0), (1, 1)))
                    battle = bs.Battle(size, {}, rosters, "eruption", [bs.BOTS[args.bot]] * 2, rng)
                    for mon in battle.mons:
                        mon.pos = start if mon.side == 0 else (size - 1 - start[0], size - 1 - start[1])
                    try:
                        winner = battle.run()
                    except (ValueError, AttributeError) as exc:
                        parser.error(f"{a}/{b}, size {size}, block {block}, seed {seed}, swap {swapped}: {exc}")
                    outcome = "draws" if winner is None else ("wins_a" if winner == swapped else "wins_b")
                    counts[outcome] += 1
                    block_score += 0.5 if winner is None else int(winner == swapped)
                    rounds += battle.round
                    timeouts += battle.stats["timeout"]
            block_means.append(block_score / (2 * args.pairs_per_seed))
        games = 2 * len(args.seeds) * args.pairs_per_seed
        score = (counts["wins_a"] + 0.5 * counts["draws"]) / games
        sd = f"{stdev(block_means):.3f}" if len(block_means) > 1 else "n/a"
        rows.append((a, b, str(size), f"{builds[a][1]:g}/{builds[a][2]:g}", str(games),
                     f"{counts['wins_a']}/{counts['wins_b']}/{counts['draws']}", f"{score:.3f}", sd,
                     f"{min(block_means):.3f}..{max(block_means):.3f}", f"{rounds / games:.2f}", str(timeouts)))
print("Reduced simulator indications only; no balance validation or price approval.")
print(f"Bot {args.bot}; blocks {args.seeds}; {args.pairs_per_seed} paired seeds/block; mirrored starts, no props/tamer.")
print("Draw = 0.5; sample SD/range describe A's seed-block means (one block: SD n/a).")
headers = ("Build A", "Build B", "Size", "Stat/skill spend", "Games", "Wins A/B/draws", "Score A", "Seed SD", "Seed range", "Rounds mean", "Timeouts")
widths = [max(len(row[i]) for row in [headers] + rows) for i in range(len(headers))]
for row in [headers] + rows:
    print(" | ".join(value.ljust(width) for value, width in zip(row, widths)))
