class_name Projectile
extends Area2D

signal hit(enemy: BaseEnemy)

var _technique: TechniqueData
var _direction: Vector2 = Vector2.RIGHT
var _speed: float = 300.0
var _damage: float = 5.0
var _element: String = "fire"
var _attacker_id: int = 0
var _is_active: bool = true

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if not _is_active:
		return
	position += _direction * _speed * delta

func setup(technique: TechniqueData, direction: Vector2, attacker_id: int) -> void:
	_technique = technique
	_direction = direction.normalized()
	_speed = technique.projectile_speed
	_damage = technique.base_damage
	_element = technique.get_element_name()
	_attacker_id = attacker_id

func _on_body_entered(body: Node) -> void:
	if not _is_active:
		return
	if body is BaseEnemy:
		var enemy := body as BaseEnemy
		_deal_damage(enemy)
		_is_active = false
		queue_free()

func _deal_damage(enemy: BaseEnemy) -> void:
	var event := DamageEvent.new(
		_attacker_id,
		enemy.get_instance_id(),
		_damage,
		_element,
		1,
		false,
		global_position
	)
	DamageBus.deal_damage(
		event.attacker_id,
		event.victim_id,
		event.raw_damage,
		event.element,
		event.knockback_tier,
		event.is_crit,
		event.position
	)
	hit.emit(enemy)