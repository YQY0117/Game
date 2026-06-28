extends GdUnitTestSuite
class_name AiLodTest

var _enemy: InkDrop
var _player: PlayerController

func before_test() -> void:
	_player = PlayerController.new()
	_player.global_position = Vector2(500, 500)
	_enemy = InkDrop.new()
	_enemy.set_target(_player)

func after_test() -> void:
	_enemy.free()
	_player.free()

func test_lod_near_distance() -> void:
	_enemy.global_position = Vector2(600, 500)
	_enemy._update_lod()
	assert_int(_enemy._lod_tick_rate).is_equal(1)

func test_lod_medium_distance() -> void:
	_enemy.global_position = Vector2(1200, 500)
	_enemy._update_lod()
	assert_int(_enemy._lod_tick_rate).is_equal(2)

func test_lod_far_distance() -> void:
	_enemy.global_position = Vector2(1800, 500)
	_enemy._update_lod()
	assert_int(_enemy._lod_tick_rate).is_equal(4)

func test_lod_frame_counter_increments() -> void:
	var initial_counter := _enemy._lod_frame_counter
	_enemy._update_lod()
	assert_int(_enemy._lod_frame_counter).is_equal(initial_counter + 1)