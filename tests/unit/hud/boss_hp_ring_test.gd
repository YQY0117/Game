extends GdUnitTestSuite
class_name BossHpRingTest

var _hud: HUD

func before_test() -> void:
	_hud = HUD.new()

func after_test() -> void:
	_hud.free()

func test_boss_hp_bar_visible_on_update() -> void:
	_hud.update_boss_hp(80.0, 100.0)
	assert_bool(_hud._boss_hp_bar.visible).is_true()

func test_boss_hp_bar_hidden_on_hide() -> void:
	_hud.update_boss_hp(80.0, 100.0)
	_hud.hide_boss_hp()
	assert_bool(_hud._boss_hp_bar.visible).is_false()

func test_player_hp_critical_triggers_ring() -> void:
	_hud.update_player_hp(10.0, 100.0)
	assert_bool(_hud._is_hp_critical).is_true()
	assert_float(_hud._hp_ring_alpha).is_equal(0.85)

func test_player_hp_normal_hides_ring() -> void:
	_hud.update_player_hp(50.0, 100.0)
	assert_bool(_hud._is_hp_critical).is_false()
	assert_float(_hud._hp_ring_alpha).is_equal(0.0)

func test_hp_ring_pulse_updates() -> void:
	_hud.update_player_hp(10.0, 100.0)
	_hud._update_hp_ring_pulse(0.6)
	assert_float(_hud._hp_ring_alpha).is_greater(0.85)