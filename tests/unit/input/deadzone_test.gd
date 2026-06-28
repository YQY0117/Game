extends GdUnitTestSuite
class_name DeadzoneTest

var _manager: InputManager

func before_test() -> void:
	_manager = InputManager.new()
	_manager._current_mode = "touch"

func after_test() -> void:
	_manager.free()

func test_touch_deadzone_below_threshold() -> void:
	_manager._current_mode = "touch"
	var raw := Vector2(0.08, 0.0)
	var result := _manager._apply_deadzone_and_curve(raw)
	assert_vector(result).is_equal(Vector2.ZERO)

func test_touch_deadzone_above_threshold() -> void:
	_manager._current_mode = "touch"
	var raw := Vector2(0.20, 0.0)
	var result := _manager._apply_deadzone_and_curve(raw)
	assert_float(result.length()).is_greater(0.0)

func test_gamepad_deadzone_below_threshold() -> void:
	_manager._current_mode = "gamepad"
	var raw := Vector2(0.12, 0.0)
	var result := _manager._apply_deadzone_and_curve(raw)
	assert_vector(result).is_equal(Vector2.ZERO)

func test_gamepad_deadzone_above_threshold() -> void:
	_manager._current_mode = "gamepad"
	var raw := Vector2(0.20, 0.0)
	var result := _manager._apply_deadzone_and_curve(raw)
	assert_float(result.length()).is_greater(0.0)

func test_touch_response_curve_nonlinear() -> void:
	_manager._current_mode = "touch"
	var raw := Vector2(0.3, 0.0)
	var result := _manager._apply_deadzone_and_curve(raw)
	var expected_m := clampf((0.3 - 0.10) / (1.0 - 0.10), 0.0, 1.0)
	var expected_magnitude := pow(expected_m, 1.5)
	assert_float(result.length()).is_equal_approx(expected_magnitude, 0.001)

func test_gamepad_response_curve_linear() -> void:
	_manager._current_mode = "gamepad"
	var raw := Vector2(0.3, 0.0)
	var result := _manager._apply_deadzone_and_curve(raw)
	var expected_m := clampf((0.3 - 0.15) / (1.0 - 0.15), 0.0, 1.0)
	var expected_magnitude := pow(expected_m, 1.0)
	assert_float(result.length()).is_equal_approx(expected_magnitude, 0.001)

func test_kbm_no_deadzone() -> void:
	_manager._current_mode = "kbm"
	var raw := Vector2(0.08, 0.0)
	var result := _manager._apply_deadzone_and_curve(raw)
	assert_float(result.length()).is_equal_approx(1.0, 0.001)

func test_zero_vector_returns_zero() -> void:
	var raw := Vector2.ZERO
	var result := _manager._apply_deadzone_and_curve(raw)
	assert_vector(result).is_equal(Vector2.ZERO)

func test_deadzone_config_override() -> void:
	_manager._dead_zone_touch = 0.05
	_manager._current_mode = "touch"
	var raw := Vector2(0.08, 0.0)
	var result := _manager._apply_deadzone_and_curve(raw)
	assert_float(result.length()).is_greater(0.0)