# Architecture

- **This file owns** the technical structure of the finished game. It owns no game rule.
- **Status:** target picture for a rebuild from scratch; nothing here is built as written. The current `godot/` build is a prototype: the rule files are the specification ([§10](#10-the-rebuild)), its tests and tools are the model for the new ones, its code is not carried over. The rebuild starts on the user's go.
- **Goal:** code that is easy to read, extend and change. Plain classes and Resources; no generic rule language, no dependency-injection framework.
- **What the game is** stands in [vision.md](vision.md): the battle and a hub around it, a roguelike without story and dialogue, offline, on a phone in landscape and on a PC alike.

## 1. Two Games and What They Share

**The battle and the hub are two separate programs in one project.** Neither knows the other. They meet only in `shared/`: the hub writes a battle request, the battle plays it and writes a result.

| Part | Contains | May use |
|---|---|---|
| **`battle/`** | the rule core, AI, view, UI, tools, tests; on top of the core the two battles: `ingame/` and `multiplayer/` | `shared/`, the services of `app/` |
| **`overworld/`** | the hub: lifespan, wild, void, Ways, roster, growth, goods, its screens and tests | `shared/`, the services of `app/` |
| **`shared/`** | what both read ([§3](#3-the-shared-data-format)), kept as small as possible. No UI, no battle state, no resolution, no game state | nothing |
| **`app/`** | main menu; `app/session/`, the only code that knows both games (it takes a request, starts the battle, hands the result back); `app/services/`: settings, translation, sound, save files, the screen ([§6](#6-screens-and-input)) | the session: `shared/`, the services, the scenes of both games; the services: `shared/` only |

- **Two battles on one rule core** ([battle_ingame.md §1](battle_ingame.md#1-the-two-battles)): the ingame battle and the multiplayer battle. `battle/rules/` knows neither; `battle/ingame/` and `battle/multiplayer/` each hold what only their battle has and never refer to each other.
- **A test checks the separation:** nothing under `battle/` refers to `overworld/` or the reverse, by class or by scene path; nothing under `battle/ingame/` refers to `battle/multiplayer/` or the reverse, and nothing else under `battle/` refers to either; nothing under `shared/` refers outside it; nothing under `app/services/` refers to a game; a game uses of `app/` only the services and the one handover of the session; `battle/rules/` uses no service.
- **What both games need is a record or a read function of `shared/`,** never a class of the other game. The hub teaches and develops skills, shows a skill card and draws a battleground: it does all of that with `shared/` alone.
- **Tests across the border** live in `app/tests/`: the hub builds a request, the battle plays it with the AI on both sides, the hub consumes the result.
- **Each game has its own UI,** also its own display of a skill card and a monster sheet, built on the card model of `shared/`, with its own sentences ([§7](#7-translation)).

## 2. Folder Layout

```
godot/
  app/               menu, session/, services/, tests/ across the border
  shared/
    formats/         battle request, battle result, monster sheet, battleground
    records/         record classes, vocabularies, checks, read functions
    data/            the content both games read: grounds/ zones/ props/ skills/ monsters/ kins/ tamer/
  battle/
    rules/           the core of both battles; runs without a window
    ai/  view/  ui/  tools/  tests/
    ingame/          its extensions of the core: tamer slots, catching
    multiplayer/     draft, generators and calculation, builders, map generator
  overworld/
    logic/           the state of a game and every rule around the battle (runs without a window)
    ui/  tests/
    data/            ways/ (trees, gifts, vows, boons) and the numbers of a game
  localization/      per language: shared content, battle, overworld
  assets/            models/ textures/ audio/ fonts/ vfx/
```

## 3. The Shared Data Format

- **Content records:** one Resource file per record, with a content status. `shared/data/` holds what both games read: grounds, zones, props, skills with their development options, species, Kins and what a tamer slot can hold. **The multiplayer battle has no fixed monsters and skills:** they are generated or drafted for a battle, or made by a player and saved ([§4](#4-the-battle)). No JSON or Python data files.
- **References by stable ID only.** A record never holds a file path of art, sound or text. An ID is never reused; an archived record stays loadable.
- **Read functions** (pure, no state): skill → card model (the parts of the card as data, no text); shape → squares; is an arrangement legal; skill + chosen options + arrangement → the resolved skill; individual → monster sheet.
- **Monster sheet, battle request and battle result:** their fields stand in [contract.md §1](contract.md#1-formats). The sheet carries its kit as **resolved skills as data**. **A request is self-contained:** the battleground with everything laid on it, both teams as finished sheets and the tamer slots travel inside it. The result returns facts, never rewards.
- **Request check:** one function lists the problems of a request. The battle refuses such a request; it never repairs one silently.
- **Reference plus choice:** what a player configures for one monster (skill ID, chosen options, arrangement) is stored with that monster and resolved when the request is built; a content file is never changed by play.
- **Exported fields:** a field of a packed array type never takes an array literal as default, because the export then drops its stored value ([godot/README.md](../godot/README.md#adding-content)). A test loads the content from an exported pack and compares it with the project, so that a loss of this kind is found before it reaches a phone.

## 4. The Battle

- **Rules run without a window.** Tests, bot runs and replays use them unchanged; `battle/rules/` contains no scene, node, autoload or service access.
- **One contract** ([contract.md](contract.md)): actions in (step, skill, end turn, what a tamer slot holds, placement), a check that says why an action is illegal, a preview that is a dry run of the same code, events out, a readable state. Placing the monsters in the start area is a phase of the battle.
- **Determinism:** the same request and ordered actions give the same result; the rules never read time, frame rate, scene state or the machine. Whole numbers decide every comparison. The one roll of the ingame battle, the catch, is seeded by the request; a dry run never rolls and shows the chance.
- **Presentation follows results:** the rules resolve an action completely and return events; the view only plays them.
- **Battle events:** one list of event types with fixed fields, read by view, sound, battle log, replays and tests. A test checks that every type has a log line.
- **Data first:** new content with existing mechanics is data only; a new mechanic gets one local extension point, not scattered ID checks.
- **Shared vocabularies, one each:** shapes ([skills.md §4](skills.md#4-shapes)), moments ([battle.md §3](battle.md#3-timing)) and effects. Ground, zones and props stay three record types that share one line type of “when · what · how much · where” ([battle.md §4.8](battle.md#48-one-sheet-for-ground-zones-and-props)).
- **AI:** it reads the state through the same options the player has and searches outside the main thread. A mid-strength opponent that plans a whole turn is intended; its budget counts evaluated states, not time. Its design is not defined.
- **One core, never a mode check.** The core plays a request and never asks which battle it is. What differs between the battles reaches it in three ways:

| Difference | Way | Examples |
|---|---|---|
| other numbers, other content | data in the request (the rule set, the sheets, the board) | vein damage, the cost of Heal, points, monsters, skills |
| other behaviour | an extension point of the core that the module of a battle fills; the request names the extensions it uses | tamer slots, catching |
| everything before and after a battle | code outside the core, which knows nothing of it | generated battlegrounds, laying parts, the draft, rewards |

- **A request names its battle** (ingame or multiplayer) for the tools and the log, and carries its rule set as data. The form of a rule set is not defined.
- **No assumption about board and sides:** the board is a list of squares, of any size and outline, without symmetry; a side has any number of monsters, and the sides may differ.
- **One end:** a battle ends when every monster of one side is at 0 HP ([battle.md §2.2](battle.md#22-core-loop)); the core has no other end and no board events.
- **Content names its battle:** a record says whether it belongs to both battles, to the ingame battle or to the multiplayer battle; a request with a record of the other battle is refused by the request check.
- **Ingame battle:** team sizes, tamer slots and catching are its own ([battle_ingame.md](battle_ingame.md)). The battleground is data inside the request; the hub generates it and lays what the Way brings ([§5](#5-the-hub)). Until the hub builds requests, `battle/ingame/` has a prototype screen that builds them.
- **Multiplayer battle:** always 3v3 on a generated, point-symmetric board, without tamer slots ([battle.md §1](battle.md#1-goals-and-pillars)); it builds its requests itself and needs no hub. It is the last step of the rebuild ([§10](#10-the-rebuild)), and nothing before it may make it harder: the core is built for it from the start. What a player makes there is saved under `user://` as plain data with the fields of a record, never as a Resource file, and is checked like a request when it is loaded ([§9](#9-saving)); an exported build never writes the game's own content files.
- **The draft is a contract of its own** in `battle/multiplayer/`, built like the battle's: a state, actions in, a check that says why an action is illegal, events out, the same result from the same seed and actions. It ends with a complete battle request. Its rules are not defined ([battle.md §1](battle.md#1-goals-and-pillars)).
- **Online play** is planned, not built, and is built only on the user's explicit go. It needs nothing of the hub: both sides hold the same request, exchange actions and compare a state hash.

## 5. The Hub

- **Logic runs without a window.** `overworld/logic/` holds the state of a game and every rule around the battle ([overworld.md](overworld.md)): the lifespan, the look at the wild, the void and its trials, rises, the drop, eggs, the tree of the Way, vows and boons. Tests and tools use it unchanged; its screens only show the state and call it.
- **One state object** holds a whole game and turns into a plain dictionary for the save ([§9](#9-saving)). What a finished game leaves for the next one is a second, separate object.
- **Deeds, not screens, change the state:** a battle of the wild, a new look, an attack on the void, a point spent, a node bought. Each is one function with a check that says why it is refused; a screen never changes a field itself.
- **A Way is a record** under `overworld/data/ways/`: what it owns (parts, tamer skills or pills), its buildings, its drop, its gifts, its trees and its vows. The code asks the record what a game has; it never compares the name of a Way. A building, a good and a node follow one schema each ([overworld.md §1](overworld.md#1-design-rules)).
- **Every number of a game is data** in one place, never a constant in the code.
- **The hub builds the whole request:** it generates the battleground from a seed and the stage, lays the parts of the Artificer or takes their own battleground, resolves the team into sheets and names the tamer slots. It reads the result back as facts and decides drop, rises and years itself.
- **Seeds:** everything drawn for a game (the nest, the look, the void, the gifts, the Sovereign beast) comes from the seed of the game and a tag, so that a loaded game shows what it showed before.
- **An individual** is a save record without battle rules ([overworld.md §7](overworld.md#7-technical-notes)).

## 6. Screens and Input

- **One layout for a phone and a PC:** landscape, built for the smallest screen and scaled by one factor of the screen service; no screen has a phone variant of its own.
- **The safe area:** the screen service gives the inset of a camera cutout; every screen lays its content inside it and lets its background run under it.
- **Every key and every button is an action of the Input Map;** code never asks for a key. Key names in a text come from one function, and on a touch screen that function names the on-screen button instead.
- **Nothing is reachable by a key or by hover alone:** every action has a control on the screen, and what a tooltip says is also reachable by a tap.
- **Touch in the battle:** the first tap on a square shows the preview, the second confirms; one finger turns the camera, two zoom and move it. Gestures belong to the view, never to the rules.
- **Lists scroll under the finger,** also when the touch starts on a control inside them.
- **The back button** of a phone cancels or opens the pause menu; it never leaves the game without a question.
- **A screen is checked on a phone,** not only in the editor; what can be checked by a tool is checked through the real UI.

## 7. Translation

- **All text is a key;** code and records hold IDs, never display text.
- **Format:** Godot `TranslationServer` with CSV, one file set per language under `localization/`, in three parts: shared content (names), battle, overworld. **German and English from the start.**
- **The language is a setting:** the player picks it in the settings; it applies at once, without a restart, and is saved with the other settings. The first start takes the language of the device, or English.
- **Generated text** (skill cards, hover cards, battle log) is built by each game from the card model and the events, in short fixed sentences with placeholders (“{name}: {n} damage”). A name always stands in its base form and a number stands after a label (“Damage: {n}”), so no sentence needs a case, a gender or a plural. The two games do not share sentences; each words its card itself.
- **Room for the longer language:** a control takes the text of either language without a fixed width that cuts it.
- **Check:** a test lists keys missing in any language.

## 8. Sound, Animation, Assets and Export

- **Sound:** one service with buses for music, effects and UI. A record maps event types to sounds; a view calls the service, rules never do.
- **Animation:** a queue plays one player per battle event with an awaitable duration, so animation speed and “skip animations” are options. A default player covers every event type; a type gets its own when it needs one. After the queue the view compares itself with the rule state.
- **Assets by ID:** folders under `assets/` are named after the content ID.
- **Export:** tests, tools and content with the status `test`, `simulation` or `archived` are left out of a build. The Android build is a preset of the project ([godot/README.md](../godot/README.md#android-build)).

## 9. Saving

- **`app/` owns the file, each game its content:** the save service handles slots, writes atomically and wraps every save in an envelope with a save version and the content version. A game hands over its state as a plain dictionary; a save is never a Resource file.
- **Migrations:** the hub holds an ordered list of steps from each save version to the next. A frozen save file of every released version is a test.
- **What a finished game leaves** is a file of its own with the same envelope.
- **Player-made content** of the multiplayer battle uses the same envelope; the battle side holds its migrations, with frozen files as tests.
- **A running battle** is saved as its request and action list; loading replays it. If the content fingerprint no longer fits, the battle starts again from its request instead.
- **A file that cannot be read or migrated** is reported to the player and left untouched; it is never overwritten or repaired silently.

## 10. The Rebuild

**Everything is written anew, the rules too.** The prototype stays playable until the rebuilt battle passes the ported rule tests; equal results are a regression check, not gameplay validation.

- **The rule files are the specification.** Before the rebuild starts, every entry of [todo/implementation.md](todo/implementation.md) has become a rule or is dropped; where prototype and rule file still differ, the rule file is right.
- **The battle rules rest during the rebuild,** from its start until the rebuilt battle can be played by hand (step 5).
- **Not rebuilt:** what no rule file names. That is height and the air layer, Surges and delayed attacks, levels of ground and zones, bodies larger than one square, late-round pressure, stat shapes, bloodlines, the switches of removed mechanics and every record with the status `archived`.

1. The contract: actions, events, request, result, sheet.
2. `shared/`: records, vocabularies, checks, read functions; the content files that stay move.
3. The rule tests, rewritten against the contract.
4. The rules, until those tests pass; recorded prototype battles are compared by HP and positions after every action. A converter turns a prototype recording into a request and actions of the contract.
5. A plain board to play on: clickable and tappable, no animation, no art. The user plays the rebuilt rules by hand; the real view replaces it in step 7.
6. AI and tools.
7. `app/` services (settings with the language, translation, save, screen), then view and UI of the battle for touch and mouse.
8. The ingame battle on the core: tamer slots, catching, its prototype screen.
9. The hub.
10. The multiplayer battle: its generators, the draft, its builders and the map generator.
