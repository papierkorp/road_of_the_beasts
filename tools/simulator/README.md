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

Modelled: square boards, ground types, ground-layer prop catalogue with aftermath, initiative queue with ties, AP, Walk, Jab Strike, one 2-cell Surge profile (Eruption/Flood/Rift), payload order (damage, defeat, removals incl. aftermath/Gong push, ground), late-round Voidscar pressure, battle end/Draw. Bots: `rush`, `kite`, `random`, `greedy` (one-step lookahead).

**Missing:** other Kin Strikes, movement presets, zones/protection/healing, self buffs, **all passives**, the **tamer skills** (the once-per-battle intervention that can swing a fight), Mountains/height, air layer, 2×2 bodies, extra turns (TPR), Nullify, skill-created props, diverse monsters/species.

## Next step

Build monsters from skill records (JSON) within the 24/30/36 construction budgets, add passives and the tamer intervention as switchable building blocks, then compare win rates of equal-cost builds. Props are considered good enough for now and are not extended further.

## Maintenance

Keep the simulator in sync with rule changes in the GDDs (coverage list above and the module docstring), and never use it as a source of rules or prices.
