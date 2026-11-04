# Road of the Beasts — Godot project

```
shared/      data schemas and the cultivation model, used by every part
             aspect, shapes, MonsterDef / SkillDef / ZoneDef / ZoneEffect (species + skills + zones),
             Stage, StatShape, MonsterInstance (the individual monster), BattleRequest / BattleResult
             (the contract between battle and overworld), GameData (registry), UiTheme
battle/      the deterministic grid battle (gdd_battle.md)
  core/      headless rules: Battle, Board, Square, Rules, AiBrain, CastPreview, InfoText,
             BattleSetup (builds a Battle from a BattleRequest, reads a BattleResult out of it)
  view/      3D board and the input controller
  ui/        battle HUD and the pre-battle draft screen
  battle.tscn, draft.tscn
overworld/   days, AP, night phase, economy, internal world (gdd_overworld.md)
  core/      headless: GameState (day, AP, money, owned individuals), Expedition (dungeon run)
  ui/        hub screen; overworld.tscn
game/        glue: main menu, settings, SaveGame, autoloads (GameSettings, GameSession)
data/        content as Resource files: monsters/, skills/, zones/ (a new file = new content)
tests/       gdUnit4 suites: tests/battle, tests/shared, tests/overworld, tests/game
tools/       sim.gd (AI-vs-AI balance runs), smoke_ui.gd (plays the real UI headless)
```

## Dependency rule

`shared` ← `battle` ← `game`, and `shared` ← `overworld` ← `game`.
Battle and overworld **never import each other**: the overworld builds a `BattleRequest`, the battle
returns a `BattleResult` (gdd_overworld §1.3) — both classes live in `shared/`. `game/` is the only place
that knows both halves (menu, `GameSession`, saves).

Known exception to clean up later: `shared/skill_def.gd`, `shared/shapes.gd` and
`shared/game_data.gd` still use `Square.GroundType` and `Board.Placement` from `battle/core`.
Moving those two enums into `shared` removes the last upward dependency.
