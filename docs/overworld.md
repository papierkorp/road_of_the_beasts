# The Game Around the Battle

- **This file owns** the rules around the battle: the day, obtaining monsters, the growth of the tamer, the Ways, tamer skills, goods and the loadout.
- **Frame:** [vision.md](vision.md) says what the game is and owns the pillars and the Ways, the lifespan, the two places of battle, the start and the hub; this file says how the rest works. Where the two differ, the frame holds.
- **Elsewhere:** battle rules ([battle.md](battle.md), [battle_ingame.md](battle_ingame.md)), monster skills ([skills.md](skills.md)), monsters and their stats ([monsters.md](monsters.md)).
- **Status:** working draft throughout; every number is a working value and nothing is validated by play.
- There are no fixed monster aspects, no aspect triangle and no attunement; themes imply no affinity, matchup or learning restriction.

---

## 1. Design Rules

1. **Everything serves the battle:** a system changes what stands on the board, or it is not part of the game ([vision.md §1](vision.md#1-the-game-in-one-picture)).
2. **Growth opens kinds of play, not bigger numbers:** a stage opens something new; numbers stay small and hard-capped.
3. **Looking is free, a deed costs the day:** a day is one dungeon run or one attack on the void; looking, planning and making cost nothing.
4. **Nothing is hidden before a battle:** both sides' sheets, the battleground and the loot are shown.
5. **Found by trying, always the same result:** crafting hides what a plant or a part gives until the player tries it; nothing rolls within a game.
6. **One schema per kind:** items, places, buildings, Ways: the schema is built once, content is configuration.
7. **Choices, not damage:** nothing outside the battle raises Strike, ground or collision damage, and no equipment raises a stat.

---

## 2. Loops

### 2.1 Battle Loop

The hub prepares a closed fight and reads its result (rules: [battle.md](battle.md), [battle_ingame.md](battle_ingame.md)).

1. The node or the depth names its battleground and the enemy team. The battleground is generated; the Artificer lays parts on it in the dungeon and brings the own battleground to the void ([§5.3](#53-the-way)).
2. The player picks the team and what the Way brings ([§6.5](#65-loadout)), seeing the full sheets of both sides.
3. Monsters and slots resolve into finished unit sheets; the fight starts.
4. The battle returns the winner or a draw, the HP left per monster, kills, catches and the pills used up. The hub awards XP and loot.

- **How many fight:** the battleground says how many monsters a side fields; the player fields at most as many as the roster holds ([§4.3](#43-the-roster)).
- The battle reads only finished unit sheets and returns facts, not rewards.

### 2.2 Day Loop

1. The player prepares in the hub: everything there is free.
2. **The deed of the day:** one run through the dungeon or one attack on the void ([vision.md §4](vision.md#4-where-battles-happen)). There are no day AP.
3. **Night:** the lifespan shrinks by one day ([vision.md §3](vision.md#3-the-day-and-the-lifespan)), eggs progress, what spoils in the night spoils.
4. The new day.

- **No clock within a day** and no real-time simulation: the night synchronizes everything once.
- A day may be ended without a deed.

### 2.3 Action Catalog

- **Authority:** the only catalog of what a deed costs. AP in this file never means anything but battle AP.

| Deed | Cost | Needs |
|---|---|---|
| Look at a place, a node, a sheet; plan; order the monsters | free | — |
| A run through the dungeon | the day | — |
| A depth of the void · the breakthrough trial · the Sovereign beast | the day | — |
| Use a tamer skill or a pill in battle | its tamer slot | [§6.5](#65-loadout) |
| Lay Seal Ground | by the Way | [§4.1](#41-obtaining-monsters) |
| Spend stat points · develop a skill slot | free | points or a step |
| Buy a node of the Way | Insight | the tree of the stage is open |
| Brew · forge | materials | the building, the Way |
| Give a pill to a monster outside a battle | the pill | — |

---

## 3. Places

The dungeon and the void, with what each costs and gives: [vision.md §4](vision.md#4-where-battles-happen). The buildings of the hub: [vision.md §6](vision.md#6-the-hub). This file adds nothing to them yet.

---

## 4. Monsters Outside the Battle

[monsters.md](monsters.md) owns individuals, stats and Kins; [skills.md](skills.md) owns skills and their development; this chapter owns how a monster is obtained and what a defeat does.

### 4.1 Obtaining Monsters

Every way yields an **individual** ([monsters.md §1](monsters.md#1-species-and-individual)); what is rolled is rolled when the individual is created, never in battle.

| Way | How |
|---|---|
| **The first egg** | one of three from the nest ([vision.md §5](vision.md#5-the-start)) |
| **Seal (in battle)** | Seal Ground lies in a battle of the dungeon; a wild monster that ends its turn on it with few HP, or falls to 0 HP on it, is caught ([battle_ingame.md §7](battle_ingame.md#7-catching)) |
| **Eggs** | hatched in the Nest. An egg fixes the species; the player spends its stat points and chooses its four skills from the learnable list ([monsters.md §1](monsters.md#1-species-and-individual)). This holds for every egg, the first one too. Where further eggs come from is not defined |

- **Void monsters** are never caught: a void egg is the trophy of a passed breakthrough trial ([monsters.md §3](monsters.md#3-kins)). Which trials give one is not defined.
- **Every Way brings Seal Ground by its own means,** from the start of a game: the Artificer lays it as a part before the battle, the Formation has the Seal tamer skill, the Alchemist brews a pill that turns a square into it and is used up ([§5.3](#53-the-way)). What limits a seal and its chance: [battle_ingame.md §7](battle_ingame.md#7-catching). What the part and the pill cost is not defined.
- Breeding is not defined.

### 4.2 Defeat

- **A monster of the player never dies:** its contract holds it. At 0 HP it is defeated for that battle.
- **No injury:** in a dungeon HP stay from battle to battle and are full again after the run; a battle in the void starts at full HP ([vision.md §4](vision.md#4-where-battles-happen)). A defeated monster misses no day.
- **Death:** only wild monsters die ([battle_ingame.md §7](battle_ingame.md#7-catching)).
- A lost battle in the void costs the day. What a lost run costs: [vision.md §4](vision.md#4-where-battles-happen).

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

| Stage | Tamer slots |
|---|---|
| Qi Gathering | 1 |
| Foundation | 2 |
| Core Formation | 3 |
| Nascent Soul | 3 |
| Immortal | 4 |

- **Each stage opens** a dungeon, the depths of the void, the tree of the Way and a longer lifespan ([vision.md §3](vision.md#3-the-day-and-the-lifespan), [§4](vision.md#4-where-battles-happen)).
- **The tamer has no XP and no sub-tiers:** the stage rises by the breakthrough trial alone. Monsters use the same stage names with three sub-tiers each ([monsters.md §5](monsters.md#5-growth)).
- **Ceiling:** a monster never exceeds the tamer's stage.
- **No stage opens a team size** ([§2.1](#21-battle-loop)).
- **Beyond Immortal** stands the Sovereign beast; defeating it wins the game, and nobody reaches a stage after it.

### 5.2 The Breakthrough Trial

- **The last depth of the void of a stage** ([vision.md §4](vision.md#4-where-battles-happen)). It asks for no material.
- **Forced at the end of the lifespan;** losing that one loses the game ([vision.md §3](vision.md#3-the-day-and-the-lifespan)). The forced trial skips the depths not won yet, and with them their Insight.
- What a trial lost earlier costs, the opponents of the trials and how a monster breaks through to its next stage are not defined.

### 5.3 The Way

The outline: [vision.md §2](vision.md#2-the-pillars-and-the-ways) and [§8](vision.md#8-growth). *Names, branches and numbers are working values.*

- **One Way per game,** chosen at the start. **It shuts the other two out:** their buildings, their materials and what they make do not exist in that game.

| Way | Has | Has not | Branches *(draft)* |
|---|---|---|---|
| **Artificer** (board) | the forge and the workshop: parts of a battleground. In the dungeon parts are laid on the generated board before each battle; in the void the battle is fought on the own battleground | tamer skills, pills | **foundry** (more parts carried into the dungeon) · **domain** (a larger budget for the own battleground) |
| **Formation** (tamer) | tamer skills in the tamer slots ([§5.4](#54-tamer-skills)) | a battleground of its own, pills | **hazard** (ground and traps that harm) · **command** (the own monsters: places, order, a second breath) |
| **Alchemist** (monsters) | the cauldron: pills for the monsters and pills in the tamer slots ([§6.2](#62-alchemy-and-pills)) | tamer skills, a battleground of its own | **body** (monster XP, stat points, reshape, healing) · **kit** (another skill in a slot, a further development step) |

- **Before and during:** the Artificer acts on the squares before the battle, and what is laid stays; the Formation acts on them during the battle, once and for a short time.
- **Parts in the dungeon:** the Artificer lays owned parts before each battle, as many as they carry: **2 and 1 more per stage** *(working value)*, more by the foundry. A part is not used up. **A part may lie on any square;** no rule keeps a way open, to start with.
- **A tree per stage;** a breakthrough opens the next one. The trees of earlier stages stay open. A tree has two branches, and the Insight of a stage buy about one of them.
- **Insight** comes from the depths of the void, one per depth won; the Formation also gains it in the dungeon.
- **A node** *(draft)*: for the Formation a tamer skill or a development step for one. For the Artificer one more part carried into the dungeon (foundry) or 3 more budget for the own battleground (domain). For the Alchemist, body: **Rich Brew** (a brew gives one pill more) and **Deep Pouch** (one more tamer slot for pills); kit: **Keen Nose** (one hidden property shows on every plant owned) and **Steady Hand** (plants that share nothing are not lost).
- **Insight in the dungeon:** the last battle of a run won gives the Formation 1 Insight *(working value)*.
- **Vows:** at the start of a game and after every breakthrough three vows are drawn; the player takes one or none, and at most three in a game. A vow is a strong benefit with a lasting restriction and holds for the rest of the game. It may shut out a Kin: the player binds no monster of that Kin again, and those in the roster stay. A vow of one Way is offered in that Way alone.

| Vow *(draft)* | Way | Gain | Price |
|---|---|---|---|
| Vow of the Fang · Feather · Scale · Hive · Veil · Stone · Root | all | the monsters of that Kin take two of the choices at every stage breakthrough | no monster of one other Kin is bound again |
| One Kin | all | every battle gives the monsters half again as much XP | a team is of one Kin only |
| Vow of the Loner | all | every monster has one more slot | one place less in every team, at least one |
| Vow without Seal | all | the last battle of a run won leaves an egg | no Seal Ground, no catching |
| Vow of the Short Life | all | the last battle of a run gives the reward of the Way twice | every lifespan is 2 years shorter |
| Vow of the Ascetic | all | the monsters regain 1 HP after every battle won in the dungeon | rest nodes heal nothing |
| Call of the Void | all | every trial leaves two void eggs | no egg from the dungeon |
| Vow of the Still Ground | Artificer | 4 more budget for the own battleground | no zone as a part |
| Vow of the Open Sky | Artificer | a Dragon Vein counts 1 toward the budget | no prop as a part |
| Vow of the Open Hand | Formation | one more tamer slot | every lifespan is 1 year shorter |
| Vow of the Bitter Cup | Alchemist | a brew gives one pill more | every pill is Bitter |

- **Eggs from the dungeon:** the last battle of a run won may leave an egg, by chance *(working value)*.

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

- A monster gains development steps as a choice at a stage breakthrough and at late advancement steps ([monsters.md §5](monsters.md#5-growth)); the Alchemist brews a further one ([§6.2](#62-alchemy-and-pills)).
- **A slot is developed, not a skill:** the slot keeps its level when it takes another skill, and the options are chosen anew from that skill.
- A skill is replaced with a **relearning pill** of the Alchemist, outside a battle.
- Where the choice is made is free: anywhere outside a battle.

---

## 6. Goods

### 6.1 Materials

```
MATERIAL = form; no tier, no grade
FORMS    plant · beast part (by Kin)
```

How many of each form there are and what each sets: [vision.md §7](vision.md#7-making-things).

| Form | Comes from | For |
|---|---|---|
| Plant | the dungeon | the Alchemist |
| Beast part | every wild monster defeated in the dungeon; the part of the Void Kin: the void | the Artificer |

- **A game holds the material of its Way alone;** the Formation gains Insight in the dungeon instead ([§5.3](#53-the-way)). How much a run gives is not defined.
- **One kind per plant and per part:** the stage of a dungeon changes how much and which plants it holds, never the material itself.
- **Properties are drawn for the game:** which plant has which properties and what a part gives is drawn when a game starts and stays fixed within it.
- Nothing is grown, bought or sold, and there is no currency.

### 6.2 Alchemy and Pills

*The Way of the Alchemist.*

- **Every plant has three or four properties** of the list below, and exactly one flaw besides.
- **A flaw is a property with a bad effect** and follows the same rule: a pill whose plants share a flaw has it. Two flaws *(working values)*: **Volatile** (the pill spoils in the night after it was brewed) and **Bitter** (the monster that takes it loses 1 HP, never its last: in a battle at once, outside a battle for its next one).
- **Two or three plants that share a property give a pill with that effect.** A pill with two shared properties has both effects.
- **Known plant by plant:** a property or a flaw shows on a plant once that plant went into a pill that had it. It does not show on a plant that was never brewed with it, even if the player knows the property from another plant.
- The same plants always give the same pill; plants that share nothing give nothing and are lost.

| Property *(draft)* | Pill | Where it acts |
|---|---|---|
| Mending | healing: restores 2 HP | in battle from a tamer slot; between the battles of a dungeon |
| Warding | the next hit on one own monster this round deals nothing | in battle |
| Swiftness | one own monster +1 Pace point until the round ends | in battle |
| Anchoring | one own monster cannot be pushed or pulled until the round ends | in battle |
| Binding | a square becomes Seal Ground ([battle_ingame.md §7](battle_ingame.md#7-catching)) | in battle |
| Growth | monster XP for one monster | outside the battle |
| Tempering | stat points for one monster, few and dear | outside the battle |
| Clarity | relearning: a skill slot takes another skill ([§5.5](#55-development-of-monster-skills)) | outside the battle |
| Insight of the kit | a development step for one skill slot | outside the battle |
| Change | reshape: the stat points are spent anew by another stat shape ([monsters.md §2.3](monsters.md#23-shapes-and-spending)) | outside the battle |

- **A pill in battle** takes a tamer slot, acts once and is used up. It heals, protects, moves or lays Seal Ground; it never raises damage.
- **Stat points from pills are a trial:** whether they may lift a monster above the points of its step ([monsters.md §2.2](monsters.md#22-prices-and-points)), and by how much, is to be found by play. They never lift a stat above its maximum.
- No pill is taken before a battle to act in it. A monster never exceeds the tamer's stage by a pill.

### 6.3 Smithing: Parts of a Battleground

*The Way of the Artificer.*

| Part | Material | Sets |
|---|---|---|
| What | the first beast part | what the piece makes: a ground, a zone or a prop, by the Kin of the part |
| How | the second beast part | how it lies: a shape or a way of laying it, by the Kin of the part |

- **What the parts give is known before forging:** the forge shows every piece that exists, what it does and what it needs; the same parts always give the same piece.
- **No crafting is a minigame.**
- **A forged piece is a part of a battleground** and nothing else: there are no weapons and no armour. It is placed on the own battleground in the workshop and laid on the generated board of a dungeon battle ([§5.3](#53-the-way), [battle_ingame.md §3](battle_ingame.md#3-battlegrounds)), within the budget of the stage.
- **Seal Ground is a part** the Artificer owns from the start ([§4.1](#41-obtaining-monsters)).
- **Drawn for the game:** which Kin gives which "what" and which "how" is drawn when a game starts ([§6.1](#61-materials)) and shown in the forge from the first day. The lists of what and how are not defined.
- What a part costs and what the player can place before the first forged part are not defined.

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
- **Night synchronization:** all resolvers run once when the day ends.
- **Data:** species, items, places, buildings and Ways are data files loaded by one registry pattern; new content is a new file.
- **Individual:** a save record without battle rules: species, shape, stats, unspent points, stage and sub-tier, XP, development per skill slot, current HP.
- **Battle request and result** are the only contract between the two halves ([architecture.md §1](architecture.md#1-two-games-and-what-they-share)): the request holds the battleground with the parts laid on it, both teams as finished unit sheets and the tamer slots; the result holds the winner, HP left, kills, catches and the pills used up.
- The whole game state lives in one save object, written at night. What a finished game leaves for the next one is saved apart from it.
