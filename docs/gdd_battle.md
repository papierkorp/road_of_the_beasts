# GDD — BATTLE SYSTEM
*Working Draft — Options, not luck · companion specifications: [Monsters](gdd_monsters.md), [Skills](gdd_skills.md), [Overworld & Meta](gdd_overworld.md) · historical prototypes and test results: [§7](#7-technical--prototype)*

---

## 1. Overview

Turn-based, isometric monster battles about **grid control**, fully deterministic and readable. Inspired by *Into the Breach*.

- **This document:** general turns/events, runtime board state/interactions and generic damage/displacement.
- **Monster definitions:** [gdd_monsters.md](gdd_monsters.md); **skills, costs and upgrades:** [gdd_skills.md](gdd_skills.md).
- **Meta progression, tamer skills and loadout:** [gdd_overworld.md](gdd_overworld.md).
- **Open decisions and validation tasks:** [temp_todo.md](temp_todo.md); working values here are not gameplay-validated.

### 1.1 Battle Modes

|   Mode  |  Board  |                                             Role                                            |
|---------|---------|---------------------------------------------------------------------------------------------|
| 1v1     | 5×5     | duel / tutorial, early game                                                                 |
| 2v2     | 6×6     | step between duel and team battle                                                           |
| **3v3** | **7×7** | **standard battle** — enough monsters for combos between allies, short enough for a session |
| 5v5     | 9×9     | special battles only (bosses, tournaments), later                                           |

The encounter chooses a mode within the player's available team size; stage availability of each mode: [gdd_overworld §6.3](gdd_overworld.md#63-stage-unlock-table).

- **Why 7×7 for 3v3:** 6 monsters on 49 squares is about as crowded as 2 on 25 (1v1), keeping pressure similar; 8×8 leaves more room to escape a 3–4 cell Surge ("too easy to dodge"). An odd size provides a **centre square** for contested high ground and mirror-fair starts.
- Small kits aim to keep 3v3–5v5 readable; kit size and rarity exceptions: [Skills §1](gdd_skills.md#1-the-kit).

### 1.2 Battle Design Pillars

1. **Control squares, not just units** — attacks use spatial hit patterns and zones create shared positional opportunities/risks. Attack targeting, recipients and the boundary to unit-bound utility follow the [central square-control contract](gdd_skills.md#2-data-oriented-skill-construction-kit). The board is the weapon
2. **Deterministic & readable** — before confirming, see exactly which squares a cast takes, levels up, cancels, replaces or loses, its ground/prop effects and every pushed monster's landing
3. **Everything reacts, nothing deletes** — no delete button; small, data-driven rules. Zone overlaps use definitions and opposite effects ([§4.6](#46-zones-effects-rules--opposites)): opposite levels subtract, cancelling at equal levels. Concrete skill effects change ground and props; zones and ground are independent ([§4.6](#46-zones-effects-rules--opposites)). Prop aftermath is fixed per type ([§4.10](#410-prop-catalogue-and-damage)).
4. **The Surge is the burst** — big damage (3+) only comes from a declared, charging, autonomous Surge; all smaller damage sources and the zone rule: [§6.1](#61-the-damage-law) themselves
5. **Every threat has a real answer** — leave, apply zone-based Surge damage reduction, change the ground under it, pick the right height for that Surge type, block with props, answer with your own Surge
6. **Options, not luck** — fully deterministic and visible; variety comes from many meaningful turn choices (position, threat, reaction), never dice or hidden information
7. **Low HP, high stakes** — one mistake can be fatal
8. **Dynamic battlefields** — ground and props are resources; squares remember explicit board changes; Surges rewrite them only when their definition includes such effects
9. **One skill source** — monster-skill authoring/access: [gdd_skills.md](gdd_skills.md), linked from [§5](#5-skill-integration). No fixed aspect or replacement element categories

---

## 2. Battle Flow

### 2.1 Core Battle Loop

1. Battlefield generated (ground, props, contested high ground — §4.1)
2. Pre-battle: choose monsters and place them in your start area; preparation/loadout: Overworld sources in [§5.2](#52-tamer-skills-and-battle-loadout). Start at **current HP** ([gdd_overworld §6.6](gdd_overworld.md#66-pills--medicines)).
3. **Each round:** one queue for all monsters of both sides, highest effective initiative first (§2.2)
4. **Monster's turn:** dispatch due events/effects, spend its **AP** on legal actions ([§2.3](#23-action-points)), then resolve end effects in [§2.4](#24-effect-timing-reference) order.
5. Round ends → resolve the round-end events in [§2.4](#24-effect-timing-reference)
6. Battle ends when one side has no monsters left. *(User decision 2026-11-11:)* the check happens after a payload/phase has fully resolved, including its defeats; the battle then ends immediately and pending Surges and autonomous aftermath lapse. If both sides have no monsters left after the same resolution, the result is a **Draw**; its BattleResult handling is defined with T19/T23.

### 2.2 Initiative Rules

- **One queue for all monsters of both sides**, strictly by effective initiative, **recalculated every round**
- A side may act several times in a row — that is the reward for initiative, not a bug
- **Ties:** higher base initiative first; still tied → the sides alternate (the first tie of a battle goes to the side with the lower total initiative; if the totals are equal, to the player's side). *(User decision 2026-11-11:)* tied units of the same side act in their fixed loadout/start slot order (slot 1 first); an extra-turn entry follows its unit's main entry. EXP and other meta state never break ties.
- An initiative-draining zone can flip the order, giving a monster two turns back to back across the round boundary — a real tempo weapon
- Multi-turn monsters get one extra queue entry per extra turn, each at −3 initiative (min 0.1)
- **Surge clock:** dispatch under [§2.4](#24-effect-timing-reference) and the [central Surge profile](gdd_skills.md#surge). Initiative changes/extra turns mean other monsters are not guaranteed a turn before detonation.
  - **Extra turns** *(user decision 2026-11-10)*: a Surge detonates at the caster's next queue entry, including an extra-turn entry, before that turn's start effects.
  - **Dead caster** *(user decision 2026-11-10)*: a Surge whose caster was defeated is not cancelled and detonates at the **start of the next round**, before the queue; several such Surges resolve together phase by phase ([§6.2](#62-surge-resolution-integration)).
  - **Unit-bound effects and caster death** *(user decision 2026-11-10)*: effects bound to a unit (buffs, debuffs, marks, self-boosts) end immediately when that unit is defeated or removed. Zones, ground, props and Surges stay with their remaining duration when their caster dies; there is no owner expiry.
  - Each Surge is bound to its own caster's queue entry, so Surges of different casters are never due at the same event; same-event ties arise only among Surges of one caster or among orphaned Surges.
  - **Tie reference for orphaned Surges** *(user decision 2026-11-11)*: the new round's initiative is computed before orphaned Surges detonate and serves as the queue reference for displaced units. Ties between sources (board operations) follow the dead caster's position in the previous round's queue; several Surges of one caster follow their cast order.

### 2.3 Action Points

**Battle-AP per turn = the monster's AP stat** (2–5, [Monsters §2.1](gdd_monsters.md#21-the-stats)).

- Pay the resolved monster action's authored Battle-AP cost: **at least 1 Battle-AP, never 0**. This does not redefine tamer/loadout usage.
- AP evaluation and construction prices: [Skills §5](gdd_skills.md#5-construction-points-and-ap-efficiency); skill execution, development and access: [§5.1](#51-monster-skills-central-specification). Tamer/loadout costs use their own Overworld sources ([§5.2](#52-tamer-skills-and-battle-loadout)), not monster-action prices.
- **Repetition:** use the resolved skill's [central repetition policy](gdd_skills.md#usage-and-repetition) together with AP, board and profile limits.
  - Concurrent Surge casts follow the [central Surge profile](gdd_skills.md#surge), not a monster-wide charging cap.
  - A repeatable zone may be recast to level it up; a round-limited skill must satisfy its declared policy.
  - No generic multi-round cooldown system; existing skills gain no new cap implicitly.
- **Positioning:** [movement and Strike profiles](gdd_skills.md#3-skill-execution-profiles) make repositioning compete with attacking for Battle-AP. Their authored prices, not a separate rule here, determine what fits in one turn; board control can place a target inside the Strike shape without a preceding move.

### 2.4 Effect Timing Reference

**Generic timing reference:** integrates source-specific triggers from resolved definitions into the battle schedule; grants no new source permissions.

|    Trigger    |                          When                         |                                                         Effects / events                                                        |
|---------------|-------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------|
| on_timer      | start of the caster's next turn, before anything else | Surge detonation                                                                                                        |
| start_of_turn | beginning of the occupant's turn                      | start-turn ground damage (§4.7)                                                                                                        |
| on_enter      | a monster enters the square (move, push, pull)        | entry-triggered ground damage or healing (§4.7)                                                                                                       |
| while_inside  | continuous modifier or source availability             | Movement, initiative and Reach modifiers; zone-based Surge damage reduction is available while inside and applies on Surge damage |
| end_of_turn   | end of the occupant's turn                            | 1. push / pull → 2. end-turn ground damage (on the landing square) → 3. `mend`                                                            |
| round end     | after the last turn of the round                      | zones −1 round (expired zones are removed), burning props burn down, late-round Voidscar spreads, initiative re-sorted |
| immediate / event-derived | on authored execution or the triggering event | Strike on use; collision / fall on impact; aftermath on prop destruction |

Order inside a turn:

1. Due Surges: damage → explicitly authored residue, if present, under the [central profile](gdd_skills.md#surge).
2. Start effects.
3. AP.
4. End effects: displacement → end-turn ground damage → `mend`.

Entry effects apply when a monster enters a square, including by push / pull.

**Event-driven reactions** *(user decision 2026-11-11)*: reactions of event-driven passives collect during a payload and resolve after its step 5 (self retreat), one at a time in the initiative-queue order of the reacting units, on the board as it then stands. Their consequences (entry or ground damage, healing) apply normally but trigger no further passive reactions; each passive reacts at most once per triggering event. Defeated units do not react. Order within a turn is unchanged.

**Scheduling references:** exceptional Surge queue timing: [§2.2](#22-initiative-rules); combined-event ordering: [§6.2](#62-surge-resolution-integration); tamer/loadout activation windows: [§5.2](#52-tamer-skills-and-battle-loadout); remaining loadout details: T19/T20 in [temp_todo.md](temp_todo.md).

---

## 3. Monsters in Battle

Battle resolves a finished unit sheet. Monster definitions (sheet, stats, Kins, roster, progression): [gdd_monsters.md](gdd_monsters.md); skills (Strikes, kits, passives): [gdd_skills.md](gdd_skills.md); loadout integration: [§5.2](#52-tamer-skills-and-battle-loadout).

### 3.1 Effective Stats

**Effective stats** combine the base sheet with all applicable, authorized modifiers, including zone, ground, height, prop and skill/passive sources.

- One zone per square limits zone occupancy, not cross-source stacking. Modifier contracts: [Skills §4](gdd_skills.md#4-effect-and-board-operation-contracts); stacking and expiry *(user decision 2026-11-11)*: the same source (same effect of the same owner) only refreshes duration and never adds magnitude; different sources (zone, ground, prop, skill, passive) add without a cap; only the existing stat floors apply (Movement and Reach min 1, Initiative min 0.1). A timed unit effect with a duration of N rounds lasts from application until the round end of the N-th following round (round-end tick, [§2.4](#24-effect-timing-reference)); it ends earlier with its defeated or removed bearer ([§2.2](#22-initiative-rules)). Skills §4 wording to be synchronized (T35).
- Board sources below are not an exhaustive modifier catalogue.

|     Stat    |                     Changed in battle by                     |
|-------------|--------------------------------------------------------------|
| Initiative  | `drain_init` / `quicken` (§4.6), Shrine (§4.10), Hearth (§4.7) |
| Movement    | `slow` / `haste` (§4.6), Banner (§4.10); Step is always 1 square |
| Reach       | +1 on a Mountain, `drain_range` / `extend` (§4.6), Umbra (§4.7), Totem (§4.10); min 1 |

### 3.2 Monster Identity & Skill Access

- **Free themes**, not fixed aspects or replacement element categories: identity comes from species, Kin, stats, skills and passives. Themes impose no matchup triangle or combat modifiers; there is no attunement (§4.8).
- Skill access and authored definitions: [gdd_skills.md](gdd_skills.md); battle integration: [§5](#5-skill-integration). Runtime ground types, zone effect tags, prop reactions and Surge behaviour use the resolved concrete definition, never the monster's theme.
- Zone × zone compares effects (§4.6); zones never change ground ([§4.6](#46-zones-effects-rules--opposites)).

---

## 4. Battlefield

### 4.1 Battlefield Generation

- Procedural ground + props, **point-symmetric around the centre** so both sides get the same distances (mirrored fairness check for every mode)
- Contested Mountain squares near the centre, equidistant from both starts
- Pre-placed props shape the opening
- **Prop symmetry** *(user decision 2026-11-11)*: props are placed only as point-mirrored pairs, so the count is always even; the centre square of an odd board never holds a prop. The prop counts in the table below are draft values reduced to even numbers, not balance approval.
- **Board distance** *(user decision 2026-11-10)*: Chebyshev, `max(|dx|, |dy|)` (diagonals count like orthogonal steps). Rules that need another measure name it explicitly.

|   Mode  |  Board  |                    Start area per side                    |     Contested Mountain     | Props |
|---------|---------|-----------------------------------------------------------|----------------------------|-------|
| 1v1     | 5×5     | opposite corners                                          | 2 near the centre          | 2     |
| 2v2     | 6×6     | back row                                                  | 2 near the centre          | 2 or 4 |
| **3v3** | **7×7** | back two rows; players place their monsters in pre-battle | 3: the centre + 2 flanking | 4 or 6 |
| 5v5     | 9×9     | back two rows                                             | 3–5                        | 6 or 8 |

**Unvalidated opening target:** on 7×7, intended 5–6-row start separation should reward acting first with position, not a free hit: no Strike or Surge reaching the enemy line in round 1. The start-area table does not guarantee this; validation remains T13 in [temp_todo.md](temp_todo.md).

### 4.2 Late-Round Pressure (Anti-Stalling)

- From a set round, the square farthest from all living monsters becomes **Voidscar** each round (permanent, undestroyable). *Reading (user decision 2026-11-10):* each square's distance is measured to its nearest living monster and the largest value wins. **Ties** *(user decision 2026-11-10)*: all equally far squares become Voidscar together, with no tie-break. Start scales with board size (tunable: 1v1 round 6, 3v3 round 8).
- **Collapse:** once no free square is left to convert, every living monster takes 1 damage per round — so every battle ends.

### 4.3 The Square Stack: Zones & Ground

```
[ AIR    ]  flying prop | flying monster | empty — immune to ground Surges (exception: attackers on a Mountain, §4.7)
[ OBJECT ]  prop (§4.10; tag heavy = cannot be moved) | empty
[ SURGE  ]  pending Surge marker | empty — shares shapes/placement with zones, never merges with them
[ ZONE   ]  ONE timed zone (the skill's `duration`) | empty — control and support
[ GROUND ]  type (neutral: Plain | Rubble | Voidscar — hazard: Lava | Thornbed | Blight, lvl I–II — blessed: Hearth | Mossbed | Umbra | Hallowed), always permanent
            + height (Low | Mountain)
```

- all layers can be active at once · **1 object, 1 pending Surge, 1 zone, 1 ground type** per square
- zones may be placed on prop squares — the zone affects the prop only through the reaction table ([§4.11](#411-prop-reactions)); **Solid** props prevent monster occupancy ([§4.9](#49-props))
- The existing immediate hazard-ground placement profile and coupled height/reset operation (§4.7) require prop-free squares, subject to explicit [§4.11 prop reactions](#411-prop-reactions). These are source-specific [board-operation requirements](gdd_skills.md#4-effect-and-board-operation-contracts); blocking flags are profile-scoped, not a universal empty-square test ([Skills §2](gdd_skills.md#interaction-fields))
- pending Surges may land on props and normally block voluntary movement; path blocking/landing legality use the resolved [movement profile](gdd_skills.md#movement). Displacement (push / pull) **can** move monsters into their squares
- **zones = what you do to a square for a while; ground = what the board remembers**
- **2×2 bodies** *(user decision 2026-11-10; details marked open below)*: a 2×2 monster occupies four squares of this stack.
  - **Distance/Reach:** measured from the nearest covered square, for attacker and target.
  - **Ground and zone triggers** (`start_of_turn`, `on_enter`): fire once per event if any covered square qualifies, never once per square.
  - **Mixed ground** *(user decision 2026-11-10; supersedes a single “worst square” ground)*: every ground type present under the body takes effect **once**, hazards and blessings alike, whether it covers one square or several; no stacking. Several levels of the same hazard type: the highest level applies once.
  - **Mountain** *(user decision 2026-11-10)*: +1 Reach only if all four squares are Mountain; climbing up costs 2 if any covered square climbs; displacement falls: [§6.3](#63-collision-fall--debris).
  - **Movement and legality** *(user decision 2026-11-10)*: a step costs the highest movement cost among the newly covered squares (this includes the Mountain climb cost above). A stand or step is legal only if all four covered squares are legal; the body occupies one layer (ground or air) as a whole, and a Solid prop, a monster of the same layer or the board edge on any covered square makes it illegal. Squares in other layers do not block.
  - **Overlap and shapes:** any overlapping covered square suffices (once per event or use); shape origin and pull direction for 2×2: [Skills §3](gdd_skills.md#body-relative-damage-and-movement-variants).
  - **Entry and simultaneous ground triggers** *(user decision 2026-11-10)*: entry triggers (Thornbed, Mossbed) use only the ground types of **newly covered** squares, each type once; leaving a square triggers nothing. Damage and healing from ground triggers at the same timing point resolve **simultaneously and net**: HP = min(max HP, HP − damage + healing); the monster dies only if HP ≤ 0 afterwards. End-of-turn ground triggers use the squares covered after displacement. Scope: ground triggers of a 2×2 body; general combined-event ordering: [§2.4](#24-effect-timing-reference) and [§6.2](#62-surge-resolution-integration).
  - **Several zones under one body** *(user decision 2026-11-11)*: every distinct zone (cast group) covering at least one square of the body takes effect **once**, regardless of how many covered squares it occupies; no per-square multiplication and no highest-level selection. Continuous stat modifiers, `shield` and end-of-turn `mend` of different zones add as different sources ([§3.1](#31-effective-stats), floors apply; `mend` nets with other same-timing ground triggers as above). Zone push/pull at turn end: each qualifying zone contributes one cardinal direction; opposite directions cancel, and the body moves one square only if exactly one cardinal direction remains (equal directions do not add distance); a zero or non-cardinal (perpendicular) sum means no movement, as for an exact-diagonal pull ([§6.5](#65-displacement)).
  - **Healing, protection and adjacency** *(user decision 2026-11-11)*: Hallowed reduces Surge damage once if any covered square is Hallowed; Mossbed heals 1 once per entry if a newly covered square is Mossbed; zone `shield` and `mend` apply once per zone (see above) and add with Hallowed; Nullify is per monster regardless of body size. Nothing multiplies with the number of covered squares. Adjacency-based effects (Bulwark, Counterweight, aura props) treat a 2×2 as adjacent if at least one covered square is orthogonally adjacent to the source (nearest covered squares when the source is also a 2×2); the effect applies once.
  - **Open (T09):** none left for the 2×2 board rules; air-layer open items are listed in the next bullet.
- **Air layer** *(user decision 2026-11-10; air content needs Soul+)*:
  - **Recipients:** every zone effect and every Surge/board effect authors its recipient layers explicitly; there is no default, and a definition without them is invalid. Strike recipients stay as in [Skills §8.1](gdd_skills.md#81-strike-by-kin).
  - **Ground under flyers:** an air-layer monster ignores ground effects by default (hazards, blessings, movement cost, Mountain bonuses and fall damage). A ground type could be authored to affect the air layer, like zones and Surges; **none does for now** (content later).
  - **Flight movement:** blocked only by air-layer occupants (air props, other flying monsters) and the board edge; Solid props, ground monsters and height do not block. Each square costs 1; Step stays 1 square.
  - **Layer change:** a Soul+ Winged stays on the air layer permanently; there is no landing effect in the current scope *(user decision 2026-11-11)*.
  - **Air props** *(user decision 2026-11-11; entries draft)*: air-layer props and one both-layer prop are part of the catalogue ([§4.10](#410-prop-catalogue-and-damage)). An air prop occupies only the air layer of its square: it blocks flight movement and air occupancy but not ground monsters, ground Surges or ground movement. Strikes hit it (ground and air coverage); a Surge hits it only with authored air recipients.
  - **Air recipients beyond Strike** *(user decision 2026-11-10)*: zone stat effects, zone push/pull, healing/protection zones and Surge damage may each be authored with air recipients (explicit per effect, priced by the [air coverage component](gdd_skills.md#5-construction-points-and-ap-efficiency)); a Surge profile with air recipients is an explicit exception to the ground-only default of the stack above. Existing definitions keep their current recipients.
  - **Winged counters:** no extra guarantee; Strikes, the Mountain rule and authorized zones/Surges are the counters, to be tested in T13.
  - **Open (T09/T02):** concrete air-capable zone/Surge definitions and the prices of air coverage and air props.

### 4.4 Square Data Model

Illustrative **runtime board state only**, not a skill-authoring schema: entries store ownership, cast bindings, levels and remaining lifetime. Definitions resolve through the [shared monster-skill data model](gdd_skills.md#2-data-oriented-skill-construction-kit) and [validation](gdd_skills.md#7-validation-and-concrete-skill-records) (concrete skills: [gdd_skills.md](gdd_skills.md)) (reference map §5).

```jsonc
{
  "pos": [2,1],
  "ground": {
    "type": "lava",          // plain | rubble | voidscar | hallowed | lava | thornbed | blight | hearth | mossbed | umbra
    "level": 1,              // hazard grounds only (1–2) = damage per trigger
    "height": 0              // 0 low | 1 Mountain (independent of type)
  },
  "object": { "name": "Stone Lion", "hp": 3, "tags": ["heavy"] },
  "air": null,
  "surge": { "def":"surge_definition_id", "owner":"wolf", "due":"next_owner_turn_start", "dir":null, "gid":"g78" },
  "zone": {
    "def": "zone_definition_id", // reference to authored definition, not an embedded schema
    "gid": "g77",            // patch id: all cells of one cast
    "owner": "tiger",
    "level": 1,              // 1–3
    "duration": 2,           // rounds left, starts at the skill's `duration`
    "dir": [1,0],            // push direction chosen at cast
    "anchor": [2,2]          // pull point chosen at cast
  }
}
```

State stores zone level, not independent effect values; runtime values use effect definitions and [§4.6](#46-zones-effects-rules--opposites). This example supplies no missing caps or scaling rules.

### 4.5 Lifecycles

|         Thing        |                                                   Clock                                                  |                                                Notes                                                |
|----------------------|----------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------|
| **Zone** | the resolved skill's duration; ticking follows [§2.4](#24-effect-timing-reference) | on expiry the zone is removed; no repaint. Authoring and upgrades: [gdd_skills.md](gdd_skills.md) |
| **Pending Surge** | scheduler integration: [§2.4](#24-effect-timing-reference) | charge, removal and authored aftermath follow the [central Surge profile](gdd_skills.md#surge) |
| **Ground**           | none — stays until changed | changed by authorized ground replacement/reset, authored Surge residue, destroyed props' aftermath ground or Voidscar spread; source restrictions and Voidscar immunity apply (§4.7); zones never change ground (§4.6) |

- **Persistence:** zones have a duration, pending Surges a detonation timer; ground has no expiry clock. Neither Voidscar nor Lava fades: ground requires a change to disappear, subject to its exceptions.
- Effects in one zone share its clock; separately authored status lifetimes remain permitted.

### 4.6 Zones: Effects, Rules & Opposites

**Runtime zone effects** resolve referenced definitions using the tags below; authoring legality and effect contracts: [gdd_skills.md](gdd_skills.md); generic event order: [§2.4](#24-effect-timing-reference).

- Every effect but `mend` has an **opposite**; compare zones by effects, never name.
- Effects hinder or help; support zones use `haste`, `quicken`, `extend`, `shield` and `mend`.

|                         Effect                        |           Trigger          |                      Action                     |    Opposite   |
|-------------------------------------------------------|----------------------------|-------------------------------------------------|---------------|
| `slow`                                                | while inside               | Movement −value (never below 1, Step unaffected) | `haste`       |
| `haste`                                               | while inside               | Movement +value                                 | `slow`        |
| `drain_init`                                          | while inside               | initiative −value (turn order!)                 | `quicken`     |
| `quicken` *(also Shrine, §4.10)*                      | while inside               | initiative +value                               | `drain_init`  |
| `drain_range`                                         | while inside               | Reach −value (min 1)                            | `extend`      |
| `extend`                                              | while inside               | Reach +value                                    | `drain_range` |
| `push`                                                | end of your turn           | move 1 in the **direction set at cast**         | `pull`        |
| `pull`                                                | end of your turn           | move 1 toward the **anchor square set at cast** | `push`        |
| `shield`                                              | when you take Surge damage | damage on this square −value                    | `expose`      |
| `expose` *(reserved)*                                 | when you take damage       | damage +1                                       | `shield`      |
| `mend`                                                | end of your turn           | heals `min(2, zone level)`, never above max HP  | none          |

- Effects hit **everyone** on the square — allies, enemies and caster; placement matters because enemies can use your healing zone too.
- `expose` remains reserved, with no approved zone.

- **Level-to-value:** definitions supply base and cap. Where the existing level formula applies, **effective value** = `min(cap, base + level − 1)`, min 1 (slow capped at 2; push/pull always 1). Compute live, with no aspect modifier.
- This formula is not a default for undefined scaling: `mend` heals `min(2, zone level)` *(user decision 2026-11-10; zone-level price still open)*; other missing effect bounds remain T02/T04 ([temp_todo.md](temp_todo.md)).

**When a zone lands on a square that already holds one:**

|                                Existing zone                                |                                        Result                                        |
|-----------------------------------------------------------------------------|--------------------------------------------------------------------------------------|
| none                                                                        | **new**                                                                              |
| **same zone** (same definition)                                             | **levels up** (max III) and refreshes to its full `duration`; the patch id becomes the new cast |
| **opposite** — any effect of one is the opposite of any effect of the other | **levels subtract:** equal levels cancel and the square is empty; otherwise the higher zone stays with the difference, its clock unchanged |
| anything else                                                               | **replaced** (level I)                                                               |

Examples by effect, not retired skill names:
- Equal-level `(slow, pull)` versus `(push)` → cancel; `(quicken, haste)` versus `(drain_init, slow)` → cancel.
- Level I `(push)` versus level III `(slow, pull)` → the latter stays at level II; different definitions without opposite effects → replaced.

No merging: a square always shows exactly one zone with its real effects.

**Zone × ground** *(user decision 2026-11-10)*: the aspect triangle and its clearing / strengthening rules are removed without replacement. Zones and ground stay independent: a zone never changes, suppresses or inverts ground, and ground never changes a zone. They combine only through their separate effects on the same square. Ground changes come only from the sources listed in §4.7; countering permanent hazard ground is a T13 test item.

### 4.7 Ground — neutral, hazard and blessed

| Group | Ground | Effect |
|-------|--------|--------|
| Neutral | **Plain** | move cost 1 |
| Neutral | **Rubble** | move cost 2; left by several destroyed props (catalogue, §4.10) and destroyed Mountains (when the destroying skill authors no ground change) |
| Neutral | **Voidscar** | 1 damage at the **start** of your turn; permanent, spreads late-game (§4.2), nothing changes it |
| Hazard | **Lava** I–II | damage = level at the **end** of your turn — *punishes staying* |
| Hazard | **Thornbed** I–II | damage = level when you **enter** the square (move, push or pull) — *punishes moving* |
| Hazard | **Blight** I–II | damage = level at the **start** of your turn — *punishes being there when your turn begins* |
| Blessed | **Hearth** | initiative +1 while you stand on it (`quicken 1`) |
| Blessed | **Mossbed** | heals 1 when you **enter** the square (move, push or pull), never above max HP — *rewards moving* |
| Blessed | **Umbra** | Reach +1 while you stand on it (`extend 1`) |
| Blessed | **Hallowed** | Surge damage on this square −1; replaced only if actual residue is laid there under the applicable ground rules. No automatic consumption on a Surge hit; without replacement it remains |
| Height | **Mountain** | the only height state; combines with any ground type; +1 Reach for the unit there; **climbing up costs 2 movement**; **pushed off → 1 fall damage** (details below) |

**Mountain rules:**

- Ground on a Mountain changes only through skills whose definition allows it.
- Climbing up costs 2 movement, subject to [movement-profile exceptions](gdd_skills.md#movement); pushed off a Mountain → 1 fall damage ([§6.3](#63-collision-fall--debris)).
- Removed only by an explicit Mountain-destruction operation (below); can be raised under a charging Surge. Type-specific Surge interactions: [central Surge profiles](gdd_skills.md#surge).

**How ground is made:**

- **Field effects** lay their specified level I hazard ground, also on Mountain
- **Surge residue** applies the explicitly authored ground operation under the [central Surge profile](gdd_skills.md#surge) and [board-operation contract](gdd_skills.md#4-effect-and-board-operation-contracts); generic Surge execution alone lays no ground
- **Blessing skills** lay blessed ground. It has no levels and is permanent; casting still spends the central authored AP price (§2.3)
- All ground is **permanent**: it stays until something changes it (§4.5)
- **Same type** on the square → hazards +1 level (max II), blessed ground stays as it is
- **Different type** → the new ground **replaces** the old one under the applicable ground/source rules; this is not automatic conversion by a skill name or theme
- **Coupled height/reset (Raise Ground):** every skill that creates height creates a Mountain; Raise Ground raises it and resets ground to Plain, including Lava but excluding Voidscar. This source-specific [board-operation contract](gdd_skills.md#4-effect-and-board-operation-contracts) grants no ground reset from height changes alone
- **Destroying a Mountain** *(user decision)*: only a skill whose definition authors an explicit Mountain-destruction `board_changes` operation does it; any skill may be authored with it, none has it implicitly. Resolution:
  1. The occupant takes **1 collapse damage**, an environmental damage like Voidscar, independent of any skill and not part of the skill's own damage (the Strike and Surge damage laws are unaffected).
  2. The Mountain is removed.
  3. The square's ground becomes the ground that same skill authors for it, if its definition can change ground on Mountain squares, otherwise **Rubble**.
  - Voidscar is never replaced. Props are separate: prop aftermath damage and pushes never destroy Mountains (ground left by a destroyed prop on a Mountain square: open, [§4.10](#410-prop-catalogue-and-damage)). Order against the skill's damage and residue: [§6.2](#62-surge-resolution-integration) step 4.
- **Air next to a Mountain** *(user decision; details 2026-11-10)*: a ground-layer monster standing on a Mountain can hit air-layer monsters on the **eight squares adjacent** to its own square with all of its attacks. For delayed Surges this is **fixed at cast**: the owner stands on a Mountain and the footprint square is adjacent to the owner's square at that moment; later movement or death of the owner changes nothing. A 2×2 attacker needs all four covered squares on Mountain (as for +1 Reach); adjacency is measured from the nearest covered square of each body, and an air-layer 2×2 is hit once if any covered square is adjacent. This is a board rule, not a skill property, and adds no skill price
- Placing ground beneath an occupant is not entry; entry triggers occur when the occupant enters the square. Mossbed has no re-entry or per-turn limit *(user decision 2026-11-10)*: every entry heals 1, bounded only by movement
- Blessed ground works for **everyone** on it, like a zone: an enemy can use your Mossbed too

### 4.8 No Attunement

- Attunement is entirely removed: no square field, repaint events, strength modifiers or display. This section number remains as a reference note.
- Ground types and height remain concrete board state; zone expiry only removes the zone. Surge aftermath applies residue only if explicitly authored as a `board_changes` effect.

### 4.9 Props

```
SOLID   → cannot enter (every ground-layer prop)
FLYING  → air layer (air content at Soul+); the Pagoda Bridge occupies both layers (§4.10)
```

**Prop principles** *(user, 2026-11-10/11)*:
- **No Field class:** ground-layer props are always Solid (Umbra ground already provides "Reach +1 while standing"). Air-layer props are the only other class.
- **Fixed, previewed aftermath:** every prop has its own aftermath, fixed by its type and independent of who or what destroyed it and from which direction. It is shown in the cast preview. **No chain reactions:** aftermath damage hits monsters only, never props.
- **Creatable by skill:** every prop type may be created by an authored prop source (empty cell required); creation prices are open (T02). Board generation may pre-place any type.
- **Prop damage rights:** damaging offensive sources (Strike, Surge) hit props like monsters; movement, support and zones damage props only through an explicitly authorized prop effect.
- **No indestructible prop** *(user decision 2026-11-11)*: every prop can be destroyed; the former Pillar, Wall, Tree and Rock are replaced by the catalogue below.
- **Timing, conflicts and symmetry:** destruction and aftermath order: [§6.2](#62-surge-resolution-integration) step 4; placement symmetry: [§4.1](#41-battlefield-generation).

### 4.10 Prop Catalogue and Damage

**Status: working draft** *(user chose the concept 2026-11-11; names, HP and aftermath values are calibration drafts until T13; creation prices T02)*. Classes: **inert** (nothing beyond ground), **burst** (damage on neighbouring squares), **residue** (leaves ground), **push** (displaces neighbours), **spawn** (creates child props), **aura** (works while standing).

| Prop | Class | HP | While standing | On destruction | Ground left |
|------|-------|----|----------------|----------------|-------------|
| Stone Lion | inert | 3 | `heavy`: cannot be moved | nothing | Rubble |
| Clay Urn | burst | 1 | — | 1 damage to monsters on the 8 neighbouring squares | Plain |
| Bamboo Stand | burst | 2 | — | 1 damage to monsters on the 4 cardinal neighbours | Plain |
| Paper Lantern | residue | 1 | — | nothing | Lava I |
| Peach Tree | residue | 2 | — | nothing | Mossbed |
| Ancestor Tablet | residue | 2 | — | nothing | Hallowed |
| Bronze Gong | push | 2 | — | monsters on the 8 neighbouring squares are pushed 1 square away from the gong | Plain |
| Pagoda Column | spawn | 3 | — | creates a Beam on each of the 4 cardinal neighbours that is free of props and monsters | Rubble |
| Beam | inert | 1 | child prop, created only by the Column | nothing, spawns nothing | Plain |
| Wind Chime *(air)* | inert | 1 | air layer only: blocks flight and air occupancy | nothing | — (ground unchanged) |
| Thunder Cloud *(air)* | burst | 1 | air layer only | 1 damage to air-layer monsters on the 8 neighbouring squares | — (ground unchanged) |
| Gale Banner *(air)* | aura | 2 | air layer only: air-layer monsters on orthogonal neighbours get `quicken 1` | aura ends | — (ground unchanged) |
| Pagoda Bridge *(both layers, draft)* | inert | 3 | occupies ground and air layer of its square, blocks both | nothing | Rubble |
| Shrine | aura | 2 | orthogonal neighbours get `quicken 1` | aura ends | Rubble |
| Totem | aura | 2 | orthogonal neighbours get `extend 1` | aura ends | Rubble |
| Banner | aura | 2 | orthogonal neighbours get `haste 1` | aura ends | Rubble |
| Wardstone | aura | 2 | orthogonal neighbours take 1 less Surge damage (summed under [§6.1](#61-the-damage-law)) | aura ends | Rubble |

**Air and both-layer props** *(user decisions 2026-11-11)*: air props never change ground; their aftermath damage reaches only air-layer monsters. The Pagoda Bridge is a draft concept: it needs an empty square in both layers, is hit by Strikes and by any Surge whose recipients include ground or air, takes a hit once per payload, and is the only prop with two layers. Its details, and all air-prop prices, are to be confirmed in T09/T02.

**Aura props** *(user: auras add tactical depth and a prop-versus-zone choice)*: all four share one template (solid, 2 HP, orthogonal-adjacent, work for everyone including enemies) with one stat effect each from [§3.1](#31-effective-stats); the template is meant to be one parameterized definition. Wardstone needs early cap checking in T13.

**Data model (draft)**

```yaml
prop_def:
  id: clay_urn
  class: burst            # inert | burst | residue | push | spawn | aura
  layer: ground | air | both   # default ground
  hp: 1                   # every prop is destructible
  solid: true             # ground-layer props are always solid
  tags: []                # heavy = cannot be moved
  creatable_by_skill: true
  aura: null              # class aura only: { area: orthogonal_adjacent, effect: { stat, modifier } }
  on_destroy:             # fixed, previewed, direction-independent typed operations
    - damage: { pattern: ring8 | cardinal4, amount: 1, recipients: monsters }
    - push:   { pattern: ring8, direction: outward, distance: 1 }
    - spawn:  { prop: beam, pattern: cardinal4, skip_if_occupied: true }
    - ground: { set: plain | rubble | lava_1 | mossbed | hallowed }
  reactions: []           # explicit-effect reactions (§4.11)
  price_ref: TBD          # Skills §5 creation price, not defined
```

**Damage to props** *(draft)*: an ordinary Surge hit deals **2 damage** and intercepts the hit instead of hitting a monster there (ground-layer props are always Solid, so no monster shares the square); Strike damage and profile exceptions follow the [central execution profiles](gdd_skills.md#3-skill-execution-profiles); collision deals 1 to the prop (a `heavy` prop takes none, [§6.3](#63-collision-fall--debris)); fall, collapse and aftermath damage never affect props.

**Aftermath resolution** *(user decisions 2026-11-11)*:
- Ground left behind is laid in category (e) of [§6.2](#62-surge-resolution-integration) step 4; the Gong push resolves directly after (a) (before Cleanse), using the §6.2 tie rules.
- Ground left behind never changes a Mountain square and never replaces Voidscar; on such squares the prop's damage, push and spawn still resolve, only the ground stays.
- The Pagoda Column's Beams are the only prop-creating aftermath; Beams spawn nothing.
- **Open (T02):** creation prices and valuation of `on_destroy` operations.

### 4.11 Prop Reactions

**Status: reduced to the one remaining tag.** The catalogue above defines aftermath, so the former ignite, extinguish and crumble reactions (Tree/Wall) no longer have a prop to act on.

- Tags react only to **explicit effects of the concrete skill**, never monster themes or blanket aspect categories. Reactions are data (`prop_def.reactions`) and shown in the cast preview.
- **`heavy`** (Stone Lion): cannot be moved by displacement or relocation.
- The Surge profiles carry no prop-specific exceptions *(user decision 2026-11-11)*; see [Skills §3](gdd_skills.md#surge).
- Zones on prop squares wait; once the prop is gone, the zone works normally there.

---

## 5. Skill Integration

### 5.1 Monster Skills: Central Specification

**Monster-skill definitions and skill-specific execution rules live only in [gdd_skills.md](gdd_skills.md).**

Battle resolves finished skills against the turn/event system (§2), board state (§4) and generic damage, displacement and collision (§6); no second skill schema, profile catalogue, point budget or AP price list.

| Topic | Central source |
|-------|----------------|
| Kit, access and species/Signature restrictions | [§1](gdd_skills.md#1-the-kit) |
| Data fields, footprint/placement, interaction flags and sight | [§2](gdd_skills.md#2-data-oriented-skill-construction-kit) |
| Strike, Surge, movement presets and execution constraints | [§3](gdd_skills.md#3-skill-execution-profiles) |
| Effects and explicit ground/height/prop operations | [§4](gdd_skills.md#4-effect-and-board-operation-contracts) |
| Construction points, AP efficiency and budget ceilings | [§5](gdd_skills.md#5-construction-points-and-ap-efficiency) |
| Slot levels 1–3, development, upgrades and replacement | [§6](gdd_skills.md#6-slot-levels-development-replacement-and-upgrades) |
| Validation of skill records | [§7](gdd_skills.md#7-validation-and-concrete-skill-records); concrete skills: [gdd_skills.md](gdd_skills.md) |

Missing rules remain in [temp_todo.md](temp_todo.md), not implicit runtime defaults.

### 5.2 Tamer Skills and Battle Loadout

Battle resolves explicit effects from the human tamer's prepared loadout under general event/board rules, deterministically and with previews. Wild monsters retain monster skills, but have no tamer skills or human loadout.

**Authoritative Overworld sources** (no monster-skill AP prices or permissions transfer):
- [§6.4 Tamer Skills](gdd_overworld.md#64-tamer-skills): definitions, slots, access and usage.
- [§2.1 Battle Loop](gdd_overworld.md#21-battle-loop) and [§7.9 Inventory and Loadout](gdd_overworld.md#79-inventory-and-loadout): preparation, visibility and loadout logistics.
- Planned medicines and arrays: [§6.6](gdd_overworld.md#66-pills--medicines) and [§6.8](gdd_overworld.md#68-arrays-artifacts-for-places).

**Tamer activation and confirmed skill rules** *(user decisions 2026-11-11)*:
- **Window:** a slotted skill (once per battle, free) may be used during the turn of one of the tamer's own monsters, never inside a payload resolution or during enemy turns; it costs no AP and no turn and has a normal preview.
- **Swap Places:** two own 1×1 ground-layer monsters trade squares; no range or LOS. Each counts as entering its new square (ground entry effects fire, as for move/push/pull).
- **Urgent Order:** an own monster that has not acted this round is inserted directly after the current turn; its original entry of this round is removed (no double action). Extra-turn entries are not affected; the round-end re-sort is unchanged.
- **Second Wind:** one own monster on the field regains 1 HP (never above max); it unlocks no monster healing.
- **Life Thread:** set on one chosen own monster, effect and consumption as in [§6.1](#61-the-damage-law); it also protects in Deadly dungeons (death/injury details T23).
- **Beast Swap:** the incoming monster takes the square and queue entry of the swapped-out monster (it acts this round only if that entry is still pending), arrives with its current HP and must have the same body size (1×1 for 1×1, 2×2 for 2×2). The swapped-out monster is not defeated and may be swapped back later; its pending Surges stay and detonate like orphaned Surges at the next round start ([§2.2](#22-initiative-rules)). Soul Tier gate unchanged.
- Remaining integration details (other skills, loadout, source-specific resolution): T18–T20.

**Unresolved integration contract:** source-specific resolution of the remaining tamer skills and loadout details are tracked in [temp_todo.md](temp_todo.md), T18–T20; this section supplies no default timing or cost.

---

## 6. Damage & Displacement

### 6.1 The Damage Law

> **The Surge is the burst.** It is the only skill that deals more than 2 damage to monsters; prop damage has source-specific exceptions in the [central damage contracts](gdd_skills.md#4-effect-and-board-operation-contracts).
> - **Strike:** max 2 against monsters; body-relative execution and authored AP follow the [central Strike profile](gdd_skills.md#strike)
> - **Hazard ground:** its level (max 2) at its trigger; Voidscar: 1. Ground effects: [§4.7](#47-ground--neutral-hazard-and-blessed); generic schedule: [§2.4](#24-effect-timing-reference)
> - **Collision** (pushed into a prop or monster; contract: [§6.3](#63-collision-fall--debris)), **fall** (pushed off a Mountain), **Mountain collapse** (environmental, independent of the destroying skill, §4.7) and **prop aftermath damage** (Clay Urn, Bamboo Stand; §4.10): 1 each
> - **Zones never deal damage.** Nothing else deals damage the instant it is cast

**Damage modifiers** *(user decision 2026-11-10)*:
- **One calculation:** damage = authored/derived base + all applicable increases − all applicable reductions, summed in one step, then floored at 0. Order-independent; several sources **add** without a cap. Each source modifies only the damage types it names (zone `shield` and Hallowed: Surge damage; passives such as Thick Hide: as worded in [Skills §9](gdd_skills.md#9-passives)); no permissions transfer between zone-, ground- and passive-based sources.
- **Zero damage still hits:** a hit reduced to 0 damage still applies its Kin effect, displacement, retreat and board operations; nothing is consumed (Hallowed remains).
- **Ceilings apply to the base only** *(user decision 2026-11-11)*: the maxima above (Strike 2, hazard level, etc.) limit the authored/derived base damage; increases add on top afterwards, still floored at 0. This approves no increase source (`expose` stays reserved) and does not change skill prices or the no-damage-upgrade policy.
- **Two protection kinds** *(user decision 2026-11-11)*: **value reduction** (zone `shield`, Hallowed, passives) joins the sum above. **Nullify** (e.g. the tamer skill Spirit Shield, and monster-skill equivalents) is an override applied *after* the sum: the Surge damage on the protected monster becomes 0 whatever increases exist. It is consumed by the first Surge damage instance that would deal at least 1 after the sum; a hit already reduced to 0 consumes nothing; one Nullify per monster, no stacking. Nullify is priced far above value reduction (Skills §5, open T02).
- **Survive effect** (tamer skill Life Thread): at the defeat step ([§6.2](#62-surge-resolution-integration) step 2 and after category (a)) the first time the protected monster would fall, from any damage source, its HP becomes 1 and the effect is consumed; further simultaneous damage of that round changes nothing; later lethal damage defeats it normally.

### 6.2 Surge Resolution Integration

- Charge/detonation/autonomy and profile rules: [Skills §3](gdd_skills.md#3-skill-execution-profiles); no second lifecycle here.
- The turn scheduler (§2.1–§2.4) dispatches due Surges; board state/reactions (§4) and generic damage/displacement (§6) resolve their declared effects.

**Payload resolution order** *(user decision, applies to every Strike and Surge detonation payload)*:

1. **Damage** to all struck monsters/props simultaneously.
2. **Defeat:** units reduced to 0 HP are removed before anything else resolves, so they are neither displaced nor affected by later steps.
3. **Displacement** (push/pull) of the survivors, one unit at a time, **the unit furthest along the movement direction first** (for pull: nearest the anchor first), so units in a line do not block each other needlessly.
   - Sideways units use independent lanes; radial pushes of 1×1 targets from one body-relative shape have pairwise distinct destinations ([Skills §3](gdd_skills.md#body-relative-damage-and-movement-variants)).
   - Collision, fall and entry effects fire at the moment of each move ([§6.3](#63-collision-fall--debris), [§2.4](#24-effect-timing-reference)).
4. **Board operations and residue** (ground, height, prop, Mountain destruction incl. its collapse damage; the destruction sequence is in [§4.7](#47-ground--neutral-hazard-and-blessed)). Fixed category order *(user decision 2026-11-10, (d) added 2026-11-11)*: (a) **removals** (prop destruction with its aftermath damage/push/spawn per [§4.10](#410-prop-catalogue-and-damage), Mountain destruction with its collapse damage), (b) **Cleanse**, (c) **height creation** (with its Plain reset), (d) **prop placement/relocation** *(user decision 2026-11-11; sees the final height)*, (e) **ground placement / residue**. Residue therefore lands after displacement: pushed units do not end in residue laid by the same payload unless they stand there afterwards, and entering it is not retroactive.
   - **Prop destruction timing** *(user decision 2026-11-11)*: a prop reduced to 0 HP in steps 1–3 (payload damage or collision) stays on the board and keeps blocking until (a); further collisions with it change nothing. At (a) all 0-HP props are removed simultaneously, their aftermaths are evaluated against the board as it stands at the start of (a) (a 0-HP prop still counts as a prop, so a Beam is not created on its square), damage from several aftermaths on one monster adds, and monsters reduced to 0 HP are then defeated. A destroyed Bronze Gong's push resolves right after (a) and before (b), under the displacement and tie rules of steps 3 and this section; its collisions resolve as usual ([§4.10](#410-prop-catalogue-and-damage)).
   - **Environmental damage in (a)** *(user decision 2026-11-11)*: prop aftermath damage and Mountain collapse damage form one simultaneous damage round on the occupants as they stand after displacement (step 3) and add. Defeat follows immediately after (a); only then (b) Cleanse, (c) height creation, (d) prop placement/relocation and (e) ground placement resolve, and defeated units receive none of them.
   - **Same-category conflicts on one square** *(user decision 2026-11-11)*: within categories (c), (d) and (e), competing operations resolve one after another in current initiative-queue order (as for displacement ties). Each checks legality on the board left by the previous one: same hazard ground +1 level (max II), different ground replaces under the applicable ground rules, a second prop on an occupied square or a second height creation on a Mountain does nothing. Category (a) removals stay simultaneous.
5. **Self retreat** ([Skills §3](gdd_skills.md#body-relative-damage-and-movement-variants)) on the resulting board state.

The order is fixed by this list, not by data-field position or per-skill authoring.

**Legality at execution** *(user decision 2026-11-10)*: legality is checked per square and per operation on the board as it is at detonation, so a Surge can be countered by prop placement, height or ground changes made after the cast. A square or operation that is no longer legal (e.g. residue on a square now holding a prop, destroying a Mountain that is already gone) does nothing; everything else resolves normally. No retargeting, replacement square or refund of AP or usage.
  - Whether a blocker also stops the rest of the footprint behind it depends on the Surge: **line-shaped footprints** are stopped by the first prop along the line from the anchor end (a Stone Lion on the middle square of a three-square line from one end also spares the squares beyond it), all other shapes lose only the blocked square *(user decision 2026-11-10)*. Which Surges are line-shaped is part of each Surge's authored shape and can differ from Surge to Surge ([Skills §3](gdd_skills.md#surge)); the prop's own interception and reactions follow the profile table.

**Several Surges due at once** *(user decision 2026-11-10; applies to Surges of any casters, e.g. dead-caster Surges at the same round start)*: Surges due at the same event resolve **phase by phase together**: all damage simultaneously, then defeat, then displacement (still furthest-first), then board operations in the category order above, then self retreats. No order between Surges is needed. **Ties** *(user decision 2026-11-10: simultaneous, no precedence)*: damage from several sources on one target is applied simultaneously and adds; they create no source priority. Displacements keep the furthest-first rule; when two displaced units compete for one destination square or lie equally far along different directions, *(user decision 2026-11-10)* they resolve in their current initiative-queue order, and the later one collides under [§6.3](#63-collision-fall--debris). No other precedence between sources exists.

Cleanse has no monster source beyond the Mountain-creation reset (Skills §4). Confirmed autonomy is unchanged.

### 6.3 Collision, Fall & Debris

- Pushed or pulled into a **prop**: no move, 1 damage to the monster and 1 to the prop (heavy props take none)
- Into a **monster**: no move, **1 damage to each of the two monsters** · off the **board edge**: no move, no damage
- **Collision contract** *(user decision)*: the monster-collision damage is derived runtime damage, not an authored component, and grants no bonus collision damage or retired collision perks. Passive modifiers such as Crashlander or Thick Hide change only the damage of the monster they name.
- **Blocked multi-step displacement:** a unit moves step by step and stops on the last free square. The blocked step is the collision (once per displacement; remaining steps are lost). A pull whose path or anchor square is occupied follows the same rule; no alternative square
- **Off a Mountain**: the move happens, 1 fall damage · onto Mountain from below: blocked like a prop, no damage
- **2×2 displacement** *(user decision 2026-11-10; details T09)*: a push/pull moves the whole body one square; if any newly covered square is blocked, there is **one collision** and no move: the 2×2 takes 1 damage once, and each blocking monster and each blocking prop takes 1 (heavy props none). Falling from a Mountain deals the 1 fall damage only if **all four** covered squares land lower; a partial fall moves without fall damage. Pushing a 2×2 up onto a Mountain from below is blocked, with no damage, as soon as any covered square would climb. Radial pushes and pulls for 2×2: [Skills §3](gdd_skills.md#body-relative-damage-and-movement-variants). Open: landing on mixed ground.
- **Prop destroyed**: resolve the type's aftermath ([§4.10](#410-prop-catalogue-and-damage)); removal timing: [§6.2](#62-surge-resolution-integration) step 4(a); no destruction-method exceptions remain

### 6.4 General Rules

- No defense stat — damage reduction via zone-based Surge reduction, ground-based Surge reduction (§4.7) and authored passives
- All damage exact and previewed
- Surge autonomy follows the [central Surge profile](gdd_skills.md#surge); its caster's death does not cancel it, and dead-caster timing is in [§2.2](#22-initiative-rules)
- Generic trigger scheduling and turn order have one reference: [§2.4](#24-effect-timing-reference); source-specific execution remains in the resolved definition

### 6.5 Displacement

- **Generic displacement:** cardinal, one square per trigger, with previewed landing.
  - The scoped adjacent-hit eight-direction exception and coupled self retreat are defined only in [Skills §3](gdd_skills.md#body-relative-damage-and-movement-variants); they do not change zone/Surge direction rules.
  - Other push sources use their authored cast/Strike direction; pull uses the board anchor fixed at cast.
  - **Pull on an exact diagonal** *(user decision 2026-11-10)*: if the anchor lies exactly diagonally from the target (`|dx| = |dy|`), there is no unique cardinal direction and the pull does not move the target (other effects of the hit remain).
  - Blocked moves: [§6.3](#63-collision-fall--debris); entry/end-event integration: [§2.4](#24-effect-timing-reference).
- Zone effects: [§4.6](#46-zones-effects-rules--opposites). Authored spatial on-hit push/pull and delayed footprint-bound displacement get recipients, bindings and triggers from the [central displacement contracts](gdd_skills.md#4-effect-and-board-operation-contracts), not a second profile catalogue here. Ties and combined-effect order: [§6.2](#62-surge-resolution-integration).

**Why end of turn:** at turn start the target could simply walk away again; at turn end it lands in Lava, through Thornbed, in front of your Strike or in a Surge detonating before it can move again. Visible counterplay: don't end your turn on a current.

---

## 7. Technical & Prototype

### 7.1 Technical Notes (Battle)

**Current design requirements (not an implementation-completeness claim):**

- Godot 4 · **3D square grid, orthogonal camera ~45°** — never hex. Art pipeline: low-poly Blender + AI textures
- Skill authoring follows the [shared data model](gdd_skills.md#2-data-oriented-skill-construction-kit), [effect contracts](gdd_skills.md#4-effect-and-board-operation-contracts) and [validation](gdd_skills.md#7-validation-and-concrete-skill-records) (concrete skills: [gdd_skills.md](gdd_skills.md)), not the historical Resource layout below
- Battle logic should remain headless and engine-independent; runtime state: [§4.4](#44-square-data-model). Queue, board interactions and damage follow their owning sections here
- Preview, AI and resolution must share deterministic rules and expose board reactions, authored aftermath and displacement landings; generic timing in [§2.4](#24-effect-timing-reference) does not imply complete event ordering
- Effect comparisons, explicit prop reactions, scoped interaction fields and authored footprints/anchors resolve from their definitions. Movement blocking uses the resolved [movement profile](gdd_skills.md#movement), not a blanket marker rule

**Unresolved implementation contracts:** T02/T07/T09 in [temp_todo.md](temp_todo.md); prototypes do not settle these current design gaps.

**Historical v6.0 implementation notes — not the current authoring schema or complete current runtime:**

- One Resource per monster / skill / zone in `data/monsters`, `data/skills`, `data/zones`, typed by `MonsterDef`, `SkillDef`, `ZoneDef`.
  - `GameData` indexes by `id` (= file name); startup validation checks duplicate ids, missing Surge/utility, unknown shapes/passives, species learn-list references, concrete Surge types/effects and stat ranges.
  - The legacy Surge/utility requirement does not override the [open kit rules](gdd_skills.md#1-the-kit)
- The headless board uses a 2D array of Square objects storing `{ ground{type, level, height}, object, surge, zone }`, with level-derived zone effect values. These fields are not an alternative current schema
- Documented preview architecture: pure `preview_cell(skill, cell)` returns `new | level | replace | weaken | cancel | lost`, shared by preview, AI and unit tests. This does not establish implementation of revised contracts or optional residue
- Shape orientations use base shapes (rotate + mirror, de-duplicated), anchor nearest the centroid. Current design instead requires explicit [footprint/anchor mappings](gdd_skills.md#footprints-and-placement); missing mappings remain T02

### 7.2 Prototype & Playtests

**Historical implemented baseline (v6.0):**

- `godot/`: main menu → draft (pick 3 of the 9 roster monsters, or 1 for a duel) → **3v3 on 7×7** or **1v1 on 5×5** against an AI team drawn from the rest; headless core (`godot/battle/core/`) implements historical v6.0, not the revised design.
- `html_prototype/battle-prototype-v5-zones-ground.html` is the older v5 reference; neither prototype validates the current design.

**Tools:**

- `godot/tests/`: gdUnit4 suites for the rules; project layout in `godot/README.md`.
- `godot/tools/sim.gd`: AI-vs-AI batch simulation with win rates per monster.
- `godot/tools/smoke_ui.gd`: plays the player's side through the real UI headless.

**Historical v6.0 simulation (60 AI-vs-AI 3v3 battles, random teams):**

- Sides win 50/50, ~14 rounds per battle with free rotation — **~19 rounds with fixed shapes**.
- Reported outlier: **Dusk Moth wins 87%** (Native Ground + Wide Eclipse + Blight residue).
- Blight is the biggest damage source after Eruption; historical Veil zones absorb many hits (230 blocked); arena collapse decides ~1 in 5 battles.

These results describe that historical ruleset, not current balance.

Playtest planning and outstanding checks: [temp_todo.md](temp_todo.md), T13.

---

## 8. Design Tracking

Open decisions/playtest checks: [temp_todo.md](temp_todo.md). This GDD records the current working design; moving review tasks does not finalize provisional values.
