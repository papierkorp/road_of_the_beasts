# Task Overview

The task list of the project. Rules live in the rule files ([battle.md](battle.md), [skills.md](skills.md), [monsters.md](monsters.md)), content drafts in [content.md](content.md), decisions in [decisions.md](decisions.md). **Open questions, alternatives and handoffs live only here.**

## How the Task Folder Works

```
docs/todo/
  to-clarify/<epic>/   waits for a decision of the user
  open/<epic>/         can be worked on
  in-progress/<epic>/  being worked on
  done/<epic>/         finished; later moved to archive/
  archive/             old finished tasks
  ideas.md             ideas without a task
  implementation.md    where the build differs from the rules
```

- **One task, one file:** `T<number>-<slug>.md`. Epics: `battle`, `skills`, `monsters`, `overworld`, `project`.
- **A status change moves the file** to the other folder; the table below is updated in the same step.
- **A task file holds:** status, open points and “done when”. A decision goes to [decisions.md](decisions.md), a rule to its rule file; neither stays in the task.
- Numbers are never reused.

## Current State

- **Two battles on one core,** developed in parallel ([battle_ingame.md](battle_ingame.md), [architecture.md §4](architecture.md#4-the-battle)): the multiplayer battle and the ingame battle. Everything measured so far is multiplayer.
- **Multiplayer battle, settled for now:** always 3v3 on a generated symmetric 7×7 board, no tamer skills, no fixed monsters or skills; last touch owns a Dragon Vein, damage from round 1, veins deal 2 from round 3, no late-round pressure, extra turns from round 2, Heal (1 HP for 3 Stamina, no AP, once per turn), a free camera; plus the rules of 2026-11-17.
- **Multiplayer content:** monsters drawn for 60 points (Random Alpha, Beta, …), kits of generated skills, grounds and zones named by what they do ([content.md §1](content.md#1-ground)). The nine monsters and the named grounds and zones are ingame content, all temporary.
- **Build:** main menu → Battle → Ingame Prototype (points per side) or Multiplayer (random monsters, or the same for both sides). The draft comes with the rebuild (T48).
- **Measured on 2026-11-18** ([S040–S045](simulation_log.md), bots, indications): at equal points more HP wins more often, Reach less; Pace and Stamina show no worth; Heal lengthens a battle by 0.1–0.5 rounds. **Not measured:** Heal without AP, the settled state as a whole, the new grounds and zones.
- **Next:** define the ingame battle (T46) and the draft (T48); skill prices ([T02](todo/open/skills/T02-find-skill-prices.md)): the list of S032 does not hold on the new rules.
- **Tests:** three known failures: two outside the battle (I46), and the content test for the user's monster `highreach` (Reach 6).
- **By hand:** the user plays every iteration; the rebuild starts when satisfied ([T42](todo/open/project/T42-rebuild-the-game-cleanly-on-the-target-architect.md)). Build and rules differ where [todo/implementation.md](todo/implementation.md) says.

## Open Questions for the User

| # | Question | Task |
|---|---|---|
| 1 | How does a stat shape split the points at the roll? | T03 |
| 2 | Ingame battle: battlegrounds, board events, ends other than 0 HP, a brake without Dragon Veins, ingame-only skills | T46 |
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
