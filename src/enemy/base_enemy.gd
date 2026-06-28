class_name BaseEnemy
extends CharacterBody2D

signal died(enemy: BaseEnemy)

enum EnemyType {
	INK_DROP,
	SCATTERED_INK,
	SLUGGISH_INK,
	FLYING_INK,
	CLUSTER_INK
}

const SPEED_RATIOS := {
	EnemyType.INK_DROP: 0.7,
	EnemyType.SCATTERED_INK: 0.85,
	EnemyType.SLUGGISH_INK: 0.55,
	EnemyType.FLYING_INK: 0.65,
	EnemyType.CLUSTER_INK: 0.6
}

const LOD_FAR_DISTANCE := 1200.0
const LOD_MID_DISTANCE := 600.0

var _enemy_type: EnemyType
var _target: PlayerController
var _base_speed: float = 100.0
var _move_speed: float = 70.0
var _health: float = 10.0
var _max_health: float = 10.0
var _is_dead: bool = false
var _lod_frame_counter: int = 0
var _lod_tick_rate: int = 1

func _ready() -> void:
	_setup_enemy()

func _setup_enemy() -> void:
	pass

func _physics_process(delta: float) -> void:
	if _is_dead or _target == null:
		return
	_update_lod()
	if _lod_frame_counter % _lod_tick_rate != 0:
		return
	_update_movement(delta)
	move_and_slide()

func _update_movement(delta: float) -> void:
	pass

func set_target(target: PlayerController) -> void:
	_target = target

func set_enemy_type(type: EnemyType) -> void:
	_enemy_type = type
	_move_speed = _base_speed * SPEED_RATIOS.get(type, 0.7)

func take_damage(amount: float) -> void:
	_health -= amount
	if _health <= 0:
		die()

func die() -> void:
	_is_dead = true
	died.emit(self)
	queue_free()

func get_enemy_type() -> EnemyType:
	return _enemy_type

func get_health() -> float:
	return _health

func is_dead() -> bool:
	return _is_dead

func _update_lod() -> void:
	_lod_frame_counter += 1
	if _target == null:
		return
	var distance := global_position.distance_to(_target.global_position)
	if distance > LOD_FAR_DISTANCE:
		_lod_tick_rate = 4
	elif distance > LOD_MID_DISTANCE:
		_lod_tick_rate = 2
	else:
		_lod_tick_rate = 1