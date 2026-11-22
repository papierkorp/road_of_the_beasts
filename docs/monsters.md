# Monster Rules

- **This file owns** what a monster is: species and individual, stats and their calculation, Kins and growth.
- **Elsewhere:** what a monster can do ([skills.md](skills.md)); how a fight runs ([battle.md](battle.md)); the nine monsters, their stats and kits ([content.md](content.md)); obtaining monsters and the game around the battle ([overworld.md](overworld.md)).
- **Status:** the system is decided. **Every number is an untested starting value.** The game checks no price and no point total.

## 1. Species and Individual

A monster the player owns is two layers: a fixed **species** and a unique **individual**.

```
SPECIES     Kin · descriptive themes · default kit · learnable skills · species skill · blurb · art
INDIVIDUAL  stat shape · stats · stage + sub-tier
            open slots · slot development and equipped skill per slot · current HP
```

- **The battle only ever sees the finished sheet:** name, Kin, the six stats and the kit (Step plus up to 6 slots).
- **Stat shape is individual, not species-wide:** two individuals of one species can play differently with the same kit.
- Wild and newly caught monsters roll a shape weighted by their **Kin lean** ([§3](#3-kins)); rare off-lean rolls are prized finds. A monster from an egg is shaped by the player ([overworld.md §4.1](overworld.md#41-obtaining-monsters)).
- **Current HP** are full at the start of every battle ([vision.md §4](vision.md#4-where-battles-happen)).
- Every monster is 1×1 and stands on the ground.

**What makes a monster:**

| Layer | Decides |
|---|---|
| **Kin** (body) | its Kin trait, the skill groups it can learn, stat lean |
| **Themes** (description) | free flavour and visual identity; no mechanical type, no eligibility rule |
| **Species** | its learnable list, its species skill and its default kit |
| **Stat shape** (individual) | how its points are spread |
| **Kit** | 4 slots at the start and up to 6, chosen by the player from the learnable list |

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

**Points:** 25 at the start, **+5 with each of the 15 steps** ([§5](#5-growth)); a step is worth one HP.

| Stage | Lower | Middle | High |
|---|---|---|---|
| Qi Gathering | 25 | 30 | 35 |
| Foundation | 40 | 45 | 50 |
| Core Formation | 55 | 60 | 65 |
| Nascent Soul | 70 | 75 | 80 |
| Immortal | 85 | 90 | 95 |

- **Why it ends at 95:** the game ends with the Sovereign beast, and no monster grows past Immortal. HP 10, AP 5 and a second turn at AP 5 cost 130 together: a monster reaches the top in one or two of these three and never in all. More points would go into actions, not into longer battles, because HP ends at 10 and a hit stays at 2.
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
- **Reshape:** pool all points and reroll by the new shape at the same number of points. Spending level-up points never changes the shape label. Item: [overworld.md §6.2](overworld.md#62-alchemy-and-pills).
- **Stage rule:** a monster cannot exceed the player's **stage** (not the exact sub-tier).
- How a shape splits the points at the roll is not defined.

## 3. Kins

**Kin is what kind of creature it is.** It sets a trait, skill access and the stat lean. It changes nothing a skill does: no Strike effect, no damage multiplier. There is no weakness triangle, no element system and no attunement.

- **Kin trait:** one innate property that no other Kin has. It takes no slot and changes how the monster deals with the board, never a damage number.
- **Skill groups:** the groups are what a skill does or creates ([skills.md §3](skills.md#3-what-a-skill-does-and-creates)): Strike, movement, effect on the user, ground, zone, prop. A Kin can learn only some of them.
- **Species skill:** every species has one skill or self buff that no other species can learn. It is on the learnable list from the start, fills a slot like any skill and may be left out.

| Kin | Body fantasy | Stat lean |
|---|---|---|
| **Beast** | tiger, ape, wolf | skirmisher, high Stamina |
| **Winged** | bird, moth, wyvern | swift, caster |
| **Scaled** | serpent, turtle, drake | bulwark, low Stamina |
| **Swarm** | insects, rats | swift (two turns) |
| **Spirit** | ghost, wisp | low HP, high Pace |
| **Stone** | golem, statue | max HP, one turn |
| **Flora** | treant, fungus, vine | not defined |
| **Void** | creatures of the void | not defined |

*Working value:* the list of Kins.

- **Void** monsters live in the void only and cannot be caught; the player gains one as an egg ([overworld.md §4.1](overworld.md#41-obtaining-monsters)).

The **species learnable list** sets concrete skill access within the groups of its Kin. Drafts of the traits and the groups of each Kin: [content.md §7](content.md#7-kins); the species skills and the learnable lists are not defined.

## 4. No Bloodline

A monster has no bloodline, no grade and no rank: two monsters of one species differ by their stat shape, their stat points and their kit alone. A Kin has its trait and no further passives ([§3](#3-kins)).

## 5. Growth

**15 steps:** five stages × three sub-tiers. Every step grants 5 freely spent stat points; a stage opens skills, never a stat value; what the tamer gains per stage stands in [overworld.md §5.1](overworld.md#51-stages). A monster never exceeds the player's stage.

| # | Stage · sub-tier | Points | Also gained |
|---|---|---|---|
| 1 | Qi Gathering Lower | 25 | 4 slots |
| 2 | Qi Gathering Middle | 30 | |
| 3 | Qi Gathering High | 35 | next: only the void lifts it |
| 4 | Foundation Lower | 40 | choice · +1 learnable skill |
| 5 | Foundation Middle | 45 | |
| 6 | Foundation High | 50 | |
| 7 | Core Formation Lower | 55 | choice · +1 learnable skill |
| 8 | Core Formation Middle | 60 | |
| 9 | Core Formation High | 65 | |
| 10 | Nascent Soul Lower | 70 | choice · +1 learnable skill |
| 11 | Nascent Soul Middle | 75 | |
| 12 | Nascent Soul High | 80 | |
| 13 | Immortal Lower | 85 | choice · +1 learnable skill |
| 14 | Immortal Middle | 90 | +1 slot-development step |
| 15 | Immortal High | 95 | +1 slot-development step |

- **The choice at a stage breakthrough:** the monster takes one of **Breadth** (a new slot, up to 6), **Depth** (a development step for one slot, [skills.md §8](skills.md#8-development)), **Lore** (one skill of another species of its Kin joins what it can learn) and **Reshape** (its stat points are spent anew, [§2.3](#23-shapes-and-spending)). Every monster has the same choice.
- **Slot-development step** (steps 14 and 15): the monster develops one skill slot.
- **Learnable skills:** the species list grows by one with each breakthrough from Foundation to Immortal.
- Breakthrough trials: [overworld.md §5.2](overworld.md#52-the-breakthrough-trial).

**A monster rises by battles won; there is no XP.**

- **In the wild:** every wild monster defeated in a battle won leaves one rise. A rise lifts one monster of the team that fought and still stands, if the defeated monster was at its step or above. One rise per monster and battle, one step, never past High.
- **Who rises:** where the rises reach for every monster that could take one, each takes one; where they do not, the player chooses. A rise not given is lost with the next battle.
- **In the void:** every monster that fought in a battle won there and still stands rises a step, whatever its step: also from High into the next stage, never past the stage of the tamer. The breakthrough trial lifts the tamer first, so the team that won it follows.
- **By a pill:** a Growth pill of the Alchemist is one rise, never past High ([overworld.md §6.2](overworld.md#62-pills)).
