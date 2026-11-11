# Road of the Beasts — Godot project

```
shared/      data schemas and the cultivation model, used by every part
             MonsterDef / SkillDef / ZoneDef / ZoneEffect / Shapes / Aspect (LEGACY species model of the overworld),
             Stage, StatShape, MonsterInstance (the individual monster), Evolution, ItemCatalog,
             BattleRequest / BattleResult (the contract between battle and overworld), GameData (registry), UiTheme
battle/      the deterministic grid battle (docs/gdd_battle.md, gdd_skills.md, gdd_monsters.md)
  defs/      DEFINITIONS — pure data Resources and tables, no rules
             FieldEffect, GroundDef + GroundTrigger, PropDef + PropAftermath, BattleZoneDef, BattleSkillDef + BoardOp,
             TamerSkillDef, BattleKitDef, UnitSheet, StrikeShapes, KinRules, BattleContent (registry of data/battle)
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
game/        glue: main menu, settings, SaveGame, autoloads (GameSettings, GameSession)
data/        content as Resource files (a new file = new content)
  battle/    grounds/ props/ zones/ skills/ tamer/ kits/  — what the battle resolves
  monsters/ skills/ zones/   legacy species data of the overworld model
tests/       gdUnit4 suites: tests/battle, tests/shared, tests/overworld, tests/game, tests/tools
tools/       headless tools (tools/README.md): sim.gd (AI-vs-AI runs), compare.gd (equal-cost build
             comparison), price.gd (construction-point calculator), smoke_ui.gd (plays the real UI);
             defs/ and lib/ their Resource classes and shared scripts, data/ price records and
             test builds as Resource files
```

## Dependency rule

`shared` ← `battle` ← `game`, and `shared` ← `overworld` ← `game`.
Battle and overworld **never import each other**: the overworld builds a `BattleRequest`, the battle
returns a `BattleResult` (gdd_overworld §8) — both classes live in `shared/`. `game/` is the only place
that knows both halves (menu, `GameSession`, saves). `shared/` no longer depends on `battle/core`.

## Battle architecture

| Layer | Where | Rule |
|-------|-------|------|
| Definitions | `battle/defs`, `data/battle/*.tres` | Data only. A definition never contains resolution code. |
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

Everything under `data/battle/` is loaded by folder; the file name is the id. `tests/battle/test_battle_content.gd`
validates the whole set and shows a new ground, prop and skill built from existing parts without code changes.

| To add | Do this | New code needed when |
|--------|---------|----------------------|
| **Ground type** | new `GroundDef` in `data/battle/grounds/`: movement cost, max level, `GroundTrigger`s (start of turn / on enter / end of turn, damage or heal), while-standing `FieldEffect`s, colour | it needs a behaviour element that does not exist yet (a new trigger timing, a new effect tag): extend `GroundTrigger` / `FieldEffect` and the one function that reads them (`BattleDamage.ground_effects`, `BattleStats.contributions`) |
| **Prop** | new `PropDef` in `data/battle/props/`: layer, HP, `heavy`, aura effects, `PropAftermath` list (damage / push / spawn + pattern), ground left | a new aftermath operation: add it to `PropAftermath` and `BattlePayload._removal_round` |
| **Zone** | new `BattleZoneDef` in `data/battle/zones/` (effects with base / cap and recipient layers) + a zone skill | a new effect tag (see ground) |
| **Skill** | new `BattleSkillDef` in `data/battle/skills/`: `kind` picks the profile (strike, surge, zone, ground, move, buff, passive); fill that profile's group; `board_ops` for ground / height / prop changes | a new execution profile or a new `BoardOp`: add the data fields and one branch in `Battle._use_skill` / the matching `BattlePayload` phase |
| **Strike shape** | one entry in `StrikeShapes` (offsets, directions, AP) | — |
| **Passive** | a `BattleSkillDef` of kind `passive` using the Passive group (stat effects, ignored effects / grounds, damage reductions, immovable, …) | a new kind of rule modifier: add the field and read it in `BattleStats` |
| **Monster kit** | new `BattleKitDef` in `data/battle/kits/<species_id>.tres` (4 slots + reference sheet); the species itself is a `MonsterDef` in `data/monsters/` | — |
| **Tamer skill** | new `TamerSkillDef` in `data/battle/tamer/` | always: tamer skills are unique mechanics, each has its resolver in `BattleTamer` |

Unique mechanics stay local: the Kin twists live in the `KinRules` table, tamer skills in `BattleTamer`, late-round
pressure in `BattleTurn`. No other module asks for a concrete monster, skill, prop or ground id.

## Content status

All shipped battle content is **test data or a GDD draft**, never approved content (docs/temp_todo.md T10–T13):
the nine kits rebuild the prior-draft assignments of gdd_skills §10 from decided mechanics only, the prop catalogue
is the working draft of gdd_battle §4.10, and seed 0 boards are fixed test layouts. Each record names its status.

## Running the checks

```
godot --headless --path godot --import
godot --headless --path godot -s -d res://addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -c -a res://tests < /dev/null
godot --headless --path godot -s res://tools/smoke_ui.gd -- 3v3 7      # draft → placement → battle through the real UI
godot --headless --path godot -s res://tools/sim.gd -- 20 3v3 1 "$(git rev-parse --short HEAD)"   # AI vs AI; prints a run block for docs/simulation_log.md
godot --headless --path godot -s res://tools/compare.gd -- --bot rush                             # equal-cost, side-swapped test builds
godot --headless --path godot -s res://tools/price.gd -- --example "Scaled Arc" --slot-level 2    # construction points of a price record
```

Options, test builds, bots and the limits of these runs: [tools/README.md](tools/README.md). None of them is a balance test.
