# GDD — BATTLE SYSTEM
*Working Draft v6.0 — Options, not luck · companion file: gdd_overworld.md · playable reference: Godot project `godot/` (implements **v6**: 3v3 on 7×7, 1v1 duel, draft, 9 monsters) · `html_prototype/battle-prototype-v5-zones-ground.html` is the older v5 reference · see §19 for what changed*

---

## 1. Overview

Turn-based, isometric monster battles about **grid control**, fully deterministic and readable. Inspired by *Into the Breach*.

**Battle modes:**

| Mode | Board | Role |
|---|---|---|
| 1v1 | 5×5 | duel / tutorial, early game |
| 2v2 | 6×6 | step between duel and team battle |
| **3v3** | **7×7** | **standard battle** — enough monsters for combos between allies, short enough for a session |
| 5v5 | 9×9 | special battles only (bosses, tournaments), later |

Modes follow the team size the player can field: 1v1 from the start, **3v3 and 2v2 from Foundation**, 5v5 special battles from Core Formation (gdd_overworld §4.5). The encounter chooses the mode.

**Why 7×7 for 3v3:** 6 monsters on 49 squares is about as crowded as 2 on 25 (1v1), so the pressure stays similar. 8×8 gives each monster more room to step out of a 3–4 cell Surge — exactly the "too easy to dodge" problem. An odd size also has a **centre square** for contested high ground and mirror-fair starts. Small kits (§9.5) keep 3v3–5v5 readable: every monster brings Move + Strike + its Surge + 1–2 utilities, not a skill bar.

Setting, progression, economy, overworld: see **gdd_overworld.md**.

---

## 2. Battle Design Pillars

1. **Control squares, not just units** — every skill claims several squares in a tetris shape; the board is the weapon
2. **Deterministic & readable** — before confirming, the player sees exactly which squares a cast takes, levels up, cancels, replaces or loses, what it does to ground and props, and where every pushed monster lands
3. **Everything reacts, nothing deletes** — no delete button. Zones with **opposite effects** cancel, the same zone levels up, anything else replaces. Zones change ground by the aspect triangle, props react to aspects. All of it is small, data-driven rules. Nobody is ever locked out by their aspect
4. **The Surge is the burst** — big damage (3+) only comes from a declared, charging, autonomous Surge. Small damage comes from Strikes (max 2), aspect ground (max 2 per trigger), collisions, falls and debris (1). Zones never deal damage themselves
5. **Every threat has a real answer** — leave, put a Veil over it, change the ground under it, pick the right height for that Surge type, block with props, answer with your own Surge
6. **Options, not luck** — fully deterministic and fully visible. Variety comes from many meaningful choices per turn (where to stand, which threat to create, which reaction to trigger), never from dice or hidden information
7. **Low HP, high stakes** — one mistake can be fatal
8. **Dynamic battlefields** — ground and props are resources; squares remember what happened on them, and Surges rewrite them
9. **Archetypes over uniques** — 16 skill archetypes × 3 aspects × parameters; uniques for special monsters

---

## 3. Core Battle Loop

1. Battlefield generated (ground, props, contested high ground — §13)
2. Pre-battle: draft monsters, place them in your start area, apply pills / arrays. Monsters start at their **current HP** (never above max; below max after earlier fights of an expedition, gdd_overworld §10.2). An **ambush** (attacking a wild monster from behind) gives the attacker's side a small round-1 initiative bonus (value tuned in playtest, proposed +1)
3. **Each round:** one queue for all monsters of both sides, highest effective initiative first (§4.3)
4. **On a monster's turn:**
   1. its own Surges that are due **fire** (§9.3): damage, then residue, then repaint
   2. start-of-turn ground effects on its square (Voidscar, Blight)
   3. spend **2 AP** (Move / Strike / cast a zone or terrain / declare a Surge) — actions may repeat, no cooldowns (§4.4)
   4. end of turn: zone displacement (push / pull, §12), then end-of-turn ground on the square it now stands on (Lava). *Thornbed fires whenever a monster enters it, including by push / pull*
5. Round ends → zones and timed ground tick down (a fading zone repaints its squares), burning props burn down, late-game Voidscar spreads, initiative recalculated
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
Movement      squares per Move action
Reach         1–3   Strike distance
TurnsPerRound 1–3

SKILLS: Move + Strike + 1 Surge + 1 utility (2 from Foundation) + 1 passive (§9.5)
```

### 4.2 Stats

| Stat | Range | Function |
|---|---|---|
| HP | 1–10 | No defense stat — dead is dead |
| Initiative | 0.1–10.0 | Position in the turn queue; **zones can drain it** |
| Movement | int | Squares per Move action; zones can slow it |
| Skill range | derived | Base per skill; **+1 on Elevated ground; zones can drain it** |
| Reach | 1–3 | Strike distance (Manhattan); +1 on Elevated; `drain_range` lowers it (min 1); Reach ≥ 2 needs line of sight (props block) |
| TurnsPerRound | 1–3 | Extra turns re-enter the queue at −3 initiative per extra turn |
| Aspect | F/N/D | Triangle position, Surge type, zone family |
| Kin / Rarity / Size | — | see §6 and gdd_overworld |

Stat ceilings per stage: HP 4/6/8/10, Init 5/7/9/10, TPR 1/2/2/3, Move 3/3/4/4, Reach 1/2/2/3.

**Every stat is paid for.** The stat shapes (§4.5) spend the same budget in different places: a fast monster acts first and may act several times in a row, so it must have less HP, less Reach or a weaker kit. A slow monster is punished in the turn order and gets that back in HP, Reach or a stronger Surge.

**Effective stats** = base + modifiers from the zone on the square the monster currently stands on (+ Elevated bonus). Only one zone per square, so modifiers never stack in a pile — a square tells you exactly what it does.

### 4.3 Initiative Rules

- **One queue for all monsters of both sides**, strictly by effective initiative, **recalculated every round**
- A side may act several times in a row — that is the reward for initiative, not a bug
- **Ties:** higher base initiative first; still tied → the sides alternate (the first tie of a battle goes to the side with the lower total initiative)
- A drain zone (e.g. Mire: −2 init) can flip the order, giving a monster two turns back to back across the round boundary — a real tempo weapon
- Multi-turn monsters get one extra queue entry per extra turn, each at −3 initiative (min 0.1)
- **Surge clock:** a Surge fires **at the start of its caster's next turn** (§9.3). In 1v1 that is the same moment as "the end of the opponent's turn"; in team battles every other monster has had its turn in between

### 4.4 Action Points

```
2 AP per turn
Move                          1 AP
Cast a zone / terrain skill   1 AP
Declare a Surge               1 AP
Self skills                   1 AP
Strike                        2 AP  (the whole turn)
Major Surge                   2 AP  (once per battle)
```

**Every action costs at least 1 AP.** There are no 0-AP actions.

**No cooldowns.** Any action may be used again in the same turn as long as AP last (Move + Move, Bog + Bog, Lava Field + Raise Ground …). The limiters are AP, the board, and one hard rule: **one charging Surge per monster**. A turn becomes a real choice between *repositioning*, *setting up* and *attacking*, instead of "whatever is off cooldown".

**Why Strike costs 2 AP:** a Strike can't be combined with a Move, so the target must already be within your Reach at the start of your turn — usually because a pull or the enemy's own position put it there. Hitting is a reward for board control, not something you can always do.

### 4.5 Monster Identity — The 6 Axes

```
1. STAT SHAPE   glass cannon / anvil / skirmisher / berserker   (per individual monster, rolled with the Kin's lean — gdd_overworld §4.3)
2. ASPECT       Force / Nature / Dark → Surge TYPE (Eruption / Flood / Rift), zone family, hazard ground, the colour it paints
3. KIN          creature type → Strike, layer, stat lean, which utility archetypes it may take, Surge size access
4. SURGE        its own named burst: type from aspect, shape + size from species, at most ONE twist (§9.4.2)
5. PASSIVE      the rule-bender — biggest personality driver
6. SIZE         1x1 vs 2x2
```

**Three layers build a monster** — nothing is invented from scratch per monster:

| Layer | Decides | Example |
|---|---|---|
| **Kin** (body) | Strike, movement layer, stat lean, allowed utility archetypes, Surge size | Beast bites and is fast; only Ancient has a Major Surge |
| **Aspect** (energy) | Surge type, zone family, hazard ground, attunement colour | Force → Eruption, Lava, Scorched |
| **Species** (the monster) | its Surge (shape + ≤1 twist), 1 utility from the matrix, 1 passive | Blaze Tiger: *Magma Pounce* — O4 Eruption that must land next to the tiger |

**No fixed roles.** A Kin is not a class (Beast ≠ "damage dealer"). What a monster does for a team comes from its kit, so two Beasts can play completely differently. Team building means picking *combinations* — one monster pulls, another one Strikes; one floods the enemy into the other's Eruption.

**Design test:** one sentence per monster built from its Surge + its utility. If two monsters read the same, change the Surge shape or twist, the aspect or the utility.

| Shape | HP | Init | TPR | Move | Reach | Feel |
|---|---|---|---|---|---|---|
| Glass cannon | 2 | 9.0 | 2 | 3 | 1 | commits fast, dies if its Surge is cut away |
| Anvil | 8 | 2.0 | 1 | 1 | 2 | slow, hard to dislodge, threatens a radius it can't leave |
| Skirmisher | 4 | 6.0 | 1 | 4 | 1 | never in its own Surge when it fires |
| Berserker | 5 | 7.0 | 2 *(3 from Soul)* | 2 | 1 | escalates one Surge with Empower; TPR 3 opens with the Soul cap |
| Balanced | 5 | 6.0 | 1 | 2 | 1 | no weakness, no spike — the kit decides |
| Fragile | 3 | 6.0 | 2 | 2 | 1 | weak body, many turns; lives on its Surge |

---

## 5. Aspects (The Triangle)

```
        FORCE
       ↗     ↘
    DARK  ←  NATURE
```
**Force beats Nature · Nature beats Dark · Dark beats Force**

| Aspect | Identity | Hazard ground | Zones (§9.5) | Surge type | Attunement |
|---|---|---|---|---|---|
| **Force** | aggression, heat | Lava | Ash Snare, Shockwave, Glare, Kiln Shell | **Eruption** | Scorched |
| **Nature** | growth, flow | Thornbed | Bog, Gale, Spore Cloud, Bark Veil | **Flood** | Overgrown |
| **Dark** | corruption, drain | Blight | Grasping Shade, Void Pull, Mire, Shade Veil | **Rift** | Cursed |

### 5.1 Where aspect matters

1. **Skills and zones** carry an aspect — the colour a zone or Surge repaints with
2. **Surge type** — Eruption, Flood or Rift (§9.3)
3. **Ground** — each aspect has one hazard ground; zones change ground by the triangle (§7.3)
4. **Attunement** on squares (§7.5) — neutral at the start of every battle. Zones and Surges are **+1 on squares of their own aspect, −1 on squares of the aspect that beats them** (min 1 for zone values, min 0 for damage)

Nothing is locked out: attunement only nudges by ±1 and can always be repainted, and every aspect has a way to replace any ground. Fights between zones are **not** aspect checks — opposite effects cancel, the same zone levels up, otherwise replace.

---

## 6. Kins (Monster Grouping)

> **Aspect = what energy a monster wields. Kin = what kind of creature it is.**

Kin maps to **Strike, Surge size, stat lean, movement layer and allowed utilities** — never to damage multipliers. There is only ONE weakness system (the triangle).

| Kin | Body fantasy | Layer/Movement | Stat lean | Surge access | Locked out of |
|---|---|---|---|---|---|
| **Beast** | tiger, ape, wolf | ground, high move | balanced/skirmisher | Minor | Major Surge, Sanctify |
| **Winged** | bird, moth, wyvern | **air** (Soul+), move 3+ | glass cannon | Minor; **immune to ground-anchored Surges while airborne** | Raise Prop, Major Surge |
| **Scaled** | serpent, turtle, drake | ground, low move | anvil | Minor | Reposition |
| **Swarm** | insects, rats | ground, move 2 | fragile, TPR 2+ | Minor, 2-cell shapes | Major Surge, Relocate |
| **Spirit** | ghost, wisp | ground, **phasing** (moves through props) | low HP, high init | Minor | Raise Prop |
| **Ancient** | golem, treant | ground, move 1 | max HP, TPR 1 | Minor + **only Kin with Major Surge** | Reposition, Air |

### 6.1 Strike by Kin

Every monster has a **Strike** (§9.4 #16): target = an enemy monster or a prop within **Reach** (Manhattan, §4.2; Reach ≥ 2 needs line of sight), **2 AP**, max 2 damage. Kin gives it a twist, never more damage than 2:

| Kin | Strike | Effect |
|---|---|---|
| Beast | Bite | 2 damage |
| Winged | Dive | 1 damage, then move 1 square away for free (the free neighbour farthest from the target) |
| Scaled | Tail Sweep | 1 damage, push the target 1 square (direction chosen with WASD) |
| Swarm | Gnaw | 1 damage, props take double (2) |
| Spirit | Siphon | 1 damage, target −1 initiative next round |
| Ancient | Slam | 2 damage to a prop or 1 to a monster, cracks Elevated under the target → Rubble |

### 6.2 First Roster Draft — 9 monsters, 3 per aspect

The stat shape is a property of the **individual monster** (gdd_overworld §4.3); the shapes below are the **reference individuals** — the typical roll of each species. Numbers are **Core Formation**-stage values (caps: HP 8, Init 9, TPR 2, Move 4, Reach 2 — gdd_overworld §4.6). Every monster also has **Move** and its Kin **Strike** (§6.1). Skills come from the matrix (§9.5); twists from §9.4.2.

| Monster | Kin | Aspect | Shape · HP / Init / Move / TPR / Reach | Surge (type · shape · twist) | Utility | Passive |
|---|---|---|---|---|---|---|
| **Blaze Tiger** | Beast | Force | skirmisher · 5 / 7.0 / 3 / 1 / 1 | *Magma Pounce* · Eruption · O4 · **Pounce** | Lava Field | Momentum |
| **Ember Hawk** | Winged | Force | glass cannon · 2 / 9.0 / 3 / 2 / 1 | *Cinder Dive* · Eruption · I3 · **Trail** | Shockwave | Skittish |
| **Forge Golem** | Ancient | Force | anvil · 8 / 2.0 / 1 / 1 / 2 | *Crucible* · Eruption · ring of 4 · **Ring** | Raise Wall | Immovable |
| **Moss Turtle** | Scaled | Nature | anvil · 8 / 3.0 / 1 / 1 / 2 | *Tidal Shell* · Flood · I3 · **Slow-burn** | Bark Veil | Deep Roots |
| **Thorn Mites** | Swarm | Nature | fragile · 3 / 6.0 / 2 / 2 / 1 | *Bramble Tide* · Flood · I2 · **Lingering** | Thornbed | Thornwalker |
| **Grove Wisp** | Spirit | Nature | skirmisher · 3 / 8.0 / 3 / 1 / 1 | *Spring Burst* · Flood · L3 · **Lob** | Gale | Adaptive |
| **Gloom Wolf** | Beast | Dark | balanced · 5 / 6.0 / 2 / 1 / 1 | *Gloom Rift* · Rift · I3 / L3 · — (baseline) | Mire | Pack Hunter |
| **Dusk Moth** | Winged | Dark | glass cannon · 2 / 9.0 / 3 / 2 / 1 | *Eclipse* · Rift · I3 → 4 cells · **Wide** | Shade Veil | Native Ground |
| **Hollow Serpent** | Scaled | Dark | anvil-ish · 6 / 4.0 / 2 / 1 / 2 | *Coiling Rift* · Rift · L4 · **Constrict** | Void Pull | Thick Hide |

One sentence each (design test):
- **Blaze Tiger** — dives into melee range, lays Lava behind the enemy and pounces with a big Eruption next to itself.
- **Ember Hawk** — strafes a burning line from where it stands, pushes enemies with Shockwave, and dodges away after taking a hit.
- **Forge Golem** — walls itself in and erupts around its own body; you have to come to it.
- **Moss Turtle** — a slow, heavy Flood that hits one turn later but harder, behind Bark Veils, and can't be pushed off its own ground.
- **Thorn Mites** — weak little Floods that leave thorns for 3 rounds, on top of a permanent Thornbed they walk through unharmed.
- **Grove Wisp** — throws weak Floods from far away, phases through props, and is the only one that can turn its shapes in battle.
- **Gloom Wolf** — the baseline: Mire flips the turn order, its Rift does the rest; much stronger with an ally next to the target.
- **Dusk Moth** — a wide, weaker Rift on Cursed squares, under a Shade Veil.
- **Hollow Serpent** — pulls you in with Void Pull, then its Rift drags everything it hits toward the centre.

Gaps on purpose (filled later): Swarm and Spirit in Force/Dark, Ancient in Nature/Dark, Snare/Hex for Force, Raise Ground, Sanctify, Shove, Reposition.

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
[ SURGE  ]  pending Surge marker | empty — shares shapes/placement with zones, never merges with them
[ ZONE   ]  ONE timed zone (2 rounds) | empty — movement & tempo control
[ GROUND ]  type (neutral: Plain | Rubble | Voidscar — aspect: Lava | Thornbed | Blight, lvl I–II, permanent or timed)
            + height (Low | Elevated) + ATTUNEMENT (neutral | F | N | D)
```

**Rules:**
- all layers can be active at once · **1 object, 1 pending Surge, 1 zone, 1 ground type** per square
- zones may be placed on prop squares — the zone affects the prop only through the reaction table (§8.2); a monster can't stand there anyway
- skills that create ground (Field, Raise Ground) need prop-free squares, except for the prop reactions in §8.2 (Lava Field on a Tree ignites it instead of laying Lava)
- a pending Surge blocks *voluntary* movement like a temporary object and may land on props; displacement (push / pull / Flood) **can** move monsters into it — that is the combo
- **zones = what you do to movement; ground = what the board remembers**

### 7.1 Square Data Model

```json
{
  "pos": [2,1],
  "ground": {
    "type": "lava",          // plain | rubble | voidscar | lava | thornbed | blight
    "level": 1,              // aspect grounds only (1–2) = damage per trigger
    "timer": 2,              // null = permanent (Field skill) | rounds left (Surge residue)
    "height": 0,             // 0 low | 1 Elevated (independent of type)
    "attunement": "f"        // null | "f" | "n" | "d"   — see §7.5
  },
  "object": { "name": "Tree", "hp": 2, "tags": ["flammable"], "burning": false },
  "air": null,
  "surge": { "owner":"wolf", "type":"rift", "aspect":"d", "name":"Gloom Rift", "value":3, "turns_left":1, "dir":null, "gid":"g78" },
  "zone": {
    "def": "bog",            // zone definition id (aspect + effect list live there)
    "gid": "g77",            // patch id: all cells of one cast
    "owner": "tiger",
    "level": 1,              // 1–3
    "duration": 2,           // rounds left
    "dir": [1,0],            // push direction chosen at cast
    "anchor": [2,2]          // pull point chosen at cast
  }
}
```

Zone definitions are data: `"bog": { "aspect":"n", "effects":[ {"tag":"slow","base":1,"cap":2}, {"tag":"pull","base":1,"cap":1} ] }`. **Effective value** = `min(cap, base + level − 1) ± attunement`, min 1 (slow capped at 2; push/pull always 1). Values are computed live, so attunement changes show immediately.

### 7.2 Lifecycles

| Thing | Clock | Notes |
|---|---|---|
| **Zone** | 2 rounds by default (a skill may carry +1 from evolution, max 3, gdd_overworld §4.7), ticks at round end | on expiry the square is **repainted** with the zone's aspect |
| **Pending Surge** | fires at the start of its caster's next turn (§9.3) | then removed; damage, then its **residue**, then **repaint** |
| **Timed ground** | 2 rounds (Lingering: 3), ticks at round end | the residue of a Surge: its aspect's hazard ground at level I; on expiry → Plain (attunement stays) |
| **Permanent ground** | none — stays until changed | changed by Raise Ground, the triangle rule (§7.3), a new ground, shattered props, debris, Voidscar |

**Principle:** *zones are temporary control, ground is the board's memory.* One clock per zone or timed ground — effects never carry their own timers (the clock's length is a property of the cast zone, not of its effects).

### 7.3 Zones: Effects, Rules & Opposites

**Effects** — zones are built only from these tags. Every effect has an **opposite**; zones are compared by effects, never by name.

| Effect | Trigger | Action | Opposite |
|---|---|---|---|
| `slow` | while inside | Move −value | `haste` |
| `haste` *(reserved)* | while inside | Move +value | `slow` |
| `drain_init` | while inside | initiative −value (turn order!) | `quicken` |
| `quicken` *(reserved for zones; used by Shrine §8)* | while inside | initiative +value | `drain_init` |
| `drain_range` | while inside | skill range and Reach −value (min 1) | `extend` |
| `extend` *(reserved for zones; used by Sigil §8)* | while inside | skill range and Reach +value | `drain_range` |
| `push` | end of your turn | move 1 in the **direction set at cast** | `pull` |
| `pull` | end of your turn | move 1 toward the **anchor square set at cast** | `push` |
| `shield` | when you take Surge damage | damage on this square −value | `expose` |
| `expose` *(reserved)* | when you take damage | damage +1 | `shield` |

Effects hit **everyone** on the square — allies, enemies and the caster. Reserved effects have no zone yet; they exist so the table is complete. *(`mend` — heal at end of turn — stays reserved without an opposite.)*

**When a zone lands on a square that already holds one:**

| Existing zone | Result |
|---|---|
| none | **new** |
| **same zone** (same definition) | **levels up** (max III) and refreshes to 2 rounds; the patch id becomes the new cast |
| **opposite** — any effect of one is the opposite of any effect of the other | both **cancel** — the square is empty |
| anything else | **replaced** (level I) |

Examples: Bog (slow, pull) on Gale (push) → cancel · Shockwave (push) on Void Pull (pull) → cancel · Mire on Bog → replaced. There is no merging, so a square always shows exactly one zone with its real effects.

**Zone × ground — the triangle rule.** When a zone is cast on an aspect ground:

| Zone aspect vs. ground aspect | Result |
|---|---|
| the zone's aspect **beats** the ground's (Force > Nature > Dark > Force) | ground **cleared** → Plain, attuned to the zone's aspect |
| **same** aspect | ground **+1 level** (max II), timer unchanged |
| the ground's aspect beats the zone's | nothing |

So a Force zone burns Thornbed away, a Nature zone cleanses Blight, a Dark zone smothers Lava. Neutral ground (Plain, Rubble, Voidscar) ignores zones. Nobody is locked out: every aspect also has Raise Ground and its own Surge residue to replace any ground (§7.4).

### 7.4 Ground — neutral + one hazard per aspect

| Group | Ground | Effect | Attunement |
|---|---|---|---|
| Neutral | **Plain** | move cost 1 | any |
| Neutral | **Rubble** | move cost 2; left by shattered props and collapsed Elevated | none |
| Neutral | **Voidscar** | 1 damage at the **start** of your turn; permanent, spreads late-game (§13.1), nothing changes it | none |
| **Force** | **Lava** I–II | damage = level at the **end** of your turn — *punishes staying* | Force |
| **Nature** | **Thornbed** I–II | damage = level when you **enter** the square (move, push or pull) — *punishes moving* | Nature |
| **Dark** | **Blight** I–II | damage = level at the **start** of your turn — *punishes being there when your turn begins* | Dark |
| Height | **Elevated** | combines with any type. Effect on Surges depends on the type: Flood can't reach it, Rift collapses it, Eruption hits but lays no residue (§9.3). +1 skill range and +1 Reach for the unit there; **climbing up costs 2 movement**; **pushed off Elevated → 1 fall damage**; collapses to Rubble from debris; can be raised under a charging Surge | none |

**How aspect ground is made:**

- **Field skills** (Lava Field / Thornbed / Blight Field) lay **permanent** level I ground
- **Surge residue** lays the Surge aspect's ground at level I as **timed** ground (2 rounds)
- **Same type** on the square → +1 level (max II); the longer lifetime wins (permanent beats timed)
- **Different type** → the new ground **replaces** the old one (a Flood on Lava leaves timed Thornbed — the Lava is gone)
- **Raise Ground** cleanses any ground except Voidscar → Plain, neutral
- Damage from ground is capped at 2 per trigger; one ground per square, so hazards never stack

### 7.5 Attunement (the board's memory)

Every square has an **attunement**: neutral at the start, later Force / Nature / Dark.

| Event | Effect |
|---|---|
| A **Surge fires** on a square | square → the Surge's aspect |
| A **zone fades** | its squares → the zone's aspect |
| An **aspect ground** is laid (Field or residue) | square → that ground's aspect |
| The triangle rule clears a ground | square → the zone's aspect |
| **Raise Ground**, prop destroyed (Rubble), Elevated collapse | square → neutral |
| Voidscar / Rubble / Elevated | cannot hold attunement |

**Strength rule** (live, per square): a zone or Surge is **+1** on squares of **its own aspect**, **−1** on squares of the **aspect that beats it**, 0 otherwise (Force > Nature > Dark > Force). Zone values never drop below 1; Surge damage never below 0.

**Why it works:** the board starts neutral so no monster is born disadvantaged. The *Surge is the main painter*: you deal damage, then your colour is left behind and strengthens your next zones and Surges there. The enemy repaints by firing Surges onto your territory. Display: a coloured strip with the name (Scorched / Overgrown / Cursed) on every attuned square.

### 7.6 Shapes (tetris)

Every Surge, zone and terrain skill controls **several squares in a fixed shape family** (Move, Strike and Self skills don't use shapes):

| Family | Cells | Orientations (incl. mirror) |
|---|---|---|
| I2 | 2 | 2 |
| I3 | 3 | 2 |
| L3 | 3 | 4 |
| O4 | 4 | 1 |
| T4 | 4 | 4 |
| S4 / Z4 | 4 | 4 |
| L4 / J4 | 4 | 8 |

**Fixed shapes:** every skill has exactly **one shape family and one fixed orientation**, absolute on the board for both teams (e.g. Gloom Rift: vertical I3; Mire: T4). Shapes are tuned outside battle (overworld: skill variants / evolution, gdd_overworld §4.7) — in battle you only pick *where* to place it, plus the push direction for Currents, Floods and Tail Sweep. Only the passive **Adaptive** may rotate shapes in battle (`R` / right-click). Place by the **anchor** — the shape's centre-most cell — which must be within range (Manhattan, base + Elevated bonus − drains). All cells must be on the board; ground skills need prop-free squares; props need empty squares; zones and Surges may land on props. Directional skills (Currents, Flood) also take a direction, pull skills an anchor. The cast preview colours each square (**new / levels up / replaces / cancels / blocked**) and lists attunement strength (+1/−1 counts), ground and prop reactions, landing squares of displaced monsters and, for Surges, damage after ground and Veils.

---

## 8. Props

```
SOLID   → cannot enter (Wall, Rock, Tree, Pillar, Shrine)
FIELD   → enterable, applies an effect to the monster on it (Sigil)
FLYING  → air layer only (later, with the air layer at Soul+)
```

### 8.1 Damage, Shatter & Prop Types

A Surge square that contains a prop deals **2 damage to the prop and does not hit a monster there** (solid props can't be occupied). Props also take damage from Strikes (§6.1), collisions (1, §12) and reactions (§8.2). If a prop's HP reaches 0 it **shatters**: Rubble replaces the ground (neutral), and **1 debris damage lands on the four neighbouring squares** (also collapsing Elevated neighbours to Rubble).

| Prop | HP | Tags | Notes |
|---|---|---|---|
| Wall | 2 | brittle | shatters into debris; Dark crumbles it |
| Tree | 2 | flammable | burns (§8.2) |
| Rock | 3 | heavy | can't be moved (Relocate, Flood); survives one Surge at 1 HP |
| Pillar | — | indestructible | anchor (rare), nothing removes it |
| **Shrine** | 2 | solid, effect | monsters orthogonally adjacent to it get `quicken 1` (initiative +1) — placed by Sanctify |
| **Sigil** | 1 | field, effect | the monster standing on it gets `extend 1` (skill range and Reach +1) — placed by Sanctify; destroyed by any Surge or Strike on it |

### 8.2 Prop Reactions

Props stop being "just in the way": each tag reacts to a few aspect sources. Reactions are data (`prop_def.reactions`) and are shown in the cast preview.

| Tag | Force (Force zones, Lava Field, Eruption) | Nature (Nature zones, Flood) | Dark (Dark zones, Blight, Rift) |
|---|---|---|---|
| **flammable** (Tree) | **ignites** when a Force skill hits it (an Eruption ignites it instead of dealing prop damage): burns down at the next round end → Rubble + timed Lava I on its square | a Nature zone or Flood **extinguishes** a burning Tree; Bark Veil: +1 HP | — |
| **brittle** (Wall) | — | — | crumbles: −1 HP per round while a Dark zone or Blight is on it, −1 extra when hit by a Rift |
| **heavy** (Rock) | — | can't be moved by Flood; Flood deals it no damage | — |
| **indestructible** (Pillar) | — | — | — |

Zones on a prop square wait there: once the prop is gone, the zone works normally on that square.

**Bank shots:** aim a Surge so that a prop next to the enemy shatters — the debris hits the square beside it even if the enemy dodged out of the footprint. **A Wall you raise beside yourself will hurt you if a Surge breaks it.**

---

## 9. Skills

### 9.1 Skill Types

```
STRIKE   → small direct damage within Reach; universal (every monster, Kin twist)
SURGE    → the burst damage; deals damage, lays residue, then repaints. One per monster.
ZONE     → timed movement/tempo control (2 rounds): Snare, Current, Hex, Veil
TERRAIN  → writes the ground/object layers: Field, Raise Ground (Elevated), Raise Prop (Wall), Sanctify (Shrine / Sigil)
DIRECT   → one-time effect on a unit or prop: Shove, Relocate
SELF     → Reposition, Channel, Ward, Empower
```

### 9.2 Skill Tiers

ARCHETYPE (~80%) · UNIQUE (~20%) · SIGNATURE (Legendary, usually a Major Surge)

### 9.3 The Surge Archetype

A **Surge is a pending marker with a timer** — same shapes and placement as zones, its own slot, different lifecycle. **It changes the board twice: damage now, ground afterwards.**

```
MINOR SURGE
  shape: per species (I2 … L4, see the roster §6.2), one family in a fixed orientation (§7.6); twists may change it (§9.4.2)
  range: 3 (anchor), +1 on Elevated ground; twists may change it
  charging: visible, blocks movement through its squares
  fires: at the START of the caster's next turn (1v1: = end of the opponent's turn)
         if the caster died, it fires when the caster's slot in the queue would have come up
  autonomous: not cancelled by displacing / killing the caster
  per-square result:
    monster  → value, +1 on own-aspect squares, −1 on squares of the aspect that beats it, − Veil shield
               (hits every monster on its squares — allies and the caster included)
    prop     → 2 damage, shatters if destroyed (debris), plus the prop reaction (§8.2)
    Elevated → depends on the Surge type (table below)
  afterwards: every struck square gets the type's RESIDUE (timed ground, §7.4)
              and is REPAINTED in the Surge's aspect (Scorched / Overgrown / Cursed)
  cost: 1 AP — limiter is ONE charging Surge per monster
  claims squares: can't be placed on squares already holding any charging Surge (the first one claims them)

MAJOR SURGE (Ancient / Legendary Signature only)
  shape: large area (up to half the board), range: long
  cost: 2 AP, once per battle
```

**Surge types by aspect.** Same lifecycle for all three; they differ in residue, props and height:

| Type | Aspect | Damage | Residue (timed ground, 2 rounds) | Props | Elevated |
|---|---|---|---|---|---|
| **Eruption** | Force | 3 | **Lava I** — burns at end of turn | Trees ignite | hit normally, **no residue** there (lava runs off) |
| **Flood** | Nature | 2 | **Thornbed I** — hurts when entered | pushes struck monsters 1 square in the direction set at cast (into the thorns it just laid); extinguishes burning Trees; heavy props block it | **can't reach it** (square blanked) |
| **Rift** | Dark | 3 | **Blight I** — hurts at start of turn | brittle props crumble | **collapses** to Rubble, the monster on it still takes damage |

So Elevated is a real decision: high ground is safe against a Flood, normal against an Eruption, and a trap against a Rift.

**The Surge counter menu** (a Surge with fewer than 3 live counters isn't finished):

| Counter | How |
|---|---|
| **Leave** | move out of its squares before it fires — but mind the residue it leaves |
| **Veil it** | a Veil over its squares: shield 2 (±1 attunement, up to 3 with level) cuts damage 1:1 per square; recast to level up |
| **Pick the height** | Raise Ground: blanks a Flood, no residue from an Eruption — useless against a Rift |
| **Re-attune** | change the square's colour before it fires: remove the Surge's +1, or give it a hostile −1 |
| **Fly over it** | the air layer is immune to ground Surges (Winged, Soul+) |
| **Props / debris** | use props to soak squares — but remember the shatter hits next to them |
| **Answer with your own Surge** | race it — but you can't claim squares already held by a charging Surge |
| **Control the tempo** | Mire / Bog / Currents to steer where the target can stand; drain the caster's initiative to delay its next turn |

### 9.4 The Archetype System

The archetypes are the rule system; concrete skills come from the matrix (§9.5); monsters pick from it (§6.2). Three groups:

| Group | Who has it | Archetypes |
|---|---|---|
| **Universal actions** | every monster | Move, Strike (#16, Kin twist §6.1) |
| **Surge** | every monster, one each | #1 — type from aspect, shape from species, ≤1 twist (§9.4.2) |
| **Utility pool** | 1 per monster (2 from Foundation stage, gdd_overworld §4.5), limited by Kin | #2–#15 |

#### 9.4.1 All archetypes

| # | Archetype | Type | What it does | Parameters |
|---|---|---|---|---|
| 1 | **Surge** | Surge | burst damage, residue, repaint | type, shape, size, twist |
| 2 | **Field** | Terrain (ground) | permanent hazard ground: Lava / Thornbed / Blight | aspect, shape |
| 3 | **Snare** | Zone | `slow` (+ optional side effect) | aspect, value, shape |
| 4 | **Current** | Zone | `push` (direction set at cast) or `pull` (anchor set at cast), fires at end of turn | mode, shape |
| 5 | **Hex** | Zone | `drain_init` / `drain_range` / `slow` bundle | which stats, amount |
| 6 | **Veil** | Zone | `shield` vs Surges (+ aspect side effect) | aspect, amount |
| 7 | **Raise Prop** | Terrain | places solid props (Wall) in a shape | prop HP, shape |
| 8 | **Raise Ground** | Terrain | Elevated + cleanses ground | shape |
| 9 | **Sanctify** | Terrain | places one effect prop (Shrine or Sigil, §8.1) | which prop |
| 10 | **Shove** | Direct | one-time push/pull of a unit (needs sight) | distance, collision dmg |
| 11 | **Reposition** | Self | blink / dash | distance |
| 12 | **Channel** | Self | cleanse your square's zone, or +1 to your next cast | which |
| 13 | **Ward** | Self | the next Surge damage on you −2 | amount |
| 14 | **Relocate** | Direct | move a non-heavy prop | distance |
| 15 | **Empower** | Self | +1 level on **your own** zone or +1 value on your charging Surge | boost, own-aspect only |
| 16 | **Strike** | Universal | enemy monster or prop within Reach, 2 AP, max 2 damage, Kin twist (§6.1) | damage, twist |

#### 9.4.2 Surge Twists

A twist is **one** extra rule on a species' Surge. It must stay readable in the preview, and every twist pays for its advantage:

| Twist | Rule | Price |
|---|---|---|
| — (baseline) | normal Surge | — |
| **Pounce** | anchor must be adjacent to the caster; may use a 4-cell shape | range 1, you stand next to your own blast |
| **Trail** | the shape must start on a square adjacent to the caster, in a straight line | no free aiming |
| **Ring** | the shape is the caster's 4 neighbours (caster's square excluded) | range 0, the enemy must come close |
| **Lob** | range +2 | damage −1 |
| **Wide** | +1 cell | damage −1 |
| **Slow-burn** | fires one caster turn later, damage +1 | the enemy gets a whole extra turn to answer |
| **Lingering** | residue lasts 3 rounds instead of 2 | damage −1 |
| **Constrict** | struck monsters are pulled 1 toward the anchor after the damage | damage −1 |

### 9.5 Skill Matrix — archetype × aspect

Aspect-flavoured archetypes get one concrete skill per aspect. Same archetype = same core rule, the aspect adds **one** side effect. Names are working titles.

| Archetype | Force | Nature | Dark |
|---|---|---|---|
| **Field** (hazard ground) | **Lava Field** — damage at end of turn | **Thornbed** — damage when you *enter* | **Blight Field** — damage at *start* of turn |
| **Snare** (slow) | **Ash Snare** — slow 1, ignites flammable props | **Bog** — slow + pull | **Grasping Shade** — slow 1 + range −1 |
| **Current** (push / pull) | **Shockwave** — push (direction set), collision +1 | **Gale** — push (direction set), extinguishes burning Trees | **Void Pull** — pull to the anchor |
| **Hex** (drain) | **Glare** — range −2 | **Spore Cloud** — initiative −1, slow 1 | **Mire** — slow, initiative −2, range −1 |
| **Veil** (shield) | **Kiln Shell** — shield 2, occupants ignore Lava | **Bark Veil** — shield 2, props on it +1 HP | **Shade Veil** — shield 2, also cuts Strike damage by 1 |

**Neutral archetypes** (Raise Prop, Raise Ground, Sanctify, Shove, Reposition, Channel, Ward, Relocate, Empower) have no aspect variant: the aspect only decides the attunement interaction (+1/−1) and the colour. Kin decides who may take them (§6, "Locked out of").

**Kit rule:**

```
Monster = Move + Strike (Kin)                      — universal
        + 1 Surge (aspect type, species shape, ≤1 twist)
        + 1 utility from the matrix / neutral pool  — 2nd utility from Foundation
        + 1 passive                                  — 2nd passive at Epic+ (gdd_overworld §5)
```

**Kit design tip:** pair the Surge with a utility of a *different effect family* (a Veil, a Snare, a Current) so there is always an answer in the kit. Aspects are **flavour + territory**: they decide which squares you paint and which zones get +1 there. The prototype Tiger's 7 skills are a test bench, not a kit.

### 9.6 Sight

Zone, terrain and Surge casts are placed by **range from the caster to the anchor** — no line of sight. Sight is needed for Shove and for Strikes with Reach ≥ 2; Self skills never need it.

### 9.7 Skill Schema

```json
{
  "id": "bog",
  "name": "Bog",
  "kind": "zone",                    // strike | surge | zone | ground | height | prop | direct | self
  "aspect": "nature",
  "zone": "bog",                     // zone definition id (kind: zone)
  "ground": null,                    // kind: ground → lava | thornbed | blight
  "archetype": "Snare",              // §9.4.1
  "shapes": ["L3"],                  // exactly one tetris family
  "orientation": 0,                  // fixed orientation index (absolute on the board)
  "range": 3,                        // anchor range (Manhattan)
  "cost": 1,                         // AP, always ≥ 1 (Strike / Major Surge: 2)
  "surge_type": null,                // eruption | flood | rift — kind: surge only
  "twist": null,                     // kind: surge only, §9.4.2
  "directional": false               // Currents / Flood: caster sets a direction at cast
}
```
**Rules:** no cooldowns (§4.4) · only `kind: surge` deals burst damage · ground damage capped at 2 per trigger · zone effect values/caps live on the **zone definition**, not on the skill · every zone must carry ≥1 effect tag · zones last 2 rounds by default (global constant, tunable); an evolved skill may add +1 round (max 3).

### 9.8 Unique Skill Examples

Mirror Step · Spatial Rend (remove a square 2 rounds) · Exile · Anchor (square immune to enemy displacement) · Conversion (your ground becomes another aspect) · Inversion (swap two rows' ground) · Mimicry · Devour Prop · Curse of Sight · Gravity Well (pull toward a square) · Twin Surge (Signature).

---

## 10. Passives Library

**Terrain Identity:** Native Ground (your zones and Surges get +2 instead of +1 on own-aspect squares; ignores the −1) · Painter (fired Surges also repaint adjacent squares) · Adaptive (may rotate its skill shapes in battle) · Trailblazer (repaints squares it walks over) · Deep Roots (undisplaceable on own-aspect squares) · Purifier (adjacent enemy zones lose 1 round at round end) · Overgrowth (your zones start at level II)

**Position & Movement:** Highlander (+2 init on Elevated) · Turret (can't move, +1 range and Reach) · Skittish (free 1-square move after taking Surge damage — to the safest free neighbour) · Phasing (moves through props) · Momentum (after a max-distance move, the next Surge this turn deals +1)

**Displacement:** Crashlander (when pushed or pulled into a prop or monster, it takes no collision damage — the other side takes 1) · Immovable (ignores push/pull) · Counterweight (allies orthogonally adjacent to it can't be pushed or pulled)

**Combat:** Thick Hide (Strikes and collisions deal 1 less, min 0) · Pack Hunter (Strike costs 1 AP if an ally is adjacent to the target) · First Blood (its first Strike each battle costs 1 AP) · Vengeful (after taking Surge damage, its next Strike costs 1 AP) · Scavenger (heals 1 when a prop within its Reach shatters) · Frenzy (+1 shape cell at 1–2 HP) · Bulwark (team: allies orthogonally adjacent to it take 1 less Surge damage)

**Ground & Zone Resistance:** Sure-footed (ignores `slow`) · Clear Mind (ignores `drain_*`) · Heatproof (ignores Lava) · Thornwalker (ignores Thornbed) · Void-touched (ignores Blight) — the unit-level way of shrugging a specific effect.

---

## 11. Damage System

### 11.1 The Damage Law

> **The Surge is the burst.** It is the only skill that deals more than 2 damage.
> - **Strike:** max 2, the only attack that lands the instant it is used — it needs the target within Reach and the whole turn (2 AP)
> - **Aspect ground:** its level (max 2) at its trigger — Lava at the end of your turn, Thornbed when you enter, Blight at the start of your turn. Voidscar: 1 at the start of your turn
> - **Collision** (pushed into a prop or monster), **fall** (pushed off Elevated) and **debris** (prop shattered next to you): 1 each
> - **Zones never deal damage.** Nothing else deals damage the instant it is cast

### 11.2 Surge Lifecycle

```
1. DECLARE   → shape appears on the board: squares, damage, fire time shown
2. CHARGE    → blocks movement through its squares
3. WAIT      → every other monster gets its turn: leave, Veil, change the height, re-attune, ...
4. DETONATE  → at the start of the caster's next turn, per square:
               Elevated → by Surge type (§9.3)
               prop     → 2 dmg, shatter + debris, prop reaction
               monster  → value ±1 by attunement − Veil shield
5. AFTERMATH → residue (timed ground) on every struck square, then the square is repainted in the Surge's aspect
```

**Autonomy:** a Surge is not cancelled by displacing, staggering or killing its caster. Only the counter menu (§9.3) stops it.

### 11.3 Collision, Fall & Debris

- Pushed or pulled into a **prop**: no move, 1 damage to the monster and 1 to the prop (heavy props take none)
- Into a **monster**: no move, no damage · off the **board edge**: no move, no damage
- **Off Elevated**: the move happens, 1 fall damage · onto Elevated from below: blocked like a prop, no damage
- **Prop shattered**: 1 debris damage to the four neighbouring squares; Elevated neighbours collapse to Rubble

### 11.4 General Rules

- No defense stat — resistances via attunement, Veils and passives
- All damage exact and previewed
- A Surge whose caster died still resolves

| Source | Fires |
|---|---|
| Surge detonation | start of the caster's next turn |
| Strike | instantly (2 AP, within Reach) |
| Lava | end of the occupant's own turn |
| Thornbed | when a monster enters the square |
| Blight / Voidscar | start of the occupant's own turn |
| Collision / fall / debris | on impact / on shatter |

---

## 12. Displacement

| Type | Mechanic |
|---|---|
| **Zone push** (Current) | at the **end of the occupant's turn**, 1 square in the **direction the caster set at cast** |
| **Zone pull** (Snare / Current) | at the **end of the occupant's turn**, 1 square toward the **anchor** the caster set at cast |
| **Shove** | direct, one-time, precise (needs sight) |
| **Tail Sweep** (Scaled Strike) | push 1, direction chosen |
| **Flood** | pushes struck monsters 1 in the direction set at cast |
| **Constrict** (twist) | pulls struck monsters 1 toward the anchor |

Always cardinal and one square per trigger; the landing square is visible in the preview. Blocked moves: §11.3.

**Why end of turn:** at the start of a turn the target simply walks away again. At the end of its turn it lands where you sent it — in Lava, through Thornbed, in front of your Strike, or in a Surge that detonates before it can move again. The counterplay is visible: don't end your turn on a current.

---

## 13. Battlefield Generation

- Procedural ground + props, **point-symmetric around the centre** so both sides get the same distances (mirrored fairness check for every mode)
- Contested Elevated squares near the centre, equidistant from both starts
- Pre-placed props shape the opening

| Mode | Board | Start area per side | Contested Elevated | Props |
|---|---|---|---|---|
| 1v1 | 5×5 | opposite corners | 2 near the centre | 2–3 |
| 2v2 | 6×6 | back row | 2 near the centre | 3–4 |
| **3v3** | **7×7** | back two rows; players place their monsters in pre-battle | 3: the centre + 2 flanking | 4–6 |
| 5v5 | 9×9 | back two rows | 3–5 | 6–8 |

On 7×7 the sides start 5–6 rows apart: no Strike and no Surge reaches the enemy line in round 1, so acting first gives position, not a free hit.

### 13.1 Late-Round Pressure (Anti-Stalling)

From a set round on, the square farthest from all living monsters converts to **Voidscar** each round (permanent, undestroyable). The start round scales with the board (tunable: 1v1 round 6, 3v3 round 8). **Collapse:** once no free square is left to convert, every living monster takes 1 damage per round — so every battle ends.

---

## 14. Effect Timing Reference

| Trigger | When | Examples |
|---|---|---|
| on_timer | start of the caster's next turn, before anything else | Surge detonation |
| start_of_turn | beginning of the occupant's turn | Voidscar, Blight |
| on_enter | a monster enters the square (move, push, pull) | Thornbed |
| while_inside | continuous modifier | slow, drain_init, drain_range, shield; Shrine / Sigil |
| end_of_turn | end of the occupant's turn | 1. push / pull → 2. Lava (on the landing square) |
| round end | after the last turn of the round | zones and timed ground −1 round (fading zones repaint), burning props burn down, Voidscar spreads, initiative re-sorted |

Order inside a turn: due Surges (damage → residue → repaint) → start effects → AP → end effects (displacement, then Lava).

---

## 15. Tamer Skills (Player Influence)

The tamer shapes; monsters fight. Each tamer skill can be used **once per battle**. The player brings a limited number of **slotted** skills into a battle (slots grow with cultivation stage, gdd_overworld §4.8).

| Skill | Effect |
|---|---|
| Spatial Pull | move an own monster to any empty square |
| Qi Suppression | an enemy monster −2 initiative next round |
| Spirit Shield | the next Surge damage on one own monster is 0 |
| Domain Glimpse | clear a tetromino of zones and reset its ground to Plain/neutral |
| Beast Swap | (Soul+) exchange an active monster with one from the spatial space |

---

## 16. Technical Notes (Battle)

- Godot 4 · **3D square grid, orthogonal camera ~45°** — never hex
- **Content = data files with a fixed template:** one Resource per monster / skill / zone in `data/monsters`, `data/skills`, `data/zones`, typed by its script class (`MonsterDef`, `SkillDef`, `ZoneDef` — only their exported fields exist, the inspector shows them as a form). `GameData` is the single registry: it finds every file automatically, indexes it by `id` (= file name) and validates the set on startup (duplicate ids, missing Surge/utility, unknown shapes or passives, aspect mismatches, stat ranges). A new monster = a new file
- Battle logic **headless & engine-independent**: 2D array of Square objects; each square stores `{ ground{type, level, timer, height, attunement}, object, surge, zone }`; zone definitions are a data table (aspect + effect list with base/cap), values computed live from level and attunement
- Resolution is deterministic and order-defined (§14); casting is a pure function `preview_cell(skill, cell)` returning `new | level | replace | cancel | lost` plus ground and prop reactions, residue and landing squares of displacement — the same function drives the preview, the AI and the unit tests
- Opposite effects (§7.3), the triangle rule for zone × ground, the source × prop-tag table (§8.2), Surge types and twists are data (Resources), not code branches; the zone × zone check compares effect tags, never zone ids
- One turn queue for all monsters (§4.3); a pending Surge stores its caster and fires on the caster's next turn start
- A pending Surge is a marker on the square with its own slot (not a zone); it blocks movement like a temporary object
- Shape orientations are generated once from base shapes (rotate + mirror, de-duplicated); anchor = cell nearest the centroid
- Art pipeline: low-poly Blender + AI textures

---

## 17. Prototype & Playtests

**Current build (v6):** the Godot project in `godot/` — main menu → draft (pick 3 of the 9 roster monsters, or 1 for a duel) → **3v3 on 7×7** or **1v1 on 5×5** against an AI team drawn from the rest. All v6 rules of this document are implemented in the headless core (`godot/core/`). The HTML prototype is the older v5 reference.

**Tools:** `godot/tests/` (gdUnit4 suites for the rules; project layout in `godot/README.md`), `godot/tools/sim.gd` (AI-vs-AI batch simulation with win rates per monster), `godot/tools/smoke_ui.gd` (plays the player's side through the real UI headless).

**First simulation (60 AI-vs-AI 3v3 battles, random teams):** sides win 50/50, ~14 rounds per battle with free rotation — **~19 rounds with fixed shapes**. Outliers to look at: **Dusk Moth wins 87%** (Native Ground + Wide Eclipse + Blight residue), Blight is the biggest damage source after Eruption, Veils absorb a lot (230 blocked hits), and ~1 in 5 battles is decided by the arena collapse (§13.1).

**Next playtest — what to check once v6 is built:**

1. Does the residue make Surges *land* (the enemy takes damage even when it dodges, or has to walk around it)?
2. Does end-of-turn displacement with a chosen direction create readable combos (current → Surge, current → Lava, pull → Strike)?
3. Is Strike at 2 AP worth using, or does it never happen? Does it make close range too sticky?
4. Do no-cooldown turns create more interesting choices, or does one action get spammed (especially double Veils)?
5. Do the three Surge types make Elevated a real decision?
6. Do props now get *used* (burned, crumbled, smashed for debris) instead of just being in the way?
7. Is 3v3 on 7×7 readable, and do fights end in a reasonable number of rounds?
8. Is Dusk Moth really that strong for a human player, or is it the AI? (simulation: 87% win rate)

---

## 18. Open Questions (Battle)

**Rules to tune**
- **Double Veil:** without cooldowns a Veil can be cast twice in one turn → level II, shield 3, a full answer to a 3-damage Surge for 2 AP. Fine, or a new Dispel loop? (watch in playtest; fallback: a zone can level up only once per turn per square)
- **Strike cost:** keep 2 AP, or 1 AP but only if you didn't move this turn?
- **Residue numbers:** timed level-I ground for 2 rounds — too strong together with the Surge, too weak to matter?
- **Triangle rule for ground:** Bog no longer cools Lava (Force beats Nature) — Lava is answered by Dark zones, Raise Ground and any Surge residue. Feels right, or does Nature need a water exception?
- **Opposite effects:** should cancelling ever leave a remainder (e.g. a level-III zone beats a level-I opposite)?
- **Zone duration:** 2 rounds for everything — should strong zones (Mire) be shorter, weak ones longer?
- **Veil strength:** shield 2 vs Surge 3 (up to 3 with level, ±1 attunement) — too weak or too strong?
- **Attunement scale:** ±1 only bites on values ≥2 (zone values clamp at 1). Rescale zone base values?
- **Surge as the painter:** is repainting fast enough to claw back territory, or does the first Surge snowball? Optional decay after N rounds?
- **Ground clutter:** do permanent Field grounds clutter the board by round 5? Optional cap of N Field squares per monster?
- **Lava on Elevated:** legal (Raise Ground cleanses it, Dark zones smother it) — does Elevated need to resist Lava?
- **Pull point / Flood direction:** pull to the anchor and one push direction per Flood (current rules) — or more freedom?

**Teams & scale**
- **Board sizes:** do Surge range 3 and 3–4 cell shapes still work on 7×7, or do ranges need +1?
- **Initiative chains:** one side can chain several turns; is the Mire cap (−3) enough?
- **Zone ownership:** zones hit everyone — does that make allied zone play too risky in 3v3?
- **Surge vs Surge:** the first Surge claims a square; is declaring first too strong in initiative order?
- **Reach budget:** is Reach 2 worth less Move / Initiative, or does it make anvils too safe?
- **Voidscar:** start round per mode — still needed in 3v3?

**Content**
- **Roster gaps:** which of the remaining 9 Kin × Aspect cells come next, and which stay empty at launch
- **Major Surge:** shape and size
- **Winged air layer:** how zones and ground affect air units (Soul+)
- **Domain Glimpse tuning:** how big

---

## 19. Version History

**v6.0 — Options, not luck (current, designed, not built).** Playtests of the Godot port showed the v5 loop wasn't fun: the Surge was the only damage source and easy to dodge on 5×5, props were just obstacles, and Elevated was a blanket "Surge immune" rule. v6 stays fully deterministic but adds:
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
