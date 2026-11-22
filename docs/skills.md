# Skill Rules

- **This file owns** what a monster skill is: the kit, the skill card, shapes, movement kinds, passives, pricing principles and slot development.
- **Elsewhere:** what ground, zones and props do and how a battle resolves ([battle.md](battle.md)); every concrete skill and kit ([content.md](content.md)); tamer skills ([overworld.md §5.4](overworld.md#54-tamer-skills)).
- **Status:** the form of a skill is decided. Every number is a working value; no skill has a price.

## 1. The Kit

```
Monster = Step and Basic Jab (always, no slot)
        + up to 6 slots, each an active skill or a passive, at least one active
```

- **Step** (1 square, 1 AP, no slot) is the weakest movement. The **Basic Jab** (2 AP, 1 damage, no push, once per turn, no slot) is the only direct damage to a monster ([battle.md §2.4](battle.md#24-action-points-and-stamina)).
- No skill is mandatory, not even a Strike or a movement. The same skill may sit in two slots, each copy with its own usage count.
- **Slots:** the multiplayer mode plays with all six open; in the game a monster starts with four, and the fifth and sixth are a choice at a stage breakthrough ([monsters.md §5](monsters.md#5-growth)).
- **The player shapes the kit** within the species' learnable list ([monsters.md §3](monsters.md#3-kins)).
- **Species skills and Signature skills** are ordinary skills with restricted access, not a kind of their own ([monsters.md §3](monsters.md#3-kins)).

## 2. The Skill Card

**A skill only delivers.** It has a cost and one shape; it may strike around its user, move its user or act on its user, and it creates ground, a zone or a prop. What those do is written once in their own definitions ([battle.md §4](battle.md#4-the-board)).

| Part of the card | Content |
|---|---|
| **Cost** | AP · use (once per turn unless the card names more; once per round; once per battle) · a movement also Stamina per square; a passive has none |
| **Shape** | one shape per skill ([§4](#4-shapes)): a base shape around the user, or a free shape of N squares at an anchor |
| **Strike** | no · or a push of 1, damage to props, or both, now, on the squares of its base shape |
| **Movement** | no · or the path kind, what it passes over, its range and a push on landing |
| **On itself** | no · or a timed effect on the user (self buff) · or a lasting one (passive) |
| **Creates ground** | no · or which ground |
| **Creates zone** | no · or which zone, for how many rounds |
| **Creates prop** | no · or which prop |

- **Every effect hits everyone on its squares,** friend and foe.
- **Guideline:** a kit skill does one thing itself or creates one thing, at most two.
- Effects on AP or turns per round are rare and expensive and carry the content status `experiment`.

**Fixed, chosen and derived:**

| Part | Fixed on the card | Chosen by the player | Follows from stats and board |
|---|---|---|---|
| Cost | AP; use | — | Stamina per square of a movement |
| Strike | base shape and extensions; damage to props yes or no; push yes or no | direction | who stands in the shape; cover |
| Movement | path kind; what it passes over; range; push on landing | path and landing square | Stamina left; movement cost of the squares |
| On itself | effect and rounds, or lasting | — | — |
| Creates | which thing; the shape; the anchor rule; rounds of a zone | **before the battle:** the arrangement of a free shape · **in the turn:** direction or anchor square, quarter turn, direction of a push zone | Reach; which squares can take it |

**Usage:**

| Use | Meaning |
|---|---|
| N per turn (default 1) | this equipped copy at most N times per turn of its monster |
| once per round | one use in the global battle round; extra turns do not reset it |
| once per battle | one use in the battle |

- A use counts when the skill is used, whatever it then achieves; an illegal attempt spends neither AP nor a use. Later effects of what the skill created are no further uses.

**Place and shape:**

- **Base shape around the user:** a Strike hits its squares; a skill that creates lays its ground, zone or props on them. The player aims it; shapes without a direction need no aim.
- **Free shape:** the card names **a number of squares** and where the anchor may lie: **within Reach** or **next to the user**. **The player arranges the squares before the battle:** every square touches another over an edge or a corner, the anchor square among them. The arrangement authored with the skill is the default. In battle the arrangement is fixed; the player may still turn it in quarter turns. The opponent sees it on the skill card. A skill that creates props uses a free shape like any other.
- **Over the edge:** squares of a shape that lie off the board are dropped; the skill acts on the rest. At least one square must lie on the board, and the anchor of a free shape must.
- **Reach** counts orthogonal steps from the user to the anchor. It applies to every free shape placed at a distance; a base shape uses none.
- **No sight rule:** nothing blocks choosing a square. A square that cannot take what the skill creates stays as it is.
- **Never free:** the squares a Strike struck and the squares a movement left.
- Everything is previewed before the player confirms.

## 3. What a Skill Does and Creates

### Strike

- **Now, around the user:** a Strike acts on every monster and prop on the squares of its base shape.
- **A Strike deals no damage to monsters.** It pushes, it damages props, or both; one that does neither only delivers what it creates.
- **Push:** every struck monster and prop moves 1 square away from the striker ([battle.md §6.4](battle.md#64-displacement)), also on the farther squares of an extended shape.
- **Damage to props:** 2 to every prop in the shape, if the card says so.
- **Cover:** a solid prop takes the hit and the square behind it is not struck.
- **One hit per monster** per use, however many squares of the shape it covers.
- A Strike may create ground or a zone on the squares it struck; it creates no prop.

### Movement

- A movement skill moves its user up to its **range** (3 squares unless the card names another) and never further than its Stamina allows. It costs AP and Stamina ([battle.md §2.4](battle.md#24-action-points-and-stamina)): walking pays the movement cost of the ground, the other path kinds 1 per square.
- **Every square entered and left counts** for ground and traps; a path over other squares touches only the landing square.
- On landing it may push: the monster ahead, or all eight neighbours ([§5](#5-movement-kinds)).
- A movement may create ground or a zone on the squares it left.

### Effect on the User

- **Self buff:** a timed effect for N rounds; used again it refreshes and never stacks.
- **Passive:** a lasting effect without cost ([§6](#6-passives)).
- **Effects available:** Pace, range of movement skills and Reach up; as `experiment`: AP +1 and one more turn in the next round.
- **A skill cannot place an effect on another monster:** what reaches others goes through the board.

### What a Skill Creates

| Created | Lasts | May be created by | Not possible |
|---|---|---|---|
| **Ground** | 2 rounds | a placed shape · a Strike, on the struck squares · a movement, on the squares it left | on Voidscar or a Dragon Vein |
| **Zone** | the rounds the skill names | a placed shape · a Strike · a movement | — |
| **Prop** | 2 rounds or until destroyed; a trap until it is entered | a placed shape: one prop per square | on a square that cannot take it; by a Strike or a movement |

- **Two at once:** a skill that neither strikes nor moves may create two things together.
- **Order:** what a skill creates lands after its damage and displacement: props, then ground, then zones ([battle.md §6.2](battle.md#62-payload-resolution)).
- **Ground under a monster** is not entering; it acts at its next moment.
- **Laid again:** the same ground or zone on the same square only restarts its clock.
- **A trap is a prop:** a skill creates a walkable prop that acts when a monster enters it.
- Own ground and zones bind the caster too. No zone damages or heals a monster.

## 4. Shapes

**One shape vocabulary** for Strikes, for what a skill creates next to its user, and for what a prop does around itself: six **base shapes** around a centre `M`, each **extended** any number of times; **a Strike is extended at most once** (it reaches 2 squares). A bigger shape costs more AP.

| Base shape | Squares | Directions | The squares |
|---|---|---|---|
| **Jab** | 1 | 8 | next to `M` |
| **Pincer** | 2 | 8 | next to `M` in the chosen direction and on the opposite side |
| **Arc** | 3 | 8 | the 3 squares in front of `M`: a row, or on a diagonal the wedge `(dx,0)`, `(dx,dy)`, `(0,dy)` |
| **Whirl** | 4 | none | the 4 neighbours of `M` |
| **Cross** | 4 | none | the 4 diagonals of `M` |
| **Storm** | 8 | none | all 8 squares around `M` |

```
  x       x      x x x         x            x         x     x   x   x x x
  M       M        M         M            M         x M x     M     x M x
          x                             x             x     x   x   x x x
Jab     Pincer   Arc       Jab,         Pincer,     Whirl   Cross   Storm
                           diagonal     diagonal
```

**Extension:** every square of the shape gets one more square behind it, away from `M`; for the Arc the whole row moves on in the facing direction. Each further extension repeats the step.

```
  x        x                       x         x       x     x   x   x
  x        x         x x x         x           x   x         x x x
  M        M         x x x     x x M x x         M         x x M x x
           x           M           x           x   x         x x x
           x                       x         x       x     x   x   x
Jab +1   Pincer +1   Arc +1    Whirl +1      Cross +1      Storm +1
```

| Shape | Squares at +0 / +1 |
|---|---|
| Jab | 1 / 2 |
| Pincer | 2 / 4 |
| Arc | 3 / 6 |
| Whirl | 4 / 8 |
| Cross | 4 / 8 |
| Storm | 8 / 16 (the eight lines of 2, not the full ring) |

**Offsets** (origin `M = (0,0)`, direction `d = (dx, dy)`, `d⊥ = (|dy|, |dx|)` for straight `d`, extension `e ≥ 0`, `k = 1 … e + 1`):

| Shape | Legal directions | Offsets |
|---|---|---|
| Jab | 8 | `k·d` |
| Pincer | 8 | `k·d`, `−k·d` |
| Arc | 8; extended: 4 straight | straight: `k·d`, `k·d + d⊥`, `k·d − d⊥`; diagonal (`e = 0` only): `(dx,0)`, `d`, `(0,dy)` |
| Whirl / Cross / Storm | none | `k·c` for each of the 4 neighbours / the 4 diagonals / all 8 `c` |

- **An extended Arc is straight only.**
- **The square in front:** every square with `k > 1` has the square with `k − 1` of the same line in front of it. A solid prop there takes a Strike and shields it.
- **Every shape hits allies too.**
- **Own square and block:** two more forms for things that include their own square: the own square, and the block around and including it (3×3, extended 5×5). Props that act on entry use them.
- **A prop has no direction:** it uses Whirl, Cross, Storm, its own square or the block.

## 5. Movement Kinds

| Path kind | Rule |
|---|---|
| **Walks** | cardinal steps; props and monsters block; pays the movement cost of every square |
| **Straight line** | one of the 4 orthogonal directions; a card may allow the 4 diagonals too, which the calculation prices; the card says what it passes over; only the landing square counts |
| **Any path** | free path; the card says what it passes over |

| On landing | Rule |
|---|---|
| pushes ahead | the monster on the next square in the direction of travel moves 1 on |
| pushes all neighbours | every monster on the eight neighbouring squares moves 1 outward |

A movement may leave ground or a zone on the squares it left. Concrete movement skills: [content.md §4](content.md#4-skills).

## 6. Passives

- A passive occupies a normal kit slot, costs no AP and is an effect on its bearer. One active skill and passives in every other slot is legal but weak.
- **Passives that lower AP costs are allowed; no action ever costs less than 1 AP.** The rule “development never lowers AP” ([§8](#8-development)) applies to skill development, not to these passives.
- **A passive holds against one kind of push at most.** Push and pull come from a Strike or another skill, from a zone or from a prop; a passive (a slot passive, a Kin trait, a Kin gift) may stop one of the three for its bearer, never all of them. A monster that nothing can move off a Dragon Vein leaves the other side no answer.
- Passives of the game and candidates: [content.md §4](content.md#4-skills).

## 7. Value and Prices

**Status: draft.** A skill calculation in the manner of the monster calculation ([monsters.md §2](monsters.md#2-stats)) is being worked out, so that skills come out about equally strong: every part of a skill card has a price in points, the sum is what the skill is worth, and each of the three AP levels has a range of points a skill of that level may lie in (less is always allowed). No price and no range is settled, and nothing checks a monster against a skill budget. The skills of [content.md](content.md) are examples; their AP costs are not settled.

Principles:

- **One budget idea:** a skill is paid for with its AP cost and its use limit; a stronger skill costs more AP or may be used less often. No skill rarity. A Strike's AP stands on its card like every other cost.
- **A complete kit at original AP:** development never forces a higher AP cost on a skill.
- **Monster stats and skills are priced apart** ([monsters.md §2](monsters.md#2-stats)) and validated together.

## 8. Development

**One pattern develops monster skills and tamer skills.** A monster skill is developed on the slot of one monster; a tamer skill on the skill the player learned ([overworld.md §5.4](overworld.md#54-tamer-skills)). Development is permanent, there is no experience currency and no physical evolution.

- **Levels 1–3.** Level 1 is the skill as written; levels 2 and 3 cost one **development step** each. Monsters gain steps as a choice at a stage breakthrough and at late advancement steps ([monsters.md §5](monsters.md#5-growth)), tamers as nodes of their Way ([overworld.md §5.3](overworld.md#53-the-way)).
- **One option per level** from the list written for that skill, each option once; level 3 combines two options. No free components.
- **Option vocabulary:** every option is one of **Area** (one more square or a larger shape), **Number** (one effect value changed within the caps), **Duration** (more rounds), **Addition** (what the skill creates also does something an existing ground, zone or prop does), **Condition** (a requirement loosened), **Count** (one more use per turn). Count exists for monster skills only.
- **Never by development:** more damage than the maxima of [battle.md §6.1](battle.md#61-damage), lower AP, more Reach, more uses of a tamer skill.
- **AP policy:** every skill has a complete path at its original AP; a bigger option may cost more AP, shown before selection, and is never the only path.
- **Useful from the start:** development expands an already viable kit, with several useful routes and no compulsory first upgrade.
- **Replacement:** outside a battle a slot may take another skill of the species' learnable list with a **relearning pill**; the slot keeps its level, and its options are chosen anew from the new skill's list.
- The options of each skill: not defined. Where and when a choice is made: [overworld.md §5.5](overworld.md#55-development-of-monster-skills).

## 9. Data

- **One Resource file per record** under `godot/data`: `skills/`, `monsters/`, `grounds/`, `zones/`, `props/`, `tamer/`. A new file is new content.
- **Content status:** `approved`, `draft` and `experiment` enter the game; `test`, `simulation` and `archived` do not. A status is not design or balance approval.
- **Content checks at load:** a monster of the game holds one to six skills of the game; a ground, a zone and a prop keep to their roles ([battle.md §4.8](battle.md#48-one-sheet-for-ground-zones-and-props)); a skill names existing grounds, zones and props; game content references no excluded record.
- Tools that show and build content (overview, skill builder, monster builder, shape editor): [godot/README.md](../godot/README.md).
