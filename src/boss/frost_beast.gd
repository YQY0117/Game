class_name FrostBeast
extends BossAI

func _setup_enemy() -> void:
	_enemy_type = EnemyType.INK_DROP
	_health = 120.0
	_max_health = 120.0
	_attack_patterns = ["ice_rain", "frost_breath"]
	_attack_interval = 5.0

func _execute_attack() -> void:
	var pattern := _attack_patterns[_current_pattern]
	match pattern:
		"ice_rain":
			_ice_rain()
		"frost_breath":
			_frost_breath()

func _ice_rain() -> void:
	pass

func _frost_breath() -> void:
	pass