# Decision Log

What the user decided, what was rejected for it and why. Git knows what changed; this file knows what was chosen.

- **Append only.** A decision that is overturned stays and gets “replaced by …” in its row.
- **User decisions only:** no agent drafts, tasks or intermediate states.
- **No rule texts or numbers:** a row points to the section that holds the rule.
- “—” means the date, the rejected option or the reason is not on record.
- **When to read it:** before proposing a rule change or reopening a decided topic. What is listed as rejected is proposed again only with a new reason.

## Battle

| Date | Topic | Decision | Rejected | Reason | Where |
|---|---|---|---|---|---|
| 2026-11-10 | Board distance | Chebyshev distance | — | — | [battle.md §4.1](battle.md#41-board-generation) |
| 2026-11-10 | Aspects | No aspects, no element triangle, no attunement | aspect system with matchups | — | [battle.md §1](battle.md#1-goals-and-pillars) |
| 2026-11-10 | Water | No Water ground and no Swim | Water and Swim | — | — |
| 2026-11-10 | Zone and ground | Independent: neither changes the other | zones that change or suppress ground | — | [battle.md §4.3](battle.md#43-the-square-ground-zone-and-occupant) |
| 2026-11-10 | Unit-bound effects | End with their bearer; zones, ground and props stay | owner expiry of board effects | — | [battle.md §2.3](battle.md#23-pace-and-the-queue) |
| 2026-11-10 | Damage modifiers | One sum, floored at 0; zero damage still hits | — | — | [battle.md §6.1](battle.md#61-damage) |
| 2026-11-10 | Displacement ties | Resolve in queue order; the later unit collides | — | — | [battle.md §6.2](battle.md#62-payload-resolution) |
| 2026-11-10 | Pull on a diagonal | A pull zone does not move a target on an exact diagonal | — | — | [battle.md §6.4](battle.md#64-displacement) |
| 2026-11-10 | Late-round pressure | Farthest squares convert together, no tie-break | — | — | [battle.md §4.2](battle.md#42-dragon-veins-surrounding-and-late-round-pressure) |
| 2026-11-11 | End of battle | Checked after a fully resolved payload; simultaneous wipe is a Draw | — | — | [battle.md §2.2](battle.md#22-core-loop) |
| 2026-11-11 | Queue ties | Same side: start slot order; meta state never breaks ties | — | — | [battle.md §2.3](battle.md#23-pace-and-the-queue) |
| 2026-11-11 | Stacking | Same source refreshes, different sources add without a cap | — | — | [battle.md §5.1](battle.md#51-effective-stats) |
| 2026-11-11 | Passive reactions | Resolve after the payload, once per event, no chains | — | — | [battle.md §3](battle.md#3-timing) |
| 2026-11-11 | Props | Mirrored pairs only; fixed, previewed effects; no chain reactions; no indestructible prop | — | — | [battle.md §4.7](battle.md#47-props) |
| 2026-11-11 | Tamer skills in battle | Activation window and the rules of Swap Places, Urgent Order, Second Wind, Life Thread, Beast Swap | — | — | [battle.md §5.2](battle.md#52-tamer-skills) |
| 2026-11-12 | Battle goals | The goals a battle has to deliver | — | — | [battle.md §1](battle.md#1-goals-and-pillars) |
| 2026-11-12 | Persistence | What a skill lays on the board is temporary | permanent hazard ground | it filled the board and made waiting pay | [battle.md §4.4](battle.md#44-lifetimes) |
| 2026-11-12 | Board edge | A push against the edge is a collision | — | the space beyond the board is void | [battle.md §6.3](battle.md#63-collision) |
| 2026-11-12 | Spiky props | A `spiky` prop deals 2 collision damage | — | — | [battle.md §4.7](battle.md#47-props) |
| 2026-11-13 | Reshape of the square | No height, no air layer, no delayed area attacks (Surges); ground and zone are two layers with one role each | height and Mountains, flying, Surges and their marker traps | — | [battle.md §4.3](battle.md#43-the-square-ground-zone-and-occupant) |
| 2026-11-13 | Fair damage | Damage from a distance never hits a monster without a turn of its own since the cast | — | — | [battle.md §6.1](battle.md#61-damage) |
| 2026-11-13 | Roles | Ground acts at a moment, a zone while a monster stands inside; a zone never damages or heals | shield and healing zones, ground that changes stats | — | [battle.md §4.5](battle.md#45-ground) |
| 2026-11-13 | Ground acts as long as it lies | — | ground that acts once and vanishes | — | [battle.md §4.4](battle.md#44-lifetimes) |
| 2026-11-13 | Prop squares | Ground and zones are laid on a prop square like on any other | props that shield their square | — | [battle.md §4.3](battle.md#43-the-square-ground-zone-and-occupant) |
| 2026-11-13 | Stat zones | A zone that only changes stats is never cast alone | stat zones as skills of their own | they went unused | [battle.md §4.6](battle.md#46-zones) |
| 2026-11-13 | Dragon Veins | Square control as the way to win; at least one per map; ownership by last touch; surrounding; late-round pressure only as a brake | extra damage against a monster that cannot evade, armour by facing, alternating activation, healing or AP on these squares | — | [battle.md §4.2](battle.md#42-dragon-veins-surrounding-and-late-round-pressure) |
| 2026-11-13 | Extra turns | Count from round 2 | — | — | [battle.md §2.3](battle.md#23-pace-and-the-queue) |
| 2026-11-13 | Traps | No traps. **Replaced by** “traps as walkable props” (2026-11-15) | — | — | — |
| 2026-11-14 | Dragon Vein rule | “Last touch owns” stays | veins that must be held; charged veins | — | [battle.md §4.2](battle.md#42-dragon-veins-surrounding-and-late-round-pressure) |
| 2026-11-14 | Dragon Vein tie | The owning side chooses the target at the last tie | — | — | [battle.md §4.2](battle.md#42-dragon-veins-surrounding-and-late-round-pressure) |
| 2026-11-14 | Surrounding and pressure | Both stay | — | — | [battle.md §4.2](battle.md#42-dragon-veins-surrounding-and-late-round-pressure) |
| 2026-11-14 | Zones at cast | A push or pull zone moves nobody when it is cast | push at cast | defeats before the victim's own first turn | [battle.md §3](battle.md#3-timing) |
| 2026-11-14 | Props are displaced | Every push or pull also moves props | fixed props | — | [battle.md §6.4](battle.md#64-displacement) |
| 2026-11-14 | 2×2 bodies | Out of scope | 2×2 monsters | — | [monsters.md §1](monsters.md#1-species-and-individual) |
| 2026-11-14 | Props act at moments | One prop kind that acts when destroyed, hit, entered or at the round end | prop classes; aura props as a class | — | [battle.md §4.7](battle.md#47-props) |
| 2026-11-15 | Pace | The stat is called Pace; it orders the queue and gives the Stamina recovery | the name Initiative; a separate recovery stat | few stats | [battle.md §2.3](battle.md#23-pace-and-the-queue) |
| 2026-11-15 | Stamina | A pool pays for movement skills; cost per square | movement covered by a Movement stat | — | [battle.md §2.4](battle.md#24-action-points-and-stamina) |
| 2026-11-15 | Recovery | The current Pace counts | the Pace on the sheet | — | [battle.md §2.4](battle.md#24-action-points-and-stamina) |
| 2026-11-15 | Round end | First everything moves, then everything acts, then all clocks tick | ground before pushing props; swapping the moments of Lava and Blight | — | [battle.md §3](battle.md#3-timing) |
| 2026-11-15 | Cover | A solid prop shields the Strike square behind it | — | — | [battle.md §4.7](battle.md#47-props) |
| 2026-11-15 | Traps | Traps exist as walkable props | — | — | [battle.md §4.7](battle.md#47-props) |
| 2026-11-15 | Dragon Veins as ground | Props and zones may be on a Dragon Vein, also at board generation | — | a Dragon Vein is ordinary ground that nothing changes | [battle.md §4.2](battle.md#42-dragon-veins-surrounding-and-late-round-pressure) |
| 2026-11-15 | One sheet | Ground, zones and props read as “when · what · how much · where” with a fixed role table | one merged kind | — | [battle.md §4.8](battle.md#48-one-sheet-for-ground-zones-and-props) |
| 2026-11-15 | Battle length | Target: a mean of 3.0–4.9 rounds for 3v3 | the target “3–5 rounds” of 2026-11-13 | — | [battle.md §1](battle.md#1-goals-and-pillars) |
| 2026-11-15 | Lowest HP | HP 1 and 2 are allowed; “lowest HP 3” was never a rule | a guaranteed minimum of 3 HP | it gets better with the stages; faster early battles are fine | [battle.md §1](battle.md#1-goals-and-pillars) |
| 2026-11-15 | Reach | Counts orthogonal steps | board distance for Reach | — | [skills.md §2](skills.md#2-the-skill-card) |

## Monsters

| Date | Topic | Decision | Rejected | Reason | Where |
|---|---|---|---|---|---|
| 2026-11-11 | Stage cap | A monster is capped by the player's stage, not the sub-tier | sub-tier cap | — | [monsters.md §2.3](monsters.md#23-shapes-and-spending) |
| 2026-11-11 | AP ceiling | One AP ceiling for every monster. **Replaced by** “no ceilings” (2026-11-15) | — | — | — |
| 2026-11-13 | Winged | Winged monsters stand on the ground | air layer | — | [monsters.md §1](monsters.md#1-species-and-individual) |
| 2026-11-13 | Stat calculation | Prices and budgets are found through play, nothing is fixed | — | — | [monsters.md §2](monsters.md#2-stats) |
| 2026-11-14 | HP | No general HP raise; 10 stays the highest HP | raising HP to lengthen battles | — | [monsters.md §2.1](monsters.md#21-the-stats) |
| 2026-11-15 | Pace scale | One stat point is 0.1 Pace | the 1–9 scale | — | [monsters.md §2.2](monsters.md#22-prices-and-points) |
| 2026-11-15 | Ranges and start | One fixed range per stat for the whole game; every stat starts at its lowest value | free base values above the minimum | — | [monsters.md §2.1](monsters.md#21-the-stats) |
| 2026-11-15 | Ceilings and unlocks | No stat ceiling and no unlock per stage; a stage gives only points | the ceiling table; unlocking turns and AP by stage | the points already limit every stat | [monsters.md §2.1](monsters.md#21-the-stats) |
| 2026-11-15 | Prices | The price list with rising AP steps and a turn price that follows the AP | HP at 2 or 3 points; flat or doubling AP prices; a flat turn price | turns and AP multiply | [monsters.md §2.2](monsters.md#22-prices-and-points) |
| 2026-11-15 | Points | 25 at the start, +5 per step, 110 at the end | 20 at the start; 120 at the end | no monster should reach the top in everything | [monsters.md §2.2](monsters.md#22-prices-and-points) |
| 2026-11-15 | Immortal and Sovereign | Give points like every step | no points at these stages | — | [monsters.md §5](monsters.md#5-growth) |

## Skills

| Date | Topic | Decision | Rejected | Reason | Where |
|---|---|---|---|---|---|
| 2026-11-11 | Extended Arc | Straight only | a diagonal extended Arc | — | [skills.md §4](skills.md#4-shapes) |
| 2026-11-11 | Beast Strike | No Kin effect: the baseline | — | — | [skills.md §4](skills.md#4-shapes) |
| 2026-11-12 | Rotation | Every monster may turn a placed shape | rotation as a passive | — | [skills.md §2](skills.md#2-the-skill-card) |
| 2026-11-12/13 | Prices | Skill prices are found through play; no price sheet | construction points and component prices | — | [skills.md §7](skills.md#7-value-and-prices) |
| 2026-11-13 | Skill card | A skill only delivers: Strike, movement, effect on the user, creates ground, zone or prop | skill kinds with rules of their own | — | [skills.md §2](skills.md#2-the-skill-card) |
| 2026-11-13 | AP and turn effects | Only as rare, expensive `experiment` content | — | — | [skills.md §3](skills.md#3-what-a-skill-does-and-creates) |
| 2026-11-13 | Displacement in kits | More displacement in the kits | a Shove action for everyone | a sturdy monster on a Dragon Vein could not be removed | [content.md §5](content.md#5-the-nine-monsters) |
| 2026-11-14 | Usage | Every slotted skill once per turn unless its card names more | unlimited repetition | — | [skills.md §2](skills.md#2-the-skill-card) |
| 2026-11-14 | Slots | Up to 6 kit slots | 4 slots plus a passive-only fifth for Epic+ | — | [skills.md §1](skills.md#1-the-kit) |
| 2026-11-14/15 | AP passives | Passives may lower AP costs; never below 1 AP | — | — | [skills.md §6](skills.md#6-passives) |
| 2026-11-15 | Slots in the game | The multiplayer mode plays with six open; in the game single slots are upgrades | — | — | [skills.md §1](skills.md#1-the-kit) |
| 2026-11-15 | Strike | Damage and push are both optional and belong to the single skill | every damaging Strike pushes | — | [skills.md §3](skills.md#3-what-a-skill-does-and-creates) |
| 2026-11-15 | Shapes | One shape per skill: six base shapes with extensions, or a free shape arranged before the battle | separate shape lists for Strikes, placed skills and props | — | [skills.md §4](skills.md#4-shapes) |
| 2026-11-15 | Shape details | Storm +1 is the eight lines; skills that create props use free shapes too | Storm +1 as the full ring | — | [skills.md §4](skills.md#4-shapes) |
| 2026-11-15 | Kit requirement | “A skill that pushes or pulls” holds for the kits the bots play | — | — | [content.md §5](content.md#5-the-nine-monsters) |
| 2026-11-15 | Skill costs | The present skills and their AP costs are examples; a Jab need not cost 2 AP | — | — | [skills.md §7](skills.md#7-value-and-prices) |
| 2026-11-15 | Kits | Six skills and a balanced kit for each of the nine monsters | — | — | [content.md §5](content.md#5-the-nine-monsters) |

## Overworld

| Date | Topic | Decision | Rejected | Reason | Where |
|---|---|---|---|---|---|
| — | Aspects | No Legendary aspect change, no dual-aspect progression | both | — | — |
| — | Evolution | No physical evolution | physical evolution | — | [skills.md §8](skills.md#8-slot-development) |
| 2026-11-11 | Domain Glimpse | Clears zones and resets ground on a freely placed tetromino | — | — | [overworld.md §6.4](overworld.md#64-tamer-skills) |
| 2026-11-14 | Spatial Pull | Dropped | the tamer skill Spatial Pull | — | — |
| 2026-11-14 | Qi Suppression | Stays; Spirit Shield is to be redefined | — | — | [overworld.md §6.4](overworld.md#64-tamer-skills) |
| 2026-11-15 | Stage table | The stage table unlocks no turns and no AP | stat unlocks by stage | a stage gives only points | [overworld.md §6.3](overworld.md#63-stage-unlock-table) |

## Way of Working

| Date | Topic | Decision | Rejected | Reason | Where |
|---|---|---|---|---|---|
| 2026-11-12 | Focus | The battle is finished first; the overworld waits | — | — | [CLAUDE.md](../CLAUDE.md) |
| 2026-11-12 | Branch and scope | Work on `main`; `docs/`, `CLAUDE.md` and `godot/` may be changed | a separate docs branch | — | [CLAUDE.md](../CLAUDE.md) |
| 2026-11-12 | Data | One data folder with one subfolder per kind; no second skill, kit or price sets; no Python or JSON files in the project | — | — | [CLAUDE.md](../CLAUDE.md) |
| 2026-11-12 | Tools | Simulations are for trying out whether the game is fun and what prices are needed; they approve nothing | — | — | [CLAUDE.md](../CLAUDE.md) |
| 2026-11-13 | Content status | `experiment` content is playable in the game | — | — | [skills.md §9](skills.md#9-data) |
| 2026-11-14 | Architecture | Target architecture for a clean rebuild; CSV translation, German and English, a mid-strength AI | — | — | [architecture.md](architecture.md) |
| 2026-11-14 | CPU | Full CPU use is allowed | mandatory low-priority runs | — | [CLAUDE.md](../CLAUDE.md) |
| 2026-11-15 | Simulations | A series runs only on explicit request | series started by the agent on its own | the user wants changes delivered quickly | [CLAUDE.md](../CLAUDE.md) |
| 2026-11-15 | Reporting | Every result states the battles under 3 and over 5 rounds | — | — | [CLAUDE.md](../CLAUDE.md) |
| 2026-11-15 | Terms | The draft sandbox is called the multiplayer mode | “battle prototype” | — | [CLAUDE.md](../CLAUDE.md) |
| 2026-11-15 | Board switches | 8×8 has four Dragon Veins by default (a test switch) | — | — | [todo/](todo/) |
| 2026-11-15 | Documentation | Rules and content in separate files; a decision log; tasks as single files by status; the simulation log keeps only the current rule era; Reach as the build plays it | — | docs had grown past their purpose | [CLAUDE.md](../CLAUDE.md) |
