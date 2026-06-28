extends GdUnitTestSuite
class_name KnockbackTest

var _player: PlayerController

func before_test() -> void:
	_player = PlayerController.new()

func after_test() -> void:
	_player.free()

func test_knockback_applies_hitstun() -> void:
	_player.apply_knockback(Vector2.RIGHT, 240.0, 0.25)
	assert_str(_player.get_current_state()).is_equal("hitstun")

func test_knockback_peak_velocity() -> void:
	_player.apply_knockback(Vector2.RIGHT, 240.0, 0.25)
	assert_float(_player.velocity.length()).is_equal_approx(240.0, 1.0)

func test_knockback_decays_over_time() -> void:
	_player.apply_knockback(Vector2.RIGHT, 240.0, 0.25)
	_player._physics_process(0.125)
	assert_float(_player.velocity.length()).is_less(240.0)

func test_knockback_ends_after_duration() -> void:
	_player.apply_knockback(Vector2.RIGHT, 240.0, 0.25)
	_player._physics_process(0.26)
	assert_str(_player.get_current_state()).is_equal("idle")

func test_new_knockback_overrides_old() -> void:
	_player.apply_knockback(Vector2.RIGHT, 150.0, 0.2)
	_player.apply_knockback(Vector2.LEFT, 360.0, 0.3)
	assert_float(_player.velocity.length()).is_equal_approx(360.0, 1.0)

func test_weaker_knockback_ignored() -> void:
	_player.apply_knockback(Vector2.RIGHT, 360.0, 0.3)
	_player.apply_knockback(Vector2.LEFT, 150.0, 0.2)
	assert_float(_player.velocity.length()).is_equal_approx(360.0, 1.0)

func test_knockback_direction_normalized() -> void:
	_player.apply_knockback(Vector2(2, 0), 240.0, 0.25)
	assert_float(_player.velocity.x).is_equal_approx(240.0, 1.0)
	assert_float(_player.velocity.y).is_equal_approx(0.0, 0.1)

func test_knockback_quadratic_decay() -> void:
	_player.apply_knockback(Vector2.RIGHT, 240.0, 0.25)
	_player._physics_process(0.125)
	var expected_decay := 1.0 - pow(0.5, 2.0)
	var expected_velocity := 240.0 * expected_decay
	assert_float(_player.velocity.length()).is_equal_approx(expected_velocity, 5.0)