extends GdUnitTestSuite
class_name WaveSpawningTest

var _manager: WaveManager
var _player: PlayerController

func before_test() -> void:
	_player = PlayerController.new()
	_player.global_position = Vector2(500, 500)
	_manager = WaveManager.new()
	_manager.set_player(_player)

func after_test() -> void:
	_manager.free()
	_player.free()

func test_initial_state() -> void:
	assert_int(_manager.get_current_wave()).is_equal(0)
	assert_int(_manager.get_enemies_alive()).is_equal(0)

func test_set_realm_updates_max_enemies() -> void:
	_manager.set_realm(1)
	assert_int(_manager._max_enemies).is_equal(30)
	_manager.set_realm(5)
	assert_int(_manager._max_enemies).is_equal(150)

func test_start_waves_emits_signal() -> void:
	var wave_started_count := 0
	_manager.wave_started.connect(func(wave): wave_started_count += 1)
	_manager.start_waves()
	assert_int(wave_started_count).is_equal(1)
	assert_int(_manager.get_current_wave()).is_equal(1)

func test_wave_rest_time() -> void:
	_manager._is_resting = true
	_manager._wave_timer = 3.0
	_manager._physics_process(1.0)
	assert_float(_manager._wave_timer).is_equal(2.0)

func test_spawn_position_in_range() -> void:
	var pos := _manager._get_spawn_position()
	var distance := pos.distance_to(_player.global_position)
	assert_float(distance).is_greater_equal(400.0)
	assert_float(distance).is_less_equal(800.0)

func test_max_enemies_formula() -> void:
	_manager.set_realm(1)
	assert_int(_manager._max_enemies).is_equal(30)
	_manager.set_realm(3)
	assert_int(_manager._max_enemies).is_equal(90)