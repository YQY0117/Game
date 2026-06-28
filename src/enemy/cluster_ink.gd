class_name ClusterInk
extends BaseEnemy

signal cluster_split(position: Vector2, count: int)

const SPLIT_COUNT_MIN := 3
const SPLIT_COUNT_MAX := 5

func _setup_enemy() -> void:
	_enemy_type = EnemyType.CLUSTER_INK
	_health = 25.0
	_max_health = 25.0

func _update_movement(delta: float) -> void:
	if _target == null:
		return
	var direction := (_target.global_position - global_position).normalized()
	velocity = direction * _move_speed

func die() -> void:
	var split_count := randi_range(SPLIT_COUNT_MIN, SPLIT_COUNT_MAX)
	cluster_split.emit(global_position, split_count)
	super()