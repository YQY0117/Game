extends GdUnitTestSuite
class_name PoolMonitoringTest

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

func test_monitor_outputs_stats() -> void:
	_pool.monitor()
	assert_int(_pool.get_available_count()).is_equal(10)
	assert_int(_pool.get_total_count()).is_equal(10)

func test_dynamic_expansion() -> void:
	for i in 10:
		_pool.get_instance()
	assert_int(_pool.get_available_count()).is_equal(0)
	var instance := _pool.get_instance()
	assert_bool(instance != null).is_true()
	assert_int(_pool.get_total_count()).is_equal(11)

func test_return_all_recovers_instances() -> void:
	for i in 5:
		_pool.get_instance()
	_pool.return_all()
	assert_int(_pool.get_available_count()).is_equal(10)