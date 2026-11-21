# T61 · Align the Build and the Architecture with the Frame

**Status:** Open — the build follows the frame since 2026-11-21: the walked 3D world is removed and the hub game is built as a first version to click through (seven steps: clean-up, game state and hub, wild area, nest and training, dungeon, void with workshop and cultivation hall, cauldron and forge). [architecture.md](../../../architecture.md) does not follow it yet.
**Prerequisites:** the user's play of the hub game; T60 for what the hub shows.
**Sources:** [vision.md](../../../vision.md); [architecture.md](../../../architecture.md); [godot/README.md](../../../../godot/README.md) ("The hub game").

- **The build:** what works per building, the test values and what is not built stand in [godot/README.md](../../../../godot/README.md); the solutions chosen without a rule in [implementation.md](../../implementation.md) (I83–I103). Open in the build: pills and weapons in a battle (I22), the effect of armour and of development levels, what a game leaves behind, content beyond the first two stages, the form controls of the map editor for a finger.
- **Left from the old model:** `StatShape`, `MonsterInstance.roll` and `Stage.CAPS` serve only tests of the battle; the hub game buys stats with points. Remove them with T03.
- **architecture.md** still describes dialogues, story steps and faction requests of the overworld (its sections on dialogue, story and localization) and names the overworld by its old content. Rewrite those parts along the frame; the split into battle, overworld and `shared/` stays.
- **Old links:** earlier rows of [decisions.md](../../../decisions.md) point to sections of vision.md and overworld.md that no longer exist; the log is not rewritten.
- **Done when:** the user has played the hub game, architecture.md describes it, and the READMEs match the build.
