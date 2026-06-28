class_name FlameElder
extends BossAI

func _setup_enemy() -> void:
	_enemy_type = EnemyType.INK_DROP
	_health = 80.0
	_max_health = 80.0
	_attack_patterns = ["fire_barrage", "flame_dash", "flame_burst"]
	_attack_interval = 4.0

func _execute_attack() -> void:
	var pattern := _attack_patterns[_current_pattern]
	match pattern:
		"fire_barrage":
			_fire_barrage()
		"flame_dash":
			_flame_dash()
		"flame_burst":
			_flame_burst()

func _fire_barrage() -> void:
	push_warning("FlameElder: _fire_barrage() not implemented")

func _flame_dash() -> void:
	push_warning("FlameElder: _flame_dash() not implemented")

func _flame_burst() -> void:
	push_warning("FlameElder: _flame_burst() not implemented")