# Content

**Everything in this file is a working draft:** names, numbers and assignments are untested examples, not approved content. The rules they follow are in [battle.md](battle.md), [skills.md](skills.md) and [monsters.md](monsters.md). The data itself lives in `godot/data`, one file per record.

## 1. Ground

**Multiplayer battle:** a ground is named by what it does: the moment, the effect, “Ground”.

| | Damage | Heal | Stamina |
|---|---|---|---|
| **Entry** (on entering) | Entry Damage Ground: 1 damage | Entry Heal Ground: 1 HP | Entry Stamina Ground: 1 Stamina |
| **Exit** (on leaving, also by push or pull) | Exit Damage Ground: 2 damage | Exit Heal Ground: 1 HP | Exit Stamina Ground: 1 Stamina |
| **Stay** (end of the occupant's turn) | Stay Damage Ground: 1 damage | Stay Heal Ground: 1 HP | Stay Stamina Ground: 1 Stamina |

**No-Prop Ground:** no prop can be placed on it; it does nothing to monsters. Healing never exceeds the maximum HP, Stamina never the pool.

**Both battles:**

| Ground | Moment | Effect |
|---|---|---|
| **Plain** | — | movement cost 1 |
| **Rubble** | on entering | movement cost 2; left by several destroyed props |
| **Voidscar** | end of the occupant's turn | 1 damage; permanent; nothing creates it at present |
| **Dragon Vein** | end of the round | 1 damage to the monster or prop on it; damages the nearest enemy of its owner; permanent |

**Ingame battle:**

| Group | Ground | Moment | Effect |
|---|---|---|---|
| Hazard | **Lava** | end of the occupant's turn | 1 damage: punishes staying |
| Hazard | **Thornbed** | on entering | 1 damage: punishes moving in |
| Hazard | **Binding Vines** | on leaving | 2 damage: stay or pay; may be laid under a monster |
| Blessed | **Mossbed** | on entering | heals 1, never above max HP; no re-entry limit |
| Blessed | **Springwater** *(experiment)* | on entering | +1 Stamina, never above the pool |
| Neutral | **Shifting Sand** *(experiment)* | — | no prop can be placed on it |

## 2. Zones

| Battle | Zone | Effect |
|---|---|---|
| Multiplayer | **Push Zone** | `push` |
| Multiplayer | **Pull Zone** | `pull` |
| Ingame | **Gale** | `push`; its own skill |
| Ingame | **Void Pull** | `pull`; its own skill, Coiling Rift |

Every zone a skill creates lasts 2 rounds.

**Generated skills of the multiplayer battle** are named the same way: a Strike is a “Push Strike” or, when it only damages props, a “Prop Strike”, with its shape in front (“Cross Push Strike”); a skill that lays something carries the name of the ground or zone.

## 3. Props

| Prop | HP | Traits | When | What | Where |
|---|---|---|---|---|---|
| Stone Lion | 3 | `heavy`, `spiky` | destroyed | leaves Rubble | own square |
| Earth Wall | 2 | — | — | nothing: it blocks and covers | — |
| Clay Urn | 1 | — | destroyed | 1 damage | the 8 squares around it |
| Bamboo Stand | 2 | `spiky` | destroyed | 1 damage | the 4 neighbours |
| Thorn Idol | 3 | — | hit | 1 damage | the 8 squares around it |
| Ember Brazier | 2 | — | end of the turn of a monster in its shape | 1 damage to that monster | the 4 neighbours |
| Storm Drum | 2 | — | end of the round · destroyed | pushes 1 square away from it · leaves Rubble | the 4 neighbours · own square |
| Bronze Gong | 2 | — | destroyed | pushes 1 square away from it | the 8 squares around it |
| Temple Bell *(experiment, draft values)* | 3 | — | hit | pushes 1 square away from it | the 8 squares around it |
| Vortex Urn | 1 | — | destroyed | pulls 1 square toward its square | the 8 squares around it |
| Paper Lantern | 1 | — | destroyed | leaves Lava I | own square |
| Peach Tree | 2 | — | destroyed | leaves Mossbed | own square |
| Ancestor Tablet | 2 | — | destroyed | leaves Mossbed | own square |
| Pagoda Column | 3 | — | destroyed | creates a Beam on every free neighbour · leaves Rubble | the 4 neighbours · own square |
| Beam | 1 | board only | — | nothing | — |
| **Spike Trap** | 1 | walkable | entered | 2 damage to the monster that entered | own square |
| **Burst Trap** | 1 | walkable | entered | 1 damage; nothing to the monster that entered | the 8 squares around it |
| **Vortex Trap** | 1 | walkable | entered | pulls 1 square toward its square; who is pulled into the monster on it collides, every collision counts | the 4 neighbours |
| Moss Rune | 1 | walkable, board only | entered | lays Mossbed | the 3×3 block around and under it |
| Bog Rune | 1 | walkable, board only | entered | creates the zone Void Pull | the 8 squares around it |
| Wall Rune | 1 | walkable, board only | entered | creates an Earth Wall on every free square | the 4 neighbours |

- **Created by skills:** Bamboo Stand, Bronze Gong, Earth Wall, Thorn Idol, Ember Brazier, Storm Drum, Clay Urn, Spike Trap, Vortex Trap.
- The three runes and the Temple Bell carry the status `experiment`; the Temple Bell is placed only by hand (map editor, skill builder).

## 4. Skills

**The skills are examples; their AP costs are not settled.** “Where” names the shape: a base shape around the user, or the number of squares of a free shape with its default arrangement.

| Skill | Cost | Where | Strike | Movement | On itself | Ground | Zone | Prop |
|---|---|---|---|---|---|---|---|---|
| Step *(every monster)* | 1 AP | neighbouring square | — | 1 square, cardinal, no Stamina | — | — | — | — |
| Basic Jab *(every monster)* | 2 AP, once per turn | Jab | 1 damage to a monster or prop, no push | — | — | — | — | — |
| Run | 1 AP + Stamina | path, range 3 | — | walks | — | — | — | — |
| Leap | 2 AP + Stamina | path, range 3 | — | straight line over everything | — | — | — | — |
| Glide | 2 AP + Stamina | path, range 3 | — | any path over props and monsters | — | — | — | — |
| Headbutt | 2 AP + Stamina | path, range 3 | — | straight line over everything; pushes the monster ahead | — | — | — | — |
| Quake Leap | 2 AP + Stamina | path, range 3 | — | straight line over everything; pushes all eight neighbours on landing | — | — | — | — |
| Fire Trail | 2 AP + Stamina | path, range 3 | — | straight line over monsters | — | Lava on the squares left | — | — |
| Jab | 2 AP | Jab | push 1, damages props | — | — | — | — | — |
| Thrust | 3 AP | Jab +1 | push 1, damages props | — | — | — | — | — |
| Shove | 1 AP | Jab | push 1 | — | — | — | — | — |
| Thorn Lash | 2 AP | Jab | push 1, damages props | — | — | Thornbed | — | — |
| Snare | 2 AP | Reach, 1 square, also under a monster | — | — | — | Binding Vines | — | — |
| Lava Field | 1 AP | Reach, 4 squares (default: block 2×2) | — | — | — | Lava | — | — |
| Thornbed | 1 AP | Reach, 3 squares (default: angle) | — | — | — | Thornbed | — | — |
| Gloom Rift | 1 AP | Reach, 3 squares (default: line) | — | — | — | Lava | — | — |
| Cinder Dive | 1 AP | Jab +2 (line of 3 from the user) | — | — | — | Lava | — | — |
| Coiling Rift | 2 AP | Reach, 4 squares | — | — | — | Lava | Void Pull | — |
| Gale | 1 AP | Reach, 3 squares (default: line) | — | — | — | — | Gale | — |
| Void Pull | 1 AP | Reach, 3 squares around the square it pulls to | — | — | — | — | Void Pull | — |
| Plant Bamboo | 1 AP | Reach, 1 free square | — | — | — | — | — | Bamboo Stand |
| Set Gong | 1 AP | Reach, 1 free square | — | — | — | — | — | Bronze Gong |
| Earth Wall | 2 AP | Reach, 3 squares (default: line) | — | — | — | — | — | an Earth Wall on each |
| Set Thorn Idol | 1 AP | Reach, 1 free square | — | — | — | — | — | Thorn Idol |
| Light Brazier | 2 AP | Reach, 1 free square | — | — | — | — | — | Ember Brazier |
| Set Storm Drum | 1 AP | Reach, 1 free square | — | — | — | — | — | Storm Drum |
| Set Clay Urn | 1 AP | Reach, 1 free square | — | — | — | — | — | Clay Urn |
| Lay Spikes | 1 AP | Reach, 1 square | — | — | — | — | — | Spike Trap |
| Lay Vortex | 1 AP | Reach, 1 square | — | — | — | — | — | Vortex Trap |
| Battle Trance *(experiment)* | 1 AP, once per battle | self | — | — | AP +1 for 2 rounds | — | — | — |
| Time Split *(experiment)* | 3 AP, once per battle | self | — | — | one more turn in the next round | — | — | — |

**AP of a Strike that pushes and damages props, by shape** (shapes without a value have none yet):

| Shape | AP | | Shape | AP |
|---|---|---|---|---|
| Jab | 2 | | Whirl | 3 |
| Jab +1 | 3 | | Whirl +1 | 5 |
| Pincer | 3 | | Cross | 3 |
| Arc | 3 | | Cross +1 | 5 |
| Arc +1 | 5 | | Storm | 4 |

**Passive candidates** (no numbers, not in the game): Thick Hide and Crashlander (collision damage it takes −1) · Heatproof / Thornwalker (ignores Lava / Thornbed) · Scavenger (heals 1 when a prop within its Reach is destroyed) · Purifier (enemy zones next to it lose 1 round at the round end) · Turret (cannot move, Reach +1) · Pack Hunter and First Blood (lower AP costs) · Frenzy (+1 shape square at 1–2 HP).

**Candidates for what a slot development may change:** one more extension of a base shape or one more square of a free shape, a longer zone, a longer range or a movement that passes over more, a second thing created, one more use per turn.

## 5. The Nine Monsters

Stats read HP / Pace / Stamina / turns / Reach / AP. Every monster costs exactly 60 points ([monsters.md §2.2](monsters.md#22-prices-and-points)).

| Monster | Kin | Themes | Stats | Kit |
|---|---|---|---|---|
| **Blaze Tiger** | Beast | flame, hunting | 5 / 2.2 / 5 / 1 / 2 / 3 | Fire Trail · Jab · Thrust · Headbutt · Lava Field · Light Brazier |
| **Ember Hawk** | Winged | embers, flight | 3 / 2.2 / 5 / 2 / 2 / 2 | Glide · Jab · Shove · Cinder Dive · Gale · Lay Spikes |
| **Dusk Moth** | Winged | dusk, eclipse | 4 / 2.1 / 3 / 1 / 4 / 3 | Run · Jab · Gloom Rift · Void Pull · Snare · Lay Vortex |
| **Forge Golem** | Stone | forge, stone | 8 / 1.0 / 1 / 1 / 3 / 3 | Jab · Thrust · Gale · Lava Field · Set Gong · Earth Wall |
| **Gloom Wolf** | Beast | gloom, pack hunting | 5 / 2.1 / 3 / 1 / 3 / 3 | Run · Thorn Lash · Shove · Gloom Rift · Plant Bamboo · Lay Spikes |
| **Grove Wisp** | Spirit | grove, wandering light | 4 / 2.2 / 5 / 1 / 3 / 3 | Quake Leap · Jab · Gale · Thornbed · Snare · Set Thorn Idol |
| **Hollow Serpent** | Scaled | hollow, coils | 6 / 1.4 / 4 / 1 / 3 / 3 | Run · Jab · Shove · Coiling Rift · Thornbed · Lay Vortex |
| **Moss Turtle** | Scaled | moss, shell | 7 / 1.1 / 3 / 1 / 3 / 3 | Run · Jab · Shove · Void Pull · Thornbed · Earth Wall |
| **Thorn Mites** | Swarm | thorns, infestation | 6 / 1.1 / 3 / 2 / 2 / 2 | Glide · Jab · Thorn Lash · Thornbed · Void Pull · Set Clay Urn |

- **Kit rule for these nine:** every kit holds a Strike, a skill that moves others, one that creates ground and one that creates a prop; every monster but the Forge Golem has a movement skill.
- **The kits ignore Kin access;** learnable lists do not exist yet.

**Ideas for further species:** Vine Panther (Beast) · Gale Crane (Winged) · Magma Drake (Scaled) · Cinder Wasps, Grave Rats (Swarm) · War Echo, Wailing Shade (Spirit) · Bone Colossus (Stone) · Elder Treant (Flora).

## 6. Example Monsters per Stage

What the points of [monsters.md §2.2](monsters.md#22-prices-and-points) buy at each Lower sub-tier (HP / Pace / Stamina / turns / Reach / AP; every row spends its points exactly):

| Stage (points) | Sturdy | Turns or AP | Fast |
|---|---|---|---|
| Qi Gathering (25) | 4 / 1.0 / 1 / 1 / 2 / 2 | 3 / 1.3 / 2 / 1 / 2 / 2 | 2 / 1.6 / 3 / 1 / 2 / 2 |
| Foundation (40) | 6 / 1.0 / 1 / 1 / 3 / 2 | 3 / 1.0 / 1 / 2 / 2 / 2 | 3 / 1.6 / 3 / 1 / 2 / 3 |
| Core Formation (55) | 8 / 1.3 / 2 / 1 / 3 / 2 | 5 / 1.1 / 3 / 2 / 2 / 2 | 4 / 2.1 / 3 / 1 / 3 / 3 |
| Nascent Soul (70) | 10 / 1.0 / 1 / 1 / 3 / 3 | 4 / 1.1 / 3 / 2 / 3 / 3 | 5 / 2.7 / 5 / 1 / 3 / 3 |
| Immortal (85) | 10 / 1.9 / 4 / 1 / 3 / 3 | 7 / 1.1 / 3 / 2 / 3 / 3 | 6 / 2.4 / 4 / 1 / 3 / 4 |

## 7. Kins

**Draft, not played.** The traits are built ([godot/README.md](../godot/README.md), "Kin traits in the battle"). The rules: [monsters.md §3](monsters.md#3-kins). A trait is a passive that takes no slot; it uses only moments and effects the battle already has, and is shown on the monster's sheet. A Kin has no further passives.

**Trait and skill groups** (every Kin learns four of the six groups; Step and Basic Jab stay with every monster):

| Kin | Trait | Learns | Never learns |
|---|---|---|---|
| **Beast** | **Follow-up:** after its Strike pushed a monster, it may enter the square that monster left, free of AP and Stamina; this is movement | Strike · movement · self · ground | zone · prop |
| **Winged** | **Aloft:** ground does not act on it on entering or leaving; end-of-turn ground and traps act as usual | movement · self · ground · zone | Strike · prop |
| **Scaled** | **Armoured:** takes no collision damage when it is the one moved; what it is moved into takes its damage | Strike · self · ground · prop | movement · zone |
| **Swarm** | **Scatter:** its Step may enter the square of an ally; the two swap, which is movement for both | Strike · movement · ground · prop | self · zone |
| **Spirit** | **Bodiless:** its movement passes over monsters; it cannot end on one | movement · self · zone · prop | Strike · ground |
| **Stone** | **Bulwark:** gives cover like a solid prop: a Strike that hits it does not strike the square behind it | Strike · self · zone · prop | movement · ground |
| **Flora** | **Rooted Growth:** ground it lays lasts 3 rounds | Strike · ground · zone · prop | movement · self |
| **Void** | **Unmoored:** push and pull zones do not move it | Strike · movement · ground · zone | self · prop |

- A movement skill that pushes on landing counts as movement, a Strike that leaves ground as a Strike: the group is what the skill is, not what it creates besides.
- The group “self” holds few skills so far ([§4](#4-skills)).

The kits of the nine monsters of [§5](#5-the-nine-monsters) ignore the groups; the test species and learnable lists of the build are no content drafts.
