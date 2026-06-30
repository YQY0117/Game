extends Node

signal damage_dealt(event: DamageEvent)
signal entity_died(victim_id: int, final_event: DamageEvent)

var _pending_events: Array[DamageEvent] = []

func deal_damage(attacker_id: int, victim_id: int, raw_damage: float, element: String, knockback_tier: int, is_crit: bool, position: Vector2) -> void:
	var event := DamageEvent.new(attacker_id, victim_id, raw_damage, element, knockback_tier, is_crit, position)
	_pending_events.append(event)

func flush() -> void:
	_pending_events.sort_custom(_sort_by_attacker_id)
	for event in _pending_events:
		_process_damage(event)
	_pending_events.clear()

func _sort_by_attacker_id(a: DamageEvent, b: DamageEvent) -> bool:
	return a.attacker_id < b.attacker_id

func _process_damage(event: DamageEvent) -> void:
	damage_dealt.emit(event)
	if _is_fatal(event):
		entity_died.emit(event.victim_id, event)

func _is_fatal(event: DamageEvent) -> bool:
	return event.raw_damage >= 100.0
