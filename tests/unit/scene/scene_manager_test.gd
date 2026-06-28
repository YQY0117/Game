extends GdUnitTestSuite
class_name SceneManagerTest

var _manager: SceneManager
var _transition_started_count: int
var _transition_completed_count: int

func before_test() -> void:
	_manager = SceneManager.new()
	_transition_started_count = 0
	_transition_completed_count = 0
	_manager.transition_started.connect(_on_transition_started)
	_manager.transition_completed.connect(_on_transition_completed)

func after_test() -> void:
	_manager.transition_started.disconnect(_on_transition_started)
	_manager.transition_completed.disconnect(_on_transition_completed)
	_manager.free()

func _on_transition_started() -> void:
	_transition_started_count += 1

func _on_transition_completed() -> void:
	_transition_completed_count += 1

func test_transition_layer_created() -> void:
	assert_bool(_manager._transition_layer != null).is_true()

func test_cover_rect_created() -> void:
	assert_bool(_manager._cover_rect != null).is_true()

func test_cover_rect_initially_hidden() -> void:
	assert_bool(_manager._cover_rect.visible).is_false()

func test_transition_signals_emitted() -> void:
	_manager.change_scene("res://test.tscn")
	assert_int(_transition_started_count).is_equal(1)
	assert_int(_transition_completed_count).is_equal(1)

func test_cover_animation_duration() -> void:
	var start_time := Time.get_ticks_msec()
	_manager._play_cover_animation()
	var elapsed := Time.get_ticks_msec() - start_time
	assert_int(elapsed).is_greater_equal(250)
	assert_int(elapsed).is_less_equal(350)

func test_dissipate_animation_duration() -> void:
	_manager._cover_rect.visible = true
	_manager._cover_rect.modulate.a = 1.0
	var start_time := Time.get_ticks_msec()
	_manager._play_dissipate_animation()
	var elapsed := Time.get_ticks_msec() - start_time
	assert_int(elapsed).is_greater_equal(150)
	assert_int(elapsed).is_less_equal(250)