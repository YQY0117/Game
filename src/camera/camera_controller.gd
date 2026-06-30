class_name CameraController
extends Camera2D

const FOLLOW_RATE := 10.0
const DEAD_ZONE := 32.0
const SHAKE_TOTAL_CLAMP := 30.0

const KNOCKBACK_SHAKE_MAGNITUDES := [2.0, 4.0, 7.0, 12.0, 18.0]
const KNOCKBACK_SHAKE_DURATIONS := [0.100, 0.130, 0.160, 0.200, 0.250]
const ZOOM_DURATION := 0.4
const ZOOM_MIN := 0.8
const ZOOM_MAX := 1.2
const HARD_FOLLOW_MARGIN_X := 80.0
const HARD_FOLLOW_MARGIN_Y := 120.0

var _target: PlayerController
var _shake_offset: Vector2 = Vector2.ZERO
var _shake_timer: float = 0.0
var _shake_magnitude: float = 0.0
var _shake_duration: float = 0.0
var _is_frozen: bool = false
var _zoom_from: float = 1.0
var _zoom_to: float = 1.0
var _zoom_timer: float = 0.0
var _zoom_duration: float = 0.0

func _ready() -> void:
	_setup_camera()

func _setup_camera() -> void:
	position_smoothing_enabled = false
	position_smoothing_speed = 0.0

func set_target(target: PlayerController) -> void:
	_target = target

func _physics_process(delta: float) -> void:
	if _is_frozen or _target == null:
		return
	
	_update_follow(delta)
	_update_shake(delta)
	_update_zoom(delta)
	_apply_position()

func _update_follow(delta: float) -> void:
	var target_pos := _target.global_position
	var camera_pos := global_position
	var distance := camera_pos.distance_to(target_pos)
	
	if distance < DEAD_ZONE:
		return
	
	var viewport_size := get_viewport_rect().size
	var half_w := viewport_size.x / 2.0
	var half_h := viewport_size.y / 2.0
	
	var dx: float = abs(target_pos.x - camera_pos.x)
	var dy: float = abs(target_pos.y - camera_pos.y)
	
	if dx > half_w - HARD_FOLLOW_MARGIN_X or dy > half_h - HARD_FOLLOW_MARGIN_Y:
		global_position = target_pos.round()
		return
	
	var alpha := 1.0 - exp(-FOLLOW_RATE * delta)
	var new_pos := camera_pos.lerp(target_pos, alpha)
	global_position = new_pos.round()

func _update_shake(delta: float) -> void:
	if _shake_timer > 0.0:
		_shake_timer -= delta
		var progress := 1.0 - (_shake_timer / _shake_duration)
		var decay := pow(1.0 - progress, 3.0)
		_shake_offset = Vector2(
			randf_range(-_shake_magnitude, _shake_magnitude) * decay,
			randf_range(-_shake_magnitude, _shake_magnitude) * decay
		)
	else:
		_shake_offset = Vector2.ZERO

func _update_zoom(delta: float) -> void:
	if _zoom_timer > 0.0:
		_zoom_timer -= delta
		var progress := 1.0 - (_zoom_timer / _zoom_duration)
		var cubic_progress: float = cubic_interpolate(0.0, 1.0, progress, progress, progress)
		var current_zoom: float = lerpf(_zoom_from, _zoom_to, cubic_progress)
		zoom = Vector2(current_zoom, current_zoom)
	else:
		zoom = Vector2(_zoom_to, _zoom_to)

func _apply_position() -> void:
	offset = _shake_offset

func shake(magnitude: float, duration: float) -> void:
	_shake_magnitude = magnitude
	_shake_duration = duration
	_shake_timer = duration

func knockback_shake(tier: int) -> void:
	var index := clampi(tier, 0, 4)
	shake(KNOCKBACK_SHAKE_MAGNITUDES[index], KNOCKBACK_SHAKE_DURATIONS[index])

func freeze() -> void:
	_is_frozen = true

func unfreeze() -> void:
	_is_frozen = false

func snap_to(pos: Vector2) -> void:
	global_position = pos.round()
	_shake_offset = Vector2.ZERO
	_shake_timer = 0.0

func zoom_to(target_zoom: float, duration: float = ZOOM_DURATION) -> void:
	_zoom_from = zoom.x
	_zoom_to = clampf(target_zoom, ZOOM_MIN, ZOOM_MAX)
	_zoom_timer = duration
	_zoom_duration = duration

func clear_shake() -> void:
	_shake_offset = Vector2.ZERO
	_shake_timer = 0.0
	_shake_magnitude = 0.0
	_shake_duration = 0.0