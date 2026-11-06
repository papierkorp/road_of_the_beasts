# GDD — OVERWORLD & META
*Working Draft v0.11 · synced with gdd_battle.md **v6.2** (battle GDD is the source of truth for all battle rules, stats and skills)*

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
2. Pre-battle: the player picks the team and the **battle loadout** (tamer skills, medicines, arrays) and sees both teams' full sheets. Only **humans** carry an inventory and so a loadout (§7.9): the player and enemy tamers. Wild monsters bring none
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
| Medicine *(planned)*   | 1 medicine from the loadout      | consumed; timing and limit open (§9); human tamers only         |
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
6. Back in the city, the day goes on (injured monsters need rest, §5.8)

|         Action          |      Cost      |                          Notes                          |
|-------------------------|----------------|---------------------------------------------------------|
| Start an expedition     | 1 AP           | includes all its battles                                |
| Start on a deeper floor | 2 AP           |                                                         |
| Walk, inspect monsters  | free           |                                                         |
| Heal between battles    | 1 healing pill | the only way to restore HP inside a run                 |
| Teleport out            | free           | ends the run, keeps the loot                            |

- **HP persists** between the battles of a run; a battle starts at current HP. Pills are logistics
- Wild monsters are visible, no random encounters. There is **no ambush bonus**: attacking from behind gives nothing
- A monster that is defeated is **Injured**, not dead (§5.8)
- After a win the player may **bind** one defeated wild monster with a Binding Seal (§5.7)
- The dungeon node fixes the battle mode and the number of wild monsters (§3.3)

### 2.3 Day Loop

A day is one turn: spend AP in the city, the night resolves everything at once.

1. Day starts with N AP (start: 3, grows with cultivation stage, proposal in §2.6)
2. Spend AP on the actions below, in any order
3. End the day by hand or when AP run out
4. **Night:** businesses produce, staff report, plants grow a tick, eggs and breeding progress, monsters gain idle XP, injured monsters rest a night, market prices shift
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

### 2.6 Action Catalog

Every action the player can take, in one place. The loop tables above stay the short version; this is the master list for balancing AP. Costs are a **first proposal** except where a loop table already fixes them.

**Day AP (proposal):** Qi Gathering 3 · Foundation 4 · Core Formation 4 · Soul Tier 5 · Immortal 5 · Sovereign 6. Growth stays slow on purpose: staff take over Process and Sell at night (§7.1), so more AP goes into dungeons, story and cultivation, not into more chores.

|              Action              |   Loop   |            Cost            |                       Needs                       |                    Notes                     |
|----------------------------------|----------|----------------------------|---------------------------------------------------|----------------------------------------------|
| Step / movement skill / Strike / zone / Surge / self skill / tamer skill | Battle | AP of the battle (§2.1) | in a fight | gdd_battle |
| Use a medicine / array           | Battle   | from the loadout           | human tamer                                       | open (§9)                                    |
| Bind a defeated wild monster     | Battle   | free + 1 Binding Seal      | win; seal tier and grade high enough (§5.7)       | in the result screen                         |
| Start an expedition              | Expedition | 1 AP (2 AP deeper floor) | Teleport Array                                    | includes all its battles                     |
| Walk, inspect, teleport out      | Expedition | free                     | —                                                 | teleport out keeps the loot                  |
| Heal in a run                    | Expedition | 1 healing pill           | pill                                              | the only way to restore HP in a run          |
| Cultivate                        | Cultivation | 1 AP                    | —                                                 | player XP                                    |
| Train a monster                  | Cultivation | 1 AP                    | —                                                 | focused XP                                   |
| Study a scroll                   | Cultivation | 1 AP                    | Scroll (§7.6)                                     | learns a tamer skill / recipe / blueprint    |
| Take a pill                      | Cultivation | free + 1 pill           | pill                                              | XP, healing, cure                            |
| Assign a monster to a spot       | Cultivation | free                    | spot in the Internal World                        | idle XP every night                          |
| Spend stat points                | Cultivation | free                    | unspent points                                    | inside the stage ceilings (§5.2)             |
| Re-slot skills                   | Cultivation | free                    | not inside an expedition                          | from the learnable list (open, §9)           |
| Evolve a skill                   | Cultivation | 1 AP                    | Evolution Pillar, evolution point                 | §5.4, §6.3.1                                 |
| Take back evolutions             | Cultivation | 1 AP + 4 materials      | Evolution Pillar                                  | prototype cost                               |
| Breakthrough                     | Cultivation | 1 AP + trial + materials | High sub-tier, Trial Pillar                      | prototype: 5 (player) / 3 (monster) materials |
| Rarity ascension                 | Cultivation | 1 AP + rare materials   | Aspect Altar, Bloodline pill (§5.6)               | major event                                  |
| Reshape (change stat shape)      | Cultivation | 1 AP + Reshape Elixir   | Trial Pillar                                      | rare item (§5.2)                             |
| Rest an injured monster          | Cultivation | free                    | Recovery Spring or time                           | §5.8                                         |
| Pair monsters / place an egg     | Cultivation | free                    | Breeding Den / Incubator                          | resolves over nights (§5.7)                  |
| Work a facility                  | Economy  | 1 AP + inputs              | furnace, forge, workshop, stall                   | runs at once                                 |
| Queue a facility                 | Economy  | free + inputs              | same                                              | resolves at night                            |
| Plant a seed / harvest           | Economy  | free                       | Herb Plot / Spirit Tree                           | grows nights; harvest is free                |
| Buy / sell at a trader           | Economy  | spirit stones, no AP       | Trader                                            | prices drift                                 |
| Deal: bulk trade, consign, bid, recruit, negotiate a property, favor action | Economy | 1 AP | Guild, Auction Hall, Envoy, owner | the one Deal action covers all of these |
| Accept / hand in a request       | Economy  | free                       | Notice Board, Watch Post                          | the reward is the favor                      |
| Fight in the Arena               | Economy  | 1 AP per tournament round  | Arena Ring                                        | favor and stones                             |
| Build / upgrade a structure      | Economy  | 1 AP + materials / stones  | grid space or property                            | moving structures is free                    |
| Story / social event             | Day      | 1 AP                       | key NPC, clan meeting                             | investigations (staff, §7.1.1) are social events |
| End the day                      | Day      | free                       | —                                                 | the night resolves everything                |

- **Free = looking, ordering, assigning, spending points, re-slotting, queueing** (golden rule, §2.3). Everything that *changes the world right now* costs 1 AP; everything that resolves at night is queued for free
- Costs of dungeon floors and reward tables wait for the item tables (§7.5–§7.8, §9)

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

The player's properties. Every commerce building stands here. A property has an owner: it is acquired by negotiation and needs the Guild's license; there are no adjacency bonuses here.

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

#### 3.1.9 Building Index

All central buildings of the city in one table (details in 3.1.1–3.1.8). "Operator" is the faction behind the counter (§3.2); the three marked * are proposals.

|    District    |      Building       |                        Function                         |      Operator       |       Access        |  Built |
|----------------|---------------------|---------------------------------------------------------|---------------------|---------------------|--------|
| Clan Compound  | Clan Hall           | clan meetings, summons, Family favor                    | player's family     | start               |        |
| Clan Compound  | Notice Board        | requests and quests                                     | player's family     | start               | ✓      |
| Clan Compound  | Clan Envoy          | Family favor actions                                    | player's family     | start               | ✓      |
| Rival Compounds| Family Hall         | favor actions and quests of that family                 | rival family        | invitation / favor  |        |
| City Lord's Keep | Audience Hall     | City Lord favor, Street Trade Permit                    | City Lord           | favor (inner hall)  |        |
| City Lord's Keep | Guard Barracks    | beasts for hire                                         | City Guard          | outer court         |        |
| Market District| Trader              | buy / sell, drifting prices                             | Merchants' Guild    | start               | ✓      |
| Market District| Guild Factor        | Guild favor, discounts, Production License              | Merchants' Guild    | start               | ✓      |
| Market District| Guild Hall          | rare blueprints, contracts                              | Merchants' Guild    | favor               |        |
| Market District| Auction Hall        | consign, bid, rare invites; monsters and eggs for sale  | Merchants' Guild    | start, invites      |        |
| Business District| Properties        | the player's shops, stalls, workshops (§7.1)            | Guild * (owners)    | license + negotiation |      |
| Arena          | Arena Ring          | tournaments, 5v5 special battles                        | City Lord *         | start               |        |
| Arena          | Ranking Board       | opponents and rewards                                   | City Lord *         | start               |        |
| Teleport Plaza | Teleport Array      | expeditions                                             | City Lord *         | start               | ✓      |
| Teleport Plaza | Meditation Pavilion | entry to the Internal World                             | the player          | start               | ✓      |
| Teleport Plaza | Watch Post          | City Guard requests                                     | City Guard          | start               | ✓      |
| Slums          | Black Stall (idea)  | odd goods                                               | none                | start               |        |

- The Business District is a **list of properties with owners**: a property is acquired by negotiating with its owner (Deal, 1 AP) and needs the Guild's license. There are **no adjacency bonuses in the city**, those exist only in the Internal World (§4.2)

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
- **Adjacency bonuses** make layout a real puzzle: herb plot + water = -1 grow night; Dark monster housed near Dark altar = +XP; adjacency exists **only here**, never in the city (table in §4.3)

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
| *New structures*     |             | Breeding Den, Incubator, Hive Nest, Recovery Spring, Study Desk, Storehouse: see §4.3 |  |

Production structures may stand **inside or on a city property** (§7.1). Commerce and quest buildings are city only (§3.1).

### 4.3 What Lives in the Spatial Space

Everything the spatial space can hold, in one table. **Footprint** is in grid cells (a monster of size 2x2 takes 4 cells when it stands still); **Placement** says how it sits on the grid. Footprints, unlock stages and the places marked *new* are a first proposal.

| Category |         Thing         | Footprint |       Placement        |                       Function / place for                        |  Unlock  |
|----------|-----------------------|-----------|------------------------|-------------------------------------------------------------------|----------|
| Monster  | Housed monster        | free      | roams the whole grid   | counts against capacity (§4.4)                                    | Qi       |
| Monster  | Assigned monster      | on a spot | stands on its spot     | idle XP at night, or breeding / incubating / resting              | Qi       |
| Monster  | Egg *(new)*           | 1         | inside an Incubator    | hatches after N nights into an individual (§5.7)                  | Foundation |
| Cultivation | Meditation Stone   | 1×1       | any cell               | place for **cultivating**: idle XP                                | Qi       |
| Cultivation | Qi Spring          | 2×2       | any cell               | stronger idle XP, counts as water                                 | Qi       |
| Cultivation | Aspect Altar (×3)  | 2×2       | any cell               | +XP nearby; place for **rarity ascension**                        | Foundation |
| Cultivation | Evolution Pillar   | 1×1       | any cell               | place for **skill evolution**                                     | Foundation |
| Cultivation | Trial Pillar       | 1×1       | any cell               | place for **breakthrough** trials and **reshaping**               | Foundation |
| Cultivation | Study Desk *(new)* | 1×1       | any cell               | place for **studying scrolls** (tamer skills, recipes)            | Foundation |
| Growing  | Herb Plot             | 2×2       | any cell               | place for **planting** seeds                                      | Qi       |
| Growing  | Spirit Tree           | 3×3       | any cell               | slow, high-tier herbs (Epic grade)                                | Core     |
| Housing  | Nest / Cave / Shrine Grove | 2×2 / 2×2 / 3×3 | any cell    | +capacity; kin-matched = mood bonus                               | Foundation |
| Breeding | Breeding Den *(new)*  | 2×2       | any cell               | place for **breeding** a male and a female (§5.7)                 | Core     |
| Breeding | Incubator *(new)*     | 1×1       | any cell               | place for **hatching** eggs                                       | Foundation |
| Breeding | Hive Nest *(new)*     | 2×2       | any cell               | Swarm species multiply here without a pair (§5.7)                 | Core     |
| Recovery | Recovery Spring *(new)* | 2×2     | any cell               | place for **resting** injured monsters (halves the time, §5.8)    | Foundation |
| Crafting | Refining Furnace      | 2×2       | any cell               | place for **crafting** pills and medicines                        | Qi       |
| Crafting | Array Workshop        | 2×2       | any cell               | place for **crafting** arrays and Binding Seals                   | Foundation |
| Crafting | Artifact Forge        | 2×2       | any cell               | place for **smithing** artifacts and tamer gear                   | Core     |
| Special  | Spirit Pond           | 2×2       | any cell               | water for adjacency                                               | Qi       |
| Storage  | Storehouse *(new)*    | 1×1       | any cell               | stores materials and goods carried in; the player's inventory stays on the tamer (§7.9) | Qi |

Anything produced inside has to be **carried out** by the player: there is no way to sell from in here (§4).

**Adjacency bonuses (Internal World only).** A structure touches another orthogonally. Bonuses are small and one per pair; the first table of a layout puzzle:

|     Structure A      |        Next to        |                  Bonus                  |
|----------------------|-----------------------|-----------------------------------------|
| Herb Plot            | Spirit Pond / Qi Spring | −1 grow night                         |
| Spirit Tree          | Spirit Pond           | −1 grow night                           |
| Meditation Stone     | Aspect Altar (same aspect as the monster) | +XP at night          |
| Refining Furnace     | Aspect Altar          | recipes of that aspect: −1 AP cost when worked (min 0, never both) |
| Nest / Cave / Grove  | monster of the matching Kin | mood / loyalty bonus              |
| Recovery Spring      | Spirit Pond           | injured monsters rest one night less    |
| Breeding Den         | Nest / Cave / Grove   | the egg is ready one night earlier      |
| Incubator            | Qi Spring             | hatches one night earlier               |

### 4.4 Capacity and Growth

The space grows with the cultivation step (§6.3.1): the **grid** with each stage, the **monster capacity** with each sub-tier. The bench is the capacity minus the team a mode needs; at Core+ it is bigger than the team, so counter-picks are possible. Proposal:

|      Stage      | Grid  | Capacity Lower / Middle / High |                   Terrain                   |
|-----------------|-------|--------------------------------|---------------------------------------------|
| Qi Gathering    | 6×6   | 1 / 1 / 2                      | barren rock                                 |
| Foundation      | 8×8   | 3 / 3 / 4                      | grass, a pond                               |
| Core Formation  | 10×10 | 5 / 6 / 7                      | forest, structures                          |
| Soul Tier       | 12×12 | 8 / 9 / 10                     | open land                                   |
| Immortal        | 14×14 | 11 / 12 / 13                   | mountains and water                         |
| Sovereign       | 16×16 | 14 / 15 / 16                   | a small world                               |

Eggs in an Incubator do not count against capacity until they hatch.

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
FRAME   the stat shape sets a min–max per stat for the ROLL: shapes stay readable, individuals differ
BUDGET  every monster of a stage and sub-tier has the same total of stat points
PRICE   stats cost points: a strong stat is paid for with the others
```

**Stat prices.** Every stat is priced in full: **points = value × price**. A new monster owns the base values for free (17 points of base), the budget below is what it gets on top:

|   Stat   | Base | Price per point | Base cost |
|----------|------|-----------------|-----------|
| HP       |    1 |               1 |         1 |
| Init     |  1.0 |     1 (see below) |       1 |
| Movement |    1 |               1 |         1 |
| Reach    |    1 |               3 |         3 |
| TPR      |    1 |               5 |         5 |
| AP       |    2 |               3 |         6 |
| **Base total** |  |               |    **17** |

TPR and AP stay priced separately; the frames keep AP 3+ off the TPR 2+ shapes (Glass cannon, Berserker, Fragile).

**Budget per stage and sub-tier** (points above the 17 base points; absolute total in brackets):

|        Stage        |  Lower  |  Middle |   High  |
|---------------------|---------|---------|---------|
| Qi Gathering        | 4 (21)  | 5 (22)  | 6 (23)  |
| Foundation          | 10 (27) | 11 (28) | 12 (29) |
| Core Formation      | 14 (31) | 15 (32) | 16 (33) |
| Soul Tier and above | 18 (35) | 19 (36) | 20 (37) |

So a sub-tier up gives **+1 stat point**, a breakthrough **+2** (**+4 into Foundation**, because TPR 2 opens there). Immortal and Sovereign add no points: the absolute scale is reached, those sub-tiers give evolution points instead (§6.3.1).

**The six frames at Core Formation** (min–max). The last column is the **absolute point total** of the frame: all stats at their minimum, and all at their maximum. The Core budget (31 / 32 / 33) has to sit inside it for every shape, and it does:

|    Shape     |  HP |  Init | Move | Reach | TPR |  AP | Total points | Feel |
|--------------|-----|-------|------|-------|-----|-----|--------------|------|
| Glass cannon | 1–3 | 7–9   | 1–3  | 1     | 2   | 2   | 28–34        | commits fast, dies if its Surge is cut away |
| Anvil        | 6–8 | 1–4   | 1–2  | 1–2   | 1   | 2–3 | 22–34        | slow, hard to dislodge, threatens a radius it can't leave |
| Skirmisher   | 3–5 | 5–8   | 3–5  | 1     | 1   | 2–3 | 25–35        | never in its own Surge when it fires |
| Berserker    | 4–6 | 5–7   | 1–3  | 1     | 2   | 2   | 29–35        | escalates one Surge with Empower; TPR 3 opens at Soul |
| Balanced     | 4–6 | 4–6   | 2–3  | 1–2   | 1   | 2–3 | 24–35        | no weakness, no spike — the kit decides |
| Fragile      | 2–4 | 5–7   | 1–3  | 1–2   | 2   | 2   | 27–36        | weak body, many turns; lives on its Surge |

Worked out with the prices (Glass cannon): HP 1–3 = 1–3 · Init 7–9 = 7–9 (8–12) · Move 1–3 = 1–3 (9–15) · Reach 1 = 3 (12–18) · TPR 2 = 10 (22–28) · AP 2 = 6 → **28–34**. Anvil: HP 6–8 · Init 1–4 (7–12) · Move 1–2 (8–14) · Reach 1–2 = 3–6 (11–20) · TPR 1 = 5 (16–25) · AP 2–3 = 6–9 → **22–34**.

**Balance check.** A shape is fair when the budget total sits inside its range and its max is not far above it (then the individual can reach the budget with room to choose). At the top of the Core budget (33) the Glass cannon has 1 point of room (max 34), the Anvil 1, the Skirmisher / Berserker / Balanced 2, the Fragile 3. The Glass cannon and the Anvil therefore roll almost the same stats every time; the wide ranges of Anvil (22–34) and Balanced (24–35) only matter as the minimum for the roll.

**All stages (absolute point range of the scaled frame vs. budget):**

|    Shape     | Qi (21–23) | Foundation (27–29) | Core (31–33) | Soul+ (35–37) |
|--------------|------------|--------------------|--------------|---------------|
| Glass cannon | 20–23      | 26–30              | 28–34        | 32–39         |
| Anvil        | 19–21      | 21–28              | 22–34        | 27–39         |
| Skirmisher   | 21–24      | 22–28              | 25–35        | 30–40         |
| Berserker    | 20–23      | 27–31              | 29–35        | 34–41         |
| Balanced     | 19–22      | 22–29              | 24–35        | 28–41         |
| Fragile      | 19–22      | 26–32              | 27–36        | 32–41         |

The Qi and Foundation ceilings squeeze some frames: the **Anvil at Qi Gathering** (max 21 against 21 / 22 / 23) cannot spend 1 point at Middle and 2 at High, and the **Anvil and Skirmisher at Foundation High** (max 28 against 29) 1 point. **Rule:** whatever the roll cannot place stays as **unspent stat points**; the player spends them freely, so nothing is lost and the frames stay as they are.

**Init has two rates:** at the roll 1 point = **1.0 Init**, so a fast shape pays for its speed with its other stats; the decimal (.0–.9) is rolled on top for free, below the frame's max. On a level-up 1 point = **+0.1 Init**: speed stays the identity of the shape, level-up points only fine-tune the queue. The budget counts points received, so every monster gets the same number whatever it buys.

Example, a Glass cannon at Core High (16 points above base): HP 2 (1) + Init 9 (8) + Move 3 (2) + TPR 2 (5) = 16.

- **Other stages scale the frame:** HP, Init, Movement and Reach limits are multiplied by *stage ceiling ÷ Core ceiling* (§5.3), rounded, min 1. TPR and AP limits are simply cut by the ceiling. Only the Berserker's TPR limit grows, to 3 at Soul. **AP 4 (Immortal) and 5 (Sovereign) are open only to the TPR 1 shapes** (Anvil, Skirmisher, Balanced), never to the TPR 2+ shapes
- **The frame is only for the roll.** A new or wild individual draws its stats inside the frame until the budget of its stage and sub-tier is spent. After that the frame no longer matters: **level-up points are limited only by the stage ceilings** (§5.3). Two Anvils start different, but never stronger than each other overall
- **Spent by the player after that:** each level-up adds points, and the player spends them freely (free action)
- **Points can be saved.** Points that hit a stage ceiling stay unspent until a ceiling opens at the next breakthrough
- **The stat shape can change** later through a ritual with a rare item (a Reshape Elixir at the Trial Pillar, 1 AP, §2.6). The ritual is a respec: all points are pooled and the monster is **re-rolled inside the new shape's frame** with the same budget; the leftover is unspent. Level-up spending does not change the shape label
- **Ceiling rule:** monsters cannot exceed the player's stage (the spatial space can only sustain what the tamer's qi can feed)
- **Tuning:** all prices, budgets and frames are a first version; they still need the battle simulation (`tools/sim.gd`)

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

Soul+ is split for AP only: **Soul 3 · Immortal 4 · Sovereign 5**, and only the TPR 1 shapes can use AP 4–5 (§5.2).

The base stat ranges (HP 1-10, Init 0.1-10.0, TPR 1-3, AP 2-5) are the **lifetime scale of the entire game** — number inflation would kill the deterministic low-HP feel. The damage law (gdd_battle §6.1) is **never** scaled by stage: Surge base damage, Strike (max 2) and ground damage are the same at Qi Gathering and at Sovereign.

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
- Evolution is a **Train** action (§2.3) at the Evolution Pillar, paid with **evolution points** (§6.3.1). Picks can be reversed through a ritual — "exchange, not just upgrade" (prototype: 1 AP + 4 materials of the monster's aspect)

**Validation rules.** An evolved skill must pass the same checks as any skill (gdd_battle §5.8). The evolution screen only offers the paths that pass:

|            Situation            |                                         Rule                                         |
|---------------------------------|--------------------------------------------------------------------------------------|
| Shape → new family             | same cell count (I2↔I2, I3↔L3, any 4-cell family); the family must be legal for the skill's twist and the monster's Kin |
| **Ring** Surge                  | the shape *is* the caster's 4 neighbours: no Shape path, no Size path                |
| **Trail** Surge                 | the shape must be a straight line: Shape only I2 / I3 and their orientation; no L / T / S / Z / O |
| **Pounce** Surge                | anchor stays adjacent; Shape may pick any 4-cell family, but the Surge is already at 4 cells: no Size |
| **Wide** Surge                  | already +1 cell: Size only while the result stays ≤ 4 cells, and the Surge pays the Wide price only once (damage −1, not −2) |
| **Swarm Surge**                 | Swarm has 2-cell shapes only (gdd_battle §3.6): Shape only changes the I2 orientation; Size and Wide are not offered |
| **Size** on any skill           | +1 cell, max 4 cells; a Surge pays the Wide price (damage −1); not offered when it would break the twist rules above |
| **Twist** path                  | at most one twist; adding Trail needs a straight shape, Ring replaces the shape with the 4 neighbours (range 0), Pounce needs an anchor adjacent to the caster, Wide needs ≤ 3 cells |
| **Value** path                  | +1 cast range total per skill (a Lob Surge's +2 is its twist, not the Value path); zone duration 3 rounds max |
| **Swap** path                   | the new skill must be on the species' learnable list and respect the Kin's lock-outs (gdd_battle §3.6) |
| Large (2x2) monsters            | no extra rules for evolution; the air layer is a Soul-stage unlock of Winged only |


### 5.5 Monster Rarity

**Rarity = potential and flexibility, NOT raw power.** A Normal and a Legendary at the same stage are close in raw stats — the Legendary has more options and a higher ceiling.

|                                  |                       Normal                       |        Rare       |        Epic       |            Legendary            |
|----------------------------------|----------------------------------------------------|-------------------|-------------------|---------------------------------|
| Base kit                         | 4 active skills                                    | same              | same              | same (+ signature at max stage) |
| Passives                         | 1                                                  | 1                 | 2                 | 2                               |
| Paths offered per evolution      | 2                                                  | 3                 | 3                 | all                             |
| Evolution points per step        | 1                                                  | 1                 | 2                 | 2                               |
| Max stage reachable              | Core                                               | Soul              | Immortal          | Sovereign                       |
| Aspect                           | fixed                                              | fixed             | fixed             | can shift once                  |

- "Max stage reachable" is the core axis — the wuxia "noble bloodline" trope, long-term potential over instant power
- **No stat bonuses from rarity.** Soul+ caps already sit on the absolute scale (HP 10, Init 10.0, TPR 3, Reach 3, AP 3; AP 4 / 5 at Immortal / Sovereign), so rarity buys slots, evolutions and ceiling — never numbers
- **High mechanics are Rare+ territory by design:** Air layer and 2x2 need Soul, TPR 3 needs Soul, the Ancient's Major Surge needs Sovereign. A Normal monster (max Core) stays grounded, single-turn-count and simple
- Rarity does **not** decide the stat shape: any rarity can roll any shape (weighted by Kin lean, §5.1)
- **Evolution points (EP)** replace "picks": every evolution step of the monster's cultivation (§6.3.1) grants the EP of its rarity, and each pick costs EP: **1 EP** for Shape, Twist, Value and Swap, **2 EP** for Size. So a Normal monster (1 EP per step) can take a Size only by saving the EP of two steps; an Epic can take one every step. No special case is left
- Offered counts and EP are a tuning start, not final (§9)

### 5.6 Rarity Ascension

- A **major event**, not a grind: rare material + ritual (bloodline awakening), story-flavored
- **Ingredients:** one **Bloodline pill** (§6.6) made of a Rare+ beast part of the monster's Kin and a herb of the next tier, plus the ritual at its Aspect Altar. The materials can come from many sources (§7.8), but the part with the grade of the new rarity only from dungeon bosses, quests, the clan leader or the auction: money is only a partial input (§7.7)
- On ascension: unlock new rarity's slots/caps, keep everything else
- **Hard cap:** Normal can climb to Epic but never Legendary — true Legendaries remain rare finds

### 5.7 Obtaining Monsters

How a monster enters the collection. Every way ends in the same record: an **individual** (stat shape rolled by the species' Kin lean, §5.1; rarity; stage). Nothing is rolled in battle, the roll happens when the individual comes into existence.

|        Way        |                                          How                                          |                         Notes                          |
|-------------------|---------------------------------------------------------------------------------------|--------------------------------------------------------|
| **Bind (Seal)**   | after a win the player binds **one** defeated wild monster with a **Binding Seal** (free, in the result screen) | the default way (decided); no dice (below)  |
| **Auction**       | buy monsters and eggs at the Guild's Auction Hall (Deal)                              | sheet visible before the bid; Monster hall can resell  |
| **Breeding**      | a male and a female of the same species in a **Breeding Den**: an egg after N nights (N by rarity) | only species with `breeds: true`; offspring: species of one parent, shape rolled by the Kin lean, rarity = the lower parent's, stage Qi Gathering Lower |
| **Eggs**          | found in dungeons, bought, quest rewards; hatched in an **Incubator**                  | an egg fixes species and rarity; the hatching rolls shape |
| **Hive (Swarm)**  | Swarm species multiply in a **Hive Nest** without a pair; one larva per N nights       | the insect way: no sex                                |
| **Quest / clan**  | story monsters, gifts from the clan leader, favor rewards                              | usually fixed individuals, often high rarity           |
| **Hire**          | Guard Barracks lend beasts for a while                                                 | not owned, no stat growth                              |

**Binding Seal.** An item (`kind: Seal`) with a **tier** (stage) and a **grade** (rarity, §7.5). It binds a monster whose stage is ≤ the seal's tier and whose rarity is ≤ the seal's grade. Normal seals are cheap, higher grades come from dungeons, the Guild and crafting (Array Workshop). The player picks **which** defeated monster to bind: a monster at 0 HP, so it needs nothing but the seal. Tamer skills and scrolls improve it (§5.11): one extra bind, or a seal of a lower tier is enough. Without a seal the defeated monster is released.

- Auction, breeding and eggs are the long game; the seal is what dungeons feed: catching and the Monster hall business are separate loops (§7.1)
- **Ceiling rule:** a seal binds only monsters up to the player's own stage (§5.2); stronger ones stay wild until the next breakthrough

### 5.8 Defeat and Injury

A monster that falls in battle is **Injured**, not dead:

- It is out for the rest of the expedition; the battle result marks it
- It is **not usable for 2 nights** (resting in the Internal World). A **Recovery Spring** halves that (rounded up), a **Revival pill** ends it at once
- Sub-tier, stat points and evolutions are never lost
- **Arena** fights never injure
- **Deadly dungeons** *(optional, marked at the Teleport Array)* give better loot, but a defeated monster there is **lost for good** unless protected: by the pill **Soul Tether** (one monster) or the tamer skill **Life Thread** (§5.11, the first fall of the battle). This keeps death as a real stake without making every run a risk of losing a favourite
- Open numbers: the 2 nights, Revival pill price and the Deadly loot bonus (§9)

---

## 6. Progression

### 6.1 Cultivation Structure (shared naming, player & monsters)

```
STAGES     Qi Gathering → Foundation → Core Formation → Soul Tier → Immortal → Sovereign
SUB-TIERS  Lower → Middle → High   (per stage)
BREAKTHROUGH  High → next stage's Lower
```

**Monsters use exactly the same stage and sub-tier names as the player**, so one table (§6.3.1) covers both.

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

#### 6.3.1 Monster Progression: the 18 Steps

Six stages × three sub-tiers = **18 steps**. The idea: **every sub-tier is stat points** (a free choice inside the stage ceilings), **every stage is new skills and mechanics**. A monster never goes past the player's step (ceiling rule) or its rarity's max stage (§5.5). Player and monsters walk the same table; the player's own bars may differ in XP numbers later.

| # | Stage · Sub-tier  | Budget (above base) | Gain on reaching the step                                                                       | XP bar to the next step | 
|---|-------------------|---------------------|--------------------------------------------------------------------------------------------------|-------------------------|
| 1 | Qi Gathering Lower| 4                   | full kit (4 active skills, 1 passive) · TPR 1 · AP 2 · 1v1                                       | 60                      |
| 2 | Qi Gathering Middle| 5                  | +1 stat point                                                                                    | 120                     |
| 3 | Qi Gathering High | 6                   | +1 stat point · breakthrough trial opens                                                         | 200 (+ trial)           |
| 4 | Foundation Lower  | 10                  | **+4 points** · **evolution step** · +1 learnable skill · TPR 2 · 3v3 / 2v2 · 1 tamer slot       | 150                     |
| 5 | Foundation Middle | 11                  | +1 stat point                                                                                    | 300                     |
| 6 | Foundation High   | 12                  | +1 stat point                                                                                    | 500 (+ trial)           |
| 7 | Core Formation Lower | 14               | **+2 points** · **evolution step** · +1 learnable skill · AP 3 · 5v5 special · 2nd tamer slot    | 400                     |
| 8 | Core Formation Middle | 15              | +1 stat point                                                                                    | 800                     |
| 9 | Core Formation High | 16                | +1 stat point                                                                                    | 1300 (+ trial)          |
| 10| Soul Tier Lower   | 18                  | **+2 points** · **evolution step** · +1 learnable skill · air layer, 2x2, TPR 3 · Beast Swap     | 1000                    |
| 11| Soul Tier Middle  | 19                  | +1 stat point                                                                                    | 2000                    |
| 12| Soul Tier High    | 20                  | +1 stat point                                                                                    | 3200 (+ trial)          |
| 13| Immortal Lower    | 20                  | no points · **evolution step** · +1 learnable skill · AP 4 (TPR 1 shapes) · dual aspect *(rules open)* · 3rd tamer slot | 2500 |
| 14| Immortal Middle   | 20                  | +1 evolution step                                                                                | 5000                    |
| 15| Immortal High     | 20                  | +1 evolution step                                                                                | 8000 (+ trial)          |
| 16| Sovereign Lower   | 20                  | **evolution step** · AP 5 (TPR 1 shapes) · Signature skill (Legendary) · Major Surge (Ancient)   | 6000                    |
| 17| Sovereign Middle  | 20                  | +1 evolution step                                                                                | 12000                   |
| 18| Sovereign High    | 20                  | +1 evolution step · the end of the table                                                         | —                       |

- **Evolution step** = the monster earns the EP of its rarity (§5.5): 1 for Normal / Rare, 2 for Epic / Legendary. Normal reaches Core (steps 4 and 7: 2 EP, enough for one Size), Rare reaches Soul (3 steps), Epic Immortal, Legendary Sovereign. Immortal and Sovereign give choices instead of numbers
- **Learnable skills:** the species list grows with the stages (4 defaults + 1 per breakthrough from Foundation to Immortal = 8). Re-slotting is free outside an expedition (open, §9)
- **Why not points at Immortal / Sovereign:** the stat ceilings and the damage law are reached; more points would only be number inflation (pillar 1)

**XP (proposal, prototype: Lower 60, Middle 120, High 200).** The bars above grow about ×2.5 per stage. A **cultivation pill** is worth about half a Lower bar of its tier (Qi +30 as in the prototype, Foundation +80, Core +200, Soul +500, Immortal +1200); a **win** gives 10 XP at Qi Gathering and ×2.5 per stage; a night on a cultivation spot gives a little (Meditation Stone ≈ one tenth of a win, Qi Spring double). Rule of thumb: a sub-tier is 3–6 days of focused play at the right stage.

**Breakthrough trials (proposal).** A trial is the step from High to the next stage's Lower. It needs the monster at High, a **Trial Pillar** in the Internal World, and materials of the **next** tier (prototype: 5 for the player, 3 for a monster). On top:

|        Breakthrough        |                               Trial                               |
|----------------------------|-------------------------------------------------------------------|
| Qi Gathering → Foundation  | **Gathering trial:** materials only, no battle                    |
| Foundation → Core          | **Pillar battle:** a 1v1 / 3v3 against a guardian team of the new stage; a *Breakthrough pill* removes the penalty (the player starts at half HP) |
| Core → Soul                | **Trial floor:** a dungeon floor with a boss and the new stage's materials; the monster (or player) must be in the winning team |
| Soul → Immortal            | **Tribulation:** a 5v5 against a mirrored team of your own stage, Upper stones are consumed (money-as-cultivation, §7.3) |
| Immortal → Sovereign       | **Story:** the clan arc and a mirror duel, no grinding              |

A monster's breakthrough is the materials plus, from Core on, a won trial battle with it in the team. Everything else about the step (stats, EP, skills) is automatic.

### 6.4 Tamer Skills

The tamer skills of gdd_battle §5.11 (Spatial Pull, Qi Suppression, Spirit Shield, Domain Glimpse, Beast Swap and the new proposals there) are **learned over the game** and **chosen before each battle** into the player's **tamer slots**.

**Two sources:** (1) **cultivation progression:** each breakthrough of the *player* lets them pick one skill of the stage's list (gdd_battle §5.11 column "Stage"); (2) **scrolls:** an item (`kind: Scroll`, §7.6) that teaches one skill when studied (1 AP, §2.6). Scrolls come from many places (§7.8): dungeons, the Guild Hall, the auction, quests, the clan leader and favor rewards. Higher-grade scrolls teach skills of a later stage early, which is the main use of a Rare scroll.

- Slots: 1 at Foundation → 2 at Core Formation → 3 at Immortal (§6.3). Qi Gathering has none. Humans, not monsters, carry them: enemy tamers bring theirs too and show them in their sheet
- **Beast Swap** is a skill like the others but can only be slotted from Soul Tier
- Each slotted skill is **once per battle**, free, never consumed — the choice of slots is part of the pre-battle decision (and visible to the player's own preview; enemy tamers' slots are shown in their sheet)
- Sub-tier does **not** change a skill's strength. Tamer artifacts may adjust range or the numeric effect by +1 within the limits of §6.9, never the number of uses

### 6.5 The Balance Rule (Pills, Medicines, Artifacts, Arrays)

> **Pills fuel progression outside battle. Artifacts grant options, not numbers, inside battle. The battle loadout (tamer skills, medicines, arrays) is chosen before the fight by a human tamer (player or NPC), known to both sides, and may change the field during it.** Medicines and some arrays are used up, tamer skills are not (once per battle, free). Every effect is deterministic and shows in the preview.

All of these goods share one item schema (§7.6).

### 6.6 Pills & Medicines

|  Pill type   |                              Effect                              |              Role             |
|--------------|------------------------------------------------------------------|-------------------------------|
| Cultivation  | chunk of XP (player or monster)                                  | bread-and-butter product      |
| Breakthrough | required ingredient / removes trial penalty                      | stage-up moments              |
| Healing      | restore monster HP **between** battles                           | dungeon attrition supply line |
| Battle prep  | small buff for the *next 1 battle* (+1 init, first-hit immunity) | chosen at pre-battle draft    |
| Bloodline    | rarity ascension ingredient                                      | major rare sink               |
| Revival      | ends the Injured state at once (§5.8)                            | logistics after defeats       |
| Soul Tether  | protects one monster from permanent loss in a Deadly dungeon     | rare, Deadly dungeons only    |
| Reshape Elixir | re-rolls a monster inside another stat shape (§5.2)            | rare ritual item              |
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

#### 7.1.1 Staff (proposal)

Staff are people with a job at a facility or the Dojo. The model should add decisions without a new chore. Three options, from simple to deep:

|                   Model                   |                                              How it works                                              |                           Verdict                           |
|-------------------------------------------|--------------------------------------------------------------------------------------------------------|-------------------------------------------------------------|
| **A. Skill + visible Loyalty**            | each hire has a *Skill* (output of the job) and a *Loyalty* (0–5, visible); wages and favor raise it, neglect and better offers lower it; at 0 they quit and the morning report says so | simple, readable, no surprise                |
| **B. A + Traits**                         | one visible trait per hire: *Greedy* (paid more, loyal to the stone), *Proud* (wants a better job title), *Devoted* (cheap, stays), *Ambitious* (can be poached by a faction whose Standing with you is lower than theirs) | recommended: gives the Dojo and the story hooks something to say |
| **C. B + Deception (hidden)**             | a hidden *Deception* stat: shown Loyalty = true Loyalty + Deception; a high-Deception hire looks safe and is not. A social event (**Investigate**, 1 AP) shows the truth | strong story tool, but a hidden number; keep it to a few story characters (a spy sent by a rival family), never random hires |

- **Recommendation: A + B for everyone, C only for scripted characters.** Betrayal then is a story beat with a clue, not a dice roll. There is no night event pool for this: staff leave or are poached because the visible rules say so, and the morning report shows it
- A hire's *Skill* decides output (one number per job: output per night); a hire's *Loyalty* decides stay or go; faction members hired through the Dojo start with the faction's loyalty bonus
- Poaching: a faction with higher Standing may offer an Ambitious hire a better post; the player can counter by paying (stones) or promoting (a better facility)

### 7.2 Favor & Faction

Connections are a **currency**, not a nebulous relationship system. The goal: favor must feel like a ladder you climb, never a ledger you are punished by.

#### 7.2.1 The Model (proposal)

Two numbers per faction (the 3 families, City Lord & City Guard, Merchants' Guild, §3.2):

```
FAVOR     points, earned and SPENT: the small change (a discount, an introduction, one request done for you)
STANDING  a rank: Stranger → Known → Trusted → Allied → Sworn
          the sum of all favor ever EARNED fills it. Never lost, never spent
```

- **Earn favor** from requests (Notice Board, Envoy, Watch Post), selling cheap to them, arena wins, auctioning items they want, defeating their rivals
- **Spend favor** on discounts, introductions (an NPC arranges something), rush orders. Spending never lowers Standing
- **Standing opens things:** licenses, Production License, rare blueprints and scrolls, auction invites, breakthrough trial access, recruiting their people (all "access", paid for once by rank, not by points)
- **No decay, no timers, no hidden numbers:** both numbers are shown, and a faction's board lists 3–5 open requests that expire in days but never force an action (§2.3)
- **Rival pair (the two rival families):** reaching Allied with one caps the other at Trusted until you choose a side; favor with one never *costs* favor with the other, only the top rank is exclusive. This is the one real dilemma of the system
- **The player's own family** is the exception: respect is earned by power (cultivation stage, arena), not by errands

#### 7.2.2 Other ideas (not chosen)

|           Idea           |                             Why not (yet)                              |
|--------------------------|------------------------------------------------------------------------|
| Single reputation meter  | easiest, but nothing to spend: favor actions disappear                 |
| Faction contracts        | long supply contracts (deliver X per week): deep for the Trader loop, a chore for everyone else; a good late addition for the Guild only |
| Gift economy             | give items to raise favor: invites hoarding and a per-NPC like/dislike table, the exact "nebulous relationship system" to avoid |

- **The player's faction = recruited staff:** each hire is a character with a stat, loyalty value and story hook (§7.1.1)
- The Dojo doubles as the faction pipeline; late game, faction members run dungeon expeditions (idle Acquire)
- Clan arc writes itself: success forces the clan to notice → tribute demands or absorption attempts → loyalty vs independence
- Open: faction names, exact rank thresholds, request pools (§9)

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

### 7.5 Materials, Seeds and Grades

One grade scale for all goods, the same four names as monster rarity: **Normal · Rare · Epic · Legendary**. The grade decides where an item can come from (§7.8): Normal is buyable, Rare comes from dungeons, the Guild and crafting, Epic from bosses, quests, the clan leader or rare auction invites, Legendary only from the story.

```
MATERIAL = aspect (F/N/D/neutral) × tier (cultivation stage) × form × grade
FORMS    herb · ore · beast part (by Kin) · essence
```

- Foundation-tier pill needs Foundation-tier herbs → deeper dungeons stay relevant automatically
- Beast parts drop by **kin** (Scaled hide, Winged feather) → collection ties into crafting; the part's grade follows the monster's rarity
- ~4 forms × 3–4 aspects × 4 tiers ≈ 48+ materials from one schema, times the grades that exist for each

**Which materials can be planted?** Only **herbs**. Ores are found and bought, beast parts drop, essences come from bosses. A Normal / Rare herb grows in an **Herb Plot**, an Epic herb only in a **Spirit Tree**, a Legendary herb cannot be planted at all (story only).

**Seed data model.** A seed is an ordinary item that points to one herb: no separate seed system.

```
SEED  (item kind Seed)
  grows     : herb material id        ← one seed per herb, 1:1 (not per aspect and tier)
  grade     : inherited from the herb
  nights    : growing time (tier and grade; adjacency can cut it, §4.3)
  yield     : herbs per harvest
  plot      : Herb Plot | Spirit Tree
```

The seed is consumed by planting; a harvest returns the herbs and, for Normal herbs only, one new seed. Seeds come from dungeons, the Trader (Normal), the Guild and the auction (§7.8).

**Recipes (all producers share one schema).**

```
RECIPE  station  : Refining Furnace | Array Workshop | Artifact Forge | pill / goods stall
        inputs   : [(material or filter, count)]      e.g. 3 herbs of tier T, any aspect
        output   : item (kind, tier, grade, aspect)
        cost     : queue for free, or work for 1 AP (§2.6)
        source   : blueprint / Production License / starting knowledge
```

Furnace, Array Workshop and the Forge are the same code with different stations (pillar 6).

**Pill catalog (families × tiers).** Tier T = a stage. Pills of one family use the same pattern at every tier, so ten families give ~40 pills:

|        Family         |                  Effect                  |                    Recipe pattern (tier T)                    |
|-----------------------|------------------------------------------|---------------------------------------------------------------|
| Cultivation           | XP (+30 / 80 / 200 / 500 / 1200)         | 3 herbs of tier T, any aspect                                 |
| Aspect Cultivation    | the same, ×1.5 for the matching aspect   | 3 herbs of one aspect + 1 essence                             |
| Healing               | restore 2 HP between battles             | 2 herbs of tier T                                             |
| Revival               | ends Injured at once                     | 2 herbs + 1 beast part                                        |
| Swift (battle prep)   | +1 initiative in the next battle         | 2 herbs + 1 ore                                               |
| Ward (battle prep)    | first-hit immunity in the next battle    | 2 herbs + 1 beast part                                        |
| Breakthrough          | removes the trial penalty (§6.3.1)       | 1 Rare herb of tier T+1 + 2 ore                               |
| Bloodline             | rarity ascension (§5.6)                  | 1 Rare+ beast part of the Kin + 1 herb of tier T+1 + Upper stones |
| Soul Tether           | protects a monster in Deadly dungeons    | 1 Epic herb + 1 beast part                                    |
| Reshape Elixir        | re-roll into another stat shape (§5.2)   | 1 Epic essence + 3 herbs                                      |
| *Medicine* *(planned)*| used in battle, effect open (§9)        | open                                                          |

**Arrays (kind Array, `while_deployed`).** Small battlefield changes on home turf (§6.8), made at the Array Workshop from ore + a beast part (tier and grade follow the inputs):

|        Array       |                          Effect                           |
|--------------------|-----------------------------------------------------------|
| Attunement Array   | 2 start squares begin attuned to the owner's aspect       |
| High Ground Array  | 1 start square begins Elevated                            |
| Warding Array      | the first Surge damage on the owner's side is 1 less      |
| Footing Array      | one start square cannot be pushed or pulled onto/off      |

The same item kind is used for the in-battle loadout (consumed or reusable, open, §9).

**Smith.** There is no separate weapon/armor system. The **Artifact Forge** (inside, or on a property run by a staff smith) turns **ore + beast parts** into **artifacts** (§6.7). An artifact has a *slot name* for flavor (Weapon, Robe, Charm), a passive from the library and a tiny stat mod; a human tamer wears 2–3, a monster 1–2. The grade of the ore sets the grade of the artifact. Recommendation: this single path, so one recipe system covers pills, arrays, seals and gear.

### 7.6 Item Schema

Goods are the **output tier of the material chain** — tradeable, one shared schema, no new resource category:

```
ITEM
  kind    : Material | Seed | Pill | Artifact | Array | Seal | Scroll | Blueprint
  aspect  : F / N / D / neutral
  tier    : matches cultivation stages
  grade   : Normal | Rare | Epic | Legendary
  value   : spirit stone base price
  effect  : null (materials) | grows (seeds) | on_use (pills) | while_equipped (artifacts)
            | while_deployed (arrays) | binds (seals) | teaches (scrolls) | unlocks (blueprints)
```

### 7.7 Economy Design Rule

> **Spirit stones buy speed and breadth — never things battles can't earn.** Rarity-ascension materials, trial access, unique monsters: locked behind favor/story/dungeon depth, money only a partial input. Otherwise Trader becomes the only correct playstyle and the battle game dies.

### 7.8 Acquisition Sources

Where things come from. Every row feeds the same item schema; money is only ever a partial input for the top grades (§7.7).

|        Source        |                          Gives                           |                    Notes                    |
|----------------------|----------------------------------------------------------|---------------------------------------------|
| **Dungeons**         | materials, seeds, eggs, scrolls, seals, blueprints, bindable monsters, boss parts | the core of the battle gate; deeper = higher tier and grade |
| **Trader**           | Normal materials, Normal seeds, Normal seals and pills   | prices drift; no AP                        |
| **Guild Hall (trading hall)** | Rare blueprints, contracts, scrolls, Rare materials | needs Guild Standing                       |
| **Auction Hall**     | monsters, eggs, Rare+ materials, scrolls                 | invites by Standing; player consigns and bids with Deal |
| **Planting**         | herbs from seeds                                         | Herb Plot (Normal / Rare), Spirit Tree (Epic) |
| **Crafting**         | pills, arrays, seals, artifacts                          | Furnace, Workshop, Forge                   |
| **Breeding / hive**  | eggs, new individuals                                    | §5.7                                       |
| **Clan leader**      | Rare / Epic gifts, scrolls, eggs                         | story and Family Standing                  |
| **Quests**           | any item, often unique ones                              | Notice Board, Watch Post, story            |
| **Arena**            | favor, scrolls, seals                                    | ranking rewards                            |

Rarity ascension materials (§5.6): the grade of the new rarity comes from dungeon bosses, quests, the clan leader or the auction. A dungeon **reward table** (what each floor and boss pays) is built from this list; it waits for the catalogs (§9).

### 7.9 Inventory and Loadout

- **Only humans have an inventory:** the player and NPC tamers. Monsters own no items except socketed artifacts. The Internal World's Storehouse holds what was carried in
- The player's inventory is a list of item stacks (no weight system for now); items are sold, used, crafted or equipped from it
- The **battle loadout** is a subset picked before a fight (tamer skills in slots, medicines, arrays). **Human opponents bring a loadout too**; wild monsters never do, because they have no human behind them. Counts and timing: open (§9)

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
         WASD + E, iso camera, monster follows; visible dungeon (the ambush bonus is dropped from the design, still in the code); building system:
         grid, blueprints + materials, cultivation spots, herb plots, adjacency; skill evolution at
         the Evolution Pillar, breakthrough; Producer: Refining Furnace + Pill Stall, healing and
         battle-prep pills; Favor with the Family, the Merchants' Guild and the City Watch: requests,
         discounts, licenses, recruits; walkable Clan Compound),
         Producer business, favor system with 2-3 factions
PHASE 3  Dojo/faction staff, consigning at the Guild's auction hall, monster hall,
         internal world growth stages, clan storyline
```

> **Prototype notes:** skill evolutions are done at the Evolution Pillar (1 AP each), taking them all back costs 1 AP + 4 materials of the monster's aspect, a breakthrough 1 AP + 5 materials (player) / 3 (monster), HP/Initiative 75% / 90% / 100% by sub-tier, pill +30 XP for 80 stones, a dungeon win +10 XP.

> **Design ahead of the code (v0.10):** the Pill Stall still stands in the Inner World, the Herb Plot plants materials instead of seeds, and the factions are still Family, Guild and Watch (no rival families, no City Lord). Stats still snap by sub-tier (no frames, budget or stat points), AP is still a fixed 2, Move still costs 1 AP (no Step, no movement skills), kits are still fixed to Move + Strike + Surge + utility, in-battle medicines and arrays don't exist yet, and the Evolution Pillar has no Size path.

> If a management feature doesn't eventually output battle power or story access — cut it.

---

## 9. Open Questions (Overworld & Meta)

Decided in v0.11 and no longer open: the frame is only for the roll, the stat shape can change (Reshape), TPR and AP stay priced separately, AP 4 / 5 from Immortal / Sovereign (TPR 1 shapes only), defeat = Injured, catching with Binding Seals, monsters share the player's stage names, no ambush bonus, no night event pool, no adjacency in the city, Slums stay without a faction for now, only humans carry an inventory.

**Monsters & progression**
- **Skill slots:** who fills the 4 slots? Direction from the designer: *Step + 4 skills, each active or passive, at least one active*, passives tied to species / aspect / individual. Decide **after** the skill catalog (gdd_battle §5.12). Related: do all species get a learnable list of about 8 skills (§6.3.1), and does that make the Swap evolution path redundant?
- Does the **Reshape** ritual (re-roll inside another frame, §5.2) need a cooldown or a cap, so it does not become a free reroll for the best stats?
- Evolution points: are 1 EP (Normal / Rare) and 2 EP (Epic / Legendary) and the Size cost of 2 EP right? Check the Normal path: 2 EP over Foundation and Core
- XP bars, pill XP and trials in §6.3.1 are a first curve: check with the prototype
- **Battle loadout:** how many medicines / arrays per battle, when (own turn, any time, 0 AP or AP), which ones are consumed, and what do medicines do exactly? (Humans only bring one, §7.9)
- **Aspect system:** does the aspect carry enough weight (Surge type, zone family, ±1 attunement) without making aspect alone win? Is it needed at all? **Dual-aspect monsters** (Immortal) wait on that answer; gdd_battle has no rules for a second aspect

**Battle hand-off**
- Injury numbers: 2 nights, Revival pill price, Deadly dungeon loot bonus (§5.8)
- Seal prices and grades; the second bind (tamer skill) and the egg timers (§5.7)
- Which parts of a battle's **board** does a dungeon node fix, and which does the generator in gdd_battle §4.1 draw? Proposal: the node fixes mode, theme (which ground families) and the prop count range; the generator places everything, point-symmetric
- Loadout counts and timing of human opponents (see above)

**Management & world**
- Day AP per stage (proposal in §2.6) and AP cost of the Arena
- Market price fluctuation model for the Trader loop: after the item catalogs (§7.5–§7.8) are complete
- Dungeon expedition structure (floors per run, HP persistence, retreat) and the **reward table**: after the catalogs
- Staff: confirm model A + B (§7.1.1)
- Favor: confirm the two-number model, rank thresholds, rival pair rule (§7.2.1), faction names and what each family offers
- Who runs the Arena, the Teleport Plaza and the Business District? (§3.1.9 proposes City Lord, City Lord, Merchants' Guild)
- Number of materials, herbs and recipes: the catalog tables (§7.5) are patterns, not final lists
- **Internal World staff:** no staff inside for now (§4); may change

---

## 10. Changelog

### Changes in v0.11 (sync with gdd_battle v6.2)

- **Stats:** every stat is priced in full (value × price, base 17), each frame shows its absolute point range and the budget is checked against it for all stages (§5.2). The frame is only for the roll, spending is limited by the stage ceilings only. Unplaceable roll points stay as unspent points. The stat shape can change through a Reshape ritual. AP caps: Immortal 4, Sovereign 5 (TPR 1 shapes only, §5.3)
- **Monster progression:** the 18-step table, evolution points by rarity (replacing "paths picked"), XP bars and breakthrough trials (§6.3.1). Evolution validation rules (§5.4)
- **Obtaining and losing monsters:** binding with seals, auction, breeding, eggs, hive (§5.7); defeat = Injured, optional Deadly dungeons (§5.8)
- **Tables:** action catalog (§2.6), building index (§3.1.9), spatial space contents, adjacency and capacity (§4.3–§4.4), materials, seeds, pills, arrays and smith (§7.5), acquisition sources (§7.8), inventory (§7.9)
- **Management:** staff model (§7.1.1), favor and standing (§7.2)
- **Removed:** the ambush bonus, the night event pool
- **Tamer skills:** two sources, cultivation and scrolls (§6.4)

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
