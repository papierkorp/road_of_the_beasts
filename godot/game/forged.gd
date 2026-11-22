class_name Forged
extends RefCounted
## The forged weapons of the hub game as tamer skills of the battle (docs/overworld.md §6.3): a weapon is a tamer
## skill paid with materials. Two beast parts make one, what it lays and how; eight entries of each are 64 weapons,
## so they are built from the test values instead of 64 files, and added to the battle's content under the id
## `Crafting.weapon_skill` gives. Which Kin stands for which entry is drawn per game; the weapons are the same. `game/` is the only part that knows both halves.


## Makes sure the battle knows every forged weapon of these values. Cheap when they are there already.
static func ensure(values: GameValues, content: BattleContent = null) -> void:
	if content == null:
		content = BattleContent.shared()
	var whats := values.forge_what.size()
	var hows := values.forge_how.size()
	if whats == 0 or hows == 0 or content.tamer.has(Crafting.weapon_skill(whats - 1, hows - 1)):
		return
	for what in whats:
		for how in hows:
			var def := build(values, what, how)
			content.tamer[def.id] = def


static func build(values: GameValues, what: int, how: int) -> TamerSkillDef:
	var w := Crafting.what_of(values, what)
	var h := Crafting.how_of(values, how)
	var def := TamerSkillDef.new()
	def.id = Crafting.weapon_skill(what, how)
	def.display_name = Crafting.piece_name(values, what, how)
	def.effect = TamerSkillDef.LAY
	def.description = "Lays %s." % Crafting.piece_text(values, what, how)
	if w.has("prop"):
		def.lay_prop = StringName(w["prop"])
	else:
		def.lay_ground = StringName(w.get("ground", &"plain"))
	def.lay_count = maxi(1, int(h.get("count", 1)))
	def.source = "weapon"
	return def
