# GDD — BATTLE SYSTEM
*Working Draft v6.0 (in discussion) — Options, not luck · companion file: gdd_overworld.md · playable reference: battle-prototype-v5-zones-ground.html (v5.0, does not include v6 changes yet)*

> **What changes in v6.0 (draft, not built yet):** playtests of the Godot port showed the v5 loop is not fun yet: the Surge is the only damage source and is easy to dodge on 5×5, props are just obstacles, and Elevated is a blanket "Surge immune" rule. v6 stays **fully deterministic** but gives more ways to deal damage and to shape the board:
> - **Surge aftermath:** struck squares keep a weaker **residue** for 2 rounds (1 damage at end of turn) — dodging alone is no longer free.
> - **Surge types by aspect:** Force = **Eruption**, Nature = **Flood**, Dark = **Rift**. Each type has its own residue and its own rule for props and Elevated ground.
> - **Strike:** a small direct attack against an adjacent monster or prop (2 AP, max 2 damage), flavoured by Kin.
> - **Directional displacement:** the caster sets the push direction / pull point; currents fire at the **end of the occupant's turn**, so they feed into Surges and hazards.
> - **Props have tags** (flammable, brittle, heavy, indestructible) and a reaction table; zones may be placed on props.
> - **Zones change ground** through a (small) reaction table.
> - **Elevated** no longer blocks every Surge — it depends on the Surge type.
> - **AP rework (proposal):** no cooldowns; actions may be repeated as long as AP last; Strike costs 2 AP.
>
> v6 changes are marked **(v6)** below. Numbers are starting values for the next playtest. Open points are collected in §18.

> **What changed in v5.0 (previous version):** v4 deleted zones; v5 brings them back with a clean split. **Zones** are timed (2 rounds), one per square, and do **movement and tempo control** (slow, push/pull, initiative/range drain, shield). **Ground** is permanent and does **damage terrain** (Lava) plus the board's memory (Elevated, Rubble, Voidscar, **attunement**). The **Surge** is a pending marker with its own slot (it uses the same shapes and placement as zones, but never merges with them): it deals damage first, then **repaints** the ground it hit. So a Surge changes the board twice — damage now, ground afterwards.
>
> v3.1 problems fixed: zones no longer merge into misleading hybrids (one zone per square; opposed zones cancel, the same zone levels up, anything else replaces), and attunement is now explained as *ground*, not a hidden zone modifier. Kept: tetris shapes, no Dispel, Surge is the only big burst, props/shatter, 2 AP.

---

## 1. Overview

Turn-based, isometric monster battles about **grid control**, fully deterministic and readable. Inspired by *Into the Breach*.

**Battle modes:** 1v1 on **5x5** (default; tetris shapes need room — 4x4 stays viable for tiny arenas) → 2v2 / 3v3 on larger boards (unlocked via progression).

Setting, progression, economy, overworld: see **gdd_overworld.md**.

---

## 2. Battle Design Pillars

1. **Control squares, not just units** — every skill claims several squares in a tetris shape; the board is the weapon
2. **Deterministic & readable** — before confirming, the player sees exactly which squares each cast takes, merges with, cuts or loses
3. **Everything reacts, nothing deletes** — no delete button. Opposed zones cancel (Bog ↔ Gale), the same zone levels up, anything else replaces. **(v6)** Zones also change ground and props through small, data-driven reaction tables (Bog cools Lava, Gale clears Rubble, fire burns Trees). Nobody is ever locked out by their aspect
4. **The Surge is the burst** — big damage (3+) only comes from a declared, charging, autonomous Surge. **(v6)** Small damage comes from Strikes (adjacent, max 2), residues and hazards (max 2 per tick), collisions and debris (1). Zones never deal damage themselves
5. **Every threat has a real answer** — leave, put a Veil zone over it, change the ground under it, pick the right height for that Surge type, block with props, answer with your own Surge
6. **(v6) Options, not luck** — fully deterministic and fully visible. Variety comes from many meaningful choices per turn (where to stand, which threat to create, which reaction to trigger), never from dice or hidden information
7. **Low HP, high stakes** — one mistake can be fatal
8. **Dynamic battlefields** — ground and props are resources; squares remember what happened on them, and Surges rewrite them
9. **Archetypes over uniques** — 16 skill archetypes × 3 aspects × parameters; uniques for special monsters

---

## 3. Core Battle Loop

1. Battlefield generated (ground, props, contested high ground)
2. Pre-battle: draft monster(s), apply pills / arrays
3. **Each round:** turn order = effective initiative, highest first (zones can drain initiative, so the order can flip)
4. **On a monster's turn:**
   1. start-of-turn effects fire (Voidscar)
   2. spend **2 AP** (Move / Strike / cast a zone or terrain / declare a Surge) — **(v6)** actions may repeat, no cooldowns (§4.4)
   3. **(v6)** end-of-turn zone displacement fires (push / pull, §12) — the monster may land on a hazard or in a Surge
   4. end-of-turn ground effects fire on the square it now stands on (Lava burn, **(v6)** Surge residue)
   5. any Surge due on this boundary **detonates**, leaves its residue and repaints the ground it hit
5. Round ends → zones and residues tick down (a fading zone repaints its squares), late-game Voidscar spreads, initiative recalculated
6. Battle ends when one side has no monsters left

---

## 4. Monsters

### 4.1 Monster Sheet

```
NAME | Size (1x1 / 2x2)
──────────────────────────────────
Kin           Beast | Winged | Scaled | Swarm | Spirit | Ancient
Aspect        Force | Nature | Dark
Rarity        Normal | Rare | Epic | Legendary
Stage         Qi Gathering ... Sovereign (capped by player stage)

HP            1–10
Initiative    0.1–10.0
Movement      squares per move action
TurnsPerRound 1–3

SKILLS: 1 Surge + 1 Zone or Terrain skill + 1 Passive
```

### 4.2 Stats

| Stat | Range | Function |
|---|---|---|
| HP | 1–10 | No defense stat — dead is dead |
| Initiative | 0.1–10.0 | Highest acts first each round; **zones can drain it** |
| Movement | int | Squares per Move action; zones can slow it |
| Skill range | derived | Base per skill; **+1 on Elevated ground; zones can drain it** |
| TurnsPerRound | 1–3 | Extra turns re-enter queue at reduced initiative |
| Aspect | F/N/D | Triangle position, Surge flavor |
| Kin / Rarity / Size | — | see §6 and gdd_overworld |

Stat ceilings per stage: HP 4/6/8/10, Init 5/7/9/10, TPR 1/2/2/3, Move 3/3/4/4.

**Effective stats** = base + modifiers from the zone on the square the monster currently stands on (plus Lava's burn). Only one zone per square, so modifiers never stack in a pile — a square tells you exactly what it does.

### 4.3 Initiative Rules

- Highest effective initiative acts first each round; **recalculated every round**
- A drain zone (e.g. Mire: −2 init) can flip turn order, giving the opponent two turns back to back at the round boundary — a real tempo weapon, and the reason initiative matters in 1v1
- Multi-turn monsters re-enter the queue at reduced initiative after each extra turn
- A Surge's clock is "end of the opponent's next turn", so it stays fair whatever the order does

### 4.4 Action Points

```
2 AP per turn · Move = 1 AP · cast a zone or terrain / declare a Surge = 1 AP · Self skills may cost 0
(v6) Strike = 2 AP (the whole turn)
```

**(v6) No cooldowns (proposal).** Any action may be used again in the same turn as long as AP last (Move + Move, Bog + Bog, Lava Field + Raise Ground ...). The limiters are AP, the board, and one hard rule: **one charging Surge per monster** (see §18 "Double Surge"). Removing cooldowns turns a turn into a real choice between *repositioning*, *setting up* and *attacking*, instead of "whatever is off cooldown".

**(v6) Why Strike costs 2 AP:** a Strike can't be combined with a Move, so you must already stand next to the target at the start of your turn — usually because a pull or the enemy's own position put it there. Hitting is a reward for board control, not something you can always do.

### 4.5 Monster Identity — The 6 Axes

```
1. STAT SHAPE   glass cannon / anvil / skirmisher / berserker
2. ASPECT       Force / Nature / Dark → Surge flavour, zone family, the colour it paints
3. KIN          creature type → Surge scale access, layer, stat lean
4. SURGE        its one burst threat: shape, size, aspect
5. PASSIVE      the rule-bender — biggest personality driver
6. SIZE         1x1 vs 2x2
```

**Design test:** one sentence per monster built from its Surge + its Zone skill. If two monsters read the same, change the shape family, the aspect or the zone's tag set.

| Shape | HP | Init | TPR | Move | Feel |
|---|---|---|---|---|---|
| Glass cannon | 2 | 9.0 | 2 | 3 | commits fast, dies if its Surge is cut away |
| Anvil | 8 | 2.0 | 1 | 1 | slow, hard to dislodge |
| Skirmisher | 4 | 6.0 | 1 | 4 | never in its own Surge when it fires |
| Berserker | 5 | 7.0 | 3 | 2 | escalates one Surge with Empower |

---

## 5. Aspects (The Triangle)

```
        FORCE
       ↗     ↘
    DARK  ←  NATURE
```
**Force beats Nature · Nature beats Dark · Dark beats Force**

| Aspect | Identity | Typical zones / ground | Surge type **(v6)** | Surge flavour |
|---|---|---|---|---|
| **Force** | aggression, heat | Lava (ground, burn) | **Eruption** | paints squares Force (Scorched) |
| **Nature** | growth, flow | Bog, Gale, Bark Veil | **Flood** | paints squares Nature (Overgrown) |
| **Dark** | corruption, drain | Mire, Shade Veil | **Rift** | paints squares Dark (Cursed) |

The Surge type decides the residue, the effect on props and the effect on Elevated ground (§9.3).

### 5.1 Where aspect matters (v5)

Aspect lives in two places only:

1. **On skills and zones** — each carries an aspect, which is what the zone/Surge repaints with.
2. **On squares as attunement** (§7.6) — neutral at the start of every battle. The rule is the same for zones and Surges: **+1 on squares of the skill's own aspect, −1 on squares of the aspect that beats it** (min 1 for zone values, min 0 for damage).

Nothing is locked out: attunement only nudges by ±1 and can always be repainted. Fights between zones are **not** aspect checks — they're simple rules (opposed cancels, same levels up, otherwise replace).

---

## 6. Kins (Monster Grouping)

> **Aspect = what energy a monster wields. Kin = what kind of creature it is.**

Kin maps to **Surge scale access, stat shape, layer** — never to damage multipliers. There is only ONE weakness system (the triangle).

| Kin | Body fantasy | Layer/Movement | Stat lean | Surge access | Locked out of |
|---|---|---|---|---|---|
| **Beast** | tiger, ape, wolf | ground, high move | balanced/skirmisher | Minor Surge only | Major Surge, Sanctify |
| **Winged** | bird, moth, wyvern | **air** (Soul+), move 3+ | glass cannon | Minor only, **immune to ground-anchored Surges while airborne** | RaiseProp, Major Surge |
| **Scaled** | serpent, turtle, drake | ground, low move | anvil | Minor, strong Raise Prop synergy | Reposition |
| **Swarm** | insects, rats | ground, move 2 | fragile, TPR 2+ | Minor, smaller shape (2 cells) | Major Surge, Relocate |
| **Spirit** | ghost, wisp | ground, phasing | low HP, high init | Minor, best Hex/Veil access | Raise Prop |
| **Ancient** | golem, treant | ground, move 1 | max HP, TPR 1 | **only Kin with Major Surge** | Reposition, Air |

### 6.1 Strike by Kin (v6)

Every monster has a **Strike** (§9.4 #16): target = an orthogonally adjacent monster or prop, **2 AP**, max 2 damage. Kin gives it a twist, never more damage than 2:

| Kin | Strike | Effect |
|---|---|---|
| Beast | Bite | 2 damage |
| Winged | Dive | 1 damage, then move 1 square away for free |
| Scaled | Tail Sweep | 1 damage, push the target 1 square (direction chosen) |
| Swarm | Gnaw | 1 damage, props take double (2) |
| Spirit | Siphon | 1 damage, target −1 initiative next round |
| Ancient | Slam | 2 damage to a prop or 1 to a monster, cracks Elevated under the target → Rubble |

**Kin × Aspect grid (launch roster ≈ 15 of 18):**

```
         Force            Nature           Dark
Beast    Blaze Tiger      Vine Panther     Gloom Wolf
Winged   Ember Hawk       Gale Crane       Dusk Moth
Scaled   Magma Drake      Moss Turtle      Hollow Serpent
Swarm    Cinder Wasps     Thorn Mites      Grave Rats
Spirit   War Echo         Grove Wisp       Wailing Shade
Ancient  Forge Golem      Elder Treant     Bone Colossus
```

---

## 7. The Square Stack: Zones & Ground

```
[ AIR    ]  flying prop | flying monster | empty — immune to ground Surges
[ OBJECT ]  prop with tags (Tree: flammable · Wall: brittle · Rock: heavy · Pillar: indestructible) | empty
[ SURGE  ]  pending Surge marker (timer) | empty — shares shapes/placement with zones, never merges with them
[ ZONE   ]  ONE timed zone (2 rounds) | empty — movement & tempo control
[ GROUND ]  Plain | Rubble | Voidscar | Lava (lvl I–II)   +  height (Low | Elevated)   +  ATTUNEMENT (neutral | F | N | D)
            + (v6) RESIDUE (Embers | Mud | Blight, 2 rounds) — left by a fired Surge
```

**Rules:** all layers can be active at once · **1 object, 1 pending Surge, 1 zone, 1 residue** per square · **(v6)** zones may be placed on prop squares (the zone affects the prop only through the reaction table §8.2; a monster can't stand there anyway) · ground skills that create ground (Lava Field, Raise Ground) still need prop-free squares, except for the prop reactions in §8.2 (Lava Field on a Tree ignites it instead of laying Lava) · a pending Surge blocks movement like a temporary object and may land on props · **zones = what you do to movement; ground = what the board remembers.**

### 7.1 Square Data Model

```json
{
  "pos": [2,1],
  "ground": {
    "type": "lava",          // plain | rubble | voidscar | lava
    "level": 1,              // lava only (1–2) = burn damage
    "height": 0,             // 0 low | 1 Elevated (independent of type)
    "attunement": "f",       // null | "f" | "n" | "d"   — see §7.6
    "residue": { "type": "embers", "rounds": 2 }   // (v6) null | embers | mud | blight
  },
  "object": { "name": "Tree", "hp": 2, "tags": ["flammable"] },
  "air": null,
  "surge": { "owner":"wolf", "aspect":"d", "name":"Gloom Surge", "value":3, "fire_after":"tiger", "gid":"g78" },
  "zone": {
    "def": "bog",            // zone definition id (aspect + effect list live there)
    "gid": "g77",            // patch id: all cells of one cast (push/pull centre)
    "owner": "tiger",
    "level": 1,              // 1–3
    "duration": 2,           // rounds left
    "dir": [1,0]             // (v6) push direction chosen at cast (Current); pull uses the anchor cell
  }
}
```

Zone definitions are data: `"bog": { "aspect":"n", "effects":[ {"tag":"slow","base":1,"cap":2}, {"tag":"pull","base":1,"cap":1} ] }`. **Effective value** = `min(cap, base + level − 1) ± attunement`, min 1 (slow capped at 2; push/pull always 1). Values are computed live, so attunement changes show immediately.

### 7.2 Lifecycles

| Thing | Clock | Notes |
|---|---|---|
| **Zone** | 2 rounds, ticks at round end | on expiry the square is **repainted** with the zone's aspect |
| **Pending Surge** | fires once at the end of the opponent's next turn | then removed; **repaints** the squares it struck and leaves a **residue** (v6) |
| **Residue (v6)** | 2 rounds, ticks at round end | 1 damage at the end of the occupant's turn + type effect (§9.3); a new Surge on the square replaces it |
| **Ground** | none — stays until changed | changed by Raise Ground (cleanse), Bog on Lava (→ Rubble), Lava Field, shattered props, debris, Voidscar |

**Principle:** *zones are temporary control, ground is the board's memory.* One clock per zone — effects never carry their own timers.

### 7.3 Zone Rules (one per square)

When a zone lands on a square that already holds one:

| Existing zone | Result |
|---|---|
| none | **new** |
| **same zone** | **levels up** (max III) and refreshes to 2 rounds; the patch id becomes the new cast |
| **opposed** (pairs: **Bog ↔ Gale**) | both **cancel** — the square is empty |
| anything else | **replaced** (level I) |

There is no merging, so a square always shows exactly one zone with its real effects. *(Opposed pairs are a data table; add e.g. Haste ↔ Slow, Mend ↔ Burn-zone later.)*

**Zone × Ground reactions** — **(v6)** extended; each zone has at most 2 reactions so it stays readable. Reactions happen when the zone is cast. Reactions are data (`zone_def.reactions`).

| Zone | on Lava | on Rubble | on Residue | on Elevated |
|---|---|---|---|---|
| **Bog** (N) | cools → Rubble | — | Embers → extinguished | — |
| **Gale** (N) | fans → one level hotter (max II) | blows it away → Plain | — | — |
| **Mire** (D) | — | — | Mud → Blight | — |
| **Veils** | — | — | — | — |

Lava Field cast on Lava → hotter (II). *(Idea for later: Mire on Plain leaves Blight when it fades.)*

### 7.4 Effect Tags (the vocabulary)

| Tag | Where | Trigger | Action |
|---|---|---|---|
| `slow` | zone | while inside | Move −value |
| `drain_init` | zone | while inside | initiative −value (turn order!) |
| `drain_range` | zone | while inside | skill range −value |
| `pull` | zone | **(v6) end of your turn** | move 1 toward the cast's **anchor** square (chosen by the caster) |
| `push` | zone | **(v6) end of your turn** | move 1 in the **direction set at cast** (into a prop = 1 collision damage to both) |
| `shield` | zone (Veil) | on Surge detonation | cuts Surge damage on this square by `value` |
| `burn` | **ground** (Lava) | end of your turn | damage `level` if you **end your turn** here |
| `residue` | **ground** (v6) | end of your turn | 1 damage + type effect (Embers / Mud / Blight) |

Reserved: `haste`, `mend`. Effects hit **everyone** on the square, including the caster.

### 7.5 Ground

| Ground | Effect |
|---|---|
| **Plain** | move cost 1 |
| **Rubble** | move cost 2; neutral (no attunement); left by destroyed props, collapsed Elevated, and cooled Lava |
| **Voidscar** | permanent, spreads late-game (§13.1); 1 damage at turn start; no zone attunement |
| **Lava** (Lava Field, Force) | burn I = 1, II = 2 (end of your turn); permanent until changed: **Bog cools → Rubble**, **Raise Ground cleanses**, Lava Field recast = II. Attuned Force |
| **Elevated** (height) | **(v6)** effect on Surges depends on the type: Flood can't reach it, Rift collapses it, Eruption hits but leaves no residue (§9.3). +1 skill range for the unit there; **climbing up costs 2 movement**; **pushed off Elevated → 1 fall damage**; collapses to Rubble from debris. Neutral; can be raised under a charging Surge; cleanses Lava and attunement |

*Later damage terrain per aspect (family × aspect):* Lava (F) / Thornbed (N) / Blight (D) — same pattern, different aspect and secondary effect.

### 7.6 Attunement (the board's memory)

Every square has an **attunement**: neutral at the start, later Force / Nature / Dark.

| Event | Effect |
|---|---|
| A **Surge fires** on a square | square → the Surge's aspect |
| A **zone fades** | its squares → the zone's aspect |
| Lava is laid | square → Force |
| **Raise Ground**, prop destroyed (Rubble), Elevated collapse | square → neutral |
| Voidscar / Rubble / Elevated | cannot hold attunement |

**Strength rule** (live, per square): a zone or Surge is **+1** on squares of **its own aspect**, **−1** on squares of the **aspect that beats it**, 0 otherwise (Force > Nature > Dark > Force). Zone values never drop below 1; Surge damage never below 0.

**Why it works:** the board starts neutral so no monster is born disadvantaged. The *Surge is the main painter*: you deal damage, then your colour is left behind and strengthens your next zones and Surges there. The enemy repaints by firing Surges onto your territory. Display: a coloured strip with the name (Scorched / Overgrown / Cursed) on every attuned square.

### 7.7 Shapes (tetris)

Every non-Move skill controls **several squares in a fixed shape family**:

| Family | Cells | Orientations (incl. mirror) |
|---|---|---|
| I2 | 2 | 2 |
| I3 | 3 | 2 |
| L3 | 3 | 4 |
| O4 | 4 | 1 |
| T4 | 4 | 4 |
| S4 / Z4 | 4 | 4 |
| L4 / J4 | 4 | 8 |

A skill lists the families it may use (e.g. Surge: I3/L3; Lava Field: O4/T4/S4/L4; Gale: I3). Rotate (`R` / right-click) and place by the **anchor** — the shape's centre-most cell — which must be within range (Manhattan, base + Elevated bonus − drains). All cells on the board; zones and ground skills need prop-free squares; props need empty squares; Surges may land on props. The cast preview colours each square (**new / levels up / replaces / cancels / blocked**) and lists attunement strength (+1/−1 counts), reactions (cools / fans Lava) and, for Surges, damage after ground and Veils.

---

## 8. Props

```
SOLID   → cannot enter (wall, rock, tree, pillar)
FIELD   → enterable, applies effect (shrine, sigil, bramble)
FLYING  → air layer only (storm cloud, void rift)
```

### 8.1 Surge Interaction & Shatter

A Surge square that contains a prop deals **2 damage to the prop and does not hit a monster there** (props can't be occupied). If the prop's HP reaches 0 it **shatters**: Rubble replaces the ground (neutral, no Lava), and **1 debris damage lands on the four neighbouring squares** (also collapsing Elevated neighbours to Rubble). **(v6)** Props can also be destroyed by Strikes (§6.1), by collisions (1 damage to the prop as well) and by reactions (§8.2).

| Prop | HP | Tags (v6) | Notes |
|---|---|---|---|
| Wall | 2 | brittle | shatters into debris; Rift/Blight crumble it |
| Tree | 2 | flammable | burns (see §8.2); destroyed outright |
| Rock | 3 | heavy | can't be pushed or moved by Flood; survives one Surge at 1 HP |
| Pillar | — | indestructible | anchor (rare), nothing removes it |
| Shrine / Sigil / Bramble | — | effect props | as before |

### 8.2 Prop Reactions (v6)

Props stop being "just in the way": each tag reacts to a few aspect sources. Reactions are data (`prop_def.reactions`) and are shown in the cast preview.

| Tag | Force (Lava Field, Eruption, Embers) | Nature (Bog, Gale, Flood) | Dark (Mire, Rift, Blight) |
|---|---|---|---|
| **flammable** (Tree) | **ignites** (Lava Field cast on it, Eruption, Embers): burns down at round end → Rubble + Embers on its square | Bark Veil on it: +1 HP (max 3) | — |
| **brittle** (Wall) | — | — | Rift / Blight: −1 HP per round (crumbles) |
| **heavy** (Rock) | — | Flood can't move it; Flood damage blanked | — |
| **indestructible** (Pillar) | — | — | — |

Zones on a prop square wait there: once the prop is gone, the zone works normally on that square.

**Bank shots:** aim a Surge so that a prop next to the enemy shatters — the debris hits the square beside it even if the enemy dodged out of the footprint. **A Wall you raise beside yourself will hurt you if a Surge breaks it.**

---

## 9. Skills

### 9.1 Skill Types

```
SURGE    → the burst damage; deals damage, then repaints the ground. One per monster.
ZONE     → timed movement/tempo control (2 rounds): Snare, Current, Hex, Veil
TERRAIN  → writes the ground/object layers: Lava Field, Raise Ground (Elevated), Raise Prop (Wall), Sanctify
SELF     → Reposition, Channel
```

### 9.2 Skill Tiers

ARCHETYPE (~80%) · UNIQUE (~20%) · SIGNATURE (Legendary, usually a Major Surge)

### 9.3 The Surge Archetype

A **Surge is a pending marker with a timer** — same shapes and placement as zones, its own slot, different lifecycle. **It changes the board twice: damage now, ground afterwards.**

```
MINOR SURGE
  shape: I3 or L3 (3 squares) — varies by monster, chosen & rotated at cast
  range: 3 (anchor), +1 on Elevated ground
  charging: visible, blocks movement through its squares
  fires: at the END of the opponent's next turn
  autonomous: not cancelled by displacing / killing the caster
  per-square result: monster → value, +1 on own-aspect squares, −1 on squares of the aspect that beats it, − Veil shield
                      prop → 2 damage, shatters if destroyed (debris), plus the prop reaction (§8.2)
                      Elevated square → depends on the Surge type (table below)
  afterwards: every struck square is REPAINTED in the Surge's aspect (Scorched / Overgrown / Cursed)
              (v6) and gets the type's RESIDUE for 2 rounds
  cost: 1 AP, NO cooldown — limiter is ONE charging Surge per monster
  cannot be placed on squares already holding an enemy's charging Surge (the first claims them)

MAJOR SURGE (Ancient / Legendary Signature only)
  shape: large area (up to half the board), range: long
  cost: 2 AP, once per battle or long cooldown
```

**(v6) Surge types by aspect.** Same lifecycle for all three; they differ in residue, props and height:

| Type | Aspect | Damage | Residue (2 rounds, 1 dmg at end of turn +) | Props | Elevated |
|---|---|---|---|---|---|
| **Eruption** | Force | 3 | **Embers**: ignites flammable props | Trees ignite | hit normally, **no residue** there (lava runs off) |
| **Flood** | Nature | 2 | **Mud**: move −1 while inside | pushes struck monsters 1 square in the direction set at cast; extinguishes Lava → Rubble; heavy props block it | **can't reach it** (square blanked) |
| **Rift** | Dark | 3 | **Blight**: initiative −1 while inside | brittle props crumble (−1 HP per round) | **collapses** to Rubble, the monster on it still takes damage |

So Elevated is a real decision: high ground is safe against a Flood, normal against an Eruption, and a trap against a Rift.

**The Surge counter menu** (a Surge with fewer than 3 live counters isn't finished):

| Counter | How |
|---|---|
| **Leave** | Move out of its squares before it fires |
| **Veil it** | A Veil zone (Bark / Shade) over its squares: shield 2 (+/- attunement, up to 3 with level) cuts damage 1:1 per square; stack by recasting to level up |
| **Raise Ground** | Elevate a square — **(v6)** blanks a Flood, no residue from an Eruption, useless against a Rift |
| **Re-attune** | change the square's colour before it fires: remove the Surge's +1, or give it a hostile −1 |
| **Fly over it** | Air layer immune to ground Surges |
| **Props / debris** | Use props to soak squares — but remember the shatter hits next to them |
| **Answer with your own Surge** | race it — but you can't claim squares already held by an enemy's charging Surge |
| **Control the tempo** | Mire / Bog / Gale to steer where the target can stand |

### 9.4 The 16 Archetypes

| # | Archetype | Type | What it does | Parameters |
|---|---|---|---|---|
| 1 | **Surge** | Surge | burst damage, then repaints | shape, size, aspect, scale |
| 2 | **Field** | Terrain (ground) | damage terrain: Lava / Thornbed / Blight | aspect, level cap, shape |
| 3 | **Snare** | Zone | `slow` (+ optional `pull`) | aspect, value, shape |
| 4 | **Current** | Zone | `push` or `pull` conveyor; **(v6)** direction chosen at cast, fires at end of turn | direction mode, shape |
| 5 | **Hex** | Zone | `drain_init` / `drain_range` / `slow` bundle (Mire) | which stats, amount |
| 6 | **Veil** | Zone | `shield` vs Surges (later `mend` / `haste`) | aspect, amount |
| 7 | **Raise Prop** | Terrain | places solid props (Wall) in a shape | prop HP, shape |
| 8 | **Raise Ground** | Terrain | Elevated + cleanses ground | shape |
| 9 | **Sanctify** | Terrain | places an effect prop | effect, HP |
| 10 | **Shove** | Direct | one-time push/pull of a unit | distance, collision dmg |
| 11 | **Reposition** | Self | blink / dash | distance |
| 12 | **Channel** | Self | buff / cleanse / empower next | which |
| 13 | **Ward (self)** | Self | reduce/negate next Surge instance | amount |
| 14 | **Relocate** | Prop | move a prop | which, distance |
| 15 | **Empower** | Amplify | +1 level on **your own** zone or +1 Surge value | boost, own-aspect only |
| 16 | **Strike (v6)** | Direct | adjacent monster or prop, 2 AP, max 2 damage, Kin twist (§6.1) | damage, twist |

*(Removed in v3.0: Dispel, Rupture, Bind, HexField. v4 removed zones entirely; v5 restored them with one-zone-per-square rules instead of merge arithmetic.)*

### 9.5 Kit-Building Rule

```
Monster = 1 Surge
        + 1 Ground skill / Utility from the archetypes above
        + 1 passive
```

**Kit design tip (v5):** pair the Surge with one zone of a *different effect family* (a Veil, a Snare, a Current) so there is always an answer in the kit. Aspects are **flavour + territory**: they decide which squares you paint with Surges and which zones get +1 there.

### 9.6 Sight

Zone, terrain and Surge casts are placed by **range from the caster to the anchor** — no line of sight. Sight remains for ranged single-target utilities (Shove) and Self skills never need it.

### 9.7 Skill Schema

```json
{
  "id": "bog",
  "name": "Bog",
  "type": "Snare",                   // Surge | Snare | Current | Hex | Veil | Terrain | Self
  "kind": "zone",                    // surge | zone | ground | height | prop
  "aspect": "nature",
  "zone": "bog",                     // zone definition id (kind: zone); kind: ground writes Lava
  "shapes": ["I3","L3"],             // allowed tetris families
  "range": 3,                        // anchor range (Manhattan)
  "cost": 1,                         // AP (v6: Strike 2)
  "surge_type": null,                // (v6) eruption | flood | rift — kind: surge only
  "directional": false               // (v6) Current / Flood: caster sets a direction at cast
}
```
**(v6)** `cooldown` is removed (§4.4). **Rules:** only `kind: surge` deals burst damage · ground `burn` (Lava) capped at 2 per tick · zone effect values/caps live on the **zone definition**, not on the skill · every zone must carry ≥1 effect tag · zones last 2 rounds (global constant, tunable).

### 9.8 Unique Skill Examples

Mirror Step · Spatial Rend (remove a square 2 rounds) · Exile · Anchor (square immune to enemy displacement) · Conversion (your ground becomes another aspect) · Inversion (swap two rows' ground) · Mimicry · Devour Prop · Curse of Sight · Gravity Well (pull toward a square) · Twin Surge (Signature).

---

## 10. Passives Library

**Terrain Identity:** Native Ground (your zones and Surges get +2 instead of +1 on own-aspect squares; ignores the −1) · Painter (fired Surges also repaint adjacent squares) · Trailblazer (repaints squares it walks over) · Deep Roots (undisplaceable on own-aspect squares) · Purifier (adjacent enemy zones lose 1 round at round end) · Overgrowth (your zones start at level II)

**Position & Movement:** Highlander (+2 init on Elevated) · Turret (can't move, +1 range) · Skittish (free 1-sq move after taking Surge damage) · Phasing (moves through props) · Momentum (+1 cell to next cast after a max-distance move)

**Displacement:** Crashlander · Immovable (ignores push/pull) · Counterweight

**Combat:** Thick Hide · Frenzy (+1 shape cell at 1–2 HP) · Scavenger · First Blood · Vengeful · Bulwark (team)

**Zone & Ground Resistance:** Sure-footed (ignores `slow`) · Clear Mind (ignores `drain_*`) · Heatproof (ignores `burn`) — the unit-level way of shrugging a specific tag.

---

## 11. Damage System

### 11.1 The Damage Law

> **The Surge is the burst.** It is the only skill that deals more than 2 damage. Lava ticks at most 2 (level II) and only if you **end your turn** on the square. Zones never deal damage. Collision (pushed into a prop) and debris (prop shattered next to you) deal 1. **(v6)** A Strike deals at most 2 and is the only attack whose damage lands the instant it is used — it needs adjacency and the whole turn (2 AP). Residues deal 1 at the end of your turn. Nothing else deals damage the instant it is cast.

### 11.2 Surge Lifecycle

```
1. DECLARE   → shape appears on the board: squares, damage, fire time shown
2. CHARGE    → blocks movement through its squares
3. WAIT      → the defender gets a full turn: leave, cut, Elevate, ...
4. DETONATE  → end of the opponent's next turn, per square:
               Elevated → blanked · prop → 2 dmg, shatter + debris ·
               monster → value ±1 by attunement − Veil shield
               Elevated → by Surge type (§9.3)
               afterwards every struck square is repainted in the Surge's aspect
               and gets the type's residue (v6)
```

**Autonomy:** a Surge is not cancelled by displacing, staggering or killing its caster. Only the counter menu (§9.3) stops it.

### 11.3 Collision & Debris

- Pushed into a prop or the edge: 1 collision damage into a prop, no damage at the edge
- Prop destroyed by a Surge: 1 debris damage to the four neighbouring squares; Elevated neighbours collapse to Rubble

### 11.4 General Rules

- No defense stat — resistances via attunement, Veils and passives
- All damage exact and previewed
- A Surge whose caster died still resolves

| Source | Fires |
|---|---|
| Surge detonation | end of the opponent's next turn |
| Lava burn | end of the occupant's own turn |
| **(v6)** Residue | end of the occupant's own turn |
| **(v6)** Strike | instantly (2 AP, adjacent) |
| Collision / debris | on impact / on shatter |

---

## 12. Displacement

| Type | Mechanic |
|---|---|
| **Zone push (v6)** | at the **end of the occupant's turn**, 1 square in the **direction the caster set at cast** (Current) |
| **Zone pull (v6)** | at the **end of the occupant's turn**, 1 square toward the cast's **anchor** square (the caster places the anchor = picks the pull point) |
| **Shove** | direct, one-time, precise |
| **Strike twist (v6)** | Scaled Tail Sweep pushes 1 (direction chosen) |
| **Flood (v6)** | pushes struck monsters 1 in the direction set at cast |

Always cardinal and one square per trigger; the occupant's landing square is visible in the preview.

**(v6) Blocked moves:** into a prop → 1 collision damage to the monster and 1 to the prop (heavy: the prop takes none) · into a monster → no move, no damage · off the board edge → no move · **off Elevated → the move happens, 1 fall damage** · onto Elevated from below → blocked like a prop, no damage.

**(v6) Why end of turn:** at the start of a turn the target simply walks away again. At the end of its turn it lands where you sent it — in Lava, in a residue, in front of your Strike, or in a Surge that detonates on the same boundary (§14). The counterplay is visible: don't end your turn on a current.

---

## 13. Battlefield Generation

- Procedural ground + props; **two contested Elevated squares near the centre, equidistant from both starts** in the prototype
- Pre-placed props shape the opening; mirrored fairness check for 1v1

### 13.1 Late-Round Pressure (Anti-Stalling)

From round 6, the square farthest from both monsters converts to **Voidscar** each round (permanent, undestroyable).

---

## 14. Effect Timing Reference

| Trigger | When | Examples |
|---|---|---|
| start_of_turn | beginning of the occupant's turn | Voidscar damage (v6: push/pull moved to end of turn) |
| while_inside | continuous modifier | slow, haste, drain_init, drain_range |
| end_of_turn | end of the occupant's turn | **(v6)** 1. push / pull → 2. Lava burn, residue (on the landing square), mend |
| on_timer | end of the opponent's turn | Surge detonation |
| round end | zones and residues −1 round (fading zones repaint their squares), burning props burn down, Voidscar spreads, initiative re-sorted |

Order inside a turn: start effects → AP → end effects (displacement, then hazards) → due Surges (damage, then residue + repaint).

---

## 15. Tamer Skills (Player Influence)

The tamer shapes; monsters fight. Once per battle (or very long cooldown).

| Skill | Effect |
|---|---|
| Spatial Pull | move own monster to any empty square |
| Qi Suppression | enemy −2 initiative next round |
| Spirit Shield | Ward one own monster against the next Surge instance |
| Domain Glimpse | **clear a tetromino of zones and reset its ground to Plain/neutral** (once per battle) |
| Beast Swap | (Soul+) exchange active monster with spatial space |

---

## 16. Technical Notes (Battle)

- Godot 4 · **3D square grid, orthogonal camera ~45°** — never hex
- Battle logic **headless & engine-independent**: 2D array of Square objects; each square stores `{ ground{type,level,height,attunement}, object, surge, zone }`; zone definitions are a data table (aspect + effect list with base/cap), values computed live from level and attunement
- Resolution is deterministic and order-defined (§14); casting is a pure function `preview_cell(skill, cell)` returning `new | level | replace | cancel | lost` (+ zone × ground reactions, **(v6)** prop reactions, residue and landing squares of displacement) — the same function drives the preview, the Wolf AI and the unit tests
- **(v6)** Reaction tables (zone × ground, source × prop tag) and Surge types are data (Resources), not code branches
- A pending Surge is a marker on the square with its own slot (not a zone); it blocks movement like a temporary object and repaints on detonation
- Shape orientations are generated once from base shapes (rotate + mirror, de-duplicated); anchor = cell nearest the centroid
- Art pipeline: low-poly Blender + AI textures

---

## 17. First Playable Prototype

**battle-prototype-v5-zones-ground.html (v5.0)** — 5x5, 1v1, you (Blaze Tiger, Force) vs an AI Gloom Wolf (Dark). Tiger kit: Magma Surge, Lava Field (ground), Bog, Gale, Bark Veil (zones), Raise Wall, Raise Ground. Wolf kit: Gloom Surge, Mire, Shade Veil. The inspector shows the stack (Air / Object / Pending Surge / Zone / Ground); every attuned square carries a coloured name strip; the cast preview shows per-square results. Test:

1. Do **zones steer** the fight (pull a target into a Surge, push it into a prop, Mire flipping initiative) and is Bog↔Gale cancelling readable?
2. Does **Lava as permanent terrain** change where you stand — and do Bog (cools) and Gale (fans) feel like designed answers?
3. Does **Surge → repaint** make territory matter: do you feel the +1/−1 when you cast on your colour or the enemy's?
4. Do Veils make Surges answerable without becoming a new Dispel loop?
5. Is the display honest — one zone, one ground, one attunement per square — and do fights end by round 6–7?

**(v6) Next playtest — what to check once v6 is built:**

1. Does the residue make Surges *land* (the enemy takes 1 even when it dodges, or has to walk around it)?
2. Does end-of-turn displacement with a chosen direction create readable combos (current → Surge, current → Lava, pull → Strike)?
3. Is Strike at 2 AP worth using, or does it never happen? Does it make close range too sticky on 5×5?
4. Do no-cooldown turns create more interesting choices, or does one action get spammed?
5. Do the three Surge types make Elevated a real decision?
6. Do props now get *used* (burned, crumbled, smashed for debris) instead of just being in the way?

**Playtest history (what this replaced):** Godot port of v5 (Surge is the only damage and easy to dodge, props only block, Elevated is a blanket immunity) → **v6 draft** · v4 ground-only (zones deleted: effects became permanent terraforming; clutter risk, and push/pull lost its natural timed role) → **v5 zones + ground**. Before that: v3.1 zones with merge arithmetic (misleading hybrid zones) → v3.0 aspect-triangle overwrites (wrong-aspect monster locked out) → v2.2 square interactions → v2.1 anti-loop tweaks → v2 Surge-only damage → v1 wind-up.

---

## 18. Open Questions (Battle)

**(v6) To decide next:**

- **Double Surge:** without cooldowns, may a monster declare two Surges in one turn (2 AP, up to 6 squares)? Pro: real all-in turn, solves dodging. Contra: likely one-turn kills on 5–6 HP. Current proposal: keep **one charging Surge per monster**
- **Strike cost:** 2 AP (whole turn) or 1 AP but only if you didn't move this turn?
- **Residue numbers:** 1 damage for 2 rounds — too strong together with the Surge, too weak to matter? Should residue damage stack with Lava on the same square (proposal: no, the higher one counts)?
- **First mover:** acting first gives tempo but can't hurt anyone in round 1 (start squares are 8 apart). Keep as is; revisit if Strike/Flood make the opener too strong
- **Pull point:** pull to the anchor (caster chooses) or to any square in the patch?
- **Mud vs. Bog:** Mud (Flood residue) and Bog both slow — distinct enough?
- **Flood push direction:** one direction for the whole Surge (set at cast) or away from the anchor?

- **Surge as the painter:** attunement only changes via fired Surges and fading zones. Is repainting fast enough to claw back territory, or does the first Surge snowball? Optional decay after N rounds?
- **Lava permanence:** it stays until Bog/Raise Ground/Lava Field changes it. Does it clutter the board by round 5? Optional fade, or a cap of N Lava squares per monster?
- **Attunement scale:** ±1 only bites on values ≥2 (zone values clamp at 1). Rescale zone base values?
- **Veil strength:** shield 2 vs Surge 3 (up to 3 with level, ±1 attunement). Too weak (never cast) or a new Dispel loop? Cooldown 2 is the brake
- **Opposed pairs:** only Bog ↔ Gale now. Which others (Haste ↔ Slow, Mend ↔ Burn-zone) and should opposed zones ever leave a remainder?
- **Zone duration:** 2 rounds for everything — should strong zones (Mire) be shorter, weak ones longer?
- **Surge vs Surge:** first Surge claims a square; is declaring *first* too strong in initiative order?
- **Surge size & damage:** 3 squares, dmg 3 (±1). Too easy to dodge on 5x5 with Move 2? Major Surge sizes need tuning
- **Push/pull at patch centre:** I3 push leaves the middle square unmoved — acceptable or push along the axis?
- **Lava on Elevated:** legal (Raise Ground cleanses it, Bog cools it) — does Elevated need to resist Lava?
- **Voidscar:** still needed? Pacing on 5x5
- **Winged's air immunity** and how zones/ground affect air units
- **Major Surge:** cost / cooldown / shape
- **Which Kin × Aspect cells stay empty at launch**
- **Team-mode (2v2/3v3):** Surge timing and zone ownership with multiple opponents
- **Domain Glimpse tuning:** how big, how often
