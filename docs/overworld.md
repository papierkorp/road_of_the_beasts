# The Game Around the Battle

- **This file owns** the rules around the battle: the day, what a deed costs, obtaining monsters, the growth of the tamer, tamer skills, goods and the loadout.
- **Frame:** [vision.md](vision.md) says what the game is and owns the pillars, the lifespan, the three places of battle, the start and the hub; this file says how the rest works. Where the two differ, the frame holds.
- **Elsewhere:** battle rules ([battle.md](battle.md), [battle_ingame.md](battle_ingame.md)), monster skills ([skills.md](skills.md)), monsters and their stats ([monsters.md](monsters.md)).
- **Status:** working draft throughout; every number is a working value and nothing is validated by play.
- There are no fixed monster aspects, no aspect triangle and no attunement; themes imply no affinity, matchup or learning restriction.

---

## 1. Design Rules

1. **Everything serves the battle:** a system changes what stands on the board, or it is not part of the game ([vision.md §1](vision.md#1-the-game-in-one-picture)).
2. **Growth opens kinds of play, not bigger numbers:** a stage opens something new; numbers stay small and hard-capped.
3. **Looking is free, deciding costs:** day AP are spent at places of battle, never on looking, planning or making.
4. **Nothing is hidden before a battle:** both sides' sheets, the battleground and the loot are shown.
5. **Found by trying, always the same result:** crafting hides what a plant or a part gives until the player tries it; nothing rolls within a game.
6. **One schema per kind:** items, places, buildings, Ways: the schema is built once, content is configuration.
7. **Choices, not damage:** nothing outside the battle raises Strike, ground or collision damage, and no equipment raises a stat.

---

## 2. Loops

### 2.1 Battle Loop

The hub prepares a closed fight and reads its result (rules: [battle.md](battle.md), [battle_ingame.md](battle_ingame.md)).

1. The encounter, the node or the depth names its battleground and the enemy team; in the void the battleground is the player's own.
2. The player picks the team and fills the **tamer slots** ([§6.5](#65-loadout)), seeing the full sheets of both sides.
3. Monsters and slots resolve into finished unit sheets; the fight starts.
4. The battle returns the winner or a draw, the HP left per monster, kills, catches and the pills used up. The hub awards XP and loot.

- **How many fight:** the battleground says how many monsters a side fields; the player fields at most as many as the roster holds ([§4.3](#43-the-roster)).
- The battle reads only finished unit sheets and returns facts, not rewards.

### 2.2 Day Loop

1. The day starts with the day AP of the stage ([§2.3](#23-action-catalog)).
2. The player spends them at the places of battle ([vision.md §4](vision.md#4-where-battles-happen)), in any order; everything in the hub is free of day AP.
3. The day ends by hand or when the day AP run out.
4. **Night:** the lifespan shrinks by one day ([vision.md §3](vision.md#3-the-day-and-the-lifespan)), the encounters of the wild area are drawn anew, eggs progress, rare encounters move one day on.
5. The new day.

- **No clock within a day** and no real-time simulation: the night synchronizes everything once.

### 2.3 Action Catalog

- **Authority:** the only catalog of what a deed costs. AP here means **day AP**, never battle AP.
- **Day AP per stage:** not defined.

| Deed | Cost | Needs |
|---|---|---|
| Look at a place, an encounter, a sheet; plan; order the monsters | free | — |
| A battle in a wild area | 1 AP | an encounter of today |
| A run through a dungeon | a fixed number of AP; not defined | — |
| Harvest a dungeon | fewer than a run; not defined | its challenge met |
| A depth of the void · the breakthrough trial | not defined | — |
| Use a tamer skill, a weapon or a pill in battle | its tamer slot | [§6.5](#65-loadout) |
| Lay Seal Ground | the tamer slot of the Seal skill | [§4.1](#41-obtaining-monsters) |
| Spend stat points · develop a skill slot | free | points or a step |
| Buy a node of the Way | Insight | the tree of the stage is open |
| Brew · forge | materials | the building |
| Take a pill outside a battle | the pill | — |
| End the day | free | — |

---

## 3. Places

The wild area, the dungeon and the void, with what each costs and gives: [vision.md §4](vision.md#4-where-battles-happen). The buildings of the hub: [vision.md §6](vision.md#6-the-hub). This file adds nothing to them yet.

---

## 4. Monsters Outside the Battle

[monsters.md](monsters.md) owns individuals, stats, Kins and bloodline; [skills.md](skills.md) owns skills and their development; this chapter owns how a monster is obtained and what a defeat does.

### 4.1 Obtaining Monsters

Every way yields an **individual** ([monsters.md §1](monsters.md#1-species-and-individual)); what is rolled is rolled when the individual is created, never in battle.

| Way | How |
|---|---|
| **The first egg** | one of three from the nest ([vision.md §5](vision.md#5-the-start)) |
| **Seal (in battle)** | the tamer lays Seal Ground in a wild area; a wild monster that ends its turn on it with few HP, or falls to 0 HP on it, is caught ([battle_ingame.md §7](battle_ingame.md#7-catching)) |
| **Eggs** | hatched in the Nest. An egg fixes species and bloodline; the player spends its stat points and chooses its four skills from the learnable list ([monsters.md §1](monsters.md#1-species-and-individual)). This holds for every egg, the first one too. Where further eggs come from is not defined |

- **Void monsters** are never caught: a void egg is the trophy of a passed breakthrough trial ([monsters.md §3](monsters.md#3-kins)). Which trials give one is not defined.
- **Seal Ground comes from the Seal tamer skill alone,** from the start; it costs nothing per battle but a tamer slot ([§5.4](#54-tamer-skills)). What limits a seal and its chance: [battle_ingame.md §7](battle_ingame.md#7-catching).
- Breeding is not defined.

### 4.2 Defeat

- **A monster of the player never dies:** its contract holds it. At 0 HP it is defeated for that battle.
- **No injury:** a battle in a wild area starts at full HP; in a dungeon HP stay from battle to battle and are full again after the run ([vision.md §4](vision.md#4-where-battles-happen)). A defeated monster misses no day.
- **Death:** only wild monsters die ([battle_ingame.md §7](battle_ingame.md#7-catching)).
- What a lost battle costs in a wild area and in the void is not defined.

### 4.3 The Roster

- **Roster:** every monster the player owns.
- **Team:** the monsters of the roster that the player sends into the next battle.
- How many the roster holds is not defined.

---

## 5. Progression

### 5.1 Stages

```
STAGES      Qi Gathering → Foundation → Core Formation → Nascent Soul → Immortal → Sovereign
```

| Stage | Tamer slots |
|---|---|
| Qi Gathering | 1 |
| Foundation | 2 |
| Core Formation | 3 |
| Nascent Soul | 3 |
| Immortal | 4 |
| Sovereign | 4 |

- **Each stage opens** a zone of the wild area, a dungeon, the depths of the void, the tree of the Way and a longer lifespan ([vision.md §3](vision.md#3-the-day-and-the-lifespan), [§4](vision.md#4-where-battles-happen)).
- **The tamer has no XP and no sub-tiers:** the stage rises by the breakthrough trial alone. Monsters use the same stage names with three sub-tiers each ([monsters.md §5](monsters.md#5-growth)).
- **Ceiling:** a monster never exceeds the tamer's stage.
- **No stage opens a team size** ([§2.1](#21-battle-loop)).

### 5.2 The Breakthrough Trial

- **The last depth of the void of a stage** ([vision.md §4](vision.md#4-where-battles-happen)): a battle on the player's own battleground. It asks for no material.
- **Forced at the end of the lifespan;** losing that one loses the game ([vision.md §3](vision.md#3-the-day-and-the-lifespan)). The forced trial skips the depths not won yet, and with them their Insight.
- What a trial lost earlier costs, the opponents of the five trials and how a monster breaks through to its next stage are not defined.

### 5.3 The Way

The outline: [vision.md §8](vision.md#8-growth).

- **One system per game,** chosen at the start.
- **A tree per stage;** a breakthrough opens the next one. The trees of earlier stages stay open.
- **Insight** comes from the depths of the void, one per depth won, and from nowhere else.
- **A node** is one of: a tamer skill ([§5.4](#54-tamer-skills)), a development step for a tamer skill the player has.
- **Branches exclude each other:** a tree has two branches, and the Insight of a stage buy about one of them. The Way of the Beast Lord: a pack (fight wide) and a champion (carry one monster). The Way of the Formation: hazard (ground and traps that harm) and bulwark (walls, props and Dragon Veins that take room). The Way of the Artificer: blade (the weapons of the forge) and cauldron (pills taken in the battle); its tamer skills work with what the tamer carries and do nothing by themselves. Each system carries one pillar: the monsters, the board, the tamer.
- **Vows:** at the start of a game and after every breakthrough three vows are drawn; the player takes one or none, and at most three in a game. A vow is a strong benefit with a lasting restriction and holds for the rest of the game. It may shut out a Kin: the player binds no monster of that Kin again, and those in the roster stay. A benefit for the monsters "owned" means the roster at the moment of the vow.
- The systems, their trees, the price of a node, the vows and what tells one system from another are not defined.

### 5.4 Tamer Skills

Tamer skills are **learned for good** and then brought into a battle in a tamer slot ([§6.5](#65-loadout)); what they do in battle: [battle_ingame.md §5](battle_ingame.md#5-tamer-skills) and [§7](battle_ingame.md#7-catching).

- **Separate source:** tamer skills act on the same squares, grounds and zones as monster skills but are no skill cards. What a tamer may do gives no monster the right to do it.
- **Domain Glimpse:** removes zones and resets ground to Plain on the squares of a tetromino the tamer places anywhere on the board, in any rotation or reflection, wholly on the board. Voidscar and Dragon Veins stay; props and monsters are unaffected.

| Skill | Tree of the stage *(draft)* | Effect |
|---|---|---|
| Seal | from the start, in every system | lays Seal Ground ([battle_ingame.md §7](battle_ingame.md#7-catching)) |
| Qi Suppression | Foundation | an enemy monster −1 Pace point next round |
| Spirit Shield | Foundation | not defined |
| Swap Places | Foundation | two own monsters trade squares |
| Domain Glimpse | Core Formation | clear a tetromino of zones and reset its ground |
| Urgent Order | Core Formation | an own monster that has not acted this round acts next |
| Second Wind | Core Formation | an own monster regains 1 HP |
| Life Thread | Core Formation | the next time an own monster would fall it stays at 1 HP |
| Beast Swap | Nascent Soul | exchange an active monster with one of the roster that is not in the battle |
| Whetstone | Qi Gathering, Way of the Artificer | every weapon used in this battle may be used once more |
| Shared Dose | Qi Gathering, Way of the Artificer | the next pill also acts on the own monsters next to the one that takes it |
| Long Reach | Foundation, Way of the Artificer | the next weapon lays 1 square more |
| Second Dose | Foundation, Way of the Artificer | every pill taken in this battle acts once more |

- **Learning:** a tamer skill is a node of the Way. Which system offers which skill is not defined; Immortal and Sovereign list none yet.
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
| Deep Seal | Condition | a seal one tier below the target suffices |

### 5.5 Development of Monster Skills

[skills.md §8](skills.md#8-development) alone defines the development of skills, for monsters and tamers alike.

- A monster gains development steps as a choice at a stage breakthrough and at late advancement steps ([monsters.md §5](monsters.md#5-growth)); they are never bought.
- A skill is replaced with a **relearning pill**, outside a battle; the slot keeps its level.
- Where the choice is made is free: anywhere outside a battle.

---

## 6. Goods

### 6.1 Materials

```
MATERIAL = form × tier (a stage); no grade
FORMS    plant · beast part (by Kin)
```

How many of each form there are and what each sets: [vision.md §7](vision.md#7-making-things).

| Form | Comes from |
|---|---|
| Plant | dungeons: a run or a harvest |
| Beast part | every wild monster defeated, in a dungeon and in a wild area; the part of the Void Kin: the void |

- **Properties are drawn for the game:** which plant has which properties and what a part gives is drawn when a game starts and stays fixed within it.
- Nothing is grown, bought or sold. Whether a currency exists is not defined.

### 6.2 Alchemy and Pills

- **Every plant has three or four properties** of the list below, and exactly one flaw besides.
- **A flaw is a property with a bad effect** and follows the same rule: a pill whose plants share a flaw has it. Two flaws *(working values)*: **Volatile** (the pill spoils in the night after it was brewed) and **Bitter** (the monster that takes it loses 1 HP, never its last: in a battle at once, outside a battle for its next one).
- **Two or three plants that share a property give a pill with that effect;** the lowest tier among them is the pill's tier.
- **A property is unknown until the player has made a pill with it.** The same plants always give the same pill; plants that share nothing give nothing and are lost.
- A pill with two shared properties has both effects.

| Property *(draft)* | Pill | Where it acts |
|---|---|---|
| Mending | healing: restores 2 HP | in battle from a tamer slot; between the battles of a dungeon |
| Warding | the next hit on one own monster this round deals nothing | in battle |
| Swiftness | one own monster +1 Pace point until the round ends | in battle |
| Anchoring | one own monster cannot be pushed or pulled until the round ends | in battle |
| Clarity | relearning: a skill slot takes another skill ([§5.5](#55-development-of-monster-skills)) | outside the battle |
| Change | reshape: the stat points are spent anew by another stat shape ([monsters.md §2.3](monsters.md#23-shapes-and-spending)) | outside the battle |
| Bloodline | bloodline ascension ([monsters.md §4](monsters.md#4-bloodline)) | outside the battle |
| Kindling | catch-up: a monster rises by one step of growth, only while it stands below the highest monster of the roster ([monsters.md §5](monsters.md#5-growth)) | outside the battle |

- **A pill in battle** takes a tamer slot, acts once and is used up. It heals, protects or moves; it never raises damage.
- **No pill adds stat points,** and none is taken before a battle to act in it.
- No pill gives monster XP except the catch-up of Kindling. Whether a pill eases a trial is not defined.

### 6.3 Smithing: Weapons and Parts of a Battleground

| Part | Material | Sets |
|---|---|---|
| What | the first beast part | what the piece makes: a ground, a zone, a prop or an effect, by the Kin of the part |
| How | the second beast part | how it acts: a shape or a way of laying it, by the Kin of the part |

- **What the parts give is known before forging:** the forge shows every piece that exists, what it does and what it needs; the same parts always give the same piece. The choice is which piece to make for which battleground.
- **No crafting is a minigame.**

| Piece | Worn by | Gives | Slots |
|---|---|---|---|
| **Weapon** | the tamer | a skill of its own, used once per battle from a tamer slot | 1 |
| **Part of a battleground** | the own battleground | a ground, a zone or a prop the player places in the workshop ([battle_ingame.md §3](battle_ingame.md#3-battlegrounds)) | within the budget |

- **A weapon's skill** is fixed by its parts and does not develop.
- **A weapon is a tamer skill paid with materials** instead of Insight ([§5.4](#54-tamer-skills)). There is no armour.
- **One pair, two forms:** the same two parts give a weapon or a part of a battleground; the player chooses the form at the forge. A weapon lays its piece once per battle from a tamer slot; a part lies on the own battleground from the start. Every "what" is therefore something that lies on the board (a ground, a zone or a prop); effects on monsters stay tamer skills of the Way. No mineral is needed.
- **Drawn for the game:** which Kin gives which "what" and which "how" is drawn when a game starts ([§6.1](#61-materials)) and shown in the forge from the first day. The lists of what and how are not defined.
- What a part costs and what the player can place before the first forged part are not defined.

### 6.4 Item Schema

```
ITEM
 kind:   Material | Pill | Weapon | Egg | Battleground part
 tier:   a cultivation stage
 effect: none (materials) | on use (pills) | while carried (weapon)
         | hatches (eggs) | placed (battleground parts)
```

### 6.5 Loadout

- **The player carries the inventory;** a monster owns nothing. Goods have no weight.
- **Tamer slots:** before a battle the player fills each slot with one learned tamer skill, one weapon or one pill. The tamer carries one weapon at most. Each acts once in that battle; a pill is used up, a skill and a weapon are not.
- **How many:** [§5.1](#51-stages).
- A wild monster and a void monster have no tamer and no slots.

### 6.6 Hard Caps

- No pill, weapon or node of a Way raises Strike, ground or collision damage ([battle.md §6.1](battle.md#61-damage)).
- No equipment raises a stat.
- A tamer skill, a weapon and a pill act once per battle each.
- Everything brought into a battle is visible in the preview.

---

## 7. Technical Notes

- **Presentation:** a hub screen of buildings and the battle's own view of the board; landscape, for touch and for mouse.
- **Night synchronization:** all resolvers run once when the day ends.
- **Data:** species, items, places, buildings and Ways are data files loaded by one registry pattern; new content is a new file.
- **Individual:** a save record without battle rules: species, shape, stats, unspent points, bloodline, stage and sub-tier, XP, development per skill slot, current HP.
- **Battle request and result** are the only contract between the two halves ([architecture.md §1](architecture.md#1-two-games-and-what-they-share)): the request holds the battleground, both teams as finished unit sheets and the tamer slots; the result holds the winner, HP left, kills, catches and the pills used up.
- The whole game state lives in one save object, written at night. What a finished game leaves for the next one is saved apart from it.
