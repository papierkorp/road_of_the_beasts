# T19 · Complete Battle Loadout and Timing

**Status:** Partly drafted — visibility, pre-battle selection and BattleResult consumption fields exist; counts, activation windows and source handling remain blocked by T18 effects/costs.
**Prerequisites:** T18 combat effects and Battle-AP/consumption contracts, not recipes or market prices; coordinate T17/T20 loadout interfaces. Complete before full-scope T13.
**Sources:** [battle_ingame.md §5](../../../battle_ingame.md#5-tamer-skills) (integration); Overworld [overworld.md §2.1](../../../overworld.md#21-battle-loop), [overworld.md §7.9](../../../overworld.md#79-inventory-and-loadout), [overworld.md §8](../../../overworld.md#8-technical-notes).
- Define Medicine/Array counts, activation windows (own turn or anytime), AP costs and consumption.
- Apply the same rules to human opponents; specify visibility, preview, pre-battle locking and reporting consumed items in BattleResult.
- **Result schema:** Battle §2.1 and Overworld §2.1 now name the **Draw**. Still define the full output contract (no winner, per-monster HP/defeat facts, kill attribution and used-up items; I29). Rewards, XP, injury and Arena consequences remain T23/meta; mentioning Draw does not settle them.
- Dependency is directional: item combat effects/Battle-AP costs first, then loadout limits; no dependency on spirit-stone prices/recipes or mutual blocking. Acquisition frequency is tuned later against the accepted per-battle limits.
- **Request inputs beyond the loadout:** a trial penalty such as “starts at half HP” ([overworld.md §6.3.1](../../../overworld.md#631-breakthrough-trials), T30), pre-battle pills (T18) and the board inputs of T21 all enter through the request; list its fields once, in [overworld.md §8](../../../overworld.md#8-technical-notes), whose result line also still lacks the Draw (K, T35).
- **Done when:** loadout counts, activation windows, AP costs, consumption, human-opponent visibility, BattleResult reporting (including the Draw outcome) are specified in Overworld §7.9/§8 and Battle §5.2.
