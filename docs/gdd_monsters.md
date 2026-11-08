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

- **Stat shape is individual, not species-wide.** Two Blaze Tigers can be a fast skirmisher and a hard-hitting berserker: same Surge, different playstyle, collection depth without new art.
- Wild/newly caught monsters roll shapes weighted by **Kin lean** (§3.1: Winged → glass cannon, Ancient → anvil, …); rare off-lean rolls are prized finds. §6.1 shows reference individuals: typical Core Formation rolls.
- **Every stat is paid for** (§2.2). Shape allocates a fixed budget: speed costs HP; slow shapes recover HP and Reach. No shape is strictly better.

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

- **No fixed roles:** Kin is not class (Beast ≠ "damage dealer"); kits determine team function, so two Beasts can play completely differently.
- Build teams from *combinations*: one monster pulls, another Strikes; one floods enemies into another's Eruption.

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

**Every stat is paid for:** monsters at the same stage/sub-tier share a budget, allocated by shape (§2.2). Acting first, possibly several times consecutively, costs HP or Reach; poor turn order buys HP, Reach or AP.

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
- TPR 2+ frames (Glass cannon, Berserker, Fragile) cap AP at 2. Progressive action-source prices would also consume most of a TPR-2 body's budget at AP 3+. AP additionally unlocks larger Strike shapes (§3.2).

**Budget per stage and sub-tier** (points above the 15 base points; absolute total in brackets):

|        Stage        |  Lower  |  Middle |   High  |
|---------------------|---------|---------|---------|
| Qi Gathering        | 4 (19)  | 5 (20)  | 6 (21)  |
| Foundation          | 10 (25) | 11 (26) | 12 (27) |
| Core Formation      | 14 (29) | 15 (30) | 16 (31) |
| Soul Tier and above | 18 (33) | 19 (34) | 20 (35) |

So a sub-tier up gives **+1 stat point**, a breakthrough **+2** (**+4 into Foundation**, because TPR 2 opens there). Immortal and Sovereign add no points: the absolute scale is reached, those sub-tiers give evolution points instead (§7.4).

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

- **Unspent points:** Qi Anvil (max 19 vs. budgets 19 / 20 / 21) leaves 1 at Middle, 2 at High; Foundation High Anvil/Skirmisher (max 26 vs. 27) leave 1. The player spends roll leftovers freely: no lost points or frame changes.
- The table excludes Berserker's TPR 3 at Soul.

- **Init at roll:** 1 point = **1.0 Init**; speed costs other stats. A free decimal (.0–.9) is rolled on top, below the frame maximum.
- **Init at level-up:** 1 point = **+0.1 Init**; fine-tune the queue without replacing shape identity. Budget counts points received, equally for every monster regardless of purchases.

Example, a Glass cannon at Core High (16 points above base): HP 2 (1) + Init 9 (8) + Move 3 (2) + TPR 2 (5) = 16.

- **Stage scaling:** multiply HP/Init/Movement/Reach frame limits by *stage ceiling ÷ Core ceiling* (§2.3), round, minimum 1; Reach uses `1 + (Reach − 1) × ratio`. Cut TPR/AP limits to the ceiling; only Berserker's TPR frame grows, to 3 at Soul.
- **Stat restriction, not roll restriction:** AP 4 (Immortal)/5 (Sovereign) require TPR 1. TPR 2+ caps AP at 3; AP 4+ prevents raising TPR.
- **Frame applies only at roll:** new/wild individuals draw within it until their stage/sub-tier budget is spent. Two Anvils start differently, never stronger overall. Each later level-up adds points for free player allocation (free action), limited only by stage ceilings (§2.3); save ceiling-blocked points for the next breakthrough.
- **Reshape:** pool all points and reroll within the new frame at the same budget; leftovers remain unspent. Level-up spending alone never changes the shape label. Item, ritual location and day-AP: [Overworld §2.6](gdd_overworld.md#26-action-catalog).
- **Ceiling rule:** monsters cannot exceed the player's stage: the spatial space sustains only what the tamer's qi can feed. §7.4 instead specifies the exact step; this scope conflict remains [temp_todo.md](temp_todo.md) T03, not a decided sub-tier cap.
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

Soul+ is split for AP only: **Soul 3 · Immortal 4 · Sovereign 5**, and AP 4–5 need TPR 1 (§2.2).

- **Lifetime scale:** HP 1–10, Init 0.1–10.0, TPR 1–3, AP 2–5 span the entire game; inflation would destroy its deterministic low-HP feel.
- **Damage never scales by stage** (gdd_battle §6.1): Surge base, Strike (max 2) and ground damage stay equal from Qi Gathering to Sovereign.

---

## 3. Kins

### 3.1 Kin Table

> **Kin = what kind of creature it is. Themes describe it freely, without assigning a mechanical type.**

- Kin sets **Strike, Surge size, stat lean, movement layer and utility access**, never damage multipliers. No Force/Nature/Dark weakness triangle, replacement element system or attunement.
- The **species learnable list** determines concrete skill access within Kin/progression restrictions.

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

**Strike shapes** (second version).
- A bigger shape costs more AP and is simply better; it never deals less damage.
- The player picks the direction when striking (8 directions, no facing). "Forward" means along that direction; a line is stopped by the first solid prop in it.

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

**Kin twists:** every Strike deals **2 damage per struck monster**, plus its bound Kin effect. Under confirmed policy, Kin advantages consume the shared construction budget (§4.5); Beast has none to price.
- §4.5 prices all Kins/existing shapes as unvalidated calibration drafts; full combination evaluation is pending. Existing effects and battle-AP prices remain unchanged.
- Table values are gameplay effects, **not construction points**.

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

- **Foreign movement:** from **Soul Tier**, learn **one other Kin's mode** unless body-forbidden; Ancient never gets Glide/Blink.
- Normal ends at Core, retaining only its Kin's modes: rarity = flexibility (§7.2).

Points in Movement only pay off with a movement skill; a Step-only monster stays at the frame's min.

---

## 4. Skills

- **Ownership:** this chapter owns kit/access (§4.1), shared model and spatial/temporal contracts (§4.2), execution profiles (§4.3), effect/board operations (§4.4), point/AP calculations (§4.5), slot development (§4.6), complete records/validation (§4.7). Kin content (§3), passive ideas (§5) and growth data (§7) do not create separate skill systems.
- **Boundary:** gdd_battle owns turns/events, board state, zone/ground/prop interactions and generic damage/displacement/collision resolution, not parallel skill execution rules. gdd_overworld owns tamer skills, loadout and meta logistics/economy; monster-skill budgets do not automatically apply there.
- Confirmed rules override legacy conflicts; open decisions remain in temp_todo.md.
- **Open rules:** a missing or unresolved rule grants no default, permission or implicit behaviour; content that depends on it stays blocked, and the T-references in this chapter name the owning task.

### 4.1 The Kit

```
Monster = Step (always, no slot)
        + 4 slots, each an active (movement skill, Strike (Kin), Surge, utility) or a passive,
          at least one active      — Epic+ get a 5th, passive-only slot (§7.2)
```

- **Slots:** all 4 open on day one; movement skills occupy a normal slot, unlike universal **Step** (1 square, 2 AP, slot-free). No skill kind is mandatory; repeats are legal (4 Surges, or two movement skills plus a Strike).
- **Limits:** species learnable list, Kin lock-outs (§3.1/§3.3), one charging Surge at a time (§4.3).
- **Default-kit tip:** pair a Surge with a *different effect family* of utility (protection, slowing or displacement), preserving an answer. Skills define zones/ground/effects; descriptive themes grant no bonuses or penalties. The prototype Tiger's 7 skills are a test bench, not a kit.

#### Species-Specific and Signature Access

- **Species exclusivity** means authorship/learn-list access, not a `unique` mechanical kind, perk category or construction system. Use the §4.7 schema, a normal legal slot, actual profile/constraints, existing interactions and explicitly validated usage/points (§4.5); ownership grants no effect permission.
- Map companion documents' legacy `Unique` labels to concrete profiles/definitions before implementation, never a catch-all profile.

- **Signature/Major access:** Signature remains Legendary/progression-bound (§7.2/§7.4), without a decided slot treatment or effect. Major Surge retains Ancient access at Sovereign, 2 AP, once per battle. Their legacy access ambiguity remains [temp_todo.md](temp_todo.md) T02/T32, not an active Battle rule or Major permission for every Legendary. No new access/values are decided here.

- **Effects/upgrades:** new effects need authored, validated definitions; exclusivity grants no arbitrary boosts, damage, healing, board removal or targeting. Use authorized field patches (§4.6), without a separate evolution count. Unresolved content stays central T02/T10–T12/T32, not a parallel catalogue.

### 4.2 Data-Oriented Skill Construction Kit

- **One model:** active actions, passives, self buffs, targeted utility, movement, Strikes, Surges, zones and species-exclusive/Signature skills share fields. No `unique` effect, opaque script hook or separate passive/buff schema bypasses construction/costing. Players select finished definitions/authored upgrades, not arbitrary components.
- **Representation ≠ approval:** self buffs/conditional passives need no structural exception, but their numbers, stacking, triggers, access and combinations still need approval. Existing profiles preserve rules; new content stays draft until its rules/cost are agreed. Genuinely new mechanics extend the shared vocabulary with explicit parameters, resolution, limits and costing, not skill-specific escape hatches.

#### Common Field Structure

Every resolved definition contains all groups below: `none`/`[]` where genuinely inapplicable; `pending` for unresolved drafts, blocking approval and never a runtime default. Names are documentation notation, not required engine serialization.

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

- **Profiles are reusable bundles, not a closed menu:** Strike supplies body-relative hits, Surge telegraphing/charging, Zone persistent board area, movement presets traversal. Fully defined self buffs/passives may use `rule_profile: none`, without bypassing damage delivery, access or hard limits.
- Evaluate resolved mechanics once; `kind`/`rule_profile` are not separately purchased advantages.

- **Recipients per effect:** resolve scope (self/selected unit/area occupants/event-bound), relationship, authorized `ground`/`air` layers and relevant prop eligibility. Effects may differ; no automatic ally-only filtering or air access. Self-bound modifiers affect their owner in its legal layer unless explicitly narrowed.

- **No redundant flags:** retired `affects_ground`/`affects_air` authoring inputs and historical/prototype names are not current schema. Ground changes belong only in `board_changes`, layers only in effect recipients; UI summaries such as “changes ground” are derived, not separately priced.

- **Events/lifetimes:** each effect names application event, state owner if any, lifetime reference/`none`, and stacking group plus stacking/refresh rule where reapplication is possible. States may have distinct lifetimes; each zone shares one clock. Persistent states specify termination/removal and recipient/condition reevaluation. Missing event/stacking/termination rules stay unresolved.
- **Bindings:** profiles §4.3, shared effects §4.4, evaluation §4.5, six structurally different checks §4.7. No aspect/attunement field, automatic new trigger or budget override.

**Spatial contracts — targeting, placement and recipients**

These are separate responsibilities, resolved against gdd_battle §4.3–4.11 and the central execution profiles (§4.3). References may supply fixed fields; an unresolved rule is not a configurable permission.

- **`targeting` — what is selected**
  - Required resolved data: Selection type (`self`, `unit`, `tile`, `prop`, `none`), eligible target definition including side/layer where applicable, distance source and LOS rule
  - Binding rules / open cases: `none` means no player selection, not no effect recipient; event bindings must be explicit.
    - `self` selects the caster; `unit` selects an eligible monster; `tile` selects a board cell, not its occupant; `prop` selects an eligible existing prop, not permission to create or relocate it.
    - Side eligibility must come from the source; no generic ally/enemy filter is granted.
- **`placement` — where it resolves**
  - Required resolved data: Binding from selection to board anchor or body footprint, required adjacency, occupancy/layer constraints and separately selected direction/pull anchor
  - Binding rules / open cases: Zone/ground/prop/Surge anchors use effective Reach, Manhattan distance from caster to anchor, not distance to every affected cell.
    - Strike uses its body shape without a ranged anchor; movement uses Movement ([§4.3](#43-skill-execution-profiles)).
    - Authored twist exceptions stay explicit.
- **Effect `recipients` — what receives an effect**
  - Required resolved data: Referenced recipient rule, spatial scope and evaluation event/application condition, including side, air/ground and prop eligibility
  - Binding rules / open cases: Selection does not restrict an area to the selected unit or its side.
    - Zones affect everyone occupying their cells; Strike hits allies but excludes its caster; Surge includes its caster and allies.
    - Ground affects ground-layer occupants; prop reactions and Surge prop/occupant handling use their own rules, not a generic occupant hit (gdd_battle §4.6–4.7 and §4.3 here).

- **LOS ≠ placement legality:** zone/ground/prop/Surge casts and self boosts need no LOS; existing direct unit-targeted displacement and species-specific effects on another monster need sight (§4.2). Reach, occupancy, layer and blocking checks still apply. Exact sight geometry/unspecified direct-target eligibility remain [temp_todo.md](temp_todo.md) T02/T04/T09.
- **Layer-specific occupancy:** per-cell layer limits, props under zones/Surges and ground-on-prop rules: [Battle §4.3](gdd_battle.md#43-the-square-stack-zones--ground). Skill-side additions: prop creation needs empty cells; charging Surges cannot overlap (§4.3 here). FIELD occupants/air occupancy remain T04/T09: no universal cross-layer `empty` test.
- **Fixed bindings:** board footprints stay at cast cells; push direction/pull anchor are fixed at cast (gdd_battle §4.4/§6.5; §4.2 here). Selecting a unit grants no homing area, following zone, moving pull anchor or automatic retarget after movement/death. Author unspecified unit-target resolution/validity (T02/T04); immediate body-relative Strike placement is no tracking precedent.

**Area contract — explicit footprint, not cast range**

- **Required area data:** shape/profile, distinct integer offsets from a declared anchor/body origin, matching `cell_count`, authored orientation/selection policy, boundary and blocking/placement references. Reusable footprints may own offsets; family names/unexplained orientation numbers cannot reconstruct cells. Non-area skills use `area: none`, without cell count/artificial footprint.
- **Anchor/caps:** [Footprints and Placement](#footprints-and-placement) lists tetris families/counts/orientations. Author the centre-most anchor's exact offset mapping; no runtime tie-break. Caps: [§4.5](#45-construction-points-and-ap-efficiency). Strike body footprints (§3.2) and Major Surge access/profile are not generic size overrides.
- **Orientation:** normal tetris skills have one family and one fixed absolute board orientation for both teams, not facing, team mirroring or default rotation. Only the owner-scoped [passive permission](#non-area-and-passive-coverage-references) allows in-battle rotation; Strike separately selects eight directions (§4.2–§4.3). Push direction is not rotation; missing mappings remain T02.
- **Boundaries:** all cells must be on-board (§4.2); no automatic trimming, shifting or rotation to fit. Keep profile-specific Strike solid-prop blocking, ground/prop occupancy and Elevated blanking separate (gdd_battle §4.3; §4.2–§4.3 here), not universal obstacle clipping/resizing. Forced-movement collision uses gdd_battle §6.3, not area placement.
- **Hits/2×2:** cells are not automatically distinct hits. Reach origin/target distance, body-relative origins, partial overlap, deduplication/damage multiplicity, mixed ground/height/layer occupancy, landing and displacement remain insufficiently defined (T04/T09). Infer neither per-cell/per-unit hits, partial placement nor collision defaults; preview/validation must expose unsupported cases.

**Temporal contract — execution, effect events and lifetime**

| Responsibility | Required resolved data | Existing binding rule |
|----------------|------------------------|-----------------------|
| `execution` | Immediate vs telegraphed delay, exact resolution event, charging/telegraph and autonomy rules where applicable | Immediate resolves the action now, not every effect now. Bind Surge execution to the [Surge profile](#surge) and its scheduling interface in [Battle §2.2](gdd_battle.md#22-initiative-rules); do not substitute a generic one-round delay. |
| Effect trigger/application | Referenced event, whose turn/entry it is, recipients at that event and ordering dependencies | Existing resolution, `start_of_turn`, `on_enter`, `while_inside`, Surge-damage protection and `end_of_turn` events remain definition-bound (gdd_battle §2.4/§4.6–4.7). `while_inside` is continuous, not a repeating cast. |
| `persistence` | Owner of the lifetime, clock/event, duration or consumption/removal condition, expiry result | Reference [Battle §4.5](gdd_battle.md#45-lifecycles) for board-state lifecycles and [Battle §4.10–§4.11](gdd_battle.md#410-damage-shatter--prop-types) for prop removal/reactions. Distinguish pending execution, any authored aftermath and self-bound states; effects of one zone share its clock. |

- **Runtime bindings:** use turn/round sequence [Battle §2.1](gdd_battle.md#21-core-battle-loop), event meanings/order [Battle §2.4](gdd_battle.md#24-effect-timing-reference), ground entry [Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed). Round duration does not count caster actions.
- **Repetition:** persistence adds no undefined payload/repeat trigger; action repetition follows [Battle §2.3](gdd_battle.md#23-action-points). Missing trigger/lifetime/timing contracts remain [temp_todo.md](temp_todo.md) T02/T04/T07/T09/T19.

#### Footprints and Placement

Existing tetris families/authoring orientations below follow the spatial/area contracts above for selection, anchor distance, occupancy, binding and boundaries. Step/non-area effects need no footprint; Strike uses [body shapes](#32-strike-by-kin).

|  Family | Cells | Orientations (incl. mirror) |
|---------|-------|-----------------------------|
| I2      |     2 |                           2 |
| I3      |     3 |                           2 |
| L3      |     3 |                           4 |
| O4      |     4 |                           1 |
| T4      |     4 |                           4 |
| S4 / Z4 |     4 |                           4 |
| L4 / J4 |     4 |                           8 |

- **Orientation counts** are authoring options, not battle choices; fixed orientation/passive rotation follow the area contract above. Outside-battle changes: [§4.6](#46-slot-levels-development-replacement-and-upgrades). Rotation shortcuts: `R` / right-click.
- **Preview:** colour squares **new / levels up / replaces / weakens / cancels / blocked**; list ground/prop reactions, displacement landings and Surge damage after reductions. Referenced Battle rules determine outcomes, not preview labels.

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

Reference the spatial contracts above through `targeting`/`placement` for LOS, selection and placement eligibility. Sight geometry/target-validity gaps remain [temp_todo.md](temp_todo.md) T02/T04/T09.

#### Reading a Complete Skill Definition

- **Read:** equip access → active/passive activation → selection/placement if any → effect recipients/event → lifetime/stacking → board operations → usage/points.
- Application need not equal activation: a cast zone may apply its modifier continuously after the action ends; an available passive may produce effects only at its declared event.
- All six §4.7 references resolve these groups; skills need not create an area, pending marker or status. Access/profile references/descriptive tags grant no effects or unpriced bonuses.

### 4.3 Skill Execution Profiles

Central monster-skill execution definitions; Battle chapter 5 links here. Generic board state, scheduling, mitigation and collisions remain in gdd_battle chapters 2, 4 and 6.

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

Profiles are reusable, not a closed menu. Direct buffs/passives use the common model without posing as Strike/Surge/Zone; passive activation needs no separate format, and species exclusivity is access data, not `unique` execution.

#### Strike

- **Immediate body shape:** starts adjacent to the monster, without anchor, range or Reach. Damage: [Battle §6.1](gdd_battle.md#61-the-damage-law); Swarm's existing 4-damage exception affects props, not monsters. Spend the selected shape's price (§3.2; costing §4.5); larger area never trades away damage.
- **Selection/hits:** no facing; choose one of 8 directions (§3.2 shapes/Kin effects). Hit every monster/prop in the shape, including allies, excluding the striker. Solid props take the hit and block cells behind them.

#### Surge

- **Surge:** telegraphed delayed execution, pending marker/timer, zone shapes/placement but its own slot/lifecycle.
- **Aftermath:** optional, explicit, separately budgeted `board_changes`, never implied by Surge alone. Damage precedes authored ground aftermath. No new prices here; legality/evaluation/validation: §4.4/§4.5/§4.7.

```
MINOR SURGE
  shape/placement: resolved authored footprint and constraints (§4.2/§4.3), checked under [central skill rules](#42-data-oriented-skill-construction-kit)
  range: effective Reach to anchor unless an explicitly approved baseline profile says otherwise
  charging: visible, blocks movement through its squares
  fires: at the START of the caster's next turn (simple alternating 1v1: after the opponent's turn)
         if the caster died, it fires when the caster's slot in the queue would have come up
  autonomous: not cancelled by displacing / killing the caster
  per-square result:
    monster  → authored value, reduced by zone shield and Hallowed (minimum 0 damage)
               (hits every monster on its squares — allies and the caster included)
    prop     → ordinary interception instead of its occupant (Battle §4.10); profile exceptions below
               select reactions resolved under Battle §4.10–§4.11
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

- Prop interception, ordinary prop damage and destruction are resolved by [Battle §4.10](gdd_battle.md#410-damage-shatter--prop-types); explicit reactions use [Battle §4.11](gdd_battle.md#411-prop-reactions).
- The profile table below selects those reactions; it does not redefine their runtime resolution.

- **Concrete profiles:** existing Surges specify **Eruption**, **Flood** or **Rift**, independent of theme. Their authored residue remains mandatory for those profiles despite the general model's optional residue.
- Timing alone neither requires these profiles nor authorizes new combinations; validate definitions under chapter 4. These are mechanical profiles, not aspects/replacement elements; “Flood” is never a zone and need not resemble water.
- Existing damage/residue/prop/height effects:

|     Type     | Damage |     Residue (permanent, level I)      |                                                                     Props                                                                     |                            Elevated                           |
|--------------|--------|---------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------|
| **Eruption** |      3 | **Lava I** — burns at end of turn | Trees ignite **instead of taking prop damage** | hit normally, **no residue** there (lava runs off) |
| **Flood** |      2 | **Thornbed I** — hurts when entered | extinguishes burning Trees; heavy props block it and are **neither damaged nor moved** | **can't reach it** (square blanked) |
| **Rift** |      3 | **Blight I** — hurts at start of turn | brittle props take **1 extra HP damage** (crumble reaction) | **collapses** to Rubble, the monster on it still takes damage |

- **Push order:** damage-2/Thornbed also pushes struck monsters **1 square in the cast-fixed direction**, into newly laid ground. Damage precedes residue; exact damage/residue/push order remains T04/T07.
- **Collapse state:** whether later Blight replaces collapse-created Rubble remains unresolved; the table establishes no exclusive final-state rule.

Elevated therefore offers profile-specific protection, not a universal Surge counter.

**Runtime counter menu** (authoring validation of live counters: §4.2/§4.4/§4.5/§4.7):

|            Counter             |                                                         How                                                          |
|--------------------------------|----------------------------------------------------------------------------------------------------------------------|
| **Leave**                      | move out of its squares before it fires — but mind any explicitly authored residue                                             |
| **Zone shield** | `shield` over its squares: reduction 2 (up to 3 with level) cuts damage 1:1 per square; recast to level up |
| **Pick the height** | Create Elevated where legal; protection, residue exclusion or collapse depends on the profile table above |
| **Stand on Hallowed** | Use its Surge reduction and replacement contract in [Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed) |
| **Fly over it**                | Existing Surge damage recipients exclude air; the air layer is out of reach (Winged, Soul+)                                       |
| **Props / debris** | Use the interception/destruction rules in [Battle §4.10](gdd_battle.md#410-damage-shatter--prop-types), subject to the interim prop status |
| **Answer with your own Surge** | race it — but you can't claim squares already held by a charging Surge                                               |
| **Control the tempo**          | slow / pull / push zones to steer where the target can stand; drain the caster's initiative to delay its next turn      |

#### Movement

Resolve **Step** as the universal one-square action; slotted movement uses the presets below. Kit/access and AP evaluation are defined in §4.1/§4.5; Kin preset access remains §3.3. Movement distance uses effective **Movement**, not Reach.

Movement skills use **flag profiles**, not special-case lists. Modes are authorized presets, not player permissions; separately authored profiles still need access/full validation (§4.2/§4.4/§4.5/§4.7).

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
- Ignoring path blockers permits no occupied landing. Walk processes entered cells; line/free/teleport only landing, with destination effects still applying.
- Glide grants no persistent flight; air/2×2 traversal/landing remain T09, Water/Swim T08.

#### Surge Constraints and Species Access

- **At most one twist:** one preview-readable extra rule, advantage priced under §4.5/§4.6. Represent it through placement/area/execution/effect/residue data and explicit profile constraints, not another schema or universal named-power menu.
- Battle rules (§4.2–§4.3) remain binding; old damage/range candidates grant no exceptions/upgrades.

Preserve the existing structural restrictions when authoring or upgrading a constrained Surge:

| Authored constraint | Validation |
|---------------------|------------|
| Adjacent anchor | Anchor stays adjacent; an existing 4-cell footprint has no Size path. |
| Straight trail from an adjacent cell | Footprint starts adjacent and stays straight; only legal I2/I3 families/orientations. |
| Four cardinal neighbours of the caster | Excludes the caster cell; no Shape or Size path. This special footprint is not generic ranged targeting. |
| Enlarged footprint | Result stays within its profile/Kin cell cap; do not charge the same enlargement twice. AP consequences follow §4.6, not an automatic surcharge. |
| Pull after damage | Existing one-square cardinal displacement toward an anchor fixed at cast; gdd_battle §6.5. |

- **Species Surge:** one per species, with its own twist; included in default kit/learnable list but optional as a normal slot skill (§4.1). Shape/Size upgrades preserve constraints; no Twist replacement path. Ownership is access/authorship on the same definition, not a new kind. Concrete twists/roster placeholders still need design/validation (T10–T12).

### 4.4 Effect and Board-Operation Contracts

**Effect catalogue — data, not skill blueprints**

- `damage`, `displacement`, `stat_change`, protection, healing, self movement and board operations are **typed contracts**, not purchasable permissions. Each needs an effect definition, legal owning profile/source, recipients, trigger/application and resolution order.
- Definitions own allowed parameters, caps, interactions and termination; skills supply only permitted values, never independently editable copies of fixed fields. References are documentation contracts, not new engine identifiers.

**`damage` — apply an existing damage source**

- Required data: source/profile definition, profile-authorized value or value source, footprint/recipients, trigger and ordering reference.
- Reduction, prop reactions, height and air eligibility come from that profile, never from a generic damage flag.

| Existing source/profile | Permitted value and recipients | Trigger, order and limits |
|-------------------------|--------------------------------|---------------------------|
| Strike | Values, monster/prop recipients and Kin exceptions: [§3.2](#32-strike-by-kin) and [Strike profile](#strike) | Bind immediate body-relative execution, prop blocking and ground/air coverage to that profile; no Reach targeting. |
| Surge | Values, recipients, ordinary prop interception and concrete prop/height exceptions: [Surge profile](#surge); the residue-free §4.7 record remains a separate draft, not balance approval | Bind delay, reductions, ground-layer eligibility and damage-before-authored-residue order to that profile and Battle §6.2. Do not substitute one profile's payload or exceptions for another's. |
| Hazard ground | Reference the concrete ground definition in [Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed) for value, recipients and caps | Bind its existing event under [Battle §2.4](gdd_battle.md#24-effect-timing-reference). Placement is `board_changes`, not immediate damage. |
| Collision / fall / debris | Reference [Battle §6.3](gdd_battle.md#63-collision-fall--debris) for event damage and recipient exceptions | Derived runtime consequences, not free castable payloads. The unresolved collision conflict remains T04. |

- **Damage permissions:** [Surge profiles](#surge) own prop exceptions, Battle §4.10–§4.11 generic reactions; indestructible props cannot be removed. Major/baseline twist exceptions need authored definitions/access/usage; no new damage values here.
- **No zone damage, immediate ranged burst or new damage zones.** Retired collision bonuses remain unapproved (T04), not collision-law exceptions. Damage values are not slot-upgrade parameters (§4.6).

**`displacement` — forced movement under an existing source**

- **Required:** definition/source, `mode: push | pull`, recipients, `steps`, trigger/order, direction/anchor binding. Use [Battle §6.5](gdd_battle.md#65-displacement) for cardinal direction, step cap/fixed pull anchor; Scaled chooses push direction with its Strike. Preview landing; fields grant no beyond-cap distance upgrade.

| Existing source | Recipients and trigger | Binding constraints |
|-----------------|------------------------|---------------------|
| Zone `push` / `pull` | Occupants under [Battle §4.6](gdd_battle.md#46-zones-effects-rules--opposites) | Bind direction/anchor and trigger to [Battle §6.5](gdd_battle.md#65-displacement), with ordering under [Battle §2.4](gdd_battle.md#24-effect-timing-reference). Persistence creates no additional trigger. |
| Existing direct unit-targeted displacement source | Selected unit, one-time direct resolution | Sight required; legal target/layer restrictions must be authored, not borrowed from removed table flags. Generic displacement does not authorize prop relocation. |
| Scaled Strike | Struck monsters under the Kin push definition | Existing Kin twist (§3.2); chosen direction and Strike constraints. |
| Surge profile with cast-direction push | Recipients, distance and trigger from the [Surge profile](#surge) | Preserve that profile's complete damage, residue, height and prop contract; unresolved ordering is not an override. |
| Authored pull twist | Struck monsters, pull 1 toward cast anchor after damage | Existing twist (§4.3); no arbitrary extra target or trigger. |

- **Consequences:** blocking/collision/fall [Battle §6.3](gdd_battle.md#63-collision-fall--debris), entry [Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed), prop destruction [Battle §4.10](gdd_battle.md#410-damage-shatter--prop-types). No implied chain push, diagonal/extra step or air/prop eligibility.
- **Unresolved, no defaults:** collision conflicts, push-Surge damage/residue/push order, Scaled damage/push order and pull ties ([temp_todo.md](temp_todo.md) T04).

**`stat_change` — referenced effective modifiers, not arbitrary stat edits**

- **Required:** typed `stat_change` definition, stat/operation, value/source, recipients, condition, lifetime, stacking group/rule, caps/floors and ordering. Timed self buffs, conditional passives and zones share this model; approved definitions restrict skill parameters. Named definitions keep fixed stat/sign/timing; new combinations remain drafts until validated. Effective modifiers never rewrite base stats.
- **Zones:** affect **everyone while inside**, end on exit/removal/expiry and use replacement/opposition/level rules (max III), not permanent cumulative deductions (gdd_battle §4.6).
  - Level III does not authorize value 3 for every effect.
  - Definitions own `base`/`cap`; use [Battle §4.6](gdd_battle.md#46-zones-effects-rules--opposites) for level-to-value computation, never unrestricted deltas.
  - Missing caps/scaling remain open.

| Existing definition | Meaning / existing authored values | Bounds and timing |
|---------------------|------------------------------------|-------------------|
| `slow` / `haste` | Movement −value / +value; retain authored values such as slow 1 | Bounds, timing and Step exception: [Battle §4.6](gdd_battle.md#46-zones-effects-rules--opposites). Changes Movement-skill effectiveness, not AP cost, TPR or a permanent stat. |
| `drain_init` / `quicken` | Effective initiative −value / +value; examples include −1, −2 and +1 | Timing and order recalculation: [Battle §2.2](gdd_battle.md#22-initiative-rules). No immediate queue rewrite or arbitrary numeric interval. General effect-value caps/floors are not specified by gdd_battle §4.6 and remain open. |
| `drain_range` / `extend` | Effective Reach −value / +value; examples include −1, −2 and +1 | Floor: [Battle §4.6](gdd_battle.md#46-zones-effects-rules--opposites). No independent per-skill range stat. Upper modifier/value caps require clarification, not extrapolation from progression ceilings. |

- **Timed Kin modifier:** Spirit Strike applies target initiative −1 next round (§3.2), not `while_inside`. Its distinct timed `stat_change` definition preserves trigger/expiry; stacking/refresh remain open. This is neither a free timing override on zone `drain_init` nor arbitrary timed Initiative/Reach/Movement permission.

- **Other sources:** Hearth/Shrine provide `quicken 1`, Umbra/Sigil `extend 1`, occupied Elevated +1 Reach. Keep ground/prop/height conditions, not zone expiry or free source substitution (gdd_battle §3.1/§4.7/§4.10).
- **Distinct contracts:** `shield` uses existing Surge reduction ([counter menu](#surge)), `mend` caps at max HP, `expose` is reserved without a zone. Reduction/healing/reserved definitions grant no generic stat edits.

- **Prohibitions:** no general temporary **TPR/AP/max-HP/movement-rule/flag** edits. Species-specific timed boosts need definitions, duration, limits and validation (§4.1), not arbitrary stat permission. Base-skill Reach debuffs/positional buffs are temporary battle effects, not cast-range upgrades; slow is not AP reduction. Budgets never authorize slot damage increases, AP reductions or cast-range increases (§4.6).

**Persistent self buffs and passive rule modifiers — shared contracts**

- **Timed self state:** ordinary `stat_change`/applicable typed effect, self recipients, explicit lifetime. Status is created runtime state, not a skill kind. Specify reapplication (stack/refresh/replace/ignore), cross-skill/source stacking identity, removal and caster/recipient death dependencies. §4.7's initiative-buff record is structural draft, not generic timed-boost approval.
- **Passive rule/stat modifiers:** use continuous/conditional `stat_change` or typed **`rule_modifier`**. Each `rule_modifier` names the exact changed rule, scope (e.g. owner's shapes), operation/parameters, activation condition, lifetime, stacking and precedence. §4.7's owner-scoped rotation reference grants no arbitrary mutation.
- **Event-driven passives:** same effect/board contracts, explicit event source, recipient binding, repeat/recursion limits and order; undefined policies block content.
- **Extensions:** opaque `custom_effect`, per-skill callbacks and ownership permissions are incomplete definitions. Extend shared typed contracts/common costing; source-specific validation restricts content, not representable families.

**`shield` / protection — referenced reduction, not shield HP**

- Required data: protection definition and owning source/profile, permitted reduction/value source, protected recipients and damage sources, application condition, damage-event ordering, lifetime/consumption and stacking/cap references.
- Protection neither grants temporary HP nor edits a defense stat.
- Fixed source rules cannot be replaced by a generic immunity or damage-filter field.

| Existing definition/source | Recipients, trigger and lifetime | Ordering and caps |
|----------------------------|----------------------------------|-------------------|
| Zone `shield` | Bind recipients/application to [Battle §4.6](gdd_battle.md#46-zones-effects-rules--opposites) and lifetime to [Battle §4.5](gdd_battle.md#45-lifecycles) | Reduction and scaling/cap follow the [Surge profile counter menu](#surge). No independent charges or effect timer. |
| Hallowed ground | Reference [Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed) for occupants, reduction and ground lifetime | Preserve the Surge profile's residue/height interaction; do not invent a separate hit-consumption rule. |

- **Protection exclusions:** retired Lava immunity/prop reinforcement/Strike reduction proposals need separate validation (T02/T04/T10), not generic `shield` options; `expose` stays reserved. Once-per-battle tamer protection (gdd_overworld §6.4) grants no repeatable monster immunity. Additional sources need authored definitions, not source substitution/default stacking (T02/T04/T20).

**`heal` — restore current HP only at an existing trigger**

- Required data: healing definition/source, authorized amount/value source, recipients, trigger, ordering, lifetime and cap/usage references.
- Healing never exceeds the recipient's existing max HP, changes max HP, revives a fallen monster or removes Injury.
- Definitions bind the event; persistence alone grants no heal on cast, per tick or extra activation.

| Existing definition/source | Recipients and trigger | Lifetime, order and caps |
|----------------------------|------------------------|--------------------------|
| Zone `mend` | Reference recipients/trigger in [Battle §4.6](gdd_battle.md#46-zones-effects-rules--opposites); existing reference magnitude: `mend 1` | Ordering uses [Battle §2.4](gdd_battle.md#24-effect-timing-reference); zone lifetime is shared. Level scaling and numeric healing cap remain open under T07, not implied by max zone level III. |
| Mossbed | Reference occupants, entry trigger and heal amount in [Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed) | No additional placement or continuous heal. Per-turn/re-entry limits remain T07; this contract does not approve arbitrary heal loops. |

- **Healing boundaries:** no generic immediate/direct monster heal, ally-only zone or new repeat trigger. The proposed tamer heal (gdd_overworld §6.4) is no monster definition. Pills heal **between battles**; expedition HP persists; Revival ends Injury, not battle HP loss (gdd_overworld §5.2/§6.4–6.6).
- Planned battle medicines/arrays need source, consumption, loadout and timing contracts (T18/T19), not generic `heal` permission. Economy/repeat-entry balance remain T07.

**Self `movement` — voluntary relocation of the caster**

- Required data: movement definition/source and authorized preset/exception, `recipients: self`, resolution trigger, origin and selected path/destination, distance source, path/landing/occupancy constraints, ordered traversal/entry events, action lifetime and usage/cap references.
- This is not forced `displacement`, unit relocation or prop movement.
- Resolve one movement action under gdd_monsters §4.3; it creates no persistent movement permission.

- **Step:** universal, slot-free, 2 AP, exactly 1 square; keep walk/blocking, ignore `slow`/extra ground costs. Not freely upgradable.
- **Slotted movement:** authorized [preset](#movement), AP baseline (§4.5), **Movement, not Reach**. Keep path, prop/monster/charging-Surge/height blocking and ground costs, including climbing/walk entry effects. Landing-only modes do not inherit walk triggers; destination effects still apply. Ignoring path blockers never legalizes occupied landing.
- **Access:** §3.3 owns presets/foreign modes, body/stage restrictions. `path: teleport` grants no access without an authorized profile; free paths grant neither persistent flight nor air access. Winged air requires Soul; flight/air occupancy/2×2 remain T09. Planned Water/Swim remain T08, not legal for unspecified Kins.
- **Custom modes/upgrades:** satisfy distance/direction pricing and access; fields are no player bypasses. §4.6's named one-flag-flip/distance-penalty patches grant no unrestricted path-mode, flight, teleport, extra action or range upgrade. Validate complete profile, entry order and destination preview; large-body/movement gaps remain T04/T09.

Tamer-source unit relocation and unit-swap effects retain their separate definitions (including proposal status where applicable), not self-movement presets or a shortcut around monster access rules (gdd_overworld §6.4; T19/T20).

**`board_changes` — typed ground, height and prop operations**

- **Required:** operation definition, legal source/profile, selected cells or prop/destination where relevant, cast/resolution trigger, damage/reaction ordering dependencies, resulting state/lifetime, placement/blocking/occupancy and cap references.
- **Scope:** recipients are board cells/props, not ally/enemy filters on later occupants; resulting hazards/healing/modifiers retain their effect contracts. Operations are one-time transitions unless explicitly assigned later events; permanent state is not repeated execution.

- **Ground placement / replacement**
  - Required data / source: Concrete ground definition and permitted level/source, footprint; immediate hazard cast, blessed-ground cast or specified Surge residue
  - Binding lifetime, ordering and limits: State, replacement/levelling, entry semantics and Voidscar exception: [Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed).
    - Placement uses §4.2; prop reactions use [Battle §4.11](gdd_battle.md#411-prop-reactions).
    - Surge aftermath follows its §4.3 profile.
    - Zone × ground remains T07; Water remains T08.
- **Height change**
  - Required data / source: Separate height definition, affected cells and authorized source: Elevated creation with coupled ground reset, profile-authored collapse or damage-derived debris collapse
  - Binding lifetime, ordering and limits: Reference [Battle §4.7](gdd_battle.md#47-ground--neutral-hazard-and-blessed) for height state and the Elevated-creation source's coupled Plain reset, and [Battle §6.3](gdd_battle.md#63-collision-fall--debris) for fall/collapse consequences.
    - Declare coupled operations explicitly; height edits grant no generic damage or displacement payload.
    - Surge-specific height handling remains §4.3; no new height levels or timed expiry.
- **Prop create / place**
  - Required data / source: Existing prop definition (HP, solid/field/flying kind, tags and reactions), legal footprint and creation source
  - Binding lifetime, ordering and limits: Placement uses §4.2; state and prop definitions use [Battle §4.9–§4.10](gdd_battle.md#49-props).
    - Enterable FIELD props grant no creation-under-occupant permission.
    - Reference existing lifetime/HP; unsupported occupancy/layer cases remain T04/T09.
- **Prop move / relocate**
  - Required data / source: Authorized source, selected prop, origin/destination and applicable path/placement constraints
  - Binding lifetime, ordering and limits: Reference placement in §4.2 and prop restrictions in [Battle §4.10–§4.11](gdd_battle.md#410-damage-shatter--prop-types).
    - Generic unit push/pull is not a prop-move definition.
    - The prop-relocation source's unresolved distance/path/reaction contract remains T02/T04.
- **Prop destroy / remove**
  - Required data / source: Existing destruction/reaction definition and eligible prop; damage-derived destruction references the damage source, not a free deletion flag
  - Binding lifetime, ordering and limits: Reference the interim destruction/reaction rules in [Battle §4.9–§4.11](gdd_battle.md#49-props) and derived debris in [Battle §6.3](gdd_battle.md#63-collision-fall--debris).
    - The prop redesign remains T04.
    - Direct deletion, salvage or suppressed debris requires a separately approved source; removal does not imply universal shatter.
- **Cleanse**
  - Required data / source: Explicit source, exact affected layer/state, legal footprint/recipients and resulting state
  - Binding lifetime, ordering and limits: The existing Elevated-creation source clears non-Voidscar ground to Plain as above; any additional monster zone-cleanse effect requires an explicit source-specific definition and validation (T02/T04); no such definition is established here.
    - Zone removal ends its effects, not ground/height/props or a charging Surge.
    - The combined zone-removal/Plain-reset exception is a tamer-source operation (gdd_overworld §6.4), not a reusable monster permission.
    - No generic cleanse of all layers, negative effects, Injury or Voidscar; unresolved combinations/order remain T02/T04/T07/T20.

- **Validation:** retain owning-profile Reach/anchor, fixed/on-board footprint, LOS and blocking (gdd_battle §4.3–4.11; §4.2–§4.3 here). No-LOS ground/prop casts still obey their empty-cell requirements. Preview resulting ground/height/props, reactions and derived damage.
- Simultaneous damage/collapse/debris/residue/relocation order remains T04/T07 where conflicting/underspecified, never list-order defaults. Planned loadout operations stay T18/T19. This catalogue approves no new props, conversion, board erasure or movement modes.

### 4.5 Construction Points and AP Efficiency

**Confirmed: one shared base budget, no skill ratings, upper bounds only.** All regular monster skills share construction; no Rare/Epic/Legendary/Mythical budget classes or automatic rarity/exclusivity bonus. Slot levels 1–3 raise ceilings. Major/Signature still need access/profile review, not a general higher-budget rating.

```text
skill point cost = mechanical component costs
                 + availability cost

availability cost = AP-efficiency cost (active skills)
                  or passive-availability cost (passive skills)


allowed ceiling = shared base budget + slot-level allowance

skill point cost <= allowed ceiling
```

- **AP efficiency:** fewer battle AP/use buys a powerful advantage, costing more construction points; higher AP leaves more effect room, never costs extra merely for spending AP. Author the finished skill/AP, then evaluate total points: AP cost is part of valuation, not an AP-class budget ladder or separate budget source.
- **Shared component prices:** charge actual mechanics once, never redundant tags/flags or the same enlargement twice; no combination surcharge ([policy](#combination-policy-and-basic-surge-target)). Evaluate telegraphing/blocking/restrictions in context, without arbitrary negative credits or uncalibrated exceptions.
- **Residue:** optional, separately priced board operation including interactions; delay/damage implies no ground payload.
- **Upper bound only:** no minimum, target band, exact spend or random budget; simpler skills may leave points unused. Develop stronger/larger variants at **original AP**; unchanged skills get no automatic AP reduction. Higher-AP extensions are optional and visible.
- **Passives:** no AP spend/free efficiency; explicitly price availability, conditions, event frequency and repeat/recursion exposure under the same total/slot ceiling, not a separate budget or zero-AP active tier. Initial availability reference below; other/event-driven patterns need separate evaluation.
- **Hard limits:** budgets never override damage caps, access, targeting, effect legality or profiles. Slot upgrade limits: [§4.6](#46-slot-levels-development-replacement-and-upgrades).
- **Calibration:** budgets/AP scale/components below are not validated balance. Unpriced components, combination reviews and tests remain temp_todo T02; all six §4.7 references remain incompletely validated.

| Slot level | Budget ceiling — preferred working draft |
|------------|------------------------------------------|
| 1 | 24 points (shared base budget) |
| 2 | 30 points (base +6) |
| 3 | 36 points (base +12) |

Maximums only: no spending targets, balance/component-price approval, EP prices or unlock conditions.

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

- **Geometry:** retain placement/occupancy/fixed orientation; constrained anchors/other targeting variants remain unpriced. Symmetric Strikes pay no direction fee when cells stay unchanged. A distant 1×1 Strike cell satisfies `max(abs(dx), abs(dy)) > 1`, not Manhattan Reach.
- Equal-size/equal-mechanics non-Strike shapes start equally priced; review special advantages such as chokepoints. No rotation, range upgrade or new placement permission.

#### Strike Costs

**Actual damage: 2 HP per struck monster.** Calibration drafts, not proof of equal strength; Spirit/Swarm/Ancient were designer-authored under the instruction to complete Strikes without individual approvals.

| Kin | Existing additional effect | Construction-point component |
|-----|----------------------------|------------------------------|
| Beast | None | 0 |
| Winged | One retreat of 1 cell after the Strike | +3 once per use, not per target |
| Scaled | Push 1, including existing push-direction selection | +2 per potentially affected hit cell |
| Spirit | Target Initiative −1 next round | +2 per potentially affected hit cell |
| Swarm | Props take 4 rather than ordinary Strike damage 2 | +2 per potentially affected hit cell; provisional pending prop redesign |
| Ancient | Elevated under the target becomes Rubble | +2 per potentially affected hit cell; provisional pending height/board resolution |

- **Kin packages:** bound, not interchangeable. Scaled includes push-direction choice, distinct from footprint direction; charge neither twice. Winged retreats once/use, not per target, without extra battle AP. Existing collision/fall/entry rules apply. Swarm grants no extra monster damage; Ancient no extra collapse/debris damage or arbitrary ground removal.
- **Unresolved:** Spirit stacking/refresh/expiry, Winged multi-target reference/ties/legal retreat, Scaled damage/push order; board/prop and 2×2/layers remain T02/T04/T09. No blanket damage-plus-Kin surcharge; review specific combinations.
- **Construction-point formula, 1×1 references:** `4 × hit cells + 2 × cells outside the adjacent eight-cell ring + effective footprint-direction cost + 2 ground/air coverage + AP-efficiency cost + Kin component`. Direction costs 2 only if cells change; ordinary prop interaction has no generic surcharge. Table values are **not damage** and decide no 2×2 hit multiplicity.

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

- **Geometry:** Arc uses the adjacent row/wedge; Cleave the illustrated cardinal two rows (three adjacent/three distant cells). Exact offsets for every selectable orientation remain T02/T06; no diagonal Cleave inferred. Symmetric forms pay no redundant direction selector.
- **Scope:** paper calculation, not legal-content catalogue, completed upgrade path or engine test.
- **Budget findings (24/30/36):** all Jabs fit level 1 numerically; per-cell-Kin Arc/Whirl/Cross need at least level 2. Only Beast Storm/cardinal Cleave fit 36; other variants and all Long Whirl/Long Cross exceed it.
- **Legacy reconciliation:** T02/T05/T06 after broader calibration; preserve neither content by automatic budget/AP changes, damage reductions, waived Kin costs nor over-budget approvals. Numeric fit grants no slot/progression access; every skill still needs a complete original-AP development path.

#### Movement Costs

**Working drafts:** price whole traversal presets with distance/direction restrictions, not travelled cells or Movement (already stat-budgeted). Run's 6-point component is selected; other modes are designer calibration drafts under the instruction to price all modes. Existing 2 battle AP add 6 efficiency points.

| Preset | Profile points | AP-efficiency points | Total construction points | Note (restrictions: [§4.3 presets](#movement)) |
|--------|----------------|----------------------|---------------------------|-----------------------------------------|
| Run | 6 | 6 | 12 | Baseline walk |
| Leap | 8 | 6 | 14 | Per §4.3 preset |
| Glide | 8 | 6 | 14 | Per §4.3 preset |
| Burrow | 8 | 6 | 14 | Per §4.3 preset |
| Phase | 7 | 6 | 13 | Per §4.3 preset |
| Blink | 10 | 6 | 16 | Per §4.3 preset |
| Swim (planned, not approved content) | 7 | 6 (assumed 2 AP) | 13 (provisional) | Run-like walk with Water cost 1; access/Water rules remain T08 |
| Step (universal, no slot) | Not budgeted | Not applicable | Not applicable | Existing 2 AP, exactly 1 cell; no skill upgrades |

- **Package scope:** whole §4.3 presets, not additive flag prices/restriction exchange rates. Retain §3.3 Kin/stage access, distance minimum 1, legal landing/occupancy/entry. Walk processes entered cells; line/free/teleport only landing. Free paths grant no persistent flight; self movement pays no ranged-anchor/ground-air-attack fee.
- **Status:** all existing slotted modes fit 24 numerically, without new access, completed upgrades, progression unlock or balance approval. Swim stays planned. Unmodified baseline walk uses the table total, combination 0, passive availability inapplicable.
- **Custom profiles/upgrades:** separately resolve costs for flag-flip/distance-penalty patches and added effects (§4.6); unused budget grants no free upgrade, base restrictions no second charge. Test low/high Movement including floor, barriers, hazards and exits; air/2×2 remain T09.

#### Self-Buff and Passive Costs

**Designer calibration drafts** for self-buff/passive [coverage references](#non-area-and-passive-coverage-references), not approval of content, legacy passives (§5), new stat effects or unresolved stacking/triggers.

| Component / reference | Mechanical points | AP-efficiency / availability points | Combination points | Total points |
|-----------------------|-------------------|-------------------------------------|--------------------|--------------|
| Self Initiative +1, 2 rounds, proposed 1 AP | 4 × 1 magnitude × 2 rounds = 8 | 12 AP efficiency | 0 | 20 |
| Owner may rotate its eligible fixed tetris shapes while equipped | 6 for rotation permission | 12 passive availability | 0 | 18 |

- **Self Initiative:** 4 points per +1/round, no artificial area/anchor/ground-air-attack fee.
  - Assumes draft refresh without magnitude stacking; normal AP-paid refresh adds no blanket surcharge.
  - Not a rate for arbitrary stats, targeted/team buffs or cumulative Initiative.
  - Round-end duration/normal round queue recalculation apply; cross-source stacking, removal/death/exact termination remain open.
  - Same draft rate can cost longer duration, not approve upgrades.
- **Passive availability:** initial 12-point premium for continuously equipped, self-scoped boolean permission (owner rotation), replacing active efficiency; mechanics priced separately. Neither 0-AP active nor extra budget. Conditions grant no automatic discount; event-driven/repeating/proccing/team-wide/other patterns need frequency/recursion/combination review before pricing/approval.
- **Rotation:** covers all owner's legal eligible-shape rotations while equipped, not each cast; identical boolean permissions do not stack. No mirroring, Strike geometry changes, cells, range or new profiles. Test equipped shapes, symmetry, action frequency, fixed-shape kits and placement options; equal value across kits is not guaranteed.
- **Validation:** both fit 24 numerically, not unlocks/full paths. Test self Initiative against tempo/queue changes and paid refresh. Other passive mechanics/combined statuses need explicit follow-through, not unused-point-funded free additions.

#### Zone, Protection and Healing Costs

**Designer test prices for §4.4 contracts, not new effect permissions.** C = potential cells, R = authored rounds, V = authored base magnitude. Add AP efficiency once/skill and applicable selection costs to these mechanical components; combination surcharge 0. Effects share one zone clock, not independently purchased timers.

| Existing effect | Mechanical construction points | Calibration scope |
|-----------------|--------------------------------|-------------------|
| slow / haste | 1.5 × V × C × R | Slow reference unchanged; opposite sign gets same initial rate |
| drain_init / quicken | 2 × V × C × R | While inside; no immediate queue rewrite |
| drain_range / extend | 2 × V × C × R | Effective Reach only, not a cast-range upgrade |
| Zone push / pull | 2 × C × R | Existing one-square end-turn trigger; direction/fixed pull anchor included |
| Immediate one-time displacement (existing direct unit-targeted / other authorized immediate sources) | 2 per potential recipient cell; existing direct unit-targeted source uses 1 recipient | Existing one-square trigger; direction/pull anchor included |
| [Profile-scoped delayed footprint push](#basic-surge-profile-cross-check) | 1 per potential recipient cell | New designer test price **only for the existing one-square push of the damage-2/Thornbed Surge profile**; direction included, no additional timing multiplier |
| Zone shield | 1 × V × C × R | Existing base 2, cap 3; Surge reduction, not shield HP |
| Zone mend | 3 × V × C × R | Existing heal 1 reference; scaling/cap and repeat balance pending T07 |
| expose | Not priced / reserved | No approved zone; no damage-boost permission |

- **Scoped push draft:** only the table's delayed footprint-bound push, escapable before resolution, not an immediately selected target. No general 50% non-damage discount/all-delayed-displacement rate; immediate direct, Scaled Strike, zone and other Surge push/pull retain rates/contracts and all distances.
- Not applicable to repeated/tracking/unavoidable/enhanced displacement. Test the entry-hazard combination; budget fit does not validate the reduced rate.

- **Selection:** ranged zones pay +2 board anchor once, no second direction/anchor-binding charge. Existing direct unit displacement provisionally pays +2 for eligible visible-unit selection **instead of** the no-LOS anchor fee; eligibility/LOS remain unresolved.
- **Repetition/values:** normal AP-paid zone levelling/refresh included, extending Slow policy for calibration only. Resolve magnitude/cap/level formulas; no stronger values, heal scaling, extra triggers or ally-only filters. Test each effect's repetition independently.
- **Healing/protection:** retain max HP, events/source permissions; no direct heal, revival, Injury cure, general immunity, tamer protection or item permission. Stacking/consumption/order (T04), mend/Mossbed loops (T07) block affected content. Prices set neither caps nor unbounded-healing permission.

#### Ground and Board Costs

**Permanent-state packages:** fixed price per created cell, not invented duration/future-trigger counts. Includes existing occupant effects, ordinary placement/replacement and persistence; no duplicate instant-damage/heal/zone-modifier charge for future effects. Entry/start/end events stay unchanged. Level-I hazards include normal AP-paid recasts to existing II, not stronger damage/level-II-start upgrades.

| Existing state / operation | Mechanical construction points | Included / unresolved scope |
|----------------------------|--------------------------------|-----------------------------|
| Lava I / Thornbed I / Blight I, immediate ground cast | 4 × C | Permanent hazard package; trigger risks to test |
| Lava I / Thornbed I / Blight I, delayed Surge aftermath | 1 × C | New designer test rate for telegraphed ground aftermath; permanent after resolution |
| Hearth / Umbra | 4 × C | Existing +1 Initiative / Reach while occupied, both sides |
| Mossbed | 6 × C | Existing heal 1 on entry; provisional until re-entry limits are resolved |
| Hallowed | 4 × C | Existing Surge reduction 1; no automatic hit consumption |
| Elevated creation with coupled Plain reset | 5 × C | Elevated plus its existing non-Voidscar → Plain cleanse, one package |
| Existing collapse-to-Rubble operation | 2 × C | Source-specific height change; no extra fall/debris damage granted |
| Create Wall / Tree | 4 per created prop | Existing HP/tags/solid/reaction package; provisional pending prop redesign |
| Create Rock | 6 per created prop | Existing heavy-prop package; provisional, source/access still required |
| Create Shrine / Sigil | 8 / 6 per created prop | Existing prop/effect package; no duplicate permanent buff charge |
| Relocate eligible prop | 6 per moved prop | Provisional component only; distance/path/destination/reactions remain undefined |
| Additional ground-only Plain reset / zone-only cleanse | 3 × C / 4 × C | Pricing placeholders only; no new monster source is approved (§4.4) |
| Water, direct Rubble creation, Pillar creation, direct prop deletion | Not priced / not authorized by this table | Need explicit source/contract; Water remains planned T08 |
| Voidscar alteration | Forbidden | No budget bypass |

- **Props:** prices grant no catalogue/access; retain empty-cell, heavy/indestructible and interaction restrictions. Ordinary destruction has no generic surcharge; natural damage-derived debris/collapse is not a second authored operation. Ignition/extinguish/crumble, falling/splitting and mixed packages await prop redesign, not guessed defaults.
- **Cast fees/residue:** standalone ground/props add the applicable +2 anchor fee and AP-efficiency cost once. Residue means authored Surge **ground change, not prop creation**; [Surge profiles](#surge) own payloads/exceptions. Delayed hazard aftermath uses 1 point/cell, no second anchor/AP or further 50% damage discount; immediate ground retains 4. Source-specific height/prop exclusions remain binding.

**Conditional-outcome costing — designer working draft:**
- Price the most expensive explicitly mutually exclusive legal outcome; sum coexisting components within it. Maximize over legal board states for the authored skill, not the cast-time board; no probability weights/best-case discounts.
- Sum per-cell maxima only if those outcomes can coexist across the footprint; count shared activation/anchor/marker once. Missing prices/unresolved order block a complete maximum, not zero-cost branches.
- Valuation grants neither runtime exclusivity nor new effects. Collapse-to-Rubble may or may not exclude later hazards: resolve final state under T04/T07 before replacing its conservative additive bound.

#### Combination Policy and Basic Surge Target

- **No combination surcharges**, including former damage-plus-hazard/displacement-plus-hazard rates: sum mechanics + AP efficiency/passive availability; retained combination fields = 0. Additional effects still cost points; legal combinations still need validation.

- **Target:** useful basic Surges with intended ground aftermath at **1 battle AP**. Concrete [profiles](#surge) include explicit `board_changes`; prop creation is separate, never a default. The generic residue-free reference remains, not a replacement.
- **Draft status:** delayed ground at **1 point/cell** is a designer test price, not user-selected final balance; scoped subtotals below. Existing 1-AP costs stay; not every legacy shape/profile fits level 1. Complete prop/height/push-profile evaluation remains pending.
- Resolve conflicts by calibration, not automatic 2-AP basic Surges. Review avoidability under enhanced blocking/guaranteed hits; test internal/team synergies.

#### Basic Surge Profile Cross-check

**Paper calculation at existing 1 battle AP; designer test prices, not content/balance approval.**
- Hypothetical fixed 2/3-cell footprints, not approved new shapes; potential ground recipients, no air permission. Every row includes anchor 2, normal marker 1, AP efficiency 12, intended level-I hazard aftermath 1/eligible cell.
- No combination surcharge, second anchor/AP or extra displacement/ground timing multiplier. Only damage-2/entry-hazard/push uses the scoped delayed-push proposal; damage uses existing 50% avoidable-Surge pricing.

| Existing profile | Costed components on Low, prop-free cells | 2-cell subtotal | 3-cell subtotal | Remaining profile evaluation |
|---|---|---|---|---|
| Eruption | `15 + 3 × cells` damage + `1 × cells` Lava aftermath | 23 | 27 | Profile-specific ignition valuation is not yet defined (§4.3) |
| Flood | `15 + 2 × cells` damage + `1 × cells` Thornbed aftermath + `1 × cells` one-square push | 23 | 27 | Sole profile eligible for the proposed push rate; prop review and damage/ground/push ordering remain unresolved |
| Rift | `15 + 3 × cells` damage + `1 × cells` Blight aftermath | 23 | 27 | Profile-specific collapse and brittle-prop reaction are not included in these Low-cell subtotals (§4.3) |

**Scoped subtotals, not complete profile prices:** ordinary offensive prop damage/destruction has no generic surcharge, but ignition/extinguishing/extra brittle damage/other special reactions are not automatically free. Infer no reaction prices before prop review.

- **Collapse/hazard:** damage-3/collapse/hazard includes collapse at **2 per potential cell**, with ground/height final state unresolved (§4.3). Two/three-cell **27/33** are conservative additive bounds for priced damage/collapse/residue, not complete profile prices.
- If runtime exclusivity is established, `max(1 residue, 2 collapse)` gives **25/30** for that subset; this calculation approves no exclusive final-state rule. If both occur, charge both; authored collapse is never waived as ordinary damage-derived debris.
- Extra brittle-prop damage remains unpriced. No-residue-on-Elevated/Elevated-exclusion rules grant no automatic credits.

- **Budget finding:** draft push pricing equates two-cell damage-2/entry-hazard/push with Low, prop-free damage-3/end-turn-hazard at 23; three cells cost 27. This resolves scoped arithmetic, not full-profile balance.
- Damage-3/collapse/hazard fits 24 on Low only; its priced height-capable subset exceeds 24 even with conditional exclusivity. Decide runtime final state before approving full price/development. All three-cell subtotals exceed 24.
- Preserve damage, 1-AP baselines, mechanics and shared ceilings; special prop reactions/event order remain T02/T04/T07 blockers.

#### Calibration Examples

| Reference | Construction-point calculation | Provisional subtotal |
|-----------|--------------------------------|----------------------|
| Beast Strike: 1 cell, 2 damage, 2 AP | damage 4 + direction 2 + ground/air 2 + AP efficiency 6 | 14 |
| Slow zone: 3 cells, 2 rounds, 1 AP | slow 9 + anchor 2 + AP efficiency 12 | 23 |
| Same slow zone: 3 rounds | slow 13.5 + anchor 2 + AP efficiency 12 | 27.5 |
| Residue-free Surge: 3 cells, 3 damage, 1 AP | damage 18 × 50% + anchor 2 + marker 1 + AP efficiency 12 | 24 |
| Zone quicken 1: 3 cells, 2 rounds, existing 1 AP | effect 12 + anchor 2 + AP efficiency 12 | 26 |
| Zone shield base 2: 3 cells, 2 rounds, existing 1 AP | protection 12 + anchor 2 + AP efficiency 12 | 26 |
| Mend 1 zone: 3 cells, 2 rounds, existing 1 AP | healing 18 + anchor 2 + AP efficiency 12 | 32 |
| Immediate hazard ground: 3 cells, existing 1 AP | hazard package 12 + anchor 2 + AP efficiency 12 | 26 |
| Hallowed ground cast: 3 cells, existing 2 AP | ground package 12 + anchor 2 + AP efficiency 6 | 20 |
| Elevated creation/Plain reset: 3 cells, existing 1 AP | height/cleanse package 15 + anchor 2 + AP efficiency 12 | 29 |

- **Status:** paper calculations, not complete validation, approved content/paths or engine tests. Above 24/30/36 means calibration conflict, not automatic unlock/AP change/budget exception. No fractional-point rounding rule.
- Hazard-Surge subtotals belong to the cross-check above; special reactions/profile interactions need review. Movement/self Initiative/passive rotation calculations stay in their respective tables.

#### Included Behaviour and Validation Limits

- **Slow:** base 1/cap 2, Movement minimum 1, Step unaffected. Includes normal AP-paid recasts/levelling/duration refresh, not level-II starts, free recasts or enhanced repetition. No pricing of other stats; rounds do not guarantee personal turns. Test repetition.
- **Marker:** existing temporary voluntary-movement blocking only, not enhanced blocking/duration; retain movement/displacement exceptions. Test chokepoints, props/height and prevented escape against the 50% damage rate: price does not guarantee avoidability.
- **Combinations:** no surcharge within/between skills/monsters. Validate full interactions; revise responsible components/rules on evidence. Guaranteed hits do not automatically qualify for avoidable-damage discounts.
- **Props:** ordinary interaction is baseline for relevant offensive sources only, not movement/support damage or universal destruction. Evaluate special damage, resistance bypass and enhanced reactions; revisit after Battle §4.9–§4.11 redesign (T04), without blocking unrelated calibration.
- **Permissions:** prices override no access/profile/damage/targeting/layer limits. Missing spatial/event/stacking contracts block affected content (T02/T04–T06/T09/T13).

#### AP-Efficiency Working Scale

**Selected for calibration, not validated balance.** These construction-point costs are added to the other evaluated mechanics of an active skill; they are not separate AP-class budgets.

| Battle AP per use | AP-efficiency cost in construction points |
|-------------------|------------------------------------------|
| 1 | 12 |
| 2 | 6 |
| 3 | 3 |
| 4 | 1 |
| 5 | 0 |

- **Limits:** higher battle AP grants no negative credits. This scale neither authorizes zero-AP actions/AP-reducing upgrades, changes existing AP costs, prices passive availability nor approves damage/area/timing drafts. Check complete skills, legal repetition and available AP/turn.
- **Existing prices below are calibration references, not a parallel final formula.** Retain until replacements are explicitly agreed; no silent repricing. Check §3.2's existing Strike shape prices against the new calculation.

| Authored action/profile | Existing battle AP cost / limit |
|-------------------------|---------------------------------|
| Step (no slot) | 2 AP |
| Slotted movement | 2 AP |
| Zone / ordinary ground / prop / direct | 1 AP |
| Minor Surge | 1 AP baseline; one charging Surge per monster |
| Strike | 2–5 AP by the selected authored shape (§3.2) |
| Blessing ground | 2 AP; not the ordinary-ground default |
| Major Surge | 2 AP; once per battle; access under §4.1 / §7.4 |

- **Baseline scope:** existing prices, not new values/final costs for every combination. Species-specific skills retain applicable profile costs pending calibration; “Unique = 1 AP, may set its own” grants neither a category nor unrestricted override. Explicitly validate retained exceptions (T02); optional higher-cost upgrades follow §4.6, not unconfirmed blanket Twist/Size surcharges.
- Tamer/planned medicine/array source-loadout contracts remain gdd_overworld §6.4–§6.6/gdd_battle §5.2; monster-action prices assign none of their costs.

**Preserved authoring constraints:**

- Normal shaped skills have one fixed family/orientation; unit-targeted effects/Step need no tetris footprint; Strike uses body shapes.
- A zone's existing duration default is 2 rounds, but every resolved definition must state/reference its lifetime; the §4.7 example remains an unvalidated combination.
- Temporary species-specific effects must state N rounds or an explicit consumption/end-of-battle condition; the former flat `rounds` field is not a separate schema.
- Movement presets/flags and their restriction-versus-distance/direction price rule remain binding runtime profiles (gdd_monsters §4.3); §4.6 owns their upgrade allowance.
- A Surge needs at least three live counters to pass design validation (leaving, protection, height, air, props or tempo as applicable); a nominal counter that its actual profile prevents does not count.

- **AP is the only battle-use resource for active monster skills.** Passives have no active AP spend; their availability is priced in construction points. No cooldowns, no mana.
- **Cast range** uses effective Reach where the battle profile requires it; Strike uses its body footprint and movement uses Movement. No independent skill-range stat or new twist exception (§4.3).
- **Size:** 1–4 cells for ordinary skills with a tetris shape, 2 for Swarm Surges (§3.1). Strikes have their own list (§3.2); Major Surge requires its explicitly authored large-area profile and access, not a generic cap override.

### 4.6 Slot Levels, Development, Replacement and Upgrades

**Confirmed: permanent slot development**, alongside physical evolution, spending the individual monster's shared **evolution points (EP)**. No separate player skill-point currency; construction/blueprint points are internal authoring data, neither intermediate spendable budget nor Overworld Blueprint items.
- **Ownership/choice:** EP develop one slot on one monster, not its equipped skill or species globally.
  - Each purchased step directly grants a skill-specific upgrade choice.
  - Designers use §4.2–§4.7 for finished skills/upgrades, internal budgeting/AP pricing; players select authored options, not arbitrary components.
  - Equipped skills define legal upgrades/prerequisites/exclusions; slot progress determines available development, not simultaneous access to all upgrades.
- **Replacement:** outside expeditions, unlocked species learnable-list skill, valuable **relearning pill**. Preserve all purchased slot progress; select legal replacement upgrades using it without another EP purchase, not literal transfer of old effects. Pill acquisition/recipe/tier/price/overworld AP remain T05/T16/T31.
- **Levels 1–3:** increasing construction ceilings (§4.5), no separate skill ratings/ranks. EP prices/unlocks/intermediate steps/total supply remain undecided; review legacy supply alongside physical evolution costs.
- **Open:** pill use for same-skill upgrade reselection; passive-only slot development and active/passive replacement rules are required before implementation.

**Confirmed construction budget and AP policy**

**Superseded prices and legacy reconciliation:**

- The former per-skill prices (1 EP for Shape/Twist/Value/Swap, 2 EP for Size) are superseded, not slot-level development prices.
- Legacy “Shape always free”, blanket “Twist = 2 AP”, “Size adds 1 AP”, Twist-plus-Size totals and double-charging an already enlarged footprint remain T02/T05 reconciliation work; none overrides the confirmed policy below.

- **Budget:** shared base + slot allowance; AP efficiency consumes it, AP classes supply no different base. Only an upper ceiling ([§4.5](#45-construction-points-and-ap-efficiency)); balance remains open (temp_todo T02/T05).
- **AP policy:** bounded improvements and a complete path at original AP for every skill. Larger extensions may optionally cost more AP, shown before selection, never mandatory for slot development.
- **Patches:** authorized fields on the same definition (§4.7), not a parallel model; area, shape/orientation, duration, movement/displacement or explicitly designed secondary effects, within skill limits/prerequisites.
- **Limits:** no direct-damage, AP-reduction or cast-range upgrades; existing Strike/Surge/ground damage caps hold. More cells/duration may increase total impact and still require budgeting/validation. Budget guidelines bypass no hard caps/legal combinations; reconcile legacy blanket AP surcharges, never apply automatically.

**Candidate catalogue, not final step prices/unlocks.** Cast range is excluded; slot development supersedes old per-skill evolution counts. Review concrete offers/AP effects under temp_todo T02/T05.

|           Family           |                                       What changes                                      |                                                                                         Rules                                                                                         |
|----------------------------|-----------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Shape** | Other shape family or orientation, **same cell count** | I2 orientation, I3↔L3 or legal 4-cell families; Strike swaps same-size shapes from §3.2. Family must respect Kin and twist constraints; shapes remain fixed in battle. Legacy ‘always free’ grants no free EP development or respec; costs remain T05. |
| **Size** | **+1 cell** within the owning profile's cap; Strike selects a larger §3.2 shape | Ordinary tetris max 4; Swarm Surge cannot enlarge. A larger Strike uses its existing shape AP price as an optional higher-cost branch, never the only development path. The old automatic Surge +1 AP is unconfirmed; requirements, EP prices and optional AP effects remain T02/T05. |
| **Twist** *(Surge only)* | Replace/add an authored extra rule; not on a Species Surge | At most one; preserve §4.3 constraints and exclude damage/range increases, including legacy delayed-damage or extended-range candidates. Validate under the confirmed AP policy. |
| **Small value** | Zones: `duration` +1 round total per skill. Movement: one flag flip total, turning off one restriction or lowering its distance penalty by 1 (§4.3) | Bounded candidate patches, not free upgrades. No damage increase or level-II start; the level-II-start passive remains a separate candidate (§5), not an approval through this table. |

- **Shared process:** authorize patches to [§4.2](#42-data-oriented-skill-construction-kit), validate through [§4.7](#47-complete-references-and-validation), including species-specific/Signature (§4.1); no per-kind schema. Replacement is never a patch and follows this section's opening rules. Legacy named examples/evolution counts are retired pending T02/T05/T10.
- **Identity:** different evolution choices within one species yield different playstyles without new art. Shaped skills retain **one shape/fixed orientation**, except existing rotation permissions; Surges have **at most one, not mandatory, twist**. Non-area skills gain no footprint. Battle rules remain valid; preview the resolved variant normally.
- **Purchase/logistics:** deliberate shared EP spend, not focused-XP Train/automatic breakthrough reward. Location/day-AP: [Overworld §6.3.2](gdd_overworld.md#632-permanent-skill-slot-development-confirmed). EP awards (§7.2/§7.4) remain unvalidated; reversal/transfer/same-skill reselection remain [temp_todo.md](temp_todo.md) T05, not free resets.
- **Validation:** enforce candidate limits, owning [Surge constraints](#surge-constraints-and-species-access), Kin access (§3) and [§4.7](#47-complete-references-and-validation). Evolution UI offers only passing paths. Unsupported 2×2/spatial cases stay T09; evolution grants no exceptions/air access.

### 4.7 Complete References and Validation

- **Author:** legal profile → §4.2 dimensions resolved through definitions → access/interactions/budget. Use this section's single schema; footprints/effect definitions are data references, not fundamental skill blueprints.
- **Validate complete records, not components:** selection → placement → footprint → recipients; execution → effect events/order → lifetime; then Kin/species access, usage limits/cost. Preview cells, recipients, displacement landings and board reactions; missing rules block content.
- **Content status:** former named example table retired; §6.1 roster names are unvalidated ideas, not definitions/permissions. Rebuild only after central [temp_todo.md](temp_todo.md) decisions, especially T02/T04/T05/T07/T09/T10.

#### Shared Schema and Calibration References

**Documentation template, not implementation:** one §4.2 model including species skills/upgraded variants. Field names show responsibilities, not required serialization; referenced effects supply mechanics/caps, not a parallel zone schema.

**Slowing-zone walkthrough — unapproved draft:** proposed 1 AP, fixed horizontal I3, 2 rounds, `slow` base 1/cap 2, no ignition/secondary effect. Area/AP are calibration proposals; a centred three-cell footprint avoids two-cell midpoint ambiguity.
- **Selection/placement:** board tile within effective Reach (Manhattan to anchor), no LOS; anchor/two horizontal neighbours all on-board, no clipping/rotation. Props/existing zones permitted under zone replacement/opposition.
- **Recipients:** ground-layer occupants of both sides, caster included; no air, props, height or ground-state effect.
- **Application/levels:** immediate slow on placement, no damage/entry payload; ends on exit/removal. Level I subtracts 1 Movement, minimum 1, Step unchanged. Same-zone levelling caps at 2 via `min(2, 1 + level - 1)`; battle-zone level, not slot level.
- **Clock:** shared, decrements at round end, removes at 0; 2 rounds do not guarantee two full personal turns per monster.
- The full field-by-field record is the Slowing Zone column of the table below.
- **Paper checks, not engine tests:** anchor (3,3) yields (2,3)/(3,3)/(4,3); (0,3) is invalid because (-1,3) is off-board. Ground Movement 3 becomes 2 at level I, returns to 3 on exit; Step stays normal, allies behave identically. Props are not slowed, air is excluded, underlying ground unchanged. General 2×2/unrelated gaps remain open.
- **Bindings:** single authored footprint, not cast-time shape choice. Placement: [§4.2](#42-data-oriented-skill-construction-kit); lifetime: [Battle §4.5](gdd_battle.md#45-lifecycles); value/replacement: [Battle §4.6](gdd_battle.md#46-zones-effects-rules--opposites). Evaluation: provisional [Slow calculation](#calibration-examples)/[AP scale](#ap-efficiency-working-scale), not unlock/content approval.
- **Representation:** The table below is the single baseline record; candidate patches stay separate/unapproved.
  - References are documentation contracts, not invented runtime identifiers.
  - Ground operations use `board_changes`, layers per-effect, no duplicate flags.
  - The superseded flat blueprint's behaviour/targeting/direction/duration/usage belong to these dimensions; Surge twists/species ownership are profile constraints/metadata on this same model.

**Draft structural/calibration references, not approved catalogue or balance:** Slowing Zone, Beast Jab, Delayed Burst; Run, Focus, Adaptive below complete six cases.
- Same top-level schema; groups explicit or bound to §4.2/§3.2. Unresolved access/upgrades/runtime remain draft. Jab covers only fully costed Beast, not other Kins' unresolved contracts (T02/T04/T06).
- No runtime identifiers. Coordinates `[dx, dy]`, **1×1 bodies only**; large-body rules remain open.

Cases per field below: **Slowing Zone reference (draft)**; **Beast Jab reference (draft record of existing Strike)**; **Delayed Burst reference (draft Minor Surge)**.

- **`metadata`**
  - Slowing Zone: `id: slowing_zone_example`; `name: Slowing Zone (draft)`; `kind: zone`; `rule_profile: zone`; `tags: [control]`; ordinary species access
  - Beast Jab: `id: jab_reference`; `name: Jab`; `kind: strike`; `rule_profile: strike`; `tags: [reference]`; Beast Kin binding (§3.2), no additional Kin effect
  - Delayed Burst: `id: delayed_burst_reference`; `name: Delayed Burst (draft)`; `kind: surge`; `rule_profile: minor_surge_residue_free`; `tags: [reference]`; no species twist; ordinary Kin/access limits
- **`access`**
  - Slowing Zone: Authored species list; existing Kin/progression constraints
  - Beast Jab: Authored species list; Beast Kin and existing Strike access (§3.2); concrete species list pending
  - Delayed Burst: Authored species list and ordinary Kin constraints; Swarm cannot use this 3-cell footprint
- **`usage_type`**
  - Slowing Zone: `active`
  - Beast Jab: `active`
  - Delayed Burst: `active`
- **`execution`**
  - Slowing Zone: `activation: player_action`; legal-cast condition; `timing: immediate`; `resolution: cast_resolution`
  - Beast Jab: `activation: player_action`; legal-Strike condition; `timing: immediate`; `resolution: cast_resolution`
  - Delayed Burst: `activation: player_action`; legal-Surge condition; `timing: telegraphed_delayed`; `resolution: caster_next_turn_start_before_start_effects`; marker/charging under §4.2; autonomous after displacement or death, using the dead caster's due queue slot
- **`targeting`**
  - Slowing Zone: `type: tile`; existing zone target eligibility; `distance_source: caster_reach`; no LOS
  - Beast Jab: `type: self`; `eligibility: caster`; `distance_source: body_footprint_not_reach`; `line_of_sight: not_required`
  - Delayed Burst: `type: tile`; any legal board anchor; `distance_source: caster_reach` (Manhattan to anchor); `line_of_sight: not_required`
- **`placement`**
  - Slowing Zone: Selected tile anchor; fixed board cells at cast; no direction selection; existing zone placement including props/replacement rules
  - Beast Jab: `anchor: caster_body`; `binding: immediate_body_relative`; `direction_selection: one_of_eight`; existing §3.2 body placement, caster excluded
  - Delayed Burst: `anchor: selected_tile`; `binding: fixed_board_cells_at_cast`; `direction_selection: none`; props permitted, no overlap with a charging Surge; existing Surge placement
- **`area`**
  - Slowing Zone: Fixed horizontal I3; offsets `[[-1,0],[0,0],[1,0]]`; 3 cells; all cells on-board; no clipping/rotation
  - Beast Jab: `shape: Jab`; `offsets: [d]`, where selected `d` is exactly one of `(−1,−1), (0,−1), (1,−1), (−1,0), (1,0), (−1,1), (0,1), (1,1)`; `cell_count: 1`; orientation = selected direction; `orientation_policy: strike_direction_selection`; `boundary_rule: all_cells_on_board`; solid-prop blocking under §3.2
  - Delayed Burst: `shape: I3`; `offsets: [[-1,0],[0,0],[1,0]]`; `cell_count: 3`; `orientation: horizontal`; `orientation_policy: fixed_board`; `boundary_rule: all_cells_on_board`; no clipping/rotation; props do not block placement; damage hits Elevated normally, without collapse
- **`effects`**
  - Slowing Zone: `stat_change: slow`; base 1/cap 2 under zone-level formula; all ground-layer occupants including allies/caster; existing zone stacking/level rules, shared created-zone lifetime; continuously while inside; ends on exit/removal; Movement minimum 1, Step unaffected
  - Beast Jab: `damage`: Beast Strike under §3.2, fixed 2 against monsters/props; recipients = all struck monsters including allies, excluding caster, and struck props; evaluate/apply once at cast resolution, action lifetime none/no retained damage stack. Beast has no additional Kin effect
  - Delayed Burst:
    - `damage`: fixed 3 against all ground-layer monsters in the footprint at resolution, including caster/allies/enemies
    - no air. Existing ordinary Surge prop handling: 2 to prop instead of occupant
    - shield/Hallowed reduction, minimum 0. Apply once at detonation
    - no push, pull, ignition or brittle-prop extra reaction
    - no repeat payload
    - one-shot damage has no retained stack
    - pending marker lifetime ends at resolution
- **`persistence`**
  - Slowing Zone: Created zone; 2 rounds; shared clock ticks at round end; removed at 0
  - Beast Jab: `none`; immediate action with no retained Kin state
  - Delayed Burst: `type: until_resolution`; `owner: pending_surge`; expires at detonation; no post-resolution effect lifetime
- **`board_changes`**
  - Slowing Zone: `[]`: no ground, height or prop operation
  - Beast Jab: `[]`: no authored ground/height/prop operation; ordinary damage-derived prop reactions use Battle §4.10–§4.11
  - Delayed Burst: `[]`: no authored ground placement, residue or height change; ordinary damage-derived prop destruction/shatter/debris remains §4.2, not an added residue component
- **`interactions`**
  - Slowing Zone: Placement not blocked by props/height; recipient layers are specified in `effects`; no ground-changing operation
  - Beast Jab: Monster damage recipients include ground and air; `blocked_by_objects: true` (solid-prop line rule); `blocked_by_height: false`; no additional Beast operation
  - Delayed Burst: Damage recipients are ground-layer only; `blocked_by_objects: false` for placement (prop intercepts damage); `blocked_by_height: false`; no ground reset, including Hallowed consumption without residue
- **`usage`**
  - Slowing Zone: `ap_cost: 1` proposed; existing zone limits
  - Beast Jab: `ap_cost: 2`; existing AP repetition, no charging limit
  - Delayed Burst: `ap_cost: 1` proposed; one charging Surge per caster, existing AP spending/repetition rules; no cooldown/mana
- **`upgrades`**
  - Slowing Zone: `[]` in baseline; separate candidate patches below, no approved requirements
  - Beast Jab: `[]` in baseline; separate candidate patches below, none approved
  - Delayed Burst: `[]` in baseline; separate candidate patches below, none approved
- **`evaluation`**
  - Slowing Zone: Provisional Slow zone calculation in [§4.5](#calibration-examples); passive availability `none`, combination 0; unlock conditions pending
  - Beast Jab: Provisional Beast Jab calculation in [§4.5](#calibration-examples); passive availability `none`, combination 0; unlock conditions pending
  - Delayed Burst: Provisional residue-free Surge calculation in [§4.5](#calibration-examples); passive availability `none`, combination 0; unlock conditions pending

**Paper checks, not executed tests:**
- Beast Jab from (3,3), `d = (1,0)`: only (4,3), 2 monster damage even to an ally, no extra Kin effect/Reach cast.
- Burst at (3,3): marks (2,3)/(3,3)/(4,3), evaluates occupants only at caster's next turn start. Leaving avoids damage; death does not cancel; air unaffected. Surviving ground stays unchanged, no invented residue consumption of Hallowed. Leaving/protection/air provide at least three live counters.

**Upgrade candidate choices — all DRAFT, not balance approval or unlocks.**

- Patches use the same schema and must pass §4.6.
- Each offer is an alternative, not automatically cumulative; no level requirements or EP prices are assigned; upgrade limits: [§4.6](#46-slot-levels-development-replacement-and-upgrades).

| Reference | Same-AP candidate choice | Optional higher-AP candidate choice |
|---|---|---|
| Slowing Zone | At 1 AP: choose fixed vertical I3 (`offsets: [[0,-1],[0,0],[0,1]]`, orientation vertical), or `persistence.duration: 3` (the +1 total cap); other fields unchanged | At proposed 2 AP: choose fixed T4 (`offsets: [[-1,0],[0,0],[1,0],[0,1]]`, centre junction anchor, count 4), keeping duration 2 and the same slow formula |
| Beast Jab | A meaningful 2-AP Beast development offer remains unresolved under [temp_todo.md](temp_todo.md) T02/T05. No lawful larger shape exists at this price in §3.2; selecting a direction is baseline use, not an upgrade. This reference does not claim a completed same-AP path | Existing Thrust at 3 AP: `shape: Thrust`, offsets `[d, 2d]` for selected cardinal `d`, count 2, solid-prop blocking unchanged; damage 2 and Beast's lack of an additional Kin effect unchanged. Optional branch, never required |
| Delayed Burst | At proposed 1 AP: choose fixed L3 (`offsets: [[0,-1],[0,0],[1,0]]`, junction anchor, count 3); other fields unchanged | At proposed 2 AP: choose fixed T4 with the offsets/anchor above, count 4; damage 3, delay, recipients and `board_changes: []` unchanged. This is not Major Surge access; Swarm cannot use either 3/4-cell reference |

- **Status:** calibration/same-AP development incomplete ([temp_todo.md](temp_todo.md) T02/T05); order/large bodies remain T04/T09. Residue is a board component, not combination surcharge (§4.5); residue-free references do not replace [concrete profiles](#surge).
- **Resolution:** resolve all definitions/required parameters before validation (§4.2–§4.7). No skill override of fixed fields; rules determine effect/operation order, never field-list position. Unsupported/unspecified cases remain central TODO.
- **Upgrades:** authorized named-field patches with prerequisites/exclusions/budget/AP consequences (§4.6), not another schema. Revalidate profile, Kin/species access, execution, placement, footprint, effect/trigger legality, persistence, interactions, usage and budget. No cooldowns/mana/aspect/attunement; upgrade limits: §4.6.

#### Non-Area and Passive Coverage References

**Additional reference coverage:**

- These three records use exactly the same field groups as the preceding three.
- **Run** records an existing preset for a legal user; **Focus** is a new, unapproved self-buff proposal; **Adaptive** is a structural transcription of the existing passive candidate, not a finalized learn-list/upgrade/balance approval.
- Names below are documentation references, not runtime identifiers.

Cases per field below: **Run reference**; **Focus self-buff reference (DRAFT)**; **Adaptive passive reference (DRAFT content)**.

- **`metadata`**
  - Run: `id: run_reference`; name Run; `kind: move`; `rule_profile: run`; tags movement
  - Focus (draft): `id: focus_reference`; name Focus; `kind: utility`; `rule_profile: none`; tags buff
  - Adaptive (draft content): `id: adaptive_reference`; name Adaptive; `kind: passive`; `rule_profile: none`; tags shape
- **`access`**
  - Run: Species learns Run and Kin/preset access permits it (§3.3); no grant to Step-only users
  - Focus (draft): One authored species learn-list; exact species/progression pending; exclusivity grants no extra budget
  - Adaptive (draft content): Authored species learn-list and legal active/passive slot; concrete list pending
- **`usage_type`**
  - Run: `active`
  - Focus (draft): `active`
  - Adaptive (draft content): `passive`
- **`execution`**
  - Run: Player action; legal-movement condition; immediate movement resolution
  - Focus (draft): Player action; caster alive/able to act; immediate application
  - Adaptive (draft content): `activation: while_equipped`; active while owner participates in battle and the skill occupies a legal slot; continuous rule evaluation, not a repeatedly cast action
- **`targeting`**
  - Run: Self mover plus player-selected legal path/destination; distance source Movement, not Reach; Run preset sight/path rules
  - Focus (draft): `type: self`; no distance or LOS check
  - Adaptive (draft content): `type: none`; owner bound by equipment, no player-selected recipient
- **`placement`**
  - Run: Caster origin, selected walk path/destination, existing Run path/landing rules; no persistent board placement
  - Focus (draft): `none`; buff attaches to caster, not its tile
  - Adaptive (draft content): `none`; permission belongs to owner, not a board tile
- **`area`**
  - Run: `none`; a movement path is traversal, not a damage/zone footprint
  - Focus (draft): `none`
  - Adaptive (draft content): `none`; modifying another skill's orientation does not create an area
- **`effects`**
  - Run: Typed self `movement`, Run preset, distance effective Movement (minimum 1); once at action resolution; owner's legal layer; no retained state/stack; process walk entry effects under existing rules
  - Focus (draft): Typed `stat_change`: effective Initiative +1 to self in its legal layer; apply at resolution; bind to `focus_state`; proposed same-skill/same-owner group refreshes duration, never adds magnitude; cross-source stacking/removal/death policies pending
  - Adaptive (draft content):
    - Typed `rule_modifier`: permit owner to rotate otherwise fixed tetris shapes when previewing/casting its own eligible skills
    - self scope in owner's legal layer
    - activation while equipped
    - boolean/idempotent permission, not extra magnitude
    - does not change Strike direction rules or authorize other profile changes
- **`persistence`**
  - Run: `none`; action completes after traversal/landing
  - Focus (draft): `focus_state`: proposed 2 rounds, tick round end, remove modifier at 0; exact queue application follows normal round initiative recalculation; other termination policies pending
  - Adaptive (draft content): `adaptive_permission`: while owner participates in battle with this passive equipped; ends when that condition fails/battle ends; no round counter
- **`board_changes`**
  - Run: `[]`; entry-triggered board reactions remain ordinary runtime rules
  - Focus (draft): `[]`
  - Adaptive (draft content): `[]`
- **`interactions`**
  - Run: Walk; blocked by solid props, monsters and charging Surges; height allowed; ground costs apply; distance modifier 0; legal destination required; air/2×2 remain T09
  - Focus (draft): No placement/path blocking; no air attack or ground interaction is introduced by a self-bound modifier
  - Adaptive (draft content): Affects only owner's authorized shape orientation choice; no targeting, footprint, layer or terrain exceptions
- **`usage`**
  - Run: Existing 2 AP; ordinary action repetition; no cooldown/mana
  - Focus (draft): Proposed 1 AP; ordinary active-action repetition; recasting refresh is only a draft policy, not a finalized balance rule
  - Adaptive (draft content): `ap_cost: none`; no active cast or player-action repetition; no separate activation button
- **`upgrades`**
  - Run: None approved; existing movement-upgrade limits still apply; full three-level path pending T05
  - Focus (draft): None approved; may explore bounded duration/secondary effects, not direct damage/AP/range upgrades; full path pending
  - Adaptive (draft content): None approved; passive development/active-passive replacement remain T05; no automatic extra permission from slot level
- **`evaluation`**
  - Run: [Movement cost reference](#movement-costs); passive availability `none`, combination 0; unlock/content/development validation pending
  - Focus (draft): [Self-buff cost reference](#self-buff-and-passive-costs); passive availability `none`, combination 0; content/stacking/development validation pending
  - Adaptive (draft content): [Passive rotation cost reference](#self-buff-and-passive-costs); AP efficiency `none`, combination 0; content/interaction/development validation pending

**Six-case paper checks:**
- **Strike:** immediate body-relative Beast Jab, ground/air, no extra Kin effect, Reach targeting or zone lifetime.
- **Surge:** declaration ≠ delayed resolution; marker lifetime implies neither residue nor lasting damage.
- **Zone:** one cast/shared lifetime; continuous slow is no extra action/repeated damage.
- **Movement:** path/destination, not artificial area; entry retains ordinary board rules.
- **Self buff:** movement off the original tile does not remove self state; no tile placement/ground payload/`unique` effect. Round-end duration does not guarantee two personal turns; cross-source stacking/termination gaps block approval.
- **Passive:** equipped rotation is a scoped rule modifier, not AP-zero cast/separate schema. Identical boolean permissions grant no extra rotations/rule changes; author other passive interactions.

- **Coverage limits:** structural walkthroughs, not engine tests/content approval. Event-driven passives fit declared activation events/conditions, event-bound recipients and typed effects; resolve repetition/recursion/order before approval (T02/T04/T11).
- **Evaluation:** §4.5 owns [Calibration Examples](#calibration-examples), [Movement Costs](#movement-costs), [Self-Buff and Passive Costs](#self-buff-and-passive-costs). All six have initial calculations, none a complete three-level path; interaction/content gaps block full validation. Same evaluation fields throughout; `none` means inapplicable, not free unpriced advantage.

---

## 5. Passives

- **Slots/model:** passives occupy normal kit slots (§4.1), use §4.2 and spend no active AP; evaluate availability/trigger frequency (§4.5). Equipped availability does not mean continuous effect: explicitly define continuous, conditional or event-driven application.
- **Access:** species learnable list/individual (Epic+ extra slot, artifacts), within Kin/progression limits, never theme/aspect. 1 active + 3 passives is legal but weak.
- **Prior-draft candidates, not approved perks/Chapter-4 exceptions:** effects/access/interactions need T02/T04/T11 validation. Momentum damage, AP discounts, Crashlander collision wording and automatic movement/target selection remain unresolved; grant no damage/AP-reduction upgrades, new collision rules or unspecified tie-breaks.

**Terrain Identity:**

- Adaptive (may rotate its skill shapes in battle)
- Purifier (adjacent enemy zones lose 1 round at round end)
- Overgrowth (your zones start at level II).
- Native Ground, Painter, Trailblazer and Deep Roots remain non-mechanical placeholders after aspect removal ([temp_todo.md](temp_todo.md) T11); no replacement effects or values are established.

**Position & Movement:**

- Highlander (+2 init on Elevated)
- Turret (can't move, +1 Reach)
- Skittish (free 1-square move after taking Surge damage — to the safest free neighbour)
- Phasing (moves through props)
- Momentum (after a max-distance move, the next Surge this turn deals +1)

**Displacement:**

- Crashlander (when pushed or pulled into a prop or monster, it takes no collision damage — the other side takes 1)
- Immovable (ignores push/pull)
- Counterweight (allies orthogonally adjacent to it can't be pushed or pulled)

**Combat:**

- Thick Hide (Strikes and collisions deal 1 less, min 0)
- Pack Hunter (Strike costs 1 AP less if an ally is adjacent to the target)
- First Blood (its first Strike each battle costs 1 AP less)
- Vengeful (after taking Surge damage, its next Strike costs 1 AP less)
- Scavenger (heals 1 when a prop within its Reach shatters)
- Frenzy (+1 shape cell at 1–2 HP)
- Bulwark (team: allies orthogonally adjacent to it take 1 less Surge damage)

**Ground & Zone Resistance:**

- Sure-footed (ignores `slow`)
- Clear Mind (ignores `drain_*`)
- Heatproof (ignores Lava)
- Thornwalker (ignores Thornbed)
- Void-touched (ignores Blight) — the unit-level way of shrugging a specific effect.

---

## 6. Roster

### 6.1 First Roster Draft — 9 monsters

**Non-authoritative prior-draft ideas:** no skill/access/cost specification, blueprint catalogue or approved damage/range exceptions. Names, old twists, passives, descriptions and overfilled loadouts grant no Chapter-4 exceptions; retain for later validation, not implementation/redesign here. Rebuild under §4.2–§4.7; species access: §4.3/§4.1.
- **Reference individuals:** shape belongs to individuals (§1.1); these are typical species rolls at **Core Formation High**, each spending exactly 16 points within frame (caps HP 8, Init 9, TPR 2, Move 5, Reach 3, AP 3; §2.2–2.3).
- **Legacy loadouts:** movement (§3.3) + Kin Strike (§3.2) + Surge + utility = 4 slots, plus table passive. Under the [current kit rule](#41-the-kit), passives need their own slot: these are not finalized legal kits. Forge Golem uses only Step and takes a second utility.

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

- **Ownership:** §4.6 exclusively defines permanent slot development, shared EP, pill replacement, patches and AP policy; costing §4.5, model/references §4.2/§4.7.
- Rarity/progression tables retain working values, not new slot ranks/prices or validated EP awards.

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
- **High mechanics are Rare+ territory by design:** Air layer and 2x2 need Soul, TPR 3 needs Soul, the Ancient's Major Surge needs Sovereign.
  - A Normal monster (max Core) has no Soul-tier air/2×2 or TPR-3 access; TPR 2 is already possible from Foundation (§7.4)
- Rarity does **not** decide the stat shape: any rarity can roll any shape (weighted by Kin lean, §1.1)
- Shared EP spending, superseded per-skill prices and replacement rules: §4.6. This table supplies only rarity/progression working data, not slot-development prices.
- Offered counts and EP income in the table are legacy working values, not a validated budget for the shared system.

### 7.3 Rarity Ascension

- A **major event**, not a grind: rare material + ritual (bloodline awakening), story-flavored
- **Ingredients:** one **Bloodline pill** (Rare+ beast part of this Kin + next-tier herb), plus ritual. Items: [Overworld §6.6](gdd_overworld.md#66-pills--medicines); acquisition: [§7.8](gdd_overworld.md#78-acquisition-sources); ritual logistics: [§2.6](gdd_overworld.md#26-action-catalog). Location remains unresolved ([temp_todo.md](temp_todo.md) T30), not an implied Aspect Altar.
- On ascension: unlock new rarity's slots/caps, keep everything else
- **Hard cap:** Normal can climb to Epic but never Legendary — true Legendaries remain rare finds

### 7.4 Monster Progression: the 18 Steps

- **18 steps:** six stages × three sub-tiers. Sub-tiers grant freely allocated stat points within ceilings; stages open skills/mechanics.
- Monsters exceed neither player's step nor rarity's max stage (§7.2). Player/monsters share this table; player XP bars may differ later.

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

- **Evolution step** = the monster earns the EP of its rarity (§7.2): 1 for Normal / Rare, 2 for Epic / Legendary.
  - Normal reaches Core (steps 4 and 7: only 2 EP under the old supply, which must be reviewed for shared slot/physical evolution), Rare reaches Soul (3 steps), Epic Immortal, Legendary Sovereign.
  - Immortal and Sovereign give choices instead of numbers
- **Learnable skills:** the species list grows with the stages (4 defaults + 1 per breakthrough from Foundation to Immortal = 8). Kit access and replacement/development rules: §4.1/§4.6
- **Why not points at Immortal / Sovereign:** the stat ceilings and the damage law are reached; more points would only be number inflation (pillar 1)

**XP proposal** (prototype bars: Lower 60, Middle 120, High 200):
- Bars grow ≈×2.5/stage; a sub-tier takes roughly 3–6 focused days at the right stage.
- **Cultivation pill:** ≈half its tier's Lower bar (Qi +30 as in prototype, Foundation +80, Core +200, Soul +500, Immortal +1200).
- **Win:** Qi 10 XP, ×2.5/stage. **Cultivation-spot night:** small gain; Meditation Stone ≈one tenth of a win, Qi Spring double.

Breakthrough trials: [Overworld §6.3.1](gdd_overworld.md#631-breakthrough-trials).

---

## 8. Design Tracking

Open decisions, dependencies and validation live only in [temp_todo.md](temp_todo.md). Source pointers, not another task list:
- Incomplete skill contracts/costs/development: T02/T05; runtime reconciliation: T04/T07–T09; passive/species/roster: T10–T12.
- Loadout/tamer: T18–T20; ritual logistics: T30; Major/Signature access: T32; document synchronization: T35.

The confirmed removal of fixed monster aspects, the Force/Nature/Dark triangle and attunement overrides older proposals. Other proposals remain working design pending review.
