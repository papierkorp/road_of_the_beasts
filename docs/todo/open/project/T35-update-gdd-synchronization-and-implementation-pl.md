# T35 · Update GDD Synchronization and Implementation Plan

**Decided:** —
**Built/Measured:** Relative references are checked (all resolve, 2026-11-15). Part of the K batch was worked on 2026-11-15 together with the decisions of that day; the rows below remain. Whole-project synchronization closes last, not from this refresh alone.
**Prerequisites:** none for the K batch; the waiting points need the named decision; overall completion after the other tasks.
**Sources:** [battle.md §7](../../../battle.md#7-technical-requirements), [monsters.md §5](../../../monsters.md#5-growth), [overworld.md §5.1](../../../overworld.md#51-stages), [overworld.md §7](../../../overworld.md#7-technical-notes); the sections named per row.
- **Archived task numbers in open tasks:** the frame of [vision.md](../../../vision.md) archived T15–T18, T20–T31, T51 and T52. Where an open task still names one, its successor is: T16, T17, T18 → T58; T20 → T57; T21, T22 → T55; T24 → T59; T29, T31 → T54; T30 → T56; the others have none. Reword those mentions when the task is next worked on.
- **K batch — text behind decisions already taken; no user decision needed (each row re-verified against the text on 2026-11-15):**

| Where | Stale or inconsistent text | Correct against |
|-------|----------------------------|-----------------|
| Skills §5 | calls the one-vein control test-only without the later switches | the log runs to S030 (S025–S030: battle-length switches, charged veins, prop rework, Stamina, board sizes) |
| Battle §1.1; Monsters §5.1, §5.2; Overworld §6.3 | kit “rarity exceptions”, rarity “buys slots”, “new rarity's slots/caps”, “rarity slots” | the Epic+ extra passive slot is struck (2026-11-14); rarity gives development steps and the maximum stage |
| Monsters §6 | “Major/Signature access: T32”; “runtime reconciliation: T04/T07–T09” | Majors went with Surges; T08 and T09 are closed |
| Overworld §6.3 | the Immortal and Sovereign rows list neither AP 4 nor AP 5 | Monsters §2.3/§5.3 (what the step grants: T03) |
| Overworld §5.2, §6.4, §6.6 | prose still calls Life Thread and Second Wind “proposed” | confirmed 2026-11-11 (Battle §5.2); the §6.4 table is right |
| Overworld §6.7 | example “range of the own-monster repositioning skill” | Spatial Pull dropped 2026-11-14 |
| Overworld §4.3 | footprint example “stationary 2×2 monster = 4” | 2×2 bodies out of scope (T09) |
| Overworld §6.9 | “no gear, pill or evolution raises …” | no evolution exists (T36) |
| Overworld §8 | the result line lacks the Draw | Overworld §2.1, [architecture.md](../../../architecture.md) §3 |
| [godot/README.md](../../../../godot/README.md), [tools](../../../../godot/tools/README.md) | counts of executed checks, to keep current with T13 | the handoff above |

- **Corrected on 2026-11-15 (no longer in the batch):** the evidence ranges of the Skills and Monsters GDDs (now to S030); T41 in the task list of the Skills scope; “dispatch due events” in Battle §2.1; the `snare` id in Battle §4.4; the passive row of Battle §5.1; Reach in the sheet of Monsters §1.2; “Kin lock-outs” in Skills §1; “(Dive, below)” in Skills §8.1; the README's S030 citation, owner mark and kit size; the build drafts named in `CLAUDE.md`.
- **Waiting for a decision (do not correct before it):**
  - **T05:** the slot counts in Monsters §1.3/§5.3 and Overworld §6.3 (how many slots a monster starts with in the game).
  - **T04:** the displacement directions of Battle §6.4 and the measure of Reach, written as the build plays them.
  - **T41:** which props and prop skills of the catalogue keep their rows in Battle §4.10 and Skills §10/§11.
  - **T03:** the Pace ceilings of Monsters §2.3 (converted only).
  - **T11:** the “species passive” of Overworld §8.
  - **T20:** Sovereign's “full spatial arsenal” in Overworld §6.3.
  - **T02:** how the AP values of Skills §8.1/§11 are labelled against “nothing has a price” in §5.
- **Remaining consistency review:**
  - [monsters.md §2.2](../../../monsters.md#22-prices-and-points)/[monsters.md §2.1](../../../monsters.md#21-the-stats): retain explicit unvalidated four-frame calculation status; T03 owns HP base/ceiling and roll-versus-growth conflicts, not a return to the old six-frame/31-point account.
  - Overworld unlock/equipment interfaces still need the T17/T32 decisions; Draw result/consequences are explicitly open under T19/T23. The missing-Draw finding is resolved in Battle §2.1 and Overworld §2.1; of the Life Thread/Second Wind labels only the prose remnants of the batch remain.
  - Spirit Shield and two arrays remain deliberately open under T18/T20; explicit open status is not a synchronization failure.
  - Keep future source/anchor changes synchronized. Current Skills §7 and Godot README agree on the initially unfiltered debug overview and the simulation-only gameplay exclusion; historical S020–S024 reports retain their recorded state.
- Keep change history in Git, not in the GDDs or this task list; update the development phases once the battle stands.
- **Done when:** all other tasks are closed or consciously deferred, tables and references are synchronized and prototype comparisons are limited to what distinguishes implementation from design.
