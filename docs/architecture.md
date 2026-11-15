# Architecture

- **This file owns** the technical structure of the finished game: the two games and what they share, folder layout, contracts, content data, dialogue, story, translation, sound and animation. It owns no game rule.
- **Status:** target picture for a clean rebuild. Nothing here is built. The current `godot/` build is a prototype: its rules, tests and tools are the specification to port, its code layout is not binding. The rebuild starts after the battle rules are decided.
- **Not planned:** a generic rule language or a dependency-injection framework. Plain classes and Resources suffice.

## 1. Two Games and What They Share

**Battle and overworld are two separate games.** Neither knows the other. They meet only in a shared data format: the overworld writes it, the battle loads it before a fight and uses it.

| Part | Contains | May use |
|---|---|---|
| **`battle/`** | everything of the battle: rules, AI, view, UI, the multiplayer mode, its tools and tests | `shared/`, `app/` |
| **`overworld/`** | everything of the overworld: day, economy, progression, story, dialogue, view, UI, its tests | `shared/`, `app/` |
| **`shared/`** | only the shared data format: the battle request and result, the monster sheet, and the content records both read | nothing |
| **`app/`** | start and main menu, settings, translation, sound, saving | `shared/` |

- **A test checks the separation:** no file under `battle/` refers to `overworld/` and none under `overworld/` to `battle/`.
- **Each game may be built differently.** The battle is rule-driven with an event list; the overworld has story, dialogue and a night resolution that the battle does not know.
- **The multiplayer mode** builds its battle request itself and needs no overworld.

## 2. Folder Layout

```
godot/
  project.godot
  app/               start and main menu, settings, translation, sound, saving
  shared/
    formats/         battle request, battle result, monster sheet
    data/            monsters/ skills/ grounds/ zones/ props/
  battle/
    rules/           board, queue, resolution, damage, displacement (runs without a window)
    ai/
    view/  ui/
    multiplayer/     draft, monster builder, skill builder, overview
    tools/           bot runs, comparisons
    tests/
  overworld/
    logic/           day, economy, progression (runs without a window)
    story/           story steps and their progress
    dialogue/        dialogue flow
    view/  ui/
    data/            dialogues/ story/ items/ structures/ ...
    tests/
  localization/      texts per language, separate for battle and overworld
  assets/            models/ textures/ audio/ fonts/ vfx/
```

## 3. The Shared Data Format

- **Battle request** (written by the overworld or the multiplayer mode): mode, board parameters, both teams as finished monster sheets, the arrangement of every free shape the player laid out before the battle, the loadout.
- **Battle result** (written by the battle): winner or Draw, HP per monster, kills, used-up items. The battle returns facts, never rewards.
- **Content records** under `shared/data/`: one Resource file per monster, skill, ground, zone and prop, with a content status. Both games read them: the battle executes a skill, the overworld shows and swaps it. No JSON or Python data files.
- **References by stable ID only.** A record never holds a file path of art, sound or text.
- **Per-unit copies, not global edits:** what a player configures for one monster (a free shape's arrangement, a developed slot) lives on that monster's sheet; a content file is never changed by play.

## 4. The Battle

- **Rules run without a window.** Tests, bot runs and replays use them unchanged; `battle/rules/` contains no scene, node or autoload access.
- **Determinism:** the same start, content, seed and ordered actions give the same result; the rules never read time, frame rate or scene state.
- **Presentation follows results:** the rules resolve an action completely and return events; the view only plays them.
- **Battle events:** a versioned list of event types with fixed fields (cast, strike, displaced, collision, damage, defeat, ground or zone laid, round end ...). View, sound, battle log, replays and tests all read this one list; a new event type is a contract change.
- **Data first:** new content with existing mechanics is data only; a new mechanic gets one local extension point, not scattered ID checks.
- **Shared vocabularies, one each:** shapes ([skills.md §4](skills.md#4-shapes)), moments ([battle.md §3](battle.md#3-timing)) and effects. Ground, zones and props stay three record types that share one line type of “when · what · how much · where” ([battle.md §4.8](battle.md#48-one-sheet-for-ground-zones-and-props)).
- **AI:** it reads the state through the same options the player has. A mid-strength opponent that plans a whole turn within a time budget is intended; its design is not defined.

## 5. Dialogue

- **A dialogue is one record** under `overworld/data/dialogues/`. It holds structure only: nodes, who speaks, the answers and where each answer leads.
- **No text in the record, only keys** (`dialogue.elder_first_meeting.line_03`); the texts live in the translation files ([§7](#7-translation)). Texts use placeholders for names and numbers.
- **Conditions and consequences** sit on nodes and answers: an answer appears only if its condition holds (a story step done, a stage reached, favor high enough), and an answer may report a story event, give an item or start a battle.
- **One loading point:** the dialogue flow never reads a file itself. It asks one loader for a dialogue by ID and always gets the same structure. The loader reads Resources; another source format replaces only the loader.
- The dialogue flow runs without a window; the dialogue window is view only.

## 6. Story

**A story step is one record** under `overworld/data/story/`:

| Field | Content |
|---|---|
| ID | a stable name |
| Requires | the steps that must be done before |
| Done by | one or more events: a dialogue finished, a battle won, a stage reached ... |
| Locked by | steps that close this one for the save once they are done |
| Opens | what becomes available afterwards: dialogues, places, requests |

- **Events, not direct calls:** dialogues, battle results and progression only report what happened. The story listens and marks the matching step. A dialogue knows nothing of the story.
- **A step may need several events,** and several steps may be open at once.
- **The story branches:** a decision can lock later steps; a locked step stays closed for that save.
- **Not every dialogue is story:** only marked places report an event.
- **The save holds only the set of finished steps;** what is open or locked is derived from it.
- **Chapters** only group steps for display.
- **Checks:** every step is reachable on some path, and every “done by” event is reported somewhere.

## 7. Translation

- **All text is a key;** code and records hold IDs, never display text.
- **Format:** Godot `TranslationServer` with CSV, one file set per language under `localization/`; German and English from the start.
- **Generated text** (skill cards, hover cards, battle log) is assembled from translated building blocks with placeholders, so order and plural work per language.
- **Check:** a test lists keys missing in any language and keys unused.

## 8. Sound, Animation and Assets

- **Sound:** one service with buses for music, effects and UI. A record maps event types to sounds; a view calls the service, rules never do.
- **Animation:** one small player per battle event type with an awaitable duration; a queue plays them in order, so animation speed and “skip animations” are options, not rule changes. After the queue the view compares itself with the rule state.
- **Assets by ID:** `assets/` holds models, textures, audio, fonts and effects in folders named after the content ID.

## 9. Porting From the Prototype

- Port tests and tools first (they pin the rules), then the battle rules, then the view. Do not port code for mechanics that no longer exist.
- Keep the prototype playable until the rebuilt battle passes the same rule tests. Equal results are a regression check, not gameplay validation.
