extends GdUnitTestSuite
class_name AutoFireTest

var _manager: TechniqueManager
var _player: PlayerController
var _technique1: TechniqueData
var _technique2: TechniqueData
var _enemy: InkDrop

func before_test() -> void:
	_player = PlayerController.new()
	_player.global_position = Vector2(500, 500)
	_manager = TechniqueManager.new()
	_manager.set_player_owner(_player)
	
	_technique1 = TechniqueData.new()
	_technique1.id = "flame_palm"
	_technique1.cooldown = 1.2
	_technique1.base_damage = 5.0
	_technique1.element = TechniqueData.Element.FIRE
	
	_technique2 = TechniqueData.new()
	_technique2.id = "ice_spike"
	_technique2.cooldown = 1.8
	_technique2.base_damage = 4.0
	_technique2.element = TechniqueData.Element.ICE
	
	_enemy = InkDrop.new()
	_enemy.global_position = Vector2(600, 500)
	_manager.set_enemies([_enemy])

func after_test() -> void:
	_manager.free()
	_player.free()
	_enemy.free()

func test_equip_technique() -> void:
	_manager.equip_technique(0, _technique1)
	assert_int(_manager.get_equipped_techniques().size()).is_equal(7)
	assert_str(_manager.get_equipped_techniques()[0].id).is_equal("flame_palm")

func test_unequip_technique() -> void:
	_manager.equip_technique(0, _technique1)
	_manager.unequip_technique(0)
	assert_bool(_manager.get_equipped_techniques()[0] == null).is_true()

func test_cooldown_timer() -> void:
	_manager.equip_technique(0, _technique1)
	_manager._cooldown_timers[0] = 0.5
	assert_float(_manager.get_cooldown_timer(0)).is_equal(0.5)

func test_find_nearest_enemy() -> void:
	var nearest := _manager._find_nearest_enemy()
	assert_bool(nearest == _enemy).is_true()

func test_technique_fires_signal() -> void:
	var fired_count := 0
	_manager.technique_fired.connect(func(tech, pos, dir): fired_count += 1)
	_manager.equip_technique(0, _technique1)
	_manager._cooldown_timers[0] = 0.0
	_manager._physics_process(0.016)
	assert_int(fired_count).is_equal(1)