extends GdUnitTestSuite
class_name BossStateMachineTest

var _boss: BossAI

func before_test() -> void:
	_boss = BossAI.new()

func after_test() -> void:
	_boss.free()

func test_initial_state_is_spawning() -> void:
	assert_str(_boss.get_boss_state()).is_equal("spawning")

func test_spawning_transitions_to_idle() -> void:
	_boss._update_spawning(0.016)
	assert_str(_boss.get_boss_state()).is_equal("idle")

func test_idle_transitions_to_telegraph() -> void:
	_boss._set_boss_state(BossAI.BossState.IDLE)
	_boss._idle_timer = 3.0
	_boss._update_idle(0.016)
	assert_str(_boss.get_boss_state()).is_equal("telegraph")

func test_telegraph_transitions_to_attacking() -> void:
	_boss._set_boss_state(BossAI.BossState.TELEGRAPH)
	_boss._tell_progress = 1.0
	_boss._update_telegraph(0.016)
	assert_str(_boss.get_boss_state()).is_equal("attacking")

func test_attacking_transitions_to_recovery() -> void:
	_boss._set_boss_state(BossAI.BossState.ATTACKING)
	_boss._update_attacking(0.016)
	assert_str(_boss.get_boss_state()).is_equal("recovery")

func test_recovery_transitions_to_idle() -> void:
	_boss._set_boss_state(BossAI.BossState.RECOVERY)
	_boss._attack_timer = 1.75
	_boss._update_recovery(0.016)
	assert_str(_boss.get_boss_state()).is_equal("idle")

func test_state_change_signal() -> void:
	var state_changes: Array[String] = []
	_boss.state_changed.connect(func(old, new): state_changes.append(new))
	_boss._set_boss_state(BossAI.BossState.IDLE)
	assert_int(state_changes.size()).is_equal(1)
	assert_str(state_changes[0]).is_equal("idle")

func test_tell_color() -> void:
	assert_color(BossAI.TELL_COLOR).is_equal(Color("#B8403A"))

func test_clearance_radius_multiplier() -> void:
	assert_float(_boss.get_clearance_radius()).is_equal(100.0)

func test_phase_change_on_low_health() -> void:
	_boss._health = 50.0
	_boss._max_health = 100.0
	_boss._phase = 1
	_boss.take_damage(0.0)
	assert_int(_boss.get_phase()).is_equal(2)

func test_dying_state_on_zero_health() -> void:
	_boss.take_damage(100.0)
	assert_str(_boss.get_boss_state()).is_equal("dying")