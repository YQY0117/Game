extends GdUnitTestSuite
class_name MovementTest

var _player: PlayerController
var _state_changes: Array[String]
var _position_changes: Array[Vector2]

func before_test() -> void:
	_player = PlayerController.new()
	_state_changes = []
	_position_changes = []
	_player.state_changed.connect(_on_state_changed)
	_player.position_changed.connect(_on_position_changed)

func after_test() -> void:
	_player.state_changed.disconnect(_on_state_changed)
	_player.position_changed.disconnect(_on_position_changed)
	_player.free()

func _on_state_changed(new_state: String) -> void:
	_state_changes.append(new_state)

func _on_position_changed(new_pos: Vector2) -> void:
	_position_changes.append(new_pos)

func test_initial_state_is_idle() -> void:
	assert_str(_player.get_current_state()).is_equal("idle")

func test_base_speed_r1() -> void:
	_player.set_realm(1)
	assert_float(_player.get_base_speed()).is_equal_approx(88.0, 0.1)

func test_base_speed_r6() -> void:
	_player.set_realm(6)
	assert_float(_player.get_base_speed()).is_equal_approx(124.0, 0.1)

func test_realm_transition_signal() -> void:
	_player.set_realm(3)
	assert_int(_player.get_current_realm()).is_equal(3)

func test_immobile_prevents_movement() -> void:
	_player.set_immobile(true)
	assert_str(_player.get_current_state()).is_equal("immobile")

func test_immobile_release() -> void:
	_player.set_immobile(true)
	_player.set_immobile(false)
	assert_str(_player.get_current_state()).is_equal("idle")

func test_teleport_resets_state() -> void:
	_player.teleport_to(Vector2(100, 100))
	assert_vector(_player.global_position).is_equal(Vector2(100, 100))
	assert_str(_player.get_current_state()).is_equal("idle")

func test_knockback_applies_hitstun() -> void:
	_player.apply_knockback(Vector2.RIGHT, 100.0, 0.5)
	assert_str(_player.get_current_state()).is_equal("hitstun")

func test_accel_factor_at_30ms() -> void:
	var factor := _player._calculate_accel_factor(0.030)
	assert_float(factor).is_equal_approx(0.5, 0.05)

func test_accel_factor_at_48ms() -> void:
	var factor := _player._calculate_accel_factor(0.048)
	assert_float(factor).is_equal_approx(0.9, 0.05)

func test_accel_factor_at_60ms() -> void:
	var factor := _player._calculate_accel_factor(0.060)
	assert_float(factor).is_equal_approx(1.0, 0.01)

func test_decel_factor_at_15ms() -> void:
	var factor := _player._calculate_decel_factor(0.015)
	assert_float(factor).is_equal_approx(0.75, 0.05)

func test_decel_factor_at_30ms() -> void:
	var factor := _player._calculate_decel_factor(0.030)
	assert_float(factor).is_equal_approx(0.0, 0.01)