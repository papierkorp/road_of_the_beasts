# Ingame Battle

The battle inside the game: grown monsters on the battlegrounds of its places. It plays the core rules of [battle.md](battle.md) and adds its own.

- **This file owns** every rule only the ingame battle has. The core and what only the multiplayer battle has stand in [battle.md](battle.md).
- **Status:** the frame of §1, §2, §4, §5 and §7 are decided as written; the numbers of §7 are working values. Everything else is not defined.

## 1. The Two Battles

Both battles share the goals of [battle.md §1](battle.md#1-goals-and-pillars): deterministic, simple to learn and hard to master, decisions that shape the board, won by tactics and skill variety, monsters that differ, square control as the basic aim.

| | Multiplayer battle | Ingame battle |
|---|---|---|
| Character | a fair match | **a tactics puzzle; it may be unfair** |
| Monsters and skills | none fixed: generated or drafted, the same points for every monster ([monsters.md §2.2](monsters.md#22-prices-and-points)) | the fixed monsters, kits and skills of the game ([content.md](content.md)); grown monsters ([monsters.md §5](monsters.md#5-growth)); the sides may differ in strength |
| Team size | always 3v3 | any, also unequal ([§2](#2-team-sizes-and-the-end-of-a-battle)) |
| Board | generated, point-symmetric 7×7 ([battle.md §4.1](battle.md#41-board-generation)) | battlegrounds that differ completely, generated for the battle; the Artificer lays parts on them or builds the own one ([§3](#3-battlegrounds)) |
| End of a battle | every monster of one side at 0 HP | the same; a caught monster counts as defeated ([§7](#7-catching)) |
| Defeats | no monster falls without a turn of its own | no such promise; a wild monster at 0 HP dies, a contracted one never ([§7](#7-catching)) |
| Chance | none | one roll: the catch ([§7](#7-catching)) |
| Length | a mean of 3.5–4.5 rounds | not defined |
| Mechanics | the core | more: tamer skills ([§5](#5-tamer-skills)), catching ([§7](#7-catching)), skills of its own |

**Goal of the ingame battle only:**

- **Room to grow:** every mechanic of the ingame battle carries upgrade paths for the stages of the tamer ([overworld.md §5](overworld.md#5-progression)), because the monsters grow too and a mechanic that does not grow with them falls behind.

- **One core:** flow, timing, the square, damage and displacement are the same in both battles. **Dragon Veins and surrounding are core rules;** a battleground has Dragon Veins where its map puts them, or none.
- **Strictly apart above the core:** a rule, a skill, a board or a number of one battle is no reason for a decision in the other. A measurement names the battle it was made in.
- **In the build:** the main menu leads through “Battle” to “Ingame Prototype” and “Multiplayer”. The prototype is a test battle without the game around it: points per side, which may differ, and a board are chosen there.

## 2. Team Sizes and the End of a Battle

Every team size other than 3v3 is an ingame matter: 1v1, 2v2, 5v5, and unequal sides such as 3v1. **Every board of the game comes from a battleground** ([§3](#3-battlegrounds)): its start areas set how many monsters each side fields, and the player fields at most as many as the roster holds ([overworld.md §4.3](overworld.md#43-the-roster)).

**The end of a battle is the end of the core:** every monster of one side at 0 HP ([battle.md §2.2](battle.md#22-core-loop)); a caught monster counts as defeated ([§7](#7-catching)). A battleground names no other end.

**Brake:** the Dragon Veins of the battleground; one without them has no brake.

## 3. Battlegrounds

- **Every battle has its battleground:** a battle of the wild and a depth of the void name theirs. It is generated, point-mirrored, not written by hand: a square of 5 to 7 squares a side, one to three Dragon Veins on its middle, mirrored pairs of ground and props, zones from Core Formation on; room for 3 against 3, more against a larger wild team *(working values)*.
- **The Artificer changes the board** ([overworld.md §5.3](overworld.md#53-the-way)), no other Way does. **In the wild** they lay parts of their own on the generated battleground before each battle; the parts stay for the battle like ground and props of the board. **In the void** the battle is fought on the battleground they built in the hub, shaped to the own team and to the opponent shown ahead; it may be changed before every battle there.
- **A part drops from the wild:** a ground, a zone or a prop ([overworld.md §6.3](overworld.md#63-parts-of-a-battleground)).
- **Limits:** a budget per stage; the start area of the opponent stays reachable.

**What a battleground is** *(the map editor of the build; sizes are working values):*

| Part | Rule |
|---|---|
| Outline | a rectangle of a chosen width and height, each 3 to 12 squares, from which single squares can be taken out. A missing square counts like the board edge: nothing stands on it, enters it or is laid on it, and a push against it is a collision ([battle.md §6.3](battle.md#63-collision)) |
| Ground | every square has one ground; a Dragon Vein is a ground and lies wherever the map puts it, in any number |
| Props | one prop per square |
| Zones | one zone per square, with the direction a push zone pushes and the number of rounds it lasts; it may last the whole battle. A pull zone pulls toward the middle of all squares of its kind on the map |
| Start areas | one per side, any squares. A side fields as many monsters as its area has free squares at most; the sides may differ in number. The player places their monsters inside their area before the battle |

The own battleground of the Artificer, its budget and what a part weighs: [overworld.md §6.3](overworld.md#63-parts-of-a-battleground). Not defined: where the monsters of the opponent stand inside their area.

## 4. Board Events

The ingame battle has no board events: a battleground acts through its ground, its zones and its props alone, and all of them lie open from the start.

## 5. Tamer Skills

Tamer skills exist in the ingame battle only.

Battle resolves what the tamer brought in the tamer slots deterministically and with previews: a tamer skill (Way of the Formation) or a pill (Way of the Alchemist) per slot, each once per battle ([overworld.md §6.5](overworld.md#65-loadout)). Wild monsters and void monsters have no tamer. Definitions and access: [overworld.md §5.4](overworld.md#54-tamer-skills); the pills: [overworld.md §6.2](overworld.md#62-pills).

- **Window:** what a tamer slot holds (once per battle) may be used during the turn of one of the tamer's own monsters, never inside a payload resolution or during an enemy turn. It costs no AP and no turn.
- **Swap Places:** two own monsters trade squares; no range. Each counts as leaving its square and entering the new one.
- **Urgent Order:** an own monster that has not acted this round is inserted directly after the current turn; its original entry of this round is removed. Extra-turn entries are not affected.
- **Second Wind:** one own monster on the field regains 1 HP, never above its maximum.
- **Life Thread:** set on one own monster: the first time it would fall, from any damage source, its HP becomes 1 and the effect is consumed; further simultaneous damage of that step changes nothing.
- **Beast Swap** cannot swap out the monster whose turn is running.
- **Beast Swap:** the incoming monster takes the square and queue entry of the swapped-out monster (it acts this round only if that entry is still pending) and arrives with its current HP. The swapped-out monster is not defeated and may be swapped back later; what it created stays.

## 6. Skills and Functions

The ingame battle offers more and other skills and functions than the multiplayer battle. Not defined: which ones, and whether a skill of one battle may appear in the other.

## 7. Catching

Monsters are caught on the board, during a battle of the wild, and nowhere else: in the void no Seal Ground can be laid.

- **Contract:** a monster with a tamer (the player's or an enemy tamer's) never dies: at 0 HP it is defeated ([overworld.md §4.2](overworld.md#42-defeat)). A **wild monster** has no contract: at 0 HP it dies, unless it stands on Seal Ground.
- **Seal Ground:** it is a ground ([battle.md §4](battle.md#4-the-board)) that **cannot be destroyed:** it replaces the ground of its square, no other ground replaces it, no reset removes it, and it does not lapse; it lies until the battle ends or it catches. It cannot be laid on ground that nothing changes (a Dragon Vein, Voidscar); it may be laid under a monster or a prop. It catches only monsters of the other side. Zones and props on its square stay and act as usual. **One Seal Ground at a time** per tamer.
- **One source per Way,** from the start of a game ([overworld.md §4.1](overworld.md#41-obtaining-monsters)): the **Artificer** lays it as a part before the battle; the **Formation** lays it with the Seal tamer skill in the window of tamer skills ([§5](#5-tamer-skills)), once per battle and upgradable; the **Alchemist** uses a pill from a tamer slot in the same window, and the pill is used up. It catches a monster of at most the tamer's stage.
- **The catch:** a wild monster that **ends its turn** on Seal Ground is caught with a chance of **its base at 1 HP, 10 points less for every further HP.** The base is **50 %** without upgrades. A wild monster that reaches **0 HP on Seal Ground is caught, always.** The roll is the only chance in a battle and comes last at the end of the turn, after zones, ground and props; before the turn ends the player sees the chance on the square.
- **Caught:** the monster leaves the board and counts as defeated for the end of the battle; the Seal Ground is used up. A failed roll changes nothing; the battle goes on, the ground stays and rolls again at every later turn end of a wild monster on it.
- **Against tamers:** nothing is caught, no monster dies.

*Working values:* the base and the step per HP. Not defined: how the wild side plays around Seal Ground.
