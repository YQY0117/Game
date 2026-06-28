extends GdUnitTestSuite
class_name MobBasicTest

var _ink_drop: InkDrop
var _scattered_ink: ScatteredInk
var _player: PlayerController

func before_test() -> void:
	_player = PlayerController.new()
	_player.global_position = Vector2(500, 500)
	_ink_drop = InkDrop.new()
	_ink_drop.set_target(_player)
	_scattered_ink = ScatteredInk.new()
	_scattered_ink.set_target(_player)

func after_test() -> void:
	_ink_drop.free()
	_scattered_ink.free()
	_player.free()

func test_ink_drop_seeks_player() -> void:
	_ink_drop.global_position = Vector2(0, 0)
	_ink_drop._update_movement(0.016)
	assert_float(_ink_drop.velocity.length()).is_greater(0.0)
	assert_float(_ink_drop.velocity.x).is_greater(0.0)

func test_scattered_ink_seeks_with_sine() -> void:
	_scattered_ink.global_position = Vector2(0, 0)
	_scattered_ink._update_movement(0.016)
	assert_float(_scattered_ink.velocity.length()).is_greater(0.0)

func test_ink_drop_speed_ratio() -> void:
	_ink_drop._base_speed = 100.0
	_ink_drop.set_enemy_type(BaseEnemy.EnemyType.INK_DROP)
	assert_float(_ink_drop._move_speed).is_equal(70.0)

func test_scattered_ink_speed_ratio() -> void:
	_scattered_ink._base_speed = 100.0
	_scattered_ink.set_enemy_type(BaseEnemy.EnemyType.SCATTERED_INK)
	assert_float(_scattered_ink._move_speed).is_equal(85.0)

func test_ink_drop_health() -> void:
	assert_float(_ink_drop.get_health()).is_equal(10.0)

func test_scattered_ink_health() -> void:
	assert_float(_scattered_ink.get_health()).is_equal(12.0)

func test_take_damage() -> void:
	_ink_drop.take_damage(5.0)
	assert_float(_ink_drop.get_health()).is_equal(5.0)

func test_die_at_zero_health() -> void:
	var died_count := 0
	_ink_drop.died.connect(func(enemy): died_count += 1)
	_ink_drop.take_damage(10.0)
	assert_int(died_count).is_equal(1)
	assert_bool(_ink_drop.is_dead()).is_true()