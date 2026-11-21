# Task Overview

The task list of the project. Rules live in the rule files ([battle.md](battle.md), [skills.md](skills.md), [monsters.md](monsters.md)), content drafts in [content.md](content.md), decisions in [decisions.md](decisions.md). **Open questions, alternatives and handoffs live only here.**

## How the Task Folder Works

Folders under `docs/todo/`: `to-clarify/<epic>/` (waits for a decision of the user), `open/<epic>/`, `in-progress/<epic>/`, `done/<epic>/` (later moved to `archive/`); `ideas.md` holds ideas without a task, `implementation.md` where the build differs from the rules.

- **One task, one file:** `T<number>-<slug>.md`. Epics: `battle`, `skills`, `monsters`, `overworld`, `project`.
- **A status change moves the file** to the other folder; the table below is updated in the same step.
- **A task file holds:** status, open points and “done when”. A decision goes to [decisions.md](decisions.md), a rule to its rule file; neither stays in the task.
- Numbers are never reused.

## Current State

- **Read first:** [vision.md](vision.md), the frame of the game. It holds over the rule files.
- **The frame (2026-11-21):** the battle is the game; a hub of buildings; offline single player, phone in landscape and PC; three pillars (monster, tamer, board); day AP and a lifespan per stage with the trial forced at its end; wild area, roguelike dungeon (harvest once its challenge is met) and the void (own battleground, last depth is the trial); a cultivation system chosen at the start; crafting with materials drawn per game.
- **Rule files follow the frame:** [overworld.md](overworld.md) is rewritten; [battle_ingame.md](battle_ingame.md), [monsters.md](monsters.md) and [skills.md](skills.md) are aligned. The city, persons, the Internal World, injury, scrolls and grades of materials are gone.
- **Not aligned yet (T61):** the build (the walked 3D world, the Growth Preview) and [architecture.md](architecture.md) (dialogue, story, faction requests). Earlier rows of [decisions.md](decisions.md) link to sections that no longer exist.
- **Next:** the questions of T54 to T60 in the chat, the rough shape before details, in this order: the limits of the own battleground (T56), the cultivation systems (T57), the numbers of day and lifespan (T54); then the first slice to build is chosen.
- **Two battles on one core** ([battle_ingame.md](battle_ingame.md), [architecture.md §4](architecture.md#4-the-battle)): the multiplayer battle and the ingame battle. Everything measured so far is multiplayer ([S040–S045](simulation_log.md), indications).
- **Multiplayer battle, settled for now:** 3v3 on a generated symmetric 7×7 board, monsters drawn for 60 points, kits of generated skills ([content.md §1](content.md#1-ground)). All content is temporary.
- **Ingame battle** ([battle_ingame.md](battle_ingame.md)): every board is a battleground that sets team size, ends and board events; catching on Seal Ground is built. Open in the build: ends and board events in the map editor (T46), Seal Ground played by hand (T49), a wild AI that values Seal Ground; then the rebuild (T42).
- **Tests:** 418 cases ([implementation.md](todo/implementation.md)); two known failures outside the battle (I46: the overworld roamer, the reference stats). A run of all of `tests/overworld` did not finish within 30 minutes on 2026-11-19 and was stopped, cause not looked into.

## Open Questions for the User

| # | Question | Task |
|---|---|---|
| 0 | Lifespan, day AP, length of a game, what a game leaves behind | T54 |
| 0 | Wild area and dungeon: numbers, challenges, loot, where the boards come from | T55 |
| 0 | The void: limits of the own battleground, depths, void monsters, the five trials | T56 |
| 0 | Cultivation systems: how many, their trees, which tamer skills | T57 |
| 0 | Materials, pills, weapons, armour, the seal item, a currency | T58 |
| 0 | The three eggs, the roster, further eggs | T59 |
| 0 | The hub's buildings, 3D or 2D board, the phone | T60 |
| 1 | How does a stat shape split the points at the roll? | T03 |
| 2 | Ingame battle: numbers of the ends and several ends in one battle, ingame-only skills | T46 |
| 13 | Seal: item and skill Seal Ground together? | T49 |
| 3 | Which props of the catalogue stay, and do aura props return? | T41 |
| 4 | Square control: do the current means suffice, or does it need more? | T39 |
| 5 | How many kit slots are open at the start of the game, and what opens the others? | T05 |
| 6 | Which pushes are cardinal, which use eight directions? | T04 |
| 7 | How far may a shape that is no Strike be extended? | T06 |
| 8 | The Thorn Idol passes a Strike on to its neighbours in the same turn: keep, change or drop? | T41 |
| 9 | May effects on AP or turns per round ever reach other monsters? | T07 |
| 10 | Does the kit rule of the nine monsters also bind kits a player composes? | T11 |
| 11 | Skill prices: is “10 points = 1 AP” the form? Ground, zone and prop skills all come out below 1 AP. What does “damages props” cost on a Strike? | T02 |
| 12 | Multiplayer: a Strike that pulls (new mechanic)? Function names for the props too? The draft: pools, number of skills, saved creations | T48 |
| 12 | Which of the ideas that are left stay: Erosion, Shifting Sand, Stamina recovery from ground and as a self buff? | T43 |

## Tasks

| ID | Task | Status | Epic |
|---|---|---|---|
| T04 | [Make Resolution Rules and Edge Cases Consistent](todo/to-clarify/battle/T04-make-resolution-rules-and-edge-cases-consistent.md) | to clarify | battle |
| T39 | [Dragon Veins: Square Control as the Way to Win by Defeat](todo/to-clarify/battle/T39-dragon-veins-square-control-as-the-way-to-win-by.md) | to clarify | battle |
| T41 | [Bring the Props, Slots and Stamina of the Build into the GDDs, or Drop Them](todo/to-clarify/battle/T41-bring-the-props-slots-and-stamina-of-the-build-i.md) | to clarify | battle |
| T43 | [Try the Ideas of 2026-11-16](todo/to-clarify/battle/T43-try-the-ideas-of-2026-11-16.md) | to clarify | battle |
| T46 | [Define the Ingame Battle](todo/to-clarify/battle/T46-define-the-ingame-battle.md) | to clarify | battle |
| T48 | [Define the Draft of the Multiplayer Battle](todo/to-clarify/battle/T48-define-the-draft-of-the-multiplayer-battle.md) | to clarify | battle |
| T03 | [Review Stat Budgets, Frames and Progression Limits](todo/to-clarify/monsters/T03-review-stat-budgets-frames-and-progression-limit.md) | to clarify | monsters |
| T49 | [Catching on the Board](todo/to-clarify/overworld/T49-catching-on-the-board.md) | to clarify | overworld |
| T50 | [Set the Frame of the Game](todo/to-clarify/overworld/T50-set-the-frame-of-the-game.md) | to clarify | overworld |
| T54 | [Lifespan, Day AP and the Length of a Game](todo/to-clarify/overworld/T54-lifespan-day-ap-and-the-length-of-a-game.md) | to clarify | overworld |
| T55 | [Wild Area and Dungeon: Numbers, Challenges and Loot](todo/to-clarify/overworld/T55-wild-area-and-dungeon-numbers-challenges-loot.md) | to clarify | overworld |
| T56 | [The Void and the Player's Battleground](todo/to-clarify/overworld/T56-the-void-and-the-players-battleground.md) | to clarify | overworld |
| T57 | [Cultivation Systems and Tamer Skills](todo/to-clarify/overworld/T57-cultivation-systems-and-tamer-skills.md) | to clarify | overworld |
| T58 | [Materials, Pills and Forged Pieces](todo/to-clarify/overworld/T58-materials-pills-and-forged-pieces.md) | to clarify | overworld |
| T59 | [Roster, Eggs and the Start](todo/to-clarify/overworld/T59-roster-eggs-and-the-start.md) | to clarify | overworld |
| T60 | [Hub and Platform](todo/to-clarify/overworld/T60-hub-and-platform.md) | to clarify | overworld |
| T05 | [Complete Skill Improvements](todo/to-clarify/skills/T05-complete-skill-improvements.md) | to clarify | skills |
| T06 | [Complete Strike Shapes and Kin Effects](todo/to-clarify/skills/T06-complete-strike-shapes-and-kin-effects.md) | to clarify | skills |
| T07 | [Ground and Zone Values](todo/open/battle/T07-ground-and-zone-values.md) | open | battle |
| T13 | [Plan and Evaluate Battle Tests](todo/open/battle/T13-plan-and-evaluate-battle-tests.md) | open | battle |
| T40 | [Reshape the Square and the Skills](todo/open/battle/T40-reshape-the-square-and-the-skills.md) | open | battle |
| T12 | [Select the Launch Roster](todo/open/monsters/T12-select-the-launch-roster.md) | open | monsters |
| T14 | [Safeguard Reshape Against Reroll Exploitation](todo/open/monsters/T14-safeguard-reshape-against-reroll-exploitation.md) | open | monsters |
| T19 | [Complete Battle Loadout and Timing](todo/open/overworld/T19-complete-battle-loadout-and-timing.md) | open | overworld |
| T35 | [Update GDD Synchronization and Implementation Plan](todo/open/project/T35-update-gdd-synchronization-and-implementation-pl.md) | open | project |
| T37 | [Editorial Deduplication Pass](todo/open/project/T37-editorial-deduplication-pass.md) | open | project |
| T42 | [Rebuild the Game Cleanly on the Target Architecture](todo/open/project/T42-rebuild-the-game-cleanly-on-the-target-architect.md) | open | project |
| T61 | [Align the Build and the Architecture with the Frame](todo/open/project/T61-align-the-build-and-the-architecture-with-the-frame.md) | open | project |
| T02 | [Find Skill Prices](todo/open/skills/T02-find-skill-prices.md) | open | skills |
| T10 | [The Skill List](todo/open/skills/T10-the-skill-list.md) | open | skills |
| T11 | [Learn Lists, Passives and Kits](todo/open/skills/T11-learn-lists-passives-and-kits.md) | open | skills |
| T32 | [Design Signature Skills](todo/open/skills/T32-design-signature-skills.md) | open | skills |

Finished: T44, T45, T47, T53 ([todo/done/](todo/done/)); archived: T01, T08, T09, T15–T18, T20–T31, T33, T34, T36, T38, T51, T52 ([todo/archive/](todo/archive/)).

## Test Switches of the Build

Not rules; they exist to try something out. A switch becomes a rule only by a decision.

- **Board size:** 3v3 on 8×8 (four Dragon Veins) and on 9×9 (three).
- **Button squares:** the three runes as mirrored pairs.
- Everything else: [godot/README.md](../godot/README.md).
