# Simulation tools

Headless tools of the Godot project. Their purpose (user, 2026-11-12): **try things out** to find out (1) whether the gameplay is fun and makes sense and (2) which prices skills will need. Skill prices are **not settled**; the runs ignore them, and nothing checks a monster against a budget or a cost. The runs give **indications only**: no balance validation, no price approval and no rule source.

Simulations run on the battle core itself (`battle/core`), on the same content files as the game.

## Tools and data

| File | Purpose |
|---|---|
| `sim.gd` | Bot-vs-bot runs; prints one run block (or one table row) in the format of [docs/simulation_log.md](../../docs/simulation_log.md). Default: random teams from the game's monsters; `--team-a` / `--team-b` field any monsters by id. |
| `compare.gd` | Side-swapped comparison of two monsters; prints a result table. |
| `smoke_ui.gd` | Plays draft → placement → battle through the real UI (not a measurement tool). |
| `lib/sim_bots.gd` | Move policies `greedy` (AiBrain as the game plays it: it walks up to the enemy; `hunt` is the same bot), `wait` (AiBrain up to S011: ends the turn instead), `chase` (walks up only while not ahead), `plan` (AiBrain's evaluation over two actions of one turn, about five times slower), `tactic` (plans the whole turn and plays the best end positions on with greedy bots until the monster's next turn; about twenty times slower), `rush`, `kite`, `random`. |
| `lib/sim_runner.gd`, `lib/cli.gd` | Boards and start squares for fixed-team runs, the game loop, argument parsing. |
| `../data/monsters/*.tres` | All monsters: the nine of the game and any simulation-only test monsters (status `simulation`; none exists at the moment). |

**Calculation costs** (user decision 2026-11-12): there is no price folder and no price calculator any more. Every skill, zone, ground and prop resource carries `internal_calc_cost`, the current working number in construction points from the Skills §5 drafts (skill: whole skill, for a Strike the total without a Kin package; zone: per cell and round at level I; ground: per created cell; prop: per created prop; −1 = not calculated, e.g. every Surge, whose trap price is open). It is an authoring note: no rule reads it, no tool checks it, and it is not part of the content fingerprint. The tools have no test suite of their own.

## One data folder, one status scale

The project has one content folder, `data/`, with one folder per kind (user decisions 2026-11-12): `monsters`, `skills`, `zones`, `grounds`, `props`, `tamer`. The tools hold no data of their own, and there is no second skill, zone, kit, build or price set: a monster is one file (`data/monsters/<id>.tres`) with its species data, stats and kit, whether the game or only a simulation uses it.

Skills (`BattleSkillDef`), monsters (`MonsterDef`), grounds, zones and props (since 2026-11-13) carry `content_status` (`battle/defs/content_status.gd`):

| Value | Meaning | Used by the game |
|---|---|---|
| `approved` | released content (none exists yet) | yes |
| `draft` | GDD draft or test content the game currently plays with (the default) | yes |
| `experiment` | a mechanic the user wants to try in the game (since 2026-11-13; e.g. rare, expensive skills that change AP or turns per round); labelled in the overview | yes |
| `test` | exists only for automated tests | never |
| `simulation` | exists only for simulation runs (test monsters and their skills) | never |
| `archived` | kept for reference but no longer used; not in the default lists of the tools either | never |

The filter sits in one place per registry: `GameData.monster_ids()` (draft screen, enemy teams, overworld) and `BattleContent.game_monster_ids()` return only game monsters; a monster of the game may not hold a test-only or simulation-only skill (content check); the content fingerprint covers only what the game can field.

**A new test monster** is a new file in `data/monsters` with `content_status = "simulation"`: any stats, any one to four skills. Nothing checks its stat points or costs. The sixteen former test builds and their eleven reference skills were deleted on 2026-11-12 (they were built to compare prices of the timed Surge); retire something you want to keep by setting `archived` instead.

## Commands

**Since the reshape of 2026-11-13** the game has no Surges, traps, Mountains or flyers ([gdd_battle §1.2](../../docs/gdd_battle.md#12-battle-design-pillars)). The variants below that act on them (`alltraps`, `alltimed`, `turns=N`, `trapcap`, `trapfade`, `castersurge`, `fairsurge`, `unfairsurge`, `surgewall`, `surgeground`, `surgedmg`, `noshield`, `shield=N`, `shieldap`, `--shield-once`) still parse but change nothing in a run on the game's content; they go with the code clean-up (temp_todo I57). The variants to work with now: `mixstats`, `mixskills`, `mixkits`, `genskills=N`, `calm=N`, `veinhold`, `wells=N`, `noflank`, `delay`, `delay=reverse`, `delay=first`, `startback`, `stat=…`, `swap=old>new`, `freeap=N`, `freemod=N`, `strikedmg=N`, `groundfade=N`, `tpr1`.

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
- **Further options of `sim.gd`:** `--variant a,b` sets the open test switches of `battle/core/battle_experiment.gd` for the run: `push=2` / `push=slide` (Strike and Surge pushes and pulls move further) and `kinpush` (Beast Strikes push, a Spirit Strike trades squares). `--shield-once` makes every shield zone skill once per round for the run, `--pressure N` shifts the start of late-round pressure, `--paired` gives battle *i* the same teams and board in every run, `--compact` / `--compact-head` print one table row per run. `--variant softpressure=N` replaces late-round pressure by one without damage (every N rounds the outer ring of the board breaks away, down to 3×3), `noshield` makes shield zone skills unusable, `jab=1` sets the Jab to 1 AP. The last compact column counts the battles that reached pressure by whether the side leading by total HP at that moment won, lost, had no lead, or the battle had no winner. The row ends with five usage columns: activations per battle by skill kind (Step separately), kit slots of each kind fielded per battle, activations per fielded slot, the most used skill with its share, and fielded skills never used; they show whether a kind is used much only because the kits hold many slots of it. Three more columns follow (since S010): the share of battles under 3, over 7 and over 10 rounds with the longest battle, the mean round of the first defeat, and monsters defeated before their own first turn per battle. Trap Surges, board-edge damage and spiky props are rules of the build, not options; the variants measured before that (timer, edge damage of Surges, grown footprint, caster line, held Surges) were removed from the code and are documented in entries S002–S004 of the simulation log. Background: T38 in [temp_todo.md](../../docs/temp_todo.md).
- **Wellspring rules (build rules since 2026-11-13; S013–S015):** the default is `wells=3`, surrounding on, TPR from round 2 and late-round pressure only when nobody holds a Wellspring. To compare: `--variant wells=N` (0 = none), `noflank`, `tpr1` (TPR counts from round 1), `latepressure=always` / `none`. Also `delay` (a monster may postpone its turn once per round) and `castersurge` (a timed Surge fires at its caster's next turn). `fairsurge` makes a due Surge wait until every monster on its squares has finished a turn since the cast. With `SIM_DEBUG` every defeat is printed with the damage history of the monster (`DBGHIT`). A compact row ends with one more column: share of last defeats, of all defeats and of the damage by Wellsprings / by surrounding, and the Wellsprings held per round end by each side. `smoke_ui.gd` takes the label of a draft check box as third argument (`Wellsprings`).
- **Switches and options added for S011/S012:** `--variant groundfade=N` (ground laid during the battle turns back into Plain at the end of the N-th round; **build rule 2**, 0 = never), `trapcap=N` (at most N traps per trap skill and monster; one more removes the oldest; **build rule 1**, 0 = no limit), `trapfade=N` (an unsprung trap lapses at the end of the N-th round; not a rule), `stat=monster.field:value` (one stat of one monster for this run, e.g. `stat=forge_golem.move:2`), `noshield` (now the battle switch `no_shield_zones`), `shield=N` (Surge reduction of shield zones), `startback` (all monsters start on the back row), and content changes for one run only: `swap=old>new` (every kit holding skill `old` holds `new`), `hp=±N`, `hpmin=N`, `hpmax=N`, `tprmax=N`, `apmin=N`, `surgedmg=±N`, `strikedmg=0–4`, `zoneonce` / `castonce` (zone skills, or all placed skills, once per round). `--no-kind-a` / `--no-kind-b <kind>` makes the bot of one side never use a skill kind (strike, surge, trap, zone, ground, move), to measure what the kind is worth to the side that keeps it. With the environment variable `SIM_DEBUG` set, a full-block run prints every defeat with its round and cause and the winner of each battle. A variant row names its bots unless both sides play `greedy`.
- **Movement skills (build test since 2026-11-13, S016):** `--variant freeap=N` sets the AP of every movement skill other than Run (authored: 2), `freemod=N` takes N squares off their Movement (authored: 0).
- **Switches of S017 (2026-11-13; all off by default):** `--variant delay=reverse` (monsters that postponed act in reverse order), `delay=first` (postponing only in round 1, for monsters with two turns and the first of the queue), `calm=N` (no damage in the first N rounds), `surgewall` (no movement enters the squares of a charging timed Surge), `surgeground[=id]` (a timed Surge without ground of its own leaves this ground, default Thornbed). **Random draws for a run:** `mixkits` (every monster plays a random kit of the game's monsters and of the simulation-only kits `data/monsters/kit_*.tres`), `mixskills` (four random skills out of every skill of the game, the first one a Strike with damage), `mixstats` (HP 3–8, initiative 1–9, Movement 1–5, Reach 2–4, TPR 1–2, AP 2–3, each drawn alone). With them the block ends with a table of win rates per drawn kit, body + kit pair, skill and stat value.
- **Reshape of 2026-11-13:** `--variant genskills=N` makes `mixskills` draw from N generated skills (`battle/defs/skill_gen.gd`, class `SkillGen`: random legal skill sentences, kept in memory only; the same class serves the in-game skill builder); the block then lists win rates per part (`part:kind=…`, `part:shape=…`, `part:stays=…`, `part:ap=…`). `mixskills` alone draws from every skill of the game. `veinhold` and `unfairsurge` switch back to the rules before the reshape (a Dragon Vein only works while held; a due Surge does not wait). `mixkits` draws from the kits of the nine monsters (the ten `kit_*` files of S017 were deleted).
- **New Resource classes or scripts:** run `godot --headless --path godot --import` once (or open the editor) so the class cache knows them.
- **A script that fails to compile does not quit by itself:** add `--quit-after 3` (or a `timeout`) to unattended runs.

## What a run covers

- **Resolved by the battle core:** everything the build implements, including trap Surges, extra turns (TPR), Strike legality at the board edge, Mountains and props on `layout` / `seeded` boards, late-round pressure and Draws.
- **Board of a fixed-team run:** `flat` is an empty board of the mode's size without Mountains; start squares are drawn by the seed from side 0's start area ([Battle §4.1](../../docs/gdd_battle.md#41-battlefield-generation)) and mirrored for side 1. On 1v1 the start area is the corner square, so seeds differ only through the bots' tie-breaks.
- **Not covered:** tamer skills, 2×2 and air units (no monster fields them), human play.

## Bots

`greedy` is `AiBrain`, the game's own opponent: one-step lookahead on a copy of the battle; since the user decision after S011 it also walks toward the nearest enemy (walking distance) when it has AP left and no better action, unless the position gets worse by more than about one point of hazard damage (`hunt` names the same bot, as in the S011 tables). `wait` is the AI as it was before: it ends the turn instead. `careful` is `greedy` with the switch `ai_careful`: it counts the Strike damage enemies can bring to each of its monsters within a round and avoids squares where that is lethal (S014: it loses to `greedy`, 43–45 %). `tactic` (since 2026-11-13) searches every order of actions the AP allow (a beam over `AiBrain`'s evaluation, kept in a plain and a threat-aware ranking), then plays the best few end positions and, with `--variant delay`, the postponed turn on with `greedy` for both sides until its monster is up again, and takes the line with the best position at that point. So it sees Surges that fire before it can move, a Strike followed by a step back, and the double turn across a round border; it still assumes that everyone else plays `greedy`. `chase` walks up only while its side is not ahead in total HP (the side that would win by waiting for late-round pressure waits). In S010/S011 `hunt` lost to the waiting `greedy` under the build rules (40–44 %) and beat `rush` clearly. `rush` strikes whoever stands in a shape, otherwise casts, otherwise walks toward the nearest enemy; `kite` backs away when an enemy is within 2 squares; `random` picks a random legal action. All of them only take actions the battle reports as legal. None plans ahead, refreshes timed effects on purpose, targets props or uses tamer skills, so stalling and late-round pressure can decide a run. `rush` and `kite` rank movement by walking distance; `AiBrain` uses board distance and can stand still on an exact diagonal with Movement 1 (tracked as I42 in [temp_todo.md](../../docs/temp_todo.md)).

Rough speed on one core: `rush` about 40 ms per 1v1 battle; `greedy` about 0.1–0.3 s per 1v1 battle and 1–2 s per 3v3 battle; `tactic` about 20–25 s per 3v3 battle (run one process per seed in parallel).

## Reading comparisons

`compare.gd` plays every seed **twice with swapped sides** on the same mirrored start squares with the same bot and no tamer skills. A Draw, including a timeout after 600 turns, scores 0.5. The table reports the stat points of both sheets (information only), wins, Draws, mean score, mean rounds and timeouts; SD and range describe the **seed-block mean scores** of monster A, not confidence intervals.

Two monsters that differ in more than one thing probe the whole sheet, **not the value of a single skill**; change one thing at a time to learn about it. High Draw rates or bot stalling make a 50/50 score meaningless. No price, budget or rule change follows from a run by itself.

## Recording results

A `sim.gd` run block or compact row is pasted unchanged into [docs/simulation_log.md](../../docs/simulation_log.md), which defines the entry format. A `compare.gd` table is recorded with its command, seeds, game count and limits under T13 in [docs/temp_todo.md](../../docs/temp_todo.md). Conclusions become tasks there; nothing is concluded in this folder.
