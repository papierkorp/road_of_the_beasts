class_name Moment
extends RefCounted
## The one list of moments at which ground, a zone or a prop acts (gdd_battle §2.4), and which of the
## three may act when and how: the roles of gdd_battle §4.3 as a permission table. Ground triggers and
## prop operations name their moment with these values.

const ENTER := "enter"              # a monster enters the square: by walking, by a push or by a pull
const LEAVE := "leave"              # a monster leaves the square
const INSIDE := "inside"            # as long as a monster stands on it (a prop: as long as the prop stands)
const TURN_END := "turn_end"        # at the end of the occupant's turn
const ROUND_END := "round_end"      # at the end of the round
const HIT := "hit"                  # a prop lost HP and still stands
const DESTROYED := "destroyed"      # a prop is removed at 0 HP
## Not a moment of the game (gdd_battle §2.4: nothing acts at the start of a turn or of a round);
## kept for archived records and the tests of the earlier timing.
const TURN_START := "turn_start"

const ALL: Array[String] = [ENTER, LEAVE, INSIDE, TURN_END, ROUND_END, HIT, DESTROYED]
const NAMES := {ENTER: "on entering", LEAVE: "on leaving", INSIDE: "while inside", TURN_END: "at the end of its turn",
	ROUND_END: "at the end of the round", HIT: "when hit", DESTROYED: "when destroyed", TURN_START: "at the start of its turn"}

## Moments each kind may use.
const MOMENTS := {
	"ground": [ENTER, LEAVE, TURN_END, ROUND_END],
	"zone": [INSIDE, TURN_END],
	"prop": [INSIDE, ENTER, ROUND_END, HIT, DESTROYED],
}
## What each kind may do (effect words of BoardSheet). `experiment` effects (AP, turns per round on
## others) are in the vocabulary but in no content of the game.
const EFFECTS := {
	"ground": ["damage", "heal"],
	"zone": ["slow", "haste", "drain_pace", "quicken", "drain_range", "extend", "push", "pull", "sap", "vigor", "tempo"],
	"prop": ["damage", "push", "pull", "ground", "zone", "prop", "slow", "haste", "drain_pace", "quicken", "drain_range", "extend"],
}


static func moment_name(when: String) -> String:
	return NAMES.get(when, when)
