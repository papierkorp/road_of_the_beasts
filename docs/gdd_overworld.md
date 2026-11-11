# GDD — OVERWORLD & META
*Working Draft · companion specifications: [Battle System](gdd_battle.md) (battle rules), [Monsters](gdd_monsters.md) (monster identity, stats, Kins, roster), [Skills](gdd_skills.md) (monster skills)*

---

## 1. Overview

- **Confirmed:** no fixed monster aspects, aspect triangle, replacement elements or Attunement. Free-form themes and concrete effects imply no affinity, matchup or learning restriction; species define learnlists. This supersedes older aspect-based proposals and prototype descriptions.

- **Authority:** [Skills scope](gdd_skills.md#scope-and-status) owns all monster-skill rules, data, construction/AP prices, development and content.
- This document owns meta integration, progression economy, ritual logistics, still-open day-AP costs and independent tamer-skill/loadout systems; [Battle](gdd_battle.md) owns runtime execution/resolution. Historical prototype notes override neither.

A wuxia **management + cultivation layer** around [deterministic grid battles](gdd_battle.md) and [monster collection](gdd_monsters.md): a disrespected clan beast tamer builds a city business empire and cultivates toward immortality.

### 1.1 Setting & Player Fantasy

- **Beast tamer:** monsters inhabit a spatial space inside the player's body; higher cultivation = larger space = more monsters.
- **City:** five powers (§3.2)—**3 cultivation families**, **City Lord** with City Guard, **Merchants' Guild**. The player belongs to a family but is **poorly regarded**; they cannot leave the city at launch; travel arrays teleport to dungeon regions.
- **The disrespected genius:** tactics win fights you're "supposed" to lose; commerce builds a faction the clan can't ignore.

### 1.2 Design Pillars

1. **Progression is horizontal, not vertical** — stage-ups unlock new *kinds* of play; numbers stay small and hard-capped
2. **Money buys speed and breadth, never exclusive power** — the best things are earned through battles, favor, and story
3. **Decisions are free, execution costs** — AP is spent on doing, never on looking, walking, or thinking
4. **One design language** — battle turns, city days, and building layouts all reward planning under visible constraints
5. **Everything feeds power or story** — any management feature that outputs neither gets cut
6. **Archetypes over uniques** — businesses, materials, structures, items: build the schema once, ship content as configurations
7. **Choices, not damage** — monsters start with their stat shape's stats; players allocate every level-up's points within its frame and stage ceilings ([Monsters §2.2](gdd_monsters.md#22-frame-budget-level-ups)). Skills, twists and gear add *options*; nothing outside battle ever raises Surge, Strike or ground damage.

---

## 2. Game Loops

Five loops, shortest to longest: battles yield loot/monsters → business yields money/favor → cultivation → harder battles and bigger business.

|      Loop       |        Time scale        |              Output              |
|-----------------|--------------------------|----------------------------------|
| **Battle**      | minutes (one fight)      | XP, loot, catches                |
| **Expedition**  | one dungeon run          | materials, monsters, HP lost     |
| **Day**         | one turn of the game     | everything resolved at night     |
| **Cultivation** | many days (a story arc)  | new stages, stat points, unlocks |
| **Economy**     | whole game, runs in parallel | money, favor, goods          |

Loop summaries show flow and interfaces; [§2.6 Action Catalog](#26-action-catalog) alone owns action costs.

### 2.1 Battle Loop

The overworld prepares a closed, deterministic fight and reads its result; runtime: [Battle §2.1](gdd_battle.md#21-core-battle-loop).

1. Encounter sets mode, board and enemy team.
2. Player picks team and **battle loadout** under the preparation/visibility rules in [§7.9](#79-inventory-and-loadout).
3. Monsters and loadout resolve into finished **unit sheets**; fight starts.
4. Rounds and battle end follow [Battle §2.1](gdd_battle.md#21-core-battle-loop).
5. Battle returns facts through [§8's request/result contract](#8-technical-notes-overworld--development-phases); overworld awards XP, loot and catches. The consequences of a Draw remain open (T23).

| Interface | Responsible specification |
|-----------|---------------------------|
| Monster actions | [gdd_skills.md](gdd_skills.md): kit, profiles, costs and development |
| Tamer skills | [§6.4](#64-tamer-skills): authored effects and usage |
| Medicines / arrays *(planned)* | [§6.6](#66-pills--medicines), [§6.8](#68-arrays-artifacts-for-places) and [§7.9](#79-inventory-and-loadout): items and pre-battle selection |

- Battle reads only finished unit sheets/loadouts, never level-based bonuses, and returns **facts, not rewards**; the overworld values them. Preparation/visibility: [§7.9](#79-inventory-and-loadout); action costs: [§2.6](#26-action-catalog).

### 2.2 Expedition Loop

A dungeon run turns AP and HP into materials and monsters.

1. Pick a dungeon at the Teleport Array and pay the AP
2. Walk the room, read the wild monsters
3. Engage: pre-battle, then the Battle Loop
4. Collect loot, heal, pick the next door
5. Repeat until you teleport out or the team is beaten
6. Back in the city, the day goes on (injured monsters need rest, §5.2)

| Interface | Responsible specification |
|-----------|---------------------------|
| Entry, deeper-floor entry, exploration and retreat | [§2.6](#26-action-catalog): action costs; retreat ends the run and keeps the loot |
| Healing supplies | [§6.6](#66-pills--medicines): pill effects; the scope of the run-healing restriction remains unresolved (T22) |
| Defeat and catches | [§5.2](#52-defeat-and-injury) and [§5.1](#51-obtaining-monsters) |

- **HP persists** through the run; battles always start at current HP, never above max, making pills logistics. Defeat: [§5.2](#52-defeat-and-injury).
- Dungeon visibility, encounter triggers and node-owned mode/count: [§3.3](#33-dungeons). Post-win binding: [§5.1](#51-obtaining-monsters).

### 2.3 Day Loop

A day is one turn: spend AP in the city, the night resolves everything at once.

1. Day starts with the stage's day-AP allowance ([§2.6 proposal](#26-action-catalog))
2. Spend day AP on actions from the catalog, in any order
3. End the day by hand or when AP run out
4. **Night:** businesses produce, staff report, plants grow a tick, eggs and breeding progress, monsters gain idle XP, injured monsters rest a night, market prices shift
5. Morning results screen → new day

| Day activity | Responsible specification |
|--------------|---------------------------|
| Expeditions | [§2.2](#22-expedition-loop) |
| Cultivation, training and rituals | [§2.4](#24-cultivation-loop), [§6.3](#63-stage-unlock-table) |
| Work, Deal, construction and story events | [§2.6](#26-action-catalog): costs and prerequisites |
| Planning and management | [§2.6](#26-action-catalog): free planning versus paid execution |

- **Decisions are free, execution costs:** [§2.6](#26-action-catalog) distinguishes planning, queued work and execution; never punish looking around.
- **No time pressure:** quests expire in days, never force specific actions; thinking time is unrestricted. No visual clock: day = bright city, night = results screen.
- Night synchronizes all systems once: save-friendly, no real-time simulation.

### 2.4 Cultivation Loop

XP turns into sub-tiers, sub-tiers into stat points, breakthroughs into new mechanics.

1. Battles, pills and cultivation actions fill the XP bars (player and each monster)
2. Full bar = sub-tier up (Lower → Middle → High); a monster gets **stat points** to spend ([Monsters §2.2](gdd_monsters.md#22-frame-budget-level-ups))
3. At High, a breakthrough trial / ritual leads to the next stage
4. The stage-up unlocks mechanics (bigger teams, slot development, air layer, tamer slots), expands the Internal World, raises the stat ceilings, opens deeper dungeons

| Progression interface | Responsible specification |
|-----------------------|---------------------------|
| XP, stat points and slot-development steps | [Monsters §2.2](gdd_monsters.md#22-frame-budget-level-ups) and [§5.3](gdd_monsters.md#53-monster-progression-the-18-steps) |
| Pills and idle cultivation | [§6.6](#66-pills--medicines) and [§4.3](#43-what-lives-in-the-spatial-space) |
| Slot development and skill replacement | [§6.3.2](#632-permanent-skill-slot-development-confirmed): meta integration |
| Breakthrough trials | [§6.3.1](#631-breakthrough-trials) |
| Cultivate, Train and ritual costs | [§2.6](#26-action-catalog) |

- **Ceiling:** monsters cannot exceed the player's stage ([Monsters §2.2](gdd_monsters.md#22-frame-budget-level-ups)). Level-ups change stats/choices, never damage (§6.9); each breakthrough rewards a new mechanic (§6.3).

### 2.5 Economy Loop

Business turns what dungeons bring into money, and money into speed and breadth.

1. Run **Acquire → Process → Sell** through [§7.1's shared business verbs](#71-businesses).
2. **Reinvest:** cultivation resources, rituals, artifacts, staff → deeper dungeons → better materials → bigger business

| Economy interface | Responsible specification |
|-------------------|---------------------------|
| Trade, recruitment, Work, queueing and construction | [§2.6](#26-action-catalog): action costs and timing |
| Facilities and staff automation | [§7.1](#71-businesses) |
| Recipes and item inputs | [§7.5](#75-materials-seeds-and-grades) |
| Favor and access | [§7.2](#72-favor--faction) |

- **Business is the engine, battles the gate:** deeper floors require battle skill; better business requires deeper floors. Neither works alone.
- Automation progression: [§7.1](#71-businesses); money's limits: [§7.7](#77-economy-design-rule).

### 2.6 Action Catalog

- **Authority:** sole overworld action-cost catalog; monster battle-AP prices and tamer usage remain in linked source sections, not loop summaries. Unqualified AP here means **day AP**, never battle AP.
- **Working design, not newly confirmed:** day-AP curve proposed, prototype ritual quantities labeled, unresolved entries still open; final validation [T31](temp_todo.md).
- **Day AP proposal:** Qi Gathering 3 · Foundation 4 · Core Formation 4 · Soul Tier 5 · Immortal 5 · Sovereign 6. Slow growth is deliberate: staff take over Process/Sell at night (§7.1), freeing AP for dungeons, story and cultivation rather than chores.

|              Action              |   Loop   |            Cost            |                       Needs                       |                    Notes                     |
|----------------------------------|----------|----------------------------|---------------------------------------------------|----------------------------------------------|
| Monster action / skill | Battle | authored battle AP: [Skills §5](gdd_skills.md#5-construction-points-and-ap-efficiency) | in a fight | runtime: [Battle §2.3](gdd_battle.md#23-action-points); no generic Unique price |
| Tamer skill                     | Battle | usage: [§6.4](#64-tamer-skills) | slotted before battle | independent tamer source / loadout |
| Use a medicine / array           | Battle   | 1 medicine / 1 array from the loadout; battle-AP cost unresolved (T19) | human tamer | planned; consumption: [§6.6](#66-pills--medicines) / [§6.8](#68-arrays-artifacts-for-places) (T18) |
| Bind a defeated wild monster     | Battle   | free + 1 Binding Seal      | win; seal tier and grade high enough (§5.1)       | in the result screen                         |
| Start an expedition              | Expedition | 1 AP (2 AP deeper floor) | Teleport Array                                    | includes all its battles                     |
| Walk, inspect, teleport out      | Expedition | free                     | —                                                 | teleport out keeps the loot                  |
| Heal in a run                    | Expedition | 1 healing pill           | pill                                              | between battles; restriction scope unresolved, see §6.6 (T22) |
| Cultivate                        | Cultivation | 1 AP                    | —                                                 | player XP                                    |
| Train a monster                  | Cultivation | 1 AP                    | —                                                 | focused XP                                   |
| Win a battle                     | Cultivation | free (reward resolution) | won battle | XP for the team; expedition / Arena entry has its own cost |
| Study a scroll                   | Cultivation | 1 AP                    | Scroll (§7.6)                                     | learns a tamer skill / recipe / blueprint    |
| Take a pill (other than a relearning pill) | Cultivation | free + 1 pill        | pill                                              | XP, healing, cure; skill change has its own row |
| Assign a monster to a spot       | Cultivation | free                    | spot in the Internal World                        | idle XP every night                          |
| Spend stat points                | Cultivation | free                    | unspent points                                    | inside the stage ceilings ([Monsters §2.2](gdd_monsters.md#22-frame-budget-level-ups))             |
| Change a monster skill | Cultivation | relearning pill; day AP open | [Skills §6 eligibility](gdd_skills.md#6-slot-levels-development-replacement-and-upgrades) | management integration: [§6.3.2](#632-permanent-skill-slot-development-confirmed) |
| Develop a skill slot | Cultivation | advancement grant, not purchased ([Skills §6](gdd_skills.md#6-slot-levels-development-replacement-and-upgrades)); day AP open | breakthrough or listed advancement | choice location: [§6.3.2](#632-permanent-skill-slot-development-confirmed) |
| Breakthrough                     | Cultivation | 1 AP + trial + materials | High sub-tier, Trial Pillar                      | prototype: 5 (player) / 3 (monster) materials |
| Rarity ascension                 | Cultivation | 1 AP + rare materials   | Bloodline pill; ritual site open (temp_todo T30; [Monsters §5.2](gdd_monsters.md#52-rarity-ascension))               | major event                                  |
| Reshape (change stat shape)      | Cultivation | 1 AP + Reshape Elixir   | Trial Pillar                                      | rare item ([Monsters §2.2](gdd_monsters.md#22-frame-budget-level-ups))                             |
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
| Story / social event             | Day      | 1 AP                       | key NPC, clan meeting                             | investigations are social events; deferred staff-story details: T26 |
| Shop sales                       | Economy  | free                       | shop | resolve at night |
| End the day                      | Day      | free                       | —                                                 | the night resolves everything                |

- **Free planning:** walking, dialogue, browsing, ordering, assigning staff or monsters, queueing production, rearranging the Internal World, team selection, inspecting sheets, spending stat points and equipping artifacts.
- **Execution:** normally 1 day AP as listed. Recruitment also uses favor (§7.2); single-Deal scope remains T28.
- **Skill replacement and slot development:** neither action inherits default 1-day-AP execution or prototype ritual prices; their day-AP costs stay open ([T05/T16/T31](temp_todo.md)). Replacement/grant rules: [Skills §6](gdd_skills.md#6-slot-levels-development-replacement-and-upgrades); meta integration: [§6.3.2](#632-permanent-skill-slot-development-confirmed).

---

## 3. Overworld

The outside world: the city and the dungeons behind its teleport arrays. Economy and story live here.

### 3.1 The City

- **Cannot leave the city at launch:** travel arrays/long-range teleports lead to self-contained dungeon regions (deserts, mountains, forests).
- **District-based, not open world:** small handcrafted 3D scenes share battles' iso camera/art pipeline. The active monster follows freely—e.g. a Magma Drake in the market conveys status.
- **All selling, quests and social contact happen here**; the Internal World cannot reach outside (§4).

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

\* proposed operators (T15). This is a district overview; [§3.1.9](#319-building-index) owns building functions, operators and access. Historical implementation reports are separated in [§8](#8-technical-notes-overworld--development-phases).

#### 3.1.1 Clan Compound

- Home base; the clan looks down on the player. Buildings: see the [index](#319-building-index).

#### 3.1.2 Rival Compounds

- Initially closed; entry is a story/favor beat. Building: see the [index](#319-building-index).

#### 3.1.3 City Lord's Keep

- City law/order. Buildings: see the [index](#319-building-index).

#### 3.1.4 Market District

- Goods exchange. Buildings: see the [index](#319-building-index).

#### 3.1.5 Business District

The player's properties house commerce and city workshops. Property access is listed in the [building index](#319-building-index); business functions and facility placement are defined in [§7.1](#71-businesses).

#### 3.1.6 Arena

- Public fights. Buildings: see the [index](#319-building-index).

#### 3.1.7 Teleport Plaza

- Hub connecting every district. Buildings: see the [index](#319-building-index).

#### 3.1.8 Slums

- Outside city order: no faction or earnable favor for now. Optional Black Stall remains unconfirmed ([T15](temp_todo.md)); see [index](#319-building-index).

#### 3.1.9 Building Index

- This index owns city building functions/operators/access; district descriptions give setting, [§7.1](#71-businesses) business configurations. **Operator** = faction behind the counter (§3.2); * marks unconfirmed proposals (T15).

| District | Building | Function | Operator | Access |
|----------|----------|----------|----------|--------|
| Clan Compound | Clan Hall | clan meetings, summons, Family favor | player's family | start |
| Clan Compound | Notice Board | requests and quests | player's family | start |
| Clan Compound | Clan Envoy | Family favor actions | player's family | start |
| Rival Compounds | Family Hall | favor actions and quests of that family | rival family | invitation / favor |
| City Lord's Keep | Audience Hall | City Lord favor, Street Trade Permit | City Lord | favor (inner hall) |
| City Lord's Keep | Guard Barracks | beasts for hire | City Guard | outer court |
| Market District | Trader | buy / sell, drifting prices | Merchants' Guild | start |
| Market District | Guild Factor | Guild favor, discounts, Production License | Merchants' Guild | start |
| Market District | Guild Hall | rare blueprints, contracts | Merchants' Guild | favor |
| Market District | Auction Hall | consign, bid, rare invites; monsters and eggs for sale | Merchants' Guild | start, invites |
| Business District | Properties | the player's shops, stalls, workshops (§7.1) | Guild * (owners) | license + negotiation |
| Arena | Arena Ring | tournaments, 5v5 special battles, favor from wins | City Lord * | start |
| Arena | Ranking Board | opponents and rewards | City Lord * | start |
| Teleport Plaza | Teleport Array | expeditions to dungeon regions | City Lord * | start |
| Teleport Plaza | Meditation Pavilion | entry to the Internal World | the player | start |
| Keep / Teleport Plaza | Watch Post | City Guard requests | City Guard | start at Plaza; Keep access unspecified (T15) |
| Slums | Black Stall *(optional idea, T15)* | odd goods | none | start (proposal) |

- Business District = **owned-property list**; acquisition requires owner negotiation and Guild license (Deal costs: [§2.6](#26-action-catalog)).
- **No city adjacency bonuses**; Internal World only (§4.3). Detailed faction offers and unresolved operators/access remain [T15](temp_todo.md).

### 3.2 The Powers of the City

Five powers hold the city. Each one is a favor faction (§7.2):

|           Power            |                       Role                       |                                 Offers                                 |
|----------------------------|--------------------------------------------------|------------------------------------------------------------------------|
| **The player's family**    | great clan that looks down on the player         | respect for power, bloodlines                                          |
| **Two rival families**     | cultivation families competing with the player's | not specified                                                          |
| **City Lord & City Guard** | law, peace and order in the city                 | Street Trade Permit, beasts for hire                                   |
| **Merchants' Guild**       | runs trade, the market and the **auction hall**  | Trader discounts, rare blueprints, Production License, auction invites |

### 3.3 Dungeons

- **Nodes:** rooms linked by doors; wild monsters roam visibly (no random encounters), touch triggers battle. No **ambush bonus**, including attacks from behind. Flow: [§2.2](#22-expedition-loop); costs: [§2.6](#26-action-catalog).
- **Individuals:** use the [monster individual model](gdd_monsters.md#11-species-and-individual); the [information/preview contract](#79-inventory-and-loadout) enables informed picks/counter-picks.
- Node fixes **mode** (1v1 / 2v2 / 3v3 / 5v5) and wild-monster count; board generation follows [Battle §4.1](gdd_battle.md#41-battlefield-generation).

---

## 4. Internal World

The cultivator's monster habitat: a physical pause menu serving **the tamer's own power** through training, medicine growing, goods production and team preparation.

- **No outside communication:** no shops, selling, quest/faction buildings or other people-dependent functions. The player carries goods out; **no staff inside** for now—only personal work and standing orders.

### 4.1 Functions

- **Living collection:** monsters roam freely; cultivation expands buildable area each stage. Grid/terrain progression: [§4.4](#44-capacity-and-growth).
- **Roster/draft:** choose owned monsters for the encounter's mode here; capacity and bench: [§4.4](#44-capacity-and-growth).
- **Passive production:** cultivation spots and growing structures follow [§4.3](#43-what-lives-in-the-spatial-space); seed-to-herb production: [§7.5](#75-materials-seeds-and-grades).
- **Management:** planning, inspection, equipping and progression execution follow [§2.6](#26-action-catalog); open slot-development/replacement logistics: [§6.3.2](#632-permanent-skill-slot-development-confirmed).

### 4.2 Building System

Everything placeable in the Internal World is a **Structure**; blueprints are one acquisition path among several.

```
STRUCTURE
  name, size (grid footprint), category
  source     : blueprint (craft w/ materials) | buy | quest/story reward
  level      : upgradeable with materials
  placed_on  : internal world grid cell
```

- **Coarse grid placement:** moving structures follows [§2.6](#26-action-catalog); structures are never lost. Adjacency/layout rules: [§4.3](#43-what-lives-in-the-spatial-space).
- [§4.3](#43-what-lives-in-the-spatial-space) alone catalogs functions, footprints, placement, unlock proposals and adjacency effects. Production (furnace/workshop/forge) is a shared facility role, not another structure list; placement of production versus commerce facilities: [§7.1](#71-businesses).

### 4.3 What Lives in the Spatial Space

- **Authority:** table owns structure functions/footprints/placement/unlocks; linked specialist sections own ritual/item/monster rules. **Footprint** = grid cells (stationary 2×2 monster = 4); **Placement** = grid binding.
- **Unvalidated first proposal (T25):** footprints, unlock stages and places marked *new*.

| Category |         Thing         | Footprint |       Placement        |                       Function / place for                        |  Unlock  |
|----------|-----------------------|-----------|------------------------|-------------------------------------------------------------------|----------|
| Monster  | Housed monster        | free      | roams the whole grid   | counts against capacity (§4.4)                                    | Qi       |
| Monster  | Assigned monster      | on a spot | stands on its spot     | idle XP at night, or breeding / incubating / resting              | Qi       |
| Monster  | Egg *(new)*           | 1         | inside an Incubator    | hatches after N nights into an individual (§5.1)                  | Foundation |
| Cultivation | Meditation Stone   | 1×1       | any cell               | place for **cultivating**: idle XP                                | Qi       |
| Cultivation | Qi Spring          | 2×2       | any cell               | stronger idle XP, counts as water                                 | Qi       |
| Cultivation | Rarity ascension site *(open)* | open | open | ritual site design pending (temp_todo T30) | open |
| Cultivation | Evolution Pillar   | 1×1       | any cell               | place for **slot development** (§6.3.2; role open, T05/T25) | Foundation |
| Cultivation | Trial Pillar       | 1×1       | any cell               | place for **breakthrough** trials and **reshaping**               | Foundation |
| Cultivation | Study Desk *(new)* | 1×1       | any cell               | place for **studying scrolls** (tamer skills, recipes)            | Foundation |
| Growing  | Herb Plot             | 2×2       | any cell               | place for **planting** seeds                                      | Qi       |
| Growing  | Spirit Tree           | 3×3       | any cell               | slow, high-tier herbs (Epic grade)                                | Core     |
| Housing  | Nest / Cave / Shrine Grove | 2×2 / 2×2 / 3×3 | any cell    | +capacity; kin-matched = mood / loyalty bonus (T25)                | Foundation |
| Breeding | Breeding Den *(new)*  | 2×2       | any cell               | place for **breeding** a male and a female (§5.1)                 | Core     |
| Breeding | Incubator *(new)*     | 1×1       | any cell               | place for **hatching** eggs                                       | Foundation |
| Breeding | Hive Nest *(new)*     | 2×2       | any cell               | Swarm species multiply here without a pair (§5.1)                 | Core     |
| Recovery | Recovery Spring *(new)* | 2×2     | any cell               | place for **resting** injured monsters; recovery effect: [§5.2](#52-defeat-and-injury) | Foundation |
| Crafting | Refining Furnace      | 2×2       | any cell               | place for **crafting** pills and medicines                        | Qi       |
| Crafting | Array Workshop        | 2×2       | any cell               | place for **crafting** arrays and Binding Seals                   | Foundation |
| Crafting | Artifact Forge        | 2×2       | any cell               | place for **smithing** artifacts and tamer gear                   | Core     |
| Special  | Spirit Pond           | 2×2       | any cell               | water for adjacency                                               | Qi       |
| Storage  | Storehouse *(new)*    | 1×1       | any cell               | storage; inventory ownership: [§7.9](#79-inventory-and-loadout) | Qi |

- **Adjacency (Internal World only; unvalidated, T25):** orthogonal contact, small bonus once per pair. Minimum times/stacking unresolved; recovery adjacency must be reconciled with §5.2 (T23/T25).

|     Structure A      |        Next to        |                  Bonus                  |
|----------------------|-----------------------|-----------------------------------------|
| Herb Plot            | Spirit Pond / Qi Spring | −1 grow night                         |
| Spirit Tree          | Spirit Pond           | −1 grow night                           |
| Nest / Cave / Grove  | monster of the matching Kin | mood / loyalty bonus              |
| Recovery Spring      | Spirit Pond           | injured monsters rest one night less    |
| Breeding Den         | Nest / Cave / Grove   | the egg is ready one night earlier      |
| Incubator            | Qi Spring             | hatches one night earlier               |

- Aspect-matched altar XP/furnace AP bonuses are removed; no ritual site implies aspect affinity. Reviews: structure/layout [T25](temp_todo.md), ritual sites T30, recipes T16.

### 4.4 Capacity and Growth

- Growth: **grid per stage**, **monster capacity per sub-tier** (stage/sub-tier progression: [Monsters §5.3](gdd_monsters.md#53-monster-progression-the-18-steps)). Bench = capacity − mode's team size; at Core+ it exceeds team size, enabling counter-picks.

**Proposal:**

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

[gdd_monsters.md](gdd_monsters.md) owns individuals, stats, Kins, roster and rarity; [gdd_skills.md](gdd_skills.md) owns skills and slot development ([Skills §6](gdd_skills.md#6-slot-levels-development-replacement-and-upgrades)); this chapter owns acquisition/defeat. Battle sees only the finished unit sheet (§2.1).

### 5.1 Obtaining Monsters

- Every acquisition yields an **individual** (shape rolled by species' Kin lean, [Monsters §1.1](gdd_monsters.md#11-species-and-individual); rarity; stage). Rolls occur at individual creation, never in battle.

|        Way        |                                          How                                          |                         Notes                          |
|-------------------|---------------------------------------------------------------------------------------|--------------------------------------------------------|
| **Bind (Seal)**   | after a win the player binds **one** defeated wild monster with a **Binding Seal** (result-screen action; cost in §2.6) | the default way (decided); no dice (below)  |
| **Auction**       | buy monsters and eggs at the Guild's Auction Hall (Deal)                              | sheet visible before the bid; Monster hall can resell  |
| **Breeding** | contract below | Breeding Den |
| **Eggs**          | found in dungeons, bought, quest rewards; hatched in an **Incubator**                  | an egg fixes species and rarity; the hatching rolls shape |
| **Hive (Swarm)**  | Swarm species multiply in a **Hive Nest** without a pair; one larva per N nights       | the insect way: no sex                                |
| **Quest / clan**  | story monsters, gifts from the clan leader, favor rewards                              | usually fixed individuals, often high rarity           |
| **Hire**          | Guard Barracks lend beasts for a while                                                 | not owned, no stat growth                              |

- **Breeding:** a male and a female of the same species in a **Breeding Den**: an egg after N nights (N by rarity); only species with `breeds: true`.
  - Offspring: species of one parent, shape rolled by the Kin lean, rarity = the lower parent's, stage Qi Gathering Lower.
- **Binding Seal** (`kind: Seal`): tier = stage, grade = rarity ([§7.6](#76-item-schema)); target stage ≤ seal tier, rarity ≤ seal grade.
  - **Player-stage ceiling** also applies ([Monsters §2.2](gdd_monsters.md#22-frame-budget-level-ups)); stronger monsters stay wild until the next breakthrough.
- Player chooses the defeated **0-HP** monster; only the seal is needed. Without one, it is released. Normal seals are cheap; higher grades come from dungeons, Guild or Array Workshop crafting.
- Proposed tamer improvements belong to [§6.4](#64-tamer-skills), not the base seal (T20/T24). Auctions/breeding/eggs are long-term acquisition; seals underpin dungeon catching. Catching and Monster hall commerce remain separate loops (§7.1).

### 5.2 Defeat and Injury

- **Injured, not dead:** battle result marks fallen monsters; unavailable for the remaining expedition and **2 nights** of Internal World rest.
  - **Recovery Spring** halves recovery (round up); **Revival pill** ends it immediately.
  - Never lose sub-tier, stat points or slot development; **Arena never injures**.
- **Deadly dungeons:** optional, marked at Teleport Array, better loot; defeat means **permanent loss** unless protected by **Soul Tether** (one monster) or the proposed own-monster fall-prevention tamer skill ([§6.4](#64-tamer-skills); interaction unresolved T20/T23). Death stays meaningful without risking a favorite every run.

---

## 6. Progression

### 6.1 Cultivation Structure (shared naming, player & monsters)

**Monsters use exactly the same stage and sub-tier names as the player**: [Monsters §5.3](gdd_monsters.md#53-monster-progression-the-18-steps) owns the six-stage/three-sub-tier structure and progression table. Breakthrough integration: [§6.3.1](#631-breakthrough-trials).

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

- **Authority:** [Skills §1](gdd_skills.md#1-the-kit) owns starting kit/legal access; [Monsters §5.1](gdd_monsters.md#51-monster-rarity)/[§5.3](gdd_monsters.md#53-monster-progression-the-18-steps) own rarity slots and development steps. Monster entries below are owner links; player entries cover stage integration. Progression adds *choices/modes*, not basic verbs—battles must never lack options.

| Stage | Monster unlock owner | Player unlock |
|-------|----------------------|---------------|
| Qi Gathering | [Kit](gdd_skills.md#1-the-kit), [stage stats](gdd_monsters.md#23-stat-ceilings-per-stage) | holds 1 monster · **1v1** (5×5) |
| Foundation | [Progression](gdd_monsters.md#53-monster-progression-the-18-steps) | holds 3+ monsters · **3v3** (7×7, standard) · **2v2** (6×6) · 1 tamer slot |
| Core Formation | [Progression](gdd_monsters.md#53-monster-progression-the-18-steps); artifact note below | holds 5+ monsters (bench for counter-picks) · 2nd tamer slot · **5v5** special battles |
| Soul Tier | [Body/stats](gdd_monsters.md#53-monster-progression-the-18-steps), [Winged layer](gdd_monsters.md#31-kin-table), [foreign movement](gdd_skills.md#82-movement-by-kin) | mid-battle **Beast Swap** access ([§6.4](#64-tamer-skills)) |
| Immortal | Dual-aspect unlock removed; no replacement mechanic confirmed (T34 completed) | 3rd tamer slot |
| Sovereign | [Signature / Major Surge access](gdd_skills.md#1-the-kit), [progression](gdd_monsters.md#53-monster-progression-the-18-steps); access note below | full spatial arsenal |

- **Retained table statements (unresolved):** Core Formation monster unlock: “2nd artifact slot at Epic+”; slot-access conflict: [§6.7](#67-artifacts-equipment--socketed-passives) (T17). Ancient-only vs Legendary wording remains open (T02/T32).

- Bigger teams, air layer, 2x2 and swap **are the rewards**: one mechanic per breakthrough also provides a natural tutorial.
- **Encounter sets mode**, within fieldable team size: narrow corridor 1v1/2v2, dungeon hall 3v3, tournament 5v5; player needs at least that many monsters.

#### 6.3.1 Breakthrough Trials

- **Unvalidated proposal (T30):** trial advances High → next stage's Lower; requires monster at High, Internal World **Trial Pillar**, **next-tier** materials and table requirements below. Budgets/gains/XP: [Monsters §5.3](gdd_monsters.md#53-monster-progression-the-18-steps); costs/prototype quantities: [§2.6](#26-action-catalog) only.

|        Breakthrough        |                               Trial                               |
|----------------------------|-------------------------------------------------------------------|
| Qi Gathering → Foundation  | **Gathering trial:** materials only, no battle                    |
| Foundation → Core | **Pillar battle:** a 1v1 / 3v3 against a guardian team of the new stage |
| Core → Soul | **Trial floor:** a dungeon floor with a boss and the new stage's materials |
| Soul → Immortal            | **Tribulation:** a 5v5 against a mirrored team of your own stage, Upper stones are consumed (money-as-cultivation, §7.3) |
| Immortal → Sovereign       | **Story:** the clan arc and a mirror duel, no grinding              |

- **Pillar battle:** a *Breakthrough pill* removes the penalty (the player starts at half HP).
- **Trial floor:** the monster (or player) must be in the winning team.
- In this proposal, monster breakthrough requires materials and, from Core on, a won trial battle with that monster in the team. Slot development is separate ([§6.3.2](#632-permanent-skill-slot-development-confirmed)).
- **Conflicts (T25/T30):** player-HP/player-in-team wording contradicts the non-combatant tamer; Trial Pillar's Foundation unlock (§4.3) blocks the first breakthrough. Neither is resolved by treating the player as a monster. Upper-stone consumption stays optional (§7.3), not confirmed by the trial row (T16/T30).

#### 6.3.2 Permanent Skill-Slot Development (confirmed)

- **Rule owner:** [Skills §6](gdd_skills.md#6-slot-levels-development-replacement-and-upgrades) alone defines development, replacement, retained progress/upgrade reselection and budget/battle-AP policy. Construction points are internal authoring data, not [§7.6 Blueprint items](#76-item-schema).
- **Meta integration:** monster management applies the source's replacement eligibility; development-choice location (Trial Pillar at the breakthrough versus Evolution Pillar) is open.
  - Costs: [§2.6](#26-action-catalog); pill role: [§6.6](#66-pills--medicines); persistence: [§8](#8-technical-notes-overworld--development-phases). None redefines the skill rules.
- **Open:** day-AP costs of both actions: §2.6 (T05/T16/T31); step supply, slot unlocks and respec/replacement: T05 under Skills §6. [Monsters §5.1](gdd_monsters.md#51-monster-rarity)/[§5.3](gdd_monsters.md#53-monster-progression-the-18-steps) step tables do not validate the supply.

### 6.4 Tamer Skills

Tamer skills are **learned over the game**, then **slotted before each battle**. **Status:** activation window, Swap Places, Urgent Order, Second Wind, Life Thread, Beast Swap confirmed 2026-11-11, values draft. *Proposal* rows (Double Bind, Seal Mastery) wait for the catching rules (T24).

- **Authority:** this section owns source-specific tamer definitions, permissions, unlocks and usage; the table is an index, not a second effect definition. General activation window: [Battle §5.2](gdd_battle.md#52-tamer-skills-and-battle-loadout).
- **Shared contracts, separate source:** use [Skills §4 effects](gdd_skills.md#4-effect-and-board-operation-contracts), [§2 data model](gdd_skills.md#2-data-oriented-skill-construction-kit) and [§7 validation](gdd_skills.md#7-validation-and-concrete-skill-records).
- **No permission transfer:** monster-profile permissions, species/Kin access, slot development and monster-action AP prices do not transfer to tamers. Own-monster repositioning, zone clearing/ground reset and proposed direct healing do not authorize monster equivalents.
  - Monster Surge-damage Nullify requires its separately authored, much higher-priced effect ([Skills §4](gdd_skills.md#4-effect-and-board-operation-contracts)); generic Nullify/Survive resolution: [Battle §6.1](gdd_battle.md#61-the-damage-law).
- Source completion/validation: [T19/T20](temp_todo.md); unspecified details have no implicit defaults.

| Skill | Stage | Kind | Definition |
|-------|-------|------|------------|
| Spatial Pull | Foundation | position | [Source](#spatial-pull) |
| Qi Suppression | Foundation | tempo | [Source](#qi-suppression) |
| Spirit Shield | Foundation | defense | [Source](#spirit-shield) |
| Swap Places | Foundation | position | [Source](#swap-places) |
| Domain Glimpse | Core | terrain | [Source](#domain-glimpse) |
| Urgent Order | Core | tempo | [Source](#urgent-order) |
| Second Wind | Core | defense | [Source](#second-wind) |
| Life Thread | Core | defense | [Source](#life-thread) |
| Double Bind *(proposal)* | Core | catching | [Source](#double-bind) |
| Beast Swap | Soul | position | [Source](#beast-swap) |
| Seal Mastery *(proposal)* | Soul | catching | [Source](#seal-mastery) |

- **Learning:** each *player* breakthrough grants one choice from that stage's list. Studying a `kind: Scroll` item ([§7.6](#76-item-schema); cost [§2.6](#26-action-catalog)) teaches one skill.
  - Acquisition: [§7.8](#78-acquisition-sources). Higher grades teach later-stage skills early—the main use of Rare scrolls.
- **Slots:** unlocks [§6.3](#63-stage-unlock-table), none at Qi Gathering; humans only, never monsters. **Beast Swap** slots only from Soul Tier. Catching skills use a slot and deliberately replace a battle skill.
- **Usage:** each slotted skill is **once per battle**, free (no Battle-AP), never consumed. Pre-battle selection/visibility: [§7.9](#79-inventory-and-loadout).
- Sub-tier **never** changes strength. Artifact modifications ([§6.7](#67-artifacts-equipment--socketed-passives), subject to [§6.9](#69-hard-caps)) never increase uses.

#### Spatial Pull

Move an own monster to any empty square.

#### Qi Suppression

An enemy monster −2 initiative next round.

#### Spirit Shield

The next Surge damage on one own monster is 0; generic Nullify resolution: [Battle §6.1](gdd_battle.md#61-the-damage-law).

#### Swap Places

- **Swap Places:** two own 1×1 ground-layer monsters trade squares; no range or LOS. Each counts as entering its new square (ground entry effects fire, as for move/push/pull).

#### Domain Glimpse

**User decision 2026-11-11:**
- Removes zones and resets ground to Plain on the squares of its tetromino.
- The tamer picks any of the 7 tetrominoes in any rotation or reflection and places it anywhere on the board (no range or LOS; all four squares must lie on the board, no trimming).
- Voidscar stays, and props, Mountains (height), Surge markers and monsters are unaffected.

#### Urgent Order

- **Urgent Order:** an own monster that has not acted this round is inserted directly after the current turn; its original entry of this round is removed (no double action). Extra-turn entries are not affected; the round-end re-sort is unchanged.

#### Second Wind

- **Second Wind:** one own monster on the field regains 1 HP (never above max); it unlocks no monster healing.

#### Life Thread

- **Life Thread:** set on one chosen own monster, effect and consumption as in [Battle §6.1](gdd_battle.md#61-the-damage-law); it also protects in Deadly dungeons (death/injury details T23).

#### Double Bind

*Proposal:* after the battle one extra defeated wild monster may be bound ([§5.1](#51-obtaining-monsters)).

#### Beast Swap

Exchange an active monster with one from the spatial space.

- **Beast Swap:** the incoming monster takes the square and queue entry of the swapped-out monster (it acts this round only if that entry is still pending), arrives with its current HP and must have the same body size (1×1 for 1×1, 2×2 for 2×2). The swapped-out monster is not defeated and may be swapped back later; its pending Surges stay and detonate like orphaned Surges at the next round start ([Battle §2.2](gdd_battle.md#22-initiative-rules)). Soul Tier gate unchanged.

#### Seal Mastery

*Proposal:* Binding Seals one tier lower than the target still bind it.

### 6.5 The Balance Rule (Pills, Medicines, Artifacts, Arrays)

- **Pills:** out-of-battle progression. **Artifacts:** in-battle options, not numbers. All goods share the item schema (§7.6).
- **Loadout:** preparation/visibility: [§7.9](#79-inventory-and-loadout); usage/consumption: [§6.4](#64-tamer-skills), [§6.6](#66-pills--medicines), [§6.8](#68-arrays-artifacts-for-places). Loadout effects may change the field during battle.

### 6.6 Pills & Medicines

Pills link progression, expedition supply and Producer economy. [§7.5](#75-materials-seeds-and-grades) owns proposed effects/recipes; this table maps roles to specialist rules.

| Product family | Role / responsible rules |
|----------------|--------------------------|
| Cultivation | routine progression supply; XP curve validation T29 |
| Relearning pill | deliberate skill replacement: [§6.3.2 meta integration](#632-permanent-skill-slot-development-confirmed); economy T05/T16/T31 |
| Breakthrough | stage-up ingredient / penalty relief in the [trial proposal](#631-breakthrough-trials); exact role unresolved (T30) |
| Healing | expedition attrition supply line; catalog effect applies between battles |
| Swift / Ward (battle prep) | pre-battle preparation; effects in §7.5 |
| Bloodline | rarity-ascension sink: [Monsters §5.2](gdd_monsters.md#52-rarity-ascension) |
| Revival / Soul Tether | defeat and permanent-loss logistics: [§5.2](#52-defeat-and-injury) |
| Reshape Elixir | rare ritual input: [Monsters §2.2](gdd_monsters.md#22-frame-budget-level-ups) |
| Medicine *(planned)* | consumed in battle through the loadout; effects and item-kind treatment unresolved (T18/T19) |

- **Healing scope unresolved (T22):** legacy “pills are the only run HP restoration” conflicts with monster [combat healing](gdd_skills.md#4-effect-and-board-operation-contracts), [healing passives](gdd_skills.md#9-passives) and proposed [tamer direct healing](#64-tamer-skills). Restriction may mean between battles or entire run; neither is adopted.
- **Attrition loop:** [persistent expedition HP](#22-expedition-loop) → pill logistics → deeper floors require better supply → Producer demand.

### 6.7 Artifacts (equipment = socketed passives)

- **Equipment authority; unresolved (T17):** artifacts draw from the [Passives Library](gdd_skills.md#9-passives), resolving into finished unit sheets. Legacy **passive + tier + tiny capped stat mod** conflicts with the table's **passive OR stat mod**; no permission to combine both.
- Recipes determine forging options; inputs: [§7.5](#75-materials-seeds-and-grades).

|       Wearer       |          Slots          |                                                                    Effects                                                                     |
|--------------------|-------------------------|------------------------------------------------------------------------------------------------------------------------------------------------|
| **Monster** | 1 (2nd at Epic+ rarity) | extra passive OR stat modifier; limits: [§6.9](#69-hard-caps) |
| **Player (tamer)** | 2–3                     | tamer skill range / numeric-effect mods up to +1 (see below), +1 day AP once/day, +spatial capacity, dungeon utility |

- **Tamer skill mods:** e.g. range of the own-monster repositioning skill, enemy initiative penalty −3 instead of −2; source skills and usage restrictions: [§6.4](#64-tamer-skills), not blanket permission for other skills or effects.
- **Slot access unresolved (T17):** table requires Epic+ for second monster artifact slot; §6.3 also places it at Core. Tamer count/unlock timing undecided; neither draft supersedes the other. Stat/damage limits: [§6.9](#69-hard-caps).
- **Intent, not validated:** monster artifacts deepen battle choices; tamer artifacts aid management/expeditions. Equipment/tactics should let a Normal beast rival an Epic.

### 6.8 Arrays (artifacts for places)

- Arrays modify home-turf battlefields, Internal World structures or business protections. Pre-battle deployment proposes an exception to [Battle §4.1 mirrored generation](gdd_battle.md#41-battlefield-generation); in-battle loadout placement is planned. No attunement/aspect-based start-square effects.

**Effect catalog — unvalidated proposals (T18/T19):**

| Array | Effect |
|-------|--------|
| High Ground Array | 1 start square begins as a Mountain |
| Warding Array | the first Surge damage on the owner's side is 1 less |
| Footing Array | one start square cannot be pushed or pulled onto/off |

- **Consumption:** some arrays are consumed; consumption depends on each definition (T18). Placement/timing/consumption completion: [T18/T19](temp_todo.md).
- Recipes: [§7.5](#75-materials-seeds-and-grades); pre-battle selection: [§7.9](#79-inventory-and-loadout). No unspecified in-battle effects are granted.

### 6.9 Hard Caps

- Artifact stat mods: **+1 max, never exceeding stage ceilings** — artifacts break ties, not tiers. The monster artifact's stat-mod option affects one stat.
- Artifact slot counts and access: [§6.7](#67-artifacts-equipment--socketed-passives), including the unresolved T17 conflict
- No artifact grants an active skill at launch (Legendary signature territory)
- No gear, pill or evolution raises Surge damage, Strike damage or ground damage (damage law, [gdd_battle §6.1](gdd_battle.md#61-the-damage-law))
- Gear-effect visibility: [§7.9](#79-inventory-and-loadout)

---

## 7. Management

### 7.1 Businesses

Disrespected clan member → business → money → faction. All 5 businesses share **4 verbs**, one Facility system (staff/input/timer/output slots) and one fluctuating-price Market:

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

- **Placement:** commerce (shops, stalls, Monster hall, Dojo, Dungeon company) only on player-owned Business District properties. Production (furnace/workshop/forge) may also be in the Internal World without a property; structures: [§4.2](#42-building-system), Internal World restrictions: [§4](#4-internal-world).
- **Guild auctions** ([building index](#319-building-index), [favor/access](#72-favor--faction)): player consigns via Deal, earns rare invites through favor, does not own an auction hall.
- **Actions** (costs/timing [§2.6](#26-action-catalog)): Acquire = expedition/Deal/catch; Process = Work/queued night production; Sell = Deal/night shop sales; Staff = recruitment Deal.
- **Monster hall:** sells trained **individuals** with shape, rarity and slot development; good rolls earn more, making off-lean catching a business.
- **Progression:** personal AP work → staff automate Process/Sell at night → AP shifts to dungeons, story and cultivation. Idle night work replaces formerly paid actions.

#### 7.1.1 Staff (model B chosen)

- **Confirmed model B:** facility/Dojo staff have visible Skill, Loyalty and one trait; random hires have no hidden Deception. Departure/poaching follows visible rules, reported in the morning—not a random night event pool.

| Field | Current working definition |
|-------|----------------------------|
| Skill | job output per night |
| Loyalty | visible 0–5; wages and favor raise it, neglect and better offers lower it; at 0 the hire quits |
| Trait | one visible trait per hire; examples below remain a working trait list |

| Trait example | Behavior |
|---------------|----------|
| Greedy | paid more, loyal to the stone |
| Proud | wants a better job title |
| Devoted | cheap, stays |
| Ambitious | may receive a better-post offer from another faction; the player may counter with stones or promotion. |

- **Ambitious:** the Standing comparison condition remains unresolved (T26).

- Dojo faction hires start with their faction's loyalty bonus. Traits/wages/output/loyalty/poaching parameters remain [T26](temp_todo.md); scripted-story deception is deferred, not active.

### 7.2 Favor & Faction

Connections are **currency**, not nebulous relationships: favor should feel like a ladder, never a punitive ledger.

#### 7.2.1 The Model (working values)

Two numbers per faction (the 3 families, City Lord & City Guard, Merchants' Guild, §3.2):

```
FAVOR     points, earned and SPENT: the small change (a discount, an introduction, one request done for you)
STANDING  a rank: Stranger → Known → Trusted → Allied → Sworn
          the sum of all favor ever EARNED fills it. Never lost, never spent
```

- **Earn:** requests (Notice Board/Envoy/Watch Post), cheap sales to the faction, arena wins, auctioning wanted items, defeating rivals. **Spend:** discounts, NPC-arranged introductions, rush orders; never lowers Standing.
- **Standing access:** licenses, Production License, rare blueprints/scrolls, auction invites, breakthrough trials, faction recruits—paid once by rank, not points.
- **Visible, no decay/timers:** both numbers shown; faction board has 3–5 requests expiring in days, never forcing an action (§2.3).
- **Confirmed model, proposed numbers:** per-faction save fields `favor` (spendable), `earned_total` (lifetime, only grows), `standing` (derived from `earned_total`). Deal size determines favor earned:

|    Size    | Favor earned | Example                                                      | Request lifetime |
|------------|--------------|--------------------------------------------------------------|------------------|
| Errand     | 1            | deliver 3 herbs, sell a pill cheap                           | 3 days           |
| Task       | 3            | win a dungeon floor for them, craft a batch                  | 5 days           |
| Commission | 8            | bring a boss part, win an arena round against a rival        | 10 days          |
| Great deed | 20           | story beat, defeat their rival's champion                    | story            |

- **Request fields:** faction, **size**, **tier** (stage; show only ≤ player stage), lifetime in days, repeat limit, item/battle goal, extra reward. Favor uses one unit everywhere; only size differs.

|   Spend    | Cost  |                    Example                     |
|------------|-------|------------------------------------------------|
| Small      | 1–3   | a day of discount, an introduction             |
| Medium     | 5–10  | rush order, a scroll offer, a hint for a dungeon |
| Large      | 15–30 | a licence, recruiting one of their people, an auction invite |

- **Standing thresholds** (`earned_total`): Known 5 · Trusted 30 · Allied 100 · Sworn 250. Standing gates purchases; stage gates requests.
- **Rival families:** Allied with one caps the other at Trusted until side selection; favor never costs favor with the other, only top rank is exclusive—the system's one real dilemma. **Own-family exception:** power (stage/arena), not errands, earns respect.
- **Access/payment conflict (T27):** rank-only access above vs favor-priced licenses/recruits/invites in the spend table. Both remain conflicting drafts, not a combined two-part price. Rival-pair/request tuning: [T27](temp_todo.md); no alternative favor model is active. Guild supply contracts remain deferred, not active (T27/T28).

#### 7.2.2 The Player's Faction

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

Common item fields and grades: [§7.6](#76-item-schema); grade-based sources: [§7.8](#78-acquisition-sources).

```
MATERIAL = ITEM (§7.6) + form
FORMS    herb · ore · beast part (by Kin) · essence
```

- **Tier/grade:** Foundation pills need Foundation herbs, keeping deeper dungeons relevant. Beast parts follow **Kin** (Scaled hide/Winged feather) and monster rarity, linking collection to crafting. Identities/recipe inputs/catalog size remain open ([temp_todo.md](temp_todo.md), T16); no aspect/fixed-element multiplier.
- **Only herbs are plantable:** Normal/Rare in **Herb Plot**, Epic only in **Spirit Tree**, Legendary never (story only). Ore is found/bought, beast parts drop, essences come from bosses.
- **Seeds:** ordinary items pointing to one herb, not a separate system:

```
SEED  (item kind Seed)
  grows     : herb material id        ← one seed per herb, 1:1 (not per tier)
  grade     : inherited from the herb
  nights    : growing time (tier and grade; adjacency can cut it, §4.3)
  yield     : herbs per harvest
  plot      : Herb Plot | Spirit Tree
```

- Planting consumes the seed; harvest yields herbs plus one seed **only for Normal herbs**. Acquisition: [§7.8](#78-acquisition-sources).

**Recipes (all producers share one schema).**

```
RECIPE  station  : Refining Furnace | Array Workshop | Artifact Forge | pill / goods stall
        inputs   : [(material or filter, count)]      e.g. 3 herbs of tier T
        output   : item (kind, tier, grade)
        cost     : action-cost reference (§2.6: Queue / Work)
        source   : blueprint / Production License / starting knowledge
```

Furnace, Array Workshop and the Forge are the same code with different stations (pillar 6).

- **Pill catalog—unvalidated draft (T16/T29):** sole local effect/recipe catalog; meta role [§6.6](#66-pills--medicines). Tier T = cultivation stage.
  - Legacy “ten families / ~40 pills” conflicts with six stages/five listed XP values; neither content count nor complete tier mapping.
  - Relearning acquisition/recipe/tier/price remain T05/T16/T31 ([§6.3.2](#632-permanent-skill-slot-development-confirmed)), with no invented entry.

|        Family         |                  Effect                  |                    Recipe pattern (tier T)                    |
|-----------------------|------------------------------------------|---------------------------------------------------------------|
| Cultivation           | XP per tier: [Monsters §5.3](gdd_monsters.md#53-monster-progression-the-18-steps) | 3 herbs of tier T                                 |
| Healing               | restore 2 HP between battles             | 2 herbs of tier T                                             |
| Revival               | injury recovery: [§5.2](#52-defeat-and-injury) | 2 herbs + 1 beast part |
| Swift (battle prep)   | +1 initiative in the next battle         | 2 herbs + 1 ore                                               |
| Ward (battle prep)    | first-hit immunity in the next battle    | 2 herbs + 1 beast part                                        |
| Breakthrough | [Trial penalty relief](#631-breakthrough-trials) | 1 Rare herb of tier T+1 + 2 ore |
| Bloodline             | rarity ascension ([Monsters §5.2](gdd_monsters.md#52-rarity-ascension))                  | 1 Rare+ beast part of the Kin + 1 herb of tier T+1 + Upper stones |
| Soul Tether           | permanent-loss protection: [§5.2](#52-defeat-and-injury) | 1 Epic herb + 1 beast part |
| Reshape Elixir | [Reshape rule](gdd_monsters.md#22-frame-budget-level-ups) | 1 Epic essence + 3 herbs |
| *Medicine* *(planned)*| used in battle (planned)                 | not specified                                                          |

- Aspect-matched cultivation pill/multiplier removed; no replacement effect/recipe. New catalog design: [temp_todo.md](temp_todo.md), T16.

- **Array recipe proposal (T16/T18):** Array Workshop converts ore + beast part to arrays; tier/grade follow inputs. Item kind/effect mapping: [§7.6](#76-item-schema); effect catalog: [§6.8](#68-arrays-artifacts-for-places). Planned battle loadout uses the same item kind.
- **Smith proposal (T16):** no separate weapon/armor system. **Artifact Forge** inside, or on property run by a staff smith, converts **ore + beast parts** to artifacts; ore determines grade. Weapon/Robe/Charm slot names are flavor. [§6.7](#67-artifacts-equipment--socketed-passives) alone owns effects/slots, including T17 conflicts.

### 7.6 Item Schema

Goods are the **output tier of the material chain** — tradeable, one shared schema, no new resource category. Grades use monster rarity's four names ([Monsters §5.1](gdd_monsters.md#51-monster-rarity)); source restrictions: [§7.8](#78-acquisition-sources).

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

- **Stones buy speed/breadth, never battle-inaccessible goods:** rarity-ascension materials, trial access and unique monsters require favor/story/dungeon depth; money is only a partial input. Otherwise Trader dominates and invalidates battle play.

### 7.8 Acquisition Sources

All sources feed the [item schema](#76-item-schema), under the [economy design rule](#77-economy-design-rule).

**Grade/source rules:**
- **Normal:** buyable. **Rare:** dungeons, Guild, crafting.
- **Epic:** bosses, quests, clan leader, rare auction invites. **Legendary:** story only.

|        Source        |                          Gives                           |                    Notes                    |
|----------------------|----------------------------------------------------------|---------------------------------------------|
| **Dungeons**         | materials, seeds, eggs, scrolls, seals, blueprints, bindable monsters, boss parts | the core of the battle gate; deeper = higher tier and grade |
| **Trader**           | Normal materials, Normal seeds, Normal seals and pills   | prices drift; costs: [§2.6](#26-action-catalog) |
| **Guild Hall (trading hall)** | Rare blueprints, contracts, scrolls, Rare materials | needs Guild Standing |
| **Guild** | seeds | — |
| **Auction Hall**     | monsters, eggs, Rare+ materials, scrolls, seeds | invites by Standing; player consigns and bids with Deal |
| **Planting**         | herbs from seeds | growing rules: [§7.5](#75-materials-seeds-and-grades) |
| **Crafting**         | pills, arrays, seals, artifacts                          | Furnace, Workshop, Forge                   |
| **Breeding / hive**  | eggs, new individuals                                    | §5.1                                       |
| **Clan leader**      | Rare / Epic gifts, scrolls, eggs                         | story and Family Standing                  |
| **Quests**           | any item, often unique ones                              | Notice Board, Watch Post, story            |
| **Arena**            | favor, scrolls, seals                                    | ranking rewards                            |
| **Favor rewards** | scrolls | [§7.2](#72-favor--faction) |

- **Rarity ascension** ([Monsters §5.2](gdd_monsters.md#52-rarity-ascension)): draft new-grade material sources are dungeon bosses, quests, clan leader, auction. **Unresolved (T16/T30):** Legendary sources conflict with the story-only rule above; neither list overrides the other. Dungeon rewards remain T22.

### 7.9 Inventory and Loadout

- **Human inventory only** (player/NPC tamers); monsters own only socketed artifacts. Storehouse holds materials and goods carried in; the player's inventory stays on the tamer. Player inventory = item stacks, no weight for now; sell/use/craft/equip from it.
- **Battle loadout:** pre-fight subset (slotted tamer skills, medicines, arrays); human opponents also bring one, wild monsters never do, having no human behind them. Design: [temp_todo.md](temp_todo.md), T19.
- **Preparation/visibility:** choose team and loadout while viewing both teams' full sheets. Both sides' full sheets/loadouts are known pre-battle ([Battle pillar 6](gdd_battle.md#12-battle-design-pillars)); tamer selection is visible in the player's preview and enemy tamers' sheets. All gear effects are visible in the pre-battle preview.
- **Wild-monster information:** Kin/themes are visually telegraphed; engaging reveals the exact sheet.
- **Fixed loadout:** choose *what* before battle, *when* during it; all effects are deterministic and previewed. Team selection/inspection costs: [§2.6](#26-action-catalog).
- **Usage/consumption:** tamer skills [§6.4](#64-tamer-skills), medicines [§6.6](#66-pills--medicines), arrays [§6.8](#68-arrays-artifacts-for-places). Request/result fields: [§8](#8-technical-notes-overworld--development-phases).

---

## 8. Technical Notes (Overworld) & Development Phases

- **Shared battle/overworld 3D + fixed iso camera:** one art pipeline, character controller, camera rig, props and lighting. Connected small city-district/dungeon-node scenes, never open world; earlier map staging below is historical, not a competing layout.
- **Night synchronization:** follow the night phase in [§2.3](#23-day-loop); save persistence is specified below.

**Persistence and owner references** (data-driven approach: [Battle §7.1](gdd_battle.md#71-technical-notes-battle)):

- **Species reference:** identity/Kin/themes follow [Monsters §1.1](gdd_monsters.md#11-species-and-individual); kit/learnlist/passives follow [Skills](gdd_skills.md). Stage stats come from individuals, no longer species.
  - **Retained species-passive statement:** existing `MonsterDef` files hold a species passive. Its relation to kit/passive slots is not resolved here.
- **Individual persistence:** save record, **no battle rules**; field meanings: [Monsters §1.1](gdd_monsters.md#11-species-and-individual).
  - Identity/stats: species id, shape, stats, unspent points, rarity; progression: stage/sub-tier/XP, available development steps.
  - Skills: permanent progress per slot, equipped skill and selected skill-specific upgrades; persist progress/resolved selections per [Skills §6](gdd_skills.md#6-slot-levels-development-replacement-and-upgrades), meta integration [§6.3.2](#632-permanent-skill-slot-development-confirmed).
  - Equipment/health: artifacts ([§6.7](#67-artifacts-equipment--socketed-passives)), current HP ([§2.2](#22-expedition-loop)). Blueprint points are internal design data, not saved player currency.
- **Finished-sheet rules:** [Monsters §1.2](gdd_monsters.md#12-monster-sheet); skill definitions/authorized patches: [Skills §2](gdd_skills.md#2-data-oriented-skill-construction-kit)/[§7](gdd_skills.md#7-validation-and-concrete-skill-records), concrete records [§11](gdd_skills.md#11-concrete-skill-records). No separate overworld skill model.
- **Fixed-template data files:** loaded/validated by the monster/skill/zone registry pattern; new content = new file.
  - Slot-development paths: [Skills §6](gdd_skills.md#6-slot-levels-development-replacement-and-upgrades); stat shapes/stage ceilings: [Monsters §2](gdd_monsters.md#2-stats).
  - Items: [§7.6](#76-item-schema); structures: [§4.2](#42-building-system); businesses: [§7.1](#71-businesses); dungeons: [§3.3](#33-dungeons).
- **Battle request / result** is the single contract between the two halves:
  - Request: mode, board parameters, both teams as **finished unit sheets** under the owners above, pre-battle modifiers (pills, arrays) and the battle loadout ([§7.9](#79-inventory-and-loadout)).
  - Result: winner (or a **Draw** when the last monsters of both sides fall simultaneously, [Battle §2.1](gdd_battle.md#21-core-battle-loop)), remaining HP per monster, kills and the used-up loadout items. The result schema and the consequences of a Draw are open (T19/T23).
  - The battle core stays headless and never imports overworld code.
- Game state (day, AP, money, inventory, owned individuals, structures) lives in one save object, written at the night phase

### Historical Prototype Reports and Roadmap

- **Historical work/plans, not active specification or verified current implementation:** “done/built” covers prototype scope only, not current GDD completion/validation. Roadmap synchronization: [T35](temp_todo.md).
- Earlier low-cost v1 proposed a Slay-the-Spire-style node map: click to open scene/battle, walkable districts later.

Earlier reported builds, excluded from active design tables:
- **City locations:** Teleport Plaza, Market District and Clan Compound.
- **Buildings:** Notice Board, Clan Envoy, Trader, Guild Factor, Teleport Array, Meditation Pavilion and the Plaza Watch Post.
- **Structures:** Meditation Stone, Qi Spring, Herb Plot, Refining Furnace, Spirit Pond and Evolution Pillar.

**Earlier development phases:**

- **Phase 1:** battle system (done: 1v1 + 3v3, draft, 9 monsters) + individual monsters; node-based dungeon access; Trader business (pure buy/sell); money → power loop (money → cultivation pills → XP → stronger stats).
  - Built: individuals, BattleRequest/Result, GameState, city map of places, dungeon node map with full enemy sheets and team pick, loot, Trader with drifting prices, cultivation pills → XP → sub-tier with stat snap (stat shapes, stage caps, XP → sub-tier snap).
  - Placeholders: night heals everyone, flat rewards, prototype prices and XP curve.
- **Phase 2:** Producer business; favor system with 2-3 factions.
  - Walkable city districts: first step built (Teleport Plaza, Market, Inner World; WASD + E, iso camera, monster follows; visible dungeon — the ambush bonus is dropped from the design, still in the code); walkable Clan Compound.
  - Building system: grid, blueprints + materials, cultivation spots, herb plots, adjacency; skill evolution at the Evolution Pillar, breakthrough.
  - Producer: Refining Furnace + Pill Stall, healing and battle-prep pills.
  - Favor with the Family, the Merchants' Guild and the City Watch: requests, discounts, licenses, recruits.
- **Phase 3:** Dojo/faction staff, consigning at the Guild's auction hall, monster hall, internal world growth stages, clan storyline.

- **Historical prototype values, not current progression/economy:** skill evolution at Evolution Pillar 1 AP each; HP/Initiative 75% / 90% / 100% by sub-tier; cultivation pill +30 XP for 80 stones; dungeon win +10 XP. Reversal/breakthrough quantities remain explicitly prototype in [§2.6](#26-action-catalog), never slot-development prices.

**Historical design/code comparison (v0.10; not reverified):**
- The Pill Stall still stands in the Inner World; the Herb Plot plants materials instead of seeds.
- The factions are still Family, Guild and Watch (no rival families, no City Lord).
- Stats still snap by sub-tier (no frames, budget or stat points).
- AP is still a fixed 2; Move still costs 1 AP (no Step, no movement skills).
- Kits are still fixed to Move + Strike + Surge + utility.
- In-battle medicines and arrays don't exist yet; the Evolution Pillar has no Size path.

> If a management feature doesn't eventually output battle power or story access — cut it.

---

## 9. Design Tracking

- Open decisions/dependencies/validation: [temp_todo.md](temp_todo.md). Local labels distinguish confirmed rules, drafts and conflicts; editing does not confirm proposals.
- [gdd_skills.md](gdd_skills.md) owns monster skills, including removal of combination surcharges; [§6.3.2](#632-permanent-skill-slot-development-confirmed) covers meta integration only.

| Review area | Existing TODOs |
|-------------|----------------|
| Monster skills / slot-development steps / Major Surge access | T02/T05/T32 |
| City, catalogs, equipment, items and loadout | T15–T20 |
| Expeditions, acquisition and Internal World | T21–T25 |
| Staff, favor, economy, progression and day AP | T26–T31 |
| Documentation / roadmap synchronization | T35 |

**Completed removals:** Legendary aspect changes (T33) and Dual-aspect progression (T34) are not active mechanics; neither authorizes a replacement system. Historical prototype notes do not override current rules.
