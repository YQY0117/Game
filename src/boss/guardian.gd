class_name Guardian
extends BossAI

func _setup_enemy() -> void:
	_enemy_type = EnemyType.INK_DROP
	_health = 150.0
	_max_health = 150.0
	_attack_patterns = ["earthquake", "ink_tide"]
	_attack_interval = 5.5

func _execute_attack() -> void:
	var pattern := _attack_patterns[_current_pattern]
	match pattern:
		"earthquake":
			_earthquake()
		"ink_tide":
			_ink_tide()

func _earthquake() -> void:
	pass

func _ink_tide() -> void:
	pass