# Simulation tools

Headless tools of the Godot project. Their purpose (user, 2026-11-12): **try things out** to find out (1) whether the gameplay is fun and makes sense and (2) which prices skills will need. Skill prices are **not settled**; the runs ignore them, and nothing checks a monster against a budget or a cost. The runs give **indications only**: no balance validation, no price approval and no rule source.

Simulations run on the battle core itself (`battle/core`), on the same content files as the game.

## Tools and data

| File | Purpose |
|---|---|
| `sim.gd` | Bot-vs-bot runs; prints one run block (or one table row) in the format of [docs/simulation_log.md](../../docs/simulation_log.md). Default: random teams from the game's monsters; `--team-a` / `--team-b` field any monsters by id. |
| `compare.gd` | Side-swapped comparison of two monsters; prints a result table. |
| `smoke_ui.gd` | Plays draft → placement → battle through the real UI (not a measurement tool). |
| `lib/sim_bots.gd` | Move policies `greedy` (AiBrain), `plan` (AiBrain's evaluation over two actions of one turn, about five times slower), `rush`, `kite`, `random`. |
| `lib/sim_runner.gd`, `lib/cli.gd` | Boards and start squares for fixed-team runs, the game loop, argument parsing. |
| `../data/monsters/*.tres` | All monsters: the nine of the game and any simulation-only test monsters (status `simulation`; none exists at the moment). |

**Calculation costs** (user decision 2026-11-12): there is no price folder and no price calculator any more. Every skill, zone, ground and prop resource carries `internal_calc_cost`, the current working number in construction points from the Skills §5 drafts (skill: whole skill, for a Strike the total without a Kin package; zone: per cell and round at level I; ground: per created cell; prop: per created prop; −1 = not calculated, e.g. every Surge, whose trap price is open). It is an authoring note: no rule reads it, no tool checks it, and it is not part of the content fingerprint. The tools have no test suite of their own.

## One data folder, one status scale

The project has one content folder, `data/`, with one folder per kind (user decisions 2026-11-12): `monsters`, `skills`, `zones`, `grounds`, `props`, `tamer`. The tools hold no data of their own, and there is no second skill, zone, kit, build or price set: a monster is one file (`data/monsters/<id>.tres`) with its species data, stats and kit, whether the game or only a simulation uses it.

Skills (`BattleSkillDef`) and monsters (`MonsterDef`) carry `content_status` (`battle/defs/content_status.gd`):

| Value | Meaning | Used by the game |
|---|---|---|
| `approved` | released content (none exists yet) | yes |
| `draft` | GDD draft or test content the game currently plays with (the default) | yes |
| `test` | exists only for automated tests | never |
| `simulation` | exists only for simulation runs (test monsters and their skills) | never |
| `archived` | kept for reference but no longer used; not in the default lists of the tools either | never |

The filter sits in one place per registry: `GameData.monster_ids()` (draft screen, enemy teams, overworld) and `BattleContent.game_monster_ids()` return only game monsters; a monster of the game may not hold a test-only or simulation-only skill (content check); the content fingerprint covers only what the game can field.

**A new test monster** is a new file in `data/monsters` with `content_status = "simulation"`: any stats, any one to four skills. Nothing checks its stat points or costs. The sixteen former test builds and their eleven reference skills were deleted on 2026-11-12 (they were built to compare prices of the timed Surge); retire something you want to keep by setting `archived` instead.

## Commands

Run from the repository root; everything after `--` belongs to the tool.

```sh
godot --headless --path godot -s res://tools/sim.gd -- 20 3v3 1 "$(git rev-parse --short HEAD)"
godot --headless --path godot -s res://tools/sim.gd -- 40 3v3 1 "<state>" --paired --compact-head --bot-a plan --bot-b plan
godot --headless --path godot -s res://tools/sim.gd -- 20 1v1 1 "<state>" --team-a blaze_tiger --team-b forge_golem --bot-a rush --bot-b rush
godot --headless --path godot -s res://tools/sim.gd -- 50 3v3 1 "<state>" --team-a blaze_tiger,forge_golem,gloom_wolf --experiment props
godot --headless --path godot -s res://tools/sim.gd -- 1 1v1 1 --team-a blaze_tiger --team-b moss_turtle --trace

godot --headless --path godot -s res://tools/compare.gd -- --seeds 1,2,3 --pairs-per-seed 10 --sizes 5,7 --bot rush
godot --headless --path godot -s res://tools/compare.gd -- --monsters forge_golem,moss_turtle --bot rush
```

- **`sim.gd` arguments:** `[battles] [mode] [seed] [state] [kits]`, then options. `--team-a` / `--team-b` field monsters by id (`--team-b` defaults to `--team-a`); `--bot-a` / `--bot-b` pick the policies; `--board` is `seeded` or `layout` for random-team runs and `flat` (default), `layout` or `seeded` for fixed teams; `--props a,b` adds one mirrored pair per prop id to a fixed-team run; `--experiment props` (with `--pairs N`) and `--experiment bots` print one block per row; `--trace` prints the board before every turn of one battle.
- **Further options of `sim.gd`:** `--variant a,b` sets the open test switches of `battle/core/battle_experiment.gd` for the run: `push=2` / `push=slide` (Strike and Surge pushes and pulls move further) and `kinpush` (Beast Strikes push, a Spirit Strike trades squares). `--shield-once` makes every shield zone skill once per round for the run, `--pressure N` shifts the start of late-round pressure, `--paired` gives battle *i* the same teams and board in every run, `--compact` / `--compact-head` print one table row per run. `--variant softpressure=N` replaces late-round pressure by one without damage (every N rounds the outer ring of the board breaks away, down to 3×3), `noshield` makes shield zone skills unusable, `jab=1` sets the Jab to 1 AP. The last compact column counts the battles that reached pressure by whether the side leading by total HP at that moment won, lost, had no lead, or the battle had no winner. The row ends with five usage columns: activations per battle by skill kind (Step separately), kit slots of each kind fielded per battle, activations per fielded slot, the most used skill with its share, and fielded skills never used; they show whether a kind is used much only because the kits hold many slots of it. Trap Surges, board-edge damage and spiky props are rules of the build, not options; the variants measured before that (timer, edge damage of Surges, grown footprint, caster line, held Surges) were removed from the code and are documented in entries S002–S004 of the simulation log. Background: T38 in [temp_todo.md](../../docs/temp_todo.md).
- **New Resource classes or scripts:** run `godot --headless --path godot --import` once (or open the editor) so the class cache knows them.
- **A script that fails to compile does not quit by itself:** add `--quit-after 3` (or a `timeout`) to unattended runs.

## What a run covers

- **Resolved by the battle core:** everything the build implements, including trap Surges, extra turns (TPR), Strike legality at the board edge, Mountains and props on `layout` / `seeded` boards, late-round pressure and Draws.
- **Board of a fixed-team run:** `flat` is an empty board of the mode's size without Mountains; start squares are drawn by the seed from side 0's start area ([Battle §4.1](../../docs/gdd_battle.md#41-battlefield-generation)) and mirrored for side 1. On 1v1 the start area is the corner square, so seeds differ only through the bots' tie-breaks.
- **Not covered:** tamer skills, 2×2 and air units (no monster fields them), human play.

## Bots

`greedy` is `AiBrain`, the game's own opponent: one-step lookahead on a copy of the battle. `rush` strikes whoever stands in a shape, otherwise casts, otherwise walks toward the nearest enemy; `kite` backs away when an enemy is within 2 squares; `random` picks a random legal action. All four only take actions the battle reports as legal. None plans ahead, refreshes timed effects on purpose, targets props or uses tamer skills, so stalling and late-round pressure can decide a run. `rush` and `kite` rank movement by walking distance; `AiBrain` uses board distance and can stand still on an exact diagonal with Movement 1 (tracked as I42 in [temp_todo.md](../../docs/temp_todo.md)).

Rough speed on one core: `rush` about 40 ms per 1v1 battle; `greedy` about 0.1–0.3 s per 1v1 battle and 1–2 s per 3v3 battle.

## Reading comparisons

`compare.gd` plays every seed **twice with swapped sides** on the same mirrored start squares with the same bot and no tamer skills. A Draw, including a timeout after 600 turns, scores 0.5. The table reports the stat points of both sheets (information only), wins, Draws, mean score, mean rounds and timeouts; SD and range describe the **seed-block mean scores** of monster A, not confidence intervals.

Two monsters that differ in more than one thing probe the whole sheet, **not the value of a single skill**; change one thing at a time to learn about it. High Draw rates or bot stalling make a 50/50 score meaningless. No price, budget or rule change follows from a run by itself.

## Recording results

A `sim.gd` run block or compact row is pasted unchanged into [docs/simulation_log.md](../../docs/simulation_log.md), which defines the entry format. A `compare.gd` table is recorded with its command, seeds, game count and limits under T13 in [docs/temp_todo.md](../../docs/temp_todo.md). Conclusions become tasks there; nothing is concluded in this folder.
