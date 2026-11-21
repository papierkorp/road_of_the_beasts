class_name ScripturePanel
extends HubPanel
## Scripture Hall (docs/vision.md §6, docs/skills.md §8): the kit of each monster and the development of its slots.
## The options of a skill are not defined, so a level changes nothing in a battle yet.


func title() -> String:
	return "Scripture Hall"


func pillar() -> String:
	return "Monster: kit"


func hint() -> String:
	return "Kits and skill development"


func build(into: VBoxContainer) -> void:
	into.add_child(HubUi.dim("A monster gains development steps as it grows. A step raises one slot to level 2 or 3. The options of the skills are not written yet: a level has no effect in a battle."))
	var list := HubUi.scroll(into)
	for m in game.roster:
		var card := HubUi.card(list)
		card.add_child(HubUi.label("%s — %d development step(s) unspent" % [m.title(), m.dev_steps], 22, UiTheme.ACCENT))
		var skills := m.species().skills
		for slot in skills.size():
			var s := skills[slot]
			if s == null:
				continue
			var row := HubUi.row()
			card.add_child(row)
			var kind := "%d AP" % s.ap_cost if s.is_active() else "passive"
			row.add_child(HubUi.label("%s (%s) · level %d\n%s" % [s.display_name, kind, m.slot_level(slot), s.description]))
			var b := HubUi.button("Develop", func():
				m.develop_slot(slot)
				hub.refresh(), 160)
			b.disabled = m.dev_steps <= 0 or m.slot_level(slot) >= 3
			row.add_child(b)
