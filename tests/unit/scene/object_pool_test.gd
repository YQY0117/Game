extends GdUnitTestSuite
class_name ObjectPoolTest

var _pool: ObjectPool
var _test_scene: PackedScene

func before_test() -> void:
	_test_scene = PackedScene.new()
	var node := Node2D.new()
	_test_scene.pack(node)
	node.free()
	_pool = ObjectPool.new(_test_scene, 10, 20)

func after_test() -> void:
	_pool.free()

func test_initial_pool_size() -> void:
	assert_int(_pool.get_available_count()).is_equal(10)
	assert_int(_pool.get_total_count()).is_equal(10)

func test_get_instance_returns_visible_node() -> void:
	var instance := _pool.get_instance()
	assert_bool(instance.visible).is_true()
	assert_bool(instance.is_processing()).is_true()

func test_get_instance_reduces_available() -> void:
	_pool.get_instance()
	assert_int(_pool.get_available_count()).is_equal(9)

func test_return_instance_hides_node() -> void:
	var instance := _pool.get_instance()
	_pool.return_instance(instance)
	assert_bool(instance.visible).is_false()
	assert_bool(instance.is_processing()).is_false()

func test_return_instance_increases_available() -> void:
	var instance := _pool.get_instance()
	_pool.return_instance(instance)
	assert_int(_pool.get_available_count()).is_equal(10)

func test_return_instance_moves_offscreen() -> void:
	var instance := _pool.get_instance()
	instance.position = Vector2(100, 100)
	_pool.return_instance(instance)
	assert_vector(instance.position).is_equal(Vector2(-1000, -1000))

func test_get_instance_creates_new_when_empty() -> void:
	for i in 10:
		_pool.get_instance()
	var instance := _pool.get_instance()
	assert_bool(instance != null).is_true()
	assert_int(_pool.get_total_count()).is_equal(11)

func test_get_instance_returns_null_at_max() -> void:
	for i in 20:
		_pool.get_instance()
	var instance := _pool.get_instance()
	assert_bool(instance == null).is_true()

func test_return_all() -> void:
	for i in 5:
		_pool.get_instance()
	_pool.return_all()
	assert_int(_pool.get_available_count()).is_equal(10)

func test_return_all_hides_all() -> void:
	for i in 5:
		_pool.get_instance()
	_pool.return_all()
	for child in _pool.get_children():
		assert_bool(child.visible).is_false()