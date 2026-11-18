# T44 · Review Pack of 2026-11-17

**Status:** Done — decided on 2026-11-18 ([decisions.md](../../../decisions.md)): veins deal 2 from round 3 and there is no late-round pressure (rules); damage from round 1 (the calm round 1 is dropped); the camera tilts freely. The text below is the state before the decision.
**Prerequisites:** the user's play of the build.
**Sources:** [godot/README.md](../../../../godot/README.md) (switches); [battle.md §3](../../../battle.md#3-timing), [battle.md §4.2](../../../battle.md#42-dragon-veins-surrounding-and-late-round-pressure), [battle.md §6.1](../../../battle.md#61-damage); [skills.md §2](../../../skills.md#2-the-skill-card); [simulation_log.md](../../../simulation_log.md) S039; [T43](../../to-clarify/battle/T43-try-the-ideas-of-2026-11-16.md).

**Decided on 2026-11-17** ([decisions.md](../../../decisions.md)), now rules without a switch: a Strike pushes every struck square; no Kin effect on Strikes; zones only push or pull, one level; ground has one level; nothing but Dragon Veins and surrounding deals damage at the round end; a prop a skill creates lasts 2 rounds; Strikes deal no damage to monsters and what the card names hits props; Wait, bought with Pace ([battle.md §2.3](../../../battle.md#23-pace-and-the-queue)). Dropped: a kit slot once per round; a Wait once a round for everyone.

| Proposal still open | Switch (build default) | Why it was proposed | Decision it would reopen |
|---|---|---|---|
| Dragon Veins deal 2 from a set round | `vein_late_round` 3 (a board value of the draft: the user sets the round), `vein_late_damage` 2 | the brake for long battles should be square control, not an arena effect | — |
| No late-round pressure | `pressure_mode` “none” | it cannot run once a vein is touched; every map has at least one vein | pressure stays (2026-11-14) |
| No damage in round 1 | `damage_from_round` 2 | “where possible no monster is defeated in round 1” | — |
| A round-end forecast in the HUD | no switch | much of the damage falls at the round end | — |

- **Readings chosen while building (to confirm):**
  - Round 1 without damage: pushes, ground and Dragon Vein ownership work, every damage is 0.
  - The forecast is a dry run of the round end on the board as it stands; the turns still to come can change it.
  - Late-round pressure is the brake of a mode without Dragon Veins (1v1 and 2v2 have none yet, [T39](../../to-clarify/battle/T39-dragon-veins-square-control-as-the-way-to-win-by.md)): with the switch on, such a battle has no brake.
- **Readings that became rules with the decisions:** a farther square is pushed along its line from the striker, a square on no line in the facing of the shape; the damage of a prop hits a monster that ends its turn in the prop's shape, pushes of round-end props stay at the round end; a lapsing prop does nothing, traps lapse too, props of the board stay; the same ground or zone laid again restarts its clock.
- **Measured before the decisions ([S039](../../../simulation_log.md), bots, indications only; mean rounds · battles under 3 · over 5 rounds, greedy of 320):** the rules 3.75 · 37 · 23; the build before the pack 4.18 · 14 · 38; the pack with veins at 2 from round 5: 4.47 · 1 · 34, from round 4: 4.26 · 1 · 17, from round 3 (the build default since): 4.04 · 1 · 13. The first defeat moves from round 1.89 to 2.39. `tactic` (of 160): before 4.42 · 5 · 27, the pack with round 5: 4.88 · 0 · 33; round 3 was not run with it. Only two switches move the length: the calm round 1 (alone 4.57 · 4 · 58) and the stronger veins (alone, from round 5: 4.10 · 14 · 25). Every other switch stays inside the noise for these bots, Wait included. Draws rise with stronger veins (7 before, 11–24 of 320). On 9×9 with five veins the pack reads 4.43 · 0 · 13 with 33 Draws.
- **Open for the user:** keep, change or drop each row after play; for those that stay, the rule text. The questions of the review that only the user can answer: whether square control is a goal or a means and whether control means “touched last” or “held”; what Pace is for; a target for the battles under 3 and over 5 rounds; whether 1v1 and 2v2 get Dragon Veins.
- **Done when:** the user has played the pack and decided each row; what stays is written into the rule files with a line in [decisions.md](../../../decisions.md), what goes is removed from the build and the README.
