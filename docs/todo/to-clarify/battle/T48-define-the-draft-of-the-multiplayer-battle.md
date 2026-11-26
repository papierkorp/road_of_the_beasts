# T48 · Define the Draft of the Multiplayer Battle

**Built/Measured:** The basic idea is the user's (2026-11-18); the draft is built only in the rebuilt code (T42), not in the prototype.
**Prerequisites:** skill prices (T02): a draft is fair only if every offered monster costs the same and every skill has its price.
**Sources:** [battle.md §1](../../../battle.md#1-goals-and-pillars); [architecture.md §4](../../../architecture.md#4-the-battle); [monsters.md §2.2](../../../monsters.md#22-prices-and-points); [skills.md §7](../../../skills.md#7-value-and-prices).

**Decided:** no fixed monsters or skills in the multiplayer battle. The players pick monsters alternately in the order 1 · 2 · 2 · 1 · 2 · 1, then skills for each monster. Both players get the same generated pool or each a pool of their own. Players can save monsters and skills they made.

**For the user to decide:**

| Topic | Questions |
|---|---|
| Pools | How many monsters and how many skills are offered? Are they generated new for every draft? |
| Skills | How many skills per monster, in which picking order, and does a kit template limit the kinds? |
| Taken picks | Is a picked monster or skill gone for the other player (one shared pool), or may both hold the same? |
| Saved creations | May a player bring saved monsters and skills into a draft, or only into free matches? Must they fit the points and prices? |
| Without a draft | Is the quick start of the prototype (everything drawn, the same for both or apart) a way to play that stays? |
| After the draft | Placement and free shapes: arranged during the draft or before the battle? |

- **In the prototype:** the multiplayer start screen draws every monster for 60 points with a kit of generated skills; two start buttons: random monsters for both sides, or the same monsters for both. Nothing is picked.
- **Done when:** the rows are decided and the draft stands in a rule file with lines in [decisions.md](../../../decisions.md).
