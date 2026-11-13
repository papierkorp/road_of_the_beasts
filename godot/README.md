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

- **Everything is test data or a working draft**, never approved content (docs/temp_todo.md T10–T13). Skills, monsters,
  grounds, zones and props carry `content_status` (`approved` / `draft` / `experiment` / `test` / `simulation` /
  `archived`); the game fields `approved`, `draft` and `experiment` (filter `ContentStatus.in_game`, called by
  `BattleContent` and `GameData`). Details: [tools/README.md](tools/README.md).
- **The build plays the reshape of 2026-11-13** (user decisions; docs/gdd_battle.md §1.2, §4, §6 and docs/gdd_skills.md
  §2–§4; every choice made while building it: docs/temp_todo.md T40):
  - **A square is ground + zone + occupant.** Ground acts at a moment (on entering, on leaving, at the end of the
    occupant's turn, at the end of the round; `GroundTrigger`), a zone while a monster stands inside (stat changes,
    push or pull at the end of its turn). No Mountains, no flying, no Surges, no traps.
  - **A skill only delivers** (`BattleSkillDef`): a Strike, the user's movement, an effect on the user (self buff,
    passive), and the ground, zone or prop it creates (`board_ops`: `ground`, `create_zone`, `create_prop`; a zone
    skill names its zone directly). A Strike leaves them on the struck squares, a movement on the squares it left.
    `SkillGen.card` (`battle/defs/skill_gen.gd`) turns any skill into its card.
  - **Dragon Veins** (ground `dragon_vein`, three on the centre row of 7×7; `BattleExperiment.wells`) belong to the side
    that touched them last (`BoardCell.owner_side`, `Battle.touch_veins`; switch `vein_touch`) and deal 1 damage to the
    nearest enemy of their owner at the end of a round. A monster with two enemies on its eight neighbour squares
    takes 1 (`flank`). Late-round pressure runs only when nobody owns a vein (`pressure_mode` = `idle`).
  - **Working values:** highest hit 2, lowest HP 3; ground laid in battle lasts 2 rounds (`ground_rounds`); every
    Strike pushes 1; the board edge deals 1 and a spiky prop 2 to a monster moved into it; Step 1 AP, Run 1 AP, every
    other movement skill 2 AP over the full Movement stat; extra turns count from round 2 (`tpr_from_round`); push and
    pull zones also move at cast; everyone may rotate a placed shape; a push zone left by a skill that also creates
    something else points where the placement is turned (`BattleCasting.rot_dir`).
  - **Content:** 26 skills, nine kits and spread test stats in `data/`; the experiment effects `vigor`, `sap` and
    `tempo` (AP and turns) with the self buffs Battle Trance and Time Split. Everything retired is `archived`.
- **Still in the code, unused by the game** (to be removed, temp_todo I56/I57): height and Mountains, the air layer,
  Surges and traps (`PendingSurge`, the Surge fields of `BattleSkillDef`), the `shield` / `mend` / `expose` effects,
  and the switches that belong to them (`surge_fair`, `surge_at_caster`, `surge_wall`, `surge_ground`, `trap_cap`,
  `trap_rounds`, `no_shield_zones`). Tests that build these by hand still run.
- **Overview and skill builder:** `game/overview.gd` has five tables (skills as cards, monsters, grounds, zones,
  props) with one row per Resource file under `data/`. Its button **Skill builder** (`game/skill_builder.gd`) builds a
  skill from the parts of the card or draws a random one, saves it to `data/skills/<id>.tres` with the status
  `experiment` and can write it into a kit slot of a monster file. Writing needs the project to run from its folder;
  nothing checks a price.
- **Monster builder** (`game/monster_builder.gd`; button in the draft sandbox and in the overview): create a monster or
  change one (name, Kin, six stats, four kit slots), saved to `data/monsters/<id>.tres` (new ones with the status
  `experiment`) and registered in `BattleContent` and `GameData` (`GameData.register`), so it stands in the team choice at
  once. “New skill” opens the skill builder, which returns to the caller (`SkillBuilder.return_scene`). No price, budget
  or Kin access is checked. Changing one of the nine monsters rewrites its file: Git is the way back.
- **Test switches** (`battle/core/battle_experiment.gd`, set by `sim.gd --variant` and partly in the draft screen;
  none is a rule): `delay_turn` with `delay_reverse` / `delay_first_round` (postponing a turn), `damage_from_round`
  (a calm first round), `start_back` (back-row starts), `push_steps`, `kin_push`, `no_rotation`, `step_ap` / `jab_ap` /
  `move_ap`, `soft_pressure`, and the AI switches `ai_hunt`, `ai_hunt_behind`, `ai_careful`, `ai_aggressive`,
  `ai_no_kind`. Tests: `tests/battle/test_battle_experiment.gd`.
- **Not built:** an owner mark for Dragon Veins in the battle view; Dragon Veins on 1v1, 2v2 and 5v5 boards; slot
  development (gdd_skills §6). `MonsterDef.reference_shape` and the overworld `StatShape` still name the six earlier
  stat shapes.
- **Removed:** the legacy skill model of the overworld (`SkillDef`, `ZoneDef`, skill evolution at the Evolution Pillar).

## Running the checks

```
godot --headless --path godot --import
godot --headless --path godot -s -d res://addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -c -a res://tests < /dev/null
godot --headless --path godot -s res://tools/smoke_ui.gd -- 3v3 7      # draft → placement → battle through the real UI
godot --headless --path godot -s res://tools/sim.gd -- 20 3v3 1 "$(git rev-parse --short HEAD)"   # AI vs AI; prints a run block for docs/simulation_log.md
godot --headless --path godot -s res://tools/compare.gd -- --bot rush                             # two monsters, side-swapped
```

Options, test monsters, bots and the limits of these runs: [tools/README.md](tools/README.md). None of them is a balance test.
