# Architecture — Road of the Beasts

*Decided by the user on 2026-11-14 as the target picture for the clean rebuild (the current Godot build is a prototype); §4 extended on 2026-11-15 with what the shape and sheet generalisation showed · launch decisions: CSV translation, German and English, a mid-strength opponent AI · rules and content: [Battle](gdd_battle.md), [Monsters](gdd_monsters.md), [Skills](gdd_skills.md), [Overworld & Meta](gdd_overworld.md) · open work: [temp_todo.md](temp_todo.md) T42*

---

## 1. Purpose and Status

- **This file owns** the technical structure of the finished game: layers, folder layout, contracts between the parts, and the principles for translation, sound, animation and content loading. It owns **no game rule**; rules stay in the GDDs ([Battle §7.1](gdd_battle.md#71-technical-notes-battle) holds only the technical requirements the rules impose).
- **Status:** confirmed by the user on 2026-11-14 (layers, folder layout, contracts, event playback). The current `godot/` build is a prototype: its rules, tests and simulations are the specification to port, its code layout is not binding. Nothing here is built; the rebuild starts only after the Battle rules are decided ([temp_todo.md](temp_todo.md) T42).
- **Not planned:** a generic rule language or a dependency-injection framework. Plain classes and Resources suffice.

## 2. Layers

| Layer | Contains | May know | Must not know |
|---|---|---|---|
| **Core** (`core/`) | rules, board, queue, resolution, content loading, contracts | IDs, numbers, Resources | scenes, nodes, autoloads, audio, texts, graphics |
| **Features** (`features/`) | battle view and UI, overworld logic/view/UI, menus, AI | core, services | each other, except through the contracts |
| **Services** (`services/`) | autoloads: localization, audio, save, settings | engine APIs | rule details |

- **Headless core:** the core runs without a window. Tests, bot simulations (`tools/`) and replays use it unchanged. A test checks that `core/` contains no scene, node or autoload access.
- **Determinism:** same initial state, same versioned content, same seed and same ordered actions give the same result ([Battle §1](gdd_battle.md#1-overview)); the core never reads time, frame rate or scene state.
- **Presentation follows results:** the core resolves an action completely and at once and returns events; the view only plays them.

## 3. Contracts Between Parts

- **`BattleRequest` / `BattleResult`** (in `core/contracts/`): the only link between Battle and Overworld ([Overworld §8](gdd_overworld.md#8-technical-notes-overworld--development-phases)). Request: mode, board parameters, both teams as finished unit sheets, the arrangement of every free shape the player laid out before the battle ([Skills §2](gdd_skills.md#place-shape-and-rotation)), loadout. Result: winner or Draw, HP per monster, kills, used-up items. Open fields: T19/T23.
- **Battle events** (in `core/contracts/`): a versioned list of event types with fixed fields (cast, strike, displaced, collision, prop_moved, damage, defeat, ground/zone laid, round end ...). The view, sound mapping, battle log, replays and tests all read this one list; a new event type is a contract change.
- **Content references:** by stable ID only. Resources never hold file paths of art, sound or text.

## 4. Content and Data

- **One Resource file per record** under `data/` (`monsters/`, `skills/`, `grounds/`, `zones/`, `props/`, `tamer/`), with `content_status` ([Skills §7](gdd_skills.md#7-data-and-validation)). No JSON or Python data files.
- **Data first:** new content with existing mechanics is data only; a new mechanic gets one local extension point in the core (a behaviour element), not scattered ID checks.
- **Shared vocabularies, one each** *(insight of the generalisation of 2026-11-15)*: content is composed from three closed lists that every kind of record uses, never from per-kind copies:
  - **shapes:** six base shapes with extensions, the own square, the block and the free shape ([Skills §8.1](gdd_skills.md#81-shapes)); a Strike, a skill that creates something and a prop all name a shape from this one list, and a skill has exactly one shape field;
  - **moments:** when something on the board acts ([Battle §2.4](gdd_battle.md#24-effect-timing-reference));
  - **effects:** what it does (damage, healing, stat changes, push, pull, creating ground, a zone or a prop).
- **One sheet for ground, zones and props:** the three kinds stay separate record types (one per layer of a square), but each is a head plus lines of “when · what · how much · where”, and the roles are one permission table checked at load ([Battle §4.12](gdd_battle.md#412-one-sheet-for-ground-zones-and-props)). In the rebuild the three record types share **one line type**. *Prototype state:* three line classes (`GroundTrigger`, `FieldEffect`, `PropAftermath`) that already name moments and shapes from the shared lists and are read through one sheet reader (`BoardSheet`); merging them is porting work, not a rule change.
- **Per-unit copies, not global edits:** what a player configures for one monster (a free shape's arrangement, later a developed slot) lives on that unit's sheet as its own copy of the record; the content file is never changed by play.
- **Validation:** loading checks references and status; automated content checks stay tests, not runtime rules.

## 5. Translation

- **All text is a key** (`skill.gale.name`, `skill.gale.desc`, `ui.battle.end_turn`); code and Resources hold IDs, never display text.
- **Format (decided 2026-11-14):** Godot `TranslationServer` with CSV, one file set per language under `localization/`; **German and English from the start**.
- **Generated text** (skill cards, hover cards, battle log) is assembled from translated building blocks with placeholders, not from fixed sentences, so order and plural work per language.
- **Check:** a test lists keys missing in any language and keys unused.

## 6. Sound

- **`Audio` service:** one autoload with buses for music, effects and UI and per-bus volume from settings.
- **Mapping by event:** a Resource maps battle event types (and UI events) to sounds with volume and variation; the battle view calls the service, the core never does.

## 7. Animation and Graphics

- **Event playback:** one small player per event type (move, hit, push, collision, ground/zone/prop appearing, defeat) with an awaitable duration; a queue plays them in order, so animation speed and “skip animations” are options, not rule changes. After the queue, the view compares itself with the core state.
- **Assets by ID:** `assets/` holds models, textures, audio, fonts and effects in folders named after the content ID; the view finds art by ID.

## 8. Folder Layout

```
godot/
  project.godot
  core/
    battle/        rules: board, queue, payload, moves, damage, props, zones, ground
    contracts/     BattleRequest/Result, battle events, IDs (the seam)
    content/       load, filter, validate Resources
    util/
  features/
    battle/        view/ · ui/ · ai/
    overworld/     logic/ (headless-testable) · view/ · ui/
    menus/         main menu, draft, overview, builders
  services/        loc.gd · audio.gd · save.gd · settings.gd (autoloads)
  data/            monsters/ skills/ grounds/ zones/ props/ tamer/
  localization/    keys.csv · de · en
  assets/          models/ textures/ audio/ fonts/ vfx/
  tools/           sim, compare, progression, discovery
  tests/           core/ battle/ overworld/ localization/
```

- Battle and Overworld stay separate folders under `features/`; shared types live only in `core/contracts/`.
- The AI sits with the battle feature (it reads core state through the same options the player has). **Decided 2026-11-14:** develop a mid-strength opponent between the one-step evaluator and the tools bot `tactic` (plans a whole turn within a time budget); its design and time budget are open (I42, T42).

## 9. Porting From the Prototype

- Port tests and simulations first (they pin the rules), then the core, then the view. Do not port code for removed mechanics (height, air layer, Surges and the marker traps that came with them; see [temp_todo.md](temp_todo.md) I56/I57). The traps of the game are walkable props ([Battle §4.9](gdd_battle.md#49-props)).
- Keep the prototype playable until the rebuilt battle passes the same rule tests and a comparable bot run ([godot/tools/README.md](../godot/tools/README.md)); equal results are a regression check, not gameplay validation.
