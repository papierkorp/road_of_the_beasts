# GDD — SKILLS
*Working Draft · companion specifications: [Monsters](gdd_monsters.md) (what a monster is), [Battle System](gdd_battle.md) (how a fight works), [Overworld & Meta](gdd_overworld.md) (the world around it) · source of truth for everything that defines a monster skill*


## Scope and Status

- **Ownership:** this file owns every monster skill rule and every concrete skill: kit and access (§1), the skill card (§2), what a skill does itself (§3), what it creates (§4), value and prices (§5), slot development (§6), data and validation (§7), Strike shapes, Kin effects and movement kinds (§8), passives (§9), the kits of the nine monsters (§10) and the skill list (§11). Monster identity, stats, Kins, roster and growth stay in [gdd_monsters.md](gdd_monsters.md).
- **Boundary:** gdd_battle owns turns and events, the board, **what grounds, zones and props do and when**, and damage, displacement and collision. gdd_overworld owns tamer skills, loadout and meta logistics.
- **Status:** the skill-card form (§2) and reshape principles are decided ([temp_todo.md](temp_todo.md) T40). First human play and feedback exist; skill content, kits and numerical values remain **working drafts, not priced or systematically gameplay-validated**. Bot evidence through S024 and automated checks do not approve prices, content or balance (T02/T13). Surges, traps, height, the air layer and their price sheets are no longer active design.
- **Open rules:** a missing rule grants no default; open decisions and tasks live only in [temp_todo.md](temp_todo.md) (T02, T05, T06, T10, T11, T40).
- **Section references:** `§n` without a file name means this file.


## 1. The Kit

```
Monster = Step (always, no slot)
        + 4 slots, each an active skill or a passive, at least one active
          — Epic+ get a 5th, passive-only slot (Monsters §5.1)
```

- **Slots:** all 4 open on day one. **Step** (1 square, 1 AP, slot-free) is the weakest movement, for monsters without a movement skill. No skill is mandatory, not even a Strike or a movement; the same skill may sit in two slots, each copy with its own usage count ([§2](#usage-and-repetition)).
- **The player shapes the kit:** which monster carries which skills is a decision of the player ([§6](#6-slot-levels-development-and-replacement)); the kits of §10 are working starting points, not validated defaults.
- **Limits:** the species' learnable list and Kin lock-outs ([Monsters §3.1](gdd_monsters.md#31-kin-table), [§8](#8-strikes-and-movement)). Which skills a species may learn is content work that does not exist yet (T11); the kits of the build ignore Kin access.
- **Species-specific and Signature skills** are ordinary skills with restricted access, not a mechanical kind of their own; Signature access stays Legendary/progression-bound ([Monsters §5.1](gdd_monsters.md#51-monster-rarity)) with no decided content (T32).


## 2. The Skill Card

**Status:** decided by the user on 2026-11-13 as the form of every skill ([Battle §1.2](gdd_battle.md#12-battle-design-pillars)). Numbers are working values, nothing is priced.

**A skill only delivers.** It has a cost and a place, it may strike a neighbour, move its user or act on its user, and it **creates ground, a zone or a prop**. What a ground, a zone or a prop does, and when, is written **once**, in its own definition ([Battle §4](gdd_battle.md#4-battlefield)); a skill only names it. There are **no Surges and no traps** *(user decision 2026-11-13)*: damage at range comes from ground, immediate damage only from a Strike.

| Part of the card | Content |
|---|---|
| **Cost** | AP · use (any number, once per round, once per battle); a passive has none |
| **Where** | a Strike: neighbouring square and its shape · a movement: its path · a created thing: anchor (within Reach, line from the caster, next to the caster) and shape (1 square, line 2–3, block 2×2, angle, cross), freely rotated · an effect on the user: self |
| **Strike** | no · or damage (at most 2) and push 1, now |
| **Movement** | no · or the path kind (walks, straight line, any path), what it passes over, the distance (the Movement stat) and a push on landing |
| **On itself** | no · or a timed effect on the user (self buff) · or a lasting one (passive) |
| **Creates ground** | no · or which ground |
| **Creates zone** | no · or which zone, for how many rounds |
| **Creates prop** | no · or which prop |

- **What the created things do:** ground acts at a moment (on entering, on leaving, at the end of the occupant's turn, at the end of the round) and lasts 2 rounds when laid in battle; a zone acts while a monster stands inside (stat changes; push or pull at the end of its turn); a prop blocks the way and acts when destroyed. Ground acts as long as it lies; there is no ground that acts once and vanishes *(user decision 2026-11-13)*.
- **Combinations:** a Strike may create ground or a zone on the struck squares; a movement may create them on the squares it left; a skill that neither strikes nor moves may create any of the three, also two at once. **Direction of a push zone:** cast alone it is chosen with the cast; left by a skill that also creates something else it points where the placement is turned (rotation); left by a Strike it points in the Strike's direction, left by a movement the way the monster went.
- **Every effect hits everyone on its squares,** friend and foe; being pushed or pulled counts as movement.
- **Guideline, not a duty:** a kit skill does one thing itself or creates one thing, at most two; Step and Jab stay plain. **A zone that only changes stats is never a skill of its own:** it comes along with ground, a push or pull, or a Strike *(user decision 2026-11-13)*.
- Effects on AP or turns per round are rare and expensive and carry the content status `experiment`.


### Usage and Repetition

| Use | Meaning |
|---|---|
| any number | no cap beyond AP |
| once per round | one use of this equipped copy in the global battle round; extra turns within the round do not reset it |
| once per battle | one use of this equipped copy in the battle |

- **Per equipped copy:** two copies of one skill in two slots each have their own count and each cost their AP.
- **A use counts when the skill is used,** whatever it then achieves; an illegal attempt spends neither AP nor a use. Later effects of what the skill created (a zone pushing at a turn end) are no further uses.
- No generic multi-round cooldown exists.

### Place, Shape and Rotation

- **Strike:** a shape around the user ([§8](#8-strikes-and-movement)); the player picks the direction.
- **Movement:** the path of the user; the distance is the Movement stat ([§3](#3-what-a-skill-does-itself)).
- **Something created:** an anchor square **within Reach** (board distance from the user), **next to the caster**, or **a line from the caster**, and a shape of 1–5 squares. The player may **turn the shape in quarter turns** *(build rule 2026-11-12: free rotation for everyone)*. All squares must lie on the board; a square that cannot take what the skill creates stays as it is ([Battle §6.2](gdd_battle.md#62-payload-resolution)).
- **Reach** applies to every skill that creates something at a distance; a Strike does not use it.
- **No sight rule:** nothing blocks choosing a square.
- **Everything is previewed** before the player confirms.


## 3. What a Skill Does Itself

Three things happen at the skill, not on the square: a Strike, the user's own movement, and an effect on the user. Everything else is created on the board (§4).

### Strike

- **Now, next to the user:** a Strike hits every monster and prop in its shape, friend and foe; it is the only immediate damage in the game ([Battle §6.1](gdd_battle.md#61-the-damage-law)).
- **Damage:** at most 2 per struck monster; a Strike may also deal 0 and only push (Shove).
- **Push** *(build rule 2026-11-12)*: every Strike pushes each struck monster on a neighbouring square 1 square away from the striker, along its own offset (all eight directions); monsters on farther squares of the shape are damaged but not moved. Collision and ground effects follow [Battle §6.3](gdd_battle.md#63-collision)/[§6.4](gdd_battle.md#64-displacement).
- **One hit per monster** per use, however many squares of the shape it covers.
- **Kin effect:** the Kin of the striker adds its effect ([§8](#8-strikes-and-movement)).
- **A Strike may create ground or a zone** on the squares it struck (§4); it creates no prop.

### Movement

- **Step:** 1 square, 1 AP, every monster.
- **Movement skill:** the user moves up to its **Movement stat** in squares *(build rule 2026-11-13: every movement skill uses the full stat)*; the skill sets the **path kind** and **what it passes over** ([§8](#8-strikes-and-movement)). Walking costs 2 movement to enter Rubble; the other path kinds ignore movement costs.
- **Every square entered and left counts** for ground ([Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed)); a path over other squares touches only the landing square.
- **On landing** a movement skill may push: the monster ahead, or all eight neighbours ([§8](#8-strikes-and-movement)).
- **A movement may create ground or a zone on the squares it left** (§4).
- `slow` and `haste` change the distance of movement skills, never of Step.

### Effect on the User

- **Self buff:** a timed effect on the user for N rounds ([Battle §4.5](gdd_battle.md#45-lifecycles)); the same buff used again refreshes and never stacks.
- **Passive:** a lasting effect without cost; candidates: [§9](#9-passives).
- **Effects available:** initiative, Movement and Reach up; as **experiment** *(user decision 2026-11-13: rare and expensive; content status `experiment`)*: AP +1 and one more turn in the next round. A skill cannot place an effect on another monster: what reaches others goes through the board.


## 4. What a Skill Creates

A skill creates **ground**, a **zone** or a **prop** on its squares. What each of them does is defined once: ground in [Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed), zones in [§4.6](gdd_battle.md#46-zones-effects-rules--opposites), props in [§4.10](gdd_battle.md#410-prop-catalogue-and-damage). The skill only names the type.

| Created | Lasts | May be created by | Not possible |
|---|---|---|---|
| **Ground** | 2 rounds | a placed shape · a Strike, on the struck squares · a movement, on the squares it left | on Voidscar or a Dragon Vein (a prop on the square does not prevent it) |
| **Zone** | the rounds the skill names (2 in the build) | a placed shape · a Strike · a movement | — (on a prop square it waits) |
| **Prop** | until destroyed | a placed shape of 1 square | on an occupied square; by a Strike or a movement |

- **Two at once:** a skill that neither strikes nor moves may create two things together, for example ground and a zone on the same squares (Coiling Rift: Blight and Void Pull).
- **Order:** what a skill creates lands after its damage and displacement ([Battle §6.2](gdd_battle.md#62-payload-resolution)): props, then ground, then zones.
- **Ground under a monster** does not count as entering it; it acts at its next moment. This makes Binding Vines the one thing a skill can lay directly under an enemy with effect.
- **Direction of a push zone:** [Battle §4.6](gdd_battle.md#46-zones-effects-rules--opposites).
- **Levels:** the same hazard ground laid again gains a level (max II); the same zone cast again gains a level (max III) and refreshes.
- **Every effect hits everyone** on its squares, friend and foe; own ground and zones bind the caster too.
- **Not in the game:** squares that act once and vanish (the earlier trap; parked idea), and damage or healing by a zone.


## 5. Value and Prices

**Status: open.** No skill, ground, zone or prop has a price, and nothing checks a monster against a budget *(user directions 2026-11-12/13: skill and stat calculation are found through play and simulation, together with the rules)*. The price sheets of the earlier model (construction points, AP-efficiency scale, component prices for Surges, timers, Mountains and air coverage) were removed with that model. The field `internal_calc_cost` of the Resource files still holds numbers of those sheets for older records and −1 for everything built since; it is an authoring note and no rule reads it.

**Principles that stay** *(earlier user decisions)*:
- **One budget idea:** a skill is paid for with its AP cost and its use limit; a stronger skill costs more AP or may be used less often. No skill rarity.
- **A complete kit at original AP:** development (§6) never forces a higher AP cost on a skill.
- **Monster stats and skills are priced apart** ([Monsters §2.2](gdd_monsters.md#22-frame-budget-level-ups)), but their interactions and thresholds for possible actions and action combinations are validated together. Calculators describe gameplay-derived balance rather than dictate it.

**Evidence boundary:** current bot observations (S020–S024) depend on kits, maps, bot policy and replacement opportunity costs; they establish neither a universal skill ranking nor component/stat prices. Progression proxies are not approved starts or slot upgrades. Current push/pull zone skills, including Bog, normally cost **1 AP**; the **2-AP ZONE PUSH/PULL override is an experiment**, not a monster-AP change or an adopted price. Three Dragon Veins remain the 7×7 default; the one-vein control is test-only. Results and pending human review belong to [temp_todo.md](temp_todo.md) T13, with pricing under T02 and stat/progression validation under T03.



## 6. Slot Levels, Development and Replacement

**Confirmed: permanent slot development**, gained only at **advancement steps** ([Monsters §5.3](gdd_monsters.md#53-monster-progression-the-18-steps)): a stage breakthrough (or the listed later sub-tier steps) offers the individual monster the option to develop one skill slot. There is no separate experience currency, no spending outside an advancement and no physical evolution.

- **Ownership:** a development step develops one slot on one monster, not the skill or the species globally. The player picks from options written for the equipped skill, never free components.
- **Replacement:** outside expeditions a slot may take another skill of the species' learnable list with a **relearning pill**; the slot keeps its development. Pill acquisition, recipe and price: T05/T16/T31.
- **Levels 1–3** per slot; how steps map to levels and what a level allows is undecided (T05).
- **What a development may change** *(candidate list on the skill card, not approved content)*: a larger or other shape, a longer zone, a movement that passes over more, a second thing created. **Never:** more damage than the caps of [Battle §6.1](gdd_battle.md#61-the-damage-law), lower AP, more Reach.
- **AP policy:** every skill has a complete path at its original AP; a bigger option may cost more AP, shown before selection, and is never the only path.
- **Useful from the start:** starting AP must support the intended starter kit without a mandatory stat purchase. Slot development expands an already viable kit, with several useful routes and no compulsory first upgrade; it must not repair an unusable starting skill.
- **Progression validation:** test the starting kit, then each single slot upgrade, then combinations, including permanent stat upgrades and the action thresholds they change ([Monsters §2.2](gdd_monsters.md#22-frame-budget-level-ups)). A slot upgrade develops that slot; a permanent stat upgrade changes the monster's stats. Keep their ledgers separate while validating their interaction.
- **Where and when:** [Overworld §6.3.2](gdd_overworld.md#632-permanent-skill-slot-development-confirmed).


## 7. Data and Validation

- **One Resource file per record** under `godot/data`: `skills/`, `monsters/` (species, reference stats and kit), `grounds/`, `zones/`, `props/`, `tamer/`. A new file is new content.
- **Content status** on skills, monsters, grounds, zones and props: `approved` (none yet), `draft` and `experiment` enter the regular build; `test`, `simulation` and `archived` do not. `ContentStatus.in_game`, used by `BattleContent` and `GameData`, is the shared filter. A runtime status is not design or balance approval.
- **Simulation-only resources:** `godot/data/skills/{mist_step,receding_blow,cloudstep_token,raise_reed_screen}.tres` and `godot/data/props/reed_screen.tres` carry `simulation`; they are excluded from regular kits and the builders' in-game choices. They remain visible in the unfiltered debug overview; **In game only** hides them. Discovery runs substitute them only for those runs. They are not approved skills, items or slot-development options and do not extend §11; experiment scope and follow-up: [godot/README.md](../godot/README.md), [temp_todo.md](temp_todo.md) T13 (S023).
- **Automated content checks:** a monster of the game holds one to four skills of the game; a skill names existing grounds, zones and props; game content must not reference excluded records. These checks are not runtime budget enforcement or gameplay validation.
- **Overview** (menu → Overview): one table each for skills (as cards), monsters, grounds, zones and props, read from these files. **In game only** is initially off; the unfiltered debug view includes excluded records without making them playable.
- **Hover card in battle:** a skill button shows what the skill does itself, then per created ground, zone or prop one line “creates …” and below it what that thing does, taken from its definition.
- **Skill builder** (Overview → Skill builder): puts a skill together from the parts of the card, or draws a random one, shows the card and what the created things do, writes it to `godot/data/skills` with the status `experiment` and can put it into a kit slot of a monster. It enforces the fixed rules (damage only by a Strike, at most 2; no prop from a Strike or a movement) and checks no price. Self buffs and the passive Immovable can be built; other passives cannot.
- **Monster builder** (battle prototype → Monster builder, also in the Overview): creates a monster or changes an existing one: name, Kin, the six stats (HP 3–10, initiative, Movement 1–5, Reach 2–4, turns per round 1–3, AP 2–5) and the four kit slots from the skills of the game; “New skill” opens the skill builder and returns. It writes `godot/data/monsters/<id>.tres` (a new monster with the status `experiment`), after which the monster stands in the team choice. It checks only that the kit holds an active skill; no price, budget, frame or Kin access.
- **Skill generator** (`godot/tools/sim.gd --variant genskills=N`): draws random cards as in-memory skills so that bot runs report a win rate per part.


## 8. Strikes and Movement

Kin identity itself stays in [Monsters §3.1](gdd_monsters.md#31-kin-table).

### 8.1 Strike Shapes

A Strike is a **shape around the body** plus the **Kin effect** of the striker. A bigger shape costs more AP. The player picks the direction when striking (8 directions, no facing).

| Squares | AP |                          Shape                          |                  Name                  |
|---------|----|---------------------------------------------------------|----------------------------------------|
|       1 |  2 | next to `M`, any of the 8 directions                    | **Jab**                                |
|       2 |  3 | 2 forward in a straight line (4 directions)             | **Thrust**                             |
|       2 |  3 | 2 forward on a diagonal (4 diagonals)                   | **Diagonal Thrust**                    |
|       2 |  3 | next to `M` in the chosen direction **and** the opposite side | **Pincer**                       |
|       3 |  3 | the 3 squares in front of `M` (a row, or on a diagonal the wedge `(dx,0)`, `(dx,dy)`, `(0,dy)` for direction `(dx,dy)`) | **Arc**                        |
|       4 |  3 | the 4 neighbours of `M`                                 | **Whirl**                              |
|       4 |  3 | the 4 diagonals of `M`                                  | **Cross**                              |
|       8 |  4 | all 8 squares around `M`                                | **Storm**                              |
|       6 |  5 | the 3 squares in front of `M` and the 3 behind those (4 straight directions only, *user decision 2026-11-11*) | **Cleave**                             |
|       8 |  5 | 2 forward in each of the 4 directions                   | **Long Whirl**                         |
|       8 |  5 | 2 forward in each of the 4 diagonals                    | **Long Cross**                         |

```
  x       x          x           x      x x x
  M       x        x             M        M
          M      M               x
Jab     Thrust   Diag Thrust   Pincer   Arc

  x     x   x   x x x
x M x     M     x M x
  x     x   x   x x x
Whirl   Cross   Storm

             x        x       x
             x          x   x
x x x    x x M x x        M
x x x        x          x   x
  M          x        x       x
Cleave   Long Whirl   Long Cross
```
`M` is the monster, `x` a hit square. Straight shapes are drawn for "up", diagonal ones for "up-right"; the player turns them to any of the 8 directions.

**Offsets per orientation** *(derived from the table above, adds no shape; origin `M = (0,0)`, direction `d = (dx, dy)`, `d⊥ = (|dy|, |dx|)` for straight `d`)*:

| Shape | Legal directions | Hit offsets |
|-------|------------------|-------------|
| Jab | 8 | `d` |
| Thrust | 4 straight | `d`, `2d` |
| Diagonal Thrust | 4 diagonal | `d`, `2d` |
| Pincer | 8 | `d`, `−d` |
| Arc | 4 straight / 4 diagonal | straight: `d`, `d + d⊥`, `d − d⊥`; diagonal: `(dx,0)`, `d`, `(0,dy)` |
| Whirl / Cross / Storm | symmetric | the 4 neighbours / the 4 diagonals / all 8 |
| Cleave | 4 straight (decided) | `k·d⊥ + d` and `k·d⊥ + 2d` for `k ∈ {−1, 0, 1}` |
| Long Whirl / Long Cross | symmetric | `c` and `2c` for each of the 4 neighbours / 4 diagonals `c` |

- **Every shape hits allies too.** A 2×2 monster starts the shape at a chosen covered square.
- **Draft Strikes:** Jab, Thrust, Shove (a Jab without damage) and Thorn Lash (a Jab that leaves Thornbed). Other shape skills are archived; user-authored experiments may still use those shapes (§7/§10), without approving them as defaults.
- **AP decides when:** AP 2 is the ceiling until Core ([Monsters §2.3](gdd_monsters.md#23-stat-ceilings-per-stage)), so early Strikes are Jabs.

**Kin effects** (on top of damage and push):

| Kin | Strike | Effect |
|---|---|---|
| Beast | Bite | none *(user decision 2026-11-11: the baseline)* |
| Winged | Dive | then the striker retreats 1 square for free, opposite the centre of the hit shape, once per use |
| Scaled | Tail Sweep | pushes the target 1 square in a **chosen** cardinal direction instead of straight away |
| Swarm | Gnaw | props take double (4) |
| Spirit | Siphon | target −1 initiative next round |
| Ancient | Slam | *(none any more: it destroyed the Mountain under the target; a new effect is open, T06)* |

**Self retreat** (Winged): one square opposite the centre of the hit shape; it exists only for shapes whose centre lies on one of the eight directions (Jab, Thrust, Diagonal Thrust, Arc, Cleave). It happens once per valid use, whether or not anything was hit, after the Strike has resolved; if the square is not free, the striker stays and nothing else happens. `R` marks the square:

```
       x               x                                   x x x
x      x             x          x x x      x x             x x x
M      M           M              M        M x               M
R      R         R                R      R                   R

Jab    Thrust    Diag Thrust    Arc      Arc (diagonal)    Cleave
```

- **No retreat cell:** Pincer, Whirl, Cross, Storm, Long Whirl and Long Cross (centre is the attacker itself); Cleave is cardinal-only, like Thrust (its diagonal counterpart would be a separate shape): a diagonal Cleave does not exist (user decision 2026-11-11).
- The Winged Strike (Dive, below) uses this same retreat cell *(user decision 2026-11-11)*.

- **2×2 bodies** *(user decision 2026-11-10; none in the build)*: a 2×2 target is pushed along the mean offset of its struck neighbouring squares if that lies on one of the eight directions, otherwise it is damaged but not pushed.

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

- All cover up to the Movement stat; Run costs 1 AP, the others 2 AP *(build test since 2026-11-13: the earlier distance deductions are gone; [simulation_log.md](simulation_log.md) S016)*.
- **Archived movement skills:** Burrow, Phase, Blink.
- **Kin access to movement kinds** (Run for all but Spirit, Leap for Beast, Glide for Winged, and so on) was part of the earlier draft; the kits of the build ignore it, and a new access table is content work (T11).


## 9. Passives

- **A passive occupies a normal kit slot,** costs no AP and is an effect on its bearer ([§3](#effect-on-the-user)). 1 active + 3 passives is legal but weak.
- **In the build:** **Immovable** (ignores push and pull); no current kit of the nine equips it (§10).
- **Candidates from the earlier draft that still fit** *(not approved, no numbers; T11)*: Counterweight (allies orthogonally next to it cannot be pushed or pulled) · Thick Hide (Strike and collision damage it takes −1) · Crashlander (collision damage it takes −1) · Sure-footed (ignores `slow`) · Clear Mind (ignores `drain_init` and `drain_range`) · Heatproof / Thornwalker / Void-touched (ignores Lava / Thornbed / Blight) · Scavenger (heals 1 when a prop within its Reach is destroyed) · Purifier (enemy zones next to it lose 1 round at the end of a round) · Overgrowth (its zones start at level II) · Turret (cannot move, Reach +1).
- **Dropped with the reshape** (their object is gone): Highlander (Mountain), Skittish, Momentum, Vengeful and Bulwark (Surge damage), Adaptive (rotation is free for everyone), Phasing (a movement kind now).
- **Still unresolved from before:** passives that lower AP costs (Pack Hunter, First Blood) conflict with “no AP reduction”; Frenzy (+1 shape square at 1–2 HP).


## 10. Kits of the Nine Monsters

**Status: current prototype interface, not approved default kits.** The table mirrors the nine `godot/data/monsters/*.tres` Resources, including manual user experiments; it is not a second skill catalogue. First human play exists; pricing, Kin access and systematic validation remain open (T02/T11/T13). Stats: [Monsters §4.1](gdd_monsters.md#41-first-roster-draft--9-monsters).

| Monster | Kin | Slot 1 | Slot 2 | Slot 3 | Slot 4 | Idea |
|---|---|---|---|---|---|---|
| **Blaze Tiger** | Beast | New Skill (`new_skill`, experiment) | Jab | Fire Trail | Lava Field | current user-authored first slot; remaining skills burn the path and a target area |
| **Ember Hawk** | Winged | Glide | Jab | Cinder Dive | Gale | two short turns from round 2: glides anywhere, strikes, burns a line, blows enemies back |
| **Dusk Moth** | Winged | Run | Gloom Rift | Void Pull | Snare | works from long Reach: pins with Binding Vines, lays dulling Blight, pulls others in |
| **Forge Golem** | Ancient | Jab | Thrust | Set Gong | Gale | holds a square, strikes two deep, sets a Gong and blows a line of enemies off their squares |
| **Gloom Wolf** | Beast | Run | Thorn Lash | Shove | Plant Bamboo | leaves thorns where it strikes, plants a spiky stand and shoves enemies into it or off a Dragon Vein |
| **Grove Wisp** | Spirit | Quake Leap | Jab | Gale | Thornbed | leaps into a group and scatters it, blows a line back, lays slowing thorns |
| **Hollow Serpent** | Scaled | Run | Jab | Coiling Rift | Thornbed | lays Blight that pulls enemies together and slowing thorns around them |
| **Moss Turtle** | Scaled | Run | Bog | Void Pull | Shove | slow wall that moves others: drags into the Bog, pulls together, shoves off a Dragon Vein |
| **Thorn Mites** | Swarm | Glide | Jab | Thornbed | Void Pull | two turns from round 2: lays slowing thorns and pulls enemies across them |

- **Confirmed kit requirement: at least one skill that pushes or pulls without a Strike** *(user decision after first play, 2026-11-13: a sturdy monster on a Dragon Vein could not be removed; the user chose more displacement in the kits over a Shove for everyone)*. The Forge Golem no longer carries Immovable for the same reason; the passive stays in the game.
- **Manual experiment boundary:** Blaze Tiger currently equips the user's `godot/data/skills/new_skill.tres` in slot 1 instead of draft Headbutt. It is an `experiment` Arc Strike, not an approved replacement in the default design; the current kit therefore does not meet the non-Strike displacement requirement above. Preserve authored data rather than silently reverting or adopting it. Builders can rewrite Resources without checking budgets or Kin access; see [godot/README.md](../godot/README.md#content-status-and-build-rules) and [temp_todo.md](temp_todo.md) T13.
- **Validation:** current-kit observations and S020–S024 limitations remain under T13; no historical win-rate ranking is a kit rule or content approval.
- **Species learn lists** and further species: [Monsters §4](gdd_monsters.md#4-roster); T11/T12.


## 11. Skill List

**Working content draft,** informed by first human play but not priced or systematically gameplay-validated. This table is the authored draft catalogue, not every Resource in the prototype: additional user `experiment` records are not automatically adopted, and `simulation` records remain excluded (§7). Highest single hit: 2 (working value). What the named grounds, zones and props do: [Battle §4.6](gdd_battle.md#46-zones-effects-rules--opposites), [§4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed), [§4.10](gdd_battle.md#410-prop-catalogue-and-damage).

| Skill | Cost | Where | Strike | Movement | On itself | Ground | Zone | Prop |
|---|---|---|---|---|---|---|---|---|
| Step *(every monster)* | 1 AP | neighbouring square | — | 1 square | — | — | — | — |
| Run | 1 AP | path | — | walks, Movement | — | — | — | — |
| Leap | 2 AP | path | — | straight line over everything | — | — | — | — |
| Glide | 2 AP | path | — | any path over props and monsters | — | — | — | — |
| Headbutt | 2 AP | path | — | straight line; pushes the monster ahead | — | — | — | — |
| Quake Leap | 2 AP | path | — | straight line over everything; pushes all eight neighbours on landing | — | — | — | — |
| Fire Trail | 2 AP | path | — | straight line over monsters | — | Lava on the squares left | — | — |
| Jab | 2 AP | neighbour, 1 square | 2 damage, push 1 | — | — | — | — | — |
| Thrust | 3 AP | neighbour, 2 in a line | 2 damage, push 1 | — | — | — | — | — |
| Shove | 1 AP | neighbour, 1 square | push 1 | — | — | — | — | — |
| Thorn Lash | 2 AP | neighbour, 1 square | 2 damage, push 1 | — | — | Thornbed | — | — |
| Snare | 2 AP | Reach, 1 square, also under a monster | — | — | — | Binding Vines | — | — |
| Lava Field | 1 AP | Reach, block 2×2 | — | — | — | Lava | — | — |
| Thornbed | 1 AP | Reach, angle | — | — | — | Thornbed | Slowing | — |
| Gloom Rift | 1 AP | Reach, line 3 | — | — | — | Blight | Mire | — |
| Cinder Dive | 1 AP | line of 3 from the caster | — | — | — | Lava | — | — |
| Coiling Rift | 2 AP | Reach, 4 squares | — | — | — | Blight | Void Pull | — |
| Gale | 1 AP | Reach, line 3 | — | — | — | — | Gale | — |
| Void Pull | 1 AP | Reach | — | — | — | — | Void Pull | — |
| Bog | 1 AP | Reach | — | — | — | — | Bog | — |
| Plant Bamboo | 1 AP | Reach, 1 free square | — | — | — | — | — | Bamboo Stand |
| Set Gong | 1 AP | Reach, 1 free square | — | — | — | — | — | Bronze Gong |
| Immovable | — | self | — | — | always: ignores push and pull | — | — | — |
| Battle Trance *(experiment)* | 1 AP, once per battle | self | — | — | AP +1 for 2 rounds | — | — | — |
| Time Split *(experiment)* | 3 AP, once per battle | self | — | — | one more turn in the next round | — | — | — |


- **Catalogue scope:** 6 movement skills, 4 Strikes, 6 that create ground (three of them also a zone), 3 that create a push or pull zone, 2 that create a prop, 1 passive, 2 experiment self buffs: 24 slotted skills plus Step. Runtime Resource counts may differ (§7); they do not define approved content.
- **A zone that only changes stats comes along with something else** *(user decision after first play, 2026-11-13: such zones went unused, the fight for the Dragon Veins decides)*: no skill creates only a stat zone. Mire rides on Gloom Rift, Slowing on Thornbed; the skills Mire and Tailwind are archived (the Tailwind zone is in the data, unused).
- **Retired with Surges and traps** (archived files): Tidal Shell, Spring Burst, Ambush Rift and the earlier Surge forms of Gloom Rift, Cinder Dive and Coiling Rift; with height: Raise Ground; with the role split: the shield and healing zone skills.
- **Major Surges and Signature skills** have no content and no rule in this model (T32).
