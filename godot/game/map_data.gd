class_name MapData
extends RefCounted
## A battleground as plain data, for the save and for the overworld, which never touches a MapDef itself:
## {"w", "h", "missing": [[x, y]], "grounds": {"x,y": id}, "props": {"x,y": id},
##  "zones": {"x,y": {"zone": id, "dir": [x, y], "rounds": n}}, "start_a": [[x, y]], "start_b": [[x, y]]}.


static func _key(p: Vector2i) -> String:
	return "%d,%d" % [p.x, p.y]


static func _point(key: String) -> Vector2i:
	var parts := key.split(",")
	return Vector2i(int(parts[0]), int(parts[1]))


static func _pairs(list: Array[Vector2i]) -> Array:
	var out: Array = []
	for p in list:
		out.append([p.x, p.y])
	return out


static func _points(list: Array) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for p in list:
		out.append(Vector2i(int(p[0]), int(p[1])))
	return out


static func to_dict(m: MapDef) -> Dictionary:
	var d := {"w": m.width, "h": m.height, "missing": _pairs(m.missing), "grounds": {}, "props": {}, "zones": {},
		"start_a": _pairs(m.start_a), "start_b": _pairs(m.start_b)}
	for p: Vector2i in m.grounds:
		d["grounds"][_key(p)] = String(m.grounds[p])
	for p: Vector2i in m.props:
		d["props"][_key(p)] = String(m.props[p])
	for p: Vector2i in m.zones:
		var z: Dictionary = m.zones[p]
		var dir: Vector2i = z.get("dir", Vector2i.ZERO)
		d["zones"][_key(p)] = {"zone": String(z.get("zone", &"")), "dir": [dir.x, dir.y], "rounds": int(z.get("rounds", 0))}
	return d


static func from_dict(d: Dictionary) -> MapDef:
	var m := MapDef.new()
	m.id = &"own_battleground"
	m.display_name = "Your battleground"
	if d.is_empty():
		return m
	m.width = int(d["w"])
	m.height = int(d["h"])
	m.missing = _points(d.get("missing", []))
	for k in d.get("grounds", {}):
		m.grounds[_point(String(k))] = StringName(d["grounds"][k])
	for k in d.get("props", {}):
		m.props[_point(String(k))] = StringName(d["props"][k])
	for k in d.get("zones", {}):
		var z: Dictionary = d["zones"][k]
		var dir: Array = z.get("dir", [0, 0])
		m.zones[_point(String(k))] = {"zone": StringName(z["zone"]), "dir": Vector2i(int(dir[0]), int(dir[1])), "rounds": int(z.get("rounds", 0))}
	m.start_a = _points(d.get("start_a", []))
	m.start_b = _points(d.get("start_b", []))
	return m


## One line for a list: size, what lies on it and how many monsters each side fields.
static func summary(m: MapDef, content: BattleContent) -> String:
	if m == null:
		return "no battleground"
	var counts := {}
	for p: Vector2i in m.grounds:
		var g := content.ground(m.grounds[p])
		if g != null:
			counts[g.display_name] = int(counts.get(g.display_name, 0)) + 1
	for p: Vector2i in m.props:
		var pr := content.prop(m.props[p])
		if pr != null:
			counts[pr.display_name] = int(counts.get(pr.display_name, 0)) + 1
	for p: Vector2i in m.zones:
		var z := content.zone(m.zones[p].get("zone", &""))
		if z != null:
			counts[z.display_name] = int(counts.get(z.display_name, 0)) + 1
	var parts: PackedStringArray = ["%d×%d" % [m.width, m.height]]
	for name in counts:
		parts.append("%s ×%d" % [name, counts[name]])
	parts.append("room for %d against %d" % [m.free_starts(content, 0).size(), m.free_starts(content, 1).size()])
	return " · ".join(parts)
