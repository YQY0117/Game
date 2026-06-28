extends GdUnitTestSuite
class_name IdleFocusTest

var _manager: InputManager
var _idle_count: int

func before_test() -> void:
	_manager = InputManager.new()
	_idle_count = 0
	_manager.input_idle.connect(_on_idle)

func after_test() -> void:
	_manager.input_idle.disconnect(_on_idle)
	_manager.free()

func _on_idle() -> void:
	_idle_count += 1

func test_idle_detection_after_50ms() -> void:
	_manager._idle_timer = 0.0
	_manager._was_idle = false
	_manager._physics_process(0.051)
	assert_int(_idle_count).is_equal(1)

func test_idle_not_emitted_before_threshold() -> void:
	_manager._idle_timer = 0.0
	_manager._was_idle = false
	_manager._physics_process(0.049)
	assert_int(_idle_count).is_equal(0)

func test_idle_emitted_once() -> void:
	_manager._idle_timer = 0.0
	_manager._was_idle = false
	_manager._physics_process(0.051)
	_manager._physics_process(0.051)
	assert_int(_idle_count).is_equal(1)

func test_movement_resets_idle() -> void:
	_manager._idle_timer = 50.0
	_manager._was_idle = true
	_manager._physics_process(0.016)
	assert_bool(_manager._was_idle).is_false()

func test_focus_loss_resets_input() -> void:
	_manager._touch_joystick_vector = Vector2(1, 0)
	_manager._joystick_active = true
	_manager._primary_touch_index = 0
	_manager._reset_all_input()
	assert_vector(_manager._touch_joystick_vector).is_equal(Vector2.ZERO)
	assert_bool(_manager._joystick_active).is_false()
	assert_int(_manager._primary_touch_index).is_equal(-1)