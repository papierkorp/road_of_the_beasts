# Task Overview

The task list of the project. Rules live in the rule files ([battle.md](battle.md), [skills.md](skills.md), [monsters.md](monsters.md)), content drafts in [content.md](content.md), decisions in [decisions.md](decisions.md). **Open questions, alternatives and handoffs live only here.**

## How the Task Folder Works

Folders under `docs/todo/`: `to-clarify/<epic>/` (waits for a decision of the user), `open/<epic>/`, `in-progress/<epic>/`, `done/<epic>/` (later moved to `archive/`); `ideas.md` holds ideas without a task, `implementation.md` where the build differs from the rules.

- **One task, one file:** `T<number>-<slug>.md`. Epics: `battle`, `skills`, `monsters`, `overworld`, `project`.
- **A status change moves the file** to the other folder; the table below is updated in the same step.
- **A task file holds:** status, open points and “done when”. A decision goes to [decisions.md](decisions.md), a rule to its rule file; neither stays in the task.
- Numbers are never reused.

## Current State

- **Read first:** [vision.md](vision.md), the frame of the game (T50). It holds over the rule files; [overworld.md](overworld.md) is rewritten along it.
- **Decided alone, to review (T51):** the rewrite of overworld.md and the first world; each such decision is a row in T51 and a working draft until the user has gone through it.
- **World in the build ([godot/README.md](../godot/README.md)):** New Game leads into a hub with every district, both wild areas, the Realm Gate (the old dungeon run stands in) and the Internal World as teleporters; a follow camera; resources of a wild area for 1 day AP that return after nights. Main menu → Growth Preview walks through the growth by clicking. Not built: persons, battle in a wild area, the house, weight, crafting, the Internal World and tamer slots by the new rules. Not tried by hand: looking around with the mouse, taking resources, the way through the Realm Gate.
- **Next:** the user walks the world and the growth preview and goes through T51 and T50; then the old overworld tasks (T15–T31) are sorted anew; then the first slice of the overworld (school, its mountain, the Internal World of the first stage). The ingame battle waits.
- **Two battles on one core** ([battle_ingame.md](battle_ingame.md), [architecture.md §4](architecture.md#4-the-battle)): the multiplayer battle and the ingame battle. Everything measured so far is multiplayer ([S040–S045](simulation_log.md), indications).
- **Multiplayer battle, settled for now:** 3v3 on a generated symmetric 7×7 board, monsters drawn for 60 points, kits of generated skills ([content.md §1](content.md#1-ground)). All content is temporary.
- **Ingame battle** ([battle_ingame.md](battle_ingame.md)): every board is a battleground that sets team size, ends and board events; catching on Seal Ground is built. When it resumes: ends and board events in the map editor and the battle (T46); the user plays Seal Ground (T49); then a wild AI that values Seal Ground. Then the rebuild ([T42](todo/open/project/T42-rebuild-the-game-cleanly-on-the-target-architect.md)).
- **Tests:** 418 cases ([implementation.md](todo/implementation.md)); two known failures outside the battle (I46: the overworld roamer, the reference stats).

## Open Questions for the User

| # | Question | Task |
|---|---|---|
| 0 | The frame is decided; open are its lists and the points seen in the growth preview (a sub-tier gives the tamer nothing, four choices on one breakthrough) | T50 |
| 0 | 28 rows decided without the user: rules of overworld.md and the first world of the build | T51 |
| 1 | How does a stat shape split the points at the roll? | T03 |
| 2 | Ingame battle: numbers of the ends and several ends in one battle, ingame-only skills, battlegrounds in the overworld (cost, content, whose board) | T46 |
| 13 | Seal: item and skill Seal Ground together? The upgrade scroll as an item; options of the other tamer skills | T49 |
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
| T26 | [Draft Staff Traits and Numbers](todo/to-clarify/overworld/T26-draft-staff-traits-and-numbers.md) | to clarify | overworld |
| T49 | [Catching on the Board](todo/to-clarify/overworld/T49-catching-on-the-board.md) | to clarify | overworld |
| T50 | [Set the Frame of the Game](todo/to-clarify/overworld/T50-set-the-frame-of-the-game.md) | to clarify | overworld |
| T51 | [Review What Was Decided Alone](todo/to-clarify/overworld/T51-review-what-was-decided-alone.md) | to clarify | overworld |
| T05 | [Complete Skill Improvements](todo/to-clarify/skills/T05-complete-skill-improvements.md) | to clarify | skills |
| T06 | [Complete Strike Shapes and Kin Effects](todo/to-clarify/skills/T06-complete-strike-shapes-and-kin-effects.md) | to clarify | skills |
| T07 | [Ground and Zone Values](todo/open/battle/T07-ground-and-zone-values.md) | open | battle |
| T13 | [Plan and Evaluate Battle Tests](todo/open/battle/T13-plan-and-evaluate-battle-tests.md) | open | battle |
| T40 | [Reshape the Square and the Skills](todo/open/battle/T40-reshape-the-square-and-the-skills.md) | open | battle |
| T12 | [Select the Launch Roster](todo/open/monsters/T12-select-the-launch-roster.md) | open | monsters |
| T14 | [Safeguard Reshape Against Reroll Exploitation](todo/open/monsters/T14-safeguard-reshape-against-reroll-exploitation.md) | open | monsters |
| T15 | [Define City Powers, Responsibilities and Content](todo/open/overworld/T15-define-city-powers-responsibilities-and-content.md) | open | overworld |
| T16 | [Complete Material, Item and Recipe Catalogues](todo/open/overworld/T16-complete-material-item-and-recipe-catalogues.md) | open | overworld |
| T17 | [Define Artifact Rules and Stacking](todo/open/overworld/T17-define-artifact-rules-and-stacking.md) | open | overworld |
| T18 | [Specify Medicines and Arrays](todo/open/overworld/T18-specify-medicines-and-arrays.md) | open | overworld |
| T19 | [Complete Battle Loadout and Timing](todo/open/overworld/T19-complete-battle-loadout-and-timing.md) | open | overworld |
| T20 | [Validate Tamer Skills Including Beast Swap](todo/open/overworld/T20-validate-tamer-skills-including-beast-swap.md) | open | overworld |
| T21 | [Define the Dungeon Node ↔ Board Generator Contract](todo/open/overworld/T21-define-the-dungeon-node-board-generator-contract.md) | open | overworld |
| T22 | [Complete Expeditions and Loot Tables](todo/open/overworld/T22-complete-expeditions-and-loot-tables.md) | open | overworld |
| T23 | [Align Injury and Deadly Dungeons](todo/open/overworld/T23-align-injury-and-deadly-dungeons.md) | open | overworld |
| T24 | [Specify Binding, Eggs, Breeding and Hive](todo/open/overworld/T24-specify-binding-eggs-breeding-and-hive.md) | open | overworld |
| T25 | [Internal World: Capacity, Buildings, Adjacency](todo/open/overworld/T25-internal-world-capacity-buildings-adjacency.md) | open | overworld |
| T27 | [Align Favor/Standing and Request Pools](todo/open/overworld/T27-align-favor-standing-and-request-pools.md) | open | overworld |
| T28 | [Balance the Market, Properties and Businesses](todo/open/overworld/T28-balance-the-market-properties-and-businesses.md) | open | overworld |
| T29 | [Review XP Curves and Cultivation Pacing](todo/open/overworld/T29-review-xp-curves-and-cultivation-pacing.md) | open | overworld |
| T30 | [Complete Breakthrough Trials and Rituals](todo/open/overworld/T30-complete-breakthrough-trials-and-rituals.md) | open | overworld |
| T31 | [Finalize Day-AP and Action Costs](todo/open/overworld/T31-finalize-day-ap-and-action-costs.md) | open | overworld |
| T35 | [Update GDD Synchronization and Implementation Plan](todo/open/project/T35-update-gdd-synchronization-and-implementation-pl.md) | open | project |
| T37 | [Editorial Deduplication Pass](todo/open/project/T37-editorial-deduplication-pass.md) | open | project |
| T42 | [Rebuild the Game Cleanly on the Target Architecture](todo/open/project/T42-rebuild-the-game-cleanly-on-the-target-architect.md) | open | project |
| T02 | [Find Skill Prices](todo/open/skills/T02-find-skill-prices.md) | open | skills |
| T10 | [The Skill List](todo/open/skills/T10-the-skill-list.md) | open | skills |
| T11 | [Learn Lists, Passives and Kits](todo/open/skills/T11-learn-lists-passives-and-kits.md) | open | skills |
| T32 | [Design Signature Skills](todo/open/skills/T32-design-signature-skills.md) | open | skills |

Finished: T44, T45, T47 ([todo/done/](todo/done/)); archived: T01, T08, T09, T33, T34, T36, T38 ([todo/archive/](todo/archive/)).

## Test Switches of the Build

Not rules; they exist to try something out. A switch becomes a rule only by a decision.

- **Board size:** 3v3 on 8×8 (four Dragon Veins) and on 9×9 (three).
- **Button squares:** the three runes as mirrored pairs.
- Everything else: [godot/README.md](../godot/README.md).
