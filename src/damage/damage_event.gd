class_name DamageEvent
extends RefCounted

var attacker_id: int
var victim_id: int
var raw_damage: float
var element: String
var knockback_tier: int
var is_crit: bool
var position: Vector2

func _init(p_attacker_id: int, p_victim_id: int, p_raw_damage: float, p_element: String, p_knockback_tier: int, p_is_crit: bool, p_position: Vector2) -> void:
	attacker_id = p_attacker_id
	victim_id = p_victim_id
	raw_damage = p_raw_damage
	element = p_element
	knockback_tier = p_knockback_tier
	is_crit = p_is_crit
	position = p_position