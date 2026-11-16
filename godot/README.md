# Road of the Beasts — Godot project

```
shared/      data schemas and the cultivation model, used by every part
             MonsterDef (species, reference stats and kit in one file), Shapes, Aspect (look and materials only),
             Stage, StatShape, MonsterInstance (the individual monster), ItemCatalog,
             BattleRequest / BattleResult (the contract between battle and overworld), GameData (registry), UiTheme
battle/      the deterministic grid battle (docs/battle.md, skills.md, monsters.md)
  defs/      DEFINITIONS — pure data Resources and tables, no rules
             FieldEffect, GroundDef + GroundTrigger, PropDef + PropAftermath, BattleZoneDef, BattleSkillDef + BoardOp,
             TamerSkillDef, UnitSheet, KinRules, ContentStatus,
             BattleShapes (the one shape vocabulary), Moment (the moments and the roles of ground, zone and prop),
             BoardSheet (reads ground, zones and props as one sheet),
             BattleContent (registry of data/)
  core/      STATE and RULES — headless, no nodes, no randomness
             state:  Battle, Board, BoardCell, BoardProp, BoardZone, PendingSurge, BattleUnit
             rules:  BattleStats (effective stats, modifiers), BattleQueue (pace), BattleMoves (movement
                     profiles), BattleCasting (placement), BattleDamage (damage law, ground triggers),
                     BattleDisplace (push / pull, collision, fall), BattleBoardOps (zones, ground, height, props),
                     BattlePayload (the §6.2 resolution order), BattleTurn (turn / round flow), BattleTamer
             setup:  BattleSetup (BattleRequest → Battle → BattleResult), BattleBoards (layouts), UnitSheets
                     (adapter: overworld individual → finished unit sheet)
             AiBrain (an opponent that only uses the public battle API)
  view/      PRESENTATION — 3D board (BattleView) and the input controller
  ui/        battle HUD, BattleText (datasheets, log, previews), the draft sandbox and ShapeEditor (free shapes before a battle)
  battle.tscn, draft.tscn
overworld/   days, AP, night phase, economy, internal world (overworld.md)
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
returns a `BattleResult` (overworld.md) — both classes live in `shared/`. `game/` is the only place
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
  reactions (battle.md). Skills only supply data to these phases.
- **Shared effect vocabulary:** zones, blessed ground, aura props, timed unit effects and passives all contribute
  `FieldEffect` entries (`slow`, `quicken`, `shield`, …); `BattleStats` is the one place that collects them.
- **Shared shapes and moments (2026-11-15):** `BattleShapes` is the one shape vocabulary (six base shapes with
  extensions, own square, block, free): a Strike, a skill that creates something around its user and a prop operation
  name a shape from it, and a skill has one shape field. `Moment` lists the moments at which ground, a zone or a prop
  acts and which kind may do what; `BoardSheet` reads all three into the same lines “when · what · how much · where”
  (Overview → Board sheets, content check of the roles). The three record classes (`GroundTrigger`, `FieldEffect`,
  `PropAftermath`) are not merged into one line class yet (docs/architecture.md §4).

## Adding content

Everything under `data/` is loaded by folder; the file name is the id. `tests/battle/test_battle_content.gd`
validates the whole set and shows a new ground, prop and skill built from existing parts without code changes.

| To add | Do this | New code needed when |
|--------|---------|----------------------|
| **Ground type** | new `GroundDef` in `data/grounds/`: movement cost, max level, `GroundTrigger`s (a moment of `Moment`: enter / leave / turn_end / round_end; damage or heal), while-standing `FieldEffect`s, colour | it needs a behaviour element that does not exist yet (a new trigger timing, a new effect tag): extend `GroundTrigger` / `FieldEffect` and the one function that reads them (`BattleDamage.ground_effects`, `BattleStats.contributions`) |
| **Prop** | new `PropDef` in `data/props/`: layer, HP, `solid`, `heavy`, `PropAftermath` list (moment `when` + operation + shape of `BattleShapes`: self / whirl / cross / storm / block, with extension), ground left | a new operation: add it to `PropAftermath` and `BattleProps.collect` |
| **Zone** | new `BattleZoneDef` in `data/zones/` (effects with base / cap and recipient layers) + a zone skill | a new effect tag (see ground) |
| **Skill** | new `BattleSkillDef` in `data/skills/`: `kind` picks the active profile (strike, zone, ground, move, buff, passive); fill that profile's group; `board_ops` for ground / zone / prop changes (Surge and height fields are legacy/test-only) | a new execution profile or a new `BoardOp`: add the data fields and one branch in `Battle._use_skill` / the matching `BattlePayload` phase |
| **Shape** | a base shape in `BattleShapes` (its arms and directions); an extension needs no entry, a skill names `shape` + `shape_extension`, or `free` with its `footprint` as the default arrangement | — |
| **Passive** | a `BattleSkillDef` of kind `passive` using the Passive group (stat effects, ignored effects / grounds, damage reductions, immovable, …) | a new kind of rule modifier: add the field and read it in `BattleStats` |
| **Monster** | new `MonsterDef` in `data/monsters/<id>.tres`: Kin, reference stats and the kit of up to 6 skills in one file | — |
| **Tamer skill** | new `TamerSkillDef` in `data/tamer/` | always: tamer skills are unique mechanics, each has its resolver in `BattleTamer` |

Unique mechanics stay local: the Kin twists live in the `KinRules` table, tamer skills in `BattleTamer`, late-round
pressure in `BattleTurn`. No other module asks for a concrete monster, skill, prop or ground id.

## Content status and build rules

- **Current content is test data, working drafts or experiments**, not approved content (docs/temp_todo.md T10–T13). Skills, monsters,
  grounds, zones and props carry `content_status` (`approved` / `draft` / `experiment` / `test` / `simulation` /
  `archived`); the game fields `approved`, `draft` and `experiment` (filter `ContentStatus.in_game`, called by
  `BattleContent` and `GameData`). Details: [tools/README.md](tools/README.md).
- **The build plays the reshape of 2026-11-13** (user decisions; docs/battle.md §1.2, §4, §6 and docs/skills.md
  §2–§4; every choice made while building it: docs/temp_todo.md T40):
  - **A square is ground + zone + occupant.** Ground acts at a moment (on entering, on leaving, at the end of the
    occupant's turn, at the end of the round; `GroundTrigger`), a zone while a monster stands inside (stat changes,
    push or pull at the end of its turn). No Mountains, no flying, no Surges; a trap is a walkable prop (below).
  - **A skill only delivers** (`BattleSkillDef`): a Strike, the user's movement, an effect on the user (self buff,
    passive), and the ground, zone or prop it creates (`board_ops`: `ground`, `create_zone`, `create_prop`; a zone
    skill names its zone directly). A Strike leaves them on the struck squares, a movement on the squares it left.
    `SkillGen.card` (`battle/defs/skill_gen.gd`) turns any skill into its card.
  - **Dragon Veins** (ground `dragon_vein`, three on the centre row of 7×7; `BattleExperiment.wells`) deal 1 damage at the end of a round to the
    nearest enemy of the side that touched them last (GDD rule, kept by the user after S028; `BoardCell.owner_side`,
    `Battle.touch_veins`; the board tints an owned vein in its side colour and labels it yours / enemy / unclaimed;
    `vein_touch` = false: only while a monster stands on it at the round end). A vein takes props like any other ground. A monster with two enemies on its eight neighbour squares
    takes 1 (`flank`). Late-round pressure runs only when nobody owns a vein (`pressure_mode` = `idle`).
  - **Working values:** highest hit 2 (HP runs from 1 to 10; the monster builder offers the ranges of monsters.md); ground laid in battle lasts 2 rounds (`ground_rounds`); a
    Strike pushes 1 if its record says so (`strike_push`, on by default); the board edge deals 1 and a spiky prop 2 to a monster moved into it; Step 1 AP, Run 1 AP; authored movement costs vary (including user experiments), with the reference
    non-Run movement skills at 2 AP (plus Stamina, below); extra turns count from round 2 (`tpr_from_round`); push and
    pull zones move only at the end of their occupant's turn, not at cast (build default since 2026-11-14, S025; `zone_cast_push`); everyone may rotate a placed shape; a push zone left by a skill that also creates
    something else points where the placement is turned (`BattleCasting.rot_dir`).
  - **Build since 2026-11-15 (user decisions of that day; S030; docs/temp_todo.md handoff and T41):**
    - *Pace:* the stat Initiative is called Pace everywhere (`pace`, `drain_pace`, `pace_bonus`). Scale: base 1.0, a
      stat point is 0.1 (`BattleStats.PACE_POINT`); `quicken` / `drain_pace` values count in points; an extra-turn entry
      sits 0.2 lower (`BattleQueue.EXTRA_TURN_PENALTY`); the nine monsters were converted by their points (9.0 → 1.4 …
      1.0 → 1.0); the AI weighs a Pace point double so that its choices stay as before. Saves from before load through
      `StatShape.pace_from_pool`; the overworld's stat shapes still count Pace on their 1–9 pool scale internally.
    - *Stamina is the rule* (`stamina` = true; false = the Movement rule before, to compare): the Movement stat of the
      sheet is the pool (the fields keep their names `movement` / `move`); a movement skill costs its AP and Stamina for
      every square (what the ground costs; a path over squares 1 each), reaches `move_range` squares (3) at most;
      Step costs none. Recovery at the round end = whole number of the *current* Pace, at least 1 (user decision
      2026-11-15: zones and timed effects on Pace count; `BattleStats.recovery(b, u)`; `stamina_regen` > 0 fixes it
      for everyone). The HUD shows it beside the pool ("Stamina 2/5 (+2)").
    - *Round end:* first everything moves, then everything acts, then all clocks tick together (user decisions of
      2026-11-15; `BattleTurn._end_round`, `_tick_clocks`): zones move props → props that push or pull (Storm Drum;
      `BattleProps.round_end(b, true)`) → round-end ground → the other round-end lines of the props (Ember Brazier)
      → Dragon Veins and surrounding → Stamina recovery → zones −1 round, timed unit effects, ground fades →
      pressure → queue. Lava keeps its own moment (the end of its occupant's turn).
    - *Strike:* damage (0–2) and push (`strike_push`) are both optional parts of the record; a Strike costs the
      `ap_cost` on its card (before: the AP of its shape, so Shove played at 2 AP; it is 1 AP now).
    - *Shapes:* `shape` + `shape_extension` on every skill (`BattleShapes`): Thrust is Jab +1 (8 directions now),
      Cleave Arc +1, Long Whirl / Long Cross the +1 forms; Cinder Dive is a Jab +2 around its user (the `trail` and
      `caster_ring` anchor modes are gone). A placed skill without a base shape is a **free shape**: its `footprint`
      is the default arrangement of N squares; the draft's **Arrange shapes** (`ShapeEditor`) lets the player lay them
      out per monster (connected, anchor included), `BattleRequest.player_shapes` carries them and
      `UnitSheets.arrange` gives the unit its own copy of the skill. The skill card shows the arrangement.
    - *Props on Dragon Veins:* also at board generation (seeded boards changed with it); only the centre stays free.
      Button squares still keep off veins.
    - *Board switches:* `board_size` (draft check boxes **Board 8×8** / **Board 9×9**; `sim.gd --variant size=N`):
      any mode on a larger board; start squares, the fixed layout and the seeded prop pairs follow the size. An even
      board has its Dragon Veins in mirrored pairs on the two centre rows (`wells` rounds up to an even number).
    - *Sheets and roles:* Overview → **Board sheets**; `BattleContent.validate` checks the roles of every ground, zone
      and prop the game fields (`BoardSheet.role_problems`).
    - *Action bar (user layout of 2026-11-15, `BattleHud`):* Step is one button over both rows, then a small gap,
      then the kit in columns of two (three columns for the six slots; keys 2–7 follow that order); End Turn over
      both rows; the side's tamer skills stand in a panel of their own beside the monster's bar. Each action names
      its `group` (`step`, `skill`, `tamer`). The view lowers its camera by half the bar's height
      (`BattleView.bottom_room`), so the board is centred in the room above the bar.
    - *Test stats (user approval of 2026-11-15, content `2026-11-15.2`):* seven monsters filled so that a Pace of
      2.x occurs: Blaze Tiger, Ember Hawk and Grove Wisp 2.2, Gloom Wolf and Dusk Moth 2.1 (they recover 2 Stamina);
      Gloom Wolf, Grove Wisp and Dusk Moth +1 HP; Moss Turtle Stamina 3; Hollow Serpent Pace 1.4, Stamina 4. Test
      values, not defaults ([content.md §5](../docs/content.md#5-the-nine-monsters)); the price
      scale behind them is not decided.
    - *Stat points (display only):* `MonsterDef.point_lines` / `points_of` hold the prices of monsters.md; the
      overview's monster table shows them in a Points column (hover for the calculation). Nothing checks a budget.
    - *Tools:* every result table states the mean rounds and the battles under 3 and over 5 rounds (`sim.gd`,
      `compare.gd`, `progression.gd`, `discovery.gd`); length target: a mean of 3.0–4.9 rounds.
  - **Build since 2026-11-14 (user decisions and drafts of that day; S028/S029; docs/temp_todo.md T40):**
    - *Decided:* every slotted skill at most `usage_limit` times per turn of its monster (1 unless the record says
      more; `once_per_turn` = false switches the limit off) and up to 6 kit slots (the nine kits hold 6 since 2026-11-15: skills.md).
    - *Prop rework (working draft, written into GDD §4.9–§4.12 on 2026-11-15):* `PropDef.solid` (false = a walkable prop: blocks no movement,
      push or Strike line, still has HP); every `PropAftermath` names its moment `when`: `destroyed`, `hit` (lost HP
      and still stands), `enter` (a monster came onto a walkable prop: a trap, used up) or `round_end`; operations
      `damage`, `push`, `pull`, `spawn`, `ground`, `zone` on a shape around the prop (`self`, `whirl`, `cross`, `storm`, `block`, with extension). Rules in
      `battle/core/battle_props.gd`; round order: round-end ground, props, Dragon Veins. Aura props (Banner, Shrine,
      Totem, Wardstone) are `archived`; the Storm Drum pushes at the round end instead of at turn ends. New: Earth
      Wall, Thorn Idol, Ember Brazier, Spike Trap, Vortex Trap and seven skills that place props (`raise_wall`,
      `set_idol`, `light_brazier`, `set_drum`, `set_urn`, `lay_spikes`, `lay_vortex`). Each of the nine kits carries one
      of them as a fifth slot (skills.md). A multi-square prop is a skill that places several one-square props.
    - *Stamina:* measured as a switch in S029; the rule since 2026-11-15 (above).
    - *Board switches:* `wells` (Dragon Veins on the centre row), `map_props` (mirrored prop pairs at the start,
      -1 = layout) and `map_buttons` (mirrored pairs of "button" squares, user idea 2026-11-15: the walkable experiment runes Moss Rune (Mossbed 3×3), Bog Rune (Bog zone around it) and Wall Rune (Earth Walls on its cardinal neighbours) act on the board without damage when a monster collects them, 0 = none); the draft screen has number fields for all three and for the Stamina per round.
  - **Content:** the in-game pool is status-filtered, not a fixed nine-monster catalogue; it includes the user
    user-built skills (none at present; `new_skill` and `asdf` were deleted on 2026-11-15). Spread authored stats and kits live in `data/`; `vigor`, `sap` and
    `tempo` (AP and turns), Battle Trance and Time Split are experiments. Retired records are `archived`.
  - **Normal versus trial defaults:** in-game ZONE skills carrying PUSH/PULL (including mixed effects such as Bog)
    currently cost 1 AP. The tools' 2-AP candidate and discovery's `single_vein` map are not adopted game defaults;
    normal 7×7 remains three veins. These switches do not set monster AP. See [tools](tools/README.md#commands).
- **Still in the code, unused by the game** (to be removed, temp_todo I56/I57): height and Mountains, the air layer,
  Surges and their marker traps (`PendingSurge`, the Surge fields of `BattleSkillDef`), the `shield` / `mend` / `expose` effects,
  and the switches that belong to them (`surge_fair`, `surge_at_caster`, `surge_wall`, `surge_ground`, `trap_cap`,
  `trap_rounds`, `no_shield_zones`). Tests that build these by hand still run.
- **Overview and skill builder:** `game/overview.gd` has six tables (skills as cards, monsters, grounds, zones,
  board sheets, props) with one row per Resource under `data/`. **In game only** excludes `test`, `simulation` and `archived`; the checkbox is initially off, so these records can still appear in the unfiltered debug overview. Its button **Skill builder** (`game/skill_builder.gd`) builds a
  skill from the parts of the card or draws a random one, saves it to `data/skills/<id>.tres` with the status
  `experiment` and can write it into a kit slot of a monster file. Writing needs the project to run from its folder;
  nothing checks a price.
- **Monster builder** (`game/monster_builder.gd`; button in the draft sandbox and in the overview): create a monster or
  change one (name, Kin, six stats, six kit slots), saved to `data/monsters/<id>.tres` (new ones with the status
  `experiment`) and registered in `BattleContent` and `GameData` (`GameData.register`), so it stands in the team choice at
  once. “New skill” opens the skill builder, which returns to the caller (`SkillBuilder.return_scene`). No price, budget
  or Kin access is checked. Changing an existing monster rewrites its file: Git is the way back.
- **Test switches** (`battle/core/battle_experiment.gd`, set by `sim.gd --variant` and partly in the draft screen;
  none is a rule): `delay_turn` with `delay_reverse` / `delay_first_round` (postponing a turn), `damage_from_round`
  (a calm first round), `start_back` (back-row starts), `push_steps`, `kin_push`, `no_rotation`, `step_ap` / `jab_ap` /
  `move_ap`, `soft_pressure`, the switches of S025–S030 (`zone_cast_push`, `once_per_turn`, `vein_touch`, `collision_both`,
  `vein_charge`, `vein_charge_late`, `step_full_move`, `stamina` / `stamina_regen` / `stamina_ap`, `map_props`, `map_buttons`, `board_size`; also check boxes and number fields in the draft screen, whose rows wrap, a charged or empty vein is labelled on the board), and the AI switches `ai_hunt`, `ai_hunt_behind`, `ai_careful`, `ai_aggressive`,
  `ai_no_kind`. Tests: `tests/battle/test_battle_experiment.gd`.
- **Kit switches** (draft check boxes; `tests/battle/test_kit_draw.gd`): **Random kits** (`random_kits`) gives every
  monster of a battle a random kit instead of its own. Each monster draws a kit template (`KitDraw.TEMPLATES`:
  Balanced, Bruiser, Skirmisher, Controller, Trapper, Shaper) that names no skill, only how many Strikes, movement,
  zone, ground and prop skills the six slots hold; the skills are drawn from the game's own. **New skills every
  battle** (`fresh_skills`) builds those kits from skills generated for the battle (`SkillGen.draw_kind`), in memory
  only; their AP come from the draft skill calculation. `kit_seed` is drawn anew for every start from the draft, so
  “Fight Again” repeats the kits. The arranged free shapes of the draft are not used with a kit switch. **AI tries
  every skill** (`ai_try_all`): the opponent prefers a skill it has not used yet in the battle (`AiBrain.TRY_BONUS`).
- **Ideas of 2026-11-16, built to try and to measure (no rules; [T43](../docs/todo/to-clarify/battle/T43-try-the-ideas-of-2026-11-16.md)):**
    - *Stamina base cost* (`stamina_base`, draft number field): a movement skill costs that much Stamina per use on top
      of the squares.
    - *Props bury traps* (`trap_defuse`, draft check box): a solid prop created on or pushed onto a trap removes it
      unsprung (event `trap_defused`).
    - *Experiment content* (status `experiment`, in no kit; the skill builder and the generated skills can use it):
      ground **Shifting Sand** (`GroundDef.no_props`: no prop can be on it; one standing there or pushed onto it breaks),
      ground **Springwater** (ground trigger kind `stamina`: +1 Stamina on entering), zone **Erosion**
      (`FieldEffect.ERODE`: props in it take 1 at the round end, with the other things that act), zone **Updraft** and
      the self buff **Deep Breath** (`FieldEffect.REFRESH`: more Stamina recovered at the round end).
- **Battle log:** every damage line names its source (“Jab by Gloom Wolf −2”, “Lava (ground) −1”); the line of a defeat
  names the hit that did it and what else the monster took in that round (`BattleText.defeat_line`). A fallen monster
  gets a button above the log that opens everything that changed its HP (`BattleText.hp_history`, `BattleHud.add_fallen`).
- **Skill calculation (draft)** (`battle/defs/skill_calc.gd`, [skills.md §7](../docs/skills.md#7-value-and-prices)):
  every part of a skill card has a price in points, 10 points pay for 1 AP. No rule reads it; the skill builder and
  the Points column of the overview show it, and generated skills take their AP from it. The prices are fitted to
  bot runs of `tools/skill_impact.gd` and are not approved.
- **Not built:** Dragon Veins on the 1v1 and 2v2 boards; slot development (skills.md); one line class for
  ground, zone and prop records (they are read as one sheet, stored as three); the rename of the stat fields
  `movement` / `move` to Stamina; an editor for the opponent's free shapes (the AI plays the defaults). `MonsterDef.reference_shape` and the overworld `StatShape` still name the six earlier
  stat shapes.
- **Removed:** the legacy skill model of the overworld (`SkillDef`, `ZoneDef`, skill evolution at the Evolution Pillar).

## Execution and validation boundaries

Full CPU use is authorized as of 2026-11-14. Invoke Godot directly with normal process/CPU settings; no code
change is needed. The optional [low-load launcher](tools/README.md#cpu-use-and-optional-low-load-launcher)
deliberately restricts CPU availability. Permission does not imply automatic parallelism or 100% use of every CPU.

`progression.gd` tests an entry action-economy proxy; `discovery.gd` retains authored stats, AP and TPR. Both use
matched teams with complete side swaps and source/completion guards. These are harness safeguards, not approval
of starts, upgrades, content, prices or fun. A usable active skill or budget fit does not establish viable starting
monsters or meaningful upgrade alternatives; owners are [monsters.md §2.2](../docs/monsters.md#22-prices-and-points)
and [skills.md §7](../docs/skills.md#7-value-and-prices)/[skills.md §8](../docs/skills.md#8-slot-development), with validation under [T13](../docs/temp_todo.md).

Latest executed checks (2026-11-15, normal CPU settings, on a copy of the working tree): the full suite ran
**355 cases**, including all **210 passing Battle cases** and the 7 of `tests/game`. Two known non-Battle cases
still fail: reference individual stats and roamer movement (I46 in [temp_todo.md](../docs/temp_todo.md)); the suite
is not green. Focused harness self-tests: `progression.gd` **1262 passed / 0 failed**, `discovery.gd`
**7296 passed / 0 failed**, including 37 real-action fixtures. `tools/smoke_ui.gd` played 3v3 through the real UI on
7×7, 8×8 and 9×9 without a refused click; the overview, draft and builder scenes load headless without errors.
The user plays every iteration by hand; the checks above are not gameplay acceptance. Historical simulation reports retain
their original execution settings and results.

## Running the checks

```
godot --headless --path godot --import
godot --headless --path godot -s -d res://addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -c -a res://tests < /dev/null
godot --headless --path godot -s res://tools/smoke_ui.gd -- 3v3 7      # draft → placement → battle through the real UI
godot --headless --path godot -s res://tools/sim.gd -- 20 3v3 1 "<state>"   # AI vs AI; prints a run block for docs/simulation_log.md
godot --headless --path godot -s res://tools/compare.gd -- --bot rush                             # two monsters, side-swapped
```

Options, test monsters, bots and the limits of these runs: [tools/README.md](tools/README.md). None of them is a balance test.
