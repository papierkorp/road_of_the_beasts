# Task Overview

The task list of the project. Rules live in the rule files ([battle.md](battle.md), [skills.md](skills.md), [monsters.md](monsters.md)), content drafts in [content.md](content.md), decisions in [decisions.md](decisions.md). **Open questions, alternatives and handoffs live only here.**

## How the Task Folder Works

```
docs/todo/
  to-clarify/<epic>/   waits for a decision of the user
  open/<epic>/         can be worked on
  in-progress/<epic>/  being worked on
  done/<epic>/         finished; moved to archive/ once nothing refers to it any more
  archive/             old finished tasks, kept for reference
  ideas.md             ideas without a task
  implementation.md    where the build reads a rule its own way, and what is not built
```

- **One task, one file:** `T<number>-<slug>.md`. Epics: `battle`, `skills`, `monsters`, `overworld`, `project`.
- **A status change moves the file** to the other folder; the table below is updated in the same step.
- **A task file holds:** status, open points and “done when”. A decision goes to [decisions.md](decisions.md), a rule to its rule file; neither stays in the task.
- Numbers are never reused.

## Current State

- **Focus:** the battle is finished first. The multiplayer mode (pick teams, fight) is the place to try it.
- **Decided and built:** Pace and Stamina, the round end (moves, acts, ticks), cover, traps as walkable props, one shape per skill with free shapes, one sheet for ground, zones and props, the monster calculation (ranges from 1, price list, 25 points +5 per step).
- **Content:** nine monsters at 60 points with six-skill kits; all of it working drafts.
- **Next:** the skills and their calculation are reworked now that the monsters stand ([T02](todo/open/skills/T02-find-skill-prices.md), [T10](todo/open/skills/T10-the-skill-list.md)).
- **Skill calculation (draft):** a first price list from bot runs stands in the build ([S032](simulation_log.md), T02); test switches deal random kits, generated skills and random monsters (60 points).
- **Being tried by hand (T43, S033–S035):** Strikes that only push (damage from ground, collisions, Dragon Veins, props and a free Basic Jab beside Step), Stamina as a cost of Strikes, and the ideas of 2026-11-16. Reach 3 and pulling Strikes are dropped. If Strikes lose their damage, the price list of S032 no longer holds.
- **Played by hand:** the user plays every iteration manually; the rebuild starts when the user is satisfied with the battle ([T42](todo/open/project/T42-rebuild-the-game-cleanly-on-the-target-architect.md)). The filled stats and the new kits are not measured by a run.
- **Build and rules differ** in the places listed in [todo/implementation.md](todo/implementation.md).

## Open Questions for the User

| # | Question | Task |
|---|---|---|
| 1 | How does a stat shape split the points at the roll? | T03 |
| 2 | Do `slow` and `haste` become “the square costs more or less Stamina”, or stay a change of range? Does a movement skill keep its AP cost? | T41 |
| 3 | Which props of the catalogue stay, and do aura props return? May a prop a skill creates last for rounds only? | T41 |
| 4 | 3v3 on 7×7, 8×8 or 9×9, and how many Dragon Veins on an even board? Dragon Veins for 1v1, 2v2 and 5v5? | T39 |
| 5 | How many kit slots are open at the start of the game, and what opens the others? | T05 |
| 6 | Which pushes are cardinal, which use eight directions (written as the build plays them)? | T04 |
| 7 | How far may a shape be extended? What is the Strike effect of the Ancient Kin? | T06 |
| 8 | The Thorn Idol passes a Strike on to its neighbours in the same turn, against “fair damage at range”: keep, change or drop? | T41 |
| 9 | May effects on AP or turns per round ever reach other monsters? | T07 |
| 10 | Does the stat-zone rule and the kit rule of the nine monsters also bind kits a player composes? | T11 |
| 11 | Skill prices: is “10 points = 1 AP, a Jab with 2 damage and a push = 20 points” the form? What happens to ground, zone and prop skills, which all come out below 1 AP: stronger, a second cost, or the floor? | T02 |
| 12 | Which of the six ideas of 2026-11-16 (Stamina base cost, Erosion, Shifting Sand, props bury traps, Stamina recovery from ground, zone and buff, the new battle log) stay? Should Strikes only push and deal no damage (switch built 2026-11-17)? Should a Strike cost Stamina beside its AP, with a free Basic Jab for every monster (switch built 2026-11-17)? | T43 |

## Tasks

| ID | Task | Status | Epic |
|---|---|---|---|
| T04 | [Make Resolution Rules and Edge Cases Consistent](todo/to-clarify/battle/T04-make-resolution-rules-and-edge-cases-consistent.md) | to clarify | battle |
| T39 | [Dragon Veins: Square Control as the Way to Win by Defeat](todo/to-clarify/battle/T39-dragon-veins-square-control-as-the-way-to-win-by.md) | to clarify | battle |
| T41 | [Bring the Props, Slots and Stamina of the Build into the GDDs, or Drop Them](todo/to-clarify/battle/T41-bring-the-props-slots-and-stamina-of-the-build-i.md) | to clarify | battle |
| T43 | [Try the Ideas of 2026-11-16](todo/to-clarify/battle/T43-try-the-ideas-of-2026-11-16.md) | to clarify | battle |
| T03 | [Review Stat Budgets, Frames and Progression Limits](todo/to-clarify/monsters/T03-review-stat-budgets-frames-and-progression-limit.md) | to clarify | monsters |
| T26 | [Draft Staff Traits and Numbers](todo/to-clarify/overworld/T26-draft-staff-traits-and-numbers.md) | to clarify | overworld |
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

Finished and archived: T01, T08, T09, T33, T34, T36, T38 ([todo/archive/](todo/archive/)).

## Test Switches of the Build

Not rules; they exist to try something out. A switch becomes a rule only by a decision.

- **Board size:** 3v3 on 8×8 (Dragon Veins in mirrored pairs on the two centre rows, four by default) and on 9×9 (three on the centre row).
- **Button squares:** the three runes of [content.md §3](content.md#3-props) as mirrored pairs on the board.
- Everything else: [godot/README.md](../godot/README.md).
