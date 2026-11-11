# Battle simulator (Python, temporary tool)

A small, reduced bot-vs-bot simulator for the **current draft rules** in `docs/` (Battle, Skills). Standard library only.

```sh
python3 -I tools/simulator/battle_sim.py --help
python3 -I tools/simulator/battle_sim.py --games 300 --bot-a greedy --bot-b greedy --size 7 \
        --arch brawler,caster,balanced --pairs 2 --experiment props
python3 -I tools/simulator/battle_sim.py --bot-a greedy --bot-b greedy --size 7 --props gong,gong --seed 3 --trace
```

## Purpose

- **First job:** an *initial balancing signal* for the construction-point prices in `docs/gdd_skills.md` §5: do skills of equal cost perform comparably?
- It gives **indications only**. It is neither balance validation nor price approval and does not count as a T13 test run (`docs/temp_todo.md`). Results are written down only in `docs/temp_todo.md` (T13).

## Why Python and not Godot (decision context, 2026-11-11)

- The rules still change daily. A small script is cheap to change; the Godot battle core is not.
- The Godot project already separates a headless battle core (`godot/battle/core/`) and has its own AI-vs-AI simulator (`godot/tools/sim.gd`), so a simulator there could share the GUI's logic. But that core still implements the historical v6.0 rules; bringing it to the current draft is game implementation, which needs a separate authorization.
- **Plan:** Python now for fast signal; after the Battle completion gate (stable rules) port the logic to `godot/battle/core` and lift `sim.gd`; Python then remains at most a cross-checker.
- **Risk:** two implementations drift apart. Countermeasures: keep skills as **data records** (JSON in the shared Skills §2 model) and only the resolution as code, so the same records can later feed Godot; reuse the T04 walkthroughs in `docs/temp_todo.md` as shared golden test cases.

## Current coverage

Modelled: square boards, ground types, ground-layer prop catalogue with aftermath, initiative queue with ties, AP, Walk and the movement presets (Step, Run, Leap, Glide, Burrow, Phase, Blink), all 11 Strike shapes with the Kin effects of Scaled (push), Winged (retreat), Spirit (initiative −1 next round) and Swarm (prop damage 4), one 2-cell Surge profile (Eruption/Flood/Rift), payload order (damage, defeat, removals incl. aftermath/Gong push, ground), late-round Voidscar pressure, battle end/Draw. Bots: `rush`, `kite`, `random`, `greedy` (one-step lookahead).

**Missing:** zones/protection/healing, self buffs, **all passives**, the **tamer skills** (the once-per-battle intervention that can swing a fight), Ancient's Mountain destruction, Mountains/height, air layer, 2×2 bodies, extra turns (TPR), Nullify, skill-created props, diverse monsters/species. **Simplifications:** Scaled push is always "away" from the attacker, Phase triggers only landing entry effects, Strike cells off the board are clipped, legacy `--arch` monsters keep the old 1-AP walk. `monsters.py --self-test` also checks that engine shape geometry equals the priced hit/distant cells.

## Next step

Extend the engine to execute more record components (zones, protection/healing, self buffs), then add passives and the tamer intervention as switchable building blocks, then compare win rates of equal-cost builds (monster builder and JSON records exist, see above). Props are considered good enough for now and are not extended further.

## Price calculator (`pricing.py`)

Replaces the retired `docs/temp_kalkscript.py`. Rates are a data table mirroring `docs/gdd_skills.md` §5 (not a price authority); `--self-test` compares them with the GDD's paper examples. Unknown or unpriced components fail closed. When §5 rates change, update the table and the golden numbers together. Usage: see the module docstring.

## Data files and monster builder

- `data/skills/*.json`: one skill record per file (compact notation of `pricing.py`; optional `sim` hint tells the simulator what it can execute: `jab`, or `surge` + profile). `data/golden.json`: expected totals copied from Skills §5 paper examples (`pricing.py --self-test` checks table and files against each other).
- `data/monsters/*.json`: **test sheets** (stats + up to 4 slots with explicit slot levels), no roster entries and no claim about reachable slot levels (T05).
- `monsters.py` validates a sheet (stat points vs budget, stage ceilings, AP 4–5 needs TPR 1, kit legality, skill price ≤ slot-level ceiling via `pricing.py`, skill AP ≤ monster AP, Strike Kin = monster Kin) and reports skills the simulator cannot execute as NOT SIMULATED.
- `battle_sim.py --mon-a a,b,c --mon-b d,e,f` plays legal sheets (refuses illegal ones). Per-monster capabilities today: Strikes, movement presets, one Surge profile. Everything else in a record is priced but ignored by the engine.

```sh
python3 -I tools/simulator/monsters.py --list
python3 -I tools/simulator/monsters.py --self-test
python3 -I tools/simulator/battle_sim.py --games 300 --size 7 --bot-a greedy --bot-b greedy \
        --mon-a test_golem_eruption,test_tiger_eruption --mon-b test_golem_rift,test_tiger_eruption
```

## Maintenance

Keep the simulator in sync with rule changes in the GDDs (coverage list above and the module docstring), and never use it as a source of rules or prices.
