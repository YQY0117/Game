extends GdUnitTestSuite
class_name PerfSignalsTest

var _player: PlayerController

func before_test() -> void:
	_player = PlayerController.new()

func after_test() -> void:
	_player.free()

func test_is_moving_when_velocity_nonzero() -> void:
	_player.velocity = Vector2(100, 0)
	assert_bool(_player.is_moving()).is_true()

func test_is_not_moving_when_velocity_zero() -> void:
	_player.velocity = Vector2.ZERO
	assert_bool(_player.is_moving()).is_false()

func test_movement_intensity_at_full_speed() -> void:
	_player.set_realm(1)
	_player.velocity = Vector2(88, 0)
	assert_float(_player.movement_intensity()).is_equal_approx(1.0, 0.01)

func test_movement_intensity_at_half_speed() -> void:
	_player.set_realm(1)
	_player.velocity = Vector2(44, 0)
	assert_float(_player.movement_intensity()).is_equal_approx(0.5, 0.01)

func test_movement_intensity_at_zero() -> void:
	_player.velocity = Vector2.ZERO
	assert_float(_player.movement_intensity()).is_equal(0.0)

func test_is_in_knockback_when_active() -> void:
	_player.apply_knockback(Vector2.RIGHT, 240.0, 0.25)
	assert_bool(_player.is_in_knockback()).is_true()

func test_is_not_in_knockback_when_inactive() -> void:
	assert_bool(_player.is_in_knockback()).is_false()

func test_signals_emit_on_state_change() -> void:
	var state_changes: Array[String] = []
	_player.state_changed.connect(func(new_state: String): state_changes.append(new_state))
	_player.set_immobile(true)
	_player.set_immobile(false)
	assert_int(state_changes.size()).is_equal(2)

func test_signals_emit_on_realm_change() -> void:
	var realm_changes: Array[int] = []
	_player.realm_transitioned.connect(func(new_realm: int): realm_changes.append(new_realm))
	_player.set_realm(3)
	assert_int(realm_changes.size()).is_equal(1)
	assert_int(realm_changes[0]).is_equal(3)

func test_physics_process_performance() -> void:
	_player.set_realm(1)
	var start_time := Time.get_ticks_usec()
	for i in 1000:
		_player._physics_process(0.016)
	var elapsed := Time.get_ticks_usec() - start_time
	assert_int(elapsed).is_less(500000)