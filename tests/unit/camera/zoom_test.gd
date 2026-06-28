extends GdUnitTestSuite
class_name ZoomTest

var _camera: CameraController

func before_test() -> void:
	_camera = CameraController.new()

func after_test() -> void:
	_camera.free()

func test_zoom_to_sets_target() -> void:
	_camera.zoom_to(0.9)
	assert_float(_camera._zoom_to).is_equal(0.9)

func test_zoom_clamps_to_min() -> void:
	_camera.zoom_to(0.5)
	assert_float(_camera._zoom_to).is_equal(0.8)

func test_zoom_clamps_to_max() -> void:
	_camera.zoom_to(1.5)
	assert_float(_camera._zoom_to).is_equal(1.2)

func test_zoom_transition_updates_zoom() -> void:
	_camera.zoom = Vector2(1.0, 1.0)
	_camera.zoom_to(0.9, 0.4)
	_camera._update_zoom(0.2)
	assert_float(_camera.zoom.x).is_less(1.0)

func test_zoom_transition_completes() -> void:
	_camera.zoom = Vector2(1.0, 1.0)
	_camera.zoom_to(0.9, 0.4)
	_camera._update_zoom(0.41)
	assert_float(_camera.zoom.x).is_equal_approx(0.9, 0.01)

func test_zoom_interrupt_from_current() -> void:
	_camera.zoom = Vector2(1.0, 1.0)
	_camera.zoom_to(0.9, 0.4)
	_camera._update_zoom(0.2)
	var mid_zoom := _camera.zoom.x
	_camera.zoom_to(1.1, 0.4)
	assert_float(_camera._zoom_from).is_equal(mid_zoom)

func test_zoom_monotonic_increase() -> void:
	_camera.zoom = Vector2(0.9, 0.9)
	_camera.zoom_to(1.1, 0.4)
	var prev_zoom := 0.9
	for i in 10:
		_camera._update_zoom(0.04)
		assert_float(_camera.zoom.x).is_greater(prev_zoom)
		prev_zoom = _camera.zoom.x

func test_zoom_monotonic_decrease() -> void:
	_camera.zoom = Vector2(1.1, 1.1)
	_camera.zoom_to(0.9, 0.4)
	var prev_zoom := 1.1
	for i in 10:
		_camera._update_zoom(0.04)
		assert_float(_camera.zoom.x).is_less(prev_zoom)
		prev_zoom = _camera.zoom.x