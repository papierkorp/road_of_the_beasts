# Task Overview

The entry point of every session. Rules live in the rule files ([battle.md](battle.md), [skills.md](skills.md), [monsters.md](monsters.md)), content drafts in [content.md](content.md), decisions in [decisions.md](decisions.md). **Open questions, alternatives and handoffs live only here and under [todo/](todo/).**

## How the Task Folder Works

The folder under `docs/todo/` is the status of a task and says who can act next. Epics: `battle`, `skills`, `monsters`, `overworld`, `project`.

- `to-clarify/<epic>/`: the user can decide at least one point today.
- `waiting/<epic>/`: nothing can be decided or worked on; all of it waits for a test by the user, a measurement or something outside.
- `open/<epic>/`: the agent can work without asking; a task that waits for another task stays here and names it under “Prerequisites”.
- `in-progress/<epic>/`: only for work that outlasts a session.
- `done/<epic>/`: closed, with a `Closed:` line: fulfilled, dropped or replaced. A closed task is not taken back; a new cause gets a new task.
- **One task, one file:** `T<number>-<slug>.md`; numbers are never reused. A status change moves the file with `git mv`, then the script writes the table ([CLAUDE.md](../CLAUDE.md)).
- **A task file holds** what is decided (as links), what is built, what it waits for, the open points and “Done when”. A decision goes to [decisions.md](decisions.md), a rule to its rule file; neither stays in the task.
- [ideas.md](todo/ideas.md) holds ideas without a task, [implementation.md](todo/implementation.md) where the build differs from the rules.

## Current State

Handover of 2026-11-26.

- **Read first:** [vision.md](vision.md), the frame of the game. It holds over the rule files.
- **The frame:** the battle is the game, a roguelike; three Ways that shut each other out (board, tamer, monsters); the lifespan is the one clock and every deed costs a year; the wild shows battles to pick from; monsters rise by battles won; parts and pills drop, nothing is made; won by defeating the Sovereign beast. No story and no dialogue.
- **Rules and build agree:** [implementation.md](todo/implementation.md) lists only what is not built, what is left over in the code and what waits for a check; nothing in it needs a decision.
- **The build** is a prototype to play: the hub game with the three Ways, generated battlegrounds, catching, stat shapes as weights, the options of Seal. Test values in `godot/data/game/values.tres`; switches and the Android build: [godot/README.md](../godot/README.md). The debug APK of commit 02990db is installed on the user's phone.
- **The target structure:** [architecture.md](architecture.md) describes a rebuild from scratch; the build is not moved onto it.
- **Two battles on one core** ([battle_ingame.md](battle_ingame.md)): every measurement so far is multiplayer ([simulation_log.md](simulation_log.md), S040–S046). The multiplayer battle is settled for now and all its content is temporary.
- **The task folder was restructured on 2026-11-26:** no status lines, `waiting/`, `archive/` merged into `done/`, the table written by `godot/tools/tasks.gd`. Structure only: the open points of the task files were not rewritten.
- **Next, in this order:**
  1. **User:** plays a game of each Way on the phone (“Waiting for the User” below).
  2. **User:** answers the open questions below, by rank.
  3. **Agent:** without the user only the K batch of T35 and the README overview named in T61. Everything else waits for 1 or 2.
  4. **User:** gives the go for the rebuild ([architecture.md §10](architecture.md#10-the-rebuild), T42). Its first step: [contract.md](contract.md) is revised once against the rule files and put to the user for acceptance. No code before that.
- **Not looked through:** the open points of T49, T54–T60 and T65 after the decisions of 2026-11-24, and T50; they may hold questions that are answered. The task files still carry dates and history (warnings of the script); T13 is far over its size. Each is cut when it is next worked on.
- **Not checked by anyone:** the two-finger gestures, the map editor on a phone, a whole game of any Way. Agent checks were tests, a headless UI run and screenshots of single screens on the phone. The recommendations in the question table are drafts of an agent.
- **Tests:** 389 cases, 0 failures (full run of `res://tests` on 2026-11-24; not run again for the restructuring, which touched no game code).

## Open Questions for the User

Only what can be decided today without a test. Every recommendation is a draft.

| Rank | Question | Recommendation (draft) | Task |
|---|---|---|---|
| 1 | Do the seven readings chosen while the board rules were built stand? | Yes, as built and tested; look first at “once per action counts for all zones together” | T62 |
| 2 | Does the table of displacement directions stand as the build plays it ([battle.md §6.4](battle.md#64-displacement))? | Yes | T04 |
| 3 | The Thorn Idol hurts its neighbours when it is hit, in the same turn it is placed: keep, change or drop? | Drop the damage: it is damage at a distance without a turn of the victim ([battle.md §6.1](battle.md#61-damage)) | T41 |
| 4 | Storm +1: the eight lines of 2 (16 squares) or the full ring (24)? | 16, the written rule | T06 |
| 5 | May effects on AP or turns per round ever reach other monsters? | No: a lost turn leaves the victim no answer in a battle of three to five rounds | T07 |
| 6 | What Insight buys beyond the trees: awakenings (a passive for an own monster), levels for tamer skills, both or neither? | Awakenings first; levels for tamer skills only if Insight is still left over in play | T65 |
| 7 | Does the growth table of [monsters.md §5](monsters.md#5-growth) end at step 15, now that no monster reaches the Sovereign stage? | Yes | T03 |
| 8 | Does the board stay 3D? | Yes: it is built and runs on the phone; open it again only if a 12×12 board cannot be read there | T60 |
| 9 | Does the kit rule of the nine monsters also bind kits a player composes? | Yes: one rule for every kit | T11 |
| 10 | Skill prices: is “10 points = 1 AP” the form? | Yes, as a working value until play says otherwise | T02 |

## Waiting for the User

| Event | What to watch | Tasks |
|---|---|---|
| A game of each Way on the phone | Wild monsters of the first step (about four in ten have AP 1, more than half HP 1–2); years per stage and the drop; the options of Seal and Qi Suppression; the working values of the board generator, the void and the pool of eggs; the two-tap scheme and the two-finger gestures | T03, T49, T54, T55, T56, T59, T61, T65 |
| Battles in the multiplayer build | Whether the means of square control suffice; which props of the catalogue stay; Shifting Sand, Springwater and Deep Breath; ground and zone values; the skill list | T07, T10, T13, T39, T40, T41, T43 |
| A look through the screens, PC and phone | The bodies and prop figures at board size, the ground patterns, the screens not looked at yet | T63 |
| Reading [content.md §7](content.md#7-kins) | The skill groups and gifts of the Kins | T12 |
| The go for the rebuild | — | T42 |

## Tasks

<!-- tasks:start -->
| ID | Task | Status | Epic |
|---|---|---|---|
| T04 | [Make Resolution Rules and Edge Cases Consistent](todo/to-clarify/battle/T04-make-resolution-rules-and-edge-cases-consistent.md) | to-clarify | battle |
| T07 | [Ground and Zone Values](todo/to-clarify/battle/T07-ground-and-zone-values.md) | to-clarify | battle |
| T41 | [Decide the Props of the Catalogue](todo/to-clarify/battle/T41-bring-the-props-slots-and-stamina-of-the-build-i.md) | to-clarify | battle |
| T46 | [Define the Ingame Battle](todo/to-clarify/battle/T46-define-the-ingame-battle.md) | to-clarify | battle |
| T48 | [Define the Draft of the Multiplayer Battle](todo/to-clarify/battle/T48-define-the-draft-of-the-multiplayer-battle.md) | to-clarify | battle |
| T62 | [Build the Board Rules of 2026-11-22](todo/to-clarify/battle/T62-build-the-board-rules-of-2026-11-22.md) | to-clarify | battle |
| T03 | [Stat Calculation: Open Points](todo/to-clarify/monsters/T03-review-stat-budgets-frames-and-progression-limit.md) | to-clarify | monsters |
| T50 | [Set the Frame of the Game](todo/to-clarify/overworld/T50-set-the-frame-of-the-game.md) | to-clarify | overworld |
| T54 | [Lifespan, Day AP and the Length of a Game](todo/to-clarify/overworld/T54-lifespan-day-ap-and-the-length-of-a-game.md) | to-clarify | overworld |
| T55 | [Wild Area and Dungeon: Numbers, Challenges and Loot](todo/to-clarify/overworld/T55-wild-area-and-dungeon-numbers-challenges-loot.md) | to-clarify | overworld |
| T56 | [The Void and the Player's Battleground](todo/to-clarify/overworld/T56-the-void-and-the-players-battleground.md) | to-clarify | overworld |
| T57 | [Ways and Tamer Skills](todo/to-clarify/overworld/T57-cultivation-systems-and-tamer-skills.md) | to-clarify | overworld |
| T58 | [Materials, Pills and Forged Pieces](todo/to-clarify/overworld/T58-materials-pills-and-forged-pieces.md) | to-clarify | overworld |
| T59 | [Roster, Eggs and the Start](todo/to-clarify/overworld/T59-roster-eggs-and-the-start.md) | to-clarify | overworld |
| T60 | [Hub and Platform](todo/to-clarify/overworld/T60-hub-and-platform.md) | to-clarify | overworld |
| T65 | [The Wild, the One Clock and Drops Instead of Crafting](todo/to-clarify/overworld/T65-the-wild-and-the-one-clock.md) | to-clarify | overworld |
| T02 | [Find Skill Prices](todo/to-clarify/skills/T02-find-skill-prices.md) | to-clarify | skills |
| T05 | [Complete Skill Improvements](todo/to-clarify/skills/T05-complete-skill-improvements.md) | to-clarify | skills |
| T06 | [Complete the Shapes](todo/to-clarify/skills/T06-complete-strike-shapes-and-kin-effects.md) | to-clarify | skills |
| T11 | [Learn Lists, Passives and Kits](todo/to-clarify/skills/T11-learn-lists-passives-and-kits.md) | to-clarify | skills |
| T13 | [Plan and Evaluate Battle Tests](todo/waiting/battle/T13-plan-and-evaluate-battle-tests.md) | waiting | battle |
| T39 | [Dragon Veins: Square Control as the Way to Win by Defeat](todo/waiting/battle/T39-dragon-veins-square-control-as-the-way-to-win-by.md) | waiting | battle |
| T40 | [Reshape the Square and the Skills](todo/waiting/battle/T40-reshape-the-square-and-the-skills.md) | waiting | battle |
| T43 | [Try the Ideas of 2026-11-16](todo/waiting/battle/T43-try-the-ideas-of-2026-11-16.md) | waiting | battle |
| T49 | [Catching on the Board](todo/waiting/overworld/T49-catching-on-the-board.md) | waiting | overworld |
| T42 | [Rebuild the Game Cleanly on the Target Architecture](todo/waiting/project/T42-rebuild-the-game-cleanly-on-the-target-architect.md) | waiting | project |
| T63 | [The Look: Ink on Paper](todo/waiting/project/T63-the-look-ink-on-paper.md) | waiting | project |
| T10 | [The Skill List](todo/waiting/skills/T10-the-skill-list.md) | waiting | skills |
| T12 | [Select the Launch Roster](todo/open/monsters/T12-select-the-launch-roster.md) | open | monsters |
| T14 | [Safeguard Reshape Against Reroll Exploitation](todo/open/monsters/T14-safeguard-reshape-against-reroll-exploitation.md) | open | monsters |
| T19 | [Complete Battle Loadout and Timing](todo/open/overworld/T19-complete-battle-loadout-and-timing.md) | open | overworld |
| T35 | [Update GDD Synchronization and Implementation Plan](todo/open/project/T35-update-gdd-synchronization-and-implementation-pl.md) | open | project |
| T37 | [Editorial Deduplication Pass](todo/open/project/T37-editorial-deduplication-pass.md) | open | project |
| T61 | [Align the Build with the Frame](todo/open/project/T61-align-the-build-and-the-architecture-with-the-frame.md) | open | project |
| T32 | [Design Signature Skills](todo/open/skills/T32-design-signature-skills.md) | open | skills |

Closed: T01, T08, T09, T15–T18, T20–T31, T33, T34, T36, T38, T44, T45, T47, T51–T53, T64 ([todo/done/](todo/done/)).
<!-- tasks:end -->
