# T43 · Try the Ideas of 2026-11-16

**Status:** To clarify — six ideas of the user are built as test switches and experiment content, so that they can be played and measured. None is a rule; each becomes one only by a decision.
**Prerequisites:** the user's play of the build.
**Sources:** [godot/README.md](../../../../godot/README.md) (switches and how they are built); [battle.md §2.4](../../../battle.md#24-action-points-and-stamina), [battle.md §4.7](../../../battle.md#47-props); [simulation_log.md](../../../simulation_log.md) S032.

| Idea | Built as | Reading chosen while building (to confirm) |
|---|---|---|
| 1 Stamina base cost of a movement skill, on top of the cost per square | number switch “Stamina base cost” (0 = the rule) | paid once per use of every movement skill, Step included |
| A zone that damages props | zone **Erosion** (experiment) | every prop in it takes 1 at the round end, in the acting part; monsters are not touched |
| Ground that allows no props | ground **Shifting Sand** (experiment) | no prop can be placed on it; a prop that stands there when it is laid, or is pushed onto it, breaks |
| A prop defuses a trap | switch “Props bury traps” | a solid prop placed on or pushed onto a trap removes the trap without setting it off |
| Stamina recovery from the board | ground **Springwater** (experiment): +1 Stamina on entering; zone **Updraft** (experiment): +1 recovery at the round end while inside | Stamina never rises above the pool |
| Stamina recovery as a self buff | skill **Deep Breath** (experiment): +1 recovery for its duration | same effect tag as Updraft (`refresh`) |
| A battle log that explains a defeat | every damage line names its source; the defeat line names the last hit and what else hit in that round; a button per fallen monster opens its whole HP history | built without a switch |

- **Open for the user:** keep, change or drop each row; for those that stay, the rule text and the values.
- **Open details:** whether Step pays the base cost too (the build: yes); whether a walkable prop (a trap) buries another trap; whether Shifting Sand also refuses traps (the build: yes, every prop); whether Erosion should also wear cover faster than a Strike does; what the three Stamina sources cost ([T02](../../open/skills/T02-find-skill-prices.md)).
- **Measured:** S032 holds one series with the base cost and trap burying switched on and the experiment content in the pool; it is an indication only.
- **Done when:** the user has played the switches and decided each row; what stays is written into the rule files and [content.md](../../../content.md), what goes is removed from the build and the README.
