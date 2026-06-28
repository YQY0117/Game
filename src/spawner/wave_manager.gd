class_name WaveManager
extends Node

signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal boss_spawned(boss: BaseEnemy)

const WAVES_PER_REALM := 5
const WAVE_REST_TIME := 3.0
const BOSS_SPAWN_DELAY := 2.0
const SPAWN_DISTANCE_MIN := 400.0
const SPAWN_DISTANCE_MAX := 800.0

var _current_realm: int = 1
var _current_wave: int = 0
var _wave_timer: float = 0.0
var _is_resting: bool = false
var _is_boss_wave: bool = false
var _boss_timer: float = 0.0
var _enemies_alive: int = 0
var _max_enemies: int = 30
var _player: PlayerController
var _enemy_pool: ObjectPool
var _active_enemies: Array[BaseEnemy] = []

func _ready() -> void:
	_update_max_enemies()

func _physics_process(delta: float) -> void:
	if _is_resting:
		_wave_timer -= delta
		if _wave_timer <= 0.0:
			_is_resting = false
			_start_next_wave()
		return
	
	if _is_boss_wave:
		_boss_timer -= delta
		if _boss_timer <= 0.0:
			_spawn_boss()
			_is_boss_wave = false
		return

func set_player(player: PlayerController) -> void:
	_player = player

func set_enemy_pool(pool: ObjectPool) -> void:
	_enemy_pool = pool

func set_realm(realm: int) -> void:
	_current_realm = realm
	_current_wave = 0
	_update_max_enemies()

func _update_max_enemies() -> void:
	_max_enemies = 30 + 30 * (_current_realm - 1)

func start_waves() -> void:
	_current_wave = 0
	_start_next_wave()

func _start_next_wave() -> void:
	_current_wave += 1
	if _current_wave > WAVES_PER_REALM:
		_complete_realm()
		return
	
	wave_started.emit(_current_wave)
	
	if _current_wave == WAVES_PER_REALM:
		_is_boss_wave = true
		_boss_timer = BOSS_SPAWN_DELAY
	else:
		_spawn_wave_enemies()

func _spawn_wave_enemies() -> void:
	var enemy_count := _calculate_enemy_count()
	for i in enemy_count:
		if _enemies_alive >= _max_enemies:
			break
		_spawn_enemy()

func _calculate_enemy_count() -> int:
	var base_count := 5 + _current_wave * 2
	return mini(base_count, _max_enemies - _enemies_alive)

func _spawn_enemy() -> void:
	if _enemy_pool == null or _player == null:
		return
	
	var enemy := _enemy_pool.get_instance() as BaseEnemy
	if enemy == null:
		return
	
	var spawn_pos := _get_spawn_position()
	enemy.global_position = spawn_pos
	enemy.set_target(_player)
	enemy.died.connect(_on_enemy_died)
	_enemies_alive += 1
	_active_enemies.append(enemy)

func _get_spawn_position() -> Vector2:
	var angle := randf() * TAU
	var distance := randf_range(SPAWN_DISTANCE_MIN, SPAWN_DISTANCE_MAX)
	var offset := Vector2(cos(angle), sin(angle)) * distance
	return _player.global_position + offset

func _spawn_boss() -> void:
	if _enemy_pool == null or _player == null:
		return
	
	var boss := _enemy_pool.get_instance() as BaseEnemy
	if boss == null:
		return
	
	var spawn_pos := _player.global_position + Vector2(600, 0)
	boss.global_position = spawn_pos
	boss.set_target(_player)
	boss.died.connect(_on_boss_died)
	_enemies_alive += 1
	_active_enemies.append(boss)
	boss_spawned.emit(boss)

func _on_enemy_died(enemy: BaseEnemy) -> void:
	_enemies_alive -= 1
	_active_enemies.erase(enemy)
	if _enemies_alive <= 0 and not _is_boss_wave:
		_wave_completed()

func _on_boss_died(enemy: BaseEnemy) -> void:
	_enemies_alive -= 1
	_active_enemies.erase(enemy)
	_wave_completed()

func _wave_completed() -> void:
	wave_completed.emit(_current_wave)
	if _current_wave < WAVES_PER_REALM:
		_is_resting = true
		_wave_timer = WAVE_REST_TIME
	else:
		_complete_realm()

func _complete_realm() -> void:
	pass

func get_current_wave() -> int:
	return _current_wave

func get_enemies_alive() -> int:
	return _enemies_alive

func get_active_enemies() -> Array[BaseEnemy]:
	return _active_enemies