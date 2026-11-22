class_name VoidPanel
extends HubPanel
## The Void Gate (docs/vision.md §4, §6): the ladder of depths, the trial at its end and the Sovereign beast.


func title() -> String:
	return "Void Gate"


func pillar() -> String:
	return "Tamer"


func hint() -> String:
	return "Depths for Insight; the breakthrough trial"


func build(into: VBoxContainer) -> void:
	var n := VoidPlace.depths(game)
	var board := "You fight every battle here on the battleground you built." if game.is_artificer() else "Every battle here has a battleground of its own, shown below."
	into.add_child(HubUi.dim("An attack on the void is the deed of a year, won or lost. A depth is won once and gives one Insight; depth %d is the breakthrough trial. %s" % [n, board]))
	var list := HubUi.scroll(into)
	var ladder := HubUi.card(list)
	var steps := HubUi.row(10)
	steps.add_child(HubUi.label(Stage.stage_name(game.stage), 22, UiTheme.ACCENT, false))
	for d in n:
		var won := d < game.void_depth
		var next := d == VoidPlace.depth(game)
		steps.add_child(HubUi.chip("%s %d%s" % ["Trial" if d == n - 1 else "Depth", d + 1, ": won" if won else (": next" if next else "")],
			UiTheme.JADE if won else (UiTheme.CINNABAR if next else UiTheme.DIM), next))
	ladder.add_child(steps)
	if game.forced_trial:
		ladder.add_child(HubUi.label("Your lifespan has run out: the trial comes now, ready or not. Losing it loses the game.", 20, HubUi.WARN))
	var f := VoidPlace.fight(game)
	var foe := HubUi.card(list)
	foe.add_child(HubUi.title(f.title, 24))
	foe.add_child(HubUi.fight_view(f))
	foe.add_child(HubUi.dim("A win gives: %s" % f.loot_text))
	var problems := PackedStringArray()
	if game.is_artificer():
		var ground := HubUi.card(list)
		ground.add_child(HubUi.label("Your battleground: %s" % GameSession.battleground_summary()))
		problems = GameSession.battleground_problems()
		if not problems.is_empty():
			ground.add_child(HubUi.label("Not legal: %s" % "; ".join(problems), 20, HubUi.WARN))
		ground.add_child(HubUi.button("To the Battleground Workshop", hub.open.bind(&"workshop", &""), 360))
	var beast := VoidPlace.sovereign(game)
	var last := HubUi.card(list)
	last.add_child(HubUi.title("The Sovereign beast", 24))
	last.add_child(HubUi.dim("It waits from your first year on. Defeating it wins the game. It is the trial of %s; before that you may attack it in any year, and a defeat costs the year and nothing else." % Stage.stage_name(VoidPlace.LAST_STAGE)))
	last.add_child(HubUi.fight_view(beast))
	if not (VoidPlace.trial_is_sovereign(game) and VoidPlace.is_trial(game)):
		var early := HubUi.button("Prepare: attack the Sovereign beast now", hub.prepare.bind(beast, func(_f: Fight) -> bool: return VoidPlace.pay_sovereign(game)), 480)
		early.disabled = VoidPlace.problem(game) != "" or game.forced_trial or not problems.is_empty()
		last.add_child(early)
	var why := VoidPlace.problem(game)
	if why != "":
		list.add_child(HubUi.label("You cannot enter: %s." % why, 20, HubUi.WARN))
	var go := HubUi.primary("Prepare: %s" % f.title, hub.prepare.bind(f, func(_f: Fight) -> bool: return VoidPlace.pay(game)), 480)
	go.disabled = why != "" or not problems.is_empty()
	into.add_child(go)
