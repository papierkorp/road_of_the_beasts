# GDD — BATTLE SYSTEM
*Working Draft — Options, not luck · companion specifications: [Monsters & Skills](gdd_monsters.md), [Overworld & Meta](gdd_overworld.md) · historical prototypes and test results: [§7](#7-technical--prototype)*

---

## 1. Overview

Turn-based, isometric monster battles about **grid control**, fully deterministic and readable. Inspired by *Into the Breach*.

- **This document:** general turns/events, runtime board state/interactions and generic damage/displacement.
- **Monster definitions, skills, costs and upgrades:** [gdd_monsters.md](gdd_monsters.md); skills: [chapter 4](gdd_monsters.md#4-skills).
- **Meta progression, tamer skills and loadout:** [gdd_overworld.md](gdd_overworld.md).
- **Open decisions and validation tasks:** [temp_todo.md](temp_todo.md); working values here are not gameplay-validated.

### 1.1 Battle Modes

|   Mode  |  Board  |                                             Role                                            |
|---------|---------|---------------------------------------------------------------------------------------------|
| 1v1     | 5×5     | duel / tutorial, early game                                                                 |
| 2v2     | 6×6     | step between duel and team battle                                                           |
| **3v3** | **7×7** | **standard battle** — enough monsters for combos between allies, short enough for a session |
| 5v5     | 9×9     | special battles only (bosses, tournaments), later                                           |

The encounter chooses a mode within the player's available team size: 1v1 from the start, **3v3 and 2v2 from Foundation**, 5v5 special battles from Core Formation ([gdd_overworld §6.3](gdd_overworld.md#63-stage-unlock-table)).

- **Why 7×7 for 3v3:** 6 monsters on 49 squares is about as crowded as 2 on 25 (1v1), keeping pressure similar; 8×8 leaves more room to escape a 3–4 cell Surge ("too easy to dodge"). An odd size provides a **centre square** for contested high ground and mirror-fair starts.
- Small kits aim to keep 3v3–5v5 readable; kit size and rarity exceptions: [gdd_monsters §4.1](gdd_monsters.md#41-the-kit).

### 1.2 Battle Design Pillars

1. **Control squares, not just units** — shaped skills claim squares; body-relative attacks and unit-targeted effects keep their own placement rules. The board is the weapon
2. **Deterministic & readable** — before confirming, see exactly which squares a cast takes, levels up, cancels, replaces or loses, its ground/prop effects and every pushed monster's landing
3. **Everything reacts, nothing deletes** — no delete button; small, data-driven rules. Zone overlaps use definitions and opposite effects ([§4.6](#46-zones-effects-rules--opposites)): opposite levels subtract, cancelling at equal levels. Concrete skill effects change ground and trigger prop reactions; zone × ground remains unresolved ([temp_todo.md](temp_todo.md), T07).
4. **The Surge is the burst** — big damage (3+) only comes from a declared, charging, autonomous Surge. Small damage comes from Strikes (max 2), hazard ground (max 2 per trigger), collisions, falls and debris (1). Zones never deal damage themselves
5. **Every threat has a real answer** — leave, apply zone-based Surge damage reduction, change the ground under it, pick the right height for that Surge type, block with props, answer with your own Surge
6. **Options, not luck** — fully deterministic and visible; variety comes from many meaningful turn choices (position, threat, reaction), never dice or hidden information
7. **Low HP, high stakes** — one mistake can be fatal
8. **Dynamic battlefields** — ground and props are resources; squares remember explicit board changes; Surges rewrite them only when their definition includes such effects
9. **One skill source** — monster-skill authoring/access: [gdd_monsters chapter 4](gdd_monsters.md#4-skills), linked from [§5](#5-skill-integration). No fixed aspect or replacement element categories

---

## 2. Battle Flow

### 2.1 Core Battle Loop

1. Battlefield generated (ground, props, contested high ground — §4.1)
2. Pre-battle: choose monsters and place them in your start area; preparation/loadout: Overworld sources in [§5.2](#52-tamer-skills-and-battle-loadout). Start at **current HP** ([gdd_overworld §6.6](gdd_overworld.md#66-pills--medicines)).
3. **Each round:** one queue for all monsters of both sides, highest effective initiative first (§2.2)
4. **Monster's turn:** dispatch due events/effects, spend its **AP** on legal actions ([§2.3](#23-action-points)), then resolve end effects in [§2.4](#24-effect-timing-reference) order.
5. Round ends → resolve the round-end events in [§2.4](#24-effect-timing-reference)
6. Battle ends when one side has no monsters left

### 2.2 Initiative Rules

- **One queue for all monsters of both sides**, strictly by effective initiative, **recalculated every round**
- A side may act several times in a row — that is the reward for initiative, not a bug
- **Ties:** higher base initiative first; still tied → the sides alternate (the first tie of a battle goes to the side with the lower total initiative)
- An initiative-draining zone can flip the order, giving a monster two turns back to back across the round boundary — a real tempo weapon
- Multi-turn monsters get one extra queue entry per extra turn, each at −3 initiative (min 0.1)
- **Surge clock:** dispatch under [§2.4](#24-effect-timing-reference) and the [central Surge profile](gdd_monsters.md#surge). Initiative changes/extra turns mean other monsters are not guaranteed a turn before detonation; exceptional queue timing remains unresolved (T04).

### 2.3 Action Points

**Battle-AP per turn = the monster's AP stat** (2–5, [gdd_monsters §2.1](gdd_monsters.md#21-the-stats)).

- Pay the resolved monster action's authored Battle-AP cost: **at least 1 Battle-AP, never 0**. This does not redefine tamer/loadout usage.
- AP evaluation and construction prices: [gdd_monsters §4.5](gdd_monsters.md#45-construction-points-and-ap-efficiency); skill execution, development and access: [§5.1](#51-monster-skills-central-specification). Tamer/loadout costs use their own Overworld sources ([§5.2](#52-tamer-skills-and-battle-loadout)), not monster-action prices.
- **No cooldowns:** monster actions may repeat within a turn as AP, board and authored profile/usage limits permit, including **one charging Surge per monster** ([central execution profiles](gdd_monsters.md#43-skill-execution-profiles)); e.g. recast a zone to level it up before changing ground. Turns offer *repositioning*, *setting up* or *attacking*, not "whatever is off cooldown".
- **Positioning:** [movement and Strike profiles](gdd_monsters.md#43-skill-execution-profiles) make repositioning compete with attacking for Battle-AP. Their authored prices, not a separate rule here, determine what fits in one turn; board control can place a target inside the Strike shape without a preceding move.

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
| immediate / event-derived | on authored execution or the triggering event | Strike on use; collision / fall on impact; debris on shatter |

Order inside a turn:

1. Due Surges: damage → explicitly authored residue, if present, under the [central profile](gdd_monsters.md#surge).
2. Start effects.
3. AP.
4. End effects: displacement → end-turn ground damage → `mend`.

Entry effects apply when a monster enters a square, including by push / pull.

**Unresolved scheduling:** the sequence does not settle exceptional Surge queue timing or combined-event ordering ([temp_todo.md](temp_todo.md), T04); source-specific tamer/loadout activation windows remain T19/T20.

---

## 3. Monsters in Battle

Battle resolves a finished unit sheet. Monster definitions (sheet, stats, Kins, Strikes, kits, passives, roster, evolution): [gdd_monsters.md](gdd_monsters.md); loadout integration: [§5.2](#52-tamer-skills-and-battle-loadout).

### 3.1 Effective Stats

**Effective stats** combine the base sheet with all applicable, authorized modifiers, including zone, ground, height, prop and skill/passive sources.

- One zone per square limits zone occupancy, not cross-source stacking. Modifier contracts: [gdd_monsters §4.4](gdd_monsters.md#44-effect-and-board-operation-contracts); cross-source stacking, refresh and caps remain unresolved ([temp_todo.md](temp_todo.md), T02/T04).
- Board sources below are not an exhaustive modifier catalogue.

|     Stat    |                     Changed in battle by                     |
|-------------|--------------------------------------------------------------|
| Initiative  | `drain_init` / `quicken` (§4.6), Shrine (§4.10), Hearth (§4.7) |
| Movement    | `slow` / `haste` (§4.6); Step is always 1 square             |
| Reach       | +1 on Elevated, `drain_range` / `extend` (§4.6), Sigil (§4.10), Umbra (§4.7); min 1 |

### 3.2 Monster Identity & Skill Access

- **Free themes**, not fixed aspects or replacement element categories: identity comes from species, Kin, stats, skills and passives. Themes impose no matchup triangle or combat modifiers; there is no attunement (§4.8).
- Skill access and authored definitions: §5. Runtime ground types, zone effect tags, prop reactions and Surge behaviour use the resolved concrete definition, never the monster's theme.
- Zone × zone compares effects (§4.6); the replacement for triangle-based zone × ground interaction is **not yet defined** ([temp_todo.md](temp_todo.md), T07).

---

## 4. Battlefield

### 4.1 Battlefield Generation

- Procedural ground + props, **point-symmetric around the centre** so both sides get the same distances (mirrored fairness check for every mode)
- Contested Elevated squares near the centre, equidistant from both starts
- Pre-placed props shape the opening

|   Mode  |  Board  |                    Start area per side                    |     Contested Elevated     | Props |
|---------|---------|-----------------------------------------------------------|----------------------------|-------|
| 1v1     | 5×5     | opposite corners                                          | 2 near the centre          | 2–3   |
| 2v2     | 6×6     | back row                                                  | 2 near the centre          | 3–4   |
| **3v3** | **7×7** | back two rows; players place their monsters in pre-battle | 3: the centre + 2 flanking | 4–6   |
| 5v5     | 9×9     | back two rows                                             | 3–5                        | 6–8   |

**Unvalidated opening target:** on 7×7, intended 5–6-row start separation should reward acting first with position, not a free hit: no Strike or Surge reaching the enemy line in round 1. The start-area table does not guarantee this; validation remains T13 in [temp_todo.md](temp_todo.md).

### 4.2 Late-Round Pressure (Anti-Stalling)

- From a set round, the square farthest from all living monsters becomes **Voidscar** each round (permanent, undestroyable). Start scales with board size (tunable: 1v1 round 6, 3v3 round 8).
- **Collapse:** once no free square is left to convert, every living monster takes 1 damage per round — so every battle ends.

### 4.3 The Square Stack: Zones & Ground

```
[ AIR    ]  flying prop | flying monster | empty — immune to ground Surges
[ OBJECT ]  prop with tags (Tree: flammable · Wall: brittle · Rock: heavy · Pillar: indestructible) | empty
[ SURGE  ]  pending Surge marker | empty — shares shapes/placement with zones, never merges with them
[ ZONE   ]  ONE timed zone (the skill's `duration`) | empty — control and support
[ GROUND ]  type (neutral: Plain | Rubble | Water | Voidscar | Hallowed — hazard: Lava | Thornbed | Blight, lvl I–II — blessed: Hearth | Mossbed | Umbra), always permanent
            + height (Low | Elevated)
```

- all layers can be active at once · **1 object, 1 pending Surge, 1 zone, 1 ground type** per square
- zones may be placed on prop squares — the zone affects the prop only through the reaction table ([§4.11](#411-prop-reactions)); **Solid** props prevent monster occupancy, while **Field** props are enterable ([§4.9](#49-props))
- The existing immediate hazard-ground placement profile and coupled height/reset operation (§4.7) require prop-free squares, subject to explicit [§4.11 prop reactions](#411-prop-reactions). These are source-specific [board-operation requirements](gdd_monsters.md#44-effect-and-board-operation-contracts); blocking flags are profile-scoped, not a universal empty-square test ([gdd_monsters §4.2](gdd_monsters.md#interaction-fields))
- pending Surges may land on props and normally block voluntary movement; path blocking/landing legality use the resolved [movement profile](gdd_monsters.md#movement). Displacement (push / pull) **can** move monsters into their squares
- **zones = what you do to a square for a while; ground = what the board remembers**

### 4.4 Square Data Model

Illustrative **runtime board state only**, not a skill-authoring schema: entries store ownership, cast bindings, levels and remaining lifetime. Definitions resolve through the [shared monster-skill data model](gdd_monsters.md#42-data-oriented-skill-construction-kit) and [references/validation](gdd_monsters.md#47-complete-references-and-validation) (reference map §5).

```jsonc
{
  "pos": [2,1],
  "ground": {
    "type": "lava",          // plain | rubble | water | voidscar | hallowed | lava | thornbed | blight | hearth | mossbed | umbra
    "level": 1,              // hazard grounds only (1–2) = damage per trigger
    "height": 0              // 0 low | 1 Elevated (independent of type)
  },
  "object": { "name": "Tree", "hp": 2, "tags": ["flammable"], "burning": false },
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
| **Zone** | the resolved skill's duration; ticking follows [§2.4](#24-effect-timing-reference) | on expiry the zone is removed; no repaint. Authoring and upgrades: [gdd_monsters chapter 4](gdd_monsters.md#4-skills) |
| **Pending Surge** | scheduler integration: [§2.4](#24-effect-timing-reference) | charge, removal and authored aftermath follow the [central Surge profile](gdd_monsters.md#surge) |
| **Ground**           | none — stays until changed | changed by authorized ground replacement/reset, authored Surge residue, shattered props, debris or Voidscar spread; source restrictions and Voidscar immunity apply (§4.7); former triangle-based zone interaction unresolved (§4.6, T07) |

- **Persistence:** zones have a duration, pending Surges a detonation timer; ground has no expiry clock. Neither Voidscar nor Lava fades: ground requires a change to disappear, subject to its exceptions.
- Effects in one zone share its clock; separately authored status lifetimes remain permitted.

### 4.6 Zones: Effects, Rules & Opposites

**Runtime zone effects** resolve referenced definitions using the tags below; authoring legality and effect contracts: [gdd_monsters chapter 4](gdd_monsters.md#4-skills); generic event order: [§2.4](#24-effect-timing-reference).

- Every effect but `mend` has an **opposite**; compare zones by effects, never name.
- Effects hinder or help; support zones use `haste`, `quicken`, `extend`, `shield` and `mend`.

|                         Effect                        |           Trigger          |                      Action                     |    Opposite   |
|-------------------------------------------------------|----------------------------|-------------------------------------------------|---------------|
| `slow`                                                | while inside               | Movement −value (never below 1, Step unaffected) | `haste`       |
| `haste`                                               | while inside               | Movement +value                                 | `slow`        |
| `drain_init`                                          | while inside               | initiative −value (turn order!)                 | `quicken`     |
| `quicken` *(also Shrine, §4.10)*                      | while inside               | initiative +value                               | `drain_init`  |
| `drain_range`                                         | while inside               | Reach −value (min 1)                            | `extend`      |
| `extend` *(also Sigil, §4.10)*                        | while inside               | Reach +value                                    | `drain_range` |
| `push`                                                | end of your turn           | move 1 in the **direction set at cast**         | `pull`        |
| `pull`                                                | end of your turn           | move 1 toward the **anchor square set at cast** | `push`        |
| `shield`                                              | when you take Surge damage | damage on this square −value                    | `expose`      |
| `expose` *(reserved)*                                 | when you take damage       | damage +1                                       | `shield`      |
| `mend`                                                | end of your turn           | heal value, never above max HP                  | none          |

- Effects hit **everyone** on the square — allies, enemies and caster; placement matters because enemies can use your healing zone too.
- `expose` remains reserved, with no approved zone.

- **Level-to-value:** definitions supply base and cap. Where the existing level formula applies, **effective value** = `min(cap, base + level − 1)`, min 1 (slow capped at 2; push/pull always 1). Compute live, with no aspect modifier.
- This formula is not a default for undefined scaling: `mend` level scaling and numeric healing cap remain unresolved (T07); other missing effect bounds remain T02/T04 ([temp_todo.md](temp_todo.md)).

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

**Zone × ground — unresolved:** the aspect triangle and its clearing / strengthening rules are removed; their replacement is **not yet defined** ([temp_todo.md](temp_todo.md), T07). No blanket replacement rule is implied; concrete ground-changing skill effects remain as specified (§4.7).

### 4.7 Ground — neutral, hazard and blessed

| Group | Ground | Effect |
|-------|--------|--------|
| Neutral | **Plain** | move cost 1 |
| Neutral | **Rubble** | move cost 2; left by shattered props and collapsed Elevated |
| Neutral | **Water** *(planned)* | move cost 2, Swim crosses it at cost 1; traversal and Step exceptions: [movement profiles](gdd_monsters.md#movement). Water/Swim contract remains T08 |
| Neutral | **Voidscar** | 1 damage at the **start** of your turn; permanent, spreads late-game (§4.2), nothing changes it |
| Hazard | **Lava** I–II | damage = level at the **end** of your turn — *punishes staying* |
| Hazard | **Thornbed** I–II | damage = level when you **enter** the square (move, push or pull) — *punishes moving* |
| Hazard | **Blight** I–II | damage = level at the **start** of your turn — *punishes being there when your turn begins* |
| Blessed | **Hearth** | initiative +1 while you stand on it (`quicken 1`) |
| Blessed | **Mossbed** | heals 1 when you **enter** the square (move, push or pull), never above max HP — *rewards moving* |
| Blessed | **Umbra** | Reach +1 while you stand on it (`extend 1`) |
| Blessed | **Hallowed** | Surge damage on this square −1; replaced only if actual residue is laid there under the applicable ground rules. No automatic consumption on a Surge hit; without replacement it remains |
| Height | **Elevated** | combines with any type; +1 Reach for the unit there; **climbing up costs 2 movement**, subject to [movement-profile exceptions](gdd_monsters.md#movement); **pushed off Elevated → 1 fall damage**; collapses to Rubble from debris under the interim prop rules; can be raised under a charging Surge. Type-specific Surge interactions: [central Surge profiles](gdd_monsters.md#surge) |

**How ground is made:**

- **Field effects** lay their specified level I hazard ground, also on Elevated
- **Surge residue** applies the explicitly authored ground operation under the [central Surge profile](gdd_monsters.md#surge) and [board-operation contract](gdd_monsters.md#44-effect-and-board-operation-contracts); generic Surge execution alone lays no ground
- **Blessing skills** lay blessed ground. It has no levels and is permanent; casting still spends the central authored AP price (§2.3)
- All ground is **permanent**: it stays until something changes it (§4.5)
- **Same type** on the square → hazards +1 level (max II), blessed ground stays as it is
- **Different type** → the new ground **replaces** the old one under the applicable ground/source rules; this is not automatic conversion by a skill name or theme
- **Coupled height/reset (Raise Ground):** raises to Elevated and resets ground to Plain, including Lava but excluding Voidscar. This source-specific [board-operation contract](gdd_monsters.md#44-effect-and-board-operation-contracts) grants no ground reset from height changes alone
- Placing ground beneath an occupant is not entry; entry triggers occur when the occupant enters the square. Mossbed re-entry/healing limits remain central T07
- Blessed ground works for **everyone** on it, like a zone: an enemy can use your Mossbed too
- Damage from ground is capped at 2 per trigger; one ground per square, so hazards never stack

### 4.8 No Attunement

- Attunement is entirely removed: no square field, repaint events, strength modifiers or display. This section number remains as a reference note.
- Ground types and height remain concrete board state; zone expiry only removes the zone. Surge aftermath applies residue only if explicitly authored as a `board_changes` effect.

### 4.9 Props

```
SOLID   → cannot enter (Wall, Rock, Tree, Pillar, Shrine)
FIELD   → enterable, applies an effect to the monster on it (Sigil)
FLYING  → air layer only (later, with the air layer at Soul+)
```

**Prop redesign — incomplete draft:**
- Concrete mechanical influence should determine destructibility, resistance and destruction-specific aftermath. Most relevant offensive skills should interact with/destroy props; this grants no damage to utility or movement skills.
- Splintering can damage previewed cells; trees may split or burn down with different aftermaths. Initially, falling/splitting uses deterministic fall effects plus ground/visual remains, not separately movable tree halves. Preview every outcome; no random scattering.

**Unresolved destruction (T04):** reaction/destruction matrix and exact fall/aftermath definitions remain in [temp_todo.md](temp_todo.md). **§4.10–§4.11 and their debris references elsewhere are interim rules**, not final outcomes for every destruction method.

### 4.10 Damage, Shatter & Prop Types

**Interim prop rules — pending T04 redesign ([§4.9](#49-props)).**

- An ordinary Surge hit deals **2 damage to the prop**, intercepting the hit instead of hitting a monster there; shared Field-prop occupancy remains unresolved below. Strike prop damage and profile-specific exceptions: [central execution profiles](gdd_monsters.md#43-skill-execution-profiles); collision damage: [§6.3](#63-collision-fall--debris); reactions: [§4.11](#411-prop-reactions).
- At 0 HP a prop **shatters**: neutral Rubble replaces the ground; **1 debris damage lands on the four neighbouring squares**, also collapsing Elevated neighbours to Rubble.

**Unresolved Field-prop hit contract (T04):** the Surge wording (**2 damage to the prop and does not hit a monster there**) does not settle shared occupancy: only Solid props exclude occupants; Field props such as Sigil are enterable ([temp_todo.md](temp_todo.md)).

|    Prop    | HP |      Tags      |                                                                Notes                                                               |
|------------|----|----------------|------------------------------------------------------------------------------------------------------------------------------------|
| Wall       | 2  | brittle        | shatters into debris; explicit crumble effects damage it (§4.11)                                                                                             |
| Tree       | 2  | flammable      | burns (§4.11)                                                                                                                      |
| Rock       | 3  | heavy          | cannot be moved; survives one ordinary 2-damage Surge hit at 1 HP; damage exemptions follow the [execution profiles](gdd_monsters.md#43-skill-execution-profiles) |
| Pillar     | —  | indestructible | anchor (rare), nothing removes it                                                                                                  |
| **Shrine** | 2  | solid, effect  | monsters orthogonally adjacent to it get `quicken 1` (initiative +1) — creation requires an authored prop source |
| **Sigil**  | 1  | field, effect  | the monster standing on it gets `extend 1` (Reach +1) — creation requires an authored prop source; destroyed by any Surge or Strike on it |

### 4.11 Prop Reactions

**Interim reactions — status: [§4.9](#49-props).**

- Props are not "just in the way": tags react to **explicit effects of the concrete skill**, never monster themes or blanket aspect categories; a zone must explicitly define the relevant effect to trigger a reaction.
- Reactions are data (`prop_def.reactions`, matched to skill effects), shown in the cast preview.

| Tag | Explicit effect / interaction | Reaction |
|-----|-------------------------------|----------|
| **flammable** (Tree) | ignite | ignites; burns down at the next round end → Lava I |
| **flammable** (Tree) | extinguish | extinguishes a burning Tree |
| **brittle** (Wall) | crumble over time | −1 HP per round while the effect is present |
| **brittle** (Wall) | additional on-hit prop damage | applies the authored extra prop damage on hit |
| **heavy** (Rock) | displacement | cannot be moved; damage exemptions follow the [execution profiles](gdd_monsters.md#43-skill-execution-profiles) |
| **indestructible** (Pillar) | any | no reaction; cannot be removed |

- The table resolves reactions, not source eligibility. Concrete skill bindings, reaction replacement of ordinary prop damage and profile-specific extra damage values belong only to [Monsters §4.3](gdd_monsters.md#43-skill-execution-profiles).
- The existing immediate Lava-placement source ignites flammable props; Blight causes ongoing crumble on brittle props. These bindings grant no such effects to other sources, ground or height changes.
- Zones on prop squares wait; once the prop is gone, the zone works normally there.

**Interim shatter bank shots:** shatter a prop beside the enemy with a Surge; debris hits the adjacent square even if the enemy dodged the footprint. **A Wall raised beside you hurts you if a Surge breaks it.**

---

## 5. Skill Integration

### 5.1 Monster Skills: Central Specification

**Monster-skill definitions and skill-specific execution rules live only in [gdd_monsters chapter 4](gdd_monsters.md#4-skills).**

Battle resolves finished skills against the turn/event system (§2), board state (§4) and generic damage, displacement and collision (§6); no second skill schema, profile catalogue, point budget or AP price list.

| Topic | Central source |
|-------|----------------|
| Kit, access and species/Signature restrictions | [§4.1](gdd_monsters.md#41-the-kit) |
| Data fields, footprint/placement, interaction flags and sight | [§4.2](gdd_monsters.md#42-data-oriented-skill-construction-kit) |
| Strike, Surge, movement presets and execution constraints | [§4.3](gdd_monsters.md#43-skill-execution-profiles) |
| Effects and explicit ground/height/prop operations | [§4.4](gdd_monsters.md#44-effect-and-board-operation-contracts) |
| Construction points, AP efficiency and budget ceilings | [§4.5](gdd_monsters.md#45-construction-points-and-ap-efficiency) |
| Slot levels 1–3, development, upgrades and replacement | [§4.6](gdd_monsters.md#46-slot-levels-development-replacement-and-upgrades) |
| Shared reference records and validation | [§4.7](gdd_monsters.md#47-complete-references-and-validation) |

Missing rules remain in [temp_todo.md](temp_todo.md), not implicit runtime defaults.

### 5.2 Tamer Skills and Battle Loadout

Battle resolves explicit effects from the human tamer's prepared loadout under general event/board rules, deterministically and with previews. Wild monsters retain monster skills, but have no tamer skills or human loadout.

**Authoritative Overworld sources** (no monster-skill AP prices or permissions transfer):
- [§6.4 Tamer Skills](gdd_overworld.md#64-tamer-skills): definitions, slots, access and usage.
- [§2.1 Battle Loop](gdd_overworld.md#21-battle-loop) and [§7.9 Inventory and Loadout](gdd_overworld.md#79-inventory-and-loadout): preparation, visibility and loadout logistics.
- Planned medicines and arrays: [§6.6](gdd_overworld.md#66-pills--medicines) and [§6.8](gdd_overworld.md#68-arrays-artifacts-for-places).

**Unresolved integration contract:** activation windows, source-specific resolution and remaining loadout details are tracked in [temp_todo.md](temp_todo.md), T18–T20; this section supplies no default timing or cost.

---

## 6. Damage & Displacement

### 6.1 The Damage Law

> **The Surge is the burst.** It is the only skill that deals more than 2 damage to monsters; prop damage has source-specific exceptions in the [central damage contracts](gdd_monsters.md#44-effect-and-board-operation-contracts).
> - **Strike:** max 2 against monsters; body-relative execution and authored AP follow the [central Strike profile](gdd_monsters.md#strike)
> - **Hazard ground:** its level (max 2) at its trigger; Voidscar: 1. Ground effects: [§4.7](#47-ground--neutral-hazard-and-blessed); generic schedule: [§2.4](#24-effect-timing-reference)
> - **Collision** (pushed into a prop or monster), **fall** (pushed off Elevated) and **debris** (prop shattered next to you): 1 each
> - **Zones never deal damage.** Nothing else deals damage the instant it is cast

**Unresolved collision contract (T04):** the monster-collision wording above conflicts with [§6.3](#63-collision-fall--debris). Neither wording resolves that conflict or authorizes bonus collision damage.

### 6.2 Surge Resolution Integration

- Charge/detonation/autonomy and profile rules: [gdd_monsters §4.3](gdd_monsters.md#43-skill-execution-profiles); no second lifecycle here.
- The turn scheduler (§2.1–§2.4) dispatches due Surges; board state/reactions (§4) and generic damage/displacement (§6) resolve their declared effects.

**Unresolved runtime (T04):** combined-effect order, displacement ties and exceptional Surge queue timing remain open ([temp_todo.md](temp_todo.md)). Do not infer order from data-list position or redefine confirmed autonomy.

### 6.3 Collision, Fall & Debris

- Pushed or pulled into a **prop**: no move, 1 damage to the monster and 1 to the prop (heavy props take none)
- Into a **monster**: no move, no damage · off the **board edge**: no move, no damage. The monster-collision damage wording in §6.1 conflicts with this detailed rule and remains central T04; it is not a new collision-bonus permission
- **Off Elevated**: the move happens, 1 fall damage · onto Elevated from below: blocked like a prop, no damage
- **Prop shattered**: resolve debris and collapse under the **interim** [§4.10](#410-damage-shatter--prop-types) rules; destruction-specific replacements remain T04

### 6.4 General Rules

- No defense stat — damage reduction via zone-based Surge reduction, ground-based Surge reduction (§4.7) and authored passives
- All damage exact and previewed
- Surge autonomy follows the [central Surge profile](gdd_monsters.md#surge); its caster's death does not cancel it, while exact dead-caster scheduling remains T04
- Generic trigger scheduling and turn order have one reference: [§2.4](#24-effect-timing-reference); source-specific execution remains in the resolved definition

### 6.5 Displacement

- **Generic displacement:** cardinal, one square per trigger, with previewed landing. Push uses the direction chosen at cast (or with the Strike); pull uses the board anchor fixed at cast. Blocked moves: [§6.3](#63-collision-fall--debris); entry/end-event integration: [§2.4](#24-effect-timing-reference).
- Zone effects: [§4.6](#46-zones-effects-rules--opposites). Authorized direct displacement, on-hit push/pull and delayed footprint-bound displacement get recipients, bindings and triggers from the [central displacement contracts](gdd_monsters.md#44-effect-and-board-operation-contracts), not a second profile catalogue here. Ties and combined-effect order remain unresolved ([temp_todo.md](temp_todo.md), T04).

**Why end of turn:** at turn start the target could simply walk away again; at turn end it lands in Lava, through Thornbed, in front of your Strike or in a Surge detonating before it can move again. Visible counterplay: don't end your turn on a current.

---

## 7. Technical & Prototype

### 7.1 Technical Notes (Battle)

**Current design requirements (not an implementation-completeness claim):**

- Godot 4 · **3D square grid, orthogonal camera ~45°** — never hex. Art pipeline: low-poly Blender + AI textures
- Skill authoring follows the [shared data model](gdd_monsters.md#42-data-oriented-skill-construction-kit), [effect contracts](gdd_monsters.md#44-effect-and-board-operation-contracts) and [references/validation](gdd_monsters.md#47-complete-references-and-validation), not the historical Resource layout below
- Battle logic should remain headless and engine-independent; runtime state: [§4.4](#44-square-data-model). Queue, board interactions and damage follow their owning sections here
- Preview, AI and resolution must share deterministic rules and expose board reactions, authored aftermath and displacement landings; generic timing in [§2.4](#24-effect-timing-reference) does not imply complete event ordering
- Effect comparisons, explicit prop reactions, scoped interaction fields and authored footprints/anchors resolve from their definitions. Movement blocking uses the resolved [movement profile](gdd_monsters.md#movement), not a blanket marker rule

**Unresolved implementation contracts:** T02/T04/T07/T09 in [temp_todo.md](temp_todo.md); prototypes do not settle these current design gaps.

**Historical v6.0 implementation notes — not the current authoring schema or complete current runtime:**

- One Resource per monster / skill / zone in `data/monsters`, `data/skills`, `data/zones`, typed by `MonsterDef`, `SkillDef`, `ZoneDef`.
  - `GameData` indexes by `id` (= file name); startup validation checks duplicate ids, missing Surge/utility, unknown shapes/passives, species learn-list references, concrete Surge types/effects and stat ranges.
  - The legacy Surge/utility requirement does not override the [open kit rules](gdd_monsters.md#41-the-kit)
- The headless board uses a 2D array of Square objects storing `{ ground{type, level, height}, object, surge, zone }`, with level-derived zone effect values. These fields are not an alternative current schema
- Documented preview architecture: pure `preview_cell(skill, cell)` returns `new | level | replace | weaken | cancel | lost`, shared by preview, AI and unit tests. This does not establish implementation of revised contracts or optional residue
- Shape orientations use base shapes (rotate + mirror, de-duplicated), anchor nearest the centroid. Current design instead requires explicit [footprint/anchor mappings](gdd_monsters.md#footprints-and-placement); missing mappings remain T02

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
