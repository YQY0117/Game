extends GdUnitTestSuite
class_name SpeedUpdateTest

var _progression: RealmProgression
var _player: PlayerController

func before_test() -> void:
	_player = PlayerController.new()
	_progression = RealmProgression.new()
	_progression.set_player(_player)

func after_test() -> void:
	_progression.free()
	_player.free()

func test_realm_change_updates_player_speed() -> void:
	var initial_speed := _player.get_base_speed()
	_progression._current_realm = 1
	_progression._complete_breakthrough()
	assert_float(_player.get_base_speed()).is_greater(initial_speed)

func test_speed_formula_r1() -> void:
	_player.set_realm(1)
	assert_float(_player.get_base_speed()).is_equal_approx(88.0, 1.0)

func test_speed_formula_r2() -> void:
	_player.set_realm(2)
	assert_float(_player.get_base_speed()).is_equal_approx(100.0, 1.0)

func test_speed_formula_r6() -> void:
	_player.set_realm(6)
	assert_float(_player.get_base_speed()).is_equal_approx(124.0, 1.0)

func test_realm_changed_signal_updates_player() -> void:
	_progression._current_realm = 1
	_progression._complete_breakthrough()
	assert_int(_player.get_current_realm()).is_equal(2)