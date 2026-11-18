# Architecture

- **This file owns** the technical structure of the finished game. It owns no game rule.
- **Status:** target picture for a rebuild from scratch; nothing here is built. The current `godot/` build is a prototype: the rule files are the specification ([§10](#10-the-rebuild)), its tests and tools are the model for the new ones, its code is not carried over. The rebuild starts when the user is satisfied with the battle in manual play. §5 and §6 are a sketch, fixed before the first real dialogue is written.
- **Goal:** code that is easy to read, extend and change. Plain classes and Resources; no generic rule language, no dependency-injection framework.

## 1. Two Games and What They Share

**Battle and overworld are two separate games.** Neither knows the other. They meet only in `shared/`: the overworld writes a battle request, the battle plays it and writes a result.

| Part | Contains | May use |
|---|---|---|
| **`battle/`** | the rule core, AI, view, UI, tools, tests; on top of the core the two battles: `multiplayer/` and `ingame/` | `shared/`, the services of `app/` |
| **`overworld/`** | day, economy, progression, story, dialogue, view, UI, tests | `shared/`, the services of `app/` |
| **`shared/`** | what both games read ([§3](#3-the-shared-data-format)), kept as small as possible. No UI, no battle state, no resolution | nothing |
| **`app/`** | main menu (“Battle” leads to the ingame prototype and to the multiplayer battle); `app/session/`, the only code that knows both games (it takes a request, starts the battle, hands the result back); `app/services/`: settings, translation, sound and save files | the session: `shared/`, the services, the scenes of both games; the services: `shared/` only |

- **Two battles on one rule core** ([battle_ingame.md §1](battle_ingame.md#1-the-two-battles)): the multiplayer battle and the ingame battle. `battle/rules/` knows neither; `battle/multiplayer/` and `battle/ingame/` each hold what only their battle has and never refer to each other.
- **A test checks the separation:** nothing under `battle/` refers to `overworld/` or the reverse, by class or by scene path; nothing under `battle/multiplayer/` refers to `battle/ingame/` or the reverse, and nothing else under `battle/` refers to either; nothing under `shared/` refers outside it; nothing under `app/services/` refers to a game; a game uses of `app/` only the services and the one handover of the session; `battle/rules/` uses no service.
- **Tests across the border** live in `app/tests/`: the overworld builds a request, the battle plays it with the AI on both sides, the overworld consumes the result.
- **Each game has its own UI,** also its own display of a skill card and a monster sheet, built on the card model of `shared/`, with its own sentences ([§7](#7-translation)).
- **The two games may work differently.** In the overworld a free shape is arranged through upgrades, items and quests and is fixed when a battle starts. The multiplayer mode has its own flow of creating monsters, skills and maps; that flow is not defined.

## 2. Folder Layout

```
godot/
  app/               menu, session/, services/, tests/ across the border
  shared/
    formats/         battle request, battle result, monster sheet
    records/         record classes, vocabularies, checks, read functions
    data/            the language of both battles: grounds/ zones/ props/
  battle/
    rules/           the core of both battles; runs without a window
    ai/  view/  ui/  tools/  tests/
    multiplayer/     draft, generators and calculation, monster builder, skill builder, map generator, overview
    ingame/          its extensions of the core (tamer skills, board events, ends of a battle), battlegrounds
      data/          the fixed content: monsters/ skills/ tamer/ development/
  overworld/
    logic/           day, economy, progression, requests (runs without a window)
    story/  dialogue/  view/  ui/  tests/
    data/            dialogues/ story/ items/ structures/ ...
  localization/      per language: shared content, battle, overworld
  assets/            models/ textures/ audio/ fonts/ vfx/
```

## 3. The Shared Data Format

- **Content records:** one Resource file per record, with a content status. `shared/data/` holds what both battles speak with: grounds, zones and props. **Fixed monsters, skills, kits, tamer skills and slot-development options belong to the ingame battle** (`battle/ingame/data/`). **The multiplayer battle has no fixed monsters and skills:** they are generated or drafted for a battle, or made by a player and saved ([§4](#4-the-battle)). No JSON or Python data files. The battle effect of a medicine or an array is a record here too; its form is not defined.
- **References by stable ID only.** A record never holds a file path of art, sound or text. An ID is never reused; an archived record stays loadable.
- **Read functions** (pure, no state): skill → card model (the parts of the card as data, no text); shape → squares; is an arrangement legal; skill + chosen development + arrangement → the resolved skill.
- **Monster sheet, battle request and battle result:** their fields stand in [contract.md §1](contract.md#1-formats). The sheet carries its kit as **resolved skills as data**. **A request is self-contained:** player-made monsters, skills and maps travel inside it. The result returns facts, never rewards.
- **Request check:** one function lists the problems of a request. The battle refuses such a request; it never repairs one silently.
- **Reference plus choice:** what a player configures for one monster (skill ID, chosen development, arrangement) is stored with that monster and resolved when the request is built; a content file is never changed by play.

## 4. The Battle

- **Rules run without a window.** Tests, bot runs and replays use them unchanged; `battle/rules/` contains no scene, node, autoload or service access.
- **One contract** ([contract.md](contract.md)): actions in (step, skill, end turn, tamer skill, placement), a check that says why an action is illegal, a preview that is a dry run of the same code, events out, a readable state. Placing the monsters in the start area is a phase of the battle.
- **Determinism:** the same request and ordered actions give the same result; the rules never read time, frame rate, scene state or the machine. Whole numbers decide every comparison.
- **Presentation follows results:** the rules resolve an action completely and return events; the view only plays them.
- **Battle events:** one list of event types with fixed fields, read by view, sound, battle log, replays and tests. A test checks that every type has a log line.
- **Data first:** new content with existing mechanics is data only; a new mechanic gets one local extension point, not scattered ID checks.
- **Shared vocabularies, one each:** shapes ([skills.md §4](skills.md#4-shapes)), moments ([battle.md §3](battle.md#3-timing)) and effects. Ground, zones and props stay three record types that share one line type of “when · what · how much · where” ([battle.md §4.8](battle.md#48-one-sheet-for-ground-zones-and-props)).
- **AI:** it reads the state through the same options the player has and searches outside the main thread. A mid-strength opponent that plans a whole turn is intended; its budget counts evaluated states, not time. Its design is not defined.
- **One core, never a mode check.** The core plays a request and never asks which battle it is. What differs between the battles reaches it in three ways:

| Difference | Way | Examples |
|---|---|---|
| other numbers, other content | data in the request (the rule set, the sheets, the board) | vein damage, the cost of Heal, points, monsters, skills |
| other behaviour | an extension point of the core that the module of a battle fills; the request names the extensions it uses | tamer skills, board events, ends of a battle |
| everything before and after a battle | code of the battle's own folder; the core knows nothing of it | draft, generators, building battlegrounds, rewards |

- **A request names its battle** (multiplayer or ingame) for the tools and the log, and carries its rule set as data. The form of a rule set is not defined.
- **No assumption about board and sides:** the board is a list of squares, of any size and outline, without symmetry; a side has any number of monsters, and the sides may differ.
- **The end of a battle is a list of conditions in the request.** The multiplayer battle names one: every monster of a side at 0 HP.
- **Board events** are lines of the shared line type of ground, zones and props (“when · what · how much · where”) without an owner; they need no machinery of their own. Their rules are not defined ([battle_ingame.md §4](battle_ingame.md#4-board-events)).
- **Content names its battle:** a record says whether it belongs to both battles, to the multiplayer battle or to the ingame battle; a request with a record of the other battle is refused by the request check.
- **Ingame battle:** team sizes, tamer skills and the end of a battle are its own ([battle_ingame.md](battle_ingame.md)). Battlegrounds are data inside the request ([battle_ingame.md §3](battle_ingame.md#3-battlegrounds)). Until the overworld builds requests, `battle/ingame/` has a prototype screen that builds them.
- **Multiplayer battle:** always 3v3 on a generated, point-symmetric board, without tamer skills ([battle.md §1](battle.md#1-goals-and-pillars)); it builds its requests itself and needs no overworld. What a player makes there is saved under `user://` as plain data with the fields of a record, never as a Resource file, and is checked like a request when it is loaded ([§9](#9-saving)); an exported build never writes the game's own content files.
- **The draft is a contract of its own** in `battle/multiplayer/`, built like the battle's: a state, actions in (pick a monster, pick a skill), a check that says why an action is illegal, events out, the same result from the same seed and actions. It ends with a complete battle request. The picking order is a table, not code: the monsters go 1 · 2 · 2 · 1 · 2 · 1 between the two players, then the skills monster by monster. A setting gives both players the same generated pool or each a pool of their own: one seed, or one seed per player. Fairness comes from the calculation: every offered monster costs the same points and every skill has its price. Pool sizes, the number of skills and the rest are not defined.
- **Online play** is planned, not built, and is built only on the user's explicit go. It needs nothing of the overworld: both sides hold the same request, exchange actions and compare a state hash. Transport and matchmaking are not defined.

## 5. Dialogue

- **A dialogue is one record** under `overworld/data/dialogues/`, structure only: nodes with stable IDs. Node kinds: a line (who speaks), a choice (answers and where each leads), a branch (a condition picks the way), a jump (to a node or another dialogue).
- **No text in the record, only keys** built from the node ID (`dialogue.elder_first_meeting.greet`), never from a position. Texts live in the translation files ([§7](#7-translation)) and use placeholders for names and numbers.
- **Conditions and consequences** sit on nodes and answers and come from one vocabulary shared with the story ([§6](#6-story)).
- **A battle started by a dialogue** suspends it; the result continues it on the branch for a win, a loss or a Draw.
- **One loading point:** the dialogue flow asks one loader for a dialogue by ID. The loader reads Resources; another source format replaces only the loader.
- The dialogue flow runs without a window; the dialogue window is view only.
- Which dialogue a person offers at a given moment is not defined.

## 6. Story

**A story step is one record** under `overworld/data/story/`:

| Field | Content |
|---|---|
| ID | a stable name |
| Requires | a condition |
| Done by | one or more events |
| Locked by | steps that close this one for the save once they are done |
| Opens | what becomes available afterwards: dialogues, places, requests |

- **One vocabulary** of conditions (a step done, a fact set, a stage reached, favor high enough, an item owned; joined by and / or) and of consequences (report an event, set a fact, give an item, start a battle).
- **Events, not direct calls:** an event is a type plus the ID of its subject (this dialogue finished, this encounter won or lost, this request done). Dialogues, battle results, requests and progression only report; the story listens.
- **Facts** hold what is no step: a choice made, a line already heard.
- **A step may need several events,** and several steps may be open at once. A step happens once and has no time limit.
- **The story branches:** a decision can lock later steps; a locked step stays closed for that save.
- **Faction requests are a system of their own** in `overworld/logic/` (pool, lifetime, repetition); they only report events.
- **The save holds** the finished steps, the events already received for open steps, and the facts; what is open or locked is derived.
- **Chapters** only group steps for display.
- **Checks:** every step is reachable; every “done by” event is reported somewhere; following only steps and locks, an ending stays reachable from every state (conditions on favor, items and facts are not searched).

## 7. Translation

- **All text is a key;** code and records hold IDs, never display text.
- **Format:** Godot `TranslationServer` with CSV, one file set per language under `localization/`, in three parts: shared content (names), battle, overworld. German and English from the start.
- **Generated text** (skill cards, hover cards, battle log) is built by each game from the card model and the events, in short fixed sentences with placeholders (“{name}: {n} damage”). A name always stands in its base form and a number stands after a label (“Damage: {n}”), so no sentence needs a case, a gender or a plural. The two games do not share sentences; each words its card itself.
- **Check:** a test lists keys missing in any language.

## 8. Sound, Animation, Assets and Export

- **Sound:** one service with buses for music, effects and UI. A record maps event types to sounds; a view calls the service, rules never do.
- **Animation:** a queue plays one player per battle event with an awaitable duration, so animation speed and “skip animations” are options. A default player covers every event type; a type gets its own when it needs one. After the queue the view compares itself with the rule state.
- **Assets by ID:** folders under `assets/` are named after the content ID.
- **Export:** tests, tools and content with the status `test`, `simulation` or `archived` are left out of a build.

## 9. Saving

- **`app/` owns the file, each game its content:** the save service handles slots, writes atomically and wraps every save in an envelope with a save version and the content version. A game hands over its state as a plain dictionary; a save is never a Resource file.
- **Migrations:** the overworld holds an ordered list of steps from each save version to the next. A frozen save file of every released version is a test.
- **Player-made content** of the multiplayer mode uses the same envelope; the battle side holds its migrations, with frozen files as tests.
- **A running battle** is saved as its request and action list; loading replays it. If the content fingerprint no longer fits, the battle starts again from its request instead.
- **A file that cannot be read or migrated** is reported to the player and left untouched; it is never overwritten or repaired silently.

## 10. The Rebuild

**Everything is written anew, the rules too.** The prototype stays playable until the rebuilt battle passes the ported rule tests; equal results are a regression check, not gameplay validation. Mechanics that no longer exist are not rebuilt.

- **The rule files are the specification.** Before the rebuild starts, every entry of [todo/implementation.md](todo/implementation.md) has become a rule or is dropped; where prototype and rule file still differ, the rule file is right.
- **The battle rules rest during the rebuild,** from its start until the rebuilt battle can be played by hand (step 5).

1. The contract: actions, events, request, result, sheet.
2. `shared/`: records, vocabularies, checks, read functions; the content files move.
3. The rule tests, rewritten against the contract.
4. The rules, until those tests pass; recorded prototype battles are compared by HP and positions after every action. A converter turns a prototype recording into a request and actions of the contract.
5. A plain board to play on: clickable, no animation, no art. The user plays the rebuilt rules by hand; the real view replaces it in step 7.
6. AI and tools.
7. `app/` services, then view and UI.
8. The two battles on the core: the multiplayer battle with its generators, the draft, its builders and the map generator, and the extensions of the ingame battle with its prototype screen.
9. The overworld.
