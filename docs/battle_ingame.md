# Ingame Battle

The battle inside the game: grown monsters on battlegrounds of the world. It plays the core rules of [battle.md](battle.md) and adds its own.

- **This file owns** every rule only the ingame battle has. The core and what only the multiplayer battle has stand in [battle.md](battle.md).
- **Status:** the frame of §1 is decided; §5 and §7 are decided as written, the numbers of §7 are working values. Everything else is not defined.

## 1. The Two Battles

Both battles share the goals of [battle.md §1](battle.md#1-goals-and-pillars): deterministic, simple to learn and hard to master, decisions that shape the board, won by tactics and skill variety, monsters that differ, square control as the basic aim.

| | Multiplayer battle | Ingame battle |
|---|---|---|
| Character | a fair match | **a tactics puzzle; it may be unfair** |
| Monsters and skills | none fixed: generated or drafted, the same points for every monster ([monsters.md §2.2](monsters.md#22-prices-and-points)) | the fixed monsters, kits and skills of the game ([content.md](content.md)); grown monsters ([monsters.md §5](monsters.md#5-growth)); the sides may differ in strength |
| Team size | always 3v3 | any, also unequal ([§2](#2-team-sizes-and-the-end-of-a-battle)) |
| Board | generated, point-symmetric 7×7 ([battle.md §4.1](battle.md#41-board-generation)) | battlegrounds that differ completely, by the monster and by what the player built ([§3](#3-battlegrounds)) |
| End of a battle | every monster of one side at 0 HP | not always that ([§2](#2-team-sizes-and-the-end-of-a-battle)) |
| Defeats | no monster falls without a turn of its own | no such promise; a wild monster at 0 HP dies, a contracted one is injured ([§7](#7-catching)) |
| Chance | none | one roll: the catch ([§7](#7-catching)) |
| Length | a mean of 3.5–4.5 rounds | not defined |
| Mechanics | the core | more: tamer skills ([§5](#5-tamer-skills)), board events ([§4](#4-board-events)), catching ([§7](#7-catching)), skills of its own |

**Goal of the ingame battle only:**

- **Room to grow:** every mechanic of the ingame battle carries upgrade paths for the ranks of the tamer ([overworld.md §6](overworld.md#6-progression)), because the monsters grow too and a mechanic that does not grow with them falls behind.

- **One core:** flow, timing, the square, damage and displacement are the same in both battles.
- **Strictly apart above the core:** a rule, a skill, a board or a number of one battle is no reason for a decision in the other. A measurement names the battle it was made in.
- **In the build:** the main menu leads through “Battle” to “Ingame Prototype” and “Multiplayer”. The prototype is a test battle without the overworld: points per side, which may differ, and a board are chosen there.

## 2. Team Sizes and the End of a Battle

Every team size other than 3v3 is an ingame matter: 1v1, 2v2, 5v5, and unequal sides such as 3v1. The encounter chooses within the player's available team size ([overworld.md §6.3](overworld.md#63-stage-unlock-table)).

*Working values of the boards built so far; Dragon Veins on them are not defined:*

| Size | Board | Start area per side | Props | Role |
|---|---|---|---|---|
| 1v1 | 5×5 | opposite corners | 2 | duel, tutorial, early game |
| 2v2 | 6×6 | back row | 2 or 4 | step between duel and team battle |
| 3v3 | 7×7 | back two rows | 4 or 6 | standard battle |
| 5v5 | 9×9 | back two rows | 6 or 8 | special battles (bosses, tournaments) |

**A battle need not end with every monster of a side at 0 HP.** Not defined: which other ends exist, who names the end of a battle, and what brakes a battle that has no Dragon Veins.

## 3. Battlegrounds

- **The player builds battlegrounds in the overworld** and uses them in battles.
- **Every monster of the player has a battleground of its own.**

**What a battleground is** *(the map editor of the build; sizes are working values):*

| Part | Rule |
|---|---|
| Outline | a rectangle of a chosen width and height, each 3 to 12 squares, from which single squares can be taken out. A missing square counts like the board edge: nothing stands on it, enters it or is laid on it, and a push against it is a collision ([battle.md §6.3](battle.md#63-collision)) |
| Ground | every square has one ground; a Dragon Vein is a ground and lies wherever the map puts it, in any number |
| Props | one prop per square |
| Zones | one zone per square, with the direction a push zone pushes and the number of rounds it lasts; it may last the whole battle. A pull zone pulls toward the middle of all squares of its kind on the map |
| Start areas | one per side, any squares. A side fields as many monsters as its area has free squares at most; the sides may differ in number. The player places their monsters inside their area before the battle |

Not defined: how a battleground is built in the overworld and what it costs; which grounds, props and zones a player may use; whose battleground a battle is fought on and what the opponent brings; what the monster gains on its own battleground; where the monsters of the opponent stand inside their area.

## 4. Board Events

The ingame battle has board events. Not defined: what an event is, when it acts ([battle.md §3](battle.md#3-timing)) and how the player sees it before it acts.

## 5. Tamer Skills

Tamer skills exist in the ingame battle only.

Battle resolves the effects of the tamer's prepared loadout deterministically and with previews. Wild monsters have no tamer. Definitions, slots and access: [overworld.md §6.4](overworld.md#64-tamer-skills).

- **Window:** a slotted tamer skill (once per battle) may be used during the turn of one of the tamer's own monsters, never inside a payload resolution or during an enemy turn. It costs no AP and no turn.
- **Swap Places:** two own monsters trade squares; no range. Each counts as leaving its square and entering the new one.
- **Urgent Order:** an own monster that has not acted this round is inserted directly after the current turn; its original entry of this round is removed. Extra-turn entries are not affected.
- **Second Wind:** one own monster on the field regains 1 HP, never above its maximum.
- **Life Thread:** set on one own monster: the first time it would fall, from any damage source, its HP becomes 1 and the effect is consumed; further simultaneous damage of that step changes nothing.
- **Beast Swap:** the incoming monster takes the square and queue entry of the swapped-out monster (it acts this round only if that entry is still pending) and arrives with its current HP. The swapped-out monster is not defeated and may be swapped back later; what it created stays.

## 6. Skills and Functions

The ingame battle offers more and other skills and functions than the multiplayer battle. Not defined: which ones, and whether a skill of one battle may appear in the other.

## 7. Catching

Monsters are caught on the board, during the battle, and nowhere else.

- **Contract:** a monster with a tamer (the player's or an enemy tamer's) never dies: at 0 HP it is defeated and injured ([overworld.md §5.2](overworld.md#52-defeat-and-injury)). A **wild monster** has no contract: at 0 HP it dies, unless it stands on a Seal Zone.
- **Seal Ground:** the tamer lays it on a square of their choice in the window of tamer skills ([§5](#5-tamer-skills)). It is a ground ([battle.md §4](battle.md#4-the-board)) that **cannot be destroyed:** it replaces the ground of its square, no other ground replaces it, no reset removes it, and it does not lapse; it lies until the battle ends or it catches. It cannot be laid on a Dragon Vein. Zones and props on its square stay and act as usual. **One Seal Ground at a time** per tamer.
- **Two sources,** both available from the start of the game: the **Binding Seal item**, consumed when laid, and the **Seal tamer skill**, once per battle and upgradable ([overworld.md §6.4](overworld.md#64-tamer-skills)). Tier and grade of the seal limit which monster it can catch ([overworld.md §5.1](overworld.md#51-obtaining-monsters)).
- **The catch:** a wild monster that **ends its turn** on Seal Ground is caught with a chance of **its base at 1 HP, 10 points less for every further HP.** The base is **50 %** for the Seal skill without upgrades and **20 / 35 / 50 / 65 %** for a Normal / Rare / Epic / Legendary seal item. A wild monster that reaches **0 HP on Seal Ground is caught, always.** The roll is the only chance in a battle; before the turn ends the player sees the chance on the square.
- **Caught:** the monster leaves the board and counts as defeated for the end of the battle; the Seal Ground is used up. A failed roll changes nothing; the battle goes on and the ground stays.
- **Against tamers:** nothing is caught, no monster dies.

*Working values:* the bases and the step per HP. Not defined: where the contract does not hold (fights to the death against tamers, areas of dungeons); how the wild side plays around Seal Ground.
