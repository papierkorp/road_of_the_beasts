# Task Overview

The task list of the project. Rules live in the rule files ([battle.md](battle.md), [skills.md](skills.md), [monsters.md](monsters.md)), content drafts in [content.md](content.md), decisions in [decisions.md](decisions.md). **Open questions, alternatives and handoffs live only here.**

## How the Task Folder Works

Folders under `docs/todo/`: `to-clarify/<epic>/` (waits for a decision of the user), `open/<epic>/`, `in-progress/<epic>/`, `done/<epic>/` (later moved to `archive/`); `ideas.md` holds ideas without a task, `implementation.md` where the build differs from the rules.

- **One task, one file:** `T<number>-<slug>.md`. Epics: `battle`, `skills`, `monsters`, `overworld`, `project`.
- **A status change moves the file** to the other folder; the table below is updated in the same step.
- **A task file holds:** status, open points and “done when”. A decision goes to [decisions.md](decisions.md), a rule to its rule file; neither stays in the task.
- Numbers are never reused.

## Current State

Handover of 2026-11-24.

- **Read first:** [vision.md](vision.md), the frame of the game. It holds over the rule files.
- **The frame:** the battle is the game, a roguelike; three Ways that shut each other out (board, tamer, monsters); the lifespan is the one clock and every deed costs a year; the wild shows battles to pick from; monsters rise by battles won; parts and pills drop, nothing is made; won by defeating the Sovereign beast. No story and no dialogue.
- **Rules and build agree:** every difference between the rule files and the build was decided on 2026-11-24 and written into the rule files and [decisions.md](decisions.md). [implementation.md](todo/implementation.md) lists only what is not built, what is left over in the code and what waits for a check; nothing in it needs a decision.
- **The build** is a prototype to play: the hub game with the three Ways, generated battlegrounds, catching, stat shapes as weights, the options of Seal. Test values in `godot/data/game/values.tres` ([godot/README.md](../godot/README.md)). It runs on a phone: an Android preset, a larger interface, touch in the battle ([godot/README.md](../godot/README.md#android-build)). The debug APK of the last commit is installed on the user's phone.
- **The target structure:** [architecture.md](architecture.md) is rewritten for a rebuild from scratch: battle and hub, what both read in `shared/`, screens for phone and PC, German and English with the language as a setting, the multiplayer battle as the last step. The build is not moved onto it.
- **Next, in this order:**
  1. **The user plays** a game of each Way on the phone and says whether the rules stay. To watch: wild monsters of the first step (about four in ten have AP 1, more than half HP 1–2, T03), the two-tap scheme and the two-finger gestures in the battle, years per stage and the drop (T65, T54), the options of Seal and Qi Suppression.
  2. **Then the rebuild starts on the user's go** ([architecture.md §10](architecture.md#10-the-rebuild), T42). Its first step: [contract.md](contract.md), a frozen draft of an older state, is revised once against the rule files and put to the user for acceptance. No code before that. From the start the battle rules rest.
- **Not looked through** after the decisions of 2026-11-24: the task files T49, T54–T60 and T65; they may still hold questions that are answered. T13 is far over its size.
- **Not checked by anyone:** the two-finger gestures, the map editor on a phone, a whole game of any Way. Agent checks were tests, a headless UI run and screenshots of single screens on the phone.
- **Two battles on one core** ([battle_ingame.md](battle_ingame.md), [architecture.md §4](architecture.md#4-the-battle)): the multiplayer battle and the ingame battle. Every measurement so far is multiplayer ([S040–S045](simulation_log.md)). The multiplayer battle is settled for now: 3v3 on a generated 7×7 board, 60 points, generated kits; all its content is temporary.
- **A quirk of the Godot export** cost a day: an exported packed array field with an array literal as default loses its value in the export ([CLAUDE.md](../CLAUDE.md), `godot/tests/shared/test_export_fields.gd`). A data fault that shows on the phone alone is checked against the exported pack first.
- **Tests:** 389 cases, 0 failures (full run of `res://tests` on 2026-11-24).

## Open Questions for the User

| # | Question | Task |
|---|---|---|
| 0 | What Insight buys beyond the trees: awakenings (a passive for an own monster) and levels for tamer skills are proposed | T65 |
| 0 | The wild and the one clock, after play: years per stage, the drop, who rises, boons | T65 |
| 0 | Years per stage for three to four hours | T54 |
| 0 | The generator of the boards: working values from the build, to confirm after play | T55 |
| 0 | The void and the own battleground: working values from the build, to confirm after play; the pools of void monsters and Sovereign beasts | T56 |
| 0 | The lists of parts and pills that drop | T58 |
| 0 | The pool of eggs and the roster: working values from the build, to confirm after play; further eggs | T59 |
| 0 | Kins: skill groups ([content.md §7](content.md#7-kins)) | T12 |
| 0 | The hub's buildings, 3D or 2D board, the phone | T60 |
| 2 | Ingame battle: ingame-only skills | T46 |
| 3 | Which props of the catalogue stay, and do aura props return? | T41 |
| 4 | Square control: do the current means suffice, or does it need more? | T39 |
| 6 | Displacement directions as the build plays them: confirm the table; corner cases of a diagonal move; who places first | T04 |
| 7 | How far may a shape that is no Strike be extended? Storm +1 as 16 or 24 squares? | T06 |
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
| T41 | [Decide the Props of the Catalogue](todo/to-clarify/battle/T41-bring-the-props-slots-and-stamina-of-the-build-i.md) | to clarify | battle |
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
| T06 | [Complete the Shapes](todo/to-clarify/skills/T06-complete-strike-shapes-and-kin-effects.md) | to clarify | skills |
| T07 | [Ground and Zone Values](todo/open/battle/T07-ground-and-zone-values.md) | open | battle |
| T13 | [Plan and Evaluate Battle Tests](todo/open/battle/T13-plan-and-evaluate-battle-tests.md) | open | battle |
| T40 | [Reshape the Square and the Skills](todo/open/battle/T40-reshape-the-square-and-the-skills.md) | open | battle |
| T12 | [Select the Launch Roster](todo/open/monsters/T12-select-the-launch-roster.md) | open | monsters |
| T14 | [Safeguard Reshape Against Reroll Exploitation](todo/open/monsters/T14-safeguard-reshape-against-reroll-exploitation.md) | open | monsters |
| T19 | [Complete Battle Loadout and Timing](todo/open/overworld/T19-complete-battle-loadout-and-timing.md) | open | overworld |
| T35 | [Update GDD Synchronization and Implementation Plan](todo/open/project/T35-update-gdd-synchronization-and-implementation-pl.md) | open | project |
| T37 | [Editorial Deduplication Pass](todo/open/project/T37-editorial-deduplication-pass.md) | open | project |
| T42 | [Rebuild the Game Cleanly on the Target Architecture](todo/open/project/T42-rebuild-the-game-cleanly-on-the-target-architect.md) | open | project |
| T61 | [Align the Build with the Frame](todo/open/project/T61-align-the-build-and-the-architecture-with-the-frame.md) | open | project |
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
