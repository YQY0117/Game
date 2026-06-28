class_name TechniqueManager
extends Node

signal technique_fired(technique: TechniqueData, position: Vector2, direction: Vector2)

const MAX_SLOTS := 7

var _equipped_techniques: Array[TechniqueData] = []
var _cooldown_timers: Array[float] = []
var _owner: PlayerController
var _enemies: Array[BaseEnemy] = []
var _detection_range: float = 500.0

func _ready() -> void:
	_setup_slots()

func _setup_slots() -> void:
	for i in MAX_SLOTS:
		_equipped_techniques.append(null)
		_cooldown_timers.append(0.0)

func set_owner(owner: PlayerController) -> void:
	_owner = owner

func set_enemies(enemies: Array[BaseEnemy]) -> void:
	_enemies = enemies

func equip_technique(slot: int, technique: TechniqueData) -> void:
	if slot < 0 or slot >= MAX_SLOTS:
		return
	_equipped_techniques[slot] = technique
	_cooldown_timers[slot] = 0.0

func unequip_technique(slot: int) -> void:
	if slot < 0 or slot >= MAX_SLOTS:
		return
	_equipped_techniques[slot] = null
	_cooldown_timers[slot] = 0.0

func _physics_process(delta: float) -> void:
	if _owner == null:
		return
	
	for i in MAX_SLOTS:
		var technique := _equipped_techniques[i]
		if technique == null:
			continue
		
		_cooldown_timers[i] -= delta
		if _cooldown_timers[i] <= 0.0:
			var target := _find_nearest_enemy()
			if target != null:
				_fire_technique(technique, target)
				_cooldown_timers[i] = technique.cooldown

func _find_nearest_enemy() -> BaseEnemy:
	if _enemies.is_empty():
		return null
	
	var nearest: BaseEnemy = null
	var nearest_dist := _detection_range
	
	for enemy in _enemies:
		if enemy == null or enemy.is_dead():
			continue
		var dist := _owner.global_position.distance_to(enemy.global_position)
		if dist < nearest_dist:
			nearest = enemy
			nearest_dist = dist
	
	return nearest

func _fire_technique(technique: TechniqueData, target: BaseEnemy) -> void:
	var direction := (target.global_position - _owner.global_position).normalized()
	technique_fired.emit(technique, _owner.global_position, direction)

func get_equipped_techniques() -> Array[TechniqueData]:
	return _equipped_techniques

func get_cooldown_timer(slot: int) -> float:
	if slot < 0 or slot >= MAX_SLOTS:
		return 0.0
	return _cooldown_timers[slot]