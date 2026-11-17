class_name KinRules
extends RefCounted
## The Kin twist every Strike of a Kin carries (gdd_skills §8.1 table) as data.
## Values are gameplay effects, not construction points. `text` is the short card line.
##   retreat           retreat 1 square opposite the shape centre, once per use (Winged Dive)
##   push              push each struck monster 1 square in the chosen cardinal direction (Scaled)
##   prop_damage       damage against props instead of 2 (Swarm Gnaw: 4)
##   pace_penalty      struck monsters get -N Pace points (0.1 each) next round (Spirit Siphon)
##   destroy_mountain  destroys the Mountain under each struck target (Ancient Slam)

const STRIKE := {
	MonsterDef.Kin.BEAST: {"name": "Bite", "text": ""},
	MonsterDef.Kin.WINGED: {"name": "Dive", "retreat": true, "text": "then retreat 1"},
	MonsterDef.Kin.SCALED: {"name": "Tail Sweep", "push": true, "text": "push 1 (chosen)"},
	MonsterDef.Kin.SWARM: {"name": "Gnaw", "prop_damage": 4, "text": "props take 4"},
	MonsterDef.Kin.SPIRIT: {"name": "Siphon", "pace_penalty": 1, "text": "−0.1 Pace next round"},
	MonsterDef.Kin.ANCIENT: {"name": "Slam", "destroy_mountain": true, "text": ""},
}
const STRIKE_DAMAGE := 2
const STRIKE_PROP_DAMAGE := 2


static func strike(kin: int) -> Dictionary:
	return STRIKE.get(kin, {})


static func strike_name(kin: int) -> String:
	return strike(kin).get("name", "Strike")


## The Kin of the striker adds nothing to a Strike (rule since 2026-11-17): always {}.
static func of(_skill: BattleSkillDef, _kin: int) -> Dictionary:
	return {}
