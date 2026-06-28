extends GdUnitTestSuite
class_name HpElementTest

var _health: HealthComponent
var _hp_changes: Array[Array]
var _died_count: int
var _critical_entered_count: int
var _critical_exited_count: int

func before_test() -> void:
	_health = HealthComponent.new()
	_hp_changes = []
	_died_count = 0
	_critical_entered_count = 0
	_critical_exited_count = 0
	_health.hp_changed.connect(_on_hp_changed)
	_health.died.connect(_on_died)
	_health.critical_state_entered.connect(_on_critical_entered)
	_health.critical_state_exited.connect(_on_critical_exited)

func after_test() -> void:
	_health.hp_changed.disconnect(_on_hp_changed)
	_health.died.disconnect(_on_died)
	_health.critical_state_entered.disconnect(_on_critical_entered)
	_health.critical_state_exited.disconnect(_on_critical_exited)
	_health.free()

func _on_hp_changed(current_hp: int, max_hp: int) -> void:
	_hp_changes.append([current_hp, max_hp])

func _on_died() -> void:
	_died_count += 1

func _on_critical_entered() -> void:
	_critical_entered_count += 1

func _on_critical_exited() -> void:
	_critical_exited_count += 1

func test_max_hp_is_20() -> void:
	assert_int(_health.get_max_hp()).is_equal(20)

func test_initial_hp_is_20() -> void:
	assert_int(_health.get_current_hp()).is_equal(20)

func test_element_matrix_fire_ice() -> void:
	assert_float(_health.get_element_multiplier("fire", "ice")).is_equal(1.5)

func test_element_matrix_ice_fire() -> void:
	assert_float(_health.get_element_multiplier("ice", "fire")).is_equal(0.7)

func test_element_matrix_same_element() -> void:
	assert_float(_health.get_element_multiplier("fire", "fire")).is_equal(1.0)

func test_element_matrix_neutral() -> void:
	assert_float(_health.get_element_multiplier("fire", "none")).is_equal(1.0)

func test_take_damage_reduces_hp() -> void:
	var event := DamageEvent.new(100, 200, 5.0, "fire", 1, false, Vector2.ZERO)
	_health.take_damage(event)
	assert_int(_health.get_current_hp()).is_equal(15)

func test_take_damage_minimum_1() -> void:
	var event := DamageEvent.new(100, 200, 0.1, "fire", 1, false, Vector2.ZERO)
	_health.take_damage(event)
	assert_int(_health.get_current_hp()).is_equal(19)

func test_take_damage_maximum_20() -> void:
	var event := DamageEvent.new(100, 200, 100.0, "fire", 1, false, Vector2.ZERO)
	_health.take_damage(event)
	assert_int(_health.get_current_hp()).is_equal(0)

func test_died_emitted_at_zero_hp() -> void:
	var event := DamageEvent.new(100, 200, 20.0, "fire", 1, false, Vector2.ZERO)
	_health.take_damage(event)
	assert_int(_died_count).is_equal(1)
	assert_bool(_health.is_dead()).is_true()

func test_dead_state_prevents_damage() -> void:
	var event := DamageEvent.new(100, 200, 20.0, "fire", 1, false, Vector2.ZERO)
	_health.take_damage(event)
	_health.take_damage(event)
	assert_int(_health.get_current_hp()).is_equal(0)

func test_resurrect_restores_hp() -> void:
	var event := DamageEvent.new(100, 200, 20.0, "fire", 1, false, Vector2.ZERO)
	_health.take_damage(event)
	_health.resurrect()
	assert_int(_health.get_current_hp()).is_equal(20)
	assert_bool(_health.is_dead()).is_false()

func test_critical_state_at_25_percent() -> void:
	_health.take_damage(DamageEvent.new(100, 200, 15.0, "fire", 1, false, Vector2.ZERO))
	assert_bool(_health.is_critical()).is_true()
	assert_int(_critical_entered_count).is_equal(1)

func test_critical_state_exited() -> void:
	_health.take_damage(DamageEvent.new(100, 200, 15.0, "fire", 1, false, Vector2.ZERO))
	_health.resurrect()
	assert_bool(_health.is_critical()).is_false()
	assert_int(_critical_exited_count).is_equal(1)

func test_hp_changed_signal_emitted() -> void:
	var event := DamageEvent.new(100, 200, 5.0, "fire", 1, false, Vector2.ZERO)
	_health.take_damage(event)
	assert_int(_hp_changes.size()).is_equal(1)
	assert_int(_hp_changes[0][0]).is_equal(15)
	assert_int(_hp_changes[0][1]).is_equal(20)