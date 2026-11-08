# GDD — MONSTERS & SKILLS
*Working Draft · companion specifications: [Battle System](gdd_battle.md) (how a fight works), [Overworld & Meta](gdd_overworld.md) (the world around it) · source of truth for everything that defines a monster*

---

## 1. Overview

Every monster definition lives here, once. The other two files link to this one.

|                                        Question                                        |       File       |
|----------------------------------------------------------------------------------------|------------------|
| What is a monster? Stats, Kins, skills, passives, roster, evolution, rarity             | this file        |
| How does a fight run? Turns, squares, zones, ground, generic damage resolution                | gdd_battle.md    |
| How do you catch, house and lose monsters? Tamer skills, items, economy, the world      | gdd_overworld.md |

### 1.1 Species and Individual

A monster the player owns is **two layers**: a fixed *species* and a unique *individual*.

```
SPECIES  (data file, shared by all individuals — §6.1)
  Kin · descriptive themes (free-form, no mechanical type) · default kit
  (4 slots, active or passive) · learnable skills · blurb · art
  Each concrete Surge skill defines its own behaviour, shape and twist.

INDIVIDUAL  (one per monster the player owns or meets in the wild)
  stat shape      glass cannon | anvil | skirmisher | berserker | balanced | fragile
  stats           rolled inside the shape's frame, then spent by the player (§2.2)
  rarity          Normal | Rare | Epic | Legendary
  stage + sub-tier + XP
  evolutions      physical evolution choices and permanent development per skill slot (§4.6)
  slot loadout    equipped skill and its selected upgrades per slot; development survives skill replacement
  artifact(s)     socketed passives (gdd_overworld §6.7)
  current HP      persists between battles of an expedition
```

- **The stat shape belongs to the individual, not the species.** Two Blaze Tigers can be a fast skirmisher and a hard-hitting berserker — same Surge, different playstyle. Collection depth without new art.
- The species' **Kin leans** towards certain shapes (§3.1 "Stat lean": Winged → glass cannon, Ancient → anvil, …). A wild or newly caught monster **rolls its shape weighted by that lean**, so a rare off-lean individual is a prized find. The monsters listed in §6.1 are the **reference individuals** (the typical roll at Core Formation).
- **Every stat is paid for** (§2.2): the shape only decides *where* a fixed stat budget may go. A fast shape gets less HP, a slow shape gets it back in HP and Reach. No shape is strictly better.

### 1.2 Monster Sheet

```
NAME | Size (1x1 / 2x2)
──────────────────────────────────
Kin           Beast | Winged | Scaled | Swarm | Spirit | Ancient
Themes        free-form description, not a mechanical type or skill restriction
Rarity        Normal | Rare | Epic | Legendary
Stage         Qi Gathering ... Sovereign (capped by player stage)

HP            1–10
Initiative    0.1–10.0
Movement      squares per movement skill (Step is always 1)
Reach         2–4   cast range of all skills
TurnsPerRound 1–3
AP            2–5   action points per turn (4 from Immortal, 5 from Sovereign, only with TPR 1)

SKILLS: Step (no slot, 2 AP) + 4 slots, active or passive, at least one active (§4.1)
```

The battle only ever sees this finished sheet.

### 1.3 Monster Identity — The 6 Axes

```
1. STAT SHAPE   glass cannon / anvil / skirmisher / berserker / balanced / fragile   (per individual monster, rolled with the Kin's lean — §1.1)
2. THEMES       free descriptive motifs; no fixed aspects, replacement element types or attunement
3. KIN          creature type → Strike, layer, stat lean, which skill profiles it may take, Surge size access
4. KIT          4 slots (active or passive, ≥ 1 active); each concrete Surge defines its behaviour, shape + size and at most ONE twist (§4.3)
5. PASSIVE      the rule-bender — biggest personality driver
6. SIZE         1x1 vs 2x2
```

**A shared construction kit builds a monster** — not everything is invented from scratch per monster:

|           Layer           |                                  Decides                                  |                                  Example                                   |
|---------------------------|---------------------------------------------------------------------------|----------------------------------------------------------------------------|
| **Kin** (body)            | Strike, movement layer, stat lean, allowed skill profiles, Surge size         | Beast bites and is fast; only Ancient has a Major Surge                    |
| **Themes** (description)  | free-form flavour and visual identity, no mechanical eligibility rules   | fire, moss, shadows, storms — motifs may mix freely                        |
| **Species** (the monster) | its default kit of 4 slots and its Species Surge (§4.3)                  | Blaze Tiger: *Magma Pounce* — O4 Eruption that must land next to the tiger |

**No fixed roles.** A Kin is not a class (Beast ≠ "damage dealer"). What a monster does for a team comes from its kit, so two Beasts can play completely differently. Team building means picking *combinations* — one monster pulls, another one Strikes; one floods the enemy into the other's Eruption.

**Design test:** one sentence per monster built from its kit. If two monsters read the same, change a Surge shape or twist, a skill or its descriptive theme.

The six stat shapes are frames of min–max values per stat, not fixed stats (§2.2).

---

## 2. Stats

### 2.1 The Stats

|         Stat        |   Range  |                                                       Function                                                        |
|---------------------|----------|-----------------------------------------------------------------------------------------------------------------------|
| HP                  | 1–10     | No defense stat — dead is dead                                                                                        |
| Initiative          | 0.1–10.0 | Position in the turn queue (gdd_battle §2.2)                                                                          |
| Movement            | int      | Squares per movement skill (gdd_monsters §4.3); Step is always 1                                                        |
| Reach               | 2–4      | Cast range of all skills (gdd_monsters §4.2); Strikes don't use it                                                      |
| TurnsPerRound (TPR) | 1–3      | Extra turns re-enter the queue at −3 initiative per extra turn                                                        |
| AP                  | 2–5      | Action points per turn (gdd_battle §2.3)                                                                              |
| Kin / Rarity / Size | —        | §3 and §7.2                                                                                                           |

Zones and Elevated change these values during a fight: effective stats, gdd_battle §3.1.

**Every stat is paid for.** All monsters of a stage and sub-tier have the same stat budget, the stat shapes spend it in different places (§2.2): a fast monster acts first and may act several times in a row, so it must have less HP or less Reach. A slow monster is punished in the turn order and gets that back in HP, Reach or AP.

### 2.2 Frame, Budget, Level-Ups

A monster **starts** with stats rolled by its stat shape; **after that the player decides** where each level-up goes. Three rules keep this fair:

```
FRAME   the stat shape sets a min–max per stat for the ROLL: shapes stay readable, individuals differ
BUDGET  every monster of a stage and sub-tier has the same total of stat points
PRICE   stats cost points: a strong stat is paid for with the others
```

**Stat prices.** Every stat is priced in full: **points = value × price** (Reach: (value − 1) × price). A new monster owns the base values for free (15 points of base), the budget below is what it gets on top. **TPR and AP get dearer with every step**, so the second and third action source cost more than the first:

|   Stat   | Base |                  Price                  | Base cost |
|----------|------|-----------------------------------------|-----------|
| HP       |    1 | 1 per point                             |         1 |
| Init     |  1.0 | 1 per point (see below)                 |         1 |
| Movement |    1 | 1 per point                             |         1 |
| Reach    |    2 | 3 per point above 1                     |         3 |
| TPR      |    1 | 1st **3** · 2nd **5** · 3rd **7**       |         3 |
| AP       |    2 | base 2 = 6 · AP 3 **+3** · AP 4 **+5** · AP 5 **+7** |  6 |
| **Base total** |  |                                       |    **15** |

Absolute cost by value: **TPR** 1 = 3 · 2 = 8 · 3 = 15. **AP** 2 = 6 · 3 = 9 · 4 = 14 · 5 = 21. The TPR 2+ shapes (Glass cannon, Berserker, Fragile) are kept at AP 2 by their frames; the progressive prices make every extra action source dearer than the last, so AP 3+ on a TPR 2 body would also eat most of the budget. AP also opens the bigger Strike shapes (§3.2), so it buys more than extra actions.

**Budget per stage and sub-tier** (points above the 15 base points; absolute total in brackets):

|        Stage        |  Lower  |  Middle |   High  |
|---------------------|---------|---------|---------|
| Qi Gathering        | 4 (19)  | 5 (20)  | 6 (21)  |
| Foundation          | 10 (25) | 11 (26) | 12 (27) |
| Core Formation      | 14 (29) | 15 (30) | 16 (31) |
| Soul Tier and above | 18 (33) | 19 (34) | 20 (35) |

So a sub-tier up gives **+1 stat point**, a breakthrough **+2** (**+4 into Foundation**, because TPR 2 opens there). Immortal and Sovereign add no points: the absolute scale is reached, those sub-tiers give evolution points instead (§7.4).

**The six frames at Core Formation** (min–max). The last column is the **absolute point total** of the frame: all stats at their minimum, and all at their maximum. The Core budget (29 / 30 / 31) has to sit inside it for every shape, and it does:

|    Shape     |  HP |  Init | Move | Reach | TPR |  AP | Total points | Feel |
|--------------|-----|-------|------|-------|-----|-----|--------------|------|
| Glass cannon | 1–3 | 7–9   | 1–3  | 2     | 2   | 2   | 26–32        | commits fast, dies if its Surge is cut away |
| Anvil        | 6–8 | 1–4   | 1–2  | 2–3   | 1   | 2–3 | 20–32        | slow, hard to dislodge, threatens a radius it can't leave |
| Skirmisher   | 3–5 | 5–8   | 3–5  | 2     | 1   | 2–3 | 23–33        | never in its own Surge when it fires |
| Berserker    | 4–6 | 5–7   | 1–3  | 2     | 2   | 2   | 27–33        | escalates one Surge with Empower; TPR 3 opens at Soul |
| Balanced     | 4–6 | 4–6   | 2–3  | 2–3   | 1   | 2–3 | 22–33        | no weakness, no spike — the kit decides |
| Fragile      | 2–4 | 5–7   | 1–3  | 2–3   | 2   | 2   | 25–34        | weak body, many turns; lives on its Surge |

Worked out with the prices (Glass cannon): HP 1–3 = 1–3 · Init 7–9 = 7–9 (8–12) · Move 1–3 = 1–3 (9–15) · Reach 2 = 3 (12–18) · TPR 2 = 8 (20–26) · AP 2 = 6 → **26–32**. Anvil: HP 6–8 · Init 1–4 (7–12) · Move 1–2 (8–14) · Reach 2–3 = 3–6 (11–20) · TPR 1 = 3 (14–23) · AP 2–3 = 6–9 → **20–32**.

**Balance check.** A shape is fair when the budget total sits inside its range and its max is not far above it (then the individual can reach the budget with room to choose). At the top of the Core budget (31) the Glass cannon has 1 point of room (max 32), the Anvil 1, the Skirmisher / Berserker / Balanced 2, the Fragile 3. The Glass cannon and the Anvil therefore roll almost the same stats every time; the wide ranges of Anvil (20–32) and Balanced (22–33) only matter as the minimum for the roll.

**All stages (absolute point range of the scaled frame vs. budget):**

|    Shape     | Qi (19–21) | Foundation (25–27) | Core (29–31) | Soul+ (33–35) |
|--------------|------------|--------------------|--------------|---------------|
| Glass cannon | 18–21      | 24–28              | 26–32        | 30–37         |
| Anvil        | 17–19      | 19–26              | 20–32        | 25–37         |
| Skirmisher   | 19–22      | 20–26              | 23–33        | 28–38         |
| Berserker    | 18–21      | 25–29              | 27–33        | 32–39         |
| Balanced     | 17–20      | 20–27              | 22–33        | 26–39         |
| Fragile      | 17–20      | 24–30              | 25–34        | 30–39         |

The Qi and Foundation ceilings squeeze some frames: the **Anvil at Qi Gathering** (max 19 against 19 / 20 / 21) cannot spend 1 point at Middle and 2 at High, and the **Anvil and Skirmisher at Foundation High** (max 26 against 27) 1 point. **Rule:** whatever the roll cannot place stays as **unspent stat points**; the player spends them freely, so nothing is lost and the frames stay as they are. (The Berserker's TPR 3 at Soul is not counted in the table.)

**Init has two rates:** at the roll 1 point = **1.0 Init**, so a fast shape pays for its speed with its other stats; the decimal (.0–.9) is rolled on top for free, below the frame's max. On a level-up 1 point = **+0.1 Init**: speed stays the identity of the shape, level-up points only fine-tune the queue. The budget counts points received, so every monster gets the same number whatever it buys.

Example, a Glass cannon at Core High (16 points above base): HP 2 (1) + Init 9 (8) + Move 3 (2) + TPR 2 (5) = 16.

- **Other stages scale the frame:** HP, Init, Movement and Reach limits are multiplied by *stage ceiling ÷ Core ceiling* (§2.3), rounded, min 1 (Reach without its first point: 1 + (Reach − 1) × ratio). TPR and AP limits are simply cut by the ceiling. Only the Berserker's TPR limit grows, to 3 at Soul. **AP 4 (Immortal) and 5 (Sovereign) need TPR 1.** This is a rule on the stats, not on the stat shape (the shape is only the roll): a monster with TPR 2+ stays at AP 3, and a monster with AP 4+ can't raise its TPR
- **The frame is only for the roll.** A new or wild individual draws its stats inside the frame until the budget of its stage and sub-tier is spent. After that the frame no longer matters: **level-up points are limited only by the stage ceilings** (§2.3). Two Anvils start different, but never stronger than each other overall
- **Spent by the player after that:** each level-up adds points, and the player spends them freely (free action)
- **Points can be saved.** Points that hit a stage ceiling stay unspent until a ceiling opens at the next breakthrough
- **The stat shape can change** later through Reshape. All points are pooled and the monster is **re-rolled inside the new shape's frame** with the same budget; the leftover is unspent. Level-up spending does not change the shape label. Item, ritual location and day-AP cost: [Overworld §2.6](gdd_overworld.md#26-action-catalog).
- **Ceiling rule:** monsters cannot exceed the player's stage (the spatial space can only sustain what the tamer's qi can feed). **Unresolved scope:** §7.4 instead says the player's exact step; this remains [temp_todo.md](temp_todo.md) T03, not a resolved sub-tier cap.
- **Working values:** prices, budgets and frames are a first version.

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

Soul+ is split for AP only: **Soul 3 · Immortal 4 · Sovereign 5**, and AP 4–5 need TPR 1 (§2.2).

The base stat ranges (HP 1-10, Init 0.1-10.0, TPR 1-3, AP 2-5) are the **lifetime scale of the entire game** — number inflation would kill the deterministic low-HP feel. The damage law (gdd_battle §6.1) is **never** scaled by stage: Surge base damage, Strike (max 2) and ground damage are the same at Qi Gathering and at Sovereign.

---

## 3. Kins

### 3.1 Kin Table

> **Kin = what kind of creature it is. Themes describe it freely, without assigning a mechanical type.**

Kin maps to **Strike, Surge size, stat lean, movement layer and allowed utilities** — never to damage multipliers. There is no Force/Nature/Dark weakness triangle, no fixed element system replacing it and no attunement. The **species' learnable list** determines which concrete skills it may learn, respecting Kin and progression restrictions.

|     Kin     |      Body fantasy      |               Layer/Movement              |      Stat lean      |                        Surge access                        |      Locked out of      |
|-------------|------------------------|-------------------------------------------|---------------------|------------------------------------------------------------|-------------------------|
| **Beast**   | tiger, ape, wolf       | ground, high move                         | balanced/skirmisher | Minor                                                      | Major Surge, Sanctify   |
| **Winged**  | bird, moth, wyvern     | **air** (Soul+), move 3+                  | glass cannon        | Minor; **immune to ground-anchored Surges while airborne** | Raise Prop, Major Surge |
| **Scaled**  | serpent, turtle, drake | ground, low move                          | anvil               | Minor                                                      | —                       |
| **Swarm**   | insects, rats          | ground, move 2                            | fragile, TPR 2+     | Minor, 2-cell shapes                                       | Major Surge, Relocate   |
| **Spirit**  | ghost, wisp            | ground, **Phase / Blink** (§3.3)        | low HP, high init   | Minor                                                      | Raise Prop              |
| **Ancient** | golem, treant          | ground, move 1                            | max HP, TPR 1       | Minor + **only Kin with Major Surge**                      | Air                     |

### 3.2 Strike by Kin

Every Strike is a **shape around the body** plus a **Kin twist** (rule: gdd_monsters §4.3). The species picks the shape, the Kin gives the twist.

**Strike shapes** (second version). A bigger shape costs more AP and is simply better; it never deals less damage. The player picks the direction when striking (8 directions, no facing). "Forward" means along that direction; a line is stopped by the first solid prop in it.

| Squares | AP |                          Shape                          |                  Name                  |
|---------|----|---------------------------------------------------------|----------------------------------------|
|       1 |  2 | next to `M`, any of the 8 directions                    | **Jab**                                |
|       2 |  3 | 2 forward in a straight line (4 directions)             | **Thrust**                             |
|       2 |  3 | 2 forward on a diagonal (4 diagonals)                   | **Diagonal Thrust**                    |
|       2 |  3 | next to `M` in the chosen direction **and** the opposite side | **Pincer**                       |
|       3 |  3 | the 3 squares in front of `M` (a row, or a wedge on a diagonal) | **Arc**                        |
|       4 |  3 | the 4 neighbours of `M`                                 | **Whirl**                              |
|       4 |  3 | the 4 diagonals of `M`                                  | **Cross**                              |
|       8 |  4 | all 8 squares around `M`                                | **Storm**                              |
|       6 |  5 | the 3 squares in front of `M` and the 3 behind those    | **Cleave**                             |
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

- **AP decides when:** AP 2 is the ceiling until Core, so Qi and Foundation Strikes are all Jabs and differ by Kin twist only. AP 3 opens at Core, AP 4 at Immortal and AP 5 at Sovereign, the last two only with TPR 1 (§2.3)
- **Every shape hits allies too.** The bigger the shape, the more of them stand in it. A 2x2 monster starts the shape at the edge of its body
- The shape is part of the species and changes through the Shape and Size evolutions (§4.6)

**Kin twists.** Every Strike deals **2 damage per struck monster**; the Kin adds its bound effect. **Confirmed costing policy:** mechanical Kin advantages count toward the same skill construction budget (§4.5); Kin identity does not make them free. Beast has no additional effect to price. Initial component prices for all Kins and all existing shapes are recorded in §4.5 as unvalidated calibration drafts; complete combination evaluation remains pending. Existing effects and battle-AP prices are unchanged. The numbers below describe gameplay effects, not construction-point prices:

|   Kin   |   Strike   |                                          Effect                                          |
|---------|------------|------------------------------------------------------------------------------------------|
| Beast   | Bite       | no effect                                                                   |
| Winged  | Dive       | then move 1 square away for free (the free neighbour farthest from the target)           |
| Scaled  | Tail Sweep | push the target 1 square (direction chosen with WASD)                                    |
| Swarm   | Gnaw       | props take double (4)                                                                    |
| Spirit  | Siphon     | target −1 initiative next round                                                          |
| Ancient | Slam       | cracks Elevated under the target → Rubble                                                |

### 3.3 Movement by Kin

Every monster has **Step**. Anything better is a movement skill in one of the 4 slots, and each Kin only has some of them. Each mode is a preset of movement flags (gdd_monsters §4.3).

|         Mode        |      Kin       |
|---------------------|----------------|
| **Step**            | all, no slot   |
| **Run**             | all but Spirit |
| **Leap**            | Beast          |
| **Glide**           | Winged         |
| **Burrow**          | Scaled, Swarm  |
| **Phase**           | Spirit         |
| **Blink**           | Spirit         |
| **Swim** *(planned)* | not assigned |

From **Soul Tier** on a monster may also learn **one mode of another Kin**, unless its body forbids it: an Ancient never gets Glide or Blink. A Normal monster ends at Core and so stays with its Kin's modes, which fits "rarity = flexibility" (§7.2).

Points in Movement only pay off with a movement skill; a Step-only monster stays at the frame's min.

---

## 4. Skills

**Single source for monster skills:** this chapter defines the kit/access (§4.1), shared data model and spatial/temporal contracts (§4.2), execution profiles (§4.3), effect/board-operation contracts (§4.4), point/AP calculation (§4.5), slot levels/development (§4.6), and complete reference records/validation (§4.7). Kin-specific content stays in §3, passive ideas in §5 and growth data in §7; none creates a second skill system.

**Boundary:** gdd_battle owns the general turn/event system, board state, zone/ground/prop state interactions and generic damage/displacement/collision resolution. Skill-specific execution rules live here, not in a parallel Battle skill chapter. gdd_overworld owns tamer skills, loadout and meta logistics/economy; those are not silently assigned monster-skill budgets. Confirmed rules override conflicting legacy proposals. Open decisions remain in temp_todo.md.

### 4.1 The Kit

```
Monster = Step (always, no slot)
        + 4 slots, each an active (movement skill, Strike (Kin), Surge, utility) or a passive,
          at least one active      — Epic+ get a 5th, passive-only slot (§7.2)
```

A movement skill is a normal slot skill and something different from **Step**, the universally available, slot-free 1-square move (2 AP). No kind of skill is mandatory. A kit may hold the same kind several times (4 Surges, or two movement skills and a Strike). Limits: the species' learnable list, the Kin's lock-outs (§3.1, §3.3) and one charging Surge at a time (gdd_monsters §4.3). All 4 slots are open from the first day.

**Kit design tip:** for a default kit, pair a Surge with a utility of a *different effect family* (protection, slowing or displacement) so there is always an answer in the kit. Themes are descriptive only; concrete skills define their zones, ground and effects, without theme-based bonuses or penalties. The prototype Tiger's 7 skills are a test bench, not a kit.

#### Species-Specific and Signature Access

Species exclusivity describes authorship and learn-list access, **not a `unique` mechanical kind, perk category or second construction system**. A species-specific skill uses the same §4.7 schema, a normal legal slot, its actual mechanical profile, existing interaction rules and an explicitly validated usage/point evaluation (§4.5). A species-specific zone or Surge keeps that profile's constraints; ownership is not an effect permission. Legacy `Unique` labels in companion documents must be mapped to concrete profiles/definitions before implementation, not kept as a catch-all profile.

Signature access remains Legendary/progression-bound (§7.2/§7.4); its concrete slot treatment and effect definition are not established by that unlock. Major Surge retains Ancient access at Sovereign, 2 AP and once per battle. The legacy ambiguity between Ancient Major Surge access and Legendary Signature access remains open under [temp_todo.md](temp_todo.md) T02/T32; it is not an active Battle rule or permission for every Legendary to learn a Major Surge. No new access or values are decided here.

A new effect requires an explicitly authored, validated definition; species exclusivity does not authorize arbitrary boosts, damage, healing, board removal or targeting. Upgrades use the same authorized field patches (§4.6), with no separate evolution count. Unresolved content belongs to central T02/T10–T12/T32, not a parallel catalogue here.

### 4.2 Data-Oriented Skill Construction Kit

**One model for every monster skill:** active actions, passive abilities, self buffs, targeted utility, movement, Strikes, Surges, zones and species-exclusive/Signature skills use the same fields. No `unique` effect, opaque script hook or second passive/buff schema bypasses construction or costing. Players choose finished definitions and authored upgrades, not arbitrary components.

**Separate representation from content approval.** The model must express a self buff or conditional passive without a structural exception. That does not approve its numbers, stacking, trigger, access or effect combination. Existing profiles preserve existing rules; new content uses the same typed contracts and remains draft until those rules and its cost are agreed. A genuinely new mechanic extends the shared effect vocabulary with explicit parameters, resolution, limits and costing—not a skill-specific escape hatch.

#### Common Field Structure

All top-level groups below are present in a resolved definition. Use `none` or `[]` for genuinely inapplicable groups. `pending` marks an unresolved draft and blocks content approval; it is never a runtime default. Field names are documentation notation, not engine serialization requirements.

| Field group | Required meaning |
|-------------|------------------|
| `metadata` | Stable id/name, descriptive tags, optional classification (`kind`) and optional reusable `rule_profile`. Classification is not an effect permission or price. |
| `access` | Species learn-list/exclusivity, Kin, progression and slot restrictions. No skill rarity/rating. |
| `usage_type` | `active` or `passive`; independent of theme, recipients or effect family. |
| `execution` | Activation (`player_action`, `while_equipped`, or a defined event), qualifying condition, resolution timing, telegraph/charging and any autonomous delayed execution. Always-on and event-driven passives are distinguishable. |
| `targeting` | What is selected (`self`, `unit`, `tile`, `prop`, or `none`), eligibility, distance source and sight. Event-driven effects may bind their recipient from the event without player selection. |
| `placement` | Body/board anchor, selected destination/path, binding and direction, or `none`. A self buff does not create a board anchor. |
| `area` | Explicit footprint/count/orientation and boundary rules, or `none` for non-area effects. Area is not cast range. |
| `effects` | Typed effect definitions with parameters/value sources, per-effect recipients/layers, application event, conditions, lifetime reference, stacking/refresh and resolution dependencies. Includes stat modifiers and rule modifiers, not just attacks. |
| `persistence` | Named lifetimes for created zones, states, props or pending actions: owner, duration/clock or end/consumption condition. Effects reference these entries; all effects of one zone share its clock. Delay is distinct from a buff's lifetime. |
| `board_changes` | Explicit typed ground, height and prop operations with targets, trigger/order and lifetime references, or `[]`. Natural damage reactions are resolved by their existing source rules. |
| `interactions` | Placement/effect/path blocking and other profile constraints. Recipient layers belong to each effect, not to global hit flags. |
| `usage` | Active battle AP cost and usage limits. Passives use `ap_cost: none`, not a zero-AP active action. No generic mana or cooldown system. |
| `upgrades` | Authored patches to these same fields, slot-level requirements, prerequisites/exclusions and explicit AP consequences. Empty while a draft's development path is unresolved. |
| `evaluation` | Derived component costs, AP-efficiency or passive-availability cost, total points and required slot-level ceiling. Legacy `combination_cost` fields are fixed at 0, not an additional price channel. Not a player currency. |

**Profiles are reusable rule bundles, not a closed menu of all possible skills.** Strike supplies body-relative hit rules, Surge telegraphing/charging, and Zone a persistent board area; movement presets supply traversal rules. A direct self buff or passive can use `rule_profile: none` and fully defined effects. Absence of a profile does not bypass damage delivery, access or other hard limits. `kind` and `rule_profile` are not independently purchased advantages; evaluate the resolved mechanics once.

**Effect recipients:** every effect resolves recipient scope (self/selected unit/area occupants/event-bound recipient), permitted relationship, unit layer (`ground`, `air`, or both where authorized), and prop eligibility where relevant. Different effects of the same skill can have different recipients; no automatic ally-only filtering or air access is granted. Self-bound state modifiers apply to their owner in its legal layer unless an explicit condition narrows this.

**No redundant hit/ground flags:** `affects_ground` and `affects_air` are retired as authoring inputs. Ground changes are described only in `board_changes`; air/ground recipients only in the effect's recipient definition. A UI summary such as “changes ground” is derived, never a second paid component. Historical/prototype flag names are not the current schema.

**Effect-level application and lifetime:** each effect names its application event, persistent-state owner if any, lifetime reference or `none`, stacking group and stacking/refresh rule where reapplication is possible. Multiple states can have distinct lifetimes; a zone still has one shared clock. Persistent states also specify what ends/removes them and when recipients/conditions are reevaluated. Missing event, stacking or termination rules stay unresolved, not inferred.

**Binding rules and validation:** §4.3 supplies existing profiles; §4.4 defines the shared effect vocabulary; §4.5 evaluates resolved mechanics; §4.7 checks six structurally different reference cases. No aspect/attunement field, automatic new trigger or budget-based override is introduced.

**Spatial contracts — targeting, placement and recipients**

These are separate responsibilities, resolved against gdd_battle §4.3–4.11 and the central execution profiles (§4.3). References may supply fixed fields; an unresolved rule is not a configurable permission.

| Contract | Required resolved data | Binding rules / open cases |
|----------|------------------------|----------------------------|
| `targeting` — what is selected | Selection type (`self`, `unit`, `tile`, `prop`, `none`), eligible target definition including side/layer where applicable, distance source and LOS rule | `none` means no player selection, not no effect recipient; event bindings must be explicit. `self` selects the caster; `unit` selects an eligible monster; `tile` selects a board cell, not its occupant; `prop` selects an eligible existing prop, not permission to create or relocate it. Side eligibility must come from the source; no generic ally/enemy filter is granted. |
| `placement` — where it resolves | Binding from selection to board anchor or body footprint, required adjacency, occupancy/layer constraints and separately selected direction/pull anchor | Zone/ground/prop/Surge anchors use effective Reach, Manhattan distance from caster to anchor, not distance to every affected cell. Strike uses its body shape without a ranged anchor; movement uses Movement ([§4.3](#43-skill-execution-profiles)). Authored twist exceptions stay explicit. |
| Effect `recipients` — what receives an effect | Referenced recipient rule, spatial scope and evaluation event/application condition, including side, air/ground and prop eligibility | Selection does not restrict an area to the selected unit or its side. Zones affect everyone occupying their cells; Strike hits allies but excludes its caster; Surge includes its caster and allies. Ground affects ground-layer occupants; prop reactions and Surge prop/occupant handling use their own rules, not a generic occupant hit (gdd_battle §4.6–4.7 and §4.3 here). |

- **LOS and legal placement are independent:** zone, ground, prop and Surge casts need no LOS; Shove and species-specific effects on another monster need sight, self boosts do not (gdd_monsters §4.2). No LOS exemption removes Reach, occupancy, layer or blocking checks. Exact sight geometry and unspecified direct-target eligibility remain open under [temp_todo.md](temp_todo.md) T02/T04/T09.
- **Occupancy is layer-specific:** retain one object, pending Surge, zone and ground type per cell; zones/Surges may land on props, ground needs prop-free cells except explicit reactions, prop creation needs empty cells. A charging Surge cannot overlap another charging Surge (gdd_battle §4.3 and §4.2–§4.3 here). FIELD-prop occupant handling and air occupancy remain T04/T09; do not infer a single universal `empty` test across layers.
- **Bindings are explicit, not tracking:** placed board footprints stay at their cast cells; push direction and pull anchor are fixed at cast (gdd_battle §4.4/§6.5 and §4.2 here). A selected unit supplies no implicit homing area, following zone, moving pull anchor or automatic retarget after movement/death. Unit-targeted definitions must specify resolution/validity behaviour where not already defined (T02/T04). Body-relative Strike placement is its own immediate rule, not a tracking precedent.

**Area contract — explicit footprint, not cast range**

Non-area skills explicitly use `area: none`; no cell count or artificial footprint is required. For area skills, required resolved data are: shape/profile reference, explicit distinct integer cell offsets relative to a declared anchor/body origin, `cell_count`, authored orientation and its permitted selection policy, plus board-boundary and blocking/placement references. A reusable footprint definition may own the offsets; the skill need not duplicate them. `cell_count` must equal the offset count; family name or an unexplained orientation number alone is insufficient to reconstruct the cells.

- Tetris family/count and orientation options are listed under [Footprints and Placement](#footprints-and-placement). The anchor is the centre-most cell; its exact offset mapping must be authored, not chosen by a runtime tie-break. Size limits are defined in [§4.5](#45-construction-points-and-ap-efficiency); Strike's separate body footprints (§3.2) and Major Surge's explicit access/profile are not generic size overrides.
- Normal tetris skills have one authored shape family and one fixed absolute board orientation for both teams, not caster facing, team mirroring or a default rotation. Only existing Adaptive permission enables in-battle rotation; Strike separately selects one of eight directions (§4.2–§4.3). Push direction is not footprint rotation. Missing offset/orientation mappings remain T02, not permission to invent a default.
- **No boundary clipping:** every footprint cell must be on the board (gdd_monsters §4.2); do not trim, shift or rotate it automatically to fit. Profile-specific blocking/reactions remain distinct from boundary validity: Strike solid-prop blocking, ground/prop occupancy and Flood's Elevated blanking retain their existing rules (gdd_battle §4.3 and §4.2–§4.3 here). Do not generalize these into universal obstacle clipping or automatic footprint resizing. Forced-movement collision uses gdd_battle §6.3, not area placement.
- Footprint cells are not automatically distinct monster hits. For **2×2 bodies**, Reach origin/target distance, body-relative origins, partial overlap, recipient deduplication/damage multiplicity, mixed ground/height/layer occupancy, landing and displacement are insufficiently defined (T04/T09). Do not infer one hit per cell, one hit per unit, partial placement or a collision-resolution default. Preview/validation must expose unsupported cases rather than silently decide them.

**Temporal contract — execution, effect events and lifetime**

| Responsibility | Required resolved data | Existing binding rule |
|----------------|------------------------|-----------------------|
| `execution` | Immediate vs telegraphed delay, exact resolution event, charging/telegraph and autonomy rules where applicable | Immediate resolves the action now, not every effect now. Bind Surge execution to the [Surge profile](#surge) and its scheduling interface in [Battle §2.2](gdd_battle.md#22-initiative-rules); do not substitute a generic one-round delay. |
| Effect trigger/application | Referenced event, whose turn/entry it is, recipients at that event and ordering dependencies | Existing resolution, `start_of_turn`, `on_enter`, `while_inside`, Surge-damage protection and `end_of_turn` events remain definition-bound (gdd_battle §2.4/§4.6–4.7). `while_inside` is continuous, not a repeating cast. |
| `persistence` | Owner of the lifetime, clock/event, duration or consumption/removal condition, expiry result | Reference [Battle §4.5](gdd_battle.md#45-lifecycles) for board-state lifecycles and [Battle §4.10–§4.11](gdd_battle.md#410-damage-shatter--prop-types) for prop removal/reactions. Distinguish pending execution, any authored aftermath and self-bound states; effects of one zone share its clock. |

**Runtime interface:** reference the turn/round sequence in [Battle §2.1](gdd_battle.md#21-core-battle-loop), event meanings and ordering in [Battle §2.4](gdd_battle.md#24-effect-timing-reference), and ground-entry semantics in [Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed). Each effect binds to those events; authored round duration is not a count of caster actions.

Persistence adds no payload or repeat trigger absent an explicit definition. Action repetition follows [Battle §2.3](gdd_battle.md#23-action-points). Missing trigger/lifetime contracts and unresolved timing remain tracked in [temp_todo.md](temp_todo.md) T02/T04/T07/T09/T19, not inferred defaults.

#### Footprints and Placement

The following table lists the existing tetris footprint families and their authored orientation options. Selection, anchor distance, occupancy, binding and boundary requirements are defined in the spatial and area contracts above; Step and non-area effects need no tetris footprint, and Strikes use their own [body shapes](#32-strike-by-kin).

|  Family | Cells | Orientations (incl. mirror) |
|---------|-------|-----------------------------|
| I2      |     2 |                           2 |
| I3      |     3 |                           2 |
| L3      |     3 |                           4 |
| O4      |     4 |                           1 |
| T4      |     4 |                           4 |
| S4 / Z4 |     4 |                           4 |
| L4 / J4 |     4 |                           8 |

Orientation counts are authoring options, not in-battle choices; the area contract above owns fixed orientation and Adaptive's exception. Outside-battle changes follow [§4.6](#46-slot-levels-development-replacement-and-upgrades). Adaptive's existing UI shortcuts are `R` / right-click.

**Preview interface:** colour each square (**new / levels up / replaces / weakens / cancels / blocked**) and list concrete ground/prop reactions, displacement landing squares and resolved Surge damage after applicable reductions. Runtime outcomes come from the referenced Battle rules, not from preview labels.

#### Interaction Fields

Blocking is scoped to placement, effect propagation or movement traversal; a shared flag name does not imply the same test in each scope.

| Field / responsibility | Meaning |
|------------------------|---------|
| `blocked_by_objects` | Profile-specific prop blocking; does not grant LOS or imply a universal empty-square test. |
| `blocked_by_height` | Whether the relevant placement/effect/path can reach Elevated cells. |
| `blocked_by_monsters`, `blocked_by_surges`, `ground_costs`, `distance_mod`, `path` | Movement-profile parameters (§4.3), resolved with path and landing rules. |
| Effect recipient layers | Ground/air eligibility per effect, not a global `affects_air` switch. |
| Explicit board operations | Ground/height/prop changes under `board_changes`, not an `affects_ground` switch. |

Lifetimes belong to `persistence` and their effect references, not an interaction flag. Fixed profile values may be referenced instead of duplicated, but must resolve unambiguously.

#### Sight and Target Eligibility

The spatial contracts above own LOS, target selection and placement eligibility. A complete record references them through `targeting` and `placement`; unresolved sight geometry and target-validity cases remain [temp_todo.md](temp_todo.md) T02/T04/T09.

#### Reading a Complete Skill Definition

Read a record in this order: **who may equip it → active/passive activation → target selection and placement, if any → each effect's recipients/event → lifetime and stacking → explicit board operations → usage and point evaluation**. An effect's application event is not automatically the skill's activation event; a cast zone can apply its modifier continuously after the action ends. A passive can be continuously available while producing effects only on its declared event.

The same groups are resolved in all six §4.7 references. There is no requirement that every skill create an area, pending marker or status. Access, a profile reference and a descriptive tag do not themselves produce effects or grant unpriced bonuses.

### 4.3 Skill Execution Profiles

These are the central definitions of monster-skill execution. Battle chapter 5 links here rather than maintaining a second skill chapter. Generic board state, event scheduling, damage mitigation and collisions remain in gdd_battle chapters 2, 4 and 6.

#### Profile Overview

|   Kind   |      Writes to      |                                         In battle                                          |
|----------|---------------------|--------------------------------------------------------------------------------------------|
| `strike` | squares around the body | small direct damage in a shape around the monster ([central skill rules](#43-skill-execution-profiles))                               |
| `surge`  | Surge layer; ground only via explicit `board_changes` | telegraphed delayed execution ([central skill rules](#43-skill-execution-profiles)), including the existing burst profiles; optional, separately budgeted residue; only one charges per monster at a time |
| `zone`   | zone layer          | timed control or support on squares (gdd_battle §4.6), lasts for the skill's `duration`               |
| `ground` | ground layer        | hazard ground or Elevated (gdd_battle §4.7)                                                           |
| `prop`   | object layer        | places or moves props (gdd_battle §4.9)                                                               |
| `direct` | a unit              | unit/self-targeted immediate effects; existing Shove resolves under gdd_battle §6.5; new buffs require explicit effect contracts                                                               |
| `move`   | the caster          | moves the caster ([central skill rules](#43-skill-execution-profiles))                                                                    |

These are existing reusable profiles, not a closed construction menu. Direct buffs and passives use the common model without masquerading as a Strike, Surge or Zone. A passive has passive activation, not a separate serialization format; species exclusivity is access data, not a `unique` execution type.

#### Strike

A Strike hits a **shape around the monster's own body**: no anchor and no range, the shape starts on the squares next to the monster. It doesn't use Reach. Max 2 damage, lands instantly. Spend the selected shape's authored price (gdd_monsters §3.2, central costing §4.5); a larger shape does not trade damage for area. The existing Swarm exception deals 4 to props, not monsters.

- There is **no facing**: the player picks the direction when striking
- It hits **every monster and prop in the shape**, allies included, never the striker itself
- A solid prop takes the hit and blocks the squares behind it
- The player picks one of 8 directions. Which shapes exist and what the Kin adds: gdd_monsters §3.2

#### Surge

A **Surge is telegraphed delayed execution**, represented by a pending marker with a timer — same shapes and placement as zones, its own slot, different lifecycle. Surge alone does not imply residue: ground aftermath is an **optional, explicit, separately budgeted `board_changes` effect** under gdd_monsters chapter 4. For a damage profile with residue, **damage resolves before the authored ground aftermath**. No new point prices are assigned here; effect legality, AP evaluation and validation follow §4.4/§4.5/§4.7.

```
MINOR SURGE
  shape/placement: resolved authored footprint and constraints (§4.2/§4.3), checked under [central skill rules](#42-data-oriented-skill-construction-kit)
  range: effective Reach to anchor unless an explicitly approved baseline profile says otherwise
  charging: visible, blocks movement through its squares
  fires: at the START of the caster's next turn (simple alternating 1v1: after the opponent's turn)
         if the caster died, it fires when the caster's slot in the queue would have come up
  autonomous: not cancelled by displacing / killing the caster
  per-square result:
    monster  → authored value, reduced by Veil and Hallowed (minimum 0 damage)
               (hits every monster on its squares — allies and the caster included)
    prop     → ordinary prop hit under Battle §4.10, with explicit reactions under §4.11
    Elevated → depends on the Surge type (table below)
  afterwards: only if explicitly authored, apply the separately budgeted RESIDUE
              board_changes effect (permanent ground, gdd_battle §4.7), subject to its profile's
              height rules below; otherwise no residue; no repaint
  usage: spend authored AP (§4.5); ONE charging Surge per monster
  claims squares: can't be placed on squares already holding any charging Surge (the first one claims them)

MAJOR SURGE
  shape/range: requires an explicitly authored large-area profile, not a generic size/range override
  usage: once per battle; authored AP and access: §4.5/§4.1
  open: legacy up-to-half-board/long-range wording needs a concrete definition (T02);
        Ancient vs Legendary Signature access remains T02/T32, not permission for either by inference
```

Prop interception, ordinary prop damage and destruction are resolved by [Battle §4.10](gdd_battle.md#410-damage-shatter--prop-types); explicit reactions use [Battle §4.11](gdd_battle.md#411-prop-reactions). The profile table below selects those reactions; it does not redefine their runtime resolution.

**Surge types on concrete skills.** Existing concrete Surge skills explicitly specify **Eruption**, **Flood** or **Rift**, independently of the monster's theme. Their authored residue effects remain part of those profiles; optional residue in the general construction model does not remove them. Surge timing alone neither requires one of these profiles nor authorizes a new effect combination; definitions still require validation under gdd_monsters chapter 4. These are mechanical Surge profiles, not monster aspects or replacement elements. "Flood" denotes a Surge type, never a zone, and need not look like water. The existing profiles retain the following concrete damage, residue, prop and height effects:

|     Type     | Damage |     Residue (permanent, level I)      |                                                                     Props                                                                     |                            Elevated                           |
|--------------|--------|---------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------|
| **Eruption** |      3 | **Lava I** — burns at end of turn     | Trees ignite                                                                                                                                  | hit normally, **no residue** there (lava runs off)            |
| **Flood**    |      2 | **Thornbed I** — hurts when entered   | pushes struck monsters 1 square in the direction set at cast (into the thorns it just laid); extinguishes burning Trees; heavy props block it | **can't reach it** (square blanked)                           |
| **Rift**     |      3 | **Blight I** — hurts at start of turn | brittle props crumble                                                                                                                         | **collapses** to Rubble, the monster on it still takes damage |

So Elevated is a real decision: high ground is safe against a Flood, normal against an Eruption, and a trap against a Rift.

**Runtime counter menu** (authoring validation of live counters: §4.2/§4.4/§4.5/§4.7):

|            Counter             |                                                         How                                                          |
|--------------------------------|----------------------------------------------------------------------------------------------------------------------|
| **Leave**                      | move out of its squares before it fires — but mind any explicitly authored residue                                             |
| **Veil it**                    | a Veil over its squares: shield 2 (up to 3 with level) cuts damage 1:1 per square; recast to level up |
| **Pick the height**            | Raise Ground: blanks a Flood, no residue from an Eruption — useless against a Rift                                   |
| **Stand on Hallowed** | Use its Surge reduction and replacement contract in [Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed) |
| **Fly over it**                | Existing Surge damage recipients exclude air; the air layer is out of reach (Winged, Soul+)                                       |
| **Props / debris** | Use the interception/destruction rules in [Battle §4.10](gdd_battle.md#410-damage-shatter--prop-types), subject to the interim prop status |
| **Answer with your own Surge** | race it — but you can't claim squares already held by a charging Surge                                               |
| **Control the tempo**          | slow / pull / push zones to steer where the target can stand; drain the caster's initiative to delay its next turn      |

#### Movement

Resolve **Step** as the universal one-square action; slotted movement uses the presets below. Kit/access and AP evaluation are defined in §4.1/§4.5; Kin preset access remains §3.3. Movement distance uses effective **Movement**, not Reach.

A movement skill is not a list of special cases but a **profile of flags**. The modes are authorized presets, not player-selectable permissions; a separately authored flag profile still requires access and complete validation (§4.2/§4.4/§4.5/§4.7):

|          Flag          |                                     Meaning                                     |
|------------------------|---------------------------------------------------------------------------------|
| `path`                 | `walk` square by square · `line` straight line, only the landing square counts · `free` any path, only the landing square counts · `teleport` any free square in range |
| `blocked_by_objects`   | solid props block the path                                                      |
| `blocked_by_monsters`  | monsters block the path                                                         |
| `blocked_by_surges`    | charging Surges block the path                                                  |
| `blocked_by_height`    | can't start or end the move on Elevated                                         |
| `ground_costs`         | Rubble, Water and climbing cost 2 movement, Thornbed fires on every square entered (walk only) |
| `distance_mod`         | distance = Movement + this (min 1)                                              |

|       Preset       | path | objects | monsters | Surges | height | ground costs | distance_mod |
|--------------------|------|---------|----------|--------|--------|--------------|--------------|
| **Step**           | walk | yes     | yes      | yes    | no     | no (and ignores `slow`) | always 1 |
| **Run**            | walk | yes     | yes      | yes    | no     | yes          | 0            |
| **Leap**           | line | no      | no       | no     | no     | no           | 0            |
| **Glide**          | free | no      | no       | yes    | no     | no           | −1           |
| **Burrow**         | free | no      | no       | no     | yes    | no           | −1           |
| **Phase**          | walk | no      | yes      | yes    | no     | yes          | −1           |
| **Blink**          | teleport | no  | no       | no     | no     | no           | −2           |
| **Swim** *(planned)* | walk | yes   | yes      | yes    | no     | yes, Water costs 1 | 0      |

- **Price rule:** every restriction a preset drops is paid for in distance or in direction (Leap: straight line only). New modes follow it
- Apply only the resolved, authorized movement variant; upgrade allowances and AP consequences belong to gdd_monsters §4.6, not a second battle upgrade rule
- Min 1 square for every movement skill. Step ignores slow and extra ground costs, but still requires a legal unblocked destination
- Ignoring path blockers does not allow an occupied landing square. Walk processes entered cells; line/free/teleport count only landing, with destination effects still applying. Glide is not persistent flight; air and 2×2 traversal/landing remain T09, Water/Swim T08

#### Surge Constraints and Species Access

A Surge may have **at most one authored twist**: one extra rule, readable in the preview, with its advantage priced under §4.5/§4.6. A twist is represented by placement, area, execution, effect or residue data and explicit profile constraints, not a second schema or a universal menu of named powers. Existing battle rules remain authoritative (§4.2–§4.3); old damage/range candidates grant no new exceptions or upgrade permissions.

Preserve the existing structural restrictions when authoring or upgrading a constrained Surge:

| Authored constraint | Validation |
|---------------------|------------|
| Adjacent anchor | Anchor stays adjacent; an existing 4-cell footprint has no Size path. |
| Straight trail from an adjacent cell | Footprint starts adjacent and stays straight; only legal I2/I3 families/orientations. |
| Four cardinal neighbours of the caster | Excludes the caster cell; no Shape or Size path. This special footprint is not generic ranged targeting. |
| Enlarged footprint | Result stays within its profile/Kin cell cap; do not charge the same enlargement twice. AP consequences follow §4.6, not an automatic surcharge. |
| Pull after damage | Existing one-square cardinal displacement toward an anchor fixed at cast; gdd_battle §6.5. |

**Species Surge:** every species has one Surge with its own species twist. It belongs to the default kit and learnable list, but remains an optional normal slot skill (§4.1). Shape/Size upgrades must preserve its constraints; no Twist replacement path is offered. Species ownership is access/authorship data on the same definition, not a new mechanical kind. Concrete species twists and roster placeholders still need design/validation (T10–T12).

### 4.4 Effect and Board-Operation Contracts

**Effect catalogue — data, not skill blueprints**

`damage`, `displacement`, `stat_change`, protection, healing, self movement and board operations are typed contracts, not independently purchasable permissions. Every entry requires a referenced **effect definition**, legal owning rule profile/source, recipients, trigger/application and resolution order. The definition supplies allowed parameters, caps, interactions and termination; a skill supplies only explicitly permitted values. Fixed definition fields must not be duplicated as independently editable choices. References below describe documentation contracts, not new engine identifiers.

**`damage` — apply an existing damage source**

Required data: source/profile definition, profile-authorized value or value source, footprint/recipients, trigger and ordering reference. Reduction, prop reactions, height and air eligibility come from that profile, never from a generic damage flag.

| Existing source/profile | Permitted value and recipients | Trigger, order and limits |
|-------------------------|--------------------------------|---------------------------|
| Strike | 2 damage under §3.2, max 2 against monsters; every monster and prop in its body footprint, allies included, excluding the striker. Existing Swarm exception: props take 4 (§3.2), not monster burst damage | Immediate; no Reach targeting. Solid props take the hit and block squares behind them; Kin twist and §3.2 / gdd_monsters §4.3 remain binding. Strike reaches air. |
| Surge | Eruption 3, Flood 2, Rift 3 against monsters, including allies and caster; the residue-free §4.7 reference proposes fixed 3, not a new balance approval. Normally 2 against a prop instead of its occupant, subject to explicit reactions | Delayed: start of caster's next turn, before start effects. Apply profile height/prop handling and reduction (shield, Hallowed; minimum 0), then explicitly authored residue, if any. Eruption hits Elevated without residue; Flood cannot reach Elevated; Rift collapses it. No air hits. See §4.3 and gdd_battle §6.2. |
| Hazard ground | Reference the concrete ground definition in [Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed) for value, recipients and caps | Bind its existing event under [Battle §2.4](gdd_battle.md#24-effect-timing-reference). Placement is `board_changes`, not immediate damage. |
| Collision / fall / debris | Reference [Battle §6.3](gdd_battle.md#63-collision-fall--debris) for event damage and recipient exceptions | Derived runtime consequences, not free castable payloads. The unresolved collision conflict remains T04. |

Prop exceptions remain explicit: Eruption ignites Trees instead of prop damage; Flood does not damage/move heavy props; Rift adds the existing brittle-prop reaction; indestructible props cannot be removed (gdd_battle §4.10–4.11). Major Surge and baseline twist exceptions require their own authored definition and access/usage rules; this catalogue supplies no new damage value. **Zones never deal damage; no immediate ranged burst or new damage zones.** The retired collision-bonus proposal remains unapproved (T04), not an exception to the collision law. Damage values are not slot-upgrade parameters (§4.6).

**`displacement` — forced movement under an existing source**

Required data: definition/source, `mode: push | pull`, recipients, `steps`, trigger/order and direction or anchor binding. Bind cardinal direction, step limit and fixed pull anchor to [Battle §6.5](gdd_battle.md#65-displacement); Tail Sweep selects its direction with the Strike. Preview the landing square. These contract fields do not authorize a distance upgrade beyond the existing hard cap.

| Existing source | Recipients and trigger | Binding constraints |
|-----------------|------------------------|---------------------|
| Zone `push` / `pull` | Occupants under [Battle §4.6](gdd_battle.md#46-zones-effects-rules--opposites) | Bind direction/anchor and trigger to [Battle §6.5](gdd_battle.md#65-displacement), with ordering under [Battle §2.4](gdd_battle.md#24-effect-timing-reference). Persistence creates no additional trigger. |
| Direct displacement (Shove) | Selected unit, one-time direct resolution | Sight required; legal target/layer restrictions must be authored, not borrowed from removed table flags. Generic displacement does not authorize prop relocation. |
| Scaled Strike (Tail Sweep) | Struck monsters, push 1 | Existing Kin twist (§3.2); chosen direction and Strike constraints. |
| Flood Surge | Struck monsters, push 1 in cast direction | Retains Flood damage, residue, height and heavy-prop rules; damage/residue/push order needs reconciliation below. |
| Authored pull twist | Struck monsters, pull 1 toward cast anchor after damage | Existing twist (§4.3); no arbitrary extra target or trigger. |

Blocking/collision/fall results use [Battle §6.3](gdd_battle.md#63-collision-fall--debris), entry effects use [Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed), and prop destruction uses [Battle §4.10](gdd_battle.md#410-damage-shatter--prop-types). No chain push, diagonal step, extra step or air/prop eligibility is implied. Collision conflicts, Flood/Tail Sweep ordering and pull ties remain unresolved under [temp_todo.md](temp_todo.md) T04; this catalogue supplies no default resolution.

**`stat_change` — referenced effective modifiers, not arbitrary stat edits**

Required data: a typed `stat_change` definition with stat, operation, value/value source, recipients, application condition, lifetime, stacking group/rule, caps/floors and ordering. The shared model supports timed self buffs, conditional passive modifiers and zone modifiers; the approved effect definition constrains which parameters a finished skill may choose. Existing named definitions retain their fixed stat, sign and timing. New combinations remain drafts until validated. Effective modifiers never rewrite the base sheet. Zone modifiers apply to **everyone while inside**, stop on leaving/removal/expiry and use zone replacement/opposition/level rules (max III), not cumulative permanent deductions (gdd_battle §4.6). Zone level III is not permission for value 3 on every effect. Referenced zone effect definitions own `base`/`cap`; the level-to-value computation is in [Battle §4.6](gdd_battle.md#46-zones-effects-rules--opposites); concrete skills must not replace that with unrestricted stat deltas. Missing numeric caps or scaling formulas remain open, not new defaults.

| Existing definition | Meaning / existing authored values | Bounds and timing |
|---------------------|------------------------------------|-------------------|
| `slow` / `haste` | Movement −value / +value; retain authored values such as slow 1 | While inside; `slow` never lowers Movement below 1; **Step is unaffected**. This changes Movement-skill effectiveness, not AP cost, TPR or a permanent stat. |
| `drain_init` / `quicken` | Effective initiative −value / +value; examples include −1, −2 and +1 | While inside; order recalculated each round (gdd_battle §2.2). No immediate queue rewrite or arbitrary numeric interval. General effect-value caps/floors are not specified by gdd_battle §4.6 and remain open. |
| `drain_range` / `extend` | Effective Reach −value / +value; examples include −1, −2 and +1 | While inside; Reach minimum 1. No independent per-skill range stat. Upper modifier/value caps require clarification, not extrapolation from progression ceilings. |

The existing Spirit Strike **Siphon** applies target initiative −1 next round (§3.2), not `while_inside`. It uses the same `stat_change` contract with a distinct referenced timed definition preserving that trigger and expiry, not a free timing override on zone `drain_init`; stacking/refresh details remain open. This does not authorize arbitrary timed Initiative/Reach/Movement effects.

Hearth / Shrine supply existing `quicken 1`, Umbra / Sigil `extend 1`; Elevated supplies its authored +1 Reach while occupied. These sources retain their ground/prop/height conditions, not zone expiry or free source substitution (gdd_battle §3.1, §4.7, §4.10). Definition-specific caps are distinct: `shield` has the existing Surge reduction (2, up to 3 with level, gdd_monsters §4.3), `mend` cannot exceed max HP, and `expose` is reserved with no zone. These are reduction/healing/reserved definitions, not generic stat-change permissions.

No general temporary **TPR, AP, HP maximum or movement-rule/flag** edits are approved. A species-specific timed boost needs an explicit authored definition, duration, limits and validation (§4.1); its existence does not unlock arbitrary stat changes. Authored base-skill Reach debuffs and existing positional Reach buffs are temporary battle effects, **not cast-range upgrades**. Slow is not AP reduction. Slot development still grants no damage increase, AP reduction or cast-range increase (§4.6); budgeting never overrides these prohibitions.

**Persistent self buffs and passive rule modifiers — shared contracts**

A timed self buff uses ordinary `stat_change` (or another applicable typed effect) with self recipients and an explicit persistent-state lifetime. A status is runtime state created by an effect, not a separate kind of skill. Specify reapplication (stack/refresh/replace/ignore), stacking identity across skills/sources, removal, and any caster/recipient death dependencies. The §4.7 initiative-buff record is a structural draft, not approval of generic timed boosts.

A passive may use the same `stat_change` effect continuously/conditionally, or a typed **`rule_modifier`** when it changes a rule instead of a stat. Every rule modifier names the exact rule being changed, scope (e.g. owner's shapes), authorized operation/parameters, activation condition, lifetime, stacking and resolution precedence. Adaptive's rotation permission is the structural reference in §4.7; this does not approve arbitrary rule mutation. Event-driven passive effects use these same effect/board-operation contracts, with explicit event source, recipient binding, repeat/recursion limits and ordering. Undefined event policies block that content.

No opaque `custom_effect`, per-skill callback or ownership-based permission is a complete definition. Future mechanics extend these shared typed contracts and the common costing rules. Source-specific validation constrains content, not which skill families the schema can represent.

**`shield` / protection — referenced reduction, not shield HP**

Required data: protection definition and owning source/profile, permitted reduction/value source, protected recipients and damage sources, application condition, damage-event ordering, lifetime/consumption and stacking/cap references. Protection neither grants temporary HP nor edits a defense stat. Fixed source rules cannot be replaced by a generic immunity or damage-filter field.

| Existing definition/source | Recipients, trigger and lifetime | Ordering and caps |
|----------------------------|----------------------------------|-------------------|
| Zone `shield` (Veil) | Bind recipients/application to [Battle §4.6](gdd_battle.md#46-zones-effects-rules--opposites) and lifetime to [Battle §4.5](gdd_battle.md#45-lifecycles) | Existing reduction 2, up to 3 with zone level ([Surge profile](#surge)); definition owns scaling/cap. No independent charges or effect timer. |
| Hallowed ground | Reference [Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed) for occupants, reduction and ground lifetime | Preserve the Surge profile's residue/height interaction; do not invent a separate hit-consumption rule. |


Retired proposals for Lava immunity, prop reinforcement or Strike reduction are not options on generic `shield`; any such content needs separate validation (T02/T04/T10). `expose` remains reserved. Spirit Shield belongs to the tamer source (gdd_overworld §6.4, once per battle); it does not authorize a repeatable monster immunity. Additional protection sources require authored definitions, not source substitution or a new default stacking rule (T02/T04/T20).

**`heal` — restore current HP only at an existing trigger**

Required data: healing definition/source, authorized amount/value source, recipients, trigger, ordering, lifetime and cap/usage references. Healing never exceeds the recipient's existing max HP, changes max HP, revives a fallen monster or removes Injury. Definitions bind the event; persistence alone grants no heal on cast, per tick or extra activation.

| Existing definition/source | Recipients and trigger | Lifetime, order and caps |
|----------------------------|------------------------|--------------------------|
| Zone `mend` | Reference recipients/trigger in [Battle §4.6](gdd_battle.md#46-zones-effects-rules--opposites); existing Healing Spring example: `mend 1` | Ordering uses [Battle §2.4](gdd_battle.md#24-effect-timing-reference); zone lifetime is shared. Level scaling and numeric healing cap remain open under T07, not implied by max zone level III. |
| Mossbed | Reference occupants, entry trigger and heal amount in [Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed) | No additional placement or continuous heal. Per-turn/re-entry limits remain T07; this contract does not approve arbitrary heal loops. |

No generic immediate/direct monster heal, ally-only healing zone or new repeat trigger is approved. Second Wind is a **proposed tamer skill**, not a monster healing definition. Healing pills restore HP **between battles**, current HP persists through an expedition, and Revival ends Injury rather than supplying battle healing (gdd_overworld §5.2, §6.4–6.6). Planned in-battle medicines/arrays need their own source, consumption, loadout and timing contracts (T18/T19); the generic `heal` entry supplies none of those permissions. Healing economy and repeat-entry balance remain central T07 work.

**Self `movement` — voluntary relocation of the caster**

Required data: movement definition/source and authorized preset/exception, `recipients: self`, resolution trigger, origin and selected path/destination, distance source, path/landing/occupancy constraints, ordered traversal/entry events, action lifetime and usage/cap references. This is not forced `displacement`, unit relocation or prop movement. Resolve one movement action under gdd_monsters §4.3; it creates no persistent movement permission.

- **Step:** always available without a slot, 2 AP, exactly 1 square; retain its walk/blocking rules, ignore `slow` and extra ground costs. It is not a freely upgradable Movement skill.
- **Slotted movement:** 2 AP, authorized Run/Leap/Glide/Burrow/Phase/Blink preset; distance = effective Movement + the preset's modifier, minimum 1, **not Reach**. Preserve the full preset's path, prop/monster/charging-Surge/height blocking and ground-cost rules, including climbing and walk entry effects. Path modes that count only landing do not inherit walk traversal triggers; destination effects still use their existing rules. Ignoring path blockers never authorizes an illegal occupied landing square.
- Preset access and foreign-mode exceptions remain §3.3 rules, including body restrictions and stage access. Blink's teleport path is available only through its authorized profile; a generic `path: teleport` override is not permission for any monster to teleport. Glide does not grant persistent flight or access to the air layer. Winged air access requires Soul Tier; flight, air occupancy and 2×2 movement details remain T09. Water/Swim are planned and remain T08, not a new legal preset for unspecified Kins.
- Authored flag-based modes must satisfy the existing distance/direction price rule and access constraints; fields are not player-selectable bypasses. Slot upgrades are named patches under §4.6: the existing one-flag-flip/distance-penalty allowance is not an unrestricted path-mode, flight, teleport, extra-action or range upgrade. Validate the complete resolved profile, entry ordering and destination preview; unresolved large-body/movement cases stay T04/T09.

Spatial Pull, Swap Places and Beast Swap are separate tamer-source definitions (including proposal status where applicable), not self-movement presets or a shortcut around monster access rules (gdd_overworld §6.4; T19/T20).

**`board_changes` — typed ground, height and prop operations**

Each entry requires an operation definition, legal source/profile, selected cells or prop and destination where relevant, cast/resolution trigger, before/after dependencies on damage/reactions, resulting state and lifetime, plus placement/blocking/occupancy and cap references. Recipients here are **board cells/props**, not a selectable ally/enemy filter on later occupants. Resulting hazards, healing and modifiers retain their own effect contracts. Board operations are one-time state transitions unless an existing definition explicitly supplies a later event; permanent state is not repeated execution.

| Operation | Required operation-specific data / existing source | Binding lifetime, ordering and limits |
|-----------|----------------------------------------------------|--------------------------------------|
| Ground placement / replacement | Concrete ground definition and permitted level/source, footprint; Field, Blessing or specified Surge residue | State, replacement/levelling, entry semantics and Voidscar exception: [Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed). Placement uses §4.2; prop reactions use [Battle §4.11](gdd_battle.md#411-prop-reactions). Surge aftermath follows its §4.3 profile. Zone × ground remains T07; Water remains T08. |
| Height change | Separate height definition, affected cells and existing source, e.g. Raise Ground, Rift or debris collapse | Reference [Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed) for height state and Raise Ground's coupled Plain reset, and [Battle §6.3](gdd_battle.md#63-collision-fall--debris) for fall/collapse consequences. Declare coupled operations explicitly; height edits grant no generic damage or displacement payload. Surge-specific height handling remains §4.3; no new height levels or timed expiry. |
| Prop create / place | Existing prop definition (HP, solid/field/flying kind, tags and reactions), legal footprint and creation source | Placement uses §4.2; state and prop definitions use [Battle §4.9–§4.10](gdd_battle.md#49-props). Enterable FIELD props grant no creation-under-occupant permission. Reference existing lifetime/HP; unsupported occupancy/layer cases remain T04/T09. |
| Prop move / relocate | Authorized source, selected prop, origin/destination and applicable path/placement constraints | Reference placement in §4.2 and prop restrictions in [Battle §4.10–§4.11](gdd_battle.md#410-damage-shatter--prop-types). Generic unit push/pull is not a prop-move definition. Relocate's unresolved distance/path/reaction contract remains T02/T04, without inferred defaults. |
| Prop destroy / remove | Existing destruction/reaction definition and eligible prop; damage-derived destruction references the damage source, not a free deletion flag | Reference the interim destruction/reaction rules in [Battle §4.9–§4.11](gdd_battle.md#49-props) and derived debris in [Battle §6.3](gdd_battle.md#63-collision-fall--debris). The prop redesign remains T04. Direct deletion, salvage or suppressed debris requires a separately approved source; removal does not imply universal shatter. |
| Cleanse | Explicit source, exact affected layer/state, legal footprint/recipients and resulting state | Raise Ground clears non-Voidscar ground to Plain as above; Any additional monster zone-cleanse effect requires an explicit source-specific definition and validation (T02/T04); no such definition is established here. Zone removal ends its effects, not ground/height/props or a charging Surge. Domain Glimpse's zone removal plus Plain reset is a tamer-source operation (gdd_overworld §6.4), not a reusable monster permission. No generic cleanse of all layers, negative effects, Injury or Voidscar; unresolved combinations/order remain T02/T04/T07/T20. |

All operations retain Reach/anchor, fixed footprint, on-board placement, LOS and blocking rules of the owning profile (gdd_battle §4.3–4.11 and §4.2–§4.3 here); no LOS for existing ground/prop casts is not permission to bypass empty-square requirements. The preview must expose resulting ground/height/props, reactions and derived damage. Conflicting or underspecified simultaneous damage, collapse, debris, residue and relocation ordering remains T04/T07, not an inferred list-order default. Planned loadout operations stay T18/T19. No new prop types, conversion mechanics, board erasure or movement modes are approved by this catalogue.

### 4.5 Construction Points and AP Efficiency

**Confirmed model: one shared base budget, no skill ratings, upper bounds only.** All regular monster skills use the same construction system; there are no Rare/Epic/Legendary/Mythical skill budget classes. Monster rarity and species exclusivity do not automatically grant additional skill points. Slot levels 1–3 increase the budget ceiling. Major Surge and Signature content still requires its explicit access/profile review; it does not establish a general higher-budget skill rating.

```text
skill point cost = mechanical component costs
                 + availability cost

availability cost = AP-efficiency cost (active skills)
                  or passive-availability cost (passive skills)


allowed ceiling = shared base budget + slot-level allowance

skill point cost <= allowed ceiling
```

- **AP efficiency is an authored, evaluated property.** Fewer battle AP per use is a powerful advantage and consumes more construction points; a higher AP cost leaves more room for effects within the same ceiling. Do not charge more points merely because a skill spends more battle AP.
- Designers author the finished skill including its AP cost, then validate the full point cost. This is not an AP-class budget ladder: AP cost is part of the skill's evaluated cost, not a separate source of budget.
- Component base prices are shared. **No combination surcharges:** price the actual components once, without an additional tax for combining them. Test interactions and adjust responsible component prices/rules if needed; redundant tags/flags or the same enlargement are never charged twice.
- Telegraphing, blocking and other restrictions must be evaluated in context; no arbitrary negative-cost credits or new exceptions are authorized before calibration.
- Optional Surge residue is a separate board-operation component, including its interactions. Delayed execution or damage does not include a mandatory ground payload.
- **Only the upper ceiling is binding.** No minimum cost, target band, exact-spend requirement or random budget roll. A simpler skill may leave points unused.
- Slot development supports authored stronger/larger variants at the **original AP cost**. It does not automatically lower the AP cost of an unchanged skill. Higher-AP extensions are optional and explicitly shown.
- **Passive availability is not free AP efficiency.** Passive records have no AP spend; evaluation must price continuous availability, qualifying conditions, event frequency and repeat/recursion exposure explicitly. Use the same total/slot ceiling, not a separate passive budget or an invented zero-AP active tier. The initial passive-availability reference price is listed below; event-driven and other availability patterns still require separate evaluation.
- Point budget never overrides damage caps, access, targeting, legal effects or profile constraints. Slot upgrades still cannot increase direct damage, reduce AP cost or increase cast range.
- **Calibration status:** budget, AP scale and component drafts below are not validated balance. Unpriced components, combination reviews and tests remain in temp_todo T02; the six §4.7 references are not fully validated.

| Slot level | Budget ceiling — preferred working draft |
|------------|------------------------------------------|
| 1 | 24 points (shared base budget) |
| 2 | 30 points (base +6) |
| 3 | 36 points (base +12) |

These are maximum totals, not spending targets or a final balance approval. They do not set EP prices or level-unlock conditions, and do not confirm the proposed component prices.

#### Component Price Sheet

**Calibration drafts, not validated balance. All prices are construction points, not combat damage.** Cells are potential footprint cells, not guaranteed hits; large-body hit multiplicity remains unresolved.

| Component | Price | Scope |
|-----------|-------|-------|
| One-time damage | damage × cells × 2 | Area included; no second blanket area charge |
| Immediate timing | 100% of damage base price | No blanket surcharge |
| Telegraphed, avoidable Surge timing | 50% of damage base price | Discount on damage only, not other components |
| Ground + air damage coverage | +2 per damage effect | Once, not per cell; authorized sources only |
| Free board anchor within Reach, no LOS | +2 | Combined property, not two charges |
| Strike footprint-direction choice | +2 | Only when selection changes hit cells |
| Strike distant hit cells | +2 per distant cell | Outside adjacent eight-cell ring |
| Fixed non-Strike shape alone | No blanket surcharge | Additional advantages/combinations still count |
| Slow zone | 1.5 × cells × rounds | Existing base 1/cap 2 contract |
| Charging Surge blocking | +1 per complete marker | Not per cell; existing exceptions retained |
| Ordinary prop damage / derived destruction | No generic surcharge for now | Relevant offensive sources only; special advantages separate |
| Optional residue / other board operations | Ground/board price sheet below | Never implied by Surge timing/damage |

**Placement/geometry:** existing placement, occupancy and fixed-orientation rules still apply; constrained anchors and other targeting variants remain unpriced. Symmetric Strikes pay no direction surcharge if their cells do not change. For 1×1 Strikes, a distant cell satisfies `max(abs(dx), abs(dy)) > 1`, not Manhattan Reach. Non-Strike shapes of equal size/evaluated mechanics start at equal prices; special advantages such as chokepoints remain subject to review. No rotation, range upgrade or new placement permission is granted.

#### Strike Costs

**Actual damage remains 2 HP per struck monster.** Prices below are calibration drafts; similar prices do not prove equal strength. Spirit/Swarm/Ancient were completed as designer drafts under the instruction to finish Strikes without individual approvals.

| Kin | Existing additional effect | Construction-point component |
|-----|----------------------------|------------------------------|
| Beast | None | 0 |
| Winged | One retreat of 1 cell after the Strike | +3 once per use, not per target |
| Scaled | Push 1, including existing push-direction selection | +2 per potentially affected hit cell |
| Spirit | Target Initiative −1 next round | +2 per potentially affected hit cell |
| Swarm | Props take 4 rather than ordinary Strike damage 2 | +2 per potentially affected hit cell; provisional pending prop redesign |
| Ancient | Elevated under the target becomes Rubble | +2 per potentially affected hit cell; provisional pending height/board resolution |

Kin effects remain bound, not interchangeable. Push-direction selection is included in Scaled's price and is distinct from footprint direction; do not charge either twice. Winged retreats once, not once per target, without extra battle AP. Existing collision/fall/entry rules apply. Spirit stacking/refresh/expiry, Winged multi-target reference/ties/legal retreat and Scaled damage/push order remain unresolved. Swarm grants no extra monster damage; Ancient grants no extra collapse/debris damage or arbitrary ground removal. Board/prop and 2×2/layer cases remain T02/T04/T09. No extra blanket damage-plus-Kin surcharge is added; specific combinations still need review.

**Construction points only — NOT combat damage.** For 1×1 reference bodies, use `4 × hit cells + 2 × cells outside the adjacent eight-cell ring + effective footprint-direction cost + 2 ground/air coverage + AP-efficiency cost + Kin component`. Direction costs 2 only when the choice changes the hit cells. Ordinary prop interaction has no generic surcharge. Actual monster damage stays **2 HP per struck monster**; unresolved 2×2 hit multiplicity is not decided by this table.

| Shape | Existing battle AP | Hit cells | Distant cells | Footprint-direction points | Beast points | Winged points | Scaled points | Spirit points | Swarm points | Ancient points |
|-------|--------------------|-----------|---------------|----------------------------|--------------|---------------|---------------|---------------|--------------|----------------|
| Jab | 2 | 1 | 0 | 2 | 14 | 17 | 16 | 16 | 16 | 16 |
| Thrust | 3 | 2 | 1 | 2 | 17 | 20 | 21 | 21 | 21 | 21 |
| Diagonal Thrust | 3 | 2 | 1 | 2 | 17 | 20 | 21 | 21 | 21 | 21 |
| Pincer | 3 | 2 | 0 | 2 | 15 | 18 | 19 | 19 | 19 | 19 |
| Arc | 3 | 3 | 0 | 2 | 19 | 22 | 25 | 25 | 25 | 25 |
| Whirl | 3 | 4 | 0 | 0 | 21 | 24 | 29 | 29 | 29 | 29 |
| Cross | 3 | 4 | 0 | 0 | 21 | 24 | 29 | 29 | 29 | 29 |
| Storm | 4 | 8 | 0 | 0 | 35 | 38 | 51 | 51 | 51 | 51 |
| Cleave (cardinal reference) | 5 | 6 | 3 | 2 | 34 | 37 | 46 | 46 | 46 | 46 |
| Long Whirl | 5 | 8 | 4 | 0 | 42 | 45 | 58 | 58 | 58 | 58 |
| Long Cross | 5 | 8 | 4 | 0 | 42 | 45 | 58 | 58 | 58 | 58 |

**Geometry assumptions and limits:** Arc uses its existing adjacent row/wedge description; Cleave uses the illustrated cardinal two-row footprint (three adjacent, three distant cells). Exact authored offsets for all selectable orientations remain T02/T06; a diagonal Cleave variant is not inferred from this cardinal calculation. Symmetric forms do not pay for a redundant direction selector. The table is a paper calculation, not a legal-content catalogue, completed upgrade path or engine test.

**Budget findings:** regular ceilings remain 24/30/36. All Jabs fit the level-1 ceiling in this calculation; Arc with per-cell Kin effects and Whirl/Cross with those effects need at least the level-2 ceiling numerically. Beast Storm fits 36, but other Storm variants exceed it. Beast cardinal Cleave fits 36, but the other variants exceed it. All Long Whirl/Long Cross variants exceed 36. Do not automatically increase budgets, change battle AP, reduce damage, waive Kin costs or approve over-budget variants to preserve legacy content. Reconcile these larger legacy shapes under T02/T05/T06 after broader calibration; numeric fit alone never grants slot-level/progression access. Every skill still needs a complete authored development path at its original AP cost.

#### Movement Costs

**Working drafts:** price the complete movement preset, not each travelled cell or the individual monster's Movement stat. Movement is already purchased in the stat budget; the profile price evaluates traversal options together with its distance/direction restrictions. Run's 6-point component is selected; other prices below are designer calibration drafts completed under the instruction to price all movement modes. Existing 2-battle-AP costs add 6 AP-efficiency points.

| Preset | Profile points | AP-efficiency points | Total construction points | Pricing rationale / retained restriction |
|--------|----------------|----------------------|---------------------------|-----------------------------------------|
| Run | 6 | 6 | 12 | Baseline walk; blockers and ground costs apply |
| Leap | 8 | 6 | 14 | Bypasses path blockers/ground costs, but straight line only |
| Glide | 8 | 6 | 14 | Free path, ignores props/monsters/ground costs; charging Surges block; Movement −1 |
| Burrow | 8 | 6 | 14 | Free path bypasses blockers/ground costs; cannot start/end Elevated; Movement −1 |
| Phase | 7 | 6 | 13 | Walk through props; monsters/Surges block, ground costs apply; Movement −1 |
| Blink | 10 | 6 | 16 | Teleport to legal destination, bypass path blockers/ground costs; Movement −2 |
| Swim (planned, not approved content) | 7 | 6 (assumed 2 AP) | 13 (provisional) | Run-like walk with Water cost 1; access/Water rules remain T08 |
| Step (universal, no slot) | Not budgeted | Not applicable | Not applicable | Existing 2 AP, exactly 1 cell; no skill upgrades |

Prices evaluate the existing §4.3 presets as whole packages, not additive flag prices or an exchange rate for changing restrictions. Kin/stage access (§3.3), minimum distance 1, legal landing/occupancy and entry rules remain unchanged. Line/free/teleport count only landing; walk processes entered cells. Glide does not grant persistent flight. No ranged-anchor or ground/air attack surcharge applies to self movement. All existing slotted modes numerically fit ceiling 24, but this neither approves new access nor completes their upgrade paths. Swim remains planned despite its provisional price.

Custom profiles, flag-flip/distance-penalty upgrades and additional effects require separate resolved costing under §4.6; do not derive free upgrades from unused budget or add a second restriction charge to the base preset. Test low/high Movement (including the minimum-distance floor), barriers, hazards and exit options; air/2×2 remain T09. For the unmodified Run reference, evaluation is profile 6 + AP efficiency 6 + combination 0 = **12**, passive availability not applicable; ceiling 24 fits numerically, not a progression unlock or balance approval.

#### Self-Buff and Passive Costs

**Designer calibration drafts, not approved content:** these prices complete the Focus/Adaptive references under the instruction to proceed without individual price questions. They do not approve the legacy passive catalogue (§5), new stat effects or unresolved stacking/trigger rules.

| Component / reference | Mechanical points | AP-efficiency / availability points | Combination points | Total points |
|-----------------------|-------------------|-------------------------------------|--------------------|--------------|
| Focus: self Initiative +1, 2 rounds, proposed 1 AP | 4 × 1 magnitude × 2 rounds = 8 | 12 AP efficiency | 0 | 20 |
| Adaptive: owner may rotate its eligible fixed tetris shapes while equipped | 6 for rotation permission | 12 passive availability | 0 | 18 |

- **Focus:** 4 points per +1 Initiative per round for this self-bound modifier; no artificial area, ranged-anchor or ground/air-attack charge. Price assumes the existing draft's refresh-without-magnitude-stacking; normal AP-paid refresh adds no blanket surcharge. It is not a price for arbitrary stats, targeted/team buffs or cumulative Initiative. Round-end duration and normal round initiative recalculation still apply; cross-source stacking, removal/death and exact termination remain unresolved. Longer duration can be costed with the same draft rate but is not an approved upgrade offer.
- **Passive availability:** 12 is the initial premium for a continuously equipped, self-scoped boolean permission such as Adaptive, replacing—not adding to—active AP efficiency. Its mechanical effect is priced separately; it is not a 0-AP active skill or an extra passive budget. Conditions grant no automatic discount; event-driven, repeating/proccing, team-wide or other passive patterns need their own frequency/recursion and combination evaluation before pricing/approval.
- **Adaptive:** price covers the existing owner's eligible shape-rotation permission for all its legal uses while equipped, not a per-cast charge. Identical boolean permissions do not stack. It grants no mirror selection, Strike geometry changes, extra cells, range or new profile access. Test benefit with different equipped shapes, shape symmetry and action frequency; pricing does not guarantee equal value across kits.
- **Validation:** both reference totals fit ceiling 24 numerically, not an unlock or full development path. Test Focus against tempo/queue changes and paid refresh; test Adaptive against fixed-shape kits and placement options. Other passive mechanics and combined status interactions remain explicit follow-through, not free additions funded by unused points.

#### Zone, Protection and Healing Costs

**Designer test prices for existing contracts (§4.4), not new effect permissions.** Let C = potential cells, R = authored rounds and V = authored base magnitude. Costs below are mechanical components; add AP efficiency once per skill and applicable selection costs; combination surcharges are 0. Multiple effects share one zone clock, not multiple independently purchased timers.

| Existing effect | Mechanical construction points | Calibration scope |
|-----------------|--------------------------------|-------------------|
| slow / haste | 1.5 × V × C × R | Slow reference unchanged; opposite sign gets same initial rate |
| drain_init / quicken | 2 × V × C × R | While inside; no immediate queue rewrite |
| drain_range / extend | 2 × V × C × R | Effective Reach only, not a cast-range upgrade |
| Zone push / pull | 2 × C × R | Existing one-square end-turn trigger; direction/fixed pull anchor included |
| One-time displacement (Shove / authorized Surge push or pull) | 2 per potential recipient cell; Shove uses 1 recipient | Existing one-square trigger; direction/pull anchor included; no telegraph discount |
| Zone shield (Veil) | 1 × V × C × R | Existing base 2, cap 3; Surge reduction, not shield HP |
| Zone mend | 3 × V × C × R | Existing heal 1 reference; scaling/cap and repeat balance pending T07 |
| expose | Not priced / reserved | No approved zone; no damage-boost permission |

**Selection and repetition:** ranged zones add the existing +2 board-anchor property once; effect direction/anchor bindings above add no second selection charge. For direct Shove, use a provisional +2 for selecting its eligible visible unit instead of the no-LOS board-anchor fee, not both; exact eligibility/LOS remains unresolved. Normal AP-paid zone levelling/refresh is included in these baseline rates, extending the Slow pricing policy for calibration only. Exact allowed magnitude/cap/level formulas must still be resolved; these rates do not authorize stronger values, heal scaling, extra triggers or ally-only filtering. Revisit each effect's repetition independently in tests.

**Healing/protection limits:** maximum HP, existing events and source permissions remain binding. No direct heal, revival, Injury cure, general immunity, Tamer Spirit Shield or item permission is created. Stacking/consumption/order (T04) and mend/Mossbed loop limits (T07) remain blockers for affected content. A price is not a proposed cap or permission for unbounded healing.

#### Ground and Board Costs

Permanent state uses a fixed **per-created-cell package price**, not an invented duration or assumed number of future triggers. Each package includes its existing occupant effect, ordinary placement/replacement and state persistence; do not also charge instant damage, healing or zone-modifier costs for those same future effects. Entry/start/end events remain unchanged. Prices for level-I hazard creation include normal AP-paid recasts up to existing level II, not stronger damage or a level-II-start upgrade.

| Existing state / operation | Mechanical construction points | Included / unresolved scope |
|----------------------------|--------------------------------|-----------------------------|
| Lava I / Thornbed I / Blight I, immediate ground cast | 4 × C | Permanent hazard package; trigger risks to test |
| Lava I / Thornbed I / Blight I, delayed Surge aftermath | 1 × C | New designer test rate for telegraphed ground aftermath; permanent after resolution |
| Hearth / Umbra | 4 × C | Existing +1 Initiative / Reach while occupied, both sides |
| Mossbed | 6 × C | Existing heal 1 on entry; provisional until re-entry limits are resolved |
| Hallowed | 4 × C | Existing Surge reduction 1; no automatic hit consumption |
| Raise Ground | 5 × C | Elevated plus its existing non-Voidscar → Plain cleanse, one package |
| Existing collapse-to-Rubble operation | 2 × C | Source-specific height change; no extra fall/debris damage granted |
| Create Wall / Tree | 4 per created prop | Existing HP/tags/solid/reaction package; provisional pending prop redesign |
| Create Rock | 6 per created prop | Existing heavy-prop package; provisional, source/access still required |
| Create Shrine / Sigil | 8 / 6 per created prop | Existing prop/effect package; no duplicate permanent buff charge |
| Relocate eligible prop | 6 per moved prop | Provisional component only; distance/path/destination/reactions remain undefined |
| Additional ground-only Plain reset / zone-only cleanse | 3 × C / 4 × C | Pricing placeholders only; no new monster source is approved (§4.4) |
| Water, direct Rubble creation, Pillar creation, direct prop deletion | Not priced / not authorized by this table | Need explicit source/contract; Water remains planned T08 |
| Voidscar alteration | Forbidden | No budget bypass |

**Authoring boundaries:** prop prices are not a new catalogue or access grant; existing empty-square, heavy/indestructible and interaction restrictions remain. Ordinary prop destruction has no generic surcharge. Ignition/extinguish/crumble variants, falling/splitting reactions and mixed prop packages await the prop redesign, not guessed defaults. Natural debris/collapse triggered by ordinary damage is not charged again as an authored operation. Standalone ground/prop casts add the applicable +2 anchor and AP-efficiency once. **Residue means the Surge's authored ground change, not prop creation.** Eruption/Flood/Rift include Lava/Thornbed/Blight respectively, subject to existing profile exceptions. Delayed hazard aftermath uses the separate 1-point-per-cell test rate, without another cast-anchor/AP fee or a further 50% damage discount. Immediate ground casts retain their 4-point rate. Source-specific height/prop exclusions remain binding.

#### Combination Policy and Basic Surge Target

**Combination surcharges are removed altogether**, including the earlier damage-plus-hazard and displacement-plus-hazard test rates. Sum actual mechanical components and AP efficiency/passive availability only; retained schema fields for combination cost are always 0. This removes an extra tax, not the cost of additional effects or the need to validate legal combinations.

**Calibration target:** useful basic Surges with their intended ground aftermath must remain possible at **1 battle AP**. Ground change is part of Eruption/Flood/Rift, explicitly represented in `board_changes`; prop creation is a separate operation, not a default Surge feature. The generic residue-free reference still exists and does not replace these profiles.

The new delayed-ground rate of **1 point per cell** is a designer test price, not user-selected final balance. A structural 2-cell, damage-3 Surge with hazard aftermath now totals 23; the 3-cell case totals 27. Existing 1-AP profile costs stay unchanged; this does not yet make every legacy shape/profile fit level 1. Prop/height exceptions and Flood displacement still need complete evaluation. Resolve remaining conflicts through calibration, not by automatically moving basic Surges to 2 AP. Enhanced blocking/guaranteed hits still require review of avoidability; internal and team synergies remain test targets.

#### Calibration Examples

| Reference | Construction-point calculation | Provisional subtotal |
|-----------|--------------------------------|----------------------|
| Beast Jab: 1 cell, 2 damage, 2 AP | damage 4 + direction 2 + ground/air 2 + AP efficiency 6 | 14 |
| Slow zone: 3 cells, 2 rounds, 1 AP | slow 9 + anchor 2 + AP efficiency 12 | 23 |
| Same slow zone: 3 rounds | slow 13.5 + anchor 2 + AP efficiency 12 | 27.5 |
| Residue-free Surge: 3 cells, 3 damage, 1 AP | damage 18 × 50% + anchor 2 + marker 1 + AP efficiency 12 | 24 |
| Zone quicken 1: 3 cells, 2 rounds, existing 1 AP | effect 12 + anchor 2 + AP efficiency 12 | 26 |
| Veil: shield base 2, 3 cells, 2 rounds, existing 1 AP | protection 12 + anchor 2 + AP efficiency 12 | 26 |
| Mend 1 zone: 3 cells, 2 rounds, existing 1 AP | healing 18 + anchor 2 + AP efficiency 12 | 32 |
| Hazard Field: 3 cells, existing 1 AP | hazard package 12 + anchor 2 + AP efficiency 12 | 26 |
| Hallowed Blessing: 3 cells, existing 2 AP | ground package 12 + anchor 2 + AP efficiency 6 | 20 |
| Raise Ground: 3 cells, existing 1 AP | height/cleanse package 15 + anchor 2 + AP efficiency 12 | 29 |
| Structural Surge draft + Lava residue: 2 cells, 1 AP | damage 6 + marker 1 + residue 2 + anchor 2 + AP efficiency 12 | 23 |
| Same structural Surge: 3 cells, 1 AP | damage 9 + marker 1 + residue 3 + anchor 2 + AP efficiency 12 | 27 |

Paper calculations only, not complete validation, approved content/development paths or engine tests. Entries exceeding 24/30/36 are calibration conflicts, not automatic slot unlocks, AP changes or budget exceptions. The residue example is not a complete Eruption definition; ignition and profile-specific interactions still require review. Run, Focus and Adaptive have draft calculations in their tables above. No rounding rule is introduced for fractional points.

#### Included Behaviour and Validation Limits

- **Slow:** base 1/cap 2, Movement minimum 1, Step unaffected. Normal AP-paid recasts, levelling and duration refresh are included without extra surcharge. Starting at level II, free recasts and enhanced repetition are not. This does not price other stat effects; round duration does not guarantee personal turns. Test repeated use.
- **Surge marker:** price covers existing temporary voluntary-movement blocking, not enhanced blocking/duration. Existing movement/displacement exceptions apply. Test chokepoints, prop/height interactions and prevented escape against the 50% damage valuation; the price does not guarantee avoidability.

- **Combinations:** no surcharge within a skill or between skills/monsters. Validate full interactions and revise responsible components/rules where evidence warrants it. Guaranteed hits do not automatically qualify for the avoidable-damage discount.
- **Props:** ordinary interaction is baseline only for relevant offensive sources, not a grant of damage to movement/support or permission to destroy every prop. Special damage, resistance bypass and enhanced reactions require evaluation. Revisit after the Battle §4.9–§4.11 redesign (T04), without blocking unrelated calibration.
- **Permissions:** prices never override access, profile, damage, targeting or layer limits. Missing spatial/event/stacking contracts block affected content rather than receive defaults; central tracking: T02/T04–T06/T09/T13.

#### AP-Efficiency Working Scale

**Selected for calibration, not validated balance.** These construction-point costs are added to the other evaluated mechanics of an active skill; they are not separate AP-class budgets.

| Battle AP per use | AP-efficiency cost in construction points |
|-------------------|------------------------------------------|
| 1 | 12 |
| 2 | 6 |
| 3 | 3 |
| 4 | 1 |
| 5 | 0 |

A higher battle-AP cost does not grant negative-cost credits. This table does not authorize zero-AP actions, change existing skills' AP costs, price passive availability or permit AP-reducing slot upgrades. Values must be checked against complete skills, legal repetition and the monster's available AP per turn. Selecting this scale does not approve the draft damage/area/timing prices.

**Existing AP prices are calibration references, not a parallel final pricing formula.** Keep current rules until replacement prices are explicitly agreed; do not silently reprice existing content. Strike shape prices remain in §3.2 as existing data to check against the new calculation.

| Authored action/profile | Existing battle AP cost / limit |
|-------------------------|---------------------------------|
| Step (no slot) | 2 AP |
| Slotted movement | 2 AP |
| Zone / ordinary ground / prop / direct | 1 AP |
| Minor Surge | 1 AP baseline; one charging Surge per monster |
| Strike | 2–5 AP by the selected authored shape (§3.2) |
| Blessing ground | 2 AP; not the ordinary-ground default |
| Major Surge | 2 AP; once per battle; access under §4.1 / §7.4 |

These are the existing baseline prices, not new calibration values or final prices for every authored combination. A species-specific skill retains its existing applicable profile cost pending calibration; the old generic “Unique = 1 AP, may set its own” is not a mechanical category or an unrestricted cost override. Any retained exceptional price needs explicit validation under T02. Optional higher-cost upgrade variants follow §4.6; blanket Twist/Size surcharges are not confirmed. Tamer skills, planned medicines and arrays have their own source/loadout contracts in gdd_overworld §6.4–§6.6 and gdd_battle §5.2; these monster-action prices do not assign their costs.

Preserved authoring constraints: normal shaped skills have one fixed family/orientation; unit-targeted effects and Step need no tetris footprint, and Strike uses its body shapes. A zone's existing duration default is 2 rounds, but every resolved definition must state/reference its lifetime; the §4.7 example remains an unvalidated combination. Temporary species-specific effects must state N rounds or an explicit consumption/end-of-battle condition; the former flat `rounds` field is not a separate schema. Movement presets/flags and their restriction-versus-distance/direction price rule remain binding runtime profiles (gdd_monsters §4.3); §4.6 owns their upgrade allowance. A Surge needs at least three live counters to pass design validation (leaving, protection, height, air, props or tempo as applicable); a nominal counter that its actual profile prevents does not count.


- **AP is the only battle-use resource for active monster skills.** Passives have no active AP spend; their availability is priced in construction points. No cooldowns, no mana.
- **Cast range** uses effective Reach where the battle profile requires it; Strike uses its body footprint and movement uses Movement. No independent skill-range stat or new twist exception (§4.3).
- **Size:** 1–4 cells for ordinary skills with a tetris shape, 2 for Swarm Surges (§3.1). Strikes have their own list (§3.2); Major Surge requires its explicitly authored large-area profile and access, not a generic cap override.

### 4.6 Slot Levels, Development, Replacement and Upgrades

**Confirmed model: permanent slot development.** Skill-slot upgrades are an additional evolution option alongside physical monster evolution. Both spend the individual monster's shared **evolution points (EP)**; no separate player-facing skill-point currency is introduced. Construction/blueprint points are internal authoring data, not an intermediate spendable player budget and not the overworld Blueprint items.

- EP develop a specific slot of a specific monster, not the equipped skill or the species globally. Each purchased development step directly grants a skill-specific upgrade choice.
- Designers author finished skills and their upgrade choices using the component model (§4.2–§4.7) as an internal budgeting and AP-pricing tool. Players choose from those authored options rather than assembling arbitrary components.
- The equipped skill determines legal upgrades, prerequisites and mutually exclusive paths. The slot's development determines how much development is available; it does not grant every upgrade simultaneously.
- Replacing a skill preserves all purchased slot development. The player selects legal upgrades for the replacement skill using that existing development; old effects do not carry over literally.
- Replacement is outside expeditions, requires a skill from the unlocked species learnable list and consumes a valuable **relearning pill**. Selecting the replacement's upgrades is part of that replacement, not a second EP purchase. Exact pill acquisition, recipe, tier, price and overworld AP cost remain open (T05/T16/T31).
- Skillslots have **levels 1–3**, each with a higher construction-budget ceiling (§4.5). No separate skill-rating or rank system is introduced. EP prices, level-unlock conditions, possible intermediate development steps and total EP supply remain undecided; the old supply must be reviewed alongside physical evolution costs.
- Whether reselecting upgrades without replacing the skill also consumes a pill is **not yet decided**. Passive-only slots and active/passive replacement need explicit rules before implementation.

**Confirmed construction budget and AP policy**

The former per-skill prices (1 EP for Shape/Twist/Value/Swap, 2 EP for Size) are superseded, not slot-level development prices. Legacy “Shape always free”, blanket “Twist = 2 AP”, “Size adds 1 AP”, Twist-plus-Size totals and double-charging an already enlarged footprint remain T02/T05 reconciliation work; none overrides the confirmed policy below.

- Allowed construction budget = shared base budget + slot-level allowance (§4.5). AP efficiency consumes this budget; AP classes do not grant different base budgets. Only an upper ceiling applies; the selected working ceilings are defined in [§4.5](#45-construction-points-and-ap-efficiency). Their balance validation remains open (temp_todo T02/T05).
- Slot development permits bounded increases in effectiveness at the same AP cost. Every skill must offer a complete development path at its original AP cost.
- Larger extensions may optionally increase AP cost; the increase is explicitly shown before selection. Higher AP cost is never a mandatory consequence of developing the slot.
- Upgrades are explicitly authorized field patches on the same skill definition (§4.7), never a parallel model. Authored upgrades may improve area, shape/orientation, duration, movement/displacement or add an explicitly designed secondary effect, subject to skill-specific limits and prerequisites.
- Slot upgrades do **not** increase direct damage, reduce AP costs or increase cast range. Existing Strike, Surge and ground damage limits remain in force. More affected cells or longer duration may increase total impact, so these still require budgeting and validation.
- Budget is a design guideline, not permission to bypass hard caps or legal-combination constraints. Legacy blanket AP surcharges require reconciliation with this policy, not automatic application to every upgrade.

Cast range is not an improvement path. The following families and validation constraints are the **existing candidate upgrade catalogue**, not finalized slot-step prices or level-unlock conditions. Old per-skill evolution counts are superseded by the slot model; concrete offers and AP effects are reviewed under temp_todo T02/T05.

|           Family           |                                       What changes                                      |                                                                                         Rules                                                                                         |
|----------------------------|-----------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Shape** | Other shape family or orientation, **same cell count** | I2 orientation, I3↔L3 or legal 4-cell families; Strike swaps same-size shapes (e.g. Whirl ↔ Cross). Family must respect Kin and twist constraints; shapes remain fixed in battle. Legacy ‘always free’ grants no free EP development or respec; costs remain T05. |
| **Size** | **+1 cell** within the owning profile's cap; Strike selects a larger §3.2 shape | Ordinary tetris max 4; Swarm Surge cannot enlarge. A larger Strike uses its existing shape AP price as an optional higher-cost branch, never the only development path. The old automatic Surge +1 AP is unconfirmed; requirements, EP prices and optional AP effects remain T02/T05. |
| **Twist** *(Surge only)* | Replace/add an authored extra rule; not on a Species Surge | At most one; preserve §4.3 constraints and exclude damage/range increases, including legacy delayed-damage or extended-range candidates. Validate under the confirmed AP policy. |
| **Small value** | Zones: `duration` +1 round total per skill. Movement: one flag flip total, turning off one restriction or lowering its distance penalty by 1 (§4.3) | Bounded candidate patches, not free upgrades. No damage increase or level-II start; Overgrowth remains a separate passive candidate (§5), not an approval through this table. |


Concrete upgrade offers are authorized patches to the shared definition ([§4.2](#42-data-oriented-skill-construction-kit)), checked through [§4.7](#47-complete-references-and-validation), not a second per-kind schema. Species-specific and Signature skills use the same process (§4.1); replacement is never an upgrade patch. Legacy named upgrade examples and their evolution counts are retired pending T02/T05/T10.

- Same species + different evolution picks = different playstyles → collection depth without new art
- An evolved shaped skill retains **one authored shape and fixed orientation**, with only existing rotation exceptions; a Surge has **at most one twist**, not a mandatory twist. Non-area skills do not acquire a footprint by evolving. All battle rules stay valid; the preview shows the resolved variant like any other
- Slot development is a deliberate shared-EP purchase, not focused-XP Train or an automatic breakthrough reward. Location and day-AP logistics belong to [Overworld §6.3.2](gdd_overworld.md#632-permanent-skill-slot-development-confirmed). EP awards remain unvalidated in §7.2/§7.4. EP reversal, transfer and same-skill upgrade reselection remain [temp_todo.md](temp_todo.md) T05; no free reset is implied.

**Validation interface:** apply the candidate-family limits above, the owning [Surge constraints](#surge-constraints-and-species-access), Kin access (§3), and the complete-record checks in [§4.7](#47-complete-references-and-validation). The evolution screen only offers paths that pass. Unsupported 2×2/spatial cases remain T09; evolution grants no exception or air access. Skill replacement follows the confirmed slot rules at the start of this section, not an upgrade patch.

### 4.7 Complete References and Validation

Author a finished skill by selecting its legal rule profile, resolving the dimensions in §4.2 through referenced definitions, then checking access, interactions and budget. Use the single schema in §4.7; reusable footprints and effect definitions are data references, not fundamental skill blueprints.

Validate the complete resolved definition, not isolated components: selection → placement → footprint → recipients; execution → effect events/order → lifetime; then Kin/species access, usage limits and cost. A preview must expose cells, recipients, displacement landings and board reactions. Missing rules block the affected content rather than receive defaults.

The former named example table is retired. Roster names (§6.1) remain unvalidated content ideas, not effect definitions or permissions. Rebuild concrete skills only after the central decisions in [temp_todo.md](temp_todo.md), especially T02/T04/T05/T07/T09/T10.

#### Shared Schema and Calibration References

**Technical documentation template, not an implementation change.** This is the single data model for §4.2, including species-specific skills and upgraded variants. Field names illustrate responsibilities rather than prescribe engine serialization. Referenced effect definitions supply their existing mechanics and caps; they are not a parallel zone schema.

**Construction walkthrough — simple slowing zone (draft, not approved content).** This minimal example replaces the unresolved Ash Snare schema example: no ignition or other secondary effect. Proposed baseline: 1 AP, a fixed horizontal I3 footprint, 2 rounds and `slow` base 1/cap 2. Area and AP are calibration proposals, not approved balance values. The centred three-cell footprint makes the anchor explicit without a two-cell midpoint ambiguity.

The skill selects a board tile within effective Reach (Manhattan distance to anchor), without LOS. The anchor and its two horizontal neighbours must all be on-board; no clipping or rotation. Existing zone placement permits props and existing zones, subject to zone replacement/opposition rules. It affects ground-layer monsters of either side, including its caster, while they occupy the cells; it does not affect air, props, height or ground state.

On placement the slow modifier applies immediately to occupants, without damage or an entry payload. Leaving/removing the zone ends it. At zone level I, Movement is reduced by 1, minimum 1; Step is unchanged. Existing same-zone levelling may increase the value to its cap of 2 (`min(2, 1 + level - 1)`); this is battle-zone level, not slot level. The shared zone clock decrements at each round end and removes the zone at 0. Thus 2 rounds does not guarantee two full personal turns for every monster.



```yaml
metadata:
  id: slowing_zone_example
  name: Slowing Zone (draft)
  kind: zone
  rule_profile: zone

  tags: [control]
access:
  eligibility: authored_species_list_and_kin_rules
usage_type: active
execution:
  activation: player_action
  condition: legal_cast
  timing: immediate
  resolution: cast_resolution
targeting:
  type: tile                         # selection, not effect recipients
  eligibility: existing_zone_target_rule
  distance_source: caster_reach      # Manhattan to the anchor
  line_of_sight: existing_zone_rule  # no LOS under gdd_monsters §4.2
placement:
  anchor: selected_tile
  binding: fixed_board_cells_at_cast
  direction_selection: none
  constraints: existing_zone_placement # includes layer-specific occupancy
area:
  shape: I3
  offsets: [[-1, 0], [0, 0], [1, 0]] # [dx, dy], relative to selected tile
  cell_count: 3
  orientation: horizontal
  orientation_policy: fixed_board
  boundary_rule: all_cells_on_board
  blocking_rule: existing_zone_placement
effects:
  - type: stat_change
    definition: slow                # binds Movement subtraction, min 1, Step unaffected
    value_source: zone_level_formula # min(cap, base + level - 1)
    base: 1
    cap: 2
    recipients:
      scope: area_occupants
      relationships: [self, ally, enemy]
      layers: [ground]
      props: false
    recipient_evaluation: while_inside
    application: while_inside
    lifetime_ref: created_zone
    stacking: existing_zone_replacement_and_level_rules
    termination: leave_or_zone_removed
    ordering: continuous_modifier

persistence:
  type: rounds
  owner: created_zone                # one clock shared by its effects
  duration: 2
  tick: round_end
  expiry: existing_zone_expiry
board_changes: []
interactions:
  blocked_by_objects: false
  blocked_by_height: false
usage:
  ap_cost: 1
  limits: existing_zone_limits
upgrades: []                        # baseline only; unapproved candidate patches are listed below
evaluation:                         # draft values resolve through §4.5, not runtime defaults
  component_cost: reference_section_4_5_slow_components
  ap_efficiency_cost: reference_section_4_5_ap_efficiency
  passive_availability_cost: none
  combination_cost: 0
  total_points: reference_section_4_5_slow_zone_calculation
  required_slot_level: reference_section_4_5_budget_fit # numerical ceiling only, no unlock
```

**Walkthrough checks:** anchor (3,3) produces cells (2,3), (3,3), (4,3); anchor (0,3) is invalid because (-1,3) is off-board. A ground-layer occupant with Movement 3 has effective Movement 2 in the level-I zone, returns to 3 on exit and still uses Step normally. An ally is affected identically. A prop is not slowed; an air-layer monster is not a recipient. Creating the zone does not change the underlying ground. These are paper checks, not executed engine tests. General 2×2 cases and unrelated rule gaps remain open.

The area is a single authored footprint, not a choice of shapes at cast. Placement resolves through [§4.2](#42-data-oriented-skill-construction-kit); zone lifetime resolves through [Battle §4.5](gdd_battle.md#45-lifecycles), and value/replacement through [Battle §4.6](gdd_battle.md#46-zones-effects-rules--opposites). Evaluation references resolve to the existing provisional [Slow zone calculation](#calibration-examples) and [AP-efficiency scale](#ap-efficiency-working-scale), not an unlock or content approval. The YAML and compact table show the same baseline; candidate upgrades remain separate, unapproved patches. These references are documentation contracts, not invented engine identifiers. Ground changes are explicit `board_changes` entries; affected layers are specified per effect, with no duplicate ground/air authoring flags. The old flat blueprint layout is superseded; behaviour, targeting, direction, duration and usage belong to the dimensions above. Surge twists and species-twist ownership are authored profile constraints/metadata on this same model.

**First reference group — draft calibration records, not balance approval.** Slowing Zone, Beast Jab and Delayed Burst form the initial three cases; Run, Focus and Adaptive below extend coverage to six. These are structural references, not a new approved skill catalogue. The compact records below use exactly the same top-level schema; field groups are explicit or reference the existing contracts in §4.2/§3.2, with unresolved access, upgrade and runtime cases marked as draft. Jab is restricted here to the fully costed Beast case; other Kins' unresolved contracts are not supplied by this reference (T02/T04/T06). They introduce no runtime identifiers. Coordinates are `[dx, dy]`; examples use 1×1 bodies only. References do not resolve the open large-body rules.

| Schema field | Slowing Zone reference (draft) | Beast Jab reference (draft record of existing Strike) | Delayed Burst reference (draft Minor Surge) |
|---|---|---|---|
| `metadata` | `id: slowing_zone_example`; `name: Slowing Zone (draft)`; `kind: zone`; `rule_profile: zone`; `tags: [control]`; ordinary species access | `id: jab_reference`; `name: Jab`; `kind: strike`; `rule_profile: strike`; `tags: [reference]`; Beast Kin binding (§3.2), no additional Kin effect | `id: delayed_burst_reference`; `name: Delayed Burst (draft)`; `kind: surge`; `rule_profile: minor_surge_residue_free`; `tags: [reference]`; no species twist; ordinary Kin/access limits |
| `access` | Authored species list; existing Kin/progression constraints | Authored species list; Beast Kin and existing Strike access (§3.2); concrete species list pending | Authored species list and ordinary Kin constraints; Swarm cannot use this 3-cell footprint |
| `usage_type` | `active` | `active` | `active` |
| `execution` | `activation: player_action`; legal-cast condition; `timing: immediate`; `resolution: cast_resolution` | `activation: player_action`; legal-Strike condition; `timing: immediate`; `resolution: cast_resolution` | `activation: player_action`; legal-Surge condition; `timing: telegraphed_delayed`; `resolution: caster_next_turn_start_before_start_effects`; marker/charging under §4.2; autonomous after displacement or death, using the dead caster's due queue slot |
| `targeting` | `type: tile`; existing zone target eligibility; `distance_source: caster_reach`; no LOS | `type: self`; `eligibility: caster`; `distance_source: body_footprint_not_reach`; `line_of_sight: not_required` | `type: tile`; any legal board anchor; `distance_source: caster_reach` (Manhattan to anchor); `line_of_sight: not_required` |
| `placement` | Selected tile anchor; fixed board cells at cast; no direction selection; existing zone placement including props/replacement rules | `anchor: caster_body`; `binding: immediate_body_relative`; `direction_selection: one_of_eight`; existing §3.2 body placement, caster excluded | `anchor: selected_tile`; `binding: fixed_board_cells_at_cast`; `direction_selection: none`; props permitted, no overlap with a charging Surge; existing Surge placement |
| `area` | Fixed horizontal I3; offsets `[[-1,0],[0,0],[1,0]]`; 3 cells; all cells on-board; no clipping/rotation | `shape: Jab`; `offsets: [d]`, where selected `d` is exactly one of `(−1,−1), (0,−1), (1,−1), (−1,0), (1,0), (−1,1), (0,1), (1,1)`; `cell_count: 1`; orientation = selected direction; `orientation_policy: strike_direction_selection`; `boundary_rule: all_cells_on_board`; solid-prop blocking under §3.2 | `shape: I3`; `offsets: [[-1,0],[0,0],[1,0]]`; `cell_count: 3`; `orientation: horizontal`; `orientation_policy: fixed_board`; `boundary_rule: all_cells_on_board`; no clipping/rotation; props do not block placement; damage hits Elevated as Eruption, without collapse |
| `effects` | `stat_change: slow`; base 1/cap 2 under zone-level formula; all ground-layer occupants including allies/caster; existing zone stacking/level rules, shared created-zone lifetime; continuously while inside; ends on exit/removal; Movement minimum 1, Step unaffected | `damage`: Beast Strike under §3.2, fixed 2 against monsters/props; recipients = all struck monsters including allies, excluding caster, and struck props; evaluate/apply once at cast resolution, action lifetime none/no retained damage stack. Beast has no additional Kin effect | `damage`: fixed 3 against all ground-layer monsters in the footprint at resolution, including caster/allies/enemies; no air. Existing ordinary Surge prop handling: 2 to prop instead of occupant; shield/Hallowed reduction, minimum 0. Apply once at detonation; no push, pull, ignition or brittle-prop extra reaction; no repeat payload; one-shot damage has no retained stack; pending marker lifetime ends at resolution |
| `persistence` | Created zone; 2 rounds; shared clock ticks at round end; removed at 0 | `none`; immediate action with no retained Kin state | `type: until_resolution`; `owner: pending_surge`; expires at detonation; no post-resolution effect lifetime |
| `board_changes` | `[]`: no ground, height or prop operation | `[]`: no authored ground/height/prop operation; ordinary damage-derived prop reactions use Battle §4.10–§4.11 | `[]`: no authored ground placement, residue or height change; ordinary damage-derived prop destruction/shatter/debris remains §4.2, not an added residue component |
| `interactions` | Placement not blocked by props/height; recipient layers are specified in `effects`; no ground-changing operation | Monster damage recipients include ground and air; `blocked_by_objects: true` (solid-prop line rule); `blocked_by_height: false`; no additional Beast operation | Damage recipients are ground-layer only; `blocked_by_objects: false` for placement (prop intercepts damage); `blocked_by_height: false`; no ground reset, including Hallowed consumption without residue |
| `usage` | `ap_cost: 1` proposed; existing zone limits | `ap_cost: 2`; existing AP repetition, no charging limit | `ap_cost: 1` proposed; one charging Surge per caster, existing AP spending/repetition rules; no cooldown/mana |
| `upgrades` | `[]` in baseline; separate candidate patches below, no approved requirements | `[]` in baseline; separate candidate patches below, none approved | `[]` in baseline; separate candidate patches below, none approved |
| `evaluation` | Provisional Slow zone calculation in [§4.5](#calibration-examples); passive availability `none`, combination 0; unlock conditions pending | Provisional Beast Jab calculation in [§4.5](#calibration-examples); passive availability `none`, combination 0; unlock conditions pending | Provisional residue-free Surge calculation in [§4.5](#calibration-examples); passive availability `none`, combination 0; unlock conditions pending |

**Paper checks:** Beast Jab with `d = (1,0)` from (3,3) hits only (4,3), for 2 monster damage with no additional Kin effect, even if occupied by an ally; it is not a Reach cast. Burst at (3,3) marks (2,3), (3,3), (4,3), then evaluates occupants only at the caster's next turn start. Leaving avoids the hit; caster death does not cancel it. Air is unaffected; surviving ground beneath the cells is unchanged, so Hallowed is not consumed by an invented residue step. Leaving, protection and air are at least three live counters. These are documentation checks, not executed tests.

**Upgrade candidate choices — all DRAFT, not balance approval or unlocks.** Patches use the same schema and must pass §4.6. Each offer is an alternative, not automatically cumulative; no level requirements/EP prices, damage increases, AP reductions or cast-range upgrades are assigned.

| Reference | Same-AP candidate choice | Optional higher-AP candidate choice |
|---|---|---|
| Slowing Zone | At 1 AP: choose fixed vertical I3 (`offsets: [[0,-1],[0,0],[0,1]]`, orientation vertical), or `persistence.duration: 3` (the +1 total cap); other fields unchanged | At proposed 2 AP: choose fixed T4 (`offsets: [[-1,0],[0,0],[1,0],[0,1]]`, centre junction anchor, count 4), keeping duration 2 and the same slow formula |
| Beast Jab | A meaningful 2-AP Beast development offer remains unresolved under [temp_todo.md](temp_todo.md) T02/T05. No lawful larger shape exists at this price in §3.2; selecting a direction is baseline use, not an upgrade. This reference does not claim a completed same-AP path | Existing Thrust at 3 AP: `shape: Thrust`, offsets `[d, 2d]` for selected cardinal `d`, count 2, solid-prop blocking unchanged; damage 2 and Beast's lack of an additional Kin effect unchanged. Optional branch, never required |
| Delayed Burst | At proposed 1 AP: choose fixed L3 (`offsets: [[0,-1],[0,0],[1,0]]`, junction anchor, count 3); other fields unchanged | At proposed 2 AP: choose fixed T4 with the offsets/anchor above, count 4; damage 3, delay, recipients and `board_changes: []` unchanged. This is not Major Surge access; Swarm cannot use either 3/4-cell reference |

**Status:** calibration and same-AP development remain incomplete ([temp_todo.md](temp_todo.md) T02/T05); event-order/large-body cases remain T04/T09. Residue is a board-operation component, not a combination surcharge (§4.5). The residue-free reference does not replace Eruption/Flood/Rift (§4.3).

Resolve every referenced definition and its required parameters before validation (§4.2–§4.7). Fixed fields cannot be contradicted by skill overrides; effect/operation order comes from the rules, never YAML list position. Unsupported cases remain central TODO, not default mechanics.

An upgrade is an **authorized patch to named fields of this definition**, with prerequisites, exclusions and budget/AP consequences (§4.6), not a second skill schema. Validate the resolved definition after applying patches: rule profile, Kin/species access, execution, placement, footprint, effect/trigger legality, persistence, interactions, usage limits and budget must still agree. Unspecified behaviour is not permission to invent a default mechanic. No cooldowns, mana, aspect or attunement; no damage upgrades, AP reductions or cast-range upgrades.

#### Non-Area and Passive Coverage References

These three records use exactly the same field groups as the preceding three. **Run** records an existing preset for a legal user; **Focus** is a new, unapproved self-buff proposal; **Adaptive** is a structural transcription of the existing passive candidate, not a finalized learn-list/upgrade/balance approval. Names below are documentation references, not runtime identifiers.

| Schema field | Run reference | Focus self-buff reference (DRAFT) | Adaptive passive reference (DRAFT content) |
|---|---|---|---|
| `metadata` | `id: run_reference`; name Run; `kind: move`; `rule_profile: run`; tags movement | `id: focus_reference`; name Focus; `kind: utility`; `rule_profile: none`; tags buff | `id: adaptive_reference`; name Adaptive; `kind: passive`; `rule_profile: none`; tags shape |
| `access` | Species learns Run and Kin/preset access permits it (§3.3); no grant to Step-only users | One authored species learn-list; exact species/progression pending; exclusivity grants no extra budget | Authored species learn-list and legal active/passive slot; concrete list pending |
| `usage_type` | `active` | `active` | `passive` |
| `execution` | Player action; legal-movement condition; immediate movement resolution | Player action; caster alive/able to act; immediate application | `activation: while_equipped`; active while owner participates in battle and the skill occupies a legal slot; continuous rule evaluation, not a repeatedly cast action |
| `targeting` | Self mover plus player-selected legal path/destination; distance source Movement, not Reach; Run preset sight/path rules | `type: self`; no distance or LOS check | `type: none`; owner bound by equipment, no player-selected recipient |
| `placement` | Caster origin, selected walk path/destination, existing Run path/landing rules; no persistent board placement | `none`; buff attaches to caster, not its tile | `none`; permission belongs to owner, not a board tile |
| `area` | `none`; a movement path is traversal, not a damage/zone footprint | `none` | `none`; modifying another skill's orientation does not create an area |
| `effects` | Typed self `movement`, Run preset, distance effective Movement (minimum 1); once at action resolution; owner's legal layer; no retained state/stack; process walk entry effects under existing rules | Typed `stat_change`: effective Initiative +1 to self in its legal layer; apply at resolution; bind to `focus_state`; proposed same-skill/same-owner group refreshes duration, never adds magnitude; cross-source stacking/removal/death policies pending | Typed `rule_modifier`: permit owner to rotate otherwise fixed tetris shapes when previewing/casting its own eligible skills; self scope in owner's legal layer; activation while equipped; boolean/idempotent permission, not extra magnitude; does not change Strike direction rules or authorize other profile changes |
| `persistence` | `none`; action completes after traversal/landing | `focus_state`: proposed 2 rounds, tick round end, remove modifier at 0; exact queue application follows normal round initiative recalculation; other termination policies pending | `adaptive_permission`: while owner participates in battle with this passive equipped; ends when that condition fails/battle ends; no round counter |
| `board_changes` | `[]`; entry-triggered board reactions remain ordinary runtime rules | `[]` | `[]` |
| `interactions` | Walk; blocked by solid props, monsters and charging Surges; height allowed; ground costs apply; distance modifier 0; legal destination required; air/2×2 remain T09 | No placement/path blocking; no air attack or ground interaction is introduced by a self-bound modifier | Affects only owner's authorized shape orientation choice; no targeting, footprint, layer or terrain exceptions |
| `usage` | Existing 2 AP; ordinary action repetition; no cooldown/mana | Proposed 1 AP; ordinary active-action repetition; recasting refresh is only a draft policy, not a finalized balance rule | `ap_cost: none`; no active cast or player-action repetition; no separate activation button |
| `upgrades` | None approved; existing movement-upgrade limits still apply; full three-level path pending T05 | None approved; may explore bounded duration/secondary effects, not direct damage/AP/range upgrades; full path pending | None approved; passive development/active-passive replacement remain T05; no automatic extra permission from slot level |
| `evaluation` | §4.5 draft: profile 6 + AP efficiency 6 + combination 0 = 12; fits level-1 ceiling 24 numerically, not an unlock/approval; passive availability not applicable | §4.5 draft: modifier 8 + AP efficiency 12 + combination 0 = 20; fits ceiling 24 numerically; passive availability not applicable; content/stacking validation pending | §4.5 draft: rotation 6 + passive availability 12 + combination 0 = 18; fits ceiling 24 numerically; AP efficiency not applicable; content/interaction validation pending |

**Six-case paper checks:**

- **Strike:** Beast Jab is a body-relative immediate attack with ground/air recipients and no additional Kin effect; no forced Reach targeting or zone lifetime.
- **Surge:** player declaration and delayed resolution are separate; marker lifetime does not imply residue or lasting damage.
- **Zone:** one cast creates a shared lifetime; continuous slow is not another action or repeated damage.
- **Movement:** changing the owner's position needs a path/destination, not an artificial area; entering a cell still uses ordinary board rules.
- **Self buff:** after application, moving off the original tile does not remove a self-attached state; no tile placement, ground payload or `unique` effect is needed. Round-end duration does not guarantee two personal turns. Cross-source stacking/termination gaps prevent content approval.
- **Passive:** granting rotation while equipped uses a scoped rule modifier, no AP-zero cast or passive-only schema. Two identical boolean permissions do not permit additional rotations/rule changes; other passive interactions still need authored rules.

These are structural walkthroughs, not executed engine tests or approval of the proposed skills. Event-driven passives are representable by declared activation events, conditions, event-bound recipients and typed effects; concrete repeat/recursion/order rules must be resolved before such content is approved (T02/T04/T11).

**Evaluation status:** §4.5 owns the provisional reference calculations: Beast Jab 14, Slow 23, residue-free Surge 24, Run 12, Focus 20 and Adaptive 18 points. All six now have initial calculations; unresolved interactions/content contracts still prevent full validation. None demonstrates a complete three-level upgrade path. Use the same evaluation fields in every record; `none` means not applicable, not a free unpriced advantage.


---

## 5. Passives

Passives take a kit slot like an active skill (§4.1) and use the **same §4.2 model**. They are available while equipped, but their effects may be continuous, conditional or event-driven as explicitly defined; “always available” does not mean every effect applies continuously. They do not spend active-action AP, and their availability/trigger frequency still requires point evaluation (§4.5). Availability depends on the species' own learnable list and the individual (Epic+ extra slot, artifacts), within Kin and progression restrictions; never on a theme or aspect. A kit of 1 active + 3 passives is legal but weak.

**Content status:** the named entries below are retained prior-draft candidates, not an approved perk catalogue or exceptions to Chapter 4. Their effects, access and interaction contracts need T02/T04/T11 validation; in particular Momentum's damage bonus, AP-discount passives, Crashlander's collision wording and automatic movement/target selection remain unresolved. Do not use these ideas to authorize damage upgrades, AP-reducing slot upgrades, new collision rules or unspecified tie-breaks.

**Terrain Identity:** Adaptive (may rotate its skill shapes in battle) · Purifier (adjacent enemy zones lose 1 round at round end) · Overgrowth (your zones start at level II). Native Ground, Painter, Trailblazer and Deep Roots remain non-mechanical placeholders after aspect removal ([temp_todo.md](temp_todo.md) T11); no replacement effects or values are established.

**Position & Movement:** Highlander (+2 init on Elevated) · Turret (can't move, +1 Reach) · Skittish (free 1-square move after taking Surge damage — to the safest free neighbour) · Phasing (moves through props) · Momentum (after a max-distance move, the next Surge this turn deals +1)

**Displacement:** Crashlander (when pushed or pulled into a prop or monster, it takes no collision damage — the other side takes 1) · Immovable (ignores push/pull) · Counterweight (allies orthogonally adjacent to it can't be pushed or pulled)

**Combat:** Thick Hide (Strikes and collisions deal 1 less, min 0) · Pack Hunter (Strike costs 1 AP less if an ally is adjacent to the target) · First Blood (its first Strike each battle costs 1 AP less) · Vengeful (after taking Surge damage, its next Strike costs 1 AP less) · Scavenger (heals 1 when a prop within its Reach shatters) · Frenzy (+1 shape cell at 1–2 HP) · Bulwark (team: allies orthogonally adjacent to it take 1 less Surge damage)

**Ground & Zone Resistance:** Sure-footed (ignores `slow`) · Clear Mind (ignores `drain_*`) · Heatproof (ignores Lava) · Thornwalker (ignores Thornbed) · Void-touched (ignores Blight) — the unit-level way of shrugging a specific effect.

---

## 6. Roster

### 6.1 First Roster Draft — 9 monsters

**Non-authoritative content ideas:** this roster is not a skill/access/cost specification. Its names, old twists, passives, descriptions and overfilled loadouts grant no exception to Chapter 4; retain them for later validation, not implementation or redesign here.

The stat shape is a property of the **individual monster** (§1.1); the shapes below are the **reference individuals** — the typical roll of each species. Numbers are **Core Formation High** values: each one spends exactly the 16-point budget inside its frame (caps: HP 8, Init 9, TPR 2, Move 5, Reach 3, AP 3 — §2.2–2.3). The default kit is **movement skill (§3.3) + Kin Strike (§3.2) + Surge + Utility** = 4 slots, plus the passive in the table. *Under the current [kit rule](#41-the-kit), a passive takes a slot of its own; this table preserves earlier reference loadouts, not finalized legal kits.* The Forge Golem moves by Step only and takes a second utility instead. Named skills and twists below are unvalidated prior-draft content ideas, not a blueprint catalogue or approved damage/range exceptions. Rebuild them with §4.2–§4.7; species access follows §4.3/§4.1.

|      Monster       |   Kin   | Descriptive themes | Shape · HP / Init / Move / TPR / Reach / AP | Movement |         Surge (type · shape · twist)         |  Utility   |    Passive    |
|--------------------|---------|--------|----------------------------------------|----------|----------------------------------------------|------------|---------------|
| **Blaze Tiger**    | Beast   | flame, hunting  | skirmisher · 5 / 7.0 / 4 / 1 / 2 / 3       | Leap     | *Magma Pounce* · Eruption · O4 · **Pounce**  | Lava Field | Momentum      |
| **Ember Hawk**     | Winged  | embers, flight  | glass cannon · 2 / 9.0 / 3 / 2 / 2 / 2     | Glide    | *Cinder Dive* · Eruption · I3 · **Trail**    | Shockwave  | Skittish      |
| **Forge Golem**    | Ancient | forge, stone  | anvil · 8 / 4.0 / 1 / 1 / 3 / 3            | —        | *Crucible* · Eruption · ring of 4 · **Ring** | Raise Wall, Raise Ground | Immovable     |
| **Moss Turtle**    | Scaled  | moss, shell | anvil · 8 / 3.0 / 2 / 1 / 3 / 3            | Run      | *Tidal Shell* · Flood · I3 · **Slow-burn**   | Bark Veil  | Deep Roots    |
| **Thorn Mites**    | Swarm   | thorns, infestation | fragile · 3 / 6.0 / 2 / 2 / 3 / 2          | Burrow   | *Bramble Tide* · Flood · I2 · **Deep Residue**| Thornbed   | Thornwalker   |
| **Grove Wisp**     | Spirit  | grove, wandering light | skirmisher · 4 / 8.0 / 4 / 1 / 2 / 3       | Phase    | *Spring Burst* · Flood · L3 · **Lob**        | Gale       | Adaptive      |
| **Gloom Wolf**     | Beast   | gloom, pack hunting   | balanced · 5 / 6.0 / 2 / 1 / 3 / 3         | Run      | *Gloom Rift* · Rift · I3 / L3 · — (baseline) | Mire       | Pack Hunter   |
| **Dusk Moth**      | Winged  | dusk, eclipse   | glass cannon · 2 / 9.0 / 3 / 2 / 2 / 2     | Glide    | *Eclipse* · Rift · I3 → 4 cells · **Wide**   | Shade Veil | Native Ground |
| **Hollow Serpent** | Scaled  | hollow, coils   | anvil · 7 / 4.0 / 2 / 1 / 3 / 3            | Burrow   | *Coiling Rift* · Rift · L4 · **Constrict**   | Void Pull  | Thick Hide    |

One sentence each (design test):
- **Blaze Tiger** — dives into melee range, lays Lava behind the enemy and pounces with a big Eruption next to itself.
- **Ember Hawk** — strafes a burning line from where it stands, pushes enemies with Shockwave, and dodges away after taking a hit.
- **Forge Golem** — walls itself in and erupts around its own body; you have to come to it.
- **Moss Turtle** — a slow, heavy Flood that hits one turn later but harder, behind Bark Veils, and has a terrain passive awaiting redesign (Deep Roots; [temp_todo.md](temp_todo.md) T11).
- **Thorn Mites** — weak little Floods that leave level II thorns, on top of a Thornbed they walk through unharmed.
- **Grove Wisp** — throws weak Floods from far away, phases through props, and is the only one that can turn its shapes in battle.
- **Gloom Wolf** — the baseline: Mire flips the turn order, its Rift does the rest; much stronger with an ally next to the target.
- **Dusk Moth** — a wide Rift under a Shade Veil; Native Ground remains a placeholder ([temp_todo.md](temp_todo.md) T11).
- **Hollow Serpent** — pulls you in with Void Pull, then its Rift drags everything it hits toward the centre.

Other kits the 4 slots allow (not in the first roster): four Surges, moving by Step only, a stationary battery · Leap + Strike + Shove + a Veil, a mobile fighter without a Surge · Run + Surge + Surge + Veil, a caster with one answer.

Coverage gaps in this reference roster: Raise Ground (except Forge Golem), Sanctify, Shove, Blink. Roster and species-list coverage remain unvalidated ([temp_todo.md](temp_todo.md) T11/T12); no Kin × aspect quota applies.

### 6.2 Additional Species Candidates

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

## 7. Growth

### 7.1 Skill Development Reference

Permanent skill-slot development, shared EP spending, pill-based replacement, upgrade patches and AP policy are defined exclusively in **§4.6**, with costing in §4.5 and the shared model/references in §4.2/§4.7. The rarity and progression tables below retain their existing working values; they do not set new slot ranks, prices or validated EP awards.

### 7.2 Monster Rarity

**Rarity = potential and flexibility, NOT raw power.** A Normal and a Legendary at the same stage are close in raw stats — the Legendary has more options and a higher ceiling.

|                                  |                       Normal                       |        Rare       |        Epic       |            Legendary            |
|----------------------------------|----------------------------------------------------|-------------------|-------------------|---------------------------------|
| Base kit                         | 4 slots (active or passive, ≥ 1 active)            | same              | same              | same (+ signature at max stage) |
| Extra passive slot               | —                                                  | —                 | 1                 | 1                               |
| Paths offered per evolution      | 2                                                  | 3                 | 3                 | all                             |
| Evolution points per step        | 1                                                  | 1                 | 2                 | 2                               |
| Max stage reachable              | Core                                               | Soul              | Immortal          | Sovereign                       |


- "Max stage reachable" is the core axis — the wuxia "noble bloodline" trope, long-term potential over instant power
- **No stat bonuses from rarity.** Soul+ caps already sit on the absolute scale (HP 10, Init 10.0, TPR 3, Reach 4, AP 3; AP 4 / 5 at Immortal / Sovereign), so rarity buys slots, evolutions and ceiling — never numbers
- **High mechanics are Rare+ territory by design:** Air layer and 2x2 need Soul, TPR 3 needs Soul, the Ancient's Major Surge needs Sovereign. A Normal monster (max Core) has no Soul-tier air/2×2 or TPR-3 access; TPR 2 is already possible from Foundation (§7.4)
- Rarity does **not** decide the stat shape: any rarity can roll any shape (weighted by Kin lean, §1.1)
- Shared EP spending, superseded per-skill prices and replacement rules: §4.6. This table supplies only rarity/progression working data, not slot-development prices.
- Offered counts and EP income in the table are legacy working values, not a validated budget for the shared system.

### 7.3 Rarity Ascension

- A **major event**, not a grind: rare material + ritual (bloodline awakening), story-flavored
- **Ingredients:** one **Bloodline pill**, made of a Rare+ beast part of the monster's Kin and a herb of the next tier, plus a ritual. Item integration is in [Overworld §6.6](gdd_overworld.md#66-pills--medicines), acquisition restrictions in [Overworld §7.8](gdd_overworld.md#78-acquisition-sources), and ritual logistics in [Overworld §2.6](gdd_overworld.md#26-action-catalog). Ritual location remains unresolved ([temp_todo.md](temp_todo.md) T30); no Aspect Altar is implied.
- On ascension: unlock new rarity's slots/caps, keep everything else
- **Hard cap:** Normal can climb to Epic but never Legendary — true Legendaries remain rare finds

### 7.4 Monster Progression: the 18 Steps

Six stages × three sub-tiers = **18 steps**. The idea: **every sub-tier is stat points** (a free choice inside the stage ceilings), **every stage is new skills and mechanics**. A monster never goes past the player's step (ceiling rule) or its rarity's max stage (§7.2). Player and monsters walk the same table; the player's own bars may differ in XP numbers later.

| # | Stage · Sub-tier  | Budget (above base) | Gain on reaching the step                                                                       | XP bar to the next step | 
|---|-------------------|---------------------|--------------------------------------------------------------------------------------------------|-------------------------|
| 1 | Qi Gathering Lower| 4                   | full kit (4 slots) · TPR 1 · AP 2 · 1v1                                       | 60                      |
| 2 | Qi Gathering Middle| 5                  | +1 stat point                                                                                    | 120                     |
| 3 | Qi Gathering High | 6                   | +1 stat point · breakthrough trial opens                                                         | 200 (+ trial)           |
| 4 | Foundation Lower  | 10                  | **+4 points** · **evolution step** · +1 learnable skill · TPR 2 · 3v3 / 2v2 · 1 tamer slot       | 150                     |
| 5 | Foundation Middle | 11                  | +1 stat point                                                                                    | 300                     |
| 6 | Foundation High   | 12                  | +1 stat point                                                                                    | 500 (+ trial)           |
| 7 | Core Formation Lower | 14               | **+2 points** · **evolution step** · +1 learnable skill · AP 3 · 5v5 special · 2nd tamer slot    | 400                     |
| 8 | Core Formation Middle | 15              | +1 stat point                                                                                    | 800                     |
| 9 | Core Formation High | 16                | +1 stat point                                                                                    | 1300 (+ trial)          |
| 10| Soul Tier Lower   | 18                  | **+2 points** · **evolution step** · +1 learnable skill · air layer, 2x2, TPR 3 · foreign movement mode (§3.3) · Beast Swap     | 1000                    |
| 11| Soul Tier Middle  | 19                  | +1 stat point                                                                                    | 2000                    |
| 12| Soul Tier High    | 20                  | +1 stat point                                                                                    | 3200 (+ trial)          |
| 13| Immortal Lower    | 20                  | no points · **evolution step** · +1 learnable skill · AP 4 (TPR 1 only) · 3rd tamer slot | 2500 |
| 14| Immortal Middle   | 20                  | +1 evolution step                                                                                | 5000                    |
| 15| Immortal High     | 20                  | +1 evolution step                                                                                | 8000 (+ trial)          |
| 16| Sovereign Lower   | 20                  | **evolution step** · AP 5 (TPR 1 only) · Signature skill (Legendary) · Major Surge (Ancient)   | 6000                    |
| 17| Sovereign Middle  | 20                  | +1 evolution step                                                                                | 12000                   |
| 18| Sovereign High    | 20                  | +1 evolution step · the end of the table                                                         | —                       |

- **Evolution step** = the monster earns the EP of its rarity (§7.2): 1 for Normal / Rare, 2 for Epic / Legendary. Normal reaches Core (steps 4 and 7: only 2 EP under the old supply, which must be reviewed for shared slot/physical evolution), Rare reaches Soul (3 steps), Epic Immortal, Legendary Sovereign. Immortal and Sovereign give choices instead of numbers
- **Learnable skills:** the species list grows with the stages (4 defaults + 1 per breakthrough from Foundation to Immortal = 8). Kit access and replacement/development rules: §4.1/§4.6
- **Why not points at Immortal / Sovereign:** the stat ceilings and the damage law are reached; more points would only be number inflation (pillar 1)

**XP (proposal, prototype: Lower 60, Middle 120, High 200).** The bars above grow about ×2.5 per stage. A **cultivation pill** is worth about half a Lower bar of its tier (Qi +30 as in the prototype, Foundation +80, Core +200, Soul +500, Immortal +1200); a **win** gives 10 XP at Qi Gathering and ×2.5 per stage; a night on a cultivation spot gives a little (Meditation Stone ≈ one tenth of a win, Qi Spring double). Rule of thumb: a sub-tier is 3–6 days of focused play at the right stage.

Breakthrough trials: [Overworld §6.3.1](gdd_overworld.md#631-breakthrough-trials).

---

## 8. Design Tracking

Open decisions, dependencies and validation tasks are maintained only in [temp_todo.md](temp_todo.md). Skill contracts, costing and development remain incomplete (T02/T05); generic runtime reconciliation belongs to T04/T07–T09; passive/species/roster content to T10–T12; loadout/tamer interfaces to T18–T20; ritual logistics to T30; Major Surge/Signature access to T32. Document synchronization is tracked under T35. These are source pointers, not a second task list.

The confirmed removal of fixed monster aspects, the Force/Nature/Dark triangle and attunement overrides older proposals. Other proposals remain working design pending review.
