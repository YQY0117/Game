extends GdUnitTestSuite
class_name BossMvpTest

var _flame_elder: FlameElder
var _frost_beast: FrostBeast
var _thunder_swordsman: ThunderSwordsman
var _guardian: Guardian

func before_test() -> void:
	_flame_elder = FlameElder.new()
	_flame_elder._setup_enemy()
	_frost_beast = FrostBeast.new()
	_frost_beast._setup_enemy()
	_thunder_swordsman = ThunderSwordsman.new()
	_thunder_swordsman._setup_enemy()
	_guardian = Guardian.new()
	_guardian._setup_enemy()

func after_test() -> void:
	_flame_elder.free()
	_frost_beast.free()
	_thunder_swordsman.free()
	_guardian.free()

func test_flame_elder_health() -> void:
	assert_float(_flame_elder.get_health()).is_equal(80.0)

func test_frost_beast_health() -> void:
	assert_float(_frost_beast.get_health()).is_equal(120.0)

func test_thunder_swordsman_health() -> void:
	assert_float(_thunder_swordsman.get_health()).is_equal(100.0)

func test_guardian_health() -> void:
	assert_float(_guardian.get_health()).is_equal(150.0)

func test_flame_elder_attack_patterns() -> void:
	assert_int(_flame_elder._attack_patterns.size()).is_equal(3)
	assert_str(_flame_elder._attack_patterns[0]).is_equal("fire_barrage")

func test_frost_beast_attack_patterns() -> void:
	assert_int(_frost_beast._attack_patterns.size()).is_equal(2)
	assert_str(_frost_beast._attack_patterns[0]).is_equal("ice_rain")

func test_thunder_swordsman_attack_patterns() -> void:
	assert_int(_thunder_swordsman._attack_patterns.size()).is_equal(3)
	assert_str(_thunder_swordsman._attack_patterns[0]).is_equal("thunder_slash")

func test_guardian_attack_patterns() -> void:
	assert_int(_guardian._attack_patterns.size()).is_equal(2)
	assert_str(_guardian._attack_patterns[0]).is_equal("earthquake")

func test_phase_transition_at_50_percent() -> void:
	_flame_elder._health = 40.0
	_flame_elder._phase = 1
	_flame_elder.take_damage(0.0)
	assert_int(_flame_elder.get_phase()).is_equal(2)