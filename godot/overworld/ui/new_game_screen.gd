class_name NewGameScreen
extends Control
## The start of a game (docs/vision.md §5): the player chooses a Way, a gift of that Way and one of three eggs.

const HUB_SCENE := "res://overworld/hub.tscn"
const MENU_SCENE := "res://game/menu.tscn"

var _system: StringName = &""
var _egg: StringName = &""
var _gift := ""
## The seed of the game to come; the three eggs are drawn from it.
var _seed := 0
var _body: VBoxContainer


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	_seed = rng.randi_range(1, 1 << 30)
	var margin := HubUi.page(self)
	_body = HubUi.col(14)
	margin.add_child(_body)
	_build()


func _build() -> void:
	for c in _body.get_children():
		_body.remove_child(c)
		c.queue_free()
	_body.add_child(HubUi.title("A new game"))
	_body.add_child(HubUi.label("You are an orphan. Choose the way you cultivate, a gift of that way, and one of the three eggs of the nest you found."))
	var list := HubUi.scroll(_body)
	list.add_child(HubUi.label("Your Way", 22, UiTheme.ACCENT))
	var systems := HubUi.row()
	list.add_child(systems)
	for id in CultivationDef.ids():
		var def := CultivationDef.of(id)
		var lines: PackedStringArray = []
		for br: Dictionary in def.branches:
			var names: PackedStringArray = []
			for n: Dictionary in def.nodes:
				if String(n.get("branch", "")) == String(br["id"]):
					names.append(String(n["name"]))
			lines.append("%s: %s" % [br["name"], ", ".join(names)])
		var way := _choice("%s\n%s\n\n%s" % [def.display_name, def.blurb, "\n".join(lines)], _system == id, func():
			_system = id
			_gift = ""
			_build())
		way.icon = UiTheme.icon(String(id))
		systems.add_child(way)
	if _system != &"":
		list.add_child(HubUi.label("A gift for the start — choose one; drawn anew for every game", 22, UiTheme.ACCENT))
		var gifts := HubUi.row()
		list.add_child(gifts)
		for o in GameState.start_offer(GameValues.shared(), _seed, _system):
			var gift_id := String(o["id"])
			var gift := _choice("%s\n%s" % [o["name"], o["text"]], _gift == gift_id, func():
				_gift = gift_id
				_build())
			gift.custom_minimum_size = Vector2(380, 120)
			gifts.add_child(gift)
	list.add_child(HubUi.label("The nest — three eggs, drawn anew for every game; every game you finish adds species to draw from", 22, UiTheme.ACCENT))
	var eggs := HubUi.row()
	list.add_child(eggs)
	for id in GameState.egg_offer(GameValues.shared(), _seed, GameSession.finished_games()):
		var def := GameData.monster(id)
		if def == null:
			continue
		var kin := KinDef.of(def.kin)
		var groups := "Learns: %s\nNever learns: %s\n%s" % [" · ".join(kin.learns), " · ".join(kin.never_learns()), kin.trait_line()] if kin != null else ""
		var egg := _choice("%s (%s)\n%s\n\n%s" % [def.display_name, MonsterDef.kin_name(def.kin), def.blurb, groups], _egg == id, func():
			_egg = id
			_build())
		egg.icon = UiTheme.icon("part_%d" % def.kin)
		eggs.add_child(egg)
	var bottom := HubUi.row()
	_body.add_child(bottom)
	bottom.add_child(HubUi.button("Back", func(): get_tree().change_scene_to_file(MENU_SCENE), 160))
	var go := HubUi.primary("Begin", _begin, 260)
	go.disabled = _system == &"" or _egg == &"" or _gift == ""
	bottom.add_child(go)


func _choice(text: String, picked: bool, action: Callable) -> Button:
	var b := Button.new()
	b.toggle_mode = true
	b.button_pressed = picked
	b.text = text
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
	b.custom_minimum_size = Vector2(380, 270)
	b.add_theme_constant_override("icon_max_width", 64)
	b.add_theme_constant_override("h_separation", 16)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.pressed.connect(action)
	return b


func _begin() -> void:
	GameSession.game = GameState.new_game(_seed, _system, _egg, null, _gift)
	GameSession.fight = null
	GameSession.hub_panel = &"monsters"
	GameSession.hub_tabs = {&"monsters": &"stats"}
	SaveGame.save(GameSession.game)
	get_tree().change_scene_to_file(HUB_SCENE)
