class_name InputManager
extends Node

signal input_mode_changed(new_mode: String)
signal input_idle()

const MODE_SWITCH_MIN_EVENTS := 3
const MODE_SWITCH_MIN_DURATION_MS := 400
const EXTRA_COOLDOWN_TO_TOUCH_MS := 200

const DEAD_ZONE_TOUCH := 0.10
const DEAD_ZONE_GAMEPAD := 0.15
const RESPONSE_CURVE_TOUCH := 1.5
const RESPONSE_CURVE_GAMEPAD := 1.0
const JOYSTICK_RESET_MS := 100
const JOYSTICK_RADIUS := 100.0
const IDLE_THRESHOLD_MS := 50

var _current_mode: String = "kbm"
var _consecutive_events: int = 0
var _continuous_duration: float = 0.0
var _last_event_time: float = 0.0
var _pending_device: String = ""
var _config: Dictionary = {}
var _joystick_center: Vector2 = Vector2.ZERO
var _joystick_active: bool = false
var _primary_touch_index: int = -1
var _last_touch_release_time: float = 0.0
var _idle_timer: float = 0.0
var _was_idle: bool = false

func _ready() -> void:
	_load_config()
	_setup_focus_handling()

func _setup_focus_handling() -> void:
	get_tree().auto_accept_quit = false
	get_tree().notification_handler = _on_notification

func _load_config() -> void:
	var config_path := "res://data/input_config.json"
	if FileAccess.file_exists(config_path):
		var file := FileAccess.open(config_path, FileAccess.READ)
		if file:
			var json := JSON.new()
			var error := json.parse(file.get_as_text())
			if error == OK:
				_config = json.data
				_apply_config()

func _apply_config() -> void:
	if _config.has("dead_zones"):
		if _config["dead_zones"].has("touch"):
			_dead_zone_touch = _config["dead_zones"]["touch"]
		if _config["dead_zones"].has("gamepad"):
			_dead_zone_gamepad = _config["dead_zones"]["gamepad"]
	if _config.has("response_curves"):
		if _config["response_curves"].has("touch"):
			_response_curve_touch = _config["response_curves"]["touch"]
		if _config["response_curves"].has("gamepad"):
			_response_curve_gamepad = _config["response_curves"]["gamepad"]

var _dead_zone_touch: float = DEAD_ZONE_TOUCH
var _dead_zone_gamepad: float = DEAD_ZONE_GAMEPAD
var _response_curve_touch: float = RESPONSE_CURVE_TOUCH
var _response_curve_gamepad: float = RESPONSE_CURVE_GAMEPAD

func get_movement_vector() -> Vector2:
	var raw := Input.get_vector(
		InputActions.MOVE_LEFT,
		InputActions.MOVE_RIGHT,
		InputActions.MOVE_UP,
		InputActions.MOVE_DOWN
	)
	return _apply_deadzone_and_curve(raw)

func _apply_deadzone_and_curve(raw: Vector2) -> Vector2:
	if raw.length() < 0.001:
		return Vector2.ZERO
	
	var dead_zone: float
	var curve_power: float
	
	match _current_mode:
		"touch":
			dead_zone = _dead_zone_touch
			curve_power = _response_curve_touch
		"gamepad":
			dead_zone = _dead_zone_gamepad
			curve_power = _response_curve_gamepad
		_:
			return raw.normalized()
	
	if raw.length() < dead_zone:
		return Vector2.ZERO
	
	var m := clampf((raw.length() - dead_zone) / (1.0 - dead_zone), 0.0, 1.0)
	return raw.normalized() * pow(m, curve_power)

func is_action_pressed(action: String) -> bool:
	return Input.is_action_pressed(action)

func get_current_mode() -> String:
	return _current_mode

func _unhandled_input(event: InputEvent) -> void:
	var device := _classify_device(event)
	if device.is_empty():
		return
	
	if device == "touch":
		_handle_touch_event(event)
	
	var now := Time.get_ticks_msec() / 1000.0
	if device == _pending_device:
		if _last_event_time > 0.0 and (now - _last_event_time) < 0.2:
			_consecutive_events += 1
		else:
			_consecutive_events = 1
		if _last_event_time > 0.0:
			_continuous_duration += (now - _last_event_time) * 1000.0
		else:
			_continuous_duration = 0.0
	else:
		_pending_device = device
		_consecutive_events = 1
		_continuous_duration = 0.0
	_last_event_time = now
	_try_switch_mode()

func _classify_device(event: InputEvent) -> String:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		return "touch"
	if event is InputEventKey or event is InputEventMouse or event is InputEventMouseButton:
		return "kbm"
	if event is InputEventJoypadMotion or event is InputEventJoypadButton:
		return "gamepad"
	return ""

func _try_switch_mode() -> void:
	if _pending_device == _current_mode:
		return
	var threshold_ms := MODE_SWITCH_MIN_DURATION_MS
	if _pending_device == "touch":
		threshold_ms += EXTRA_COOLDOWN_TO_TOUCH_MS
	var should_switch := _consecutive_events >= MODE_SWITCH_MIN_EVENTS or _continuous_duration >= threshold_ms
	if should_switch:
		_current_mode = _pending_device
		_consecutive_events = 0
		_continuous_duration = 0.0
		input_mode_changed.emit(_current_mode)

func _physics_process(delta: float) -> void:
	var movement := get_movement_vector()
	if movement.length() < 0.001:
		_idle_timer += delta * 1000.0
		if _idle_timer >= IDLE_THRESHOLD_MS and not _was_idle:
			_was_idle = true
			input_idle.emit()
	else:
		_idle_timer = 0.0
		_was_idle = false

func _handle_touch_event(event: InputEvent) -> void:
	var now := Time.get_ticks_msec() / 1000.0
	
	if event is InputEventScreenTouch:
		if event.pressed:
			if _primary_touch_index == -1:
				if event.position.x < get_viewport().get_visible_rect().size.x / 2.0:
					_primary_touch_index = event.index
					_joystick_center = event.position
					_joystick_active = true
		else:
			if event.index == _primary_touch_index:
				_primary_touch_index = -1
				_joystick_active = false
				_last_touch_release_time = now
	
	if event is InputEventScreenDrag and _joystick_active:
		if event.index == _primary_touch_index:
			var delta := event.position - _joystick_center
			if delta.length() > JOYSTICK_RADIUS:
				delta = delta.normalized() * JOYSTICK_RADIUS
			var raw := delta / JOYSTICK_RADIUS
			_touch_joystick_vector = _apply_deadzone_and_curve(raw)

var _touch_joystick_vector: Vector2 = Vector2.ZERO

func get_touch_joystick_vector() -> Vector2:
	return _touch_joystick_vector

func _on_notification(what: int) -> void:
	if what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT:
		_reset_all_input()

func _reset_all_input() -> void:
	_touch_joystick_vector = Vector2.ZERO
	_joystick_active = false
	_primary_touch_index = -1
	_idle_timer = 0.0
	_was_idle = false
