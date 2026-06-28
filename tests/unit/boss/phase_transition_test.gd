extends GdUnitTestSuite
class_name PhaseTransitionTest

var _boss: BossAI

func before_test() -> void:
	_boss = BossAI.new()
	_boss._max_health = 100.0
	_boss._health = 100.0
	_boss._attack_interval = 4.0

func after_test() -> void:
	_boss.free()

func test_phase2_at_50_percent() -> void:
	_boss._health = 50.0
	_boss.take_damage(0.0)
	assert_int(_boss.get_phase()).is_equal(2)

func test_phase3_at_25_percent() -> void:
	_boss._health = 25.0
	_boss.take_damage(0.0)
	assert_int(_boss.get_phase()).is_equal(3)

func test_phase2_attack_speed_increase() -> void:
	_boss._health = 50.0
	_boss.take_damage(0.0)
	assert_float(_boss._attack_interval).is_equal_approx(3.2, 0.01)

func test_phase3_attack_speed_increase() -> void:
	_boss._health = 25.0
	_boss.take_damage(0.0)
	assert_float(_boss._attack_interval).is_equal_approx(2.4, 0.01)

func test_phase_change_signal() -> void:
	var phase_changes: Array[int] = []
	_boss.phase_changed.connect(func(phase): phase_changes.append(phase))
	_boss._health = 50.0
	_boss.take_damage(0.0)
	assert_int(phase_changes.size()).is_equal(1)
	assert_int(phase_changes[0]).is_equal(2)

func test_no_phase_change_above_50() -> void:
	_boss._health = 60.0
	_boss.take_damage(0.0)
	assert_int(_boss.get_phase()).is_equal(1)