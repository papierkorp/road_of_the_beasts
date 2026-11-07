# GDD — MONSTERS & SKILLS
*Working Draft v1.0 · companion files: gdd_battle.md (how a fight works) and gdd_overworld.md (the world around it) · source of truth for everything that defines a monster*

---

## 1. Overview

Every monster definition lives here, once. The other two files link to this one.

|                                        Question                                        |       File       |
|----------------------------------------------------------------------------------------|------------------|
| What is a monster? Stats, Kins, skills, passives, roster, evolution, rarity             | this file        |
| How does a fight run? Turns, squares, zones, ground, Surge rules, damage                | gdd_battle.md    |
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
  evolutions      physical evolution choices and permanent development per skill slot (§4.7)
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
4. KIT          4 slots (active or passive, ≥ 1 active); each concrete Surge defines its behaviour, shape + size and at most ONE twist (§4.4)
5. PASSIVE      the rule-bender — biggest personality driver
6. SIZE         1x1 vs 2x2
```

**A shared construction kit builds a monster** — not everything is invented from scratch per monster:

|           Layer           |                                  Decides                                  |                                  Example                                   |
|---------------------------|---------------------------------------------------------------------------|----------------------------------------------------------------------------|
| **Kin** (body)            | Strike, movement layer, stat lean, allowed skill profiles, Surge size         | Beast bites and is fast; only Ancient has a Major Surge                    |
| **Themes** (description)  | free-form flavour and visual identity, no mechanical eligibility rules   | fire, moss, shadows, storms — motifs may mix freely                        |
| **Species** (the monster) | its default kit of 4 slots and its Species Surge (§4.4)                  | Blaze Tiger: *Magma Pounce* — O4 Eruption that must land next to the tiger |

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
| Movement            | int      | Squares per movement skill (gdd_battle §5.5); Step is always 1                                                        |
| Reach               | 2–4      | Cast range of all skills (gdd_battle §5.3); Strikes don't use it                                                      |
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
- **The stat shape can change** later through a ritual with a rare item (a Reshape Elixir at the Trial Pillar, 1 AP, gdd_overworld §2.6). The ritual is a respec: all points are pooled and the monster is **re-rolled inside the new shape's frame** with the same budget; the leftover is unspent. Level-up spending does not change the shape label
- **Ceiling rule:** monsters cannot exceed the player's stage (the spatial space can only sustain what the tamer's qi can feed)
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

Every Strike is a **shape around the body** plus a **Kin twist** (rule: gdd_battle §5.2). The species picks the shape, the Kin gives the twist.

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
- The shape is part of the species and changes through the Shape and Size evolutions (§4.7)

**Kin twists.** Every Strike deals **2 damage**; the Kin adds one effect. The effect is the Kin's identity, it has no price:

|   Kin   |   Strike   |                                          Effect                                          |
|---------|------------|------------------------------------------------------------------------------------------|
| Beast   | Bite       | no effect                                                                   |
| Winged  | Dive       | then move 1 square away for free (the free neighbour farthest from the target)           |
| Scaled  | Tail Sweep | push the target 1 square (direction chosen with WASD)                                    |
| Swarm   | Gnaw       | props take double (4)                                                                    |
| Spirit  | Siphon     | target −1 initiative next round                                                          |
| Ancient | Slam       | cracks Elevated under the target → Rubble                                                |

### 3.3 Movement by Kin

Every monster has **Step**. Anything better is a movement skill in one of the 4 slots, and each Kin only has some of them. Each mode is a preset of movement flags (gdd_battle §5.5).

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

**Authoritative monster-skill specification:** this chapter owns the shared construction model, effect contracts, kit/access, authored usage costs and slot development/upgrades. §4.1 defines the kit; §4.2 the construction dimensions, spatial/temporal/effect contracts and costing; §4.3 validation; §4.4 Surge constraints; §4.5 the single schema; §4.6 species/signature access; §4.7 permanent development, replacement and upgrade/AP policy. Kin-specific data remain in §3, passive content in §5 and rarity/progression tables in §7, all subject to this chapter.

**Boundary:** gdd_battle owns generic execution and resolution: turns/AP spending, targeting/placement checks, board layers, effect application/stacking, movement traversal, Surge lifecycle, damage and collisions. References and binding summaries here constrain authored definitions; they are not a second runtime specification. gdd_overworld owns action logistics, items and the tamer/loadout system, not a parallel monster-skill model. Confirmed rules here supersede conflicting legacy skill-development proposals; unresolved cases stay open, not new permissions.

### 4.1 The Kit

```
Monster = Step (always, no slot)
        + 4 slots, each an active (movement skill, Strike (Kin), Surge, utility) or a passive,
          at least one active      — Epic+ get a 5th, passive-only slot (§7.2)
```

A movement skill is a normal slot skill and something different from **Step**, the universally available, slot-free 1-square move (2 AP). No kind of skill is mandatory. A kit may hold the same kind several times (4 Surges, or two movement skills and a Strike). Limits: the species' learnable list, the Kin's lock-outs (§3.1, §3.3) and one charging Surge at a time (gdd_battle §5.4). All 4 slots are open from the first day.

**Kit design tip:** for a default kit, pair a Surge with a utility of a *different effect family* (protection, slowing or displacement) so there is always an answer in the kit. Themes are descriptive only; concrete skills define their zones, ground and effects, without theme-based bonuses or penalties. The prototype Tiger's 7 skills are a test bench, not a kit.

### 4.2 Data-Oriented Skill Construction Kit

A concrete skill is an authored data definition assembled from independent dimensions, not a choice from a closed list of fundamental blueprints. **Rule profiles and referenced effect definitions constrain legal combinations; reusable authored data grants no new mechanics or permissions.** Players select finished skills and authored upgrades (§4.7), not arbitrary components.

| Dimension | Data and responsibility |
|-----------|-------------------------|
| **Metadata** | Stable id, name, descriptive tags, skill kind and rule profile; species access and Kin/progression restrictions still apply. Tags only support filtering, never mechanical eligibility. |
| **Execution timing** | `immediate` or `telegraphed_delayed`, with the exact resolution event and telegraph/charging rules. This is distinct from effect triggers and persistence. |
| **Targeting** | Legal selection of `self`, `unit`, `tile` or `prop`, with profile-bound eligibility, distance and sight checks. Selection is distinct from placement and effect recipients; see the spatial contracts below. |
| **Placement** | Where the selected target anchors the skill, body-relative or board-anchored placement, adjacency/occupancy requirements, and any direction or pull anchor selected at cast. Selecting a unit does not imply tracking it after placement. |
| **Area** | Shape family, explicit cell footprint/count and orientation policy. Area is not cast range. Existing fixed orientations, Strike direction selection and explicit exceptions such as Adaptive remain distinct. |
| **Effects** | Typed entries such as damage, displacement, shield, stat change, heal, cleanse or movement, with recipients, values, ordering and references to existing rules. An effect name alone does not authorize a new use. |
| **Timing triggers** | When each effect applies: resolution, entry, start/end of turn, round event or another already authored trigger. No automatic repeated application merely because an area persists. |
| **Persistence** | Lifetime of each created zone, ground, prop or temporary effect: rounds, permanent, until destroyed, until consumed or another existing termination rule. Not the delay before execution. |
| **Board changes** | Explicit ground placement/residue, height change or prop creation/movement/destruction, including existing overwrite, cleanse and collision rules. Ground and height are separate dimensions even where an existing profile couples them. |
| **Interactions** | Ground/air applicability, solid-prop and height blocking, LOS requirements and movement flags. Changing ground is a board operation, not an inferred consequence of hitting ground-layer units. |
| **Usage limits** | AP cost, existing per-battle limits, charging concurrency and consumption conditions. No generic cooldown or mana system. |

**Binding rule profiles and validation**

- **Strike:** immediate, body-relative footprint from §3.2, not Reach targeting; existing AP-by-shape, ally hits, prop blocking, 2-damage rule and Kin twist remain binding. Generic area/effect fields cannot turn it into a ranged burst.
- **Surge:** telegraphed delayed execution under gdd_battle §5.4, including preview, charging/resolution, one charging Surge at a time, legal shape/size, damage law and profile-specific interactions. **Surge means telegraphed delayed execution, not mandatory residue.** Residue is an optional, explicit `board_changes` component, evaluated and priced separately from damage/delay; `board_changes: []` is legal. Eruption/Flood/Rift retain their authored residue as concrete profiles. Eruption/Flood/Rift are existing mechanical Surge profiles, not the only possible data layouts or unrestricted permission to invent more behaviours. Major Surge retains Ancient/progression access and once-per-battle constraints.
- **Zone:** a temporary area carrying at least one existing zone effect; existing trigger, stacking, value/cap and expiry rules apply (gdd_battle §4.6). Effects and caps have one authoritative definition; duration belongs to the concrete skill's persistence data. A shield or heal entry does not grant immediate casting or arbitrary new triggers.
- **Other existing profiles:** ground, prop, direct and movement retain their authored battle rules and Kin lock-outs (§3.1, §3.3). Species exclusivity and Signature access are metadata/access restrictions (§4.6), not additional mechanical kinds. Movement flags remain the existing presets/authorized exceptions, not unrestricted movement permissions.
- Damage delivery remains restricted to existing rules: Strike damage is not Surge burst damage; only Surge authorizes the existing burst-damage mechanic; ground damage stays capped at 2 per trigger. No immediate ranged burst, damage zone, repeated heal or other new combination is approved solely because fields can express it.
- Existing targeting/placement, shape, layer, LOS, blocking, friendly-fire and usage constraints must all pass alongside budget validation. A budget surplus never overrides them. No aspect or attunement field is introduced.

**Spatial contracts — targeting, placement and recipients**

These are separate responsibilities, resolved against gdd_battle §4.3–4.11 and §5.2–5.7. References may supply fixed fields; an unresolved rule is not a configurable permission.

| Contract | Required resolved data | Binding rules / open cases |
|----------|------------------------|----------------------------|
| `targeting` — what is selected | Selection type (`self`, `unit`, `tile`, `prop`), eligible target definition including side/layer where applicable, distance source and LOS rule | `self` selects the caster; `unit` selects an eligible monster; `tile` selects a board cell, not its occupant; `prop` selects an eligible existing prop, not permission to create or relocate it. Side eligibility must come from the source; no generic ally/enemy filter is granted. |
| `placement` — where it resolves | Binding from selection to board anchor or body footprint, required adjacency, occupancy/layer constraints and separately selected direction/pull anchor | Zone/ground/prop/Surge anchors use effective Reach, Manhattan distance from caster to anchor, not distance to every affected cell (gdd_battle §5.3). Strike uses its body shape without a ranged anchor; movement uses Movement (gdd_battle §5.2, §5.5). Authored twist exceptions stay explicit (§4.4).|
| Effect `recipients` — what receives an effect | Referenced recipient rule, spatial scope and evaluation event/application condition, including side, air/ground and prop eligibility | Selection does not restrict an area to the selected unit or its side. Zones affect everyone occupying their cells; Strike hits allies but excludes its caster; Surge includes its caster and allies. Ground affects ground-layer occupants; prop reactions and Surge prop/occupant handling use their own rules, not a generic occupant hit (gdd_battle §4.6–4.7, §5.2–5.4). |

- **LOS and legal placement are independent:** zone, ground, prop and Surge casts need no LOS; Shove and species-specific effects on another monster need sight, self boosts do not (gdd_battle §5.7). No LOS exemption removes Reach, occupancy, layer or blocking checks. Exact sight geometry and unspecified direct-target eligibility remain open under [temp_todo.md](temp_todo.md) T02/T04/T09.
- **Occupancy is layer-specific:** retain one object, pending Surge, zone and ground type per cell; zones/Surges may land on props, ground needs prop-free cells except explicit reactions, prop creation needs empty cells. A charging Surge cannot overlap another charging Surge (gdd_battle §4.3, §5.3–5.4). FIELD-prop occupant handling and air occupancy remain T04/T09; do not infer a single universal `empty` test across layers.
- **Bindings are explicit, not tracking:** placed board footprints stay at their cast cells; push direction and pull anchor are fixed at cast (gdd_battle §4.4, §5.3, §6.5). A selected unit supplies no implicit homing area, following zone, moving pull anchor or automatic retarget after movement/death. Unit-targeted definitions must specify resolution/validity behaviour where not already defined (T02/T04). Body-relative Strike placement is its own immediate rule, not a tracking precedent.

**Area contract — explicit footprint, not cast range**

Required resolved data: shape/profile reference, explicit distinct integer cell offsets relative to a declared anchor/body origin, `cell_count`, authored orientation and its permitted selection policy, plus board-boundary and blocking/placement references. A reusable footprint definition may own the offsets; the skill need not duplicate them. `cell_count` must equal the offset count; family name or an unexplained orientation number alone is insufficient to reconstruct the cells.

- For tetris profiles, gdd_battle §5.3 binds family/count: I2 = 2; I3/L3 = 3; O4/T4/S4/Z4/L4/J4 = 4. The anchor is the centre-most cell; its exact offset mapping must be authored, not chosen by a runtime tie-break. The usual 1–4-cell and Swarm-size restrictions remain §3.1/§4.2 rules; Strike's separate body footprints (§3.2) and Major Surge's explicit access/profile are not generic size overrides.
- Normal tetris skills have one fixed absolute board orientation for both teams, not caster facing, team mirroring or a default rotation. Only existing Adaptive permission enables in-battle rotation; Strike separately selects one of eight directions (gdd_battle §5.2–5.3). Push direction is not footprint rotation. Missing offset/orientation mappings remain T02, not permission to invent a default.
- **No boundary clipping:** every footprint cell must be on the board (gdd_battle §5.3); do not trim, shift or rotate it automatically to fit. Profile-specific blocking/reactions remain distinct from boundary validity: Strike solid-prop blocking, ground/prop occupancy and Flood's Elevated blanking retain their existing rules (gdd_battle §4.3, §5.2–5.4). Do not generalize these into universal obstacle clipping or automatic footprint resizing. Forced-movement collision uses gdd_battle §6.3, not area placement.
- Footprint cells are not automatically distinct monster hits. For **2×2 bodies**, Reach origin/target distance, body-relative origins, partial overlap, recipient deduplication/damage multiplicity, mixed ground/height/layer occupancy, landing and displacement are insufficiently defined (T04/T09). Do not infer one hit per cell, one hit per unit, partial placement or a collision-resolution default. Preview/validation must expose unsupported cases rather than silently decide them.

**Temporal contract — execution, effect events and lifetime**

| Responsibility | Required resolved data | Existing binding rule |
|----------------|------------------------|-----------------------|
| `execution` | Immediate vs telegraphed delay, exact resolution event, charging/telegraph and autonomy rules where applicable | Immediate resolves the action now, not every effect now. Surge declares a marker and resolves at the start of the caster's next turn, before start effects; displacement/death of the caster does not cancel it. If dead, use when its queue slot would have occurred (gdd_battle §2.2, §5.4, §6.2). This is not a generic one-round delay. |
| Effect trigger/application | Referenced event, whose turn/entry it is, recipients at that event and ordering dependencies | Existing resolution, `start_of_turn`, `on_enter`, `while_inside`, Surge-damage protection and `end_of_turn` events remain definition-bound (gdd_battle §2.4, §4.6–4.7). `while_inside` is continuous, not a repeating cast. |
| `persistence` | Owner of the lifetime, clock/event, duration or consumption/removal condition, expiry result | Zone has one shared round clock for all its effects, ticks at round end and is removed on expiry without repaint. Ground remains until changed; pending Surge ends at detonation; optional authored residue has its own separate lifetime. Props and authored temporary effects retain their own removal/consumption rules (gdd_battle §4.5, §5.6). No independent zone-effect timers. |

The event sequence is gdd_battle §2.1/§2.4: **due Surges (damage → explicitly authored residue, if any) → occupant start effects → AP actions → end displacement → Lava on the landing square → `mend`**. Thornbed/Mossbed entry events occur on entry, including push/pull; placing ground beneath an occupant is not entry. At round end: zones decrement/remove → burning props burn down → Voidscar spreads → initiative recalculates. Per-turn effects belong to the occupant's own turn, not once per team or once per round; round duration is not a count of caster actions.

Persistence adds no on-cast, on-entry, per-turn or expiry payload absent an existing definition. Do not add repeat triggers, proc limits, cooldowns or reactivation events to fill gaps; AP repetition and one charging Surge remain gdd_battle §2.3 constraints. **Open centrally:** T02 for missing authored trigger/lifetime contracts (including ignition); T04 for Flood/Tail Sweep and simultaneous-event ordering, pull ties, multiple turns/changed initiative/dead-caster queue timing (the informal “everyone acts between” description is not guaranteed); T07 for ground/zone interaction and Mossbed re-entry/healing limits; T09 for 2×2 entry/overlap and air; T19 for medicine/array activation windows and consumption. No new ordering or timing policy is decided here.

**Effect catalogue — data, not skill blueprints**

`damage`, `displacement`, `stat_change`, protection, healing, self movement and board operations are typed contracts, not independently purchasable permissions. Every entry requires a referenced **effect definition**, legal owning rule profile/source, recipients, trigger/application and resolution order. The definition supplies allowed parameters, caps, interactions and termination; a skill supplies only explicitly permitted values. Fixed definition fields must not be duplicated as independently editable choices. References below describe documentation contracts, not new engine identifiers.

**`damage` — apply an existing damage source**

Required data: source/profile definition, profile-authorized value or value source, footprint/recipients, trigger and ordering reference. Reduction, prop reactions, height and air eligibility come from that profile, never from a generic damage flag.

| Existing source/profile | Permitted value and recipients | Trigger, order and limits |
|-------------------------|--------------------------------|---------------------------|
| Strike | 2 damage under §3.2, max 2 against monsters; every monster and prop in its body footprint, allies included, excluding the striker. Existing Swarm exception: props take 4 (§3.2), not monster burst damage | Immediate; no Reach targeting. Solid props take the hit and block squares behind them; Kin twist and §3.2 / gdd_battle §5.2 remain binding. Strike reaches air. |
| Surge | Eruption 3, Flood 2, Rift 3 against monsters, including allies and caster; the residue-free §4.5 reference proposes fixed 3, not a new balance approval. Normally 2 against a prop instead of its occupant, subject to explicit reactions | Delayed: start of caster's next turn, before start effects. Apply profile height/prop handling and reduction (shield, Hallowed; minimum 0), then explicitly authored residue, if any. Eruption hits Elevated without residue; Flood cannot reach Elevated; Rift collapses it. No air hits. See gdd_battle §5.4, §6.2. |
| Hazard ground | Lava / Thornbed / Blight: level I–II, damage = level, max 2 per trigger; Voidscar: 1. Ground-layer occupant, regardless of side | Lava: end of occupant turn, on landing square after displacement; Thornbed: entry, including push/pull; Blight / Voidscar: start of occupant turn. Placement is `board_changes`, not immediate damage. One ground per square; no stacked hazards (gdd_battle §4.7). |
| Collision / fall / debris | Existing event damage: 1 each, subject to recipient exceptions in gdd_battle §6.3 | Derived on blocked impact, falling off Elevated or prop shatter, not a free castable payload. Prop collision damages mover and prop (heavy prop takes none); monster/edge blocking deals none under gdd_battle §6.3. Debris hits four neighbouring squares and collapses Elevated neighbours. |

Prop exceptions remain explicit: Eruption ignites Trees instead of prop damage; Flood does not damage/move heavy props; Rift adds the existing brittle-prop reaction; indestructible props cannot be removed (gdd_battle §4.10–4.11). Major Surge and baseline twist exceptions require their own authored definition and access/usage rules; this catalogue supplies no new damage value. **Zones never deal damage; no immediate ranged burst or new damage zones.** The retired collision-bonus proposal remains unapproved (T04), not an exception to the collision law. Damage values are not slot-upgrade parameters (§4.7).

**`displacement` — forced movement under an existing source**

Required data: definition/source, `mode: push | pull`, recipients, `steps`, trigger/order and direction or anchor binding. Push requires a cardinal direction selected at cast (Tail Sweep: selected with the Strike); pull requires a board-square anchor selected at cast, not an implicitly tracked unit or the caster's later position. Movement is always cardinal, **one square per trigger** (`steps: 1`), with the landing square previewed (gdd_battle §6.5). No distance upgrade may exceed that hard cap without a separate rule decision.

| Existing source | Recipients and trigger | Binding constraints |
|-----------------|------------------------|---------------------|
| Zone `push` / `pull` | Occupant at end of its own turn; caster, allies and enemies alike | Direction/anchor fixed at cast. Displacement → Lava on landing square → `mend`; entry effects apply on entering the destination. Persistence does not create another trigger. |
| Direct displacement (Shove) | Selected unit, one-time direct resolution | Sight required; legal target/layer restrictions must be authored, not borrowed from removed table flags. Generic displacement does not authorize prop relocation. |
| Scaled Strike (Tail Sweep) | Struck monsters, push 1 | Existing Kin twist (§3.2); chosen direction and Strike constraints. |
| Flood Surge | Struck monsters, push 1 in cast direction | Retains Flood damage, residue, height and heavy-prop rules; damage/residue/push order needs reconciliation below. |
| Authored pull twist | Struck monsters, pull 1 toward cast anchor after damage | Existing twist (§4.4); no arbitrary extra target or trigger. |

Blocking, collisions, falling, shatter and entry effects are delegated to **gdd_battle §6.3–6.5, §4.7 and §4.10**, not configurable collision damage here. No chain push, diagonal step, extra step or air/prop eligibility is implied. **Open conflicts:** gdd_battle §6.1 mentions monster-collision damage but gdd_battle §6.3 explicitly says none; this catalogue reports the detailed gdd_battle §6.3 result without resolving the conflict. Flood's wording in gdd_battle §5.4 implies pushing into newly laid residue, whereas gdd_battle §6.2 gives damage → aftermath without placing push in that sequence. Pull's cardinal tie-break (including already being on the anchor), and damage/push order for Tail Sweep, need explicit specification; do not invent defaults.

**`stat_change` — referenced effective modifiers, not arbitrary stat edits**

Required data: existing effect definition, its permitted `value`, source/recipients, application condition and termination reference. Definitions bind stat, sign, floor/cap, opposite and timing; a skill cannot freely choose `stat`, `operation` or a new trigger. These modifiers never rewrite the base sheet. Zone modifiers apply to **everyone while inside**, stop on leaving/removal/expiry and use zone replacement/opposition/level rules (max III), not cumulative permanent deductions (gdd_battle §4.6). Zone level III is not permission for value 3 on every effect. Referenced zone effect definitions own `base`/`cap` and the level-to-value computation (gdd_battle §4.7); concrete skills must not replace that with unrestricted stat deltas. Missing numeric caps or scaling formulas remain open, not new defaults.

| Existing definition | Meaning / existing authored values | Bounds and timing |
|---------------------|------------------------------------|-------------------|
| `slow` / `haste` | Movement −value / +value; retain authored values such as slow 1 | While inside; `slow` never lowers Movement below 1; **Step is unaffected**. This changes Movement-skill effectiveness, not AP cost, TPR or a permanent stat. |
| `drain_init` / `quicken` | Effective initiative −value / +value; examples include −1, −2 and +1 | While inside; order recalculated each round (gdd_battle §2.2). No immediate queue rewrite or arbitrary numeric interval. General effect-value caps/floors are not specified by gdd_battle §4.6 and remain open. |
| `drain_range` / `extend` | Effective Reach −value / +value; examples include −1, −2 and +1 | While inside; Reach minimum 1. No independent per-skill range stat. Upper modifier/value caps require clarification, not extrapolation from progression ceilings. |

The existing Spirit Strike **Siphon** applies target initiative −1 next round (§3.2), not `while_inside`. It needs a separate referenced timed definition preserving that trigger and expiry, not a free timing override on zone `drain_init`; stacking/refresh details remain open. This does not authorize arbitrary timed Initiative/Reach/Movement effects.

Hearth / Shrine supply existing `quicken 1`, Umbra / Sigil `extend 1`; Elevated supplies its authored +1 Reach while occupied. These sources retain their ground/prop/height conditions, not zone expiry or free source substitution (gdd_battle §3.1, §4.7, §4.10). Definition-specific caps are distinct: `shield` has the existing Surge reduction (2, up to 3 with level, gdd_battle §5.4), `mend` cannot exceed max HP, and `expose` is reserved with no zone. These are reduction/healing/reserved definitions, not generic stat-change permissions.

No general temporary **TPR, AP, HP maximum or movement-rule/flag** edits are approved. A species-specific timed boost needs an explicit authored definition, duration, limits and validation (§4.6); its existence does not unlock arbitrary stat changes. Authored base-skill Reach debuffs and existing positional Reach buffs are temporary battle effects, **not cast-range upgrades**. Slow is not AP reduction. Slot development still grants no damage increase, AP reduction or cast-range increase (§4.7); budgeting never overrides these prohibitions.

**`shield` / protection — referenced reduction, not shield HP**

Required data: protection definition and owning source/profile, permitted reduction/value source, protected recipients and damage sources, application condition, damage-event ordering, lifetime/consumption and stacking/cap references. Protection neither grants temporary HP nor edits a defense stat. Fixed source rules cannot be replaced by a generic immunity or damage-filter field.

| Existing definition/source | Recipients, trigger and lifetime | Ordering and caps |
|----------------------------|----------------------------------|-------------------|
| Zone `shield` (Veil) | Everyone occupying the square, including caster and enemies; available while inside, applied when taking Surge damage; ends on leaving or zone removal/expiry | Existing reduction 2, up to 3 with zone level (gdd_battle §5.4); definition owns scaling/cap. Surge damage − shield − Hallowed, minimum 0, before optional authored residue. Zone replacement/opposition/level rules apply; no independent charges or effect timer. |
| Hallowed ground | Ground-layer occupant of either side when taking Surge damage; permanent ground until changed, not a timed buff | Reduce by 1; explicitly authored Surge residue then replaces it, giving the existing one-time protection for those profiles. Preserve profile-specific residue/height rules; if no residue is laid, do not invent a separate consumption rule. |


Retired proposals for Lava immunity, prop reinforcement or Strike reduction are not options on generic `shield`; any such content needs separate validation (T02/T04/T10). `expose` remains reserved. Spirit Shield belongs to the tamer source (gdd_overworld §6.4, once per battle); it does not authorize a repeatable monster immunity. Additional protection sources require authored definitions, not source substitution or a new default stacking rule (T02/T04/T20).

**`heal` — restore current HP only at an existing trigger**

Required data: healing definition/source, authorized amount/value source, recipients, trigger, ordering, lifetime and cap/usage references. Healing never exceeds the recipient's existing max HP, changes max HP, revives a fallen monster or removes Injury. Definitions bind the event; persistence alone grants no heal on cast, per tick or extra activation.

| Existing definition/source | Recipients and trigger | Lifetime, order and caps |
|----------------------------|------------------------|--------------------------|
| Zone `mend` | Everyone on the square at the end of their own turn, including caster and enemies; existing Healing Spring example: `mend 1` | Displacement → Lava on landing square → `mend`; use the resulting occupancy and normal destination entry effects. Zone lifetime/replacement/level rules apply, with no independent effect timer. Max HP is binding; level scaling and numeric healing cap remain open under T07, not implied by max zone level III. |
| Mossbed | Ground-layer occupant of either side on entry by movement, push or pull; heal 1 | Permanent ground until changed; heal on the existing entry event, not on placement or continuously. Max HP applies. A per-turn limit/re-entry policy remains a T07 decision; neither invent a cap nor interpret this contract as approval of arbitrary heal loops. |

No generic immediate/direct monster heal, ally-only healing zone or new repeat trigger is approved. Second Wind is a **proposed tamer skill**, not a monster healing definition. Healing pills restore HP **between battles**, current HP persists through an expedition, and Revival ends Injury rather than supplying battle healing (gdd_overworld §5.2, §6.4–6.6). Planned in-battle medicines/arrays need their own source, consumption, loadout and timing contracts (T18/T19); the generic `heal` entry supplies none of those permissions. Healing economy and repeat-entry balance remain central T07 work.

**Self `movement` — voluntary relocation of the caster**

Required data: movement definition/source and authorized preset/exception, `recipients: self`, resolution trigger, origin and selected path/destination, distance source, path/landing/occupancy constraints, ordered traversal/entry events, action lifetime and usage/cap references. This is not forced `displacement`, unit relocation or prop movement. Resolve one movement action under gdd_battle §5.5; it creates no persistent movement permission.

- **Step:** always available without a slot, 2 AP, exactly 1 square; retain its walk/blocking rules, ignore `slow` and extra ground costs. It is not a freely upgradable Movement skill.
- **Slotted movement:** 2 AP, authorized Run/Leap/Glide/Burrow/Phase/Blink preset; distance = effective Movement + the preset's modifier, minimum 1, **not Reach**. Preserve the full preset's path, prop/monster/charging-Surge/height blocking and ground-cost rules, including climbing and walk entry effects. Path modes that count only landing do not inherit walk traversal triggers; destination effects still use their existing rules. Ignoring path blockers never authorizes an illegal occupied landing square.
- Preset access and foreign-mode exceptions remain §3.3 rules, including body restrictions and stage access. Blink's teleport path is available only through its authorized profile; a generic `path: teleport` override is not permission for any monster to teleport. Glide does not grant persistent flight or access to the air layer. Winged air access requires Soul Tier; flight, air occupancy and 2×2 movement details remain T09. Water/Swim are planned and remain T08, not a new legal preset for unspecified Kins.
- Authored flag-based modes must satisfy the existing distance/direction price rule and access constraints; fields are not player-selectable bypasses. Slot upgrades are named patches under §4.7: the existing one-flag-flip/distance-penalty allowance is not an unrestricted path-mode, flight, teleport, extra-action or range upgrade. Validate the complete resolved profile, entry ordering and destination preview; unresolved large-body/movement cases stay T04/T09.

Spatial Pull, Swap Places and Beast Swap are separate tamer-source definitions (including proposal status where applicable), not self-movement presets or a shortcut around monster access rules (gdd_overworld §6.4; T19/T20).

**`board_changes` — typed ground, height and prop operations**

Each entry requires an operation definition, legal source/profile, selected cells or prop and destination where relevant, cast/resolution trigger, before/after dependencies on damage/reactions, resulting state and lifetime, plus placement/blocking/occupancy and cap references. Recipients here are **board cells/props**, not a selectable ally/enemy filter on later occupants. Resulting hazards, healing and modifiers retain their own effect contracts. Board operations are one-time state transitions unless an existing definition explicitly supplies a later event; permanent state is not repeated execution.

| Operation | Required operation-specific data / existing source | Binding lifetime, ordering and limits |
|-----------|----------------------------------------------------|--------------------------------------|
| Ground placement / replacement | Concrete ground definition and permitted level/source, footprint; Field, Blessing or specified Surge residue | One permanent ground type per square, until changed. Field/residue starts at I where specified; same hazard type levels up to II, same blessed type stays unchanged, different type replaces under gdd_battle §4.7. Hazards max 2 damage per trigger; blessed ground has no levels and benefits either side. Retain Voidscar's unchangeable exception. Field needs prop-free squares except explicit reactions (Tree ignition instead of Lava). Elevated may carry ground; placement does not itself change height or trigger occupant entry. Residue follows damage and profile-specific height rules; no automatic zone × ground conversion (T07). Water creation/replacement remains T08. |
| Height change | Separate height definition, affected cells and existing source, e.g. Raise Ground, Rift or debris collapse | Low/Elevated only; no new height levels or timed height expiry. Raise Ground requires prop-free squares, may raise under a charging Surge and explicitly cleanses non-Voidscar ground to Plain. That coupled ground operation must be declared, not inferred for all height edits. Rift/debris collapse retains existing Rubble and damage rules. Elevated's Reach, climbing, fall and Surge interactions remain gdd_battle §4.7, §5.4, §6.3; height change alone grants no generic fall-damage payload or unit displacement. |
| Prop create / place | Existing prop definition (HP, solid/field/flying kind, tags and reactions), legal footprint and creation source | Existing prop placement requires empty squares (gdd_battle §5.3); one object per square. Do not overwrite occupants/objects or equate enterable FIELD props with permission to create under an occupant. Props persist until removed/destroyed by their rules, not zone expiry; no invented duration/HP. Shrine/Sigil use their existing definitions. Unspecified occupancy/layer cases, especially air and 2×2, remain T04/T09. |
| Prop move / relocate | Authorized source, selected prop, origin/destination and applicable path/placement constraints | Retain blocking, occupancy and one-object limits; heavy props cannot be moved (including Relocate/Flood), indestructible props cannot be removed. Generic unit push/pull is not a prop-move definition. No default distance, swap, relocation-triggered reaction, ground repaint or shatter is inferred; unspecified Relocate details require T02/T04 specification before use. |
| Prop destroy / remove | Existing destruction/reaction definition and eligible prop; damage-derived destruction references the damage source, not a free deletion flag | HP reaching 0 shatters: Rubble on its square, debris 1 to four neighbours and collapse of Elevated neighbours. Tree burning instead resolves at next round end to Lava I under its reaction; no inferred shatter on every removal. Pillar cannot be removed. Retain explicit ignite/extinguish/crumble/reinforcement definitions and their triggers; direct deletion, salvage or suppressed debris needs a separately approved source, not an optional generic switch. |
| Cleanse | Explicit source, exact affected layer/state, legal footprint/recipients and resulting state | Raise Ground clears non-Voidscar ground to Plain as above; Any additional monster zone-cleanse effect requires an explicit source-specific definition and validation (T02/T04); no such definition is established here. Zone removal ends its effects, not ground/height/props or a charging Surge. Domain Glimpse's zone removal plus Plain reset is a tamer-source operation (gdd_overworld §6.4), not a reusable monster permission. No generic cleanse of all layers, negative effects, Injury or Voidscar; unresolved combinations/order remain T02/T04/T07/T20. |

All operations retain Reach/anchor, fixed footprint, on-board placement, LOS and blocking rules of the owning profile (gdd_battle §4.3–4.11, §5.3–5.7); no LOS for existing ground/prop casts is not permission to bypass empty-square requirements. The preview must expose resulting ground/height/props, reactions and derived damage. Conflicting or underspecified simultaneous damage, collapse, debris, residue and relocation ordering remains T04/T07, not an inferred list-order default. Planned loadout operations stay T18/T19. No new prop types, conversion mechanics, board erasure or movement modes are approved by this catalogue.

**Confirmed costing model — base prices and combination rules**

Internal skill construction value is the sum of component base prices plus explicitly defined interaction surcharges. Optional Surge residue is a separately evaluated `board_changes` component, including its own interactions; neither damage nor delayed execution includes a mandatory ground payload. AP class and slot development determine the permitted budget (§4.7). Base prices provide a shared reference, not a claim that a component is equally powerful in every context: area combined with damage, displacement or repeated triggers must be evaluated together. Particularly problematic combinations may have hard limits or be disallowed regardless of remaining budget.

Combination rules are authored and documented alongside the components, not improvised hidden charges. Exact component prices, surcharges, budget thresholds and development allowances are still open under temp_todo T02/T05; calibrate them using a basic Strike, a temporary zone and a delayed Surge before expanding to the full catalogue. The authored monster-action prices are centralized below; Strike's shape-to-price data remain in §3.2. gdd_battle §2.3 owns spending AP and runtime repetition, not a separate authoring price list.

| Authored action/profile | Existing battle AP cost / limit |
|-------------------------|---------------------------------|
| Step (no slot) | 2 AP |
| Slotted movement | 2 AP |
| Zone / ordinary ground / prop / direct | 1 AP |
| Minor Surge | 1 AP baseline; one charging Surge per monster |
| Strike | 2–5 AP by the selected authored shape (§3.2) |
| Blessing ground | 2 AP; not the ordinary-ground default |
| Major Surge | 2 AP; once per battle; access under §4.6 / §7.4 |

These are the existing baseline prices, not new calibration values or final prices for every authored combination. A species-specific skill has its applicable mechanical profile's cost; the old generic “Unique = 1 AP, may set its own” is not a mechanical category or an unrestricted cost override. Any retained exceptional price needs explicit validation under T02. Optional higher-cost upgrade variants follow §4.7; blanket Twist/Size surcharges are not confirmed. Tamer skills, planned medicines and arrays have their own source/loadout contracts in gdd_overworld §6.4–§6.6 and gdd_battle §5.8; these monster-action prices do not assign their costs.

Authoring constraints retained from battle §5: normal shaped skills have one fixed family/orientation; unit-targeted effects and Step need no tetris footprint, and Strike uses its body shapes. A zone's existing duration default is 2 rounds, but every resolved definition must state/reference its lifetime; the §4.5 example remains an unvalidated combination. Temporary species-specific effects must state N rounds or an explicit consumption/end-of-battle condition; the former flat `rounds` field is not a separate schema. Movement presets/flags and their restriction-versus-distance/direction price rule remain binding runtime profiles (gdd_battle §5.5); §4.7 owns their upgrade allowance. A Surge needs at least three live counters to pass design validation (leaving, protection, height, air, props or tempo as applicable); a nominal counter that its actual profile prevents does not count.


- **AP is the only price a skill pays in battle.** No cooldowns, no mana
- **Cast range** uses effective Reach where the battle profile requires it; Strike uses its body footprint and movement uses Movement. No independent skill-range stat or new twist exception (§4.4).
- **Size:** 1–4 cells for ordinary skills with a tetris shape, 2 for Swarm Surges (§3.1). Strikes have their own list (§3.2); Major Surge requires its explicitly authored large-area profile and access, not a generic cap override.

### 4.3 Construction and Validation

Author a finished skill by selecting its legal rule profile, resolving the dimensions in §4.2 through referenced definitions, then checking access, interactions and budget. Use the single schema in §4.5; reusable footprints and effect definitions are data references, not fundamental skill blueprints.

Validate the complete resolved definition, not isolated components: selection → placement → footprint → recipients; execution → effect events/order → lifetime; then Kin/species access, usage limits and cost. A preview must expose cells, recipients, displacement landings and board reactions. Missing rules block the affected content rather than receive defaults.

The former named example table is retired. Roster names (§6.1) remain unvalidated content ideas, not effect definitions or permissions. Rebuild concrete skills only after the central decisions in [temp_todo.md](temp_todo.md), especially T02/T04/T05/T07/T09/T10.

### 4.4 Surge Constraints and Species Access

A Surge may have **at most one authored twist**: one extra rule, readable in the preview, with its advantage priced under §4.2/§4.7. A twist is represented by placement, area, execution, effect or residue data and explicit profile constraints, not a second schema or a universal menu of named powers. Existing battle rules remain authoritative (gdd_battle §5.3–5.4); old damage/range candidates grant no new exceptions or upgrade permissions.

Preserve the existing structural restrictions when authoring or upgrading a constrained Surge:

| Authored constraint | Validation |
|---------------------|------------|
| Adjacent anchor | Anchor stays adjacent; an existing 4-cell footprint has no Size path. |
| Straight trail from an adjacent cell | Footprint starts adjacent and stays straight; only legal I2/I3 families/orientations. |
| Four cardinal neighbours of the caster | Excludes the caster cell; no Shape or Size path. This special footprint is not generic ranged targeting. |
| Enlarged footprint | Result stays within its profile/Kin cell cap; do not charge the same enlargement twice. AP consequences follow §4.7, not an automatic surcharge. |
| Pull after damage | Existing one-square cardinal displacement toward an anchor fixed at cast; gdd_battle §6.5. |

**Species Surge:** every species has one Surge with its own species twist. It belongs to the default kit and learnable list, but remains an optional normal slot skill (§4.1). Shape/Size upgrades must preserve its constraints; no Twist replacement path is offered. Species ownership is access/authorship data on the same definition, not a new mechanical kind. Concrete species twists and roster placeholders still need design/validation (T10–T12).

### 4.5 Skill Schema

**Technical documentation template, not an implementation change.** This is the single data model for §4.2, including species-specific skills and upgraded variants. Field names illustrate responsibilities rather than prescribe engine serialization. Referenced effect definitions supply their existing mechanics and caps; they are not a parallel zone schema.

**Construction walkthrough — simple slowing zone (draft, not approved content).** This minimal example replaces the unresolved Ash Snare schema example: no ignition or other secondary effect. Proposed baseline: 1 AP, a fixed horizontal I3 footprint, 2 rounds and `slow` base 1/cap 2. Area and AP are calibration proposals, not approved balance values. The centred three-cell footprint makes the anchor explicit without a two-cell midpoint ambiguity.

The skill selects a board tile within effective Reach (Manhattan distance to anchor), without LOS. The anchor and its two horizontal neighbours must all be on-board; no clipping or rotation. Existing zone placement permits props and existing zones, subject to zone replacement/opposition rules. It affects ground-layer monsters of either side, including its caster, while they occupy the cells; it does not affect air, props, height or ground state.

On placement the slow modifier applies immediately to occupants, without damage or an entry payload. Leaving/removing the zone ends it. At zone level I, Movement is reduced by 1, minimum 1; Step is unchanged. Existing same-zone levelling may increase the value to its cap of 2 (`min(2, 1 + level - 1)`); this is battle-zone level, not slot rank. The shared zone clock decrements at each round end and removes the zone at 0. Thus 2 rounds does not guarantee two full personal turns for every monster.



```yaml
metadata:
  id: slowing_zone_example
  name: Slowing Zone (draft)
  kind: zone
  rule_profile: zone

  tags: [control]
execution:
  timing: immediate
  resolution: cast_resolution
targeting:
  type: tile                         # selection, not effect recipients
  eligibility: existing_zone_target_rule
  distance_source: caster_reach      # Manhattan to the anchor
  line_of_sight: existing_zone_rule  # no LOS under gdd_battle §5.7
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
    recipients: all_occupants        # self, allies and enemies; existing layer rules
    recipient_evaluation: while_inside
    application: while_inside
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
  affects_ground: false             # no ground change specified by this zone
  affects_air: false
  blocked_by_objects: false
  blocked_by_height: false
usage:
  ap_cost: 1
  limits: existing_zone_limits
upgrades: []                        # only explicitly authored field patches
```

**Walkthrough checks:** anchor (3,3) produces cells (2,3), (3,3), (4,3); anchor (0,3) is invalid because (-1,3) is off-board. A ground-layer occupant with Movement 3 has effective Movement 2 in the level-I zone, returns to 3 on exit and still uses Step normally. An ally is affected identically. A prop is not slowed; an air-layer monster is not a recipient. Creating the zone does not change the underlying ground. These are paper checks, not executed engine tests. General 2×2 cases and unrelated rule gaps remain open.

The area is a single authored footprint, not a choice of shapes at cast. Referenced placement, effect and lifetime rules resolve to §4.2 and gdd_battle §4.4–4.6/§5.3/§5.7; references are documentation contracts, not invented engine identifiers. `affects_ground` retains the legacy interaction flag name; actual ground changes must be explicit `board_changes` entries. The old flat blueprint layout is superseded; behaviour, targeting, direction, duration and usage belong to the dimensions above. Surge twists and species-twist ownership are authored profile constraints/metadata on this same model.

**Two further reference designs — draft calibration records, not balance approval.** Together with Slowing Zone above these are three references, not a new skill catalogue. The compact records below use exactly the same top-level schema; all fields are explicit or bound to the named existing contracts in §4.2/§3.2. They introduce no runtime identifiers. Coordinates are `[dx, dy]`; examples use 1×1 bodies only. References do not resolve the open large-body rules.

| Schema field | Jab reference (draft record of existing Strike) | Delayed Burst reference (draft Minor Surge) |
|---|---|---|
| `metadata` | `id: jab_reference`; `name: Jab`; `kind: strike`; `rule_profile: strike`; `tags: [reference]`; Kin binding: caster's §3.2 twist, never independently selectable | `id: delayed_burst_reference`; `name: Delayed Burst (draft)`; `kind: surge`; `rule_profile: minor_surge_residue_free`; `tags: [reference]`; no species twist; ordinary Kin/access limits |
| `execution` | `timing: immediate`; `resolution: cast_resolution` | `timing: telegraphed_delayed`; `resolution: caster_next_turn_start_before_start_effects`; marker/charging under §4.2; autonomous after displacement or death, using the dead caster's due queue slot |
| `targeting` | `type: self`; `eligibility: caster`; `distance_source: body_footprint_not_reach`; `line_of_sight: not_required` | `type: tile`; any legal board anchor; `distance_source: caster_reach` (Manhattan to anchor); `line_of_sight: not_required` |
| `placement` | `anchor: caster_body`; `binding: immediate_body_relative`; `direction_selection: one_of_eight`; existing §3.2 body placement, caster excluded | `anchor: selected_tile`; `binding: fixed_board_cells_at_cast`; `direction_selection: none`; props permitted, no overlap with a charging Surge; existing Surge placement |
| `area` | `shape: Jab`; `offsets: [d]`, where selected `d` is exactly one of `(−1,−1), (0,−1), (1,−1), (−1,0), (1,0), (−1,1), (0,1), (1,1)`; `cell_count: 1`; orientation = selected direction; `orientation_policy: strike_direction_selection`; `boundary_rule: all_cells_on_board`; solid-prop blocking under §3.2 | `shape: I3`; `offsets: [[-1,0],[0,0],[1,0]]`; `cell_count: 3`; `orientation: horizontal`; `orientation_policy: fixed_board`; `boundary_rule: all_cells_on_board`; no clipping/rotation; props do not block placement; damage hits Elevated as Eruption, without collapse |
| `effects` | `damage`: §3.2 Strike, fixed 2 against monsters/props except Swarm prop damage 4; recipients = all struck monsters including allies, excluding caster, and struck props; evaluate/apply once at cast resolution. Kin effect remains the caster's exact §3.2 binding, including its existing recipients, ordering and lifetime; Beast has none. No new Kin effect | `damage`: fixed 3 against all ground-layer monsters in the footprint at resolution, including caster/allies/enemies; no air. Existing ordinary Surge prop handling: 2 to prop instead of occupant; shield/Hallowed reduction, minimum 0. Apply once at detonation; no push, pull, ignition or brittle-prop extra reaction; no repeat payload |
| `persistence` | `type: none` for action; any Kin effect lifetime is exactly §3.2 (e.g. Siphon next round), not a zone clock | `type: until_resolution`; `owner: pending_surge`; expires at detonation; no post-resolution effect lifetime |
| `board_changes` | No optional ground payload; Ancient's bound Elevated → Rubble and damage-derived prop reactions remain exactly §3.2/§4.2, not selectable upgrades | `[]`: no authored ground placement, residue or height change; ordinary damage-derived prop destruction/shatter/debris remains §4.2, not an added residue component |
| `interactions` | `affects_ground: false` except bound Ancient board operation; `affects_air: true`; `blocked_by_objects: true` (solid-prop line rule); `blocked_by_height: false`; existing Strike recipient/prop rules | `affects_ground: false`; `affects_air: false`; `blocked_by_objects: false` for placement (prop intercepts damage); `blocked_by_height: false`; no ground reset, including Hallowed consumption without residue |
| `usage` | `ap_cost: 2`; existing AP repetition, no charging limit | `ap_cost: 1` proposed; one charging Surge per caster, existing AP spending/repetition rules; no cooldown/mana |
| `upgrades` | Only the candidate patches below; none approved | Only the candidate patches below; none approved |

**Paper checks:** Jab with `d = (1,0)` from (3,3) hits only (4,3), for 2 monster damage plus the bound Kin effect, even if occupied by an ally; it is not a Reach cast. Burst at (3,3) marks (2,3), (3,3), (4,3), then evaluates occupants only at the caster's next turn start. Leaving avoids the hit; caster death does not cancel it. Air is unaffected; surviving ground beneath the cells is unchanged, so Hallowed is not consumed by an invented residue step. Leaving, protection and air are at least three live counters. These are documentation checks, not executed tests.

**Upgrade candidate choices — all DRAFT, not balance approval or unlocks.** Patches use the same schema and must pass §4.7. Each offer is an alternative, not automatically cumulative; no rank/EP values, damage increases, AP reductions or cast-range upgrades are assigned.

| Reference | Same-AP candidate choice | Optional higher-AP candidate choice |
|---|---|---|
| Slowing Zone | At 1 AP: choose fixed vertical I3 (`offsets: [[0,-1],[0,0],[0,1]]`, orientation vertical), or `persistence.duration: 3` (the +1 total cap); other fields unchanged | At proposed 2 AP: choose fixed T4 (`offsets: [[-1,0],[0,0],[1,0],[0,1]]`, centre junction anchor, count 4), keeping duration 2 and the same slow formula |
| Jab | A meaningful 2-AP Kin-preserving development offer still needs an explicit design under T02/T05. No lawful larger shape exists at this price in §3.2; selecting a direction is baseline use, not an upgrade. This reference does not claim a completed same-AP path | Existing Thrust at 3 AP: `shape: Thrust`, offsets `[d, 2d]` for selected cardinal `d`, count 2, solid-prop blocking unchanged; damage 2 and the bound Kin effect unchanged. Optional branch, never required |
| Delayed Burst | At proposed 1 AP: choose fixed L3 (`offsets: [[0,-1],[0,0],[1,0]]`, junction anchor, count 3); other fields unchanged | At proposed 2 AP: choose fixed T4 with the offsets/anchor above, count 4; damage 3, delay, recipients and `board_changes: []` unchanged. This is not Major Surge access; Swarm cannot use either 3/4-cell reference |

**Open follow-through:** T02/T05 must calibrate component prices, residue surcharges and these candidate budgets and complete the Jab same-AP path before content approval. Companion battle wording that makes residue universal must be reconciled with this chapter's confirmed optional-component rule; no companion file is changed here. T04/T09 still own event-order/large-body gaps and dead-caster queue details. Existing Eruption/Flood/Rift damage, timing and residue profiles are not replaced by the residue-free reference.

Resolve every referenced definition and its required parameters before validation (§4.2–§4.3). Fixed fields cannot be contradicted by skill overrides; effect/operation order comes from the rules, never YAML list position. Unsupported cases remain central TODO, not default mechanics.

An upgrade is an **authorized patch to named fields of this definition**, with prerequisites, exclusions and budget/AP consequences (§4.7), not a second skill schema. Validate the resolved definition after applying patches: rule profile, Kin/species access, execution, placement, footprint, effect/trigger legality, persistence, interactions, usage limits and budget must still agree. Unspecified behaviour is not permission to invent a default mechanic. No cooldowns, mana, aspect or attunement; no damage upgrades, AP reductions or cast-range upgrades.

### 4.6 Species-Specific and Signature Access

Species exclusivity describes authorship and learn-list access, **not a `unique` mechanical kind, perk category or second construction system**. A species-specific skill uses the same §4.5 schema, a normal legal slot, its actual mechanical profile, existing interaction rules and an explicitly validated AP cost (§4.2). A species-specific zone or Surge keeps that profile's constraints; ownership is not an effect permission. Legacy `Unique` labels in companion documents must be mapped to concrete profiles/definitions before implementation, not kept as a catch-all profile.

Signature access remains Legendary/progression-bound (§7.2/§7.4); its concrete slot treatment and effect definition are not established by that unlock. Major Surge retains Ancient access at Sovereign, 2 AP and once per battle. Battle's older “Ancient / Legendary Signature” wording versus Ancient-only access elsewhere remains an explicit T02/T32 conflict, not permission for every Legendary to learn a Major Surge. No new access or values are decided here.

A new effect requires an explicitly authored, validated definition; species exclusivity does not authorize arbitrary boosts, damage, healing, board removal or targeting. Upgrades use the same authorized field patches (§4.7), with no separate evolution count. Unresolved content belongs to central T02/T10–T12/T32, not a parallel catalogue here.

### 4.7 Permanent Slot Development, Replacement and Upgrades

**Confirmed model: permanent slot development.** Skill-slot upgrades are an additional evolution option alongside physical monster evolution. Both spend the individual monster's shared **evolution points (EP)**; no separate player-facing skill-point currency is introduced. Construction/blueprint points are internal authoring data, not an intermediate spendable player budget and not the overworld Blueprint items.

- EP develop a specific slot of a specific monster, not the equipped skill or the species globally. Each purchased development step directly grants a skill-specific upgrade choice.
- Designers author finished skills and their upgrade choices using the component model (§4.2–§4.5) as an internal budgeting and AP-pricing tool. Players choose from those authored options rather than assembling arbitrary components.
- The equipped skill determines legal upgrades, prerequisites and mutually exclusive paths. The slot's development determines how much development is available; it does not grant every upgrade simultaneously.
- Replacing a skill preserves all purchased slot development. The player selects legal upgrades for the replacement skill using that existing development; old effects do not carry over literally.
- Replacement is outside expeditions, requires a skill from the unlocked species learnable list and consumes a valuable **relearning pill**. Selecting the replacement's upgrades is part of that replacement, not a second EP purchase. Exact pill acquisition, recipe, tier, price and overworld AP cost remain open (T05/T16/T31).
- Slot ranks, if used, are derived milestones of slot development, not separately purchased ranks. Rank count, thresholds, intermediate steps, EP prices and total EP supply remain undecided; the old supply must be reviewed alongside physical evolution costs.
- Whether reselecting upgrades without replacing the skill also consumes a pill is **not yet decided**. Passive-only slots and active/passive replacement need explicit rules before implementation.

**Confirmed construction budget and AP policy**

The former per-skill prices (1 EP for Shape/Twist/Value/Swap, 2 EP for Size) are superseded, not slot-development prices. Legacy “Shape always free”, blanket “Twist = 2 AP”, “Size adds 1 AP”, Twist-plus-Size totals and double-charging an already enlarged footprint remain T02/T05 reconciliation work; none overrides the confirmed policy below.

- Allowed construction budget = the AP class's base budget + the slot-development allowance. Exact values and thresholds remain open (temp_todo T02/T05).
- Slot development permits bounded increases in effectiveness at the same AP cost. Every skill must offer a complete development path at its original AP cost.
- Larger extensions may optionally increase AP cost; the increase is explicitly shown before selection. Higher AP cost is never a mandatory consequence of developing the slot.
- Upgrades are explicitly authorized field patches on the same skill definition (§4.5), never a parallel model. Authored upgrades may improve area, shape/orientation, duration, movement/displacement or add an explicitly designed secondary effect, subject to skill-specific limits and prerequisites.
- Slot upgrades do **not** increase direct damage, reduce AP costs or increase cast range. Existing Strike, Surge and ground damage limits remain in force. More affected cells or longer duration may increase total impact, so these still require budgeting and validation.
- Budget is a design guideline, not permission to bypass hard caps or legal-combination constraints. Legacy blanket AP surcharges require reconciliation with this policy, not automatic application to every upgrade.

Cast range is not an improvement path. The following families and validation constraints are the **existing candidate upgrade catalogue**, not finalized slot-step prices or a confirmed rank structure. Old per-skill evolution counts are superseded by the slot model; concrete offers and AP effects are reviewed under temp_todo T02/T05.

|           Family           |                                       What changes                                      |                                                                                         Rules                                                                                         |
|----------------------------|-----------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Shape**                  | other shape family or orientation, **same cell count**                                  | same cell count; shapes stay fixed in battle. Legacy ‘always free’ does not establish free EP development or free respec; costs remain T05                                                                                                                                              |
| **Size** | **+1 cell** within the owning profile's cap | ordinary tetris max 4; Swarm Surge cannot enlarge; Strike uses §3.2. Slot-development requirement, EP price and optional AP effects remain T02/T05 |
| **Twist** *(Surge only)* | Replace/add an authored extra rule; not on a Species Surge | At most one; validate the patched definition and constraints (§4.4–§4.5) under the confirmed AP policy                                                                                                                  |
| **Small value**            | `duration` +1 round (zones) · or, for Movement, **one flag flip**: turn one restriction of the mode off, or lower its distance penalty by 1 (once per skill, gdd_battle §5.5) | tiny, capped; **never raises Surge or ground damage**. No level-II start (that is the Overgrowth passive's job and would make a Veil shield 3 in one cast) |
| **Replacement (not an upgrade)** | replace the equipped skill using a relearning pill | preserves slot development; species list and Kin restrictions still apply; no EP-priced Swap path |

Concrete upgrade offers are authorized patches to §4.5, not a second per-kind schema. Species-specific and Signature skills use the same process (§4.6); replacement is never an upgrade patch. Legacy named upgrade examples and their evolution counts are retired pending T02/T05/T10.

- Same species + different evolution picks = different playstyles → collection depth without new art
- An evolved shaped skill retains **one authored shape and fixed orientation**, with only existing rotation exceptions; a Surge has **at most one twist**, not a mandatory twist. Non-area skills do not acquire a footprint by evolving. All battle rules stay valid; the preview shows the resolved variant like any other
- Slot development is a separate deliberate action at the **Evolution Pillar**, paid with shared **EP**; it is not focused-XP Train and not an automatic breakthrough reward. Its day-AP cost remains open (gdd_overworld §2.3–§2.6/§6.3.2; T05/T31). EP awards are listed, still unvalidated for the shared pool, in §7.2/§7.4. Reversing EP investments and reselecting existing upgrades are separate unresolved rules (temp_todo T05); no free reset or transfer of EP between slots is implied.

**Validation rules.** The following legacy constraints retain their placement/shape limits, but old automatic AP surcharges require the confirmed policy above; Twist offers must also exclude damage/range increases (including legacy delayed-damage or extended-range candidates). An evolved skill must pass the same checks as any skill (§4.5). The evolution screen only offers the paths that pass:

|            Situation            |                                         Rule                                         |
|---------------------------------|--------------------------------------------------------------------------------------|
| Shape → new family             | same cell count (I2↔I2, I3↔L3, any 4-cell family); the family must be legal for the skill's twist and the monster's Kin |
| Constrained Surge | Preserve the authored adjacency, straight-line, neighbour-ring and enlargement restrictions in §4.4; no Shape/Size path may break them. |
| **Swarm Surge**                 | Swarm has 2-cell shapes only (§3.1): Shape only changes the I2 orientation; enlargement is not offered |
| **Strike**                      | Shape swaps between Strike shapes of the same size (Whirl ↔ Cross), Size picks a bigger one. The selected larger Strike uses its existing shape price (§3.2); this is an optional higher-cost branch, not the only development path |
| **Species Surge**               | no Twist path (§4.4)                                                                 |
| **Size** on any skill           | +1 cell within the profile cap; ordinary tetris cap 4, Swarm Surge cap 2; Strike uses §3.2, not a universal 4-cell cap. The old automatic Surge +1 AP is unconfirmed under the AP policy; preserve §4.4 constraints |
| **Twist** path | At most one authored twist; preserve §4.4 placement/footprint constraints and exclude damage/range increases. |
| **Value** path                  | `duration` +1 round total per skill; Movement: one flag flip total per skill         |
| Skill replacement (no Swap upgrade path) | unlocked species learnable list and Kin lock-outs (§3.1); pill-based replacement preserves development |
| Large (2x2) monsters | no new evolution exception; unresolved spatial/runtime rules in §4.2 still block unsupported offers (T09). Air remains Winged/Soul access, not an upgrade |

---

## 5. Passives

Passives are **always on** and take a kit slot like an active skill (§4.1). Availability depends on the species' own learnable list and the individual (Epic+ extra slot, artifacts), within Kin and progression restrictions; never on a theme or aspect. A kit of 1 active + 3 passives is legal but weak.

**Content status:** the named entries below are retained prior-draft candidates, not an approved perk catalogue or exceptions to Chapter 4. Their effects, access and interaction contracts need T02/T04/T11 validation; in particular Momentum's damage bonus, AP-discount passives, Crashlander's collision wording and automatic movement/target selection remain unresolved. Do not use these ideas to authorize damage upgrades, AP-reducing slot upgrades, new collision rules or unspecified tie-breaks.

**Terrain Identity:** Adaptive (may rotate its skill shapes in battle) · Purifier (adjacent enemy zones lose 1 round at round end) · Overgrowth (your zones start at level II). **TODO:** redesign or retire Native Ground, Painter, Trailblazer and Deep Roots without own-aspect squares, attunement bonuses or abstract repainting. Any retained ground interaction must name concrete ground/effects; no replacement mechanics or balance values are decided here.

**Position & Movement:** Highlander (+2 init on Elevated) · Turret (can't move, +1 Reach) · Skittish (free 1-square move after taking Surge damage — to the safest free neighbour) · Phasing (moves through props) · Momentum (after a max-distance move, the next Surge this turn deals +1)

**Displacement:** Crashlander (when pushed or pulled into a prop or monster, it takes no collision damage — the other side takes 1) · Immovable (ignores push/pull) · Counterweight (allies orthogonally adjacent to it can't be pushed or pulled)

**Combat:** Thick Hide (Strikes and collisions deal 1 less, min 0) · Pack Hunter (Strike costs 1 AP less if an ally is adjacent to the target) · First Blood (its first Strike each battle costs 1 AP less) · Vengeful (after taking Surge damage, its next Strike costs 1 AP less) · Scavenger (heals 1 when a prop within its Reach shatters) · Frenzy (+1 shape cell at 1–2 HP) · Bulwark (team: allies orthogonally adjacent to it take 1 less Surge damage)

**Ground & Zone Resistance:** Sure-footed (ignores `slow`) · Clear Mind (ignores `drain_*`) · Heatproof (ignores Lava) · Thornwalker (ignores Thornbed) · Void-touched (ignores Blight) — the unit-level way of shrugging a specific effect.

---

## 6. Roster

### 6.1 First Roster Draft — 9 monsters

**Non-authoritative content ideas:** this roster is not a skill/access/cost specification. Its names, old twists, passives, descriptions and overfilled loadouts grant no exception to Chapter 4; retain them for later validation, not implementation or redesign here.

The stat shape is a property of the **individual monster** (§1.1); the shapes below are the **reference individuals** — the typical roll of each species. Numbers are **Core Formation High** values: each one spends exactly the 16-point budget inside its frame (caps: HP 8, Init 9, TPR 2, Move 5, Reach 3, AP 3 — §2.2–2.3). The default kit is **movement skill (§3.3) + Kin Strike (§3.2) + Surge + Utility** = 4 slots, plus the passive in the table. *Under the 4-slot rule of v6.2 the passive takes a slot of its own; this table preserves the earlier reference loadouts, not finalized legal kits.* the Forge Golem moves by Step only and takes a second utility instead. Named skills and twists below are unvalidated prior-draft content ideas, not a blueprint catalogue or approved damage/range exceptions. Rebuild them with §4.2–§4.5; species access follows §4.4/§4.6.

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
- **Moss Turtle** — a slow, heavy Flood that hits one turn later but harder, behind Bark Veils, and has a terrain passive awaiting redesign (Deep Roots, TODO §5).
- **Thorn Mites** — weak little Floods that leave level II thorns, on top of a Thornbed they walk through unharmed.
- **Grove Wisp** — throws weak Floods from far away, phases through props, and is the only one that can turn its shapes in battle.
- **Gloom Wolf** — the baseline: Mire flips the turn order, its Rift does the rest; much stronger with an ally next to the target.
- **Dusk Moth** — a wide Rift under a Shade Veil; Native Ground awaits redesign (TODO §5).
- **Hollow Serpent** — pulls you in with Void Pull, then its Rift drags everything it hits toward the centre.

Other kits the 4 slots allow (not in the first roster): four Surges, moving by Step only, a stationary battery · Leap + Strike + Shove + a Veil, a mobile fighter without a Surge · Run + Surge + Surge + Veil, a caster with one answer.

Coverage gaps in this reference roster: Raise Ground (except Forge Golem), Sanctify, Shove, Blink. TODO: review kit and effect coverage through species learnable lists, not Kin × aspect quotas.

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

**TODO:** decide launch roster scope, distinct kits, species twists and species learnable lists. No replacement roster quota is set here.

---

## 7. Growth

### 7.1 Skill Development Reference

Permanent skill-slot development, shared EP spending, pill-based replacement, upgrade patches and AP policy are defined exclusively in **§4.7**, with costing and the shared schema in §4.2/§4.5. The rarity and progression tables below retain their existing working values; they do not set new slot ranks, prices or validated EP awards.

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
- **High mechanics are Rare+ territory by design:** Air layer and 2x2 need Soul, TPR 3 needs Soul, the Ancient's Major Surge needs Sovereign. A Normal monster (max Core) stays grounded, single-turn-count and simple
- Rarity does **not** decide the stat shape: any rarity can roll any shape (weighted by Kin lean, §1.1)
- Shared EP spending, superseded per-skill prices and replacement rules: §4.7. This table supplies only rarity/progression working data, not slot-development prices.
- Offered counts and EP income in the table are legacy working values, not a validated budget for the shared system.

### 7.3 Rarity Ascension

- A **major event**, not a grind: rare material + ritual (bloodline awakening), story-flavored
- **Ingredients:** one **Bloodline pill** (gdd_overworld §6.6) made of a Rare+ beast part of the monster's Kin and a herb of the next tier, plus a ritual (TODO: define the ritual location without Aspect Altars). The materials can come from many sources (gdd_overworld §7.8), but the part with the grade of the new rarity only from dungeon bosses, quests, the clan leader or the auction: money is only a partial input (gdd_overworld §7.7)
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
- **Learnable skills:** the species list grows with the stages (4 defaults + 1 per breakthrough from Foundation to Immortal = 8). Kit access and replacement/development rules: §4.1/§4.7
- **Why not points at Immortal / Sovereign:** the stat ceilings and the damage law are reached; more points would only be number inflation (pillar 1)

**XP (proposal, prototype: Lower 60, Middle 120, High 200).** The bars above grow about ×2.5 per stage. A **cultivation pill** is worth about half a Lower bar of its tier (Qi +30 as in the prototype, Foundation +80, Core +200, Soul +500, Immortal +1200); a **win** gives 10 XP at Qi Gathering and ×2.5 per stage; a night on a cultivation spot gives a little (Meditation Stone ≈ one tenth of a win, Qi Spring double). Rule of thumb: a sub-tier is 3–6 days of focused play at the right stage.

Breakthrough trials: gdd_overworld §6.3.1.

---

## 8. Design Tracking

Open decisions, dependencies and validation tasks are maintained centrally in [temp_todo.md](temp_todo.md). Effect definitions and caps are tracked under T02/T05/T07; collision conflicts, displacement/board-operation ordering and tie-breaks under T04. Healing repetition/scaling and zone × ground rules remain T07; Water/Swim T08; flight, air occupancy and 2×2 interactions T09; planned medicines/arrays and loadout timing T18/T19; tamer-source exceptions T20. These are references to central decisions, not a parallel tracking list. The following contextual notes refer to that central work:
- Finalize species learnable lists, legal default kits, species twists and roster scope without aspect quotas.
- Redesign or retire the former aspect-dependent passives (§5); their roster entries remain placeholders, not active aspect mechanics.
- Review ritual ingredients and rarity-ascension locations without aspect materials or Aspect Altars (§4.7, §7.3).
- Specify concrete ground/zone interactions and any additional Surge behaviours where still open, without a triangle, attunement or replacement element taxonomy. Existing concrete ground and effect examples remain; no new interaction or balance values are decided here.
- Reconcile references in gdd_battle.md, gdd_overworld.md and the central TODO separately. References from this file do not reinstate obsolete aspect rules.

The confirmed removal of fixed monster aspects, the Force/Nature/Dark triangle and attunement overrides older proposals. Other proposals remain working design pending review.

---

## 9. Changelog

**Effect catalogue revision.** Removed the legacy blueprint/default table and redundant AP summary. Specified constrained `damage`, `displacement` and `stat_change` contracts and aligned the shared schema. Preserved concrete skills, twist/upgrade rules and historical entries below; unresolved ordering, caps and prior-draft exceptions remain open, not new permissions.

**Data-oriented skill construction revision.** Replaced the closed blueprint list and flat schema with one component model, binding rule profiles and authorized upgrade patches. Preserved concrete skill and twist/evolution examples as unvalidated prior drafts; the intermediate legacy-default table was subsequently removed. Base prices plus combination rules remain confirmed; concrete prices and allowances remain open. No new gameplay combinations or code changes are authorized.

**Aspect-free design revision.** Replaced fixed monster aspects with free descriptive themes. Species learnable lists govern skill access; concrete skills define Surge behaviour, ground and effects. Kept the blueprint construction kit without mandatory three-way variants. Removed aspect-based rarity/progression and roster requirements; marked dependent passive and ritual design as TODO without replacement balance decisions.

**v1.0 — New file (gdd_battle v6.3, gdd_overworld v0.12).** All monster definitions moved here from gdd_battle §3 / §5 and gdd_overworld §5 / §6.3.1, so nothing is defined twice. The archetype table and the skill catalog became one historical **blueprint table** without skill names (since removed; current effect catalogue: §4.2), with kinds, tags (formerly categories / roles) and the flags `affects_ground`, `affects_air`, `blocked_by_objects`, `blocked_by_height`. Skills get a `duration` value that can be upgraded (§7.1). New **Boon** zones and **Blessing** ground for allies (§4.3). Movement modes of other Kins open at Soul Tier (§3.3). The twist Lingering became **Deep Residue** because ground is permanent now (§4.4).Skill kinds: `height` merged into `ground`, new `move`. Strike is a shape around the body, priced in AP (§3.2). Reach is the cast range of all skills and moved to 2–4 without changing any point total; skills have no `range` value and the Value path lost cast range (§2.2, §7.1). First cost table for the blueprints (historical; since removed in favour of gdd_battle §2.3). Every species gets a **Species Surge** with a twist of its own (§4.4).
