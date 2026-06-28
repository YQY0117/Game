extends GdUnitTestSuite
class_name ModeSwitchTest

var _manager: InputManager
var _emitted_modes: Array[String]

func before_test() -> void:
	_manager = InputManager.new()
	_emitted_modes = []
	_manager.input_mode_changed.connect(_on_mode_changed)

func after_test() -> void:
	_manager.input_mode_changed.disconnect(_on_mode_changed)
	_manager.free()

func _on_mode_changed(new_mode: String) -> void:
	_emitted_modes.append(new_mode)

func _touch_event() -> InputEventScreenTouch:
	var event := InputEventScreenTouch.new()
	event.pressed = true
	event.position = Vector2(100, 100)
	return event

func _key_event() -> InputEventKey:
	var event := InputEventKey.new()
	event.keycode = KEY_W
	event.pressed = true
	return event

func test_3_consecutive_touch_switches_mode() -> void:
	assert_str(_manager.get_current_mode()).is_equal("kbm")
	_manager._unhandled_input(_touch_event())
	_manager._unhandled_input(_touch_event())
	_manager._unhandled_input(_touch_event())
	assert_str(_manager.get_current_mode()).is_equal("touch")
	assert_array(_emitted_modes).contains_exactly(["touch"])

func test_400ms_hold_switches_mode() -> void:
	assert_str(_manager.get_current_mode()).is_equal("kbm")
	_manager._pending_device = "touch"
	_manager._consecutive_events = 1
	_manager._continuous_duration = InputManager.MODE_SWITCH_MIN_DURATION_MS + InputManager.EXTRA_COOLDOWN_TO_TOUCH_MS
	_manager._try_switch_mode()
	assert_str(_manager.get_current_mode()).is_equal("touch")
	assert_array(_emitted_modes).contains_exactly(["touch"])

func test_2_events_no_switch() -> void:
	assert_str(_manager.get_current_mode()).is_equal("kbm")
	_manager._unhandled_input(_touch_event())
	_manager._unhandled_input(_touch_event())
	assert_str(_manager.get_current_mode()).is_equal("kbm")
	assert_array(_emitted_modes).is_empty()

func test_different_device_resets_counter() -> void:
	assert_str(_manager.get_current_mode()).is_equal("kbm")
	_manager._unhandled_input(_touch_event())
	_manager._unhandled_input(_touch_event())
	_manager._unhandled_input(_key_event())
	_manager._unhandled_input(_touch_event())
	_manager._unhandled_input(_touch_event())
	assert_str(_manager.get_current_mode()).is_equal("kbm")
	assert_array(_emitted_modes).is_empty()
