extends GdUnitTestSuite
class_name TouchJoystickTest

var _manager: InputManager

func before_test() -> void:
	_manager = InputManager.new()

func after_test() -> void:
	_manager.free()

func test_first_touch_sets_center() -> void:
	var event := InputEventScreenTouch.new()
	event.pressed = true
	event.position = Vector2(100, 100)
	event.index = 0
	_manager._handle_touch_event(event)
	assert_vector(_manager._joystick_center).is_equal(Vector2(100, 100))
	assert_bool(_manager._joystick_active).is_true()

func test_second_touch_ignored() -> void:
	var event1 := InputEventScreenTouch.new()
	event1.pressed = true
	event1.position = Vector2(100, 100)
	event1.index = 0
	_manager._handle_touch_event(event1)
	
	var event2 := InputEventScreenTouch.new()
	event2.pressed = true
	event2.position = Vector2(200, 200)
	event2.index = 1
	_manager._handle_touch_event(event2)
	
	assert_int(_manager._primary_touch_index).is_equal(0)
	assert_vector(_manager._joystick_center).is_equal(Vector2(100, 100))

func test_primary_release_deactivates() -> void:
	var event := InputEventScreenTouch.new()
	event.pressed = true
	event.position = Vector2(100, 100)
	event.index = 0
	_manager._handle_touch_event(event)
	
	var release := InputEventScreenTouch.new()
	release.pressed = false
	release.index = 0
	_manager._handle_touch_event(release)
	
	assert_bool(_manager._joystick_active).is_false()
	assert_int(_manager._primary_touch_index).is_equal(-1)

func test_drag_updates_vector() -> void:
	var touch := InputEventScreenTouch.new()
	touch.pressed = true
	touch.position = Vector2(100, 100)
	touch.index = 0
	_manager._handle_touch_event(touch)
	
	var drag := InputEventScreenDrag.new()
	drag.position = Vector2(150, 100)
	drag.index = 0
	_manager._handle_touch_event(drag)
	
	assert_float(_manager._touch_joystick_vector.x).is_greater(0.0)

func test_right_half_screen_ignored() -> void:
	var viewport_w := 1280
	var event := InputEventScreenTouch.new()
	event.pressed = true
	event.position = Vector2(viewport_w / 2.0 + 50, 100)
	event.index = 0
	_manager._handle_touch_event(event)
	
	assert_bool(_manager._joystick_active).is_false()