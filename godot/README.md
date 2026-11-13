# Road of the Beasts — Godot project

```
shared/      data schemas and the cultivation model, used by every part
             MonsterDef (species, reference stats and kit in one file), Shapes, Aspect (look and materials only),
             Stage, StatShape, MonsterInstance (the individual monster), ItemCatalog,
             BattleRequest / BattleResult (the contract between battle and overworld), GameData (registry), UiTheme
battle/      the deterministic grid battle (docs/gdd_battle.md, gdd_skills.md, gdd_monsters.md)
  defs/      DEFINITIONS — pure data Resources and tables, no rules
             FieldEffect, GroundDef + GroundTrigger, PropDef + PropAftermath, BattleZoneDef, BattleSkillDef + BoardOp,
             TamerSkillDef, UnitSheet, StrikeShapes, KinRules, ContentStatus,
             BattleContent (registry of data/)
  core/      STATE and RULES — headless, no nodes, no randomness
             state:  Battle, Board, BoardCell, BoardProp, BoardZone, PendingSurge, BattleUnit
             rules:  BattleStats (effective stats, modifiers), BattleQueue (initiative), BattleMoves (movement
                     profiles), BattleCasting (placement), BattleDamage (damage law, ground triggers),
                     BattleDisplace (push / pull, collision, fall), BattleBoardOps (zones, ground, height, props),
                     BattlePayload (the §6.2 resolution order), BattleTurn (turn / round flow), BattleTamer
             setup:  BattleSetup (BattleRequest → Battle → BattleResult), BattleBoards (layouts), UnitSheets
                     (adapter: overworld individual → finished unit sheet)
             AiBrain (an opponent that only uses the public battle API)
  view/      PRESENTATION — 3D board (BattleView) and the input controller
  ui/        battle HUD, BattleText (datasheets, log, previews) and the draft sandbox
  battle.tscn, draft.tscn
overworld/   days, AP, night phase, economy, internal world (gdd_overworld.md)
game/        glue: main menu, settings, SaveGame, autoloads (GameSettings, GameSession), Overview (debug tables
             of every skill and monster record, reached from the main menu)
data/        ALL content as Resource files, one folder per kind (a new file = new content)
             monsters/ skills/ zones/ grounds/ props/ tamer/  — the game's content and, with the status
                                                               "simulation", test monsters of the tools; every
                                                               resource carries its internal_calc_cost
tests/       gdUnit4 suites: tests/battle, tests/shared, tests/overworld, tests/game
tools/       headless tools (tools/README.md): sim.gd (AI-vs-AI runs), compare.gd (comparison of two
             monsters), smoke_ui.gd (plays the real UI);
             lib/ their shared scripts (their data lies under data/, their Resource classes in battle/defs/)
```

## Dependency rule

`shared` ← `battle` ← `game`, and `shared` ← `overworld` ← `game`.
Battle and overworld **never import each other**: the overworld builds a `BattleRequest`, the battle
returns a `BattleResult` (gdd_overworld §8) — both classes live in `shared/`. `game/` is the only place
that knows both halves (menu, `GameSession`, saves). `shared/` no longer depends on `battle/core`.

## Battle architecture

| Layer | Where | Rule |
|-------|-------|------|
| Definitions | `battle/defs`, `data/*.tres` | Data only. A definition never contains resolution code. |
| State | `Battle` + `Board*`, `BattleUnit`, `PendingSurge` | Plain data; `Battle.clone()` copies it, `snapshot()` / `state_hash()` describe it. |
| Rules | `battle/core/battle_*.gd` | Static functions on a `Battle`. No nodes, time, frames or UI state. |
| Presentation | `battle/view`, `battle/ui` | Calls `Battle.check` / `preview` / `apply`, reads state and `events`. Decides nothing. |

- **One entry point:** every change is an action Dictionary passed to `Battle.apply()` (`step`, `skill`, `end_turn`,
  `tamer`); `Battle.check()` says why an action is illegal and never changes state.
- **Determinism:** the rules contain no randomness. Same start state + same content (`BattleContent.VERSION` /
  `fingerprint()`) + same ordered actions = same `events` and `state_hash()`. `Battle.actions` is the replayable
  log (`Battle.replay`). Seeds exist only outside the rules: board layout (`BattleRequest.board_seed`) and the
  AI's tie-breaks.
- **Preview = dry run:** `Battle.preview(action)` applies the action to a muted copy and returns its events (for a
  Surge also the forecast of its detonation). The cast preview, the AI and the real resolution therefore share one
  implementation.
- **Fixed resolution order:** `BattlePayload` resolves every Strike, Surge detonation and board skill as
  damage → defeat → displacement → board operations (removals, height, props, ground) → self retreat → passive
  reactions (gdd_battle §6.2). Skills only supply data to these phases.
- **Shared effect vocabulary:** zones, blessed ground, aura props, timed unit effects and passives all contribute
  `FieldEffect` entries (`slow`, `quicken`, `shield`, …); `BattleStats` is the one place that collects them.

## Adding content

Everything under `data/` is loaded by folder; the file name is the id. `tests/battle/test_battle_content.gd`
validates the whole set and shows a new ground, prop and skill built from existing parts without code changes.

| To add | Do this | New code needed when |
|--------|---------|----------------------|
| **Ground type** | new `GroundDef` in `data/grounds/`: movement cost, max level, `GroundTrigger`s (start of turn / on enter / end of turn, damage or heal), while-standing `FieldEffect`s, colour | it needs a behaviour element that does not exist yet (a new trigger timing, a new effect tag): extend `GroundTrigger` / `FieldEffect` and the one function that reads them (`BattleDamage.ground_effects`, `BattleStats.contributions`) |
| **Prop** | new `PropDef` in `data/props/`: layer, HP, `heavy`, aura effects, `PropAftermath` list (damage / push / spawn + pattern), ground left | a new aftermath operation: add it to `PropAftermath` and `BattlePayload._removal_round` |
| **Zone** | new `BattleZoneDef` in `data/zones/` (effects with base / cap and recipient layers) + a zone skill | a new effect tag (see ground) |
| **Skill** | new `BattleSkillDef` in `data/skills/`: `kind` picks the profile (strike, surge, zone, ground, move, buff, passive); fill that profile's group; `board_ops` for ground / height / prop changes | a new execution profile or a new `BoardOp`: add the data fields and one branch in `Battle._use_skill` / the matching `BattlePayload` phase |
| **Strike shape** | one entry in `StrikeShapes` (offsets, directions, AP) | — |
| **Passive** | a `BattleSkillDef` of kind `passive` using the Passive group (stat effects, ignored effects / grounds, damage reductions, immovable, …) | a new kind of rule modifier: add the field and read it in `BattleStats` |
| **Monster** | new `MonsterDef` in `data/monsters/<id>.tres`: Kin, reference stats and the kit of up to 4 skills in one file | — |
| **Tamer skill** | new `TamerSkillDef` in `data/tamer/` | always: tamer skills are unique mechanics, each has its resolver in `BattleTamer` |

Unique mechanics stay local: the Kin twists live in the `KinRules` table, tamer skills in `BattleTamer`, late-round
pressure in `BattleTurn`. No other module asks for a concrete monster, skill, prop or ground id.

## Content status and build rules

- **Everything is test data or a GDD draft**, never approved content (docs/temp_todo.md T10–T13). Skills and monsters
  carry `content_status` (`approved` / `draft` / `test` / `simulation` / `archived`); the game never fields test-only,
  simulation-only or archived records (filter in `BattleContent`). Details: [tools/README.md](tools/README.md).
- **Build rules that are GDD working drafts since 2026-11-12** (user directions, docs/temp_todo.md T38, not validated):
  **Surge** and **trap** are two skill kinds: a Surge is cast on any squares and detonates after its turns (2) of any
  monster; a trap needs monster-free squares, stays until a monster, a new prop or a new Mountain appears on it, never
  lapses and may be set repeatedly; a Surge replaces a trap square by square; a monster pushed against
  the **board edge** takes 1 damage; a monster pushed into a **spiky prop** (`PropDef.spiky`: Bamboo Stand, Stone Lion)
  takes 2; movement skills may displace on landing (`BattleSkillDef.impact_push`).
  Since the user decisions of 2026-11-12 also: Step 1 AP, slotted movement skills 1 AP, shield / mend zone skills 2 AP,
  push and pull zones also move the monsters in them at cast, every Strike pushes each struck monster 1 square away,
  and everyone may rotate a placed shape.
- **Test content without a GDD skill record** (T38): board skills Set Gong and Plant Bamboo (place a Bronze Gong / a
  spiky Bamboo Stand on a free square in Reach); props Vortex Urn (destroyed: pulls the eight neighbours 1 square in)
  and Storm Drum (pushes a monster that ends its turn orthogonally next to it 1 square away).
- **Test switches, build only** (`battle/core/battle_experiment.gd`, set in the draft screen or by `sim.gd --variant`): pushes
  over 2 squares / sliding, the Spirit swap, no rotation, AP of Step / Jab / movement, and the aggressive bot, and `soft_pressure` (late-round pressure without damage: the outer ring breaks away
  every N rounds down to 3×3; not shown by the battle view yet).
- **Build rules since simulation S011** (user decision 2026-11-12; working drafts in gdd_battle §4.5 and gdd_skills §3,
  [docs/simulation_log.md](../docs/simulation_log.md) S011/S012): ground laid during the battle turns back into Plain at
  the end of the round after the one it was laid in (`ground_rounds` = 2), a monster holds one trap per trap skill
  (`trap_cap` = 1; setting it again moves the trap), no kit holds a shield zone (Moss Turtle: Mire, Dusk Moth: Blink) and
  the AI walks up to the enemy instead of ending a turn with AP left (`ai_hunt`, not a rule). The three values stay
  switches of `battle_experiment.gd` so that `sim.gd` can compare (0 / off = the earlier behaviour). The battle view
  does not show how long ground still lasts.
- **Wellspring rules, build rules since 2026-11-13** (user decision, working draft in gdd_battle §4.2 / §2.2, temp_todo T39;
  simulations S013–S015): three Wellspring squares on the centre row of the 7×7 board (`wells` = 3, ground
  `data/grounds/wellspring.tres`; no prop or Mountain there; boards with an even side or under 7×7 get none). At the end of a
  round a monster standing on one deals 1 damage to the nearest enemy (ties: more HP, more initiative, then roster order
  as a stand-in for the holder's choice), and a monster with two enemies on its eight neighbour squares takes 1 damage
  (`flank`). In round 1 every monster has one turn (`tpr_from_round` = 2). Late-round pressure runs only at the end of a
  round in which nobody holds a Wellspring (`pressure_mode` = `idle`; `always` / `none` to compare). `AiBrain` values held
  Wellsprings and surrounded monsters and walks toward a free Wellspring. The battle view colours the square; it does not
  show who a Wellspring hits next.
- **Stats of the nine monsters** follow the draft prices of 2026-11-13 (gdd_monsters §2.2: HP 2 per point from a base of 4,
  initiative 0.5, second turn 3; four frames). `MonsterDef.reference_shape`, the overworld `StatShape` and the overview
  screen still name the six earlier shapes and prices.
- **Open switches of T39, off by default, no GDD rule:** `delay_turn` (action `delay`: before it has acted a monster may
  move its queue entry to the end of the round, once per round), `surge_at_caster` (a timed Surge fires at its caster's
  next turn), `surge_fair` (a Surge that is due waits until every monster on its squares has finished a turn since the
  cast) and the AI switch `ai_careful` (bot `careful`).
- **Further switches of S011, off by default, no GDD rule:** `trap_rounds` (an unsprung trap lapses at the end of the
  N-th round), `no_shield_zones` (shield zone skills cannot be used), `start_back` (back-row starts), `ai_hunt_behind`
  (only the side that is not ahead walks up) and `ai_no_kind` (a side plays without one skill kind; simulations only).
  Tests: `tests/battle/test_battle_experiment.gd`.
- **Removed:** the legacy skill model of the overworld (`SkillDef`, `ZoneDef`, skill evolution at the Evolution
  Pillar). Slot development (gdd_skills §6) is not built.

## Running the checks

```
godot --headless --path godot --import
godot --headless --path godot -s -d res://addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -c -a res://tests < /dev/null
godot --headless --path godot -s res://tools/smoke_ui.gd -- 3v3 7      # draft → placement → battle through the real UI
godot --headless --path godot -s res://tools/sim.gd -- 20 3v3 1 "$(git rev-parse --short HEAD)"   # AI vs AI; prints a run block for docs/simulation_log.md
godot --headless --path godot -s res://tools/compare.gd -- --bot rush                             # two monsters, side-swapped
```

Options, test monsters, bots and the limits of these runs: [tools/README.md](tools/README.md). None of them is a balance test.
