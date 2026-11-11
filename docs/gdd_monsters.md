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
  and learnable-skill references (Skills §1) · blurb · art
  Concrete Surge behaviour, shape and twist resolve from Skills §3.

INDIVIDUAL  (one per monster the player owns or meets in the wild)
  stat shape      glass cannon | anvil | skirmisher | berserker | balanced | fragile
  stats           rolled inside the shape's frame, then spent by the player (§2.2)
  rarity          Normal | Rare | Epic | Legendary
  stage + sub-tier + XP
  slot development  per-slot progress (Skills §6), supplied at advancement steps (§5.3)
  slot loadout    equipped skill and selected upgrades per slot (Skills §6)
  artifact(s)     equipment references (Overworld §6.7)
  current HP      expedition state (Overworld §2.2)
```

- **Referenced contracts:** [kit](gdd_skills.md#1-the-kit), [Surge profiles](gdd_skills.md#surge), [slot development/replacement](gdd_skills.md#6-slot-levels-development-replacement-and-upgrades), [artifacts](gdd_overworld.md#67-artifacts-equipment--socketed-passives), [expedition HP](gdd_overworld.md#22-expedition-loop).
- **Stat shape is individual, not species-wide.** Two Blaze Tigers can be a fast skirmisher and a hard-hitting berserker: same Surge, different playstyle, collection depth without new art.
- Wild/newly caught monsters roll shapes weighted by **Kin lean** (§3.1: Winged → glass cannon, Ancient → anvil, …); rare off-lean rolls are prized finds. §4.1 shows reference individuals: typical Core Formation rolls.
- **Shape trade-offs:** use the [frame/budget rules](#22-frame-budget-level-ups); speed costs HP, while slow shapes recover HP and Reach. No shape is strictly better.

### 1.2 Monster Sheet

```
NAME | Size (1x1 / 2x2)
──────────────────────────────────
Kin           Beast | Winged | Scaled | Swarm | Spirit | Ancient
Themes        free-form description, not a mechanical type or skill restriction
Rarity        Normal | Rare | Epic | Legendary
Stage         Qi Gathering ... Sovereign (capped by player stage)

HP
Initiative
Movement      squares per movement skill (Skills §3)
Reach         cast range of all skills
TurnsPerRound
AP            action points per turn
              (ranges and stage ceilings: §2.1, §2.3)

SKILLS: resolved kit under Skills §1
```

Battle sees only this finished sheet, a presentation of [§1.1](#11-species-and-individual) and [§2.1](#21-the-stats), not a second data model. Skill fields resolve through [Skills §1](gdd_skills.md#1-the-kit)/[§3](gdd_skills.md#3-skill-execution-profiles).

### 1.3 Monster Identity — The 6 Axes

```
1. STAT SHAPE   glass cannon / anvil / skirmisher / berserker / balanced / fragile   (per individual monster, rolled with the Kin's lean — §1.1)
2. THEMES       free descriptive motifs; no fixed aspects, replacement element types or attunement
3. KIN          creature type → Strike, layer, stat lean, which skill profiles it may take, Surge size access
4. KIT          authored skills and Surge identity (Skills §1/§3)
5. PASSIVE      the rule-bender — biggest personality driver
6. SIZE         1x1 vs 2x2
```

**A shared construction kit builds a monster** — not everything is invented from scratch per monster. Kit rules: [Skills §1](gdd_skills.md#1-the-kit); Surge behaviour/shape/twist contracts: [§3](gdd_skills.md#surge-constraints-and-species-access).

|           Layer           |                                  Decides                                  |                                  Example                                   |
|---------------------------|---------------------------------------------------------------------------|----------------------------------------------------------------------------|
| **Kin** (body)            | Strike, movement layer, stat lean, allowed skill profiles, Surge size         | Beast bites and is fast; only Ancient has a Major Surge (at Sovereign; Legendary ambiguity open, [Skills §1](gdd_skills.md#1-the-kit)) |
| **Themes** (description)  | free-form flavour and visual identity, no mechanical eligibility rules   | fire, moss, shadows, storms — motifs may mix freely                        |
| **Species** (the monster) | default kit and Species Surge references ([Skills §10](gdd_skills.md#10-species-skill-assignments-prior-draft)) | Blaze Tiger: *Magma Pounce* — O4 Eruption that must land next to the tiger |

- **No fixed roles:** Kin is not class (Beast ≠ "damage dealer"); kits determine team function, so two Beasts can play completely differently.
- Build teams from *combinations*: one monster pulls, another Strikes; one floods enemies into another's Eruption.

**Design test:** one sentence per monster built from its kit. If two monsters read the same, change a Surge shape or twist, a skill or its descriptive theme.

Stat-shape frames: [§2.2](#22-frame-budget-level-ups).

---

## 2. Stats

### 2.1 The Stats

|         Stat        |   Range  |                                                       Function                                                        |
|---------------------|----------|-----------------------------------------------------------------------------------------------------------------------|
| HP                  | 1–10     | No defense stat — dead is dead                                                                                        |
| Initiative          | 0.1–10.0 | Position in the turn queue ([gdd_battle §2.2](gdd_battle.md#22-initiative-rules))                                                                          |
| Movement | int | Squares per movement skill; Step exception: [Skills §3](gdd_skills.md#movement) |
| Reach               | 2–4      | Cast range of all skills ([§2](gdd_skills.md#2-data-oriented-skill-construction-kit)); Strikes don't use it                                                      |
| TurnsPerRound (TPR) | 1–3      | Extra turns: queue entries and initiative penalty in [gdd_battle §2.2](gdd_battle.md#22-initiative-rules)                |
| AP                  | 2–5      | Action points per turn ([gdd_battle §2.3](gdd_battle.md#23-action-points))                                                                              |
| Kin / Rarity / Size | —        | §3 and §5.1                                                                                                           |

Zones and standing on a Mountain change these values during a fight: effective stats, [gdd_battle §3.1](gdd_battle.md#31-effective-stats).

Budget/prices: [§2.2](#22-frame-budget-level-ups). Acting first, possibly several times consecutively, costs HP or Reach; poor turn order buys HP, Reach or AP.

### 2.2 Frame, Budget, Level-Ups

A monster **starts** with stats rolled by its stat shape; **after that the player decides** where each level-up goes. Three rules keep this fair:

```
FRAME   the stat shape sets a min–max per stat for the ROLL: shapes stay readable, individuals differ
BUDGET  every monster of a stage and sub-tier has the same total of stat points
PRICE   stats cost points: a strong stat is paid for with the others
```

**Stat prices:** **points = value × price** (Reach: (value − 1) × price). Base values are free (15 base points); the budget below is additional. **TPR/AP prices rise per step:** second and third action sources cost more than the first.

|   Stat   | Base |                  Price                  | Base cost |
|----------|------|-----------------------------------------|-----------|
| HP       |    1 | 1 per point                             |         1 |
| Init     |  1.0 | 1 per point (see below)                 |         1 |
| Movement |    1 | 1 per point                             |         1 |
| Reach    |    2 | 3 per point above 1                     |         3 |
| TPR      |    1 | 1st **3** · 2nd **5** · 3rd **7**       |         3 |
| AP       |    2 | base 2 = 6 · AP 3 **+3** · AP 4 **+5** · AP 5 **+7** |  6 |
| **Base total** |  |                                       |    **15** |

- **Absolute costs:** TPR 1/2/3 = 3/8/15; AP 2/3/4/5 = 6/9/14/21.
- **One AP ceiling for every monster** *(user decision 2026-11-11)*: [§2.3](#23-stat-ceilings-per-stage) applies to all monsters; no TPR value lowers it and no AP value restricts TPR. Extra turns are limited by price instead. AP also gates [Strike shapes](gdd_skills.md#81-strike-by-kin).
- **TPR price draft:** the additive costs above do not scale with actions per round; the formula remains open until simulator evidence (T03/T13).

**Budget per stage and sub-tier** (points above the 15 base points; absolute total in brackets):

|        Stage        |  Lower  |  Middle |   High  |
|---------------------|---------|---------|---------|
| Qi Gathering        | 4 (19)  | 5 (20)  | 6 (21)  |
| Foundation          | 10 (25) | 11 (26) | 12 (27) |
| Core Formation      | 14 (29) | 15 (30) | 16 (31) |
| Soul Tier and above | 18 (33) | 19 (34) | 20 (35) |

Derived gains through Soul: sub-tier **+1 stat point**, breakthrough **+2** (**+4 into Foundation**, where TPR 2 opens). Immortal/Sovereign gains and rationale: [§5.3](#53-monster-progression-the-18-steps).

**The six frames at Core Formation** (min–max). Total points are absolute totals with all stats at minimum/maximum; every shape contains the required Core budget (29 / 30 / 31).

|    Shape     |  HP |  Init | Move | Reach | TPR |  AP | Total points | Feel |
|--------------|-----|-------|------|-------|-----|-----|--------------|------|
| Glass cannon | 1–3 | 7–9   | 1–3  | 2     | 2   | 2   | 26–32        | commits fast, dies if its Surge is cut away |
| Anvil        | 6–8 | 1–4   | 1–2  | 2–3   | 1   | 2–3 | 20–32        | slow, hard to dislodge, threatens a radius it can't leave |
| Skirmisher   | 3–5 | 5–8   | 3–5  | 2     | 1   | 2–3 | 23–33        | never in its own Surge when it fires |
| Berserker    | 4–6 | 5–7   | 1–3  | 2     | 2   | 2   | 27–33        | escalates one Surge with Empower; TPR 3 opens at Soul |
| Balanced     | 4–6 | 4–6   | 2–3  | 2–3   | 1   | 2–3 | 22–33        | no weakness, no spike — the kit decides |
| Fragile      | 2–4 | 5–7   | 1–3  | 2–3   | 2   | 2   | 25–34        | weak body, many turns; lives on its Surge |

**Worked frame totals:**

- Worked out with the prices (Glass cannon): HP 1–3 = 1–3 · Init 7–9 = 7–9 (8–12) · Move 1–3 = 1–3 (9–15) · Reach 2 = 3 (12–18) · TPR 2 = 8 (20–26) · AP 2 = 6 → **26–32**.
- Anvil: HP 6–8 · Init 1–4 (7–12) · Move 1–2 (8–14) · Reach 2–3 = 3–6 (11–20) · TPR 1 = 3 (14–23) · AP 2–3 = 6–9 → **20–32**.

**Balance check:** a fair frame contains the budget with a nearby maximum, allowing the individual to spend it with some choice.
- At Core's maximum budget (31), headroom is 1 for Glass cannon (max 32) and Anvil, 2 for Skirmisher/Berserker/Balanced, 3 for Fragile.
- Glass cannon and Anvil therefore vary little between rolls; the wide Anvil (20–32) and Balanced (22–33) ranges matter only as roll minima.

**All stages (absolute point range of the scaled frame vs. budget):**

|    Shape     | Qi (19–21) | Foundation (25–27) | Core (29–31) | Soul+ (33–35) |
|--------------|------------|--------------------|--------------|---------------|
| Glass cannon | 18–21      | 24–28              | 26–32        | 30–37         |
| Anvil        | 17–19      | 19–26              | 20–32        | 25–37         |
| Skirmisher   | 19–22      | 20–26              | 23–33        | 28–38         |
| Berserker    | 18–21      | 25–29              | 27–33        | 32–39         |
| Balanced     | 17–20      | 20–27              | 22–33        | 26–39         |
| Fragile      | 17–20      | 24–30              | 25–34        | 30–39         |

- **Unspent points:** Qi Anvil (max 19 vs. budgets 19 / 20 / 21) leaves 1 at Middle, 2 at High; Qi Balanced/Fragile (max 20) leave 1 at High; Foundation High Anvil/Skirmisher (max 26 vs. 27) leave 1. The player spends roll leftovers freely: no lost points or frame changes.
- The table excludes Berserker's TPR 3 at Soul.

- **Init at roll:** 1 point = **1.0 Init**; speed costs other stats. A free decimal (.0–.9) is rolled on top, below the frame maximum.
- **Init at level-up:** 1 point = **+0.1 Init**; fine-tune the queue without replacing shape identity. Budget counts points received, equally for every monster regardless of purchases.

Example, a Glass cannon at Core High (16 points above base): HP 2 (1) + Init 9 (8) + Move 3 (2) + TPR 2 (5) = 16.

- **Stage scaling** *(user decision 2026-11-11; ceilings: [§2.3](#23-stat-ceilings-per-stage))*:
  - Reach ratio = *(stage ceiling − 1) ÷ (Core ceiling − 1)*; limit = `1 + (Core limit − 1) × ratio`.
  - HP/Init/Movement: scale Core limits by *stage ceiling ÷ Core ceiling*.
  - For both scaling formulas, round half up, minimum 1. Cut TPR/AP limits to the ceiling; only Berserker's TPR frame grows, to 3 at Soul.
- **Frame applies only at roll:** new/wild individuals draw within it until their stage/sub-tier budget is spent. Two Anvils start differently, never stronger overall.
  - Each later level-up adds points for free player allocation (free action), limited only by stage ceilings (§2.3).
  - Save ceiling-blocked points for the next breakthrough.
- **Reshape:** pool all points and reroll within the new frame at the same budget; leftovers remain unspent. Level-up spending alone never changes the shape label. Item, ritual location and day-AP: [Overworld §2.6](gdd_overworld.md#26-action-catalog).
- **Ceiling rule:** monsters cannot exceed the player's stage: the spatial space sustains only what the tamer's qi can feed. *(user decision 2026-11-11)* the cap is the player's **stage**, not the exact sub-tier; §5.3 lists the progression steps within that stage and sets no separate sub-tier cap.
- **Working values:** prices, budgets and frames are first drafts.

### 2.3 Stat Ceilings per Stage

Each stage defines hard caps, no shape and no point can go above them:

|                                                  | Qi Gathering | Foundation | Core Formation | Soul+ |
|--------------------------------------------------|--------------|------------|----------------|-------|
| Max HP                                           |            4 |          6 |              8 |    10 |
| Max Initiative                                   |          5.0 |        7.0 |            9.0 |  10.0 |
| Max TurnsPerRound                                |            1 |          2 |              2 |     3 |
| Max Movement                                     |            3 |          4 |              5 |     5 |
| Max Reach (see §2.1)                  |            2 |          3 |              3 |     4 |
| Max AP                                           |            2 |          2 |              3 |     3 |

Soul+ is split for AP only: **Soul 3 · Immortal 4 · Sovereign 5**.

- **Lifetime scale:** [§2.1 ranges](#21-the-stats) span the whole game; inflation would destroy the deterministic low-HP feel.
- **Damage never scales by stage:** Surge base, Strike and ground damage stay equal from Qi Gathering to Sovereign; source limits: [Battle §6.1](gdd_battle.md#61-the-damage-law).

---

## 3. Kins

### 3.1 Kin Table

> **Kin = what kind of creature it is. Themes describe it freely, without assigning a mechanical type.**

- Kin sets **Strike, Surge size, stat lean, movement layer and utility access**, never damage multipliers. No Force/Nature/Dark weakness triangle, replacement element system or attunement.
- The **species learnable list** determines concrete skill access within Kin/progression restrictions.

|     Kin     |      Body fantasy      |               Layer/Movement              |      Stat lean      |                        Surge access                        |      Locked out of      |
|-------------|------------------------|-------------------------------------------|---------------------|------------------------------------------------------------|-------------------------|
| **Beast**   | tiger, ape, wolf       | ground, high move                         | balanced/skirmisher | Minor                                                      | Major Surge, Sanctify   |
| **Winged** | bird, moth, wyvern | **air** (Soul+), move 3+ | glass cannon | Minor; recipient/ground interface: [Battle §4.3](gdd_battle.md#43-the-square-stack-zones--ground), Mountain exception: [§4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed) | Raise Prop, Major Surge |
| **Scaled**  | serpent, turtle, drake | ground, low move                          | anvil               | Minor                                                      | —                       |
| **Swarm**   | insects, rats          | ground, move 2                            | fragile, TPR 2+     | Minor, 2-cell shapes                                       | Major Surge, Relocate   |
| **Spirit**  | ghost, wisp            | ground, **Phase / Blink** ([Skills §8.2](gdd_skills.md#82-movement-by-kin))        | low HP, high init   | Minor                                                      | Raise Prop              |
| **Ancient** | golem, treant          | ground, move 1                            | max HP, TPR 1       | Minor + **only Kin with Major Surge**                      | Air                     |

Strike shapes and Kin effects ([Skills §8.1](gdd_skills.md#81-strike-by-kin)), movement modes by Kin ([Skills §8.2](gdd_skills.md#82-movement-by-kin)) and everything else about skills live in [gdd_skills.md](gdd_skills.md).

---

## 4. Roster

### 4.1 First Roster Draft — 9 monsters

**Non-authoritative prior-draft ideas.** Names, descriptions and shapes are unvalidated; skill assignments are in [Skills §10](gdd_skills.md#10-species-skill-assignments-prior-draft).
- **Reference individuals:** typical species rolls at **Core Formation High**, each spending exactly 16 points within its [frame/budget](#22-frame-budget-level-ups) and [stage ceilings](#23-stat-ceilings-per-stage); shape belongs to the individual ([§1.1](#11-species-and-individual)).

| Monster | Kin | Descriptive themes | Shape · HP / Init / Move / TPR / Reach / AP |
|---|---|---|---|
| **Blaze Tiger** | Beast | flame, hunting | skirmisher · 5 / 7.0 / 4 / 1 / 2 / 3 |
| **Ember Hawk** | Winged | embers, flight | glass cannon · 2 / 9.0 / 3 / 2 / 2 / 2 |
| **Forge Golem** | Ancient | forge, stone | anvil · 8 / 4.0 / 1 / 1 / 3 / 3 |
| **Moss Turtle** | Scaled | moss, shell | anvil · 8 / 3.0 / 2 / 1 / 3 / 3 |
| **Thorn Mites** | Swarm | thorns, infestation | fragile · 3 / 6.0 / 2 / 2 / 3 / 2 |
| **Grove Wisp** | Spirit | grove, wandering light | skirmisher · 4 / 8.0 / 4 / 1 / 2 / 3 |
| **Gloom Wolf** | Beast | gloom, pack hunting | balanced · 5 / 6.0 / 2 / 1 / 3 / 3 |
| **Dusk Moth** | Winged | dusk, eclipse | glass cannon · 2 / 9.0 / 3 / 2 / 2 / 2 |
| **Hollow Serpent** | Scaled | hollow, coils | anvil · 7 / 4.0 / 2 / 1 / 3 / 3 |


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
| Slot-development steps per advancement |                      1                             |         1         |         2         |                2                |
| Max stage reachable              | Core                                               | Soul              | Immortal          | Sovereign                       |

- Base kit, rarity-dependent passive slot and Legendary Signature access: [Skills §1](gdd_skills.md#1-the-kit); advancement unlocks: [§5.3](#53-monster-progression-the-18-steps).
- "Max stage reachable" is the core axis — the wuxia "noble bloodline" trope, long-term potential over instant power
- **No stat bonuses from rarity.** Soul+ caps already sit on the absolute scale ([§2.3](#23-stat-ceilings-per-stage)), so rarity buys slots, development steps and ceiling — never numbers
- **High mechanics are Rare+ territory by design:** rarity ceilings gate the [advancement unlocks](#53-monster-progression-the-18-steps); a Normal monster stops at Core, before Soul-tier air/2×2 and TPR-3 access, but can reach Foundation's TPR 2.
- Rarity does **not** decide the stat shape: any rarity can roll any shape (weighted by Kin lean, §1.1)
- Slot development, superseded per-skill prices and replacement rules: [Skills §6](gdd_skills.md#6-slot-levels-development-replacement-and-upgrades). This table supplies only rarity/progression working data, not slot-development prices.

### 5.2 Rarity Ascension

- A **major event**, not a grind: rare material + ritual (bloodline awakening), story-flavored
- **Ingredients:** one **Bloodline pill** (Rare+ beast part of this Kin + next-tier herb), plus ritual. Items: [Overworld §6.6](gdd_overworld.md#66-pills--medicines); acquisition: [§7.8](gdd_overworld.md#78-acquisition-sources); ritual logistics: [§2.6](gdd_overworld.md#26-action-catalog). Location remains unresolved ([temp_todo.md](temp_todo.md) T30), not an implied Aspect Altar.
- On ascension: unlock new rarity's slots/caps, keep everything else
- **Hard cap:** Normal can climb to Epic but never Legendary — true Legendaries remain rare finds

### 5.3 Monster Progression: the 18 Steps

- **18 steps:** six stages × three sub-tiers. Sub-tiers grant freely allocated stat points within ceilings; stages open skills/mechanics.
- Monsters exceed neither the player's stage (§2.2) nor rarity's max stage (§5.1). Player/monsters share this table; player XP bars may differ later.

- Budgets and AP/TPR ceilings: [§2.2](#22-frame-budget-level-ups)/[§2.3](#23-stat-ceilings-per-stage); kit: [Skills §1](gdd_skills.md#1-the-kit). Player-specific mode, tamer-slot and Beast Swap unlocks: [Overworld §6.3](gdd_overworld.md#63-stage-unlock-table).
- Stat-point gains below reference the budget table; development supply and XP bars are defined here. **Retained progression-draft budget:** Immortal and Sovereign each keep 20 points above base at all three sub-tiers. Reconciliation with the §2.2 “Soul Tier and above” row: [T03](temp_todo.md#open-tasks).

| # | Stage · Sub-tier | Gain on reaching the step | XP bar to the next step |
|---|------------------|---------------------------|-------------------------|
| 1 | Qi Gathering Lower | starting kit and ceilings (sources above) | 60 |
| 2 | Qi Gathering Middle | +1 stat point | 120 |
| 3 | Qi Gathering High | +1 stat point · breakthrough trial opens | 200 (+ trial) |
| 4 | Foundation Lower | **+4 points** · **slot-development step** · +1 learnable skill · TPR ceiling rises | 150 |
| 5 | Foundation Middle | +1 stat point | 300 |
| 6 | Foundation High | +1 stat point | 500 (+ trial) |
| 7 | Core Formation Lower | **+2 points** · **slot-development step** · +1 learnable skill · AP ceiling rises | 400 |
| 8 | Core Formation Middle | +1 stat point | 800 |
| 9 | Core Formation High | +1 stat point | 1300 (+ trial) |
| 10 | Soul Tier Lower | **+2 points** · **slot-development step** · +1 learnable skill · air layer, 2×2 · TPR ceiling rises · foreign movement ([Skills §8.2](gdd_skills.md#82-movement-by-kin)) | 1000 |
| 11 | Soul Tier Middle | +1 stat point | 2000 |
| 12 | Soul Tier High | +1 stat point | 3200 (+ trial) |
| 13 | Immortal Lower | no points · **slot-development step** · +1 learnable skill · AP ceiling rises | 2500 |
| 14 | Immortal Middle | +1 slot-development step | 5000 |
| 15 | Immortal High | +1 slot-development step | 8000 (+ trial) |
| 16 | Sovereign Lower | **slot-development step** · AP ceiling rises · Signature skill (Legendary) · Major Surge (Ancient) | 6000 |
| 17 | Sovereign Middle | +1 slot-development step | 12000 |
| 18 | Sovereign High | +1 slot-development step · end of the table | — |

- **Development supply:** apply [§5.1 steps per advancement](#51-monster-rarity) at the steps marked above; step use: [Skills §6](gdd_skills.md#6-slot-levels-development-replacement-and-upgrades).
  - Derived totals: Normal reaches Core (steps 4 and 7: only 2 development steps, review T05); Rare reaches Soul (3 steps). Epic reaches Immortal, Legendary Sovereign ([§5.1](#51-monster-rarity)).
- **Learnable skills:** the species list grows with the stages (4 defaults + 1 per breakthrough from Foundation to Immortal = 8). Kit access and replacement/development rules: [Skills §1](gdd_skills.md#1-the-kit)/[Skills §6](gdd_skills.md#6-slot-levels-development-replacement-and-upgrades)
- **Why not points at Immortal / Sovereign:** the stat ceilings and the damage law are reached; more points would only be number inflation (pillar 1). Those sub-tiers give choices (slot-development steps) instead of numbers.

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
