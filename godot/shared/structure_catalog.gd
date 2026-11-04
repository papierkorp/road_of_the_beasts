class_name StructureCatalog
extends RefCounted
## The structures of the first building step (gdd_overworld §6.4): two cultivation spots, a herb
## plot, a pond (water) and one altar per aspect. Prices and numbers are prototype values.
## Defined in code for now; they become data files when the set grows.

static var _defs := {}


static func _ensure() -> void:
	if not _defs.is_empty():
		return
	var F := Aspect.Type.FORCE
	var N := Aspect.Type.NATURE
	var D := Aspect.Type.DARK
	var ANY := Aspect.Type.NONE
	_add(&"meditation_stone", "Meditation Stone", StructureDef.Category.CULTIVATION, Vector2i(1, 1), ANY,
		Color(0.55, 0.62, 0.75), 1.1, "An assigned monster meditates here and gains XP every night.",
		[{"aspect": ANY, "count": 3}], 120, 10, false)
	_add(&"qi_spring", "Qi Spring", StructureDef.Category.CULTIVATION, Vector2i(1, 1), N,
		Color(0.35, 0.65, 0.8), 0.7, "A spring of pure qi: stronger than a stone. It also counts as water.",
		[{"aspect": N, "count": 4}, {"aspect": ANY, "count": 2}], 300, 20, true)
	_add(&"herb_plot", "Herb Plot", StructureDef.Category.GROWING, Vector2i(1, 1), N,
		Color(0.3, 0.55, 0.3), 0.35, "Plant a material, harvest three of it after a few nights. Water nearby speeds it up.",
		[{"aspect": N, "count": 2}], 100, 0, false)
	_add(&"spirit_pond", "Spirit Pond", StructureDef.Category.SPECIAL, Vector2i(2, 1), N,
		Color(0.25, 0.5, 0.75), 0.25, "Still water. Herb plots next to it grow a night faster.",
		[{"aspect": N, "count": 3}], 150, 0, true)
	_add(&"refining_furnace", "Refining Furnace", StructureDef.Category.PRODUCTION, Vector2i(1, 1), F,
		Color(0.8, 0.4, 0.2), 1.5, "Turns materials into pills — every night on its standing order, or at once when you work it. A Qi Spring next to it makes finer batches.",
		[{"aspect": F, "count": 4}, {"aspect": ANY, "count": 2}], 350, 0, false)
	_add(&"pill_stall", "Pill Stall", StructureDef.Category.PRODUCTION, Vector2i(1, 1), ANY,
		Color(0.6, 0.45, 0.3), 1.0, "Pills on its shelf are sold to customers every night. Water next to it brings one more customer.",
		[{"aspect": ANY, "count": 6}], 250, 0, false)
	_add(&"evolution_pillar", "Evolution Pillar", StructureDef.Category.SPECIAL, Vector2i(1, 1), ANY,
		Color(0.85, 0.7, 0.3), 1.9, "The ritual site for skill evolution: pick one variant of a skill instead of a number.",
		[{"aspect": ANY, "count": 6}], 400, 0, false)
	_add(&"altar_force", "Force Altar", StructureDef.Category.SPECIAL, Vector2i(1, 1), F,
		Color(0.89, 0.35, 0.23), 1.3, "Force monsters meditating next to it gain extra XP.",
		[{"aspect": F, "count": 4}], 200, 0, false)
	_add(&"altar_nature", "Nature Altar", StructureDef.Category.SPECIAL, Vector2i(1, 1), N,
		Color(0.31, 0.68, 0.50), 1.3, "Nature monsters meditating next to it gain extra XP.",
		[{"aspect": N, "count": 4}], 200, 0, false)
	_add(&"altar_dark", "Dark Altar", StructureDef.Category.SPECIAL, Vector2i(1, 1), D,
		Color(0.54, 0.39, 0.79), 1.3, "Dark monsters meditating next to it gain extra XP.",
		[{"aspect": D, "count": 4}], 200, 0, false)


static func _add(id: StringName, display_name: String, category: StructureDef.Category, size: Vector2i,
		aspect: Aspect.Type, color: Color, height: float, blurb: String, recipe: Array, price: int, idle_xp: int,
		water: bool) -> void:
	var d := StructureDef.new()
	d.id = id
	d.display_name = display_name
	d.category = category
	d.size = size
	d.aspect = aspect
	d.color = color
	d.height = height
	d.blurb = blurb
	for r in recipe:
		d.recipe.append(r)
	d.price = price
	d.idle_xp = idle_xp
	d.water = water
	_defs[id] = d


static func def(id: StringName) -> StructureDef:
	_ensure()
	return _defs.get(id)


static func has(id: StringName) -> bool:
	_ensure()
	return _defs.has(id)


static func ids() -> Array[StringName]:
	_ensure()
	var out: Array[StringName] = []
	for id in _defs:
		out.append(id)
	out.sort()
	return out
