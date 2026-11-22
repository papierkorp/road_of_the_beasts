class_name VoidPanel
extends HubPanel
## Void Gate (docs/vision.md §4, §6): the next depth on the player's own battleground; the last one is the trial.


func title() -> String:
	return "Void Gate"


func pillar() -> String:
	return "Tamer"


func hint() -> String:
	return "Depths on your own battleground; the trial"


func build(into: VBoxContainer) -> void:
	var n := VoidPlace.depths(game)
	into.add_child(HubUi.dim("The void has no ground: every battle here is fought on your own battleground. A depth costs %d AP and is won once; each gives one Insight. Depth %d is the breakthrough trial." % [game.values.void_ap, n]))
	var list := HubUi.scroll(into)
	var ladder := HubUi.card(list)
	var steps: PackedStringArray = []
	for d in n:
		var mark := "won" if d < game.void_depth else ("next" if d == VoidPlace.depth(game) else "waits")
		steps.append("%s %d: %s" % ["Trial" if d == n - 1 else "Depth", d + 1, mark])
	ladder.add_child(HubUi.label("%s — %s" % [Stage.stage_name(game.stage), "   ·   ".join(steps)], 22, UiTheme.ACCENT))
	if game.forced_trial:
		ladder.add_child(HubUi.label("Your lifespan has run out: the trial comes now, ready or not. Losing it loses the game.", 20, HubUi.WARN))
	var f := VoidPlace.fight(game)
	var foe := HubUi.card(list)
	foe.add_child(HubUi.label(f.title, 22, UiTheme.ACCENT))
	for m in f.enemies:
		foe.add_child(HubUi.label(HubUi.monster_lines(m)))
	foe.add_child(HubUi.dim("A win gives: %s" % f.loot_text))
	var ground := HubUi.card(list)
	ground.add_child(HubUi.label("Your battleground: %s" % GameSession.battleground_summary()))
	var problems := GameSession.battleground_problems()
	if not problems.is_empty():
		ground.add_child(HubUi.label("Not legal: %s" % "; ".join(problems), 20, HubUi.WARN))
	ground.add_child(HubUi.button("To the Battleground Workshop", hub.open.bind(&"workshop", &""), 360))
	var beast := VoidPlace.sovereign(game)
	var last := HubUi.card(list)
	last.add_child(HubUi.label("The Sovereign beast — the last depth of the void", 22, UiTheme.ACCENT))
	last.add_child(HubUi.dim("It waits from your first year on. Defeating it makes you Sovereign and wins the game. It is the trial of %s; before that you may attack it in any year for %d AP, and a defeat costs nothing else." % [Stage.stage_name(VoidPlace.LAST_STAGE), game.values.void_ap]))
	for m in beast.enemies:
		last.add_child(HubUi.label(HubUi.monster_lines(m)))
	if not (VoidPlace.trial_is_sovereign(game) and VoidPlace.is_trial(game)):
		var early := HubUi.button("Prepare: attack the Sovereign beast now", hub.prepare.bind(beast, func(_f: Fight) -> bool: return VoidPlace.pay_sovereign(game)), 480)
		early.disabled = VoidPlace.problem(game) != "" or game.forced_trial or not problems.is_empty()
		last.add_child(early)
	var why := VoidPlace.problem(game)
	if why != "":
		list.add_child(HubUi.label("You cannot enter: %s." % why, 20, HubUi.WARN))
	var go := HubUi.button("Prepare: %s" % f.title, hub.prepare.bind(f, func(_f: Fight) -> bool: return VoidPlace.pay(game)), 480)
	go.disabled = why != "" or not problems.is_empty()
	into.add_child(go)
