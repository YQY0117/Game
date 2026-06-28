class_name HealthComponent
extends Node

signal hp_changed(current_hp: int, max_hp: int)
signal died()
signal critical_state_entered()
signal critical_state_exited()

const MAX_HP := 20
const CRITICAL_THRESHOLD := 0.25
const I_FRAME_DURATION_MS := 600

var _current_hp: int = MAX_HP
var _is_dead: bool = false
var _is_critical: bool = false
var _i_frame_end_time: int = 0
var _element_mult_matrix: Dictionary = {}

func _ready() -> void:
	_init_element_matrix()

func _init_element_matrix() -> void:
	var elements := ["fire", "ice", "wind", "lightning", "sword", "fist"]
	for attacker in elements:
		_element_mult_matrix[attacker] = {}
		for defender in elements:
			_element_mult_matrix[attacker][defender] = 1.0
	
	_element_mult_matrix["fire"]["ice"] = 1.5
	_element_mult_matrix["ice"]["fire"] = 0.7
	_element_mult_matrix["ice"]["lightning"] = 1.5
	_element_mult_matrix["lightning"]["ice"] = 0.7
	_element_mult_matrix["lightning"]["wind"] = 1.5
	_element_mult_matrix["wind"]["lightning"] = 0.7
	_element_mult_matrix["wind"]["fire"] = 1.5
	_element_mult_matrix["fire"]["wind"] = 0.7

func get_element_multiplier(attacker_element: String, defender_element: String) -> float:
	if _element_mult_matrix.has(attacker_element) and _element_mult_matrix[attacker_element].has(defender_element):
		return _element_mult_matrix[attacker_element][defender_element]
	return 1.0

func take_damage(event: DamageEvent) -> void:
	if _is_dead:
		return
	if _is_in_i_frame():
		return
	
	var element_mult := get_element_multiplier(event.element, "none")
	var final_damage := roundi(event.raw_damage * element_mult)
	final_damage = clampi(final_damage, 1, MAX_HP)
	
	_current_hp -= final_damage
	_current_hp = clampi(_current_hp, 0, MAX_HP)
	
	_start_i_frame()
	_update_critical_state()
	hp_changed.emit(_current_hp, MAX_HP)
	
	if _current_hp <= 0:
		_is_dead = true
		died.emit()

func _is_in_i_frame() -> bool:
	return Time.get_ticks_msec() < _i_frame_end_time

func _start_i_frame() -> void:
	_i_frame_end_time = Time.get_ticks_msec() + I_FRAME_DURATION_MS

func _update_critical_state() -> void:
	var hp_ratio := float(_current_hp) / float(MAX_HP)
	var was_critical := _is_critical
	_is_critical = hp_ratio <= CRITICAL_THRESHOLD
	
	if _is_critical and not was_critical:
		critical_state_entered.emit()
	elif not _is_critical and was_critical:
		critical_state_exited.emit()

func resurrect() -> void:
	_is_dead = false
	_current_hp = MAX_HP
	_is_critical = false
	hp_changed.emit(_current_hp, MAX_HP)

func get_current_hp() -> int:
	return _current_hp

func get_max_hp() -> int:
	return MAX_HP

func is_dead() -> bool:
	return _is_dead

func is_critical() -> bool:
	return _is_critical