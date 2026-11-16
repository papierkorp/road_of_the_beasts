# Battle Contract

- **This file owns** the public surface of the rebuilt battle: the formats that cross its border, its phases, actions, events and readable state. It owns no game rule; where a rule decides a field, the rule file is linked.
- **Status:** frozen draft, not accepted by the user. It is not kept up to date while the battle rules change; it is revised once against the finished rules when the rebuild starts, as its step 1 ([architecture.md §10](architecture.md#10-the-rebuild)).
- **Conventions:** every value is a whole number, an ID or a list of them. A square is `(x, y)`. A direction is one of the eight neighbours as `(dx, dy)`. A side is `0` or `1`. Pace counts in points ([battle.md §2.3](battle.md#23-pace-and-the-queue)). Names of types and fields are lower case with underscores.

## 1. Formats

### 1.1 Monster Sheet

| Field | Content |
|---|---|
| `unit_id` | stable ID of this individual, unique within the request |
| `name_key` | translation key of its name |
| `species_id` | for art and sound only; no rule reads it |
| `kin` | one of the six Kins |
| `hp`, `pace`, `stamina`, `reach`, `turns`, `ap` | the six stats |
| `current_hp` | HP at the start of the battle |
| `skills` | up to 6 resolved skills as data, in slot order |

### 1.2 Battle Request

| Field | Content |
|---|---|
| `encounter_id` | chosen by the sender, returned unchanged in the result |
| `mode` | 1v1, 2v2, 3v3 or 5v5 |
| `board` | a finished board (size, ground, props and Dragon Veins per square), or generator parameters with a seed |
| `teams` | per side: the sheets of the monsters that fight, in slot order |
| `benches` | per side: the sheets available to Beast Swap |
| `loadouts` | per side: slotted tamer skills and loadout items |
| `controllers` | per side: human or AI |
| `content_fingerprint` | the content the request was built against |

### 1.3 Battle Result

| Field | Content |
|---|---|
| `encounter_id` | from the request |
| `outcome` | the winning side, or Draw |
| `conceded` | the side that conceded, if one did |
| `rounds` | the round the battle ended in |
| `units` | per `unit_id`: HP left, defeated, fielded |
| `used` | per side: the tamer skills and loadout items that were used |
| `actions` | the ordered action list |
| `content_fingerprint` | from the request |

Request and actions together replay the battle.

## 2. The Interface

| Call | Returns | Use |
|---|---|---|
| `problems(request)` | a list of problem keys; empty means playable | sender and battle; lives in `shared/` |
| `start(request)` | a battle in the placement phase | |
| `options()` | every legal action of the side that has to act | UI and AI read the same list |
| `check(action)` | nothing, or the key of the reason it is illegal | never changes state |
| `preview(action)` | the events the action would cause | a dry run of the same code |
| `apply(action)` | the events it caused | the only way the state changes |
| `state()` | the readable state ([§5](#5-readable-state)) | view, AI, tests |
| `state_hash()` | one number for the whole state | replays, online play |
| `result()` | the battle result, once the battle is over | |

A reason is a key, never display text.

## 3. Phases and Actions

**Phases:** placement → rounds → over.

| Action | Fields | When |
|---|---|---|
| `place` | `unit`, `square` | placement: the side whose turn it is to place ([battle.md §2.2](battle.md#22-core-loop)) |
| `step` | `to` | the active monster's turn |
| `skill` | `slot` and what the card lets the player choose (below) | the active monster's turn |
| `tamer` | `skill`, and its targets: `units`, `squares`, `turn` | a turn of one of the side's own monsters ([battle.md §5.2](battle.md#52-tamer-skills)) |
| `choose` | `option` | the battle waits for a choice of this side (the Dragon Vein tie) |
| `end_turn` | — | the active monster's turn |
| `concede` | — | a turn of one of the side's own monsters |

Every action also names its `side`; the acting monster is the current queue entry and is not named.

**Fields of `skill`**, by what the card lets the player choose ([skills.md §2](skills.md#2-the-skill-card)):

| The skill | Fields |
|---|---|
| has a base shape with a direction | `dir` |
| has a free shape | `anchor`, `turn` (0–3 quarter turns) |
| is a movement | `to`; for a free path also `path` |
| pushes in a chosen direction (Scaled Strike, a push zone cast alone) | `push_dir` |
| needs no choice | — |

## 4. Events

Every event carries `type`, `seq` (its number in the battle) and `action` (the number of the action that caused it; a round end belongs to the action that ended the last turn).

| Group | Type | Fields |
|---|---|---|
| Flow | `placed` | `unit`, `square` |
| | `round_started` | `round`, `queue` |
| | `turn_started` | `unit`, `ap`, `extra` |
| | `turn_ended` | `unit` |
| | `queue_changed` | `queue` |
| | `choice_needed` | `side`, `kind`, `options` |
| | `choice_made` | `side`, `option` |
| | `battle_over` | `outcome`, `conceded`, `round` |
| Use | `skill_used` | `unit`, `slot`, `skill`, `squares`, `dir` |
| | `tamer_skill_used` | `side`, `skill`, `units`, `squares` |
| Monsters | `moved` | `unit`, `from`, `to`, `path`, `stamina_paid` |
| | `displaced` | `unit`, `from`, `to`, `source` |
| | `collided` | `mover`, `at`, `with` (edge, units, props) |
| | `unmoved` | `unit`, `reason` |
| | `damaged` | `unit`, `amount`, `base`, `kind`, `source` |
| | `healed` | `unit`, `amount`, `source` |
| | `defeated` | `unit` |
| | `survived` | `unit`, `source` |
| | `effect_changed` | `unit`, `effect`, `value`, `ends_round`, `result` (applied, refreshed, ended) |
| | `stamina_recovered` | `unit`, `amount` |
| | `swapped` | `a`, `b` |
| | `beast_swapped` | `out`, `in`, `square` |
| Board | `ground_changed` | `square`, `ground`, `level`, `result` (laid, levelled, replaced, faded, reset), `source` |
| | `zone_changed` | `square`, `zone`, `level`, `rounds`, `result` (new, levelled, reduced, cancelled, replaced, faded, cleared) |
| | `vein_taken` | `square`, `side`, `unit` |
| | `prop_placed` | `prop`, `kind`, `square` |
| | `prop_acted` | `prop`, `moment`, `unit` (who entered a trap) |
| | `prop_damaged` | `prop`, `amount`, `hp` |
| | `prop_moved` | `prop`, `from`, `to`, `source` |
| | `prop_unmoved` | `prop`, `reason` |
| | `prop_destroyed` | `prop`, `square` |

- **`kind` of damage:** strike, ground, collision, prop, vein, surround, pressure ([battle.md §6.1](battle.md#61-damage)).
- **`source`** names what caused it: a unit, a prop, a ground, a zone or a tamer skill, by ID.
- **A prop has an ID** of its own, given when it comes onto the board; `kind` is its record.
- **A new event type or field is a change of this file.**

## 5. Readable State

| Part | Content |
|---|---|
| Battle | phase, round, the queue, the active entry, AP left, the side that has to act, a pending choice, the outcome |
| Unit | its sheet, side, slot, square, HP, Stamina, effective stats, timed effects with their last round, uses per slot, on the field or on the bench, defeated |
| Square | ground with level and rounds left; zone with level, rounds left, direction or anchor; the prop or monster on it; the owner of a Dragon Vein |
| Prop | ID, kind, square, HP |
| Side | tamer skills and loadout items, used or not |

The state is read-only for everyone outside the rules.
