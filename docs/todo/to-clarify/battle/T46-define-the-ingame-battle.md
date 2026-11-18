# T46 · Define the Ingame Battle

**Status:** To clarify — the split into a multiplayer battle and an ingame battle on one rule core is decided (2026-11-18); what the ingame battle adds is open.
**Prerequisites:** none.
**Sources:** [battle_ingame.md](../../../battle_ingame.md); [battle.md §1](../../../battle.md#1-goals-and-pillars); [architecture.md §1](../../../architecture.md#1-two-games-and-what-they-share), [§4](../../../architecture.md#4-the-battle); [godot/README.md](../../../../godot/README.md) (battle menu, prototype screen).

**Open for the user:**

| Topic | Questions |
|---|---|
| Battlegrounds | Decided and built as a map editor: outline, ground, Dragon Veins, props, zones with rounds, start areas ([battle_ingame.md §3](../../../battle_ingame.md#3-battlegrounds)). Open: how one is built in the overworld and what it costs; which content a player may use; whose battleground a battle is fought on and what the opponent brings; what a monster gains on its own; where the opponent stands in its area; size limits (3–12 is a working value) |
| Board events | What is an event, when does it act, how is it announced? |
| Skills and functions | Which exist only ingame? May a skill of one battle appear in the other? |
| Goals | Decided: a tactics puzzle that may be unfair. Open: a length target |
| End of a battle | Which ends other than every monster of a side at 0 HP exist, and who names them? What brakes a battle without Dragon Veins? |
| Team sizes | Boards, start areas and Dragon Veins for 1v1, 2v2, 5v5 and unequal sides such as 3v1 |
| Tamer skills | Ingame only (decided); the prototype screen offers none yet |
| Core or multiplayer | Are Dragon Veins and surrounding core, or multiplayer only? |
| Growth in battle | Which stats and stages the prototype should offer; AP 5 and a third turn were never played |

- **Built so far:** the battle menu, the ingame prototype screen (points per side, board size, a custom map with team sizes per side) and the map editor. No board events, no tamer skills in the prototype, no skills of its own; the monsters are drawn, the nine fixed monsters are not used yet.
- **In the documents:** only [battle.md §1](../../../battle.md#1-goals-and-pillars) and §4.1 mark what is multiplayer; the other sections are not sorted yet.
- **Done when:** every row is decided and written into [battle_ingame.md](../../../battle_ingame.md) or [battle.md](../../../battle.md), with lines in [decisions.md](../../../decisions.md).
