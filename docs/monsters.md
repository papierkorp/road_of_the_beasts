# Monster Rules

- **This file owns** what a monster is: species and individual, stats and their calculation, Kins, rarity and growth.
- **Elsewhere:** what a monster can do ([skills.md](skills.md)); how a fight runs ([battle.md](battle.md)); the nine monsters, their stats and kits ([content.md](content.md)); catching, housing and the world ([overworld.md](overworld.md)).
- **Status:** the system is decided. **Every number is an untested starting value.** The game checks no price and no point total.

## 1. Species and Individual

A monster the player owns is two layers: a fixed **species** and a unique **individual**.

```
SPECIES     Kin · descriptive themes · default kit · learnable skills · blurb · art
INDIVIDUAL  stat shape · stats · rarity · stage + sub-tier + XP
            slot development and equipped skill per slot · artifacts · current HP
```

- **The battle only ever sees the finished sheet:** name, Kin, the six stats and the kit (Step plus up to 6 slots).
- **Stat shape is individual, not species-wide:** two individuals of one species can play differently with the same kit.
- Wild and newly caught monsters roll a shape weighted by their **Kin lean** ([§3](#3-kins)); rare off-lean rolls are prized finds.
- **Current HP** persists between the battles of an expedition.
- Every monster is 1×1 and stands on the ground.

**What makes a monster:**

| Layer | Decides |
|---|---|
| **Kin** (body) | stat lean, skill access |
| **Themes** (description) | free flavour and visual identity; no mechanical type, no eligibility rule |
| **Species** | its default kit and its learnable list |
| **Stat shape** (individual) | how its points are spread |
| **Kit** | up to 6 slots, chosen by the player from the learnable list |

- **No fixed roles:** Kin is not class; kits determine team function.
- **Design test:** one sentence per monster built from its kit. If two monsters read the same, change a skill, a stat or its theme.

## 2. Stats

### 2.1 The Stats

| Stat | Range | Function |
|---|---|---|
| HP | 1–10 | No defense stat. The highest single hit is 2, so a monster with 1 or 2 HP can fall to one hit: that is the buyer's choice |
| Pace | 1.0–10.0 | Position in the turn queue and the order of the Dragon Veins it took; the whole number of its current value, at least 1, is the Stamina recovered per round and, above 1, the number of Waits per battle ([battle.md §2.3](battle.md#23-pace-and-the-queue)). Counts in points of 0.1 |
| Stamina | 1–10 | Size of the pool that pays for movement skills; Step needs none |
| Reach | 1–10 | How far away a skill may create ground, a zone or a prop, in orthogonal steps; Strikes do not use it. The range is wide because boards may grow in the game |
| Turns per round | 1–3 | Extra turns from round 2 on |
| AP | 1–5 | Action points per turn |

**One fixed range per stat for the whole game, and every stat starts at the lowest value of its range.** There is no free value above the minimum, no ceiling per stage and no unlock per stage: what a monster has above the minimum it has paid for.

### 2.2 Prices and Points

```
RANGE   one fixed range per stat; the start is its lowest value
PRICE   every step above the start costs points
POINTS  every monster of a stage and sub-tier has the same number of points; a stage gives nothing else
```

| Purchase | Price |
|---|---|
| +0.1 Pace | 1 |
| +1 Stamina | 2 |
| +1 HP | 5 |
| +1 Reach | 5 |
| AP 2 / 3 / 4 / 5 | 5 / 10 / 15 / 20 for the step (AP 5 in total: 50) |
| Second turn | 10 + 5 per AP of the monster (AP 2: 20 · AP 3: 25 · AP 4: 30 · AP 5: 35) |
| Third turn | twice the price of the second |

- **The turn price follows the AP** because turns and AP multiply. It is counted with the AP the monster ends up with, whatever was bought first.
- The prices of Pace and Reach are set, not measured.

**Points:** 25 at the start, **+5 with each of the 18 steps** ([§5](#5-growth)); a step is worth one HP.

| Stage | Lower | Middle | High |
|---|---|---|---|
| Qi Gathering | 25 | 30 | 35 |
| Foundation | 40 | 45 | 50 |
| Core Formation | 55 | 60 | 65 |
| Soul Tier | 70 | 75 | 80 |
| Immortal | 85 | 90 | 95 |
| Sovereign | 100 | 105 | 110 |

- **Why it ends at 110:** HP 10, AP 5 and a second turn at AP 5 cost 130 together. With 110 a monster reaches the top in two of these three and never in all. More points would go into actions, not into longer battles, because HP ends at 10 and a hit stays at 2.
- **The prices take the place of unlocks:** with at least HP 3 and Reach 2 a second turn fits from 40 points, AP 3 from 30, AP 4 from 45, AP 5 from 65 and a third turn from 80; with a sturdier body each comes about a stage later.
- **Multiplayer mode:** one fixed number of points for every monster (60).
- **Monster stats and skills are priced apart** ([skills.md §7](skills.md#7-value-and-prices)) and validated together.

### 2.3 Shapes and Spending

A monster **starts** with stats rolled by its stat shape; **afterwards the player decides** where each step's 5 points go (a free action; unspent points are kept).

| Shape | Feel |
|---|---|
| Bulwark | slow, hard to dislodge; holds ground near a Dragon Vein: most points in HP |
| Skirmisher | gets where it wants first; takes free squares and pushes holders off: Pace and Stamina |
| Swift | more turns from round 2 on, paid with body or speed |
| Caster | weak body, long Reach; works from behind the others |

- **Viable from the start:** the points of the first step must pay for a monster that works with its starter kit. Progression expands a viable build rather than repairs it; several routes must be useful.
- **Reshape:** pool all points and reroll by the new shape at the same number of points. Spending level-up points never changes the shape label. Item: [overworld.md §6.6](overworld.md#66-pills--medicines).
- **Stage rule:** a monster cannot exceed the player's **stage** (not the exact sub-tier): the spatial space sustains only what the tamer's qi can feed.
- How a shape splits the points at the roll is not defined.

## 3. Kins

**Kin is what kind of creature it is.** It sets the stat lean and skill access. It changes nothing a skill does: no Strike effect, no damage multiplier. There is no weakness triangle, no element system and no attunement.

| Kin | Body fantasy | Stat lean |
|---|---|---|
| **Beast** | tiger, ape, wolf | skirmisher, high Stamina |
| **Winged** | bird, moth, wyvern | swift, caster |
| **Scaled** | serpent, turtle, drake | bulwark, low Stamina |
| **Swarm** | insects, rats | swift (two turns) |
| **Spirit** | ghost, wisp | low HP, high Pace |
| **Ancient** | golem, treant | max HP, one turn |

The **species learnable list** sets concrete skill access. Neither learnable lists nor Kin access exist as content yet.

## 4. Rarity

**Rarity is potential and flexibility, not raw power.**

| | Normal | Rare | Epic | Legendary |
|---|---|---|---|---|
| Kit | up to 6 slots | same | same | same, plus a Signature skill at its highest stage |
| Slot-development steps per advancement | 1 | 1 | 2 | 2 |
| Highest stage | Core | Soul | Immortal | Sovereign |

- **No stat bonus from rarity:** rarity buys development steps and a higher last stage, never numbers.
- Rarity does not decide the stat shape.
- **Ascension** is a major event, not a grind: one **Bloodline pill** (a Rare+ beast part of this Kin and a next-tier herb) plus a ritual ([overworld.md §6.6](overworld.md#66-pills--medicines)). The monster gains the new rarity's steps and last stage and keeps everything else. **Normal can climb to Epic, never to Legendary.**

*Working values:* the step counts per rarity.

## 5. Growth

**18 steps:** six stages × three sub-tiers. Every step grants 5 freely spent stat points; a stage opens skills, never a stat value; what the tamer gains per stage stands in [overworld.md §6.3](overworld.md#63-stage-unlock-table). A monster exceeds neither the player's stage nor its rarity's last stage.

| # | Stage · sub-tier | Points | Also gained | XP to the next step |
|---|---|---|---|---|
| 1 | Qi Gathering Lower | 25 | full kit | 60 |
| 2 | Qi Gathering Middle | 30 | | 120 |
| 3 | Qi Gathering High | 35 | breakthrough trial opens | 200 (+ trial) |
| 4 | Foundation Lower | 40 | slot-development step · +1 learnable skill | 150 |
| 5 | Foundation Middle | 45 | | 300 |
| 6 | Foundation High | 50 | | 500 (+ trial) |
| 7 | Core Formation Lower | 55 | slot-development step · +1 learnable skill | 400 |
| 8 | Core Formation Middle | 60 | | 800 |
| 9 | Core Formation High | 65 | | 1300 (+ trial) |
| 10 | Soul Tier Lower | 70 | slot-development step · +1 learnable skill | 1000 |
| 11 | Soul Tier Middle | 75 | | 2000 |
| 12 | Soul Tier High | 80 | | 3200 (+ trial) |
| 13 | Immortal Lower | 85 | slot-development step · +1 learnable skill | 2500 |
| 14 | Immortal Middle | 90 | +1 slot-development step | 5000 |
| 15 | Immortal High | 95 | +1 slot-development step | 8000 (+ trial) |
| 16 | Sovereign Lower | 100 | slot-development step · Signature skill (Legendary) | 6000 |
| 17 | Sovereign Middle | 105 | +1 slot-development step | 12000 |
| 18 | Sovereign High | 110 | +1 slot-development step | — |

- **Slot-development step:** the monster may develop one skill slot ([skills.md §8](skills.md#8-development)): 1 per step for Normal and Rare, 2 for Epic and Legendary.
- **Learnable skills:** the species list grows by one with each breakthrough from Foundation to Immortal.
- Breakthrough trials: [overworld.md §6.3.1](overworld.md#631-breakthrough-trials).

*Working values (XP):* bars grow about ×2.5 per stage; a sub-tier takes roughly 3–6 focused days at the right stage. A cultivation pill gives about half its tier's Lower bar (Qi +30, Foundation +80, Core +200, Soul +500, Immortal +1200). A win gives 10 XP at Qi Gathering, ×2.5 per stage. A night at a cultivation spot gives a small gain (Meditation Stone about one tenth of a win, Qi Spring double).
