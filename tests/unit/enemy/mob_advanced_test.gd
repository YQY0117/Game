extends GdUnitTestSuite
class_name MobAdvancedTest

var _sluggish: SluggishInk
var _flying: FlyingInk
var _cluster: ClusterInk
var _player: PlayerController

func before_test() -> void:
	_player = PlayerController.new()
	_player.global_position = Vector2(500, 500)
	_sluggish = SluggishInk.new()
	_sluggish.set_target(_player)
	_flying = FlyingInk.new()
	_flying.set_target(_player)
	_cluster = ClusterInk.new()
	_cluster.set_target(_player)

func after_test() -> void:
	_sluggish.free()
	_flying.free()
	_cluster.free()
	_player.free()

func test_sluggish_seeks_player() -> void:
	_sluggish.global_position = Vector2(0, 0)
	_sluggish._update_movement(0.016)
	assert_float(_sluggish.velocity.length()).is_greater(0.0)

func test_sluggish_speed_ratio() -> void:
	_sluggish._base_speed = 100.0
	_sluggish.set_enemy_type(BaseEnemy.EnemyType.SLUGGISH_INK)
	assert_float(_sluggish._move_speed).is_equal(55.0)

func test_flying_stays_at_distance() -> void:
	_flying.global_position = Vector2(300, 500)
	_flying._update_movement(0.016)
	assert_float(_flying.velocity.length()).is_greater(0.0)

func test_flying_speed_ratio() -> void:
	_flying._base_speed = 100.0
	_flying.set_enemy_type(BaseEnemy.EnemyType.FLYING_INK)
	assert_float(_flying._move_speed).is_equal(65.0)

func test_cluster_seeks_player() -> void:
	_cluster.global_position = Vector2(0, 0)
	_cluster._update_movement(0.016)
	assert_float(_cluster.velocity.length()).is_greater(0.0)

func test_cluster_splits_on_death() -> void:
	var split_count := 0
	_cluster.cluster_split.connect(func(pos, count): split_count = count)
	_cluster.die()
	assert_int(split_count).is_greater_equal(3)
	assert_int(split_count).is_less_equal(5)

func test_cluster_health() -> void:
	assert_float(_cluster.get_health()).is_equal(25.0)