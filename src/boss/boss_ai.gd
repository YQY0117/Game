class_name BossAI
extends BaseEnemy

signal state_changed(old_state: String, new_state: String)
signal phase_changed(new_phase: int)

enum BossState {
	SPAWNING,
	IDLE,
	TELEGRAPH,
	ATTACKING,
	RECOVERY,
	HITSTUN,
	PHASE_TRANSITION,
	DYING
}

const TELL_COLOR := Color("#B8403A")
const CLEARANCE_RADIUS_MULTIPLIER := 2.0

var _boss_state: BossState = BossState.SPAWNING
var _attack_patterns: Array[String] = ["melee", "ranged", "aoe"]
var _current_pattern: int = 0
var _phase: int = 1
var _attack_timer: float = 0.0
var _attack_interval: float = 4.0
var _telegraph_duration: float = 1.25
var _recovery_duration: float = 1.75
var _idle_timer: float = 0.0
var _idle_duration: float = 3.0
var _tell_progress: float = 0.0

func _setup_enemy() -> void:
	_enemy_type = EnemyType.INK_DROP
	_health = 100.0
	_max_health = 100.0
	_boss_state = BossState.SPAWNING

func _physics_process(delta: float) -> void:
	if _is_dead:
		return
	_update_boss_state(delta)
	_update_movement(delta)
	move_and_slide()

func _update_boss_state(delta: float) -> void:
	match _boss_state:
		BossState.SPAWNING:
			_update_spawning(delta)
		BossState.IDLE:
			_update_idle(delta)
		BossState.TELEGRAPH:
			_update_telegraph(delta)
		BossState.ATTACKING:
			_update_attacking(delta)
		BossState.RECOVERY:
			_update_recovery(delta)
		BossState.HITSTUN:
			_update_hitstun(delta)
		BossState.PHASE_TRANSITION:
			_update_phase_transition(delta)
		BossState.DYING:
			_update_dying(delta)

func _update_spawning(delta: float) -> void:
	_set_boss_state(BossState.IDLE)

func _update_idle(delta: float) -> void:
	_idle_timer += delta
	if _idle_timer >= _idle_duration:
		_idle_timer = 0.0
		_set_boss_state(BossState.TELEGRAPH)

func _update_telegraph(delta: float) -> void:
	_tell_progress += delta / _telegraph_duration
	if _tell_progress >= 1.0:
		_tell_progress = 0.0
		_set_boss_state(BossState.ATTACKING)

func _update_attacking(delta: float) -> void:
	_execute_attack()
	_set_boss_state(BossState.RECOVERY)

func _update_recovery(delta: float) -> void:
	_attack_timer += delta
	if _attack_timer >= _recovery_duration:
		_attack_timer = 0.0
		_current_pattern = (_current_pattern + 1) % _attack_patterns.size()
		_set_boss_state(BossState.IDLE)

func _update_hitstun(delta: float) -> void:
	_set_boss_state(BossState.IDLE)

func _update_phase_transition(delta: float) -> void:
	_set_boss_state(BossState.IDLE)

func _update_dying(delta: float) -> void:
	pass

func _set_boss_state(new_state: BossState) -> void:
	if _boss_state != new_state:
		var old_state_name := _get_boss_state_name()
		_boss_state = new_state
		state_changed.emit(old_state_name, _get_boss_state_name())

func _get_boss_state_name() -> String:
	match _boss_state:
		BossState.SPAWNING:
			return "spawning"
		BossState.IDLE:
			return "idle"
		BossState.TELEGRAPH:
			return "telegraph"
		BossState.ATTACKING:
			return "attacking"
		BossState.RECOVERY:
			return "recovery"
		BossState.HITSTUN:
			return "hitstun"
		BossState.PHASE_TRANSITION:
			return "phase_transition"
		BossState.DYING:
			return "dying"
	return "idle"

func _execute_attack() -> void:
	var pattern := _attack_patterns[_current_pattern]
	match pattern:
		"melee":
			_melee_attack()
		"ranged":
			_ranged_attack()
		"aoe":
			_aoe_attack()

func _melee_attack() -> void:
	push_warning("BossAI: _melee_attack() not implemented")

func _ranged_attack() -> void:
	push_warning("BossAI: _ranged_attack() not implemented")

func _aoe_attack() -> void:
	push_warning("BossAI: _aoe_attack() not implemented")

func take_damage(amount: float) -> void:
	_health -= amount
	if _health <= 0:
		_set_boss_state(BossState.DYING)
		die()
	elif _health <= _max_health * 0.5 and _phase == 1:
		_phase = 2
		_set_boss_state(BossState.PHASE_TRANSITION)
		phase_changed.emit(_phase)

func get_boss_state() -> String:
	return _get_boss_state_name()

func get_phase() -> int:
	return _phase

func get_tell_progress() -> float:
	return _tell_progress

func get_clearance_radius() -> float:
	return 50.0 * CLEARANCE_RADIUS_MULTIPLIER