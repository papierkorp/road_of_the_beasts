# T51 · Review What Was Decided Alone

**Status:** To clarify — while the user was away (2026-11-19) the overworld rules were rewritten along the frame and a first world was built. Every row below was decided without the user and stands as a working draft; the user confirms, changes or drops it.
**Prerequisites:** none.
**Sources:** [overworld.md](../../../overworld.md), [vision.md](../../../vision.md), [godot/README.md](../../../../godot/README.md).

**Rules written into overworld.md:**

| # | Topic | What was written | Where |
|---|---|---|---|
| 1 | Day AP | 6 at Qi Gathering, +1 per stage up to 11, because every battle and every resource now costs 1 | [§2.6](../../../overworld.md#26-action-catalog) |
| 2 | HP in a wild area | HP persists through the day; a night restores a monster that is not injured; a fallen one rests 2 nights | [§2.2](../../../overworld.md#22-wild-area-loop) |
| 3 | Zones | A resource of a zone above the player's stage cannot be taken; its monsters can be met | [§3.3](../../../overworld.md#33-wild-areas-and-one-time-realms) |
| 4 | Wild areas and return | Two areas with three zones each (school's mountain, wild forest); back after 1 / 3 / 7 nights by grade, a monster after 2 | §3.3 |
| 5 | One-time realm | Open for 3 days; a token is used up by the first entry and holds while it is open; inside, costs as in a wild area | §3.3 |
| 6 | Buildings per district | A list of buildings for every group | [§3.1](../../../overworld.md#31-the-city) |
| 7 | Internal World | The structure list (World Core, Battleground Hall, Seal Bench, habitats by kind, Statue); one habitat holds two monsters; grid 6–16, holds 2 / 3 / 5 / 7 / 9 / 12, own battlegrounds 0–5 | [§4.3](../../../overworld.md#43-what-lives-in-the-spatial-space), [§4.4](../../../overworld.md#44-capacity-and-growth) |
| 8 | Own battlegrounds | Opened by world stage 2, so from Foundation | §4.3, [§6.3](../../../overworld.md#63-stage-unlock-table) |
| 9 | Trials | Every breakthrough is a battle, the first too: examination duel, shrine guardians, realm guardian, mirror team, guardian of the barrier | [§6.3.1](../../../overworld.md#631-breakthrough-trials) |
| 10 | Arrays | Dropped as items; a battleground of one's own takes their place | [§6.8](../../../overworld.md#68-arrays-artifacts-for-places) |
| 11 | Tamer artifacts | Dropped (+1 day AP, capacity, skill mods): no equipment raises a stat | [§6.7](../../../overworld.md#67-weapons-and-armour) |
| 12 | Weapons | As many weapons as tamer slots; a weapon's skill does not develop | §6.7 |
| 13 | Pills | Ten properties and their pills; three act in battle beside healing (Warding, Swiftness, Anchoring); no pill is taken before a battle; a pill with two shared properties has both effects; plants that share nothing are lost | [§6.6](../../../overworld.md#66-pills--medicines), [§7.5](../../../overworld.md#75-materials-seeds-and-grades) |
| 14 | Smithing | The temper may be left out; a golem is forged from ore and an essence | §7.5 |
| 15 | Craft ranks | Five ranks per hall | §7.5 |
| 16 | The house | Founded from Core Formation; the five businesses became four wings; before the house the player sells to the Guild and consigns at the Auction Hall; in hiding an order costs 1 day AP more and hush money | [§7.1](../../../overworld.md#71-the-house) |
| 17 | People | Strength, Loyalty 0–5, one trait; the night compares summed Strength with the task, a tie holds what was | [§7.1.1](../../../overworld.md#711-people) |
| 18 | Harm | A request that harms a group lowers its favor toward the player; below zero is a grudge that stops its requests until paid off; Standing is never lost | [§7.2](../../../overworld.md#72-favor--faction) |
| 19 | Weight | A table of what counts (stage, arcs shown, craft ranks, open house and wings, Epic pieces worn); a group below the player's weight gives way | §7.2 |
| 20 | Rival families | The cap "Allied with one holds the other at Trusted" is gone; deeds and weight take its place | §7.2 |
| 21 | Dropped without a successor | Arena tournaments, beasts for hire, the Business District, staff model B as written, the Trial and Evolution Pillars, Hive Nest, Qi Spring | — |

**In the build:**

| # | Topic | What was built |
|---|---|---|
| 22 | Hub | One room with every district, both wild areas, the Realm Gate and the Internal World as teleporters; a test layout, not the geography of the city |
| 23 | Districts | One room per group with its buildings as tall blocks; a building without a function shows a text of what it is for |
| 24 | Old functions | The trader stands in Trader's Row (Guild Quarter), the request board on the Notice Wall (City Lord), the three old factions in Family Hall, Guild Hall and Guard Barracks; the old dungeon run stands in for a one-time realm at the Realm Gate |
| 25 | Camera | A follow camera in every walkable area: the right mouse button (new action `world_look`) or the middle one turns it, the wheel zooms; it starts looking where there is room and stops in front of a building |
| 26 | Wild areas | Zones, resources for 1 day AP that return after their nights, wild monsters that only wander: no battle in a wild area yet |
| 27 | Day AP | 6 at the start in the build as well |
| 28 | Removed | The city map screen |

**Not touched, though the frame changes it:** the capacity of the Internal World (still 1 / 3 / 5 by the tamer's stage), the stage of the Internal World, team size by battleground, tamer slots for weapon and pill, alchemy by properties, smithing, the house, weight, the growth preview's open points (T50).

- **Done when:** the user has gone through every row; what is confirmed gets a line in [decisions.md](../../../decisions.md), what is changed is rewritten in its section, and this file moves to `done/`.
