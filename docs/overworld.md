# The Game Around the Battle

- **This file owns** the rules around the battle: what a deed costs, obtaining monsters, the growth of the tamer, the Ways, tamer skills, goods and the loadout.
- **Frame:** [vision.md](vision.md) says what the game is and owns the pillars and the Ways, the lifespan, the two places of battle, the start and the hub; this file says how the rest works. Where the two differ, the frame holds.
- **Elsewhere:** battle rules ([battle.md](battle.md), [battle_ingame.md](battle_ingame.md)), monster skills ([skills.md](skills.md)), monsters and their stats ([monsters.md](monsters.md)).
- **Status:** working draft throughout; every number is a working value and nothing is validated by play.
- There are no fixed monster aspects, no aspect triangle and no attunement; themes imply no affinity, matchup or learning restriction.

---

## 1. Design Rules

1. **Everything serves the battle:** a system changes what stands on the board, or it is not part of the game ([vision.md §1](vision.md#1-the-game-in-one-picture)).
2. **Growth opens kinds of play, not bigger numbers:** a stage opens something new; numbers stay small and hard-capped.
3. **Looking is free, a deed costs a year:** a battle in the wild, a new look at the wild and an attack on the void each cost a year of the lifespan; looking and planning cost nothing.
4. **Nothing is hidden before a battle:** both sides' sheets, the battleground and the loot are shown.
5. **Nothing is made:** what a Way uses drops ready from a battle, and the drop is shown before the battle.
6. **One schema per kind:** items, places, buildings, Ways: the schema is built once, content is configuration.
7. **Choices, not damage:** nothing outside the battle raises Strike, ground or collision damage, and no equipment raises a stat.

---

## 2. Loops

### 2.1 Battle Loop

The hub prepares a closed fight and reads its result (rules: [battle.md](battle.md), [battle_ingame.md](battle_ingame.md)).

1. The battle of the wild or the depth names its battleground and the enemy team. The battleground is generated; the Artificer lays parts on it in the wild and brings the own battleground to the void ([§5.3](#53-the-way)).
2. The player picks the team and what the Way brings ([§6.5](#65-loadout)), seeing the full sheets of both sides.
3. Monsters and slots resolve into finished unit sheets; the fight starts.
4. The battle returns the winner or a draw, the HP left per monster, kills, catches and the pills used up. The hub hands out the drop and the rises.

- **How many fight:** the battleground says how many monsters a side fields; the player fields at most as many as the roster holds ([§4.3](#43-the-roster)).
- The battle reads only finished unit sheets and returns facts, not rewards.

### 2.2 Deed Loop


1. The player prepares in the hub: everything there is free.
2. **A deed:** a battle in the wild, a new look at the wild or an attack on the void ([vision.md §4](vision.md#4-where-battles-happen)). Each costs a year of the lifespan ([vision.md §3](vision.md#3-the-lifespan)).
3. The hub reads the result back: the drop, the rises, the eggs.

- **No day and no night:** the lifespan is the only clock; nothing happens between two deeds.
- **Every battle starts at full HP.**

### 2.3 Action Catalog


- **Authority:** the only catalog of what a deed costs. AP in this file never means anything but battle AP.

| Deed | Cost *(working values)* | Needs |
|---|---|---|
| Look at a place, a battle, a sheet; plan; order the monsters | free | — |
| A battle in the wild | 1 year, won or lost | — |
| A new look at the wild | 1 year | — |
| A depth of the void · the Sovereign beast | 1 year, won or lost | — |
| The breakthrough trial | 1 year when lost; won, it ends the lifespan it would be paid from | — |
| Use a tamer skill or a pill in battle | its tamer slot | [§6.5](#65-loadout) |
| Lay Seal Ground | by the Way | [§4.1](#41-obtaining-monsters) |
| Spend stat points · develop a skill slot · give a rise | free | points, a step, a rise |
| Buy a node of the Way | Insight | the tree of the stage is open |
| Give a pill to a monster outside a battle | the pill | — |

---

## 3. Places


The wild and the void, with what each costs and gives: [vision.md §4](vision.md#4-where-battles-happen). The buildings of the hub: [vision.md §6](vision.md#6-the-hub).

**The wild** *(working values)*:

- **A look shows 3 battles.** The first is the easiest: the fewest monsters of the stage, all at Lower. The others draw their number and the sub-tier of each monster.
- **Monsters per battle, by the stage of the tamer:** 1–2 · 1–3 · 2–3 · 2–4 · 2–4.
- **A battle won leaves the look;** the others stay. A battle lost waits. When every battle of a look is won, a new look comes for nothing.
- **The drop** is one unit of the reward of the Way per monster ([§6.1](#61-what-drops)), and the rises ([monsters.md §5](monsters.md#5-growth)).
- **An egg:** a battle may hold an egg of one of its species, by chance (15 %); it is shown with the drop.
- **Every opponent is shown with its stage and sub-tier,** in the look, before the battle and in it.

---

## 4. Monsters Outside the Battle

[monsters.md](monsters.md) owns individuals, stats and Kins; [skills.md](skills.md) owns skills and their development; this chapter owns how a monster is obtained and what a defeat does.

### 4.1 Obtaining Monsters

Every way yields an **individual** ([monsters.md §1](monsters.md#1-species-and-individual)); what is rolled is rolled when the individual is created, never in battle.

| Way | How |
|---|---|
| **The first egg** | one of three from the nest ([vision.md §5](vision.md#5-the-start)) |
| **Seal (in battle)** | Seal Ground lies in a battle of the wild; a wild monster that ends its turn on it with few HP, or falls to 0 HP on it, is caught ([battle_ingame.md §7](battle_ingame.md#7-catching)) |
| **Eggs** | hatched in the Nest. An egg fixes the species; the player spends its stat points and chooses its four skills from the learnable list ([monsters.md §1](monsters.md#1-species-and-individual)). This holds for every egg, the first one too. An egg hatches after 2 battles fought *(working value)*. Further eggs: a battle of the wild may hold one ([§3](#3-places)) |

- **Void monsters** are never caught: a void egg is the trophy of a passed breakthrough trial ([monsters.md §3](monsters.md#3-kins)). Which trials give one is not defined.
- **Every Way brings Seal Ground by its own means,** from the start of a game: the Artificer lays it as a part before the battle, the Formation has the Seal tamer skill, the Alchemist carries a Binding pill that turns a square into it and is used up ([§5.3](#53-the-way)). What limits a seal and its chance: [battle_ingame.md §7](battle_ingame.md#7-catching).
- Breeding is not defined.

### 4.2 Defeat

- **A monster of the player never dies:** its contract holds it. At 0 HP it is defeated for that battle.
- **No injury:** every battle starts at full HP ([vision.md §4](vision.md#4-where-battles-happen)).
- **Death:** only wild monsters die ([battle_ingame.md §7](battle_ingame.md#7-catching)).
- A lost battle costs its year and nothing else.

### 4.3 The Roster

- **Roster:** every monster the player owns.
- **Team:** the monsters of the roster that the player sends into the next battle.
- How many the roster holds is not defined.

---

## 5. Progression

### 5.1 Stages


```
STAGES      Qi Gathering → Foundation → Core Formation → Nascent Soul → Immortal
```

| Stage | Tamer slots | Lifespan in years *(working value)* |
|---|---|---|
| Qi Gathering | 1 | 10 |
| Foundation | 2 | 11 |
| Core Formation | 3 | 12 |
| Nascent Soul | 3 | 13 |
| Immortal | 4 | 14 |

- **Each stage opens** its wild, the depths of the void, the tree of the Way and a new lifespan ([vision.md §3](vision.md#3-the-lifespan), [§4](vision.md#4-where-battles-happen)).
- **The tamer has no XP and no sub-tiers:** the stage rises by the breakthrough trial alone. Monsters use the same stage names with three sub-tiers each ([monsters.md §5](monsters.md#5-growth)).
- **Ceiling:** a monster never exceeds the tamer's stage.
- **No stage opens a team size** ([§2.1](#21-battle-loop)).
- **Beyond Immortal** stands the Sovereign beast; defeating it wins the game, and nobody reaches a stage after it.
- **A boon at every breakthrough:** the player takes one of the boons; one may be taken again at a later breakthrough.

| Boon *(draft)* | Effect |
|---|---|
| Long Life | every lifespan is 3 years longer, the new one too |
| Wide Hand | one more tamer slot; the Artificer lays one more part |
| Keen Eye | a look at the wild shows one more battle |

### 5.2 The Breakthrough Trial

- **The last depth of the void of a stage** ([vision.md §4](vision.md#4-where-battles-happen)). It asks for no material.
- **Forced at the end of the lifespan;** losing that one loses the game ([vision.md §3](vision.md#3-the-lifespan)). The forced trial skips the depths not won yet, and with them their Insight.
- **A trial lost before its time** costs its year. A trial won lifts the team that fought it with the tamer ([monsters.md §5](monsters.md#5-growth)). The opponents of the trials are not defined.

### 5.3 The Way


The outline: [vision.md §2](vision.md#2-the-pillars-and-the-ways) and [§8](vision.md#8-growth). *Names, branches and numbers are working values.*

- **One Way per game,** chosen at the start. **It shuts the other two out:** their buildings and what they use do not exist in that game.

| Way | Has | Has not | Branches *(draft)* |
|---|---|---|---|
| **Artificer** (board) | parts of a battleground and the workshop. In the wild parts are laid on the generated board before each battle; in the void the battle is fought on the own battleground | tamer skills, pills | **foundry** (more parts laid before a battle of the wild) · **domain** (a larger budget for the own battleground) |
| **Formation** (tamer) | tamer skills in the tamer slots ([§5.4](#54-tamer-skills)) | a battleground of its own, pills | **hazard** (ground and traps that harm) · **command** (the own monsters: places, order, a second breath) |
| **Alchemist** (monsters) | pills for the monsters and pills in the tamer slots ([§6.2](#62-pills)) | tamer skills, a battleground of its own | **body** (more pills dropped, more of them carried into a battle) · **kit** (monsters that take more Tempering pills) |

- **Before and during:** the Artificer acts on the squares before the battle, and what is laid stays; the Formation acts on them during the battle, once and for a short time.
- **The gift of the start** *(working values)*: one of three, drawn from the game's seed. Formation: one tamer skill of the first tree that needs no other, free and counted as bought. Artificer: one pack of parts (3 Earth Walls, 2 Spike Traps, 3 Thornbed or 4 Rubble) beside the one Dragon Vein every Artificer owns. Alchemist: 2 pills of one kind for the battle (Mending, Warding, Swiftness or Anchoring) beside the 2 Binding pills.
- **Parts in the wild:** the Artificer lays owned parts before each battle, as many as they carry: **2 and 1 more per stage** *(working value)*, more by the foundry. A part is not used up. **A part may lie on any square;** no rule keeps a way open, to start with.
- **A tree per stage;** a breakthrough opens the next one. The trees of earlier stages stay open. A tree has two branches.
- **Insight** comes from the depths of the void, one per depth won; the Formation also gains it in the wild ([§6.1](#61-what-drops)).
- **A node** *(draft)*: for the Formation a tamer skill or a development step for one. For the Artificer one more part laid before a battle of the wild (foundry) or 3 more budget for the own battleground (domain). For the Alchemist, body: **Rich Find** (a wild battle drops one pill more) and **Deep Pouch** (one more tamer slot for pills); kit: **Open Meridians** (every monster takes 2 more Tempering pills).
- **Vows:** at the start of a game and after every breakthrough three vows are drawn; the player takes one or none, and at most three in a game. A vow is a strong benefit with a lasting restriction and holds for the rest of the game. It may shut out a Kin: the player binds no monster of that Kin again, and those in the roster stay. A vow of one Way is offered in that Way alone.

| Vow *(draft)* | Way | Gain | Price |
|---|---|---|---|
| Vow of the Fang · Feather · Scale · Hive · Veil · Stone · Root | all | the monsters of that Kin take two of the choices at every stage breakthrough | no monster of one other Kin is bound again |
| One Kin | all | every wild battle won drops one more of the reward of the Way | a team is of one Kin only |
| Vow of the Loner | all | every monster has one more slot | one place less in every team, at least one |
| Vow without Seal | all | wild battles hold an egg far more often | no Seal Ground, no catching |
| Call of the Void | all | every trial leaves two void eggs | no egg from the wild |
| Vow of the Still Ground | Artificer | 4 more budget for the own battleground | no zone as a part |
| Vow of the Open Sky | Artificer | a Dragon Vein counts 1 toward the budget | no prop as a part |
| Vow of the Open Hand | Formation | one more tamer slot | every lifespan is 1 year shorter |

### 5.4 Tamer Skills

Tamer skills belong to the **Way of the Formation**. They are **learned for good** and then brought into a battle in a tamer slot ([§6.5](#65-loadout)); what they do in battle: [battle_ingame.md §5](battle_ingame.md#5-tamer-skills) and [§7](battle_ingame.md#7-catching).

- **Separate source:** tamer skills act on the same squares, grounds and zones as monster skills but are no skill cards. What a tamer may do gives no monster the right to do it.
- **Domain Glimpse:** removes zones and resets ground to Plain on the squares of a tetromino the tamer places anywhere on the board, in any rotation or reflection, wholly on the board. Voidscar and Dragon Veins stay; props and monsters are unaffected.

| Skill | Tree of the stage *(draft)* | Effect |
|---|---|---|
| Seal | from the start | lays Seal Ground ([battle_ingame.md §7](battle_ingame.md#7-catching)) |
| Qi Suppression | Foundation | an enemy monster −1 Pace point next round |
| Spirit Shield | Foundation | not defined |
| Swap Places | Foundation | two own monsters trade squares |
| Domain Glimpse | Core Formation | clear a tetromino of zones and reset its ground |
| Urgent Order | Core Formation | an own monster that has not acted this round acts next |
| Second Wind | Core Formation | an own monster regains 1 HP |
| Life Thread | Core Formation | the next time an own monster would fall it stays at 1 HP |
| Beast Swap | Nascent Soul | exchange an active monster with one of the roster that is not in the battle |

- **Learning:** a tamer skill is a node of the Way. Its branches are not defined; Immortal lists no skill yet.
- **Use:** once per battle, free of battle AP, never used up; visible before the battle.
- **Development:** by the pattern of [skills.md §8](skills.md#8-development), levels 1–3, one option per level, never more uses. A step is a node of the Way.

**Options of Seal** *(draft; the other skills have none yet)*:

| Option | Vocabulary | Effect |
|---|---|---|
| Wide Seal | Area | Seal Ground on two adjacent squares |
| Strong Seal | Number | base chance 65 % |
| Patient Seal | Number | 5 points less per HP instead of 10 |
| Drawing Seal | Addition | Seal Ground also pulls like a pull zone |
| Walled Seal | Addition | lays Earth Walls on the free squares around it |

### 5.5 Development of Monster Skills

[skills.md §8](skills.md#8-development) alone defines the development of skills, for monsters and tamers alike.

- A monster gains development steps as a choice at a stage breakthrough and at late advancement steps ([monsters.md §5](monsters.md#5-growth)); a Honing pill of the Alchemist gives a further one ([§6.2](#62-pills)).
- **A slot is developed, not a skill:** the slot keeps its level when it takes another skill, and the options are chosen anew from that skill.
- A skill is replaced with a **relearning pill** of the Alchemist, outside a battle.
- Where the choice is made is free: anywhere outside a battle.

---

## 6. Goods

### 6.1 What Drops


There are no materials, no forge and no cauldron: what a Way uses drops ready from a battle of the wild, and the drop is shown before the battle.

| Way | A wild battle won drops *(working values)* |
|---|---|
| Artificer | units of one part of a battleground, one per monster of the battle |
| Alchemist | pills, one per monster of the battle, each of a kind drawn from [§6.2](#62-pills) |
| Formation | 1 Insight from a battle against 2 monsters or more |

- **A game holds the goods of its Way alone.**
- **Parts by stage:** Rubble, Thornbed, Earth Wall and Spike Trap from the start; Shifting Sand, Lava and Umbra from Foundation; Vortex Trap and Dragon Vein from Core Formation; Gale from Nascent Soul.
- Nothing is grown, made, bought or sold, and there is no currency.

### 6.2 Pills


*The Way of the Alchemist.* A pill has one effect and no flaw.

| kind:   Pill | Egg | Battleground part
 effect: on use (pills) | hatches (eggs) | placed (battleground parts)*(draft)* | Effect | Where it acts |
|---|---|---|
| Mending | one own monster regains 2 HP | in battle |
| Warding | the next hit on one own monster this round deals nothing | in battle |
| Swiftness | one own monster +1 Pace point until the round ends | in battle |
| Anchoring | one own monster cannot be pushed or pulled until the round ends | in battle |
| Binding | a square becomes Seal Ground ([battle_ingame.md §7](battle_ingame.md#7-catching)) | in battle |
| Growth | one monster rises a step, never past High ([monsters.md §5](monsters.md#5-growth)) | outside the battle |
| Tempering | 1 stat point for one monster beyond the points of its step; a monster takes at most 5 | outside the battle |
| Clarity | relearning: a skill slot takes another skill ([§5.5](#55-development-of-monster-skills)) | outside the battle |
| Honing | a development step for one skill slot | outside the battle |
| Change | reshape: every stat point comes back and is spent anew ([monsters.md §2.3](monsters.md#23-shapes-and-spending)) | outside the battle |

- **A pill in battle** takes a tamer slot, acts once and is used up. It heals, protects, moves or lays Seal Ground; it never raises damage.
- **Stat points from pills are a trial:** whether they may lift a monster above the points of its step ([monsters.md §2.2](monsters.md#22-prices-and-points)), and by how much, is to be found by play. They never lift a stat above its maximum.
- No pill is taken before a battle to act in it. A monster never exceeds the tamer's stage by a pill.

### 6.3 Parts of a Battleground


*The Way of the Artificer.*

- **A part is a ground, a zone or a prop** and nothing else: there are no weapons and no armour. It is placed on the own battleground in the workshop and laid on the generated board of a wild battle ([§5.3](#53-the-way), [battle_ingame.md §3](battle_ingame.md#3-battlegrounds)), within the budget of the stage.
- **A part is not used up:** it is owned as units, and as many may lie at once as are owned.
- **Seal Ground is a part** the Artificer owns from the start ([§4.1](#41-obtaining-monsters)).

### 6.4 Item Schema

```
ITEM
 kind:   Material | Pill | Egg | Battleground part
 effect: none (materials) | on use (pills) | hatches (eggs) | placed (battleground parts)
```

### 6.5 Loadout

- **The player carries the inventory;** a monster owns nothing. Goods have no weight.
- **Tamer slots:** before a battle the Formation fills each slot with one learned tamer skill, the Alchemist with one pill. Each acts once in that battle; a pill is used up, a skill is not.
- **The Artificer has no tamer slots:** what they bring are the parts laid before the battle.
- **What catches takes no room:** the Seal skill and one Binding pill ride beside the tamer slots; the one Seal Ground of the Artificer lies beside the parts carried.
- **How many:** [§5.1](#51-stages).
- A wild monster and a void monster have no tamer and no slots.

### 6.6 Hard Caps

- No pill, part or node of a Way raises Strike, ground or collision damage ([battle.md §6.1](battle.md#61-damage)).
- No equipment exists, and nothing raises a stat above its maximum.
- A tamer skill and a pill act once per battle each.
- Everything brought into a battle is visible in the preview.

---

## 7. Technical Notes

- **Presentation:** a hub screen of buildings and the battle's own view of the board; landscape, for touch and for mouse.
- **Data:** species, items, places, buildings and Ways are data files loaded by one registry pattern; new content is a new file.
- **Individual:** a save record without battle rules: species, shape, stats, unspent points, stage and sub-tier, development per skill slot, current HP.
- **Battle request and result** are the only contract between the two halves ([architecture.md §1](architecture.md#1-two-games-and-what-they-share)): the request holds the battleground with the parts laid on it, both teams as finished unit sheets and the tamer slots; the result holds the winner, HP left, kills, catches and the pills used up.
- The whole game state lives in one save object, written whenever the hub is shown. What a finished game leaves for the next one is saved apart from it.
