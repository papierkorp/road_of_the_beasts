# Battle Rules

Turn-based, isometric monster battles about **grid control**, deterministic and readable.

- **This file owns** the rules of a battle: flow, timing, the board, what ground, zones and props are, damage and displacement.
- **Elsewhere:** what only the ingame battle has ([battle_ingame.md](battle_ingame.md)), what a skill is ([skills.md](skills.md)), what a monster is ([monsters.md](monsters.md)), every concrete ground, zone, prop, skill, kit and monster ([content.md](content.md)), meta progression and tamer skills ([overworld.md](overworld.md)).
- **Status:** rules are decided unless a section says “working value”. Working values are untested numbers. **The multiplayer battle as written here is settled for now;** a change needs a new reason.

## 1. Goals and Pillars

**Two battles, one core:** the **multiplayer battle** and the **ingame battle** both play this file; each adds rules, content, boards and balance of its own, and nothing balanced for one binds the other.

**Goals of both battles** (rules, content and prices are judged against them):

- **Deterministic:** no dice, no hidden information.
- **Simple to learn, hard to master:** few uniform rules, no hidden abilities; everything a monster can do is visible.
- **Influence and consequence:** the player's decisions shape the board and the course of the battle, visibly.
- **Won by tactics and strategy:** repeating one skill must not win a battle; position and combination decide. Skill variety matters: each skill is the right choice in some situations and none in all.
- **Monsters differ:** different monsters offer different ways to play. That is what the stat calculation is for: every stat matters, and monsters must not all come out alike.
- **Square control is the basic aim.**

**Goals of the multiplayer battle only:**

- **No helpless defeat:** no monster is defeated without its player having had a chance to act: every monster gets at least one turn, and best no monster falls in round 1.
- **Win condition:** the battle ends when every monster of one side has 0 HP.
- **Not endless:** a **mean of 3.5–4.5 rounds**; a battle counts the round it ends in.
- **Always 3v3,** on a generated, point-symmetric 7×7 board ([§4.1](#41-board-generation)).
- **No fixed monsters or skills:** they are generated or drafted for a battle; both players get the same pool or each their own. A player can save monsters and skills of their own. The draft is not defined.

The goals of the ingame battle: [battle_ingame.md §1](battle_ingame.md#1-the-two-battles).

**Pillars** (the means):

1. **Control squares, not just units.** A skill acts through a Strike, movement, an effect on its user, or by creating ground, a zone or a prop. The board is the weapon.
2. **Deterministic and readable.** Before confirming, the player sees which squares a skill takes, what it creates there and where every pushed monster lands.
3. **A square has two layers with one role each.** Ground acts at a moment; a zone acts while a monster stands in it. A monster or a prop occupies the square. There is no height, no air layer and no delayed area attack.
4. **A skill only delivers.** What a ground, a zone or a prop does, and when, is written once in its own definition; a skill names what it creates.
5. **Fair damage.** Damage from a distance never hits a monster that has had no turn of its own since the cast ([§6.1](#61-damage)).
6. **Small HP, small hits.** The highest single hit is 2 *(working value)* and HP ends at 10. A monster with 3 or more HP never falls to one hit; HP 1 and 2 exist and are a risk their owner chose.
7. **Hold the Dragon Veins.** Square control is the way to the win condition: a Dragon Vein works for the side that touched it last, and whoever waits loses HP.
8. **Being moved is movement.** Every effect that reacts to entering or leaving a square also reacts to a push or pull.
9. **One skill source.** No aspects, no element triangle, no attunement.

## 2. Modes and Battle Flow

### 2.1 Modes

The multiplayer battle is always **3v3 on 7×7**. Every other team size, equal or unequal, belongs to the ingame battle ([battle_ingame.md §2](battle_ingame.md#2-team-sizes-and-the-end-of-a-battle)).

### 2.2 Core Loop

1. The battlefield is generated ([§4.1](#41-board-generation)).
2. Pre-battle: choose monsters and place them in the start area. The sides place alternately and openly, one monster at a time; which side places first is not defined. Monsters start at their **current HP**.
3. **Each round:** one queue for all monsters of both sides ([§2.3](#23-pace-and-the-queue)).
4. **A monster's turn:** it spends AP and Stamina on legal actions ([§2.4](#24-action-points-and-stamina)), then its end-of-turn effects resolve ([§3](#3-timing)).
5. The round ends with the round-end events ([§3](#3-timing)).
6. **End of battle** (when a side has no monsters left; the ingame battle may name other ends): a side may concede during a turn of one of its own monsters, which ends the battle at once as its defeat. Otherwise the end is checked after a payload has fully resolved, including its defeats. The battle then ends at once and anything still pending lapses. If both sides have no monsters left after the same resolution, the result is a **Draw**.

### 2.3 Pace and the Queue

**Pace** orders the round. The whole number of a monster's current Pace is the Stamina it recovers at the round end ([§2.4](#24-action-points-and-stamina)) and, above 1, its number of Waits; the Pace of the monster that took a Dragon Vein orders the veins ([§4.2](#42-dragon-veins-surrounding-and-late-round-pressure)).

- **One queue for both sides**, strictly by effective Pace, **recalculated every round**. A side may act several times in a row.
- **Pace points:** Pace counts in points of 0.1. An effect names points (`drain_pace 1` lowers Pace by 0.1). Effective Pace never falls below 0.1.
- **Ties:** higher base Pace first; still tied, the sides alternate (the first tie of a battle goes to the side with the lower total Pace; if the totals are equal, to the player's side). Tied units of one side act in their start slot order (slot 1 first). An extra-turn entry follows its unit's main entry. Meta state never breaks ties.
- **Extra turns:** a monster with more turns per round gets one extra queue entry per extra turn, each 2 Pace points (0.2) lower than the entry before, minimum 0.1 *(working value)*. **Extra turns count from round 2:** in round 1 every monster has exactly one entry.
- **Wait:** a monster may postpone its turn to the end of the round, before it has done anything and at most once per round. It has as many Waits per battle as the whole number of its current Pace lies above 1 (2.x: one, 3.x: two). Monsters that waited act in reverse order: the first to wait acts last.
- **Effects bound to a unit** (buffs, marks) end at once when that unit is defeated or removed. Zones, ground and props stay when their creator is defeated.

### 2.4 Action Points and Stamina

**AP per turn = the monster's AP stat.** **Stamina** is a pool that pays for movement and for Heal.

- An action costs the AP on its card, at least 1.
- **Step** (every monster): 1 AP, 1 square, no Stamina.
- **Basic Jab** (every monster): 2 AP, 1 damage to the monster or prop on a neighbouring square, no push, once per turn. The only direct damage to a monster.
- **Heal** (every monster): 3 Stamina, no AP, 1 HP back up to the maximum, once per turn.
- **Repetition:** each equipped skill may be used once per turn of its monster unless its card names more uses, once per round or once per battle ([skills.md §2](skills.md#2-the-skill-card)).

| Stamina | Rule |
|---|---|
| Pool | The monster's Stamina stat; full at the start of a battle |
| Cost | A movement skill costs its AP **and** Stamina for every square it enters: the movement cost of that square's ground. A path that passes over squares (straight line, any path) costs 1 per square of its distance |
| Range | A movement skill reaches at most the range on its card (3 squares unless it names another) and never further than the Stamina left |
| Free | Step, being pushed or pulled |
| Recovery | At the round end every monster recovers the **whole number of its current Pace, at least 1**, never above its pool. The current value counts: a timed effect on Pace changes the recovery when it carries the monster across a whole number (Pace 2.0 with a drain of 1 recovers 1; Pace 1.9 with `quicken` 1 recovers 2) |

*Working values:* the range of 3 and every cost.

## 3. Timing

**The one timing reference** for everything that acts by itself. A definition names one of these moments. **Nothing acts at the start of a turn or of a round.**

| Moment | When | What acts |
|---|---|---|
| now | when the skill is used | a Strike; the user's own movement; the creation of ground, a zone or a prop (a push or pull zone moves nobody when it is cast) |
| on entering | a monster enters the square by walking, a push or a pull | ground with an entry effect; a walkable prop on the square; a Dragon Vein changes its owner |
| on leaving | a monster leaves the square by walking, a push or a pull | ground with a leaving effect |
| end of the occupant's turn | when the monster's turn ends | 1. zone push or pull → 2. end-of-turn ground on the square it now stands on → 3. the damage of a prop in whose shape it now stands |
| end of the round | after the last turn of the round | see below |
| on an event | when it happens | collision damage; a prop that is hit and still stands; a prop that is destroyed |

**The round end: first everything moves, then everything acts, then all clocks tick.**

1. Push and pull zones move the props standing in them.
2. Props that push or pull at the round end act, in one step. What reacts to entering or leaving fires at the move. Zones that damage props act.
3. Surround damage in one step, then the Dragon Veins one after another ([§4.2](#42-dragon-veins-surrounding-and-late-round-pressure)).
4. Stamina recovery by the current Pace.
5. All clocks: zones lose a round, timed effects on monsters expire, ground laid in battle fades, props a skill created lapse ([§4.4](#44-lifetimes)).
6. The queue is built anew.

- **Nothing but Dragon Veins and surrounding deals damage at the round end:** no ground and no prop does. A monster pushed onto end-of-turn ground or next to a damaging prop at the round end takes nothing then and can still leave in its next turn; ground that acts on entering fires at the push.
- **Clocks last:** a thing that lasts N rounds still counts at its N-th round end. An effect in its last round still counts for the Stamina recovery.
- **Inside a turn:** every action resolves completely, including the pushes, entries and departures it causes ([§6.2](#62-payload-resolution)); then the end effects.
- **Placing ground under a monster is not entering:** it acts at its next moment, not at once.
- **Event-driven reactions** (passives): they collect during a payload and resolve after its last step, one at a time in the queue order of the reacting units, on the board as it then stands. Their consequences apply normally but trigger no further reactions; each passive reacts at most once per triggering event. Defeated units do not react.

## 4. The Board

### 4.1 Board Generation

*Multiplayer battle only.*

- Ground and props are generated **point-symmetric around the centre**, so both sides get the same distances.
- **Props** are placed only as point-mirrored pairs; the centre square of an odd board never holds one. A pair may start on Dragon Veins.
- **Board distance:** Chebyshev, `max(|dx|, |dy|)`; diagonals count like orthogonal steps. **Reach is the exception:** it counts orthogonal steps ([skills.md §2](skills.md#2-the-skill-card)).

| Board | Start area per side | Dragon Veins | Props *(working values)* |
|---|---|---|---|
| 7×7 | back two rows; players place their monsters | 3 on the centre row (x = 1, 3, 5) | 4 or 6 |

### 4.2 Dragon Veins, Surrounding and Late-Round Pressure

*Working values: every number in this section.*

- **Dragon Vein:** a ground type that nothing changes. Otherwise it is ordinary ground: a prop may stand on it and a zone may lie on it; only no ground is laid on it.
- **Ownership by last touch:** a Dragon Vein belongs to the side whose monster touched it last (walked onto or across it, was pushed or pulled onto it, or stands on it). It stays with that side until a monster of the other side touches it. At the start nobody owns one. A prop touches nothing: a solid prop on a vein blocks the square, and the vein keeps working for its owner.
- **Dragon Vein damage:** at the round end every owned Dragon Vein deals **1 damage, from round 3 on 2, to the nearest enemy of its owner** (board distance). Ties: the enemy with more HP, then with more Pace, then **the owning side chooses**.
- **The veins act one after another,** the vein of the faster taker first: the taker is the monster that took the vein for its side (a later touch by an ally does not change it); its current Pace counts, then the queue order. A vein whose taker has fallen acts last. Each vein picks its target on the board as it then stands, defeats are resolved after each, and the battle ends as soon as one side is gone.
- **Surrounding:** at the round end a monster with **two or more enemies on its eight neighbour squares** takes 1 damage, all in one step before the veins.
- No source reduces Dragon Vein or surround damage.
- **No late-round pressure:** nothing shrinks the board or punishes waiting; the Dragon Veins are the brake.

### 4.3 The Square: Ground, Zone and Occupant

```
[ OCCUPANT ]  one monster | one solid prop | a walkable prop, alone or under a monster | empty
[ ZONE     ]  ONE timed zone | empty — pushes or pulls who ends a turn inside
[ GROUND   ]  ONE ground type — acts at a moment
```

- **One ground, one zone, one occupant per square;** all three can be active at once.
- **A zone is what you do to a square for a while; ground is what the square does at a moment; a prop is a thing on the square that acts around itself.**
- **Ground and zone are independent:** neither changes, suppresses or inverts the other; they combine only through their separate effects on the same square.
- **A prop does not shield its square:** ground and zones are laid on a prop square like on any other and act on whoever stands there once the prop is gone.
- A solid prop prevents monster occupancy; a monster prevents the placement of a solid prop.

### 4.4 Lifetimes

| Thing | Clock |
|---|---|
| **Zone** | the rounds its creating skill names; loses one at each round end. Cast again on the same squares it refreshes |
| **Ground laid in battle** | **2 rounds** (the round it is laid in and the next one), then Plain again. The clock restarts whenever it is laid again. It acts at every one of its moments as long as it lies |
| **Ground of the starting board, Voidscar, Dragon Vein** | none; Voidscar and Dragon Vein are never changed by anything |
| **Prop a skill created** | **2 rounds**, like ground, then it lapses without acting; earlier when its HP are gone. A trap is used up by the monster that enters it |
| **Prop of the board** | none; it stays until its HP are gone |
| **Timed effect on a monster** | N rounds: until the end of the N-th following round; it ends earlier with its bearer |

What a skill lays is temporary: permanent hazards fill the board and make waiting pay.

### 4.5 Ground

**Ground acts at a moment:** it damages, heals or costs Stamina when a monster enters it, leaves it or ends its turn on it. It changes no stat and has one level.

- **Made by:** a skill, on its squares (a placed shape, the square a Strike hit, the squares a movement left; also under a prop), or a destroyed prop that leaves ground. Never on Voidscar or a Dragon Vein.
- **Same type on the square:** its clock restarts. **Different type:** the new ground replaces the old one.
- Ground works for **everyone** on it.
- Ground types: [content.md §1](content.md#1-ground).

### 4.6 Zones

**A zone pushes or pulls:** a monster that ends its turn inside is moved 1 square. A third kind damages the props standing in it at the round end (1 damage) and does nothing to monsters. A zone changes no stat, never damages or heals a monster and has one level.

| Effect | When | Action | Opposite |
|---|---|---|---|
| `push` | end of the occupant's turn | move 1 in the zone's direction | `pull` |
| `pull` | end of the occupant's turn | move 1 toward the zone's anchor square | `push` |

- A zone moves **everyone** on the square: allies, enemies and the caster.
- **Direction of a push zone:** cast alone, the direction is chosen with the cast. Left by a skill that also creates something else, it points where the placement is turned; left by a Strike, in the Strike's direction; left on the path of a movement, the way the monster went.
- **Counterplay:** do not end your turn in a current.

**A zone lands on a square that already holds one:**

| Existing zone | Result |
|---|---|
| none | new |
| the same zone | refreshes to its full duration |
| an opposite | both cancel and the square is empty |
| anything else | replaced |

A square always shows exactly one zone. Zone types: [content.md §2](content.md#2-zones).

### 4.7 Props

**A prop is a thing on a square that acts around itself.** It has HP, stays until they are gone, and acts at its moments on the squares of its shape.

| | Solid prop | Walkable prop |
|---|---|---|
| Square | no monster shares it | a monster stands on it, walks onto it or is pushed onto it |
| Movement | blocks the way | blocks nothing |
| Strike | takes the hit and **shields the square behind it** | can be struck; shields nothing |

- **Cover:** a solid prop takes a Strike and the square behind it is not struck. “Behind” is exact: in an extended shape every square has one square in front of it ([skills.md §4](skills.md#4-shapes)). Walkable props and monsters give no cover. Cover exists for Strikes only: nothing blocks choosing a square for ground, a zone or a prop.
- **Trap:** a walkable prop with an entry effect. It acts when a monster enters its square (walking, push or pull) and is then used up; the monster continues as its move allows. Traps are open information: the movement preview shows the harm. **A solid prop springs a trap:** created on or pushed onto a trap, it sets the trap off and takes its square.
- **Moments of a prop:** when destroyed, when hit (it lost HP and still stands), when entered (walkable props), at the end of the turn of a monster in its shape (damage), at the round end (push or pull).
- **Fixed, previewed effects:** what a prop does is fixed by its type, independent of who or what set it off and from which direction. **No chain reactions:** prop damage hits monsters only, never props.
- **No indestructible prop.**
- **What damages a prop:** a Strike whose card names damage deals 2 to every prop in its shape, the Basic Jab 1, a collision 1. A Strike without damage moves a prop but does not damage it. Ground, zones and movement do not damage props.
- **Tags:** `heavy` (cannot be displaced and takes no collision damage) and `spiky` (deals 2 instead of 1 collision damage to a monster displaced into it) *(working values)*.
- **Zones and props:** a push or pull zone moves a prop standing in it at the round end.
- **Created by a skill:** on a square that can take it. A created prop needs a square free of props and monsters. Board generation may pre-place any prop type.

**Resolution:**

- **One step per moment:** everything the props of one moment do resolves together: damage, defeat, new props, ground, zones, then pushes and pulls. Damage from several props on one monster adds. (At the round end the pushes and pulls come first, [§3](#3-timing).)
- **Destroyed:** a prop at 0 HP stays on the board and keeps blocking until the removal step of the payload ([§6.2](#62-payload-resolution)); then all 0-HP props are removed together and what they do is evaluated against the board as it stands.
- **Hit:** a prop that lost HP and still stands acts in the next board step, all such props together.
- After a pull toward a destroyed prop the first monster to arrive takes the square, the others collide.
- A prop that names no ground leaves the ground under it as it is. Ground left behind never replaces Voidscar or a Dragon Vein.

Prop types: [content.md §3](content.md#3-props).

### 4.8 One Sheet for Ground, Zones and Props

Every ground, zone and prop reads as a head plus lines of **when · what · how much · where**.

| Head | Ground | Zone | Prop |
|---|---|---|---|
| Lies as | ground layer | zone layer | occupant: solid, or walkable under a monster |
| Ends by | 2 rounds when laid in battle; other ground replaces it | the rounds its skill names; an opposite zone | 0 HP; 2 rounds when a skill created it; a trap when it is entered |
| Acts on | who stands on the square | who stands on the square | the squares of its shape; a trap: who entered it |
| Numbers | movement cost 1–2 | — | HP 1–3 |

| Line part | Vocabulary |
|---|---|
| When | the moments of [§3](#3-timing) |
| What | damage · healing · range of movement skills ± · Pace ± · Reach ± · push · pull · creates ground, a zone or a prop |
| How much | damage 1–2; a stat change by its value; push and pull 1 square |
| Where | the square itself, or a shape around a prop: the 4 neighbours, the 4 diagonals, the 8 around, each with extensions, or the full block 3×3 / 5×5. A prop has no direction |

**Roles** (which kind may use which moment and effect):

| | Ground | Zone | Prop |
|---|---|---|---|
| on entering | yes | — | walkable props only |
| on leaving | yes | — | — |
| while inside | — | — | on its shape |
| end of the occupant's turn | yes | push, pull | damage |
| end of the round | — | — | push, pull |
| when hit, when destroyed | — | — | yes |
| damage | yes | **never** | yes |
| healing | yes | **never** | — |
| stat changes | **never** | **never** | yes |
| push, pull | — | yes | yes |
| creates ground, a zone or a prop | — | — | yes |

Three kinds stay: a hazard and a current can lie on the same square.

## 5. Monsters and Tamer in Battle

### 5.1 Effective Stats

Effective stats combine the sheet with every modifier: props that work while they stand and effects on the monster itself. Ground and zones change no stat.

- **Stacking:** the same source (same effect of the same owner) only refreshes its duration and never adds. Different sources add without a cap; only the floors apply (range of a movement skill and Reach min 1, Pace min 0.1).

| Stat | Changed in battle by |
|---|---|
| Pace | `quicken` / `drain_pace`: Pace ± value points; the Stamina recovery reads the same current value |
| Stamina | the pool changes only by moving and by recovery; `haste` / `slow`: a movement skill costs value less or more Stamina per use, never Step |
| Reach | `extend` / `drain_range`: Reach ± value (min 1) |

Identity comes from species, Kin, stats, skills and passives. Themes impose no matchup triangle and no combat modifier.

### 5.2 Tamer Skills

Tamer skills exist in the ingame battle only ([battle_ingame.md §5](battle_ingame.md#5-tamer-skills)).

## 6. Damage and Displacement

### 6.1 Damage

**The highest single hit is 2** *(working value)*.

- **Strike:** none against monsters: a Strike only pushes. What its card names as damage (2) hits the props in its shape.
- **Basic Jab:** 1, now, to the monster or prop on a neighbouring square.
- **Ground:** 1–2, each at its moment.
- **Collision:** 1; 2 for the moved monster at a `spiky` prop.
- **Prop:** 1–2 at its moment.
- **Dragon Vein and surrounding:** 1 each at the round end.
- **Zones never deal damage.** Nothing but the Basic Jab damages a monster the instant it is used.
- **Damage never scales by stage.**

**Fair damage at range:** damage from a distance never hits a monster that has had no turn of its own since the cast. At range a skill can only create ground or a prop; ground acts when a monster enters or leaves it or at the end of that monster's own turn.

**Calculation:**

- **One step:** damage = base + all increases − all reductions, then floored at 0. Order-independent. Each source modifies only the damage kinds it names. The maxima above limit the base; no source of increases exists.
- **Zero damage still hits:** a hit reduced to 0 damage is still a hit.
- **Same moment, net:** damage and healing from ground at the same moment resolve together: HP = min(max HP, HP − damage + healing).
- No defense stat exists; damage is reduced only by passives that say so. All damage is exact and previewed.

### 6.2 Payload Resolution

**A payload** is what one use of a skill does at once. Its steps always resolve in this order:

1. **Damage** to all struck props, and to the monster the Basic Jab struck, simultaneously. A solid prop takes the hit for the square behind it.
2. **Defeat:** units at 0 HP are removed before anything else resolves.
3. **Displacement** of the survivors, one unit at a time, **the unit furthest along the movement direction first** (for a pull: nearest the anchor first). Collision, leaving and entry effects fire at each move.
4. **Board changes**, in fixed order: (a) **removals:** every prop at 0 HP is removed with what it does when destroyed; monsters reduced to 0 HP by it are then defeated; (b) **prop placement**; (c) **ground:** what destroyed props leave, then what the skill creates; (d) **zones** the skill creates.

- What a payload creates lands after its displacement: a monster pushed by a Strike does not end in the ground that Strike leaves unless it stands there afterwards.
- **Legality at execution:** each square is checked on the board as it stands at that step. A square that is not legal does nothing; everything else resolves. No retargeting and no refund of AP.
- **Same square, same step:** competing changes resolve one after another in queue order of their sources.
- **Ties in displacement:** units competing for one destination, or equally far along different directions, resolve in their current queue order; the later one collides.

### 6.3 Collision

- Into a **solid prop:** no move, 1 damage to the monster (2 at a `spiky` prop) and 1 to the prop (`heavy` props take none). Onto a **walkable prop** the move happens.
- Into a **monster:** no move, 1 damage to each of the two.
- Against the **board edge:** no move, 1 damage to the moved monster *(working value)*.
- Collision damage is derived, not part of a skill. Passives that name it change only the damage of the monster they belong to.
- **A blocked move is no movement:** the monster does not leave its square, so ground that acts on leaving does not act.

### 6.4 Displacement

**One square per trigger**, with a previewed landing. Being pushed or pulled is movement: the monster leaves its square and enters the next one with every ground effect of both, springs a trap it is moved onto and takes a Dragon Vein it is moved onto. It costs no Stamina.

| Source | Direction |
|---|---|
| a Strike that pushes | every struck monster and prop moves 1 square away from the striker along the line of its square: **eight directions**; a square on no line (the outer corners of an extended Arc) in the facing of the shape |
| a movement that pushes on landing | the monster ahead: the direction of travel; all neighbours: outward, eight directions |
| a prop that pushes or pulls | away from the prop, or toward its square, along the offset: eight directions |
| a push zone | its direction: **cardinal** |
| a pull zone | toward its anchor: cardinal. On an exact diagonal (`|dx| = |dy|`) the pull does not move the target |

- **Props are displaced too:** every push or pull that moves a monster also moves a prop on the affected square by one square. A prop in a push or pull zone is moved once, at the round end. Props resolve after all monsters of the same step; the furthest along goes first. A blocked prop does not move and takes 1 damage; a monster in its way takes 1 (2 from a `spiky` prop), another prop in its way takes 1. Ground and zones do not act on a prop.
- Passives may make a monster immovable ([skills.md §6](skills.md#6-passives)).

## 7. Technical Requirements

- Godot 4, **3D square grid, orthogonal camera**, never hex. The player turns and tilts the camera freely.
- Round-end resolution reads the Dragon Vein squares actually on the board, not a fixed list.
- Architecture: [architecture.md](architecture.md); the build and its tools: [godot/README.md](../godot/README.md).
