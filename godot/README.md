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
             of content with an optional in-game-only filter, reached from the main menu)
data/        ALL content as Resource files, one folder per kind (a new file = new content)
             monsters/ skills/ zones/ grounds/ props/ tamer/  — the game's content and, with the status
                                                               "simulation", test monsters of the tools; every
                                                               skill/ground/zone/prop carries an internal_calc_cost authoring note
tests/       gdUnit4 suites: tests/battle, tests/shared, tests/overworld, tests/game
tools/       headless tools (tools/README.md): sim.gd (AI-vs-AI runs), compare.gd (comparison of two
             monsters), progression.gd (entry/upgrade interventions), discovery.gd (authored new-skill/map
             experiments), smoke_ui.gd (plays the real UI);
             lib/ their shared scripts (their data lies under data/, their Resource classes in battle/defs/)
```

**Simulation-only discovery content:** Mist Step, Receding Blow, Cloudstep Token, Raise Reed Screen and the Reed Screen prop are experimental Resources under `data/`, not enabled in regular kits or the builders' in-game choices. The overview's **In game only** filter excludes them; with that filter off it can display them as non-game records. The discovery tool substitutes them only for its runs, tests light-obstacle/split-vein maps, and leaves authored stats intact. These trials are not approved GDD content, item/loadout rules or prices; commands and limits are in [tools/README.md](tools/README.md), results in [S023](../docs/simulation_log.md#s023--2026-11-14--authored-gameplay-discovery-and-mist-step-ablation).

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
- **Preview = dry run:** `Battle.preview(action)` applies the action to a muted copy and returns its events.
  The cast preview, the AI and the real resolution therefore share one implementation. Surge forecasting remains
  legacy/test-only code, not an active game mechanic.
- **Fixed resolution order:** `BattlePayload` resolves Strikes and board skills as
  damage → defeat → displacement → board operations (removals, props, ground, zones) → self retreat → passive
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
| **Skill** | new `BattleSkillDef` in `data/skills/`: `kind` picks the active profile (strike, zone, ground, move, buff, passive); fill that profile's group; `board_ops` for ground / zone / prop changes (Surge and height fields are legacy/test-only) | a new execution profile or a new `BoardOp`: add the data fields and one branch in `Battle._use_skill` / the matching `BattlePayload` phase |
| **Strike shape** | one entry in `StrikeShapes` (offsets, directions, AP) | — |
| **Passive** | a `BattleSkillDef` of kind `passive` using the Passive group (stat effects, ignored effects / grounds, damage reductions, immovable, …) | a new kind of rule modifier: add the field and read it in `BattleStats` |
| **Monster** | new `MonsterDef` in `data/monsters/<id>.tres`: Kin, reference stats and the kit of up to 4 skills in one file | — |
| **Tamer skill** | new `TamerSkillDef` in `data/tamer/` | always: tamer skills are unique mechanics, each has its resolver in `BattleTamer` |

Unique mechanics stay local: the Kin twists live in the `KinRules` table, tamer skills in `BattleTamer`, late-round
pressure in `BattleTurn`. No other module asks for a concrete monster, skill, prop or ground id.

## Content status and build rules

- **Current content is test data, working drafts or experiments**, not approved content (docs/temp_todo.md T10–T13). Skills, monsters,
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
    Strike pushes 1; the board edge deals 1 and a spiky prop 2 to a monster moved into it; Step 1 AP, Run 1 AP; authored movement costs vary (including user experiments), with the reference
    non-Run movement skills at 2 AP over the full Movement stat; extra turns count from round 2 (`tpr_from_round`); push and
    pull zones also move at cast; everyone may rotate a placed shape; a push zone left by a skill that also creates
    something else points where the placement is turned (`BattleCasting.rot_dir`).
  - **Content:** the in-game pool is status-filtered, not a fixed nine-monster catalogue; it includes the user
    experiment `asdf` and user-built skills. Spread authored stats and kits live in `data/`; `vigor`, `sap` and
    `tempo` (AP and turns), Battle Trance and Time Split are experiments. Retired records are `archived`.
  - **Normal versus trial defaults:** in-game ZONE skills carrying PUSH/PULL (including mixed effects such as Bog)
    currently cost 1 AP. The tools' 2-AP candidate and discovery's `single_vein` map are not adopted game defaults;
    normal 7×7 remains three veins. These switches do not set monster AP. See [tools](tools/README.md#commands).
- **Still in the code, unused by the game** (to be removed, temp_todo I56/I57): height and Mountains, the air layer,
  Surges and traps (`PendingSurge`, the Surge fields of `BattleSkillDef`), the `shield` / `mend` / `expose` effects,
  and the switches that belong to them (`surge_fair`, `surge_at_caster`, `surge_wall`, `surge_ground`, `trap_cap`,
  `trap_rounds`, `no_shield_zones`). Tests that build these by hand still run.
- **Overview and skill builder:** `game/overview.gd` has five tables (skills as cards, monsters, grounds, zones,
  props) with one row per Resource under `data/`. **In game only** excludes `test`, `simulation` and `archived`; the checkbox is initially off, so these records can still appear in the unfiltered debug overview. Its button **Skill builder** (`game/skill_builder.gd`) builds a
  skill from the parts of the card or draws a random one, saves it to `data/skills/<id>.tres` with the status
  `experiment` and can write it into a kit slot of a monster file. Writing needs the project to run from its folder;
  nothing checks a price.
- **Monster builder** (`game/monster_builder.gd`; button in the draft sandbox and in the overview): create a monster or
  change one (name, Kin, six stats, four kit slots), saved to `data/monsters/<id>.tres` (new ones with the status
  `experiment`) and registered in `BattleContent` and `GameData` (`GameData.register`), so it stands in the team choice at
  once. “New skill” opens the skill builder, which returns to the caller (`SkillBuilder.return_scene`). No price, budget
  or Kin access is checked. Changing an existing monster rewrites its file: Git is the way back.
- **Test switches** (`battle/core/battle_experiment.gd`, set by `sim.gd --variant` and partly in the draft screen;
  none is a rule): `delay_turn` with `delay_reverse` / `delay_first_round` (postponing a turn), `damage_from_round`
  (a calm first round), `start_back` (back-row starts), `push_steps`, `kin_push`, `no_rotation`, `step_ap` / `jab_ap` /
  `move_ap`, `soft_pressure`, and the AI switches `ai_hunt`, `ai_hunt_behind`, `ai_careful`, `ai_aggressive`,
  `ai_no_kind`. Tests: `tests/battle/test_battle_experiment.gd`.
- **Not built:** an owner mark for Dragon Veins in the battle view; Dragon Veins on 1v1, 2v2 and 5v5 boards; slot
  development (gdd_skills §6). `MonsterDef.reference_shape` and the overworld `StatShape` still name the six earlier
  stat shapes.
- **Removed:** the legacy skill model of the overworld (`SkillDef`, `ZoneDef`, skill evolution at the Evolution Pillar).

## Execution and validation boundaries

Full CPU use is authorized as of 2026-11-14. Invoke Godot directly with normal process/CPU settings; no code
change is needed. The optional [low-load launcher](tools/README.md#cpu-use-and-optional-low-load-launcher)
deliberately restricts CPU availability. Permission does not imply automatic parallelism or 100% use of every CPU.

`progression.gd` tests an entry action-economy proxy; `discovery.gd` retains authored stats, AP and TPR. Both use
matched teams with complete side swaps and source/completion guards. These are harness safeguards, not approval
of starts, upgrades, content, prices or fun. A usable active skill or budget fit does not establish viable starting
monsters or meaningful upgrade alternatives; owners are [Monsters §2.2](../docs/gdd_monsters.md#22-frame-budget-level-ups)
and [Skills §5](../docs/gdd_skills.md#5-value-and-prices)/[§6](../docs/gdd_skills.md#6-slot-levels-development-and-replacement), with validation under [T13](../docs/temp_todo.md).

Latest executed checks (2026-11-14, normal CPU settings): the full suite ran **303 cases**, including all
**158 passing Battle cases**. Two known non-Battle cases still fail: reference individual stats and roamer
movement (I46 in [temp_todo.md](../docs/temp_todo.md)); the suite is not green. Focused harness self-tests:
`progression.gd` **1183 passed / 0 failed**, `discovery.gd` **6930 passed / 0 failed**, including 37 real-action
fixtures. UI inspection and focused human play remain pending; these checks are not gameplay acceptance.
Historical simulation reports retain their original execution settings and results.

## Running the checks

```
godot --headless --path godot --import
godot --headless --path godot -s -d res://addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -c -a res://tests < /dev/null
godot --headless --path godot -s res://tools/smoke_ui.gd -- 3v3 7      # draft → placement → battle through the real UI
godot --headless --path godot -s res://tools/sim.gd -- 20 3v3 1 "<state>"   # AI vs AI; prints a run block for docs/simulation_log.md
godot --headless --path godot -s res://tools/compare.gd -- --bot rush                             # two monsters, side-swapped
```

Options, test monsters, bots and the limits of these runs: [tools/README.md](tools/README.md). None of them is a balance test.
