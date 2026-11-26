# T19 · Complete Battle Loadout and Timing

**Decided:** —
**Built/Measured:** Visibility, pre-battle selection and the result fields exist ([overworld.md §6.5](../../../overworld.md#65-loadout)); what a weapon's skill or a pill does on the board and the full result contract are open.
**Prerequisites:** T58 for the effects of pills and weapons; T57 for the tamer skills. Complete before full-scope T13.
**Sources:** [battle_ingame.md §5](../../../battle_ingame.md#5-tamer-skills); [overworld.md §2.1](../../../overworld.md#21-battle-loop), [§6.5](../../../overworld.md#65-loadout), [§7](../../../overworld.md#7-technical-notes).

- Define the activation window, battle-AP cost and consumption of a pill and of a weapon's skill beside the window of tamer skills ([battle_ingame.md §5](../../../battle_ingame.md#5-tamer-skills)).
- **Result schema:** define the full output contract: the Draw, per-monster HP and defeat facts, kill attribution, catches and used-up pills (I29).
- **Request inputs beyond the loadout:** HP carried through a dungeon run and the player's own battleground in the void enter through the request; list its fields once, in [overworld.md §7](../../../overworld.md#7-technical-notes).
- If tamers appear as opponents (T55), the same rules and visibility apply to them.
- **Done when:** activation windows, costs, consumption, visibility and the result contract are specified in [overworld.md §6.5](../../../overworld.md#65-loadout), [§7](../../../overworld.md#7-technical-notes) and [battle_ingame.md §5](../../../battle_ingame.md#5-tamer-skills).
