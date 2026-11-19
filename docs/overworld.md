# Overworld and Meta

- **This file owns** the rules around the battle: the city and its groups, wild areas and one-time realms, the Internal World, obtaining and housing monsters, the growth of the player, tamer skills, items, the house and the day.
- **Frame:** [vision.md](vision.md) says what the game is; this file says how it works. Where the two differ, the frame holds.
- **Elsewhere:** battle rules ([battle.md](battle.md), [battle_ingame.md](battle_ingame.md)), monster skills ([skills.md](skills.md)), monsters and their stats ([monsters.md](monsters.md)).
- **Status:** working draft throughout; every number is a working value and nothing is validated by play.
- There are no fixed monster aspects, no aspect triangle and no attunement; themes imply no affinity, matchup or learning restriction.

---

## 1. Overview

A xuanhuan **city of cultivators** around deterministic grid battles and monster collection: a disrespected beast tamer of a great family grows, by battle, by people or by craft, until they can leave the city.

### 1.1 Setting and Player Fantasy

- **Beast tamer:** monsters live in the Internal World, a world of the player's own that nobody else enters.
- **The city is the whole world:** ten groups hold it ([§3.2](#32-the-groups-of-the-city)). A barrier keeps everyone below Sovereign inside; passing it is the end of the game.
- **The player is small:** buildings and districts are imposing, and the player starts as the least regarded member of their family.

### 1.2 Design Pillars

1. **Growth opens kinds of play, not bigger numbers:** a stage opens something new; numbers stay small and hard-capped.
2. **Weight is a key and a target:** what the player shows opens doors and draws reactions ([§7.2](#72-favor--faction)).
3. **Looking is free, deciding costs:** day AP are spent on deeds, never on walking, looking or planning.
4. **Several keys to every obstacle:** fight it, send one's people, or use one's standing. Only the trial of a breakthrough demands a battle.
5. **Found by trying, always the same result:** crafting hides what a plant or a part gives until the player tries it; nothing rolls.
6. **One schema per kind:** groups, items, structures, wings: the schema is built once, content is configuration.
7. **Choices, not damage:** nothing outside the battle raises Strike, ground or collision damage, and no equipment raises a stat.

---

## 2. Game Loops

| Loop | Time scale | Output |
|---|---|---|
| **Battle** | minutes | XP, loot, catches |
| **Wild area** | part of a day | materials, monsters, HP lost |
| **Day** | one turn of the game | everything resolved at night |
| **Cultivation** | many days (one arc) | stages, stat points, insights |
| **House and craft** | the whole game | money, standing, people, goods |

[§2.6](#26-action-catalog) alone owns what an action costs.

### 2.1 Battle Loop

The overworld prepares a closed fight and reads its result (rules: [battle.md](battle.md), [battle_ingame.md](battle_ingame.md)).

1. The encounter names its battleground and the enemy team.
2. The player picks the team and fills the **tamer slots** ([§7.9](#79-inventory-and-loadout)), seeing the full sheets of both sides.
3. Monsters and slots resolve into finished unit sheets; the fight starts.
4. The battle returns the winner or a draw, the HP left per monster, kills, catches and the pills used up. The overworld awards XP and loot.

- **No hidden information:** both sides' sheets and slots are known before the battle. A wild monster shows its Kin and themes; engaging shows the exact sheet.
- **How many fight:** the battleground says how many monsters a side fields; the player fields at most as many as the Internal World holds ([§4.4](#44-capacity-and-growth)).
- The battle reads only finished unit sheets and returns facts, not rewards.

### 2.2 Wild Area Loop

A wild area turns day AP and HP into materials and monsters ([§3.3](#33-wild-areas-and-one-time-realms)).

1. Walk in: free. Look around: free. The layout is always the same.
2. Take a resource: 1 day AP.
3. Engage a wild monster: 1 day AP, then the Battle Loop.
4. Leave whenever you want; what you took is yours.

- **HP persists through the day;** every battle starts at the HP the monster has. A monster that falls is injured ([§5.2](#52-defeat-and-injury)). A night restores the HP of a monster that is not injured.
- Wild monsters are visible and walk about; touching one starts the battle. There are no random encounters and no ambush bonus.
- Wild monsters are caught in battle on Seal Ground ([battle_ingame.md §7](battle_ingame.md#7-catching)).

### 2.3 Day Loop

A day is one turn: spend day AP in the city, the night resolves everything at once.

1. The day starts with the day AP of the stage ([§2.6](#26-action-catalog)).
2. The player spends them on deeds, in any order.
3. The day ends by hand or when the day AP run out.
4. **Night:** orders of the house resolve, golems work, plants grow, eggs and breeding progress, monsters in a fitting habitat gain XP, injured monsters rest, what was taken in a wild area moves one night closer to its return, prices shift.
5. Morning report, then the new day.

- **No time pressure:** requests expire in days and never force a deed. There is no clock within a day.
- The night synchronizes all systems once: there is no real-time simulation.

### 2.4 Cultivation Loop

1. Battles, pills and cultivating fill the XP bars of the player and of each monster.
2. A full bar is a sub-tier (Lower → Middle → High); a monster gets stat points ([monsters.md §2.2](monsters.md#22-prices-and-points)).
3. At High, the end of the arc and the trial lead to the next stage ([§6.3.1](#631-breakthrough-trials)).
4. The breakthrough gives what [§6.3](#63-stage-unlock-table) lists and one insight.

- **Ceiling:** a monster never exceeds the player's stage, the Internal World never either.

### 2.5 House and Craft Loop

1. **Acquire:** wild areas, realms, buying, catching, requests.
2. **Make:** pills in the cauldron, weapons and armour in the forge ([§7.5](#75-materials-seeds-and-grades)).
3. **Use:** in battle, as a gift, for a request or a hall's trial, to equip one's people, or for sale.
4. **Reinvest:** the Internal World, the house and its wings, people, tokens for a realm.

- **No route is the gate of another:** a player may grow by battle, by people or by craft; each opens obstacles in its own way ([§7.2](#72-favor--faction)).
- **Stones buy speed and breadth,** never a thing that only a deed can give ([§7.7](#77-economy-design-rule)).

### 2.6 Action Catalog

- **Authority:** the only catalog of what a deed costs. AP here means **day AP**, never battle AP.
- **Day AP per stage:** Qi Gathering 6 · Foundation 7 · Core Formation 8 · Soul Tier 9 · Immortal 10 · Sovereign 11.

| Deed | Cost | Needs |
|---|---|---|
| Walk, look, enter an area or a building, talk, plan, arrange the Internal World | free | — |
| Take a resource in a wild area or a realm | 1 AP | — |
| Engage a wild monster | 1 AP | — |
| Enter a group realm | 1 token for all its days | the realm is open |
| Enter a world realm | not defined | once only |
| Use a tamer skill, a weapon or a pill in battle | its tamer slot | [§7.9](#79-inventory-and-loadout) |
| Lay Seal Ground | 1 Binding Seal, or free with the Seal skill | [§5.1](#51-obtaining-monsters) |
| Cultivate · train a monster | 1 AP | — |
| Study a scroll | 1 AP | the scroll |
| Take a pill outside a battle | the pill | — |
| Spend stat points · develop a skill slot | free | points or a step |
| Change a monster skill | a relearning pill | outside a battle |
| Breakthrough | the trial and its materials | High sub-tier |
| Raise the Internal World | materials | below the tamer's stage |
| Build or upgrade a structure or a wing | 1 AP + materials or stones | room on the grid; the house |
| Build a battleground | materials | the Battleground Hall |
| Work a cauldron or a forge by hand | 1 AP + inputs | the structure |
| Leave a standing order for a golem | free + inputs | a golem |
| Plant · harvest | free | a field |
| Buy · sell | spirit stones | a trader |
| Accept or hand in a request · consign · bid | 1 AP | the group |
| Take a hall's trial | 1 AP + the piece asked for | the hall |
| Give an order to the house | 1 AP (more in hiding, [§7.1](#71-the-house)) | people |
| End the day | free | — |

---

## 3. Overworld

### 3.1 The City

- **Full 3D with a follow camera** the player turns and zooms freely. The city is built from areas loaded one at a time: a district per group, the wild areas, the Internal World.
- **Scale:** halls and gates stand far above the player; a district is wide.
- **Nobody leaves the city** below Sovereign.

| District | Held by | Buildings *(draft)* |
|---|---|---|
| **Family compound** | the player's family | Family Hall, Ancestral Shrine, Training Yard, Beast Pens, the player's side house |
| **Rival compounds** (2) | one rival family each | Family Hall, Training Yard, Treasure Pavilion |
| **City Lord's mansion** | City Lord with the City Guard | Audience Hall, Guard Barracks, Notice Wall, Prison Tower |
| **Guild quarter** | Merchant Guild | Guild Hall, Trader's Row, Warehouse |
| **Auction Hall** | Auction Hall | Bidding Hall, Consignment Counter, Private Boxes |
| **Alchemy Hall** | Alchemy Hall | Trial Chamber, Herb Store, Public Cauldrons |
| **Smiths' Hall** | Smiths' Hall | Trial Forge, Ore Yard, Armoury |
| **The school** | the school | Great Hall, Library, Arena, Dormitories, the gate to its mountain |
| **Underground** | Underground | Black Market, Slave Market, Den |
| **Realm Gate** | City Lord | the teleport array into a one-time realm |

What each building offers is not defined beyond its group's row in [§3.2](#32-the-groups-of-the-city).

### 3.2 The Groups of the City

Ten groups, each with favor and Standing of its own ([§7.2](#72-favor--faction)) and a few named key persons. The player's house becomes the eleventh ([§7.1](#71-the-house)).

| Group | Role | Offers *(draft)* |
|---|---|---|
| **The player's family** | a great clan that looks down on the player | bloodlines, family requests, the arc of the family |
| **Two rival families** | compete with the player's family | requests against the other families, their treasures |
| **City Lord with the City Guard** | law and order; opposed to the Underground | permits, bounties, the Realm Gate |
| **Merchant Guild** | buys and sells, makes nothing | traders with drifting prices, licences |
| **Auction Hall** | neutral, serves all | monsters, eggs, rare goods, tokens; consignment |
| **Alchemy Hall** | ranks for alchemists | trials, plants, requests for pills |
| **Smiths' Hall** | ranks for smiths | trials, ore, requests for weapons and armour |
| **The school** | teaches; rivals inside it | the first arc, the Arena, its mountain |
| **Underground** | black market; opposed to the City Lord | the Slave Market (monsters and subordinates), goods without questions, hush for a hidden house |

Names and key persons are not defined.

### 3.3 Wild Areas and One-Time Realms

These two are the only places of their kind; there are no repeatable dungeons.

**Wild area:** a fixed place open to all, split into zones.

- **A zone** has a stage and a fixed list of what grows and lives there. Every zone is open to every player: its resources can be taken and its monsters met at any stage. Only the strength of its monsters holds a player back.
- **Every stage has at least one zone.**
- **Return:** a taken resource and a defeated or caught monster come back after a fixed number of nights. Which monster appears is drawn from the zone's list.
- **Costs:** [§2.2](#22-wild-area-loop).

| Wild area *(draft)* | Zones |
|---|---|
| The school's mountain | Foothill (Qi Gathering), Slope (Foundation), Peak (Core Formation) |
| The wild forest | Edge (Foundation), Deep Wood (Soul Tier), Heart (Immortal) |
| A third area for the late stages | among them a zone for Sovereign; name and zones are not defined |

| Returns after *(working values)* | Nights |
|---|---|
| Normal resource | 1 |
| Rare resource | 3 |
| Epic resource | 7 |
| Wild monster | 2 |

**One-time realm:** a world the game generates. There are two kinds:

| Kind | Opened by | How long | Entry |
|---|---|---|---|
| **Group realm** | a group of the city | several days (working value: 3) | a token, used up by the first entry; it holds for the days the realm is open |
| **World realm** | the world itself, neutral | one single visit | who leaves does not come back |

- **Announced:** the city announces a realm some days ahead.
- **Tokens** of a group realm come from groups (Standing), the Auction Hall, requests or battle. What a world realm asks for entry is not defined.
- **Inside:** resources and battles cost day AP as in a wild area; nothing returns. Other groups send their people in.
- **Gone:** when it closes, the realm no longer exists.
- How the people of other groups act inside is not defined.

---

## 4. Internal World

The player's own world: monsters live here, plants grow, the cauldron and the forge stand here.

- **Nobody else enters:** no shops, no selling, no people. Golems do the work the player does not.

### 4.1 Functions

- **Home of the monsters:** they roam freely; a monster with a fitting habitat thrives ([§4.3](#43-what-lives-in-the-spatial-space)).
- **Making:** fields, cauldron, forge.
- **Battlegrounds:** built in the Battleground Hall ([battle_ingame.md §3](battle_ingame.md#3-battlegrounds)).
- **Preparing:** team, tamer slots, stat points and skill slots are arranged here or anywhere else, free of cost.

### 4.2 Building System

Everything placed in the Internal World is a **structure**.

```
STRUCTURE
 name, size (grid footprint), category
 source: built with materials | bought | reward
 level: upgradeable with materials
 placed_on: a cell of the grid
```

- **A coarse grid:** what stands where is free; moving a structure costs nothing, and none is ever lost.
- **Neighbours give small gains,** here and nowhere else in the game.

### 4.3 What Lives in the Spatial Space

| Category | Structure | Footprint | Function | From world stage |
|---|---|---|---|---|
| Core | World Core | 2×2 | the Internal World is raised here ([§4.4](#44-capacity-and-growth)) | 1 |
| Growing | Herb Field | 2×2 | grows plants from seeds | 1 |
| Growing | Spirit Tree | 3×3 | slow plants of Epic grade | 3 |
| Making | Cauldron | 2×2 | pills ([§7.5](#75-materials-seeds-and-grades)) | 1 |
| Making | Forge | 2×2 | weapons, armour, golems | 2 |
| Making | Seal Bench | 1×1 | Binding Seals | 2 |
| Habitat | Nest · Cave · Grove · Pond · Hive | 2×2 | a monster whose Kin fits thrives: XP at night, breeding, faster recovery | 2 |
| Breeding | Incubator | 1×1 | hatches eggs | 2 |
| Recovery | Recovery Spring | 2×2 | an injured monster rests one night less | 2 |
| Battle | Battleground Hall | 3×3 | the player builds battlegrounds of their own | 2 |
| Cultivation | Meditation Stone | 1×1 | the player cultivates here | 1 |
| Cultivation | Statue | 1×1 | holds an insight on show; no effect | 1 |
| Storage | Storehouse | 1×1 | holds goods | 1 |
| Water | Spirit Pond | 2×2 | water for neighbours | 1 |

- **Habitats:** any monster can move in. Only a monster with a habitat that fits its Kin grows by itself at night; one habitat holds two monsters. Which habitat fits which Kin is not defined.
- **Golems:** built in the forge, one task each: tend the fields (harvest and replant), tend a habitat, or work the cauldron or forge on a standing order. A golem does its task every night. How many golems a world holds is not defined.

| Structure | Next to | Gain |
|---|---|---|
| Herb Field · Spirit Tree | Spirit Pond | one growing night less |
| Habitat | another habitat of the same kind | breeding takes one night less |
| Incubator | a habitat of the egg's Kin | hatches one night earlier |
| Recovery Spring | Spirit Pond | one resting night less |

### 4.4 Capacity and Growth

**The Internal World has a stage of its own.** The player raises it at the World Core with materials; it is never higher than the tamer's stage.

| World stage | Grid | Holds monsters | Own battlegrounds |
|---|---|---|---|
| 1 | 6×6 | 2 | 0 |
| 2 | 8×8 | 3 | 1 |
| 3 | 10×10 | 5 | 2 |
| 4 | 12×12 | 7 | 3 |
| 5 | 14×14 | 9 | 4 |
| 6 | 16×16 | 12 | 5 |

- What a stage costs in materials is not defined.
- An egg in an Incubator does not count until it hatches.

---

## 5. Monsters in the Overworld

[monsters.md](monsters.md) owns individuals, stats, Kins and rarity; [skills.md](skills.md) owns skills and their development; this chapter owns how a monster is obtained and what a defeat does.

### 5.1 Obtaining Monsters

Every way yields an **individual** ([monsters.md §1](monsters.md#1-species-and-individual)); what is rolled is rolled when the individual is created, never in battle.

| Way | How |
|---|---|
| **Seal (in battle)** | the tamer lays Seal Ground; a wild monster that ends its turn on it with few HP, or falls to 0 HP on it, is caught ([battle_ingame.md §7](battle_ingame.md#7-catching)) |
| **Slave Market** | monsters for spirit stones at the Underground; the sheet is visible |
| **Auction Hall** | young monsters and eggs; the sheet is visible before the bid |
| **Eggs** | found in wild areas and realms, bought, given; hatched in an Incubator. An egg fixes species and rarity; hatching rolls the shape |
| **Breeding** | two monsters of one species in a fitting habitat: an egg after some nights |
| **Gift** | from a key person, as the reward of a request or an arc |

- **Binding Seal** (item): tier = stage, grade = rarity; it catches a monster of at most its tier and grade. The player's stage is a ceiling as well.
- **Two sources of Seal Ground,** both from the start: the seal item, used up when laid, and the Seal tamer skill, which costs nothing per battle but a tamer slot ([§6.4](#64-tamer-skills)). Seal items catch by rarity (chances: [battle_ingame.md §7](battle_ingame.md#7-catching)).

### 5.2 Defeat and Injury

- **Injured, not dead:** the contract with its tamer holds a monster. A fallen monster is out for the rest of the day and rests **2 nights**; a Recovery Spring shortens it, a Revival pill ends it at once. It never loses a sub-tier, stat points or skill development.
- **Death:** only wild monsters die ([battle_ingame.md §7](battle_ingame.md#7-catching)). Places where the contract does not hold are not defined.

---

## 6. Progression

### 6.1 Cultivation Structure

```
STAGES      Qi Gathering → Foundation → Core Formation → Soul Tier → Immortal → Sovereign
SUB-TIERS   Lower → Middle → High (per stage)
BREAKTHROUGH   High → the next stage's Lower
```

Monsters use the same names ([monsters.md §5](monsters.md#5-growth)).

### 6.2 What Grows

| What | How | Limit |
|---|---|---|
| **The tamer's stage** | cultivation; the same for every player | the trial |
| **An insight** | one of three at every breakthrough: one for battle, one for people, one for craft and trade | five in the game |
| **Ladders of deeds** | the rank of a craft, favor and Standing with a group, the house, the stage of the Internal World | day AP |
| **A monster** | stat points, skill development, rarity, armour | the tamer's stage |

- There is no skill tree and there are no points to distribute for the player.
- **A sub-tier of the tamer** fills the bar toward the breakthrough; what else it gives is not defined.
- The insights are not defined.

### 6.3 Stage Unlock Table

One arc per stage; the breakthrough closes the arc ([vision.md §6](vision.md#6-story-and-the-end)).

| Stage | Arc | Tamer slots | Opens besides |
|---|---|---|---|
| Qi Gathering | School | 1 | catching; the Internal World; the foothill of the school's mountain |
| Foundation | Family | 2 | habitats, the forge and golems; the Battleground Hall; the wild forest |
| Core Formation | One-time realm | 3 | the house and its orders ([§7.1](#71-the-house)) |
| Soul Tier | Monster riot | 3 | Beast Swap |
| Immortal | Struggle for the city | 4 | battlegrounds for five monsters; holding districts |
| Sovereign | Leaving | 4 | the barrier opens |

- **No stage opens a team size** ([§2.1](#21-battle-loop)).
- **The end of an arc:** the player shows themselves or stays unseen ([§7.2](#72-favor--faction)); a few great decisions also open or lock later steps of the story.
- What a monster gains per stage: [monsters.md §5](monsters.md#5-growth).

#### 6.3.1 Breakthrough Trials

**The trial of a breakthrough is a battle the player fights on the board;** it is the only battle the game demands. It needs the High sub-tier and the materials of the next stage.

| Breakthrough | Trial *(draft)* |
|---|---|
| Qi Gathering → Foundation | the final examination of the school: a duel in its Arena |
| Foundation → Core Formation | the test of the family: against the guardians of the Ancestral Shrine |
| Core Formation → Soul Tier | the guardian at the heart of the one-time realm |
| Soul Tier → Immortal | the tribulation: against a mirror of the player's own team |
| Immortal → Sovereign | the guardian of the barrier |

- A monster's breakthrough needs materials and, from Core Formation on, a won battle with that monster in the team.
- A *Breakthrough pill* eases a trial; how is not defined.

#### 6.3.2 Permanent Skill-Slot Development (confirmed)

[skills.md §8](skills.md#8-development) alone defines the development of skills, for monsters and tamers alike.

- A monster gains development steps at its advancement steps ([monsters.md §5](monsters.md#5-growth)); they are never bought.
- A skill is replaced with a **relearning pill**, outside a battle; the slot keeps its level.
- Where the choice is made is free: anywhere outside a battle.

### 6.4 Tamer Skills

Tamer skills are **learned for good** and then brought into a battle in a tamer slot ([§7.9](#79-inventory-and-loadout)); what they do in battle: [battle_ingame.md §5](battle_ingame.md#5-tamer-skills) and [§7](battle_ingame.md#7-catching).

- **Separate source:** tamer skills act on the same squares, grounds and zones as monster skills but are no skill cards. What a tamer may do gives no monster the right to do it.
- **Domain Glimpse:** removes zones and resets ground to Plain on the squares of a tetromino the tamer places anywhere on the board, in any rotation or reflection, wholly on the board. Voidscar and Dragon Veins stay; props and monsters are unaffected.

| Skill | Stage | Effect |
|---|---|---|
| Seal | from the start | lays Seal Ground ([battle_ingame.md §7](battle_ingame.md#7-catching)) |
| Qi Suppression | Foundation | an enemy monster −1 Pace point next round |
| Spirit Shield | Foundation | not defined |
| Swap Places | Foundation | two own monsters trade squares |
| Domain Glimpse | Core Formation | clear a tetromino of zones and reset its ground |
| Urgent Order | Core Formation | an own monster that has not acted this round acts next |
| Second Wind | Core Formation | an own monster regains 1 HP |
| Life Thread | Core Formation | the next time an own monster would fall it stays at 1 HP |
| Beast Swap | Soul Tier | exchange an active monster with one that waits in the Internal World |

- **Learning:** every breakthrough of the player teaches one skill of the new stage's list; a scroll teaches one skill. Immortal and Sovereign list none yet.
- **Use:** once per battle, free of battle AP, never used up; visible to both sides before the battle.
- **Development:** by the pattern of [skills.md §8](skills.md#8-development), levels 1–3, one option per level, never more uses. One step per breakthrough of the player and one per **upgrade scroll**, which is bound to one skill.

**Options of Seal** *(draft; the other skills have none yet)*:

| Option | Vocabulary | Effect |
|---|---|---|
| Wide Seal | Area | Seal Ground on two adjacent squares |
| Strong Seal | Number | base chance 65 % |
| Patient Seal | Number | 5 points less per HP instead of 10 |
| Drawing Seal | Addition | Seal Ground also pulls like a pull zone |
| Walled Seal | Addition | lays Earth Walls on the free squares around it |
| Deep Seal | Condition | a seal one tier below the target suffices |

### 6.5 The Balance Rule

- **Pills** serve growth outside the battle and one moment inside it. **Weapons and armour** give options, never numbers. All goods share one schema ([§7.6](#76-item-schema)).
- Everything the tamer brings into a battle takes a tamer slot and is visible beforehand.

### 6.6 Pills & Medicines

A pill is made in the cauldron from plants that share a property ([§7.5](#75-materials-seeds-and-grades)); the shared property is its effect.

| Property | Pill | Where it acts |
|---|---|---|
| Growth | cultivation: XP ([monsters.md §5](monsters.md#5-growth)) | outside the battle |
| Mending | healing: restores 2 HP | outside the battle; in battle from a tamer slot |
| Renewal | revival: ends an injury | outside the battle |
| Clarity | relearning: a skill slot takes another skill | outside the battle |
| Opening | breakthrough: eases a trial | outside the battle |
| Bloodline | rarity ascension ([monsters.md §4](monsters.md#4-rarity)) | outside the battle |
| Change | reshape: the monster is rolled anew by another stat shape ([monsters.md §2.3](monsters.md#23-shapes-and-spending)) | outside the battle |
| Warding | the next hit on one own monster this round deals nothing | in battle |
| Swiftness | one own monster +1 Pace point until the round ends | in battle |
| Anchoring | one own monster cannot be pushed or pulled until the round ends | in battle |

- **A pill in battle** takes a tamer slot, acts once and is used up. It heals, protects or moves; it never raises damage.
- A pill with two shared properties has both effects.
- There is no pill that is taken before a battle to act in it.

### 6.7 Weapons and Armour

| Piece | Worn by | Gives | Slots |
|---|---|---|---|
| **Weapon** | the tamer | a skill of its own, used once per battle from a tamer slot | 1 |
| **Armour** | a monster | one more passive of the list in [skills.md §6](skills.md#6-passives) | 1 per monster |

- **No equipment raises a stat,** and none raises damage.
- **A weapon's skill** is fixed by its parts and does not develop.
- **Worn openly, a piece counts toward the player's weight** ([§7.2](#72-favor--faction)); kept in the Internal World it does not.
- The lists of weapon skills and armour passives are not defined.

### 6.8 Arrays (artifacts for places)

There are no arrays as items. A player who wants a board in their favour builds a battleground of their own ([battle_ingame.md §3](battle_ingame.md#3-battlegrounds)).

### 6.9 Hard Caps

- No pill, weapon, armour or insight raises Strike, ground or collision damage ([battle.md §6.1](battle.md#61-damage)).
- No equipment raises a stat.
- A tamer skill, a weapon and a pill act once per battle each.
- Everything brought into a battle is visible in the preview.

---

## 7. Management

### 7.1 The House

From Core Formation the player founds **a house of their own**: the eleventh group of the city, with a weight of its own.

| Wing | Holds | Gives |
|---|---|---|
| **School** | students: the player's people | orders at night |
| **Workshop** | cauldrons and forges with people at them | goods made at night |
| **Trading hall** | shelves and a counter | sales at night, consignment for others |
| **Monster hall** | pens | trained monsters for sale and for hire |

- **Wings come one after another;** all four can stand. Which the player builds is the route. What a wing costs is not defined.
- **Open or hidden:** a house is founded openly or in hiding. A hidden house may do everything and adds no visible weight, but each of its orders costs 1 day AP more and hush money to the Underground. Only an event of the story uncovers it.
- **Before the house** the player sells to the traders of the Merchant Guild and consigns at the Auction Hall.

#### 7.1.1 People

The player's people are the students and staff of the house.

| Field | Meaning |
|---|---|
| Strength | one visible number; equipment the player hands out raises it |
| Loyalty | visible 0–5; wages and care raise it, neglect and better offers lower it; at 0 the person leaves |
| Trait | one visible trait |

- **Orders:** by day the player gives an order to some of their people: harvest a zone of a wild area, guard a place, press a demand against a group, enter a realm.
- **The night decides** by comparing the summed Strength of the people sent with the visible value of the task or of the other side; the higher wins, a tie holds what was. The outcome is shown before the order is given. There is no battle on the board.
- Traits, wages and where people come from (the school of the house, the Slave Market, key persons) are not defined.

### 7.2 Favor & Faction

Every group knows the player by two numbers, and the city knows the player by their weight.

```
FAVOR      points, earned and spent: a discount, an introduction, a token
STANDING   a rank: Stranger → Known → Trusted → Allied → Sworn
           the sum of all favor ever earned; never spent
WEIGHT     what the city sees of the player; every group has a weight too
```

**Deeds:** favor is earned through requests, sales the group wants, wins in its name and gifts to its key persons.

- **A request that harms another group says so before the player accepts,** and by how much: the harmed group loses that much favor toward the player. Favor below zero is a grudge; a group with a grudge gives no requests until it is paid off.
- No group dislikes the player for a friendship alone, and nothing decays with time.

| Size of a request | Favor | Lifetime |
|---|---|---|
| Errand | 1 | 3 days |
| Task | 3 | 5 days |
| Commission | 8 | 10 days |
| Great deed | 20 | story |

Standing: Known 5 · Trusted 30 · Allied 100 · Sworn 250.

**Weight:** the sum of what the player shows.

| Shown | Weight |
|---|---|
| each stage above Qi Gathering | 1 |
| each arc at whose end the player showed themselves | 2 |
| each rank of a craft | 1 |
| an open house, and each of its wings | 1 |
| a weapon or armour of Epic grade or higher, worn openly | 1 |

- **A group whose weight the player passes reacts:** it tests the player, demands something, or allies with another group against them. Which group does what is part of the story.
- **A group below the player's weight gives way:** the player's Standing opens what it guards without a battle.

| | Show oneself | Stay unseen |
|---|---|---|
| **Gains** | the reward of the arc and Standing; key persons come with offers; doors open by Standing | no group reacts; rivals do not prepare |
| **Costs** | every group whose weight the player passes reacts | no reward; every obstacle is fought, paid for or left to one's people |

The weights of the groups are not defined.

### 7.3 Currency: Spirit Stones Only

One whole number, shown in denominations: 100 Lower = 1 Middle · 100 Middle = 1 Upper. There is no second currency.

### 7.4 The Resource Kinds

| Resource | Sources | Sinks |
|---|---|---|
| **Spirit stones** | sales, requests, the house | people, materials, structures, hush money |
| **Materials** | wild areas, realms, fields, buying | pills, weapons, armour, structures, the Internal World |
| **Favor** | requests, sales, gifts | discounts, introductions, tokens, licences |
| **XP** | battles, cultivating, pills, habitats | sub-tiers |

### 7.5 Materials, Seeds and Grades

All goods use the four grades of monster rarity: Normal, Rare, Epic, Legendary.

```
MATERIAL = tier (cultivation stage) × form × grade
FORMS    plant · ore · beast part (by Kin) · essence
```

- **Where they come from:** plants and ore from the zones of wild areas and realms; beast parts from defeated wild monsters; essences from the strongest monsters and from realms.
- **Only plants are grown:** Normal and Rare in a Herb Field, Epic in a Spirit Tree, Legendary never. A seed is an item that names one plant; a harvest of a Normal plant returns a seed.

**Alchemy:**

- **Every plant has three or four properties** of the list in [§6.6](#66-pills--medicines).
- **Two or three plants that share a property give a pill with that effect;** the lowest tier among them is the pill's tier, the lowest grade its grade.
- **A property is unknown until the player has made a pill with it.** The same plants always give the same pill; plants that share nothing give nothing and are lost.
- Which plant has which properties is not defined.

**Smithing:**

| Part | Material | Sets |
|---|---|---|
| Body | ore | tier and grade |
| Core | a part of a monster | which skill (weapon) or passive (armour), by the Kin of the monster |
| Temper | an essence; may be left out | one variation in the vocabulary of [skills.md §8](skills.md#8-development) |

- **What a part gives is unknown until the player has forged with it;** the same parts always give the same piece.
- A golem is forged from ore and an essence.
- **No crafting is a minigame.**

**Rank of a craft:** the Alchemy Hall and the Smiths' Hall each grant six ranks by trial, named and counted like the six stages (Qi Gathering to Sovereign): the player hands in the piece the hall asks for, at the grade it asks for. A rank opens the hall's better requests and stores and counts toward the weight ([§7.2](#72-favor--faction)).

### 7.6 Item Schema

```
ITEM
 kind:   Material | Seed | Pill | Weapon | Armour | Golem | Seal | Scroll | Token | Structure
 tier:   a cultivation stage
 grade:  Normal | Rare | Epic | Legendary
 value:  base price in spirit stones
 effect: none (materials) | grows (seeds) | on use (pills) | while worn (weapon, armour)
         | works (golem) | binds (seals) | teaches (scrolls) | admits (tokens)
```

### 7.7 Economy Design Rule

**Stones buy speed and breadth.** What only a deed gives stays out of the shops: a rank, an insight, a breakthrough, Legendary goods.

### 7.8 Acquisition Sources

| Source | Gives |
|---|---|
| **Wild areas** | plants, ore, beast parts, eggs, monsters to catch |
| **One-time realms** | the same at higher grades, essences, scrolls |
| **Merchant Guild** | Normal materials, seeds, seals and pills at drifting prices |
| **Auction Hall** | monsters, eggs, Rare and Epic goods, scrolls, tokens |
| **Underground** | monsters and subordinates, goods the other groups do not sell |
| **Alchemy Hall · Smiths' Hall** | plants and ore by rank, requests |
| **Fields** | plants from seeds |
| **Cauldron · forge** | pills, weapons, armour, golems, seals |
| **Breeding** | eggs |
| **Requests and key persons** | any item, often a unique one |

### 7.9 Inventory and Loadout

- **The player carries the inventory;** a monster owns only its armour. Goods have no weight.
- **Tamer slots:** before a battle the player fills each slot with one learned tamer skill, one weapon or one pill. The tamer carries one weapon at most. Each acts once in that battle; a pill is used up, a skill and a weapon are not.
- **How many:** [§6.3](#63-stage-unlock-table).
- A human opponent brings slots of their own; a wild monster has none.

---

## 8. Technical Notes

- **Presentation:** full 3D; a follow camera in the city and its areas, the battle's own camera on the board. Areas are loaded one at a time.
- **Night synchronization:** all resolvers run once when the day ends.
- **Data:** species, items, structures, groups, wild areas and wings are data files loaded by one registry pattern; new content is a new file.
- **Individual:** a save record without battle rules: species, shape, stats, unspent points, rarity, stage and sub-tier, XP, development per skill slot, armour, current HP.
- **Battle request and result** are the only contract between the two halves ([architecture.md §1](architecture.md#1-two-games-and-what-they-share)): the request holds the battleground, both teams as finished unit sheets and the tamer slots; the result holds the winner, HP left, kills, catches and the pills used up.
- The whole game state lives in one save object, written at night.
