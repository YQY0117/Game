class_name ScatteredInk
extends BaseEnemy

const SINE_FREQUENCY := 2.0
const SINE_STRENGTH := 50.0

var _time: float = 0.0

func _setup_enemy() -> void:
	_enemy_type = EnemyType.SCATTERED_INK
	_health = 12.0
	_max_health = 12.0

func _update_movement(delta: float) -> void:
	if _target == null:
		return
	_time += delta
	var seek_dir := (_target.global_position - global_position).normalized()
	var perpendicular := Vector2(-seek_dir.y, seek_dir.x)
	var sine_offset := perpendicular * sin(_time * SINE_FREQUENCY) * SINE_STRENGTH
	velocity = (seek_dir * _move_speed + sine_offset).normalized() * _move_speed