# Simulation and price tools

Headless authoring and measurement tools of the Godot project. They give **indications only**: no balance validation, no price approval and no rule source. The GDDs under `docs/` own every rule and price; a numeric budget fit grants no content, access or balance approval. Missing rules are never invented here: what a tool cannot represent is reported as **NOT SIMULATED** or fails closed.

Simulations run on the battle core itself (`battle/core`) and the data are Godot Resource files (`.tres`), like all other content. The earlier Python experiment `tools/simulator` and its JSON files are gone (2026-11-11).

## Tools and data

| File | Purpose |
|---|---|
| `price.gd` | Construction-point calculator for price records and test builds (Skills §5 drafts). Anything without a rate fails closed. |
| `sim.gd` | Bot-vs-bot runs; prints one run block in the format of [docs/simulation_log.md](../../docs/simulation_log.md). Default: random teams from the nine test kits. |
| `compare.gd` | Equal-cost, side-swapped comparison of two test builds; prints a result table. |
| `smoke_ui.gd` | Plays draft → placement → battle through the real UI (not a measurement tool). |
| `defs/price_record.gd`, `defs/price_component.gd` | Resource classes `PriceRecord` and `PriceComponent`: what a skill is charged for. |
| `defs/sim_build_def.gd`, `defs/sim_build_slot.gd` | Resource classes `SimBuildDef` and `SimBuildSlot`: one stat allocation with up to four priced slots. |
| `lib/skill_pricing.gd` | The rate table (mirror of the Skills §5 working drafts) and the evaluation. |
| `lib/sim_builds.gd` | Test build → unit sheet: stat spend, stage ceilings, slot prices, and the check that a record prices exactly its definition. |
| `lib/sim_bots.gd` | Move policies `greedy` (AiBrain), `rush`, `kite`, `random`. |
| `lib/sim_runner.gd`, `lib/cli.gd` | Boards and start squares for build runs, the game loop, argument parsing. |
| `data/prices/*.tres` | Price records; the file name is the id. Arithmetic references, not an approved catalogue. |
| `data/builds/*.tres` | Test builds; the file name is the id. No species-access or progression-reachability claim. |

`tests/tools` holds the two small suites of these tools: paper totals and fail-closed cases of the calculator, and legality / definition check / repeatability of the builds. When a Skills §5 rate changes, update `lib/skill_pricing.gd` and the `paper_total` of the affected records together.

## Commands

Run from the repository root; everything after `--` belongs to the tool.

```sh
godot --headless --path godot -s res://tools/price.gd -- --list-examples
godot --headless --path godot -s res://tools/price.gd -- --example "Scaled Arc" --slot-level 2
godot --headless --path godot -s res://tools/price.gd -- scaled_arc --slot-level 2        # id, display name or path of a record
godot --headless --path godot -s res://tools/price.gd -- --list-builds
godot --headless --path godot -s res://tools/price.gd -- --build test_golem_shield

godot --headless --path godot -s res://tools/sim.gd -- 20 3v3 1 "$(git rev-parse --short HEAD)"
godot --headless --path godot -s res://tools/sim.gd -- 20 1v1 1 "<state>" --team-a test_golem_slow --team-b test_golem_mend --bot-a rush --bot-b rush
godot --headless --path godot -s res://tools/sim.gd -- 50 3v3 1 "<state>" --team-a test_tiger_eruption,test_golem_shield,test_wolf_beast_arc --experiment props
godot --headless --path godot -s res://tools/sim.gd -- 1 1v1 1 --team-a test_tiger_eruption --team-b test_golem_eruption --trace

godot --headless --path godot -s res://tools/compare.gd -- --seeds 1,2,3 --pairs-per-seed 10 --sizes 5,7 --bot rush
godot --headless --path godot -s res://tools/compare.gd -- --builds test_golem_eruption,test_golem_flood --bot rush
```

- **`price.gd` exit codes:** 0 fits the ceiling / legal build, 1 over the ceiling / illegal build, 2 incomplete, unsupported or unknown.
- **`sim.gd` arguments:** `[battles] [mode] [seed] [state] [kits]`, then options. `--team-a` / `--team-b` field test builds by id (`--team-b` defaults to `--team-a`); `--bot-a` / `--bot-b` pick the policies; `--board` is `seeded` or `layout` for kit runs and `flat` (default), `layout` or `seeded` for build runs; `--props a,b` adds one mirrored pair per prop id to a build run; `--experiment props` (with `--pairs N`) and `--experiment bots` print one block per row; `--trace` prints the board before every turn of one battle.
- **New Resource classes or scripts:** run `godot --headless --path godot --import` once (or open the editor) so the class cache knows them.
- **A script that fails to compile does not quit by itself:** add `--quit-after 3` (or a `timeout`) to unattended runs.

## Price records

A `PriceRecord` is edited like any other Resource (inspector or text). It holds:

| Field | Meaning |
|---|---|
| `display_name` | The name used in the GDD and in reports. |
| `usage`, `ap`, `once_per_round`, `round_cap` | Availability basis: `active` with 1–5 battle AP, `passive_boolean` or `event_once_per_round`. A round limit needs `round_cap` decided (`effective` prices availability at 75 %); `unresolved` has no price. |
| `components` | `PriceComponent` entries. `type` picks the rate: `damage`, `strike_extras`, `anchor`, `marker`, `zone`, `displacement`, `ground`, `move`, `self_buff`, `rotation`, `nullify`, `relocate`, `prop`, `air_coverage`. |
| `paper_total` | The GDD's own paper result for this record (Skills §5); the test compares it with the calculation. |
| `skill` | The `BattleSkillDef` the record prices: a content record of `data/battle/skills` or a fixture embedded in the record. Empty = a price reference only. |
| `fixture` | Says that the definition uses geometry or values the GDD has not specified or approved. |

A missing amount, an unknown name, a repeatable or team-wide event and an unresolved round cap are refused, never priced at zero. Mend uses its level-I price (32 for three cells / two rounds); runtime healing stays `min(2, zone level)`.

## Test builds and what a run covers

A build fights with the definition its price record names, and only if that definition is exactly what the record pays for. `lib/sim_builds.gd` compares both and reports the slot as NOT SIMULATED on any difference; nothing is converted or filled in.

| Definition kind | Compared with the priced components | Limits |
|---|---|---|
| Strike | Shape cells, cells outside the adjacent ring, direction choice, AP of the shape, fixed damage 2 with ground and air recipients, the Kin package or one body-relative variant (Skills §3: Scaled push on adjacent cells, Winged retreat) | Damage-free variants only on the Jab shape; one Strike definition serves the records of several Kins, the Kin comes from the monster |
| Surge | Damage, footprint cells, telegraphed timing, air recipients, anchor, marker, push, and every board operation against its ground package (level-I residue, Mountain destruction) | Mountain blanking, line footprints, Mountain creation and prop creation have no checked price |
| Zone | Every effect of the zone against one zone component: level-I value, footprint cells, rounds; anchor; ground recipients only | Decided bounds only (Slow 1/2, Shield 2/3, Mend 1/2, push/pull 1). An effect without a decided cap must not scale and is reported as NOT SIMULATED above level I |
| Self buff | Initiative magnitude and rounds | Initiative only |
| Movement | The preset's own content record at its AP | Unpatched presets only |
| Passive | The rotation permission (Adaptive) | The only passive with a price check |

- **Checked per build:** stat spend against the stage budget, stage ceilings, slot prices against the slot-level ceiling, skill AP against the AP stat, Strike Kin against the monster's Kin. Not checked: species access, development reachability.
- **Resolved by the battle core:** extra turns (TPR), concurrent Surges and their scheduling, Strike legality at the board edge, Scaled push direction, Mountains and props on `layout` / `seeded` boards, late-round pressure, Draws.
- **Price references without a definition (priced, not simulated):** three-cell Surges, collapse and residue-free Surges, immediate ground, Blessing and Mountain creation. No shipped record covers prop creation, Nullify, Relocate, air coverage or 2×2 bodies. Tamer skills are never fielded by these tools.
- **Board of a build run:** `flat` is an empty board of the mode's size without Mountains; start squares are drawn by the seed from side 0's start area ([Battle §4.1](../../docs/gdd_battle.md#41-battlefield-generation)) and mirrored for side 1. On 1v1 the start area is the corner square, so seeds differ only through the bots' tie-breaks.

## Bots

`greedy` is `AiBrain`, the game's own opponent: one-step lookahead on a copy of the battle. `rush` strikes whoever stands in a shape, otherwise casts, otherwise walks toward the nearest enemy; `kite` backs away when an enemy is within 2 squares; `random` picks a random legal action. All four only take actions the battle reports as legal. None plans ahead, refreshes timed effects on purpose, targets props or uses tamer skills, so stalling and late-round pressure can decide a run. `rush` and `kite` rank movement by walking distance; `AiBrain` uses board distance and can stand still on an exact diagonal with Movement 1 (tracked as I42 in [temp_todo.md](../../docs/temp_todo.md)).

Rough speed on one core: `rush` about 40 ms per 1v1 battle; `greedy` about 0.1–0.3 s per 1v1 battle and 1–2 s per 3v3 battle.

## Reading comparisons

`compare.gd` requires equal exact stat spend, equal summed skill prices and the same slot-level distribution, and refuses illegal or partly simulated builds. Each build fields one monster. Every seed is played **twice with swapped sides** on the same mirrored start squares with the same bot and no tamer skills. A Draw, including a timeout after 600 turns, scores 0.5. The table reports wins, Draws, mean score, mean rounds and timeouts; SD and range describe the **seed-block mean scores** of build A, not confidence intervals.

Different stat allocations at equal spend probe the whole build, **not the marginal value of a shared skill**. High Draw rates or bot stalling make a 50/50 score meaningless for a price question. No price, budget or rule change follows from a run.

## Recording results

A `sim.gd` run block is pasted unchanged into [docs/simulation_log.md](../../docs/simulation_log.md), which defines the entry format. A `compare.gd` table is recorded with its command, seeds, game count and limits under T13 in [docs/temp_todo.md](../../docs/temp_todo.md). Conclusions become tasks there; nothing is concluded in this folder.
