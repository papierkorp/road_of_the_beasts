# T21 · Define the Dungeon Node ↔ Board Generator Contract

**Status:** Open — board-generation/BattleRequest contract prioritized for Battle; dungeon-node content and healthy-team availability follow afterward.
**Prerequisites:** T04 board rules for generator inputs now; T12 for final opponent/roster coverage tests. No full dungeon/loot/capacity design prerequisite to the board contract.
**Sources:** [overworld.md §3.3](../../../overworld.md#33-dungeons); [battle.md §4.1](../../../battle.md#41-board-generation).
- **Battle deliverable:** finish the allowed board-generation inputs, mode/team-size constraints and deterministic placement responsibility before final T13; test requests can supply these without a whole dungeon run. **Meta deliverable:** populate dungeon nodes and check healthy-team/capacity access after the gate.
- Node-owned mode and wild-monster count are already the working design in Overworld §3.3. Define the remaining parameters: theme/ground families, prop-count ranges, start areas and seed/placement responsibility. Point-symmetric generation remains Battle §4.1's constraint; assigning all these parameters to the node is only a proposal.
- Check encounter access against required team size and available healthy monsters.
- [ ] **Board generator and “button” squares (user idea; built as a switch 2026-11-15):** the generator places `map_buttons` mirrored pairs of runes on free squares outside the start areas, never on a Dragon Vein or a prop, drawn by the board seed (I64). Decide after play whether they become part of the board contract (how many, where, fairness); effect values: T07.
- **Inputs the build already varies (switches, no contract):** the Dragon Vein count (0–7 on 7×7), mirrored prop pairs (-1 = layout, 0 = none, N random pairs) and button pairs (0–4) are number fields of the draft screen. Decide which of them a node may set and which the mode fixes; Dragon Veins for 1v1, 2v2 and 5v5 are T39.
- **Done when:** the node ↔ generator contract is recorded in Overworld §3.3 and Battle §4.1.
