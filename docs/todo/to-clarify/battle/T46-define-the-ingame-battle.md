# T46 · Define the Ingame Battle

**Status:** To clarify — the split into a multiplayer battle and an ingame battle on one rule core is decided (2026-11-18); what the ingame battle adds is open.
**Prerequisites:** none.
**Sources:** [battle_ingame.md](../../../battle_ingame.md); [battle.md §1](../../../battle.md#1-goals-and-pillars); [architecture.md §1](../../../architecture.md#1-two-games-and-what-they-share), [§4](../../../architecture.md#4-the-battle); [godot/README.md](../../../../godot/README.md) (battle menu, prototype screen).

**Open for the user:**

| Topic | Questions |
|---|---|
| Battlegrounds | Decided and built as a map editor: outline, ground, Dragon Veins, props, zones with rounds, start areas ([battle_ingame.md §3](../../../battle_ingame.md#3-battlegrounds)). Decided: every place brings its battlegrounds, the player's own counts in the void only and is built from blueprints and materials; its limits and costs: T56. Open here: where the opponent stands in its area; size limits (3–12 is a working value) |
| Board events | Decided: none ([battle_ingame.md §4](../../../battle_ingame.md#4-board-events)) |
| Skills and functions | Which exist only ingame? May a skill of one battle appear in the other? |
| Goals | Decided: a tactics puzzle that may be unfair. Open: a length target |
| End of a battle | Decided: as in the core, every monster of one side at 0 HP; no other end ([battle_ingame.md §2](../../../battle_ingame.md#2-team-sizes-and-the-end-of-a-battle)) |
| Team sizes | Decided: every board of the game is a battleground, its start areas set the team size; the generated boards stay a prototype tool |
| Tamer skills | Ingame only (decided); the prototype screen offers none yet. Catching on the board is decided ([battle_ingame.md §7](../../../battle_ingame.md#7-catching)); its details: T49 |
| Core or multiplayer | Decided: Dragon Veins and surrounding are core; the map decides whether veins lie on it |
| Growth in battle | Which stats and stages the prototype should offer; AP 5 and a third turn were never played |

- **Built so far:** the battle menu, the ingame prototype screen (points per side, board size, a custom map with team sizes per side) and the map editor. No tamer skills in the prototype, no skills of its own; the monsters are drawn, the nine fixed monsters are not used yet.
- **In the documents:** only [battle.md §1](../../../battle.md#1-goals-and-pillars) and §4.1 mark what is multiplayer; the other sections are not sorted yet.
- **Done when:** every row is decided and written into [battle_ingame.md](../../../battle_ingame.md) or [battle.md](../../../battle.md), with lines in [decisions.md](../../../decisions.md).
