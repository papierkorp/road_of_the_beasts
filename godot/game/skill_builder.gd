class_name SkillBuilder
extends Control
## Skill builder: puts a skill together from the parts of the skill card (gdd_skills §2: cost, place,
## Strike, movement, effect on its user, and the ground, zone and prop it creates; SkillGen.build),
## shows the card and the card text of the battle, and writes it as a Resource file to res://data/skills (content status
## `experiment`). A saved skill can be put into a kit slot of a monster (writes the monster file).
## It checks no price: prices are open. Writing works when the project runs from its folder
## (editor or `godot --path`); an exported build cannot write to res://.

const OVERVIEW_SCENE := "res://game/overview.tscn"
const USES := [["repeatable", "any number"], ["once_per_round", "once per round"], ["once_per_battle", "once per battle"]]
## Fields in the order of the form: key, label.
const FIELDS := [["ap", "Cost"], ["use", "Use"], ["strike", "Strike (now, neighbour)"], ["damage", "Strike damage"],
	["path", "Movement of its user"], ["impact", "On landing"], ["self", "On itself"], ["shape", "Shape of the place"],
	["ground", "Creates ground"], ["zone", "Creates zone"], ["prop", "Creates prop"]]

## Scene to return to (the overview by default; the monster builder sets itself here).
static var return_scene := OVERVIEW_SCENE

var _content: BattleContent
var _name: LineEdit
var _fields := {}               # key -> OptionButton
var _rows := {}                 # key -> the row Control (hidden when the kind does not use it)
var _preview: RichTextLabel
var _message: Label
var _monster: OptionButton
var _slot: OptionButton
var _built: BattleSkillDef
var _rng := RandomNumberGenerator.new()
var _random_count := 0


## Choices of one field as [[value, label], ...]; "" = no.
static func choices(c: BattleContent, key: String) -> Array:
	match key:
		"ap":
			return [["1", "1 AP"], ["2", "2 AP"], ["3", "3 AP"], ["4", "4 AP"]]
		"use":
			return USES
		"strike":
			return [["", "no"], ["jab", "Jab: 1 square"], ["thrust", "Thrust: 2 in a line"], ["arc", "Arc: 3 in front"]]
		"damage":
			return [["2", "2 damage, push 1"], ["1", "1 damage, push 1"], ["0", "push 1 only"]]
		"path":
			return [["", "no"], ["walk", "walks (blocked by props and monsters)"], ["line", "straight line over everything"], ["free", "any path over everything"]]
		"impact":
			return [["none", "nothing"], ["ahead", "pushes the monster ahead"], ["ring", "pushes all neighbours"]]
		"self":
			return [["", "no"], ["quicken", "initiative +1 for 2 rounds"], ["haste", "Movement +1 for 2 rounds"], ["extend", "Reach +1 for 2 rounds"],
				["vigor", "AP +1 for 2 rounds (experiment)"], ["tempo", "one more turn (experiment)"], ["immovable", "passive: ignores push and pull"]]
		"shape":
			return [["one", "1 square"], ["line2", "line of 2"], ["line3", "line of 3"], ["block", "block 2×2"], ["angle", "angle (3)"], ["cross", "cross (5)"]]
		"ground":
			var out: Array = [["", "no"]]
			for id in BattleContent.sorted_ids(c.grounds):
				var g: GroundDef = c.grounds[id]
				if ContentStatus.in_game(g) and not g.immutable and id != GroundDef.PLAIN:
					out.append([String(id), "%s: %s" % [g.display_name, BattleText.ground_brief(g)]])
			return out
		"zone":
			var zones: Array = [["", "no"]]
			for id in BattleContent.sorted_ids(c.zones):
				var z: BattleZoneDef = c.zones[id]
				if ContentStatus.in_game(z):
					zones.append([String(id), "%s: %s" % [z.display_name, BattleText.effects_text(z.effects)]])
			return zones
		"prop":
			var props: Array = [["", "no"]]
			for id in BattleContent.sorted_ids(c.props):
				var d: PropDef = c.props[id]
				if ContentStatus.in_game(d) and d.creatable_by_skill:
					props.append([String(id), d.display_name])
			return props
	return []


## Which fields count for the chosen parts (the others are hidden): a Strike or a movement takes no
## shape and no prop, an effect on the user nothing else.
static func fields_of(spec: Dictionary) -> Array:
	if String(spec.get("strike", "")) != "":
		return ["ap", "use", "strike", "damage", "ground", "zone"]
	if String(spec.get("path", "")) != "":
		return ["ap", "use", "strike", "path", "impact", "ground", "zone"]
	if String(spec.get("self", "")) == "immovable":
		return ["strike", "path", "self"]
	if String(spec.get("self", "")) != "":
		return ["ap", "use", "strike", "path", "self"]
	return ["ap", "use", "strike", "path", "self", "shape", "ground", "zone", "prop"]


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = UiTheme.create()
	_content = BattleContent.shared()
	_rng.randomize()
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
	title.text = "SKILL BUILDER"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", UiTheme.ACCENT)
	bar.add_child(title)
	var random := Button.new()
	random.text = "Random skill"
	random.pressed.connect(_on_random)
	bar.add_child(random)

	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 32)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(body)
	var form := VBoxContainer.new()
	form.custom_minimum_size = Vector2(560, 0)
	form.add_theme_constant_override("separation", 8)
	body.add_child(form)

	_name = LineEdit.new()
	_name.text = "New Skill"
	_name.text_changed.connect(func(_t): _rebuild())
	form.add_child(_row("Name", _name, "name"))
	for field: Array in FIELDS:
		var key: String = field[0]
		var ob := OptionButton.new()
		for ch: Array in choices(_content, key):
			ob.add_item(ch[1])
			ob.set_item_metadata(ob.item_count - 1, ch[0])
		ob.item_selected.connect(func(_i): _rebuild())
		_fields[key] = ob
		form.add_child(_row(field[1], ob, key))

	var save_bar := HBoxContainer.new()
	save_bar.add_theme_constant_override("separation", 12)
	form.add_child(save_bar)
	var save := Button.new()
	save.text = "Save skill"
	save.pressed.connect(_on_save)
	save_bar.add_child(save)
	_monster = OptionButton.new()
	for id in _content.game_monster_ids():
		_monster.add_item(_content.monster(id).display_name)
		_monster.set_item_metadata(_monster.item_count - 1, id)
	save_bar.add_child(_monster)
	_slot = OptionButton.new()
	for i in 4:
		_slot.add_item("slot %d" % (i + 1))
	save_bar.add_child(_slot)
	var give := Button.new()
	give.text = "Save and put into this kit slot"
	give.pressed.connect(_on_assign)
	save_bar.add_child(give)
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
	hint.text = "A skill only delivers: it may strike a neighbour, move its user or act on its user, and it creates ground, a zone or a prop. What those do and when is defined once, in the ground, zone and prop files (Overview). There are no Surges and no traps: damage at range comes from ground. Saved skills get the status experiment; prices are not checked."
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_color_override("font_color", UiTheme.DIM)
	hint.add_theme_font_size_override("font_size", 14)
	col.add_child(hint)
	_rebuild()


func _row(label: String, field: Control, key: String) -> Control:
	var row := HBoxContainer.new()
	var l := Label.new()
	l.text = label
	l.custom_minimum_size = Vector2(200, 0)
	row.add_child(l)
	field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(field)
	_rows[key] = row
	return row


func _value(key: String) -> String:
	var ob: OptionButton = _fields[key]
	return String(ob.get_item_metadata(maxi(0, ob.selected)))


## The chosen parts as a spec for SkillGen.build.
func spec() -> Dictionary:
	var out := {"name": _name.text}
	for key: String in _fields:
		out[key] = _value(key)
	return out


func _rebuild() -> void:
	var used := fields_of(spec())
	for key: String in _fields:
		_rows[key].visible = used.has(key)
	_built = SkillGen.build(_content, spec())
	_show(_built)


func _show(s: BattleSkillDef) -> void:
	var parts := SkillGen.card(_content, s)
	var lines: PackedStringArray = ["[b]%s[/b]   (id %s)" % [s.display_name, s.id], ""]
	for row: Array in [["cost", "Cost"], ["where", "Where"], ["strike", "Strike"], ["move", "Movement"], ["self", "On itself"],
			["ground", "Creates ground"], ["zone", "Creates zone"], ["prop", "Creates prop"]]:
		lines.append("[color=#8a93a3]%s[/color]   %s" % [row[1], parts[row[0]]])
	for op in s.board_ops:                        # what the created things do stands in their own definitions
		if op.op == BoardOp.GROUND and _content.ground(op.ground) != null:
			lines.append("")
			lines.append("[color=#8a93a3]Ground %s[/color]   %s" % [_content.ground(op.ground).display_name, _content.ground(op.ground).description])
		elif op.op == BoardOp.CREATE_ZONE and _content.zone(op.zone) != null:
			lines.append("")
			lines.append("[color=#8a93a3]Zone %s[/color]   %s" % [_content.zone(op.zone).display_name, BattleText.effects_text(_content.zone(op.zone).effects)])
	if s.zone != null:
		lines.append("")
		lines.append("[color=#8a93a3]Zone %s[/color]   %s" % [s.zone.display_name, BattleText.effects_text(s.zone.effects)])
	lines.append("")
	lines.append("[color=#8a93a3]Card text in battle[/color]")
	for r in BattleText.skill_rows(_content, s):
		lines.append("  %s" % String(r[1]))
	if _content.skills.has(s.id) and _content.skills[s.id] != s:
		lines.append("")
		lines.append("[color=#d9a04a]A skill with this id exists: saving replaces its file.[/color]")
	_preview.text = "\n".join(lines)


func _on_random() -> void:
	_random_count += 1
	_built = SkillGen.draw_named(_content, _rng, _rng.randi_range(0, 3))
	_built.display_name = "Random %d" % _random_count
	_built.id = StringName("random_%d_%d" % [_random_count, _rng.randi_range(100, 999)])
	_built.status = "drawn in the skill builder (gdd_skills §2 sentence); experiment, not priced"
	_message.text = "Random skill drawn; it is saved as drawn (the fields on the left do not show it)."
	_show(_built)


func _on_save() -> void:
	var problem := SkillGen.save(_content, _built)
	_message.text = problem if problem != "" else "Saved res://data/skills/%s.tres (status experiment)." % _built.id


func _on_assign() -> void:
	var problem := SkillGen.save(_content, _built)
	if problem == "":
		var monster: StringName = _monster.get_item_metadata(maxi(0, _monster.selected))
		problem = SkillGen.assign(_content, _built, monster, maxi(0, _slot.selected))
		if problem == "":
			problem = "Saved, and %s now holds %s in slot %d." % [_content.monster(monster).display_name, _built.display_name, _slot.selected + 1]
	_message.text = problem


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_back()


func _back() -> void:
	var to := return_scene
	return_scene = OVERVIEW_SCENE
	get_tree().change_scene_to_file(to)
