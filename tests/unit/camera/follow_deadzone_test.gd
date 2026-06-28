extends GdUnitTestSuite
class_name FollowDeadzoneTest

var _camera: CameraController
var _player: PlayerController

func before_test() -> void:
	_camera = CameraController.new()
	_player = PlayerController.new()
	_camera.set_target(_player)

func after_test() -> void:
	_camera.free()
	_player.free()

func test_camera_follows_player() -> void:
	_player.global_position = Vector2(100, 100)
	_camera.global_position = Vector2(0, 0)
	_camera._update_follow(0.016)
	assert_float(_camera.global_position.x).is_greater(0.0)

func test_deadzone_prevents_movement() -> void:
	_player.global_position = Vector2(10, 10)
	_camera.global_position = Vector2(0, 0)
	_camera._update_follow(0.016)
	assert_vector(_camera.global_position).is_equal(Vector2.ZERO)

func test_deadzone_boundary() -> void:
	_player.global_position = Vector2(31, 0)
	_camera.global_position = Vector2(0, 0)
	_camera._update_follow(0.016)
	assert_vector(_camera.global_position).is_equal(Vector2.ZERO)

func test_beyond_deadzone() -> void:
	_player.global_position = Vector2(33, 0)
	_camera.global_position = Vector2(0, 0)
	_camera._update_follow(0.016)
	assert_float(_camera.global_position.x).is_greater(0.0)

func test_shake_applies_offset() -> void:
	_camera.shake(5.0, 0.5)
	_camera._update_shake(0.016)
	assert_float(_camera._shake_offset.length()).is_greater(0.0)

func test_shake_decays() -> void:
	_camera.shake(5.0, 0.5)
	_camera._update_shake(0.25)
	var offset1 := _camera._shake_offset.length()
	_camera._update_shake(0.25)
	var offset2 := _camera._shake_offset.length()
	assert_float(offset2).is_less(offset1)

func test_freeze_prevents_update() -> void:
	_camera.freeze()
	_player.global_position = Vector2(100, 100)
	_camera.global_position = Vector2(0, 0)
	_camera._physics_process(0.016)
	assert_vector(_camera.global_position).is_equal(Vector2.ZERO)

func test_unfreeze_allows_update() -> void:
	_camera.freeze()
	_camera.unfreeze()
	_player.global_position = Vector2(100, 100)
	_camera.global_position = Vector2(0, 0)
	_camera._update_follow(0.016)
	assert_float(_camera.global_position.x).is_greater(0.0)

func test_snap_to_resets_position() -> void:
	_camera.snap_to(Vector2(50, 50))
	assert_vector(_camera.global_position).is_equal(Vector2(50, 50))