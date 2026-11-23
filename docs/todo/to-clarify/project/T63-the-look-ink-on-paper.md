# T63 · The Look: Ink on Paper

**Status:** Built as a first full pass, to be looked at by the user. The style is decided (user, 2026-11-22; [decisions.md](../../../decisions.md)); what is built and where: [godot/README.md](../../../../godot/README.md), "Look: ink on paper".
**Prerequisites:** the user plays through the screens.
**Sources:** [vision.md](../../../vision.md) (phone in landscape and PC).

**Built:** the theme of every control, two fonts, the paper ground, 41 signs, the painted board with ground signs and zone arrows, the hub screens (buildings, monsters, gates with a small painted battleground, cultivation, forge, cauldron, workshop, inventory, the preparation of a fight, the start of a game), the battle HUD, the map editor and the tables of the overview.

**Built after the first pass:** the bodies of the monsters, from code (user, 2026-11-23): two or three bodies per Kin, one named by each species, with an ink line and movements for walking, attacking, casting, being hit, pushed, healed and defeated; and the figures of the props, a figure per prop named in its data, that appear, shake, slide, snap and fall apart ([godot/README.md](../../../../godot/README.md), "Bodies" and "Props").

**To confirm (chosen while building):**

- A Kin is shown by the part its beasts leave (Fang for Beast, Feather for Winged, …); there is no second set of Kin emblems.
- The cauldron says what the picked plants are known to share, from found properties only.
- The forge and the cauldron read left to right in three columns; on a narrow phone the columns do not wrap yet.
- Titles use a serif (Shippori Mincho); a brush hand was tried and dropped because its capitals were hard to read.
- A button in a column is as wide as its text, no longer as wide as the column.
- The twenty bodies and their movements, seen by the user only as still pictures: the shapes, which body each species has, the pale flash of a hit, the speed of the movements.
- The figures of the props: which figure each prop has, and whether a trap (spikes, dome, rings) reads as walkable beside a solid prop. Archived props without a figure of their own stand as a block.

**Open:**

- Seen only as screenshots at 1920×1080; not played by hand, not seen on a phone. Touch sizes follow `HubUi.TAP` as before.
- Not looked at: the dungeon while a run is going, the game over screen, the skill and monster builders, the pause menu and the glossary of the battle, the end banner.
- Not drawn: a picture per species, a background per building, the signs of single tamer skills and vows (one sign each for all of them), transitions between screens, sounds.
- The colours of grounds, zones and props in `godot/data` were chosen for the dark screen; on paper some are loud (Dragon Vein cyan). A pass over the data colours is open.

**Done when:** the user has seen the screens and decided the points above.
