# Vision: the Frame of the Game

- **This file owns** the frame of the game (the hub and the ingame battle), not the multiplayer battle. Read it first.
- **Elsewhere:** the rules ([battle.md](battle.md), [battle_ingame.md](battle_ingame.md), [skills.md](skills.md), [monsters.md](monsters.md), [overworld.md](overworld.md)). Where a rule file contradicts this frame, the frame holds.
- **Status marks:** *set* = stated or decided by the user; *draft* = a proposal that waits for a decision (task [T50](todo/to-clarify/overworld/T50-set-the-frame-of-the-game.md)).

---

## 1. The Game in One Picture

*Status: set.*

```mermaid
flowchart LR
    Hub["The hub<br/>buildings, decide for day AP"] --> Battle["Battle<br/>wild area, dungeon, void"]
    Battle --> Res["Resources"]
    Res --> Pillars["Monster · Tamer · Board"]
    Pillars --> Battle
    Hub --> Night["The night<br/>resolves, the lifespan shrinks"]
    Night --> Hub
    Pillars --> End["Sovereign"]
```

- **The turn-based battle is the game.** Everything around it exists to change the battle or to improve it.
- **The test for every system:** it changes what stands on the board, or it is not part of the game.
- **Offline and single player.** A multiplayer part for battles alone may follow much later, or never.
- **Playable on a phone,** in landscape, and on a PC alike.
- **No 3D world:** the player does not walk anywhere. The hub is a screen of buildings, each a theme with its actions.
- **Genre:** xuanhuan first, with wuxia and xianxia: more fantasy than history.

## 2. The Pillars

*Status: the three pillars are set; the split of the monster pillar, the resources and their sources are working values to be tried.*

A battle is made of three things, and every resource of the game feeds one of them:

| Pillar | What it changes in the battle | Resources | Sources |
|---|---|---|---|
| **Monster: roster** | which monsters fight: species, kin, rarity, stat shape | monsters, eggs | catching in a wild area, hatching |
| **Monster: growth** | the stat points of a monster, capped by the tamer's stage | monster XP | the battles a monster fought |
| **Monster: kit** | its skills and passives, their development, open slots, its armour | monster XP, crafting materials | the battles a monster fought, the forge, the cauldron |
| **Tamer** | the stage, the tamer slots and what fills them: a tamer skill, a weapon, pills | path points, breakthrough materials, crafting materials | the void, dungeons, the cauldron, the forge |
| **Board** | the battleground of one's own, on which every battle in the void is fought | path points (blueprints), crafting materials | the void, dungeons, wild areas |

**Four kinds of resource:** monster XP, path points, breakthrough materials, crafting materials (plants, ore, beast parts, essences; [§7](#7-making-things)).

## 3. The Day and the Lifespan

*Status: set. Numbers are not defined.*

- **A day is one turn:** the player spends day AP in the hub, the night resolves everything at once.
- **The lifespan:** the tamer has a number of days to live. Each stage has its lifespan, and only a breakthrough lengthens it. The days left are always shown.
- **A day of play is a year of the tamer's life:** the game shows years ("year 3", "5 years left"); the rules keep the word day for the unit and day AP for what it gives.
- **The trial comes at the end:** the breakthrough trial is the last depth of the void ([§4](#4-where-battles-happen)); the player may take it on any day before. When the lifespan ends, the trial must be taken, ready or not; who loses that one has lost the game. A game is lost on the board, never to a counter.
- **What this asks of the player:** day AP go to the monsters or to the tamer. Who tends only the monsters runs out of time; who tends only the tamer meets the trial with a weak team.
- **The end:** Sovereign is the last stage, and reaching it wins the game.
- **A game is short and the next one differs:** a lost game starts anew from the nest. Its length is meant to be about ten hours *(working value)*.
- **What a game leaves behind is breadth, never strength:** more to choose from in the next game, nothing that makes it easier: further cultivation systems and further eggs.

## 4. Where Battles Happen

*Status: the places, the wild area, the dungeon and the void are set; what each place feeds is a working value to be tried. Numbers and lists are not defined.*

| Place | What it is | Cost | Feeds | What it gives |
|---|---|---|---|---|
| **Wild area** | wild monsters on battlegrounds; the place to catch on Seal Ground ([battle_ingame.md §7](battle_ingame.md#7-catching)) | day AP per battle | the monsters | monster XP, caught monsters, beast parts |
| **Dungeon** | a run through a row of battles in the manner of a roguelike | all day AP left, with a least number | the tamer and the kits | breakthrough materials, plants, ore, essences |
| **Void** | a ladder of battles against void monsters, fought on the player's own battleground; its last depth is the breakthrough trial | not defined | the tamer and the board | a path point per depth ([§8](#8-growth)); from the trial the stage, and with it lifespan |

- **Day AP go to places of battle.** Where the player spends them decides which pillar grows; the tamer does not cultivate in the hub.
- **The hub only transforms:** brewing, forging and building cost materials and no day AP.
- **Every battle is a new problem.** The battle is deterministic, so one board has one answer: few battles a day, each on a board of its own.
- **What is mastered need not be played again:** a dungeon whose challenge the player has met can be harvested without a battle (below).
- **Every board is a battleground** with its team size, its ends and its board events ([battle_ingame.md](battle_ingame.md)).

**The wild area:**

- **A list of today's encounters,** not a map. Each shows its battleground, its monsters, which of them can be caught, and its loot.
- **One battle costs 1 day AP** *(working value)*; every battle starts at full HP.
- **Every night the encounters are drawn anew** from the fixed list of the zone. An encounter that was won, or whose monster was caught, is gone.
- **Rare encounters** are announced ahead and stay for a few days only.
- **Nothing is taken without a battle:** plants and ore are loot too.
- **One zone per stage:** each stage opens a new zone with species of its own.

**The dungeon:**

- **A map of nodes with forks,** generated anew for every run with its battlegrounds and opponents; four to six battles lead to its end *(working value)*.
- **Nearly every node is a battle.** At a fork the player sees what each way holds: the battleground, the opponents and the loot.
- **HP stay** from battle to battle. Only pills and a few rest nodes heal.
- **Leaving** is possible after every battle, with everything gathered so far.
- **A defeat** ends the run and costs a part of the loot. It does not end the game, and no monster is injured by it.
- **The last battle** holds the best loot, such as breakthrough materials.
- **One dungeon per stage:** each stage opens a new one, harder and with better materials.
- **The challenge:** every dungeon names one, such as three runs won in a row or a battle won within a number of rounds. Once it is met, the dungeon can be **harvested** without a battle, for fewer day AP than a run.
- **A harvest gives less:** a fixed base yield, safe. A run that is played gives more and can fail. Breakthrough materials and monster XP never come from a harvest.

**The void:**

- **The void has no ground, so the player brings it:** every battle there is fought on a battleground the player built. Everywhere else the board belongs to the place.
- **The board is the answer:** the opponent is shown ahead, and the player builds or changes the battleground before the battle.
- **Void monsters are stronger** than anything else of the stage; the home board is what lets the player meet them.
- **A few depths per stage,** three to five *(working value)*, each won once. The last depth is the breakthrough trial.
- **Every depth won gives a path point** ([§8](#8-growth)). The depths before the trial also show how far the team and the board are from it.
- **Building a battleground:** its parts need a blueprint from the cultivation system and crafting materials. Limits: a budget per stage; the start area of the opponent stays reachable. Details are not defined.

## 5. The Start

*Status: set.*

- The player is an orphan and finds a nest with three eggs. The three are drawn anew for every game from a pool of species, each of another Kin and none of the void; every finished game adds species to the pool. The player chooses one; the first monster hatches from it. Every further monster is caught or hatched.
- **The player chooses a cultivation system** from a selection ([§8](#8-growth)).

## 6. The Hub

*Status: draft.*

One screen with buildings; a tap opens a building and its actions. Which buildings exist follows from the sources of [§2](#2-the-pillars):

| Building | Pillar | What the player does there |
|---|---|---|
| Monsters | Monster | in one place: hatch and shape eggs, see and order the roster; spend stat points; teach and develop skills, take the choice of a stage breakthrough |
| Gates | all | in one place, everything that costs day AP: enter a wild area, start a dungeon, enter a depth of the void and take the breakthrough trial |
| Cauldron | Tamer | make pills |
| Forge | Tamer, Monster: kit | make weapons and armour |
| Cultivation hall | Tamer, Board | spend path points in the tree of the cultivation system |
| Inventory | — | see everything the player owns |
| Battleground workshop | Board | build and shape the battlegrounds for the void |

What the hub is in the world of the game is not defined.

## 7. Making Things

*Status: set; the numbers of materials are working values. Lists of plants, properties, pills, weapons and armour are not defined.*

```mermaid
flowchart LR
    Plants["Plants<br/>3-4 properties each"] --> Cauldron["Cauldron<br/>2-3 plants sharing a property"] --> Pill["Pill<br/>with that effect"]
    Ore["Ore and beast parts"] --> Forge["Forge"]
    Forge --> Weapon["Weapon, for the tamer<br/>carries a skill"]
    Forge --> Armour["Armour, for a monster<br/>carries a passive"]
    Pill --> Slots["Tamer slots<br/>once per battle each"]
    Weapon --> Slots
    Skill["Tamer skill"] --> Slots
```

- **Materials come from battles and harvests:** plants, ore and essences from dungeons, beast parts from wild areas.
- **A material has a tier (a stage) and no grade.**

| Material | Number *(working value)* | Sets |
|---|---|---|
| Plants | 4 from the start, 1 more per stage | the effect of a pill |
| Ore | 1 per stage | the tier of a piece |
| Essence | 1 per stage | the temper of a piece |
| Beast part | 1 per kin | the core of a piece |
| Breakthrough material | 1 per stage, only from the last battle of its dungeon | admits to the trial |

- **Properties differ from game to game:** which plant has which properties, and what a part gives, is drawn anew for every game and stays fixed within it.
- **Alchemy:** every plant has three or four properties. Two or three plants that share a property give a pill with that effect; the plants set its tier. A property is unknown until the player finds it by trying. The same plants always give the same pill.
- **Smithing:** the tamer carries a weapon, which brings a skill of its own. Every monster wears armour, which gives one more passive. No equipment raises a stat, and none raises damage.
- **A piece has three parts:** a body of ore (the tier), a core from a part of a monster (which skill or passive, by the kind of monster), a temper from an essence (one variation). What a part gives is found by trying; the same parts always give the same piece. No crafting is a minigame.
- **One rule for what the tamer brings:** a tamer skill, a weapon and a pill each take a tamer slot and act once per battle. Stages add slots ([§8](#8-growth)).
- **Pills in battle** heal, protect or move; they never raise damage. A pill is used up; a skill and a weapon are not. Other pills heal between battles or reshape a monster: another skill in a slot, the stat points spent anew, a higher rarity. No pill adds stat points.

## 8. Growth

*Status: the stages, the tamer slots and the cultivation system are set in outline; its systems, trees and numbers are not defined.*

Qi Gathering → Foundation → Core Formation → Soul Tier → Immortal → Sovereign.

| What grows | How | Limit |
|---|---|---|
| **The tamer's stage** | breakthrough materials and the breakthrough trial | the lifespan |
| **The cultivation system** | path points from the depths of the void | the tamer's stage |
| **A monster** | stat points, development of its skills, rarity, its armour | the tamer's stage |
| **The roster** | catching and hatching | not defined |
| **The battlegrounds** | blueprints from the cultivation system, built from materials | a budget per stage |

- **No stage opens a team size.** The battleground says how many monsters may fight.
- **Tamer slots come from the stage:** 1 at Qi Gathering, 2 at Foundation, 3 at Core Formation, 4 at Immortal.

**The cultivation system:**

- **Chosen at the start** from a selection and kept for the whole game. Systems differ in what they offer, tamer skills among it.
- **A small tree per stage.** A breakthrough opens the tree of the new stage.
- **Path points buy its nodes:** tamer skills, their development steps and blueprints for the battleground. There are no scrolls.
