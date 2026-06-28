class_name PlayerController
extends CharacterBody2D

signal position_changed(new_pos: Vector2)
signal velocity_changed(new_vel: Vector2)
signal state_changed(new_state: String)
signal realm_transitioned(new_realm: int)

enum State {
	IDLE,
	RUNNING,
	HITSTUN,
	IMMOBILE
}

const BASE_SPEED_R1 := 88.0
const BASE_SPEED_R6 := 124.0
const ACCEL_TIME := 0.060
const DECEL_TIME := 0.030
const REALM_COUNT := 6
const CLEARANCE_RADIUS_TABLE := [16.0, 22.4, 32.0, 41.6, 52.8, 64.0]

var _current_state: State = State.IDLE
var _current_realm: int = 1
var _base_speed: float = BASE_SPEED_R1
var _clearance_radius: float = CLEARANCE_RADIUS_TABLE[0]
var _move_input: Vector2 = Vector2.ZERO
var _accel_timer: float = 0.0
var _decel_timer: float = 0.0
var _last_velocity: Vector2 = Vector2.ZERO
var _knockback_velocity: Vector2 = Vector2.ZERO
var _knockback_timer: float = 0.0
var _knockback_force: float = 0.0
var _knockback_duration: float = 0.0
var _is_immobile: bool = false

func _ready() -> void:
	_update_base_speed()

func _physics_process(delta: float) -> void:
	if _is_immobile:
		velocity = Vector2.ZERO
		move_and_slide()
		_emit_signals()
		return
	
	if _knockback_timer > 0.0:
		_knockback_timer -= delta
		var progress := 1.0 - (_knockback_timer / _knockback_duration)
		var decay := 1.0 - pow(progress, 2.0)
		velocity = _knockback_velocity * decay
		move_and_slide()
		_emit_signals()
		return
	
	_move_input = InputManager.get_movement_vector()
	
	if _move_input.length() > 0.01:
		_set_state(State.RUNNING)
		_accel_timer += delta
		_decel_timer = 0.0
		var speed_factor := _calculate_accel_factor(_accel_timer)
		velocity = _move_input * _base_speed * speed_factor
	else:
		if _current_state == State.RUNNING:
			_decel_timer += delta
			_accel_timer = 0.0
			var decel_factor := _calculate_decel_factor(_decel_timer)
			velocity = _last_velocity * decel_factor
			if decel_factor < 0.01:
				velocity = Vector2.ZERO
				_set_state(State.IDLE)
				_decel_timer = 0.0
		else:
			velocity = Vector2.ZERO
			_accel_timer = 0.0
	
	move_and_slide()
	_emit_signals()

func _set_state(new_state: State) -> void:
	if _current_state != new_state:
		_current_state = new_state
		state_changed.emit(_get_state_name())

func _get_state_name() -> String:
	match _current_state:
		State.IDLE:
			return "idle"
		State.RUNNING:
			return "running"
		State.HITSTUN:
			return "hitstun"
		State.IMMOBILE:
			return "immobile"
	return "idle"

func _calculate_accel_factor(t: float) -> float:
	var ratio := clampf(t / ACCEL_TIME, 0.0, 1.0)
	return 1.0 - pow(1.0 - ratio, 3.0)

func _calculate_decel_factor(t: float) -> float:
	var ratio := clampf(t / DECEL_TIME, 0.0, 1.0)
	return 1.0 - pow(ratio, 2.0)

func _emit_signals() -> void:
	if position != _last_velocity:
		position_changed.emit(global_position)
	if velocity != _last_velocity:
		velocity_changed.emit(velocity)
	_last_velocity = velocity

func _update_base_speed() -> void:
	var k := 1.8
	var log_max := log(1.0 + k * 5.0)
	_base_speed = BASE_SPEED_R1 + (BASE_SPEED_R6 - BASE_SPEED_R1) * log(1.0 + k * (_current_realm - 1.0)) / log_max
	_clearance_radius = CLEARANCE_RADIUS_TABLE[_current_realm - 1]

func set_realm(new_realm: int) -> void:
	_current_realm = clampi(new_realm, 1, REALM_COUNT)
	_update_base_speed()
	realm_transitioned.emit(_current_realm)

func apply_knockback(direction: Vector2, force: float, duration: float) -> void:
	if _current_state == State.HITSTUN:
		if force <= _knockback_force:
			return
	_set_state(State.HITSTUN)
	_knockback_velocity = direction.normalized() * force
	_knockback_timer = duration
	_knockback_duration = duration
	_knockback_force = force

func set_immobile(immobile: bool) -> void:
	_is_immobile = immobile
	if immobile:
		_set_state(State.IMMOBILE)
		_knockback_timer = 0.0
		_knockback_velocity = Vector2.ZERO
	else:
		_set_state(State.IDLE)

func teleport_to(pos: Vector2) -> void:
	global_position = pos
	velocity = Vector2.ZERO
	_knockback_velocity = Vector2.ZERO
	_knockback_timer = 0.0
	_accel_timer = 0.0
	_decel_timer = 0.0
	_set_state(State.IDLE)

func get_current_state() -> String:
	return _get_state_name()

func get_current_realm() -> int:
	return _current_realm

func get_base_speed() -> float:
	return _base_speed

func get_clearance_radius() -> float:
	return _clearance_radius

func is_moving() -> bool:
	return velocity.length() > 0.01

func movement_intensity() -> float:
	if _base_speed <= 0.0:
		return 0.0
	return clampf(velocity.length() / _base_speed, 0.0, 1.0)

func is_in_knockback() -> bool:
	return _knockback_timer > 0.0