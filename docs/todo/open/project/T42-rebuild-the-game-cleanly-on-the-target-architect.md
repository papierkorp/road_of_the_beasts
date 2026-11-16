# T42 · Rebuild the Game Cleanly on the Target Architecture

**Status:** Open — the target is [architecture.md](../../../architecture.md); the order of the rebuild is its [§10](../../../architecture.md#10-the-rebuild). Everything is written anew, the rules too.
**Prerequisite:** the user says they are satisfied with the battle in manual play (the gate is the prototype, not the rebuild). Before the start every entry of [implementation.md](../../implementation.md) is a rule or dropped, put to the user in bundles. From the start the battle rules rest until the rebuilt battle can be played by hand. Overworld work stays behind the battle.
**Sources:** [architecture.md](../../../architecture.md); [battle.md §7](../../../battle.md#7-technical-requirements); [godot/README.md](../../../../godot/README.md); [godot/tools/README.md](../../../../godot/tools/README.md); I56/I57, I74.

**Open points:**

- **Contract (step 1):** the draft is [contract.md](../../../contract.md); the user has not accepted it. Not defined: which side places first ([battle.md §2.2](../../../battle.md#22-core-loop)); how the AI places; whether the player picks the route of a walk or only its destination (T04); what conceding costs in the overworld. To settle in the one revision: the map generator belongs into the content fingerprint; `options()` as a full list can grow very large with free paths and shapes.
- **Comparison (step 4):** the converter from prototype recordings to contract actions (placement phase, unit and prop IDs).
- **Tests (step 3):** which prototype tests become the specification; the test switches of `BattleExperiment` that are no rule are not rebuilt.
- **AI:** design of the mid-strength opponent and its budget in evaluated states (I42).
- **Multiplayer mode:** how creating monsters, skills and maps becomes part of its play (user idea: the players build in turns); the map generator.
- **Online play:** a plan only; built on the user's explicit go. Transport and matchmaking are not defined.
- **Loadout items:** the record form of what a medicine or an array does in battle (T18, T19).
- **Dialogue and story:** [architecture.md §5–§6](../../../architecture.md#5-dialogue) are a sketch; fix them with a branching trial piece before the first real dialogue. Not defined: which dialogue a person offers at a given moment.
- **Player-made content:** its plain-data form and the place of its migrations.

**Done when:** the rebuilt battle passes the rewritten rule tests and the comparison with recorded prototype battles. Equal results are a regression check, not gameplay validation.
