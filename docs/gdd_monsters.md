# GDD — MONSTERS
*Working Draft · companion specifications: [Skills](gdd_skills.md) (what a monster can do), [Battle System](gdd_battle.md) (how a fight works), [Overworld & Meta](gdd_overworld.md) (the world around it) · source of truth for everything that defines a monster itself*

---

## 1. Overview

Every monster definition lives here, once; every skill definition lives in [gdd_skills.md](gdd_skills.md). The other files link to these two.

|                                        Question                                        |       File       |
|----------------------------------------------------------------------------------------|------------------|
| What is a monster? Stats, Kins, roster, progression, rarity                              | this file        |
| What can a monster do? Skills, passives, Strike and movement tables, costs, development | gdd_skills.md    |
| How does a fight run? Turns, squares, zones, ground, generic damage resolution                | gdd_battle.md    |
| How do you catch, house and lose monsters? Tamer skills, items, economy, the world      | gdd_overworld.md |

### 1.1 Species and Individual

A monster the player owns is **two layers**: a fixed *species* and a unique *individual*.

```
SPECIES  (data file, shared by all individuals — §4.1)
  Kin · descriptive themes (free-form, no mechanical type) · default kit
  (up to 6 slots, active or passive) · learnable skills · blurb · art
  Skills are cards ([Skills §2](gdd_skills.md#2-the-skill-card)); the species only lists which it may learn.

INDIVIDUAL  (one per monster the player owns or meets in the wild)
  stat shape      bulwark | skirmisher | swift | caster
  stats           rolled inside the shape's frame, then spent by the player (§2.2)
  rarity          Normal | Rare | Epic | Legendary
  stage + sub-tier + XP
  slot development  permanent development per skill slot, gained at advancement steps ([Skills §6](gdd_skills.md#6-slot-levels-development-and-replacement), §5.3)
  slot loadout    equipped skill and its selected upgrades per slot; development survives skill replacement
  artifact(s)     socketed passives (gdd_overworld §6.7)
  current HP      persists between battles of an expedition
```

- **Stat shape is individual, not species-wide.** Two Blaze Tigers can be a fast skirmisher and a two-turn swift one: same kit, different playstyle, collection depth without new art.
- Wild/newly caught monsters roll shapes weighted by **Kin lean** (§3.1: Winged → swift or caster, Ancient → bulwark, …); rare off-lean rolls are prized finds. §4.1 shows reference individuals: typical Core Formation rolls.
- **Every stat is paid for** (§2.2). Shape allocates a fixed budget: speed, extra turns and Reach cost HP. No shape is meant to be strictly better; whether that holds is measured, not assumed (§2.2).

### 1.2 Monster Sheet

```
NAME | Size (1x1; 2x2 removed from the scope)
──────────────────────────────────
Kin           Beast | Winged | Scaled | Swarm | Spirit | Ancient
Themes        free-form description, not a mechanical type or skill restriction
Rarity        Normal | Rare | Epic | Legendary
Stage         Qi Gathering ... Sovereign (capped by player stage)

HP
Pace          position in the queue; the whole number of the current value = Stamina recovered per round
Stamina       pool that pays for movement skills (Step needs none)
Reach         how far away a skill may create ground, a zone or a prop (Strikes use none)
TurnsPerRound
AP            action points per turn
              (ranges and stage ceilings: §2.1, §2.3)

SKILLS: Step (no slot, 1 AP) + up to 6 slots, active or passive, at least one active ([Skills §1](gdd_skills.md#1-the-kit))
```

The battle only ever sees this finished sheet.

### 1.3 Monster Identity — The 6 Axes

```
1. STAT SHAPE   bulwark / skirmisher / swift / caster   (per individual monster, rolled with the Kin's lean — §1.1)
2. THEMES       free descriptive motifs; no fixed aspects, replacement element types or attunement
3. KIN          creature type → Strike effect, stat lean, which skills it may learn
4. KIT          up to 6 slots (active or passive, ≥ 1 active), chosen by the player from the species' learnable list ([Skills §1](gdd_skills.md#1-the-kit))
5. PASSIVE      the rule-bender — biggest personality driver
6. SIZE         1x1 (2x2 removed from the scope, 2026-11-14)
```

**A shared construction kit builds a monster** — not everything is invented from scratch per monster:

|           Layer           |                                  Decides                                  |                                  Example                                   |
|---------------------------|---------------------------------------------------------------------------|----------------------------------------------------------------------------|
| **Kin** (body)            | Strike effect, stat lean, skill access                                    | Beast bites and is fast; a Winged Strike retreats; a Scaled one picks its push direction ([Skills §8](gdd_skills.md#8-shapes-and-movement)) |
| **Themes** (description)  | free-form flavour and visual identity, no mechanical eligibility rules   | fire, moss, shadows, storms — motifs may mix freely                        |
| **Species** (the monster) | its default kit of 4 slots and its learnable list ([Skills §10](gdd_skills.md#10-kits-of-the-nine-monsters))        | Blaze Tiger's current prototype kit: [Skills §10](gdd_skills.md#10-kits-of-the-nine-monsters); manual experiments are not approved species defaults |

- **No fixed roles:** Kin is not class (Beast ≠ "damage dealer"); kits determine team function, so two Beasts can play completely differently.
- Build teams from *combinations*: one monster pulls, another Strikes; one lays Binding Vines under a target and another pushes it off them.

**Design test:** one sentence per monster built from its kit. If two monsters read the same, change a skill, a stat or its descriptive theme.

The stat shapes are frames of min–max values per stat, not fixed stats (§2.2).

---

## 2. Stats

### 2.1 The Stats

| Stat | Range | Function |
|---|---|---|
| HP | 1–10 | No defense stat — dead is dead. The highest single hit is 2 ([Battle §6.1](gdd_battle.md#61-the-damage-law)), so a monster with 1 or 2 HP can fall to one hit: that is the buyer's choice *(user, 2026-11-15: a lowest HP of 3 was never a rule)* |
| Pace | 1.0–10.0 | Position in the turn queue ([gdd_battle §2.2](gdd_battle.md#22-pace-and-the-queue)); the whole number of its current value, at least 1, is the Stamina recovered per round ([gdd_battle §2.3](gdd_battle.md#23-action-points-and-stamina)). Counts in points of 0.1; effective minimum 0.1. *The term replaces Initiative (user decision 2026-11-15)* |
| Stamina | 1–10 | Size of the pool that pays for movement skills, 1 or more per square ([gdd_battle §2.3](gdd_battle.md#23-action-points-and-stamina)); Step needs none. *Was the Movement stat (squares per movement skill) until 2026-11-15; its values are carried over untested* |
| Reach | 1–10 | How far away a skill may create ground, a zone or a prop ([Skills §2](gdd_skills.md#place-shape-and-rotation)); Strikes don't use it; the range is wide because boards may grow in the game |
| TurnsPerRound (TPR) | 1–3 | Extra turns: queue entries and Pace penalty in [gdd_battle §2.2](gdd_battle.md#22-pace-and-the-queue) |
| AP | 1–5 | Action points per turn ([gdd_battle §2.3](gdd_battle.md#23-action-points-and-stamina)) |
| Kin / Rarity / Size | — | §3 and §5.1 |

**One fixed range per stat for the whole game, and every stat starts at the lowest value of its range** *(user decisions 2026-11-15)*. There is no free value above the minimum and no ceiling per stage (§2.3): what a monster has above 1 it has paid for (§2.2).

Zones, aura props and self buffs change these values during a fight: effective stats, [gdd_battle §3.1](gdd_battle.md#31-effective-stats).

**Stat value remains open:** every stat should support meaningful decisions. Bot observations depend on kits, maps, opponents and action thresholds; they neither prove a stat has no value nor establish additive prices. First human play exists; systematic gameplay and progression validation remain open ([temp_todo.md](temp_todo.md) T03/T13, including S020–S031).

**Every stat is paid for:** monsters at the same stage/sub-tier have the same points (§2.2). Acting first, possibly several times consecutively, costs HP or Reach; poor turn order buys HP, Reach or AP.

### 2.2 Frame, Budget, Level-Ups

**Section status:** the system below is decided by the user *(2026-11-15: start values, ranges, no ceilings and no unlocks, the price list with the turn formula, 25 points at the start and +5 per step, 110 at the end)*; **every number is an untested starting value** to be tuned through play ([temp_todo.md](temp_todo.md) T03/T13). The build checks no price and no budget. The prices of Pace and Reach are set, not measured; the bots of S026–S030 could not value them.

**Confirmed progression principles:** battle must work from the start; progression expands a viable build rather than repairs it.

- **Viable entry build:** the points of the first step must pay for a monster that works with its starter kit. Since every stat starts at 1, the basics are bought from these points (what a starter kit costs in AP is settled with the skills, [Skills §5](gdd_skills.md#5-value-and-prices)).
- **Meaningful routes:** several stat-development routes must be useful. Validate the starting build, then each single upgrade, then combinations, including interactions with skill-slot development ([Skills §6](gdd_skills.md#6-slot-levels-development-and-replacement)) and thresholds that change which actions or action combinations are possible.
- **Separate ledgers, joint validation:** permanent stat upgrades change the monster's stats; slot upgrades develop a skill slot, not those stats. Stat and skill accounting remain separate, but their gameplay interactions are validated together. Calculators describe balance derived from gameplay; they do not dictate it. The numerical drafts below do not establish entry-build viability or useful upgrade routes.

**The whole calculation is three things:**

```
RANGE   one fixed range per stat, the start is its lowest value (§2.1)
PRICE   every step above the start costs points
POINTS  every monster of a stage and sub-tier has the same number of points; a stage gives nothing else
```

**Prices:**

| Purchase | Price |
|---|---|
| +0.1 Pace | 1 |
| +1 Stamina | 2 |
| +1 HP | 5 |
| +1 Reach | 5 |
| AP 2 / 3 / 4 / 5 | 5 / 10 / 15 / 20 for the step (AP 5 in total: 50) |
| Second turn | 10 + 5 per AP of the monster (AP 2: 20 · AP 3: 25 · AP 4: 30 · AP 5: 35) |
| Third turn | twice the price of the second |

- **The turn price follows the AP** because turns and AP multiply (AP 3 with two turns is six actions per round); it is counted with the AP the monster ends up with, whatever was bought first.
- **Where the ratios come from** *(indications of the random-stat bot series S026–S030, not validation)*: an HP was worth about 4 more team wins in 100 battles, the second turn about 11, AP 3 instead of 2 about 9, a Stamina point about 2; Reach and Pace showed nothing measurable.
- **To watch in play:** two turns stay a little cheaper per action than many AP in one turn (extra turns only come from round 2); a sturdy monster reaches HP 10 at Soul and has only Pace, Stamina and turns to buy afterwards.

**Points per stage and sub-tier:** 25 at the start, **+5 with each of the 18 steps** ([§5.3](#53-monster-progression-the-18-steps)); a step is worth one HP.

| Stage | Lower | Middle | High |
|---|---|---|---|
| Qi Gathering | 25 | 30 | 35 |
| Foundation | 40 | 45 | 50 |
| Core Formation | 55 | 60 | 65 |
| Soul Tier | 70 | 75 | 80 |
| Immortal | 85 | 90 | 95 |
| Sovereign | 100 | 105 | 110 |

- **Why it ends at 110:** HP 10 (45), AP 5 (50) and a second turn at AP 5 (35) cost 130 together. With 110 a Sovereign monster reaches the top in two of these three and never in all; more points would go into actions, not into longer battles, because HP ends at 10 and a hit stays at 2. *Option noted, not chosen:* +10 at the last two breakthroughs (120 at the end).
- **The prices take the place of the unlocks:** with at least HP 3 and Reach 2 a second turn fits from 40 points (Foundation Lower), AP 3 from 30, AP 4 from 45, AP 5 from 65 and a third turn from 80; with a sturdier body each comes about a stage later.
- **Multiplayer mode:** plays with one fixed number of points for every monster (60 fits the present monster files, §4.1).

**Example monsters at the Lower sub-tier** (HP / Pace / Stamina / turns / Reach / AP; every row spends its points exactly):

| Stage (points) | Sturdy | Turns or AP | Fast |
|---|---|---|---|
| Qi Gathering (25) | 4 / 1.0 / 1 / 1 / 2 / 2 | 3 / 1.3 / 2 / 1 / 2 / 2 | 2 / 1.6 / 3 / 1 / 2 / 2 |
| Foundation (40) | 6 / 1.0 / 1 / 1 / 3 / 2 | 3 / 1.0 / 1 / 2 / 2 / 2 | 3 / 1.6 / 3 / 1 / 2 / 3 |
| Core Formation (55) | 8 / 1.3 / 2 / 1 / 3 / 2 | 5 / 1.1 / 3 / 2 / 2 / 2 | 4 / 2.1 / 3 / 1 / 3 / 3 |
| Soul Tier (70) | 10 / 1.0 / 1 / 1 / 3 / 3 | 4 / 1.1 / 3 / 2 / 3 / 3 | 5 / 2.7 / 5 / 1 / 3 / 3 |
| Immortal (85) | 10 / 1.9 / 4 / 1 / 3 / 3 | 7 / 1.1 / 3 / 2 / 3 / 3 | 6 / 2.4 / 4 / 1 / 3 / 4 |
| Sovereign (100) | 10 / 1.1 / 3 / 2 / 3 / 3 | 5 / 1.1 / 3 / 3 / 3 / 2 | 6 / 1.9 / 4 / 1 / 3 / 5 |

**Shapes and the roll:** a monster starts with stats rolled by its stat shape, afterwards the player decides where each step's 5 points go (a free action; unspent points are kept).

| Shape | Feel |
|---|---|
| Bulwark | slow, hard to dislodge; holds ground near a Dragon Vein: most points in HP |
| Skirmisher | gets where it wants first; takes free squares and pushes holders off: Pace and Stamina |
| Swift | more turns from round 2 on, paid with body or speed |
| Caster | weak body, long Reach; works from behind the others |

- *Open (T03):* how a shape splits the points at the roll (the earlier min–max frames and their stage scaling went with the ceilings); the columns of the example table are a first sketch of three of them.
- **Reshape:** pool all points and reroll by the new shape at the same budget; leftovers remain unspent. Level-up spending alone never changes the shape label. Item, ritual location and day-AP: [Overworld §2.6](gdd_overworld.md#26-action-catalog).
- **Stage rule:** monsters cannot exceed the player's stage: the spatial space sustains only what the tamer's qi can feed. *(user decision 2026-11-11)* the cap is the player's **stage**, not the exact sub-tier; §5.3 lists the progression steps within that stage and sets no separate sub-tier cap.

### 2.3 Stat Ceilings per Stage

**There are none** *(user decision 2026-11-15; the earlier table of a highest HP, Pace, Stamina, Reach, TPR and AP per stage is dropped)*. A stage gives points (§2.2) and no ceiling and no unlock: the fixed ranges of §2.1 and the prices are the only limits.

- **Damage never scales by stage** ([gdd_battle §6.1](gdd_battle.md#61-the-damage-law)): Strike (max 2), ground and collision damage stay equal from Qi Gathering to Sovereign.

---

## 3. Kins

### 3.1 Kin Table

> **Kin = what kind of creature it is. Themes describe it freely, without assigning a mechanical type.**

- Kin sets the **Strike effect, the stat lean and skill access**, never damage multipliers. No weakness triangle, element system or attunement. Every monster stands on the ground *(user decision 2026-11-13: no air layer; Winged monsters are ground monsters)*.
- The **species learnable list** determines concrete skill access within Kin and progression restrictions; neither exists as content yet (T11), and the kits of the build ignore Kin access.

| Kin | Body fantasy | Stat lean | Strike effect ([Skills §8.1](gdd_skills.md#81-shapes)) |
|---|---|---|---|
| **Beast** | tiger, ape, wolf | skirmisher, high Stamina | none (baseline) |
| **Winged** | bird, moth, wyvern | swift, caster | retreats 1 square after the Strike |
| **Scaled** | serpent, turtle, drake | bulwark, low Stamina | pushes in a chosen direction |
| **Swarm** | insects, rats | swift (two turns) | props take double |
| **Spirit** | ghost, wisp | low HP, high Pace | target −1 Pace point (−0.1) next round |
| **Ancient** | golem, treant | max HP, one turn | open *(it destroyed Mountains; T06)* |

- **Open with the reshape (T06/T11):** what sets the Kins apart beyond the Strike effect. The earlier table gave them Surge sizes, movement layers, the air layer for Winged and lock-outs from single skills; all of that is gone with Surges, height and the air layer.
- Strike shapes, movement kinds and everything else about skills: [gdd_skills.md](gdd_skills.md).

---

## 4. Roster

### 4.1 First Roster Draft — 9 monsters

**Working draft.** Names, descriptions and shapes are unvalidated; the kits of the build are in [Skills §10](gdd_skills.md#10-kits-of-the-nine-monsters).
- **Reference individuals:** shape belongs to individuals (§1.1). The left column contains calculation examples at **Core Formation High**, each spending 16 points within the draft frames (§2.2–2.3), not current build stats or validated species defaults.

**Prototype interface:** the right column records the nine monsters' current Resource stats under `godot/data/monsters/`; omitted fields inherit `MonsterDef` defaults. The build checks no price, budget or frame. Manual builder edits are experiments, not automatic GDD approval ([godot/README.md](../godot/README.md#content-status-and-build-rules), [temp_todo.md](temp_todo.md) T03/T13). Kits have one owner: [Skills §10](gdd_skills.md#10-kits-of-the-nine-monsters). Lowest HP 3 and highest single hit 2 remain working values; Winged monsters stand on the ground.

| Monster | Kin | Descriptive themes | Shape · HP / Pace / Stamina / TPR / Reach / AP | Current prototype stats (not approved defaults) |
|---|---|---|---|---|
| **Blaze Tiger** | Beast | flame, hunting | skirmisher · 7 / 1.3 / 5 / 1 / 2 / 3 | 5 / **2.2** / 5 / 1 / 2 / 3 |
| **Ember Hawk** | Winged | embers, flight | swift · 5 / 1.4 / 5 / 2 / 2 / 3 | 3 / **2.2** / 5 / 2 / **2** / 2 |
| **Forge Golem** | Ancient | forge, stone | bulwark · 8 / 1.2 / 1 / 1 / 3 / 3 | 8 / 1.0 / 1 / 1 / 3 / 3 |
| **Moss Turtle** | Scaled | moss, shell | bulwark · 8 / 1.1 / 2 / 1 / 3 / 3 | 7 / 1.1 / **3** / 1 / 3 / 3 |
| **Thorn Mites** | Swarm | thorns, infestation | swift · 6 / 1.1 / 3 / 2 / 3 / 3 | 6 / 1.1 / 3 / 2 / **2** / 2 |
| **Grove Wisp** | Spirit | grove, wandering light | skirmisher · 5 / 1.4 / 5 / 1 / 3 / 3 | **4** / **2.2** / 5 / 1 / 3 / 3 |
| **Gloom Wolf** | Beast | gloom, pack hunting | skirmisher · 6 / 1.4 / 3 / 1 / 3 / 3 | **5** / **2.1** / 3 / 1 / 3 / 3 |
| **Dusk Moth** | Winged | dusk, eclipse | caster · 5 / 1.3 / 3 / 1 / 4 / 3 | **4** / **2.1** / 3 / 1 / 4 / 3 |
| **Hollow Serpent** | Scaled | hollow, coils | bulwark · 7 / 1.2 / 3 / 1 / 3 / 3 | 6 / **1.4** / **4** / 1 / 3 / 3 |

- **Test stats of 2026-11-15** *(bold values; approved by the user as test values, not as defaults)*: seven monsters were filled so that a Pace of 2.x, and with it a Stamina recovery of 2, occurs in play at all: five fast monsters now recover 2 (Blaze Tiger, Ember Hawk, Grove Wisp 2.2; Gloom Wolf, Dusk Moth 2.1), three frail ones got 1 HP (Gloom Wolf, Grove Wisp, Dusk Moth), Moss Turtle and Hollow Serpent got Stamina. Forge Golem kept its stats; the user's experiment monster `asdf` and its skills `asdf`, `asdf_2`, `asdf_3` were deleted on the user's instruction. **Under the prices of §2.2 every one of the nine files costs exactly 60 points** (Core Formation Middle; the points of the multiplayer mode): for that Ember Hawk and Thorn Mites, the two with two turns, went from Reach 3 to 2 *(user instruction 2026-11-15)*. The left column still shows the examples of the earlier calculation and has to be redone (T03). No series has measured the filled stats yet ([simulation_log.md](simulation_log.md) S031 is the state before the fill; simulation series run only on the user's explicit request).


### 4.2 Additional Species Candidates

The former Kin × aspect grid is not a roster requirement. These names remain an unordered idea pool within each Kin, without fixed theme categories or a required number of variants:

| Kin | Additional candidates |
|-----|-----------------------|
| Beast | Vine Panther |
| Winged | Gale Crane |
| Scaled | Magma Drake |
| Swarm | Cinder Wasps, Grave Rats |
| Spirit | War Echo, Wailing Shade |
| Ancient | Elder Treant, Bone Colossus |

**Status:** candidate pool only; launch selection and species definitions remain open under [temp_todo.md](temp_todo.md) T11/T12. No replacement roster quota is set here.

---

## 5. Growth

**Section status:** rarity/progression tables retain working values, not new slot ranks/prices or validated step supply. Step counts per rarity are legacy working values, not a validated supply for slot development.

### 5.1 Monster Rarity

**Rarity = potential and flexibility, NOT raw power.** A Normal and a Legendary at the same stage are close in raw stats — the Legendary has more options and a higher ceiling.

|                                  |                       Normal                       |        Rare       |        Epic       |            Legendary            |
|----------------------------------|----------------------------------------------------|-------------------|-------------------|---------------------------------|
| Base kit                         | up to 6 slots (active or passive, ≥ 1 active)      | same              | same              | same (+ signature at max stage) |
| Slot-development steps per advancement |                      1                             |         1         |         2         |                2                |
| Max stage reachable              | Core                                               | Soul              | Immortal          | Sovereign                       |

- "Max stage reachable" is the core axis — the wuxia "noble bloodline" trope, long-term potential over instant power
- **No stat bonuses from rarity.** Soul+ caps already sit on the absolute scale ([§2.3](#23-stat-ceilings-per-stage)), so rarity buys slots, development steps and ceiling — never numbers
- **High stages are Rare+ territory by design:** a Normal monster ends at Core (65 points), so the purchases that need more (a third turn, AP 5 with a body) stay with the higher rarities.
- Rarity does **not** decide the stat shape: any rarity can roll any shape (weighted by Kin lean, §1.1)
- Slot development and replacement rules: [Skills §6](gdd_skills.md#6-slot-levels-development-and-replacement). This table supplies only rarity/progression working data, not slot-development prices.

### 5.2 Rarity Ascension

- A **major event**, not a grind: rare material + ritual (bloodline awakening), story-flavored
- **Ingredients:** one **Bloodline pill** (Rare+ beast part of this Kin + next-tier herb), plus ritual. Items: [Overworld §6.6](gdd_overworld.md#66-pills--medicines); acquisition: [§7.8](gdd_overworld.md#78-acquisition-sources); ritual logistics: [§2.6](gdd_overworld.md#26-action-catalog). Location remains unresolved ([temp_todo.md](temp_todo.md) T30), not an implied Aspect Altar.
- On ascension: unlock new rarity's slots/caps, keep everything else
- **Hard cap:** Normal can climb to Epic but never Legendary — true Legendaries remain rare finds

### 5.3 Monster Progression: the 18 Steps

- **18 steps:** six stages × three sub-tiers. Every step grants 5 freely allocated stat points (§2.2); a stage opens skills and modes, never a stat value.
- Monsters exceed neither the player's stage (§2.2) nor rarity's max stage (§5.1). Player/monsters share this table; player XP bars may differ later.

| # | Stage · Sub-tier  | Budget (above base) | Gain on reaching the step                                                                       | XP bar to the next step | 
|---|-------------------|---------------------|--------------------------------------------------------------------------------------------------|-------------------------|
| 1 | Qi Gathering Lower | 25 | the starting 25 points · full kit · 1v1 | 60 |
| 2 | Qi Gathering Middle | 30 | +5 points | 120 |
| 3 | Qi Gathering High | 35 | +5 points · breakthrough trial opens | 200 (+ trial) |
| 4 | Foundation Lower | 40 | +5 points · **slot-development step** · +1 learnable skill · 3v3 / 2v2 · 1 tamer slot | 150 |
| 5 | Foundation Middle | 45 | +5 points | 300 |
| 6 | Foundation High | 50 | +5 points | 500 (+ trial) |
| 7 | Core Formation Lower | 55 | +5 points · **slot-development step** · +1 learnable skill · 5v5 special · 2nd tamer slot | 400 |
| 8 | Core Formation Middle | 60 | +5 points | 800 |
| 9 | Core Formation High | 65 | +5 points | 1300 (+ trial) |
| 10 | Soul Tier Lower | 70 | +5 points · **slot-development step** · +1 learnable skill · Beast Swap | 1000 |
| 11 | Soul Tier Middle | 75 | +5 points | 2000 |
| 12 | Soul Tier High | 80 | +5 points | 3200 (+ trial) |
| 13 | Immortal Lower | 85 | +5 points · **slot-development step** · +1 learnable skill · 3rd tamer slot | 2500 |
| 14 | Immortal Middle | 90 | +5 points · +1 slot-development step | 5000 |
| 15 | Immortal High | 95 | +5 points · +1 slot-development step | 8000 (+ trial) |
| 16 | Sovereign Lower | 100 | +5 points · **slot-development step** · Signature skill (Legendary) | 6000 |
| 17 | Sovereign Middle | 105 | +5 points · +1 slot-development step | 12000 |
| 18 | Sovereign High | 110 | +5 points · +1 slot-development step · the end of the table | — |
- **Slot-development step** = the monster may develop one skill slot ([Skills §6](gdd_skills.md#6-slot-levels-development-and-replacement)): 1 step for Normal / Rare, 2 for Epic / Legendary (§5.1).
  - Normal reaches Core (steps 4 and 7: only 2 development steps in total, to be reviewed under T05), Rare reaches Soul (3 steps), Epic Immortal, Legendary Sovereign.
- **Learnable skills:** the species list grows with the stages (4 defaults + 1 per breakthrough from Foundation to Immortal = 8). Kit access and replacement/development rules: [Skills §1](gdd_skills.md#1-the-kit)/[Skills §6](gdd_skills.md#6-slot-levels-development-and-replacement)
- **Immortal and Sovereign give points like every step** *(user decision 2026-11-15; before, they gave none)*: without unlocks AP 4 and AP 5 have to be paid; the end at 110 keeps a monster from reaching the top everywhere (§2.2).

**XP proposal** (prototype bars: Lower 60, Middle 120, High 200):
- Bars grow ≈×2.5/stage; a sub-tier takes roughly 3–6 focused days at the right stage.
- **Cultivation pill:** ≈half its tier's Lower bar (Qi +30 as in prototype, Foundation +80, Core +200, Soul +500, Immortal +1200).
- **Win:** Qi 10 XP, ×2.5/stage. **Cultivation-spot night:** small gain; Meditation Stone ≈one tenth of a win, Qi Spring double.

Breakthrough trials: [Overworld §6.3.1](gdd_overworld.md#631-breakthrough-trials).

---

## 6. Design Tracking

Open decisions, dependencies and validation live only in [temp_todo.md](temp_todo.md). Source pointers, not another task list:
- Incomplete skill contracts/costs/development: T02/T05; runtime reconciliation: T04/T07–T09; passive/species/roster: T10–T12.
- Loadout/tamer: T18–T20; ritual logistics: T30; Major/Signature access: T32; document synchronization: T35.

The confirmed removal of fixed monster aspects, the Force/Nature/Dark triangle and attunement overrides older proposals. Other proposals remain working design pending review.
