# GDD — SKILLS
*Working Draft · companion specifications: [Monsters](gdd_monsters.md) (what a monster is), [Battle System](gdd_battle.md) (how a fight works), [Overworld & Meta](gdd_overworld.md) (the world around it) · source of truth for everything that defines a monster skill*


## Scope and Status

- **Ownership:** this file owns every monster skill rule and every concrete skill: kit and access (§1), the skill card (§2), what a skill does itself (§3), what it creates (§4), value and prices (§5), slot development (§6), data and validation (§7), shapes, Kin effects and movement kinds (§8), passives (§9), the kits of the nine monsters (§10) and the skill list (§11). Monster identity, stats, Kins, roster and growth stay in [gdd_monsters.md](gdd_monsters.md).
- **Boundary:** gdd_battle owns turns and events, the board, **what grounds, zones and props do and when**, and damage, displacement and collision. gdd_overworld owns tamer skills, loadout and meta logistics.
- **Status:** the skill-card form (§2) and reshape principles are decided ([temp_todo.md](temp_todo.md) T40). First human play and feedback exist; skill content, kits and numerical values remain **working drafts, not priced or systematically gameplay-validated**. Bot evidence through S030 and automated checks do not approve prices, content or balance (T02/T13). Surges with their marker traps, height, the air layer and their price sheets are no longer active design; a trap exists again as a walkable prop ([Battle §4.9](gdd_battle.md#49-props)).
- **Open rules:** a missing rule grants no default; open decisions and tasks live only in [temp_todo.md](temp_todo.md) (T02, T05, T06, T10, T11, T40, T41).
- **Section references:** `§n` without a file name means this file.


## 1. The Kit

```
Monster = Step (always, no slot)
        + up to 6 slots, each an active skill or a passive, at least one active
```

- **Slots:** 6 slots (user decision 2026-11-14; before: 4 plus a passive-only 5th for Epic+). **The multiplayer mode (the build's draft sandbox, called battle prototype until 2026-11-15) plays with all six open; in the game single slots are planned as upgrades** *(user decision 2026-11-15)*. How many are open at the start, and what opens the others, is open (T05). **Step** (1 square, 1 AP, slot-free) is the weakest movement, for monsters without a movement skill. No skill is mandatory, not even a Strike or a movement; the same skill may sit in two slots, each copy with its own usage count ([§2](#usage-and-repetition)).
- **The player shapes the kit:** which monster carries which skills is a decision of the player ([§6](#6-slot-levels-development-and-replacement)); the kits of §10 are working starting points, not validated defaults.
- **Limits:** the species' learnable list ([Monsters §3.1](gdd_monsters.md#31-kin-table)). Which skills a species may learn, and whether a Kin excludes any, is content work that does not exist yet (T11); the kits of the build ignore Kin access.
- **Species-specific and Signature skills** are ordinary skills with restricted access, not a mechanical kind of their own; Signature access stays Legendary/progression-bound ([Monsters §5.1](gdd_monsters.md#51-monster-rarity)) with no decided content (T32).


## 2. The Skill Card

**Status:** decided by the user on 2026-11-13 as the form of every skill ([Battle §1.2](gdd_battle.md#12-battle-design-pillars)); one shape per skill and the optional damage and push of a Strike on 2026-11-15. Numbers are working values, nothing is priced.

**A skill only delivers.** It has a cost and one shape, it may strike around its user, move its user or act on its user, and it **creates ground, a zone or a prop**. What a ground, a zone or a prop does, and when, is written **once**, in its own definition ([Battle §4](gdd_battle.md#4-battlefield)); a skill only names it. There are **no Surges** *(user decision 2026-11-13)*: damage at range comes from ground and from props (a trap is a walkable prop, *user decision 2026-11-15*), immediate damage only from a Strike.

| Part of the card | Content |
|---|---|
| **Cost** | AP · use (once per turn unless the card names more; once per round; once per battle) · a movement also Stamina per square ([Battle §2.3](gdd_battle.md#23-action-points-and-stamina)); a passive has none |
| **Shape** | one shape per skill ([§8.1](#81-shapes)): a **base shape** around the user (Jab, Pincer, Arc, Whirl, Cross, Storm, each with extensions), or a **free shape**: a number of squares at an anchor within Reach or next to the user |
| **Strike** | no · or damage (0–2), a push of 1, or both, now, on the squares of its base shape |
| **Movement** | no · or the path kind (walks, straight line, any path), what it passes over, its range and a push on landing |
| **On itself** | no · or a timed effect on the user (self buff) · or a lasting one (passive) |
| **Creates ground** | no · or which ground |
| **Creates zone** | no · or which zone, for how many rounds |
| **Creates prop** | no · or which prop |

- **What the created things do:** ground acts at a moment (on entering, on leaving, at the end of the occupant's turn, at the end of the round) and lasts 2 rounds when laid in battle; a zone acts while a monster stands inside (stat changes; push or pull at the end of its turn); a prop acts at its moments (when destroyed, hit or entered, at the end of the round) on a shape around itself, and a solid one blocks the way and gives cover. All three are written as one sheet ([Battle §4.12](gdd_battle.md#412-one-sheet-for-ground-zones-and-props)). Ground acts as long as it lies; a square that acts once and vanishes is a walkable prop: a trap *(user decision 2026-11-15)*.
- **Combinations:** a Strike may create ground or a zone on the struck squares; a movement may create them on the squares it left; a skill that neither strikes nor moves may create any of the three, also two at once. **Direction of a push zone:** cast alone it is chosen with the cast; left by a skill that also creates something else it points where the placement is turned (rotation); left by a Strike it points in the Strike's direction, left by a movement the way the monster went.
- **Every effect hits everyone on its squares,** friend and foe; being pushed or pulled counts as movement.
- **Guideline, not a duty:** a kit skill does one thing itself or creates one thing, at most two; Step and Jab stay plain. **A zone that only changes stats is never a skill of its own:** it comes along with ground, a push or pull, or a Strike *(user decision 2026-11-13)*.
- Effects on AP or turns per round are rare and expensive and carry the content status `experiment`.

### Fixed, Chosen and Derived

What a skill fixes, what the player chooses and what follows from stats and board *(overview of the card without skill names; user request 2026-11-15)*:

| Part | Fixed on the card | Chosen by the player | Follows from stats and board |
|---|---|---|---|
| Cost | AP; use (N per turn, once per round, once per battle) | — | Stamina per square of a movement |
| Strike | base shape and extensions; damage 0–2; push yes or no | direction (eight; an extended Arc four) | who stands in the shape; cover by a solid prop; the Kin effect |
| Movement | path kind; what it passes over; range; push on landing (none, ahead, all neighbours) | path and landing square | Stamina left; movement cost of the squares |
| On itself | effect and rounds (self buff), or lasting (passive) | — | — |
| Creates ground, a zone, a prop | which thing; the shape: a base shape around the user, or the number of squares of a free shape and its anchor rule (within Reach, next to the user); rounds of a zone | **before the battle:** the arrangement of a free shape · **in the turn:** direction or anchor square, quarter turn, direction of a push zone | Reach; which squares can take it |
| Leaves (combination) | ground or a zone on a Strike or a movement | — | the struck squares, or the squares left |

### Usage and Repetition

| Use | Meaning |
|---|---|
| N per turn (default 1) | this equipped copy at most N times per turn of its monster (user decision 2026-11-14; data field `usage_limit`). A card may name a higher N; raising it is a candidate slot development ([§6](#6-slot-levels-development-and-replacement)), unpriced. Step is not slotted and has no limit |
| once per round | one use of this equipped copy in the global battle round; extra turns within the round do not reset it |
| once per battle | one use of this equipped copy in the battle |

- **Per equipped copy:** two copies of one skill in two slots each have their own count and each cost their AP.
- **A use counts when the skill is used,** whatever it then achieves; an illegal attempt spends neither AP nor a use. Later effects of what the skill created (a zone pushing at a turn end) are no further uses.
- No generic multi-round cooldown exists.

### Place, Shape and Rotation

**One shape per skill** *(user decision 2026-11-15)*: the same vocabulary for Strikes, for what a skill creates, and for what a prop does around itself ([§8.1](#81-shapes)).

- **Base shape around the user:** a Strike hits its squares; a skill that creates lays its ground, zone or props on them (a line from the user is a Jab with extensions, the ring around the user a Whirl). The player aims it in one of eight directions (an extended Arc: four straight ones); Whirl, Cross and Storm need no aim. All squares must lie on the board.
- **Free shape:** the card names only **a number of squares** and where the anchor may lie: **within Reach** (board distance from the user) or **next to the user**. **The player arranges the squares before the battle:** connected over their edges, the anchor square among them. The arrangement authored with the skill is the default (bots and quick battles use it).
  - In battle the arrangement is fixed; the player may still **turn it in quarter turns** *(build rule 2026-11-12: free rotation for everyone)*.
  - The opponent sees the arrangement on the skill card: no hidden abilities.
  - A skill that creates props uses a free shape like one that creates ground or a zone (Earth Wall: 3 squares) *(confirmed by the user on 2026-11-15)*.
  - All squares must lie on the board; a square that cannot take what the skill creates stays as it is ([Battle §6.2](gdd_battle.md#62-payload-resolution)).
- **Never free:** the squares a Strike struck and the squares a movement left.
- **Movement:** the path of the user ([§3](#3-what-a-skill-does-itself)).
- **Reach** applies to every free shape placed at a distance; a base shape lies around the user and uses none.
- **No sight rule:** nothing blocks choosing a square. Cover exists for Strikes only ([Battle §4.9](gdd_battle.md#49-props)).
- **Everything is previewed** before the player confirms.
- *Open (T05/T10):* the largest number of squares (1–5 in the draft skills), and whether a free shape may also be arranged by an opponent's AI.


## 3. What a Skill Does Itself

Three things happen at the skill, not on the square: a Strike, the user's own movement, and an effect on the user. Everything else is created on the board (§4).

### Strike

- **Now, around the user:** a Strike hits every monster and prop on the squares of its base shape, friend and foe; it is the only immediate damage in the game ([Battle §6.1](gdd_battle.md#61-the-damage-law)).
- **Damage and push are both optional** *(user decision 2026-11-15)*: a Strike deals 0–2 damage per struck monster, and its card says whether it pushes. A Jab does both; Shove only pushes. A Strike that does neither only delivers what it creates.
- **Push:** a Strike that pushes moves each struck monster and prop on a neighbouring square 1 square away from the striker, along its own offset (eight directions; [Battle §6.4](gdd_battle.md#64-displacement)); farther squares of the shape are damaged but not moved. Collision and ground effects follow [Battle §6.3](gdd_battle.md#63-collision).
- **Cover** *(user decision 2026-11-15)*: a solid prop takes the hit and the square behind it is not struck ([Battle §4.9](gdd_battle.md#49-props)).
- **One hit per monster** per use, however many squares of the shape it covers.
- **Props:** a Strike that deals damage damages the props in its shape; one that only pushes moves them without damage.
- **Kin effect:** the Kin of the striker adds its effect ([§8](#8-shapes-and-movement)).
- **A Strike may create ground or a zone** on the squares it struck (§4); it creates no prop.

### Movement

- **Step:** 1 square, 1 AP, no Stamina, every monster.
- **Movement skill:** the user moves up to the **range** of the skill (3 squares unless its card names another) and never further than its Stamina allows; the skill sets the **path kind** and **what it passes over** ([§8.2](#82-movement-kinds)). It costs its AP and Stamina for every square ([Battle §2.3](gdd_battle.md#23-action-points-and-stamina)): walking pays the movement cost of the ground (Rubble 2), the other path kinds 1 per square. *(User decision 2026-11-15; before, a movement skill covered the Movement stat.)*
- **Every square entered and left counts** for ground and traps ([Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed), [§4.9](gdd_battle.md#49-props)); a path over other squares touches only the landing square.
- **On landing** a movement skill may push: the monster ahead, or all eight neighbours ([§8.2](#82-movement-kinds)).
- **A movement may create ground or a zone on the squares it left** (§4).
- `slow` and `haste` change the range of movement skills, never of Step *(the build's reading under Stamina; open, T41)*.

### Effect on the User

- **Self buff:** a timed effect on the user for N rounds ([Battle §4.5](gdd_battle.md#45-lifecycles)); the same buff used again refreshes and never stacks.
- **Passive:** a lasting effect without cost; candidates: [§9](#9-passives).
- **Effects available:** Pace (in points of 0.1), range of movement skills and Reach up; as **experiment** *(user decision 2026-11-13: rare and expensive; content status `experiment`)*: AP +1 and one more turn in the next round. A skill cannot place an effect on another monster: what reaches others goes through the board.


## 4. What a Skill Creates

A skill creates **ground**, a **zone** or a **prop** on its squares. What each of them does is defined once: ground in [Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed), zones in [§4.6](gdd_battle.md#46-zones-effects-rules--opposites), props in [§4.10](gdd_battle.md#410-prop-catalogue-and-damage). The skill only names the type.

| Created | Lasts | May be created by | Not possible |
|---|---|---|---|
| **Ground** | 2 rounds | a placed shape · a Strike, on the struck squares · a movement, on the squares it left | on Voidscar or a Dragon Vein (a prop on the square does not prevent it) |
| **Zone** | the rounds the skill names (2 in the build) | a placed shape · a Strike · a movement | — (on the square of a solid prop its stat effects wait; a push or pull zone moves the prop at the round end) |
| **Prop** | until destroyed; a trap until it is entered | a placed shape: one prop per square (1 square; Earth Wall 3) | on a square that cannot take it (a solid prop needs a square free of monsters and props); by a Strike or a movement |

- **Two at once:** a skill that neither strikes nor moves may create two things together, for example ground and a zone on the same squares (Coiling Rift: Blight and Void Pull).
- **Order:** what a skill creates lands after its damage and displacement ([Battle §6.2](gdd_battle.md#62-payload-resolution)): props, then ground, then zones.
- **Ground under a monster** does not count as entering it; it acts at its next moment. This makes Binding Vines the one thing a skill can lay directly under an enemy with effect.
- **Direction of a push zone:** [Battle §4.6](gdd_battle.md#46-zones-effects-rules--opposites).
- **Levels:** the same hazard ground laid again gains a level (max II); the same zone cast again gains a level (max III) and refreshes.
- **Every effect hits everyone** on its squares, friend and foe; own ground and zones bind the caster too.
- **Placed shape:** a base shape around the user or a free shape at an anchor ([§2](#place-shape-and-rotation)).
- **Traps are props** *(user decision 2026-11-15)*: a skill creates a walkable prop that acts when a monster enters it and is then used up (Spike Trap, Vortex Trap; [Battle §4.10](gdd_battle.md#410-prop-catalogue-and-damage)).
- **Not in the game:** damage or healing by a zone.


## 5. Value and Prices

**Status: open.** No skill, ground, zone or prop has a price, and nothing checks a monster against a budget *(user directions 2026-11-12/13: skill and stat calculation are found through play and simulation, together with the rules)*. The price sheets of the earlier model (construction points, AP-efficiency scale, component prices for Surges, timers, Mountains and air coverage) were removed with that model. The field `internal_calc_cost` of the Resource files still holds numbers of those sheets for older records and −1 for everything built since; it is an authoring note and no rule reads it.

**Principles that stay** *(earlier user decisions)*:
- **One budget idea:** a skill is paid for with its AP cost and its use limit; a stronger skill costs more AP or may be used less often. No skill rarity. A Strike's AP stands on its card like every other cost *(since 2026-11-15; before, a Strike took the AP of its shape; draft values per shape: [§8.1](#81-shapes))*.
- **A complete kit at original AP:** development (§6) never forces a higher AP cost on a skill.
- **Monster stats and skills are priced apart** ([Monsters §2.2](gdd_monsters.md#22-frame-budget-level-ups)), but their interactions and thresholds for possible actions and action combinations are validated together. Calculators describe gameplay-derived balance rather than dictate it.

**Evidence boundary:** current bot observations (S020–S031) depend on kits, maps, bot policy and replacement opportunity costs; they establish neither a universal skill ranking nor component/stat prices. Progression proxies are not approved starts or slot upgrades. Current push/pull zone skills, including Bog, normally cost **1 AP**; the **2-AP ZONE PUSH/PULL override is an experiment**, not a monster-AP change or an adopted price. Three Dragon Veins remain the 7×7 default; the one-vein control is test-only. Results and pending human review belong to [temp_todo.md](temp_todo.md) T13, with pricing under T02 and stat/progression validation under T03.



## 6. Slot Levels, Development and Replacement

**Confirmed: permanent slot development**, gained only at **advancement steps** ([Monsters §5.3](gdd_monsters.md#53-monster-progression-the-18-steps)): a stage breakthrough (or the listed later sub-tier steps) offers the individual monster the option to develop one skill slot. There is no separate experience currency, no spending outside an advancement and no physical evolution.

- **Ownership:** a development step develops one slot on one monster, not the skill or the species globally. The player picks from options written for the equipped skill, never free components.
- **Replacement:** outside expeditions a slot may take another skill of the species' learnable list with a **relearning pill**; the slot keeps its development. Pill acquisition, recipe and price: T05/T16/T31.
- **Levels 1–3** per slot; how steps map to levels and what a level allows is undecided (T05).
- **What a development may change** *(candidate list on the skill card, not approved content)*: one more extension of its base shape or one more square of its free shape, a longer zone, a longer range or a movement that passes over more, a second thing created, one more use per turn. **Never:** more damage than the caps of [Battle §6.1](gdd_battle.md#61-the-damage-law), lower AP, more Reach.
- **AP policy:** every skill has a complete path at its original AP; a bigger option may cost more AP, shown before selection, and is never the only path.
- **Useful from the start:** starting AP must support the intended starter kit without a mandatory stat purchase. Slot development expands an already viable kit, with several useful routes and no compulsory first upgrade; it must not repair an unusable starting skill.
- **Progression validation:** test the starting kit, then each single slot upgrade, then combinations, including permanent stat upgrades and the action thresholds they change ([Monsters §2.2](gdd_monsters.md#22-frame-budget-level-ups)). A slot upgrade develops that slot; a permanent stat upgrade changes the monster's stats. Keep their ledgers separate while validating their interaction.
- **Where and when:** [Overworld §6.3.2](gdd_overworld.md#632-permanent-skill-slot-development-confirmed).


## 7. Data and Validation

- **One Resource file per record** under `godot/data`: `skills/`, `monsters/` (species, reference stats and kit), `grounds/`, `zones/`, `props/`, `tamer/`. A new file is new content.
- **Content status** on skills, monsters, grounds, zones and props: `approved` (none yet), `draft` and `experiment` enter the regular build; `test`, `simulation` and `archived` do not. `ContentStatus.in_game`, used by `BattleContent` and `GameData`, is the shared filter. A runtime status is not design or balance approval.
- **Simulation-only resources:** `godot/data/skills/{mist_step,receding_blow,cloudstep_token,raise_reed_screen}.tres` and `godot/data/props/reed_screen.tres` carry `simulation`; they are excluded from regular kits and the builders' in-game choices. They remain visible in the unfiltered debug overview; **In game only** hides them. Discovery runs substitute them only for those runs. They are not approved skills, items or slot-development options and do not extend §11; experiment scope and follow-up: [godot/README.md](../godot/README.md), [temp_todo.md](temp_todo.md) T13 (S023).
- **Automated content checks:** a monster of the game holds one to six skills of the game; a ground, a zone and a prop of the game keep to their roles ([Battle §4.12](gdd_battle.md#412-one-sheet-for-ground-zones-and-props)); a skill names existing grounds, zones and props; game content must not reference excluded records. These checks are not runtime budget enforcement or gameplay validation.
- **Overview** (menu → Overview): one table each for skills (as cards), monsters, grounds, zones and props, and **Board sheets**: ground, zones and props together in the one sheet format, all read from these files. **In game only** is initially off; the unfiltered debug view includes excluded records without making them playable.
- **Hover card in battle:** a skill button shows what the skill does itself, then per created ground, zone or prop one line “creates …” and below it what that thing does, taken from its definition.
- **Skill builder** (Overview → Skill builder): puts a skill together from the parts of the card, or draws a random one, shows the card and what the created things do, writes it to `godot/data/skills` with the status `experiment` and can put it into a kit slot of a monster. It offers the base shapes with extensions for a Strike, damage 0–2 and push yes or no, enforces the fixed rules (damage only by a Strike, at most 2; no prop from a Strike or a movement) and checks no price. Self buffs and the passive Immovable can be built; other passives cannot.
- **Monster builder** (multiplayer mode → Monster builder, also in the Overview): creates a monster or changes an existing one: name, Kin, the six stats in their ranges (HP 1–10, Pace 1.0–10.0, Stamina 1–10, Reach 1–10, turns per round 1–3, AP 1–5; [Monsters §2.1](gdd_monsters.md#21-the-stats)) and the six kit slots from the skills of the game; “New skill” opens the skill builder and returns. It writes `godot/data/monsters/<id>.tres` (a new monster with the status `experiment`), after which the monster stands in the team choice. It checks only that the kit holds an active skill; no price, budget, frame or Kin access.
- **Shape editor** (multiplayer mode → Arrange shapes): the player lays out the free shapes of the picked monsters before the battle ([§2](#place-shape-and-rotation)); the battle request carries the arrangements, an illegal one leaves the default.
- **Skill generator** (`godot/tools/sim.gd --variant genskills=N`): draws random cards as in-memory skills so that bot runs report a win rate per part.


## 8. Shapes and Movement

Kin identity itself stays in [Monsters §3.1](gdd_monsters.md#31-kin-table).

### 8.1 Shapes

**One shape vocabulary** *(user decision 2026-11-15)*: six **base shapes** around a centre `M`, each **extended** any number of times. A Strike uses them around the striker, a skill that creates something next to its user uses them around the user, a prop around itself. A bigger shape costs more AP; the AP stands on the card of the skill ([§5](#5-value-and-prices)).

| Base shape | Squares | Directions |                                                      The squares                                                       |
|------------|---------|------------|------------------------------------------------------------------------------------------------------------------------|
| **Jab**    |       1 | 8          | next to `M`                                                                                                            |
| **Pincer** |       2 | 8          | next to `M` in the chosen direction **and** on the opposite side                                                       |
| **Arc**    |       3 | 8          | the 3 squares in front of `M`: a row, or on a diagonal the wedge `(dx,0)`, `(dx,dy)`, `(0,dy)` for direction `(dx,dy)` |
| **Whirl**  |       4 | none       | the 4 neighbours of `M`                                                                                                |
| **Cross**  |       4 | none       | the 4 diagonals of `M`                                                                                                 |
| **Storm**  |       8 | none       | all 8 squares around `M`                                                                                               |

```
  x       x      x x x         x            x
  M       M        M         M            M
          x                             x
Jab     Pincer   Arc       Jab,         Pincer,
                           diagonal     diagonal

  x     x   x   x x x
x M x     M     x M x
  x     x   x   x x x
Whirl   Cross   Storm
```

**Extension:** every square of the shape gets one more square behind it, away from `M`; for the Arc the whole row moves on in the facing direction. Each further extension repeats the step. An extended Arc is straight only *(user decision 2026-11-11: no diagonal form)*.

```
  x        x                       x         x       x     x   x   x
  x        x         x x x         x           x   x         x x x
  M        M         x x x     x x M x x         M         x x M x x
           x           M           x           x   x         x x x
           x                       x         x       x     x   x   x
Jab +1   Pincer +1   Arc +1    Whirl +1      Cross +1      Storm +1
(Thrust)             (Cleave)  (Long Whirl)  (Long Cross)
```
`M` is the centre, `x` a square of the shape. A shape with a direction is drawn for "up" (the diagonal Jab and Pincer for "up-right"); the player turns it to any of its legal directions.

|   Shape   | Squares |                            Earlier a shape of its own                           | Draft AP *(a Strike with 2 damage and push)* |
|-----------|---------|---------------------------------------------------------------------------------|----------------------------------------------|
| Jab       |       1 | Jab                                                                             | 2                                            |
| Jab +1    |       2 | Thrust (straight) and Diagonal Thrust (diagonal): now one shape in 8 directions | 3                                            |
| Jab +2    |       3 | — (the line of 3 from the user)                                                 | open                                         |
| Pincer    |       2 | Pincer                                                                          | 3                                            |
| Pincer +1 |       4 | —                                                                               | open                                         |
| Arc       |       3 | Arc                                                                             | 3                                            |
| Arc +1    |       6 | Cleave                                                                          | 5                                            |
| Whirl     |       4 | Whirl                                                                           | 3                                            |
| Whirl +1  |       8 | Long Whirl                                                                      | 5                                            |
| Cross     |       4 | Cross                                                                           | 3                                            |
| Cross +1  |       8 | Long Cross                                                                      | 5                                            |
| Storm     |       8 | Storm                                                                           | 4                                            |
| Storm +1  |      16 | — (the eight lines of 2, not the full ring of 24)                               | open                                         |

**Offsets per orientation** *(origin `M = (0,0)`, direction `d = (dx, dy)`, `d⊥ = (|dy|, |dx|)` for straight `d`, extension `e ≥ 0`, `k = 1 … e + 1`)*:

|         Shape         |     Legal directions    |                                          Offsets                                          |
|-----------------------|-------------------------|-------------------------------------------------------------------------------------------|
| Jab                   | 8                       | `k·d`                                                                                     |
| Pincer                | 8                       | `k·d`, `−k·d`                                                                             |
| Arc                   | 8; extended: 4 straight | straight: `k·d`, `k·d + d⊥`, `k·d − d⊥`; diagonal (`e = 0` only): `(dx,0)`, `d`, `(0,dy)` |
| Whirl / Cross / Storm | none                    | `k·c` for each of the 4 neighbours / the 4 diagonals / all 8 `c`                          |

- **The square in front:** every square with `k > 1` has the square with `k − 1` of the same line in front of it. A solid prop there takes a Strike and shields it ([Battle §4.9](gdd_battle.md#49-props)).
- **Every shape hits allies too.**
- **Two more forms for things that include their own square:** the **own square**, and the **block** around and including it (3×3, extended 5×5). Props that act on entry use them (traps, the Moss Rune).
- **A prop has no direction:** it uses Whirl, Cross, Storm, its own square or the block, never Jab, Pincer or Arc ([Battle §4.12](gdd_battle.md#412-one-sheet-for-ground-zones-and-props)).
- **Free shape:** a skill that creates something at an anchor has no base shape but a number of squares ([§2](#place-shape-and-rotation)).
- **Draft Strikes:** Jab, Thrust (Jab +1), Shove (a Jab that only pushes) and Thorn Lash (a Jab that leaves Thornbed). Strikes with other shapes are archived; user-authored experiments may still use those shapes (§7/§10), without approving them as defaults.
- **AP decides when:** AP 2 is the ceiling until Core ([Monsters §2.3](gdd_monsters.md#23-stat-ceilings-per-stage)), so early Strikes are Jabs.
- **Storm +1 is the eight lines (16 squares)** and an extended Arc stays straight only *(both confirmed by the user on 2026-11-15)*; the full ring of 24 squares exists only as the 5×5 block of a prop.
- *Open (T06):* the AP of the shapes without a draft value; how far a shape may be extended.

**Kin effects** (on top of damage and push):

| Kin | Strike | Effect |
|---|---|---|
| Beast | Bite | none *(user decision 2026-11-11: the baseline)* |
| Winged | Dive | then the striker retreats 1 square for free, opposite the centre of the hit shape, once per use |
| Scaled | Tail Sweep | pushes the target 1 square in a **chosen** cardinal direction instead of straight away |
| Swarm | Gnaw | props take double (4) |
| Spirit | Siphon | target −1 Pace point (−0.1) next round |
| Ancient | Slam | *(none any more: it destroyed the Mountain under the target; a new effect is open, T06)* |

**Self retreat** (Winged): one square opposite the centre of the hit shape; it exists only for shapes whose centre lies on one of the eight directions (Jab and Arc, also extended). It happens once per valid use, whether or not anything was hit, after the Strike has resolved; if the square is not free, the striker stays and nothing else happens. `R` marks the square:

```
       x               x                                   x x x
x      x             x          x x x      x x             x x x
M      M           M              M        M x               M
R      R         R                R      R                   R

Jab    Jab +1    Jab +1 (diag)  Arc      Arc (diagonal)    Arc +1
```

- **No retreat cell:** Pincer, Whirl, Cross and Storm, also extended (the centre is the attacker itself). An extended Arc is straight only: a diagonal Cleave does not exist (user decision 2026-11-11).
- The Winged Strike (Dive, above) uses this same retreat cell *(user decision 2026-11-11)*.

- **2×2 bodies** *(out of scope since 2026-11-14; none in the build; kept only until clean-up)*: a 2×2 target is pushed along the mean offset of its struck neighbouring squares if that lies on one of the eight directions, otherwise it is damaged but not pushed.

### 8.2 Movement Kinds

| Skill | Path | Passes over | On landing | Leaves |
|---|---|---|---|---|
| **Step** | 1 square, cardinal | nothing | — | — |
| **Run** | walks, cardinal steps | nothing: props and monsters block; Rubble costs 2 | — | — |
| **Leap** | straight line (8 directions) | everything; only the landing square counts | — | — |
| **Glide** | any path | props and monsters | — | — |
| **Headbutt** | straight line | everything | pushes the monster on the next square 1 on | — |
| **Quake Leap** | straight line | everything | pushes every monster on the eight neighbouring squares 1 outward | — |
| **Fire Trail** | straight line | monsters | — | Lava on the squares it left |

- All reach up to 3 squares and pay Stamina per square ([Battle §2.3](gdd_battle.md#23-action-points-and-stamina); user decision 2026-11-15, before: up to the Movement stat); Run costs 1 AP, the others 2 AP *(build test since 2026-11-13: the earlier distance deductions are gone; [simulation_log.md](simulation_log.md) S016)*. Step pays no Stamina.
- **Archived movement skills:** Burrow, Phase, Blink.
- **Kin access to movement kinds** (Run for all but Spirit, Leap for Beast, Glide for Winged, and so on) was part of the earlier draft; the kits of the build ignore it, and a new access table is content work (T11).


## 9. Passives

- **A passive occupies a normal kit slot,** costs no AP and is an effect on its bearer ([§3](#effect-on-the-user)). One active skill and passives in every other slot is legal but weak.
- **In the build:** **Immovable** (ignores push and pull); no current kit of the nine equips it (§10).
- **Candidates from the earlier draft that still fit** *(not approved, no numbers; T11)*: Counterweight (allies orthogonally next to it cannot be pushed or pulled) · Thick Hide (Strike and collision damage it takes −1) · Crashlander (collision damage it takes −1) · Sure-footed (ignores `slow`) · Clear Mind (ignores `drain_pace` and `drain_range`) · Heatproof / Thornwalker / Void-touched (ignores Lava / Thornbed / Blight) · Scavenger (heals 1 when a prop within its Reach is destroyed) · Purifier (enemy zones next to it lose 1 round at the end of a round) · Overgrowth (its zones start at level II) · Turret (cannot move, Reach +1).
- **Dropped with the reshape** (their object is gone): Highlander (Mountain), Skittish, Momentum, Vengeful and Bulwark (Surge damage), Adaptive (rotation is free for everyone), Phasing (a movement kind now).
- **Passives that lower AP costs** (Pack Hunter, First Blood) **are allowed; no action ever costs less than 1 AP** *(user decisions 2026-11-14 and 2026-11-15; read as the only fixed limit)*: the “no AP reduction” principle of [§5](#5-value-and-prices)/[§6](#6-slot-levels-development-and-replacement) applies to skill development, not to these passives; the floor is [Battle §2.3](gdd_battle.md#23-action-points-and-stamina). How much a single passive lowers and under which condition is content (T11). Still unresolved from before: Frenzy (+1 shape square at 1–2 HP).


## 10. Kits of the Nine Monsters

**Status: current prototype interface, not approved default kits.** The table mirrors the nine `godot/data/monsters/*.tres` Resources, including manual user experiments; it is not a second skill catalogue. First human play exists; pricing, Kin access and systematic validation remain open (T02/T11/T13). Stats: [Monsters §4.1](gdd_monsters.md#41-first-roster-draft--9-monsters).

| Monster | Kin | Movement | Strike | Third skill | Moves others | Ground | Prop | Idea |
|---|---|---|---|---|---|---|---|---|
| **Blaze Tiger** | Beast | Fire Trail | Jab | Thrust | Headbutt | Lava Field | Light Brazier | charges in, burns the path and the target area, knocks a monster off its square |
| **Ember Hawk** | Winged | Glide | Jab | Cinder Dive (ground) | Gale · Shove | — (Cinder Dive) | Lay Spikes | two short turns from round 2: glides anywhere, strikes or shoves, burns a line, blows enemies back |
| **Dusk Moth** | Winged | Run | Jab | Snare (ground) | Void Pull | Gloom Rift | Lay Vortex | works from long Reach: pins with Binding Vines, lays dulling Blight, pulls others in |
| **Forge Golem** | Ancient | — (Step only) | Jab | Thrust | Gale | Lava Field | Set Gong · Earth Wall | holds a square, strikes two deep, heats the ground before it and builds its own cover |
| **Gloom Wolf** | Beast | Run | Thorn Lash | Lay Spikes (prop) | Shove | Gloom Rift | Plant Bamboo | leaves thorns where it strikes, slows with Blight and shoves enemies into spikes or off a Dragon Vein |
| **Grove Wisp** | Spirit | Quake Leap | Jab | Snare (ground) | Gale | Thornbed | Set Thorn Idol | leaps into a group and scatters it, blows a line back, binds and lays slowing thorns |
| **Hollow Serpent** | Scaled | Run | Jab | Thornbed (ground) | Shove | Coiling Rift | Lay Vortex | lays Blight that pulls enemies together, thorns around them, and shoves the rest in |
| **Moss Turtle** | Scaled | Run | Jab | Bog (zone) | Shove | Thornbed | Earth Wall | slow wall that moves others: drags into the Bog, shoves off a Dragon Vein, walls a path |
| **Thorn Mites** | Swarm | Glide | Jab | Thorn Lash | Void Pull | Thornbed | Set Clay Urn | two turns from round 2: strikes thorns into the ground and pulls enemies across them |

- **Six skills and a balanced kit** *(user instruction 2026-11-15 for the multiplayer mode)*: every kit holds a damaging Strike, a skill that moves others, one that creates ground and one that creates a prop, and every monster but the Forge Golem a movement skill (the Golem has a Stamina of 1 and a second prop instead). The sixth skills were added by the agent and are not confirmed one by one: Thrust and Headbutt (Blaze Tiger, in place of the deleted user experiment `new_skill`), Jab (Dusk Moth, Moss Turtle: neither had a damaging Strike), Shove (Ember Hawk, Hollow Serpent), Lava Field (Forge Golem), Gloom Rift (Gloom Wolf), Snare (Grove Wisp), Thorn Lash (Thorn Mites); Moss Turtle's Void Pull gave way to Thornbed. Not played and not measured.
- **Requirement for the kits the bots play: at least one skill that pushes or pulls** *(user decision after first play, 2026-11-13: a sturdy monster on a Dragon Vein could not be removed; the user chose more displacement in the kits over a Shove for everyone)*. Since a Strike may push without damage and pushing is a property of the single skill ([§3](#3-what-a-skill-does-itself)), a Strike that pushes counts too *(confirmed by the user on 2026-11-15 for the kits the bots field: the nine kits above and every drawn test kit; before, the wording was “without a Strike”)*. It is a requirement on these kits, not a rule that forces a displacement skill into a kit the player composes. The Forge Golem no longer carries Immovable for the same reason; the passive stays in the game.
- **Builder edits:** builders can rewrite Resources without checking points or Kin access; see [godot/README.md](../godot/README.md#content-status-and-build-rules) and [temp_todo.md](temp_todo.md) T13.
- **Six slots:** the multiplayer mode fields all six ([§1](#1-the-kit)).
- **Validation:** current-kit observations and the limitations of S020–S031 remain under T13; no historical win-rate ranking is a kit rule or content approval.
- **Species learn lists** and further species: [Monsters §4](gdd_monsters.md#4-roster); T11/T12.


## 11. Skill List

**Working content draft,** informed by first human play but not priced or systematically gameplay-validated. This table is the authored draft catalogue, not every Resource in the prototype: additional user `experiment` records are not automatically adopted, and `simulation` records remain excluded (§7). Highest single hit: 2 (working value). What the named grounds, zones and props do: [Battle §4.6](gdd_battle.md#46-zones-effects-rules--opposites), [§4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed), [§4.10](gdd_battle.md#410-prop-catalogue-and-damage).

| Skill | Cost | Where | Strike | Movement | On itself | Ground | Zone | Prop |
|---|---|---|---|---|---|---|---|---|
| Step *(every monster)* | 1 AP | neighbouring square | — | 1 square, no Stamina | — | — | — | — |
| Run | 1 AP + Stamina | path, range 3 | — | walks | — | — | — | — |
| Leap | 2 AP + Stamina | path, range 3 | — | straight line over everything | — | — | — | — |
| Glide | 2 AP + Stamina | path, range 3 | — | any path over props and monsters | — | — | — | — |
| Headbutt | 2 AP + Stamina | path, range 3 | — | straight line; pushes the monster ahead | — | — | — | — |
| Quake Leap | 2 AP + Stamina | path, range 3 | — | straight line over everything; pushes all eight neighbours on landing | — | — | — | — |
| Fire Trail | 2 AP + Stamina | path, range 3 | — | straight line over monsters | — | Lava on the squares left | — | — |
| Jab | 2 AP | Jab | 2 damage, push 1 | — | — | — | — | — |
| Thrust | 3 AP | Jab +1 (2 in a line) | 2 damage, push 1 | — | — | — | — | — |
| Shove | 1 AP | Jab | push 1, no damage | — | — | — | — | — |
| Thorn Lash | 2 AP | Jab | 2 damage, push 1 | — | — | Thornbed | — | — |
| Snare | 2 AP | Reach, 1 square, also under a monster | — | — | — | Binding Vines | — | — |
| Lava Field | 1 AP | Reach, 4 squares (default: block 2×2) | — | — | — | Lava | — | — |
| Thornbed | 1 AP | Reach, 3 squares (default: angle) | — | — | — | Thornbed | Slowing | — |
| Gloom Rift | 1 AP | Reach, 3 squares (default: line) | — | — | — | Blight | Mire | — |
| Cinder Dive | 1 AP | line of 3 from the user (Jab +2) | — | — | — | Lava | — | — |
| Coiling Rift | 2 AP | Reach, 4 squares | — | — | — | Blight | Void Pull | — |
| Gale | 1 AP | Reach, 3 squares (default: line) | — | — | — | — | Gale | — |
| Void Pull | 1 AP | Reach, 4 squares | — | — | — | — | Void Pull | — |
| Bog | 1 AP | Reach, 3 squares (default: angle) | — | — | — | — | Bog | — |
| Plant Bamboo | 1 AP | Reach, 1 free square | — | — | — | — | — | Bamboo Stand |
| Set Gong | 1 AP | Reach, 1 free square | — | — | — | — | — | Bronze Gong |
| Earth Wall *(build draft)* | 2 AP | Reach, 3 squares (default: line) | — | — | — | — | — | an Earth Wall on each |
| Set Thorn Idol *(build draft)* | 1 AP | Reach, 1 free square | — | — | — | — | — | Thorn Idol |
| Light Brazier *(build draft)* | 2 AP | Reach, 1 free square | — | — | — | — | — | Ember Brazier |
| Set Storm Drum *(build draft)* | 1 AP | Reach, 1 free square | — | — | — | — | — | Storm Drum |
| Set Clay Urn *(build draft)* | 1 AP | Reach, 1 free square | — | — | — | — | — | Clay Urn |
| Lay Spikes *(build draft)* | 1 AP | Reach, 1 square | — | — | — | — | — | Spike Trap (walkable) |
| Lay Vortex *(build draft)* | 1 AP | Reach, 1 square | — | — | — | — | — | Vortex Trap (walkable) |
| Immovable | — | self | — | — | always: ignores push and pull | — | — | — |
| Battle Trance *(experiment)* | 1 AP, once per battle | self | — | — | AP +1 for 2 rounds | — | — | — |
| Time Split *(experiment)* | 3 AP, once per battle | self | — | — | one more turn in the next round | — | — | — |


- **Catalogue scope:** 6 movement skills, 4 Strikes, 6 that create ground (three of them also a zone), 3 that create a push or pull zone, 9 that create a prop (two of them a trap; seven are build drafts of 2026-11-14 on user direction, six of which sit in the fifth kit slots of §10), 1 passive, 2 experiment self buffs: 31 slotted skills plus Step. Runtime Resource counts may differ (§7); they do not define approved content.
- **“Where” reads as one shape** ([§8.1](#81-shapes)): a base shape around the user, or the number of squares of a free shape that the player arranges before the battle; “default” names the authored arrangement.
- **Shove costs 1 AP on its card.** Until 2026-11-15 the build charged a Strike the AP of its shape, so Shove played at 2 AP in every run up to S030.
- **A zone that only changes stats comes along with something else** *(user decision after first play, 2026-11-13: such zones went unused, the fight for the Dragon Veins decides)*: no skill creates only a stat zone. Mire rides on Gloom Rift, Slowing on Thornbed; the skills Mire and Tailwind are archived (the Tailwind zone is in the data, unused).
- **Retired with Surges and their marker traps** (archived files): Tidal Shell, Spring Burst, Ambush Rift and the earlier Surge forms of Gloom Rift, Cinder Dive and Coiling Rift; with height: Raise Ground; with the role split: the shield and healing zone skills.
- **Major Surges and Signature skills** have no content and no rule in this model (T32).
