# T61 · Align the Build and the Architecture with the Frame

**Status:** Open — the rule files follow the frame of [vision.md](../../../vision.md); the build and [architecture.md](../../../architecture.md) do not yet.
**Prerequisites:** T60 for what the hub shows; the user's go for changes to the build.
**Sources:** [vision.md](../../../vision.md); [architecture.md](../../../architecture.md); [godot/README.md](../../../../godot/README.md).

- **The build** still holds the walked 3D world (`CityAreas`: districts of the ten groups, two wild areas, the Realm Gate, the Internal World as teleporters), resources taken for day AP, the old dungeon run and the Growth Preview with insights and weight. Decide per part: remove, keep as a test screen, or rebuild; then remove unused code and data.
- **architecture.md** still describes dialogues, story steps and faction requests of the overworld (its sections on dialogue, story and localization) and names the overworld by its old content. Rewrite those parts along the frame; the split into battle, overworld and `shared/` stays.
- **godot/README.md** follows the build and changes with it.
- **Old links:** earlier rows of [decisions.md](../../../decisions.md) point to sections of vision.md and overworld.md that no longer exist; the log is not rewritten.
- **Done when:** the build shows nothing the frame dropped, architecture.md describes the hub game, and the READMEs match the build.
