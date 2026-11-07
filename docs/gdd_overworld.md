# GDD — OVERWORLD & META
*Working Draft v0.12 · synced with gdd_battle.md **v6.3** and gdd_monsters.md **v1.0** (gdd_battle is the source of truth for battle rules, gdd_monsters for monsters, stats and skills)*

---

## 1. Overview

**Confirmed decision:** monsters have no fixed aspects, no aspect triangle and no fixed elements as a replacement. Themes are free-form; species define their learnable skill lists. Attunement is removed. Concrete themes and effects remain, but do not imply an affinity, matchup or learning restriction. This decision supersedes older aspect-based proposals and prototype descriptions; historical changelogs remain unchanged.

**Specification boundary:** gdd_monsters **chapter 4** is the single authoritative monster-skill specification: §4.1 kit/access, §4.2 construction dimensions, effect contracts and base battle-AP prices, §4.3 validation, §4.4 Surge constraints, §4.5 shared schema, §4.6 species-exclusive/Signature access and §4.7 permanent slot development, shared EP, pill-based replacement, upgrades and budget/AP policy. This document owns their meta integration, progression economy, ritual logistics and still-open day-AP costs, plus the independent tamer-skill and loadout systems. gdd_battle owns runtime execution/resolution. Historical prototype notes and changelogs do not override these boundaries.

A **management + cultivation layer** wrapped around deterministic grid battles (see gdd_battle.md) and a collection of monsters (see gdd_monsters.md), set in a wuxia world. The player is a disrespected beast tamer in a great clan who builds a business empire in the city and cultivates toward immortality.

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
7. **Choices, not damage** — a monster starts with the stats of its stat shape; after that the player spends every level-up's stat points themselves, inside the shape's frame and the stage ceilings (gdd_monsters §2.2). Skills, twists and gear add *options*. Nothing outside battle ever raises Surge, Strike or ground damage

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
| Monster action / skill | authored battle AP and limits: gdd_monsters §4.2 | kit/access §4.1, Surge §4.4, species/Signature §4.6; upgrades and AP policy §4.7 |
| Tamer skill            | free, once per battle            | only slotted skills (§6.4)                                       |
| Medicine *(planned)*   | 1 medicine from the loadout      | consumed; human tamers only         |
| Array *(planned)*      | 1 array from the loadout         | changes squares in battle        |

- **No hidden information:** the full sheets and the loadouts of both sides are known before the battle starts (gdd_battle pillar 6). Wild monsters telegraph Kin and concrete themes in the world; the exact sheet is visible when you engage
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
6. Back in the city, the day goes on (injured monsters need rest, §5.2)

|         Action          |      Cost      |                          Notes                          |
|-------------------------|----------------|---------------------------------------------------------|
| Start an expedition     | 1 AP           | includes all its battles                                |
| Start on a deeper floor | 2 AP           |                                                         |
| Walk, inspect monsters  | free           |                                                         |
| Heal between battles    | 1 healing pill | the only way to restore HP inside a run                 |
| Teleport out            | free           | ends the run, keeps the loot                            |

- **HP persists** between the battles of a run; a battle starts at current HP. Pills are logistics
- Wild monsters are visible, no random encounters. There is **no ambush bonus**: attacking from behind gives nothing
- A monster that is defeated is **Injured**, not dead (§5.2)
- After a win the player may **bind** one defeated wild monster with a Binding Seal (§5.1)
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
| Train a monster      | 1 AP | focused XP; slot development is a separate action (§2.4)   |
| Develop a skill slot | EP; day AP open | permanent individual progression (§6.3.2)          |
| Change a monster skill | Umlernpille; day AP open | outside expeditions only (§6.3.2) |
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
2. Full bar = sub-tier up (Lower → Middle → High); a monster gets **stat points** to spend (gdd_monsters §2.2)
3. At High, a breakthrough trial / ritual leads to the next stage
4. The stage-up unlocks mechanics (bigger teams, evolutions, air layer, tamer slots), expands the Internal World, raises the stat ceilings, opens deeper dungeons

|               Action               |            Cost            |                           Notes                           |
|------------------------------------|----------------------------|-----------------------------------------------------------|
| Cultivate (player XP)              | 1 AP                       |                                                           |
| Train a monster (focused XP)       | 1 AP                       |                                                           |
| Win a battle                       | free                       | XP for the team                                           |
| Take a cultivation pill            | 1 pill                     | chunk of XP (prototype: +30)                              |
| Assign a monster to a spot         | free                       | idle XP every night                                       |
| Spend stat points                  | free                       | inside the shape's frame and the stage ceilings (gdd_monsters §2.2)    |
| Develop a skill slot               | EP; day AP open            | permanent slot progress; directly grants a skill-specific upgrade choice (§6.3.2) |
| Change a monster skill             | Umlernpille; day AP open   | unlocked species learnable list; outside expeditions (§6.3.2) |
| Breakthrough                       | 1 AP + materials           | prototype: 5 materials (player) / 3 (monster)             |
| Take back physical evolutions      | 1 AP + materials           | prototype quantity: 4 materials; input selection open (temp_todo T16/T30); not a skill-upgrade respec |

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
| Monster action / skill          | Battle | authored battle AP: gdd_monsters §4.2 / §4.7 | in a fight | runtime: gdd_battle; no generic Unique price |
| Tamer skill                     | Battle | free, once per battle (§6.4) | slotted before battle | independent tamer source / loadout |
| Use a medicine / array           | Battle   | from the loadout           | human tamer                                       | planned                                      |
| Bind a defeated wild monster     | Battle   | free + 1 Binding Seal      | win; seal tier and grade high enough (§5.1)       | in the result screen                         |
| Start an expedition              | Expedition | 1 AP (2 AP deeper floor) | Teleport Array                                    | includes all its battles                     |
| Walk, inspect, teleport out      | Expedition | free                     | —                                                 | teleport out keeps the loot                  |
| Heal in a run                    | Expedition | 1 healing pill           | pill                                              | the only way to restore HP in a run          |
| Cultivate                        | Cultivation | 1 AP                    | —                                                 | player XP                                    |
| Train a monster                  | Cultivation | 1 AP                    | —                                                 | focused XP                                   |
| Study a scroll                   | Cultivation | 1 AP                    | Scroll (§7.6)                                     | learns a tamer skill / recipe / blueprint    |
| Take a pill (other than Umlernpille) | Cultivation | free + 1 pill        | pill                                              | XP, healing, cure; skill change has its own row |
| Assign a monster to a spot       | Cultivation | free                    | spot in the Internal World                        | idle XP every night                          |
| Spend stat points                | Cultivation | free                    | unspent points                                    | inside the stage ceilings (gdd_monsters §2.2)             |
| Change a monster skill    | Cultivation | Umlernpille; day AP open | outside expeditions; unlocked species learnable list | no EP purchase; slot progress stays, matching upgrades reselected (§6.3.2) |
| Develop a skill slot             | Cultivation | EP; day AP open         | individual slot; Evolution Pillar                 | directly grants a designer-authored, skill-specific upgrade choice (§6.3.2); EP prices open |
| Take back physical evolutions    | Cultivation | 1 AP + 4 materials      | Evolution Pillar                                  | prototype cost; not a skill-upgrade respec |
| Breakthrough                     | Cultivation | 1 AP + trial + materials | High sub-tier, Trial Pillar                      | prototype: 5 (player) / 3 (monster) materials |
| Rarity ascension                 | Cultivation | 1 AP + rare materials   | Bloodline pill; ritual site open (temp_todo T30; gdd_monsters §7.3)               | major event                                  |
| Reshape (change stat shape)      | Cultivation | 1 AP + Reshape Elixir   | Trial Pillar                                      | rare item (gdd_monsters §2.2)                             |
| Rest an injured monster          | Cultivation | free                    | Recovery Spring or time                           | §5.2                                         |
| Pair monsters / place an egg     | Cultivation | free                    | Breeding Den / Incubator                          | resolves over nights (§5.1)                  |
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

- **Free = looking, ordering, assigning, spending stat points, queueing** (golden rule, §2.3). Execution normally costs 1 AP; night production is queued for free. Monster skill changes consume an Umlernpille and are not free re-slotting; their day-AP cost and that of slot development remain open (T05/T16/T31)

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

\* proposed operators. Built so far: Teleport Plaza, Market District, Clan Compound.

#### 3.1.1 Clan Compound

The player's home base, and where the clan looks down on them.

- **Clan Hall** — clan meetings, summons, Family favor
- **Notice Board** — requests and quests *(built)*
- **Clan Envoy** — Family favor actions *(built)*

#### 3.1.2 Rival Compounds

Closed to the player at first; entering one is a story and favor beat.

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

- **Black Stall** *(idea)* — odd goods; optional concept

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
| **Two rival families**     | cultivation families competing with the player's | not specified                                                          |
| **City Lord & City Guard** | law, peace and order in the city                 | Street Trade Permit, beasts for hire                                   |
| **Merchants' Guild**       | runs trade, the market and the **auction hall**  | Trader discounts, rare blueprints, Production License, auction invites |

### 3.3 Dungeons

- **Dungeons:** wild monsters roam visibly (no random encounters); touching = battle. Each node is a room, the doors lead to the next nodes (flow and costs: §2.2)
- Dungeon monsters are full **individuals** (own stat shape, stage, evolutions) and telegraph Kin and concrete themes visually; their complete sheet is shown in the pre-battle screen → informed roster picks and counter-picks
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
- **Monster management:** inspecting stat shapes, spending stat points, planning evolution choices and equipping artifacts are free. Executing progression rituals follows §2.6; slot-development and skill-replacement day AP remain open (§6.3.2), not covered by the free planning rule

### 4.2 Building System

Everything placeable in the Internal World is a **Structure**; blueprints are one acquisition path among several.

```
STRUCTURE
  name, size (grid footprint), category
  source     : blueprint (craft w/ materials) | buy | quest/story reward
  level      : upgradeable with materials
  placed_on  : internal world grid cell
```

- **Coarse grid placement**, free to move anytime, structures never lost
- **Adjacency bonuses** make layout a real puzzle: herb plot + water = -1 grow night; adjacency exists **only here**, never in the city (table in §4.3)

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
| Rarity ascension site *(open)* | Special | site and requirements need redesign (temp_todo T30); no aspect affinity | |
| Evolution Pillar     | Special     | slot-development ritual site (§6.3.2)                                      |   ✓   |
| Trial Pillar         | Special     | breakthrough rituals                                             |       |
| *New structures*     |             | Breeding Den, Incubator, Hive Nest, Recovery Spring, Study Desk, Storehouse: see §4.3 |  |

Production structures may stand **inside or on a city property** (§7.1). Commerce and quest buildings are city only (§3.1).

### 4.3 What Lives in the Spatial Space

Everything the spatial space can hold, in one table. **Footprint** is in grid cells (a monster of size 2x2 takes 4 cells when it stands still); **Placement** says how it sits on the grid. Footprints, unlock stages and the places marked *new* are a first proposal.

| Category |         Thing         | Footprint |       Placement        |                       Function / place for                        |  Unlock  |
|----------|-----------------------|-----------|------------------------|-------------------------------------------------------------------|----------|
| Monster  | Housed monster        | free      | roams the whole grid   | counts against capacity (§4.4)                                    | Qi       |
| Monster  | Assigned monster      | on a spot | stands on its spot     | idle XP at night, or breeding / incubating / resting              | Qi       |
| Monster  | Egg *(new)*           | 1         | inside an Incubator    | hatches after N nights into an individual (§5.1)                  | Foundation |
| Cultivation | Meditation Stone   | 1×1       | any cell               | place for **cultivating**: idle XP                                | Qi       |
| Cultivation | Qi Spring          | 2×2       | any cell               | stronger idle XP, counts as water                                 | Qi       |
| Cultivation | Rarity ascension site *(open)* | open | open | ritual site design pending (temp_todo T30) | open |
| Cultivation | Evolution Pillar   | 1×1       | any cell               | place for **slot development** (§6.3.2)                                     | Foundation |
| Cultivation | Trial Pillar       | 1×1       | any cell               | place for **breakthrough** trials and **reshaping**               | Foundation |
| Cultivation | Study Desk *(new)* | 1×1       | any cell               | place for **studying scrolls** (tamer skills, recipes)            | Foundation |
| Growing  | Herb Plot             | 2×2       | any cell               | place for **planting** seeds                                      | Qi       |
| Growing  | Spirit Tree           | 3×3       | any cell               | slow, high-tier herbs (Epic grade)                                | Core     |
| Housing  | Nest / Cave / Shrine Grove | 2×2 / 2×2 / 3×3 | any cell    | +capacity; kin-matched = mood bonus                               | Foundation |
| Breeding | Breeding Den *(new)*  | 2×2       | any cell               | place for **breeding** a male and a female (§5.1)                 | Core     |
| Breeding | Incubator *(new)*     | 1×1       | any cell               | place for **hatching** eggs                                       | Foundation |
| Breeding | Hive Nest *(new)*     | 2×2       | any cell               | Swarm species multiply here without a pair (§5.1)                 | Core     |
| Recovery | Recovery Spring *(new)* | 2×2     | any cell               | place for **resting** injured monsters (halves the time, §5.2)    | Foundation |
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
| Nest / Cave / Grove  | monster of the matching Kin | mood / loyalty bonus              |
| Recovery Spring      | Spirit Pond           | injured monsters rest one night less    |
| Breeding Den         | Nest / Cave / Grove   | the egg is ready one night earlier      |
| Incubator            | Qi Spring             | hatches one night earlier               |

The former aspect-matched altar XP and furnace AP bonuses are removed. Any new structure or adjacency design is unresolved; ritual-site requirements are tracked in [temp_todo.md](temp_todo.md), T30, and recipe implications in T16.

### 4.4 Capacity and Growth

The space grows with the cultivation step (gdd_monsters §7.4): the **grid** with each stage, the **monster capacity** with each sub-tier. The bench is the capacity minus the team a mode needs; at Core+ it is bigger than the team, so counter-picks are possible. Proposal:

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

## 5. Monsters in the Overworld

What a monster is (individual, stats, skills, evolution, rarity): **gdd_monsters.md**. This chapter is only how a monster enters the collection and what happens when it falls. The battle only ever sees the finished unit sheet (§2.1).

### 5.1 Obtaining Monsters

How a monster enters the collection. Every way ends in the same record: an **individual** (stat shape rolled by the species' Kin lean, gdd_monsters §1.1; rarity; stage). Nothing is rolled in battle, the roll happens when the individual comes into existence.

|        Way        |                                          How                                          |                         Notes                          |
|-------------------|---------------------------------------------------------------------------------------|--------------------------------------------------------|
| **Bind (Seal)**   | after a win the player binds **one** defeated wild monster with a **Binding Seal** (free, in the result screen) | the default way (decided); no dice (below)  |
| **Auction**       | buy monsters and eggs at the Guild's Auction Hall (Deal)                              | sheet visible before the bid; Monster hall can resell  |
| **Breeding**      | a male and a female of the same species in a **Breeding Den**: an egg after N nights (N by rarity) | only species with `breeds: true`; offspring: species of one parent, shape rolled by the Kin lean, rarity = the lower parent's, stage Qi Gathering Lower |
| **Eggs**          | found in dungeons, bought, quest rewards; hatched in an **Incubator**                  | an egg fixes species and rarity; the hatching rolls shape |
| **Hive (Swarm)**  | Swarm species multiply in a **Hive Nest** without a pair; one larva per N nights       | the insect way: no sex                                |
| **Quest / clan**  | story monsters, gifts from the clan leader, favor rewards                              | usually fixed individuals, often high rarity           |
| **Hire**          | Guard Barracks lend beasts for a while                                                 | not owned, no stat growth                              |

**Binding Seal.** An item (`kind: Seal`) with a **tier** (stage) and a **grade** (rarity, §7.5). It binds a monster whose stage is ≤ the seal's tier and whose rarity is ≤ the seal's grade. Normal seals are cheap, higher grades come from dungeons, the Guild and crafting (Array Workshop). The player picks **which** defeated monster to bind: a monster at 0 HP, so it needs nothing but the seal. Tamer skills and scrolls improve it (§6.4): one extra bind, or a seal of a lower tier is enough. Without a seal the defeated monster is released.

- Auction, breeding and eggs are the long game; the seal is what dungeons feed: catching and the Monster hall business are separate loops (§7.1)
- **Ceiling rule:** a seal binds only monsters up to the player's own stage (gdd_monsters §2.2); stronger ones stay wild until the next breakthrough

### 5.2 Defeat and Injury

A monster that falls in battle is **Injured**, not dead:

- It is out for the rest of the expedition; the battle result marks it
- It is **not usable for 2 nights** (resting in the Internal World). A **Recovery Spring** halves that (rounded up), a **Revival pill** ends it at once
- Sub-tier, stat points and evolutions are never lost
- **Arena** fights never injure
- **Deadly dungeons** *(optional, marked at the Teleport Array)* give better loot, but a defeated monster there is **lost for good** unless protected: by the pill **Soul Tether** (one monster) or the tamer skill **Life Thread** (§6.4, the first fall of the battle). This keeps death as a real stake without making every run a risk of losing a favourite

---

## 6. Progression

### 6.1 Cultivation Structure (shared naming, player & monsters)

```
STAGES     Qi Gathering → Foundation → Core Formation → Soul Tier → Immortal → Sovereign
SUB-TIERS  Lower → Middle → High   (per stage)
BREAKTHROUGH  High → next stage's Lower
```

**Monsters use exactly the same stage and sub-tier names as the player**, so one table (gdd_monsters §7.4) covers both.

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

The starting kit and legal access are defined in **gdd_monsters §4.1**; this table summarizes stage integration, not a second kit specification. Battles must never feel starved of options. Progression adds *choices and modes*, not the basic verbs; rarity-related slots remain gdd_monsters §7.2.

|     Stage      |                            Monster unlock                            |                                     Player unlock                                      |
|----------------|----------------------------------------------------------------------|----------------------------------------------------------------------------------------|
| Qi Gathering   | full kit (4 slots) · TPR 1 · AP 2                                  | holds 1 monster · **1v1** (5×5)                                                        |
| Foundation     | physical evolution access · TPR 2 possible                               | holds 3+ monsters · **3v3** (7×7, standard) · **2v2** (6×6) · 1 tamer slot             |
| Core Formation | physical Size path · AP 3 · 2nd artifact slot at Epic+ | holds 5+ monsters (bench for counter-picks) · 2nd tamer slot · **5v5** special battles |
| Soul Tier      | Air layer access (Winged) · 2x2 size · TPR 3 possible · one foreign movement mode                | mid-battle **Beast Swap** from the spatial space                                       |
| Immortal       | Open: former Dual-aspect unlock removed (temp_todo T34)             | 3rd tamer slot                                                                         |
| Sovereign      | Signature / Major Surge access: gdd_monsters §4.6 / §7.4; Ancient-only vs Legendary wording remains open (T02/T32) | full spatial arsenal                                                                   |

> Expansion features (bigger teams, air layer, 2x2, swap) **are** the reward structure — mechanics introduced one breakthrough at a time, solving the tutorial problem for free. Battle modes follow the team size the player can field; **which mode a fight uses is set by the encounter** (a narrow corridor node is a 1v1/2v2, a dungeon hall a 3v3, a tournament a 5v5), and the player needs at least that many monsters.

#### 6.3.1 Breakthrough Trials

The steps themselves (budget, gains, XP): gdd_monsters §7.4.

**Breakthrough trials (proposal).** A trial is the step from High to the next stage's Lower. It needs the monster at High, a **Trial Pillar** in the Internal World, and materials of the **next** tier (prototype: 5 for the player, 3 for a monster). On top:

|        Breakthrough        |                               Trial                               |
|----------------------------|-------------------------------------------------------------------|
| Qi Gathering → Foundation  | **Gathering trial:** materials only, no battle                    |
| Foundation → Core          | **Pillar battle:** a 1v1 / 3v3 against a guardian team of the new stage; a *Breakthrough pill* removes the penalty (the player starts at half HP) |
| Core → Soul                | **Trial floor:** a dungeon floor with a boss and the new stage's materials; the monster (or player) must be in the winning team |
| Soul → Immortal            | **Tribulation:** a 5v5 against a mirrored team of your own stage, Upper stones are consumed (money-as-cultivation, §7.3) |
| Immortal → Sovereign       | **Story:** the clan arc and a mirror duel, no grinding              |

A monster's breakthrough is the materials plus, from Core on, a won trial battle with it in the team. Slot development and its upgrade choices are separate, deliberate purchases, not automatic breakthrough rewards; EP awards remain open.

#### 6.3.2 Permanent Skill-Slot Development (confirmed)

**Rules source: gdd_monsters §4.7.** Permanent slot development, the shared physical/skill evolution EP pool, replacement eligibility, retained development and upgrade reselection, authored upgrade paths and budget/battle-AP policy are defined there only. Construction points are internal authoring data, not the Blueprint items in §7.6.

**Overworld integration:** slot development is a deliberate action at the **Evolution Pillar**, separate from focused-XP Train and breakthrough rewards. Skill replacement uses the **Umlernpille** (relearning pill) through monster management outside expeditions, under the source's eligibility rules. The action tables (§2.3–§2.6), item entry (§6.6) and saved individual (§8) integrate these rules rather than redefine them.

**Open economy/logistics (T05/T16/T31):** slot-development day AP and the pill's acquisition, recipe, tier, price and replacement day AP remain undecided. Neither action inherits the usual 1-day-AP execution default or the prototype ritual price. EP prices, ranks/thresholds, total supply versus physical evolution, same-skill upgrade reselection/respec, reversing EP investments and passive-slot replacement cases remain unresolved under gdd_monsters §4.7. Growth/EP award tables remain in gdd_monsters §7.2/§7.4 and require shared-pool validation.

### 6.4 Tamer Skills

Tamer skills are **learned over the game** and **chosen before each battle** into the player's **tamer slots**. How they work in a fight: gdd_battle §5.8. Rows marked *proposal* are new.

**Shared effect/schema contract, separate source:** concrete tamer definitions reference the effect contracts in **gdd_monsters §4.2**, the shared schema responsibilities in **§4.5** and validation in **§4.3**, while retaining their explicit tamer-source permissions, unlocks, loadout and usage rules here / in gdd_battle §5.8. Resolve targeting, placement, recipients, execution, effect triggers/order, lifetime/consumption, interactions and limits for each source; a table summary alone is not a complete executable definition. Monster-profile permissions, species/Kin access, slot EP and monster-action AP prices do not transfer to tamers. Conversely, Spirit Shield, Spatial Pull, Domain Glimpse or proposed Second Wind do not authorize equivalent monster effects. Unspecified source details, artifact modifications and proposal validation remain T19/T20 (and applicable effect-contract TODOs); do not fill them with invented costs, timing or generic effect permissions.

|      Skill      | Stage |                                  Effect                                  |  Kind  |
|-----------------|-------|--------------------------------------------------------------------------|--------|
| Spatial Pull    | Foundation | move an own monster to any empty square                            | position |
| Qi Suppression  | Foundation | an enemy monster −2 initiative next round                          | tempo |
| Spirit Shield   | Foundation | the next Surge damage on one own monster is 0                      | defense |
| Swap Places *(proposal)* | Foundation | two own monsters trade squares                             | position |
| Domain Glimpse  | Core | clear a tetromino of zones and reset its ground to Plain         | terrain |
| Urgent Order *(proposal)* | Core | an own monster that has not acted this round acts next          | tempo |
| Second Wind *(proposal)* | Core | an own monster regains 1 HP (never above max)                     | defense |
| Life Thread *(proposal)* | Core | the next time an own monster would fall it stays at 1 HP          | defense (also protects in Deadly dungeons) |
| Double Bind *(proposal)* | Core | after the battle one extra defeated wild monster may be bound (§5.1) | catching, uses a slot |
| Beast Swap      | Soul | exchange an active monster with one from the spatial space               | position |
| Seal Mastery *(proposal)* | Soul | Binding Seals one tier lower than the target still bind it       | catching, uses a slot |

Catching skills take a slot on purpose: a team that wants to bind gives up a battle skill.

**Two sources:** (1) **cultivation progression:** each breakthrough of the *player* lets them pick one skill of the stage's list (column "Stage"); (2) **scrolls:** an item (`kind: Scroll`, §7.6) that teaches one skill when studied (1 AP, §2.6). Scrolls come from many places (§7.8): dungeons, the Guild Hall, the auction, quests, the clan leader and favor rewards. Higher-grade scrolls teach skills of a later stage early, which is the main use of a Rare scroll.

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
| Umlernpille  | skill replacement under gdd_monsters §4.7; meta integration §6.3.2 | expensive, deliberate; price / recipe / tier / day AP open (T05/T16/T31); same-skill upgrade respec undecided (T05) |
| Breakthrough | required ingredient / removes trial penalty                      | stage-up moments              |
| Healing      | restore monster HP **between** battles                           | dungeon attrition supply line |
| Battle prep  | small buff for the *next 1 battle* (+1 init, first-hit immunity) | chosen at pre-battle draft    |
| Bloodline    | rarity ascension ingredient                                      | major rare sink               |
| Revival      | ends the Injured state at once (§5.2)                            | logistics after defeats       |
| Soul Tether  | protects one monster from permanent loss in a Deadly dungeon     | rare, Deadly dungeons only    |
| Reshape Elixir | re-rolls a monster inside another stat shape (gdd_monsters §2.2)            | rare ritual item              |
| Medicine *(planned)* | used **in** battle from the loadout    | consumed, feeds Producer      |

Healing pills create the **dungeon attrition loop**: HP persists between fights in an expedition → pills are logistics → deeper floors need better supply → feeds Producer. A battle always *starts* at the monster's current HP (never above its max).

### 6.7 Artifacts (equipment = socketed passives)

```
ARTIFACT = passive from the Passives Library (gdd_monsters §5) + tier + (tiny capped stat mod)
```

Reuses the passive implementation — near-zero new code. Crafting = Producer picks which passive to forge in (recipe determines options). The unit sheet simply lists the passives in the monster's slots, the Epic+ extra passive and the artifact passive(s).

|       Wearer       |          Slots          |                                                                    Effects                                                                     |
|--------------------|-------------------------|------------------------------------------------------------------------------------------------------------------------------------------------|
| **Monster**        | 1 (2nd at Epic+ rarity) | extra passive OR +1 to one stat, **never above stage caps**                                                                                    |
| **Player (tamer)** | 2–3                     | tamer skill mods (+Spatial Pull range, Qi Suppression −3 instead of −2 — never extra uses), +1 AP once/day, +spatial capacity, dungeon utility |

Monster artifacts deepen the battle game; tamer artifacts feed the management/expedition game. A Normal-rarity beast with a perfect artifact-passive combo can rival an Epic — "skill beats stats."

### 6.8 Arrays (artifacts for places)

- Battlefield modifiers on home turf, deployed pre-battle or, *planned*, placed in battle from the loadout (§2.1). The proposed exception to the mirrored-fairness rule of gdd_battle §4.1 stays small: e.g. one start square begins Elevated. No attunement or aspect-based start-square effects.
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

#### 7.1.1 Staff (model B chosen)

Staff are people with a job at a facility or the Dojo. The model should add decisions without a new chore. Three options, from simple to deep:

|                   Model                   |                                              How it works                                              |                           Verdict                           |
|-------------------------------------------|--------------------------------------------------------------------------------------------------------|-------------------------------------------------------------|
| **A. Skill + visible Loyalty**            | each hire has a *Skill* (output of the job) and a *Loyalty* (0–5, visible); wages and favor raise it, neglect and better offers lower it; at 0 they quit and the morning report says so | simple, readable, no surprise                |
| **B. A + Traits (chosen)**                | one visible trait per hire: *Greedy* (paid more, loyal to the stone), *Proud* (wants a better job title), *Devoted* (cheap, stays), *Ambitious* (can be poached by a faction whose Standing with you is lower than theirs) | recommended: gives the Dojo and the story hooks something to say |
| **C. B + Deception (hidden)**             | a hidden *Deception* stat: shown Loyalty = true Loyalty + Deception; a high-Deception hire looks safe and is not. A social event (**Investigate**, 1 AP) shows the truth | strong story tool, but a hidden number; keep it to a few story characters (a spy sent by a rival family), never random hires |

- **Decision: model B for everyone** (C may come later for scripted story characters). Betrayal then is a story beat with a clue, not a dice roll. There is no night event pool for this: staff leave or are poached because the visible rules say so, and the morning report shows it
- A hire's *Skill* decides output (one number per job: output per night); a hire's *Loyalty* decides stay or go; faction members hired through the Dojo start with the faction's loyalty bonus
- Poaching: a faction with higher Standing may offer an Ambitious hire a better post; the player can counter by paying (stones) or promoting (a better facility)

### 7.2 Favor & Faction

Connections are a **currency**, not a nebulous relationship system. The goal: favor must feel like a ladder you climb, never a ledger you are punished by.

#### 7.2.1 The Model (working values)

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
- **Stats (confirmed model, numbers are a proposal).** Per faction the save stores `favor` (spendable), `earned_total` (lifetime, only grows) and `standing` (derived from `earned_total`). Favor comes in sizes, so big and small deals are worth different amounts:

|    Size    | Favor earned | Example                                                      | Request lifetime |
|------------|--------------|--------------------------------------------------------------|------------------|
| Errand     | 1            | deliver 3 herbs, sell a pill cheap                           | 3 days           |
| Task       | 3            | win a dungeon floor for them, craft a batch                  | 5 days           |
| Commission | 8            | bring a boss part, win an arena round against a rival        | 10 days          |
| Great deed | 20           | story beat, defeat their rival's champion                    | story            |

  A request has: faction, **size**, **tier** (a stage: only requests up to the player's stage are shown), lifetime in days, repeat limit, item or battle goal, extra reward. Favor is the same unit everywhere; only the size differs

|   Spend    | Cost  |                    Example                     |
|------------|-------|------------------------------------------------|
| Small      | 1–3   | a day of discount, an introduction             |
| Medium     | 5–10  | rush order, a scroll offer, a hint for a dungeon |
| Large      | 15–30 | a licence, recruiting one of their people, an auction invite |

  **Standing thresholds** (by `earned_total`): Known 5 · Trusted 30 · Allied 100 · Sworn 250. Standing gates *what can be bought*, the stage gates *which requests exist*
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
MATERIAL = tier (cultivation stage) × form × grade
FORMS    herb · ore · beast part (by Kin) · essence
```

- Foundation-tier pill needs Foundation-tier herbs → deeper dungeons stay relevant automatically
- Beast parts drop by **kin** (Scaled hide, Winged feather) → collection ties into crafting; the part's grade follows the monster's rarity
- Concrete material identities, recipe inputs and catalog size remain open ([temp_todo.md](temp_todo.md), T16); no aspect or fixed-element multiplier.

**Which materials can be planted?** Only **herbs**. Ores are found and bought, beast parts drop, essences come from bosses. A Normal / Rare herb grows in an **Herb Plot**, an Epic herb only in a **Spirit Tree**, a Legendary herb cannot be planted at all (story only).

**Seed data model.** A seed is an ordinary item that points to one herb: no separate seed system.

```
SEED  (item kind Seed)
  grows     : herb material id        ← one seed per herb, 1:1 (not per tier)
  grade     : inherited from the herb
  nights    : growing time (tier and grade; adjacency can cut it, §4.3)
  yield     : herbs per harvest
  plot      : Herb Plot | Spirit Tree
```

The seed is consumed by planting; a harvest returns the herbs and, for Normal herbs only, one new seed. Seeds come from dungeons, the Trader (Normal), the Guild and the auction (§7.8).

**Recipes (all producers share one schema).**

```
RECIPE  station  : Refining Furnace | Array Workshop | Artifact Forge | pill / goods stall
        inputs   : [(material or filter, count)]      e.g. 3 herbs of tier T
        output   : item (kind, tier, grade)
        cost     : queue for free, or work for 1 AP (§2.6)
        source   : blueprint / Production License / starting knowledge
```

Furnace, Array Workshop and the Forge are the same code with different stations (pillar 6).

**Pill catalog (families × tiers).** Tier T = a stage. Pills of one family use the same pattern at every tier, so ten families give ~40 pills:

|        Family         |                  Effect                  |                    Recipe pattern (tier T)                    |
|-----------------------|------------------------------------------|---------------------------------------------------------------|
| Cultivation           | XP (+30 / 80 / 200 / 500 / 1200)         | 3 herbs of tier T                                 |
| Healing               | restore 2 HP between battles             | 2 herbs of tier T                                             |
| Revival               | ends Injured at once                     | 2 herbs + 1 beast part                                        |
| Swift (battle prep)   | +1 initiative in the next battle         | 2 herbs + 1 ore                                               |
| Ward (battle prep)    | first-hit immunity in the next battle    | 2 herbs + 1 beast part                                        |
| Breakthrough          | removes the trial penalty (§6.3.1)       | 1 Rare herb of tier T+1 + 2 ore                               |
| Bloodline             | rarity ascension (gdd_monsters §7.3)                  | 1 Rare+ beast part of the Kin + 1 herb of tier T+1 + Upper stones |
| Soul Tether           | protects a monster in Deadly dungeons    | 1 Epic herb + 1 beast part                                    |
| Reshape Elixir        | re-roll into another stat shape (gdd_monsters §2.2)   | 1 Epic essence + 3 herbs                                      |
| *Medicine* *(planned)*| used in battle (planned)                 | not specified                                                          |

The former aspect-matched cultivation pill is removed, including its matching multiplier. Any new pill/catalog design belongs to [temp_todo.md](temp_todo.md), T16; no replacement effect or recipe is specified.

**Arrays (kind Array, `while_deployed`).** Small battlefield changes on home turf (§6.8), made at the Array Workshop from ore + a beast part (tier and grade follow the inputs):

|        Array       |                          Effect                           |
|--------------------|-----------------------------------------------------------|
| High Ground Array  | 1 start square begins Elevated                            |
| Warding Array      | the first Surge damage on the owner's side is 1 less      |
| Footing Array      | one start square cannot be pushed or pulled onto/off      |

The same item kind is used for the planned in-battle loadout.

**Smith.** There is no separate weapon/armor system. The **Artifact Forge** (inside, or on a property run by a staff smith) turns **ore + beast parts** into **artifacts** (§6.7). An artifact has a *slot name* for flavor (Weapon, Robe, Charm), a passive from the library and a tiny stat mod; a human tamer wears 2–3, a monster 1–2. The grade of the ore sets the grade of the artifact. Recommendation: this single path, so one recipe system covers pills, arrays, seals and gear.

### 7.6 Item Schema

Goods are the **output tier of the material chain** — tradeable, one shared schema, no new resource category:

```
ITEM
  kind    : Material | Seed | Pill | Artifact | Array | Seal | Scroll | Blueprint
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
| **Breeding / hive**  | eggs, new individuals                                    | §5.1                                       |
| **Clan leader**      | Rare / Epic gifts, scrolls, eggs                         | story and Family Standing                  |
| **Quests**           | any item, often unique ones                              | Notice Board, Watch Post, story            |
| **Arena**            | favor, scrolls, seals                                    | ranking rewards                            |

Rarity ascension materials (gdd_monsters §7.3): the grade of the new rarity comes from dungeon bosses, quests, the clan leader or the auction. A dungeon **reward table** (what each floor and boss pays) is built from this list.

### 7.9 Inventory and Loadout

- **Only humans have an inventory:** the player and NPC tamers. Monsters own no items except socketed artifacts. The Internal World's Storehouse holds what was carried in
- The player's inventory is a list of item stacks (no weight system for now); items are sold, used, crafted or equipped from it
- The **battle loadout** is a subset picked before a fight (tamer skills in slots, medicines, arrays). **Human opponents bring a loadout too**; wild monsters never do, because they have no human behind them. Loadout design tracking: [temp_todo.md](temp_todo.md), T19

---

## 8. Technical Notes (Overworld) & Development Phases

- **Overworld = same 3D + fixed iso camera as battles** — one art pipeline (character controller, camera rig, props, lighting shared)
- Structure: connected small scenes (hub-based city districts + dungeon nodes), never open world
- Cheapest v1: **node-based map** (Slay-the-Spire style) — click location → scene/battle; upgrade to walkable districts later
- Night phase = single synchronization point → save-friendly, no real-time simulation ("on day end, run all resolvers once")

**Data model (mirrors the battle's data-driven approach, gdd_battle §7.1):**

- **Species** = the existing `MonsterDef` data files (Kin, free-form themes, learnable skill list, default kit, species passive). They no longer carry fixed stats for a stage — stats come from the individual
- **Individual** = a save-game record (species id, stat shape, stats, unspent stat points, rarity, stage / sub-tier / XP, shared EP balance, physical evolution picks, permanent development progress per skill slot, equipped skill per slot and its selected skill-specific upgrades, artifacts, current HP). Persist slot progress and resolved upgrade selections according to gdd_monsters §4.7 (meta integration §6.3.2); skill definitions and authorized patches use its §4.5 schema, not a separate overworld skill model. Blueprint points are internal design data, not a saved player-currency balance. It owns **no battle rules**
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

> **Prototype notes:** skill evolutions are done at the Evolution Pillar (1 AP each), taking them all back has a prototype cost of 1 AP + 4 materials (input selection pending, temp_todo T16/T30), a breakthrough 1 AP + 5 materials (player) / 3 (monster), HP/Initiative 75% / 90% / 100% by sub-tier, pill +30 XP for 80 stones, a dungeon win +10 XP.

> **Design ahead of the code (v0.10):** the Pill Stall still stands in the Inner World, the Herb Plot plants materials instead of seeds, and the factions are still Family, Guild and Watch (no rival families, no City Lord). Stats still snap by sub-tier (no frames, budget or stat points), AP is still a fixed 2, Move still costs 1 AP (no Step, no movement skills), kits are still fixed to Move + Strike + Surge + utility, in-battle medicines and arrays don't exist yet, and the Evolution Pillar has no Size path.

> If a management feature doesn't eventually output battle power or story access — cut it.

---

## 9. Design Tracking

Open decisions, dependencies and validation tasks are maintained centrally in [temp_todo.md](temp_todo.md). Existing proposals remain the working design until their review is complete, except where superseded by the confirmed no-aspects/no-attunement decision (§1) or the authoritative monster-skill specification (gdd_monsters chapter 4, especially §4.7; meta integration §6.3.2). T05 tracks slot-development ranks, thresholds, EP prices and awards, and the undecided same-skill upgrade respec; T05/T16/T31 track Umlernpille price, recipe, tier and day AP, and slot-development day AP. T02/T05 retain component prices, combination surcharges, budget thresholds and upgrade calibration; no local monster-cost list overrides gdd_monsters §4.2/§4.7. T02/T32 retain the Ancient-only versus Legendary Major Surge access conflict (§6.3); T19/T20 retain unresolved tamer/loadout source contracts. Historical Prototype notes and changelogs below do not override these confirmed rules. T16 covers material/item/recipe redesign; T30 covers ritual requirements and sites. The former Legendary aspect-change progression (T33) and Dual-aspect progression (T34) are not active mechanics; those entries need review under the confirmed decision, not implementation of aspect changes or a replacement system.

---

## 10. Changelog

### Changes in v0.12 (sync with gdd_battle v6.3, gdd_monsters v1.0)

- **New file gdd_monsters.md:** the individual, stats, frames, ceilings, skill evolution, rarity, ascension and the 18 steps moved there. §5 keeps Obtaining (now §5.1) and Defeat (now §5.2); §6.3.1 keeps the breakthrough trials
- **Tamer skills:** the skill table moved here from gdd_battle (§6.4)
- **Open questions** about monsters and skills moved to gdd_monsters §8

### Changes in v0.11 (sync with gdd_battle v6.2)

- **Stats:** every stat is priced in full (value × price, base 15; TPR 3 / 5 / 7 and AP +3 / +5 / +7 per step), each frame shows its absolute point range and the budget is checked against it for all stages (§5.2). The frame is only for the roll, spending is limited by the stage ceilings only. Unplaceable roll points stay as unspent points. The stat shape can change through a Reshape ritual. AP caps: Immortal 4, Sovereign 5 (only with TPR 1, gdd_monsters §2.3)
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
