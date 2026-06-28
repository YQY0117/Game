class_name FlyingInk
extends BaseEnemy

const STAY_DISTANCE_MIN := 200.0
const STAY_DISTANCE_MAX := 400.0
const PROJECTILE_INTERVAL := 2.0

var _projectile_timer: float = 0.0

func _setup_enemy() -> void:
	_enemy_type = EnemyType.FLYING_INK
	_health = 15.0
	_max_health = 15.0

func _update_movement(delta: float) -> void:
	if _target == null:
		return
	var distance := global_position.distance_to(_target.global_position)
	var direction := (_target.global_position - global_position).normalized()
	
	if distance < STAY_DISTANCE_MIN:
		velocity = -direction * _move_speed
	elif distance > STAY_DISTANCE_MAX:
		velocity = direction * _move_speed
	else:
		var perpendicular := Vector2(-direction.y, direction.x)
		velocity = perpendicular * _move_speed * 0.5
	
	_projectile_timer += delta
	if _projectile_timer >= PROJECTILE_INTERVAL:
		_projectile_timer = 0.0
		_fire_projectile()

func _fire_projectile() -> void:
	pass