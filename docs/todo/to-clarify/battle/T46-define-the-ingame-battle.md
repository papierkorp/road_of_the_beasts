# T46 · Define the Ingame Battle

**Status:** To clarify — the split into a multiplayer battle and an ingame battle on one rule core is decided (2026-11-18); what the ingame battle adds is open.
**Prerequisites:** none.
**Sources:** [battle_ingame.md](../../../battle_ingame.md); [battle.md §1](../../../battle.md#1-goals-and-pillars); [architecture.md §1](../../../architecture.md#1-two-games-and-what-they-share), [§4](../../../architecture.md#4-the-battle); [godot/README.md](../../../../godot/README.md) (battle menu, prototype screen).

**Open for the user:**

| Topic | Questions |
|---|---|
| Battlegrounds | How is one built in the overworld and what does it cost? What may it hold (ground, props, Dragon Veins, start areas)? Which sizes and outlines are legal? Whose battleground is a battle fought on, and what does the opponent bring? What does a monster gain on its own? |
| Board events | What is an event, when does it act, how is it announced? |
| Skills and functions | Which exist only ingame? May a skill of one battle appear in the other? |
| Goals | Decided: a tactics puzzle that may be unfair. Open: a length target |
| End of a battle | Which ends other than every monster of a side at 0 HP exist, and who names them? What brakes a battle without Dragon Veins? |
| Team sizes | Boards, start areas and Dragon Veins for 1v1, 2v2, 5v5 and unequal sides such as 3v1 |
| Tamer skills | Ingame only (decided); the prototype screen offers none yet |
| Core or multiplayer | Are Dragon Veins and surrounding core, or multiplayer only? |
| Growth in battle | Which stats and stages the prototype should offer; AP 5 and a third turn were never played |

- **Built so far:** the battle menu and the ingame prototype screen (points per side, board size); it plays the core rules with the switches of the build and has no battlegrounds, no board events and no skills of its own.
- **In the documents:** only [battle.md §1](../../../battle.md#1-goals-and-pillars) and §4.1 mark what is multiplayer; the other sections are not sorted yet.
- **Done when:** every row is decided and written into [battle_ingame.md](../../../battle_ingame.md) or [battle.md](../../../battle.md), with lines in [decisions.md](../../../decisions.md).
