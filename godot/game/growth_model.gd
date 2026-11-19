class_name GrowthModel
extends RefCounted
## The growth of docs/vision.md §8 as a model one can click through (game/growth_preview.gd): what a step gives
## to everyone, where the player chooses, and where the rules have a gap. A test tool, not the game: the tables
## below are the working drafts of vision.md §8, monsters.md §4–5, skills.md §8 and overworld.md §6.4; the insights,
## the numbers of the Internal World and the count of the visible weight are placeholders written for this screen.

const SUB := ["Lower", "Middle", "High"]
const ARCS := ["School", "Family", "One-time realm", "Monster riot", "Struggle for the city", "Leaving"]
const TAMER_SLOTS := [1, 2, 3, 3, 4, 4]
const OPENS := [
	"catching; the Internal World with a field and a cauldron; the wild area of the school",
	"habitats, a forge and the first golem",
	"a house of one's own and its orders at night",
	"Beast Swap",
	"battlegrounds for five monsters; holding districts",
	"the barrier opens: the player can leave the city, the game can end",
]
const WORLD_GRID := [6, 8, 10, 12, 14, 16]
const WORLD_HOLDS := [2, 3, 5, 7, 9, 12]          # placeholder
const WORLD_GROUNDS := [0, 1, 2, 3, 4, 5]         # own battlegrounds, placeholder
const HOUSE_STAGE := 2                            # Core Formation, draft

## One of three at every breakthrough: battle, people, craft and trade. Placeholders.
const INSIGHTS := {
	1: [
		{"label": "Battle · Bound Seal", "text": "The Seal skill no longer takes a tamer slot."},
		{"label": "People · A Name Remembered", "text": "Every key person offers one request more."},
		{"label": "Craft and trade · Keen Nose", "text": "One property of every plant is known from the start."},
	],
	2: [
		{"label": "Battle · Field Sense", "text": "You see the battleground before you choose your team."},
		{"label": "People · Open Gate", "text": "The house holds two people more."},
		{"label": "Craft and trade · Steady Fire", "text": "A cauldron or forge makes one piece more per night."},
	],
	3: [
		{"label": "Battle · Deep Bench", "text": "One more monster waits on the bench for Beast Swap."},
		{"label": "People · Banner", "text": "Orders of the house count as one rank stronger at night."},
		{"label": "Craft and trade · Master's Mark", "text": "Pieces you sign sell higher and raise standing."},
	],
	4: [
		{"label": "Battle · Home Ground", "text": "Your own battleground may hold one more thing."},
		{"label": "People · Many Hands", "text": "Two orders of the house for one day AP."},
		{"label": "Craft and trade · Open Ledger", "text": "You see the offers of the Auction Hall a night ahead."},
	],
	5: [
		{"label": "Battle · Unbroken Contract", "text": "An injured monster recovers in one night."},
		{"label": "People · An Heir Named", "text": "The house stands on when you leave the city."},
		{"label": "Craft and trade · Grandmaster", "text": "You can make pieces of the highest grade."},
	],
}
## The tamer skills a breakthrough offers (overworld.md §6.4); Immortal and Sovereign list none.
const TAMER_SKILLS := {
	1: ["Qi Suppression", "Spirit Shield", "Swap Places"],
	2: ["Domain Glimpse", "Urgent Order", "Second Wind", "Life Thread"],
	3: ["Beast Swap"],
}
const SEAL_OPTIONS := [
	{"label": "Wide Seal (Area)", "text": "Seal Ground on two adjacent squares."},
	{"label": "Strong Seal (Number)", "text": "Base chance 65 %."},
	{"label": "Patient Seal (Number)", "text": "5 points less per HP instead of 10."},
	{"label": "Drawing Seal (Addition)", "text": "Seal Ground also pulls like a pull zone."},
	{"label": "Walled Seal (Addition)", "text": "Lays Earth Walls on the free squares around it."},
	{"label": "Deep Seal (Condition)", "text": "A seal one tier below the target suffices."},
]
const VOCAB := ["Area", "Number", "Duration", "Addition", "Condition", "Count"]
const RARITIES := ["Normal", "Rare", "Epic", "Legendary"]
const RARITY_LAST := [2, 3, 4, 5]                 # the highest stage of a rarity
const RARITY_STEPS := [1, 1, 2, 2]                # development steps per new stage
const EXTRA_STEP_AT := [13, 14, 16, 17]           # Immortal and Sovereign, Middle and High
const CRAFT_RANKS := ["none", "Apprentice", "Journeyman", "Adept", "Master", "Grandmaster"]
const WINGS := ["School", "Workshop", "Trading hall", "Monster hall"]
const STAT_MAX := {"hp": 10, "pace": 100, "stam": 10, "reach": 10, "tpr": 3, "ap": 5}

var step := 0                 ## the tamer's step, 0–17 (stage × 3 + sub-tier)
var world := 0                ## the stage of the Internal World, never above the tamer's
var shown := 0                ## arcs at whose end the player showed themselves
var insights: Array[String] = []
var skills := {"Seal": []}    ## tamer skill → the options chosen; its level is 1 + their number
var alchemy := 0
var smith := 0
var house := ""               ## "", "open" or "hidden"
var wings: Array[String] = []
var monsters: Array[Dictionary] = []
var entries: Array[Dictionary] = []    ## the log: {kind: choice | fixed | gap | note, text}
var pending: Array[Dictionary] = []    ## open choices: {title, text, options: [{label, text}], on}
var _caught := 0


func stage() -> int:
	return step / 3


func sub() -> int:
	return step % 3


static func step_name(s: int) -> String:
	return "%s %s" % [Stage.NAMES[s / 3], SUB[s % 3]]


func tamer_slots() -> int:
	return TAMER_SLOTS[stage()]


## A placeholder count, only to show what moves it: the stage, every arc end shown, craft ranks and an open house.
func visible_weight() -> int:
	var w := stage() + shown * 2 + alchemy + smith
	if house == "open":
		w += 1 + wings.size()
	return w


func choose(i: int) -> void:
	if pending.is_empty():
		return
	var c: Dictionary = pending.pop_front()
	(c["on"] as Callable).call(i)


func _ask(title: String, text: String, options: Array, on: Callable, front: bool = false) -> void:
	var c := {"title": title, "text": text, "options": options, "on": on}
	if front:
		pending.push_front(c)
	else:
		pending.append(c)


func _log(kind: String, text: String) -> void:
	entries.append({"kind": kind, "text": text})


# ---------------------------------------------------------------- the tamer

func can_advance() -> bool:
	return step < 17 and pending.is_empty()


func advance_text() -> String:
	if step >= 17:
		return "The last step is reached"
	if sub() < 2:
		return "Advance to %s" % step_name(step + 1)
	return "End the arc and break through to %s" % Stage.NAMES[stage() + 1]


func advance() -> void:
	if not can_advance():
		return
	if sub() < 2:
		step += 1
		_log("gap", "Tamer: %s. A sub-tier gives the tamer nothing in the frame (not defined)." % step_name(step))
		return
	_ask("The arc ends: %s" % ARCS[stage()], "Show yourself or stay unseen. The same choice ends every arc.", [
		{"label": "Show yourself", "text": "You take the reward of the arc and standing. Your visible weight rises, so groups react sooner."},
		{"label": "Stay unseen", "text": "No reward and no standing. Your visible weight stays, and you are left alone longer."},
	], _arc_end)


func _arc_end(i: int) -> void:
	var arc: String = ARCS[stage()]
	if i == 0:
		shown += 1
		_log("choice", "Arc %s: you showed yourself. Reward and standing; visible weight +2." % arc)
	else:
		_log("choice", "Arc %s: you stayed unseen. No reward; visible weight unchanged." % arc)
	_log("note", "Trial of the breakthrough: a battle on the board, the only battle the game requires.")
	step += 1
	var s := stage()
	_log("fixed", "Tamer: breakthrough to %s. The arc %s begins." % [Stage.NAMES[s], ARCS[s]])
	if TAMER_SLOTS[s] > TAMER_SLOTS[s - 1]:
		_log("fixed", "Tamer slot %d: for a tamer skill, a weapon or a pill." % TAMER_SLOTS[s])
	_log("fixed", "Monsters may now reach %s; the Internal World may be raised to stage %d." % [Stage.NAMES[s], s + 1])
	_log("fixed", "Opens besides (draft): %s." % OPENS[s])
	_ask("Insight of the breakthrough to %s" % Stage.NAMES[s], "Choose one of three. The other two are gone for good.",
		INSIGHTS[s], _take_insight.bind(s))
	var offer: Array = []
	for n: String in TAMER_SKILLS.get(s, []):
		if not skills.has(n):
			offer.append({"label": n, "text": "Learned for good; it takes a tamer slot when brought into a battle."})
	if offer.is_empty():
		_log("gap", "No tamer skill is listed for %s (not defined)." % Stage.NAMES[s])
		_ask_tamer_step()
	else:
		_ask("A tamer skill of %s" % Stage.NAMES[s], "Every breakthrough teaches one skill of the stage's list.", offer, _learn.bind(offer))


func _take_insight(i: int, s: int) -> void:
	var o: Dictionary = INSIGHTS[s][i]
	insights.append(o["label"])
	_log("choice", "Insight: %s. %s" % [o["label"], o["text"]])


func _learn(i: int, offer: Array) -> void:
	var n: String = offer[i]["label"]
	skills[n] = []
	_log("choice", "Tamer skill learned: %s." % n)
	_ask_tamer_step()


func _ask_tamer_step() -> void:
	var names: Array = []
	var opts: Array = []
	for n: String in skills:
		var lv: int = (skills[n] as Array).size() + 1
		if lv < 3:
			names.append(n)
			opts.append({"label": "%s: level %d → %d" % [n, lv, lv + 1], "text": "One option of the list written for this skill."})
	if names.is_empty():
		_log("gap", "A development step for a tamer skill, but every learned skill is at level 3.")
		return
	_ask("Development step for a tamer skill", "One step per breakthrough; more come from upgrade scrolls.", opts, _tamer_skill_picked.bind(names))


func _tamer_skill_picked(i: int, names: Array) -> void:
	var n: String = names[i]
	if n != "Seal":
		(skills[n] as Array).append("option not defined")
		_log("choice", "%s is now level %d." % [n, (skills[n] as Array).size() + 1])
		_log("gap", "The options of %s are not defined." % n)
		return
	var opts: Array = []
	for o: Dictionary in SEAL_OPTIONS:
		if not (skills[n] as Array).has(o["label"]):
			opts.append(o)
	_ask("Seal: which option?", "Each option once; level 3 holds two.", opts, _seal_option.bind(opts), true)


func _seal_option(i: int, opts: Array) -> void:
	(skills["Seal"] as Array).append(opts[i]["label"])
	_log("choice", "Seal is now level %d: %s." % [(skills["Seal"] as Array).size() + 1, opts[i]["label"]])


# ---------------------------------------------------------------- the Internal World

func world_block() -> String:
	if world >= 5:
		return "the last stage is reached"
	if world >= stage():
		return "never above the tamer's stage (%s)" % Stage.NAMES[stage()]
	return ""


func raise_world() -> void:
	if world_block() != "" or not pending.is_empty():
		return
	world += 1
	_log("fixed", "Internal World: stage %d for materials at the world core. Grid %d×%d, holds %d monsters, %d own battlegrounds." % [
		world + 1, WORLD_GRID[world], WORLD_GRID[world], WORLD_HOLDS[world], WORLD_GROUNDS[world]])


# ---------------------------------------------------------------- ladders of deeds

func pass_trial(craft: String) -> void:
	if not pending.is_empty() or int(get(craft)) >= 5:
		return
	set(craft, int(get(craft)) + 1)
	_log("fixed", "%s: the hall's trial passed, rank %s. Better requests and ingredients; visible weight +1." % [
		"Alchemy" if craft == "alchemy" else "Smithing", CRAFT_RANKS[int(get(craft))]])


func house_block() -> String:
	if house != "":
		return "the house stands"
	if stage() < HOUSE_STAGE:
		return "from %s (draft)" % Stage.NAMES[HOUSE_STAGE]
	return ""


func found_house() -> void:
	if house_block() != "" or not pending.is_empty():
		return
	_ask("Found the house", "Openly or in hiding.", [
		{"label": "Openly", "text": "The eleventh group of the city. The house and each wing add to your visible weight."},
		{"label": "In hiding", "text": "Adds no visible weight. Every order costs more; only the story uncovers it."},
	], _house_founded)


func _house_founded(i: int) -> void:
	house = "open" if i == 0 else "hidden"
	_log("choice", "The house is founded %s." % ("openly: visible weight +1" if i == 0 else "in hiding: no visible weight, orders cost more"))


func add_wing() -> void:
	if house == "" or wings.size() >= WINGS.size() or not pending.is_empty():
		return
	var opts: Array = []
	for w: String in WINGS:
		if not wings.has(w):
			opts.append({"label": w, "text": "What a wing needs and gives is not defined."})
	_ask("A wing for the house", "Which wings the player builds is the route. All of them can follow later.", opts, _wing_added.bind(opts))


func _wing_added(i: int, opts: Array) -> void:
	wings.append(opts[i]["label"])
	_log("choice", "Wing built: %s." % opts[i]["label"])


# ---------------------------------------------------------------- monsters

func catch_block() -> String:
	if monsters.size() >= WORLD_HOLDS[world]:
		return "the Internal World holds %d: raise it first" % WORLD_HOLDS[world]
	return ""


func catch_monster() -> void:
	if catch_block() != "" or not pending.is_empty():
		return
	var opts: Array = []
	for r in RARITIES.size():
		opts.append({"label": RARITIES[r], "text": "Ends at %s; %d development step(s) per new stage." % [Stage.NAMES[RARITY_LAST[r]], RARITY_STEPS[r]]})
	_ask("A new monster", "In the game the rarity is what you catch, buy or hatch; here you pick it.", opts, _caught_one)


func _caught_one(r: int) -> void:
	_caught += 1
	monsters.append({"name": "Monster %d" % _caught, "rarity": r, "step": 0, "hp": 1, "pace": 10, "stam": 1, "reach": 1,
		"tpr": 1, "ap": 1, "dev": 0, "learn": 0, "slots": [[], [], [], [], [], []]})
	_log("fixed", "Monster %d (%s) at Qi Gathering Lower: 25 stat points. In the game its stat shape spends them; here you do." % [_caught, RARITIES[r]])


static func points_total(m: Dictionary) -> int:
	return 25 + 5 * int(m["step"])


static func points_spent(m: Dictionary) -> int:
	return MonsterDef.points_of(m["hp"], int(m["pace"]) / 10.0, m["stam"], m["reach"], m["tpr"], m["ap"])


## What one more of `stat` costs (`amount` in its unit: Pace counts in tenths), -1 at the end of its range.
static func buy_cost(m: Dictionary, stat: String, amount: int = 1) -> int:
	if int(m[stat]) + amount > int(STAT_MAX[stat]):
		return -1
	var n := m.duplicate()
	n[stat] = int(m[stat]) + amount
	return points_spent(n) - points_spent(m)


func buy(mi: int, stat: String, amount: int = 1) -> bool:
	var m: Dictionary = monsters[mi]
	var cost := buy_cost(m, stat, amount)
	if cost < 0 or points_spent(m) + cost > points_total(m):
		return false
	m[stat] = int(m[stat]) + amount
	return true


func monster_block(mi: int) -> String:
	var m: Dictionary = monsters[mi]
	var next: int = int(m["step"]) + 1
	if next > 17:
		return "the last step is reached"
	if next / 3 > RARITY_LAST[m["rarity"]]:
		return "a %s monster ends at %s" % [RARITIES[m["rarity"]], Stage.NAMES[RARITY_LAST[m["rarity"]]]]
	if next / 3 > stage():
		return "never above the tamer's stage (%s)" % Stage.NAMES[stage()]
	return ""


func advance_monster(mi: int) -> void:
	if monster_block(mi) != "" or not pending.is_empty():
		return
	var m: Dictionary = monsters[mi]
	m["step"] = int(m["step"]) + 1
	var s: int = m["step"]
	_log("fixed", "%s: %s, +5 stat points to spend freely." % [m["name"], step_name(s)])
	if s % 3 == 0:
		var steps: int = RARITY_STEPS[m["rarity"]]
		m["dev"] = int(m["dev"]) + steps
		_log("note", "%s passed its breakthrough trial (materials; a battle from Core Formation on, draft)." % m["name"])
		_log("fixed", "%s: %d development step(s) for its skill slots." % [m["name"], steps])
		if s / 3 <= 4:
			m["learn"] = int(m["learn"]) + 1
			_log("fixed", "%s: one more skill on its learnable list." % m["name"])
		elif m["rarity"] == 3:
			_log("fixed", "%s: its Signature skill (Legendary)." % m["name"])
	elif EXTRA_STEP_AT.has(s):
		m["dev"] = int(m["dev"]) + 1
		_log("fixed", "%s: 1 development step." % m["name"])


func develop(mi: int) -> void:
	var m: Dictionary = monsters[mi]
	if int(m["dev"]) <= 0 or not pending.is_empty():
		return
	var ids: Array = []
	var opts: Array = []
	for i in 6:
		var lv: int = (m["slots"][i] as Array).size() + 1
		if lv < 3:
			ids.append(i)
			opts.append({"label": "Skill slot %d: level %d → %d" % [i + 1, lv, lv + 1], "text": "The skill in this slot gains one option."})
	if ids.is_empty():
		_log("gap", "%s has a development step, but every slot is at level 3." % m["name"])
		return
	_ask("%s: which skill slot?" % m["name"], "A step develops one slot for good.", opts, _slot_picked.bind(mi, ids))


func _slot_picked(i: int, mi: int, ids: Array) -> void:
	var slot: int = ids[i]
	var opts: Array = []
	for v: String in VOCAB:
		if not (monsters[mi]["slots"][slot] as Array).has(v):
			opts.append({"label": v, "text": "The options of each skill are not defined; only the kind of option is shown."})
	_ask("Skill slot %d: which option?" % (slot + 1), "One option of the list written for the skill, each once.", opts, _option_picked.bind(mi, slot, opts), true)


func _option_picked(i: int, mi: int, slot: int, opts: Array) -> void:
	var m: Dictionary = monsters[mi]
	(m["slots"][slot] as Array).append(opts[i]["label"])
	m["dev"] = int(m["dev"]) - 1
	_log("choice", "%s, skill slot %d is now level %d: %s." % [m["name"], slot + 1, (m["slots"][slot] as Array).size() + 1, opts[i]["label"]])


# ---------------------------------------------------------------- the whole ladder

## One row per stage: stage, arc, tamer slots, what the player chooses at the breakthrough into it, what opens besides.
static func ladder_rows() -> Array:
	var rows: Array = []
	for s in 6:
		var choices := "—"
		if s > 0:
			var parts: Array[String] = ["show or stay unseen", "1 of 3 insights"]
			if TAMER_SKILLS.has(s):
				parts.append("1 of %d tamer skills" % (TAMER_SKILLS[s] as Array).size())
			parts.append("1 step for a tamer skill")
			choices = ", ".join(parts)
		rows.append([Stage.NAMES[s], ARCS[s], str(TAMER_SLOTS[s]), choices, OPENS[s]])
	return rows
