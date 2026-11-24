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
  core/      headless logic: GameState (day, lifespan, stage, the Way, roster, items; saved as a dictionary),
             GameValues + CultivationDef (the classes of the data under data/game and data/cultivation),
             DungeonRun, VoidPlace (the two places), MapGen (generated battlegrounds), Places (reads a result
             back), Fight (a battle the hub asks for, as plain data), Cultivation (the tree), Crafting (alchemy,
             smithing, laying parts), Materials (item ids and names), Cheats
  ui/        HubScreen (head, buildings, the screen that prepares a fight), one panel per building
             (panel_*.gd), NewGameScreen, GameOverScreen, HubUi (builders sized for a finger)
  hub.tscn, new_game.tscn, game_over.tscn
game/        glue: main menu, settings, SaveGame (one slot; what a finished game leaves is kept apart),
             autoloads (GameSettings, GameSession, CheatMenu), FightBridge (a Fight → BattleRequest), MapData
             (a battleground as plain data for the save), Overview (debug tables of content with an optional
             in-game-only filter, reached from the main menu)
data/        ALL content as Resource files, one folder per kind (a new file = new content)
             game/values.tres (every test value of the hub game), cultivation/ (the systems and their trees),
             maps/ (six test battlegrounds for the prototype and the map editor)
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

Main menu → New Game: choose a Way, a gift of that Way and one of three eggs, then the hub. Continue loads the one
save (a save of the game before the wild is not read).
The hub shows the stage and the lifespan; a building opens its panel. **The lifespan is the one clock:** a battle of
the wild, a new look at the wild and an attack on the void cost a year each (`Wild`, `VoidPlace`,
`GameState.spend`); a deed is paid when its result is read back. There are no days and no day AP. A fight is
prepared on one screen (battleground, opponents, team, what the Way brings) and fought in the battle scene; the hub
reads the result (`Places.resolve`), and every battle starts at full HP.

**The three Ways** (`GameState.ARTIFICER`, `FORMATION`, `ALCHEMIST`; data in `data/cultivation/`): a game follows
one and has nothing of the other two. `HubScreen.panels` builds only the buildings of the Way. Nothing is made:
what a Way uses drops from the wild.

| Way | Building of its own | In a battle | A wild battle drops | Catches with |
|---|---|---|---|---|
| Artificer (the board) | Battleground Workshop | parts laid on the board before each battle of the wild (`Fight.parts`, `Crafting.lay`: as many as `GameState.carry`, on any square, not used up); in the void the own battleground. No tamer slots | units of one part, one per monster | Seal Ground as a part beside those carried (`Fight.SEAL_PART`, `BattleRequest.player_seals`) |
| Formation (the tamer) | — | tamer skills in the tamer slots | 1 Insight from 2 monsters or more | the Seal tamer skill, beside the slots |
| Alchemist (the monsters) | — | pills in the tamer slots | pills, one per monster | a Binding pill beside the slots (`data/tamer/pill_binding`); it starts with two |

| Building | What works |
|---|---|
| Monsters · Roster and eggs | the roster and its order, release, eggs with the battles until they hatch; the Kin trait of each monster; the rises a wild battle left, where the player has to choose |
| Monsters · Stats | spending the stat points of each step (the prices of docs/monsters.md §2.2); a monster fresh from the egg takes its points back until its first battle |
| Monsters · Skills and growth | the kit of each monster: 4 slots at the start, filled from what it can learn; the choice at a stage breakthrough (a new slot, a development step, Lore, Reshape: one of them); the development of each slot (below); with a relearning pill, another skill in a slot |
| Gates · Wild | the look: 3 battles, each with a generated battleground, its monsters with stage and sub-tier and its drop; a battle won leaves the look; a new look for a year; catching; by chance an egg |
| Gates · Void | the depths of the stage, one Insight per depth, the last depth as the breakthrough trial; forced at the end of the lifespan, and lost then the game is lost. The Sovereign beast: shown from the start, open to an attack at any time, the trial of Immortal; who defeats it has won the game |
| Cultivation Hall | the tree of the Way, a tree per stage: tamer skills (Formation) or perks (Artificer, Alchemist) for Insight; the boon of a breakthrough; the vows |
| Battleground Workshop *(Artificer)* | the map editor on the own battleground with the parts owned, a budget, a size range and a reachable start area of the opponent |
| Inventory | what the player owns: stage and Insight, monsters, pills; the Alchemist gives pills to monsters here |

**Growth without XP** (docs/monsters.md §5; `Wild.resolve`, `Wild.give`, `GameState.rise_in_void`,
`MonsterInstance.rise`): every enemy of a wild battle won leaves a rise for one monster of the team that stands
and is at its step or below, one step, never past High (`GameState.rises`, `MonsterInstance.may_rise`). Where the
rises reach for all they are given at once; else the player gives them under Monsters. A battle won in the void
lifts every monster that fought, also into the next stage, never past the tamer's.

**Skill development** (docs/skills.md §8; `battle/defs/skill_dev.gd`, `MonsterInstance.develop_slot`, `pick_option`,
`battle_skills`): a slot has a level of 1 to 3; a development step raises it and adds one option of the kind of
its skill (`SkillDev.options`: a Strike reaches further, damages props or leaves Thornbed; a movement goes 1 further,
passes over props or monsters, counts only its landing square, or pushes on landing; ground, zones and props take 1
square or 1 round more; a self buff 1 round or 1 value more). The battle gets a copy of the skill with the options
applied (`SkillDev.developed`, `UnitSheets.from_instance`); the record is never changed. When a slot takes another
skill (`Crafting.relearn`, the pill of Clarity) it keeps its level and the options are chosen anew. Wild monsters
spend their development steps at random. A Strike leaves Thornbed: a choice of the build, the rules name no ground.

**Generated battlegrounds** (`overworld/core/map_gen.gd`): every battle of the wild and of the void (for the
Formation and the Alchemist) is fought on a point-mirrored board of 5 to 7 squares a side with Dragon Veins on its
middle and mirrored pairs of ground, props and, from later stages, zones (`gen_*` in `values.tres`). The six test
battlegrounds of `data/maps/` belong to the prototype and the map editor only.

**Test values.** Every number of the hub game lies in `data/game/values.tres` (class `GameValues`, one comment per
field), the Ways in `data/cultivation/`. None is a rule (tasks T54–T65). 10 to 14 years of lifespan per stage, 1
year per deed, 3 battles per look with 1–2 up to 2–4 monsters by stage, 3 depths of the void, an egg after 2
battles, 2 parts carried and 1 more per stage, a tempering pill 1 stat point (5 per monster at most), three boons,
a Sovereign beast at Immortal High with 15 points more.

**Solutions chosen without a rule** are listed in [docs/todo/implementation.md](../docs/todo/implementation.md)
("Hub Game"). **Not built:** development steps of tamer skills, species skills, anything a finished game leaves
besides more species to draw eggs from, ends of a battle other than 0 HP, board events; the
trees of the Ways end at Nascent Soul.

**Kin traits in the battle.** A grown monster of the hub game carries the trait of its Kin as a passive without a
slot (`UnitSheet.innate`, built by `KinDef.passives` from the flags in `data/kins/<kin>.tres`). All eight act:
Follow-up, Aloft, Armoured, Scatter, Bodiless, Bulwark, Rooted Growth, Unmoored. A Kin has no further passives:
bloodlines and Kin gifts are gone. **No passive stops a push or a pull** (`BattleStats.is_immovable` reads the timed
effect `anchor` alone): the self buff Brace (`data/skills/brace.tres`, until the round ends) and the Anchoring pill.

**Species of the hub game.** Sixteen, two per Kin: the nine of the multiplayer battle and seven with
`hub_only = true`, which the multiplayer battle, the prototype and the tools never see (`GameData.monster_ids`; the
hub uses `GameData.species_ids`). Each has a `learnable` list of eight skills inside the four groups of its Kin;
`skills` stays the kit of the multiplayer battle. All lists are test content. Creatures of the void are met in the
void only, are never caught, and a passed trial leaves an egg of one.

**Pills in the battle.** A pill that acts in a battle is a `TamerSkillDef` in `data/tamer/` (`pill_*`) and is put
into a tamer slot on the screen that prepares a fight; it is used up after the battle.

**Vows.** Three are offered at the start and after every breakthrough, in the Cultivation Hall; one or none is
taken, at most three in a game. The fourteen vows are data (`vows` in `values.tres`: gain, price, effect keys the
code reads, and the Way a vow is offered in).

**Cheat menu:** the action `toggle_cheats` or the button in the bottom-right corner: change the lifespan and
Insight, a step or a stage for the monsters, the next stage for the tamer, the drop of a wild battle.

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
  “Ingame Prototype”, “Multiplayer” (the draft, `battle/draft.tscn`) and “Auto Battle”: a battle to watch, the AI
  plays both sides of a 3v3 of the multiplayer battle with drawn monsters, drawn kits and a generated board, with
  the test switches as the draft screen last set them (`GameSession.autoplay`, switched off again when the battle menu
  or the draft opens); the draft screen has the same button. In a watched battle a Pause button stands in the bar in
  place of End Turn: the AI makes no further move until it is pressed again (`BattleController._hold`,
  `BattleHud.set_watch`); the game is not paused, so the camera turns, the inspector works and the
  monsters stay clickable for their story. Two switches of the draft to try (user, 2026-11-23, no
  rule): “Basic Jab” 0 takes the Basic Jab from every monster (`BattleExperiment.basic_jab`), “Step AP” 2 makes the
  Step cost 2 AP (`BattleExperiment.step_ap`, read by `BattleMoves.step_ap()`). The ingame prototype
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
  show the chance; the log shows the roll. Record: `data/tamer/seal.tres`
  (`TamerSkillDef.seal_base`); there is no seal item. Not built: upgrades of the Seal skill, a wild AI that avoids Seal Ground,
  . Tests:
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
  Stamina), `no_prop`, and `data/zones/push_zone` and `pull_zone`. `SkillGen.ground_ids` and
  `zone_ids` (generated skills, skill builder, overview tab Generator) use no record of the ingame battle; Lava,
  Thornbed, Mossbed, Binding Vines, Springwater, Shifting Sand, Gale and Void Pull are ingame records.
  Generated Strikes are called “<shape> Push Strike”, “<shape> Prop Strike” or “<shape> Touch”, and the generator
  makes no Strike that does nothing. Drawn monsters are called by their drawn Kin, Random Winged, Random Flora, …; a Kin drawn again in the same battle counts on (Random Winged2; `MonsterDraw.deal`). The
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
  turn (step off a vein, then lock it). The battle screen lets the AI think on a worker thread and on its own copy
  of the battle (`BattleController._decide`, `Battle.clone`), so the board does not stand still meanwhile; a
  decision took 94 ms in the middle and up to 1.6 s when it ran on the main thread. The caches of `Shapes` and
  `KinDef` are locked for it. Test: `test_the_ai_decides_the_same_on_a_copy_of_the_battle`.
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
    - *Board rules of 2026-11-22* (docs/battle.md §4.2, §4.5, §4.6; tests `tests/battle/test_board_rules.gd`):
      a push or pull zone moves a monster whose move ends in it (`BattleTurn.arrive`, called after a Step, the
      landing of a movement skill, a push, a pull, a retreat and a swap), once per action (`Battle.zone_moved`), and
      still at the end of its turn. Every Dragon Vein deals 1 to the monster or prop on its square at the round end,
      in one step after surrounding (`BattleTurn._veins_wear`). Ground damages props: the ground a pushed or pulled
      prop leaves and enters (`BattleDisplace.shove_prop`), end-of-turn ground at the round end
      (`BattleTurn._ground_wears_props`, `BattleDamage.ground_on_prop`); healing and Stamina do nothing to a prop.
      The zones that damaged props (Prop Damage Zone, Erosion, `FieldEffect.ERODE`) are gone. New prop **Burst
      Trap** (skill `lay_burst`); the Vortex Trap pulls its 4 neighbours. The AI counts the cost of standing on a
      vein, a lock of a vein by the HP the prop has left, and a prop that ground or a vein wears down as a bomb.
    - *Round end:* by themselves only Dragon Veins and surrounding damage a monster there. The damage line of a prop (Ember
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
      ground **Shifting Sand** (`GroundDef.no_props`), ground **Springwater** (+1 Stamina on entering) and the self buff **Deep Breath**
      (`FieldEffect.REFRESH`: more Stamina recovered at the round end).
- **Look: ink on paper** (user decision 2026-11-22; no rule; open points in docs/todo T63).
    - *Theme:* `shared/ui_theme.gd` holds the palette (paper, ink, ochre accent, cinnabar, jade, the two side
      colours `UiTheme.SIDE`), the theme of every control and the fonts (`assets/fonts`: Shippori Mincho for titles,
      cut down to Latin glyphs, and Source Sans 3 for text, both under the SIL Open Font License, licence files
      beside them). `PrimaryButton` (`HubUi.primary`) is the one cinnabar button of a screen. No colour of the look is
      written anywhere else: screens take them from `UiTheme`.
    - *Paper:* `assets/shaders/paper.gdshader` paints the ground of every screen (`UiTheme.paper_rect`,
      `UiTheme.paper_material`), in the battle on a canvas layer behind the 3D board.
    - *Signs:* `assets/icons/*.svg`, drawn in white and tinted with `UiTheme.icon_rect`: the buildings
      (`building_*`), the skill kinds (`kind_*`, on the action bar and in skill lists), the stats (`stat_*`), the
      eight beast parts (`part_<kin>`; a Kin is shown by the part its beasts leave, `HubUi.kin_sign`), the three Ways
      (`way_of_the_*`), a tamer skill, a vow, a plant, a pill, an egg, the seal of the title, and the marks of check
      boxes and switches (drawn in ink, set in the theme).
    - *Board:* `assets/shaders/tile.gdshader` paints a square: a wash of the ground's colour (taken down a step
      from the data colour, `BattleView._ground_color`), an ink edge, a pattern for what the ground is and one sign
      for when it acts (rings: a Dragon Vein; points inward: acts on entering; points outward: on leaving; a ring:
      at the end of a turn; `BattleView._ground_mark`). The pattern is the ground's data (`GroundDef.pattern`, a
      look and not part of the content fingerprint): cracks (Lava), thorns, moss, ripples, sand, stones (Rubble),
      void, loops (Snare), seal, petals, bars (No Prop); `auto` takes it from what the ground does first, which
      gives the grounds of the multiplayer battle three patterns: cracks for damage, petals for healing, ripples
      for Stamina. Only cracks glow. `assets/shaders/zone.gdshader` paints a zone as a hatched wash that flows in
      its direction, with a brush arrow (a pull zone lies only where it pulls, so every square of it has one), and
      `assets/shaders/zone_air.gdshader` paints streaks on the sides of the column above the square
      (`BattleView.ZONE_TALL`), so a zone fills its square: they run in its direction
      and rise where a zone moves nobody. By default a square is not labelled
      with the names of its ground and zone (the inspector names them; the setting “Battle: names of ground and
      zone on the squares” of the settings panel, `GameSettings.square_labels`, saved with the other settings,
      turns them on): it shows a surge, the rounds a zone has
      left, a level above I, a seal and the owner of a Dragon Vein. The colours of bodies and props are taken a
      step toward a warm grey (`BattleView.MUTE`).
    - *Bodies:* `shared/monster_body.gd` builds the body of a monster from code, no model files: simple parts,
      each with an ink line (`assets/shaders/ink_outline.gdshader`; materials, parts and the flash are shared with
      the props in `shared/ink_figure.gd`). The style is a beast of a hard wuxia world (user, 2026-11-23): the
      tones of a body (`MonsterBody._tones`) are a deep and a near-black tone of its aspect colour
      (`MonsterLook.aspect_color`), bone for horns, fangs and claws, bronze and gold for armour, rings and seals,
      and unlit tones for glowing eyes and flames of qi; the helpers `_eyes`, `_horn`, `_claws`, `_spike`,
      `_flame` and `_blade` build the recurring parts. Every Kin has two or three bodies (`MonsterBody.BODIES`):
      Beast tiger (qi mane, sabre fangs), wolf, bear (bronze skull plate) · Winged hawk, moth · Scaled lizard (a
      horned drake), turtle (the black tortoise with a snake for a tail), serpent · Swarm wasps, mites · Spirit
      ghost (bone mask with a talisman), wisp (a burning skull), shade (a wraith) · Stone golem (bound in
      bronze), colossus (of bone) · Flora treant (bound with rope and seals), mushroom (its cap a wanderer's
      hat) · Void eye, stalker, maw. A species names its body in its data
      (`MonsterDef.body`; `auto` is the first of its Kin); the field is a look and not part of the content
      fingerprint. The body stands, breathes or floats by itself; the battle view
      plays its movements from the events of the battle (`BattleView._on_event`): `moved` walk, `strike` attack,
      `cast` and `surge_declared` cast, `damage` flinch and pale flash, `displaced` lean against the push, `healed`
      jump and jade flash, `defeated` topple and shrink. The rules resolve at once; what an attack causes is shown
      `MonsterBody.strike_time()` later. `tools/body_preview.gd` shows every body and every movement.
    - *Props:* `battle/view/prop_body.gd` builds the figure of a prop the same way: weathered, quieter than the
      monsters, so that a prop stays scenery (user, 2026-11-23). Its tones (`PropBody._tones`) are a darkened tone
      of the colour in its data, old wood, stone, bronze and gold, rope and paper seals; a part glows only where
      a prop acts by itself (rune, trap, fire, lantern, the sign of the Storm Drum, the eyes of the Thorn Idol).
      Qi fire and horns belong to the monsters. Which
      figure a prop has is its data (`PropDef.figure`: tablet, bamboo, beam, urn, wall, screen, brazier, gong, drum,
      column, lantern, tree, lion, idol, bell, banner, rune, spikes, mine, vortex; `auto` is a plate for a walkable prop
      and a block for any other); the field is a look and not part of the content fingerprint. Flames, flags,
      crowns and stalks sway, the rings of a vortex turn. From the events: `prop_placed` the figure grows out of
      its square, `prop_hit` it shakes and flashes pale, `prop_moved` it slides over from its old square,
      `trap_sprung` it snaps up in cinnabar, `prop_destroyed` and `prop_lapsed` it falls flat and shrinks; a prop
      without HP that still stands is darker. `tools/body_preview.gd -- props` shows every prop of the game.
    - *Builders of the hub (`overworld/ui/hub_ui.gd`):* `monster_head` (Kin sign, name, stats with signs),
      `monster_line` (the same in one line), `fight_view` (a battleground painted small by
      `overworld/ui/mini_board.gd` beside its opponents), `tile` (a tile to pick with a sign), `swatch`, `chip`, `skill_line`, `signed`, `item_sign`.
    - *Not drawn:* a picture per species, backgrounds per building, sounds.
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
  names the hit that did it and what else the monster took in that round (`BattleText.defeat_line`). Every monster
  can be clicked for its story at any time: a living one in the turn order at the top left, a fallen one on its button
  above the log (`BattleHud.unit_pressed`, `show_story`). The story lists, round by round, what the monster used (Step,
  Heal and skills with their AP; the core records them as `action_used` events) and everything that changed its HP
  (`BattleText.unit_story_lines`, `hp_history`).
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

## Android build

The preset `Android` in `export_presets.cfg` builds a debug APK (arm64, landscape, without `addons/`, `tests/` and
`reports/`). It needs the export templates of the Godot version, OpenJDK 17 and an Android SDK (platform-tools,
build-tools); their paths are set in the editor settings (Export → Android).

```
godot --headless --path godot --export-debug "Android" <path>/road_of_the_beasts-debug.apk
adb install -r <path>/road_of_the_beasts-debug.apk
```

With a phone connected (USB debugging on), the Android button of the editor builds, installs and starts the game.
The game has not been played on a phone: touch arrives as a left click; hover, right click and keys have no touch
counterpart.
