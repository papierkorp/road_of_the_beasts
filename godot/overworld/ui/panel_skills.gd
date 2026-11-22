class_name SkillsPanel
extends HubPanel
## The kit of each monster (docs/skills.md §1, §8; docs/monsters.md §5): the skills in its slots, the development of
## each slot and the choice at a stage breakthrough. A slot is developed, not a skill: it has a level of 1 to 3,
## and each level above the first takes one option of the kind of its skill (SkillDev). When a slot takes another
## skill (the relearning pill of the Alchemist) it keeps its level and its options are chosen anew.

## The slot whose skill is being replaced: [index in the roster, slot], or [] for none.
static var relearning: Array = []


func build(into: VBoxContainer) -> void:
	into.add_child(HubUi.dim("A monster starts with %d slots. At each stage breakthrough it takes one of: a new slot, a development step, a skill of another species of its Kin, or its stat points anew. A development step raises a slot by a level (up to %d) and adds one option of the kind of its skill; the slot keeps its level when it takes another skill." % [MonsterInstance.START_SLOTS, SkillDev.MAX_LEVEL]))
	var list := HubUi.scroll(into)
	for index in game.roster.size():
		var m := game.roster[index]
		var card := HubUi.card(list)
		card.add_child(HubUi.monster_head(m))
		card.add_child(HubUi.label("%d of %d slots filled · %d development step(s) unspent" % [m.kit.size(), m.slots, m.dev_steps], 18, HubUi.GOOD if m.dev_steps > 0 else UiTheme.ACCENT))
		card.add_child(HubUi.dim(HubUi.kin_lines(m)))
		if m.choice_picks > 0:
			_choice(card, m)
		var skills := m.kit_skills()
		for slot in skills.size():
			_slot(card, index, m, slot, skills[slot])
		if m.kit.size() < m.slots:
			card.add_child(HubUi.label("%d free slot(s): choose from what it can learn.%s" % [m.slots - m.kit.size(), "" if m.fresh else " A choice is final."], 20, HubUi.GOOD))
			for s in m.learnable():
				if m.kit.has(s.id):
					continue
				var row := HubUi.row()
				card.add_child(row)
				row.add_child(HubUi.skill_line(s, "%s · %s" % [s.display_name, _kind(s)], GameSession.skill_text(s)))
				row.add_child(HubUi.button("Learn", func():
					m.learn(s.id)
					hub.refresh(), 150))


## One slot: its skill as it goes into a battle, its level, the options it took and those it may take now.
func _slot(card: VBoxContainer, index: int, m: MonsterInstance, slot: int, s: BattleSkillDef) -> void:
	var taken := m.slot_options(slot)
	var row := HubUi.row()
	card.add_child(row)
	row.add_child(HubUi.skill_line(s, "Slot %d: %s · %s · level %d" % [slot + 1, s.display_name, _kind(s), m.slot_level(slot)],
		GameSession.skill_text(SkillDev.developed(s, taken))))
	if m.fresh:
		row.add_child(HubUi.button("Take out", func():
			m.unlearn(slot)
			hub.refresh(), 150))
	if Crafting.clarity_pill(game) != "" and not m.fresh:
		var open := relearning == [index, slot]
		row.add_child(HubUi.button("Keep it" if open else "Relearn", func():
			relearning = [] if open else [index, slot]
			hub.refresh(), 150))
	if not taken.is_empty():
		var chips := HubUi.flow(6)
		for o in taken:
			chips.add_child(HubUi.chip(SkillDev.option_name(String(o)), UiTheme.JADE))
		card.add_child(chips)
	var options := m.open_options(slot)
	var free := m.open_picks(slot) > 0           # the level already allows one more option
	var by_step := not free and m.dev_steps > 0 and m.slot_level(slot) < SkillDev.MAX_LEVEL
	if free or by_step:
		if options.is_empty():
			if by_step:
				card.add_child(HubUi.dim("This skill has no option left to take."))
		else:
			card.add_child(HubUi.label("Choose an option for this slot:" if free else "Develop this slot (1 development step):", 17, HubUi.GOOD))
			var picks := HubUi.flow(10)
			card.add_child(picks)
			for o in options:
				picks.add_child(HubUi.button(SkillDev.option_name(o), func():
					if free:
						m.pick_option(slot, o)
					else:
						m.develop_slot(slot, o)
					hub.refresh(), 420))
	if relearning == [index, slot]:
		card.add_child(HubUi.label("A relearning pill: slot %d takes another skill. It keeps level %d; its options are chosen anew." % [slot + 1, m.slot_level(slot)], 17, HubUi.GOOD))
		for other in m.learnable():
			if m.kit.has(other.id):
				continue
			var line := HubUi.row()
			card.add_child(line)
			line.add_child(HubUi.skill_line(other, "%s · %s" % [other.display_name, _kind(other)], GameSession.skill_text(other)))
			line.add_child(HubUi.primary("Take", func():
				Crafting.relearn(game, m, slot, other.id)
				relearning = []
				hub.refresh(), 150))


func _kind(s: BattleSkillDef) -> String:
	return "%d AP" % s.ap_cost if s.is_active() else "passive"


func _choice(card: VBoxContainer, m: MonsterInstance) -> void:
	card.add_child(HubUi.label("Stage breakthrough: choose %d of these." % m.choice_picks, 20, HubUi.GOOD))
	var row := HubUi.flow()
	card.add_child(row)
	for c in [MonsterInstance.BREADTH, MonsterInstance.DEPTH, MonsterInstance.RESHAPE]:
		var b := HubUi.button(MonsterInstance.CHOICE_NAMES[c], func():
			m.choose(c)
			hub.refresh(), 380)
		b.disabled = not m.can_choose(c)
		row.add_child(b)
	if m.can_choose(MonsterInstance.LORE):
		for s in m.lore_options():
			row.add_child(HubUi.button("Lore: %s" % s.display_name, func():
				m.choose(MonsterInstance.LORE, s.id)
				hub.refresh(), 380))
