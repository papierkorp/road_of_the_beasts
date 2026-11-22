class_name MonstersPanel
extends HubTabs
## Monsters (docs/vision.md §6): everything about the monsters in one building: the roster and the eggs, their stat
## points, their skills and what they choose at a stage breakthrough.


func title() -> String:
	return "Monsters"


func pillar() -> String:
	return "Monster"


func hint() -> String:
	var todo := 0
	for m in game.roster:
		if HubUi.todo_text(m) != "":
			todo += 1
	return "Roster, stats, skills" + ("\n%d with something to decide" % todo if todo > 0 else "")


func tabs() -> Array:
	return [[&"roster", "Roster and eggs", RosterPanel], [&"stats", "Stats", StatsPanel], [&"skills", "Skills and growth", SkillsPanel]]
