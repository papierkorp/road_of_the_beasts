# GDD — OVERWORLD & META
*Working Draft v0.10 · synced with gdd_battle.md **v6.1** (battle GDD is the source of truth for all battle rules, stats and skills)*

---

## 1. Overview

A **management + cultivation layer** wrapped around deterministic grid battles (see gdd_battle.md), set in a wuxia world. The player is a disrespected beast tamer in a great clan who builds a business empire in the city and cultivates toward immortality.

### 1.1 Setting & Player Fantasy

- Wuxia world; the player is a **beast tamer** with a spatial space inside their body that houses monsters — higher cultivation = larger space = more monsters
- Based in a great city held by five powers (§3.2): **3 cultivation families**, the **City Lord** with the City Guard, and the **Merchants' Guild**; the player belongs to one of the families but is **poorly regarded** within the clan
- The player cannot leave the city (at launch) — travel arrays teleport to dungeon regions
- Core fantasy: **the disrespected genius** — win fights you're "supposed" to lose through tactics, build a faction the clan can't ignore through commerce

### 1.2 Design Pillars

1. **Progression is horizontal, not vertical** — stage-ups unlock new *kinds* of play; numbers stay small and hard-capped
2. **Money buys speed and breadth, never exclusive power** — the best things are earned through battles, favor, and story
3. **Decisions are free, execution costs** — AP is spent on doing, never on looking, walking, or thinking
4. **One design language** — battle turns, city days, and building layouts all reward planning under visible constraints
5. **Everything feeds power or story** — any management feature that outputs neither gets cut
6. **Archetypes over uniques** — businesses, materials, structures, items: build the schema once, ship content as configurations
7. **Choices, not damage** — a monster starts with the stats of its stat shape; after that the player spends every level-up's stat points themselves, inside the shape's frame and the stage ceilings (§5.2). Skills, twists and gear add *options*. Nothing outside battle ever raises Surge, Strike or ground damage

---

## 2. Game Loops

The game runs on five loops, from the shortest to the longest. Each one feeds the next: battles bring loot and monsters → business turns loot into money and favor → money and favor fuel cultivation → cultivation unlocks harder battles and bigger business.

|      Loop       |        Time scale        |              Output              |
|-----------------|--------------------------|----------------------------------|
| **Battle**      | minutes (one fight)      | XP, loot, catches                |
| **Expedition**  | one AP (a dungeon run)   | materials, monsters, HP lost     |
| **Day**         | one turn of the game     | everything resolved at night     |
| **Cultivation** | many days (a story arc)  | new stages, stat points, unlocks |
| **Economy**     | whole game, runs in parallel | money, favor, goods          |

Every loop is described in the same format: one sentence, the flow from start to end, the actions with their costs, then the rules.

### 2.1 Battle Loop

The overworld prepares a closed, deterministic fight and reads its result (rules: gdd_battle.md).

1. The encounter sets the mode, the board and the enemy team
2. Pre-battle: the player picks the team and the **battle loadout** (tamer skills, medicines, arrays) and sees both teams' full sheets
3. Monsters and loadout resolve into finished **unit sheets**; the fight starts
4. Rounds run until one side has no monsters left (gdd_battle §2.1)
5. The battle returns facts: winner, HP left per monster, kills
6. The overworld turns those facts into XP, loot and catches

|         Action         |               Cost               |                              Notes                               |
|------------------------|----------------------------------|------------------------------------------------------------------|
| Step                   | 2 AP                             | 1 square, every monster                                          |
| Movement skill         | 2 AP                             | squares = Movement stat, modes by Kin (gdd_battle §5.5.3)        |
| Cast a zone / terrain  | 1 AP                             |                                                                  |
| Declare a Surge        | 1 AP                             | one charging Surge per monster                                   |
| Self skill             | 1 AP                             |                                                                  |
| Strike                 | 2 AP                             | target must be within Reach                                      |
| Major Surge            | 2 AP                             | once per battle                                                  |
| Tamer skill            | free, once per battle            | only slotted skills (§6.4)                                       |
| Medicine *(planned)*   | 1 medicine from the loadout      | consumed; timing and limit open (§9)                             |
| Array *(planned)*      | 1 array from the loadout         | changes squares in battle; consumed or reusable open (§9)        |

- **No hidden information:** the full sheets and the loadouts of both sides are known before the battle starts (gdd_battle pillar 6). Wild monsters telegraph kin / aspect in the world; the exact sheet is visible when you engage
- **The loadout is fixed before the battle.** In battle the player decides *when* to use it, never *what* is in it. Everything in it is deterministic and shows in the preview
- **Resources can be used up in battle:** medicines and some arrays are consumed, tamer skills are not
- **The battle only sees the unit sheet** and the loadout, never "this is level X so it gets Y"
- **The battle returns facts, not rewards:** the overworld decides what they are worth
- Choosing the team and inspecting sheets is free (§2.3)

### 2.2 Expedition Loop

A dungeon run turns AP and HP into materials and monsters.

1. Pick a dungeon at the Teleport Array and pay the AP
2. Walk the room, read the wild monsters
3. Engage: pre-battle, then the Battle Loop
4. Collect loot, heal, pick the next door
5. Repeat until you teleport out or the team is beaten
6. Back in the city, the day goes on

|         Action          |      Cost      |                          Notes                          |
|-------------------------|----------------|---------------------------------------------------------|
| Start an expedition     | 1 AP           | includes all its battles                                |
| Start on a deeper floor | 2 AP           |                                                         |
| Walk, inspect monsters  | free           |                                                         |
| Ambush from behind      | free           | +1 round-1 initiative (`Battle.AMBUSH_BONUS`)           |
| Heal between battles    | 1 healing pill | the only way to restore HP inside a run                 |
| Teleport out            | free           | ends the run, keeps the loot                            |

- **HP persists** between the battles of a run; a battle starts at current HP. Pills are logistics
- Wild monsters are visible, no random encounters. Being caught from behind gives the monster the same bonus
- The dungeon node fixes the battle mode and the number of wild monsters (§3.3)

### 2.3 Day Loop

A day is one turn: spend AP in the city, the night resolves everything at once.

1. Day starts with N AP (start: 3, grows with cultivation stage)
2. Spend AP on the actions below, in any order
3. End the day by hand or when AP run out
4. **Night:** businesses produce, staff report, plants grow a tick, monsters gain idle XP, market prices shift, events roll (sabotage, visitor, clan summons)
5. Morning results screen → new day

|         Action       | Cost |                            Notes                           |
|----------------------|------|------------------------------------------------------------|
| Dungeon expedition   | 1 AP | deeper floors 2 AP (§2.2)                                  |
| Cultivate            | 1 AP | progress player XP toward the next sub-tier                |
| Train a monster      | 1 AP | focused XP / perform a skill evolution                     |
| Work a business      | 1 AP | personally boost one facility (craft batch, run shop)      |
| Deal / Negotiate     | 1 AP | bulk trade, recruit staff, faction favor actions, auctions |
| Build                | 1 AP | place / construct in the Internal World or on a property   |
| Story / Social event | 1 AP | clan meetings, investigations, key NPC scenes              |
| Everything else      | free | see the golden rule                                        |

- **Golden rule: decisions are free, execution costs.** Walking, dialogue, browsing, assigning staff, queueing production, rearranging the Internal World, choosing the battle team, inspecting sheets, spending stat points: all free. Never punish looking around
- **Nothing is time-critical:** quests expire in days, they never force specific actions. Thinking time is the player's luxury
- No visual clock: day = bright city, night = results screen
- The night is the single synchronization point of all systems: save-friendly, no real-time simulation

### 2.4 Cultivation Loop

XP turns into sub-tiers, sub-tiers into stat points, breakthroughs into new mechanics.

1. Battles, pills and cultivation actions fill the XP bars (player and each monster)
2. Full bar = sub-tier up (Lower → Middle → High); a monster gets **stat points** to spend (§5.2)
3. At High, a breakthrough trial / ritual leads to the next stage
4. The stage-up unlocks mechanics (bigger teams, evolutions, air layer, tamer slots), expands the Internal World, raises the stat ceilings, opens deeper dungeons

|               Action               |            Cost            |                           Notes                           |
|------------------------------------|----------------------------|-----------------------------------------------------------|
| Cultivate (player XP)              | 1 AP                       |                                                           |
| Train a monster (focused XP)       | 1 AP                       |                                                           |
| Win a battle                       | free                       | XP for the team                                           |
| Take a cultivation pill            | 1 pill                     | chunk of XP (prototype: +30)                              |
| Assign a monster to a spot         | free                       | idle XP every night                                       |
| Spend stat points                  | free                       | inside the shape's frame and the stage ceilings (§5.2)    |
| Evolve a skill                     | 1 AP                       | at the Evolution Pillar (§5.4)                            |
| Breakthrough                       | 1 AP + materials           | prototype: 5 materials (player) / 3 (monster)             |
| Take back evolutions               | 1 AP + materials           | prototype: 4 materials of the monster's aspect            |

- **Ceiling rule:** a monster cannot exceed the player's stage
- A level-up never raises damage (§6.9), it moves stats and opens choices
- Stage-ups are the reward structure: one new mechanic per breakthrough (§6.3)

### 2.5 Economy Loop

Business turns what dungeons bring into money, and money into speed and breadth.

1. **Acquire:** dungeons, buying, catching, recruiting
2. **Process:** refine, craft, train (time + input → output)
3. **Sell:** shop, Guild auction, contracts
4. **Reinvest:** cultivation resources, rituals, artifacts, staff → deeper dungeons → better materials → bigger business

|               Action                |            Cost             |                          Notes                          |
|-------------------------------------|-----------------------------|---------------------------------------------------------|
| Run a dungeon                       | 1 AP (2 AP deeper)          | materials and monsters                                  |
| Buy / sell single goods at a trader | spirit stones, no AP        | prices drift every night                                |
| Bulk trade, consign to the auction  | 1 AP (Deal)                 |                                                         |
| Recruit staff                       | 1 AP (Deal) + favor         |                                                         |
| Work a facility                     | 1 AP + input materials      | runs at once                                            |
| Queue a facility                    | free + input materials      | resolves at night                                       |
| Shop sales                          | free                        | resolve at night                                        |
| Build a structure                   | 1 AP + materials / stones   | §4.2                                                    |

- **Business is the engine, battles are the gate.** Deeper floors need battle skill, better business needs deeper floors. Neither loop works alone
- **Staff replace AP:** early game the player does everything personally, later staff run Process and Sell at night (§7.1)
- **Spirit stones buy speed and breadth**, never things battles can't earn (§7.7)

---

## 3. Overworld

The outside world: the city and the dungeons behind its teleport arrays. Economy and story live here.

### 3.1 The City

- The player **cannot leave the city** (at launch); travel arrays / long-range teleports lead to self-contained dungeon regions (deserts, mountains, forests)
- **District-based, not open world:** each district = one small handcrafted 3D scene, same iso camera and art pipeline as battles
- **All selling, quests and contact with other people happen here**; the Internal World can't reach the outside (§4)
- The player's active monster follows them: walking the market with a Magma Drake behind you is the status fantasy, for free

|         District        |              Player access              |            Held by            |
|-------------------------|-----------------------------------------|-------------------------------|
| **Clan Compound**       | yes, from the start                     | the player's family           |
| **Rival Compounds** (2) | no; by invitation or favor              | one rival family each         |
| **City Lord's Keep**    | outer court yes, inner hall by favor    | City Lord & City Guard        |
| **Market District**     | yes, from the start                     | Merchants' Guild              |
| **Business District**   | yes; a property needs a license         | Merchants' Guild *            |
| **Arena**               | yes, from the start                     | City Lord *                   |
| **Teleport Plaza**      | yes, from the start                     | City Lord *                   |
| **Slums**               | yes, from the start                     | neutral (no faction)          |

\* proposal, see §9. Built so far: Teleport Plaza, Market District, Clan Compound.

#### 3.1.1 Clan Compound

The player's home base, and where the clan looks down on them.

- **Clan Hall** — clan meetings, summons, Family favor
- **Notice Board** — requests and quests *(built)*
- **Clan Envoy** — Family favor actions *(built)*

#### 3.1.2 Rival Compounds

Closed to the player at first; entering one is a story and favor beat. Buildings open until the families are defined (§9).

- **Family Hall** — favor actions and quests of that family

#### 3.1.3 City Lord's Keep

Law and order of the city.

- **Audience Hall** — City Lord favor, Street Trade Permit
- **Guard Barracks** — beasts for hire
- **Watch Post** — City Guard requests; also stands at the Teleport Plaza *(built there)*

#### 3.1.4 Market District

Where goods change hands.

- **Trader** — buy and sell, drifting prices *(built)*
- **Guild Factor** — Guild favor, discounts, Production License *(built)*
- **Guild Hall** — rare blueprints, contracts
- **Auction Hall** — consign goods, rare invites (§7.1)

#### 3.1.5 Business District

The player's properties. Every commerce building stands here.

- **Pill Stall / Shop** — sells goods at night
- **Monster Hall** — sells trained beasts
- **Dojo** — trains disciples, the faction pipeline
- **Dungeon Company** — sends staff on expeditions
- **City workshops** — production buildings run by staff (§4.2)

#### 3.1.6 Arena

Public fights.

- **Arena Ring** — tournaments, 5v5 special battles, favor from wins
- **Ranking Board** — opponents and rewards

#### 3.1.7 Teleport Plaza

The hub of the city; every district connects here.

- **Teleport Array** — expeditions to the dungeon regions *(built)*
- **Meditation Pavilion** — entry to the Internal World *(built)*
- **Watch Post** — City Guard requests *(built)*

#### 3.1.8 Slums

A place outside the city's order: no faction and no favor to earn, for now.

- **Black Stall** *(idea)* — odd goods; stays optional until the Slums get a purpose (§9)

### 3.2 The Powers of the City

Five powers hold the city. Each one is a favor faction (§7.2):

|           Power            |                       Role                       |                                 Offers                                 |
|----------------------------|--------------------------------------------------|------------------------------------------------------------------------|
| **The player's family**    | great clan that looks down on the player         | respect for power, bloodlines                                          |
| **Two rival families**     | cultivation families competing with the player's | open (§9)                                                              |
| **City Lord & City Guard** | law, peace and order in the city                 | Street Trade Permit, beasts for hire                                   |
| **Merchants' Guild**       | runs trade, the market and the **auction hall**  | Trader discounts, rare blueprints, Production License, auction invites |

### 3.3 Dungeons

- **Dungeons:** wild monsters roam visibly (no random encounters); touching = battle. Each node is a room, the doors lead to the next nodes (flow and costs: §2.2)
- Dungeon monsters are full **individuals** (own stat shape, stage, evolutions) and telegraph kin / aspect visually; their complete sheet is shown in the pre-battle screen → informed roster picks and counter-picks
- A dungeon node fixes the **battle mode** (1v1 / 2v2 / 3v3 / 5v5) and the number of wild monsters; the board follows the generation rules of gdd_battle §4.1

---

## 4. Internal World

The cultivator's spatial space, where monsters live: the pause menu made physical. It serves **the tamer's own power**: training monsters, growing medicine, producing goods, preparing the team.

**It cannot communicate with the outside world.** Nothing that needs other people works in here: no shops, no selling, no quest or faction buildings. Goods made inside are carried out by the player. That also means **no staff in here** for now: production inside runs on the player's own work and standing orders.

### 4.1 Functions

- Monsters walk around freely; the collection is *visible and alive*
- **Grows with cultivation:** Qi Gathering = barren rock → Foundation = grass, pond → Core = forests, structures; each stage physically expands buildable area
- **Roster:** capacity grows with stage / sub-tier (1 → 3+ → 5+ → ...); the **pre-battle draft / counter-pick happens here** — pick your team from the owned monsters for the mode the encounter demands (at Core+ the bench is bigger than the team)
- **Passive:** cultivation spots (assign monster → idle XP at night), growing plots (plant the correct seed → medicinal herbs, §7.5)
- **Monster management:** inspect stat shape, spend stat points, assign evolutions, equip artifacts — all free (only the evolution ritual itself costs AP)

### 4.2 Building System

Everything placeable in the Internal World is a **Structure**; blueprints are one acquisition path among several.

```
STRUCTURE
  name, size (grid footprint), category
  source     : blueprint (craft w/ materials) | buy | quest/story reward
  aspect     : Force | Nature | Dark | None    ← affinity bonuses
  level      : upgradeable with materials
  placed_on  : internal world grid cell
```

- **Coarse grid placement**, free to move anytime, structures never lost
- **Adjacency bonuses** make layout a real puzzle: herb plot + water = -1 grow night; Dark monster housed near Dark altar = +XP

|      Structure       |   Category  |                             Function                             | Built |
|----------------------|-------------|------------------------------------------------------------------|-------|
| Meditation Stone     | Cultivation | assigned monster gains idle XP at night                          |   ✓   |
| Qi Spring            | Cultivation | stronger idle XP, counts as water                                |   ✓   |
| Herb Plot            | Growing     | plant seeds → grow N nights → harvest herbs                      |   ✓   |
| Spirit Tree          | Growing     | slow, high-tier herbs                                            |       |
| Nest                 | Housing     | +capacity, kin-matched = mood / loyalty bonus                    |       |
| Cave                 | Housing     | +capacity, kin-matched = mood / loyalty bonus                    |       |
| Shrine Grove         | Housing     | +capacity, kin-matched = mood / loyalty bonus                    |       |
| Refining Furnace     | Production  | materials → pills and medicines                                  |   ✓   |
| Array Workshop       | Production  | materials → arrays                                               |       |
| Artifact Forge       | Production  | materials → artifacts                                            |       |
| Spirit Pond          | Special     | water for adjacency                                              |   ✓   |
| Aspect Altar (×3)    | Special     | +XP for monsters of its aspect nearby; rarity ascension site     |   ✓   |
| Evolution Pillar     | Special     | skill evolution ritual site                                      |   ✓   |
| Trial Pillar         | Special     | breakthrough rituals                                             |       |

Production structures may stand **inside or on a city property** (§7.1). Commerce and quest buildings are city only (§3.1).

---

## 5. Monsters

How a monster's sheet comes to exist: the individual, its stats, evolutions and rarity. What the finished sheet does in a fight — stats, Kin, Aspect, skills, the roster — is the job of **gdd_battle.md** (§3 and §5 there). The battle only ever sees the finished unit sheet (§2.1).

### 5.1 The Individual Monster

A monster the player owns is **two layers**: a fixed *species* and a unique *individual*.

```
SPECIES  (data file, shared by all individuals — gdd_battle §3.8)
  Kin · Aspect · default kit (4 active skills, Surge type from aspect, shape + twist
  from species) · learnable skills · species passive · blurb · art

INDIVIDUAL  (one per monster the player owns or meets in the wild)
  stat shape      glass cannon | anvil | skirmisher | berserker | balanced | fragile
  stats           rolled inside the shape's frame, then spent by the player (5.2)
  rarity          Normal | Rare | Epic | Legendary
  stage + sub-tier + XP
  evolutions      the paths picked for its skills (5.4)
  artifact(s)     socketed passives (6.7)
  current HP      persists between battles of an expedition
```

- **The stat shape belongs to the individual, not the species.** Two Blaze Tigers can be a fast skirmisher and a hard-hitting berserker — same Surge, different playstyle. Collection depth without new art.
- The species' **Kin leans** towards certain shapes (gdd_battle §3.6 "stat lean": Winged → glass cannon, Ancient → anvil, …). A wild or newly caught monster **rolls its shape weighted by that lean**, so a rare off-lean individual is a prized find. The monsters listed in gdd_battle §3.8 are the **reference individuals** (the typical roll at Core Formation).
- **Every stat is paid for** (§5.2): the shape only decides *where* a fixed stat budget may go. A fast shape gets less HP, a slow shape gets it back in HP and Reach. No shape is strictly better.

### 5.2 Monster Stats: Frame, Budget, Level-Ups

A monster **starts** with stats rolled by its stat shape; **after that the player decides** where each level-up goes. Three rules keep this fair:

```
FRAME   the stat shape sets a min–max per stat: shapes stay readable, individuals differ
BUDGET  every monster of a stage and sub-tier has the same total of stat points
PRICE   stats cost points: a strong stat is paid for with the others
```

**Stat prices.** Every monster gets the base values for free; each point above them costs:

|   Stat   | Base | Price per +1 |
|----------|------|--------------|
| HP       |    1 |            1 |
| Init     |  1.0 |  see below   |
| Movement |    1 |            1 |
| Reach    |    1 |            3 |
| AP       |    2 |            3 |
| TPR      |    1 |            5 |

**Budget per stage and sub-tier** (total points above the base values):

|        Stage        | Lower | Middle | High |
|---------------------|-------|--------|------|
| Qi Gathering        |     4 |      5 |    6 |
| Foundation          |    10 |     11 |   12 |
| Core Formation      |    14 |     15 |   16 |
| Soul Tier and above |    18 |     19 |   20 |

So a sub-tier up gives **+1 stat point**, a breakthrough **+2** (**+4 into Foundation**, because TPR 2 opens there). Immortal and Sovereign add no points: the absolute scale is reached, those stages only unlock mechanics (§6.3).

**The six frames at Core Formation** (min–max):

|    Shape     |  HP |  Init | Move | Reach | TPR |  AP |                              Feel                              |
|--------------|-----|-------|------|-------|-----|-----|----------------------------------------------------------------|
| Glass cannon | 1–3 | 7–9   | 1–3  | 1     | 2   | 2   | commits fast, dies if its Surge is cut away                    |
| Anvil        | 6–8 | 1–4   | 1–2  | 1–2   | 1   | 2–3 | slow, hard to dislodge, threatens a radius it can't leave      |
| Skirmisher   | 3–5 | 5–8   | 3–5  | 1     | 1   | 2–3 | never in its own Surge when it fires                           |
| Berserker    | 4–6 | 5–7   | 1–3  | 1     | 2   | 2   | escalates one Surge with Empower; TPR 3 opens at Soul          |
| Balanced     | 4–6 | 4–6   | 2–3  | 1–2   | 1   | 2–3 | no weakness, no spike — the kit decides                        |
| Fragile      | 2–4 | 5–7   | 1–3  | 1–2   | 2   | 2   | weak body, many turns; lives on its Surge                      |

**Init has two rates:** at the roll 1 point = **1.0 Init**, so a fast shape pays for its speed with its other stats; the decimal (.0–.9) is rolled on top for free, below the frame's max. On a level-up 1 point = **+0.1 Init**: speed stays the identity of the shape, level-up points only fine-tune the queue. The budget counts points received, so every monster gets the same number whatever it buys.

Example, a Glass cannon at Core High (16 points): HP 2 (1) + Init 9 (8) + Move 3 (2) + TPR 2 (5) = 16.

- **Other stages scale the frame:** HP, Init, Movement and Reach limits are multiplied by *stage ceiling ÷ Core ceiling* (§5.3), rounded, min 1. TPR and AP limits are simply cut by the ceiling. Only the Berserker's TPR limit grows, to 3 at Soul
- **Rolled at the start:** a new or wild individual draws its stats inside the frame until the budget of its stage and sub-tier is spent. Two Anvils are never identical, but never stronger than each other overall
- **Spent by the player after that:** each level-up adds points, and the player spends them freely (free action). Only the frame's **max** and the stage ceiling limit this; the min only matters for the roll
- **Points can be saved.** Points that hit a limit stay unspent until a ceiling opens at the next breakthrough
- **Ceiling rule:** monsters cannot exceed the player's stage (the spatial space can only sustain what the tamer's qi can feed)
- **Tuning:** all prices, budgets and frames are a first version, calculated so that every shape can spend its budget at Core and Soul; they still need the battle simulation (`tools/sim.gd`)

### 5.3 Stat Ceilings per Stage

Each stage defines hard caps, no shape and no point can go above them:

|                                                  | Qi Gathering | Foundation | Core Formation | Soul+ |
|--------------------------------------------------|--------------|------------|----------------|-------|
| Max HP                                           |            4 |          6 |              8 |    10 |
| Max Initiative                                   |          5.0 |        7.0 |            9.0 |  10.0 |
| Max TurnsPerRound                                |            1 |          2 |              2 |     3 |
| Max Movement                                     |            3 |          4 |              5 |     5 |
| Max Reach (Strike distance, see gdd_battle §3.2) |            1 |          2 |              2 |     3 |
| Max AP                                           |            2 |          2 |              3 |     3 |

The base stat ranges (HP 1-10, Init 0.1-10.0, TPR 1-3, AP 2-3) are the **lifetime scale of the entire game** — number inflation would kill the deterministic low-HP feel. The damage law (gdd_battle §6.1) is **never** scaled by stage: Surge base damage, Strike (max 2) and ground damage are the same at Qi Gathering and at Sovereign.

### 5.4 Skill Evolution — Variants over Numbers

Every active skill a monster has can **evolve**. At an evolution the player picks **one** path instead of getting flat number increases. Five path families exist; each evolution offers a few of them (how many, and how many you may take, depends on rarity — §5.5):

|           Family           |                                       What changes                                      |                                                                                         Rules                                                                                         |
|----------------------------|-----------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Shape**                  | other shape family or orientation, **same cell count**                                  | always free. Shapes stay fixed in battle                                                                                                                                              |
| **Size**                   | **+1 cell** (max 4 cells)                                                               | worth more than Shape: **counts as 2 evolutions** of that skill, so at the earliest with the second evolution (§6.3). A Surge also pays the Wide price (damage −1, gdd_battle §5.5.2) |
| **Twist** *(Surge only)*   | swap the Surge's twist, or add one to a baseline Surge                                  | at most ONE twist, each twist pays its own price (gdd_battle §5.5.2)                                                                                                                  |
| **Small value**            | zone lasts 3 instead of 2 rounds (zones only, max 3) · cast range +1 (max +1 per skill) | tiny, capped; **never raises Surge or ground damage**. No level-II start (that is the Overgrowth passive's job and would make a Veil shield 3 in one cast, gdd_battle §8 Double Veil) |
| **Swap**                   | exchange the skill for another one the species can learn                                | must respect the Kin's locked-out archetypes (gdd_battle §3.6)                                                                                                                        |

```
GLOOM RIFT (Surge, I3 vertical), evolve → pick ONE:
  a) Shape  — I3 → L3 (same cells, new territory)
  b) Size   — I3 → L4 (+1 cell, damage −1, counts as 2 evolutions)
  c) Twist  — baseline → Lingering (residue lasts 3 rounds, damage −1)
  d) Value  — cast range 3 → 4 (max +1)

MIRE (utility, T4), evolve → pick ONE:
  a) Shape  — T4 → L4 (same cells)
  b) Value  — duration 2 → 3 rounds
  c) Swap   — Mire → Grasping Shade (Dark Snare)
```

- Same species + different evolution picks = different playstyles → collection depth without new art
- An evolved skill is still **exactly one shape, one fixed orientation, one twist** — all battle rules stay valid; the preview shows the evolved skill like any other
- Evolution is a **Train** action (§2.3). Picks can be reversed through a ritual (cost open, §9) — "exchange, not just upgrade"

### 5.5 Monster Rarity

**Rarity = potential and flexibility, NOT raw power.** A Normal and a Legendary at the same stage are close in raw stats — the Legendary has more options and a higher ceiling.

|                                  |                       Normal                       |        Rare       |        Epic       |            Legendary            |
|----------------------------------|----------------------------------------------------|-------------------|-------------------|---------------------------------|
| Base kit                         | 4 active skills                                    | same              | same              | same (+ signature at max stage) |
| Passives                         | 1                                                  | 1                 | 2                 | 2                               |
| Evolution paths offered / picked | 2 offered, pick 1                                  | 3 offered, pick 1 | 3 offered, pick 2 | all offered, pick all           |
| Max stage reachable              | Core                                               | Soul              | Immortal          | Sovereign                       |
| Aspect                           | fixed                                              | fixed             | fixed             | can shift once                  |

- "Max stage reachable" is the core axis — the wuxia "noble bloodline" trope, long-term potential over instant power
- **No stat bonuses from rarity.** Soul+ caps already sit on the absolute scale (HP 10, Init 10.0, TPR 3, Reach 3, AP 3), so rarity buys slots, evolutions and ceiling — never numbers
- **High mechanics are Rare+ territory by design:** Air layer and 2x2 need Soul, TPR 3 needs Soul, the Ancient's Major Surge needs Sovereign. A Normal monster (max Core) stays grounded, single-turn-count and simple
- Rarity does **not** decide the stat shape: any rarity can roll any shape (weighted by Kin lean, §5.1)
- Offered / picked counts are a tuning start, not final (§9)

### 5.6 Rarity Ascension

- A **major event**, not a grind: rare material + ritual (bloodline awakening), story-flavored
- On ascension: unlock new rarity's slots/caps, keep everything else
- **Hard cap:** Normal can climb to Epic but never Legendary — true Legendaries remain rare finds

---

## 6. Progression

### 6.1 Cultivation Structure (shared naming, player & monsters)

```
STAGES     Qi Gathering → Foundation → Core Formation → Soul Tier → Immortal → Sovereign
SUB-TIERS  Lower → Middle → High   (per stage)
BREAKTHROUGH  High → next stage's Lower
```

### 6.2 Player Progression (3 layers)

```
1. STAGE       → unlocks mechanics (see 6.3)
2. SUB-TIER    → grows spatial space capacity
3. WITHIN      → cultivation XP bar (battles, story, resources)
                 full bar = sub-tier up
                 breakthroughs (High → next stage) gated by trials / story
                 events / rare resources — natural narrative beats
```

### 6.3 Stage Unlock Table

The **full kit is available from the first day** — 4 active skills and one passive. Battles must never feel starved of options. Progression adds *slots, choices and modes*, not the basic verbs.

|     Stage      |                            Monster unlock                            |                                     Player unlock                                      |
|----------------|----------------------------------------------------------------------|----------------------------------------------------------------------------------------|
| Qi Gathering   | full kit (4 active skills, 1 passive) · TPR 1 · AP 2                 | holds 1 monster · **1v1** (5×5)                                                        |
| Foundation     | first skill evolution · TPR 2 possible                               | holds 3+ monsters · **3v3** (7×7, standard) · **2v2** (6×6) · 1 tamer slot             |
| Core Formation | second skill evolution (Size path) · AP 3 · 2nd artifact slot at Epic+ | holds 5+ monsters (bench for counter-picks) · 2nd tamer slot · **5v5** special battles |
| Soul Tier      | Air layer access (Winged) · 2x2 size · TPR 3 possible                | mid-battle **Beast Swap** from the spatial space                                       |
| Immortal       | Dual-aspect monsters *(rules open)*                                  | 3rd tamer slot                                                                         |
| Sovereign      | Signature skills (Legendary) · Major Surge (Ancient, Legendary only) | full spatial arsenal                                                                   |

> Expansion features (bigger teams, air layer, 2x2, swap) **are** the reward structure — mechanics introduced one breakthrough at a time, solving the tutorial problem for free. Battle modes follow the team size the player can field; **which mode a fight uses is set by the encounter** (a narrow corridor node is a 1v1/2v2, a dungeon hall a 3v3, a tournament a 5v5), and the player needs at least that many monsters.

### 6.4 Tamer Skills

The five tamer skills of gdd_battle §5.11 (Spatial Pull, Qi Suppression, Spirit Shield, Domain Glimpse, Beast Swap) are **learned over the game** (story, rituals, favor) and **chosen before each battle** into the player's **tamer slots**.

- Slots: 1 at Foundation → 2 at Core Formation → 3 at Immortal (§6.3). Qi Gathering has none
- **Beast Swap** is a skill like the others but can only be slotted from Soul Tier
- Each slotted skill is **once per battle**, free, never consumed — the choice of slots is part of the pre-battle decision (and visible to the player's own preview; enemy tamers' slots are shown in their sheet)
- Sub-tier does **not** change a skill's strength. Tamer artifacts may adjust range or the numeric effect by +1 within the limits of §6.9, never the number of uses

### 6.5 The Balance Rule (Pills, Medicines, Artifacts, Arrays)

> **Pills fuel progression outside battle. Artifacts grant options, not numbers, inside battle. The battle loadout (tamer skills, medicines, arrays) is chosen before the fight, known to both sides, and may change the field during it.** Medicines and some arrays are used up, tamer skills are not (once per battle, free). Every effect is deterministic and shows in the preview.

All of these goods share one item schema (§7.6).

### 6.6 Pills & Medicines

|  Pill type   |                              Effect                              |              Role             |
|--------------|------------------------------------------------------------------|-------------------------------|
| Cultivation  | chunk of XP (player or monster)                                  | bread-and-butter product      |
| Breakthrough | required ingredient / removes trial penalty                      | stage-up moments              |
| Healing      | restore monster HP **between** battles                           | dungeon attrition supply line |
| Battle prep  | small buff for the *next 1 battle* (+1 init, first-hit immunity) | chosen at pre-battle draft    |
| Bloodline    | rarity ascension ingredient                                      | major rare sink               |
| Medicine *(planned)* | used **in** battle from the loadout, effect open (§9)    | consumed, feeds Producer      |

Healing pills create the **dungeon attrition loop**: HP persists between fights in an expedition → pills are logistics → deeper floors need better supply → feeds Producer. A battle always *starts* at the monster's current HP (never above its max).

### 6.7 Artifacts (equipment = socketed passives)

```
ARTIFACT = passive from the Passives Library (gdd_battle §5.10) + aspect + tier + (tiny capped stat mod)
```

Reuses the passive implementation — near-zero new code. Crafting = Producer picks which passive to forge in (recipe determines options). The unit sheet simply lists the species passive, the Epic+ passive and the artifact passive(s).

|       Wearer       |          Slots          |                                                                    Effects                                                                     |
|--------------------|-------------------------|------------------------------------------------------------------------------------------------------------------------------------------------|
| **Monster**        | 1 (2nd at Epic+ rarity) | extra passive OR +1 to one stat, **never above stage caps**                                                                                    |
| **Player (tamer)** | 2–3                     | tamer skill mods (+Spatial Pull range, Qi Suppression −3 instead of −2 — never extra uses), +1 AP once/day, +spatial capacity, dungeon utility |

Monster artifacts deepen the battle game; tamer artifacts feed the management/expedition game. A Normal-rarity beast with a perfect artifact-passive combo can rival an Epic — "skill beats stats."

### 6.8 Arrays (artifacts for places)

- Battlefield modifiers on home turf, deployed pre-battle or, *planned*, placed in battle from the loadout (§2.1). Battles start **neutral on purpose** (no monster born disadvantaged, gdd_battle §4.8), so arrays are the only thing allowed to break that — and the one deliberate exception to the mirrored-fairness rule of gdd_battle §4.1 — kept small: e.g. one or two squares start attuned to the owner's aspect, or one start square begins elevated
- Internal-world structure boosters, business protections

### 6.9 Hard Caps

- Artifact stat mods: **+1 max, never exceeding stage ceilings** — artifacts break ties, not tiers
- One monster slot default — the choice *is* the content
- No artifact grants an active skill at launch (Legendary signature territory)
- No gear, pill or evolution raises Surge damage, Strike damage or ground damage (damage law, gdd_battle §6.1)
- All gear effects visible in the pre-battle preview

---

## 7. Management

### 7.1 Businesses

The player, disrespected in the clan, builds a business → money → faction. All 5 business ideas decompose into **4 shared verbs** — one Facility system (slots: staff, input, timer, output) + one Market system (fluctuating prices) covers everything:

```
ACQUIRE  → get resources in (dungeon runs, buying, catching, recruiting)
PROCESS  → transform them (train, refine, craft — time + input → output)
SELL     → convert to money/favor (shop, Guild auction, contracts)
STAFF    → hire people who automate the above at night
```

|     Business    |        Acquire         |           Process            |           Sell          |
|-----------------|------------------------|------------------------------|-------------------------|
| Monster hall    | catch (battles!)       | train monsters               | sell trained beasts     |
| Trader          | buy low / dungeon loot | —                            | sell high               |
| Producer        | buy/gather materials   | craft pills/artifacts/arrays | sell products           |
| Dojo            | recruit disciples      | train them                   | sell contracts/manpower |
| Dungeon company | expeditions            | —                            | sell raw loot           |

**Where facilities stand:** commerce (shops, stalls, Monster hall, Dojo, Dungeon company) only on the player's properties in the Business District. Production (furnaces, workshops, forges) may stand on a property **or** in the Internal World (§4.2): inside it costs no property, but it can't reach the outside, so whatever it makes the player has to carry out to sell, and staff can't work there (for now).

**Auctions belong to the Merchants' Guild** (§3.2): the player does not own an auction hall, but consigns goods to the Guild's hall (Deal) and earns rare invites through favor.

**Verb → action mapping:** Acquire = expedition/Deal/catch · Process = Work (or staff at night, 0 AP) · Sell = Deal (daily shop sales resolve free at night) · Staff = Deal (recruit).

The Monster hall deals in **individuals**: a trained beast is sold with its stat shape, rarity and evolutions — a good roll is worth more, which makes catching off-lean shapes a business in itself.

**Built-in progression arc:** early game the player spends AP on everything personally → staff take over Process/Sell at night → AP shifts toward dungeons, story, cultivation. The idle layer = "night phase does what you used to spend AP on."

### 7.2 Favor & Faction

Connections are a **currency**, not a nebulous relationship system:

```
FAVOR (per faction: the 3 families, City Lord & City Guard, Merchants' Guild — §3.2)
  earn:  quests, selling cheap to them, arena wins, auctioning
         items they want, defeating their rivals
  spend: business licenses, protection (fewer sabotage events),
         rare auction invites, breakthrough trial access,
         recruiting THEIR people
```

- **The player's faction = recruited staff** — each hire is a character with a stat, loyalty value, and story hook
- The Dojo doubles as the faction pipeline; late game, faction members run dungeon expeditions (idle Acquire)
- Clan arc writes itself: success forces the clan to notice → tribute demands or absorption attempts → loyalty vs independence

### 7.3 Currency — Spirit Stones Only

One integer internally, **tiered denominations** for display and flavor:

```
100 Lower = 1 Middle · 100 Middle = 1 Upper
```

- Display auto-formats (`3 Middle, 42 Lower`); vendors/regions can display in different tiers (slums in Lower, auction hall in Upper)
- Optional depth: Upper stones double as a *material* — breakthrough rituals physically consume them (money-as-cultivation-resource, genre-authentic)
- No gold+stones dual currency, no stamina currencies (AP is that), no per-business currencies

### 7.4 The 4 Resource Kinds

|      Resource     |                What                |                Sources                |                 Sinks                 |
|-------------------|------------------------------------|---------------------------------------|---------------------------------------|
| **Spirit Stones** | money                              | business profit, loot sales, auctions | staff, materials, structures, rituals |
| **Materials**     | tiered crafting inputs             | dungeons, growing plots, buying       | crafting, blueprints, upgrades        |
| **Favor**         | per-faction relationship currency  | quests, deals, arena                  | licenses, invites, access, recruits   |
| **XP bars**       | progression (player + per monster) | battles, cultivate, idle spots        | sub-tier ups                          |

### 7.5 Materials Schema (mirror existing systems)

```
MATERIAL = aspect (F/N/D/neutral) × tier (cultivation stages) × form (herb/ore/beast-part/seed)
```

- Foundation-tier pill needs Foundation-tier herbs → deeper dungeons stay relevant automatically
- Beast parts drop by **kin** (Scaled hide, Winged feather) → collection ties into crafting
- **Seeds** grow one specific herb in a growing plot (§4.2): certain medicines need the correct seed
- ~4 forms × 3-4 aspects × 4 tiers ≈ 48+ materials from one schema

### 7.6 Item Schema

Goods are the **output tier of the material chain** — tradeable, one shared schema, no new resource category:

```
ITEM
  kind    : Material | Pill | Artifact | Array | Blueprint
  aspect  : F / N / D / neutral
  tier    : matches cultivation stages
  value   : spirit stone base price
  effect  : null (materials) | on_use (pills) | while_equipped (artifacts)
            | while_deployed (arrays)
```

### 7.7 Economy Design Rule

> **Spirit stones buy speed and breadth — never things battles can't earn.** Rarity-ascension materials, trial access, unique monsters: locked behind favor/story/dungeon depth, money only a partial input. Otherwise Trader becomes the only correct playstyle and the battle game dies.

---

## 8. Technical Notes (Overworld) & Development Phases

- **Overworld = same 3D + fixed iso camera as battles** — one art pipeline (character controller, camera rig, props, lighting shared)
- Structure: connected small scenes (hub-based city districts + dungeon nodes), never open world
- Cheapest v1: **node-based map** (Slay-the-Spire style) — click location → scene/battle; upgrade to walkable districts later
- Night phase = single synchronization point → save-friendly, no real-time simulation ("on day end, run all resolvers once")

**Data model (mirrors the battle's data-driven approach, gdd_battle §7.1):**

- **Species** = the existing `MonsterDef` data files (Kin, Aspect, default kit, species passive). They no longer carry fixed stats for a stage — stats come from the individual
- **Individual** = a save-game record (species id, stat shape, stats, unspent stat points, rarity, stage / sub-tier / XP, evolution picks, artifacts, current HP). It owns **no battle rules**
- **Evolution paths, stat shapes, stage ceilings, items, structures, businesses, dungeons** = data files with fixed templates, loaded and validated by the same registry pattern as monsters / skills / zones. New content = a new file
- **Battle request / result** is the single contract between the two halves: the request carries mode, board parameters, both teams as **finished unit sheets** (resolved stats, evolved skills, passives, current HP) pre-battle modifiers (pills, arrays) and the battle loadout (tamer skills, medicines, arrays); the result carries winner, remaining HP, kills and the used-up loadout items. The battle core stays headless and never imports overworld code
- Game state (day, AP, money, inventory, owned individuals, structures) lives in one save object, written at the night phase

**Development phases:**
```
PHASE 1  Battle system (done: 1v1 + 3v3, draft, 9 monsters) + individual monsters
         (built: individuals, BattleRequest/Result, GameState, city map of places,
         dungeon node map with full enemy sheets and team pick, loot, Trader with drifting
         prices, cultivation pills → XP → sub-tier with stat snap;
         placeholders: night heals everyone, flat rewards, prototype prices and XP curve)
         (stat shapes, stage caps, XP → sub-tier snap) + node-based dungeon access
         + Trader business (pure buy/sell) + money → power loop
         (money → cultivation pills → XP → stronger stats)
PHASE 2  Walkable city districts (first step built: Teleport Plaza, Market, Inner World;
         WASD + E, iso camera, monster follows; visible dungeon with ambush; building system:
         grid, blueprints + materials, cultivation spots, herb plots, adjacency; skill evolution at
         the Evolution Pillar, breakthrough; Producer: Refining Furnace + Pill Stall, healing and
         battle-prep pills; Favor with the Family, the Merchants' Guild and the City Watch: requests,
         discounts, licenses, recruits; walkable Clan Compound),
         Producer business, favor system with 2-3 factions
PHASE 3  Dojo/faction staff, consigning at the Guild's auction hall, monster hall,
         internal world growth stages, clan storyline
```

> **Design ahead of the code (v0.10):** the Pill Stall still stands in the Inner World, the Herb Plot plants materials instead of seeds, and the factions are still Family, Guild and Watch (no rival families, no City Lord). Stats still snap by sub-tier (no frames, budget or stat points), AP is still a fixed 2, Move still costs 1 AP (no Step, no movement skills), kits are still fixed to Move + Strike + Surge + utility, in-battle medicines and arrays don't exist yet, and the Evolution Pillar has no Size path.

> If a management feature doesn't eventually output battle power or story access — cut it.

---

## 9. Open Questions (Overworld & Meta)

**Monsters & progression**
- Stat prices, budgets and frames (§5.2) are a first version; check them with `tools/sim.gd`. At Qi Gathering and Foundation the Anvil and Skirmisher hit their frame before the budget is spent (1–2 points wait for the next breakthrough): fine, or widen those frames?
- Does the frame's **max** hold for life, or may rare items / rituals push a stat past it?
- Is the **max AP** of 3 enough at Soul+, and should AP 3 with TPR 2+ stay excluded by the frames?
- **Skill slots:** who fills the 4 slots? Current text: fixed species kit + Swap evolution. Recommendation: every species gets a learnable list of about 8 skills (its 4 defaults + about 4 more, new ones open at breakthroughs), and the player re-slots them for free outside an expedition
  *(prototype: Lower 75% / Middle 90% / High 100% of the HP and Initiative budget; XP to next sub-tier 60 / 120, High bar 200; pill +30 XP for 80 stones; dungeon win +10 XP)*
- Can an individual's **stat shape change** later (ritual / rare item), or is it fixed for life?
- *(prototype)* evolutions are done at the Evolution Pillar (1 AP each); taking them all back costs 1 AP + 4 materials of the monster's aspect; breakthrough costs 1 AP + 5 materials (player) / 3 (monster)
- Evolution schedule: how many evolutions per skill per stage, and what XP / materials do they cost?
- Rarity "paths offered / picked" counts for the five path families (§5.5); how does a Size pick (counts as 2 evolutions) work for a rarity that picks 1?
- **Battle loadout:** how many medicines / arrays may a battle use, when (own turn, any time, 0 AP or AP), which ones are consumed, and what do medicines do exactly? Does the enemy bring a loadout too?
- **Tamer skills:** how are the skills learned (story, items, favor) and what is the exact set beyond gdd_battle §5.11 (Domain Glimpse tuning is open there)?
- **Evolution × twist × Kin:** Shape evolutions must respect the twist (Ring has no free shape, Trail needs a straight line, Pounce uses O4) and the Kin's Surge size access (Swarm = 2-cell shapes) — validation rules to write
- Do monsters share the exact cultivation stage names, or beast-flavored equivalents?
- Rarity ascension materials & acquisition sources
- XP curve per sub-tier; what breakthrough trials look like mechanically
- **Dual-aspect monsters** (Immortal): gdd_battle has no rules for a second aspect (Surge type, zone family, ground) — define there first
- **Air layer / 2x2** rules live in gdd_battle open questions; stage gating is set here (Soul)

**Battle hand-off**
- What happens to a monster that **dies in an expedition** (revived by pills, injured for N days, lost)?
- Exact round-1 initiative bonus for attacking a wild monster from behind (the rule itself is now in gdd_battle §2.1)
- Does a victory give a **catch** chance, a catch action (costs AP / item), or a guaranteed catch of one defeated monster?
- Which board parameters does a dungeon node control (props, elevated squares) versus the generator in gdd_battle §4.1?
- Spatial space capacity per player sub-tier, and the bench size for counter-picks

**Management & world**
- AP growth curve per cultivation stage; exact AP costs per action
- Night event pool (sabotage, visitors, clan summons) and trigger weights
- Market price fluctuation model for the Trader loop
- Staff stats/loyalty model; can staff betray or be poached?
- Internal world grid size per stage; adjacency bonus table
- Dungeon expedition structure: floors per run, HP persistence rules, retreat rules
- **Rival families:** names, character, what they offer; does favor with one cost favor with another?
- Who runs the Arena, the Teleport Plaza and the Business District? (§3.1 proposes City Lord, City Lord, Merchants' Guild)
- **Internal World staff:** no staff inside for now (§4); may change
- **Slums:** do they stay without a faction, or does the underworld return later?
- **Business District:** how are properties acquired, and do facilities get adjacency bonuses there?
- **Seeds:** sources and how many; one seed per herb, or per aspect and tier?

---

## 10. Changelog

### Changes in v0.10

- **New structure:** §2 has one heading per loop (Battle, Expedition, Day, Cultivation, Economy), all in the same format (sentence, flow, actions with costs, rules). World is split into **§3 Overworld** and **§4 Internal World**, so Monsters to Changelog moved up by one. Section references in the changelogs below keep their old numbers
- **Stats:** frames per shape, a stat budget per stage and sub-tier, stat prices and **player-spent stat points** replace the fixed shapes and the stat snap (§5.2). Init has two rates, 1 point = 1.0 at the roll and +0.1 on a level-up. New stat **AP** (2–3), Max Movement raised to 3 / 4 / 5 / 5 (§5.3)
- **Kits:** 4 active skills + 1 passive from day one instead of Move + Strike + Surge + utility; no 2nd utility slot at Foundation (§6.3, gdd_battle §5.6). Moving costs 2 AP; Step for everyone, movement skills by Kin (gdd_battle §5.5.3)
- **Evolution:** Shape (same cells) and **Size** (+1 cell, counts as 2 evolutions) are separate paths; Swap now works on any active skill (§5.4)
- **Battle loadout:** medicines and arrays may be used in battle and consumed; "nothing is consumed mid-battle" is gone, "no hidden information" stays (§2.1, §6.5)
- **World:** district table with access and owner, central buildings per district (§3.1), full structure table (§4.2). New districts: Rival Compounds, City Lord's Keep
- **Internal World:** production may stand inside again; only commerce and quest buildings are excluded, because it can't communicate with the outside (§4)

### Changes in v0.9

- **New structure:** Overview, Game Loops, World, Monsters, Progression, Management; all section numbers changed. Section references in the `godot/` code comments still use the old numbers
- **Internal World** (§3.4) only serves the tamer's own power: no buying, selling or business facilities. Herb plots grow herbs from **seeds** (§6.5), a new material form
- **Production moved to the city** (§6.1): Refining furnace, Array workshop and stalls are facilities on properties in the Business District
- **The city's powers** (§3.2) are now 3 cultivation families, the City Lord & City Guard and the Merchants' Guild, instead of 5 families plus guilds, watch and underworld. The Slums stay as a place without a faction
- **Auction hall** belongs to the Guild: no longer a player business (5 instead of 6), the player consigns goods

### Changes in v0.8 (sync with gdd_battle v6.0)

- **Monsters are individuals** (§4.1): the species fixes Kin / Aspect / base kit, the individual owns **stat shape**, rarity, stage, evolutions, artifacts and HP. Stats = shape × stage ceiling × sub-tier (§4.2)
- **Full base kit from day one** (§5.3): Move, Strike, Surge, 1 utility, 1 passive at Qi Gathering. The old "1 active + 1 passive, 2nd active at Foundation" is gone; Foundation adds the 2nd utility slot
- **Team sizes earlier** (§5.3): 1v1 at Qi Gathering, **3v3 (standard) and 2v2 from Foundation**, 5v5 special battles from Core, Beast Swap at Soul. The encounter, not the player, picks the mode
- **Skill evolution reworked** (§4.4) to the battle's skill system: four path families — Shape, Twist, Small value, Utility swap — with Surge/Strike/ground damage never growing. The old "Deeper +1 StartOfTurn damage" and "duration 3 → 5" examples were dropped (damage law, 2-round zone clock)
- **Rarity** (§4.5): "2 active skills" row replaced by the real kit; evolution choices now count path offers / picks
- **TPR cap fixed**: TPR 2 is possible from Foundation (matches the stage-cap table); old "Core: TPR 2" removed
- **Pre-battle**: full sheets of both teams visible (no hidden info), healing pills and HP persistence defined against the battle's start HP, arrays limited by the neutral-start rule
- **Six closed stat shapes with rolled ranges and a fixed point total per stage** (§4.2); Berserker's TPR 3 opens at Soul instead of breaking the Core cap
- **Tamer skills are chosen into slots** (§5.4); slots grow with stage, sub-tier no longer changes their potency
- **Rarity gives no stat bonuses** (Soul+ caps = absolute scale); Normal monsters never reach Soul mechanics (air, 2x2, TPR 3) or the Major Surge — intended
- Evolution **Small value** limited to zone duration +1 (max 3) and cast range +1; no level-II start
- New §2.2 and §7 describe the battle request / result contract between both halves
