extends GdUnitTestSuite
class_name RealmSpeedTest

var _player: PlayerController

func before_test() -> void:
	_player = PlayerController.new()

func after_test() -> void:
	_player.free()

func test_realm_1_speed() -> void:
	_player.set_realm(1)
	assert_float(_player.get_base_speed()).is_equal_approx(88.0, 1.0)

func test_realm_2_speed() -> void:
	_player.set_realm(2)
	assert_float(_player.get_base_speed()).is_equal_approx(100.0, 1.0)

func test_realm_3_speed() -> void:
	_player.set_realm(3)
	assert_float(_player.get_base_speed()).is_equal_approx(109.0, 1.0)

func test_realm_4_speed() -> void:
	_player.set_realm(4)
	assert_float(_player.get_base_speed()).is_equal_approx(116.0, 1.0)

func test_realm_5_speed() -> void:
	_player.set_realm(5)
	assert_float(_player.get_base_speed()).is_equal_approx(121.0, 1.0)

func test_realm_6_speed() -> void:
	_player.set_realm(6)
	assert_float(_player.get_base_speed()).is_equal_approx(124.0, 1.0)

func test_realm_1_clearance() -> void:
	_player.set_realm(1)
	assert_float(_player.get_clearance_radius()).is_equal_approx(16.0, 0.1)

func test_realm_2_clearance() -> void:
	_player.set_realm(2)
	assert_float(_player.get_clearance_radius()).is_equal_approx(22.4, 0.1)

func test_realm_3_clearance() -> void:
	_player.set_realm(3)
	assert_float(_player.get_clearance_radius()).is_equal_approx(32.0, 0.1)

func test_realm_4_clearance() -> void:
	_player.set_realm(4)
	assert_float(_player.get_clearance_radius()).is_equal_approx(41.6, 0.1)

func test_realm_5_clearance() -> void:
	_player.set_realm(5)
	assert_float(_player.get_clearance_radius()).is_equal_approx(52.8, 0.1)

func test_realm_6_clearance() -> void:
	_player.set_realm(6)
	assert_float(_player.get_clearance_radius()).is_equal_approx(64.0, 0.1)

func test_realm_transition_signal() -> void:
	_player.set_realm(3)
	assert_int(_player.get_current_realm()).is_equal(3)