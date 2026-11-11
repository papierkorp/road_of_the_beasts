# Temporary price experiment (Python)

Small, disposable CLI tools for **quick construction-price indications**, not a second game implementation. Standard library only; always invoke with `python3 -I`. The game is built in Godot.

## Scope and lifetime

- **Answer a concrete price question, then stop.** Model only what that experiment needs; complete GDD coverage, a second battle application and production architecture are not goals. There is no automatic port or synchronization promise with Godot.
- **JSON is the deliberate reusable exception:** keep skill records, monster sheets and paper calculation totals as reusable inputs or templates. They need not be discarded with an experiment. Reuse in Godot still requires mapping and checking the compact record format; it is not a ready-made production schema.
- **Checks stay lightweight:** retain the small inline price/sheet checks and perform experiment-specific smoke or arithmetic checks as needed. Do not build a permanent battle-test suite, legacy regression fixtures or a compatibility framework. `data/golden.json` checks paper prices; a `legacy_golden.json` of old battle outcomes is not maintained.
- **The GDDs remain authoritative.** Missing rules are not invented and incomplete simulation is not evidence against a price. Document the experiment's exclusions here; record measurements and their limits only under T13 in [`docs/temp_todo.md`](../../docs/temp_todo.md), not as a second results catalogue in this README.

## Tools and reusable data

| File | Purpose |
|---|---|
| `pricing.py` | Calculate Skills §5 draft prices; unknown/unpriced components fail closed. Its small inline self-test checks paper arithmetic, not gameplay. |
| `monsters.py` | Assemble JSON test sheets, check stat/slot spend, report unsupported effects as **NOT SIMULATED**. |
| `battle_sim.py` | Reduced bot-vs-bot experiment; no claim to implement the complete GDD. |
| `compare.py` | Short equal-cost, side-swapped experiment; prints a result table without writing files. |
| `data/skills/*.json` | Reusable price records and optional `sim` hints; templates, not a production Godot schema or approved catalogue. |
| `data/monsters/*.json` | Reusable stat/kit examples with explicit slot levels; no species-access or progression-reachability claims. |
| `data/golden.json` | Expected **paper construction totals** corresponding to skill records; useful arithmetic references, not battle regression results. |

Rules and prices remain in the GDDs, not these tools. A numeric budget fit grants no content/access/balance approval. When the owning price draft changes, update the calculator and JSON totals together. Mend uses its level-I price (32 for three cells/two rounds), while runtime healing remains `min(2, zone level)`.

```sh
python3 -I tools/simulator/pricing.py --self-test
python3 -I tools/simulator/pricing.py --example "Slow zone 2 rounds"
python3 -I tools/simulator/monsters.py --self-test
python3 -I tools/simulator/monsters.py test_golem_shield
python3 -I tools/simulator/battle_sim.py --games 10 --size 7 --bot-a greedy --bot-b greedy \
        --mon-a test_golem_slow --mon-b test_golem_mend
python3 -I tools/simulator/compare.py --seeds 1,2,3 --pairs-per-seed 10 --sizes 5,7 --bot greedy
python3 -I tools/simulator/compare.py --builds test_tiger_shield,test_golem_shield --bot rush
```

## Reduced coverage

- Flat square boards, 1×1 ground-layer monsters, ground/entry triggers, ground-layer props and aftermath, AP, movement presets, Strike shapes and their reduced Kin effects, one two-cell Surge profile per monster, late Voidscar pressure and Draws.
- Zones: same definition levels to III and refreshes; opposites subtract levels; otherwise replace. Duration ticks at round end; zones and ground stay independent. Slow is base 1/cap 2; Shield base 2/cap 3 reduces only Surge damage; Mend heals `min(2, level)` after end-turn displacement and ground damage. Mossbed heals on every entry, never on placement.
- Haste, initiative and Reach modifiers have base-level support only where bounds/scaling are unresolved. A cap is never inferred from zone level III. The Quicken record is retained as a priced template but its levelled behaviour is **NOT SIMULATED**; `compare.py` rejects partial coverage.
- Only the Focus example is a self-buff: +1 Initiative, two following rounds, same effect/owner refreshes without magnitude stacking. Adaptive is the only passive represented: boolean permission to rotate the owner's centred I3 zones, no mirroring or Strike changes. Other passive candidates stay **NOT SIMULATED**; generic event-order decisions do not supply their missing prices/content.
- Zone push/pull uses a cast-fixed cardinal direction/anchor at turn end; an exactly diagonal pull does not move. There is no concrete push/pull skill record beyond the generic priced component; deterministic bots do not evaluate its future displacement well.

**Not simulated:** Mountains/height and Ancient destruction, air, 2×2 bodies, extra turns, other passives, tamer/loadout/Nullify effects, skill-created props, full species/upgrade content. Tamer effects have no construction points, so their begun implementation was removed when the user narrowed this to a price experiment. TPR > 1 is reported as unsupported, not banned by an obsolete AP/TPR restriction. No game implementation or Godot changes are authorized here.

**Important simplifications:** Scaled always pushes away; Phase applies only landing entry effects; Strike cells off-board are clipped. Bots avoid hazards, use a one-step heuristic, and do not reliably refresh timed effects or plan healing/displacement loops. Pending Surges remain limited to one per caster; dead-caster detonation, simultaneous multiple payloads, complete queue tie policy and Surge reblocking are not faithfully reproduced. The legacy `--arch` mode retains its historical one-AP walk. The existing Flood shortcut lacks its authored push and is not exposed by a `sim`-enabled JSON record. Prop targeting, payload/collision ordering and anti-stalling are approximations. None of these shortcuts is a GDD rule.

## Reading comparisons

`compare.py` requires equal exact stat spend, summed skill prices and slot-level distribution; it refuses illegal/partially supported inputs. Each build fields one monster. Each individual seed plays **twice with swapped sides**, using mirrored start squares, no props and the same bot. Seed blocks generate distinct 64-bit game seeds. A draw, including a timeout, scores 0.5. The table reports wins, draws, mean score, rounds and timeouts; SD/min/max describe **seed-block mean scores**, not confidence intervals.

Different stat allocation is allowed at equal spend. Such a comparison probes the whole test build, **not the marginal value of its shared skill**. High Draw rates or bot stalling can make a 50/50 score meaningless for price valuation. No price, budget or rule change follows automatically.

For a quick experiment: choose priced JSON inputs, check their spend and unsupported components, run only the relevant side-swapped comparison, then record the command, seed setup, game count and limitations in T13. Stop there unless a specific price question needs another measurement; a simulation gap is not automatically an implementation backlog.
