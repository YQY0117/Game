class_name ThunderSwordsman
extends BossAI

func _setup_enemy() -> void:
	_enemy_type = EnemyType.INK_DROP
	_health = 100.0
	_max_health = 100.0
	_attack_patterns = ["thunder_slash", "blink_slash", "thunder_array"]
	_attack_interval = 3.5

func _execute_attack() -> void:
	var pattern := _attack_patterns[_current_pattern]
	match pattern:
		"thunder_slash":
			_thunder_slash()
		"blink_slash":
			_blink_slash()
		"thunder_array":
			_thunder_array()

func _thunder_slash() -> void:
	pass

func _blink_slash() -> void:
	pass

func _thunder_array() -> void:
	pass