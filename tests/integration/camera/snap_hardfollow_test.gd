extends GdUnitTestSuite
class_name SnapHardfollowTest

var _camera: CameraController
var _player: PlayerController

func before_test() -> void:
	_camera = CameraController.new()
	_player = PlayerController.new()
	_camera.set_target(_player)

func after_test() -> void:
	_camera.free()
	_player.free()

func test_snap_to_immediate() -> void:
	_camera.global_position = Vector2(0, 0)
	_camera.snap_to(Vector2(500, 300))
	assert_vector(_camera.global_position).is_equal(Vector2(500, 300))

func test_snap_to_resets_shake() -> void:
	_camera.shake(10.0, 0.5)
	_camera.snap_to(Vector2(100, 100))
	assert_vector(_camera._shake_offset).is_equal(Vector2.ZERO)
	assert_float(_camera._shake_timer).is_equal(0.0)

func test_hard_follow_triggers_on_x_overflow() -> void:
	_camera.global_position = Vector2(0, 0)
	_player.global_position = Vector2(600, 0)
	_camera._update_follow(0.016)
	assert_float(abs(_camera.global_position.x - _player.global_position.x)).is_less(80.0)

func test_hard_follow_triggers_on_y_overflow() -> void:
	_camera.global_position = Vector2(0, 0)
	_player.global_position = Vector2(0, 400)
	_camera._update_follow(0.016)
	assert_float(abs(_camera.global_position.y - _player.global_position.y)).is_less(120.0)

func test_soft_follow_within_margins() -> void:
	_camera.global_position = Vector2(0, 0)
	_player.global_position = Vector2(100, 0)
	_camera._update_follow(0.016)
	assert_float(_camera.global_position.x).is_greater(0.0)
	assert_float(_camera.global_position.x).is_less(100.0)

func test_position_integer_aligned() -> void:
	_camera.snap_to(Vector2(100.5, 200.7))
	assert_float(_camera.global_position.x).is_equal(100.0)
	assert_float(_camera.global_position.y).is_equal(200.0)