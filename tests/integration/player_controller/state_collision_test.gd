extends GdUnitTestSuite
class_name StateCollisionTest

var _player: PlayerController

func before_test() -> void:
	_player = PlayerController.new()

func after_test() -> void:
	_player.free()

func test_state_priority_immobile_over_hitstun() -> void:
	_player.apply_knockback(Vector2.RIGHT, 240.0, 0.25)
	assert_str(_player.get_current_state()).is_equal("hitstun")
	_player.set_immobile(true)
	assert_str(_player.get_current_state()).is_equal("immobile")

func test_immobile_cancels_knockback() -> void:
	_player.apply_knockback(Vector2.RIGHT, 240.0, 0.25)
	_player.set_immobile(true)
	assert_float(_player._knockback_timer).is_equal(0.0)
	assert_vector(_player._knockback_velocity).is_equal(Vector2.ZERO)

func test_immobile_prevents_movement() -> void:
	_player.set_immobile(true)
	_player._physics_process(0.016)
	assert_vector(_player.velocity).is_equal(Vector2.ZERO)

func test_immobile_release_returns_to_idle() -> void:
	_player.set_immobile(true)
	_player.set_immobile(false)
	assert_str(_player.get_current_state()).is_equal("idle")

func test_teleport_resets_all_state() -> void:
	_player.apply_knockback(Vector2.RIGHT, 240.0, 0.25)
	_player.teleport_to(Vector2(100, 100))
	assert_str(_player.get_current_state()).is_equal("idle")
	assert_vector(_player.velocity).is_equal(Vector2.ZERO)
	assert_vector(_player._knockback_velocity).is_equal(Vector2.ZERO)

func test_state_priority_hitstun_over_running() -> void:
	_player._move_input = Vector2.RIGHT
	_player._set_state(PlayerController.State.RUNNING)
	_player.apply_knockback(Vector2.LEFT, 240.0, 0.25)
	assert_str(_player.get_current_state()).is_equal("hitstun")

func test_state_transitions_emit_signals() -> void:
	var state_changes: Array[String] = []
	_player.state_changed.connect(func(new_state: String): state_changes.append(new_state))
	_player.set_immobile(true)
	_player.set_immobile(false)
	assert_int(state_changes.size()).is_equal(2)
	assert_str(state_changes[0]).is_equal("immobile")
	assert_str(state_changes[1]).is_equal("idle")