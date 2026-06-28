class_name SluggishInk
extends BaseEnemy

const LERP_SPEED := 2.0

var _target_velocity: Vector2 = Vector2.ZERO

func _setup_enemy() -> void:
	_enemy_type = EnemyType.SLUGGISH_INK
	_health = 20.0
	_max_health = 20.0

func _update_movement(delta: float) -> void:
	if _target == null:
		return
	var direction := (_target.global_position - global_position).normalized()
	_target_velocity = direction * _move_speed
	velocity = velocity.lerp(_target_velocity, LERP_SPEED * delta)