class_name MonsterBuilder
extends Control
## Monster builder of the battle prototype: create a monster or change an existing one — name, Kin,
## the six stats and the four kit slots — and write it as a Resource file to res://data/monsters
## (a new monster gets the content status `experiment`). The skills come from res://data/skills;
## "New skill" opens the skill builder and returns here. Nothing checks a price or a budget: stat
## and skill prices are open. Writing works when the project runs from its folder (editor or
## `godot --path`); an exported build cannot write to res://.

const SCENE := "res://game/monster_builder.tscn"
const DRAFT_SCENE := "res://battle/draft.tscn"
const SKILL_BUILDER_SCENE := "res://game/skill_builder.tscn"
## Stat fields: key, label, min, max, step (the lifetime ranges of gdd_monsters §2.1; lowest HP 3).
const STATS := [["hp", "HP", 3, 10, 1], ["initiative", "Initiative", 1, 10, 0.5], ["move", "Movement", 1, 5, 1],
	["reach", "Reach", 2, 4, 1], ["tpr", "Turns per round", 1, 3, 1], ["ap", "AP", 2, 5, 1]]
const NEW := "— new monster —"
const EMPTY := "— empty —"

## Scene to return to (the draft sandbox by default).
static var return_scene := DRAFT_SCENE
## The monster the builder shows when it opens ("" = a new one); kept across the trip to the skill builder.
static var editing := &""

var _content: BattleContent
var _pick: OptionButton
var _name: LineEdit
var _kin: OptionButton
var _spins := {}                # stat key -> SpinBox
var _slots: Array[OptionButton] = []
var _blurb: LineEdit
var _preview: RichTextLabel
var _message: Label
var _loading := false


## A monster from chosen values. `spec`: name, kin (0–5), hp, initiative, move, reach, tpr, ap,
## skills (ids, "" = empty slot), blurb. `base` is the monster being changed (its id, status,
## look and notes stay) or null for a new one.
static func build(c: BattleContent, spec: Dictionary, base: MonsterDef = null) -> MonsterDef:
	var m: MonsterDef = base if base != null else MonsterDef.new()
	var label := String(spec.get("name", "")).strip_edges()
	if label == "":
		label = "New Monster"
	m.display_name = label
	if base == null:
		m.id = StringName(label.to_snake_case().replace(" ", "_").validate_filename())
		m.content_status = ContentStatus.EXPERIMENT
		m.notes = "Built in the monster builder of the battle prototype; no price or budget was checked."
	m.kin = clampi(int(spec.get("kin", 0)), 0, MonsterDef.Kin.size() - 1) as MonsterDef.Kin
	m.hp = clampi(int(spec.get("hp", 5)), 3, 10)
	m.initiative = clampf(float(spec.get("initiative", 5.0)), 0.1, 10.0)
	m.move = clampi(int(spec.get("move", 2)), 1, 5)
	m.reach = clampi(int(spec.get("reach", 2)), 2, 4)
	m.tpr = clampi(int(spec.get("tpr", 1)), 1, 3)
	m.ap = clampi(int(spec.get("ap", 2)), 2, 5)
	m.blurb = String(spec.get("blurb", m.blurb))
	var kit: Array[BattleSkillDef] = []
	for sid in spec.get("skills", []):
		var s := c.skill(StringName(sid)) if String(sid) != "" else null
		if s != null and kit.size() < 4:
			kit.append(s)
	m.skills = kit
	return m


## Why this monster cannot be saved ("" = it can).
static func problem(c: BattleContent, m: MonsterDef, is_new: bool) -> String:
	if String(m.id) == "":
		return "the monster needs a name"
	if is_new and c.monsters.has(m.id):
		return "a monster with the id '%s' exists: pick it in the list to change it, or choose another name" % m.id
	if m.skills.is_empty():
		return "the kit needs at least one skill"
	var active := 0
	for s in m.skills:
		if s.is_active():
			active += 1
	if active == 0:
		return "the kit needs at least one active skill"
	return ""


## Writes the monster to res://data/monsters/<id>.tres and registers it: "" or the problem.
static func save(c: BattleContent, m: MonsterDef, is_new: bool) -> String:
	var why := problem(c, m, is_new)
	if why != "":
		return why
	var path := "%s/monsters/%s.tres" % [BattleContent.ROOT, m.id]
	var err := ResourceSaver.save(m, path)
	if err != OK:
		return "could not write %s (error %d)" % [path, err]
	m.take_over_path(path)
	c.monsters[m.id] = m
	GameData.register(m)
	return ""


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = UiTheme.create()
	_content = BattleContent.shared()
	var bg := ColorRect.new()
	bg.color = Color(0.075, 0.082, 0.094)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 24)
	add_child(margin)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	margin.add_child(col)

	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation", 16)
	col.add_child(bar)
	var back := Button.new()
	back.text = "Back"
	back.pressed.connect(_back)
	bar.add_child(back)
	var title := Label.new()
	title.text = "MONSTER BUILDER"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", UiTheme.ACCENT)
	bar.add_child(title)
	_pick = OptionButton.new()
	_pick.custom_minimum_size = Vector2(260, 0)
	_pick.item_selected.connect(func(_i): _load_picked())
	bar.add_child(_pick)
	var new_skill := Button.new()
	new_skill.text = "New skill (skill builder)"
	new_skill.pressed.connect(_open_skill_builder)
	bar.add_child(new_skill)

	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 32)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(body)
	var form := VBoxContainer.new()
	form.custom_minimum_size = Vector2(600, 0)
	form.add_theme_constant_override("separation", 8)
	body.add_child(form)

	_name = LineEdit.new()
	_name.text_changed.connect(func(_t): _refresh())
	form.add_child(_row("Name", _name))
	_kin = OptionButton.new()
	for k in MonsterDef.Kin.values():
		_kin.add_item("%s — Strike: %s" % [MonsterDef.kin_name(k), _kin_effect(k)])
	_kin.item_selected.connect(func(_i): _refresh())
	form.add_child(_row("Kin", _kin))
	for st: Array in STATS:
		var spin := SpinBox.new()
		spin.min_value = st[2]
		spin.max_value = st[3]
		spin.step = st[4]
		spin.value_changed.connect(func(_v): _refresh())
		_spins[st[0]] = spin
		form.add_child(_row(st[1], spin))
	for i in 4:
		var ob := OptionButton.new()
		ob.item_selected.connect(func(_i): _refresh())
		_slots.append(ob)
		form.add_child(_row("Skill slot %d" % (i + 1), ob))
	_blurb = LineEdit.new()
	_blurb.placeholder_text = "one sentence on how it plays (optional)"
	form.add_child(_row("Blurb", _blurb))

	var save_bar := HBoxContainer.new()
	save_bar.add_theme_constant_override("separation", 12)
	form.add_child(save_bar)
	var save_button := Button.new()
	save_button.text = "Save monster"
	save_button.pressed.connect(_on_save)
	save_bar.add_child(save_button)
	var play := Button.new()
	play.text = "Save and back to the team choice"
	play.pressed.connect(func():
		if _on_save():
			_back())
	save_bar.add_child(play)
	_message = Label.new()
	_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_message.add_theme_color_override("font_color", UiTheme.ACCENT)
	form.add_child(_message)

	_preview = RichTextLabel.new()
	_preview.bbcode_enabled = true
	_preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_preview.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(_preview)

	var hint := Label.new()
	hint.text = "Pick a monster in the list to change it, or build a new one. A kit has up to four skills, at least one of them active; Step is always there. Saved monsters appear in the team choice of the battle prototype and in the overview (new ones with the status experiment). Stat and skill prices are open: nothing is checked against a budget."
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_color_override("font_color", UiTheme.DIM)
	hint.add_theme_font_size_override("font_size", 14)
	col.add_child(hint)

	_fill_lists()
	_load_picked()


static func _kin_effect(k: int) -> String:
	var text := String(KinRules.strike(k).get("text", ""))
	if k == MonsterDef.Kin.ANCIENT:
		return "none (it broke Mountains)"
	return text if text != "" else "none"


func _row(label: String, field: Control) -> Control:
	var row := HBoxContainer.new()
	var l := Label.new()
	l.text = label
	l.custom_minimum_size = Vector2(170, 0)
	row.add_child(l)
	field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(field)
	return row


## Fills the monster list and the four skill lists from the content.
func _fill_lists() -> void:
	_pick.clear()
	_pick.add_item(NEW)
	_pick.set_item_metadata(0, &"")
	for id in BattleContent.sorted_ids(_content.monsters):
		var m: MonsterDef = _content.monsters[id]
		if ContentStatus.in_game(m):
			_pick.add_item(m.display_name)
			_pick.set_item_metadata(_pick.item_count - 1, id)
			if id == editing:
				_pick.select(_pick.item_count - 1)
	for ob in _slots:
		ob.clear()
		ob.add_item(EMPTY)
		ob.set_item_metadata(0, "")
		for id in BattleContent.sorted_ids(_content.skills):
			var s: BattleSkillDef = _content.skills[id]
			if ContentStatus.in_game(s):
				ob.add_item("%s  (%s)" % [s.display_name, "passive" if not s.is_active() else "%d AP" % s.cost()])
				ob.set_item_metadata(ob.item_count - 1, String(id))


func _picked_id() -> StringName:
	return _pick.get_item_metadata(maxi(0, _pick.selected))


## Puts the chosen monster (or the defaults of a new one) into the form.
func _load_picked() -> void:
	_loading = true
	editing = _picked_id()
	var m: MonsterDef = _content.monster(editing) if editing != &"" else null
	_name.text = m.display_name if m != null else "New Monster"
	_name.editable = m == null                      # the name of an existing monster is its file name
	_kin.select(m.kin if m != null else 0)
	var values := {"hp": 5, "initiative": 5.0, "move": 3, "reach": 3, "tpr": 1, "ap": 3}
	if m != null:
		values = {"hp": m.hp, "initiative": m.initiative, "move": m.move, "reach": m.reach, "tpr": m.tpr, "ap": m.ap}
	for key: String in _spins:
		(_spins[key] as SpinBox).value = values[key]
	for i in 4:
		var want := String(m.skills[i].id) if m != null and i < m.skills.size() and m.skills[i] != null else ""
		_slots[i].select(0)
		for k in _slots[i].item_count:
			if String(_slots[i].get_item_metadata(k)) == want:
				_slots[i].select(k)
	_blurb.text = m.blurb if m != null else ""
	_message.text = ""
	_loading = false
	_refresh()


## The values of the form as a spec for `build`.
func spec() -> Dictionary:
	var out := {"name": _name.text, "kin": _kin.selected, "blurb": _blurb.text, "skills": []}
	for key: String in _spins:
		out[key] = (_spins[key] as SpinBox).value
	for ob in _slots:
		out["skills"].append(String(ob.get_item_metadata(maxi(0, ob.selected))))
	return out


func _refresh() -> void:
	if _loading:
		return
	var draft := build(_content, spec())             # a throw-away copy: the stored monster changes on save only
	var lines: PackedStringArray = ["[b]%s[/b]   (%s%s)" % [draft.display_name, MonsterDef.kin_name(draft.kin),
		", new" if editing == &"" else ", id %s" % editing], ""]
	lines.append("HP %d · initiative %s · Movement %d · Reach %d · %d turn%s · AP %d" % [draft.hp, String.num(draft.initiative, 1), draft.move,
		draft.reach, draft.tpr, "" if draft.tpr == 1 else "s (from round 2)", draft.ap])
	lines.append("[color=#8a93a3]Strike effect of the Kin:[/color] %s" % _kin_effect(draft.kin))
	lines.append("")
	lines.append("[color=#8a93a3]Step[/color]   1 AP · 1 square")
	for s in draft.skills:
		lines.append("")
		lines.append("[b]%s[/b]   %s" % [s.display_name, "passive" if not s.is_active() else "%d AP" % s.cost()])
		for r in BattleText.skill_rows(_content, s, draft.kin):
			lines.append("  %s" % String(r[1]))
		if s.is_active() and s.cost() > draft.ap:
			lines.append("  [color=#d9a04a]costs more AP than the monster has[/color]")
	var why := problem(_content, draft, editing == &"")
	if why != "":
		lines.append("")
		lines.append("[color=#d9a04a]%s[/color]" % why)
	_preview.text = "\n".join(lines)


func _on_save() -> bool:
	var is_new := editing == &""
	var m := build(_content, spec(), null if is_new else _content.monster(editing))
	var why := save(_content, m, is_new)
	if why != "":
		_message.text = why
		return false
	editing = m.id
	_fill_lists()
	_name.editable = false
	_message.text = "Saved res://data/monsters/%s.tres%s." % [m.id, " (status experiment)" if is_new else ""]
	_refresh()
	return true


func _open_skill_builder() -> void:
	SkillBuilder.return_scene = SCENE
	get_tree().change_scene_to_file(SKILL_BUILDER_SCENE)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_back()


func _back() -> void:
	var to := return_scene
	return_scene = DRAFT_SCENE
	editing = &""
	get_tree().change_scene_to_file(to)
