class_name HubTabs
extends HubPanel
## A building with several parts: a row of tabs and the part that is open. The open tab is kept in GameSession, so
## it survives a refresh and a battle.


## The parts: [[id, title, script of the panel], …].
func tabs() -> Array:
	return []


func tab() -> StringName:
	var all := tabs()
	var want: StringName = GameSession.hub_tabs.get(id, &"")
	for t: Array in all:
		if t[0] == want:
			return want
	return all[0][0]


func build(into: VBoxContainer) -> void:
	var now := tab()
	var row := HubUi.row()
	into.add_child(row)
	var open: HubPanel = null
	for t: Array in tabs():
		var tab_id: StringName = t[0]
		var b := HubUi.button(t[1], hub.open.bind(id, tab_id), 230)
		b.toggle_mode = true
		b.button_pressed = tab_id == now
		b.disabled = tab_locked(tab_id)
		row.add_child(b)
		if tab_id == now:
			open = t[2].new()
	open.hub = hub
	open.game = game
	open.id = id
	open.build(into)


func tab_locked(_tab_id: StringName) -> bool:
	return false
