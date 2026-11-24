# Implementation Notes

Where the Godot build (`godot/`; layout and commands: [godot/README.md](../../godot/README.md)) differs from the rule files, chose a solution the rules do not name, or lacks something. **This file decides no rule.** A question is decided in its owning section under the named task; the code and its test follow.

- **For the rebuild** ([architecture.md §10](../architecture.md#10-the-rebuild)): before it starts, every row of §1 to §3 has become a rule or is dropped. §4 to §6 need no decision.
- IDs (`I..`) are stable and never reused; a row is removed once the code, its test and the owner section agree. Removed IDs are listed at the end.

## 1. The Build Differs from a Rule

None.

## 2. Battle: Solutions Without a Rule

None.

## 3. Hub: Solutions Without a Rule

None. Every number of the hub is a test value in `godot/data/game/values.tres`; the rule files hold them as working values.

## 4. Not Built

| ID | Missing | Task |
|----|---------|------|
| I19 | Signature skills (the `once_per_battle` use limit exists) | T32 |
| I26 | Event-driven passives beyond one event (built: a prop destroyed within Reach heals) | T11 |
| I28 | The choice of start squares by the enemy side: it takes the default squares of its area | T55 |
| I29 | The final result schema: kill attribution | T19 |
| I42 | An opponent between the one-step `AiBrain` and the slow whole-turn bot of the tools; the AI makes no placement choice and knows neither Seal Ground nor moved props | T13 |
| I54 | A “who is hit next” hint for Dragon Veins in the view | T39 |
| I145 | Development of tamer skills other than Seal; trees of the Ways beyond Nascent Soul; an AI that uses tamer slots; translation, sound and save versions ([architecture.md](../architecture.md)) | T57, T42 |
| I146 | On a touch screen: what a tooltip says, larger arrows of number fields, a start screen of the game's own | T60 |

## 5. Leftovers in the Code

Not rebuilt ([architecture.md §10](../architecture.md#10-the-rebuild)); nothing of the game reaches them.

| ID | Leftover |
|----|----------|
| I56 | The removed mechanics: height and Mountains, the air layer, Surges and their traps, the shield, `mend` and `expose` effects, with their texts, view parts, AI terms and the tests that build them by hand |
| I57 | Levels of ground and zones, the self retreat of a Strike, the opposites of stat effects, price entries of archived records, `sim.gd` variants of removed switches |
| I30 | Bodies of 2×2 squares: rules, tests and fields |
| I10 | Late-round pressure (`pressure_mode`, Voidscar spreading, `soft_pressure`); the older rule tests still play it |
| I75 | Old names and models: `movement` / `move` hold the Stamina pool; stage caps and stat shapes of the earlier overworld; comments that cite the earlier GDD files (`gdd_battle §…`) |
| I147 | About half of the skill, prop and zone records carry the status `archived` |

## 6. Verification and Code Follow-ups

| ID | Point |
|----|-------|
| I40 | The user has played the battle by hand; the hub game was clicked through on a phone by an agent. No one has played a whole game of any Way |
| I44 | `UnitSheet.problems()` is checked in tests, but `BattleSetup` does not refuse an illegal sheet |
| I45 | `BattleContent.VERSION` is bumped by hand; only `fingerprint()` is derived from the definitions |
| I48 | No planned scenario of T13 has been played on the build; bot runs: [simulation_log.md](../simulation_log.md) |
| I58 | The skill builder cannot build passives other than Immovable, cannot edit an existing skill's fields from its file and has no “remove from kit” |

*Removed, their object is gone or the rule file now says the same: I01–I09, I11–I13, I16–I18, I20–I25, I43, I46, I51–I53, I55, I59–I74, I76–I105, I110, I111, I119, I120, I122, I123, I125, I126, I131–I144.*
