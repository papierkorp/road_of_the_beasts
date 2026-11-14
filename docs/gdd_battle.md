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

- **Why 7×7 for 3v3:** 6 monsters on 49 squares is about as crowded as 2 on 25 (1v1), keeping pressure similar. An odd size provides a **centre row** for the Dragon Veins (§4.2) and mirror-fair starts. Other board shapes are a parked idea ([temp_todo.md](temp_todo.md), Potential Extensions).
- Small kits aim to keep 3v3–5v5 readable; kit size and rarity exceptions: [Skills §1](gdd_skills.md#1-the-kit).

### 1.2 Battle Design Pillars

**Status:** the pillars reflect the square and skill reshape *(user decisions 2026-11-13; implemented in the Godot build)*. First human play and feedback have occurred; systematic gameplay and balance validation remain open ([temp_todo.md](temp_todo.md), T13/T40). Numbers in this document are working values.

1. **Control squares, not just units** — skills act through a Strike, movement, an effect on the user, or the creation of ground, a zone or a prop ([skill card](gdd_skills.md#2-the-skill-card)). The board is the weapon.
2. **Deterministic and readable** — no dice, no hidden information; before confirming, the player sees which squares a skill takes, what it creates there and where every pushed monster lands.
3. **A square has two layers with one role each** — **ground acts at a moment** (on entering, on leaving, at the end of the occupant's turn, at the end of the round), **a zone acts while a monster stands in it** (stat changes; push or pull at the end of its turn). A monster or a prop occupies the square. There is no height, no air layer and no Surge or trap marker (§4.3).
4. **A skill only delivers** — what a ground, a zone or a prop does, and when, is written once, in its own definition (§4.6, §4.7, §4.10); a skill names what it creates. Learning the grounds and zones is learning the game.
5. **Fair damage** — damage from a distance never hits a monster that has had no turn of its own since the cast: it comes only from ground, and ground never acts at the start of a turn or round. Immediate damage exists only as a Strike on a neighbouring square (§6.1).
6. **Small HP, no one-hit defeats** — the highest single hit is 2 and the lowest HP 3 *(working values)*: no hit takes a monster from full HP to zero, but two mistakes do.
7. **Hold the Dragon Veins** — the win condition is “all enemy monsters defeated”; the way there is square control: a Dragon Vein works for the side that touched it last, and whoever waits loses HP (§4.2).
8. **Being moved is movement** — every effect that reacts to entering or leaving a square also reacts to a push or pull; displacement combines with ground, collision and Dragon Vein control.
9. **One skill source** — monster-skill authoring and access: [gdd_skills.md](gdd_skills.md), linked from [§5](#5-skill-integration). No aspects, no element triangle, no attunement.

**Battle goals** *(user, 2026-11-12; restated 2026-11-13)* — what a battle has to deliver; the pillars above are the means, and rules, content and prices are judged against these goals ([temp_todo.md](temp_todo.md) T13 measures them):
- **Influence and consequence:** the player's decisions shape the board and the battle and have visible consequences.
- **Deterministic:** no dice, no hidden information.
- **Short:** a battle of about 15 rounds is already very long. **Target for 3v3 *(user, 2026-11-13)*:** **3–5 rounds on average**, with battles **under 2 or over 5 rounds** measured separately as outliers, ended by fighting and not by late-round pressure (§4.2). Even short battles must offer meaningful decisions through AP, turns and positioning. Where possible no monster is defeated in round 1.
- **Tactical:** repeating one skill must not win a battle; position and combination decide.
- **Every skill has its situation:** each skill is the right choice in some situations and none in all.
- **Fair defeats:** a loss reads as the player's own mistake; no monster is defeated without its player having had a chance to act.
- **Simple to learn, hard to master:** few uniform rules, no hidden abilities; everything a monster can do is visible.
- **Monsters differ:** different monsters offer different ways to play, and every stat matters ([Monsters §2.2](gdd_monsters.md#22-frame-budget-level-ups)).
- **Win condition:** the battle ends when every monster of one side has 0 HP.

**Development and validation:** a viable starting build and alternative upgrade paths must be tested together, including starter-kit affordability, meaningful stat roles and the battle goals above. Concrete starting stats and upgrades are not approved by bot results. Stat prices, frames and budgets remain unvalidated ([Monsters §2.2](gdd_monsters.md#22-frame-budget-level-ups)); skill prices remain open ([Skills §5](gdd_skills.md#5-value-and-prices)). Open checks and candidate comparisons: [temp_todo.md](temp_todo.md), T02/T03/T05/T13/T40; measurements: [simulation_log.md](simulation_log.md).

---

## 2. Battle Flow

### 2.1 Core Battle Loop

1. Battlefield generated (ground, props, Dragon Veins — §4.1)
2. Pre-battle: choose monsters and place them in your start area; preparation/loadout: Overworld sources in [§5.2](#52-tamer-skills-and-battle-loadout). Start at **current HP** ([gdd_overworld §6.6](gdd_overworld.md#66-pills--medicines)).
3. **Each round:** one queue for all monsters of both sides, highest effective initiative first (§2.2)
4. **Monster's turn:** dispatch due events/effects, spend its **AP** on legal actions ([§2.3](#23-action-points)), then resolve end effects in [§2.4](#24-effect-timing-reference) order.
5. Round ends → resolve the round-end events in [§2.4](#24-effect-timing-reference)
6. Battle ends when one side has no monsters left. *(User decision 2026-11-11:)* the check happens after a payload/phase has fully resolved, including its defeats; the battle then ends immediately and autonomous aftermath lapses. If both sides have no monsters left after the same resolution, the result is a **Draw**; its BattleResult handling is defined with T19/T23.

### 2.2 Initiative Rules

- **One queue for all monsters of both sides**, strictly by effective initiative, **recalculated every round**
- A side may act several times in a row — that is the reward for initiative, not a bug
- **Ties:** higher base initiative first; still tied → the sides alternate (the first tie of a battle goes to the side with the lower total initiative; if the totals are equal, to the player's side). *(User decision 2026-11-11:)* tied units of the same side act in their fixed loadout/start slot order (slot 1 first); an extra-turn entry follows its unit's main entry. EXP and other meta state never break ties.
- An initiative-draining zone can flip the order, giving a monster two turns back to back across the round boundary — a real tempo weapon
- Multi-turn monsters get one extra queue entry per extra turn, each at −3 initiative (min 0.1)
- **Extra turns count from round 2** *(working draft, user decision 2026-11-13; S013)*: in round 1 every monster has exactly one queue entry, whatever its TurnsPerRound
- **Unit-bound effects and caster death** *(user decision 2026-11-10)*: effects bound to a unit (buffs, debuffs, marks, self-boosts) end immediately when that unit is defeated or removed. Zones, ground and props stay when the monster that created them is defeated; there is no owner expiry.
- **Postponing a turn** is not a rule: two forms were measured as test switches (any monster once per round with the waiting monsters in reverse order; round 1 only for monsters with two turns and the first of the queue) and did not lift the fast monsters in bot runs ([simulation_log.md](simulation_log.md) S017; T39).

### 2.3 Action Points

**Battle-AP per turn = the monster's AP stat** (2–5, [Monsters §2.1](gdd_monsters.md#21-the-stats)).

- Pay the resolved monster action's authored Battle-AP cost: **at least 1 Battle-AP, never 0**. This does not redefine tamer/loadout usage.
- **Step** (every monster): 1 AP, 1 square. Costs of skills: their [skill card](gdd_skills.md#2-the-skill-card); what a skill may cost is open ([Skills §5](gdd_skills.md#5-value-and-prices)). Tamer/loadout costs use their own Overworld sources ([§5.2](#52-tamer-skills-and-battle-loadout)).
- **Repetition:** a skill may be used any number of times for its AP unless its card says once per round or once per battle ([Skills §2](gdd_skills.md#usage-and-repetition)). A zone may be cast again to level it up, ground laid again to level a hazard. No generic multi-round cooldown system.
- **Positioning** competes with attacking for Battle-AP: with AP 2 a monster strikes or moves, with AP 3 it can do both.

### 2.4 Effect Timing Reference

**The one timing reference** for everything that acts by itself. A definition names one of these moments; nothing acts at the start of a turn or of a round.

| Moment | When | What acts |
|---|---|---|
| now | when the skill is used | a Strike; the user's own movement; the creation of ground, a zone or a prop; the first push or pull of a push or pull zone (it moves whoever stands in it when it is cast) |
| on entering | a monster enters the square: by walking, by a push or by a pull | ground with an entry effect (Thornbed, Mossbed); a Dragon Vein changes its owner |
| on leaving | a monster leaves the square: by walking, by a push or by a pull | ground with a leaving effect (Binding Vines) |
| while inside | as long as a monster stands on the square | zone stat changes (Movement, initiative, Reach); the aura of a neighbouring prop |
| end of the occupant's turn | when the monster's turn ends | 1. zone push or pull and the Storm Drum → 2. end-of-turn ground on the square it now stands on (Lava, Voidscar) |
| end of the round | after the last turn of the round | 1. end-of-round ground (Blight), each monster for itself → 2. Dragon Vein and surround damage, one step (§4.2) → 3. zones lose a round, timed unit effects expire, ground laid in battle fades (§4.5) → 4. late-round pressure, if it runs (§4.2) → 5. the queue is built anew |
| on an event | when it happens | collision damage on a blocked push or pull (§6.3); a prop's aftermath when it is destroyed (§4.10) |

Order inside a turn:

1. AP: every action resolves completely, including the pushes, entries and departures it causes ([§6.2](#62-payload-resolution)).
2. End effects: zone displacement → end-of-turn ground on the landing square.

**Placing ground under a monster is not entering:** ground laid beneath an occupant acts at its next moment (leaving, end of turn, end of round), not at once.

**Event-driven reactions** *(user decision 2026-11-11)*: reactions of event-driven passives collect during a payload and resolve after its last step, one at a time in the initiative-queue order of the reacting units, on the board as it then stands. Their consequences (entry or ground damage, healing) apply normally but trigger no further passive reactions; each passive reacts at most once per triggering event. Defeated units do not react.

**Scheduling references:** payload order: [§6.2](#62-payload-resolution); tamer/loadout activation windows: [§5.2](#52-tamer-skills-and-battle-loadout); remaining loadout details: T19/T20 in [temp_todo.md](temp_todo.md).

---

## 3. Monsters in Battle

Battle resolves a finished unit sheet. Monster definitions (sheet, stats, Kins, roster, progression): [gdd_monsters.md](gdd_monsters.md); skills (Strikes, kits, passives): [gdd_skills.md](gdd_skills.md); loadout integration: [§5.2](#52-tamer-skills-and-battle-loadout).

### 3.1 Effective Stats

**Effective stats** combine the base sheet with all applicable modifiers: zones, the auras of props, and effects on the monster itself (self buffs, passives). Ground changes no stat.

- One zone per square limits zone occupancy, not cross-source stacking. Stacking and expiry *(user decision 2026-11-11)*: the same source (same effect of the same owner) only refreshes duration and never adds magnitude; different sources (zone, prop, skill, passive) add without a cap; only the existing stat floors apply (Movement and Reach min 1, Initiative min 0.1). A timed unit effect with a duration of N rounds lasts from application until the round end of the N-th following round (round-end tick, [§2.4](#24-effect-timing-reference)); it ends earlier with its defeated or removed bearer ([§2.2](#22-initiative-rules)).
- Board sources below are not an exhaustive modifier catalogue.

| Stat | Changed in battle by |
|---|---|
| Initiative | `drain_init` / `quicken` (zone or self buff, §4.6), Shrine (§4.10) |
| Movement | `slow` / `haste` (§4.6), Banner (§4.10); Step is always 1 square |
| Reach | `drain_range` / `extend` (§4.6), Totem (§4.10); min 1 |
| AP, turns per round | *experiment only:* the self buffs Battle Trance and Time Split ([Skills §11](gdd_skills.md#11-skill-list)) |

### 3.2 Monster Identity & Skill Access

- **Free themes**, not fixed aspects or replacement element categories: identity comes from species, Kin, stats, skills and passives. Themes impose no matchup triangle or combat modifiers; there is no attunement (§4.8).
- Skill access and authored definitions: [gdd_skills.md](gdd_skills.md); battle integration: [§5](#5-skill-integration). Ground types, zone effects and prop reactions use the resolved concrete definition, never the monster's theme.
- Zone × zone compares effects (§4.6); zones never change ground ([§4.6](#46-zones-effects-rules--opposites)).

---

## 4. Battlefield

### 4.1 Battlefield Generation

- Procedural ground + props, **point-symmetric around the centre** so both sides get the same distances (mirrored fairness check for every mode)
- **Dragon Veins** on the centre row (§4.2); every map has at least one *(user decision 2026-11-13; count and squares for boards without a centre row are open)*
- Pre-placed props shape the opening
- **Prop symmetry** *(user decision 2026-11-11)*: props are placed only as point-mirrored pairs, so the count is always even; the centre square of an odd board never holds a prop, and no prop stands on a Dragon Vein. The prop counts in the table below are draft values, not balance approval.
- **Board distance** *(user decision 2026-11-10)*: Chebyshev, `max(|dx|, |dy|)` (diagonals count like orthogonal steps). Rules that need another measure name it explicitly.

| Mode | Board | Start area per side | Dragon Veins | Props |
|---|---|---|---|---|
| 1v1 | 5×5 | opposite corners | open (the build places none) | 2 |
| 2v2 | 6×6 | back row | open (no centre row; the build places none) | 2 or 4 |
| **3v3** | **7×7** | back two rows; players place their monsters in pre-battle | **3 on the centre row (x = 1, 3, 5)** | 4 or 6 |
| 5v5 | 9×9 | back two rows | open | 6 or 8 |

**Opening** *(unvalidated)*: on 7×7 the start rows lie 4 squares apart; the first round is for position. A first round without any damage was measured as a test switch (first defeat in round 2.0 instead of 1.1–1.4; [simulation_log.md](simulation_log.md) S017/S018) and is not a rule (T39).

### 4.2 Dragon Veins, Surrounding and Late-Round Pressure

**Status: working draft** *(user decisions 2026-11-13; standard of the Godot build; first human play and feedback have occurred, systematic validation remains open: T13/T39/T40 in [temp_todo.md](temp_todo.md))*. The win condition is unchanged: all enemy monsters defeated. Holding squares is the way there, and whoever waits loses HP.

- **Dragon Veins:** three squares on the centre row of the 3v3 board (7×7: x = 1, 3, 5) are **Dragon Vein**, a ground type that nothing changes ([§4.7](#47-ground--neutral-hazard-and-blessed)). No prop may stand on one and no ground is laid on it; a zone may lie on it. Count and squares for other modes are open (boards with an even side have no centre row; the build places none there). *(The squares were called Wellspring until 2026-11-13.)*
- **Ownership by last touch** *(user decision 2026-11-13)*: a Dragon Vein belongs to the side whose monster **touched it last**: walked onto or across it, was pushed or pulled onto it, or stands on it. It stays with that side after the monster has left, until a monster of the other side touches it. At the start nobody owns one.
- **Dragon Vein damage:** at the end of a round every owned Dragon Vein deals **1 damage to the nearest enemy of its owner** (board distance from the square). Ties: the enemy with more HP, then with more initiative, then **the owner chooses**. (The build takes roster order for the last tie; a choice needs an input step.)
- **Surrounding:** at the end of a round a monster with **two or more enemies on its eight neighbour squares** takes 1 damage.
- **One step:** ground that acts at the end of a round resolves first, each monster for itself; then Dragon Vein and surround damage of a round resolve together as one simultaneous damage step ([§6.1](#61-the-damage-law)), before ground laid in battle fades and before late-round pressure.
- **Late-round pressure is only a brake:** it runs only at the end of a round **in which nobody owns a Dragon Vein**, and then as before: from a set round (tunable: 1v1 round 6, 3v3 round 8) the square farthest from all living monsters becomes **Voidscar** (permanent, undestroyable). *Reading (user decision 2026-11-10):* each square's distance is measured to its nearest living monster and the largest value wins; all equally far squares convert together, with no tie-break. **Collapse:** once no free square is left to convert, every living monster takes 1 damage per round. In modes without Dragon Veins it runs every round. With ownership by touch a vein is owned from the first rounds on, so on the 3v3 board the brake practically never runs.

### 4.3 The Square: Ground, Zone and Occupant

```
[ OCCUPANT ]  one monster | one prop (§4.10) | empty
[ ZONE     ]  ONE timed zone | empty — acts while a monster stands inside (§4.6)
[ GROUND   ]  ONE ground type — acts at a moment (§4.7); laid in battle: 2 rounds (§4.5)
```

- **One ground, one zone, one occupant per square;** all three can be active at once. *(User decisions 2026-11-13: height and the air layer are removed, Surges and traps are removed; ground and zone stay two layers with one role each.)*
- **zones = what you do to a square for a while; ground = what the square does at a moment.**
- **Ground and zone are independent:** a zone never changes ground and ground never changes a zone; they combine only through their separate effects on the same square (Lava under a slowing zone).
- **A prop does not shield its square:** ground and zones are laid on a prop square like on any other *(user decision 2026-11-13)*; they act on whoever stands there once the prop is gone.
- A prop prevents monster occupancy; a monster prevents prop placement.
- **Squares that act once and then vanish** (the earlier trap) do not exist; the idea is parked ([temp_todo.md](temp_todo.md), Potential Extensions).
- **2×2 bodies** *(user decision 2026-11-10; no monster of the build has one)*: a 2×2 monster occupies four squares.
  - **Distance/Reach:** measured from the nearest covered square, for attacker and target.
  - **Ground moments** (entering, leaving, end of turn, end of round): fire once per event if any covered square qualifies, never once per square. **Mixed ground:** every ground type present under the body takes effect **once**; several levels of the same hazard: the highest level applies once. Entry effects use only the **newly covered** squares, leaving effects the squares it no longer covers.
  - **Same moment, net:** damage and healing from ground at the same moment resolve simultaneously: HP = min(max HP, HP − damage + healing); the monster is defeated only if HP ≤ 0 afterwards.
  - **Movement and legality:** a step costs the highest movement cost among the newly covered squares. A stand or step is legal only if all four covered squares are legal; a prop, a monster or the board edge on any covered square makes it illegal.
  - **Several zones under one body** *(user decision 2026-11-11)*: every distinct zone (cast group) covering at least one square of the body takes effect **once**. Stat changes of different zones add as different sources ([§3.1](#31-effective-stats), floors apply). Push or pull at turn end: each qualifying zone contributes one cardinal direction; opposite directions cancel, and the body moves one square only if exactly one cardinal direction remains.
  - **Adjacency** (aura props, passives that name neighbours): a 2×2 is adjacent if at least one covered square is orthogonally adjacent to the source; the effect applies once.

### 4.4 Square Data Model

Illustrative **runtime board state only**, not a skill-authoring format: entries store ownership, levels and remaining lifetime. Definitions are Resource files under `godot/data` ([Skills §7](gdd_skills.md#7-data-and-validation)).

```jsonc
{
  "pos": [2,1],
  "ground": {
    "type": "lava",          // plain | rubble | voidscar | dragon_vein | lava | thornbed | blight | snare | mossbed
    "level": 1,              // hazard grounds only (1–2) = damage per moment
    "until_round": 4,        // laid in battle: last round it lasts; 0 = stays
    "owner_side": -1         // Dragon Vein only: the side that touched it last, -1 = nobody yet
  },
  "object": { "name": "Stone Lion", "hp": 3, "tags": ["heavy", "spiky"] },   // ground and zone under it stay and wait
  "zone": {
    "def": "gale",           // reference to the zone definition
    "gid": "g77",            // patch id: all cells of one cast
    "owner": "tiger",
    "level": 1,              // 1–3
    "duration": 2,           // rounds left
    "dir": [1,0],            // push direction
    "anchor": [2,2]          // pull point
  }
}
```

State stores the zone level, not effect values; values follow the effect definitions and [§4.6](#46-zones-effects-rules--opposites).

### 4.5 Lifecycles

| Thing | Clock | Notes |
|---|---|---|
| **Zone** | the rounds its creating skill names (2 in every skill of the build); loses one at the end of each round | on expiry the zone is removed; cast again on the same squares it levels up and refreshes (§4.6) |
| **Ground laid in battle** | **2 rounds** (the round it is laid in and the next one), then Plain again | the clock restarts whenever the ground is laid or levelled again; it acts at every one of its moments as long as it lies *(user decision 2026-11-13: no ground that acts once and vanishes)* |
| **Ground of the starting board, Voidscar, Dragon Vein** | none | Voidscar and Dragon Vein are never changed by anything |
| **Prop** | none | stays until its HP are gone; then its aftermath resolves (§4.10) |
| **Effect on a monster** (self buff) | N rounds: until the end of the N-th following round | ends earlier with its bearer ([§2.2](#22-initiative-rules)) |

- **Persistence** *(working draft, user decision 2026-11-12 after [simulation_log.md](simulation_log.md) S011)*: what a skill lays on the board is temporary. *Reason: permanent hazard ground filled the board and made waiting pay.*

### 4.6 Zones: Effects, Rules & Opposites

**A zone acts while a monster stands in it** *(role decided 2026-11-13)*: it changes stats, and it pushes or pulls at the end of the occupant's turn. A zone never deals damage and never heals; that is ground's role (§4.7). Zone definitions: `godot/data/zones`; which skill creates which zone: [Skills §11](gdd_skills.md#11-skill-list).

| Effect | When | Action | Opposite |
|---|---|---|---|
| `slow` | while inside | Movement −value (never below 1, Step unaffected) | `haste` |
| `haste` | while inside | Movement +value | `slow` |
| `drain_init` | while inside | initiative −value (turn order!) | `quicken` |
| `quicken` | while inside | initiative +value | `drain_init` |
| `drain_range` | while inside | Reach −value (min 1) | `extend` |
| `extend` | while inside | Reach +value | `drain_range` |
| `push` | when cast, and at the end of the occupant's turn | move 1 in the zone's direction | `pull` |
| `pull` | when cast, and at the end of the occupant's turn | move 1 toward the zone's anchor square | `push` |

- Effects hit **everyone** on the square — allies, enemies and the caster.
- **Direction of a push zone:** cast alone, the direction is chosen with the cast. Left by a skill that also creates something else, it points where the placement is turned (rotation); left by a Strike, in the Strike's direction; left on the path of a movement, the way the monster went.
- **Level-to-value:** definitions supply base and cap; **effective value** = `min(cap, base + level − 1)`, min 1 (slow capped at 2; push/pull always 1).
- **Zones of the build** *(working draft)*: Gale (`push`), Void Pull (`pull`), Bog (`slow` 1, `pull`); as an extra on a skill that creates ground: Mire (`slow` 1, `drain_init` 2, `drain_range` 1; with Gloom Rift) and Slowing (`slow` 1; with Thornbed); Tailwind (`haste` 2) is in the data and unused. **A zone that only changes stats is never cast alone** *(user decision after first play, 2026-11-13)*. The earlier shield and healing zones are archived: reducing Surge damage has no object any more, and healing belongs to ground.

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

**Zone × ground** *(user decision 2026-11-10)*: zones and ground stay independent: a zone never changes, suppresses or inverts ground, and ground never changes a zone. They combine only through their separate effects on the same square.

### 4.7 Ground — neutral, hazard and blessed

**Ground acts at a moment** *(role decided 2026-11-13)*: it damages, heals or costs movement when a monster enters it, leaves it, ends its turn on it, or stands on it at the end of the round. It changes no stat and never acts at the start of a turn or round. Ground definitions: `godot/data/grounds`; which skill creates which ground: [Skills §11](gdd_skills.md#11-skill-list).

| Group | Ground | Moment | Effect |
|---|---|---|---|
| Neutral | **Plain** | — | movement cost 1 |
| Neutral | **Rubble** | on entering | movement cost 2; left by several destroyed props (§4.10) |
| Neutral | **Voidscar** | end of the occupant's turn | 1 damage; permanent, spreads with late-round pressure (§4.2), nothing changes it |
| Neutral | **Dragon Vein** | end of the round | nothing to whoever stands on it; 1 damage to the nearest enemy of its owner (§4.2); permanent, nothing changes it, no prop on it |
| Hazard | **Lava** I–II | end of the occupant's turn | damage = level — *punishes staying* |
| Hazard | **Thornbed** I–II | on entering (walk, push or pull) | damage = level — *punishes moving in* |
| Hazard | **Binding Vines** | on leaving (walk, push or pull) | 2 damage; standing still costs nothing — *stay or pay; may be laid under a monster* |
| Hazard | **Blight** I–II | end of the round | damage = level — *punishes being there when the round ends* |
| Blessed | **Mossbed** | on entering (walk, push or pull) | heals 1, never above max HP; no re-entry limit — *rewards moving* |

**How ground is made and changed:**

- **A skill creates it** on its squares ([skill card](gdd_skills.md#2-the-skill-card)): on a placed shape, on the square a Strike hit, or on the squares a movement left; also under a prop. Never on Voidscar or a Dragon Vein.
- **A destroyed prop** leaves the ground of its type (§4.10); a prop that names none leaves the ground under it as it is.
- **Same type** on the square → a hazard gains a level (max II; Binding Vines and Mossbed have no levels) and its clock restarts. **Different type** → the new ground replaces the old one.
- Ground laid during the battle lasts 2 rounds (§4.5); ground of the starting board stays until something replaces it.
- **Placing ground beneath an occupant is not entering** ([§2.4](#24-effect-timing-reference)). Binding Vines laid under a monster hurt when it leaves, also when it is pushed or pulled off.
- Ground works for **everyone** on it: an enemy can use your Mossbed too.
- **No height:** Mountains, climbing costs, the Reach bonus, fall and collapse damage are removed *(user decision 2026-11-13)*; props block the way instead. The earlier stat grounds Hearth, Umbra and Hallowed are archived (ground changes no stat).

### 4.8 Removed Square Mechanics

Kept as one reference so that older notes can be placed: **attunement and the aspect triangle** (removed 2026-11-10), **Water and Swim** (2026-11-10), **height / Mountains and the air layer with flying** (2026-11-13), **Surges and traps** as markers on a square (2026-11-13). None has a replacement rule; what took their place is described in §4.3–§4.7.

### 4.9 Props

**A prop occupies a square:** it blocks the way for monsters and has its effect when it is destroyed *(user, 2026-11-13)*; some work on their neighbours while they stand. It gives no cover.

**Prop principles** *(user, 2026-11-10/11)*:
- **Always solid:** no monster shares a square with a prop.
- **Fixed, previewed aftermath:** every prop has its own aftermath, fixed by its type and independent of who or what destroyed it and from which direction. It is shown in the preview. **No chain reactions:** aftermath damage hits monsters only, never props.
- **Creatable by skill:** a prop type may be created by a skill on an empty square (catalogue flag); board generation may pre-place any type of the game.
- **What damages a prop:** a Strike hits props in its shape like monsters; a monster pushed or pulled into a prop damages it (§6.3). Ground, zones and movement do not.
- **No indestructible prop** *(user decision 2026-11-11)*.
- **Spiky props** *(working draft, user direction 2026-11-12)*: a prop with the tag `spiky` deals 2 instead of 1 collision damage to a monster pushed or pulled into it ([§6.3](#63-collision)).
- **Timing and symmetry:** destruction and aftermath order: [§6.2](#62-payload-resolution); placement symmetry: [§4.1](#41-battlefield-generation).

### 4.10 Prop Catalogue and Damage

**Status: working draft** *(user chose the concept 2026-11-11; names, HP and aftermath values are calibration drafts until T13)*. Classes: **inert** (nothing beyond ground), **burst** (damage on neighbouring squares), **residue** (leaves ground), **push** (displaces neighbours when destroyed), **spawn** (creates child props), **aura** (works while standing). Definitions: `godot/data/props`.

| Prop | Class | HP | While standing | On destruction | Ground left |
|---|---|---|---|---|---|
| Stone Lion | inert | 3 | `heavy`: cannot be moved; `spiky` | nothing | Rubble |
| Clay Urn | burst | 1 | — | 1 damage to monsters on the 8 neighbouring squares | — |
| Bamboo Stand | burst | 2 | `spiky` | 1 damage to monsters on the 4 cardinal neighbours | — |
| Paper Lantern | residue | 1 | — | nothing | Lava I |
| Peach Tree | residue | 2 | — | nothing | Mossbed |
| Ancestor Tablet | residue | 2 | — | nothing | Mossbed *(Hallowed until 2026-11-13; now a twin of the Peach Tree, to be given its own ground or removed)* |
| Bronze Gong | push | 2 | — | monsters on the 8 neighbouring squares are pushed 1 square away from the gong | — |
| Vortex Urn | push | 1 | — | monsters on the 8 neighbouring squares are pulled 1 square toward the urn's square; the first to arrive takes the square, the others collide ([§6.3](#63-collision)) | — |
| Pagoda Column | spawn | 3 | — | creates a Beam on each of the 4 cardinal neighbours that is free of props and monsters | Rubble |
| Beam | inert | 1 | child prop, created only by the Column | nothing, spawns nothing | — |
| Shrine | aura | 2 | orthogonal neighbours get `quicken 1` | aura ends | Rubble |
| Totem | aura | 2 | orthogonal neighbours get `extend 1` | aura ends | Rubble |
| Banner | aura | 2 | orthogonal neighbours get `haste 1` | aura ends | Rubble |
| Wardstone | aura | 2 | *(none any more: it reduced Surge damage; to be given a new effect or removed, T40)* | aura ends | Rubble |
| Storm Drum | aura | 2 | a monster that ends its turn orthogonally next to it is pushed 1 square away from the drum (friend and foe; resolved with the turn-end zone displacement, [§2.4](#24-effect-timing-reference)) | effect ends | Rubble |

- **Created by skills of the build:** Bamboo Stand (Plant Bamboo), Bronze Gong (Set Gong).
- **Archived with the air layer:** Wind Chime, Thunder Cloud, Gale Banner, Pagoda Bridge.
- **Ground left “—”:** the prop leaves the ground under it as it is, including ground a skill laid there while the prop stood *(changed 2026-11-13; before, such a prop reset the square to Plain)*.
- **Aura props** *(user: auras add tactical depth and a prop-versus-zone choice)*: one template (2 HP, orthogonal neighbours, work for everyone including enemies) with one stat effect each from [§3.1](#31-effective-stats).

**Damage to props:** a Strike deals 2 to a prop in its shape (a Swarm Strike 4, [Skills §8](gdd_skills.md#8-strikes-and-movement)); a collision deals 1 to the prop (a `heavy` prop takes none; a `spiky` prop deals 2 to the monster, [§6.3](#63-collision)); aftermath damage never affects props.

**Aftermath resolution** *(user decisions 2026-11-11)*:
- A prop at 0 HP stays on the board and keeps blocking until the removal step of the payload ([§6.2](#62-payload-resolution)); then all 0-HP props are removed together, their aftermaths are evaluated against the board as it stands, and damage from several aftermaths on one monster adds.
- A destroyed Bronze Gong's or Vortex Urn's displacement resolves right after the removal, under the displacement and tie rules of §6.2.
- Ground left behind never replaces Voidscar or a Dragon Vein; the prop's damage, push and spawn still resolve.
- The Pagoda Column's Beams are the only prop-creating aftermath; Beams spawn nothing.

### 4.11 Prop Tags

- **`heavy`** (Stone Lion): cannot be moved by displacement.
- **`spiky`** (Stone Lion, Bamboo Stand; draft assignment): 2 collision damage to a monster displaced into it ([§4.9](#49-props)).
- A zone on a prop square waits; once the prop is gone, the zone works normally there.

---

## 5. Skill Integration

### 5.1 Monster Skills: Central Specification

**Monster-skill definitions and skill-specific execution rules live only in [gdd_skills.md](gdd_skills.md).**

Battle resolves finished skills against the turn/event system (§2), board state (§4) and generic damage, displacement and collision (§6); no second skill format, skill list or price list. What grounds, zones and props do is defined here (§4.6, §4.7, §4.10); a skill only names them.

| Topic | Central source |
|---|---|
| Kit and access | [§1](gdd_skills.md#1-the-kit) |
| The skill card: cost, place, Strike, movement, effect on the user, what it creates | [§2](gdd_skills.md#2-the-skill-card) |
| The three things a skill does itself | [§3](gdd_skills.md#3-what-a-skill-does-itself) |
| What a skill creates and how it combines | [§4](gdd_skills.md#4-what-a-skill-creates) |
| Value and prices (open) | [§5](gdd_skills.md#5-value-and-prices) |
| Slot levels, development and replacement | [§6](gdd_skills.md#6-slot-levels-development-and-replacement) |
| Data, validation and the skill builder | [§7](gdd_skills.md#7-data-and-validation) |
| Strike shapes, Kin effects and movement kinds | [§8](gdd_skills.md#8-strikes-and-movement) |
| Skill list and kits | [§11](gdd_skills.md#11-skill-list), [§10](gdd_skills.md#10-kits-of-the-nine-monsters) |

Missing rules remain in [temp_todo.md](temp_todo.md), not implicit runtime defaults.

### 5.2 Tamer Skills and Battle Loadout

Battle resolves explicit effects from the human tamer's prepared loadout under general event/board rules, deterministically and with previews. Wild monsters retain monster skills, but have no tamer skills or human loadout.

**Authoritative Overworld sources** (no monster-skill AP prices or permissions transfer):
- [§6.4 Tamer Skills](gdd_overworld.md#64-tamer-skills): definitions, slots, access and usage.
- [§2.1 Battle Loop](gdd_overworld.md#21-battle-loop) and [§7.9 Inventory and Loadout](gdd_overworld.md#79-inventory-and-loadout): preparation, visibility and loadout logistics.
- Planned medicines and arrays: [§6.6](gdd_overworld.md#66-pills--medicines) and [§6.8](gdd_overworld.md#68-arrays-artifacts-for-places).

**Tamer activation and confirmed skill rules** *(user decisions 2026-11-11)*:
- **Window:** a slotted skill (once per battle, free) may be used during the turn of one of the tamer's own monsters, never inside a payload resolution or during enemy turns; it costs no AP and no turn and has a normal preview.
- **Swap Places:** two own 1×1 monsters trade squares; no range or LOS. Each counts as leaving its square and entering the new one (ground effects fire, as for move/push/pull).
- **Urgent Order:** an own monster that has not acted this round is inserted directly after the current turn; its original entry of this round is removed (no double action). Extra-turn entries are not affected; the round-end re-sort is unchanged.
- **Second Wind:** one own monster on the field regains 1 HP (never above max); it unlocks no monster healing.
- **Life Thread:** set on one chosen own monster, effect and consumption as in [§6.1](#61-the-damage-law); it also protects in Deadly dungeons (death/injury details T23).
- **Beast Swap:** the incoming monster takes the square and queue entry of the swapped-out monster (it acts this round only if that entry is still pending), arrives with its current HP and must have the same body size (1×1 for 1×1, 2×2 for 2×2). The swapped-out monster is not defeated and may be swapped back later; what it created on the board stays ([§2.2](#22-initiative-rules)). Soul Tier gate unchanged.
- **Tamer skills that named Surges** (Spirit Shield: Nullify against Surge damage, and others in [gdd_overworld §6.4](gdd_overworld.md#64-tamer-skills)) have lost their object with the reshape of 2026-11-13 and are to be redefined (T20).
- Remaining integration details (other skills, loadout, source-specific resolution): T18–T20.

**Unresolved integration contract:** source-specific resolution of the remaining tamer skills and loadout details are tracked in [temp_todo.md](temp_todo.md), T18–T20; this section supplies no default timing or cost.

---

## 6. Damage & Displacement

### 6.1 The Damage Law

> **No hit takes a monster from full HP to zero.** The highest single hit is 2, the lowest HP 3 *(working values of 2026-11-13)*.
> - **Strike:** at most 2 against monsters, now, on neighbouring squares ([Skills §3](gdd_skills.md#3-what-a-skill-does-itself))
> - **Ground:** its level (hazards, at most 2), Binding Vines 2, Voidscar 1, each at its moment ([§4.7](#47-ground--neutral-hazard-and-blessed), [§2.4](#24-effect-timing-reference))
> - **Collision** (pushed or pulled into a prop, a monster or the board edge): 1; 2 for the moved monster at a `spiky` prop ([§6.3](#63-collision))
> - **Prop aftermath** (Clay Urn, Bamboo Stand): 1 (§4.10)
> - **Dragon Vein and surrounding:** 1 each at the end of a round ([§4.2](#42-dragon-veins-surrounding-and-late-round-pressure)); no source reduces them
> - **Zones never deal damage.** Nothing but a Strike deals damage the instant it is used

**Fair damage at range** *(user decision 2026-11-13)*: damage from a distance never hits a monster that has had no turn of its own since the cast. This holds by construction: at range a skill can only create ground, and ground acts when a monster enters or leaves it, at the end of that monster's own turn, or at the end of the round, when every monster has had its turn.

**Damage modifiers** *(user decision 2026-11-10)*:
- **One calculation:** damage = base + all applicable increases − all applicable reductions, summed in one step, then floored at 0. Order-independent; several sources add. Each source modifies only the damage kinds it names (passives: [Skills §9](gdd_skills.md#9-passives)).
- **Zero damage still hits:** a Strike reduced to 0 damage still applies its push and what it creates.
- **Ceilings apply to the base only** *(user decision 2026-11-11)*: the maxima above limit the base damage; no source of increases exists in the game.
- **Same moment, net:** damage and healing from ground at the same moment resolve together: HP = min(max HP, HP − damage + healing).
- **Survive effect** (tamer skill Life Thread): the first time the protected monster would fall, from any damage source, its HP becomes 1 and the effect is consumed; further simultaneous damage of that step changes nothing; later lethal damage defeats it normally.
- No defense stat exists; damage is reduced only by passives that say so. All damage is exact and previewed.

### 6.2 Payload Resolution

**A payload** is what one use of a skill does at once: a Strike, or the things a skill creates. Its steps always resolve in this order *(user decision)*:

1. **Damage** to all struck monsters and props simultaneously.
2. **Defeat:** units reduced to 0 HP are removed before anything else resolves, so they are neither displaced nor affected by later steps.
3. **Displacement** (push or pull) of the survivors, one unit at a time, **the unit furthest along the movement direction first** (for a pull: nearest the anchor first), so units in a line do not block each other needlessly. Collision, leaving and entry effects fire at the moment of each move ([§6.3](#63-collision), [§2.4](#24-effect-timing-reference)).
4. **Board changes**, in fixed order: (a) **removals**: every prop at 0 HP is removed with its aftermath (damage, push or pull, spawn; [§4.10](#410-prop-catalogue-and-damage)), aftermath damage on one monster adds, and monsters reduced to 0 HP are then defeated; (b) **prop placement**; (c) **ground**: what destroyed props leave, then what the skill creates; (d) **zones** the skill creates. What a payload creates therefore lands after its displacement: a monster pushed by a Strike does not end in the ground that Strike leaves unless it stands there afterwards.
5. **Self retreat** of a Strike that has one ([Skills §8](gdd_skills.md#8-strikes-and-movement)), on the resulting board.

- **Legality at execution:** each square is checked on the board as it stands at that step: a prop is not placed on an occupied square, and Voidscar and Dragon Veins take no ground. A square that is not legal does nothing; everything else resolves. No retargeting and no refund of AP.
- **Same square, same step:** competing changes resolve one after another in initiative-queue order of their sources; the same hazard gains a level (max II), different ground replaces, a second prop on an occupied square does nothing.
- **Ties in displacement** *(user decision 2026-11-10)*: units competing for one destination square, or equally far along different directions, resolve in their current initiative-queue order; the later one collides.
- **The battle-end check** follows each fully resolved payload ([§2.1](#21-core-battle-loop)).

### 6.3 Collision

- Pushed or pulled into a **prop**: no move, 1 damage to the monster (2 at a `spiky` prop, [§4.9](#49-props)) and 1 to the prop (heavy props take none)
- Into a **monster**: no move, **1 damage to each of the two monsters** · against the **board edge**: no move, **1 damage** to the pushed or pulled monster *(working draft, user direction 2026-11-12: the space beyond the board is void)*
- **Collision contract** *(user decision)*: collision damage is derived, not part of a skill, and grants no bonus. Passives that name it change only the damage of the monster they belong to.
- **A blocked move is no movement:** the monster does not leave its square, so ground that acts on leaving (Binding Vines) does not act.
- **2×2 displacement** *(user decision 2026-11-10)*: a push or pull moves the whole body one square; if any newly covered square is blocked, there is **one collision** and no move: the 2×2 takes 1 damage once, and each blocking monster and each blocking prop takes 1 (heavy props none).
- **Prop destroyed**: its aftermath resolves in the removal step ([§6.2](#62-payload-resolution)).
- There is no fall and no collapse damage (no height).

### 6.4 Displacement

- **Cardinal, one square per trigger**, with previewed landing. Being pushed or pulled **is movement**: the monster leaves its square and enters the next one, with every ground effect of both (§4.7), and it takes a Dragon Vein it is moved onto (§4.2).
- **Sources:** every Strike pushes the struck monster 1 square away from the striker *(build rule 2026-11-12)*; a push zone moves in its direction, a pull zone toward its anchor (§4.6); some movement skills push on landing ([Skills §8](gdd_skills.md#8-strikes-and-movement)); a destroyed Bronze Gong or Vortex Urn and the Storm Drum (§4.10).
- **Pull on an exact diagonal** *(user decision 2026-11-10)*: if the anchor lies exactly diagonally from the target (`|dx| = |dy|`), there is no unique cardinal direction and the pull does not move the target.
- Blocked moves: [§6.3](#63-collision). Passives may make a monster immovable ([Skills §9](gdd_skills.md#9-passives)).

**Why zones move at the end of the turn:** at turn start the target could simply walk away again; at turn end it lands in Lava, through Thornbed, off its Binding Vines or in front of your Strike. Visible counterplay: do not end your turn in a current.

---

## 7. Technical & Prototype

### 7.1 Technical Notes (Battle)

**Current design requirements (not an implementation-completeness claim):**

- Godot 4 · **3D square grid, orthogonal camera ~45°** — never hex. Art pipeline: low-poly Blender + AI textures
- Content is data: one Resource file per monster, skill, ground, zone and prop ([Skills §7](gdd_skills.md#7-data-and-validation))
- Battle logic stays headless and engine-independent; runtime state: [§4.4](#44-square-data-model)
- Preview, AI and resolution share the same deterministic rules and show what a skill creates and where every displaced monster lands

**Dragon Vein implementation boundary:** round-end resolution reads actual Dragon Vein ground cells, not a fixed list of generated positions. Normal 3v3 generation still places the three centre-row veins of §4.1; a single central vein is a tested candidate, not an adopted default. Simulation-only skills/props and push/pull-zone AP overrides likewise change no GDD rule or active content.

**Implementation status (not a design source):** `godot/battle` implements this document with unvalidated test content; its layout, extension points, test switches and the commands for its automated checks are in [godot/README.md](../godot/README.md). **The code for the removed mechanics** (height, air layer, Surges and traps) is still in the battle core and unused by the game; removing it is part of T40. Readings the code had to choose and its other open points: [Implementation](temp_todo.md#implementation). The implementation approves no draft value.

### 7.2 Prototype & Playtests

**Builds:**

- `godot/`: main menu → draft sandbox (1, 2 or 3 monsters from the current in-game content, reference kits in [Skills §10](gdd_skills.md#10-kits-of-the-nine-monsters), optional test loadout) → placement → **1v1 on 5×5**, **2v2 on 6×6** or **3v3 on 7×7** against an AI team drawn from the rest; the overworld starts battles through the same request. Its **Monster builder** creates or changes monsters (stats, Kin, kit) and leads to the skill builder for new skills ([Skills §7](gdd_skills.md#7-data-and-validation)). Menu → Overview exposes the content and its status; `approved`, `draft` and `experiment` content is available in-game, while `test`, `simulation` and `archived` content is excluded. Content status is not gameplay or balance validation.
- `tools/html_prototype/battle-prototype-v5-zones-ground.html` is the historical v5 reference and validates nothing of the current design.

**Tools:**

- `godot/tests/`: gdUnit4 suites; `tests/battle` checks rules, resolution order and determinism with concrete expected results.
- `godot/tools/sim.gd`: bot-versus-bot batch runs with win rates per monster, per stat value, per skill and per skill part; results: [simulation_log.md](simulation_log.md).
- `godot/tools/smoke_ui.gd`: plays the player's side through the real UI headless.

**First human play and feedback have occurred; systematic gameplay and balance validation remain open.** Bot runs and automated regression checks do not establish human agency, fun, fairness or balanced prices. Candidate map, skill and AP-cost variants are not adopted rules or content. Playtest planning and outstanding checks: [temp_todo.md](temp_todo.md), T13/T40.

---

## 8. Design Tracking

Open decisions/playtest checks: [temp_todo.md](temp_todo.md). This GDD records the current working design; moving review tasks does not finalize provisional values.
