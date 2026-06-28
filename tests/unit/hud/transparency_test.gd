extends GdUnitTestSuite
class_name TransparencyTest

var _hud: HUD

func before_test() -> void:
	_hud = HUD.new()

func after_test() -> void:
	_hud.free()

func test_idle_alpha() -> void:
	assert_float(_hud.get_current_alpha()).is_equal(0.35)

func test_combat_fade_in() -> void:
	_hud.enter_combat()
	_hud._update_fade(0.2)
	assert_float(_hud.get_current_alpha()).is_equal_approx(1.0, 0.01)

func test_post_combat_delay() -> void:
	_hud.exit_combat()
	assert_bool(_hud._is_post_combat).is_true()
	assert_float(_hud._post_combat_timer).is_equal(3.0)

func test_post_combat_fade_out() -> void:
	_hud.exit_combat()
	_hud._update_post_combat(3.1)
	assert_bool(_hud._is_post_combat).is_false()
	assert_float(_hud._target_alpha).is_equal(0.35)

func test_fade_updates_alpha() -> void:
	_hud.enter_combat()
	_hud._update_fade(0.1)
	assert_float(_hud.get_current_alpha()).is_greater(0.35)
	assert_float(_hud.get_current_alpha()).is_less(1.0)