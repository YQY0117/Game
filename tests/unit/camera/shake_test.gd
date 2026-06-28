extends GdUnitTestSuite
class_name ShakeTest

var _camera: CameraController

func before_test() -> void:
	_camera = CameraController.new()

func after_test() -> void:
	_camera.free()

func test_shake_sets_parameters() -> void:
	_camera.shake(10.0, 0.5)
	assert_float(_camera._shake_magnitude).is_equal(10.0)
	assert_float(_camera._shake_duration).is_equal(0.5)

func test_shake_applies_offset() -> void:
	_camera.shake(5.0, 0.5)
	_camera._update_shake(0.016)
	assert_float(_camera._shake_offset.length()).is_greater(0.0)

func test_shake_cubic_decay() -> void:
	_camera.shake(10.0, 0.200)
	_camera._update_shake(0.050)
	var offset1 := _camera._shake_offset.length()
	_camera._update_shake(0.050)
	var offset2 := _camera._shake_offset.length()
	assert_float(offset2).is_less(offset1)

func test_knockback_shake_tier_0() -> void:
	_camera.knockback_shake(0)
	assert_float(_camera._shake_magnitude).is_equal(2.0)
	assert_float(_camera._shake_duration).is_equal(0.100)

func test_knockback_shake_tier_4() -> void:
	_camera.knockback_shake(4)
	assert_float(_camera._shake_magnitude).is_equal(18.0)
	assert_float(_camera._shake_duration).is_equal(0.250)

func test_knockback_shake_clamps_tier() -> void:
	_camera.knockback_shake(10)
	assert_float(_camera._shake_magnitude).is_equal(18.0)

func test_shake_envelope_at_25_percent() -> void:
	_camera.shake(10.0, 0.200)
	_camera._update_shake(0.050)
	var expected_envelope := pow(1.0 - 0.25, 3.0)
	var actual_magnitude := _camera._shake_offset.length()
	assert_float(actual_magnitude).is_less(10.0 * expected_envelope + 1.0)

func test_shake_envelope_at_50_percent() -> void:
	_camera.shake(10.0, 0.200)
	_camera._update_shake(0.100)
	var expected_envelope := pow(1.0 - 0.50, 3.0)
	var actual_magnitude := _camera._shake_offset.length()
	assert_float(actual_magnitude).is_less(10.0 * expected_envelope + 1.0)