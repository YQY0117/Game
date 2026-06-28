extends GdUnitTestSuite
class_name StateEdgeTest

var _camera: CameraController
var _player: PlayerController

func before_test() -> void:
	_camera = CameraController.new()
	_player = PlayerController.new()
	_camera.set_target(_player)

func after_test() -> void:
	_camera.free()
	_player.free()

func test_frozen_locks_position() -> void:
	_camera.freeze()
	_player.global_position = Vector2(100, 100)
	_camera._physics_process(0.016)
	assert_vector(_camera.global_position).is_equal(Vector2.ZERO)

func test_frozen_locks_zoom() -> void:
	_camera.zoom_to(0.9, 0.4)
	_camera._update_zoom(0.2)
	_camera.freeze()
	var zoom_before := _camera.zoom.x
	_camera._update_zoom(0.2)
	assert_float(_camera.zoom.x).is_equal(zoom_before)

func test_frozen_clears_shake() -> void:
	_camera.shake(10.0, 0.5)
	_camera._update_shake(0.1)
	_camera.freeze()
	_camera._update_shake(0.1)
	assert_vector(_camera._shake_offset).is_equal(Vector2.ZERO)

func test_unfreezes_restores_behavior() -> void:
	_camera.freeze()
	_camera.unfreeze()
	_player.global_position = Vector2(100, 100)
	_camera._update_follow(0.016)
	assert_float(_camera.global_position.x).is_greater(0.0)

func test_death_clears_shake() -> void:
	_camera.shake(10.0, 0.5)
	_camera._update_shake(0.1)
	_camera.clear_shake()
	assert_vector(_camera._shake_offset).is_equal(Vector2.ZERO)
	assert_float(_camera._shake_timer).is_equal(0.0)

func test_pull_model_no_signal_subscription() -> void:
	var connections := _camera.get_signal_connection_list("position_changed")
	assert_int(connections.size()).is_equal(0)

func test_hard_follow_at_12fps() -> void:
	_camera.global_position = Vector2(0, 0)
	_player.global_position = Vector2(500, 0)
	_camera._update_follow(0.083)
	assert_float(abs(_camera.global_position.x - _player.global_position.x)).is_less(80.0)