class_name CityAreas
extends RefCounted
## The areas of the city (docs/overworld.md §3) as layouts for DistrictMap: the hub, one district per group and the
## wild areas. A TEST LAYOUT: the hub puts every district next to the others as a teleporter so that each can be
## tried on its own; it is not the geography of the city. No persons yet, only the world and its buildings.
## A building either does something that is built (a panel, a faction) or shows what it is meant for (an info text).

const HUB := &"city"
const HUB_SIZE := Vector2(64, 46)
const ROOM_SIZE := Vector2(40, 30)
const WILD_SIZE := Vector2(44, 33)

## The building slots of a district: centre, footprint, height. The first is the main hall.
const SLOTS := [
	[Vector2(20, 5), Vector2(14, 6), 10.0],
	[Vector2(5.5, 15.5), Vector2(7, 9), 7.0],
	[Vector2(34.5, 15.5), Vector2(7, 9), 7.0],
	[Vector2(6, 5), Vector2(7, 6), 6.0],
	[Vector2(34, 5), Vector2(7, 6), 6.0],
]

## Per district: title, group, ground and wall colour, where it stands in the hub (centre, the side its door faces)
## and its buildings: [key, name, action ("" = an info text), what it is for].
const DISTRICTS := {
	&"family": {"title": "Family Compound", "group": "The player's family", "ground": Color(0.30, 0.24, 0.24), "wall": Color(0.62, 0.30, 0.26),
		"hub": Vector2(21, 6), "front": Vector2(0, 1), "buildings": [
			["hall", "Family Hall", "faction:family", ""],
			["yard", "Training Yard", "", "Train a monster here for 1 day AP. Not built."],
			["pens", "Beast Pens", "", "The monsters of the family. Bloodlines and gifts of the elders come from here. Not built."],
			["shrine", "Ancestral Shrine", "", "The trial of the breakthrough to Core Formation is fought here, against the guardians of the shrine (draft)."],
			["side_house", "Your Side House", "", "Where the least regarded member of the family lives."],
		]},
	&"rival_a": {"title": "Rival Compound of the First Family", "group": "A rival family", "ground": Color(0.24, 0.27, 0.31), "wall": Color(0.30, 0.42, 0.62),
		"hub": Vector2(8, 6), "front": Vector2(0, 1), "buildings": [
			["hall", "Family Hall", "", "Requests of this family, most of them against the other two. Entry by invitation or Standing. Not built."],
			["yard", "Training Yard", "", "Their young cultivators train here. Not built."],
			["treasure", "Treasure Pavilion", "", "What this family guards. A player with more weight than the family is let in; a player with less fights, pays or sends their people (draft)."],
		]},
	&"rival_b": {"title": "Rival Compound of the Second Family", "group": "A rival family", "ground": Color(0.25, 0.29, 0.24), "wall": Color(0.36, 0.55, 0.34),
		"hub": Vector2(56, 6), "front": Vector2(0, 1), "buildings": [
			["hall", "Family Hall", "", "Requests of this family, most of them against the other two. Entry by invitation or Standing. Not built."],
			["yard", "Training Yard", "", "Their young cultivators train here. Not built."],
			["treasure", "Treasure Pavilion", "", "What this family guards. A player with more weight than the family is let in; a player with less fights, pays or sends their people (draft)."],
		]},
	&"lord": {"title": "City Lord's Mansion", "group": "City Lord with the City Guard", "ground": Color(0.30, 0.29, 0.31), "wall": Color(0.55, 0.52, 0.60),
		"hub": Vector2(33, 6), "front": Vector2(0, 1), "buildings": [
			["audience", "Audience Hall", "", "The City Lord grants permits and decides who may pass the Realm Gate. Not built."],
			["barracks", "Guard Barracks", "faction:watch", ""],
			["notice", "Notice Wall", "panel:clan", ""],
			["prison", "Prison Tower", "", "Who breaks the law of the city ends here. Not built."],
		]},
	&"guild": {"title": "Guild Quarter", "group": "Merchant Guild", "ground": Color(0.34, 0.29, 0.22), "wall": Color(0.78, 0.60, 0.28),
		"hub": Vector2(33, 40), "front": Vector2(0, -1), "buildings": [
			["hall", "Guild Hall", "faction:guild", ""],
			["traders", "Trader's Row", "panel:market", ""],
			["warehouse", "Warehouse", "", "The guild buys and sells and makes nothing. Bulk trade and licences are dealt here. Not built."],
		]},
	&"auction": {"title": "Auction Hall", "group": "Auction Hall", "ground": Color(0.27, 0.22, 0.30), "wall": Color(0.60, 0.36, 0.66),
		"hub": Vector2(45, 40), "front": Vector2(0, -1), "buildings": [
			["bidding", "Bidding Hall", "", "Young monsters, eggs, rare goods and tokens for a one-time realm go to the highest bid. Neutral: it serves every group. Not built."],
			["consign", "Consignment Counter", "", "Hand in a piece to be sold at the next auction. Not built."],
			["boxes", "Private Boxes", "", "Who bids from a box stays unseen. Not built."],
		]},
	&"alchemy": {"title": "Alchemy Hall", "group": "Alchemy Hall", "ground": Color(0.22, 0.29, 0.27), "wall": Color(0.30, 0.62, 0.52),
		"hub": Vector2(8, 40), "front": Vector2(0, -1), "buildings": [
			["trial", "Trial Chamber", "", "The hall grants five ranks: hand in the pill it asks for at the grade it asks for (1 day AP). A rank counts toward your weight. Not built."],
			["herbs", "Herb Store", "", "Plants by rank. Not built."],
			["cauldrons", "Public Cauldrons", "", "Combine two or three plants that share a property into a pill. Not built; your own cauldron stands in the Internal World."],
		]},
	&"smiths": {"title": "Smiths' Hall", "group": "Smiths' Hall", "ground": Color(0.28, 0.25, 0.23), "wall": Color(0.66, 0.42, 0.26),
		"hub": Vector2(21, 40), "front": Vector2(0, -1), "buildings": [
			["trial", "Trial Forge", "", "The hall grants five ranks: hand in the weapon or armour it asks for (1 day AP). A rank counts toward your weight. Not built."],
			["ore", "Ore Yard", "", "Ore by rank. Not built."],
			["armoury", "Armoury", "", "A weapon gives the tamer a skill for a tamer slot; armour gives a monster one more passive. Not built."],
		]},
	&"school": {"title": "The School", "group": "The school", "ground": Color(0.27, 0.30, 0.26), "wall": Color(0.50, 0.60, 0.72),
		"hub": Vector2(45, 6), "front": Vector2(0, 1), "buildings": [
			["great_hall", "Great Hall", "", "The first arc plays here; at its end the best of the year is crowned. Show yourself or stay unseen. Not built."],
			["library", "Library", "", "Scrolls: tamer skills and upgrade scrolls. Not built."],
			["arena", "Arena", "", "The trial of the breakthrough to Foundation: the final examination, a duel (draft). Not built."],
			["dorms", "Dormitories", "", "The houses of the school and their rivalries. Not built."],
			["mountain_gate", "Mountain Gate", "goto:mountain", "Go up the school's mountain"],
		]},
	&"underground": {"title": "The Underground", "group": "Underground", "ground": Color(0.15, 0.14, 0.17), "wall": Color(0.34, 0.30, 0.38),
		"hub": Vector2(56, 40), "front": Vector2(0, -1), "dark": true, "buildings": [
			["black_market", "Black Market", "", "Goods the other groups do not sell, and no questions. Not built."],
			["slave_market", "Slave Market", "", "Monsters and subordinates for spirit stones; every sheet is visible. Not built."],
			["den", "Den", "", "Hush money for a hidden house is paid here. Opposed to the City Lord. Not built."],
		]},
}

## Per wild area: title, ground, where it stands in the hub, its extra gate and its zones from the entrance inward:
## [name, stage, colour].
const WILDS := {
	&"mountain": {"title": "The School's Mountain", "ground": Color(0.25, 0.27, 0.24), "hub": Vector2(60, 17), "front": Vector2(-1, 0),
		"wall": Color(0.45, 0.50, 0.45), "gate": &"school", "rock": Color(0.42, 0.42, 0.44), "zones": [
			["Foothill", 0, Color(0.30, 0.38, 0.26)], ["Slope", 1, Color(0.36, 0.36, 0.30)], ["Peak", 2, Color(0.50, 0.52, 0.56)]]},
	&"forest": {"title": "The Wild Forest", "ground": Color(0.16, 0.24, 0.17), "hub": Vector2(60, 29), "front": Vector2(-1, 0),
		"wall": Color(0.22, 0.42, 0.26), "gate": &"", "rock": Color(0.18, 0.36, 0.20), "zones": [
			["Edge", 1, Color(0.22, 0.34, 0.20)], ["Deep Wood", 3, Color(0.14, 0.26, 0.17)], ["Heart", 4, Color(0.20, 0.20, 0.30)]]},
}
## Nights until a taken resource is back (docs/overworld.md §3.3).
const NIGHTS_NORMAL := 1
const NIGHTS_RARE := 3


static func ids() -> Array[StringName]:
	var out: Array[StringName] = [HUB]
	for id: StringName in DISTRICTS:
		out.append(id)
	for id: StringName in WILDS:
		out.append(id)
	return out


static func has(id: StringName) -> bool:
	return id == HUB or DISTRICTS.has(id) or WILDS.has(id)


static func build(id: StringName) -> DistrictMap:
	if DISTRICTS.has(id):
		return _district(id)
	if WILDS.has(id):
		return _wild(id)
	return _hub()


## What a building is for: {name, group, text}, or empty for an unknown key ("<district>.<building>").
static func info(key: StringName) -> Dictionary:
	var parts := String(key).split(".")
	if parts.size() != 2 or not DISTRICTS.has(StringName(parts[0])):
		return {}
	var d: Dictionary = DISTRICTS[StringName(parts[0])]
	for b: Array in d["buildings"]:
		if b[0] == parts[1]:
			return {"name": b[1], "group": d["group"], "text": b[3]}
	return {}


static func _hub() -> DistrictMap:
	var m := DistrictMap.new()
	m.id = HUB
	m.title = "The City (test hub)"
	m.size = HUB_SIZE
	m.ground = Color(0.30, 0.29, 0.31)
	m.arrivals = {&"start": Vector2(32, 27), &"dungeon": Vector2(32, 24.6), &"inner": Vector2(6.2, 23)}
	for id: StringName in DISTRICTS:
		var d: Dictionary = DISTRICTS[id]
		_door(m, id, d["title"], d["hub"], Vector2(9, 6), 9.0, d["wall"], d["front"])
	for id: StringName in WILDS:
		var w: Dictionary = WILDS[id]
		_door(m, id, w["title"], w["hub"], Vector2(5, 8), 12.0, w["wall"], w["front"])
	m._add("pavilion", "Meditation Pavilion", Vector2(3.5, 23), Vector2(4, 5), 5.0, Color(0.35, 0.6, 0.5), &"goto:inner", "Enter your Internal World")
	m._add("realm_gate", "Realm Gate", Vector2(32, 21), Vector2(7, 4), 1.2, Color(0.45, 0.35, 0.7), &"panel:plaza", "Use the Realm Gate")
	for x: float in [24.0, 40.0]:
		for y: float in [16.0, 30.0]:
			m._add("pillar_%d_%d" % [int(x), int(y)], "", Vector2(x, y), Vector2(1.2, 1.2), 7.0, Color(0.5, 0.5, 0.52))
	return m


## A building of the hub that leads into an area; the player arrives in front of it when they come back.
static func _door(m: DistrictMap, id: StringName, title: String, pos: Vector2, size: Vector2, height: float, color: Color, front: Vector2) -> void:
	m._add(String(id), title, pos, size, height, color, StringName("goto:%s" % id), "Enter: %s" % title)
	m.arrivals[id] = pos + front * (absf(front.x) * size.x / 2.0 + absf(front.y) * size.y / 2.0 + 1.6)


static func _district(id: StringName) -> DistrictMap:
	var d: Dictionary = DISTRICTS[id]
	var m := DistrictMap.new()
	m.id = id
	m.title = d["title"]
	m.size = ROOM_SIZE
	m.ground = d["ground"]
	m.sky = not d.get("dark", false)
	m.arrivals = {&"start": Vector2(20, 26), HUB: Vector2(20, 26)}
	var wall: Color = d["wall"]
	var buildings: Array = d["buildings"]
	for i in buildings.size():
		var b: Array = buildings[i]
		var slot: Array = SLOTS[i]
		var action := StringName(b[2]) if b[2] != "" else StringName("info:%s.%s" % [id, b[0]])
		var label: String = b[3] if String(b[2]).begins_with("goto:") else "Enter the %s" % b[1]
		m._add(b[0], b[1], slot[0], slot[1], slot[2], wall.lerp(Color.WHITE, 0.12 * (i % 3)), action, label)
		if String(b[2]).begins_with("goto:"):
			var target := StringName(String(b[2]).trim_prefix("goto:"))
			m.arrivals[target] = Vector2(slot[0].x, slot[0].y + slot[1].y / 2.0 + 1.6)
	m._add("gate", "City Gate", Vector2(20, 29.2), Vector2(6, 1.6), 1.4, Color(0.35, 0.55, 0.75), &"goto:city", "Back to the city")
	for x: float in [15.0, 25.0]:
		m._add("gate_pillar_%d" % int(x), "", Vector2(x, 27.5), Vector2(1.0, 1.0), 6.0, wall.darkened(0.3))
	for x: float in [13.0, 27.0]:
		m._add("lantern_%d" % int(x), "", Vector2(x, 13.0), Vector2(0.7, 0.7), 2.4, Color(0.85, 0.7, 0.4))
	return m


## A wild area: three zones in bands from the entrance (south) inward, each with its stage, its resources and its
## rocks or trees, which grow with the zone. The layout is always the same.
static func _wild(id: StringName) -> DistrictMap:
	var w: Dictionary = WILDS[id]
	var m := DistrictMap.new()
	m.id = id
	m.title = w["title"]
	m.size = WILD_SIZE
	m.ground = w["ground"]
	m.arrivals = {&"start": Vector2(10, 29.6), HUB: Vector2(10, 29.6)}
	m._add("gate", "City Gate", Vector2(10, 32.2), Vector2(4, 1.6), 1.4, Color(0.35, 0.55, 0.75), &"goto:city", "Back to the city")
	if w["gate"] != &"":
		m._add("gate_b", "Gate", Vector2(35, 32.2), Vector2(4, 1.6), 1.4, Color(0.50, 0.60, 0.72), StringName("goto:%s" % w["gate"]), "Back to: %s" % DISTRICTS[w["gate"]]["title"])
		m.arrivals[w["gate"]] = Vector2(35, 29.6)
	var rng := RandomNumberGenerator.new()
	rng.seed = String(id).length() * 7919
	var band := WILD_SIZE.y / 3.0
	for z in 3:
		var zone: Array = w["zones"][z]
		var rect := Rect2(0.0, WILD_SIZE.y - band * (z + 1), WILD_SIZE.x, band)
		var stage: int = zone[1]
		m.zones.append({"name": zone[0], "stage": stage, "rect": rect})
		m._patch("zone_%d" % z, "%s — %s" % [zone[0], Stage.NAMES[stage]], rect.grow(-0.4), zone[2])
		for i in 5:
			var s := rng.randf_range(1.2, 2.2) + z * 0.6
			var at := Vector2(6.5 + i * 8.0 + rng.randf_range(-1.0, 1.0), rect.position.y + (2.4 if i % 2 == 0 else band - 2.4) + rng.randf_range(-0.6, 0.6))
			m._add("rock_%d_%d" % [z, i], "", at, Vector2(s, s), rng.randf_range(2.0, 4.0) + z * 4.0, (w["rock"] as Color).lerp(Color.WHITE, rng.randf_range(0.0, 0.15)))
		var items := ItemCatalog.materials_of_tier(stage)
		for i in 4:
			var rare := i == 3
			var item: String = items[(z * 7 + i * 5 + String(id).length()) % items.size()]
			var nights := NIGHTS_RARE if rare else NIGHTS_NORMAL
			var at := Vector2(9.0 + i * 8.5, rect.position.y + band / 2.0 + (1.2 if i % 2 == 0 else -1.2))
			var key := "%s/%d/%d" % [id, z, i]
			m._add(key, ("Rare " if rare else "") + ItemCatalog.display_name(item), at, Vector2(0.9, 0.9), 0.9,
				Color(0.85, 0.55, 0.85) if rare else Color(0.55, 0.85, 0.55), StringName("take:%s" % key),
				"Take %s  (1 day AP, back after %d night%s)" % [ItemCatalog.display_name(item), nights, "" if nights == 1 else "s"])
			m.things[-1]["node"] = {"item": item, "nights": nights, "stage": stage}
	return m
