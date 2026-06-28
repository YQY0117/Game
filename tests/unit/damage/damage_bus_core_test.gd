extends GdUnitTestSuite
class_name DamageBusCoreTest

var _bus: DamageBus
var _dealt_events: Array[DamageEvent]
var _death_events: Array[Array]

func before_test() -> void:
	_bus = DamageBus.new()
	_dealt_events = []
	_death_events = []
	_bus.damage_dealt.connect(_on_damage_dealt)
	_bus.entity_died.connect(_on_entity_died)

func after_test() -> void:
	_bus.damage_dealt.disconnect(_on_damage_dealt)
	_bus.entity_died.disconnect(_on_entity_died)
	_bus.free()

func _on_damage_dealt(event: DamageEvent) -> void:
	_dealt_events.append(event)

func _on_entity_died(victim_id: int, final_event: DamageEvent) -> void:
	_death_events.append([victim_id, final_event])

func test_damage_event_has_7_fields() -> void:
	var event := DamageEvent.new(100, 200, 50.0, "fire", 1, false, Vector2.ZERO)
	assert_int(event.attacker_id).is_equal(100)
	assert_int(event.victim_id).is_equal(200)
	assert_float(event.raw_damage).is_equal(50.0)
	assert_str(event.element).is_equal("fire")
	assert_int(event.knockback_tier).is_equal(1)
	assert_bool(event.is_crit).is_false()
	assert_vector(event.position).is_equal(Vector2.ZERO)

func test_deal_damage_queues_event() -> void:
	_bus.deal_damage(100, 200, 50.0, "fire", 1, false, Vector2.ZERO)
	assert_int(_bus._pending_events.size()).is_equal(1)

func test_flush_processes_events_in_order() -> void:
	_bus.deal_damage(300, 200, 50.0, "fire", 1, false, Vector2.ZERO)
	_bus.deal_damage(100, 200, 50.0, "fire", 1, false, Vector2.ZERO)
	_bus.deal_damage(200, 200, 50.0, "fire", 1, false, Vector2.ZERO)
	_bus.flush()
	assert_int(_dealt_events.size()).is_equal(3)
	assert_int(_dealt_events[0].attacker_id).is_equal(100)
	assert_int(_dealt_events[1].attacker_id).is_equal(200)
	assert_int(_dealt_events[2].attacker_id).is_equal(300)

func test_flush_clears_pending_events() -> void:
	_bus.deal_damage(100, 200, 50.0, "fire", 1, false, Vector2.ZERO)
	_bus.flush()
	assert_int(_bus._pending_events.size()).is_equal(0)

func test_entity_died_emitted_on_fatal_damage() -> void:
	_bus.deal_damage(100, 200, 100.0, "fire", 1, false, Vector2.ZERO)
	_bus.flush()
	assert_int(_death_events.size()).is_equal(1)
	assert_int(_death_events[0][0]).is_equal(200)

func test_entity_died_not_emitted_on_non_fatal_damage() -> void:
	_bus.deal_damage(100, 200, 50.0, "fire", 1, false, Vector2.ZERO)
	_bus.flush()
	assert_int(_death_events.size()).is_equal(0)

func test_deterministic_ordering_100_runs() -> void:
	for i in 100:
		_dealt_events.clear()
		_bus.deal_damage(300, 200, 50.0, "fire", 1, false, Vector2.ZERO)
		_bus.deal_damage(100, 200, 50.0, "fire", 1, false, Vector2.ZERO)
		_bus.deal_damage(200, 200, 50.0, "fire", 1, false, Vector2.ZERO)
		_bus.flush()
		assert_int(_dealt_events[0].attacker_id).is_equal(100)
		assert_int(_dealt_events[1].attacker_id).is_equal(200)
		assert_int(_dealt_events[2].attacker_id).is_equal(300)