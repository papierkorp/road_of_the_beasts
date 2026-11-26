# T31 · Finalize Day-AP and Action Costs

**Archived (2026-11-21):** replaced by T54 (lifespan, day AP and the length of a game), by the frame of [vision.md](../../../vision.md). The text below is the state before it.

**Closed:** replaced by T54 with the new frame of the game ([decisions.md](../../../decisions.md)).
**State before closing:** Open — blocked by T22, T25, T28–T30; day-AP curve is a proposal only.
**Prerequisites:** T22, T25, T28–T30.
**Sources:** Overworld [overworld.md §2.3](../../../overworld.md#23-day-loop), [overworld.md §2.6](../../../overworld.md#26-action-catalog).
- Review proposed 3/4/4/5/5/6 AP per Stage and Arena price per tournament round.
- Balance expeditions, cultivation, story and work against each other; account for staff reducing the workload.
- Keep free decisions/queuing/rearranging consistent with paid execution. Decide whether AP reaching 0 immediately ends the day (§2.3) or still permits free healing/harvesting/queueing/planning before night; do not assume one from UI convenience. Include dependency-aware night resolution (production inputs, hatching capacity, recovery and idle XP), not an undefined simultaneous write order.
- **Done when:** day-end/free-action boundary and dependency-aware night resolution are explicit, and the day-AP curve/every action cost in [overworld.md §2.6](../../../overworld.md#26-action-catalog) are compared with documented current-design economy/pacing tests. No arithmetic-only balance closure.
