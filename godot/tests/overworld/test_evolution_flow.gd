extends GdUnitTestSuite
## Breakthroughs and the Evolution Pillar as a structure (the legacy skill evolution is removed).


func _rng(seed_value := 8) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng


func _game() -> GameState:
	return GameState.new_game(_rng())


func _mat(aspect: Aspect.Type, n := 1) -> Array:
	return [ItemCatalog.material_id(MonsterDef.Kin.BEAST, aspect, 0), n]


func _give(g: GameState, aspect: Aspect.Type, n: int) -> void:
	var m := _mat(aspect, n)
	g.add_item(m[0], m[1])


func _ready_for_foundation(g: GameState) -> void:
	g.monsters[0].xp = 0
	g.monsters[0].add_xp(60 + 120)
	g.monsters[0].add_xp(MonsterInstance.HIGH_BAR)


func _with_pillar(g: GameState) -> void:
	g.add_item(ItemCatalog.structure_item_id(GameState.EVOLUTION_PILLAR))
	g.place_structure(GameState.EVOLUTION_PILLAR, Vector2i(2, 1), false)


# ---------- breakthrough ----------

func test_the_player_needs_a_ready_monster_materials_and_ap_to_break_through() -> void:
	var g := _game()
	_give(g, Aspect.Type.FORCE, GameState.BREAKTHROUGH_MATERIALS)
	assert_bool(g.can_break_through()).is_false()                 # the monster isn't ready
	_ready_for_foundation(g)
	assert_int(g.breakthrough_monster()).is_equal(0)
	assert_bool(g.can_break_through()).is_true()
	g.spend_ap(3)
	assert_bool(g.can_break_through()).is_false()                 # no AP


func test_breaking_through_raises_the_stage_ap_and_unlocks_the_pillar() -> void:
	var g := _game()
	_ready_for_foundation(g)
	_give(g, Aspect.Type.FORCE, 6)
	assert_bool(g.break_through()).is_true()
	assert_int(g.stage).is_equal(Stage.Type.FOUNDATION)
	assert_int(g.max_ap).is_equal(GameState.START_AP + 1)
	assert_int(g.item_count(ItemCatalog.material_id(MonsterDef.Kin.BEAST, Aspect.Type.FORCE, 0))).is_equal(1)
	assert_bool(g.has_blueprint(GameState.EVOLUTION_PILLAR)).is_true()
	assert_str(String(g.battle_mode())).is_equal("3v3")
	assert_int(BuildGrid.region(g.stage).get_area()).is_greater(BuildGrid.region(Stage.Type.QI_GATHERING).get_area())
	assert_bool(g.market.factors.has(ItemCatalog.materials_of_tier(1)[0])).is_true()


func test_a_monster_follows_the_player_one_stage_at_a_time() -> void:
	var g := _game()
	_ready_for_foundation(g)
	_give(g, Aspect.Type.FORCE, 10)
	g.break_through()
	var m := g.monsters[0]
	assert_bool(m.can_break_through(g.stage)).is_true()
	assert_bool(g.can_monster_break_through(0)).is_true()
	var hp_before := m.max_hp()
	assert_bool(g.monster_break_through(0)).is_true()
	assert_int(m.stage).is_equal(Stage.Type.FOUNDATION)
	assert_int(m.sub_tier).is_equal(Stage.SubTier.LOWER)
	assert_int(m.xp).is_equal(0)
	assert_int(m.max_hp()).is_greater_equal(hp_before)
	assert_bool(g.can_monster_break_through(0)).is_false()        # never above the player's stage


func test_a_monster_cannot_pass_the_players_stage() -> void:
	var g := _game()
	_ready_for_foundation(g)
	_give(g, Aspect.Type.FORCE, 10)
	assert_bool(g.monsters[0].can_break_through(g.stage)).is_false()
	assert_bool(g.can_monster_break_through(0)).is_false()


func test_the_cheat_moves_everyone_up() -> void:
	var g := _game()
	Cheats.stage_up(g)
	assert_int(g.stage).is_equal(Stage.Type.FOUNDATION)
	assert_int(g.monsters[0].stage).is_equal(Stage.Type.FOUNDATION)


# ---------- evolving ----------

func test_the_pillar_is_a_buildable_structure() -> void:
	var d := StructureCatalog.def(GameState.EVOLUTION_PILLAR)
	assert_str(d.display_name).is_equal("Evolution Pillar")
	assert_bool(d.recipe.is_empty()).is_false()
