class_name SkillsPanel
extends HubPanel
## The kit of each monster (docs/skills.md §1, §8; docs/monsters.md §5): the skills in its slots, their development
## and the choice at a stage breakthrough. The options of a skill are not defined, so a level changes nothing in a
## battle yet; a Kin trait acts in a battle, a gift only if it is built (KinDef).


func build(into: VBoxContainer) -> void:
	into.add_child(HubUi.dim("A monster starts with %d slots. At each stage breakthrough it takes one of three: a new slot, a development step, or a gift of its Kin. The trait of its Kin acts in every battle. Not built yet: a skill level changes nothing in a battle, and so does a gift marked \"not built\"." % MonsterInstance.START_SLOTS))
	var list := HubUi.scroll(into)
	for m in game.roster:
		var card := HubUi.card(list)
		card.add_child(HubUi.label("%s — %d of %d slots filled, %d development step(s) unspent" % [m.title(), m.kit.size(), m.slots, m.dev_steps], 22, UiTheme.ACCENT))
		card.add_child(HubUi.dim(HubUi.kin_lines(m)))
		if m.choice_picks > 0:
			_choice(card, m)
		var skills := m.kit_skills()
		for slot in skills.size():
			var s := skills[slot]
			var row := HubUi.row()
			card.add_child(row)
			row.add_child(HubUi.label("Slot %d: %s (%s) · level %d\n%s" % [slot + 1, s.display_name, _kind(s), m.slot_level(slot), GameSession.skill_text(s)]))
			var b := HubUi.button("Develop", func():
				m.develop_slot(slot)
				hub.refresh(), 150)
			b.disabled = m.dev_steps <= 0 or m.slot_level(slot) >= 3
			row.add_child(b)
			if m.fresh:
				row.add_child(HubUi.button("Take out", func():
					m.unlearn(slot)
					hub.refresh(), 150))
		if m.kit.size() < m.slots:
			card.add_child(HubUi.label("%d free slot(s): choose from what it can learn.%s" % [m.slots - m.kit.size(), "" if m.fresh else " A choice is final."], 20, HubUi.GOOD))
			for s in m.learnable():
				if m.kit.has(s.id):
					continue
				var row := HubUi.row()
				card.add_child(row)
				row.add_child(HubUi.label("%s (%s)\n%s" % [s.display_name, _kind(s), GameSession.skill_text(s)]))
				row.add_child(HubUi.button("Learn", func():
					m.learn(s.id)
					hub.refresh(), 150))


func _kind(s: BattleSkillDef) -> String:
	return "%d AP" % s.ap_cost if s.is_active() else "passive"


func _choice(card: VBoxContainer, m: MonsterInstance) -> void:
	card.add_child(HubUi.label("Stage breakthrough: choose %d of the three." % m.choice_picks, 20, HubUi.GOOD))
	var row := HubUi.flow()
	card.add_child(row)
	for c in [MonsterInstance.BREADTH, MonsterInstance.DEPTH]:
		var b := HubUi.button(MonsterInstance.CHOICE_NAMES[c], func():
			m.choose(c)
			hub.refresh(), 330)
		b.disabled = not m.can_choose(c)
		row.add_child(b)
	var kin := m.species().kin
	if m.can_choose(MonsterInstance.BLOOD):
		for g in m.open_gifts():
			row.add_child(HubUi.button("Blood: %s" % KinDef.gift_line(kin, g), func():
				m.choose(MonsterInstance.BLOOD, g)
				hub.refresh(), 330))
