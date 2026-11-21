# Road of the Beasts — Godot project

```
shared/      data schemas and the cultivation model, used by every part
             MonsterDef (species, reference stats and kit in one file), Shapes, Aspect (look and materials only),
             Stage, StatShape, MonsterInstance (the individual monster), ItemCatalog,
             BattleRequest / BattleResult (the contract between battle and overworld), GameData (registry), UiTheme
battle/      the deterministic grid battle (docs/battle.md, skills.md, monsters.md)
  defs/      DEFINITIONS — pure data Resources and tables, no rules
             FieldEffect, GroundDef + GroundTrigger, PropDef + PropAftermath, BattleZoneDef, BattleSkillDef + BoardOp,
             TamerSkillDef, UnitSheet, ContentStatus,
             BattleShapes (the one shape vocabulary), Moment (the moments and the roles of ground, zone and prop),
             BoardSheet (reads ground, zones and props as one sheet),
             BattleContent (registry of data/)
  core/      STATE and RULES — headless, no nodes, no randomness
             state:  Battle, Board, BoardCell, BoardProp, BoardZone, PendingSurge, BattleUnit
             rules:  BattleStats (effective stats, modifiers), BattleQueue (pace), BattleMoves (movement
                     profiles), BattleCasting (placement), BattleDamage (damage law, ground triggers),
                     BattleDisplace (push / pull, collision, fall), BattleBoardOps (zones, ground, height, props),
                     BattlePayload (the §6.2 resolution order), BattleTurn (turn / round flow), BattleTamer, BattleCatch (Seal Ground, ingame)
             setup:  BattleSetup (BattleRequest → Battle → BattleResult), BattleBoards (layouts), UnitSheets
                     (adapter: overworld individual → finished unit sheet)
             AiBrain (an opponent that only uses the public battle API)
  view/      PRESENTATION — 3D board (BattleView) and the input controller
  ui/        battle HUD, BattleText (datasheets, log, previews), the draft sandbox and ShapeEditor (free shapes before a battle)
  battle.tscn, draft.tscn
overworld/   the hub game around the battle (docs/vision.md, docs/overworld.md): see "The hub game" below
  core/      headless logic: GameState (day, day AP, lifespan, stage, roster, items; saved as a dictionary),
             GameValues + CultivationDef (the classes of the data under data/game and data/cultivation),
             WildArea, DungeonRun, VoidPlace (the three places), Places (reads a result back), Fight (a battle
             the hub asks for, as plain data), Cultivation (the tree, building parts), Crafting (alchemy and
             smithing), Materials (item ids and names), Cheats
  ui/        HubScreen (head, buildings, the screen that prepares a fight), one panel per building
             (panel_*.gd), NewGameScreen, GameOverScreen, HubUi (builders sized for a finger)
  hub.tscn, new_game.tscn, game_over.tscn
game/        glue: main menu, settings, SaveGame (one slot; what a finished game leaves is kept apart),
             autoloads (GameSettings, GameSession, CheatMenu), FightBridge (a Fight → BattleRequest), MapData
             (a battleground as plain data for the save), Overview (debug tables of content with an optional
             in-game-only filter, reached from the main menu)
data/        ALL content as Resource files, one folder per kind (a new file = new content)
             game/values.tres (every test value of the hub game), cultivation/ (the systems and their trees),
             maps/ (battlegrounds: six test battlegrounds of the places)
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
Battle and overworld **never import each other**: the overworld describes a battle as a `Fight` (plain data),
`game/FightBridge` turns it into a `BattleRequest`, the battle returns a `BattleResult` — request and result
live in `shared/`. The overworld reaches battlegrounds, the map editor and the names of board parts only through
the autoload `GameSession`. `game/` is the only place
that knows both halves (menu, `GameSession`, saves). `shared/` no longer depends on `battle/core`.

## The hub game

Main menu → New Game: choose a cultivation system and one of three eggs, then the hub. Continue loads the one save.
The hub shows the day, the day AP, the stage and the lifespan; a building opens its panel. A fight is prepared on
one screen (battleground, opponents, team, tamer slots) and fought in the battle scene; the hub reads the result.

| Building | What works |
|---|---|
| Nest | the roster and its order, release, eggs with their nights |
| Wild Gate | today's encounters per zone (one zone per stage reached), a battle for day AP at full HP, XP, a beast part per monster killed, catching on Seal Ground, eggs, a rare encounter that is announced and stays |
| Dungeon Gate | a run for all day AP of a full day: a generated map of nodes with forks and a rest node, HP stay, healing pills between battles, leaving keeps the loot, a defeat keeps a share, the last battle gives the breakthrough material and an essence; a challenge per dungeon, then the harvest without a battle |
| Training Ground | spending the stat points of each step (the prices of docs/monsters.md §2.2) |
| Scripture Hall | the kit and the development level of each slot (a level has no effect in a battle) |
| Cauldron | brewing two or three plants, properties drawn per game and found by trying; pills that reshape, raise the rarity or heal in a dungeon |
| Forge | forging a weapon or an armour from ore, a beast part and an optional essence; an armour is worn by a monster (no effect in a battle) |
| Void Gate | the depths of the stage on the player's own battleground, a path point per depth, the last depth as the breakthrough trial; forced at the end of the lifespan, and lost then the game is lost |
| Cultivation Hall | the tree of the system, a tree per stage: tamer skills and blueprints for path points |
| Battleground Workshop | building parts from blueprints and materials; the map editor on the own battleground with owned parts, a budget, a size range and a reachable start area of the opponent |

**Test values.** Every number of the hub game lies in `data/game/values.tres` (class `GameValues`, one comment per
field), the systems in `data/cultivation/`. None is a rule: the rule files say "not defined" for each (tasks T54–T60).
The values are chosen so that one stage can be played in about half an hour: 3 day AP and 8 days of lifespan at the
first stage, 4 encounters a day, a dungeon of 6 battle nodes and a rest of which a run passes 4, 3 depths of the
void, 1 breakthrough material for the trial, 30 XP per win against 60 for the first step.

**Solutions chosen without a rule** are listed in [docs/todo/implementation.md](../docs/todo/implementation.md)
("Hub Game"). **Not built:** pills and weapons in a battle, the effect of an armour and of a development level,
the relearning pill, what a finished game leaves for the next one (the games are only counted), ends of a battle
other than 0 HP, board events, content beyond the first two stages (later stages reuse it; the trees end at
Foundation), an Android export.

**Cheat menu:** the action `toggle_cheats` or the button in the bottom-right corner: refill day AP, change the
lifespan, XP, path points, materials.

## Battle architecture

| Layer | Where | Rule |
|-------|-------|------|
| Definitions | `battle/defs`, `data/*.tres` | Data only. A definition never contains resolution code. |
| State | `Battle` + `Board*`, `BattleUnit`, `PendingSurge` | Plain data; `Battle.clone()` copies it, `snapshot()` / `state_hash()` describe it. |
| Rules | `battle/core/battle_*.gd` | Static functions on a `Battle`. No nodes, time, frames or UI state. |
| Presentation | `battle/view`, `battle/ui` | Calls `Battle.check` / `preview` / `apply`, reads state and `events`. Decides nothing. |

- **One entry point:** every change is an action Dictionary passed to `Battle.apply()` (`step`, `skill`, `end_turn`,
  `tamer`); `Battle.check()` says why an action is illegal and never changes state.
- **Determinism:** the rules contain no randomness but the seeded catch roll of the ingame battle (`BattleCatch`,
  `Battle.roll_seed` / `rolls`; dry runs never roll, so previews and the AI see only the chance). Same start state + same content (`BattleContent.VERSION` /
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

Unique mechanics stay local: tamer skills in `BattleTamer`, late-round
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
    takes 1 (`flank`). An owned vein deals 2 from round 3 on (`vein_late_round`, `vein_late_damage`). There is no late-round pressure (`pressure_mode` = `none`).
  - **Working values:** highest hit 2 (HP runs from 1 to 10; the monster builder offers the ranges of monsters.md); ground laid in battle lasts 2 rounds (`ground_rounds`); a
    Strike pushes 1 if its record says so (`strike_push`, on by default); the board edge deals 1 and a spiky prop 2 to a monster moved into it; Step 1 AP, Run 1 AP; authored movement costs vary (including user experiments), with the reference
    non-Run movement skills at 2 AP (plus Stamina, below); extra turns count from round 2 (`tpr_from_round`); push and
    pull zones move only at the end of their occupant's turn, not at cast (rule since 2026-11-14, S025); everyone may rotate a placed shape; a push zone left by a skill that also creates
    something else points where the placement is turned (`BattleCasting.rot_dir`).
  - **Build since 2026-11-15 (user decisions of that day; S030; docs/temp_todo.md handoff and T41):**
    - *Pace:* the stat Initiative is called Pace everywhere (`pace`, `drain_pace`, `pace_bonus`). Scale: base 1.0, a
      stat point is 0.1 (`BattleStats.PACE_POINT`); `quicken` / `drain_pace` values count in points (a drain point double since 2026-11-18, `BattleStats.DRAIN_FACTOR`); an extra-turn entry
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
    - *Board switches:* `board_size` (draft number field **Board size** beside the other board values: 7 = the board of the mode, 8 or 9; `sim.gd --variant size=N`):
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
      `compare.gd`, `progression.gd`, `discovery.gd`); length target: a mean of 3.5–4.5 rounds.
  - **Build since 2026-11-14 (user decisions and drafts of that day; S028/S029; docs/temp_todo.md T40):**
    - *Decided:* every slotted skill at most `usage_limit` times per turn of its monster (1 unless the record says
      more; no switch since 2026-11-17, only older rule tests turn `once_per_turn` off) and up to 6 kit slots (the nine kits hold 6 since 2026-11-15: skills.md).
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
  Surges and their marker traps (`PendingSurge`, the Surge fields of `BattleSkillDef`), the `shield` / `mend` / `expose` effects. Tests that build these by hand still run.
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
- **Two battles** (docs/battle_ingame.md §1): the main menu button “Battle” opens `battle/battle_menu.tscn` with
  “Ingame Prototype” and “Multiplayer” (the draft, `battle/draft.tscn`). The ingame prototype
  (`battle/ingame/ingame_prototype.gd`) is a test battle without the overworld: points per side from 25 to 110 in
  steps of 5 with the stage they stand for, a board size, 1v1 / 2v2 / 3v3 on the generated boards of `BattleBoards`
  (1v1 5×5, 2v2 6×6, 3v3 7×7; a test tool only: every board of the game is a battleground, docs/battle_ingame.md §2). It writes a `BattleRequest` with
  `battle_kind` `ingame`, `side_points` and `draw_seed`; `BattleSetup` then draws every monster for the points of its
  side up to the ranges of the sheet (`MonsterDraw.INGAME_TOP`: AP 5, three turns) with a kit of generated skills.
  The screen resets `BattleExperiment` to the build defaults, so no switch of the draft carries over. It has no
  battlegrounds, board events or skills of its own yet (docs/todo T46). The existing folders are not sorted into
  `battle/multiplayer/` and `battle/ingame/` yet; that is part of the rebuild (docs/architecture.md §2).
  Tests: `tests/battle/test_ingame_prototype.gd`.
- **Catching in the ingame prototype** (docs/battle_ingame.md §7; `battle/core/battle_catch.gd`): the prototype screen
  has “Enemy: wild (no tamer)” (on by default) and “Your seal” (none, the Seal skill 50 %, or a Normal / Rare / Epic /
  Legendary seal item 20 / 35 / 50 / 65 %); `IngamePrototype.add_catching` writes `BattleRequest.enemy_wild`,
  `player_tamer` and `roll_seed`. In the battle the seal stands in the tamer panel: click a square to lay Seal Ground
  (ground `data/grounds/seal.tres`, immutable, no fade; not on a Dragon Vein or other immutable ground; one per
  tamer at a time, `Battle.seals`). A wild monster that ends its turn on enemy Seal Ground is rolled for
  (`seal_base` − `BattleExperiment.seal_step` × (HP − 1)); one that falls to 0 HP there is caught; a wild monster
  falling elsewhere dies (`BattleUnit.caught` / `died`, also in `BattleResult`). The square label and the unit card
  show the chance; the log shows the roll. Records: `data/tamer/seal.tres`, `seal_normal … seal_legendary.tres`
  (`TamerSkillDef.seal_base`, `seal_item`). Not built: upgrades of the Seal skill, a wild AI that avoids Seal Ground,
  items as a loadout of their own (an item is a loadout entry like a tamer skill). Tests:
  `tests/battle/test_battle_catch.gd`.
- **Map editor and custom maps** (`battle/ingame/map_editor.gd`, scene `map_editor.tscn`, reached from the ingame
  prototype; docs/battle_ingame.md §3): makes a battleground and saves it as a `MapDef`
  (`battle/defs/map_def.gd`) under `data/maps/<id>.tres`. Width and height from 3 to 12; tools, by click or drag:
  Ground, Dragon Vein, Prop, Zone (with direction and rounds, 0 = the whole battle), the start areas of both
  sides, Remove / Restore square, Clear square (`MapEditor.paint`). The message line says what keeps a map from
  being played (`MapDef.problems`). In the ingame prototype the row “Map” picks a saved map, “Your monsters” and
  “Enemy monsters” set the team sizes (they may differ), “Battle on the map” starts. In the battle
  (`BattleRequest.map`, `BattleBoards.build_map`): the rectangle sits in the middle of a square grid and every
  other square is in `Board.missing`, which `Board.in_bounds` treats as off the board; start areas are
  `Battle.start_areas` (`BattleBoards.may_start`), the default places are spread over the area
  (`BattleBoards.spread`) and the player rearranges theirs in the placement phase; a zone that lasts the whole
  battle has the duration `BoardZone.WHOLE_BATTLE`. The opponent AI reads the Dragon Veins from the board now
  (`Board.veins`), not from the fixed squares of a board size. Not built: tamer skills, board events, a way to
  delete a map in the editor (delete the file), 2×2 bodies on maps. Tests: `tests/battle/test_custom_map.gd`.
- **Multiplayer start screen** (`battle/ui/draft_screen.gd`, scene `battle/draft.tscn`; docs/battle.md §1): always
  3v3 on a generated, point-symmetric 7×7 board, without tamer skills and without fixed monsters or skills. Nothing
  is picked: `request()` writes a `BattleRequest` with a `draw_seed`, and `BattleSetup` then draws every monster for
  the 60 points (`MonsterDraw`) with a kit of skills generated for the battle (`KitDraw`); the species is only the
  look. Two start buttons: “Random monsters for both sides” (every monster drawn on its own) and “Same monsters
  for both sides” (`mirror_draw`: monster 1, 2 and 3 of both sides have the same stats, Kin and kit). The monster cards, “Arrange shapes”, the three random check boxes, the
  start buttons for 1v1 and 2v2 and the tamer test loadout are gone. The alternating draft of monsters and skills is
  not built here (docs/todo T48). The monster builder still saves monsters, but this screen fields none of them.
  `BattleExperiment.random_monsters`, `random_kits` and `fresh_skills` remain for `sim.gd` only. `ShapeEditor` is
  used by no screen any more (its checks are still tested).
- **Content of the multiplayer battle** (docs/content.md §1, §2): `GroundDef.battle` and `BattleZoneDef.battle` say
  whether a record belongs to both battles, to the multiplayer battle or to the ingame battle. The multiplayer
  records are named by what they do: `data/grounds/entry_damage … stay_stamina` (three moments × damage, heal,
  Stamina), `no_prop`, and `data/zones/push_zone`, `pull_zone`, `prop_damage_zone`. `SkillGen.ground_ids` and
  `zone_ids` (generated skills, skill builder, overview tab Generator) use no record of the ingame battle; Lava,
  Thornbed, Mossbed, Binding Vines, Springwater, Shifting Sand, Gale, Void Pull and Erosion are ingame records.
  Generated Strikes are called “<shape> Push Strike”, “<shape> Prop Strike” or “<shape> Touch”, and the generator
  makes no Strike that does nothing. Drawn monsters are called Random Alpha, Beta, … (`MonsterDraw.LETTERS`). The
  draft prices of the new records copy those of the old ones with the same effect; the others use the default.
  Tests: `tests/battle/test_multiplayer_content.gd`. Not built: a Strike that pulls.
- **Test switches** (`battle/core/battle_experiment.gd`, set by `sim.gd --variant` and partly in the draft screen;
  none is a rule): `damage_from_round` 2
  (a calm first round; the rule and build default is 1: damage from round 1), `start_back` (back-row starts), `no_rotation`, `soft_pressure`, the switches of S025–S030 (`vein_touch`, `stamina_regen`, `map_props`, `map_buttons`, `board_size`; also check boxes and number fields in the draft screen, whose rows wrap, a charged or empty vein is labelled on the board), and the AI switches `ai_hunt`, `ai_hunt_behind`, `ai_careful`, `ai_aggressive`,
  `ai_no_kind`. Tests: `tests/battle/test_battle_experiment.gd`.
- **Heal** (rule since 2026-11-18, docs/battle.md §2.4; no switch): an action every monster has beside Step and
  the Basic Jab (`{type: &"heal"}`, `Battle.heal_error`, HUD button under Wait, Input Map action `battle_heal`). It
  costs 3 Stamina from the pool and no AP and gives 1 HP back, once per turn (`Battle.HEAL_STAMINA`, `HEAL_HP`). The
  opponent AI lists it whenever it is legal and gives Stamina in the pool no worth; a full `sim.gd` block prints the
  Heal uses. In the action bar Wait stands over Heal and End Turn to their right, as high as both.
  Tests: `tests/battle/test_stamina_heal.gd`.
- **Kit switches** (for `sim.gd` and tests; the battle screens draw through the request instead; `tests/battle/test_kit_draw.gd`): **Random kits** (`random_kits`) gives every
  monster of a battle a random kit instead of its own. Each monster draws a kit template (`KitDraw.TEMPLATES`:
  Balanced, Bruiser, Skirmisher, Controller, Trapper, Shaper) that names no skill, only how many Strikes, movement,
  zone, ground and prop skills the six slots hold; the skills are drawn from the game's own. **New skills every
  battle** (`fresh_skills`) builds those kits from skills generated for the battle (`SkillGen.draw_kind`), in memory
  only; their AP come from the draft skill calculation. `kit_seed` is drawn anew for every start from the draft, so
  “Fight Again” repeats the kits. The arranged free shapes of the draft are not used with a kit switch. **Random monsters** (`random_monsters`, `battle/defs/monster_draw.gd`):
  every monster of the battle gets random stats and a random Kin, bought with the monster calculation
  (`MonsterDef.points_of`) for the 60 points of the multiplayer mode: at least HP 3, Stamina 2, Reach 2 and AP 2, at
  most HP 10, Pace 4.0, Stamina 8, Reach 4, AP 4 and two turns; the species picked is only the look, the name becomes
  “Random <Kin>”. It implies random kits and is drawn by `kit_seed`, so “Fight Again” repeats the monsters. The draft checks
  the three random switches the first time it opens (`DraftScreen._opened`; user, 2026-11-17); a battle started elsewhere, the
  tests and the tools play the monsters as they are. **The AI tries every skill** (no switch): the opponent prefers a skill it has not used yet in the battle (`AiBrain.TRY_BONUS`).
- **The AI fights for Dragon Veins** (no switch since 2026-11-17; user, 2026-11-16): `AiBrain._vein_score`
  values an owned vein (`VEIN_OWNED`), a solid prop on an owned vein (`VEIN_LOCK`), every square the nearest enemy
  needs to reach an owned vein (`VEIN_GUARD`, walls and bodies count) and pulls its nearest monster to veins it does
  not own (`VEIN_PULL`); placements on and next to veins are candidates. In the game (`AiBrain.decide` with
  `lookahead`, bot `game` of `tools/sim.gd`) the best first actions are judged with the best second action of the
  turn (step off a vein, then lock it).
- **Rules since 2026-11-17 (user decisions; written into battle.md, skills.md and monsters.md; no switch any more):**
    - *Strikes:* a Strike of the kit deals no damage to monsters (`BattleSkillDef.monster_damage()`, `push_only()`);
      it pushes, and what its card names as damage hits props (`hits_props()`, 2 per prop). Every monster has the
      **Basic Jab** (2 AP, 1 damage, no push, once a turn) as an action beside Step, not as a kit slot: the action
      `{type: &"skill", slot: Battle.BASIC_SLOT, dir}`, a button of its own next to Step. Step costs 1 AP.
    - *Strike push:* every monster and prop a Strike struck is pushed, also on the farther squares of an extended
      shape, along the line of its square (`BattlePayload._push_dir`).
    - *Kin:* the Kin of the striker adds nothing to a Strike; the table of the former effects, the push direction
      of an action and the skill flag `kin_effect` are removed.
    - *Zones:* a zone only pushes or pulls and has one level (`BattleStats.contributions`,
      `BattleBoardOps.zone_outcome`). The zones Mire, Slowing, Tailwind, Updraft, Bog and Shockwave are `archived`.
    - *Ground:* one level; laying it again restarts its clock (result `refresh`). Blight is `archived`; Gloom Rift
      and Coiling Rift lay Lava instead.
    - *Round end:* nothing but Dragon Veins and surrounding deals damage there. The damage line of a prop (Ember
      Brazier) hits a monster that ends its turn inside the prop's shape (`BattleProps.turn_end_hits`); pushes of
      round-end props (Storm Drum) stay at the round end.
    - *Created props:* a prop a skill creates lapses without effect after two rounds (`BoardProp.CREATED_ROUNDS`,
      `BoardProp.until`, event `prop_lapsed`); props of the board stay.
    - *Removed with their switches:* a kit slot once per round, “a movement skill or a Strike in a turn”, Stamina on
      Strikes, the Stamina base cost of movement, charged Dragon Veins, zone push at cast, Wait in round 1 only, a Wait
      once a round for everyone, collision damage for the moved monster only, a Step that walks the full movement and
      the switches of Surges and Surge traps (`surge_fair` is always on, one trap per trap skill). The Surge code
      itself, the levels in `BoardCell.level` and the price entries of archived records in `skill_calc.gd` are
      still there, unused.
    - *Pace:* Wait is bought with Pace: a monster may postpone its turn as often per battle as the whole number of
      its current Pace lies above 1 (`Battle.waits_total`, `waits_left`; button **Wait** beside End Turn, which shows
      what is left); those that waited act in reverse order. The Dragon Veins act one after another
      (`BattleTurn._veins_in_order`), the vein of the faster taker first (`BoardCell.owner_unit`: the monster that
      took it; a fallen taker's vein last), defeats after each; surrounding acts before them. The board names the
      taker and its Pace under an owned vein.
    - *Traps:* a solid prop created on or pushed onto a trap springs it and takes its square
      (`BattleBoardOps.spring_at`, event `trap_sprung` with `by`); what the trap does runs once the prop stands there.
- **Settled for now (user, 2026-11-18; [T44](../docs/todo/done/battle/T44-review-pack-of-2026-11-17.md), docs/battle.md):**
  the multiplayer battle as built. The draft has no check box for these any more; the switches stay in
  `BattleExperiment` for the tools and tests. `--variant x.<switch>=<value>` sets any switch by its name. Tests:
  `tests/battle/test_review_pack.gd`. `tools/discovery.gd` and `tools/progression.gd` were not run against these rules.
    - `vein_touch` true: last touch owns a Dragon Vein.
    - `damage_from_round` 1: damage from round 1.
    - `vein_late_round` 3, `vein_late_damage` 2: an owned Dragon Vein deals 2 from round 3 on (S039 measured 5, 4
      and 3). The round is still a board value of the draft (**Veins deal 2 from round**, 0 = never).
    - `pressure_mode` “none”: no late-round pressure. `BattleExperiment.pack(false)` plays the rules before (veins
      always 1, pressure while nobody owns a vein): `tests/battle/helpers.gd rule_strikes` for the older rule tests,
      `sim.gd --variant nopack` to compare.
    - `free_camera` true: a middle-mouse drag turns the camera and tilts it up and down, between 15° and 88°
      (`BattleView._pitch_target`).
    - **Round-end forecast** (no switch): under the queue the HUD always shows what the round end would do on the
      board as it stands, who is hit by what and who falls (`BattleTurn.round_end_forecast`, a dry run on a copy).
    - *Experiment content* (status `experiment`, in no kit; the skill builder and the generated skills can use it):
      ground **Shifting Sand** (`GroundDef.no_props`), ground **Springwater** (+1 Stamina on entering), zone
      **Erosion** (`FieldEffect.ERODE`: props in it take 1 at the round end) and the self buff **Deep Breath**
      (`FieldEffect.REFRESH`: more Stamina recovered at the round end).
- **Rules of this battle** (pause menu of the battle screen, `BattleHud._show_rules`): a window with every switch
  of `BattleExperiment`, first what differs from the build default, then the defaults in use
  (`BattleExperiment.settings_lines`); the text can be copied. `sim.gd` prints the same two lists with every run block.
- **Changes of 2026-11-17 (user decisions, written into the rule files):** `slow` and `haste` change the Stamina a
  movement skill costs per use (`BattleMoves.use_cost`), no longer its range; straight-line movement has four
  directions unless its card allows diagonals; the squares of a free shape touch over an edge or a corner; generated Strikes reach 1 or 2 squares.
  A movement skill may allow
  diagonal lines on its card (`BattleSkillDef.move_diagonal`; the generator gives it to one line in four, the draft
  price list holds an unmeasured price for it).
  The Ancient Kin text “breaks Mountain” is gone from the card (Mountains were removed on 2026-11-13).
- **Skill card** (`BattleText.skill_rows`, user request 2026-11-17): every skill is shown as the same small table,
  rows in a fixed order and left out when empty: **Cost** (AP, Stamina, uses), **Where** (shape or path and range),
  **Does** (damage, push, Kin effect, effect on the user), **Creates** (one row per ground, zone or prop and below
  it what that thing does; **Leaves** for a movement). Step and the Basic Jab use the same table; the overview and
  the builders print the same rows.
- **Input Map (user rule 2026-11-17):** every key and mouse button is an action in `project.godot` (`battle_select`,
  `battle_rotate`, `battle_aim_north/south/west/east`, `battle_step`, `battle_skill_1`–`6`, `battle_confirm`,
  `battle_cancel`, `battle_glossary`, `camera_turn_left/right`, `camera_zoom_in/out`, `camera_drag`,
  `toggle_fullscreen`, `toggle_cheats`, `walk_up/down/left/right`, `interact`, `build_toggle`, `build_rotate`,
  `build_place`, `build_pick_up`). No code asks for a key; hints and buttons read the key name from the map
  (`UiTheme.key_text`).
- **Compass (user request 2026-11-17):** N, E, S and W stand beside the middle of each board edge
  (`BattleView._make_compass`; north = y − 1, east = x + 1, as `BattleText.DIR_NAMES`). Hovering a square of a push
  or pull zone names where it moves a monster there (“here: push north”, “here: pull east (to centre)”,
  `BattleText.zone_way`), and the log names the direction of every push and pull (“Wolf west → [2,4]”).
- **Generator table (user request 2026-11-17):** the overview opens on the tab **Generator**
  (`Overview.generator_rows`): how a random skill is built, every part with what it can be, then what the grounds,
  zones and props of the pool can do, in general terms and without names. It reads the lists of `SkillGen`
  (`STRIKE_DAMAGE`, `MOVE_PATHS`, …, the same lists `draw_kind` draws from) and the records of the pool, and marks
  what a test switch turns off. New Strike part: **damages props** yes or no (`BattleSkillDef.strike_props`: -1 =
  as the rule, follows the damage; 0 = spares props; 1 = damages them also without damage to monsters); the
  generator draws it, the card shows it.
- **Kinds, terms and glossary (user requests 2026-11-17):** every action button carries the kind of its skill as a
  word and a coloured stripe (`BattleText.KINDS`: Strike, Move, Ground, Zone, Prop, Self, Passive;
  `BattleHud._kind_stripe`) and the card starts with a **Kind** row. Cards and the square inspector use terms only
  (a prop: `solid · heavy · spiky`, then one line per thing it does, then when it lapses; `BattleText.prop_lines`);
  every term is explained once in the **Glossary** (pause menu or key G; `BattleText.GLOSSARY`). A movement card
  has a row **Passes**: what the movement passes over and whether every square on the way counts or only the
  landing square. Why a skill cannot be used now stands in red over the whole width of the card. The centre square
  of a pull zone is labelled on the board. Layout to try: Step over the Basic Jab, End Turn over Wait.
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
and [skills.md §7](../docs/skills.md#7-value-and-prices)/[skills.md §8](../docs/skills.md#8-development), with validation under [T13](../docs/temp_todo.md).

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
