# T45 · Pace Ideas of 2026-11-17

**Status:** Done — decided by the user on 2026-11-17 without play ([decisions.md](../../../decisions.md)).
**Sources:** [battle.md §2.3](../../../battle.md#23-pace-and-the-queue), [battle.md §4.2](../../../battle.md#42-dragon-veins-surrounding-and-late-round-pressure); [monsters.md §2](../../../monsters.md#2-stats); [T44](T44-review-pack-of-2026-11-17.md).

**Why:** Pace orders the queue and gives the Stamina recovery. The recovery is dear for what it gives (Pace 2.0 costs 10 points for 3 more Stamina in a battle of four rounds; the same 3 in the pool cost 6), and acting early has no clear worth while the last touch of a round takes a Dragon Vein. The price of Pace stays; the whole number of Pace gives more, and the tenths decide ties.

| Idea | Outcome |
|---|---|
| Wait is bought with Pace: as many Waits per battle as the whole number of Pace lies above 1 | rule |
| Dragon Veins act in Pace order: the vein of the faster taker first | rule |
| Of several monsters one push or pull moves, the slower one is moved first | dropped: the queue order stays |

- **Left as it is:** Pace below 2.0 buys only the order; a monster at Pace 1.0 still acts last for nothing.
- **To watch in play:** is Pace bought exactly to 2.0, or beyond it to outbid the other team; is the one Wait spent in a round where it decides a vein; does a monster that falls first at the round end read as earned.
- **Not measured.** Rule tests: `tests/battle/test_review_pack.gd`.
