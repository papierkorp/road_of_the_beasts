# GDD — BATTLE SYSTEM
*Working Draft v6.3 — Options, not luck · companion files: gdd_monsters.md, gdd_overworld.md · playable reference: Godot project `godot/` (implements **v6.0**: 3v3 on 7×7, 1v1 duel, draft, 9 monsters; the v6.1 to v6.3 changes in §9 are design ahead of the code) · `html_prototype/battle-prototype-v5-zones-ground.html` is the older v5 reference · see §9 for what changed*

---

## 1. Overview

Turn-based, isometric monster battles about **grid control**, fully deterministic and readable. Inspired by *Into the Breach*.

Monsters, skills and their progression: see **gdd_monsters.md**. Setting, economy, overworld: see **gdd_overworld.md**.

### 1.1 Battle Modes

|   Mode  |  Board  |                                             Role                                            |
|---------|---------|---------------------------------------------------------------------------------------------|
| 1v1     | 5×5     | duel / tutorial, early game                                                                 |
| 2v2     | 6×6     | step between duel and team battle                                                           |
| **3v3** | **7×7** | **standard battle** — enough monsters for combos between allies, short enough for a session |
| 5v5     | 9×9     | special battles only (bosses, tournaments), later                                           |

Modes follow the team size the player can field: 1v1 from the start, **3v3 and 2v2 from Foundation**, 5v5 special battles from Core Formation (gdd_overworld §6.3). The encounter chooses the mode.

**Why 7×7 for 3v3:** 6 monsters on 49 squares is about as crowded as 2 on 25 (1v1), so the pressure stays similar. 8×8 gives each monster more room to step out of a 3–4 cell Surge — exactly the "too easy to dodge" problem. An odd size also has a **centre square** for contested high ground and mirror-fair starts. Small kits (gdd_monsters §4.1) keep 3v3–5v5 readable: every monster brings 4 skill slots, not a skill bar.

### 1.2 Battle Design Pillars

1. **Control squares, not just units** — shaped skills claim board squares; body-relative attacks and unit-targeted effects retain their own placement rules. The board is the weapon
2. **Deterministic & readable** — before confirming, the player sees exactly which squares a cast takes, levels up, cancels, replaces or loses, what it does to ground and props, and where every pushed monster lands
3. **Everything reacts, nothing deletes** — no delete button. Zones with **opposite effects** cancel, the same zone levels up, anything else replaces. Concrete skill effects change ground and trigger prop reactions. The former triangle-based zone × ground interaction is not yet defined (temp_todo.md, T07). These are small, data-driven rules
4. **The Surge is the burst** — big damage (3+) only comes from a declared, charging, autonomous Surge. Small damage comes from Strikes (max 2), hazard ground (max 2 per trigger), collisions, falls and debris (1). Zones never deal damage themselves
5. **Every threat has a real answer** — leave, put a Veil over it, change the ground under it, pick the right height for that Surge type, block with props, answer with your own Surge
6. **Options, not luck** — fully deterministic and fully visible. Variety comes from many meaningful choices per turn (where to stand, which threat to create, which reaction to trigger), never from dice or hidden information
7. **Low HP, high stakes** — one mistake can be fatal
8. **Dynamic battlefields** — ground and props are resources; squares remember explicit board changes; Surges rewrite them only when their definition includes such effects
9. **One skill source** — monster-skill authoring and access are centralized in gdd_monsters chapter 4; §5 here collects the references and runtime rules. No fixed aspect or replacement element categories

---

## 2. Battle Flow

### 2.1 Core Battle Loop

1. Battlefield generated (ground, props, contested high ground — §4.1)
2. Pre-battle: draft monsters, place them in your start area, apply pills / arrays, choose the battle loadout (§5.8). Monsters start at their **current HP** (never above max; below max after earlier fights of an expedition, gdd_overworld §6.6).
3. **Each round:** one queue for all monsters of both sides, highest effective initiative first (§2.2)
4. **On a monster's turn:**
   1. its own Surges that are due **fire** (§5.4): damage, then explicitly authored residue if present
   2. start-of-turn ground effects on its square (Voidscar, Blight)
   3. spend its **AP** (the AP stat, 2–5: Step or movement skill / Strike / cast a zone, ground, prop or direct skill / declare a Surge) — actions may repeat, no cooldowns (§2.3)
   4. end of turn: zone displacement (push / pull, §6.5), then end-of-turn ground on the square it now stands on (Lava), then `mend`. *Thornbed and Mossbed fire whenever a monster enters them, including by push / pull*
5. Round ends → zones tick down (expired zones are removed), burning props burn down, late-game Voidscar spreads, initiative recalculated
6. Battle ends when one side has no monsters left

### 2.2 Initiative Rules

- **One queue for all monsters of both sides**, strictly by effective initiative, **recalculated every round**
- A side may act several times in a row — that is the reward for initiative, not a bug
- **Ties:** higher base initiative first; still tied → the sides alternate (the first tie of a battle goes to the side with the lower total initiative)
- An initiative-draining zone can flip the order, giving a monster two turns back to back across the round boundary — a real tempo weapon
- Multi-turn monsters get one extra queue entry per extra turn, each at −3 initiative (min 0.1)
- **Surge clock:** a Surge fires **at the start of its caster's next turn** (§5.4). In a simple alternating 1v1 this follows the opponent's turn; initiative changes and extra turns mean not every other monster is guaranteed a turn in between. Exact queue timing for these cases remains central T04

### 2.3 Action Points

**AP per turn = the monster's AP stat** (2–5, gdd_monsters §2.1). Spend the resolved action's authored AP cost; the central baseline prices and exceptions are in **[gdd_monsters §4.2](gdd_monsters.md#42-data-oriented-skill-construction-kit)**, with Strike shape prices in gdd_monsters §3.2. Slot development and optional higher-cost variants follow gdd_monsters §4.7 (reference map: §5). Species exclusivity is not a separate price class or permission to override cost. Tamer/loadout costs use their own source (§5.8).

**Every action costs at least 1 AP.** There are no 0-AP actions.

**No cooldowns.** Any action may be used again in the same turn as long as AP last (for example, recasting a zone to level it up before changing ground). The limiters are AP, the board, and one hard rule: **one charging Surge per monster**. A turn becomes a real choice between *repositioning*, *setting up* and *attacking*, instead of "whatever is off cooldown".

**Why moving and a basic Strike both cost 2 AP:** a Strike can't be combined with moving, not even at AP 3, so the target must already stand inside your Strike shape at the start of your turn — usually because a pull or the enemy's own position put it there. Hitting is a reward for board control, not something you can always do. At AP 2 a monster moves **or** acts: leaving a Surge costs the whole turn, so a Surge is much harder to shrug off. AP 3 is what buys Move + one 1-AP action in the same turn.

### 2.4 Effect Timing Reference

|    Trigger    |                          When                         |                                                         Examples                                                        |
|---------------|-------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------|
| on_timer      | start of the caster's next turn, before anything else | Surge detonation                                                                                                        |
| start_of_turn | beginning of the occupant's turn                      | Voidscar, Blight                                                                                                        |
| on_enter      | a monster enters the square (move, push, pull)        | Thornbed, Mossbed                                                                                                       |
| while_inside  | continuous modifier                                   | slow, haste, drain_init, quicken, drain_range, extend, shield; Shrine / Sigil; Hearth, Umbra                            |
| end_of_turn   | end of the occupant's turn                            | 1. push / pull → 2. Lava (on the landing square) → 3. `mend`                                                            |
| round end     | after the last turn of the round                      | zones −1 round (expired zones are removed), burning props burn down, Voidscar spreads, initiative re-sorted                  |

Order inside a turn: due Surges (damage → explicitly authored residue, if present) → start effects → AP → end effects (displacement, then Lava, then `mend`).

---

## 3. Monsters in Battle

The battle only sees a finished unit sheet. Everything that defines a monster (sheet, stats, Kins, Strikes, kits, passives, roster, evolution) is in **gdd_monsters.md** and is not repeated here.

### 3.1 Effective Stats

**Effective stats** = base + modifiers from the zone on the square the monster currently stands on (+ Elevated bonus). Only one zone per square, so modifiers never stack in a pile — a square tells you exactly what it does.

|     Stat    |                     Changed in battle by                     |
|-------------|--------------------------------------------------------------|
| Initiative  | `drain_init` / `quicken` (§4.6), Shrine (§4.10), Hearth (§4.7) |
| Movement    | `slow` / `haste` (§4.6); Step is always 1 square             |
| Reach       | +1 on Elevated, `drain_range` / `extend` (§4.6), Sigil (§4.10), Umbra (§4.7); min 1 |

### 3.2 Monster Identity & Skill Access

Monsters have **free themes**, not fixed aspects or replacement element categories. Identity comes from species, Kin, stats, skills and passives; themes do not impose a matchup triangle or combat modifiers.

Skill access and authored definitions follow the central references in §5. At runtime, ground types, zone effect tags, prop reactions and Surge behaviour come from the resolved concrete definition, never from a monster's theme.

There is no attunement system (§4.8). Zone × zone resolution compares effects (§4.6); the former triangle-based zone × ground interaction is **not yet defined** (see [temp_todo.md](temp_todo.md), T07).

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

On 7×7 the sides start 5–6 rows apart: no Strike and no Surge reaches the enemy line in round 1, so acting first gives position, not a free hit.

### 4.2 Late-Round Pressure (Anti-Stalling)

From a set round on, the square farthest from all living monsters converts to **Voidscar** each round (permanent, undestroyable). The start round scales with the board (tunable: 1v1 round 6, 3v3 round 8). **Collapse:** once no free square is left to convert, every living monster takes 1 damage per round — so every battle ends.

### 4.3 The Square Stack: Zones & Ground

```
[ AIR    ]  flying prop | flying monster | empty — immune to ground Surges
[ OBJECT ]  prop with tags (Tree: flammable · Wall: brittle · Rock: heavy · Pillar: indestructible) | empty
[ SURGE  ]  pending Surge marker | empty — shares shapes/placement with zones, never merges with them
[ ZONE   ]  ONE timed zone (the skill's `duration`) | empty — control and support
[ GROUND ]  type (neutral: Plain | Rubble | Water | Voidscar | Hallowed — hazard: Lava | Thornbed | Blight, lvl I–II — blessed: Hearth | Mossbed | Umbra), always permanent
            + height (Low | Elevated)
```

**Rules:**
- all layers can be active at once · **1 object, 1 pending Surge, 1 zone, 1 ground type** per square
- zones may be placed on prop squares — the zone affects the prop only through the reaction table (§4.11); a monster can't stand there anyway
- skills with `blocked_by_objects` (Field, Raise Ground) need prop-free squares, except for the prop reactions in §4.11 (Lava Field on a Tree ignites it instead of laying Lava)
- a pending Surge blocks *voluntary* movement like a temporary object and may land on props; displacement (push / pull, also the push of a Flood Surge) **can** move monsters into it — that is the combo
- **zones = what you do to a square for a while; ground = what the board remembers**

### 4.4 Square Data Model

Illustrative **runtime board state only**, not a skill-authoring schema. Definition references resolve through the single monster-skill schema (gdd_monsters §4.5; reference map §5); runtime entries store ownership, cast bindings, levels and remaining lifetime.

```json
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

Effect definitions supply the base and cap; this state does not redeclare them. **Effective value** = `min(cap, base + level − 1)`, min 1 (slow capped at 2; push/pull always 1). Values are computed live from the zone's level; there is no aspect modifier.

### 4.5 Lifecycles

|         Thing        |                                                   Clock                                                  |                                                Notes                                                |
|----------------------|----------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------|
| **Zone**             | the resolved skill's duration (authoring/default and upgrades: gdd_monsters §4.2/§4.7), ticks at round end | on expiry the zone is removed; no repaint |
| **Pending Surge**    | fires at the start of its caster's next turn (§5.4)                                                      | then removed; damage, then optional, explicitly authored **residue**                                        |
| **Ground**           | none — stays until changed | changed by Raise Ground, a new ground, Surge residue, shattered props, debris, Voidscar; former triangle-based zone interaction unresolved (§4.6, T07) |

**Principle:** *only zones run on a clock, ground is the board's memory.* A Voidscar doesn't fade and neither does Lava; ground goes away because something changes it. One clock per zone — effects never carry their own timers (the clock's length is a property of the skill, not of its effects).

### 4.6 Zones: Effects, Rules & Opposites

**Runtime zone effects** — resolve the referenced definitions using these tags; authoring legality is centralized in gdd_monsters §4.2–§4.3. Every effect but `mend` has an **opposite**; zones are compared by effects, never by name. Some effects hinder, some help: `haste`, `quicken`, `extend`, `shield` and `mend` are what support zones are made of.

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

Effects hit **everyone** on the square — allies, enemies and the caster. An enemy can stand in your healing zone too, so where you put it matters. `expose` has no zone yet; it exists so the table is complete.

**When a zone lands on a square that already holds one:**

|                                Existing zone                                |                                        Result                                        |
|-----------------------------------------------------------------------------|--------------------------------------------------------------------------------------|
| none                                                                        | **new**                                                                              |
| **same zone** (same definition)                                             | **levels up** (max III) and refreshes to its full `duration`; the patch id becomes the new cast |
| **opposite** — any effect of one is the opposite of any effect of the other | **levels subtract:** equal levels cancel and the square is empty; otherwise the higher zone stays with the difference, its clock unchanged |
| anything else                                                               | **replaced** (level I)                                                               |

Resolution examples by effect, not retired skill names: equal-level `(slow, pull)` versus `(push)` → cancel; `(quicken, haste)` versus `(drain_init, slow)` → cancel; level I `(push)` versus level III `(slow, pull)` → the latter stays at level II; different definitions without opposite effects → replaced. There is no merging, so a square always shows exactly one zone with its real effects.

**Zone × ground — unresolved interaction.** The aspect triangle and its clearing / strengthening rules are removed. How zones interact with ground in place of that former rule is **not yet defined**; see [temp_todo.md](temp_todo.md), T07. No blanket replacement rule is implied here. Concrete ground-changing skill effects remain as specified (§4.7).

### 4.7 Ground — neutral, hazard and blessed

| Group | Ground | Effect |
|-------|--------|--------|
| Neutral | **Plain** | move cost 1 |
| Neutral | **Rubble** | move cost 2; left by shattered props and collapsed Elevated |
| Neutral | **Water** *(planned)* | move cost 2, Swim crosses it at cost 1 (§5.5); Step works as always |
| Neutral | **Voidscar** | 1 damage at the **start** of your turn; permanent, spreads late-game (§4.2), nothing changes it |
| Hazard | **Lava** I–II | damage = level at the **end** of your turn — *punishes staying* |
| Hazard | **Thornbed** I–II | damage = level when you **enter** the square (move, push or pull) — *punishes moving* |
| Hazard | **Blight** I–II | damage = level at the **start** of your turn — *punishes being there when your turn begins* |
| Blessed | **Hearth** | initiative +1 while you stand on it (`quicken 1`) |
| Blessed | **Mossbed** | heals 1 when you **enter** the square (move, push or pull), never above max HP — *rewards moving* |
| Blessed | **Umbra** | Reach +1 while you stand on it (`extend 1`) |
| Blessed | **Hallowed** | Surge damage on this square −1; replaced only if actual residue is laid there under the applicable ground rules. No automatic consumption on a Surge hit; without replacement it remains |
| Height | **Elevated** | combines with any type. Effect on Surges depends on the type: the Flood Surge can't reach it, the Rift Surge collapses it, the Eruption Surge hits but lays no residue (§5.4). +1 Reach for the unit there; **climbing up costs 2 movement**; **pushed off Elevated → 1 fall damage**; collapses to Rubble from debris; can be raised under a charging Surge |

**How ground is made:**

- **Field effects** lay their specified level I hazard ground, also on Elevated
- **Surge residue**, when explicitly included as a separately budgeted `board_changes` effect, lays the concrete skill's specified ground at level I (§5.4); Surge execution alone lays no ground
- **Blessing skills** lay blessed ground. It has no levels and is permanent; casting still spends the central authored AP price (§2.3)
- All ground is **permanent**: it stays until something changes it (§4.5)
- **Same type** on the square → hazards +1 level (max II), blessed ground stays as it is
- **Different type** → the new ground **replaces** the old one (a Flood on Lava leaves Thornbed — the Lava is gone)
- **Raise Ground** cleanses any ground except Voidscar → Plain, also Lava already on the square
- Placing ground beneath an occupant is not entry; entry triggers occur when the occupant enters the square. Mossbed re-entry/healing limits remain central T07
- Blessed ground works for **everyone** on it, like a zone: an enemy can use your Mossbed too
- Damage from ground is capped at 2 per trigger; one ground per square, so hazards never stack

### 4.8 No Attunement

Attunement is removed entirely: no square field, repaint events, strength modifiers or attunement display. Ground types and height remain concrete board state; zone expiry only removes the zone, and Surge aftermath applies residue only when explicitly authored as a `board_changes` effect. This section number is retained as a reference note.

### 4.9 Props

```
SOLID   → cannot enter (Wall, Rock, Tree, Pillar, Shrine)
FIELD   → enterable, applies an effect to the monster on it (Sigil)
FLYING  → air layer only (later, with the air layer at Soul+)
```

### 4.10 Damage, Shatter & Prop Types

A Surge square that contains a prop deals **2 damage to the prop and does not hit a monster there** (solid props can't be occupied). Props also take damage from Strikes (§5.2), collisions (1, §6.5) and reactions (§4.11). If a prop's HP reaches 0 it **shatters**: Rubble replaces the ground (neutral), and **1 debris damage lands on the four neighbouring squares** (also collapsing Elevated neighbours to Rubble).

|    Prop    | HP |      Tags      |                                                                Notes                                                               |
|------------|----|----------------|------------------------------------------------------------------------------------------------------------------------------------|
| Wall       | 2  | brittle        | shatters into debris; explicit crumble effects damage it (§4.11)                                                                                             |
| Tree       | 2  | flammable      | burns (§4.11)                                                                                                                      |
| Rock       | 3  | heavy          | can't be moved (Relocate, Flood Surge); survives one Surge at 1 HP                                                                       |
| Pillar     | —  | indestructible | anchor (rare), nothing removes it                                                                                                  |
| **Shrine** | 2  | solid, effect  | monsters orthogonally adjacent to it get `quicken 1` (initiative +1) — creation requires an authored prop source |
| **Sigil**  | 1  | field, effect  | the monster standing on it gets `extend 1` (Reach +1) — creation requires an authored prop source; destroyed by any Surge or Strike on it |

### 4.11 Prop Reactions

Props stop being "just in the way": tags react to **explicit effects of the concrete skill**, never to a monster theme or a blanket aspect category. Reactions are data (`prop_def.reactions`, matched to skill effects) and are shown in the cast preview. A zone only triggers a reaction if its definition explicitly supplies the relevant effect.

| Tag | Explicit skill effect / source | Reaction |
|-----|-------------------------------|----------|
| **flammable** (Tree) | ignite (Lava Field, Eruption) | ignites; Eruption ignites instead of dealing prop damage; burns down at the next round end → Lava I |
| **flammable** (Tree) | extinguish (Flood, or a zone explicitly carrying this effect) | extinguishes a burning Tree |
| **flammable** (Tree) | legacy prop-reinforcement proposal | +1 HP was proposed, not an approved generic shield effect; requires a validated source (T02/T04/T10) |
| **brittle** (Wall) | crumble over time (Blight or a zone explicitly carrying this effect) | −1 HP per round while the effect is present |
| **brittle** (Wall) | Rift's crumble on hit | −1 extra HP when hit |
| **heavy** (Rock) | Flood's displacement / prop interaction | cannot be moved; Flood deals it no damage |
| **indestructible** (Pillar) | any | no reaction; cannot be removed |

Zones on a prop square wait there: once the prop is gone, the zone works normally on that square.

**Bank shots:** aim a Surge so that a prop next to the enemy shatters — the debris hits the square beside it even if the enemy dodged out of the footprint. **A Wall you raise beside yourself will hurt you if a Surge breaks it.**

---

## 5. Skills

**Boundary and central reference map.** This chapter owns generic skill execution in battle, not another construction catalogue, kit list, price list or schema. **[gdd_monsters chapter 4](gdd_monsters.md#4-skills)** is the authoritative monster-skill specification:

- **§4.1:** kit, slot-free Step and access constraints.
- **§4.2:** construction dimensions, spatial/temporal/effect contracts, base AP prices and combination costing.
- **§4.3:** complete-definition validation; missing rules block affected content.
- **§4.4:** Surge constraints and species-twist ownership.
- **§4.5:** the single skill schema and authorized definition patches.
- **§4.6:** species-exclusive and Signature access; exclusivity is not a mechanical kind.
- **§4.7:** permanent slot development, upgrades, replacement/relearning pills and AP policy.

Battle resolves the finished definition: AP spending (§2.3), events (§2.4), board state/effects (§4), targeting/traversal (§5) and damage/displacement (§6). Unresolved contracts stay in [temp_todo.md](temp_todo.md), especially T02/T04/T05/T07/T09/T10/T32; no default or new permission is implied by a data field.

### 5.1 Runtime Profiles

|   Kind   |      Writes to      |                                         In battle                                          |
|----------|---------------------|--------------------------------------------------------------------------------------------|
| `strike` | squares around the body | small direct damage in a shape around the monster (§5.2)                               |
| `surge`  | Surge layer; ground only via explicit `board_changes` | telegraphed delayed execution (§5.4), including the existing burst profiles; optional, separately budgeted residue; only one charges per monster at a time |
| `zone`   | zone layer          | timed control or support on squares (§4.6), lasts for the skill's `duration`               |
| `ground` | ground layer        | hazard ground or Elevated (§4.7)                                                           |
| `prop`   | object layer        | places or moves props (§4.9)                                                               |
| `direct` | a unit              | one-time displacement (§6.5)                                                               |
| `move`   | the caster          | moves the caster (§5.5)                                                                    |

These are runtime dispatch responsibilities, not a closed construction menu. Species-specific effects use their validated mechanical profile; the retired `unique` label grants no effect, targeting or price exception (§5 reference map).

### 5.2 Strike

A Strike hits a **shape around the monster's own body**: no anchor and no range, the shape starts on the squares next to the monster. It doesn't use Reach. Max 2 damage, lands instantly. Spend the selected shape's authored price (gdd_monsters §3.2, central costing §4.2); a larger shape does not trade damage for area. The existing Swarm exception deals 4 to props, not monsters.

- There is **no facing**: the player picks the direction when striking
- It hits **every monster and prop in the shape**, allies included, never the striker itself
- A solid prop takes the hit and blocks the squares behind it
- The player picks one of 8 directions. Which shapes exist and what the Kin adds: gdd_monsters §3.2

### 5.3 Shapes (tetris)

Every Surge, zone, ground and prop skill controls **several squares in a fixed shape family** (Step and unit-targeted effects need no tetris footprint; Strikes have their own body shapes, §5.2):

|  Family | Cells | Orientations (incl. mirror) |
|---------|-------|-----------------------------|
| I2      |     2 |                           2 |
| I3      |     3 |                           2 |
| L3      |     3 |                           4 |
| O4      |     4 |                           1 |
| T4      |     4 |                           4 |
| S4 / Z4 |     4 |                           4 |
| L4 / J4 |     4 |                           8 |

**Fixed shapes:** every skill has exactly **one shape family and one fixed orientation**, absolute on the board for both teams as resolved by the authored definition. Outside-battle changes follow gdd_monsters §4.7 — in battle you only pick *where* to place it, plus an explicitly required push direction. Only the passive **Adaptive** may rotate shapes in battle (`R` / right-click). Place by the **anchor** — the shape's centre-most cell — which must be within the caster's **Reach** (Manhattan, effective value, §3.1). All cells must be on the board; ground skills need prop-free squares; props need empty squares; zones and Surges may land on props. Directional effects (zone push, Flood Surges) also take a direction, pull skills an anchor. The cast preview colours each square (**new / levels up / replaces / weakens / cancels / blocked**) and lists concrete ground and prop reactions, landing squares of displaced monsters and, for Surges, damage after ground and Veils.

Authored footprints supply explicit offsets and anchor mappings (gdd_monsters §4.2); runtime does not pick an ambiguous anchor, mirror by team, clip, shift or rotate a footprint to make it fit. Placed board cells, push direction and pull anchor remain fixed at cast, not tracking a selected unit. Missing mappings remain T02; 2×2 origins, overlap/hit multiplicity and layer occupancy remain T04/T09. Placement legality and LOS are separate checks (§5.7).

### 5.4 The Surge

A **Surge is telegraphed delayed execution**, represented by a pending marker with a timer — same shapes and placement as zones, its own slot, different lifecycle. Surge alone does not imply residue: ground aftermath is an **optional, explicit, separately budgeted `board_changes` effect** under gdd_monsters chapter 4. For a damage profile with residue, **damage resolves before the authored ground aftermath**. This adds no timing or damage price; existing effect, AP and validation rules remain in gdd_monsters §4.2–§4.3.

```
MINOR SURGE
  shape/placement: resolved authored footprint and constraints (gdd_monsters §4.2/§4.4), checked under §5.3
  range: effective Reach to anchor unless an explicitly approved baseline profile says otherwise
  charging: visible, blocks movement through its squares
  fires: at the START of the caster's next turn (1v1: = end of the opponent's turn)
         if the caster died, it fires when the caster's slot in the queue would have come up
  autonomous: not cancelled by displacing / killing the caster
  per-square result:
    monster  → value − Veil shield −1 on Hallowed (minimum 0 damage)
               (hits every monster on its squares — allies and the caster included)
    prop     → 2 damage, shatters if destroyed (debris), plus the prop reaction (§4.11)
    Elevated → depends on the Surge type (table below)
  afterwards: only if explicitly authored, apply the separately budgeted RESIDUE
              board_changes effect (permanent ground, §4.7), subject to its profile's
              height rules below; otherwise no residue; no repaint
  usage: spend authored AP (gdd_monsters §4.2); ONE charging Surge per monster
  claims squares: can't be placed on squares already holding any charging Surge (the first one claims them)

MAJOR SURGE
  shape/range: requires an explicitly authored large-area profile, not a generic size/range override
  usage: once per battle; authored AP and access: gdd_monsters §4.2/§4.6
  open: legacy up-to-half-board/long-range wording needs a concrete definition (T02);
        Ancient vs Legendary Signature access remains T02/T32, not permission for either by inference
```

**Surge types on concrete skills.** Existing concrete Surge skills explicitly specify **Eruption**, **Flood** or **Rift**, independently of the monster's theme. Their authored residue effects remain part of those profiles; optional residue in the general construction model does not remove them. Surge timing alone neither requires one of these profiles nor authorizes a new effect combination; definitions still require validation under gdd_monsters chapter 4. These are mechanical Surge profiles, not monster aspects or replacement elements. "Flood" denotes a Surge type, never a zone, and need not look like water. The existing profiles retain the following concrete damage, residue, prop and height effects:

|     Type     | Damage |     Residue (permanent, level I)      |                                                                     Props                                                                     |                            Elevated                           |
|--------------|--------|---------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------|
| **Eruption** |      3 | **Lava I** — burns at end of turn     | Trees ignite                                                                                                                                  | hit normally, **no residue** there (lava runs off)            |
| **Flood**    |      2 | **Thornbed I** — hurts when entered   | pushes struck monsters 1 square in the direction set at cast (into the thorns it just laid); extinguishes burning Trees; heavy props block it | **can't reach it** (square blanked)                           |
| **Rift**     |      3 | **Blight I** — hurts at start of turn | brittle props crumble                                                                                                                         | **collapses** to Rubble, the monster on it still takes damage |

So Elevated is a real decision: high ground is safe against a Flood, normal against an Eruption, and a trap against a Rift.

**Runtime counter menu** (authoring validation of live counters: gdd_monsters §4.2–§4.3):

|            Counter             |                                                         How                                                          |
|--------------------------------|----------------------------------------------------------------------------------------------------------------------|
| **Leave**                      | move out of its squares before it fires — but mind any explicitly authored residue                                             |
| **Veil it**                    | a Veil over its squares: shield 2 (up to 3 with level) cuts damage 1:1 per square; recast to level up |
| **Pick the height**            | Raise Ground: blanks a Flood, no residue from an Eruption — useless against a Rift                                   |
| **Stand on Hallowed**          | Surge damage −1 on that square; Hallowed remains unless actual ground replacement occurs (§4.7)                                                                          |
| **Fly over it**                | Surges don't have `affects_air`: the air layer is out of reach (Winged, Soul+)                                       |
| **Props / debris**             | use props to soak squares — but remember the shatter hits next to them                                               |
| **Answer with your own Surge** | race it — but you can't claim squares already held by a charging Surge                                               |
| **Control the tempo**          | slow / pull / push zones to steer where the target can stand; drain the caster's initiative to delay its next turn      |

### 5.5 Movement

Resolve **Step** as the universal one-square action; slotted movement uses the presets below. Kit/access and prices are referenced in §5; Kin preset access remains gdd_monsters §3.3. Movement distance uses effective **Movement**, not Reach.

A movement skill is not a list of special cases but a **profile of flags**. The modes are authorized presets, not player-selectable permissions; a separately authored flag profile still requires access and complete validation (gdd_monsters §4.2–§4.3):

|          Flag          |                                     Meaning                                     |
|------------------------|---------------------------------------------------------------------------------|
| `path`                 | `walk` square by square · `line` straight line, only the landing square counts · `free` any path, only the landing square counts · `teleport` any free square in range |
| `blocked_by_objects`   | solid props block the path                                                      |
| `blocked_by_monsters`  | monsters block the path                                                         |
| `blocked_by_surges`    | charging Surges block the path                                                  |
| `blocked_by_height`    | can't start or end the move on Elevated                                         |
| `ground_costs`         | Rubble, Water and climbing cost 2 movement, Thornbed fires on every square entered (walk only) |
| `distance_mod`         | distance = Movement + this (min 1)                                              |

|       Preset       | path | objects | monsters | Surges | height | ground costs | distance_mod |
|--------------------|------|---------|----------|--------|--------|--------------|--------------|
| **Step**           | walk | yes     | yes      | yes    | no     | no (and ignores `slow`) | always 1 |
| **Run**            | walk | yes     | yes      | yes    | no     | yes          | 0            |
| **Leap**           | line | no      | no       | no     | no     | no           | 0            |
| **Glide**          | free | no      | no       | yes    | no     | no           | −1           |
| **Burrow**         | free | no      | no       | no     | yes    | no           | −1           |
| **Phase**          | walk | no      | yes      | yes    | no     | yes          | −1           |
| **Blink**          | teleport | no  | no       | no     | no     | no           | −2           |
| **Swim** *(planned)* | walk | yes   | yes      | yes    | no     | yes, Water costs 1 | 0      |

- **Price rule:** every restriction a preset drops is paid for in distance or in direction (Leap: straight line only). New modes follow it
- Apply only the resolved, authorized movement variant; upgrade allowances and AP consequences belong to gdd_monsters §4.7, not a second battle upgrade rule
- Min 1 square for every movement skill. Step ignores slow and extra ground costs, but still requires a legal unblocked destination
- Ignoring path blockers does not allow an occupied landing square. Walk processes entered cells; line/free/teleport count only landing, with destination effects still applying. Glide is not persistent flight; air and 2×2 traversal/landing remain T09, Water/Swim T08

### 5.6 Skill Flags

Runtime interprets the resolved interaction fields below under the owning profile. This is not a second schema or permission to combine arbitrary flags; the single definition model is gdd_monsters §4.5.

|         Field        |                                                       In battle                                                       |
|----------------------|-----------------------------------------------------------------------------------------------------------------------|
| `affects_ground`     | the skill changes the ground on its squares: residue or another explicit ground-changing effect; former triangle-based zone interaction unresolved (§4.6, T07)             |
| `affects_air`        | the skill also reaches the air layer. If not, units in the air ignore it. Ground itself never touches the air layer   |
| `blocked_by_objects` | apply profile-specific prop blocking (movement: path); occupancy/reactions remain §4.3/§5.3. This flag neither grants LOS nor defines a universal empty-square test                   |
| `blocked_by_height`  | it can't reach Elevated squares. If not, it works there too: a Field on Elevated lays its ground there like anywhere else |
| resolved persistence | zones keep one remaining-round clock (§4.5). Other timed/consumed effects use their explicitly authored lifetime; no generic `rounds` default |
| `blocked_by_monsters`, `blocked_by_surges`, `ground_costs`, `distance_mod`, `path` | movement skills only, the profile of §5.5                      |

The construction dimensions and effect contracts are in gdd_monsters §4.2; §4.5 documents the shared skill data model. Interaction flags are fields of the concrete skill, constrained by its rule profile, not a separate list of named skill blueprints.

### 5.7 Sight

Zone, ground, prop and Surge casts are placed by the **caster's Reach, from the caster to the anchor** — no line of sight. Sight is needed for Shove and species-specific effects on another monster; boosts on the caster never need it. Target eligibility, validity after movement/death and exact sight geometry require explicit contracts (T02/T04/T09); no implicit tracking, retargeting or generic side filter.

### 5.8 Tamer Skills & Battle Loadout

The tamer shapes; monsters fight. A human tamer (the player or an NPC) brings a limited number of **slotted** tamer skills into a battle; each can be used **once per battle**. Wild monsters have no tamer and no skills. The skill list, slots and sources: gdd_overworld §6.4.

Besides tamer skills a human tamer may bring **medicines** and **arrays** *(planned)*: they can change the field in battle and are partly used up. The loadout is fixed before the battle and known to both sides, so pillar 6 stays intact; every effect is deterministic and previewed. Enemy human tamers bring one as well; wild monsters never do.

---

## 6. Damage & Displacement

### 6.1 The Damage Law

> **The Surge is the burst.** It is the only skill that deals more than 2 damage.
> - **Strike:** max 2, the only attack that lands the instant it is used — it needs the target inside its shape and the AP of that shape
> - **Hazard ground:** its level (max 2) at its trigger — Lava at the end of your turn, Thornbed when you enter, Blight at the start of your turn. Voidscar: 1 at the start of your turn
> - **Collision** (pushed into a prop or monster), **fall** (pushed off Elevated) and **debris** (prop shattered next to you): 1 each
> - **Zones never deal damage.** Nothing else deals damage the instant it is cast

### 6.2 Surge Lifecycle

```
1. DECLARE   → shape appears on the board: squares, damage, fire time shown
2. CHARGE    → blocks movement through its squares
3. WAIT      → intervening queue entries may respond: leave, Veil, change height, Hallowed, ...
4. DETONATE  → at the start of the caster's next turn, per square:
               Elevated → by Surge type (§5.4)
               prop     → 2 dmg, shatter + debris, prop reaction
               monster  → value − Veil shield − Hallowed (minimum 0 damage)
5. AFTERMATH → only explicitly authored, separately budgeted residue (board_changes,
               permanent ground), subject to the profile's height rules; otherwise none; no repaint
```

**Open runtime reconciliation (central T04):** Flood's §5.4 wording implies pushing into newly laid residue, but the lifecycle does not yet specify push within damage → aftermath. Tail Sweep damage/push order, simultaneous damage/shatter/collapse/residue ordering, pull ties (including already on the anchor) and changed-initiative/extra-turn/dead-caster queue timing also need explicit rules. Do not infer ordering from data-list position. These gaps do not cancel confirmed autonomy or cast-time bindings.

**Autonomy:** a Surge is not cancelled by displacing, staggering or killing its caster. Only the counter menu (§5.4) stops it.

### 6.3 Collision, Fall & Debris

- Pushed or pulled into a **prop**: no move, 1 damage to the monster and 1 to the prop (heavy props take none)
- Into a **monster**: no move, no damage · off the **board edge**: no move, no damage. The monster-collision damage wording in §6.1 conflicts with this detailed rule and remains central T04; it is not a new collision-bonus permission
- **Off Elevated**: the move happens, 1 fall damage · onto Elevated from below: blocked like a prop, no damage
- **Prop shattered**: 1 debris damage to the four neighbouring squares; Elevated neighbours collapse to Rubble

### 6.4 General Rules

- No defense stat — damage reduction via Veils, Hallowed and passives
- All damage exact and previewed
- A Surge whose caster died still resolves

|           Source          |              Fires               |
|---------------------------|----------------------------------|
| Surge detonation          | start of the caster's next turn  |
| Strike                    | instantly, inside its shape      |
| Lava                      | end of the occupant's own turn   |
| Thornbed                  | when a monster enters the square |
| Blight / Voidscar         | start of the occupant's own turn |
| Collision / fall / debris | on impact / on shatter           |

### 6.5 Displacement

|               Type              |                                           Mechanic                                           |
|---------------------------------|----------------------------------------------------------------------------------------------|
| **Zone push**         | at the **end of the occupant's turn**, 1 square in the **direction the caster set at cast**  |
| **Zone pull** | at the **end of the occupant's turn**, 1 square toward the **anchor** the caster set at cast |
| **Shove**                       | direct, one-time, precise (needs sight)                                                      |
| **Tail Sweep** (Scaled Strike)  | push 1, direction chosen                                                                     |
| **Flood Surge**                 | pushes struck monsters 1 in the direction set at cast                                        |
| **Authored pull-after-damage twist**     | pulls struck monsters 1 toward the anchor                                                    |

Always cardinal and one square per trigger; the landing square is visible in the preview. Blocked moves: §6.3.

**Why end of turn:** at the start of a turn the target simply walks away again. At the end of its turn it lands where you sent it — in Lava, through Thornbed, in front of your Strike, or in a Surge that detonates before it can move again. The counterplay is visible: don't end your turn on a current.

---

## 7. Technical & Prototype

### 7.1 Technical Notes (Battle)

- Godot 4 · **3D square grid, orthogonal camera ~45°** — never hex
- Definition authoring uses only gdd_monsters §4.5; the Resource layout below describes the existing implementation, not an alternative schema. Its legacy missing-Surge/utility validation does not impose mandatory kit kinds (gdd_monsters §4.1). Unsupported current contracts remain central T02/T04/T09
- **Content = data files with a fixed template:** one Resource per monster / skill / zone in `data/monsters`, `data/skills`, `data/zones`, typed by its script class (`MonsterDef`, `SkillDef`, `ZoneDef` — only their exported fields exist, the inspector shows them as a form). `GameData` is the single registry: it finds every file automatically, indexes it by `id` (= file name) and validates the set on startup (duplicate ids, missing Surge/utility, unknown shapes or passives, invalid species learn-list references, missing concrete Surge types / effects, stat ranges). A new monster = a new file
- Battle logic **headless & engine-independent**: 2D array of Square objects; each square stores `{ ground{type, level, height}, object, surge, zone }`; zone definitions are a data table (effect list with base/cap), values computed live from level
- Resolution is deterministic and order-defined (§2.4); casting is a pure function `preview_cell(skill, cell)` returning `new | level | replace | weaken | cancel | lost` plus ground and prop reactions, explicitly authored residue if present, and landing squares of displacement — the same function drives the preview, the AI and the unit tests
- Opposite effects (§4.6), explicit skill-effect × prop-tag reactions (§4.11), skill flags (§5.6), concrete skill Surge types and twists are data (Resources), not code branches; the zone × zone check compares effect tags, never zone ids. The former triangle-based zone × ground interaction remains undefined (temp_todo.md, T07)
- One turn queue for all monsters (§2.2); a pending Surge stores its caster and fires on the caster's next turn start
- A pending Surge is a marker on the square with its own slot (not a zone); it blocks movement like a temporary object
- Existing implementation generates shape orientations from base shapes (rotate + mirror, de-duplicated) and picks the cell nearest the centroid. Current authored footprint/anchor mappings must instead be explicit (§5.3); ambiguous mappings remain T02, not a runtime tie-break
- Art pipeline: low-poly Blender + AI textures

### 7.2 Prototype & Playtests

**Current build (v6):** the Godot project in `godot/` — main menu → draft (pick 3 of the 9 roster monsters, or 1 for a duel) → **3v3 on 7×7** or **1v1 on 5×5** against an AI team drawn from the rest. The historical v6.0 rules, not the revised current design, are implemented in the headless core (`godot/battle/core/`). The HTML prototype is the older v5 reference.

**Tools:** `godot/tests/` (gdUnit4 suites for the rules; project layout in `godot/README.md`), `godot/tools/sim.gd` (AI-vs-AI batch simulation with win rates per monster), `godot/tools/smoke_ui.gd` (plays the player's side through the real UI headless).

**Historical v6.0 simulation (60 AI-vs-AI 3v3 battles, random teams):** sides win 50/50, ~14 rounds per battle with free rotation — **~19 rounds with fixed shapes**. Outliers to look at: **Dusk Moth wins 87%** (Native Ground + Wide Eclipse + Blight residue), Blight is the biggest damage source after Eruption, Veils absorb a lot (230 blocked hits), and ~1 in 5 battles is decided by the arena collapse (§4.2).

Playtest planning and outstanding checks: [temp_todo.md](temp_todo.md), T13.

---

## 8. Design Tracking

Open decisions and playtest checks are maintained centrally in [temp_todo.md](temp_todo.md). This GDD records the current working design; provisional values are not made final by moving their review tasks.

---

## 9. Changelog

**Current design decision — free themes, no aspects or attunement (design ahead of the code).** Removed the triangle, fixed monster aspects and all active aspect-dependent fields and modifiers, without replacement elements. Skill access uses species learn lists; blueprints and concrete ground / skill effects remain. Surge type belongs to the concrete skill. Prop reactions require explicit skill effects. The former triangle-based zone × ground interaction remains **not yet defined** (temp_todo.md, T07).

**Historical entries below:** these record earlier rules and prototype states, not current aspect or attunement mechanics. Their version-specific references and deviations are retained.

**v6.3 — Clean-up, permanent ground, flags (design ahead of the code).** This file now covers the battle only. Monster definitions moved to the new **gdd_monsters.md**: sheet, stats, Kins, Strike by Kin, roster, archetypes, skill matrix, twists, schema, passives. The tamer skill list moved to gdd_overworld §6.4. Old §3 became a short chapter, §5 was renumbered (§5.2 Strike, §5.5 Movement, §5.6 Skill Flags, §5.8 Tamer Skills & Battle Loadout); section references in the `godot/` code comments still use the old numbers. Rule changes:
- **Ground is permanent.** Surge residue no longer runs out; only zones have a clock. A burning Tree now leaves Lava I (it used to leave Rubble and timed Lava on one square, which broke the one-ground rule). The twist Lingering became Deep Residue (gdd_monsters §4.4)
- **`duration` is a skill value** (default 2, upgradeable) instead of a global constant
- **Support zones:** `haste`, `quicken`, `extend` and `mend` are in use by the new Boon zones (gdd_monsters §4.3); `mend` fires at end of turn after Lava
- **Skill flags** `affects_ground`, `affects_air`, `blocked_by_objects`, `blocked_by_height` (§5.6)
- **Skill kinds** are now strike, surge, zone, ground, prop, direct, move, self (§5.1)
- **Water** is a planned neutral ground, Swim its movement mode (§4.7, §5.5)
- **Blessed ground:** Hearth, Mossbed, Umbra and Hallowed, one per aspect plus a neutral one (§4.7)
- **Opposite zones subtract their levels** instead of always cancelling (§4.6)
- **Strike is a shape around the body** instead of a distance, it hits allies too, and monsters have no facing. The shape sets the AP, 2–5 (§5.2, gdd_monsters §3.2)
- **Reach is the cast range of all skills:** skills have no range of their own any more (§5.3), "skill range" is gone

**v6.2 — Tables and tamer skills (design ahead of the code).** Kits are **Step + 4 slots** (active or passive, at least one active); Epic+ get a 5th passive-only slot. TPR and AP prices rise with every step (gdd_overworld §5.2). AP rises to 4 at Immortal and 5 at Sovereign (TPR 1 shapes only). The ambush bonus is removed. Tamer skills get stages, sources (breakthrough pick or scroll) and seven proposed skills including catching skills (§5.11); only human tamers bring a loadout. New skill catalog table (§5.12) for the kit decision.

**v6.1 — Open kits (design ahead of the code).** The monster sheet gets **AP as a stat** (2–3), and the stat shapes become frames with a shared budget (gdd_overworld §5.2); the roster's reference values were recalculated to that budget. Max Movement rises to 3 / 4 / 5 / 5. Kits are now **4 active skills + 1 passive** instead of fixed Move + Strike + Surge + utility; Strike and movement become slot skills and a kit may hold several Surges. Medicines and arrays may join tamer skills as a **battle loadout**, partly consumed in battle, always known beforehand. Moving costs **2 AP**: every monster has **Step** (1 square, no slot), everything better is a movement skill in a slot with Kin limits (§5.5.3). Reposition became the Movement archetype.

**Restructure (no rule changes).** The document now reads Overview, Battle Flow, Monsters, Battlefield, Skills, Damage & Displacement, Technical & Prototype; all section numbers changed. Section references in the `godot/` code comments still use the old numbers.

**v6.0 — Options, not luck (current, built).** Playtests of the Godot port showed the v5 loop wasn't fun: the Surge was the only damage source and easy to dodge on 5×5, props were just obstacles, and Elevated was a blanket "Surge immune" rule. v6 stays fully deterministic but adds:
- **Surge residue** (timed hazard ground) and **Surge types by aspect** (Eruption / Flood / Rift) with their own rules for props and height
- **Strike** (2 AP, max 2 damage, Kin twist) and the **Reach** stat
- **Directional displacement** (direction / anchor set at cast) firing at the **end** of the occupant's turn
- **Prop tags and reactions** (flammable, brittle, heavy, indestructible); zones may be placed on props; Shrine and Sigil as effect props
- **Ground = neutral + one hazard per aspect** (Lava / Thornbed / Blight); zones change ground by the triangle; zones fight zones by **opposite effects** instead of name pairs
- **No cooldowns**, every action ≥ 1 AP, one charging Surge per monster
- **Team battles:** standard 3v3 on 7×7, one initiative queue, Surges fire at the start of the caster's next turn
- **Monster identity** in three layers (Kin / Aspect / Species), Surge twists, skill matrix (archetype × aspect) and a first 9-monster roster

**v5.0 — Zones + Ground.** v4 had deleted zones; v5 brought them back with a clean split. **Zones** were timed (2 rounds), one per square, and did movement and tempo control (slow, push/pull, initiative/range drain, shield). **Ground** was permanent and did damage terrain (Lava) plus the board's memory (Elevated, Rubble, Voidscar, attunement). The **Surge** got its own slot: damage first, then it repaints the ground it hit. Pairs like Bog ↔ Gale cancelled by name; Bog cooled Lava, Gale fanned it; Elevated blanked every Surge; skills had cooldowns. Playtest questions were: do zones steer the fight, does permanent Lava change where you stand, does repainting make territory matter, do Veils make Surges answerable without a Dispel loop, and is one zone / one ground / one attunement per square honest to read.

**v3.1** fixed misleading hybrid zones (one zone per square instead of merge arithmetic) and explained attunement as ground, not a hidden zone modifier. Kept: tetris shapes, no Dispel, Surge as the only big burst, props/shatter, 2 AP.

**Earlier:** v4 ground-only (zones deleted: effects became permanent terraforming; clutter risk, push/pull lost its timed role) · v3.0 aspect-triangle overwrites (wrong-aspect monster locked out) · v2.2 square interactions · v2.1 anti-loop tweaks · v2 Surge-only damage · v1 wind-up. *(v3.0 also removed Dispel, Rupture, Bind and HexField.)*