# T62 · Build the Board Rules of 2026-11-22

**Status:** Built, to confirm. The rules are decided and written (user, 2026-11-22; [decisions.md](../../../decisions.md)) and the build plays them ([godot/README.md](../../../../godot/README.md), tests `tests/battle/test_board_rules.gd`); the readings below wait for the user.
**Prerequisites:** none.
**Sources:** [battle.md §3](../../../battle.md#3-timing), [§4.2](../../../battle.md#42-dragon-veins-surrounding-and-late-round-pressure), [§4.5](../../../battle.md#45-ground), [§4.6](../../../battle.md#46-zones), [content.md §3](../../../content.md#3-props).

Core rules: they hold in the multiplayer battle and in the ingame battle.

- [x] **Dragon Vein:** at the round end every vein, owned or not, deals 1 to the monster or prop on its square, in one step after surrounding and before the owned veins act.
- [x] **Zones on arriving:** a push or pull zone moves a monster whose move ends in it (Step, landing of a movement skill, push, pull) at once; squares passed over do not count; once per action; the move at the end of the turn stays. The preview shows the landing.
- [x] **Ground and props:** entry and exit ground damage a prop a push or pull moves; end-of-turn ground damages the props on it at the round end. No healing, no Stamina.
- [x] **Zones that damage props are gone:** remove `prop_damage_zone` and `erosion` from `godot/data/zones/`, `FieldEffect.ERODE`, the skill generator, the kit draw and their tests.
- [x] **Traps:** a Burst Trap record; the Vortex Trap pulls its 4 neighbours.
- [x] **Opponent AI:** it sees zones on arriving through its dry runs and counts the cost of staying on a vein, a vein lock by the HP the prop has left, and a prop that ground or a vein wears down. Not played against by hand yet.
- [x] Rule tests (gdUnit) for each point; [godot/README.md](../../../../godot/README.md) follows.

**Readings chosen while writing (to confirm):**

- A prop that falls to 0 HP on the ground it is pushed off stays on that square and acts from there, like a monster defeated on leaving.
- The zone move also follows a self retreat after a Strike and the swap of two allies.
- The preview shows the landing as a text line ("→ square (zone)"); the highlighted square is still the one stepped onto.
- The own-square damage of all veins is one step, not part of each vein's turn in the order of the takers.
- "Once per action" counts for all zones together: after a zone has moved a monster, no zone moves it again in that action, so a Strike into a zone moves two squares at most.
- A prop standing in a zone is still moved at the round end only, not when it is pushed in.
- Board generation may start a prop on damaging ground or on a Dragon Vein; it then loses 1 HP per round by itself.

**Measured:** [S046](../../../simulation_log.md) (bots): about a quarter of a round shorter under both bots, fewer battles over 5 rounds, more under 3 under greedy; the bots keep standing on veins. What each rule does by itself is not measured.

**Done when:** the build plays the rules, the tests pass and the user has confirmed the readings.
