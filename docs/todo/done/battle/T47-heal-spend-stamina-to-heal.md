# T47 · Heal: Spend or Burn Stamina to Heal

**Status:** Done — decided on 2026-11-18: Heal is a rule of both battles, 1 HP for 3 Stamina and no AP, once per turn ([battle.md §2.4](../../../battle.md#24-action-points-and-stamina)); the switches are removed from the build. The text below is the state before the decision.
**Prerequisites:** the user's play of the switch.
**Sources:** [godot/README.md](../../../../godot/README.md) (switch `heal_burn`); [battle.md §2.4](../../../battle.md#24-action-points-and-stamina); [monsters.md §2.2](../../../monsters.md#22-prices-and-points); [simulation_log.md](../../../simulation_log.md) S040–S045 (the action is called Mend up to S044); [T03](../../to-clarify/monsters/T03-review-stat-budgets-frames-and-progression-limit.md), [T40](../../open/battle/T40-reshape-the-square-and-the-skills.md).

**Why:** at equal points, monsters with more HP won more often in S040 and S041, and Pace and Stamina showed no worth with the bots. The idea gives Stamina a second job: a reserve of HP that costs mobility for the rest of the battle.

**The switch as built (draft values):**

| Point | Value |
|---|---|
| Who | every monster, beside Step and the Basic Jab |
| Cost | 1 AP (with the second switch `heal_pays_stamina`: 1 Stamina from the pool and no AP) and N maximum Stamina for the rest of the battle (N is the switch; proposed 2); Stamina above the new maximum is lost |
| Effect | heals 1 HP, never above the maximum HP |
| Limits | once per turn; not at full HP; the maximum Stamina never falls below 1 |

- **Variant without burning (user idea, same day):** switch `heal_spend` N: Heal costs 1 AP and N Stamina from the pool, the maximum stays and the Stamina comes back with the recovery by Pace; a monster with a maximum below N can never heal.
- **Readings chosen while building (to confirm):** burning Stamina instead of Pace (Pace already orders the round, sets the recovery and buys Waits); an action of every monster instead of a skill (the stat is then worth the same to all); healing works in a round without damage too.
- **Measured, not played ([S042](../../../simulation_log.md), bots, indications only; greedy of 320, damage and extra turns from round 1; mean rounds · battles under 3 · over 5 rounds):** without Heal 3.53 · 26 · 7, with Heal at 2 Stamina per HP 3.66 · 20 · 13. The bots heal 1.95 times per battle; the win rate over the Stamina values stays flat and the HP slope stays. At 1 Stamina per HP ([S043](../../../simulation_log.md)): 3.84 · 14 · 19 for 1 AP with 4.31 uses per battle, and 3.99 · 11 · 24 paid with 1 Stamina instead of the AP with 8.20 uses; Stamina stays flat in both. Without burning, for 1 AP and 3 Stamina from the pool (`heal_spend` 3, [S044](../../../simulation_log.md)): 3.65 · 19 · 15 with 1.82 uses; Stamina 7 and 8 read 53 % and 55 % (inside the noise). With 2 HP per Heal at the same cost (`heal_amount` 2, [S045](../../../simulation_log.md)): 3.83 · 15 · 17 with 2.65 uses; Stamina 2 reads 46 %, Pace 2.0 and more 52 % (inside the noise), the HP slope stays. The opponent AI weighs a point of maximum Stamina as 3 against 10 for an HP; that weight is a guess.
- **Open for the user:** keep or drop after play; the rate (Stamina per HP), the AP, once per turn or once per round; whether healing lengthens battles beyond the length target and invites standing still instead of the fight for Dragon Veins.
- **Done when:** the user has played it and decided; if it stays, the rule goes into [battle.md §2.4](../../../battle.md#24-action-points-and-stamina) with a line in [decisions.md](../../../decisions.md); if not, the switch leaves the build and the README.
