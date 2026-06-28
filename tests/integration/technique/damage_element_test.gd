extends GdUnitTestSuite
class_name DamageElementTest

var _projectile: Projectile
var _technique: TechniqueData
var _enemy: InkDrop

func before_test() -> void:
	_technique = TechniqueData.new()
	_technique.id = "flame_palm"
	_technique.cooldown = 1.2
	_technique.base_damage = 5.0
	_technique.element = TechniqueData.Element.FIRE
	_technique.projectile_speed = 300.0
	
	_projectile = Projectile.new()
	_projectile.setup(_technique, Vector2.RIGHT, 100)
	
	_enemy = InkDrop.new()
	_enemy.global_position = Vector2(100, 0)

func after_test() -> void:
	_projectile.free()
	_enemy.free()

func test_projectile_setup() -> void:
	assert_float(_projectile._damage).is_equal(5.0)
	assert_str(_projectile._element).is_equal("fire")
	assert_float(_projectile._speed).is_equal(300.0)

func test_projectile_moves() -> void:
	var initial_pos := _projectile.position
	_projectile._physics_process(0.016)
	assert_float(_projectile.position.x).is_greater(initial_pos.x)

func test_deal_damage_to_enemy() -> void:
	var damage_dealt := 0.0
	DamageBus.damage_dealt.connect(func(event): damage_dealt = event.raw_damage)
	_projectile._deal_damage(_enemy)
	assert_float(damage_dealt).is_equal(5.0)
	DamageBus.damage_dealt.disconnect(func(event): damage_dealt = event.raw_damage)

func test_hit_signal_emitted() -> void:
	var hit_count := 0
	_projectile.hit.connect(func(enemy): hit_count += 1)
	_projectile._deal_damage(_enemy)
	assert_int(hit_count).is_equal(1)