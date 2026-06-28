class_name InkDrop
extends BaseEnemy

func _setup_enemy() -> void:
	_enemy_type = EnemyType.INK_DROP
	_health = 10.0
	_max_health = 10.0

func _update_movement(delta: float) -> void:
	if _target == null:
		return
	var direction := (_target.global_position - global_position).normalized()
	velocity = direction * _move_speed