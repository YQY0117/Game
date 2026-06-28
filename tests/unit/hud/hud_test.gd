extends GdUnitTestSuite
class_name HudTest

var _hud: HUD

func before_test() -> void:
	_hud = HUD.new()

func after_test() -> void:
	_hud.free()

func test_initial_alpha() -> void:
	assert_float(_hud.get_current_alpha()).is_equal(0.35)

func test_enter_combat_sets_target_alpha() -> void:
	_hud.enter_combat()
	assert_float(_hud._target_alpha).is_equal(1.0)

func test_exit_combat_starts_timer() -> void:
	_hud.exit_combat()
	assert_bool(_hud._is_post_combat).is_true()
	assert_float(_hud._post_combat_timer).is_equal(3.0)

func test_fade_updates_alpha() -> void:
	_hud.enter_combat()
	_hud._update_fade(0.1)
	assert_float(_hud.get_current_alpha()).is_greater(0.35)

func test_update_realm() -> void:
	_hud.update_realm("筑基")
	assert_str(_hud._realm_label.text).is_equal("筑基")

func test_update_spirit() -> void:
	_hud.update_spirit(50.0, 100.0)
	assert_float(_hud._spirit_bar.value).is_equal(50.0)

func test_update_boss_hp() -> void:
	_hud.update_boss_hp(80.0, 100.0)
	assert_float(_hud._boss_hp_bar.value).is_equal(80.0)
	assert_bool(_hud._boss_hp_bar.visible).is_true()

func test_hide_boss_hp() -> void:
	_hud.update_boss_hp(80.0, 100.0)
	_hud.hide_boss_hp()
	assert_bool(_hud._boss_hp_bar.visible).is_false()