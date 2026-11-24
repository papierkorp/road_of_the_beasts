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
- **The frame (reworked 2026-11-22, T65):** the battle is the game, a roguelike; three Ways that shut each other out (board, tamer, monsters); the lifespan is the one clock and every deed costs a year; the wild shows battles to pick from; monsters rise by battles won; parts and pills drop, nothing is made; won by defeating the Sovereign beast.
- **Built (T65), not played by hand:** wild and void, rises, drops per Way, a gift at the start, a boon at every breakthrough.
- **The target structure:** [architecture.md](architecture.md) follows the frame: battle and hub, no story, the multiplayer battle last. The build is not aligned with it (T61).
- **The build (T61):** a first version to click through; test values in `godot/data/game/values.tres` ([godot/README.md](../godot/README.md); [implementation.md](todo/implementation.md) §3). Every battleground is generated.
- **Next:** the user plays the three Ways and checks the balance by hand; the answer on Insight (T65); then the numbers of a game (T54).
- **Two battles on one core** ([battle_ingame.md](battle_ingame.md), [architecture.md §4](architecture.md#4-the-battle)): the multiplayer battle and the ingame battle. Every measurement so far is multiplayer ([S040–S045](simulation_log.md)).
- **Multiplayer battle, settled for now:** 3v3 on a generated 7×7 board, 60 points, generated kits ([content.md §1](content.md#1-ground)). All content is temporary.
- **Ingame battle** ([battle_ingame.md](battle_ingame.md)): every board is a battleground that sets the team size; catching on Seal Ground is built. Open in the build: Seal Ground played by hand (T49), a wild AI that values Seal Ground; then the rebuild (T42).
- **Tests:** 389 cases, 0 failures ([implementation.md](todo/implementation.md)).

## Open Questions for the User

| # | Question | Task |
|---|---|---|
| 0 | What Insight buys beyond the trees: awakenings (a passive for an own monster) and levels for tamer skills are proposed | T65 |
| 0 | The wild and the one clock, after play: years per stage, the drop, who rises, boons | T65 |
| 0 | Years per stage for three to four hours | T54 |
| 0 | The generator of the boards | T55 |
| 0 | The void: limits of the own battleground, depths, the pools of void monsters and Sovereign beasts | T56 |
| 0 | The lists of parts and pills that drop | T58 |
| 0 | The pool of eggs, the roster, further eggs | T59 |
| 0 | Kins: skill groups ([content.md §7](content.md#7-kins)) | T12 |
| 0 | The hub's buildings, 3D or 2D board, the phone | T60 |
| 2 | Ingame battle: ingame-only skills | T46 |
| 3 | Which props of the catalogue stay, and do aura props return? | T41 |
| 4 | Square control: do the current means suffice, or does it need more? | T39 |
| 6 | Which pushes are cardinal, which use eight directions? | T04 |
| 7 | How far may a shape that is no Strike be extended? | T06 |
| 8 | The Thorn Idol passes a Strike on to its neighbours in the same turn: keep, change or drop? | T41 |
| 9 | May effects on AP or turns per round ever reach other monsters? | T07 |
| 10 | Does the kit rule of the nine monsters also bind kits a player composes? | T11 |
| 11 | Skill prices: is “10 points = 1 AP” the form? Ground, zone and prop skills all come out below 1 AP. What does “damages props” cost on a Strike? | T02 |
| 12 | Multiplayer: a Strike that pulls (new mechanic)? Function names for the props too? The draft: pools, number of skills, saved creations | T48 |
| 12 | Which of the ideas that are left stay: Shifting Sand, Stamina recovery from ground and as a self buff? | T43 |

## Tasks

| ID | Task | Status | Epic |
|---|---|---|---|
| T62 | [Build the Board Rules of 2026-11-22](todo/to-clarify/battle/T62-build-the-board-rules-of-2026-11-22.md) | to clarify | battle |
| T04 | [Make Resolution Rules and Edge Cases Consistent](todo/to-clarify/battle/T04-make-resolution-rules-and-edge-cases-consistent.md) | to clarify | battle |
| T39 | [Dragon Veins: Square Control as the Way to Win by Defeat](todo/to-clarify/battle/T39-dragon-veins-square-control-as-the-way-to-win-by.md) | to clarify | battle |
| T41 | [Bring the Props, Slots and Stamina of the Build into the GDDs, or Drop Them](todo/to-clarify/battle/T41-bring-the-props-slots-and-stamina-of-the-build-i.md) | to clarify | battle |
| T43 | [Try the Ideas of 2026-11-16](todo/to-clarify/battle/T43-try-the-ideas-of-2026-11-16.md) | to clarify | battle |
| T46 | [Define the Ingame Battle](todo/to-clarify/battle/T46-define-the-ingame-battle.md) | to clarify | battle |
| T48 | [Define the Draft of the Multiplayer Battle](todo/to-clarify/battle/T48-define-the-draft-of-the-multiplayer-battle.md) | to clarify | battle |
| T63 | [The Look: Ink on Paper](todo/to-clarify/project/T63-the-look-ink-on-paper.md) | to clarify | project |
| T03 | [Review Stat Budgets, Frames and Progression Limits](todo/to-clarify/monsters/T03-review-stat-budgets-frames-and-progression-limit.md) | to clarify | monsters |
| T65 | [The Wild, the One Clock and Drops](todo/to-clarify/overworld/T65-the-wild-and-the-one-clock.md) | to clarify | overworld |
| T64 | [The Three Ways and the Day Without AP](todo/done/overworld/T64-the-three-ways-and-the-day.md) | done | overworld |
| T49 | [Catching on the Board](todo/to-clarify/overworld/T49-catching-on-the-board.md) | to clarify | overworld |
| T50 | [Set the Frame of the Game](todo/to-clarify/overworld/T50-set-the-frame-of-the-game.md) | to clarify | overworld |
| T54 | [Lifespan, Day AP and the Length of a Game](todo/to-clarify/overworld/T54-lifespan-day-ap-and-the-length-of-a-game.md) | to clarify | overworld |
| T55 | [Wild Area and Dungeon: Numbers, Challenges and Loot](todo/to-clarify/overworld/T55-wild-area-and-dungeon-numbers-challenges-loot.md) | to clarify | overworld |
| T56 | [The Void and the Player's Battleground](todo/to-clarify/overworld/T56-the-void-and-the-players-battleground.md) | to clarify | overworld |
| T57 | [Ways and Tamer Skills](todo/to-clarify/overworld/T57-cultivation-systems-and-tamer-skills.md) | to clarify | overworld |
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
